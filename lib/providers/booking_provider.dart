import 'package:flutter/material.dart';
import 'package:salas_beats/models/booking.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/services/booking_service.dart';
import 'package:salas_beats/utils/payment_utils.dart';

class BookingProvider extends ChangeNotifier {
  
  BookingProvider(this._authProvider);
  final BookingService _bookingService = BookingService();
  final AuthProvider _authProvider;
  
  // Estado de carga
  bool _isLoading = false;
  bool _isCreatingBooking = false;
  bool _isCalculatingPrice = false;
  
  // Datos de reservas
  List<BookingModel> _userBookings = [];
  List<BookingModel> _hostBookings = [];
  BookingModel? _currentBooking;
  PriceCalculation? _currentPriceCalculation;
  
  // Filtros y búsqueda
  BookingStatus? _statusFilter;
  String _searchQuery = '';
  DateTime? _dateFilter;
  
  // Errores
  String? _error;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isCreatingBooking => _isCreatingBooking;
  bool get isCalculatingPrice => _isCalculatingPrice;
  List<BookingModel> get userBookings => _userBookings;
  List<BookingModel> get hostBookings => _hostBookings;
  BookingModel? get currentBooking => _currentBooking;
  PriceCalculation? get currentPriceCalculation => _currentPriceCalculation;
  BookingStatus? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;
  DateTime? get dateFilter => _dateFilter;
  String? get error => _error;
  
  // Getters filtrados
  List<BookingModel> get filteredUserBookings => _filterBookings(_userBookings);
  
  List<BookingModel> get filteredHostBookings => _filterBookings(_hostBookings);
  
  List<BookingModel> get upcomingBookings {
    final now = DateTime.now();
    return _userBookings
        .where((booking) => 
            booking.startTime.isAfter(now) &&
            (booking.status == BookingStatus.confirmed ||
             booking.status == BookingStatus.pending),)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
  
  List<BookingModel> get pastBookings {
    final now = DateTime.now();
    return _userBookings
        .where((booking) => 
            booking.endTime.isBefore(now) ||
            booking.status == BookingStatus.completed ||
            booking.status == BookingStatus.cancelled,)
        .toList()
      ..sort((a, b) => b.endTime.compareTo(a.endTime));
  }
  
  List<BookingModel> get activeBookings {
    final now = DateTime.now();
    return _userBookings
        .where((booking) => 
            booking.startTime.isBefore(now) &&
            booking.endTime.isAfter(now) &&
            booking.status == BookingStatus.confirmed,)
        .toList();
  }
  
  // Métodos de filtrado
  List<BookingModel> _filterBookings(List<BookingModel> bookings) {
    var filtered = bookings;
    
    // Filtrar por estado
    if (_statusFilter != null) {
      filtered = filtered.where((booking) => booking.status == _statusFilter).toList();
    }
    
    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((booking) {
        // TODO: Obtener información del listing para buscar por nombre
        return booking.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               false; // specialRequests field not available
      }).toList();
    }
    
    // Filtrar por fecha
    if (_dateFilter != null) {
      filtered = filtered.where((booking) {
        final bookingDate = DateTime(
          booking.startTime.year,
          booking.startTime.month,
          booking.startTime.day,
        );
        final filterDate = DateTime(
          _dateFilter!.year,
          _dateFilter!.month,
          _dateFilter!.day,
        );
        return bookingDate.isAtSameMomentAs(filterDate);
      }).toList();
    }
    
    return filtered;
  }
  
