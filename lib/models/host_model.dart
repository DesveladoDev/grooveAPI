import 'package:cloud_firestore/cloud_firestore.dart';

enum KycStatus { pending, inReview, approved, rejected }

class HostStats { // Porcentaje

  HostStats({
    this.totalBookings = 0,
    this.totalListings = 0,
    this.totalEarnings = 0.0,
    this.responseRate = 100,
    this.averageResponseTime = 1.0,
    this.cancellationRate = 0,
  });

  factory HostStats.fromMap(Map<String, dynamic> map) => HostStats(
      totalBookings: (map['totalBookings'] as num?)?.toInt() ?? 0,
      totalListings: (map['totalListings'] as num?)?.toInt() ?? 0,
      totalEarnings: (map['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      responseRate: (map['responseRate'] as num?)?.toInt() ?? 100,
      averageResponseTime: (map['averageResponseTime'] as num?)?.toDouble() ?? 1.0,
      cancellationRate: (map['cancellationRate'] as num?)?.toInt() ?? 0,
    );
  final int totalBookings;
  final int totalListings;
  final double totalEarnings;
  final int responseRate; // Porcentaje
  final double averageResponseTime; // En horas
  final int cancellationRate;

  Map<String, dynamic> toMap() => {
      'totalBookings': totalBookings,
      'totalListings': totalListings,
      'totalEarnings': totalEarnings,
      'responseRate': responseRate,
      'averageResponseTime': averageResponseTime,
      'cancellationRate': cancellationRate,
    };

  HostStats copyWith({
    int? totalBookings,
    int? totalListings,
    double? totalEarnings,
    int? responseRate,
    double? averageResponseTime,
    int? cancellationRate,
  }) => HostStats(
      totalBookings: totalBookings ?? this.totalBookings,
      totalListings: totalListings ?? this.totalListings,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      responseRate: responseRate ?? this.responseRate,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      cancellationRate: cancellationRate ?? this.cancellationRate,
    );
}

class HostModel {

  HostModel({
    required this.userId,
    required this.stats, required this.createdAt, this.stripeAccountId,
    this.kycStatus = KycStatus.pending,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.updatedAt,
    this.businessName,
    this.taxId,
    this.bankAccount,
    this.isActive = true,
  });

  factory HostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return HostModel(
      userId: data['userId'] as String? ?? '',
      stripeAccountId: data['stripeAccountId'] as String?,
      kycStatus: KycStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['kycStatus'],
        orElse: () => KycStatus.pending,
      ),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      stats: HostStats.fromMap(data['stats'] as Map<String, dynamic>? ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      businessName: data['businessName'] as String?,
      taxId: data['taxId'] as String?,
      bankAccount: data['bankAccount'] as String?,
      isActive: data['isActive'] as bool? ?? true,
    );
  }
  final String userId;
  final String? stripeAccountId;
  final KycStatus kycStatus;
  final double rating;
  final int reviewCount;
  final HostStats stats;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? businessName;
  final String? taxId; // RFC en México
  final String? bankAccount; // CLABE
  final bool isActive;

  Map<String, dynamic> toFirestore() => {
      'userId': userId,
      'stripeAccountId': stripeAccountId,
      'kycStatus': kycStatus.toString().split('.').last,
      'rating': rating,
      'reviewCount': reviewCount,
      'stats': stats.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'businessName': businessName,
      'taxId': taxId,
      'bankAccount': bankAccount,
      'isActive': isActive,
    };

  HostModel copyWith({
    String? userId,
    String? stripeAccountId,
    KycStatus? kycStatus,
    double? rating,
    int? reviewCount,
    HostStats? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? businessName,
    String? taxId,
    String? bankAccount,
    bool? isActive,
  }) => HostModel(
      userId: userId ?? this.userId,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      kycStatus: kycStatus ?? this.kycStatus,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      businessName: businessName ?? this.businessName,
      taxId: taxId ?? this.taxId,
      bankAccount: bankAccount ?? this.bankAccount,
      isActive: isActive ?? this.isActive,
    );

  // Getters útiles
  bool get isStripeConnected => stripeAccountId != null && stripeAccountId!.isNotEmpty;
  bool get isKycApproved => kycStatus == KycStatus.approved;
  bool get canReceivePayments => isStripeConnected && isKycApproved && isActive;
  String get formattedRating => rating.toStringAsFixed(1);

  @override
  String toString() => 'HostModel(userId: $userId, kycStatus: $kycStatus, rating: $rating, isActive: $isActive)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HostModel && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}