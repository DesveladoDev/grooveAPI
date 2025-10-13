import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/models/listing_model.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/providers/listing_provider.dart';
import 'package:salas_beats/providers/stripe_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:salas_beats/utils/app_routes.dart';
import 'package:salas_beats/widgets/common/custom_button.dart';
import 'package:salas_beats/widgets/common/loading_overlay.dart';
import 'package:salas_beats/widgets/host/earnings_card.dart';
import 'package:salas_beats/widgets/host/listing_card.dart';
import 'package:salas_beats/widgets/host/quick_stats.dart';

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});
  
  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) => Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Dashboard'),
                  background: _buildHeaderBackground(),
                ),
                actions: [
                  IconButton(
                    onPressed: () => _showSettingsMenu(context),
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          body: Column(
            children: [
              // Tabs
              ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'Resumen'),
                    Tab(text: 'Listados'),
                    Tab(text: 'Reservas'),
                    Tab(text: 'Ganancias'),
                  ],
                ),
              ),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildListingsTab(),
                    _buildBookingsTab(),
                    _buildEarningsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  
  Widget _buildHeaderBackground() => Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                            ? Text(
                                user?.name.substring(0, 1).toUpperCase() ?? 'U', // Using name instead of firstName
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, ${user?.name ?? 'Anfitrión'}', // Using name instead of firstName
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Consumer<StripeProvider>(
                              builder: (context, stripeProvider, child) => Text(
                                  stripeProvider.hasActiveConnectAccount
                                      ? 'Cuenta verificada'
                                      : 'Configuración pendiente',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  
  Widget _buildOverviewTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estado de la cuenta
          Consumer<StripeProvider>(
            builder: (context, stripeProvider, child) {
              if (!stripeProvider.hasActiveConnectAccount) {
                return _buildAccountSetupCard();
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Estadísticas rápidas
          const QuickStats(),
          const SizedBox(height: 24),
          
          // Ganancias del mes
          const EarningsCard(),
          const SizedBox(height: 24),
          
          // Listados recientes
          _buildRecentListings(),
          const SizedBox(height: 24),
          
          // Reservas próximas
          _buildUpcomingBookings(),
        ],
      ),
    );
  
  Widget _buildListingsTab() => Consumer<ListingProvider>(
      builder: (context, listingProvider, child) {
        final listings = listingProvider.hostListings;
        
        if (listings.isEmpty) {
          return _buildEmptyListings();
        }
        
        return RefreshIndicator(
          onRefresh: () => listingProvider.loadHostListings(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: listings.length,
            itemBuilder: (context, index) => ListingCard(
                listing: listings[index],
                onTap: () => _navigateToListingDetail(listings[index]),
                onEdit: () => _navigateToEditListing(listings[index]),
                onToggleStatus: () => _toggleListingStatus(listings[index]),
              ),
          ),
        );
      },
    );
  
  Widget _buildBookingsTab() => DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Próximas'),
              Tab(text: 'En curso'),
              Tab(text: 'Historial'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBookingsList('upcoming'),
                _buildBookingsList('active'),
                _buildBookingsList('completed'),
              ],
            ),
          ),
        ],
      ),
    );
  
  Widget _buildEarningsTab() => Consumer<StripeProvider>(
      builder: (context, stripeProvider, child) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen de ganancias
              _buildEarningsSummary(stripeProvider),
              const SizedBox(height: 24),
              
              // Gráfico de ganancias
              _buildEarningsChart(),
              const SizedBox(height: 24),
              
              // Transacciones recientes
              _buildRecentTransactions(),
            ],
          ),
        ),
    );
  
  Widget _buildAccountSetupCard() => Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 8),
                Text(
                  'Configuración pendiente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Completa la configuración de tu cuenta para empezar a recibir reservas.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Completar configuración',
              onPressed: () => Navigator.of(context).pushNamed(
                '/host-onboarding', // hostOnboarding route not available
              ),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  
  Widget _buildRecentListings() => Consumer<ListingProvider>(
      builder: (context, listingProvider, child) {
        final listings = listingProvider.hostListings.take(3).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tus listados',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (listings.isEmpty)
              _buildEmptyState(
                icon: Icons.home_work,
                title: 'Sin listados',
                description: 'Crea tu primer listado para empezar',
                actionText: 'Crear listado',
                onAction: _navigateToCreateListing,
              )
            else
              ...listings.map((listing) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListingCard(
                  listing: listing,
                  onTap: () => _navigateToListingDetail(listing),
                  compact: true,
                ),
              ),),
          ],
        );
      },
    );
  
  Widget _buildUpcomingBookings() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Próximas reservas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(2),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // TODO: Implementar lista de reservas próximas
        _buildEmptyState(
          icon: Icons.calendar_today,
          title: 'Sin reservas próximas',
          description: 'Las nuevas reservas aparecerán aquí',
        ),
      ],
    );
  
  Widget _buildEmptyListings() => Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: _buildEmptyState(
          icon: Icons.home_work,
          title: 'Sin listados',
          description: 'Crea tu primer listado para empezar a recibir reservas',
          actionText: 'Crear listado',
          onAction: _navigateToCreateListing,
        ),
      ),
    );
  
  Widget _buildBookingsList(String type) {
    // TODO: Implementar lista de reservas por tipo
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: _buildEmptyState(
          icon: Icons.event_note,
          title: 'Sin reservas',
          description: 'Las reservas aparecerán aquí cuando los huéspedes hagan reservas',
        ),
      ),
    );
  }
  
  Widget _buildEarningsSummary(StripeProvider stripeProvider) => Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de ganancias',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildEarningsStat(
                    'Este mes',
                    r'$0.00',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildEarningsStat(
                    'Total',
                    r'$0.00',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEarningsStat(
                    'Pendiente',
                    r'$0.00',
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildEarningsStat(
                    'Disponible',
                    r'$0.00',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  
  Widget _buildEarningsStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) => Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
  
  Widget _buildEarningsChart() => Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ganancias por mes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Gráfico de ganancias\n(Próximamente)',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  
  Widget _buildRecentTransactions() => Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transacciones recientes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildEmptyState(
              icon: Icons.receipt_long,
              title: 'Sin transacciones',
              description: 'Las transacciones aparecerán aquí',
            ),
          ],
        ),
      ),
    );
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    String? actionText,
    VoidCallback? onAction,
  }) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
        if (actionText != null && onAction != null) ...[
          const SizedBox(height: 20),
          CustomButton(
            text: actionText,
            onPressed: onAction,
            isOutlined: true,
          ),
        ],
      ],
    );
  
  Widget _buildFloatingActionButton() => FloatingActionButton.extended(
      onPressed: _navigateToCreateListing,
      icon: const Icon(Icons.add),
      label: const Text('Crear listado'),
    );
  
  // Métodos de navegación
  void _navigateToCreateListing() {
    Navigator.of(context).pushNamed(AppRoutes.createListing);
  }
  
  void _navigateToListingDetail(ListingModel listing) {
    Navigator.of(context).pushNamed(
      AppRoutes.listingDetail,
      arguments: listing.id,
    );
  }
  
  void _navigateToEditListing(ListingModel listing) {
    Navigator.of(context).pushNamed(
      AppRoutes.editListing,
      arguments: listing.id,
    );
  }
  
  // Métodos de funcionalidad
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final stripeProvider = Provider.of<StripeProvider>(context, listen: false);
      final listingProvider = Provider.of<ListingProvider>(context, listen: false);
      
      await Future.wait([
        stripeProvider.loadConnectAccountStatus(),
        listingProvider.loadHostListings(),
        // TODO: Cargar reservas y ganancias
      ]);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _toggleListingStatus(ListingModel listing) async {
    try {
      final listingProvider = Provider.of<ListingProvider>(context, listen: false);
      await listingProvider.updateListingStatus(
        listing.id,
        !listing.isActive,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            listing.isActive 
                ? 'Listado desactivado' 
                : 'Listado activado',
          ),
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.settings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Ayuda'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.support);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    context.go(AppRoutes.login);
  }
}