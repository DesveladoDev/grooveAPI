import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/services/auth_service.dart';
import 'package:salas_beats/models/user_model.dart';

// Generate mocks
@GenerateMocks([
  AuthService,
  FirebaseAuth,
  User,
])
import 'auth_provider_test.mocks.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late MockAuthService mockAuthService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;

    setUp(() {
      mockAuthService = MockAuthService();
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      
      authProvider = AuthProvider();
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
        final result = await authProvider.login(
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
        final result = await authProvider.logout();

        // Assert
        expect(result, isTrue);
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

    group('Profile Completion', () {
      test('should detect incomplete profile', () {
        // Arrange
        final incompleteUser = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          name: '',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        authProvider.setUser(incompleteUser);

        // Act & Assert
        expect(authProvider.needsProfileCompletion, isTrue);
        expect(authProvider.profileCompletionProgress, lessThan(1.0));
      });

      test('should detect complete profile', () {
        // Arrange
        final completeUser = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          verified: true,
          photoURL: 'https://example.com/photo.jpg',
          createdAt: DateTime.now(),
        );

        authProvider.setUser(completeUser);

        // Act & Assert
        expect(authProvider.needsProfileCompletion, isFalse);
        expect(authProvider.profileCompletionProgress, equals(1.0));
      });
    });

    group('Loading States', () {
      test('should handle loading state correctly', () {
        // Act
        authProvider.setLoading(true);

        // Assert
        expect(authProvider.isLoading, isTrue);

        // Act
        authProvider.setLoading(false);

        // Assert
        expect(authProvider.isLoading, isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle and clear errors', () {
        // Act
        authProvider.setError('Test error');

        // Assert
        expect(authProvider.error, equals('Test error'));

        // Act
        authProvider.clearError();

        // Assert
        expect(authProvider.error, isNull);
      });
    });
  });
}