import 'package:flutter/material.dart';

class BookingHeatmap extends StatelessWidget {
  const BookingHeatmap({super.key, required this.data});

  /// Map of day (yyyy-mm-dd) to booking count
  final Map<DateTime, int> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    int maxCount = 1;
    for (int d = 1; d <= daysInMonth; d++) {
      final dt = DateTime(now.year, now.month, d);
      final c = data[DateTime(dt.year, dt.month, dt.day)] ?? 0;
      if (c > maxCount) maxCount = c;
    }

    Color colorFor(int count) {
      final t = count / (maxCount == 0 ? 1 : maxCount);
      return Color.lerp(theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.primary, t) ?? theme.colorScheme.primary;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actividad de reservas (mes actual)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildWeekdayHeader(theme),
            const SizedBox(height: 8),
            _buildGrid(start, daysInMonth, colorFor),
            const SizedBox(height: 8),
            _buildLegend(theme, maxCount),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader(ThemeData theme) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildGrid(DateTime start, int daysInMonth, Color Function(int) colorFor) {
    final firstWeekday = start.weekday % 7; // 0..6 with 0 as Sunday? Adjust
    final cells = <Widget>[];

    // Add leading empty cells
    for (int i = 1; i < firstWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (int d = 1; d <= daysInMonth; d++) {
      final dt = DateTime(start.year, start.month, d);
      final count = data[DateTime(dt.year, dt.month, dt.day)] ?? 0;
      cells.add(Container(
        margin: const EdgeInsets.all(2),
        height: 28,
        decoration: BoxDecoration(
          color: colorFor(count),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            '$d',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  Widget _buildLegend(ThemeData theme, int maxCount) {
    return Row(
      children: [
        _legendBox(theme.colorScheme.primary.withOpacity(0.1)),
        const SizedBox(width: 6),
        _legendBox(Color.lerp(theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.primary, 0.5) ?? theme.colorScheme.primary),
        const SizedBox(width: 6),
        _legendBox(theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text('Menos → Más reservas', style: theme.textTheme.labelMedium),
      ],
    );
  }

  Widget _legendBox(Color color) => Container(
        width: 20,
        height: 12,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      );
}