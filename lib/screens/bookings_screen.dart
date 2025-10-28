import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salas_beats/models/booking.dart';
import 'package:salas_beats/utils/app_routes.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data - en producción vendría de Firestore
  final List<BookingModel> _mockBookings = [
    BookingModel(
      id: 'booking1',
      listingId: 'listing1',
      hostId: 'host1',
      guestId: 'guest1',
      startTime: DateTime.now().add(const Duration(days: 2, hours: 14)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 17)),
      hours: 3,
      pricePerHour: 450,
      subtotal: 1350,
      guestServiceFeePct: 15.3,
      guestServiceFee: 206.55,
      hostFeePct: 3,
      hostFee: 40.5,
      taxes: 216,
      totalGuestPay: 1772.55,
      hostPayout: 1309.5,
      status: BookingStatus.paid,
      paymentIntentId: 'pi_123',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BookingModel(
      id: 'booking2',
      listingId: 'listing2',
      hostId: 'host2',
      guestId: 'guest1',
      startTime: DateTime.now().subtract(const Duration(days: 3, hours: -10)),
      endTime: DateTime.now().subtract(const Duration(days: 3, hours: -12)),
      hours: 2,
      pricePerHour: 280,
      subtotal: 560,
      guestServiceFeePct: 16.5,
      guestServiceFee: 92.4,
      hostFeePct: 3,
      hostFee: 16.8,
      taxes: 89.6,
      totalGuestPay: 742,
      hostPayout: 543.2,
      status: BookingStatus.paid,
      paymentIntentId: 'pi_456',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    BookingModel(
      id: 'booking3',
      listingId: 'listing3',
      hostId: 'host3',
      guestId: 'guest1',
      startTime: DateTime.now().add(const Duration(days: 7, hours: 16)),
      endTime: DateTime.now().add(const Duration(days: 7, hours: 19)),
      hours: 3,
      pricePerHour: 350,
      subtotal: 1050,
      guestServiceFeePct: 14.1,
      guestServiceFee: 148.05,
      hostFeePct: 3,
      hostFee: 31.5,
      taxes: 168,
      totalGuestPay: 1366.05,
      hostPayout: 1018.5,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    BookingModel(
      id: 'booking4',
      listingId: 'listing4',
      hostId: 'host4',
      guestId: 'guest1',
      startTime: DateTime.now().subtract(const Duration(days: 10, hours: -14)),
      endTime: DateTime.now().subtract(const Duration(days: 10, hours: -16)),
      hours: 2,
      pricePerHour: 380,
      subtotal: 760,
      guestServiceFeePct: 15.3,
      guestServiceFee: 116.28,
      hostFeePct: 3,
      hostFee: 22.8,
      taxes: 121.6,
      totalGuestPay: 997.88,
      hostPayout: 737.2,
      status: BookingStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];
  
  // Mock listings data
  final Map<String, String> _listingTitles = {
    'listing1': 'Estudio de Grabación Pro',
    'listing2': 'Sala de Ensayo Rock',
    'listing3': 'Estudio Acústico',
    'listing4': 'Sala de Producción',
  };
  
  final Map<String, String> _listingAddresses = {
    'listing1': 'Roma Norte, CDMX',
    'listing2': 'Condesa, CDMX',
    'listing3': 'Polanco, CDMX',
    'listing4': 'Del Valle, CDMX',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BookingModel> get _upcomingBookings => _mockBookings.where((booking) => booking.status == BookingStatus.paid && booking.startTime.isAfter(DateTime.now())).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

  List<BookingModel> get _pastBookings => _mockBookings.where((booking) => booking.status == BookingStatus.paid && booking.endTime.isBefore(DateTime.now())).toList()..sort((a, b) => b.startTime.compareTo(a.startTime));

  List<BookingModel> get _pendingAndCancelledBookings => _mockBookings.where((booking) => booking.status == BookingStatus.pending || booking.status == BookingStatus.cancelled).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void _navigateToBookingDetail(BookingModel booking) {
    Navigator.of(context).pushNamed(
      AppRoutes.bookingDetail,
      arguments: booking.id,
    );
  }

  void _navigateToListing(String listingId) {
    Navigator.of(context).pushNamed(
      AppRoutes.listingDetail,
      arguments: listingId,
    );
  }

  void _contactHost(String hostId, String listingId) {
    Navigator.of(context).pushNamed(
        AppRoutes.chatRoom,
        arguments: {
          'hostId': hostId,
          'listingId': listingId,
        },
      );
  }

  void _cancelBooking(BookingModel booking) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Estás seguro de que quieres cancelar esta reserva?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Política de cancelación:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reembolso completo hasta 24 horas antes del inicio.',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar lógica de cancelación
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reserva cancelada. El reembolso se procesará en 3-5 días hábiles.'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  void _writeReview(BookingModel booking) {
    Navigator.of(context).pushNamed(
        AppRoutes.reviewCreate,
        arguments: {
          'bookingId': booking.id,
          'listingId': booking.listingId,
          'hostId': booking.hostId,
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            _buildTabBar(theme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingTab(theme),
                  _buildPastTab(theme),
                  _buildOtherTab(theme),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(theme),
    );
  }

  Widget _buildHeader(ThemeData theme) => Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            'Mis Reservas',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Implementar filtros/búsqueda
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );

  Widget _buildTabBar(ThemeData theme) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        tabs: [
          Tab(
            text: 'Próximas (${_upcomingBookings.length})',
          ),
          Tab(
            text: 'Pasadas (${_pastBookings.length})',
          ),
          Tab(
            text: 'Otras (${_pendingAndCancelledBookings.length})',
          ),
        ],
      ),
    );

  Widget _buildUpcomingTab(ThemeData theme) {
    if (_upcomingBookings.isEmpty) {
      return _buildEmptyState(
        theme,
        Icons.calendar_today,
        'No tienes reservas próximas',
        'Explora salas increíbles y haz tu primera reserva',
        'Explorar salas',
        () => Navigator.of(context).pushNamed(AppRoutes.explore),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _upcomingBookings.length,
      itemBuilder: (context, index) => _buildBookingCard(
          _upcomingBookings[index],
          theme,
          isUpcoming: true,
        ),
    );
  }

  Widget _buildPastTab(ThemeData theme) {
    if (_pastBookings.isEmpty) {
      return _buildEmptyState(
        theme,
        Icons.history,
        'No tienes reservas pasadas',
        'Tus reservas completadas aparecerán aquí',
        null,
        null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _pastBookings.length,
      itemBuilder: (context, index) => _buildBookingCard(
          _pastBookings[index],
          theme,
          isPast: true,
        ),
    );
  }

  Widget _buildOtherTab(ThemeData theme) {
    if (_pendingAndCancelledBookings.isEmpty) {
      return _buildEmptyState(
        theme,
        Icons.pending_actions,
        'No hay reservas pendientes o canceladas',
        'Las reservas pendientes de pago o canceladas aparecerán aquí',
        null,
        null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _pendingAndCancelledBookings.length,
      itemBuilder: (context, index) => _buildBookingCard(
          _pendingAndCancelledBookings[index],
          theme,
        ),
    );
  }

  Widget _buildBookingCard(
    BookingModel booking,
    ThemeData theme, {
    bool isUpcoming = false,
    bool isPast = false,
  }) {
    final listingTitle = _listingTitles[booking.listingId] ?? 'Sala desconocida';
    final listingAddress = _listingAddresses[booking.listingId] ?? 'Dirección no disponible';
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (booking.status) {
      case BookingStatus.paid:
        statusColor = Colors.green;
        statusText = 'Confirmada';
        statusIcon = Icons.check_circle;
        break;
      case BookingStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pendiente de pago';
        statusIcon = Icons.pending;
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelada';
        statusIcon = Icons.cancel;
        break;
      case BookingStatus.refunded:
        statusColor = Colors.blue;
        statusText = 'Reembolsada';
        statusIcon = Icons.money_off;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Estado desconocido';
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToBookingDetail(booking),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado y precio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${booking.totalGuestPay.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información del listing
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.3),
                          theme.colorScheme.secondary.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listingTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                listingAddress,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Fecha y hora
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      booking.formattedDateRange,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${booking.hours}h)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Botones de acción
              Row(
                children: [
                  if (isUpcoming && booking.status == BookingStatus.paid) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _contactHost(booking.hostId, booking.listingId),
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Contactar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelBooking(booking),
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ] else if (isPast && booking.status == BookingStatus.paid) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _writeReview(booking),
                        icon: const Icon(Icons.star, size: 16),
                        label: const Text('Escribir reseña'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToListing(booking.listingId),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Reservar otra vez'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ] else if (booking.status == BookingStatus.pending) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Completar pago
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Redirigiendo a completar pago...'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text('Completar pago'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToListing(booking.listingId),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Ver sala'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
  ) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );

  Widget _buildBottomNavBar(ThemeData theme) => BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 2,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Explorar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Reservas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Mensajes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutes.home);
            break;
          case 1:
            context.go(AppRoutes.explore);
            break;
          case 2:
            // Ya estamos en bookings
            break;
          case 3:
            context.go(AppRoutes.chatList);
            break;
          case 4:
            context.go(AppRoutes.profile);
            break;
        }
      },
    );
}