import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel { // Ratings por categoría (limpieza, comunicación, etc.)

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.listingId,
    required this.fromUserId,
    required this.toUserId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
    this.isPublic = true,
    this.categoryRatings,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      bookingId: data['bookingId'] as String? ?? '',
      listingId: data['listingId'] as String? ?? '',
      fromUserId: data['fromUserId'] as String? ?? '',
      toUserId: data['toUserId'] as String? ?? '',
      rating: (data['rating'] as int?) ?? 1,
      comment: data['comment'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isPublic: (data['isPublic'] as bool?) ?? true,
      categoryRatings: data['categoryRatings'] != null
          ? Map<String, int>.from(data['categoryRatings'] as Map<dynamic, dynamic>)
          : null,
    );
  }
  final String id;
  final String bookingId;
  final String listingId;
  final String fromUserId; // Quien escribe la reseña
  final String toUserId; // Quien recibe la reseña
  final int rating; // 1-5 estrellas
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPublic; // Si la reseña es pública o privada
  final Map<String, int>? categoryRatings;

  Map<String, dynamic> toFirestore() => {
      'bookingId': bookingId,
      'listingId': listingId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isPublic': isPublic,
      'categoryRatings': categoryRatings,
    };

  ReviewModel copyWith({
    String? id,
    String? bookingId,
    String? listingId,
    String? fromUserId,
    String? toUserId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    Map<String, int>? categoryRatings,
  }) => ReviewModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      listingId: listingId ?? this.listingId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      categoryRatings: categoryRatings ?? this.categoryRatings,
    );

  // Getters útiles
  String get formattedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year}';

  String get ratingStars => '★' * rating + '☆' * (5 - rating);

  bool get hasComment => comment.isNotEmpty;
  bool get hasCategoryRatings => categoryRatings != null && categoryRatings!.isNotEmpty;

  double get averageCategoryRating {
    if (categoryRatings == null || categoryRatings!.isEmpty) return rating.toDouble();
    final sum = categoryRatings!.values.reduce((a, b) => a + b);
    return sum / categoryRatings!.length;
  }

  @override
  String toString() => 'ReviewModel(id: $id, rating: $rating, fromUserId: $fromUserId, toUserId: $toUserId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}