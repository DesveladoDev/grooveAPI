import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:salas_beats/providers/admin_provider.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/services/localization_service.dart';
import 'package:salas_beats/widgets/localization_demo_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  final bool _pushNotifications = true;
  final bool _darkMode = false;
  
  void _navigateToEditProfile() {
    context.go(AppRoutes.editProfile);
  }
  
  void _navigateToHostDashboard() {
    context.go(AppRoutes.hostDashboard);
  }
  
  void _navigateToFavorites() {
    context.go(AppRoutes.favorites);
  }
  
  void _navigateToPaymentMethods() {
    context.go(AppRoutes.paymentMethods);
  }
  
  void _navigateToSupport() {
    context.go(AppRoutes.support);
  }
  
  void _navigateToPrivacyPolicy() {
    context.go(AppRoutes.privacyPolicy);
  }
  
  void _navigateToTermsOfService() {
    context.go(AppRoutes.termsOfService);
  }
  
  void _navigateToAdminPanel() {
    context.go('/admin');
  }
  
  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.selectLanguage,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Text('🇪🇸', style: TextStyle(fontSize: 24)),
                title: const Text('Español'),
                trailing: LocalizationService().currentLanguageCode == 'es' 
                    ? const Icon(Icons.check, color: Colors.green) 
                    : null,
                onTap: () async {
                  await LocalizationService().changeLanguage('es');
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.languageUpdated),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                trailing: LocalizationService().currentLanguageCode == 'en' 
                    ? const Icon(Icons.check, color: Colors.green) 
                    : null,
                onTap: () async {
                  await LocalizationService().changeLanguage('en');
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.languageUpdated),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Text('🇧🇷', style: TextStyle(fontSize: 24)),
                title: const Text('Português'),
                trailing: LocalizationService().currentLanguageCode == 'pt' 
                    ? const Icon(Icons.check, color: Colors.green) 
                    : null,
                onTap: () async {
                  await LocalizationService().changeLanguage('pt');
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.languageUpdated),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
    );
  }
  
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que quieres eliminar tu cuenta?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Esta acción:'),
            SizedBox(height: 8),
            Text('• Eliminará permanentemente todos tus datos'),
            Text('• Cancelará todas las reservas activas'),
            Text('• No se puede deshacer'),
            SizedBox(height: 12),
            Text(
              'Si tienes reservas activas, te recomendamos cancelarlas primero.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDeleteAccount();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
  
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Confirmación final',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'Escribe "ELIMINAR" para confirmar que quieres eliminar permanentemente tu cuenta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar eliminación de cuenta
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de eliminación de cuenta próximamente'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar cuenta'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              
              if (mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: const Text('Cerrar sesión'),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(theme),
              _buildProfileInfo(theme),
              const SizedBox(height: 24),
              
              // Demo de localización (temporal para testing)
              const LocalizationDemoWidget(),
              
              _buildMenuSection(theme),
              const SizedBox(height: 100), // Espacio para bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(theme),
    );
  }
  
  Widget _buildHeader(ThemeData theme) => Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            'Mi Perfil',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Implementar configuraciones
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  
  Widget _buildProfileInfo(ThemeData theme) => Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Avatar y botón de editar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary,
                    backgroundImage: user.photoURL != null 
                        ? NetworkImage(user.photoURL!) 
                        : null,
                    child: user.photoURL == null
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _navigateToEditProfile,
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Nombre y email
              Text(
                user.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 4),
              
              Text(
                user.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Estado de verificación
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    user.verified ? Icons.verified : Icons.warning,
                    size: 16,
                    color: user.verified ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user.verified ? 'Cuenta verificada' : 'Cuenta no verificada',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: user.verified ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Rol y estadísticas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    theme,
                    'Rol',
                    user.role == 'musician' ? 'Músico' : 
                    user.role == 'host' ? 'Anfitrión' : 'Usuario',
                    Icons.person,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                  _buildStatItem(
                    theme,
                    'Miembro desde',
                    '${user.createdAt.year}',
                    Icons.calendar_today,
                  ),
                  if (user.role == 'host') ...[
                    Container(
                      width: 1,
                      height: 40,
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                    _buildStatItem(
                      theme,
                      'Rating',
                      '4.8',
                      Icons.star,
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  
  Widget _buildStatItem(ThemeData theme, String label, String value, IconData icon) => Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  
  Widget _buildMenuSection(ThemeData theme) => Column(
      children: [
        // Sección de cuenta
        _buildSectionHeader(theme, 'Cuenta'),
        _buildMenuItem(
          theme,
          'Editar perfil',
          'Actualiza tu información personal',
          Icons.edit,
          _navigateToEditProfile,
        ),
        _buildMenuItem(
          theme,
          'Métodos de pago',
          'Gestiona tus tarjetas y métodos de pago',
          Icons.payment,
          _navigateToPaymentMethods,
        ),
        _buildMenuItem(
          theme,
          'Favoritos',
          'Salas que has guardado',
          Icons.favorite,
          _navigateToFavorites,
        ),
        
        // Sección de administración (solo para admins)
        Consumer<AdminProvider>(
          builder: (context, adminProvider, child) => FutureBuilder<bool>(
              future: adminProvider.isAdmin(),
              builder: (context, snapshot) {
                if (snapshot.data ?? false) {
                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildSectionHeader(theme, 'Administración'),
                      _buildMenuItem(
                        theme,
                        'Panel de administración',
                        'Gestiona la plataforma y usuarios',
                        Icons.admin_panel_settings,
                        _navigateToAdminPanel,
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ),
        
        // Sección de anfitrión (solo si es host)
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.currentUser?.role == 'host') {
              return Column(
                children: [
                  const SizedBox(height: 24),
                  _buildSectionHeader(theme, 'Anfitrión'),
                  _buildMenuItem(
                    theme,
                    'Panel de anfitrión',
                    'Gestiona tus salas y reservas',
                    Icons.dashboard,
                    _navigateToHostDashboard,
                  ),
                  _buildMenuItem(
                    theme,
                    'Mis salas',
                    'Ver y editar tus listings',
                    Icons.home_work,
                    () {
                      Navigator.of(context).pushNamed(AppRoutes.hostListings);
                    },
                  ),
                  _buildMenuItem(
                    theme,
                    'Ganancias',
                    'Historial de pagos y ganancias',
                    Icons.monetization_on,
                    () {
                      Navigator.of(context).pushNamed(AppRoutes.hostEarnings);
                    },
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        
        const SizedBox(height: 24),
        
        // Sección de configuración
        _buildSectionHeader(theme, 'Configuración'),
        _buildSwitchMenuItem(
          theme,
          'Notificaciones',
          'Recibir notificaciones de la app',
          Icons.notifications,
          _notificationsEnabled,
          (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        _buildSwitchMenuItem(
          theme,
          'Notificaciones por email',
          'Recibir emails sobre reservas y actualizaciones',
          Icons.email,
          _emailNotifications,
          (value) {
            setState(() {
              _emailNotifications = value;
            });
          },
        ),
        _buildMenuItem(
          theme,
          'Idioma',
          'Español (México)',
          Icons.language,
          _showLanguageSelector,
        ),
        
        const SizedBox(height: 24),
        
        // Sección de soporte
        _buildSectionHeader(theme, 'Soporte y legal'),
        _buildMenuItem(
          theme,
          'Centro de ayuda',
          'Preguntas frecuentes y soporte',
          Icons.help,
          _navigateToSupport,
        ),
        _buildMenuItem(
          theme,
          'Política de privacidad',
          'Cómo protegemos tu información',
          Icons.privacy_tip,
          _navigateToPrivacyPolicy,
        ),
        _buildMenuItem(
          theme,
          'Términos de servicio',
          'Condiciones de uso de la plataforma',
          Icons.description,
          _navigateToTermsOfService,
        ),
        
        const SizedBox(height: 24),
        
        // Sección de cuenta
        _buildSectionHeader(theme, 'Cuenta'),
        _buildMenuItem(
          theme,
          'Cerrar sesión',
          'Salir de tu cuenta',
          Icons.logout,
          _signOut,
          textColor: Colors.red,
        ),
        _buildMenuItem(
          theme,
          'Eliminar cuenta',
          'Eliminar permanentemente tu cuenta',
          Icons.delete_forever,
          _showDeleteAccountDialog,
          textColor: Colors.red,
        ),
        
        const SizedBox(height: 24),
        
        // Información de la app
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Salas & Beats',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Versión 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Conectando músicos con espacios increíbles',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  
  Widget _buildSectionHeader(ThemeData theme, String title) => Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  
  Widget _buildMenuItem(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? textColor,
  }) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (textColor ?? theme.colorScheme.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: textColor ?? theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  
  Widget _buildSwitchMenuItem(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: theme.colorScheme.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  
  Widget _buildBottomNavBar(ThemeData theme) => BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 4,
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
            context.go(AppRoutes.bookingHistory);
            break;
          case 3:
            context.go(AppRoutes.chatList);
            break;
          case 4:
            // Ya estamos en profile
            break;
        }
      },
    );
}