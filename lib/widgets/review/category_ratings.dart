import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/widgets/review/rating_input.dart';

class CategoryRatings extends StatelessWidget {

  const CategoryRatings({
    required this.ratings, required this.onRatingsChanged, super.key,
    this.enabled = true,
    this.categories,
  });
  final Map<String, int> ratings;
  final Function(Map<String, int>) onRatingsChanged;
  final bool enabled;
  final List<String>? categories;

  static const List<String> defaultCategories = [
    'Limpieza',
    'Comunicación',
    'Ubicación',
    'Precio/Calidad',
  ];

  static const Map<String, IconData> categoryIcons = {
    'Limpieza': Icons.cleaning_services,
    'Comunicación': Icons.chat_bubble_outline,
    'Ubicación': Icons.location_on_outlined,
    'Precio/Calidad': Icons.attach_money,
    'Comodidad': Icons.bed_outlined,
    'Seguridad': Icons.security_outlined,
    'Servicios': Icons.room_service_outlined,
    'Experiencia': Icons.star_outline,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesToShow = categories ?? defaultCategories;

    return Column(
      children: categoriesToShow.map((category) {
        final currentRating = ratings[category] ?? 5;
        final icon = categoryIcons[category] ?? Icons.star_outline;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RatingInput(
                        rating: currentRating,
                        onRatingChanged: enabled
                            ? (rating) {
                                final newRatings = Map<String, int>.from(ratings);
                                newRatings[category] = rating;
                                onRatingsChanged(newRatings);
                              }
                            : (_) {},
                        size: 24,
                        enabled: enabled,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Map<String, int>>('ratings', ratings));
    properties.add(ObjectFlagProperty<Function(Map<String, int> p1)>.has('onRatingsChanged', onRatingsChanged));
    properties.add(DiagnosticsProperty<bool>('enabled', enabled));
    properties.add(IterableProperty<String>('categories', categories));
  }
}

class CategoryRatingsDisplay extends StatelessWidget {

  const CategoryRatingsDisplay({
    required this.ratings, super.key,
    this.showAverages = false,
    this.iconSize = 16,
    this.starSize = 14,
  });
  final Map<String, int> ratings;
  final bool showAverages;
  final double iconSize;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (ratings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showAverages) ...[
          Text(
            'Calificaciones Detalladas',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...ratings.entries.map((entry) {
          final category = entry.key;
          final rating = entry.value;
          final icon = CategoryRatings.categoryIcons[category] ?? Icons.star_outline;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final isActive = index < rating;
                    return Icon(
                      isActive ? Icons.star : Icons.star_border,
                      size: starSize,
                      color: isActive ? Colors.amber : theme.colorScheme.outline,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  rating.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Map<String, int>>('ratings', ratings));
    properties.add(DiagnosticsProperty<bool>('showAverages', showAverages));
    properties.add(DoubleProperty('iconSize', iconSize));
    properties.add(DoubleProperty('starSize', starSize));
  }
}

class CategoryRatingsSummary extends StatelessWidget {

  const CategoryRatingsSummary({
    required this.allRatings, super.key,
    this.title = 'Promedio por Categoría',
  });
  final List<Map<String, int>> allRatings;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final averages = _calculateAverages();

    if (averages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...averages.entries.map((entry) {
          final category = entry.key;
          final average = entry.value;
          final icon = CategoryRatings.categoryIcons[category] ?? Icons.star_outline;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRatingColor(average, theme),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    average.toStringAsFixed(1),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Map<String, double> _calculateAverages() {
    if (allRatings.isEmpty) return {};

    final categoryValues = <String, List<int>>{};
    
    // Recopilar todos los valores por categoría
    for (final ratings in allRatings) {
      for (final entry in ratings.entries) {
        categoryValues.putIfAbsent(entry.key, () => []).add(entry.value);
      }
    }

    // Calcular promedios
    final averages = <String, double>{};
    for (final entry in categoryValues.entries) {
      final values = entry.value;
      final average = values.reduce((a, b) => a + b) / values.length;
      averages[entry.key] = average;
    }

    return averages;
  }

  Color _getRatingColor(double rating, ThemeData theme) {
    if (rating >= 4.5) {
      return Colors.green;
    } else if (rating >= 3.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<Map<String, int>>('allRatings', allRatings));
    properties.add(StringProperty('title', title));
  }
}