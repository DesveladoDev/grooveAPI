import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salas_beats/models/booking_model.dart';
import 'package:salas_beats/models/listing_model.dart';
import 'package:salas_beats/models/settings_model.dart';
import 'package:salas_beats/utils/payment_utils.dart';

class BookingResult {

  BookingResult({
    required this.success,
    this.error,
    this.booking,
    this.bookingId,
  });

  factory BookingResult.success(BookingModel booking, String bookingId) => BookingResult(
      success: true,
      booking: booking,
      bookingId: bookingId,
    );

  factory BookingResult.error(String error) => BookingResult(
      success: false,
      error: error,
    );
  final bool success;
  final String? error;
  final BookingModel? booking;
  final String? bookingId;
}

class PriceCalculation {

  PriceCalculation({
    required this.basePrice,
    required this.serviceFee,
    required this.hostFee,
    required this.taxes,
    required this.totalPrice,
    required this.hostEarnings,
    required this.platformRevenue,
    required this.totalHours,
    required this.breakdown,
  });

  factory PriceCalculation.fromJson(Map<String, dynamic> json) => PriceCalculation(
      basePrice: ((json['basePrice'] ?? 0.0) as num).toDouble(),
      serviceFee: ((json['serviceFee'] ?? 0.0) as num).toDouble(),
      hostFee: ((json['hostFee'] ?? 0.0) as num).toDouble(),
      taxes: ((json['taxes'] ?? 0.0) as num).toDouble(),
      totalPrice: ((json['totalPrice'] ?? 0.0) as num).toDouble(),
      hostEarnings: ((json['hostEarnings'] ?? 0.0) as num).toDouble(),
      platformRevenue: ((json['platformRevenue'] ?? 0.0) as num).toDouble(),
      totalHours: (json['totalHours'] ?? 0) as int,
      breakdown: Map<String, double>.from(json['breakdown'] as Map<dynamic, dynamic>? ?? <String, double>{}),
    );
  final double basePrice;
  final double serviceFee;
  final double hostFee;
  final double taxes;
  final double totalPrice;
  final double hostEarnings;
  final double platformRevenue;
  final int totalHours;
  final Map<String, double> breakdown;

