import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salas_beats/models/message_model.dart';
import 'package:salas_beats/models/user_model.dart';
import 'package:salas_beats/utils/app_routes.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Mock data para conversaciones
  final List<ChatThreadModel> _mockThreads = [
    ChatThreadModel(
      id: 'thread1',
      participantIds: ['user1', 'user2'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      lastMessage: MessageModel(
        id: 'msg1',
        threadId: 'thread1',
        fromUserId: 'user2',
        toUserId: 'user1',
        text: '¡Perfecto! Nos vemos mañana a las 3 PM',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        status: MessageStatus.read,
        bookingId: 'booking1',
        listingId: 'listing1',
      ),
      bookingId: 'booking1',
      listingId: 'listing1',
    ),
    ChatThreadModel(
      id: 'thread2',
      participantIds: ['user1', 'user3'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      lastMessage: MessageModel(
        id: 'msg2',
        threadId: 'thread2',
        fromUserId: 'user3',
        toUserId: 'user1',
        text: 'Hola, tengo una pregunta sobre el equipo disponible',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: MessageStatus.delivered,
      ),
      listingId: 'listing2',
    ),
    ChatThreadModel(
      id: 'thread3',
      participantIds: ['user1', 'user4'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      lastMessage: MessageModel(
        id: 'msg3',
        threadId: 'thread3',
        fromUserId: 'user1',
        toUserId: 'user4',
        text: 'Gracias por la excelente experiencia',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: MessageStatus.read,
        bookingId: 'booking2',
      ),
      bookingId: 'booking2',
    ),
  ];
  
  // Mock data para usuarios
  final Map<String, UserModel> _mockUsers = {
    'user2': UserModel(
      id: 'user2',
      name: 'Carlos Mendoza',
      email: 'carlos@example.com',
      role: UserRole.host,
      photoURL: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      verified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    'user3': UserModel(
      id: 'user3',
      name: 'Ana García',
      email: 'ana@example.com',
      role: UserRole.musician,
      photoURL: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
      verified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    'user4': UserModel(
      id: 'user4',
      name: 'Miguel Torres',
      email: 'miguel@example.com',
      role: UserRole.host,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  };
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  List<ChatThreadModel> get _filteredThreads {
    if (_searchQuery.isEmpty) return _mockThreads;
    
    return _mockThreads.where((thread) {
      final otherUserId = thread.participantIds.firstWhere(
        (id) => id != 'user1', // Asumiendo que user1 es el usuario actual
        orElse: () => '',
      );
      final otherUser = _mockUsers[otherUserId];
      
      return otherUser?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
    }).toList();
  }
  
  List<ChatThreadModel> get _activeThreads => _filteredThreads.where((thread) => 
      thread.lastActivity.isAfter(DateTime.now().subtract(const Duration(days: 7))),
    ).toList();
  
  List<ChatThreadModel> get _archivedThreads => _filteredThreads.where((thread) => 
      thread.lastActivity.isBefore(DateTime.now().subtract(const Duration(days: 7))),
    ).toList();
  
  List<ChatThreadModel> get _bookingThreads => _filteredThreads.where((thread) => thread.bookingId != null).toList();
  
  void _navigateToConversation(ChatThreadModel thread) {
    Navigator.of(context).pushNamed(
      AppRoutes.chatRoom, // Using chatRoom instead of conversation
      arguments: {
        'threadId': thread.id,
        'otherUser': _getOtherUser(thread),
        'bookingId': thread.bookingId,
        'listingId': thread.listingId,
      },
    );
  }
  
  UserModel? _getOtherUser(ChatThreadModel thread) {
    final otherUserId = thread.participantIds.firstWhere(
      (id) => id != 'user1', // Asumiendo que user1 es el usuario actual
      orElse: () => '',
    );
    return _mockUsers[otherUserId];
  }
  
  void _showNewMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo mensaje'),
        content: const Text(
          'Para iniciar una conversación, visita el perfil de un anfitrión o haz una reserva.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRoutes.explore);
            },
            child: const Text('Explorar'),
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            _buildSearchBar(theme),
            _buildTabBar(theme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildThreadList(_activeThreads, theme),
                  _buildThreadList(_bookingThreads, theme),
                  _buildThreadList(_archivedThreads, theme),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(theme),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewMessageDialog,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme) => Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            'Mensajes',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Implementar configuraciones de chat
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  
  Widget _buildSearchBar(ThemeData theme) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar conversaciones...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
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
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Activos'),
                if (_activeThreads.any((t) => t.unreadCount > 0)) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_activeThreads.fold(0, (sum, t) => sum + t.unreadCount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Reservas'),
                if (_bookingThreads.any((t) => t.unreadCount > 0)) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_bookingThreads.fold(0, (sum, t) => sum + t.unreadCount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'Archivo'),
        ],
      ),
    );
  
  Widget _buildThreadList(List<ChatThreadModel> threads, ThemeData theme) {
    if (threads.isEmpty) {
      return _buildEmptyState(theme);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: threads.length,
      itemBuilder: (context, index) {
        final thread = threads[index];
        final otherUser = _getOtherUser(thread);
        
        return _buildThreadItem(thread, otherUser, theme);
      },
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay conversaciones',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicia una conversación haciendo una reserva\no contactando a un anfitrión',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.explore);
            },
            child: const Text('Explorar salas'),
          ),
        ],
      ),
    );
  
  Widget _buildThreadItem(ChatThreadModel thread, UserModel? otherUser, ThemeData theme) {
    if (otherUser == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primary,
              backgroundImage: otherUser.photoURL != null 
                  ? NetworkImage(otherUser.photoURL!) 
                  : null,
              child: otherUser.photoURL == null
                  ? Text(
                      otherUser.name.isNotEmpty ? otherUser.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            if (otherUser.verified)
              Positioned(
                bottom: 0,
                right: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                otherUser.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: thread.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (thread.bookingId != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Reserva',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              thread.lastMessage?.text ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: thread.unreadCount > 0 
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: thread.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  _formatTime(thread.lastActivity),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
                if (thread.lastMessage?.fromUserId == 'user1') ...[
                  const SizedBox(width: 4),
                  Icon(
                    thread.lastMessage?.status == MessageStatus.read
                        ? Icons.done_all
                        : thread.lastMessage?.status == MessageStatus.delivered
                            ? Icons.done_all
                            : Icons.done,
                    size: 12,
                    color: thread.lastMessage?.status == MessageStatus.read
                        ? Colors.blue
                        : theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: thread.unreadCount > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${thread.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () => _navigateToConversation(thread),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
  
  Widget _buildBottomNavBar(ThemeData theme) => BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 3,
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
            context.go(AppRoutes.explore);
            break;
          case 2:
            context.go(AppRoutes.bookings);
            break;
          case 3:
            // Ya estamos en mensajes
            break;
          case 4:
            context.go(AppRoutes.profile);
            break;
        }
      },
    );
}