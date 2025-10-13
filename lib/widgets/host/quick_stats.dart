import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/config/constants.dart';
import 'package:salas_beats/providers/booking_provider.dart';
import 'package:salas_beats/providers/listing_provider.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({super.key});
  
  @override
  Widget build(BuildContext context) => Consumer2<ListingProvider, BookingProvider>(
      builder: (context, listingProvider, bookingProvider, child) => Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estadísticas rápidas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultSpacing),
                
                // Primera fila de estadísticas
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.home_work,
                        label: 'Listados',
                        value: listingProvider.hostListings.length.toString(),
                        color: Colors.blue,
                        subtitle: _getActiveListingsText(listingProvider),
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultSpacing),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.calendar_today,
                        label: 'Reservas',
                        value: bookingProvider.hostBookings.length.toString(),
                        color: Colors.green,
                        subtitle: 'Este mes',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultSpacing),
                
                // Segunda fila de estadísticas
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.star,
                        label: 'Calificación',
                        value: _getAverageRating(listingProvider),
                        color: Colors.orange,
                        subtitle: 'Promedio',
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultSpacing),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.visibility,
                        label: 'Vistas',
                        value: _getTotalViews(listingProvider),
                        color: Colors.purple,
                        subtitle: 'Total',
                      ),
                    ),
                  ],
                ),
                
                // Indicadores de rendimiento
                const SizedBox(height: AppConstants.defaultSpacing),
                _buildPerformanceIndicators(context, listingProvider),
              ],
            ),
          ),
        ),
    );
  
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? subtitle,
  }) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  
  Widget _buildPerformanceIndicators(
    BuildContext context,
    ListingProvider listingProvider,
  ) {
    final activeListings = listingProvider.hostListings
        .where((listing) => listing.active)
        .length;
    final totalListings = listingProvider.hostListings.length;
    final activePercentage = totalListings > 0 
        ? (activeListings / totalListings) * 100 
        : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rendimiento',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        
        // Indicador de listados activos
        _buildProgressIndicator(
          context,
          label: 'Listados activos',
          value: activePercentage,
          color: Colors.green,
          subtitle: '$activeListings de $totalListings activos',
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        
        // Indicador de ocupación (mock)
        _buildProgressIndicator(
          context,
          label: 'Tasa de ocupación',
          value: 0, // TODO: Calcular tasa real
          color: Colors.blue,
          subtitle: 'Este mes',
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        
        // Indicador de respuesta (mock)
        _buildProgressIndicator(
          context,
          label: 'Tiempo de respuesta',
          value: 85, // Mock value
          color: Colors.orange,
          subtitle: 'Promedio: 2 horas',
        ),
      ],
    );
  }
  
  Widget _buildProgressIndicator(
    BuildContext context, {
    required String label,
    required double value,
    required Color color,
    String? subtitle,
  }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  
  // Métodos auxiliares
  String _getActiveListingsText(ListingProvider provider) {
    final active = provider.hostListings
        .where((listing) => listing.active)
        .length;
    final total = provider.hostListings.length;
    return '$active de $total activos';
  }
  
  String _getAverageRating(ListingProvider provider) {
    if (provider.hostListings.isEmpty) return '0.0';
    
    double totalRating = 0;
    var ratedListings = 0;
    
    for (final listing in provider.hostListings) {
      if (listing.rating > 0) {
        totalRating += listing.rating;
        ratedListings++;
      }
    }
    
    if (ratedListings == 0) return '0.0';
    
    final average = totalRating / ratedListings;
    return average.toStringAsFixed(1);
  }
  
  String _getTotalViews(ListingProvider provider) {
    var totalViews = 0;
    for (final listing in provider.hostListings) {
      // totalViews += listing.viewCount; // viewCount no está disponible en ListingModel
      totalViews += 0; // Placeholder hasta implementar viewCount
    }
    
    if (totalViews >= 1000) {
      return '${(totalViews / 1000).toStringAsFixed(1)}k';
    }
    
    return totalViews.toString();
  }
}

// Widget compacto para usar en otras pantallas
class CompactQuickStats extends StatelessWidget {
  const CompactQuickStats({super.key});
  
  @override
  Widget build(BuildContext context) => Consumer2<ListingProvider, BookingProvider>(
      builder: (context, listingProvider, bookingProvider, child) => Row(
          children: [
            Expanded(
              child: _buildCompactStat(
                context,
                icon: Icons.home_work,
                value: listingProvider.hostListings.length.toString(),
                label: 'Listados',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: AppConstants.smallSpacing),
            Expanded(
              child: _buildCompactStat(
                context,
                icon: Icons.calendar_today,
                value: bookingProvider.hostBookings.length.toString(),
                label: 'Reservas',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: AppConstants.smallSpacing),
            Expanded(
              child: _buildCompactStat(
                context,
                icon: Icons.star,
                value: _getAverageRating(listingProvider),
                label: 'Rating',
                color: Colors.orange,
              ),
            ),
          ],
        ),
    );
  
  Widget _buildCompactStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  
  String _getAverageRating(ListingProvider provider) {
    if (provider.hostListings.isEmpty) return '0.0';
    
    double totalRating = 0;
    var ratedListings = 0;
    
    for (final listing in provider.hostListings) {
      if (listing.rating > 0) {
        totalRating += listing.rating;
        ratedListings++;
      }
    }
    
    if (ratedListings == 0) return '0.0';
    
    final average = totalRating / ratedListings;
    return average.toStringAsFixed(1);
  }
}