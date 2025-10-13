import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { musician, host, admin }

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
  }); // TODO: Implement badges system

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == data['role'],
        orElse: () => UserRole.musician,
      ),
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      phone: data['phone'] as String?,
      photoURL: data['photoURL'] as String?,
      verified: (data['verified'] as bool?) ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isOnboardingComplete: (data['isOnboardingComplete'] as bool?) ?? false,
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

  String get displayName => name;

  // Additional getters for UI compatibility
  bool get isVerified => verified;
  double get rating => 0; // TODO: Implement rating system
  int get reviewCount => 0; // TODO: Implement review system
  String get status => 'offline'; // TODO: Implement status system
  String get bio => ''; // TODO: Implement bio field
  List<String> get badges => [];

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
  }) => UserModel(
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
    );

  @override
  String toString() => 'UserModel(id: $id, role: $role, name: $name, email: $email, verified: $verified)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}