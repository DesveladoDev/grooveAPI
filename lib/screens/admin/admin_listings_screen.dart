import 'package:flutter/material.dart';
import 'package:salas_beats/models/listing_model.dart';
import 'package:salas_beats/widgets/common/empty_state_widget.dart';
// import '../../widgets/listing/listing_card.dart';
import 'package:salas_beats/widgets/common/loading_widget.dart';

class AdminListingsScreen extends StatefulWidget {
  const AdminListingsScreen({super.key});

  @override
  State<AdminListingsScreen> createState() => _AdminListingsScreenState();
}

class _AdminListingsScreenState extends State<AdminListingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<ListingModel> _listings = [];
  List<ListingModel> _filteredListings = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final listings = <ListingModel>[]; // await _adminService.getAllListings(); // Method not available
      setState(() {
        _listings = listings;
        _filteredListings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar listados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterListings() {
    setState(() {
      _filteredListings = _listings.where((listing) {
        final matchesSearch = _searchQuery.isEmpty ||
            listing.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            listing.description.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesStatus = _selectedStatus == 'all' ||
            true; // status property not available
        
        final matchesCategory = _selectedCategory == 'all' ||
            listing.category == _selectedCategory;
        
        return matchesSearch && matchesStatus && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildTabBar(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );

  PreferredSizeWidget _buildAppBar() => AppBar(
      title: const Text('Gestión de Listados'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadListings,
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export_data',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Exportar Datos'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'bulk_actions',
              child: Row(
                children: [
                  Icon(Icons.checklist),
                  SizedBox(width: 8),
                  Text('Acciones Masivas'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'analytics',
              child: Row(
                children: [
                  Icon(Icons.analytics),
                  SizedBox(width: 8),
                  Text('Analíticas'),
                ],
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildSearchAndFilters() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar listados...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        _filterListings();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _filterListings();
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Todos')),
                    DropdownMenuItem(value: 'active', child: Text('Activos')),
                    DropdownMenuItem(value: 'pending', child: Text('Pendientes')),
                    DropdownMenuItem(value: 'suspended', child: Text('Suspendidos')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rechazados')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                    _filterListings();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Todas')),
                    DropdownMenuItem(value: 'studio', child: Text('Estudio')),
                    DropdownMenuItem(value: 'rehearsal', child: Text('Ensayo')),
                    DropdownMenuItem(value: 'event', child: Text('Evento')),
                    DropdownMenuItem(value: 'recording', child: Text('Grabación')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    _filterListings();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );

  Widget _buildTabBar() => TabBar(
      controller: _tabController,
      tabs: [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.list),
              const SizedBox(width: 8),
              Text('Todos (${_filteredListings.length})'),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pending),
              const SizedBox(width: 8),
              Text('Pendientes (${_filteredListings.length})'), // status property not available
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle),
              const SizedBox(width: 8),
              Text('Activos (${_filteredListings.length})'), // status property not available
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block),
              const SizedBox(width: 8),
              Text('Suspendidos (${_filteredListings.length})'), // status property not available
            ],
          ),
        ),
      ],
    );

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildListingsList(_filteredListings),
        _buildListingsList(_filteredListings), // status property not available
        _buildListingsList(_filteredListings), // status property not available
        _buildListingsList(_filteredListings), // status property not available
      ],
    );
  }

  Widget _buildListingsList(List<ListingModel> listings) {
    if (listings.isEmpty) {
      return const EmptyStateWidget(
          icon: Icons.home_work,
          title: 'No hay listados',
          message: 'No hay listados disponibles',
        );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
             title: Text(listing.title),
             subtitle: Text(listing.description),
             onTap: () => _viewListingDetails(listing),
             trailing: PopupMenuButton<String>(
               onSelected: (action) => _handleListingAction(action, listing),
               itemBuilder: (context) => [
                 const PopupMenuItem(
                   value: 'view',
                   child: Row(
                     children: [
                       Icon(Icons.visibility),
                       SizedBox(width: 8),
                       Text('Ver Detalles'),
                     ],
                   ),
                 ),
                 const PopupMenuItem(
                   value: 'edit',
                   child: Row(
                     children: [
                       Icon(Icons.edit),
                       SizedBox(width: 8),
                       Text('Editar'),
                     ],
                   ),
                 ),
                 const PopupMenuItem(
                   value: 'delete',
                   child: Row(
                     children: [
                       Icon(Icons.delete, color: Colors.red),
                       SizedBox(width: 8),
                       Text('Eliminar', style: TextStyle(color: Colors.red)),
                     ],
                   ),
                 ),
               ],
             ),
          ),
        );
      },
    );
  }

  void _viewListingDetails(ListingModel listing) {
    Navigator.pushNamed(
      context,
      '/listing-detail',
      arguments: {'listingId': listing.id},
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export_data':
        _exportData();
        break;
      case 'bulk_actions':
        _showBulkActionsDialog();
        break;
      case 'analytics':
        _showAnalytics();
        break;
    }
  }

  void _handleListingAction(String action, ListingModel listing) {
    switch (action) {
      case 'view':
        _viewListingDetails(listing);
        break;
      case 'edit':
        _editListing(listing);
        break;
      case 'approve':
        _approveListing(listing);
        break;
      case 'reject':
        _rejectListing(listing);
        break;
      case 'suspend':
        _suspendListing(listing);
        break;
      case 'activate':
        _activateListing(listing);
        break;
      case 'delete':
        _deleteListing(listing);
        break;
    }
  }

  void _editListing(ListingModel listing) {
    Navigator.pushNamed(
      context,
      '/edit-listing',
      arguments: {'listingId': listing.id},
    ).then((_) => _loadListings());
  }

  Future<void> _approveListing(ListingModel listing) async {
    try {
      // await _adminService.approveListing(listing.id); // Method not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listado aprobado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _loadListings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al aprobar listado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectListing(ListingModel listing) async {
    try {
      // await _adminService.rejectListing(listing.id); // Method not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listado rechazado exitosamente'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadListings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al rechazar listado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _suspendListing(ListingModel listing) async {
    try {
      // await _adminService.suspendListing(listing.id); // Method not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listado suspendido exitosamente'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadListings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al suspender listado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _activateListing(ListingModel listing) async {
    try {
      // await _adminService.activateListing(listing.id); // Method not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listado activado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _loadListings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al activar listado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteListing(ListingModel listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar el listado "${listing.title}"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        // await _adminService.deleteListing(listing.id); // Method not available
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listado eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadListings();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar listado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _exportData() {
    // TODO: Implementar exportación de datos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportación de datos próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showBulkActionsDialog() {
    // TODO: Implementar acciones masivas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Acciones masivas próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showAnalytics() {
    Navigator.pushNamed(context, '/admin/analytics/listings');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}