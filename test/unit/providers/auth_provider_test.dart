import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth hide AuthProvider;

import 'package:salas_beats/providers/auth_provider.dart' as AppAuthProvider;
import 'package:salas_beats/providers/auth_provider.dart' show AuthStatus;
import 'package:salas_beats/services/auth_service.dart';
import 'package:salas_beats/models/user_model.dart';

// Generate mocks
@GenerateMocks([
  AuthService,
  FirebaseAuth.FirebaseAuth,
  FirebaseAuth.User,
])
import 'auth_provider_test.mocks.dart';

void main() {
  group('AuthProvider Tests', () {
    late AppAuthProvider.AuthProvider authProvider;
    late MockAuthService mockAuthService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;

    setUp(() {
        mockAuthService = MockAuthService();
        mockFirebaseAuth = MockFirebaseAuth();
        mockUser = MockUser();
        
        // Configure mocks to prevent initialization errors
        when(mockAuthService.authStateChanges).thenAnswer((_) => Stream.empty());
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUser.uid).thenReturn('test-uid');
        
        authProvider = AppAuthProvider.AuthProvider(
          authService: mockAuthService,
          firebaseAuth: mockFirebaseAuth,
        );
    });

    tearDown(() {
      authProvider.dispose();
    });

    group('Initialization', () {
      test('should initialize with uninitialized status', () {
        expect(authProvider.status, equals(AuthStatus.uninitialized));
        expect(authProvider.user, isNull);
        expect(authProvider.isAuthenticated, isFalse);
      });

      test('should set authenticated status when user exists', () async {
        // Arrange
        final testUser = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');
        when(mockAuthService.getCurrentUserData()).thenAnswer((_) async => testUser);

        // Act
        await authProvider.checkAuthStatus();

        // Assert
        expect(authProvider.status, equals(AuthStatus.authenticated));
        expect(authProvider.user, isNotNull);
        expect(authProvider.user?.id, equals('test-uid'));
        expect(authProvider.isAuthenticated, isTrue);
      });

      test('should set unauthenticated status when no user exists', () async {
        // Arrange
        when(mockAuthService.currentUser).thenReturn(null);

        // Act
        await authProvider.checkAuthStatus();

        // Assert
        expect(authProvider.status, equals(AuthStatus.unauthenticated));
        expect(authProvider.user, isNull);
        expect(authProvider.isAuthenticated, isFalse);
      });
    });

    group('Authentication Actions', () {
      test('should register user successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const name = 'Test User';
        const role = 'musician';

        final testUser = UserModel(
          id: 'test-uid',
          email: email,
          name: name,
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        final authResult = AuthResult.success(user: testUser);
        when(mockAuthService.registerWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
          role: anyNamed('role'),
        )).thenAnswer((_) async => authResult);

        // Act
        final result = await authProvider.register(
          email: email,
          password: password,
          name: name,
          role: role,
        );

        // Assert
        expect(result, isTrue);
        expect(authProvider.status, equals(AuthStatus.authenticated));
        expect(authProvider.user, isNotNull);
        expect(authProvider.user?.email, equals(email));
        expect(authProvider.error, isNull);
      });

      test('should handle registration failure', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const name = 'Test User';
        const role = 'musician';

        final authResult = AuthResult.failure('Email already in use');
        when(mockAuthService.registerWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
          role: anyNamed('role'),
        )).thenAnswer((_) async => authResult);

        // Act
        final result = await authProvider.register(
          email: email,
          password: password,
          name: name,
          role: role,
        );

        // Assert
        expect(result, isFalse);
        expect(authProvider.status, equals(AuthStatus.unauthenticated));
        expect(authProvider.user, isNull);
        expect(authProvider.error, equals('Email already in use'));
      });

      test('should login user successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        final testUser = UserModel(
          id: 'test-uid',
          email: email,
          name: 'Test User',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        final authResult = AuthResult.success(user: testUser);
        when(mockAuthService.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => authResult);

        // Act
        final result = await authProvider.signIn(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isTrue);
        expect(authProvider.status, equals(AuthStatus.authenticated));
        expect(authProvider.user, isNotNull);
        expect(authProvider.user?.email, equals(email));
        expect(authProvider.error, isNull);
      });

      test('should logout user successfully', () async {
        // Arrange
        final testUser = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        // Set initial authenticated state
        authProvider.setUser(testUser);
        authProvider.setStatus(AuthStatus.authenticated);

        final authResult = AuthResult.success();
        when(mockAuthService.signOut()).thenAnswer((_) async => authResult);

        // Act
        await authProvider.logout();

        // Assert
        expect(authProvider.status, equals(AuthStatus.unauthenticated));
        expect(authProvider.user, isNull);
        expect(authProvider.error, isNull);
      });
    });

    group('User Role Checks', () {
      test('should correctly identify admin user', () {
        // Arrange
        final adminUser = UserModel(
          id: 'admin-uid',
          email: 'admin@example.com',
          name: 'Admin User',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        );

        // Act
        authProvider.setUser(adminUser);

        // Assert
        expect(authProvider.isAdmin, isTrue);
        expect(authProvider.isHost, isFalse);
        expect(authProvider.isMusician, isFalse);
      });

      test('should correctly identify host user', () {
        // Arrange
        final hostUser = UserModel(
          id: 'host-uid',
          email: 'host@example.com',
          name: 'Host User',
          role: UserRole.host,
          createdAt: DateTime.now(),
        );

        // Act
        authProvider.setUser(hostUser);

        // Assert
        expect(authProvider.isAdmin, isFalse);
        expect(authProvider.isHost, isTrue);
        expect(authProvider.isMusician, isFalse);
      });

      test('should correctly identify musician user', () {
        // Arrange
        final musicianUser = UserModel(
          id: 'musician-uid',
          email: 'musician@example.com',
          name: 'Musician User',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        // Act
        authProvider.setUser(musicianUser);

        // Assert
        expect(authProvider.isAdmin, isFalse);
        expect(authProvider.isHost, isFalse);
        expect(authProvider.isMusician, isTrue);
      });
    });

    group('Permissions', () {
      test('should grant admin permissions to admin user', () {
        // Arrange
        final adminUser = UserModel(
          id: 'admin-uid',
          email: 'admin@example.com',
          name: 'Admin User',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        );

        authProvider.setUser(adminUser);

        // Act & Assert
        expect(authProvider.hasPermission('admin_panel'), isTrue);
        expect(authProvider.hasPermission('host_dashboard'), isTrue);
        expect(authProvider.hasPermission('create_listing'), isTrue);
        expect(authProvider.hasPermission('manage_bookings'), isTrue);
        expect(authProvider.hasPermission('view_analytics'), isTrue);
        expect(authProvider.hasPermission('manage_users'), isTrue);
        expect(authProvider.hasPermission('manage_settings'), isTrue);
      });

      test('should grant host permissions to host user', () {
        // Arrange
        final hostUser = UserModel(
          id: 'host-uid',
          email: 'host@example.com',
          name: 'Host User',
          role: UserRole.host,
          createdAt: DateTime.now(),
        );

        authProvider.setUser(hostUser);

        // Act & Assert
        expect(authProvider.hasPermission('admin_panel'), isFalse);
        expect(authProvider.hasPermission('host_dashboard'), isTrue);
        expect(authProvider.hasPermission('create_listing'), isTrue);
        expect(authProvider.hasPermission('manage_bookings'), isTrue);
        expect(authProvider.hasPermission('view_analytics'), isTrue);
        expect(authProvider.hasPermission('manage_users'), isFalse);
        expect(authProvider.hasPermission('manage_settings'), isFalse);
      });

      test('should deny permissions to unauthenticated user', () {
        // Act & Assert
        expect(authProvider.hasPermission('admin_panel'), isFalse);
        expect(authProvider.hasPermission('host_dashboard'), isFalse);
        expect(authProvider.hasPermission('create_listing'), isFalse);
        expect(authProvider.hasPermission('manage_bookings'), isFalse);
        expect(authProvider.hasPermission('view_analytics'), isFalse);
        expect(authProvider.hasPermission('manage_users'), isFalse);
        expect(authProvider.hasPermission('manage_settings'), isFalse);
      });
    });

    group('User Display Information', () {
      test('should return correct display name', () {
        // Arrange
        final user = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        authProvider.setUser(user);

        // Act & Assert
        expect(authProvider.displayName, equals('Test User'));
      });

      test('should return email prefix when name is empty', () {
        // Arrange
        final user = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          name: '',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        authProvider.setUser(user);

        // Act & Assert
        expect(authProvider.displayName, equals('test'));
      });

      test('should return correct user initials', () {
        // Arrange
        final user = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          name: 'John Doe',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        authProvider.setUser(user);

        // Act & Assert
        expect(authProvider.userInitials, equals('JD'));
      });

      test('should return single initial for single name', () {
        // Arrange
        final user = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          name: 'John',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        authProvider.setUser(user);

        // Act & Assert
        expect(authProvider.userInitials, equals('J'));
      });
    });



    group('User Role Update', () {
      test('should successfully update user role to musician', () async {
        // Arrange
        final initialUser = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );
        
        // Setup authenticated user
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');
        when(mockAuthService.getCurrentUserData()).thenAnswer((_) async => initialUser);
        await authProvider.checkAuthStatus();
        
        when(mockAuthService.updateUserRole(userId: 'test-uid', role: 'host'))
            .thenAnswer((_) async => AuthResult.success(
              user: initialUser.copyWith(role: UserRole.host),
              message: 'Rol actualizado exitosamente',
            ));

        // Act
        final result = await authProvider.updateUserRole('host');

        // Assert
        expect(result, isTrue);
        expect(authProvider.user?.role, equals(UserRole.host));
        expect(authProvider.error, isNull);
      });

      test('should handle role update failure', () async {
        // Arrange
        final initialUser = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );
        
        // Setup authenticated user
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');
        when(mockAuthService.getCurrentUserData()).thenAnswer((_) async => initialUser);
        await authProvider.checkAuthStatus();
        
        when(mockAuthService.updateUserRole(userId: 'test-uid', role: 'invalid-role'))
            .thenAnswer((_) async => AuthResult.failure('Rol inválido'));

        // Act
        final result = await authProvider.updateUserRole('invalid-role');

        // Assert
        expect(result, isFalse);
        expect(authProvider.user?.role, equals(UserRole.musician)); // Should remain unchanged
        expect(authProvider.error, equals('Rol inválido'));
      });

      test('should handle role update when user is null', () async {
        // Arrange
        when(mockAuthService.currentUser).thenReturn(null);
        await authProvider.checkAuthStatus();

        // Act
        final result = await authProvider.updateUserRole('host');

        // Assert
        expect(result, isFalse);
        expect(authProvider.user, isNull);
      });

      test('should validate role values', () async {
        // Arrange
        final initialUser = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );
        
        // Setup authenticated user
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');
        when(mockAuthService.getCurrentUserData()).thenAnswer((_) async => initialUser);
        await authProvider.checkAuthStatus();

        // Test valid roles
        for (final role in ['musician', 'host']) {
          when(mockAuthService.updateUserRole(userId: 'test-uid', role: role))
              .thenAnswer((_) async => AuthResult.success(
                user: initialUser.copyWith(
                  role: role == 'musician' ? UserRole.musician : UserRole.host
                ),
                message: 'Rol actualizado exitosamente',
              ));

          final result = await authProvider.updateUserRole(role);
          expect(result, isTrue, reason: 'Role $role should be valid');
        }
      });
    });
  });
}