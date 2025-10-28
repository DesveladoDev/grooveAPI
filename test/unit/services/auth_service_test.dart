import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:cloud_firestore/cloud_firestore.dart' as Firestore;
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:salas_beats/services/auth_service.dart';
import 'package:salas_beats/models/user_model.dart';
import 'package:salas_beats/utils/validation_service.dart';

// Generate mocks
@GenerateMocks([
  FirebaseAuth.FirebaseAuth,
  Firestore.FirebaseFirestore,
  GoogleSignIn,
  FirebaseAuth.User,
  FirebaseAuth.UserCredential,
  Firestore.QuerySnapshot,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  FirebaseAuth.AuthCredential,
  ValidationService,
], customMocks: [
  MockSpec<Firestore.CollectionReference<Map<String, dynamic>>>(
    as: #MockCollectionReference,
  ),
  MockSpec<Firestore.DocumentReference<Map<String, dynamic>>>(
    as: #MockDocumentReference,
  ),
  MockSpec<Firestore.DocumentSnapshot<Map<String, dynamic>>>(
    as: #MockDocumentSnapshot,
  ),
])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late MockDocumentReference mockDocumentReference;
    late MockDocumentSnapshot mockDocumentSnapshot;
    late MockCollectionReference mockCollectionReference;
    late MockValidationService mockValidationService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockGoogleSignIn = MockGoogleSignIn();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      mockDocumentReference = MockDocumentReference();
      mockDocumentSnapshot = MockDocumentSnapshot();
      mockCollectionReference = MockCollectionReference();
      mockValidationService = MockValidationService();

      // Configure basic mocks
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.uid).thenReturn('test-uid');
      when(mockAuth.currentUser).thenReturn(mockUser);
      
      // Configure basic document snapshot
      when(mockDocumentSnapshot.id).thenReturn('test-uid');
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn({
        'id': 'test-uid',
        'email': 'test@example.com',
        'name': 'Test User',
        'role': 'musician',
        'createdAt': Timestamp.now(),
      });

      // Configure ValidationService mocks for different scenarios
      // Valid data
      when(mockValidationService.validateUserData(
        email: 'test@example.com',
        name: 'Test User',
      )).thenReturn(const ValidationResult(isValid: true));
      
      when(mockValidationService.validatePassword('password123'))
          .thenReturn(const ValidationResult(isValid: true));
      
      when(mockValidationService.validateEmail('test@example.com'))
          .thenReturn(const ValidationResult(isValid: true));
      
      // Invalid data - casos específicos
      when(mockValidationService.validateUserData(
        email: '',
        name: 'Test User',
        phone: null,
      )).thenReturn(const ValidationResult(isValid: false, errors: ['El email es obligatorio']));
      
      when(mockValidationService.validateUserData(
        email: 'invalid-email',
        name: 'Test User',
        phone: null,
      )).thenReturn(const ValidationResult(isValid: false, errors: ['El formato del email no es válido']));
      
      when(mockValidationService.validateUserData(
        email: 'test@example.com',
        name: 'Test User',
        phone: null,
      )).thenReturn(const ValidationResult(isValid: true));
      
      when(mockValidationService.validateEmail(''))
          .thenReturn(const ValidationResult(isValid: false, errors: ['El email es obligatorio']));
      
      when(mockValidationService.validateEmail('invalid-email'))
          .thenReturn(const ValidationResult(isValid: false, errors: ['El formato del email no es válido']));
      
      when(mockValidationService.validateEmail('invalid-email'))
          .thenReturn(const ValidationResult(isValid: false, errors: ['El formato del email no es válido']));
      
      when(mockValidationService.validatePassword('123'))
           .thenReturn(const ValidationResult(isValid: false, errors: ['La contraseña debe tener al menos 8 caracteres']));
       
      when(mockValidationService.validatePassword('password123'))
           .thenReturn(const ValidationResult(isValid: true));
       
      when(mockValidationService.validatePassword('validPassword123'))
           .thenReturn(const ValidationResult(isValid: true));

      // Configure Firebase mocks for successful operations
      when(mockAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.updateDisplayName(any)).thenAnswer((_) async {});

      when(mockFirestore.collection('users')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.set(any)).thenAnswer((_) async {});
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);

      authService = AuthService(
        firebaseAuth: mockAuth,
        firebaseFirestore: mockFirestore,
        googleSignIn: mockGoogleSignIn,
        validationService: mockValidationService,
      );
    });

    group('Email Registration', () {
      test('should register user successfully with valid data', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const name = 'Test User';
        const role = 'musician';

        // Act
        final result = await authService.registerWithEmailAndPassword(
          email: email,
          password: password,
          name: name,
          role: role,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.error, isNull);
        expect(result.user, isNotNull);
        expect(result.user?.email, equals(email.toLowerCase()));
        expect(result.user?.name, equals(name));
      });

      test('should fail registration with empty email', () async {
        // Act
        final result = await authService.registerWithEmailAndPassword(
          email: '',
          password: 'password123',
          name: 'Test User',
          role: 'musician',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('El email es obligatorio'));
      });

      test('should fail registration with invalid email format', () async {
        // Act
        final result = await authService.registerWithEmailAndPassword(
          email: 'invalid-email',
          password: 'password123',
          name: 'Test User',
          role: 'musician',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('El formato del email no es válido'));
      });

      test('should fail registration with short password', () async {
        // Act
        final result = await authService.registerWithEmailAndPassword(
          email: 'test@example.com',
          password: '123',
          name: 'Test User',
          role: 'musician',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.error, contains('La contraseña debe tener al menos 8 caracteres'));
      });

      test('should fail registration with invalid role', () async {
        // Act
        final result = await authService.registerWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
          role: 'invalid-role',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('Rol inválido. Debe ser "musician" o "host"'));
      });
    });

    group('Email Login', () {
      test('should login successfully with valid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');

        when(mockFirestore.collection('users')).thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
        when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn({
          'id': 'test-uid',
          'email': email,
          'name': 'Test User',
          'role': 'musician',
          'createdAt': Timestamp.now(),
        });
        when(mockDocumentReference.update(any)).thenAnswer((_) async {});

        // Act
        final result = await authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.error, isNull);
        expect(result.user, isNotNull);
        expect(result.user?.email, equals(email));
      });

      test('should fail login with invalid email format', () async {
        // Act
        final result = await authService.signInWithEmailAndPassword(
          email: 'invalid-email',
          password: 'password123',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('El formato del email no es válido'));
      });
    });

    group('Authentication State', () {
      test('should return true when user is authenticated', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);

        // Act & Assert
        expect(authService.isAuthenticated, isTrue);
      });

      test('should return false when user is not authenticated', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(authService.isAuthenticated, isFalse);
      });

      test('should return current user when authenticated', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);

        // Act & Assert
        expect(authService.currentUser, equals(mockUser));
      });
    });

    group('User Data Retrieval', () {
      test('should get current user data successfully', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');

        when(mockFirestore.collection('users')).thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('test-uid')).thenReturn(mockDocumentReference);
        when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn({
          'id': 'test-uid',
          'email': 'test@example.com',
          'name': 'Test User',
          'role': 'musician',
          'createdAt': Timestamp.now(),
        });

        // Act
        final userData = await authService.getCurrentUserData();

        // Assert
        expect(userData, isNotNull);
        expect(userData?.id, equals('test-uid'));
        expect(userData?.email, equals('test@example.com'));
        expect(userData?.name, equals('Test User'));
      });

      test('should return null when no user is authenticated', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act
        final userData = await authService.getCurrentUserData();

        // Assert
        expect(userData, isNull);
      });
    });

    group('Role Verification', () {
      test('should return true for admin user', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');

        when(mockFirestore.collection('users')).thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('test-uid')).thenReturn(mockDocumentReference);
        when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn({
          'id': 'test-uid',
          'email': 'admin@example.com',
          'name': 'Admin User',
          'role': 'admin',
          'createdAt': Timestamp.now(),
        });

        // Act
        final isAdmin = await authService.isAdmin();

        // Assert
        expect(isAdmin, isTrue);
      });

      test('should return true for host user', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');

        when(mockFirestore.collection('users')).thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('test-uid')).thenReturn(mockDocumentReference);
        when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn({
          'id': 'test-uid',
          'email': 'host@example.com',
          'name': 'Host User',
          'role': 'host',
          'createdAt': Timestamp.now(),
        });

        // Act
        final isHost = await authService.isHost();

        // Assert
        expect(isHost, isTrue);
      });
    });

    group('Logout', () {
      test('should logout successfully', () async {
        // Arrange
        when(mockAuth.signOut()).thenAnswer((_) async {});
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

        // Act
        final result = await authService.signOut();

        // Assert
        expect(result.success, isTrue);
        expect(result.message, equals('Sesión cerrada exitosamente'));
        verify(mockAuth.signOut()).called(1);
      });
    });
  });
}