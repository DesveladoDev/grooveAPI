import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  paid,
  inProgress,
  completed,
  cancelled,
  refunded,
  partialRefund
}

class BookingModel {
  BookingModel({
    required this.id,
    required this.listingId,
    required this.hostId,
    required this.guestId,
    required this.startTime,
    required this.endTime,
    required this.hours,
    required this.pricePerHour,
    required this.subtotal,
    required this.guestServiceFeePct,
    required this.guestServiceFee,
    required this.hostFeePct,
    required this.hostFee,
    required this.taxes,
    required this.totalGuestPay,
    required this.hostPayout,
    required this.createdAt,
    this.status = BookingStatus.pending,
    this.paymentIntentId,
    this.transferId,
    this.updatedAt,
    this.confirmedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.metadata,
    this.notes,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      listingId: (data['listingId'] ?? data['userId'] ?? '') as String,
      hostId: (data['hostId'] ?? '') as String,
      guestId: (data['guestId'] ?? data['userId'] ?? '') as String,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      hours: ((data['hours'] ?? 1) as num).toInt(),
      pricePerHour: ((data['pricePerHour'] ?? 0.0) as num).toDouble(),
      subtotal: ((data['subtotal'] ?? data['totalAmount'] ?? 0.0) as num).toDouble(),
      guestServiceFeePct: ((data['guestServiceFeePct'] ?? 0.0) as num).toDouble(),
      guestServiceFee: ((data['guestServiceFee'] ?? 0.0) as num).toDouble(),
      hostFeePct: ((data['hostFeePct'] ?? 3.0) as num).toDouble(),
      hostFee: ((data['hostFee'] ?? 0.0) as num).toDouble(),
      taxes: ((data['taxes'] ?? 0.0) as num).toDouble(),
      totalGuestPay: ((data['totalGuestPay'] ?? data['totalAmount'] ?? 0.0) as num).toDouble(),
      hostPayout: ((data['hostPayout'] ?? 0.0) as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => BookingStatus.pending,
      ),
      paymentIntentId: data['paymentIntentId'] as String?,
      transferId: data['transferId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      confirmedAt: data['confirmedAt'] != null
          ? (data['confirmedAt'] as Timestamp).toDate()
          : null,
      cancelledAt: data['cancelledAt'] != null
          ? (data['cancelledAt'] as Timestamp).toDate()
          : null,
      cancellationReason: data['cancellationReason'] as String?,
      metadata: data['metadata'] != null 
          ? Map<String, dynamic>.from(data['metadata'] as Map) 
          : null,
      notes: data['notes'] as String?,
    );
  }

  // Factory constructor para crear booking con cálculos automáticos
  factory BookingModel.create({
    required String listingId,
    required String hostId,
    required String guestId,
    required DateTime startTime,
    required DateTime endTime,
    required double pricePerHour,
    double taxRate = 0.16, // IVA México
  }) {
    // Validaciones
    if (startTime.isAfter(endTime)) {
      throw ArgumentError('La fecha de inicio debe ser anterior a la fecha de fin');
    }
    
    if (startTime.isBefore(DateTime.now())) {
      throw ArgumentError('La fecha de inicio no puede ser en el pasado');
    }
    
    if (pricePerHour <= 0) {
      throw ArgumentError('El precio por hora debe ser mayor a 0');
    }

    final hours = endTime.difference(startTime).inHours;
    if (hours <= 0) {
      throw ArgumentError('La reserva debe ser de al menos 1 hora');
    }
    
    final subtotal = pricePerHour * hours;
    
    // Calcular tarifa de servicio al huésped según tiers
    final guestServiceFeePct = _calculateGuestServiceFeePct(subtotal);
    final guestServiceFee = subtotal * (guestServiceFeePct / 100);
    
    // Comisión fija del anfitrión
    const hostFeePct = 3.0;
    final hostFee = subtotal * (hostFeePct / 100);
    
    // Calcular impuestos sobre las tarifas de servicio
    final taxes = guestServiceFee * taxRate;
    
    // Total que paga el huésped
    final totalGuestPay = subtotal + guestServiceFee + taxes;
    
    // Pago neto al anfitrión (subtotal menos comisión)
    final hostPayout = subtotal - hostFee;
    
    return BookingModel(
      id: '', // Se asignará al guardar en Firestore
      listingId: listingId,
      hostId: hostId,
      guestId: guestId,
      startTime: startTime,
      endTime: endTime,
      hours: hours,
      pricePerHour: pricePerHour,
      subtotal: subtotal,
      guestServiceFeePct: guestServiceFeePct,
      guestServiceFee: guestServiceFee,
      hostFeePct: hostFeePct,
      hostFee: hostFee,
      taxes: taxes,
      totalGuestPay: totalGuestPay,
      hostPayout: hostPayout,
      createdAt: DateTime.now(),
    );
  }

  final String id;
  final String listingId;
  final String hostId;
  final String guestId;
  final DateTime startTime;
  final DateTime endTime;
  final int hours;
  final double pricePerHour;
  final double subtotal;
  final double guestServiceFeePct;
  final double guestServiceFee;
  final double hostFeePct;
  final double hostFee;
  final double taxes;
  final double totalGuestPay;
  final double hostPayout;
  final BookingStatus status;
  final String? paymentIntentId;
  final String? transferId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final Map<String, dynamic>? metadata;
  final String? notes;

  // Getters para compatibilidad con código existente
  String get userId => guestId;
  double get totalAmount => totalGuestPay;

  // Método para calcular tarifa de servicio según tiers
  static double _calculateGuestServiceFeePct(double subtotal) {
    if (subtotal <= 500) return 14.1;
    if (subtotal <= 1500) return 15.0;
    if (subtotal <= 3000) return 15.5;
    return 16.5;
  }

  // Validaciones de negocio
  bool get canBeCancelled => 
      status == BookingStatus.pending || 
      status == BookingStatus.confirmed;

  bool get canBeConfirmed => status == BookingStatus.pending;

  bool get isActive => 
      status == BookingStatus.confirmed || 
      status == BookingStatus.inProgress;

  bool get isCompleted => status == BookingStatus.completed;

  bool get isCancelled => 
      status == BookingStatus.cancelled || 
      status == BookingStatus.refunded;

  // Duración en formato legible
  String get durationText {
    if (hours == 1) return '1 hora';
    return '$hours horas';
  }

  Map<String, dynamic> toFirestore() => {
        'listingId': listingId,
        'hostId': hostId,
        'guestId': guestId,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'hours': hours,
        'pricePerHour': pricePerHour,
        'subtotal': subtotal,
        'guestServiceFeePct': guestServiceFeePct,
        'guestServiceFee': guestServiceFee,
        'hostFeePct': hostFeePct,
        'hostFee': hostFee,
        'taxes': taxes,
        'totalGuestPay': totalGuestPay,
        'hostPayout': hostPayout,
        'status': status.toString().split('.').last,
        'paymentIntentId': paymentIntentId,
        'transferId': transferId,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
        'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
        'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
        'cancellationReason': cancellationReason,
        'metadata': metadata,
        'notes': notes,
      };

  BookingModel copyWith({
    String? id,
    String? listingId,
    String? hostId,
    String? guestId,
    DateTime? startTime,
    DateTime? endTime,
    int? hours,
    double? pricePerHour,
    double? subtotal,
    double? guestServiceFeePct,
    double? guestServiceFee,
    double? hostFeePct,
    double? hostFee,
    double? taxes,
    double? totalGuestPay,
    double? hostPayout,
    BookingStatus? status,
    String? paymentIntentId,
    String? transferId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    Map<String, dynamic>? metadata,
    String? notes,
  }) =>
      BookingModel(
        id: id ?? this.id,
        listingId: listingId ?? this.listingId,
        hostId: hostId ?? this.hostId,
        guestId: guestId ?? this.guestId,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        hours: hours ?? this.hours,
        pricePerHour: pricePerHour ?? this.pricePerHour,
        subtotal: subtotal ?? this.subtotal,
        guestServiceFeePct: guestServiceFeePct ?? this.guestServiceFeePct,
        guestServiceFee: guestServiceFee ?? this.guestServiceFee,
        hostFeePct: hostFeePct ?? this.hostFeePct,
        hostFee: hostFee ?? this.hostFee,
        taxes: taxes ?? this.taxes,
        totalGuestPay: totalGuestPay ?? this.totalGuestPay,
        hostPayout: hostPayout ?? this.hostPayout,
        status: status ?? this.status,
        paymentIntentId: paymentIntentId ?? this.paymentIntentId,
        transferId: transferId ?? this.transferId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        confirmedAt: confirmedAt ?? this.confirmedAt,
        cancelledAt: cancelledAt ?? this.cancelledAt,
        cancellationReason: cancellationReason ?? this.cancellationReason,
        metadata: metadata ?? this.metadata,
        notes: notes ?? this.notes,
      );

  /// Retorna el rango de fechas formateado para mostrar en la UI
  String get formattedDateRange {
    final startDate = startTime.day == endTime.day && 
                     startTime.month == endTime.month && 
                     startTime.year == endTime.year
        ? '${startTime.day}/${startTime.month}/${startTime.year}'
        : '${startTime.day}/${startTime.month}/${startTime.year} - ${endTime.day}/${endTime.month}/${endTime.year}';
    
    final startTimeStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endTimeStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    
    return '$startDate, $startTimeStr - $endTimeStr';
  }

  @override
  String toString() =>
      'BookingModel(id: $id, listingId: $listingId, status: $status, totalGuestPay: $totalGuestPay)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Alias para compatibilidad con código existente
typedef Booking = BookingModel;