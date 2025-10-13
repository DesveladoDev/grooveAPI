import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class StatsCard extends StatelessWidget {

  const StatsCard({
    required this.title, required this.value, required this.icon, super.key,
    this.subtitle,
    this.iconColor,
    this.backgroundColor,
    this.trend,
    this.isPositiveTrend = true,
    this.onTap,
    this.isLoading = false,
  });
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? trend;
  final bool isPositiveTrend;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = backgroundColor ?? theme.colorScheme.surface;
    final iconBgColor = iconColor ?? theme.colorScheme.primary;
    
    return Card(
      elevation: 2,
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading ? _buildLoadingState() : _buildContent(context, theme, iconBgColor),
        ),
      ),
    );
  }

  Widget _buildLoadingState() => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(width: 12),
            Text('Cargando...'),
          ],
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 24,
          width: 80,
          child: LinearProgressIndicator(),
        ),
      ],
    );

  Widget _buildContent(BuildContext context, ThemeData theme, Color iconBgColor) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con icono y título
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconBgColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Valor principal
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        // Subtítulo y tendencia
        if (subtitle != null || trend != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (subtitle != null)
                Expanded(
                  child: Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (trend != null) _buildTrendIndicator(theme),
            ],
          ),
        ],
      ],
    );

  Widget _buildTrendIndicator(ThemeData theme) {
    final trendColor = isPositiveTrend ? Colors.green : Colors.red;
    final trendIcon = isPositiveTrend ? Icons.trending_up : Icons.trending_down;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            size: 14,
            color: trendColor,
          ),
          const SizedBox(width: 4),
          Text(
            trend!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: trendColor,
              fontWeight: FontWeight.w600,
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
    properties.add(StringProperty('subtitle', subtitle));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(ColorProperty('iconColor', iconColor));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(StringProperty('trend', trend));
    properties.add(DiagnosticsProperty<bool>('isPositiveTrend', isPositiveTrend));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
  }
}

class StatsGrid extends StatelessWidget {

  const StatsGrid({
    required this.stats, super.key,
    this.isLoading = false,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.5,
  });
  final List<StatsCardData> stats;
  final bool isLoading;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) => GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return StatsCard(
          title: stat.title,
          value: stat.value,
          subtitle: stat.subtitle,
          icon: stat.icon,
          iconColor: stat.iconColor,
          backgroundColor: stat.backgroundColor,
          trend: stat.trend,
          isPositiveTrend: stat.isPositiveTrend,
          onTap: stat.onTap,
          isLoading: isLoading,
        );
      },
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<StatsCardData>('stats', stats));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
    properties.add(IntProperty('crossAxisCount', crossAxisCount));
    properties.add(DoubleProperty('childAspectRatio', childAspectRatio));
  }
}

class StatsCardData {

  const StatsCardData({
    required this.title,
    required this.value,
    required this.icon, this.subtitle,
    this.iconColor,
    this.backgroundColor,
    this.trend,
    this.isPositiveTrend = true,
    this.onTap,
  });
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? trend;
  final bool isPositiveTrend;
  final VoidCallback? onTap;
}

// Utilidades para formatear valores
class StatsFormatter {
  static String formatCurrency(double amount, {String symbol = r'$'}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 0);
    return formatter.format(amount);
  }

  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  static String formatPercentage(double percentage) => '${percentage.toStringAsFixed(1)}%';
}