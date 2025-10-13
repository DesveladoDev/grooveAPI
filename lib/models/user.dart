import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  guest,
  host,
  admin
}

class User {

  User({
    required this.id,
    required this.email,
    required this.role, 
    required this.isVerified, 
    required this.createdAt, 
    required this.updatedAt, 
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.preferences,
    this.favoriteListings,
    this.isOnboardingComplete = false,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == data['role'],
        orElse: () => UserRole.guest,
      ),
      isVerified: (data['isVerified'] as bool?) ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      preferences: data['preferences'] as Map<String, dynamic>?,
      favoriteListings: data['favoriteListings'] != null
          ? List<String>.from(data['favoriteListings'] as Iterable)
          : null,
      isOnboardingComplete: (data['isOnboardingComplete'] as bool?) ?? false,
    );
  }
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final UserRole role;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;
  final List<String>? favoriteListings;
  final bool isOnboardingComplete;

  Map<String, dynamic> toFirestore() => {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'preferences': preferences,
      'favoriteListings': favoriteListings,
      'isOnboardingComplete': isOnboardingComplete,
    };

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    UserRole? role,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    List<String>? favoriteListings,
  }) => User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      favoriteListings: favoriteListings ?? this.favoriteListings,
    );
}