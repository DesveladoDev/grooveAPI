import 'package:cloud_firestore/cloud_firestore.dart';

enum CancellationPolicy { flexible, moderate, strict }

class LocationData {

  LocationData({
    required this.lat,
    required this.lng,
    required this.address,
    required this.city,
    this.state,
    this.postalCode,
    this.country = 'México',
  });

  factory LocationData.fromMap(Map<String, dynamic> map) => LocationData(
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      state: map['state'] as String?,
      postalCode: map['postalCode'] as String?,
      country: map['country'] as String? ?? 'México',
    );
  final double lat;
  final double lng;
  final String address;
  final String city;
  final String? state;
  final String? postalCode;
  final String? country;

  Map<String, dynamic> toMap() => {
      'lat': lat,
      'lng': lng,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };

  LocationData copyWith({
    double? lat,
    double? lng,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) => LocationData(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );

  String get fullAddress {
    final parts = [address, city, state, country].where((part) => part != null && part.isNotEmpty);
    return parts.join(', ');
  }
}

class PricingRule { // 1.0 = precio base, 1.5 = 50% más caro

  PricingRule({
    required this.dayOfWeek,
    required this.timeSlot,
    required this.multiplier,
  });

  factory PricingRule.fromMap(Map<String, dynamic> map) => PricingRule(
      dayOfWeek: map['dayOfWeek'] as String? ?? '',
      timeSlot: map['timeSlot'] as String? ?? '',
      multiplier: (map['multiplier'] as num?)?.toDouble() ?? 1.0,
    );
  final String dayOfWeek; // 'monday', 'tuesday', etc. o 'weekend', 'weekday'
  final String timeSlot; // '09:00-12:00', '12:00-18:00', '18:00-23:00'
  final double multiplier;

  Map<String, dynamic> toMap() => {
      'dayOfWeek': dayOfWeek,
      'timeSlot': timeSlot,
      'multiplier': multiplier,
    };
}

class ListingModel { // Precio por hora (alias para hourlyPrice)

  ListingModel({
    required this.id,
    required this.hostId,
    required this.title,
    required this.description,
    required this.capacity, required this.hourlyPrice, required this.location, required this.createdAt, this.photos = const [],
    this.videoUrl,
    this.amenities = const [],
    this.rules = const [],
    this.cancellationPolicy = CancellationPolicy.moderate,
    this.active = true,
    this.updatedAt,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.pricingRules = const [],
    this.minBookingHours = 1,
    this.bufferMinutes = 15,
    this.studioType,
    this.features = const {},
    this.zipCode,
    this.category,
    this.equipment = const [],
    this.pricePerHour,
  });

  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return ListingModel(
      id: doc.id,
      hostId: data['hostId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      photos: List<String>.from(data['photos'] as Iterable? ?? []),
      videoUrl: data['videoUrl'] as String?,
      amenities: List<String>.from(data['amenities'] as Iterable? ?? []),
      capacity: (data['capacity'] as num?)?.toInt() ?? 1,
      hourlyPrice: (data['hourlyPrice'] as num?)?.toDouble() ?? 0.0,
      rules: List<String>.from(data['rules'] as Iterable? ?? []),
      location: LocationData.fromMap(data['location'] as Map<String, dynamic>? ?? {}),
      cancellationPolicy: CancellationPolicy.values.firstWhere(
        (e) => e.toString().split('.').last == data['cancellationPolicy'],
        orElse: () => CancellationPolicy.moderate,
      ),
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      pricingRules: (data['pricingRules'] as List<dynamic>? ?? [])
          .map((rule) => PricingRule.fromMap(rule as Map<String, dynamic>))
          .toList(),
      minBookingHours: (data['minBookingHours'] as int?) ?? 1,
      bufferMinutes: (data['bufferMinutes'] as int?) ?? 15,
      studioType: data['studioType'] as String?,
      features: Map<String, bool>.from(data['features'] as Map<dynamic, dynamic>? ?? {}),
      zipCode: data['zipCode'] as String?,
      category: data['category'] as String?,
      equipment: List<String>.from(data['equipment'] as Iterable<dynamic>? ?? []),
      pricePerHour: (data['pricePerHour'] as num?)?.toDouble(),
    );
  }
  final String id;
  final String hostId;
  final String title;
  final String description;
  final List<String> photos;
  final String? videoUrl;
  final List<String> amenities;
  final int capacity; // Número de personas
  final double hourlyPrice; // Precio base por hora en MXN
  final List<String> rules;
  final LocationData location;
  final CancellationPolicy cancellationPolicy;
  final bool active;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double rating;
  final int reviewCount;
  final List<PricingRule> pricingRules;
  final int minBookingHours; // Mínimo de horas para reservar
  final int bufferMinutes; // Minutos de buffer entre reservas
  final String? studioType; // 'ensayo', 'grabacion', 'mixto'
  final Map<String, bool> features; // Características específicas
  final String? zipCode; // Código postal
  final String? category; // Categoría del estudio
  final List<String> equipment; // Equipamiento disponible
  final double? pricePerHour;

