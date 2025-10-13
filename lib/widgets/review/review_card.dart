import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/models/review_model.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/providers/review_provider.dart';
import 'package:salas_beats/widgets/common/custom_button.dart';
import 'package:salas_beats/widgets/common/user_avatar.dart';
import 'package:salas_beats/widgets/review/category_ratings.dart';
import 'package:salas_beats/widgets/review/rating_input.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewCard extends StatelessWidget {

  const ReviewCard({
    required this.review, super.key,
    this.showActions = true,
    this.onEdit,
    this.onDelete,
    this.onReport,
    this.showUserInfo = true,
    this.expandable = false,
  });
  final ReviewModel review;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final bool showUserInfo;
  final bool expandable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwnReview = authProvider.user?.id == review.fromUserId;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información del usuario
            if (showUserInfo) _buildUserHeader(context, theme),
            
            // Rating y fecha
            _buildRatingSection(context, theme),
            
            // Comentario
            if (review.hasComment) ...[
              const SizedBox(height: 12),
              _buildCommentSection(context, theme),
            ],
            
            // Ratings por categoría
            if (review.hasCategoryRatings) ...[
              const SizedBox(height: 16),
              _buildCategoryRatings(context, theme),
            ],
            
            // Acciones
            if (showActions && (isOwnReview || !isOwnReview)) ...[
              const SizedBox(height: 16),
              _buildActionsSection(context, theme, isOwnReview),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, ThemeData theme) => FutureBuilder<Map<String, dynamic>?>(
      future: _getUserInfo(review.fromUserId),
      builder: (context, snapshot) {
        final userInfo = snapshot.data;
        final userName = userInfo?['name'] ?? 'Usuario';
        final userAvatar = userInfo?['photoURL'];
        
        return Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: userAvatar != null ? NetworkImage(userAvatar as String) : null,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: userAvatar == null ? Text(
                (userName as String).isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName as String,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    timeago.format(review.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (review.updatedAt != null)
              Tooltip(
                message: 'Editado',
                child: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        );
      },
    );

  Widget _buildRatingSection(BuildContext context, ThemeData theme) => Row(
      children: [
        RatingDisplay(
          rating: review.rating.toDouble(),
          size: 18,
          textStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (!showUserInfo)
          Text(
            timeago.format(review.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );

  Widget _buildCommentSection(BuildContext context, ThemeData theme) {
    if (expandable && review.comment.length > 200) {
      return _ExpandableComment(comment: review.comment);
    }
    
    return Text(
      review.comment,
      style: theme.textTheme.bodyMedium,
    );
  }

  Widget _buildCategoryRatings(BuildContext context, ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calificaciones Detalladas',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        CategoryRatingsDisplay(
          ratings: review.categoryRatings!,
          iconSize: 14,
        ),
      ],
    );

  Widget _buildActionsSection(BuildContext context, ThemeData theme, bool isOwnReview) => Row(
      children: [
        if (isOwnReview) ...[
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Editar'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _showDeleteConfirmation(context),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Eliminar'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ] else ...[
          TextButton.icon(
            onPressed: () => _showReportDialog(context),
            icon: const Icon(Icons.flag_outlined, size: 16),
            label: const Text('Reportar'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const Spacer(),
        if (!review.isPublic)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outlined,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Privada',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Reseña'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta reseña? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final reasons = [
      'Contenido inapropiado',
      'Spam o publicidad',
      'Información falsa',
      'Lenguaje ofensivo',
      'Otro',
    ];
    
    String? selectedReason;
    final otherController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reportar Reseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Por qué quieres reportar esta reseña?'),
              const SizedBox(height: 16),
              ...reasons.map((reason) => RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: selectedReason,
                onChanged: (value) {
                  setState(() {
                    selectedReason = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),),
              if (selectedReason == 'Otro') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: otherController,
                  decoration: const InputDecoration(
                    hintText: 'Describe el motivo...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: selectedReason != null
                  ? () {
                      final reason = selectedReason == 'Otro'
                          ? otherController.text.trim()
                          : selectedReason!;
                      
                      if (reason.isNotEmpty) {
                        Navigator.of(context).pop();
                        onReport?.call();
                        _submitReport(context, reason);
                      }
                    }
                  : null,
              child: const Text('Reportar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport(BuildContext context, String reason) async {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    
    final success = await reviewProvider.reportReview(review.id, reason);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Reporte enviado exitosamente'
                : 'Error al enviar el reporte',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> _getUserInfo(String userId) async {
    // Aquí deberías implementar la lógica para obtener la información del usuario
    // Por ahora retornamos datos de ejemplo
    return {
      'name': 'Usuario $userId',
      'photoURL': null,
    };
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ReviewModel>('review', review));
    properties.add(DiagnosticsProperty<bool>('showActions', showActions));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onEdit', onEdit));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onDelete', onDelete));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onReport', onReport));
    properties.add(DiagnosticsProperty<bool>('showUserInfo', showUserInfo));
    properties.add(DiagnosticsProperty<bool>('expandable', expandable));
  }
}

class _ExpandableComment extends StatefulWidget {

  const _ExpandableComment({required this.comment});
  final String comment;

  @override
  State<_ExpandableComment> createState() => _ExpandableCommentState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('comment', comment));
  }
}

class _ExpandableCommentState extends State<_ExpandableComment> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shouldTruncate = widget.comment.length > 200;
    final displayText = _isExpanded || !shouldTruncate
        ? widget.comment
        : '${widget.comment.substring(0, 200)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: theme.textTheme.bodyMedium,
        ),
        if (shouldTruncate) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Ver menos' : 'Ver más',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}