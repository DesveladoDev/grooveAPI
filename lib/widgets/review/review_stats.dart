import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:salas_beats/models/review_model.dart';
import 'package:salas_beats/widgets/review/rating_input.dart';

class ReviewStats extends StatelessWidget {

  const ReviewStats({
    required this.reviews, super.key,
    this.stats,
    this.showDetailed = true,
  });
  final Map<String, dynamic>? stats;
  final List<ReviewModel> reviews;
  final bool showDetailed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (reviews.isEmpty && (stats == null || stats!['totalReviews'] == 0)) {
      return _buildEmptyStats(theme);
    }

    final totalReviews = (stats?['totalReviews'] ?? reviews.length) as int;
    final averageRating = (stats?['averageRating'] ?? _calculateAverageRating()) as double;
    final ratingDistribution = (stats?['ratingDistribution'] ?? _calculateRatingDistribution()) as Map<int, int>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con rating promedio
          _buildStatsHeader(theme, averageRating, totalReviews),
          
          if (showDetailed && totalReviews > 0) ...[
            const SizedBox(height: 20),
            // Distribución de ratings
            _buildRatingDistribution(theme, ratingDistribution, totalReviews),
            
            const SizedBox(height: 20),
            // Estadísticas adicionales
            _buildAdditionalStats(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyStats(ThemeData theme) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.star_outline,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Sin reseñas aún',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Las reseñas aparecerán aquí cuando estén disponibles',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

  Widget _buildStatsHeader(ThemeData theme, double averageRating, int totalReviews) => Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'de 5',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RatingDisplay(
                rating: averageRating,
                size: 20,
                showText: false,
              ),
              const SizedBox(height: 8),
              Text(
                '$totalReviews ${totalReviews == 1 ? 'reseña' : 'reseñas'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.star,
            size: 32,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );

  Widget _buildRatingDistribution(ThemeData theme, Map<int, int> distribution, int totalReviews) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribución de Calificaciones',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(5, (index) {
          final rating = 5 - index; // Mostrar de 5 a 1
          final count = distribution[rating] ?? 0;
          final percentage = totalReviews > 0 ? count / totalReviews : 0.0;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _RatingBar(
              rating: rating,
              count: count,
              percentage: percentage,
            ),
          );
        }),
      ],
    );

  Widget _buildAdditionalStats(ThemeData theme) {
    final recentReviews = reviews.where((review) {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      return review.createdAt.isAfter(thirtyDaysAgo);
    }).length;

    final averageCommentLength = reviews.isNotEmpty
        ? reviews.map((r) => r.comment.length).reduce((a, b) => a + b) / reviews.length
        : 0.0;

    final publicReviews = reviews.where((r) => r.isPublic).length;
    final privateReviews = reviews.length - publicReviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas Adicionales',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Últimos 30 días',
                value: recentReviews.toString(),
                icon: Icons.schedule,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Públicas',
                value: publicReviews.toString(),
                icon: Icons.public,
                color: Colors.green,
              ),
            ),
          ],
        ),
        if (privateReviews > 0) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Privadas',
                  value: privateReviews.toString(),
                  icon: Icons.lock,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Promedio palabras',
                  value: (averageCommentLength / 5).round().toString(),
                  icon: Icons.text_fields,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  double _calculateAverageRating() {
    if (reviews.isEmpty) return 0;
    final totalRating = reviews.map((r) => r.rating).reduce((a, b) => a + b);
    return totalRating / reviews.length;
  }

  Map<int, int> _calculateRatingDistribution() {
    final distribution = <int, int>{};
    for (var i = 1; i <= 5; i++) {
      distribution[i] = reviews.where((r) => r.rating == i).length;
    }
    return distribution;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Map<String, dynamic>?>('stats', stats));
    properties.add(IterableProperty<ReviewModel>('reviews', reviews));
    properties.add(DiagnosticsProperty<bool>('showDetailed', showDetailed));
  }
}

class _RatingBar extends StatelessWidget {

  const _RatingBar({
    required this.rating,
    required this.count,
    required this.percentage,
  });
  final int rating;
  final int count;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Text(
          '$rating',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.star,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: _getRatingColor(rating),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 30,
          child: Text(
            '$count',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.deepOrange;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('rating', rating));
    properties.add(IntProperty('count', count));
    properties.add(DoubleProperty('percentage', percentage));
  }
}

class _StatCard extends StatelessWidget {

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('value', value));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(ColorProperty('color', color));
  }
}