  Map<String, dynamic> toFirestore() => {
      'hostId': hostId,
      'title': title,
      'description': description,
      'photos': photos,
      'videoUrl': videoUrl,
      'amenities': amenities,
      'capacity': capacity,
      'hourlyPrice': hourlyPrice,
      'rules': rules,
      'location': location.toMap(),
      'cancellationPolicy': cancellationPolicy.toString().split('.').last,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'rating': rating,
      'reviewCount': reviewCount,
      'pricingRules': pricingRules.map((rule) => rule.toMap()).toList(),
      'minBookingHours': minBookingHours,
      'bufferMinutes': bufferMinutes,
      'studioType': studioType,
      'features': features,
      'zipCode': zipCode,
      'category': category,
      'equipment': equipment,
      'pricePerHour': pricePerHour,
    };

  ListingModel copyWith({
    String? id,
    String? hostId,
    String? title,
    String? description,
    List<String>? photos,
    String? videoUrl,
    List<String>? amenities,
    int? capacity,
    double? hourlyPrice,
    List<String>? rules,
    LocationData? location,
    CancellationPolicy? cancellationPolicy,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewCount,
    List<PricingRule>? pricingRules,
    int? minBookingHours,
    int? bufferMinutes,
    String? studioType,
    Map<String, bool>? features,
    String? zipCode,
    String? category,
    List<String>? equipment,
    double? pricePerHour,
  }) => ListingModel(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      title: title ?? this.title,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      videoUrl: videoUrl ?? this.videoUrl,
      amenities: amenities ?? this.amenities,
      capacity: capacity ?? this.capacity,
      hourlyPrice: hourlyPrice ?? this.hourlyPrice,
      rules: rules ?? this.rules,
      location: location ?? this.location,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      pricingRules: pricingRules ?? this.pricingRules,
      minBookingHours: minBookingHours ?? this.minBookingHours,
      bufferMinutes: bufferMinutes ?? this.bufferMinutes,
      studioType: studioType ?? this.studioType,
      features: features ?? this.features,
      zipCode: zipCode ?? this.zipCode,
      category: category ?? this.category,
      equipment: equipment ?? this.equipment,
      pricePerHour: pricePerHour ?? this.pricePerHour,
    );

  // Getters útiles
  String get formattedPrice => '\$${hourlyPrice.toStringAsFixed(0)} MXN/hora';
  String get formattedRating => rating > 0 ? rating.toStringAsFixed(1) : 'Nuevo';
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasPhotos => photos.isNotEmpty;
  String get primaryPhoto => photos.isNotEmpty ? photos.first : '';
  
  // Calcular precio dinámico basado en fecha y hora
  double calculateDynamicPrice(DateTime dateTime) {
    var finalPrice = hourlyPrice;
    
    for (final rule in pricingRules) {
      // Lógica para aplicar reglas de precios dinámicos
      // Esto se puede expandir según las necesidades específicas
      if (_matchesPricingRule(rule, dateTime)) {
        finalPrice *= rule.multiplier;
      }
    }
    
    return finalPrice;
  }
  
  bool _matchesPricingRule(PricingRule rule, DateTime dateTime) {
    // Implementar lógica para verificar si la fecha/hora coincide con la regla
    // Por ahora, retorna false como placeholder
    return false;
  }

  // Getter para compatibilidad
  bool get isActive => active;

  @override
  String toString() => 'ListingModel(id: $id, title: $title, hourlyPrice: $hourlyPrice, active: $active)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}