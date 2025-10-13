import 'package:flutter_test/flutter_test.dart';
import 'package:salas_beats/services/auth_service.dart';
import '../firebase_test_helpers.dart';

void main() {
  group('AuthService Integration Tests', () {
    late AuthService authService;

    setUpAll(() async {
      await FirebaseTestHelpers.initializeFirebaseForTesting();
    });

    setUp(() {
      authService = AuthService();
    });

    tearDown(() async {
      await FirebaseTestHelpers.clearEmulatorData();
    });

    group('Email Authentication', () {
      test('should register user with email and password', () async {
        await FirebaseTestHelpers.runWithFirebase(() async {
          // Arrange
          const email = 'test@example.com';
          const password = 'testPassword123';
          const displayName = 'Test User';

          // Act
          final result = await authService.registerWithEmail(
            email: email,
            password: password,
            displayName: displayName,
          );

          // Assert
          expect(result.success, isTrue);
          expect(result.user, isNotNull);
          expect(result.user!.email, equals(email));
          expect(result.user!.displayName, equals(displayName));
          expect(result.errorMessage, isNull);

          // Verificar que el usuario se creó en Firestore
          final userDoc = await FirebaseTestHelpers.firestore
              .collection('users')
              .doc(result.user!.uid)
              .get();
          
          expect(userDoc.exists, isTrue);
          expect(userDoc.data()!['email'], equals(email));
          expect(userDoc.data()!['displayName'], equals(displayName));
        });
      });

      test('should fail to register with invalid email', () async {
        await FirebaseTestHelpers.runWithFirebase(() async {
          // Arrange
          const invalidEmail = 'invalid-email';
          const password = 'testPassword123';

          // Act
          final result = await authService.registerWithEmail(
            email: invalidEmail,
            password: password,
            displayName: 'Test User',
          );

          // Assert
          expect(result.success, isFalse);
          expect(result.user, isNull);
          expect(result.errorMessage, isNotNull);
          expect(result.errorMessage, contains('email'));
        });
      });

      test('should fail to register with weak password', () async {
        await FirebaseTestHelpers.runWithFirebase(() async {
          // Arrange
          const email = 'test@example.com';
          const weakPassword = '123';

          // Act
          final result = await authService.registerWithEmail(
            email: email,
            password: weakPassword,
            displayName: 'Test User',
          );

          // Assert
          expect(result.success, isFalse);
          expect(result.user, isNull);
          expect(result.errorMessage, isNotNull);
          expect(result.errorMessage, contains('password'));
        });
      });

      test('should login with valid credentials', () async {
        await FirebaseTestHelpers.runWithFirebase(() async {
          // Arrange - Crear usuario primero
          const email = 'test@example.com';
          const password = 'testPassword123';
          
          await authService.registerWithEmail(
            email: email,
            password: password,
            displayName: 'Test User',
          );
          
          // Logout para poder hacer login
          await authService.signOut();

          // Act
          final result = await authService.signInWithEmail(
            email: email,
            password: password,
          );

          // Assert
          expect(result.success, isTrue);
          expect(result.user, isNotNull);
          expect(result.user!.email, equals(email));
          expect(result.errorMessage, isNull);
        });
      });

      test('should fail to login with invalid credentials', () async {
        await FirebaseTestHelpers.runWithFirebase(() async {
          // Arrange
          const email = 'nonexistent@example.com';
          const password = 'wrongPassword';

          // Act
          final result = await authService.signInWithEmail(
            email: email,
            password: password,
          );

          // Assert
          expect(result.success, isFalse);
          expect(result.user, isNull);
          expect(result.errorMessage, isNotNull);
        });
      });
    });

    group('User Data Management', () {
      test('should get user data after registration', () async {
        await FirebaseTestHelpers.runWithFirebase(() async {
          // Arrange
          const email = 'test@example.com';
          const password = 'testPassword123';
          const displayName = 'Test User';

          final registerResult = await authService.registerWithEmail(
            email: email,
            password: password,
            displayName: displayName,
          );

          // Act
          final userData = await authService.getUserData(registerResult.user!.uid);

          // Assert
          expect(userData, isNotNull);
          expect(userData!['email'], equals(email));
          expect(userData['displayName'], equals(displayName));
          expect(userData['role'], equals('musician')); // Default role
          expect(userData['createdAt'], isNotNull);
        });
      });

      test('should update user profile', () async {
        await FirebaseTestHelpers.runWithFirebase(() async {
          // Arrange
          const email = 'test@example.com';
          const password = 'testPassword123';
          const initialDisplayName = 'Test User';
          const updatedDisplayName = 'Updated User';

          final registerResult = await authService.registerWithEmail(
            email: email,
            password: password,
            displayName: initialDisplayName,
          );

          // Act
          await authService.updateUserProfile(
            displayName: updatedDisplayName,
          );

          // Assert
          final userData = await authService.getUserData(registerResult.user!.uid);
          expect(userData!['displayName'], equals(updatedDisplayName));

          // Verificar que el usuario de Auth también se actualizó
          final currentUser = FirebaseTestHelpers.auth.currentUser;
          expect(currentUser!.displayName, equals(updatedDisplayName));
        });
      });

      test('should check user roles correctly', () async {
        await FirebaseTestHelpers.runWithFirebase(() async {
          // Arrange - Crear usuario músico
          const musicianEmail = 'musician@example.com';
          const password = 'testPassword123';

          await authService.registerWithEmail(
            email: musicianEmail,
            password: password,
            displayName: 'Musician User',
          );

          // Act & Assert - Verificar rol de músico
          expect(await authService.isAdmin(), isFalse);
          expect(await authService.isHost(), isFalse);

          // Arrange - Crear usuario host manualmente en Firestore
          await authService.signOut();
          final hostUser = await FirebaseTestHelpers.createTestUser(
            email: 'host@example.com',
            password: password,
            displayName: 'Host User',
          );

          await FirebaseTestHelpers.firestore
              .collection('users')
              .doc(hostUser.uid)
              .set({
            'email': 'host@example.com',
            'displayName': 'Host User',
            'role': 'host',
            'createdAt': DateTime.now(),
          });

          // Act & Assert - Verificar rol de host
          expect(await authService.isAdmin(), isFalse);
          expect(await authService.isHost(), isTrue);
        });
      });
    });

    group('Password Reset', () {
      test('should send password reset email', () async {
        await FirebaseTestHelpers.runWithFirebase(() async {
          // Arrange
          const email = 'test@example.com';
          const password = 'testPassword123';

          // Crear usuario primero
          await authService.registerWithEmail(
            email: email,
            password: password,
            displayName: 'Test User',
          );

          // Act & Assert - No debería lanzar excepción
          expect(
            () => authService.sendPasswordResetEmail(email),
            returnsNormally,
          );
        });
      });

      test('should handle password reset for non-existent email', () async {
        await FirebaseTestHelpers.runWithFirebase(() async {
          // Arrange
          const nonExistentEmail = 'nonexistent@example.com';

          // Act & Assert - No debería lanzar excepción en emulator
          expect(
            () => authService.sendPasswordResetEmail(nonExistentEmail),
            returnsNormally,
          );
        });
      });
    });

    group('Account Deletion', () {
      test('should delete user account and data', () async {
        await FirebaseTestHelpers.runWithFirebase(() async {
          // Arrange
          const email = 'test@example.com';
          const password = 'testPassword123';

          final registerResult = await authService.registerWithEmail(
            email: email,
            password: password,
            displayName: 'Test User',
          );

          final userId = registerResult.user!.uid;

          // Verificar que el usuario existe en Firestore
          final userDocBefore = await FirebaseTestHelpers.firestore
              .collection('users')
              .doc(userId)
              .get();
          expect(userDocBefore.exists, isTrue);

          // Act
          await authService.deleteAccount();

          // Assert
          // Verificar que el usuario ya no está autenticado
          expect(FirebaseTestHelpers.auth.currentUser, isNull);

          // Verificar que los datos del usuario se eliminaron de Firestore
          final userDocAfter = await FirebaseTestHelpers.firestore
              .collection('users')
              .doc(userId)
              .get();
          expect(userDocAfter.exists, isFalse);
        });
      });
    });

    group('Authentication State', () {
      test('should maintain authentication state across operations', () async {
        await FirebaseTestHelpers.runWithFirebase(() async {
          // Arrange
          const email = 'test@example.com';
          const password = 'testPassword123';

          // Act - Registrar usuario
          final registerResult = await authService.registerWithEmail(
            email: email,
            password: password,
            displayName: 'Test User',
          );

          // Assert - Usuario debe estar autenticado
          expect(FirebaseTestHelpers.auth.currentUser, isNotNull);
          expect(FirebaseTestHelpers.auth.currentUser!.uid, 
                 equals(registerResult.user!.uid));

          // Act - Cerrar sesión
          await authService.signOut();

          // Assert - Usuario no debe estar autenticado
          expect(FirebaseTestHelpers.auth.currentUser, isNull);

          // Act - Iniciar sesión nuevamente
          final loginResult = await authService.signInWithEmail(
            email: email,
            password: password,
          );

          // Assert - Usuario debe estar autenticado nuevamente
          expect(FirebaseTestHelpers.auth.currentUser, isNotNull);
          expect(FirebaseTestHelpers.auth.currentUser!.uid, 
                 equals(loginResult.user!.uid));
        });
      });
    });
  });
}