import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salas_beats/widgets/admin/metrics_card.dart';
import '../../test_helpers.dart';

void main() {
  group('MetricsCard Widget Tests', () {
    testWidgets('should display all metric information correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MetricsCard(
            title: 'Total Users',
            value: '1,234',
            subtitle: '+12% from last month',
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
      );

      // Verificar que se muestran todos los textos
      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('1,234'), findsOneWidget);
      expect(find.text('+12% from last month'), findsOneWidget);
      
      // Verificar que se muestra el icono
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('should apply gradient background based on color', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MetricsCard(
            title: 'Revenue',
            value: '\$5,678',
            subtitle: '+8% from last week',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
      );

      // Verificar que hay un Container con decoración
      final containerFinder = find.descendant(
        of: find.byType(MetricsCard),
        matching: find.byType(Container),
      );
      
      expect(containerFinder, findsWidgets);
      
      // Verificar que el widget se renderiza correctamente
      expect(find.byType(MetricsCard), findsOneWidget);
    });

    testWidgets('should handle tap when onTap is provided', (tester) async {
      bool tapCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          MetricsCard(
            title: 'Active Sessions',
            value: '42',
            subtitle: 'Currently online',
            icon: Icons.online_prediction,
            color: Colors.orange,
            onTap: () => tapCalled = true,
          ),
        ),
      );

      // Tocar la tarjeta
      await tester.tap(find.byType(MetricsCard));
      await tester.pump();

      expect(tapCalled, isTrue);
    });

    testWidgets('should not be tappable when onTap is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MetricsCard(
            title: 'Static Metric',
            value: '999',
            subtitle: 'No interaction',
            icon: Icons.info,
            color: Colors.grey,
            onTap: null,
          ),
        ),
      );

      // Verificar que el widget se renderiza
      expect(find.byType(MetricsCard), findsOneWidget);
      
      // No debe haber errores al intentar tocar
      await tester.tap(find.byType(MetricsCard));
      await tester.pump();
    });

    testWidgets('should display different icons correctly', (tester) async {
      const testCases = [
        (Icons.people, 'Users'),
        (Icons.attach_money, 'Revenue'),
        (Icons.trending_up, 'Growth'),
        (Icons.star, 'Rating'),
        (Icons.schedule, 'Time'),
      ];

      for (final (icon, title) in testCases) {
        await tester.pumpWidget(
          createTestWidget(
            MetricsCard(
              title: title,
              value: '100',
              subtitle: 'Test subtitle',
              icon: icon,
              color: Colors.blue,
            ),
          ),
        );

        expect(find.byIcon(icon), findsOneWidget);
        expect(find.text(title), findsOneWidget);
      }
    });

    testWidgets('should handle different color themes', (tester) async {
      const testColors = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
      ];

      for (final color in testColors) {
        await tester.pumpWidget(
          createTestWidget(
            MetricsCard(
              title: 'Test Metric',
              value: '123',
              subtitle: 'Test subtitle',
              icon: Icons.star,
              color: color,
            ),
          ),
        );

        // Verificar que el widget se renderiza sin errores
        expect(find.byType(MetricsCard), findsOneWidget);
      }
    });

    testWidgets('should handle long text values', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MetricsCard(
            title: 'Very Long Metric Title That Might Overflow',
            value: '1,234,567,890',
            subtitle: 'This is a very long subtitle that might cause layout issues if not handled properly',
            icon: Icons.data_usage,
            color: Colors.indigo,
          ),
        ),
      );

      // Verificar que se muestran todos los textos largos
      expect(find.text('Very Long Metric Title That Might Overflow'), findsOneWidget);
      expect(find.text('1,234,567,890'), findsOneWidget);
      expect(find.text('This is a very long subtitle that might cause layout issues if not handled properly'), findsOneWidget);
    });

    testWidgets('should handle empty strings', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MetricsCard(
            title: '',
            value: '',
            subtitle: '',
            icon: Icons.help,
            color: Colors.grey,
          ),
        ),
      );

      // Verificar que el widget se renderiza sin errores
      expect(find.byType(MetricsCard), findsOneWidget);
      expect(find.byIcon(Icons.help), findsOneWidget);
    });

    testWidgets('should handle special characters in text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MetricsCard(
            title: 'Métricas Españolas',
            value: '€1.234,56',
            subtitle: '↑ 15% más que ayer',
            icon: Icons.euro,
            color: Colors.amber,
          ),
        ),
      );

      expect(find.text('Métricas Españolas'), findsOneWidget);
      expect(find.text('€1.234,56'), findsOneWidget);
      expect(find.text('↑ 15% más que ayer'), findsOneWidget);
    });

    testWidgets('should maintain consistent layout with different content lengths', (tester) async {
      // Tarjeta con contenido corto
      await tester.pumpWidget(
        createTestWidget(
          const MetricsCard(
            title: 'A',
            value: '1',
            subtitle: 'B',
            icon: Icons.star,
            color: Colors.blue,
          ),
        ),
      );

      final shortSize = tester.getSize(find.byType(MetricsCard));

      // Tarjeta con contenido largo
      await tester.pumpWidget(
        createTestWidget(
          const MetricsCard(
            title: 'Very Long Title',
            value: '1,234,567',
            subtitle: 'Very long subtitle text',
            icon: Icons.star,
            color: Colors.blue,
          ),
        ),
      );

      final longSize = tester.getSize(find.byType(MetricsCard));

      // Las tarjetas deben mantener dimensiones consistentes
      expect(shortSize.height, lessThanOrEqualTo(longSize.height + 50)); // Tolerancia para el texto
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MetricsCard(
            title: 'Accessibility Test',
            value: '100',
            subtitle: 'Test for screen readers',
            icon: Icons.accessibility,
            color: Colors.green,
          ),
        ),
      );

      // Verificar que los textos son accesibles
      expect(find.text('Accessibility Test'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('Test for screen readers'), findsOneWidget);
      
      // Verificar que el icono es accesible
      expect(find.byIcon(Icons.accessibility), findsOneWidget);
    });

    testWidgets('should handle rapid taps correctly', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        createTestWidget(
          MetricsCard(
            title: 'Tap Test',
            value: '0',
            subtitle: 'Tap counter',
            icon: Icons.touch_app,
            color: Colors.purple,
            onTap: () => tapCount++,
          ),
        ),
      );

      // Realizar múltiples taps rápidos
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(MetricsCard));
        await tester.pump(const Duration(milliseconds: 10));
      }

      expect(tapCount, 5);
    });

    testWidgets('should render correctly in different theme modes', (tester) async {
      // Tema claro
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: MetricsCard(
              title: 'Light Theme',
              value: '123',
              subtitle: 'Light mode test',
              icon: Icons.light_mode,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.byType(MetricsCard), findsOneWidget);

      // Tema oscuro
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: MetricsCard(
              title: 'Dark Theme',
              value: '456',
              subtitle: 'Dark mode test',
              icon: Icons.dark_mode,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.byType(MetricsCard), findsOneWidget);
    });
  });
}