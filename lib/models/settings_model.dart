import 'package:cloud_firestore/cloud_firestore.dart';

class TaxRate {

  TaxRate({
    required this.countryCode,
    required this.rate,
    required this.name,
    this.active = true,
  });

  factory TaxRate.fromMap(Map<String, dynamic> map) => TaxRate(
      countryCode: map['countryCode'] as String? ?? '',
      rate: (map['rate'] as num? ?? 0.0).toDouble(),
      name: map['name'] as String? ?? '',
      active: (map['active'] as bool?) ?? true,
    );
  final String countryCode;
  final double rate;
  final String name;
  final bool active;

  Map<String, dynamic> toMap() => {
      'countryCode': countryCode,
      'rate': rate,
      'name': name,
      'active': active,
    };

  TaxRate copyWith({
    String? countryCode,
    double? rate,
    String? name,
    bool? active,
  }) => TaxRate(
      countryCode: countryCode ?? this.countryCode,
      rate: rate ?? this.rate,
      name: name ?? this.name,
      active: active ?? this.active,
    );

  // Getters útiles
  double get percentage => rate * 100;
  String get formattedRate => '${percentage.toStringAsFixed(1)}%';

  @override
  String toString() => 'TaxRate(countryCode: $countryCode, rate: $formattedRate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxRate && other.countryCode == countryCode;
  }

  @override
  int get hashCode => countryCode.hashCode;
}

class ServiceFeeTier {

  ServiceFeeTier({
    required this.minAmount,
    required this.maxAmount,
    required this.feePercentage,
    required this.description,
  });

  factory ServiceFeeTier.fromMap(Map<String, dynamic> map) => ServiceFeeTier(
      minAmount: (map['minAmount'] as num? ?? 0.0).toDouble(),
      maxAmount: (map['maxAmount'] as num? ?? double.infinity).toDouble(),
      feePercentage: (map['feePercentage'] as num? ?? 0.0).toDouble(),
      description: map['description'] as String? ?? '',
    );
  final double minAmount;
  final double maxAmount;
  final double feePercentage;
  final String description;

  Map<String, dynamic> toMap() => {
      'minAmount': minAmount,
      'maxAmount': maxAmount == double.infinity ? null : maxAmount,
      'feePercentage': feePercentage,
      'description': description,
    };

  bool isAmountInRange(double amount) => amount >= minAmount && amount < maxAmount;

  String get formattedRange {
    if (maxAmount == double.infinity) {
      return '\$${minAmount.toStringAsFixed(0)}+';
    }
    return '\$${minAmount.toStringAsFixed(0)} - \$${maxAmount.toStringAsFixed(0)}';
  }

  String get formattedFee => '${feePercentage.toStringAsFixed(1)}%';

  @override
  String toString() => 'ServiceFeeTier(range: $formattedRange, fee: $formattedFee)';
}

class RefundPolicy {

  RefundPolicy({
    required this.id,
    required this.name,
    required this.description,
    required this.refundPercentages,
    this.active = true,
  });

  factory RefundPolicy.fromMap(Map<String, dynamic> map) => RefundPolicy(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      refundPercentages: Map<String, double>.from(
        (map['refundPercentages'] as Map<dynamic, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key.toString(), (value ?? 0.0).toDouble()),
        ),
      ),
      active: (map['active'] as bool?) ?? true,
    );
  final String id;
  final String name;
  final String description;
  final Map<String, double> refundPercentages; // Horas antes -> porcentaje de reembolso
  final bool active;

  Map<String, dynamic> toMap() => {
      'id': id,
      'name': name,
      'description': description,
      'refundPercentages': refundPercentages,
      'active': active,
    };

  double getRefundPercentage(int hoursBeforeStart) {
    // Buscar el porcentaje de reembolso más apropiado
    var refundPercentage = 0.0;
    
    for (final entry in refundPercentages.entries) {
      final hours = int.tryParse(entry.key) ?? 0;
      if (hoursBeforeStart >= hours && entry.value > refundPercentage) {
        refundPercentage = entry.value;
      }
    }
    
    return refundPercentage;
  }

  @override
  String toString() => 'RefundPolicy(id: $id, name: $name)';
}

class CityConfig {

  CityConfig({
    required this.cityCode,
    required this.name,
    required this.country,
    this.active = true,
    this.serviceFeeOverride,
    this.metadata,
  });

