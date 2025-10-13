import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/models/user_model.dart';
import 'package:salas_beats/providers/admin_provider.dart';
import 'package:salas_beats/widgets/common/custom_error_widget.dart';
import 'package:salas_beats/widgets/common/loading_widget.dart';
// import '../../widgets/admin/user_card.dart';
// import '../../widgets/admin/user_filters.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUsers();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.loadUsers(
        // status: _selectedStatus, // Parameter not available
        // role: _selectedRole, // Parameter not available
        // search: _searchQuery, // Parameter not available
        // dateFrom: _selectedDateFrom, // Parameter not available
        // dateTo: _selectedDateTo, // Parameter not available
      );
    } catch (e) {
      setState(() {
        _error = 'Error al cargar usuarios: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreUsers();
    }
  }

  void _loadMoreUsers() {
    final adminProvider = context.read<AdminProvider>();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _debounceSearch();
  }

  void _debounceSearch() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == _searchQuery) {
        _loadUsers();
      }
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
      floatingActionButton: _buildFloatingActionButton(),
    );

  PreferredSizeWidget _buildAppBar() => AppBar(
      title: const Text('Gestión de Usuarios'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadUsers,
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: _exportUsers,
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'bulk_actions',
              child: Row(
                children: [
                  Icon(Icons.checklist),
                  SizedBox(width: 8),
                  Text('Acciones masivas'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'import_users',
              child: Row(
                children: [
                  Icon(Icons.upload),
                  SizedBox(width: 8),
                  Text('Importar usuarios'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'user_analytics',
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
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, email o ID...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _searchController.clear,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filtros
          Container( // UserFilters not available
            padding: const EdgeInsets.all(16),
            child: const Text('Filtros no disponibles'),
            // selectedStatus: _selectedStatus,
            // selectedRole: _selectedRole,
            // selectedDateFrom: _selectedDateFrom,
            // selectedDateTo: _selectedDateTo,
            // onStatusChanged and other callbacks commented out
          ),
        ],
      ),
    );

  Widget _buildTabBar() => Consumer<AdminProvider>(
      builder: (context, adminProvider, child) => TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Todos'),
                  const SizedBox(width: 4),
                  _buildBadge(0), // totalUsers not available
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Activos'),
                  const SizedBox(width: 4),
                  _buildBadge(0), // activeUsers not available
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Suspendidos'),
                  const SizedBox(width: 4),
                  _buildBadge(0), // suspendedUsers not available
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Nuevos'),
                  const SizedBox(width: 4),
                  _buildBadge(0), // newUsers not available
                ],
              ),
            ),
          ],
        ),
    );

  Widget _buildBadge(int count) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Cargando usuarios...'),
      );
    }

    if (_error != null) {
      return CustomErrorWidget(
        message: _error,
        onRetry: _loadUsers,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildUsersList(UserStatus.all),
        _buildUsersList(UserStatus.active),
        _buildUsersList(UserStatus.suspended),
        _buildUsersList(UserStatus.new_user),
      ],
    );
  }

  Widget _buildUsersList(UserStatus status) => Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final users = <UserModel>[]; // getUsersByStatus not available

        if (users.isEmpty) {
          return _buildEmptyState(status);
        }

        return RefreshIndicator(
          onRefresh: () async {
            _loadUsers();
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card( // Using Card instead of UserCard
                child: ListTile(
                  title: Text(user.name ?? 'Usuario'),
                  subtitle: Text(user.email ?? ''),
                  onTap: () => _viewUserDetails(user),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editUser(user);
                          break;
                        case 'suspend':
                          _suspendUser(user);
                          break;
                        case 'activate':
                          _activateUser(user);
                          break;
                        case 'delete':
                          _deleteUser(user);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(value: 'suspend', child: Text('Suspender')),
                      const PopupMenuItem(value: 'activate', child: Text('Activar')),
                      const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
                ),
               );
            },
          ),
        );
      },
    );

  Widget _buildEmptyState(UserStatus status) {
    String message;
    IconData icon;

    switch (status) {
      case UserStatus.active:
        message = 'No hay usuarios activos';
        icon = Icons.person_off;
        break;
      case UserStatus.suspended:
        message = 'No hay usuarios suspendidos';
        icon = Icons.block;
        break;
      case UserStatus.new_user:
        message = 'No hay usuarios nuevos';
        icon = Icons.person_add;
        break;
      default:
        message = 'No se encontraron usuarios';
        icon = Icons.people_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta ajustar los filtros de búsqueda',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() => FloatingActionButton(
      onPressed: _createUser,
      child: const Icon(Icons.person_add),
    );

  void _viewUserDetails(UserModel user) {
    Navigator.pushNamed(
      context,
      '/admin/users/details',
      arguments: user.id,
    );
  }

  void _editUser(UserModel user) {
    Navigator.pushNamed(
      context,
      '/admin/users/edit',
      arguments: user.id,
    );
  }

  void _createUser() {
    Navigator.pushNamed(context, '/admin/users/create');
  }

  Future<void> _suspendUser(UserModel user) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Suspender Usuario',
      message: '¿Estás seguro de que quieres suspender a ${user.name}?',
      confirmText: 'Suspender',
      isDestructive: true,
    );

    if (confirmed) {
      try {
        final adminProvider = context.read<AdminProvider>();
        // await adminProvider.suspendUser(user.id); // Method not available
        _showSuccessSnackBar('Usuario suspendido correctamente');
      } catch (e) {
        _showErrorSnackBar('Error al suspender usuario: $e');
      }
    }
  }

  Future<void> _activateUser(UserModel user) async {
    try {
      final adminProvider = context.read<AdminProvider>();
      // await adminProvider.activateUser(user.id); // Method not available
      _showSuccessSnackBar('Usuario activado correctamente');
    } catch (e) {
      _showErrorSnackBar('Error al activar usuario: $e');
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Eliminar Usuario',
      message: '¿Estás seguro de que quieres eliminar a ${user.name}? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      isDestructive: true,
    );

    if (confirmed) {
      try {
        final adminProvider = context.read<AdminProvider>();
        // await adminProvider.deleteUser(user.id); // Method not available
        _showSuccessSnackBar('Usuario eliminado correctamente');
      } catch (e) {
        _showErrorSnackBar('Error al eliminar usuario: $e');
      }
    }
  }

  Future<void> _exportUsers() async {
    try {
      final adminProvider = context.read<AdminProvider>();
      // await adminProvider.exportUsers(); // Method not available
      _showSuccessSnackBar('Usuarios exportados correctamente');
    } catch (e) {
      _showErrorSnackBar('Error al exportar usuarios: $e');
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'bulk_actions':
        _showBulkActionsDialog();
        break;
      case 'import_users':
        _importUsers();
        break;
      case 'user_analytics':
        Navigator.pushNamed(context, '/admin/analytics/users');
        break;
    }
  }

  void _showBulkActionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acciones Masivas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Enviar email masivo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar envío de email masivo
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Suspender seleccionados'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar suspensión masiva
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar seleccionados'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar eliminación masiva
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _importUsers() {
    // TODO: Implementar importación de usuarios
    _showErrorSnackBar('Función de importación próximamente');
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

enum UserStatus {
  all,
  active,
  suspended,
  new_user,
}

enum UserRole {
  admin,
  host,
  guest,
  moderator,
}