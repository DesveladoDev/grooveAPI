import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFirebaseOptions extends FirebaseOptions {
  const MockFirebaseOptions()
      : super(
          apiKey: 'test-api-key',
          appId: 'test-app-id',
          messagingSenderId: 'test-sender-id',
          projectId: 'test-project-id',
        );
}

Future<void> setupFirebaseForTesting() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const MockFirebaseOptions(),
    );
  } catch (e) {
    // Firebase ya está inicializado
  }
}