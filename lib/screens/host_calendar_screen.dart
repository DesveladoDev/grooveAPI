import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/models/booking.dart';
import 'package:salas_beats/providers/booking_provider.dart';
import 'package:salas_beats/widgets/common/custom_error_widget.dart';
import 'package:salas_beats/widgets/common/loading_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class HostCalendarScreen extends StatefulWidget {
  
  const HostCalendarScreen({super.key, this.listingId});
  final String? listingId;

  @override
  State<HostCalendarScreen> createState() => _HostCalendarScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('listingId', listingId));
  }
}

class _HostCalendarScreenState extends State<HostCalendarScreen> {
  late final ValueNotifier<List<BookingModel>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<BookingModel>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHostBookings();
    });
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _loadHostBookings() async {
    try {
      await context.read<BookingProvider>().loadHostBookings();
      _updateEvents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar reservas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateEvents() {
    final provider = context.read<BookingProvider>();
    final bookings = provider.hostBookings;
    
    final events = <DateTime, List<BookingModel>>{};
    
    for (final booking in bookings) {
      final date = DateTime(booking.startTime.year, booking.startTime.month, booking.startTime.day);
      if (events[date] != null) {
        events[date]!.add(booking);
      } else {
        events[date] = [booking];
      }
    }
    
    setState(() {
      _events = events;
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  List<BookingModel> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Reservas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
                _selectedEvents.value = _getEventsForDay(_selectedDay!);
              });
            },
          ),
          PopupMenuButton<CalendarFormat>(
            onSelected: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarFormat.month,
                child: Text('Vista mensual'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.twoWeeks,
                child: Text('Vista quincenal'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.week,
                child: Text('Vista semanal'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.hostBookings.isEmpty) {
            return const LoadingWidget();
          }

          // Error handling commented out - hasError not available in BookingProvider
          // if (provider.hasError) {
          //   return CustomErrorWidget(
          //     message: provider.error!,
          //     onRetry: _loadHostBookings,
          //   );
          // }

          return Column(
            children: [
              _buildCalendar(),
              const SizedBox(height: 8),
              Expanded(
                child: _buildEventsList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAvailabilityDialog,
        child: const Icon(Icons.event_available),
      ),
    );

  Widget _buildCalendar() => Card(
      margin: const EdgeInsets.all(8),
      child: TableCalendar<BookingModel>(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
          holidayTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        onDaySelected: _onDaySelected,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getEventColor(events.cast<BookingModel>()),
                    shape: BoxShape.circle,
                  ),
                  width: 16,
                  height: 16,
                  child: Center(
                    child: Text(
                      '${events.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );

  Widget _buildEventsList() => ValueListenableBuilder<List<BookingModel>>(
      valueListenable: _selectedEvents,
      builder: (context, value, _) {
        if (value.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay reservas para este día',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: value.length,
          itemBuilder: (context, index) {
            final booking = value[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(booking.status.toString()),
                  child: Icon(
                    _getStatusIcon(booking.status.toString()),
                    color: Colors.white,
                  ),
                ),
                title: Text(booking.listingId ?? 'Reserva'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Cliente: ${booking.guestId ?? 'N/A'}'),
                    Text('Estado: ${_getStatusText(booking.status.toString())}'),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) => _handleBookingAction(action, booking),
                  itemBuilder: (context) => [
                    if (booking.status == 'pending')
                      const PopupMenuItem(
                        value: 'accept',
                        child: Text('Aceptar'),
                      ),
                    if (booking.status == 'pending')
                      const PopupMenuItem(
                        value: 'reject',
                        child: Text('Rechazar'),
                      ),
                    const PopupMenuItem(
                      value: 'details',
                      child: Text('Ver detalles'),
                    ),
                    if (booking.status == 'confirmed')
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Text('Cancelar'),
                      ),
                  ],
                ),
                onTap: () => _navigateToBookingDetail(booking),
              ),
            );
          },
        );
      },
    );

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }

  Color _getEventColor(List<BookingModel> events) {
    if (events.any((e) => e.status == 'confirmed')) {
      return Colors.green;
    } else if (events.any((e) => e.status == 'pending')) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmada';
      case 'pending':
        return 'Pendiente';
      case 'cancelled':
        return 'Cancelada';
      case 'completed':
        return 'Completada';
      default:
        return 'Desconocido';
    }
  }

  String _formatTime(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  void _handleBookingAction(String action, BookingModel booking) {
    switch (action) {
      case 'accept':
        _acceptBooking(booking);
        break;
      case 'reject':
        _rejectBooking(booking);
        break;
      case 'cancel':
        _cancelBooking(booking);
        break;
      case 'details':
        _navigateToBookingDetail(booking);
        break;
    }
  }

  Future<void> _acceptBooking(BookingModel booking) async {
    try {
      // TODO: Implementar método acceptBooking en BookingProvider
      // await context.read<BookingProvider>().acceptBooking(booking.id);
      _updateEvents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva aceptada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al aceptar reserva: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectBooking(BookingModel booking) async {
    try {
      // TODO: Implementar método rejectBooking en BookingProvider
      // await context.read<BookingProvider>().rejectBooking(booking.id);
      _updateEvents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Funcionalidad de rechazo pendiente de implementar'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al rechazar reserva: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text('¿Estás seguro de que quieres cancelar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await context.read<BookingProvider>().cancelBooking(
          bookingId: booking.id,
          reason: 'Cancelado por el host',
          cancelledBy: 'host',
        );
        _updateEvents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reserva cancelada'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cancelar reserva: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToBookingDetail(BookingModel booking) {
    Navigator.pushNamed(
      context,
      AppRoutes.bookingDetail,
      arguments: {'bookingId': booking.id},
    );
  }

  void _showAvailabilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestionar Disponibilidad'),
        content: const Text('Esta funcionalidad estará disponible próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}