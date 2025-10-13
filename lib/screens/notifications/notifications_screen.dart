import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/models/notification_model.dart';
import 'package:salas_beats/providers/notification_provider.dart';
import 'package:salas_beats/widgets/common/empty_state_widget.dart';
import 'package:salas_beats/widgets/common/error_widget.dart';
import 'package:salas_beats/widgets/common/loading_widget.dart';
import 'package:salas_beats/widgets/notification/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final String _selectedFilter = 'all';
  String _searchQuery = '';
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Inicializar notificaciones si no están cargadas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotificationProvider>();
      if (provider.notifications.isEmpty && !provider.isLoading) {
        provider.refresh();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_showFilters) _buildFilters(),
          _buildTabBar(),
          Expanded(
            child: _buildTabBarView(),
          ),
        ],
      ),
    );

  PreferredSizeWidget _buildAppBar() => AppBar(
      title: const Text('Notificaciones'),
      actions: [
        // Botón de búsqueda
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _showSearchDialog,
        ),
        // Botón de filtros
        IconButton(
          icon: Icon(
            _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
          ),
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
        ),
        // Menú de opciones
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'mark_all_read',
              child: Row(
                children: [
                  Icon(Icons.mark_email_read),
                  SizedBox(width: 8),
                  Text('Marcar todas como leídas'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_all',
              child: Row(
                children: [
                  Icon(Icons.clear_all),
                  SizedBox(width: 8),
                  Text('Eliminar todas'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Configuración'),
                ],
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text('Filtros no disponibles'),
    ); // NotificationFilters not available
  }

  Widget _buildTabBar() => Consumer<NotificationProvider>(
      builder: (context, provider, child) => TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Todas'),
                  if (provider.notifications.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    _buildBadge(provider.notifications.length),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No leídas'),
                  if (provider.unreadCount > 0) ...[
                    const SizedBox(width: 4),
                    _buildBadge(provider.unreadCount),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Hoy'),
                  if (provider.todayNotifications.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    _buildBadge(provider.todayNotifications.length),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Recientes'),
                  if (provider.recentNotifications.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    _buildBadge(provider.recentNotifications.length),
                  ],
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
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

  Widget _buildTabBarView() => Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.notifications.isEmpty) {
          return const LoadingWidget();
        }

        if (provider.hasError) {
          return CustomErrorWidget(
            message: provider.error!,
            onRetry: provider.refresh,
          );
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildNotificationsList(_getFilteredNotifications('all')),
            _buildNotificationsList(_getFilteredNotifications('unread')),
            _buildNotificationsList(_getFilteredNotifications('today')),
            _buildNotificationsList(_getFilteredNotifications('recent')),
          ],
        );
      },
    );

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.notifications_none,
        title: 'No hay notificaciones',
        message: 'Cuando recibas notificaciones aparecerán aquí',
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<NotificationProvider>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NotificationCard(
              notification: notification,
              onTap: () => _handleNotificationTap(notification),
              onMarkAsRead: () => _markAsRead(notification),
              onDelete: () => _deleteNotification(notification),
            ),
          );
        },
      ),
    );
  }

  List<NotificationModel> _getFilteredNotifications(String filter) {
    final provider = context.watch<NotificationProvider>();
    List<NotificationModel> notifications;

    switch (filter) {
      case 'unread':
        notifications = provider.unreadNotifications;
        break;
      case 'today':
        notifications = provider.todayNotifications;
        break;
      case 'recent':
        notifications = provider.recentNotifications;
        break;
      default:
        notifications = provider.notifications;
    }

    // Aplicar filtro de búsqueda si existe
    if (_searchQuery.isNotEmpty) {
      notifications = notifications.where((notification) => notification.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               notification.body.toLowerCase().contains(_searchQuery.toLowerCase()),).toList();
    }

    // Aplicar filtro seleccionado
    if (_selectedFilter != 'all') {
      notifications = notifications.where((notification) => notification.type == _selectedFilter).toList();
    }

    return notifications;
  }

  void _handleMenuAction(String action) {
    final provider = context.read<NotificationProvider>();
    
    switch (action) {
      case 'mark_all_read':
        provider.markAllAsRead();
        break;
      case 'clear_all':
        _showClearAllDialog();
        break;
      case 'settings':
        // Navegar a configuración de notificaciones
        break;
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Marcar como leída si no lo está
    if (!notification.isRead) {
      _markAsRead(notification);
    }

    // Navegar según el tipo de notificación
    switch (notification.type) {
      case 'booking':
        if (notification.data['bookingId'] != null) {
          final bookingId = notification.data['bookingId'];
          // Navegar a detalles de reserva
        }
        break;
      case 'payment':
        if (notification.data['paymentId'] != null) {
          final paymentId = notification.data['paymentId'];
          // Navegar a detalles de pago
        }
        break;
      case 'message':
        if (notification.data['chatId'] != null) {
          final chatId = notification.data['chatId'];
          // Navegar a chat
        }
        break;
      case 'review':
        if (notification.data['reviewId'] != null) {
          final reviewId = notification.data['reviewId'];
          // Navegar a reseñas
        }
        break;
      case 'host':
        // Navegar a dashboard de host
        break;
      default:
        // Para otros tipos, mostrar detalles de la notificación
        _showNotificationDetails(notification);
    }
  }

  void _markAsRead(NotificationModel notification) {
    context.read<NotificationProvider>().markAsRead(notification.id);
  }

  void _deleteNotification(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar notificación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta notificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationProvider>().deleteNotification(notification.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar notificaciones'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todas las notificaciones'),
        content: const Text('¿Estás seguro de que quieres eliminar todas las notificaciones?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // context.read<NotificationProvider>().clearAll(); // Method not available
            },
            child: const Text('Eliminar todas'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 16),
            Text(
              'Recibida: ${notification.createdAt}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}