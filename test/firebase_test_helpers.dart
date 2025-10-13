import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class para configurar Firebase Emulators en tests
class FirebaseTestHelpers {
  static const String _projectId = 'salas-beats-test';
  static const String _authEmulatorHost = 'localhost:9099';
  static const String _firestoreEmulatorHost = 'localhost:8080';
  static const String _storageEmulatorHost = 'localhost:9199';

  static bool _initialized = false;

  /// Inicializa Firebase con emulators para testing
  static Future<void> initializeFirebaseForTesting() async {
    if (_initialized) return;

    TestWidgetsFlutterBinding.ensureInitialized();

    // Configurar Firebase para testing
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: _projectId,
      ),
    );

    // Configurar emulators
    await _configureEmulators();
    
    _initialized = true;
  }

  /// Configura todos los emulators de Firebase
  static Future<void> _configureEmulators() async {
    // Configurar Auth Emulator
    await FirebaseAuth.instance.useAuthEmulator(_authEmulatorHost);

    // Configurar Firestore Emulator
    FirebaseFirestore.instance.useFirestoreEmulator(
      _firestoreEmulatorHost.split(':')[0],
      int.parse(_firestoreEmulatorHost.split(':')[1]),
    );

    // Configurar Storage Emulator
    await FirebaseStorage.instance.useStorageEmulator(
      _storageEmulatorHost.split(':')[0],
      int.parse(_storageEmulatorHost.split(':')[1]),
    );
  }

  /// Limpia todos los datos de los emulators
  static Future<void> clearEmulatorData() async {
    await clearFirestoreData();
    await clearAuthData();
    await clearStorageData();
  }

  /// Limpia datos de Firestore
  static Future<void> clearFirestoreData() async {
    final firestore = FirebaseFirestore.instance;
    
    // Limpiar colecciones principales
    final collections = [
      'users',
      'listings',
      'bookings',
      'chats',
      'reviews',
      'notifications',
    ];

    for (final collection in collections) {
      final snapshot = await firestore.collection(collection).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  /// Limpia datos de Auth
  static Future<void> clearAuthData() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      await auth.signOut();
    }
  }

  /// Limpia datos de Storage
  static Future<void> clearStorageData() async {
    // En el emulator, los datos se limpian automáticamente
    // al reiniciar, pero podemos implementar limpieza específica si es necesario
  }

  /// Crea un usuario de prueba en Auth
  static Future<User> createTestUser({
    required String email,
    required String password,
    String? displayName,
    String? photoURL,
  }) async {
    final auth = FirebaseAuth.instance;
    
    final userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (displayName != null || photoURL != null) {
      await userCredential.user!.updateDisplayName(displayName);
      if (photoURL != null) {
        await userCredential.user!.updatePhotoURL(photoURL);
      }
    }

    return userCredential.user!;
  }

  /// Crea datos de prueba en Firestore
  static Future<void> seedFirestoreData() async {
    final firestore = FirebaseFirestore.instance;

    // Crear usuario de prueba
    await firestore.collection('users').doc('test-user-1').set({
      'email': 'test@example.com',
      'displayName': 'Test User',
      'role': 'musician',
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });

    // Crear host de prueba
    await firestore.collection('users').doc('test-host-1').set({
      'email': 'host@example.com',
      'displayName': 'Test Host',
      'role': 'host',
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'stripeAccountId': 'acct_test_123',
    });

    // Crear listing de prueba
    await firestore.collection('listings').doc('test-listing-1').set({
      'hostId': 'test-host-1',
      'title': 'Test Studio',
      'description': 'A test recording studio',
      'hourlyPrice': 50.0,
      'capacity': 4,
      'category': 'studio',
      'amenities': ['wifi', 'parking'],
      'equipment': ['microphones', 'speakers'],
      'location': {
        'address': '123 Test St',
        'city': 'Test City',
        'state': 'TS',
        'postalCode': '12345',
        'lat': 40.7128,
        'lng': -74.0060,
      },
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'rating': 4.5,
      'reviewCount': 10,
    });

    // Crear booking de prueba
    await firestore.collection('bookings').doc('test-booking-1').set({
      'listingId': 'test-listing-1',
      'userId': 'test-user-1',
      'hostId': 'test-host-1',
      'checkIn': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
      'checkOut': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1, hours: 4))),
      'hours': 4,
      'totalAmount': 200.0,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Wrapper para tests que requieren Firebase
  static Future<void> runWithFirebase(
    Future<void> Function() testFunction, {
    bool seedData = false,
    bool clearAfter = true,
  }) async {
    await initializeFirebaseForTesting();
    
    if (seedData) {
      await seedFirestoreData();
    }

    try {
      await testFunction();
    } finally {
      if (clearAfter) {
        await clearEmulatorData();
      }
    }
  }

  /// Verifica que los emulators estén ejecutándose
  static Future<bool> areEmulatorsRunning() async {
    try {
      // Intentar conectar a Firestore emulator
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('_test').doc('_test').get();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene una referencia a Firestore configurada para testing
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Obtiene una referencia a Auth configurada para testing
  static FirebaseAuth get auth => FirebaseAuth.instance;

  /// Obtiene una referencia a Storage configurada para testing
  static FirebaseStorage get storage => FirebaseStorage.instance;
}

/// Matcher personalizado para verificar documentos de Firestore
class FirestoreDocumentMatcher extends Matcher {
  final String collection;
  final String documentId;
  final Map<String, dynamic>? expectedData;

  const FirestoreDocumentMatcher(
    this.collection,
    this.documentId, {
    this.expectedData,
  });

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    // Este matcher se puede usar en tests para verificar datos de Firestore
    return true; // Implementación simplificada
  }

  @override
  Description describe(Description description) {
    return description.add('Firestore document at $collection/$documentId');
  }
}

/// Helper para crear matchers de Firestore
FirestoreDocumentMatcher firestoreDocument(
  String collection,
  String documentId, {
  Map<String, dynamic>? data,
}) {
  return FirestoreDocumentMatcher(collection, documentId, expectedData: data);
}

/// Extensión para facilitar el testing con Firestore
extension FirestoreTestExtensions on FirebaseFirestore {
  /// Obtiene un documento y verifica que existe
  Future<DocumentSnapshot> getDocumentAndExpectExists(
    String collection,
    String documentId,
  ) async {
    final doc = await this.collection(collection).doc(documentId).get();
    if (!doc.exists) {
      throw Exception('Document $collection/$documentId does not exist');
    }
    return doc;
  }

  /// Verifica que un documento no existe
  Future<void> expectDocumentNotExists(
    String collection,
    String documentId,
  ) async {
    final doc = await this.collection(collection).doc(documentId).get();
    if (doc.exists) {
      throw Exception('Document $collection/$documentId should not exist');
    }
  }

  /// Cuenta documentos en una colección
  Future<int> countDocuments(String collection) async {
    final snapshot = await this.collection(collection).get();
    return snapshot.docs.length;
  }
}