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

class BookingModel { // Información adicional

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
    required this.createdAt, this.status = BookingStatus.pending,
    this.paymentIntentId,
    this.transferId,
    this.updatedAt,
    this.confirmedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.metadata,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      listingId: (data['listingId'] ?? '') as String,
      hostId: (data['hostId'] ?? '') as String,
      guestId: (data['guestId'] ?? '') as String,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      hours: ((data['hours'] ?? 1) as num).toInt(),
      pricePerHour: ((data['pricePerHour'] ?? 0.0) as num).toDouble(),
      subtotal: ((data['subtotal'] ?? 0.0) as num).toDouble(),
      guestServiceFeePct: ((data['guestServiceFeePct'] ?? 0.0) as num).toDouble(),
      guestServiceFee: ((data['guestServiceFee'] ?? 0.0) as num).toDouble(),
      hostFeePct: ((data['hostFeePct'] ?? 3.0) as num).toDouble(),
      hostFee: ((data['hostFee'] ?? 0.0) as num).toDouble(),
      taxes: ((data['taxes'] ?? 0.0) as num).toDouble(),
      totalGuestPay: ((data['totalGuestPay'] ?? 0.0) as num).toDouble(),
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
      metadata: data['metadata'] != null ? Map<String, dynamic>.from(data['metadata'] as Map) : null,
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
    final hours = endTime.difference(startTime).inHours;
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
  final double subtotal; // pricePerHour * hours
  final double guestServiceFeePct; // 14.1% - 16.5%
  final double guestServiceFee; // Tarifa de servicio al huésped
  final double hostFeePct; // 3% fijo
  final double hostFee; // Comisión del anfitrión
  final double taxes; // IVA u otros impuestos
  final double totalGuestPay; // Total que paga el huésped
  final double hostPayout; // Pago neto al anfitrión
  final BookingStatus status;
  final String? paymentIntentId; // Stripe Payment Intent ID
  final String? transferId; // Stripe Transfer ID
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final Map<String, dynamic>? metadata;

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
    };

  // Calcular tarifa de servicio al huésped según tiers
  static double _calculateGuestServiceFeePct(double subtotal) {
    if (subtotal < 500) {
      return 16.5; // 16.5% para montos menores a $500 MXN
    } else if (subtotal <= 1500) {
      return 15.3; // 15.3% para montos entre $500-$1,500 MXN
    } else {
      return 14.1; // 14.1% para montos mayores a $1,500 MXN
    }
  }

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
  }) => BookingModel(
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
    );

  // Getters útiles
  Duration get duration => endTime.difference(startTime);
  bool get isPaid => status == BookingStatus.paid;
  bool get isActive => [BookingStatus.confirmed, BookingStatus.paid, BookingStatus.inProgress].contains(status);
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isCompleted => status == BookingStatus.completed;
  bool get canBeCancelled => [BookingStatus.pending, BookingStatus.confirmed, BookingStatus.paid].contains(status);
  
  String get formattedDateRange {
    final startFormatted = '${startTime.day}/${startTime.month}/${startTime.year} ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    final endFormatted = '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$startFormatted - $endFormatted';
  }
  
  String get formattedTotal => '\$${totalGuestPay.toStringAsFixed(2)} MXN';
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)} MXN';
  String get formattedServiceFee => '\$${guestServiceFee.toStringAsFixed(2)} MXN';
  String get formattedTaxes => '\$${taxes.toStringAsFixed(2)} MXN';
  String get formattedHostPayout => '\$${hostPayout.toStringAsFixed(2)} MXN';
  
  // Getter para el estado formateado
  String get formattedStatus {
    switch (status) {
      case BookingStatus.pending:
        return 'Pendiente';
      case BookingStatus.confirmed:
        return 'Confirmada';
      case BookingStatus.paid:
        return 'Pagada';
      case BookingStatus.inProgress:
        return 'En progreso';
      case BookingStatus.completed:
        return 'Completada';
      case BookingStatus.cancelled:
        return 'Cancelada';
      case BookingStatus.refunded:
        return 'Reembolsada';
      case BookingStatus.partialRefund:
        return 'Reembolso parcial';
    }
  }
  
  // Getter para el título del listing (placeholder hasta obtener datos reales)
  String get listingTitle => metadata?['listingTitle'] as String? ?? 'Estudio de música';
  
  // Getter para el número de huéspedes
  int get guestCount => metadata?['guestCount'] as int? ?? 1;
  
  // Getter para el monto total (alias para totalGuestPay)
  double get totalAmount => totalGuestPay;
  
  // Ingreso de la plataforma (tarifa de servicio + comisión del anfitrión)
  double get platformRevenue => guestServiceFee + hostFee;
  String get formattedPlatformRevenue => '\$${platformRevenue.toStringAsFixed(2)} MXN';

  @override
  String toString() => 'BookingModel(id: $id, listingId: $listingId, status: $status, total: $formattedTotal)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}