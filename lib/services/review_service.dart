import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salas_beats/models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crear una nueva reseña
  Future<String> createReview({
    required String bookingId,
    required String listingId,
    required String toUserId,
    required int rating,
    required String comment,
    Map<String, int>? categoryRatings,
    bool isPublic = true,
  }) async {
    try {
      // Validaciones de entrada
      if (bookingId.trim().isEmpty) {
        throw ArgumentError('El ID de reserva es obligatorio');
      }
      if (listingId.trim().isEmpty) {
        throw ArgumentError('El ID de listing es obligatorio');
      }
      if (toUserId.trim().isEmpty) {
        throw ArgumentError('El ID del usuario a reseñar es obligatorio');
      }
      if (rating < 1 || rating > 5) {
        throw ArgumentError('La calificación debe estar entre 1 y 5');
      }
      if (comment.trim().isEmpty) {
        throw ArgumentError('El comentario es obligatorio');
      }
      if (comment.trim().length < 10) {
        throw ArgumentError('El comentario debe tener al menos 10 caracteres');
      }
      if (comment.trim().length > 1000) {
        throw ArgumentError('El comentario no puede exceder 1000 caracteres');
      }
      
      // Validar categoryRatings si se proporcionan
      if (categoryRatings != null) {
        for (final entry in categoryRatings.entries) {
          if (entry.value < 1 || entry.value > 5) {
            throw ArgumentError('Todas las calificaciones por categoría deben estar entre 1 y 5');
          }
        }
      }
      
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw StateError('Usuario no autenticado');
      }
      
      // Verificar que no se esté auto-reseñando
      if (currentUser.uid == toUserId) {
        throw ArgumentError('No puedes reseñarte a ti mismo');
      }

      // Verificar que el usuario no haya reseñado ya esta reserva
      final existingReview = await _firestore
          .collection('reviews')
          .where('bookingId', isEqualTo: bookingId.trim())
          .where('fromUserId', isEqualTo: currentUser.uid)
          .get();

      if (existingReview.docs.isNotEmpty) {
        throw StateError('Ya has reseñado esta reserva');
      }

      final review = ReviewModel(
        id: '',
        bookingId: bookingId,
        listingId: listingId,
        fromUserId: currentUser.uid,
        toUserId: toUserId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        isPublic: isPublic,
        categoryRatings: categoryRatings,
      );

      final docRef = await _firestore
          .collection('reviews')
          .add(review.toFirestore());

      // Actualizar estadísticas del usuario reseñado
      await _updateUserRatingStats(toUserId);
      
      // Actualizar estadísticas del listing
      await _updateListingRatingStats(listingId);

      return docRef.id;
    } on ArgumentError catch (e) {
      throw ArgumentError('Datos inválidos: ${e.message}');
    } on StateError catch (e) {
      throw StateError('Estado inválido: ${e.message}');
    } on FirebaseException catch (e) {
      throw Exception('Error de base de datos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al crear reseña: ${e.toString()}');
    }
  }

  // Obtener reseñas de un usuario
  Stream<List<ReviewModel>> getUserReviews(String userId, {bool asReceiver = true}) {
    final field = asReceiver ? 'toUserId' : 'fromUserId';
    
    return _firestore
        .collection('reviews')
        .where(field, isEqualTo: userId)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList(),);
  }

  // Obtener reseñas de un listing
  Stream<List<ReviewModel>> getListingReviews(String listingId) => _firestore
        .collection('reviews')
        .where('listingId', isEqualTo: listingId)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList(),);

  // Obtener una reseña específica
  Future<ReviewModel?> getReview(String reviewId) async {
    try {
      // Validaciones de entrada
      if (reviewId.trim().isEmpty) {
        throw ArgumentError('El ID de reseña es obligatorio');
      }
      
      final doc = await _firestore
          .collection('reviews')
          .doc(reviewId.trim())
          .get();

      if (doc.exists) {
        return ReviewModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener reseña: $e');
    }
  }

  // Verificar si un usuario puede reseñar una reserva
  Future<bool> canReviewBooking(String bookingId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Verificar que la reserva existe y está completada
      final bookingDoc = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (!bookingDoc.exists) return false;

      final bookingData = bookingDoc.data()!;
      final status = bookingData['status'];
      final guestId = bookingData['guestId'];
      final hostId = bookingData['hostId'];

      // Solo se puede reseñar si la reserva está completada
      if (status != 'completed') return false;

      // Solo el huésped o el anfitrión pueden reseñar
      if (currentUser.uid != guestId && currentUser.uid != hostId) return false;

      // Verificar que no haya reseñado ya
      final existingReview = await _firestore
          .collection('reviews')
          .where('bookingId', isEqualTo: bookingId)
          .where('fromUserId', isEqualTo: currentUser.uid)
          .get();

      return existingReview.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  // Actualizar una reseña
  Future<void> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
    Map<String, int>? categoryRatings,
    bool? isPublic,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar que el usuario es el autor de la reseña
      final reviewDoc = await _firestore
          .collection('reviews')
          .doc(reviewId)
          .get();

      if (!reviewDoc.exists) {
        throw Exception('Reseña no encontrada');
      }

      final reviewData = reviewDoc.data()!;
      if (reviewData['fromUserId'] != currentUser.uid) {
        throw Exception('No tienes permisos para editar esta reseña');
      }

      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (rating != null) updateData['rating'] = rating;
      if (comment != null) updateData['comment'] = comment;
      if (categoryRatings != null) updateData['categoryRatings'] = categoryRatings;
      if (isPublic != null) updateData['isPublic'] = isPublic;

      await _firestore
          .collection('reviews')
          .doc(reviewId)
          .update(updateData);

      // Actualizar estadísticas si cambió el rating
      if (rating != null) {
        await _updateUserRatingStats(reviewData['toUserId'] as String);
        await _updateListingRatingStats(reviewData['listingId'] as String);
      }
    } catch (e) {
      throw Exception('Error al actualizar reseña: $e');
    }
  }

  // Eliminar una reseña
  Future<void> deleteReview(String reviewId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar que el usuario es el autor de la reseña
      final reviewDoc = await _firestore
          .collection('reviews')
          .doc(reviewId)
          .get();

      if (!reviewDoc.exists) {
        throw Exception('Reseña no encontrada');
      }

      final reviewData = reviewDoc.data()!;
      if (reviewData['fromUserId'] != currentUser.uid) {
        throw Exception('No tienes permisos para eliminar esta reseña');
      }

      await _firestore
          .collection('reviews')
          .doc(reviewId)
          .delete();

      // Actualizar estadísticas
      await _updateUserRatingStats(reviewData['toUserId'] as String);
      await _updateListingRatingStats(reviewData['listingId'] as String);
    } catch (e) {
      throw Exception('Error al eliminar reseña: $e');
    }
  }

  // Obtener estadísticas de reseñas de un usuario
  Future<Map<String, dynamic>> getUserReviewStats(String userId) async {
    try {
      final reviews = await _firestore
          .collection('reviews')
          .where('toUserId', isEqualTo: userId)
          .where('isPublic', isEqualTo: true)
          .get();

      if (reviews.docs.isEmpty) {
        return {
          'totalReviews': 0,
          'averageRating': 0.0,
          'ratingDistribution': <int, int>{},
        };
      }

      final ratings = reviews.docs
          .map((doc) => (doc.data()['rating'] as num).toInt())
          .toList();

      final totalReviews = ratings.length;
      final averageRating = ratings.reduce((a, b) => a + b) / totalReviews;
      
      final ratingDistribution = <int, int>{};
      for (var i = 1; i <= 5; i++) {
        ratingDistribution[i] = ratings.where((r) => r == i).length;
      }

      return {
        'totalReviews': totalReviews,
        'averageRating': averageRating,
        'ratingDistribution': ratingDistribution,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // Actualizar estadísticas de rating de un usuario
  Future<void> _updateUserRatingStats(String userId) async {
    try {
      final stats = await getUserReviewStats(userId);
      
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'reviewStats': stats,
        'averageRating': stats['averageRating'],
        'totalReviews': stats['totalReviews'],
      });
    } catch (e) {
      // Error silencioso para no afectar la operación principal
      print('Error actualizando estadísticas de usuario: $e');
    }
  }

  // Actualizar estadísticas de rating de un listing
  Future<void> _updateListingRatingStats(String listingId) async {
    try {
      final reviews = await _firestore
          .collection('reviews')
          .where('listingId', isEqualTo: listingId)
          .where('isPublic', isEqualTo: true)
          .get();

      if (reviews.docs.isEmpty) {
        await _firestore
            .collection('listings')
            .doc(listingId)
            .update({
          'averageRating': 0.0,
          'totalReviews': 0,
        });
        return;
      }

      final ratings = reviews.docs
          .map((doc) => (doc.data()['rating'] as num).toInt())
          .toList();

      final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      
      await _firestore
          .collection('listings')
          .doc(listingId)
          .update({
        'averageRating': averageRating,
        'totalReviews': ratings.length,
      });
    } catch (e) {
      // Error silencioso para no afectar la operación principal
      print('Error actualizando estadísticas de listing: $e');
    }
  }

  // Reportar una reseña
  Future<void> reportReview(String reviewId, String reason) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      await _firestore
          .collection('review_reports')
          .add({
        'reviewId': reviewId,
        'reportedBy': currentUser.uid,
        'reason': reason,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('Error al reportar reseña: $e');
    }
  }
}