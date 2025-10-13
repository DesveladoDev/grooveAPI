import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/models/booking_model.dart';
import 'package:salas_beats/utils/helpers.dart';
import 'package:salas_beats/widgets/common/empty_state.dart';
import 'package:salas_beats/widgets/common/loading_widget.dart';

class BookingList extends StatelessWidget {

  const BookingList({
    required this.bookings, super.key,
    this.isLoading = false,
    this.emptyMessage,
    this.onBookingTap,
    this.onCancelBooking,
    this.onConfirmBooking,
    this.showActions = true,
  });
  final List<BookingModel> bookings;
  final bool isLoading;
  final String? emptyMessage;
  final Function(BookingModel)? onBookingTap;
  final Function(BookingModel)? onCancelBooking;
  final Function(BookingModel)? onConfirmBooking;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingWidget(message: 'Cargando reservas...');
    }

    if (bookings.isEmpty) {
      return EmptyState(
        title: 'No hay reservas',
        message: emptyMessage ?? 'No se encontraron reservas en este momento.',
        icon: Icons.event_busy,
      );
    }

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BookingCard(
          booking: booking,
          onTap: () => onBookingTap?.call(booking),
          onCancel: onCancelBooking != null
              ? () => onCancelBooking!.call(booking)
              : null,
          onConfirm: onConfirmBooking != null
              ? () => onConfirmBooking!.call(booking)
              : null,
          showActions: showActions,
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<BookingModel>('bookings', bookings));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
    properties.add(StringProperty('emptyMessage', emptyMessage));
    properties.add(ObjectFlagProperty<Function(BookingModel p1)?>.has('onBookingTap', onBookingTap));
    properties.add(ObjectFlagProperty<Function(BookingModel p1)?>.has('onCancelBooking', onCancelBooking));
    properties.add(ObjectFlagProperty<Function(BookingModel p1)?>.has('onConfirmBooking', onConfirmBooking));
    properties.add(DiagnosticsProperty<bool>('showActions', showActions));
  }
}

class BookingCard extends StatelessWidget {

  const BookingCard({
    required this.booking, super.key,
    this.onTap,
    this.onCancel,
    this.onConfirm,
    this.showActions = true,
  });
  final BookingModel booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reserva #${booking.id.substring(0, 8)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 12),
              
              // Información de la reserva
              _buildBookingInfo(context),
              
              // Fechas
              const SizedBox(height: 12),
              _buildDateInfo(context),
              
              // Acciones
              if (showActions && _shouldShowActions()) ...[
                const SizedBox(height: 16),
                _buildActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (booking.status) {
      case BookingStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        statusText = 'Pendiente';
        break;
      case BookingStatus.confirmed:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        statusText = 'Confirmada';
        break;
      case BookingStatus.cancelled:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        statusText = 'Cancelada';
        break;
      case BookingStatus.completed:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        statusText = 'Completada';
        break;
      case BookingStatus.paid:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        statusText = 'Pagada';
        break;
      case BookingStatus.inProgress:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        statusText = 'En progreso';
        break;
      case BookingStatus.refunded:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        statusText = 'Reembolsada';
        break;
      case BookingStatus.partialRefund:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        statusText = 'Reembolso parcial';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBookingInfo(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          booking.listingTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.people, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${booking.guestCount} huéspedes',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '\$${booking.totalAmount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildDateInfo(BuildContext context) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${Helpers.formatDate(booking.startTime)} - ${Helpers.formatDate(booking.endTime)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );

  Widget _buildActions(BuildContext context) => Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onCancel != null && booking.status == BookingStatus.pending) ...[
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
        ],
        if (onConfirm != null && booking.status == BookingStatus.pending)
          ElevatedButton(
            onPressed: onConfirm,
            child: const Text('Confirmar'),
          ),
      ],
    );

  bool _shouldShowActions() => booking.status == BookingStatus.pending &&
           (onCancel != null || onConfirm != null);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BookingModel>('booking', booking));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onCancel', onCancel));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onConfirm', onConfirm));
    properties.add(DiagnosticsProperty<bool>('showActions', showActions));
  }
}