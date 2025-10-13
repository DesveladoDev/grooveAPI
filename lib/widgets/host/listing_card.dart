import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/models/listing_model.dart';
import 'package:salas_beats/utils/app_routes.dart';

class ListingCard extends StatelessWidget {
  
  const ListingCard({
    required this.listing, super.key,
    this.onTap,
    this.onEdit,
    this.onToggleStatus,
    this.compact = false,
    this.showActions = true,
  });
  final ListingModel listing;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final bool compact;
  final bool showActions;
  
  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del listado
            _buildListingImage(),
            
            // Contenido del listado
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con título y estado
                  _buildHeader(context),
                  const SizedBox(height: 8),
                  
                  // Descripción
                  if (!compact) ...[
                    Text(
                      listing.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Información del listado
                  _buildListingInfo(context),
                  
                  // Estadísticas
                  if (!compact) ...[
                    const SizedBox(height: 12),
                    _buildStats(context),
                  ],
                  
                  // Acciones
                  if (showActions) ...[
                    const SizedBox(height: 16),
                    _buildActions(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  
  Widget _buildListingImage() => Stack(
      children: [
        // Imagen principal
        Container(
          height: compact ? 120 : 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            image: listing.photos.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(listing.photos.first),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: listing.photos.isEmpty
              ? Icon(
                  Icons.image,
                  size: 48,
                  color: Colors.grey[400],
                )
              : null,
        ),
        
        // Badge de estado
        Positioned(
          top: 12,
          right: 12,
          child: _buildStatusBadge(),
        ),
        
        // Contador de imágenes
        if (listing.photos.length > 1)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    listing.photos.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  
  Widget _buildStatusBadge() {
    final isActive = listing.active;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) => Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${listing.location.city}, ${listing.location.state}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${listing.hourlyPrice.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              'por hora',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  
  Widget _buildListingInfo(BuildContext context) => Row(
      children: [
        // Tipo de estudio
        _buildInfoChip(
          icon: Icons.music_note,
          label: _getStudioTypeLabel(listing.studioType),
        ),
        const SizedBox(width: 8),
        
        // Capacidad
        _buildInfoChip(
          icon: Icons.people,
          label: '${listing.capacity} personas',
        ),
        const SizedBox(width: 8),
        
        // Rating
        if (listing.rating > 0)
          _buildInfoChip(
            icon: Icons.star,
            label: listing.rating.toStringAsFixed(1),
            color: Colors.orange,
          ),
      ],
    );
  
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final chipColor = color ?? Colors.grey[600]!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStats(BuildContext context) => Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.visibility,
            label: 'Vistas',
            value: '0', // viewCount no disponible
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.calendar_today,
            label: 'Reservas',
            value: '0', // bookingCount no disponible
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.favorite,
            label: 'Favoritos',
            value: '0', // favoriteCount no disponible
          ),
        ),
      ],
    );
  
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) => Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  
  Widget _buildActions(BuildContext context) => Row(
      children: [
        // Botón de editar
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Editar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Botón de toggle estado
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onToggleStatus,
            icon: Icon(
              listing.active ? Icons.pause : Icons.play_arrow,
              size: 18,
            ),
            label: Text(listing.active ? 'Pausar' : 'Activar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: listing.active ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        
        // Botón de menú
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Ver detalles'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Duplicar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'analytics',
              child: ListTile(
                leading: Icon(Icons.analytics),
                title: Text('Estadísticas'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.more_vert,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  
  // Métodos auxiliares
  String _getStudioTypeLabel(String? type) {
    switch (type) {
      case 'ensayo':
        return 'Ensayo';
      case 'grabacion':
        return 'Grabación';
      case 'mixto':
        return 'Mixto';
      default:
        return 'Estudio';
    }
  }
  
  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'view':
        Navigator.of(context).pushNamed(
          AppRoutes.listingDetail,
          arguments: listing.id,
        );
        break;
      case 'duplicate':
        _showDuplicateDialog(context);
        break;
      case 'analytics':
        // TODO: Implementar ruta de analytics
        // Navigator.of(context).pushNamed(
        //   AppRoutes.listingAnalytics,
        //   arguments: listing.id,
        // );
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }
  
  void _showDuplicateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicar listado'),
        content: Text(
          '¿Deseas crear una copia de "${listing.title}"? '
          'Podrás editarla antes de publicarla.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar duplicación
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listado duplicado exitosamente'),
                ),
              );
            },
            child: const Text('Duplicar'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar listado'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${listing.title}"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar eliminación
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listado eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ListingModel>('listing', listing));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onEdit', onEdit));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onToggleStatus', onToggleStatus));
    properties.add(DiagnosticsProperty<bool>('compact', compact));
    properties.add(DiagnosticsProperty<bool>('showActions', showActions));
  }
}

// Widget compacto para listas horizontales
class CompactListingCard extends StatelessWidget {
  
  const CompactListingCard({
    required this.listing, super.key,
    this.onTap,
  });
  final ListingModel listing;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) => Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: ListingCard(
        listing: listing,
        onTap: onTap,
        compact: true,
        showActions: false,
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ListingModel>('listing', listing));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
  }
}