  Map<String, dynamic> toJson() => {
      'basePrice': basePrice,
      'serviceFee': serviceFee,
      'hostFee': hostFee,
      'taxes': taxes,
      'totalPrice': totalPrice,
      'hostEarnings': hostEarnings,
      'platformRevenue': platformRevenue,
      'totalHours': totalHours,
      'breakdown': breakdown,
    };
}

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Colecciones
  static const String _bookingsCollection = 'bookings';
  static const String _listingsCollection = 'listings';
  static const String _usersCollection = 'users';
  static const String _settingsCollection = 'settings';
  
  /// Calcula el precio total de una reserva incluyendo comisiones y tarifas
  Future<PriceCalculation> calculatePrice({
    required String listingId,
    required DateTime startTime,
    required DateTime endTime,
    required String cityId,
    int guestCount = 1,
  }) async {
    // Validaciones de entrada
    if (listingId.isEmpty) {
      throw ArgumentError('listingId no puede estar vacío');
    }
    if (startTime.isAfter(endTime)) {
      throw ArgumentError('startTime debe ser anterior a endTime');
    }
    if (guestCount <= 0) {
      throw ArgumentError('guestCount debe ser mayor a 0');
    }
    if (cityId.isEmpty) {
      throw ArgumentError('cityId no puede estar vacío');
    }

    try {
      // Obtener información del listing
      final listingDoc = await _firestore
          .collection(_listingsCollection)
          .doc(listingId)
          .get();
      
      if (!listingDoc.exists) {
        throw StateError('Listing con ID $listingId no encontrado');
      }
      
      final listing = ListingModel.fromFirestore(listingDoc);
      
      // Obtener configuraciones del sistema
      final settingsDoc = await _firestore
          .collection(_settingsCollection)
          .doc('main')
          .get();
      
      SettingsModel settings;
      if (settingsDoc.exists) {
        settings = SettingsModel.fromFirestore(settingsDoc);
      } else {
        settings = SettingsModel.createDefault();
      }
      
      // Calcular duración en horas
      final duration = endTime.difference(startTime);
      final totalHours = duration.inHours;
      
      if (totalHours <= 0) {
        throw ArgumentError('La duración debe ser mayor a 0 horas. Duración actual: $totalHours horas');
      }
      
      // Validar duración máxima (24 horas)
      if (totalHours > 24) {
        throw ArgumentError('La duración no puede exceder 24 horas. Duración solicitada: $totalHours horas');
      }
      
      // Precio base
      var basePrice = listing.hourlyPrice * totalHours;
      
      // Aplicar descuentos por duración (lógica simplificada)
      if (totalHours >= 8) {
        basePrice *= 0.9; // 10% descuento para 8+ horas
      } else if (totalHours >= 4) {
        basePrice *= 0.95; // 5% descuento para 4+ horas
      }
      
      // Obtener configuración de la ciudad
      final cityConfig = settings.citiesWhitelist.firstWhere(
        (city) => city.cityCode == cityId,
        orElse: () => CityConfig(
          cityCode: cityId,
          name: cityId,
          country: 'MX',
        ),
      );
      
      // Calcular comisión de servicio (pagada por el usuario)
      final serviceFee = basePrice * settings.getServiceFeePercentage(basePrice) / 100;
      
      // Calcular comisión del anfitrión (descontada de las ganancias)
      final hostFee = basePrice * (settings.hostFeePct / 100);
      
      // Calcular impuestos
      var taxes = 0.0;
      final taxRate = settings.getTaxRate(cityConfig.country);
      if (taxRate != null) {
        taxes = (basePrice + serviceFee) * taxRate.rate;
      }
      
      // Totales
      final totalPrice = basePrice + serviceFee + taxes;
      final hostEarnings = basePrice - hostFee;
      final platformRevenue = serviceFee + hostFee;
      
      // Desglose detallado
      final breakdown = <String, double>{
        'basePrice': basePrice,
        'serviceFee': serviceFee,
        'hostFee': hostFee,
        'taxes': taxes,
        'totalPrice': totalPrice,
        'hostEarnings': hostEarnings,
        'platformRevenue': platformRevenue,
      };
      
      return PriceCalculation(
        basePrice: basePrice,
        serviceFee: serviceFee,
        hostFee: hostFee,
        taxes: taxes,
        totalPrice: totalPrice,
        hostEarnings: hostEarnings,
        platformRevenue: platformRevenue,
        totalHours: totalHours,
        breakdown: breakdown,
      );
      
    } catch (e) {
      throw Exception('Error al calcular precio: $e');
    }
  }
  
  /// Verifica la disponibilidad de un listing en un rango de tiempo
  Future<bool> checkAvailability({
    required String listingId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      // Verificar que no haya reservas conflictivas
      final conflictingBookings = await _firestore
          .collection(_bookingsCollection)
          .where('listingId', isEqualTo: listingId)
          .where('status', whereIn: [
            BookingStatus.confirmed.toString().split('.').last,
            BookingStatus.inProgress.toString().split('.').last,
          ],)
          .get();
      
      for (final doc in conflictingBookings.docs) {
        final booking = BookingModel.fromFirestore(doc);
        
        // Verificar solapamiento de horarios
        if (startTime.isBefore(booking.endTime) && 
            endTime.isAfter(booking.startTime)) {
          return false;
        }
      }
      
      // TODO: Verificar disponibilidad en el calendario del anfitrión
      // Esto se implementaría con el AvailabilityModel
      
      return true;
      
    } catch (e) {
      if (e is ArgumentError || e is StateError) {
        rethrow;
      }
      throw Exception('Error al verificar disponibilidad para listing $listingId: ${e.toString()}');
    }
  }
  
  /// Crea una nueva reserva
  Future<BookingResult> createBooking({
    required String userId,
    required String listingId,
    required DateTime startTime,
    required DateTime endTime,
    required int guestCount,
    required String paymentMethodId,
    String? specialRequests,
    Map<String, dynamic>? metadata,
  }) async {
    // Validaciones de entrada
    if (userId.isEmpty) {
      return BookingResult.error('ID de usuario requerido');
    }
    if (listingId.isEmpty) {
      return BookingResult.error('ID de listing requerido');
    }
    if (paymentMethodId.isEmpty) {
      return BookingResult.error('Método de pago requerido');
    }
    if (startTime.isAfter(endTime)) {
      return BookingResult.error('La fecha de inicio debe ser anterior a la fecha de fin');
    }
    if (startTime.isBefore(DateTime.now().subtract(const Duration(minutes: 5)))) {
      return BookingResult.error('No se pueden crear reservas en el pasado');
    }
    if (guestCount <= 0) {
      return BookingResult.error('El número de huéspedes debe ser mayor a 0');
    }

    try {
      // Verificar disponibilidad
      final isAvailable = await checkAvailability(
        listingId: listingId,
        startTime: startTime,
        endTime: endTime,
      );
      
      if (!isAvailable) {
        return BookingResult.error('El horario seleccionado no está disponible');
      }
      
      // Obtener información del listing
      final listingDoc = await _firestore
          .collection(_listingsCollection)
          .doc(listingId)
          .get();
      
      if (!listingDoc.exists) {
        return BookingResult.error('El listing con ID $listingId no existe');
      }
      
      final listing = ListingModel.fromFirestore(listingDoc);
      
      // Verificar que el listing esté activo
      if (!listing.active) {
        return BookingResult.error('El listing no está disponible para reservas');
      }
      
      // Verificar capacidad
      if (guestCount > listing.capacity) {
        return BookingResult.error(
          'El número de huéspedes ($guestCount) excede la capacidad máxima (${listing.capacity})',);
      }
      
      // Calcular precio
      final priceCalculation = await calculatePrice(
        listingId: listingId,
        startTime: startTime,
        endTime: endTime,
        cityId: listing.location.city ?? 'default',
        guestCount: guestCount,
      );
      
      // Crear la reserva
      final booking = BookingModel(
        id: '', // Se asignará automáticamente
        guestId: userId,
        hostId: listing.hostId,
        listingId: listingId,
        startTime: startTime,
        endTime: endTime,
        hours: endTime.difference(startTime).inHours,
        pricePerHour: listing.hourlyPrice,
        subtotal: priceCalculation.totalPrice,
        guestServiceFeePct: 15,
        guestServiceFee: priceCalculation.platformRevenue,
        hostFeePct: 3,
        hostFee: priceCalculation.totalPrice - priceCalculation.hostEarnings,
        taxes: 0,
        totalGuestPay: priceCalculation.totalPrice,
        hostPayout: priceCalculation.hostEarnings,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: metadata,
      );
      
      // Guardar en Firestore
      final docRef = await _firestore
          .collection(_bookingsCollection)
          .add(booking.toFirestore());
      
      final savedBooking = booking.copyWith(id: docRef.id);
      
      // Actualizar el documento con el ID
      await docRef.update({'id': docRef.id});
      
      return BookingResult.success(savedBooking, docRef.id);
      
    } on ArgumentError catch (e) {
      return BookingResult.error('Datos inválidos: ${e.message}');
    } on StateError catch (e) {
      return BookingResult.error('Estado inválido: ${e.message}');
    } on FirebaseException catch (e) {
      return BookingResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      return BookingResult.error('Error inesperado al crear reserva: ${e.toString()}');
    }
  }
  
  /// Obtiene las reservas de un usuario
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_bookingsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map(BookingModel.fromFirestore)
          .toList();
      
    } catch (e) {
      throw Exception('Error al obtener reservas del usuario: $e');
    }
  }
  
  /// Obtiene las reservas de un anfitrión
  Future<List<BookingModel>> getHostBookings(String hostId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_bookingsCollection)
          .where('hostId', isEqualTo: hostId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map(BookingModel.fromFirestore)
          .toList();
      
    } catch (e) {
      throw Exception('Error al obtener reservas del anfitrión: $e');
    }
  }
  
  /// Obtiene una reserva por ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .get();
      
      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      }
      
      return null;
      
    } catch (e) {
      throw Exception('Error al obtener reserva: $e');
    }
  }
  
  /// Actualiza el estado de una reserva
  Future<bool> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
    String? cancellationReason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final updateData = {
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (cancellationReason != null) {
        updateData['cancellationReason'] = cancellationReason;
        updateData['cancelledAt'] = FieldValue.serverTimestamp();
      }
      
      if (metadata != null) {
        updateData['metadata'] = metadata;
      }
      
      await _firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .update(updateData);
      
      return true;
      
    } catch (e) {
      throw Exception('Error al actualizar estado de reserva: $e');
    }
  }
  
  /// Actualiza el estado de pago de una reserva
  Future<bool> updatePaymentStatus({
    required String bookingId,
    required PaymentStatus paymentStatus,
    String? paymentIntentId,
    String? stripeChargeId,
    Map<String, dynamic>? paymentMetadata,
  }) async {
    try {
      final updateData = {
        'paymentStatus': paymentStatus.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (paymentIntentId != null) {
        updateData['paymentIntentId'] = paymentIntentId;
      }
      
      if (stripeChargeId != null) {
        updateData['stripeChargeId'] = stripeChargeId;
      }
      
      if (paymentMetadata != null) {
        updateData['paymentMetadata'] = paymentMetadata;
      }
      
      // Si el pago es exitoso, actualizar también el estado de la reserva
      if (paymentStatus == PaymentStatus.succeeded) {
        updateData['status'] = BookingStatus.confirmed.toString().split('.').last;
        updateData['confirmedAt'] = FieldValue.serverTimestamp();
      }
      
      await _firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .update(updateData);
      
      return true;
      
    } catch (e) {
      throw Exception('Error al actualizar estado de pago: $e');
    }
  }
  
  /// Cancela una reserva
  Future<BookingResult> cancelBooking({
    required String bookingId,
    required String reason,
    required String cancelledBy, // 'user' o 'host'
  }) async {
    try {
      final booking = await getBookingById(bookingId);
      
      if (booking == null) {
        return BookingResult.error('Reserva no encontrada');
      }
      
      // Verificar si se puede cancelar
      if (booking.status == BookingStatus.cancelled ||
          booking.status == BookingStatus.completed) {
        return BookingResult.error('No se puede cancelar esta reserva');
      }
      
      // Calcular política de reembolso
      final hoursUntilStart = booking.startTime.difference(DateTime.now()).inHours;
      var refundPercentage = 0.0;
      
      // Política de cancelación básica
      if (hoursUntilStart >= 24) {
        refundPercentage = 1.0; // Reembolso completo
      } else if (hoursUntilStart >= 12) {
        refundPercentage = 0.5; // 50% de reembolso
      } else {
        refundPercentage = 0.0; // Sin reembolso
      }
      
      // Actualizar la reserva
      await updateBookingStatus(
        bookingId: bookingId,
        status: BookingStatus.cancelled,
        cancellationReason: reason,
        metadata: {
          'cancelledBy': cancelledBy,
          'refundPercentage': refundPercentage,
          'refundAmount': booking.totalGuestPay * refundPercentage,
        },
      );
      
      final updatedBooking = await getBookingById(bookingId);
      
      return BookingResult.success(updatedBooking!, bookingId);
      
    } catch (e) {
      return BookingResult.error('Error al cancelar reserva: $e');
    }
  }
  
  /// Obtiene estadísticas de reservas para un anfitrión
  Future<Map<String, dynamic>> getHostBookingStats(String hostId) async {
    try {
      final bookings = await getHostBookings(hostId);
      
      final stats = {
        'totalBookings': bookings.length,
        'confirmedBookings': bookings.where((b) => b.status == BookingStatus.confirmed).length,
        'completedBookings': bookings.where((b) => b.status == BookingStatus.completed).length,
        'cancelledBookings': bookings.where((b) => b.status == BookingStatus.cancelled).length,
        'totalEarnings': bookings
            .where((b) => b.status == BookingStatus.completed)
            .fold(0.0, (sum, b) => sum + b.hostPayout),
        'averageBookingValue': bookings.isNotEmpty
            ? bookings.fold(0.0, (sum, b) => sum + b.totalGuestPay) / bookings.length
            : 0.0,
        'thisMonthBookings': bookings
            .where((b) => b.createdAt.month == DateTime.now().month &&
                         b.createdAt.year == DateTime.now().year,)
            .length,
        'thisMonthEarnings': bookings
            .where((b) => b.createdAt.month == DateTime.now().month &&
                         b.createdAt.year == DateTime.now().year &&
                         b.status == BookingStatus.completed,)
            .fold(0.0, (sum, b) => sum + b.hostPayout),
      };
      
      return stats;
      
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }
  
  /// Stream de reservas en tiempo real para un usuario
  Stream<List<BookingModel>> getUserBookingsStream(String userId) => _firestore
        .collection(_bookingsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(BookingModel.fromFirestore)
            .toList(),);
  
  /// Stream de reservas en tiempo real para un anfitrión
  Stream<List<BookingModel>> getHostBookingsStream(String hostId) => _firestore
        .collection(_bookingsCollection)
        .where('hostId', isEqualTo: hostId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(BookingModel.fromFirestore)
            .toList(),);
}