import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:salas_beats/models/booking_model.dart';
import 'package:salas_beats/models/listing_model.dart';
import 'package:salas_beats/utils/app_routes.dart';

class ListingDetailScreen extends StatefulWidget {
  
  const ListingDetailScreen({
    required this.listingId, super.key,
  });
  final String listingId;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('listingId', listingId));
  }
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _showAllAmenities = false;
  bool _showAllRules = false;
  
  // Mock data - en producción vendría de Firestore
  late ListingModel _listing;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadListing();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _loadListing() {
    // Mock data - en producción se cargaría desde Firestore usando widget.listingId
    _listing = ListingModel(
      id: widget.listingId,
      hostId: 'host1',
      title: 'Estudio de Grabación Pro',
      description: 'Estudio profesional completamente equipado con tecnología de vanguardia. Perfecto para grabaciones profesionales, mezcla y masterización. Ubicado en el corazón de Roma Norte con fácil acceso y estacionamiento disponible.',
      photos: [
        'https://example.com/studio1.jpg',
        'https://example.com/studio2.jpg',
        'https://example.com/studio3.jpg',
        'https://example.com/studio4.jpg',
      ],
      videoUrl: 'https://example.com/studio_tour.mp4',
      amenities: [
        'Micrófono profesional Neumann U87',
        'Mesa de mezclas SSL',
        'Monitores de estudio Genelec',
        'Cabina aislada acústicamente',
        'Piano de cola Steinway',
        'Amplificadores Marshall',
        'Batería Pearl Reference',
        'Pro Tools HDX',
        'Aire acondicionado',
        'WiFi de alta velocidad',
        'Estacionamiento gratuito',
        'Servicio de café',
      ],
      capacity: 8,
      hourlyPrice: 450,
      rules: [
        'No fumar dentro del estudio',
        'Máximo 8 personas simultáneamente',
        'Respetar los horarios de reserva',
        'Cuidar el equipo profesional',
        'No consumir alimentos cerca del equipo',
        'Mantener el volumen en niveles seguros',
        'Limpiar después del uso',
      ],
      location: LocationData(
        lat: 19.4326,
        lng: -99.1332,
        address: 'Calle Álvaro Obregón 185, Roma Norte',
        city: 'Ciudad de México',
      ),
      cancellationPolicy: CancellationPolicy.flexible,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }
  
  void _navigateToBooking() {
    Navigator.of(context).pushNamed(
      AppRoutes.booking,
      arguments: _listing.id,
    );
  }
  
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    // TODO: Implementar lógica de favoritos en Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite 
              ? 'Agregado a favoritos' 
              : 'Removido de favoritos',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _contactHost() {
    Navigator.of(context).pushNamed(
      AppRoutes.chatList,
      arguments: {
        'hostId': _listing.hostId,
        'listingId': _listing.id,
      },
    );
  }
  
  void _shareListing() {
    // TODO: Implementar compartir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir próximamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _reportListing() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar listing'),
        content: const Text(
          '¿Hay algo inapropiado en este listing? Nuestro equipo lo revisará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reporte enviado. Gracias por tu feedback.'),
                ),
              );
            },
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 20),
                  _buildDescription(theme),
                  const SizedBox(height: 24),
                  _buildAmenities(theme),
                  const SizedBox(height: 24),
                  _buildLocation(theme),
                  const SizedBox(height: 24),
                  _buildRules(theme),
                  const SizedBox(height: 24),
                  _buildCancellationPolicy(theme),
                  const SizedBox(height: 24),
                  _buildHostInfo(theme),
                  const SizedBox(height: 100), // Espacio para el botón flotante
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildBookingButton(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  Widget _buildSliverAppBar(ThemeData theme) => SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: _shareListing,
            icon: const Icon(Icons.share, color: Colors.white),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
          ),
        ),
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.more_vert, color: Colors.white),
          ),
          onSelected: (value) {
            if (value == 'report') {
              _reportListing();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag),
                  SizedBox(width: 8),
                  Text('Reportar'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Galería de imágenes
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: _listing.photos.length,
              itemBuilder: (context, index) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.3),
                        theme.colorScheme.secondary.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.music_note,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
            ),
            
            // Indicadores de página
            if (_listing.photos.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _listing.photos.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  
  Widget _buildHeader(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _listing.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${_listing.hourlyPrice.toInt()}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'por hora',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _listing.location.address,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Icon(
              Icons.people_outlined,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              'Hasta ${_listing.capacity} personas',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 16),
            const Icon(
              Icons.star,
              size: 16,
              color: Colors.amber,
            ),
            const SizedBox(width: 4),
            Text(
              '4.8 (24 reseñas)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  
  Widget _buildDescription(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _listing.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  
  Widget _buildAmenities(ThemeData theme) {
    final displayedAmenities = _showAllAmenities 
        ? _listing.amenities 
        : _listing.amenities.take(6).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenidades',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: displayedAmenities.map((amenity) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getAmenityIcon(amenity),
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    amenity,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),).toList(),
        ),
        
        if (_listing.amenities.length > 6)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showAllAmenities = !_showAllAmenities;
                });
              },
              child: Text(
                _showAllAmenities 
                    ? 'Mostrar menos' 
                    : 'Ver todas (${_listing.amenities.length})',
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildLocation(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 8),
              Text(
                'Mapa interactivo',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _listing.location.address,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Abrir en Google Maps
                },
                icon: const Icon(Icons.directions),
                label: const Text('Cómo llegar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _contactHost,
                icon: const Icon(Icons.message),
                label: const Text('Contactar'),
              ),
            ),
          ],
        ),
      ],
    );
  
  Widget _buildRules(ThemeData theme) {
    final displayedRules = _showAllRules 
        ? _listing.rules 
        : _listing.rules.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reglas del espacio',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...displayedRules.map((rule) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rule,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),),
        
        if (_listing.rules.length > 3)
          TextButton(
            onPressed: () {
              setState(() {
                _showAllRules = !_showAllRules;
              });
            },
            child: Text(
              _showAllRules 
                  ? 'Mostrar menos' 
                  : 'Ver todas las reglas (${_listing.rules.length})',
            ),
          ),
      ],
    );
  }
  
  Widget _buildCancellationPolicy(ThemeData theme) {
    String policyText;
    IconData policyIcon;
    Color policyColor;
    
    switch (_listing.cancellationPolicy) {
      case 'flexible':
        policyText = 'Cancelación flexible: Reembolso completo hasta 24 horas antes';
        policyIcon = Icons.check_circle;
        policyColor = Colors.green;
        break;
      case 'moderate':
        policyText = 'Cancelación moderada: Reembolso del 50% hasta 48 horas antes';
        policyIcon = Icons.info;
        policyColor = Colors.orange;
        break;
      case 'strict':
        policyText = 'Cancelación estricta: Sin reembolso después de la confirmación';
        policyIcon = Icons.warning;
        policyColor = Colors.red;
        break;
      default:
        policyText = 'Política de cancelación no especificada';
        policyIcon = Icons.help;
        policyColor = Colors.grey;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Política de cancelación',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: policyColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: policyColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                policyIcon,
                color: policyColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  policyText,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildHostInfo(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anfitrión',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carlos Mendoza',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.9 • Anfitrión desde 2022',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _contactHost,
                child: const Text('Contactar'),
              ),
            ],
          ),
        ),
      ],
    );
  
  Widget _buildBookingButton(ThemeData theme) => Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: _navigateToBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 8),
            Text(
              'Reservar ahora',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  
  /// Maps amenity names to appropriate Material Design icons
  /// 
  /// This method provides visual representation for common studio amenities
  /// by matching keywords in the amenity name to relevant icons.
  /// 
  /// [amenity] - The amenity name to map to an icon
  /// 
  /// Returns the most appropriate [IconData] for the amenity,
  /// defaulting to [Icons.check_circle] if no specific match is found
  IconData _getAmenityIcon(String amenity) {
    // Convert to lowercase for case-insensitive matching
    final amenityLower = amenity.toLowerCase();
    
    // Define amenity-to-icon mappings
    const amenityIconMap = <String, IconData>{
      'micrófono': Icons.mic,
      'micro': Icons.mic,
      'piano': Icons.piano,
      'batería': Icons.album,
      'amplificador': Icons.speaker,
      'wifi': Icons.wifi,
      'estacionamiento': Icons.local_parking,
      'aire': Icons.ac_unit,
      'clima': Icons.ac_unit,
      'café': Icons.local_cafe,
      'monitor': Icons.speaker_group,
      'cabina': Icons.meeting_room,
    };
    
    // Find matching icon by checking if amenity contains any keyword
    for (final entry in amenityIconMap.entries) {
      if (amenityLower.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Default icon for unmatched amenities
    return Icons.check_circle;
  }
}