  // Métodos de filtros
  void setStatusFilter(BookingStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void setDateFilter(DateTime? date) {
    _dateFilter = date;
    notifyListeners();
  }
  
  void clearFilters() {
    _statusFilter = null;
    _searchQuery = '';
    _dateFilter = null;
    notifyListeners();
  }
  
  // Métodos de carga de datos
  Future<void> loadUserBookings() async {
    if (_authProvider.currentUser == null) return;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _userBookings = await _bookingService.getUserBookings(_authProvider.currentUser!.id);
      
    } catch (e) {
      _error = 'Error al cargar reservas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadHostBookings() async {
    if (_authProvider.currentUser == null || _authProvider.currentUser!.role != 'host') {
      return;
    }
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _hostBookings = await _bookingService.getHostBookings(_authProvider.currentUser!.id);
      
    } catch (e) {
      _error = 'Error al cargar reservas del anfitrión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadBookingById(String bookingId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _currentBooking = await _bookingService.getBookingById(bookingId);
      
    } catch (e) {
      _error = 'Error al cargar reserva: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Cálculo de precios
  Future<void> calculatePrice({
    required String listingId,
    required DateTime startTime,
    required DateTime endTime,
    required String cityId,
    int guestCount = 1,
  }) async {
    try {
      _isCalculatingPrice = true;
      _error = null;
      notifyListeners();
      
      _currentPriceCalculation = await _bookingService.calculatePrice(
        listingId: listingId,
        startTime: startTime,
        endTime: endTime,
        cityId: cityId,
        guestCount: guestCount,
      );
      
    } catch (e) {
      _error = 'Error al calcular precio: $e';
      _currentPriceCalculation = null;
    } finally {
      _isCalculatingPrice = false;
      notifyListeners();
    }
  }
  
  // Verificación de disponibilidad
  Future<bool> checkAvailability({
    required String listingId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      return await _bookingService.checkAvailability(
        listingId: listingId,
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      _error = 'Error al verificar disponibilidad: $e';
      return false;
    }
  }
  
  // Creación de reservas
  Future<BookingResult> createBooking({
    required String listingId,
    required DateTime startTime,
    required DateTime endTime,
    required int guestCount,
    required String paymentMethodId,
    String? specialRequests,
    Map<String, dynamic>? metadata,
  }) async {
    if (_authProvider.currentUser == null) {
      return BookingResult.error('Usuario no autenticado');
    }
    
    try {
      _isCreatingBooking = true;
      _error = null;
      notifyListeners();
      
      final result = await _bookingService.createBooking(
        userId: _authProvider.currentUser!.id,
        listingId: listingId,
        startTime: startTime,
        endTime: endTime,
        guestCount: guestCount,
        paymentMethodId: paymentMethodId,
        specialRequests: specialRequests,
        metadata: metadata,
      );
      
      if (result.success && result.booking != null) {
        _currentBooking = result.booking;
        // Actualizar la lista de reservas del usuario
        _userBookings.insert(0, result.booking!);
      } else {
        _error = result.error;
      }
      
      return result;
      
    } catch (e) {
      _error = 'Error al crear reserva: $e';
      return BookingResult.error(_error!);
    } finally {
      _isCreatingBooking = false;
      notifyListeners();
    }
  }
  
  // Actualización de estado de reservas
  Future<bool> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
    String? cancellationReason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _error = null;
      
      final success = await _bookingService.updateBookingStatus(
        bookingId: bookingId,
        status: status,
        cancellationReason: cancellationReason,
        metadata: metadata,
      );
      
      if (success) {
        // Actualizar la reserva en las listas locales
        _updateBookingInLists(bookingId, (booking) => booking.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        ),);
        
        // Si es la reserva actual, actualizarla también
        if (_currentBooking?.id == bookingId) {
          _currentBooking = _currentBooking!.copyWith(
            status: status,
            updatedAt: DateTime.now(),
          );
        }
        
        notifyListeners();
      } else {
        _error = 'Error al actualizar estado de reserva';
      }
      
      return success;
      
    } catch (e) {
      _error = 'Error al actualizar reserva: $e';
      return false;
    }
  }
  
