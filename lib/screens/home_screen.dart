import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:salas_beats/models/listing_model.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/services/localization_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedCity = 'All';
  double _maxPrice = 1000;
  final List<String> _selectedAmenities = [];
  
  @override
  void initState() {
    super.initState();
    print('🏠 HomeScreen: initState llamado');
    print('🏠 HomeScreen: Pantalla Home inicializándose correctamente');
  }
  
  // Mock data - en producción vendría de Firestore
  final List<ListingModel> _mockListings = [
    ListingModel(
      id: '1',
      hostId: 'host1',
      title: 'Estudio de Grabación Pross',
      description: 'Estudio profesional con equipos de alta gama para grabación y mezcla.',
      photos: ['https://example.com/studio1.jpg'],
      amenities: ['Micrófono profesional', 'Mesa de mezclas', 'Monitores de estudio', 'Cabina aislada'],
      capacity: 6,
      hourlyPrice: 450,
      rules: ['No fumar', 'Máximo 6 personas'],
      location: LocationData(
        lat: 19.4326,
        lng: -99.1332,
        address: 'Roma Norte, CDMX',
        city: 'Ciudad de México',
      ),
      cancellationPolicy: CancellationPolicy.flexible,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ListingModel(
      id: '2',
      hostId: 'host2',
      title: 'Sala de Ensayo Rock',
      description: 'Perfecta para bandas de rock. Amplificadores y batería incluidos.',
      photos: ['https://example.com/studio2.jpg'],
      amenities: ['Batería completa', 'Amplificadores', 'Micrófonos', 'Sistema de sonido'],
      capacity: 5,
      hourlyPrice: 280,
      rules: ['Respetar horarios', 'Cuidar el equipo'],
      location: LocationData(
        lat: 19.3910,
        lng: -99.2837,
        address: 'Condesa, CDMX',
        city: 'Ciudad de México',
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ListingModel(
      id: '3',
      hostId: 'host3',
      title: 'Estudio Acústico',
      description: 'Ideal para grabaciones acústicas y sesiones íntimas.',
      photos: ['https://example.com/studio3.jpg'],
      amenities: ['Piano de cola', 'Guitarra acústica', 'Micrófono de condensador', 'Tratamiento acústico'],
      capacity: 3,
      hourlyPrice: 350,
      rules: ['Solo instrumentos acústicos', 'Máximo 3 personas'],
      location: LocationData(
        lat: 19.4284,
        lng: -99.1276,
        address: 'Polanco, CDMX',
        city: 'Ciudad de México',
      ),
      cancellationPolicy: CancellationPolicy.strict,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
  
  final List<String> _cities = ['All', 'Ciudad de México', 'Guadalajara', 'Monterrey'];
  final List<String> _availableAmenities = [
    'Micrófono profesional',
    'Mesa de mezclas',
    'Monitores de estudio',
    'Batería completa',
    'Amplificadores',
    'Piano',
    'Guitarra',
    'Cabina aislada',
    'Sistema de sonido',
    'Tratamiento acústico',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ListingModel> get _filteredListings => _mockListings.where((listing) {
      // Filtro por búsqueda
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          listing.title.toLowerCase().contains(searchQuery) ||
          listing.description.toLowerCase().contains(searchQuery) ||
          listing.location.address.toLowerCase().contains(searchQuery);
      
      // Filtro por ciudad
      final matchesCity = _selectedCity == 'All' || listing.location.city == _selectedCity;
      
      // Filtro por precio
      final matchesPrice = listing.hourlyPrice <= _maxPrice;
      
      // Filtro por amenidades
      final matchesAmenities = _selectedAmenities.isEmpty ||
          _selectedAmenities.every((amenity) => listing.amenities.contains(amenity));
      
      return matchesSearch && matchesCity && matchesPrice && matchesAmenities;
    }).toList();

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFiltersSheet(),
    );
  }

  void _navigateToListing(ListingModel listing) {
    Navigator.of(context).pushNamed(
      AppRoutes.listingDetail,
      arguments: listing.id,
    );
  }

  void _navigateToExplore() {
    Navigator.of(context).pushNamed(AppRoutes.explore);
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 HomeScreen: build() llamado');
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    print('🏠 HomeScreen: Usuario actual: ${user?.name ?? 'Usuario'}');
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header con saludo y búsqueda
            _buildHeader(theme, user?.name ?? 'Usuario'),
            
            // Barra de búsqueda y filtros
            _buildSearchBar(theme),
            
            // Lista de salas
            Expanded(
              child: _buildListingsList(theme),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(theme),
    );
  }

  Widget _buildHeader(ThemeData theme, String userName) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.hello(userName),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.findPerfectSpace,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              // Avatar y notificaciones
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.notifications);
                    },
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.profile);
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

  Widget _buildSearchBar(ThemeData theme) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: context.l10n.searchPlaceholder,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _showFilters,
              icon: const Icon(
                Icons.tune,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildListingsList(ThemeData theme) {
    final filteredListings = _filteredListings;
    
    if (filteredListings.isEmpty) {
      return _buildEmptyState(theme);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredListings.length,
      itemBuilder: (context, index) => _buildListingCard(filteredListings[index], theme),
    );
  }

  Widget _buildListingCard(ListingModel listing, ThemeData theme) => Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToListing(listing),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Stack(
                children: [
                  // Placeholder para imagen
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.3),
                          theme.colorScheme.secondary.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  
                  // Botón de favorito
                  Positioned(
                    top: 12,
                    right: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          print("Hola");
                        },
                        icon: const Icon(
                          Icons.favorite_border,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Información
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y precio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        context.l10n.pricePerHour(listing.hourlyPrice.toInt()),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Ubicación
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
                          listing.location.address,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Capacidad y rating
                  Row(
                    children: [
                      Icon(
                        Icons.people_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.upToCapacity(listing.capacity),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.8 (24)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Amenidades (primeras 3)
                  Wrap(
                    spacing: 8,
                    children: listing.amenities.take(3).map((amenity) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          amenity,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildEmptyState(ThemeData theme) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noRoomsFound,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.adjustFiltersMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedCity = 'All';
                  _maxPrice = 1000;
                  _selectedAmenities.clear();
                });
              },
              child: Text(context.l10n.clearFilters),
            ),
          ],
        ),
      ),
    );

  Widget _buildFiltersSheet() => StatefulBuilder(
      builder: (context, setModalState) {
        final theme = Theme.of(context);
        
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.filters,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedCity = 'All';
                        _maxPrice = 1000;
                        _selectedAmenities.clear();
                      });
                    },
                    child: Text(context.l10n.clear),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Ciudad
              Text(
                context.l10n.city,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _cities.map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city == 'All' ? context.l10n.all : city),
                  ),).toList(),
                onChanged: (value) {
                  setModalState(() {
                    _selectedCity = value!;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Precio máximo
              Text(
                context.l10n.maxPricePerHour(_maxPrice.toInt()),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                value: _maxPrice,
                min: 100,
                max: 1000,
                divisions: 18,
                onChanged: (value) {
                  setModalState(() {
                    _maxPrice = value;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Amenidades
              Text(
                context.l10n.amenities,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableAmenities.map((amenity) {
                  final isSelected = _selectedAmenities.contains(amenity);
                  return FilterChip(
                    label: Text(amenity),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        if (selected) {
                          _selectedAmenities.add(amenity);
                        } else {
                          _selectedAmenities.remove(amenity);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Botón aplicar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Actualizar la lista principal
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.applyFilters,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );

  Widget _buildBottomNavBar(ThemeData theme) => BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0, // Home está activo
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: context.l10n.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.explore),
          label: context.l10n.explore,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today),
          label: context.l10n.bookings,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat),
          label: context.l10n.messages,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: context.l10n.profile,
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Ya estamos en home
            break;
          case 1:
            context.go(AppRoutes.explore);
            break;
          case 2:
            context.go(AppRoutes.bookingHistory);
            break;
          case 3:
            context.go(AppRoutes.chatList);
            break;
          case 4:
            context.go(AppRoutes.profile);
            break;
        }
      },
    );
}