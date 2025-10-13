import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportModel {

  AdminReportModel({
    required this.id,
    required this.dateBucket,
    required this.period,
    required this.reportDate,
    required this.gmv,
    required this.platformRevenue,
    required this.guestServiceFees,
    required this.hostFees,
    required this.taxes,
    required this.hostPayouts,
    required this.bookingsCount,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.refundedBookings,
    required this.newUsers,
    required this.newHosts,
    required this.newListings,
    required this.activeListings,
    required this.averageBookingValue,
    required this.cancellationRate,
    required this.conversionRate,
    required this.cityBreakdown,
    required this.paymentMethodBreakdown,
    required this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  factory AdminReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return AdminReportModel(
      id: doc.id,
      dateBucket: (data['dateBucket'] ?? '') as String,
      period: (data['period'] ?? 'daily') as String,
      reportDate: (data['reportDate'] as Timestamp).toDate(),
      gmv: ((data['gmv'] ?? 0.0) as num).toDouble(),
      platformRevenue: ((data['platformRevenue'] ?? 0.0) as num).toDouble(),
      guestServiceFees: ((data['guestServiceFees'] ?? 0.0) as num).toDouble(),
      hostFees: ((data['hostFees'] ?? 0.0) as num).toDouble(),
      taxes: ((data['taxes'] ?? 0.0) as num).toDouble(),
      hostPayouts: ((data['hostPayouts'] ?? 0.0) as num).toDouble(),
      bookingsCount: (data['bookingsCount'] ?? 0) as int,
      completedBookings: (data['completedBookings'] ?? 0) as int,
      cancelledBookings: (data['cancelledBookings'] ?? 0) as int,
      refundedBookings: (data['refundedBookings'] ?? 0) as int,
      newUsers: (data['newUsers'] ?? 0) as int,
      newHosts: (data['newHosts'] ?? 0) as int,
      newListings: (data['newListings'] ?? 0) as int,
      activeListings: (data['activeListings'] ?? 0) as int,
      averageBookingValue: ((data['averageBookingValue'] ?? 0.0) as num).toDouble(),
      cancellationRate: ((data['cancellationRate'] ?? 0.0) as num).toDouble(),
      conversionRate: ((data['conversionRate'] ?? 0.0) as num).toDouble(),
      cityBreakdown: (data['cityBreakdown'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>() ?? {},
      paymentMethodBreakdown: (data['paymentMethodBreakdown'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>() ?? {},
      metadata: (data['metadata'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>() ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Factory para crear reporte vacío
  factory AdminReportModel.createEmpty({
    required String dateBucket,
    required String period,
    required DateTime reportDate,
  }) => AdminReportModel(
      id: '', // Se asignará al guardar
      dateBucket: dateBucket,
      period: period,
      reportDate: reportDate,
      gmv: 0,
      platformRevenue: 0,
      guestServiceFees: 0,
      hostFees: 0,
      taxes: 0,
      hostPayouts: 0,
      bookingsCount: 0,
      completedBookings: 0,
      cancelledBookings: 0,
      refundedBookings: 0,
      newUsers: 0,
      newHosts: 0,
      newListings: 0,
      activeListings: 0,
      averageBookingValue: 0,
      cancellationRate: 0,
      conversionRate: 0,
      cityBreakdown: {},
      paymentMethodBreakdown: {},
      metadata: {},
      createdAt: DateTime.now(),
    );
  final String id;
  final String dateBucket; // 'YYYY-MM-DD' para diario, 'YYYY-MM' para mensual, 'YYYY' para anual
  final String period; // 'daily', 'weekly', 'monthly', 'yearly'
  final DateTime reportDate;
  final double gmv; // Gross Merchandise Value
  final double platformRevenue; // Ingresos totales de la plataforma (comisiones + tasas)
  final double guestServiceFees; // Tasas de servicio cobradas a huéspedes
  final double hostFees; // Comisiones cobradas a anfitriones
  final double taxes; // Impuestos cobrados
  final double hostPayouts; // Pagos realizados a anfitriones
  final int bookingsCount; // Número total de reservas
  final int completedBookings; // Reservas completadas
  final int cancelledBookings; // Reservas canceladas
  final int refundedBookings; // Reservas reembolsadas
  final int newUsers; // Nuevos usuarios registrados
  final int newHosts; // Nuevos anfitriones registrados
  final int newListings; // Nuevos listings creados
  final int activeListings; // Listings activos
  final double averageBookingValue; // Valor promedio de reserva
  final double cancellationRate; // Tasa de cancelación
  final double conversionRate; // Tasa de conversión (checkout iniciado -> pago completado)
  final Map<String, dynamic> cityBreakdown; // Desglose por ciudad
  final Map<String, dynamic> paymentMethodBreakdown; // Desglose por método de pago
  final Map<String, dynamic> metadata; // Información adicional
  final DateTime createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toFirestore() => {
      'dateBucket': dateBucket,
      'period': period,
      'reportDate': Timestamp.fromDate(reportDate),
      'gmv': gmv,
      'platformRevenue': platformRevenue,
      'guestServiceFees': guestServiceFees,
      'hostFees': hostFees,
      'taxes': taxes,
      'hostPayouts': hostPayouts,
      'bookingsCount': bookingsCount,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'refundedBookings': refundedBookings,
      'newUsers': newUsers,
      'newHosts': newHosts,
      'newListings': newListings,
      'activeListings': activeListings,
      'averageBookingValue': averageBookingValue,
      'cancellationRate': cancellationRate,
      'conversionRate': conversionRate,
      'cityBreakdown': cityBreakdown,
      'paymentMethodBreakdown': paymentMethodBreakdown,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };

  AdminReportModel copyWith({
    String? id,
    String? dateBucket,
    String? period,
    DateTime? reportDate,
    double? gmv,
    double? platformRevenue,
    double? guestServiceFees,
    double? hostFees,
    double? taxes,
    double? hostPayouts,
    int? bookingsCount,
    int? completedBookings,
    int? cancelledBookings,
    int? refundedBookings,
    int? newUsers,
    int? newHosts,
    int? newListings,
    int? activeListings,
    double? averageBookingValue,
    double? cancellationRate,
    double? conversionRate,
    Map<String, dynamic>? cityBreakdown,
    Map<String, dynamic>? paymentMethodBreakdown,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AdminReportModel(
      id: id ?? this.id,
      dateBucket: dateBucket ?? this.dateBucket,
      period: period ?? this.period,
      reportDate: reportDate ?? this.reportDate,
      gmv: gmv ?? this.gmv,
      platformRevenue: platformRevenue ?? this.platformRevenue,
      guestServiceFees: guestServiceFees ?? this.guestServiceFees,
      hostFees: hostFees ?? this.hostFees,
      taxes: taxes ?? this.taxes,
      hostPayouts: hostPayouts ?? this.hostPayouts,
      bookingsCount: bookingsCount ?? this.bookingsCount,
      completedBookings: completedBookings ?? this.completedBookings,
      cancelledBookings: cancelledBookings ?? this.cancelledBookings,
      refundedBookings: refundedBookings ?? this.refundedBookings,
      newUsers: newUsers ?? this.newUsers,
      newHosts: newHosts ?? this.newHosts,
      newListings: newListings ?? this.newListings,
      activeListings: activeListings ?? this.activeListings,
      averageBookingValue: averageBookingValue ?? this.averageBookingValue,
      cancellationRate: cancellationRate ?? this.cancellationRate,
      conversionRate: conversionRate ?? this.conversionRate,
      cityBreakdown: cityBreakdown ?? this.cityBreakdown,
      paymentMethodBreakdown: paymentMethodBreakdown ?? this.paymentMethodBreakdown,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );

  // Getters útiles
  String get formattedDate {
    switch (period) {
      case 'daily':
        return '${reportDate.day}/${reportDate.month}/${reportDate.year}';
      case 'weekly':
        return 'Semana ${_getWeekOfYear(reportDate)} ${reportDate.year}';
      case 'monthly':
        return '${_getMonthName(reportDate.month)} ${reportDate.year}';
      case 'yearly':
        return '${reportDate.year}';
      default:
        return dateBucket;
    }
  }

  String get formattedGmv => '\$${gmv.toStringAsFixed(2)}';
  String get formattedPlatformRevenue => '\$${platformRevenue.toStringAsFixed(2)}';
  String get formattedHostPayouts => '\$${hostPayouts.toStringAsFixed(2)}';
  String get formattedAverageBookingValue => '\$${averageBookingValue.toStringAsFixed(2)}';
  String get formattedCancellationRate => '${(cancellationRate * 100).toStringAsFixed(1)}%';
  String get formattedConversionRate => '${(conversionRate * 100).toStringAsFixed(1)}%';

  double get netRevenue => platformRevenue - hostPayouts;
  String get formattedNetRevenue => '\$${netRevenue.toStringAsFixed(2)}';

  double get completionRate {
    if (bookingsCount == 0) return 0;
    return completedBookings / bookingsCount;
  }

  String get formattedCompletionRate => '${(completionRate * 100).toStringAsFixed(1)}%';

  double get refundRate {
    if (bookingsCount == 0) return 0;
    return refundedBookings / bookingsCount;
  }

  String get formattedRefundRate => '${(refundRate * 100).toStringAsFixed(1)}%';

  // Métodos para obtener datos de desglose
  List<MapEntry<String, double>> get topCitiesByGmv {
    final cities = <MapEntry<String, double>>[];
    for (final entry in cityBreakdown.entries) {
      if (entry.value is Map && entry.value['gmv'] != null) {
        cities.add(MapEntry(entry.key, (entry.value['gmv'] as num).toDouble()));
      }
    }
    cities.sort((a, b) => b.value.compareTo(a.value));
    return cities;
  }

  List<MapEntry<String, int>> get topCitiesByBookings {
    final cities = <MapEntry<String, int>>[];
    for (final entry in cityBreakdown.entries) {
      if (entry.value is Map && entry.value['bookings'] != null) {
        cities.add(MapEntry(entry.key, entry.value['bookings'] as int));
      }
    }
    cities.sort((a, b) => b.value.compareTo(a.value));
    return cities;
  }

  List<MapEntry<String, double>> get paymentMethodDistribution {
    final methods = <MapEntry<String, double>>[];
    for (final entry in paymentMethodBreakdown.entries) {
      if (entry.value is num) {
        methods.add(MapEntry(entry.key, (entry.value as num).toDouble()));
      }
    }
    methods.sort((a, b) => b.value.compareTo(a.value));
    return methods;
  }

  // Métodos de comparación
  double getGrowthRate(AdminReportModel? previousReport) {
    if (previousReport == null || previousReport.gmv == 0) return 0;
    return (gmv - previousReport.gmv) / previousReport.gmv;
  }

  String getFormattedGrowthRate(AdminReportModel? previousReport) {
    final growth = getGrowthRate(previousReport);
    final sign = growth >= 0 ? '+' : '';
    return '$sign${(growth * 100).toStringAsFixed(1)}%';
  }

  // Métodos de validación
  bool get isValid => dateBucket.isNotEmpty &&
           period.isNotEmpty &&
           gmv >= 0 &&
           platformRevenue >= 0 &&
           hostPayouts >= 0 &&
           bookingsCount >= 0;

  List<String> get validationErrors {
    final errors = <String>[];
    if (dateBucket.isEmpty) errors.add('dateBucket no puede estar vacío');
    if (period.isEmpty) errors.add('period no puede estar vacío');
    if (gmv < 0) errors.add('GMV no puede ser negativo');
    if (platformRevenue < 0) errors.add('platformRevenue no puede ser negativo');
    if (hostPayouts < 0) errors.add('hostPayouts no puede ser negativo');
    if (bookingsCount < 0) errors.add('bookingsCount no puede ser negativo');
    if (platformRevenue != (guestServiceFees + hostFees + taxes)) {
      errors.add('platformRevenue debe ser igual a la suma de guestServiceFees + hostFees + taxes');
    }
    return errors;
  }

  // Métodos auxiliares
  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
  }

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return months[month - 1];
  }

  // Método para exportar a CSV
  Map<String, dynamic> toCsvRow() => {
      'Fecha': formattedDate,
      'Periodo': period,
      'GMV': gmv,
      'Ingresos Plataforma': platformRevenue,
      'Tasas Servicio': guestServiceFees,
      'Comisiones Host': hostFees,
      'Impuestos': taxes,
      'Pagos Host': hostPayouts,
      'Total Reservas': bookingsCount,
      'Reservas Completadas': completedBookings,
      'Reservas Canceladas': cancelledBookings,
      'Reservas Reembolsadas': refundedBookings,
      'Nuevos Usuarios': newUsers,
      'Nuevos Hosts': newHosts,
      'Nuevos Listings': newListings,
      'Listings Activos': activeListings,
      'Valor Promedio Reserva': averageBookingValue,
      'Tasa Cancelación': cancellationRate,
      'Tasa Conversión': conversionRate,
      'Tasa Completación': completionRate,
      'Tasa Reembolso': refundRate,
    };

  @override
  String toString() => 'AdminReportModel(id: $id, dateBucket: $dateBucket, gmv: $formattedGmv, bookings: $bookingsCount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminReportModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}