import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

// Mock classes
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

/// Crea un widget de prueba con providers mockeados
Widget createTestWidget(
  Widget child, {
  List<ChangeNotifierProvider> providers = const [],
}) {
  if (providers.isEmpty) {
    return MaterialApp(
      home: Scaffold(body: child),
      navigatorObservers: [MockNavigatorObserver()],
    );
  }
  
  return MultiProvider(
    providers: providers,
    child: MaterialApp(
      home: Scaffold(body: child),
      navigatorObservers: [MockNavigatorObserver()],
    ),
  );
}

/// Helper para tests con imágenes de red
Future<void> testWithNetworkImages(WidgetTester tester, Future<void> Function() testFunction) async {
  await mockNetworkImagesFor(() async {
    await testFunction();
  });
}

/// Helper para encontrar widgets por tipo y texto
Finder findWidgetByTypeAndText<T extends Widget>(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is T && widget.toString().contains(text),
  );
}

/// Helper para simular delay en tests
Future<void> pumpAndSettle(WidgetTester tester, [Duration? duration]) async {
  await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 100));
}

/// Matcher personalizado para verificar estados de loading
Matcher isLoadingState() {
  return predicate<Widget>((widget) {
    return widget is CircularProgressIndicator || 
           (widget is Center && widget.child is CircularProgressIndicator);
  }, 'is loading state');
}

/// Matcher para verificar estados de error
Matcher isErrorState([String? message]) {
  return predicate<Widget>((widget) {
    if (widget is Text) {
      return message != null ? widget.data?.contains(message) == true : true;
    }
    return false;
  }, 'is error state${message != null ? ' with message: $message' : ''}');
}

/// Helper para setup común de tests
void setupTestEnvironment() {
  // Configuración común para todos los tests
  TestWidgetsFlutterBinding.ensureInitialized();
}

/// Helper para cleanup después de tests
void tearDownTestEnvironment() {
  // Cleanup común
}