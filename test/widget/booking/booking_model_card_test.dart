import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salas_beats/models/booking_model.dart';
import 'package:salas_beats/widgets/booking/booking_model_card.dart';
import '../../test_helpers.dart';

void main() {
  group('BookingModelCard Widget Tests', () {
    late BookingModel mockBooking;

    setUp(() {
      mockBooking = BookingModel(
        id: 'test-booking-123',
        listingId: 'listing-456',
        userId: 'user-789',
        hostId: 'host-101',
        checkIn: DateTime(2024, 3, 15, 10, 0),
        checkOut: DateTime(2024, 3, 15, 14, 0),
        hours: 4,
        totalAmount: 200.0,
        status: BookingStatus.pending,
        createdAt: DateTime(2024, 3, 10),
      );
    });

    testWidgets('should display booking information correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BookingModelCard(booking: mockBooking),
        ),
      );

      // Verificar que se muestra el ID de la reserva
      expect(find.text('Reserva #test-boo'), findsOneWidget);
      
      // Verificar que se muestra el estado
      expect(find.text('Pendiente'), findsOneWidget);
      
      // Verificar que se muestra la información de horas
      expect(find.text('4 horas'), findsOneWidget);
      
      // Verificar que se muestra el total formateado
      expect(find.textContaining('\$200'), findsOneWidget);
      
      // Verificar que se muestra el listing ID
      expect(find.text('Listing ID: listing-456'), findsOneWidget);
    });

    testWidgets('should display correct status chip for confirmed booking', (tester) async {
      final confirmedBooking = mockBooking.copyWith(status: BookingStatus.confirmed);
      
      await tester.pumpWidget(
        createTestWidget(
          BookingModelCard(booking: confirmedBooking),
        ),
      );

      expect(find.text('Confirmada'), findsOneWidget);
      
      // Verificar que el chip tiene el color correcto (verde para confirmada)
      final chipWidget = tester.widget<Container>(
        find.descendant(
          of: find.text('Confirmada'),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = chipWidget.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.green);
    });

    testWidgets('should display correct status chip for cancelled booking', (tester) async {
      final cancelledBooking = mockBooking.copyWith(status: BookingStatus.cancelled);
      
      await tester.pumpWidget(
        createTestWidget(
          BookingModelCard(booking: cancelledBooking),
        ),
      );

      expect(find.text('Cancelada'), findsOneWidget);
      
      // Verificar que el chip tiene el color correcto (rojo para cancelada)
      final chipWidget = tester.widget<Container>(
        find.descendant(
          of: find.text('Cancelada'),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = chipWidget.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.red);
    });

    testWidgets('should display correct status chip for completed booking', (tester) async {
      final completedBooking = mockBooking.copyWith(status: BookingStatus.completed);
      
      await tester.pumpWidget(
        createTestWidget(
          BookingModelCard(booking: completedBooking),
        ),
      );

      expect(find.text('Completada'), findsOneWidget);
      
      // Verificar que el chip tiene el color correcto (azul para completada)
      final chipWidget = tester.widget<Container>(
        find.descendant(
          of: find.text('Completada'),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = chipWidget.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.blue);
    });

    testWidgets('should show action buttons for pending booking', (tester) async {
      bool cancelCalled = false;
      bool confirmCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          BookingModelCard(
            booking: mockBooking,
            onCancel: () => cancelCalled = true,
            onConfirm: () => confirmCalled = true,
          ),
        ),
      );

      // Verificar que se muestran los botones de acción
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);

      // Probar el botón de cancelar
      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      expect(cancelCalled, isTrue);

      // Probar el botón de confirmar
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      expect(confirmCalled, isTrue);
    });

    testWidgets('should show only cancel button for confirmed booking', (tester) async {
      final confirmedBooking = mockBooking.copyWith(status: BookingStatus.confirmed);
      bool cancelCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          BookingModelCard(
            booking: confirmedBooking,
            onCancel: () => cancelCalled = true,
          ),
        ),
      );

      // Solo debe mostrar el botón de cancelar para reservas confirmadas
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Confirmar'), findsNothing);

      // Probar el botón de cancelar
      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      expect(cancelCalled, isTrue);
    });

    testWidgets('should not show action buttons for completed booking', (tester) async {
      final completedBooking = mockBooking.copyWith(status: BookingStatus.completed);

      await tester.pumpWidget(
        createTestWidget(
          BookingModelCard(
            booking: completedBooking,
            onCancel: () {},
            onConfirm: () {},
          ),
        ),
      );

      // No debe mostrar botones de acción para reservas completadas
      expect(find.text('Cancelar'), findsNothing);
      expect(find.text('Confirmar'), findsNothing);
    });

    testWidgets('should not show action buttons when showActions is false', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BookingModelCard(
            booking: mockBooking,
            showActions: false,
            onCancel: () {},
            onConfirm: () {},
          ),
        ),
      );

      // No debe mostrar botones de acción cuando showActions es false
      expect(find.text('Cancelar'), findsNothing);
      expect(find.text('Confirmar'), findsNothing);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      bool tapCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          BookingModelCard(
            booking: mockBooking,
            onTap: () => tapCalled = true,
          ),
        ),
      );

      // Tocar la tarjeta
      await tester.tap(find.byType(BookingModelCard));
      await tester.pump();
      
      expect(tapCalled, isTrue);
    });

    testWidgets('should display date range information', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BookingModelCard(booking: mockBooking),
        ),
      );

      // Verificar que se muestra la información de fecha
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      
      // Verificar que se muestra el rango de fechas formateado
      expect(find.textContaining('Mar 15'), findsOneWidget);
    });

    testWidgets('should display all required icons', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BookingModelCard(booking: mockBooking),
        ),
      );

      // Verificar que se muestran todos los iconos requeridos
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('should handle null callbacks gracefully', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BookingModelCard(
            booking: mockBooking,
            onTap: null,
            onCancel: null,
            onConfirm: null,
          ),
        ),
      );

      // Verificar que el widget se renderiza sin errores
      expect(find.byType(BookingModelCard), findsOneWidget);
      
      // No debe mostrar botones de acción cuando los callbacks son null
      expect(find.text('Cancelar'), findsNothing);
      expect(find.text('Confirmar'), findsNothing);
    });
  });
}