import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/models/booking_model.dart';
import 'package:salas_beats/providers/booking_provider.dart';
import 'package:salas_beats/widgets/booking/booking_model_card.dart';
import 'package:salas_beats/widgets/common/custom_error_widget.dart';
import 'package:salas_beats/widgets/common/loading_widget.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadUserBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Activas'),
            Tab(text: 'Completadas'),
            Tab(text: 'Canceladas'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.userBookings.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.error != null) {
            return CustomErrorWidget(
              message: provider.error,
              onRetry: provider.loadUserBookings,
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(provider.userBookings),
              _buildBookingsList(_getFilteredBookings(provider.userBookings, 'active')),
              _buildBookingsList(_getFilteredBookings(provider.userBookings, 'completed')),
              _buildBookingsList(_getFilteredBookings(provider.userBookings, 'cancelled')),
            ],
          );
        },
      ),
    );

  Widget _buildBookingsList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No tienes reservas en esta categoría',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BookingProvider>().loadUserBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BookingModelCard(
              booking: booking,
              onTap: () => _navigateToBookingDetail(booking),
              onCancel: booking.canBeCancelled ? () => _cancelBooking(booking) : null,
            ),
          );
        },
      ),
    );
  }

  List<BookingModel> _getFilteredBookings(List<BookingModel> bookings, String filter) {
    switch (filter) {
      case 'active':
        return bookings.where((b) => b.status == 'confirmed' || b.status == 'pending').toList();
      case 'completed':
        return bookings.where((b) => b.status == 'completed').toList();
      case 'cancelled':
        return bookings.where((b) => b.status == 'cancelled').toList();
      default:
        return bookings;
    }
  }

  void _navigateToBookingDetail(BookingModel booking) {
    Navigator.pushNamed(
      context,
      AppRoutes.bookingDetail,
      arguments: {'bookingId': booking.id},
    );
  }

  void _cancelBooking(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text('¿Estás seguro de que quieres cancelar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BookingProvider>().cancelBooking(
                bookingId: booking.id,
                reason: 'Cancelado por el usuario',
                cancelledBy: 'user',
              );
            },
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}