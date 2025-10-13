import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:salas_beats/models/user_model.dart';
import 'package:salas_beats/services/auth_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  authenticating,
}

class AuthProvider extends ChangeNotifier {

  AuthProvider() {
    _initializeAuth();
  }
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _error;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  UserModel? get currentUser => _user; // Alias para compatibilidad
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isEmailVerified => _authService.isEmailVerified;
  bool get isAdmin => _user?.role == 'admin';
  bool get isHost => _user?.role == 'host';
  bool get isMusician => _user?.role == 'musician';

  // Verificar estado de autenticación
  Future<void> checkAuthStatus() async {
    try {
      print('🔐 AuthProvider: checkAuthStatus iniciado');
      _setLoading(true);
      final currentUser = _authService.currentUser;
      
      print('🔐 AuthProvider: currentUser = ${currentUser?.email ?? 'null'}');
      
      if (currentUser != null) {
        print('🔐 AuthProvider: Usuario encontrado, cargando datos');
        await _loadUserData(currentUser.uid);
      } else {
        print('🔐 AuthProvider: No hay usuario, estableciendo como no autenticado');
        _setUnauthenticated();
      }
    } catch (e) {
      print('❌ AuthProvider: Error en checkAuthStatus: $e');
      _setError('Error al verificar autenticación: $e');
      _setUnauthenticated();
    } finally {
      _setLoading(false);
      print('🔐 AuthProvider: checkAuthStatus completado. Status: $_status');
    }
  }

  // Inicializar provider
  Future<void> initialize() async {
    await checkAuthStatus();
  }

  // Método para establecer error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Método para establecer loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Método para establecer no autenticado
  void _setUnauthenticated() {
    _status = AuthStatus.unauthenticated;
    _user = null;
    notifyListeners();
  }

  Future<void> logout() async {
    // Unificar flujo de cierre de sesión usando signOut()
    // para asegurar que también se cierra sesión de Google
    // y se actualiza el estado inmediatamente.
    await signOut();
  }