  factory CityConfig.fromMap(Map<String, dynamic> map) => CityConfig(
      cityCode: map['cityCode'] as String? ?? '',
      name: map['name'] as String? ?? '',
      country: map['country'] as String? ?? '',
      active: (map['active'] as bool?) ?? true,
      serviceFeeOverride: (map['serviceFeeOverride'] as num?)?.toDouble(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  final String cityCode;
  final String name;
  final String country;
  final bool active;
  final double? serviceFeeOverride;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toMap() => {
      'cityCode': cityCode,
      'name': name,
      'country': country,
      'active': active,
      'serviceFeeOverride': serviceFeeOverride,
      'metadata': metadata,
    };

  @override
  String toString() => 'CityConfig(cityCode: $cityCode, name: $name, active: $active)';
}

class SettingsModel {

  SettingsModel({
    required this.id,
    required this.serviceFeeTiers, required this.taxRates, required this.refundPolicies, required this.citiesWhitelist, required this.createdAt, this.guestServiceFeeMinPct = 14.1,
    this.guestServiceFeeMaxPct = 16.5,
    this.hostFeePct = 3.0,
    this.minBookingHours = 1,
    this.maxBookingHours = 12,
    this.bookingIncrements = const [30, 60],
    this.defaultCleaningBufferMinutes = 15,
    this.checkoutTimeoutMinutes = 15,
    this.dynamicPricingEnabled = true,
    this.moderationEnabled = true,
    this.features,
    this.updatedAt,
  });

  factory SettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return SettingsModel(
      id: doc.id,
      guestServiceFeeMinPct: (data['guestServiceFeeMinPct'] as num? ?? 14.1).toDouble(),
      guestServiceFeeMaxPct: (data['guestServiceFeeMaxPct'] as num? ?? 16.5).toDouble(),
      hostFeePct: (data['hostFeePct'] as num? ?? 3.0).toDouble(),
      serviceFeeTiers: (data['serviceFeeTiers'] as List<dynamic>? ?? [])
          .map((tier) => ServiceFeeTier.fromMap(tier as Map<String, dynamic>))
          .toList(),
      taxRates: Map<String, TaxRate>.from(
        (data['taxRates'] as Map<dynamic, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key.toString(), TaxRate.fromMap(value as Map<String, dynamic>)),
        ),
      ),
      refundPolicies: (data['refundPolicies'] as List<dynamic>? ?? [])
          .map((policy) => RefundPolicy.fromMap(policy as Map<String, dynamic>))
          .toList(),
      citiesWhitelist: (data['citiesWhitelist'] as List<dynamic>? ?? [])
          .map((city) => CityConfig.fromMap(city as Map<String, dynamic>))
          .toList(),
      minBookingHours: (data['minBookingHours'] as int?) ?? 1,
      maxBookingHours: (data['maxBookingHours'] as int?) ?? 12,
      bookingIncrements: List<int>.from(data['bookingIncrements'] as Iterable<dynamic>? ?? [30, 60]),
      defaultCleaningBufferMinutes: (data['defaultCleaningBufferMinutes'] as int?) ?? 15,
      checkoutTimeoutMinutes: (data['checkoutTimeoutMinutes'] as int?) ?? 15,
      dynamicPricingEnabled: (data['dynamicPricingEnabled'] as bool?) ?? true,
      moderationEnabled: (data['moderationEnabled'] as bool?) ?? true,
      features: data['features'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Factory para configuración por defecto
  factory SettingsModel.createDefault() => SettingsModel(
      id: 'default',
      serviceFeeTiers: [
        ServiceFeeTier(
          minAmount: 0,
          maxAmount: 500,
          feePercentage: 16.5,
          description: r'Reservas menores a $500 MXN',
        ),
        ServiceFeeTier(
          minAmount: 500,
          maxAmount: 1500,
          feePercentage: 15.3,
          description: r'Reservas de $500 a $1,500 MXN',
        ),
        ServiceFeeTier(
          minAmount: 1500,
          maxAmount: double.infinity,
          feePercentage: 14.1,
          description: r'Reservas mayores a $1,500 MXN',
        ),
      ],
      taxRates: {
        'MX': TaxRate(
          countryCode: 'MX',
          rate: 0.16,
          name: 'IVA México',
        ),
      },
      refundPolicies: [
        RefundPolicy(
          id: 'flexible',
          name: 'Flexible',
          description: 'Reembolso completo hasta 24 horas antes',
          refundPercentages: {
            '24': 1.0, // 100% si cancela 24h antes
            '2': 0.5,  // 50% si cancela 2h antes
            '0': 0.0,  // 0% si cancela menos de 2h antes
          },
        ),
        RefundPolicy(
          id: 'moderate',
          name: 'Moderada',
          description: 'Reembolso completo hasta 48 horas antes',
          refundPercentages: {
            '48': 1.0, // 100% si cancela 48h antes
            '24': 0.5, // 50% si cancela 24h antes
            '0': 0.0,  // 0% si cancela menos de 24h antes
          },
        ),
        RefundPolicy(
          id: 'strict',
          name: 'Estricta',
          description: 'Reembolso completo hasta 7 días antes',
          refundPercentages: {
            '168': 1.0, // 100% si cancela 7 días antes (168h)
            '48': 0.5,  // 50% si cancela 48h antes
            '0': 0.0,   // 0% si cancela menos de 48h antes
          },
        ),
      ],
      citiesWhitelist: [
        CityConfig(
          cityCode: 'CDMX',
          name: 'Ciudad de México',
          country: 'MX',
        ),
        CityConfig(
          cityCode: 'GDL',
          name: 'Guadalajara',
          country: 'MX',
        ),
        CityConfig(
          cityCode: 'MTY',
          name: 'Monterrey',
          country: 'MX',
        ),
      ],
      createdAt: DateTime.now(),
    );
  final String id;
  final double guestServiceFeeMinPct;
  final double guestServiceFeeMaxPct;
  final double hostFeePct;
  final List<ServiceFeeTier> serviceFeeTiers;
  final Map<String, TaxRate> taxRates;
  final List<RefundPolicy> refundPolicies;
  final List<CityConfig> citiesWhitelist;
  final int minBookingHours;
  final int maxBookingHours;
  final List<int> bookingIncrements; // En minutos: [30, 60]
  final int defaultCleaningBufferMinutes;
  final int checkoutTimeoutMinutes;
  final bool dynamicPricingEnabled;
  final bool moderationEnabled;
  final Map<String, dynamic>? features; // Feature flags
  final DateTime createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toFirestore() => {
      'guestServiceFeeMinPct': guestServiceFeeMinPct,
      'guestServiceFeeMaxPct': guestServiceFeeMaxPct,
      'hostFeePct': hostFeePct,
      'serviceFeeTiers': serviceFeeTiers.map((tier) => tier.toMap()).toList(),
      'taxRates': taxRates.map((key, value) => MapEntry(key, value.toMap())),
      'refundPolicies': refundPolicies.map((policy) => policy.toMap()).toList(),
      'citiesWhitelist': citiesWhitelist.map((city) => city.toMap()).toList(),
      'minBookingHours': minBookingHours,
      'maxBookingHours': maxBookingHours,
      'bookingIncrements': bookingIncrements,
      'defaultCleaningBufferMinutes': defaultCleaningBufferMinutes,
      'checkoutTimeoutMinutes': checkoutTimeoutMinutes,
      'dynamicPricingEnabled': dynamicPricingEnabled,
      'moderationEnabled': moderationEnabled,
      'features': features,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };

  SettingsModel copyWith({
    String? id,
    double? guestServiceFeeMinPct,
    double? guestServiceFeeMaxPct,
    double? hostFeePct,
    List<ServiceFeeTier>? serviceFeeTiers,
    Map<String, TaxRate>? taxRates,
    List<RefundPolicy>? refundPolicies,
    List<CityConfig>? citiesWhitelist,
    int? minBookingHours,
    int? maxBookingHours,
    List<int>? bookingIncrements,
    int? defaultCleaningBufferMinutes,
    int? checkoutTimeoutMinutes,
    bool? dynamicPricingEnabled,
    bool? moderationEnabled,
    Map<String, dynamic>? features,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SettingsModel(
      id: id ?? this.id,
      guestServiceFeeMinPct: guestServiceFeeMinPct ?? this.guestServiceFeeMinPct,
      guestServiceFeeMaxPct: guestServiceFeeMaxPct ?? this.guestServiceFeeMaxPct,
      hostFeePct: hostFeePct ?? this.hostFeePct,
      serviceFeeTiers: serviceFeeTiers ?? this.serviceFeeTiers,
      taxRates: taxRates ?? this.taxRates,
      refundPolicies: refundPolicies ?? this.refundPolicies,
      citiesWhitelist: citiesWhitelist ?? this.citiesWhitelist,
      minBookingHours: minBookingHours ?? this.minBookingHours,
      maxBookingHours: maxBookingHours ?? this.maxBookingHours,
      bookingIncrements: bookingIncrements ?? this.bookingIncrements,
      defaultCleaningBufferMinutes: defaultCleaningBufferMinutes ?? this.defaultCleaningBufferMinutes,
      checkoutTimeoutMinutes: checkoutTimeoutMinutes ?? this.checkoutTimeoutMinutes,
      dynamicPricingEnabled: dynamicPricingEnabled ?? this.dynamicPricingEnabled,
      moderationEnabled: moderationEnabled ?? this.moderationEnabled,
      features: features ?? this.features,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );

  // Métodos útiles
  double getServiceFeePercentage(double amount) {
    for (final tier in serviceFeeTiers) {
      if (tier.isAmountInRange(amount)) {
        return tier.feePercentage;
      }
    }
    return guestServiceFeeMaxPct; // Fallback
  }

  TaxRate? getTaxRate(String countryCode) => taxRates[countryCode];

  RefundPolicy? getRefundPolicy(String policyId) {
    try {
      return refundPolicies.firstWhere((policy) => policy.id == policyId);
    } catch (e) {
      return null;
    }
  }

  List<RefundPolicy> get activeRefundPolicies => refundPolicies.where((policy) => policy.active).toList();

  bool isCityActive(String cityCode) {
    try {
      final city = citiesWhitelist.firstWhere((city) => city.cityCode == cityCode);
      return city.active;
    } catch (e) {
      return false;
    }
  }

  List<CityConfig> get activeCities => citiesWhitelist.where((city) => city.active).toList();

  bool isFeatureEnabled(String featureName) => (features?[featureName] as bool?) ?? false;

  Duration get checkoutTimeout => Duration(minutes: checkoutTimeoutMinutes);
  Duration get defaultCleaningBuffer => Duration(minutes: defaultCleaningBufferMinutes);

  @override
  String toString() => 'SettingsModel(id: $id, hostFee: $hostFeePct%, serviceFee: $guestServiceFeeMinPct%-$guestServiceFeeMaxPct%)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}