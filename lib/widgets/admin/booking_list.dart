import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:timeago/timeago.dart' as timeago;

class BookingList extends StatelessWidget {

  const BookingList({
    required this.bookings, super.key,
    this.onBookingTap,
    this.onBookingEdit,
    this.onBookingCancel,
    this.onSearch,
    this.onFilterByStatus,
    this.isLoading = false,
    this.searchQuery,
    this.selectedStatus,
  });
  final List<AdminBooking> bookings;
  final Function(AdminBooking)? onBookingTap;
  final Function(AdminBooking)? onBookingEdit;
  final Function(AdminBooking)? onBookingCancel;
  final Function(String)? onSearch;
  final Function(BookingStatus?)? onFilterByStatus;
  final bool isLoading;
  final String? searchQuery;
  final BookingStatus? selectedStatus;

  @override
  Widget build(BuildContext context) => Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reservas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${bookings.length} reservas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search and Filter Bar
            Row(
              children: [
                // Search Bar
                if (onSearch != null)
                  Expanded(
                    flex: 2,
                    child: TextField(
                      onChanged: onSearch,
                      decoration: InputDecoration(
                        hintText: 'Buscar reservas...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                
                if (onSearch != null && onFilterByStatus != null)
                  const SizedBox(width: 16),
                
                // Status Filter
                if (onFilterByStatus != null)
                  Expanded(
                    child: DropdownButtonFormField<BookingStatus?>(
                      initialValue: selectedStatus,
                      onChanged: onFilterByStatus,
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<BookingStatus?>(
                          child: Text('Todos'),
                        ),
                        ...BookingStatus.values.map(
                          (status) => DropdownMenuItem<BookingStatus?>(
                            value: status,
                            child: Text(_getStatusText(status)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Loading State
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            // Empty State
            else if (bookings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery?.isNotEmpty ?? false
                            ? 'No se encontraron reservas'
                            : 'No hay reservas registradas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // Booking List
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookings.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return BookingTile(
                    booking: booking,
                    onTap: onBookingTap != null ? () => onBookingTap!(booking) : null,
                    onEdit: onBookingEdit != null ? () => onBookingEdit!(booking) : null,
                    onCancel: onBookingCancel != null ? () => onBookingCancel!(booking) : null,
                  );
                },
              ),
          ],
        ),
      ),
    );

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pendiente';
      case BookingStatus.confirmed:
        return 'Confirmada';
      case BookingStatus.cancelled:
        return 'Cancelada';
      case BookingStatus.completed:
        return 'Completada';
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<AdminBooking>('bookings', bookings));
    properties.add(ObjectFlagProperty<Function(AdminBooking p1)?>.has('onBookingTap', onBookingTap));
    properties.add(ObjectFlagProperty<Function(AdminBooking p1)?>.has('onBookingEdit', onBookingEdit));
    properties.add(ObjectFlagProperty<Function(AdminBooking p1)?>.has('onBookingCancel', onBookingCancel));
    properties.add(ObjectFlagProperty<Function(String p1)?>.has('onSearch', onSearch));
    properties.add(ObjectFlagProperty<Function(BookingStatus? p1)?>.has('onFilterByStatus', onFilterByStatus));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
    properties.add(StringProperty('searchQuery', searchQuery));
    properties.add(EnumProperty<BookingStatus?>('selectedStatus', selectedStatus));
  }
}

class BookingTile extends StatelessWidget {

  const BookingTile({
    required this.booking, super.key,
    this.onTap,
    this.onEdit,
    this.onCancel,
  });
  final AdminBooking booking;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            // Listing Image/Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: booking.listingImageUrl?.isNotEmpty ?? false
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        booking.listingImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.home,
                            color: Colors.blue,
                            size: 24,
                          ),
                      ),
                    )
                  : const Icon(
                      Icons.home,
                      color: Colors.blue,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 16),
            
            // Booking Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.listingTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      BookingStatusChip(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Huésped: ${booking.guestName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDate(booking.checkIn)} - ${_formatDate(booking.checkOut)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${booking.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Creada ${timeago.format(booking.createdAt, locale: 'es')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            if (onEdit != null || onCancel != null)
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'cancel':
                      onCancel?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  if (onCancel != null && booking.status != BookingStatus.cancelled)
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Cancelar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AdminBooking>('booking', booking));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onEdit', onEdit));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onCancel', onCancel));
  }
}

class BookingStatusChip extends StatelessWidget {

  const BookingStatusChip({required this.status, super.key});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _getStatusColor(),
        ),
      ),
    );

  Color _getStatusColor() {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    switch (status) {
      case BookingStatus.pending:
        return 'Pendiente';
      case BookingStatus.confirmed:
        return 'Confirmada';
      case BookingStatus.cancelled:
        return 'Cancelada';
      case BookingStatus.completed:
        return 'Completada';
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<BookingStatus>('status', status));
  }
}

class AdminBooking {

  const AdminBooking({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.guestId, required this.guestName, required this.hostId, required this.hostName, required this.checkIn, required this.checkOut, required this.guests, required this.totalAmount, required this.hostEarnings, required this.platformFee, required this.status, required this.createdAt, this.listingImageUrl,
    this.updatedAt,
    this.cancellationReason,
  });

  factory AdminBooking.fromMap(Map<String, dynamic> map) => AdminBooking(
      id: (map['id'] as String?) ?? '',
      listingId: (map['listingId'] as String?) ?? '',
      listingTitle: (map['listingTitle'] as String?) ?? '',
      listingImageUrl: map['listingImageUrl'] as String?,
      guestId: (map['guestId'] as String?) ?? '',
      guestName: (map['guestName'] as String?) ?? '',
      hostId: (map['hostId'] as String?) ?? '',
      hostName: (map['hostName'] as String?) ?? '',
      checkIn: DateTime.parse(map['checkIn'] as String),
      checkOut: DateTime.parse(map['checkOut'] as String),
      guests: (map['guests'] as int?) ?? 1,
      totalAmount: ((map['totalAmount'] as num?) ?? 0).toDouble(),
      hostEarnings: ((map['hostEarnings'] as num?) ?? 0).toDouble(),
      platformFee: ((map['platformFee'] as num?) ?? 0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (map['status'] as String?),
        orElse: () => BookingStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      cancellationReason: map['cancellationReason'] as String?,
    );
  final String id;
  final String listingId;
  final String listingTitle;
  final String? listingImageUrl;
  final String guestId;
  final String guestName;
  final String hostId;
  final String hostName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double totalAmount;
  final double hostEarnings;
  final double platformFee;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? cancellationReason;

  Map<String, dynamic> toMap() => {
      'id': id,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'listingImageUrl': listingImageUrl,
      'guestId': guestId,
      'guestName': guestName,
      'hostId': hostId,
      'hostName': hostName,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'guests': guests,
      'totalAmount': totalAmount,
      'hostEarnings': hostEarnings,
      'platformFee': platformFee,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
}

enum BookingStatus { pending, confirmed, cancelled, completed }

class CompactBookingList extends StatelessWidget {

  const CompactBookingList({
    required this.bookings, super.key,
    this.maxItems = 5,
    this.onViewAll,
  });
  final List<AdminBooking> bookings;
  final int maxItems;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final displayBookings = bookings.take(maxItems).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reservas Recientes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Ver todas'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (displayBookings.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No hay reservas',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...displayBookings.map(
              (booking) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.home,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.listingTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            booking.guestName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${booking.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        BookingStatusChip(status: booking.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<AdminBooking>('bookings', bookings));
    properties.add(IntProperty('maxItems', maxItems));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onViewAll', onViewAll));
  }
}