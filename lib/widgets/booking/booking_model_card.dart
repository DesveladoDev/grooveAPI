import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/models/booking_model.dart';

class BookingModelCard extends StatelessWidget {

  const BookingModelCard({
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
    Color statusColor;
    String statusText;
    
    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = Colors.green;
        statusText = 'Confirmada';
        break;
      case BookingStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelada';
        break;
      case BookingStatus.completed:
        statusColor = Colors.blue;
        statusText = 'Completada';
        break;
      case BookingStatus.paid:
        statusColor = Colors.green;
        statusText = 'Pagada';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconocido';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBookingInfo(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Listing ID: ${booking.listingId}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.people, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${booking.hours} horas',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              booking.formattedTotal,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
          Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              booking.formattedDateRange,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

  bool _shouldShowActions() => booking.status == BookingStatus.pending || 
           booking.status == BookingStatus.confirmed;

  Widget _buildActions(BuildContext context) => Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onCancel != null && booking.canBeCancelled)
          TextButton(
            onPressed: onCancel,
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        if (onConfirm != null && booking.status == BookingStatus.pending)
          const SizedBox(width: 8),
        if (onConfirm != null && booking.status == BookingStatus.pending)
          ElevatedButton(
            onPressed: onConfirm,
            child: const Text('Confirmar'),
          ),
      ],
    );

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