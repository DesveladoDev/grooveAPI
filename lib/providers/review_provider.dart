import 'package:flutter/material.dart';
import 'package:salas_beats/models/review_model.dart';
import 'package:salas_beats/services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  // Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Estado de error
  String? _error;
  String? get error => _error;

  // Reseñas del usuario actual
  List<ReviewModel> _userReviews = [];
  List<ReviewModel> get userReviews => _userReviews;

  // Reseñas recibidas por el usuario
  List<ReviewModel> _receivedReviews = [];
  List<ReviewModel> get receivedReviews => _receivedReviews;

  // Reseñas de un listing específico
  List<ReviewModel> _listingReviews = [];
  List<ReviewModel> get listingReviews => _listingReviews;

  // Estadísticas de reseñas
  Map<String, dynamic>? _reviewStats;
  Map<String, dynamic>? get reviewStats => _reviewStats;

  // Reseña seleccionada para editar
  ReviewModel? _selectedReview;
  ReviewModel? get selectedReview => _selectedReview;

  // Streams
  Stream<List<ReviewModel>>? _userReviewsStream;
  Stream<List<ReviewModel>>? _receivedReviewsStream;
  Stream<List<ReviewModel>>? _listingReviewsStream;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Crear una nueva reseña
  Future<bool> createReview({
    required String bookingId,
    required String listingId,
    required String toUserId,
    required int rating,
    required String comment,
    Map<String, int>? categoryRatings,
    bool isPublic = true,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _reviewService.createReview(
        bookingId: bookingId,
        listingId: listingId,
        toUserId: toUserId,
        rating: rating,
        comment: comment,
        categoryRatings: categoryRatings,
        isPublic: isPublic,
      );

      // Refrescar las listas de reseñas
      await loadUserReviews();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cargar reseñas escritas por el usuario
  Future<void> loadUserReviews() async {
    try {
      _setLoading(true);
      _setError(null);

      // Obtener el UID del usuario actual desde el servicio
      // Por ahora usaremos un stream
      // _userReviews = await _reviewService.getUserReviews(userId, asReceiver: false);
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Configurar stream de reseñas del usuario
  void setupUserReviewsStream(String userId, {bool asReceiver = true}) {
    if (asReceiver) {
      _receivedReviewsStream = _reviewService.getUserReviews(userId);
      _receivedReviewsStream!.listen(
        (reviews) {
          _receivedReviews = reviews;
          notifyListeners();
        },
        onError: (Object error) {
          _setError(error.toString());
        },
      );
    } else {
      _userReviewsStream = _reviewService.getUserReviews(userId, asReceiver: false);
      _userReviewsStream!.listen(
        (reviews) {
          _userReviews = reviews;
          notifyListeners();
        },
        onError: (Object error) {
          _setError(error.toString());
        },
      );
    }
  }

  // Configurar stream de reseñas de un listing
  void setupListingReviewsStream(String listingId) {
    _listingReviewsStream = _reviewService.getListingReviews(listingId);
    _listingReviewsStream!.listen(
      (reviews) {
        _listingReviews = reviews;
        notifyListeners();
      },
      onError: (Object error) {
        _setError(error.toString());
      },
    );
  }

  // Verificar si se puede reseñar una reserva
  Future<bool> canReviewBooking(String bookingId) async {
    try {
      return await _reviewService.canReviewBooking(bookingId);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Obtener una reseña específica
  Future<ReviewModel?> getReview(String reviewId) async {
    try {
      _setLoading(true);
      _setError(null);

      final review = await _reviewService.getReview(reviewId);
      _selectedReview = review;
      
      return review;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar una reseña
  Future<bool> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
    Map<String, int>? categoryRatings,
    bool? isPublic,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _reviewService.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
        categoryRatings: categoryRatings,
        isPublic: isPublic,
      );

      // Actualizar la reseña seleccionada si es la misma
      if (_selectedReview?.id == reviewId) {
        _selectedReview = await _reviewService.getReview(reviewId);
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar una reseña
  Future<bool> deleteReview(String reviewId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _reviewService.deleteReview(reviewId);

      // Limpiar la reseña seleccionada si es la misma
      if (_selectedReview?.id == reviewId) {
        _selectedReview = null;
      }

      // Actualizar las listas
      _userReviews.removeWhere((review) => review.id == reviewId);
      _receivedReviews.removeWhere((review) => review.id == reviewId);
      _listingReviews.removeWhere((review) => review.id == reviewId);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cargar estadísticas de reseñas de un usuario
  Future<void> loadUserReviewStats(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      _reviewStats = await _reviewService.getUserReviewStats(userId);
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Reportar una reseña
  Future<bool> reportReview(String reviewId, String reason) async {
    try {
      _setLoading(true);
      _setError(null);

      await _reviewService.reportReview(reviewId, reason);
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Seleccionar una reseña para editar
  void selectReview(ReviewModel review) {
    _selectedReview = review;
    notifyListeners();
  }

  // Limpiar la reseña seleccionada
  void clearSelectedReview() {
    _selectedReview = null;
    notifyListeners();
  }

  // Obtener el promedio de rating de las reseñas de un listing
  double getListingAverageRating() {
    if (_listingReviews.isEmpty) return 0;
    
    final totalRating = _listingReviews
        .map((review) => review.rating)
        .reduce((a, b) => a + b);
    
    return totalRating / _listingReviews.length;
  }

  // Obtener la distribución de ratings de un listing
  Map<int, int> getListingRatingDistribution() {
    final distribution = <int, int>{};
    
    for (var i = 1; i <= 5; i++) {
      distribution[i] = _listingReviews
          .where((review) => review.rating == i)
          .length;
    }
    
    return distribution;
  }

  // Filtrar reseñas por rating
  List<ReviewModel> filterReviewsByRating(List<ReviewModel> reviews, int rating) => reviews.where((review) => review.rating == rating).toList();

  // Filtrar reseñas por fecha
  List<ReviewModel> filterReviewsByDate(List<ReviewModel> reviews, DateTime startDate, DateTime endDate) => reviews.where((review) => review.createdAt.isAfter(startDate) && 
             review.createdAt.isBefore(endDate),).toList();

  // Buscar reseñas por texto
  List<ReviewModel> searchReviews(List<ReviewModel> reviews, String query) {
    if (query.isEmpty) return reviews;
    
    final lowercaseQuery = query.toLowerCase();
    return reviews.where((review) => review.comment.toLowerCase().contains(lowercaseQuery)).toList();
  }

  // Limpiar todos los datos
  void clear() {
    _userReviews.clear();
    _receivedReviews.clear();
    _listingReviews.clear();
    _reviewStats = null;
    _selectedReview = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}