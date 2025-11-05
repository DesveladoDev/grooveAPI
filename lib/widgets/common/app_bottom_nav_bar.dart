import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/providers/chat_provider.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // If ChatProvider is not provided, fall back to 0.
    final int unreadCount = _getUnreadCount(context);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.explore),
          label: 'Explorar',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Reservas',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat),
              if (unreadCount > 0)
                Positioned(
                  right: -6,
                  top: -2,
                  child: _Badge(count: unreadCount),
                ),
            ],
          ),
          label: 'Mensajes',
        ),
        const BottomNavigationBarItem(
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

  int _getUnreadCount(BuildContext context) {
    try {
      return context.select<ChatProvider?, int>((p) => p?.totalUnreadCount ?? 0);
    } catch (_) {
      // If provider not found, avoid crashing
      return 0;
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;

  String get _text => count > 99 ? '99+' : '$count';

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        child: Text(
          _text,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
}