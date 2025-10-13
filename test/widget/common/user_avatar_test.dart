import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:salas_beats/widgets/user_avatar.dart';
import '../../test_helpers.dart';

void main() {
  group('UserAvatar Widget Tests', () {
    testWidgets('should display initials when no image URL is provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: 'John Doe',
            radius: 30,
          ),
        ),
      );

      // Verificar que se muestran las iniciales
      expect(find.text('JD'), findsOneWidget);
      
      // Verificar que es un CircleAvatar
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should display question mark for empty or null name', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: '',
            radius: 30,
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);

      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: null,
            radius: 30,
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('should handle single name correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: 'John',
            radius: 30,
          ),
        ),
      );

      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('should handle multiple names correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: 'John Michael Doe',
            radius: 30,
          ),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('should display network image when URL is provided', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(
            const UserAvatar(
              imageUrl: 'https://example.com/avatar.jpg',
              displayName: 'John Doe',
              radius: 30,
            ),
          ),
        );

        // Verificar que se carga la imagen de red
        expect(find.byType(CircleAvatar), findsOneWidget);
        
        // No debe mostrar las iniciales cuando hay imagen
        expect(find.text('JD'), findsNothing);
      });
    });

    testWidgets('should apply custom background color', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: 'John Doe',
            radius: 30,
            backgroundColor: Colors.red,
          ),
        ),
      );

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.backgroundColor, Colors.red);
    });

    testWidgets('should apply custom text color', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: 'John Doe',
            radius: 30,
            textColor: Colors.white,
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('JD'));
      expect(textWidget.style?.color, Colors.white);
    });

    testWidgets('should apply custom radius', (tester) async {
      const customRadius = 50.0;
      
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: 'John Doe',
            radius: customRadius,
          ),
        ),
      );

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.radius, customRadius);
      
      // Verificar que el tamaño del texto se ajusta al radio
      final textWidget = tester.widget<Text>(find.text('JD'));
      expect(textWidget.style?.fontSize, customRadius * 0.6);
    });

    testWidgets('should show border when showBorder is true', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: 'John Doe',
            radius: 30,
            showBorder: true,
            borderColor: Colors.blue,
            borderWidth: 3,
          ),
        ),
      );

      // Verificar que hay un DecoratedBox para el borde
      expect(find.byType(DecoratedBox), findsOneWidget);
      
      final decoratedBox = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
      final decoration = decoratedBox.decoration as BoxDecoration;
      
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.border?.top.color, Colors.blue);
      expect(decoration.border?.top.width, 3);
    });

    testWidgets('should not show border when showBorder is false', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: 'John Doe',
            radius: 30,
            showBorder: false,
          ),
        ),
      );

      // No debe haber DecoratedBox cuando showBorder es false
      expect(find.byType(DecoratedBox), findsNothing);
    });

    testWidgets('should handle tap when onTap is provided', (tester) async {
      bool tapCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          UserAvatar(
            displayName: 'John Doe',
            radius: 30,
            onTap: () => tapCalled = true,
          ),
        ),
      );

      // Verificar que hay un GestureDetector
      expect(find.byType(GestureDetector), findsOneWidget);

      // Tocar el avatar
      await tester.tap(find.byType(UserAvatar));
      await tester.pump();

      expect(tapCalled, isTrue);
    });

    testWidgets('should not wrap in GestureDetector when onTap is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: 'John Doe',
            radius: 30,
            onTap: null,
          ),
        ),
      );

      // No debe haber GestureDetector cuando onTap es null
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('should handle empty image URL correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            imageUrl: '',
            displayName: 'John Doe',
            radius: 30,
          ),
        ),
      );

      // Debe mostrar las iniciales cuando la URL está vacía
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('should use theme colors when no custom colors provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: 'John Doe',
            radius: 30,
          ),
        ),
      );

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      
      // Debe usar colores del tema por defecto
      expect(circleAvatar.backgroundColor, isNotNull);
      
      final textWidget = tester.widget<Text>(find.text('JD'));
      expect(textWidget.style?.color, isNotNull);
    });

    testWidgets('should handle special characters in name', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: 'José María',
            radius: 30,
          ),
        ),
      );

      // Debe mostrar las iniciales correctas
      expect(find.text('JM'), findsOneWidget);
    });

    testWidgets('should handle very long names', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: 'Very Long Name That Should Be Truncated',
            radius: 30,
          ),
        ),
      );

      // Debe mostrar solo las primeras dos iniciales
      expect(find.text('VL'), findsOneWidget);
    });

    testWidgets('should handle rapid taps correctly', (tester) async {
      int tapCount = 0;
      
      await tester.pumpWidget(
        createTestWidget(
          UserAvatar(
            displayName: 'John Doe',
            radius: 30,
            onTap: () => tapCount++,
          ),
        ),
      );

      // Tocar múltiples veces rápidamente
      await tester.tap(find.byType(UserAvatar));
      await tester.tap(find.byType(UserAvatar));
      await tester.tap(find.byType(UserAvatar));
      await tester.pump();

      expect(tapCount, equals(3));
    });

    testWidgets('should maintain aspect ratio', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UserAvatar(
            displayName: 'John Doe',
            radius: 50,
          ),
        ),
      );

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.radius, 50);
      
      // El widget debe ser circular
      final size = tester.getSize(find.byType(CircleAvatar));
      expect(size.width, size.height);
    });
  });
}