import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/models/review_model.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/providers/review_provider.dart';
import 'package:salas_beats/widgets/common/custom_button.dart';
import 'package:salas_beats/widgets/common/custom_text_field.dart';
import 'package:salas_beats/widgets/review/category_ratings.dart';
import 'package:salas_beats/widgets/review/rating_input.dart';

class ReviewCreateScreen extends StatefulWidget { // Para editar

  const ReviewCreateScreen({
    required this.bookingId, required this.listingId, required this.toUserId, super.key,
    this.toUserName,
    this.listingTitle,
    this.existingReview,
  });
  final String bookingId;
  final String listingId;
  final String toUserId;
  final String? toUserName;
  final String? listingTitle;
  final ReviewModel? existingReview;

  @override
  State<ReviewCreateScreen> createState() => _ReviewCreateScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('bookingId', bookingId));
    properties.add(StringProperty('listingId', listingId));
    properties.add(StringProperty('toUserId', toUserId));
    properties.add(StringProperty('toUserName', toUserName));
    properties.add(StringProperty('listingTitle', listingTitle));
    properties.add(DiagnosticsProperty<ReviewModel?>('existingReview', existingReview));
  }
}

class _ReviewCreateScreenState extends State<ReviewCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  int _overallRating = 5;
  Map<String, int> _categoryRatings = {
    'Limpieza': 5,
    'Comunicación': 5,
    'Ubicación': 5,
    'Precio/Calidad': 5,
  };
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.existingReview != null) {
      final review = widget.existingReview!;
      _overallRating = review.rating;
      _commentController.text = review.comment;
      _isPublic = review.isPublic;
      
      if (review.categoryRatings != null) {
        _categoryRatings = Map<String, int>.from(review.categoryRatings!);
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    var success = false;

    try {
      if (widget.existingReview != null) {
        // Actualizar reseña existente
        success = await reviewProvider.updateReview(
          reviewId: widget.existingReview!.id,
          rating: _overallRating,
          comment: _commentController.text.trim(),
          categoryRatings: _categoryRatings,
          isPublic: _isPublic,
        );
      } else {
        // Crear nueva reseña
        success = await reviewProvider.createReview(
          bookingId: widget.bookingId,
          listingId: widget.listingId,
          toUserId: widget.toUserId,
          rating: _overallRating,
          comment: _commentController.text.trim(),
          categoryRatings: _categoryRatings,
          isPublic: _isPublic,
        );
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.existingReview != null
                    ? 'Reseña actualizada exitosamente'
                    : 'Reseña creada exitosamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        _showErrorSnackBar(reviewProvider.error ?? 'Error desconocido');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingReview != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Reseña' : 'Escribir Reseña'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información de la reserva
              _buildBookingInfo(theme),
              const SizedBox(height: 24),

              // Rating general
              _buildOverallRating(theme),
              const SizedBox(height: 24),

              // Ratings por categoría
              _buildCategoryRatings(theme),
              const SizedBox(height: 24),

              // Comentario
              _buildCommentSection(theme),
              const SizedBox(height: 24),

              // Configuración de privacidad
              _buildPrivacySettings(theme),
              const SizedBox(height: 32),

              // Botón de envío
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingInfo(ThemeData theme) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.listingTitle != null) ...[
            Text(
              'Espacio',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.listingTitle!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (widget.toUserName != null) ...[
            Text(
              'Anfitrión',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.toUserName!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );

  Widget _buildOverallRating(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calificación General',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        RatingInput(
          rating: _overallRating,
          onRatingChanged: (rating) {
            setState(() {
              _overallRating = rating;
            });
          },
          size: 40,
        ),
      ],
    );

  Widget _buildCategoryRatings(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calificaciones Detalladas',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        CategoryRatings(
          ratings: _categoryRatings,
          onRatingsChanged: (ratings) {
            setState(() {
              _categoryRatings = ratings;
            });
          },
        ),
      ],
    );

  Widget _buildCommentSection(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comentario',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _commentController,
          hint: 'Comparte tu experiencia...',
          maxLines: 5,
          maxLength: 500,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor escribe un comentario';
            }
            if (value.trim().length < 10) {
              return 'El comentario debe tener al menos 10 caracteres';
            }
            return null;
          },
        ),
      ],
    );

  Widget _buildPrivacySettings(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración de Privacidad',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Reseña pública'),
          subtitle: const Text(
            'Permitir que otros usuarios vean esta reseña',
          ),
          value: _isPublic,
          onChanged: (value) {
            setState(() {
              _isPublic = value;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );

  Widget _buildSubmitButton() => SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: widget.existingReview != null ? 'Actualizar Reseña' : 'Publicar Reseña',
        onPressed: _isLoading ? null : _submitReview,
        isLoading: _isLoading,
      ),
    );
}