  // Cancelación de reservas
  Future<BookingResult> cancelBooking({
    required String bookingId,
    required String reason,
    required String cancelledBy,
  }) async {
    try {
      _error = null;
      
      final result = await _bookingService.cancelBooking(
        bookingId: bookingId,
        reason: reason,
        cancelledBy: cancelledBy,
      );
      
      if (result.success && result.booking != null) {
        // Actualizar la reserva en las listas locales
        _updateBookingInLists(bookingId, (booking) => result.booking!);
        
        // Si es la reserva actual, actualizarla también
        if (_currentBooking?.id == bookingId) {
          _currentBooking = result.booking;
        }
        
        notifyListeners();
      } else {
        _error = result.error;
      }
      
      return result;
      
    } catch (e) {
      _error = 'Error al cancelar reserva: $e';
      return BookingResult.error(_error!);
    }
  }
  
  // Actualización de estado de pago
  Future<bool> updatePaymentStatus({
    required String bookingId,
    required PaymentStatus paymentStatus,
    String? paymentIntentId,
    String? stripeChargeId,
    Map<String, dynamic>? paymentMetadata,
  }) async {
    try {
      _error = null;
      
      final success = await _bookingService.updatePaymentStatus(
        bookingId: bookingId,
        paymentStatus: paymentStatus,
        paymentIntentId: paymentIntentId,
        stripeChargeId: stripeChargeId,
        paymentMetadata: paymentMetadata,
      );
      
      if (success) {
        // Actualizar la reserva en las listas locales
        _updateBookingInLists(bookingId, (booking) => booking.copyWith(
          status: BookingStatus.paid,
          updatedAt: DateTime.now(),
        ),);
        
        // Si es la reserva actual, actualizarla también
        if (_currentBooking?.id == bookingId) {
          _currentBooking = _currentBooking!.copyWith(
            status: BookingStatus.paid,
            updatedAt: DateTime.now(),
          );
        }
        
        notifyListeners();
      } else {
        _error = 'Error al actualizar estado de pago';
      }
      
      return success;
      
    } catch (e) {
      _error = 'Error al actualizar pago: $e';
      return false;
    }
  }
  
  // Obtener estadísticas
  Future<Map<String, dynamic>?> getHostBookingStats() async {
    if (_authProvider.currentUser == null || _authProvider.currentUser!.role != 'host') {
      return null;
    }
    
    try {
      return await _bookingService.getHostBookingStats(_authProvider.currentUser!.id);
    } catch (e) {
      _error = 'Error al obtener estadísticas: $e';
      return null;
    }
  }
  
  // Métodos de utilidad
  void _updateBookingInLists(String bookingId, BookingModel Function(BookingModel) updater) {
    // Actualizar en reservas de usuario
    final userIndex = _userBookings.indexWhere((b) => b.id == bookingId);
    if (userIndex != -1) {
      _userBookings[userIndex] = updater(_userBookings[userIndex]);
    }
    
    // Actualizar en reservas de anfitrión
    final hostIndex = _hostBookings.indexWhere((b) => b.id == bookingId);
    if (hostIndex != -1) {
      _hostBookings[hostIndex] = updater(_hostBookings[hostIndex]);
    }
  }
  
  // Limpiar datos
  void clearCurrentBooking() {
    _currentBooking = null;
    notifyListeners();
  }
  
  void clearCurrentPriceCalculation() {
    _currentPriceCalculation = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Refrescar datos
  Future<void> refresh() async {
    await Future.wait([
      loadUserBookings(),
      if (_authProvider.currentUser?.role == 'host') loadHostBookings(),
    ]);
  }
  
  // Streams en tiempo real
  Stream<List<BookingModel>>? getUserBookingsStream() {
    if (_authProvider.currentUser == null) return null;
    
    return _bookingService.getUserBookingsStream(_authProvider.currentUser!.id);
  }
  
  Stream<List<BookingModel>>? getHostBookingsStream() {
    if (_authProvider.currentUser == null || _authProvider.currentUser!.role != 'host') {
      return null;
    }
    
    return _bookingService.getHostBookingsStream(_authProvider.currentUser!.id);
  }
  
}