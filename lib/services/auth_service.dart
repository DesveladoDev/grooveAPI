import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:salas_beats/config/constants.dart';
import 'package:salas_beats/firebase_options.dart';
import 'package:salas_beats/models/host_model.dart';
import 'package:salas_beats/models/user_model.dart' as UserModel;
import 'package:salas_beats/utils/validation_service.dart';
import 'package:salas_beats/utils/error_handler.dart';
import 'package:salas_beats/utils/profile_error_handler.dart';

class AuthResult {

  AuthResult({
    required this.success,
    this.error,
    this.user,
    this.message,
  });

  factory AuthResult.success({UserModel.UserModel? user, String? message}) => AuthResult(
      success: true,
      user: user,
      message: message,
    );

  factory AuthResult.failure(String error) => AuthResult(
      success: false,
      error: error,
    );
  final bool success;
  final String? error;
  final UserModel.UserModel? user;
  final String? message;
}

class AuthService {
  factory AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firebaseFirestore,
    GoogleSignIn? googleSignIn,
    ValidationService? validationService,
  }) {
    if (firebaseAuth != null || firebaseFirestore != null || googleSignIn != null || validationService != null) {
      // Return a new instance for testing
      return AuthService._internal(
        firebaseAuth: firebaseAuth,
        firebaseFirestore: firebaseFirestore,
        googleSignIn: googleSignIn,
        validationService: validationService,
      );
    }
    return _instance;
  }
  
  AuthService._internal({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firebaseFirestore,
    GoogleSignIn? googleSignIn,
    ValidationService? validationService,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firebaseFirestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(
         clientId: DefaultFirebaseOptions.currentPlatform.iosClientId,
       ),
       _validationService = validationService ?? ValidationService();
  
  static final AuthService _instance = AuthService._internal();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final ValidationService _validationService;

  // Stream del usuario actual
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Usuario actual
  User? get currentUser => _auth.currentUser;
  
  // Verificar si el usuario está autenticado
  bool get isAuthenticated => currentUser != null;
  
  // Verificar si el email está verificado
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Registro con email y contraseña
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role, // 'musician' o 'host'
    String? phone,
  }) async {
    try {
      // Usar validaciones centralizadas
      final validationResult = _validationService.validateUserData(
        email: email,
        name: name,
        phone: phone,
      );
      
      // Validar contraseña por separado
      final passwordValidation = _validationService.validatePassword(password);
      
      if (!validationResult.isValid) {
        return AuthResult.failure(validationResult.errors.first);
      }
      
      if (!passwordValidation.isValid) {
        return AuthResult.failure(passwordValidation.errors.first);
      }
      
      // Validar rol específico
      if (!['musician', 'host'].contains(role)) {
        return AuthResult.failure('Rol inválido. Debe ser "musician" o "host"');
      }

      // Crear usuario en Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return AuthResult.failure('Error al crear la cuenta');
      }

      // Actualizar el nombre del usuario
      await firebaseUser.updateDisplayName(name);

      // Crear documento del usuario en Firestore
      final userModel = UserModel.UserModel(
        id: firebaseUser.uid,
        role: UserModel.UserRole.values.firstWhere((e) => e.toString().split('.').last == role, orElse: () => UserModel.UserRole.musician),
        name: name,
        email: email.trim().toLowerCase(),
        phone: phone,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set(userModel.toFirestore());

      // Si es host, crear documento de host
      if (role == 'host') {
        final hostModel = HostModel(
          userId: firebaseUser.uid,
          stats: HostStats(
            
          ),
          createdAt: DateTime.now(),
        );

        await _firestore.collection('hosts').doc(firebaseUser.uid).set(hostModel.toFirestore());
      }

      // Enviar email de verificación
      await sendEmailVerification();

      return AuthResult.success(
        user: userModel,
        message: 'Cuenta creada exitosamente. Por favor verifica tu email.',
      );
    } catch (e, stackTrace) {
      final appError = ProfileErrorHandler.handleProfileCreationError(e, stackTrace: stackTrace);
      ErrorHandler.logError(appError);
      return AuthResult.failure(appError.message);
    }
  }

  // Login con email y contraseña
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Usar validaciones centralizadas
      final emailValidation = _validationService.validateEmail(email);
      if (!emailValidation.isValid) {
        return AuthResult.failure(emailValidation.errors.first);
      }
      
      final passwordValidation = _validationService.validatePassword(password);
      if (!passwordValidation.isValid) {
        return AuthResult.failure(passwordValidation.errors.first);
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return AuthResult.failure('Error al iniciar sesión');
      }

      // Obtener datos del usuario desde Firestore
      var userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      // Si el documento no existe, intentamos crearlo para no bloquear el login
      if (!userDoc.exists) {
        final createResult = await createMissingUserDocument();
        if (!createResult.success) {
          return AuthResult.failure(createResult.error ?? 'No se pudo crear el documento de usuario');
        }
        // Reintentar obtener el documento
        userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (!userDoc.exists) {
          return AuthResult.failure('Usuario no encontrado tras crear documento');
        }
      }

      final userModel = UserModel.UserModel.fromFirestore(userDoc);

      // Actualizar última fecha de actividad
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return AuthResult.success(
        user: userModel,
        message: 'Sesión iniciada exitosamente',
      );
    } catch (e, stackTrace) {
      final appError = ErrorHandler.handleException(e, stackTrace: stackTrace);
      ErrorHandler.logError(appError);
      return AuthResult.failure(appError.message);
    }
  }

  // Login con Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.failure('Inicio de sesión con Google cancelado por el usuario');
      }

      final googleAuth = await googleUser.authentication;
      
      // Validar que se obtuvieron los tokens necesarios
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return AuthResult.failure('Error al obtener credenciales de Google');
      }
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      
      if (firebaseUser == null) {
        return AuthResult.failure('Error al iniciar sesión con Google');
      }

      // Verificar si es un usuario nuevo
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      UserModel.UserModel userModel;
      if (!userDoc.exists) {
        // Usuario nuevo, crear documento con rol temporal
        // El usuario deberá completar el onboarding para seleccionar su rol
        userModel = UserModel.UserModel(
          id: firebaseUser.uid,
          role: UserModel.UserRole.guest, // Rol temporal hasta completar onboarding
          name: firebaseUser.displayName ?? 'Usuario',
          email: firebaseUser.email ?? '',
          phone: firebaseUser.phoneNumber,
          photoURL: firebaseUser.photoURL,
          verified: firebaseUser.emailVerified,
          createdAt: DateTime.now(),
          isOnboardingComplete: false, // Requiere completar onboarding
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(userModel.toFirestore());
      } else {
        userModel = UserModel.UserModel.fromFirestore(userDoc);
        
        // Actualizar información si es necesario
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
          'photoURL': firebaseUser.photoURL,
        });
      }

      return AuthResult.success(
        user: userModel,
        message: 'Sesión iniciada con Google exitosamente',
      );
    } catch (e) {
      return AuthResult.failure('Error al iniciar sesión con Google: ${e.toString()}');
    }
  }

  // Login con Apple
  Future<AuthResult> signInWithApple() async {
    try {
      // Verificar disponibilidad de Apple Sign-In
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        return AuthResult.failure('Apple Sign-In no está disponible en este dispositivo');
      }

      // Solicitar credenciales de Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Crear credencial de Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Iniciar sesión con Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final firebaseUser = userCredential.user;
      
      if (firebaseUser == null) {
        return AuthResult.failure('Error al iniciar sesión con Apple');
      }

      // Verificar si es un usuario nuevo
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      UserModel.UserModel userModel;
      if (!userDoc.exists) {
        // Usuario nuevo, crear documento
        // Construir nombre completo desde Apple credential
        String displayName = firebaseUser.displayName ?? '';
        if (displayName.isEmpty && appleCredential.givenName != null) {
          displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        }
        if (displayName.isEmpty) {
          displayName = 'Usuario Apple';
        }

        userModel = UserModel.UserModel(
          id: firebaseUser.uid,
          role: UserModel.UserRole.guest, // Rol temporal hasta completar onboarding
          name: displayName,
          email: firebaseUser.email ?? '',
          phone: firebaseUser.phoneNumber,
          photoURL: firebaseUser.photoURL,
          verified: firebaseUser.emailVerified,
          createdAt: DateTime.now(),
          isOnboardingComplete: false, // Requiere completar onboarding
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(userModel.toFirestore());
      } else {
        userModel = UserModel.UserModel.fromFirestore(userDoc);
        
        // Actualizar información si es necesario
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }

      return AuthResult.success(
        user: userModel,
        message: 'Sesión iniciada con Apple exitosamente',
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          return AuthResult.failure('Inicio de sesión con Apple cancelado por el usuario');
        case AuthorizationErrorCode.failed:
          return AuthResult.failure('Error en la autorización de Apple');
        case AuthorizationErrorCode.invalidResponse:
          return AuthResult.failure('Respuesta inválida de Apple');
        case AuthorizationErrorCode.notHandled:
          return AuthResult.failure('Solicitud no manejada por Apple');
        case AuthorizationErrorCode.unknown:
        default:
          return AuthResult.failure('Error desconocido en Apple Sign-In');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Error al iniciar sesión con Apple: ${e.toString()}');
    }
  }

  // Cerrar sesión
  Future<AuthResult> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      return AuthResult.success(message: 'Sesión cerrada exitosamente');
    } catch (e) {
      return AuthResult.failure('Error al cerrar sesión: ${e.toString()}');
    }
  }

  // Enviar email de verificación
  Future<AuthResult> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('No hay usuario autenticado');
      }

      if (user.emailVerified) {
        return AuthResult.failure('El email ya está verificado');
      }

      await user.sendEmailVerification();
      return AuthResult.success(message: 'Email de verificación enviado');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Error al enviar email de verificación: ${e.toString()}');
    }
  }

  // Recargar usuario para verificar email
  Future<AuthResult> reloadUser() async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('No hay usuario autenticado');
      }

      await user.reload();
      
      // Actualizar estado de verificación en Firestore
      if (user.emailVerified) {
        await _firestore.collection('users').doc(user.uid).update({
          'verified': true,
          'emailVerifiedAt': FieldValue.serverTimestamp(),
        });
      }

      return AuthResult.success(message: 'Usuario actualizado');
    } catch (e) {
      return AuthResult.failure('Error al actualizar usuario: ${e.toString()}');
    }
  }

  // Restablecer contraseña
  Future<AuthResult> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        return AuthResult.failure('El email es obligatorio');
      }

      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
      return AuthResult.success(message: 'Email de restablecimiento enviado');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Error al enviar email de restablecimiento: ${e.toString()}');
    }
  }

  // Cambiar contraseña
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('No hay usuario autenticado');
      }

      if (newPassword.length < 6) {
        return AuthResult.failure('La nueva contraseña debe tener al menos 6 caracteres');
      }

      // Reautenticar usuario
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return AuthResult.success(message: 'Contraseña actualizada exitosamente');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Error al cambiar contraseña: ${e.toString()}');
    }
  }

  // Actualizar perfil
  Future<AuthResult> updateProfile({
    String? name,
    String? phone,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('No hay usuario autenticado');
      }

      // Validar datos del perfil antes de actualizar
      final profileData = {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (photoURL != null) 'photoURL': photoURL,
      };

      final validationError = ProfileErrorHandler.validateProfileData(profileData);
      if (validationError != null) {
        return AuthResult.failure(validationError.message);
      }

      final updates = <String, dynamic>{};
      
      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
        updates['name'] = name;
      }
      
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
        updates['photoURL'] = photoURL;
      }
      
      if (phone != null) {
        updates['phone'] = phone;
      }

      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('users').doc(user.uid).update(updates);
      }

      return AuthResult.success(message: 'Perfil actualizado exitosamente');
    } catch (e, stackTrace) {
      final appError = ProfileErrorHandler.handleProfileUpdateError(e, stackTrace: stackTrace);
      ErrorHandler.logError(appError);
      return AuthResult.failure(appError.message);
    }
  }

  // Eliminar cuenta
  Future<AuthResult> deleteAccount(String password) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('No hay usuario autenticado');
      }

      // Reautenticar usuario
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Eliminar datos del usuario de Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Si es host, eliminar datos de host
      final hostDoc = await _firestore.collection('hosts').doc(user.uid).get();
      if (hostDoc.exists) {
        await _firestore.collection('hosts').doc(user.uid).delete();
      }

      // Eliminar cuenta de Firebase Auth
      await user.delete();

      return AuthResult.success(message: 'Cuenta eliminada exitosamente');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Error al eliminar cuenta: ${e.toString()}');
    }
  }

  // Obtener datos del usuario actual
  Future<UserModel.UserModel?> getCurrentUserData() async {
    try {
      print('🔍 AuthService: getCurrentUserData iniciado');
      final user = currentUser;
      
      print('🔍 AuthService: currentUser = ${user?.email ?? 'null'}');
      
      if (user == null) {
        print('🔍 AuthService: No hay usuario actual, retornando null');
        return null;
      }

      print('🔍 AuthService: Obteniendo documento de usuario para uid: ${user.uid}');
      var userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      print('🔍 AuthService: Documento existe: ${userDoc.exists}');
      
      if (!userDoc.exists) {
        print('🔍 AuthService: Documento de usuario no existe, intento de creación');
        final createResult = await createMissingUserDocument();
        if (!createResult.success) {
          print('❌ AuthService: No se pudo crear el documento: ${createResult.error}');
          return null;
        }
        // Reintentar obtener el documento
        userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          print('❌ AuthService: El documento sigue sin existir tras creación');
          return null;
        }
      }

      print('🔍 AuthService: Creando UserModel desde Firestore');
      final userModel = UserModel.UserModel.fromFirestore(userDoc);
      print('🔍 AuthService: UserModel creado exitosamente: ${userModel.email}');
      
      return userModel;
    } catch (e) {
      print('❌ AuthService: Error en getCurrentUserData: $e');
      return null;
    }
  }

  // Verificar si el usuario es admin
  Future<bool> isAdmin() async {
    try {
      final userData = await getCurrentUserData();
      return userData?.role == UserModel.UserRole.admin;
    } catch (e) {
      return false;
    }
  }

  // Verificar si el usuario es host
  Future<bool> isHost() async {
    try {
      final userData = await getCurrentUserData();
      return userData?.role == UserModel.UserRole.host;
    } catch (e) {
      return false;
    }
  }

  // MÉTODO TEMPORAL: Crear usuario faltante en Firestore
  Future<AuthResult> createMissingUserDocument() async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('No hay usuario autenticado');
      }

      // Verificar si el documento ya existe
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return AuthResult.success(message: 'El documento del usuario ya existe');
      }

      // Crear documento del usuario con rol temporal
      final userModel = UserModel.UserModel(
        id: user.uid,
        role: UserModel.UserRole.guest, // Rol temporal hasta completar onboarding
        name: user.displayName ?? 'Usuario',
        email: user.email ?? '',
        phone: user.phoneNumber,
        photoURL: user.photoURL,
        verified: user.emailVerified,
        createdAt: DateTime.now(),
        isOnboardingComplete: false, // Requiere completar onboarding
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toFirestore());

      return AuthResult.success(
        user: userModel,
        message: 'Documento de usuario creado exitosamente',
      );
    } catch (e) {
      return AuthResult.failure('Error al crear documento de usuario: ${e.toString()}');
    }
  }

  // Marcar onboarding como completado
  Future<AuthResult> completeOnboarding() async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('No hay usuario autenticado');
      }

      // Actualizar el documento del usuario en Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'isOnboardingComplete': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return AuthResult.success(message: 'Onboarding completado exitosamente');
    } catch (e) {
      return AuthResult.failure('Error al completar onboarding: ${e.toString()}');
    }
  }

  // Obtener mensajes de error en español
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No existe una cuenta con este email';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este email';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-email':
        return 'El email no es válido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'requires-recent-login':
        return 'Necesitas iniciar sesión nuevamente';
      case 'credential-already-in-use':
        return 'Esta credencial ya está en uso';
      case 'invalid-credential':
        return 'Credencial inválida';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con un método de login diferente';
      default:
        return 'Error de autenticación: $errorCode';
    }
  }

  // Actualizar rol del usuario después del onboarding
  Future<AuthResult> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      print('🔄 AuthService: Actualizando rol de usuario $userId a $role');
      
      // Validar que el rol sea válido
      if (!['musician', 'host'].contains(role)) {
        return AuthResult.failure('Rol inválido. Debe ser "musician" o "host"');
      }

      // Obtener el documento actual del usuario
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return AuthResult.failure('Usuario no encontrado');
      }

      // Convertir string a enum
      final userRole = UserModel.UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == role,
        orElse: () => UserModel.UserRole.guest,
      );

      // Actualizar el documento con el nuevo rol y marcar onboarding como completo
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'isOnboardingComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Obtener el usuario actualizado
      final updatedUserDoc = await _firestore.collection('users').doc(userId).get();
      final updatedUser = UserModel.UserModel.fromFirestore(updatedUserDoc);

      print('✅ AuthService: Rol actualizado exitosamente a $role');
      return AuthResult.success(
        user: updatedUser,
        message: 'Rol actualizado exitosamente',
      );
    } catch (e) {
      print('❌ AuthService: Error al actualizar rol: $e');
      return AuthResult.failure('Error al actualizar el rol: ${e.toString()}');
    }
  }

  // Verificar si el usuario necesita completar el onboarding
  Future<bool> needsOnboarding() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return true;

      final userData = UserModel.UserModel.fromFirestore(userDoc);
      return !userData.isOnboardingComplete || userData.role == UserModel.UserRole.guest;
    } catch (e) {
      print('❌ AuthService: Error al verificar onboarding: $e');
      return false;
    }
  }
}