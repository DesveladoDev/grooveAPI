import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { 
  musician, 
  host, 
  admin,
  guest // Agregado para compatibilidad
}

enum UserStatus {
  online,
  offline,
  away,
  busy,
  invisible
}

enum UserBadge {
  verified,
  premium,
  topHost,
  superHost,
  newUser,
  frequentGuest,
  earlyAdopter,
  musicExpert,
  studioOwner
}

class UserModel {
  UserModel({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.createdAt,
    this.phone,
    this.photoURL,
    this.verified = false,
    this.updatedAt,
    this.isOnboardingComplete = false,
    this.preferences,
    this.favoriteListings,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.status = UserStatus.offline,
    this.bio = '',
    this.badges = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == data['role'],
        orElse: () => UserRole.guest,
      ),
      name: (data['name'] as String?) ?? (data['displayName'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? (data['phoneNumber'] as String?),
      photoURL: data['photoURL'] as String?,
      verified: (data['verified'] as bool?) ?? (data['isVerified'] as bool?) ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isOnboardingComplete: (data['isOnboardingComplete'] as bool?) ?? false,
      preferences: data['preferences'] as Map<String, dynamic>?,
      favoriteListings: data['favoriteListings'] != null
          ? List<String>.from(data['favoriteListings'] as Iterable)
          : null,
      rating: _validateRating(((data['rating'] ?? 0.0) as num).toDouble()),
      reviewCount: _validateReviewCount((data['reviewCount'] as int?) ?? 0),
      status: _parseUserStatus((data['status'] as String?) ?? 'offline'),
      bio: _validateBio((data['bio'] as String?) ?? ''),
      badges: _parseBadges(data['badges']),
    );
  }

  final String id;
  final UserRole role;
  final String name;
  final String email;
  final String? phone;
  final String? photoURL;
  final bool verified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isOnboardingComplete;
  final Map<String, dynamic>? preferences;
  final List<String>? favoriteListings;
  final double rating;
  final int reviewCount;
  final UserStatus status;
  final String bio;
  final List<UserBadge> badges;

  // Getters for compatibility
  String get displayName => name;
  bool get isVerified => verified;
  String? get phoneNumber => phone;

  Map<String, dynamic> toFirestore() => {
        'role': role.toString().split('.').last,
        'name': name,
        'email': email,
        'phone': phone,
        'photoURL': photoURL,
        'verified': verified,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
        'isOnboardingComplete': isOnboardingComplete,
        'preferences': preferences,
        'favoriteListings': favoriteListings,
        'rating': rating,
        'reviewCount': reviewCount,
        'status': status.toString().split('.').last,
        'bio': bio,
        'badges': badges.map((badge) => badge.toString().split('.').last).toList(),
      };

  UserModel copyWith({
    String? id,
    UserRole? role,
    String? name,
    String? email,
    String? phone,
    String? photoURL,
    bool? verified,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOnboardingComplete,
    Map<String, dynamic>? preferences,
    List<String>? favoriteListings,
    double? rating,
    int? reviewCount,
    UserStatus? status,
    String? bio,
    List<UserBadge>? badges,
  }) =>
      UserModel(
        id: id ?? this.id,
        role: role ?? this.role,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        photoURL: photoURL ?? this.photoURL,
        verified: verified ?? this.verified,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
        preferences: preferences ?? this.preferences,
        favoriteListings: favoriteListings ?? this.favoriteListings,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        status: status ?? this.status,
        bio: bio ?? this.bio,
        badges: badges ?? this.badges,
      );

  @override
  String toString() =>
      'UserModel(id: $id, role: $role, name: $name, email: $email, verified: $verified)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Métodos de utilidad para rating y reviews
  String get ratingDisplay => rating.toStringAsFixed(1);
  
  bool get hasRating => rating > 0.0;
  
  bool get hasReviews => reviewCount > 0;
  
  String get reviewCountDisplay {
    if (reviewCount == 0) return 'Sin reseñas';
    if (reviewCount == 1) return '1 reseña';
    return '$reviewCount reseñas';
  }

  // Métodos de utilidad para status
  bool get isOnline => status == UserStatus.online;
  
  bool get isAvailable => status == UserStatus.online || status == UserStatus.away;
  
  String get statusDisplay {
    switch (status) {
      case UserStatus.online:
        return 'En línea';
      case UserStatus.offline:
        return 'Desconectado';
      case UserStatus.away:
        return 'Ausente';
      case UserStatus.busy:
        return 'Ocupado';
      case UserStatus.invisible:
        return 'Invisible';
    }
  }

  // Métodos de utilidad para bio
  bool get hasBio => bio.isNotEmpty;
  
  String get bioPreview {
    if (bio.length <= 100) return bio;
    return '${bio.substring(0, 97)}...';
  }

  // Métodos de utilidad para badges
  bool get hasBadges => badges.isNotEmpty;
  
  bool hasBadge(UserBadge badge) => badges.contains(badge);
  
  List<UserBadge> get displayBadges => badges.take(3).toList();
  
  int get hiddenBadgesCount => badges.length > 3 ? badges.length - 3 : 0;

  // Métodos para actualizar rating
  UserModel updateRating(double newRating, int newReviewCount) {
    return copyWith(
      rating: _validateRating(newRating),
      reviewCount: _validateReviewCount(newReviewCount),
      updatedAt: DateTime.now(),
    );
  }

  // Métodos para gestionar badges
  UserModel addBadge(UserBadge badge) {
    if (badges.contains(badge)) return this;
    final newBadges = List<UserBadge>.from(badges)..add(badge);
    return copyWith(
      badges: newBadges,
      updatedAt: DateTime.now(),
    );
  }

  UserModel removeBadge(UserBadge badge) {
    if (!badges.contains(badge)) return this;
    final newBadges = List<UserBadge>.from(badges)..remove(badge);
    return copyWith(
      badges: newBadges,
      updatedAt: DateTime.now(),
    );
  }

  // Métodos para actualizar status
  UserModel updateStatus(UserStatus newStatus) {
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
  }

  // Métodos para actualizar bio
  UserModel updateBio(String newBio) {
    return copyWith(
      bio: _validateBio(newBio),
      updatedAt: DateTime.now(),
    );
  }

  // Métodos de validación estáticos
  static double _validateRating(double rating) {
    if (rating < 0.0) return 0.0;
    if (rating > 5.0) return 5.0;
    return rating;
  }

  static int _validateReviewCount(int count) {
    return count < 0 ? 0 : count;
  }

  static UserStatus _parseUserStatus(String status) {
    try {
      return UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status,
      );
    } catch (e) {
      return UserStatus.offline;
    }
  }

  static String _validateBio(String bio) {
    if (bio.length > 500) {
      return bio.substring(0, 500);
    }
    return bio.trim();
  }

  static List<UserBadge> _parseBadges(dynamic badgesData) {
    if (badgesData == null) return const [];
    
    try {
      final badgeStrings = List<String>.from(badgesData as Iterable);
      return badgeStrings
          .map((badgeString) {
            try {
              return UserBadge.values.firstWhere(
                (e) => e.toString().split('.').last == badgeString,
              );
            } catch (e) {
              return null;
            }
          })
          .where((badge) => badge != null)
          .cast<UserBadge>()
          .toList();
    } catch (e) {
      return const [];
    }
  }
}

// Alias para compatibilidad con código existente
typedef User = UserModel;