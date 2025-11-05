import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salas_beats/config/constants.dart';
import 'package:salas_beats/models/listing_model.dart';
import 'package:salas_beats/utils/app_routes.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedCategory = 'Todas';
  
  final List<String> _categories = [
    'Todas',
    'Estudio de grabación',
    'Sala de ensayo',
    'Estudio acústico',
    'Sala de producción',
    'Espacio para eventos',
  ];
  
  // Mock data - en producción vendría de Firestore
  final List<ListingModel> _mockListings = [
    ListingModel(
      id: '1',
      hostId: 'host1',
      title: 'Estudio de Grabación Pro',
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
    ListingModel(
      id: '4',
      hostId: 'host4',
      title: 'Sala de Producción',
      description: 'Espacio equipado para producción musical y post-producción.',
      photos: ['https://example.com/studio4.jpg'],
      amenities: ['DAW profesional', 'Controladores MIDI', 'Sintetizadores', 'Monitores de referencia'],
      capacity: 4,
      hourlyPrice: 380,
      rules: ['Experiencia en producción requerida', 'Cuidar el software'],
      location: LocationData(
        lat: 19.4150,
        lng: -99.1700,
        address: 'Del Valle, CDMX',
        city: 'Ciudad de México',
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ListingModel> get _filteredListings => _mockListings.where((listing) {
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          listing.title.toLowerCase().contains(searchQuery) ||
          listing.description.toLowerCase().contains(searchQuery);
      
      final matchesCategory = _selectedCategory == 'Todas' ||
          listing.title.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
          listing.description.toLowerCase().contains(_selectedCategory.toLowerCase());
      
      return matchesSearch && matchesCategory;
    }).toList();

  void _navigateToListing(ListingModel listing) {
    Navigator.of(context).pushNamed(
      AppRoutes.listingDetail,
      arguments: listing.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(theme),
            
            // Barra de búsqueda
            _buildSearchBar(theme),
            
            // Categorías
            _buildCategories(theme),
            
            // Tabs (Lista/Mapa)
            _buildTabBar(theme),
            
            // Contenido de tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListView(theme),
                  _buildMapView(theme),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(theme),
    );
  }

  Widget _buildHeader(ThemeData theme) => Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Text(
            'Explorar',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Implementar filtros avanzados
            },
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
    );

  Widget _buildSearchBar(ThemeData theme) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, tipo, ubicación...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
      ),
    );

  Widget _buildCategories(ThemeData theme) => Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );

  Widget _buildTabBar(ThemeData theme) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
     child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
            indicatorSize: TabBarIndicatorSize.tab,
            padding: const EdgeInsets.all(4.0),
            labelPadding: const EdgeInsets.symmetric(vertical: 8.0),
            tabs: const [
              Tab(
                icon: Icon(Icons.list),
                text: 'Lista',
              ),
              Tab(
                icon: Icon(Icons.map),
                text: 'Mapa',
              ),
            ],
          ),
    );

  Widget _buildListView(ThemeData theme) {
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

  Widget _buildMapView(ThemeData theme) => Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Vista de Mapa',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente: Visualiza las salas en un mapa interactivo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Lista simplificada de ubicaciones
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredListings.length,
              itemBuilder: (context, index) {
                final listing = _filteredListings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      listing.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(listing.location.address),
                    trailing: Text(
                      '\$${listing.hourlyPrice.toStringAsFixed(0) ?? '0'}/hora',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _navigateToListing(listing),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

  Widget _buildListingCard(ListingModel listing, ThemeData theme) => Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToListing(listing),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
                  color: Colors.white,
                  size: 32,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Información
              Expanded(
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${listing.hourlyPrice.toStringAsFixed(0) ?? '0'}/hora',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Ubicación
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.location.address,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Capacidad y rating
                    Row(
                      children: [
                        Icon(
                          Icons.people_outlined,
                          size: AppConstants.smallIconSize,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.capacity} personas',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.star,
                          size: AppConstants.smallIconSize,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '0.0 (0)', // averageRating and reviewCount not available
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Amenidades principales
                    Wrap(
                      spacing: 4,
                      children: listing.amenities.take(2).map((amenity) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            amenity,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),).toList(),
                    ),
                  ],
                ),
              ),
              
              // Botón de favorito
              IconButton(
                onPressed: () {
                  // TODO: Implementar favoritos
                },
                icon: const Icon(
                  Icons.favorite_border,
                  size: 20,
                ),
              ),
            ],
          ),
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
              'No se encontraron salas',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta cambiar la categoría o ajustar tu búsqueda',
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
                  _selectedCategory = 'Todas';
                });
              },
              child: const Text('Limpiar búsqueda'),
            ),
          ],
        ),
      ),
    );

  Widget _buildBottomNavBar(ThemeData theme) => BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 1,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Explorar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Reservas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Mensajes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutes.home);
            break;
          case 1:
            // Ya estamos en explorar
            break;
          case 2:
            context.go(AppRoutes.bookings);
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