  // Inicializar autenticación
  void _initializeAuth() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      // Evitar notificaciones durante navegaciones activas
      await Future<void>.delayed(const Duration(milliseconds: 100));
      
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      } else {
        _setUnauthenticated();
      }
    });
  }

  // Cargar datos del usuario
  Future<void> _loadUserData(String userId) async {
    try {
      print('👤 AuthProvider: _loadUserData iniciado para userId: $userId');
      final userData = await _authService.getCurrentUserData();
      
      print('👤 AuthProvider: userData obtenido: ${userData?.email ?? 'null'}');
      
      if (userData != null) {
        _user = userData;
        _status = AuthStatus.authenticated;
        _error = null;
        print('👤 AuthProvider: Usuario cargado exitosamente');
      } else {
        print('👤 AuthProvider: No se pudieron cargar los datos del usuario');
        _setUnauthenticated();
      }
    } catch (e) {
      print('❌ AuthProvider: Error en _loadUserData: $e');
      _error = 'Error al cargar datos del usuario: ${e.toString()}';
      _setUnauthenticated();
    }
    notifyListeners();
  }



  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Registro con email y contraseña
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
  }) async {
    _setLoading(true);
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      // Validaciones adicionales en el frontend
      if (email.trim().isEmpty) {
        _error = 'El email es requerido';
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
      }
      
      if (password.length < 8) {
        _error = 'La contraseña debe tener al menos 8 caracteres';
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
      }
      
      if (name.trim().isEmpty) {
        _error = 'El nombre es requerido';
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
      }
      
      if (role.trim().isEmpty) {
        _error = 'El rol es requerido';
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
      }

      final result = await _authService.registerWithEmailAndPassword(
        email: email.trim(),
        password: password,
        name: name.trim(),
        role: role.trim(),
        phone: phone?.trim(),
      );

      if (result.success) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado durante el registro';
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  // Login con email y contraseña
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      // Validaciones adicionales en el frontend
      if (email.trim().isEmpty) {
        _error = 'El email es requerido';
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
      }
      
      if (password.isEmpty) {
        _error = 'La contraseña es requerida';
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
      }

      final result = await _authService.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.success) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado durante el login';
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  // Login con Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final result = await _authService.signInWithGoogle();

      if (result.success) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado durante el login con Google';
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  // Login con Apple
  Future<bool> signInWithApple() async {
    _setLoading(true);
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final result = await _authService.signInWithApple();

      if (result.success) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado durante el login con Apple';
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  // Cerrar sesión
  Future<bool> signOut() async {
    _setLoading(true);

    try {
      final result = await _authService.signOut();
      
      if (result.success) {
        _setUnauthenticated();
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error al cerrar sesión';
      _setLoading(false);
      return false;
    }
  }

  // Enviar email de verificación
  Future<bool> sendEmailVerification() async {
    _setLoading(true);

    try {
      final result = await _authService.sendEmailVerification();
      
      if (result.success) {
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error al enviar email de verificación';
      _setLoading(false);
      return false;
    }
  }

  // Recargar usuario
  Future<bool> reloadUser() async {
    try {
      final result = await _authService.reloadUser();
      
      if (result.success) {
        // Recargar datos del usuario
        if (_authService.currentUser != null) {
          await _loadUserData(_authService.currentUser!.uid);
        }
        return true;
      } else {
        _error = result.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error al recargar usuario';
      notifyListeners();
      return false;
    }
  }

  // Restablecer contraseña
  Future<bool> resetPassword(String email) async {
    _setLoading(true);

    try {
      final result = await _authService.resetPassword(email);
      
      if (result.success) {
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error al restablecer contraseña';
      _setLoading(false);
      return false;
    }
  }

  // Cambiar contraseña
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);

    try {
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      if (result.success) {
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error al cambiar contraseña';
      _setLoading(false);
      return false;
    }
  }

  // Actualizar perfil
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? photoURL,
  }) async {
    _setLoading(true);

    try {
      final result = await _authService.updateProfile(
        name: name,
        phone: phone,
        photoURL: photoURL,
      );
      
      if (result.success) {
        // Recargar datos del usuario
        if (_authService.currentUser != null) {
          await _loadUserData(_authService.currentUser!.uid);
        }
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error al actualizar perfil';
      _setLoading(false);
      return false;
    }
  }

  // Eliminar cuenta
  Future<bool> deleteAccount(String password) async {
    _setLoading(true);

    try {
      final result = await _authService.deleteAccount(password);
      
      if (result.success) {
        _setUnauthenticated();
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error al eliminar cuenta';
      _setLoading(false);
      return false;
    }
  }

  // Actualizar rol del usuario (solo para admins)
  Future<bool> updateUserRole(String userId, String newRole) async {
    if (!isAdmin) {
      _error = 'No tienes permisos para realizar esta acción';
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      // Aquí implementarías la lógica para actualizar el rol
      // Esto normalmente se haría a través de Cloud Functions
      // por seguridad
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Error al actualizar rol del usuario';
      _setLoading(false);
      return false;
    }
  }

  // Verificar permisos
  bool hasPermission(String permission) {
    if (_user == null) return false;
    
    switch (permission) {
      case 'admin_panel':
        return isAdmin;
      case 'host_dashboard':
        return isHost || isAdmin;
      case 'create_listing':
        return isHost || isAdmin;
      case 'manage_bookings':
        return isHost || isAdmin;
      case 'view_analytics':
        return isHost || isAdmin;
      case 'manage_users':
        return isAdmin;
      case 'manage_settings':
        return isAdmin;
      default:
        return false;
    }
  }

  // Obtener nombre de usuario para mostrar
  String get displayName {
    if (_user?.name != null && _user!.name.isNotEmpty) {
      return _user!.name;
    }
    if (_user?.email != null) {
      return _user!.email.split('@').first;
    }
    return 'Usuario';
  }

  // Obtener iniciales del usuario
  String get userInitials {
    final name = displayName;
    if (name.isEmpty) return 'U';
    
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // Obtener URL de foto de perfil
  String? get profilePhotoUrl => _user?.photoURL;

  // Verificar si necesita completar perfil
  bool get needsProfileCompletion {
    if (_user == null) return false;
    
    // Verificar campos obligatorios según el rol
    if (_user!.name.isEmpty) return true;
    if (!_user!.verified) return true;
    
    if (isHost) {
      // Los hosts necesitan más información
      if (_user!.phone == null || _user!.phone!.isEmpty) return true;
    }
    
    return false;
  }

  // Obtener progreso de completación del perfil
  double get profileCompletionProgress {
    if (_user == null) return 0;
    
    var completed = 0;
    var total = 4; // Campos básicos
    
    if (_user!.name.isNotEmpty) completed++;
    if (_user!.email.isNotEmpty) completed++;
    if (_user!.verified) completed++;
    if (_user!.photoURL != null) completed++;
    
    if (isHost) {
      total += 2; // Campos adicionales para hosts
      if (_user!.phone != null && _user!.phone!.isNotEmpty) completed++;
      // Aquí podrías agregar verificación de KYC, etc.
    }
    
    return completed / total;
  }

  // Completar onboarding
  Future<bool> completeOnboarding() async {
    _setLoading(true);

    try {
      final result = await _authService.completeOnboarding();
      
      if (result.success) {
        // Recargar datos del usuario para reflejar el cambio
        if (_authService.currentUser != null) {
          await _loadUserData(_authService.currentUser!.uid);
        }
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error al completar onboarding';
      _setLoading(false);
      return false;
    }
  }

}