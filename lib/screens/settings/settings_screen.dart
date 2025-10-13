import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:salas_beats/config/app_constants.dart';
import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkMode = false;
  String _language = 'es';

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildProfileSection(),
          const Divider(),
          _buildNotificationSection(),
          const Divider(),
          _buildAppearanceSection(),
          const Divider(),
          _buildPrivacySection(),
          const Divider(),
          _buildSupportSection(),
          const Divider(),
          _buildAccountSection(),
        ],
      ),
    );

  Widget _buildProfileSection() => Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Perfil',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(user?.name ?? 'Usuario'),
              subtitle: Text(user?.email ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar perfil'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.editProfile);
              },
            ),
          ],
        );
      },
    );

  Widget _buildNotificationSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Notificaciones',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Notificaciones'),
          subtitle: const Text('Recibir notificaciones de la app'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Notificaciones por email'),
          subtitle: const Text('Recibir notificaciones por correo'),
          value: _emailNotifications,
          onChanged: _notificationsEnabled
              ? (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                }
              : null,
        ),
        SwitchListTile(
          title: const Text('Notificaciones push'),
          subtitle: const Text('Recibir notificaciones push'),
          value: _pushNotifications,
          onChanged: _notificationsEnabled
              ? (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                }
              : null,
        ),
        ListTile(
          leading: const Icon(Icons.tune),
          title: const Text('Configuración avanzada'),
          subtitle: const Text('Personalizar tipos de notificaciones'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.notificationSettings);
          },
        ),
      ],
    );

  Widget _buildAppearanceSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Apariencia',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Modo oscuro'),
          subtitle: const Text('Usar tema oscuro'),
          value: _darkMode,
          onChanged: (value) {
            setState(() {
              _darkMode = value;
            });
            // TODO: Implementar cambio de tema
          },
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Idioma'),
          subtitle: Text(_language == 'es' ? 'Español' : 'English'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showLanguageDialog,
        ),
      ],
    );

  Widget _buildPrivacySection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Privacidad y seguridad',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Configuración de privacidad'),
          subtitle: const Text('Controla quién puede verte'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.privacySettings);
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Cambiar contraseña'),
          subtitle: const Text('Actualiza tu contraseña'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, '/change-password');
          },
        ),
        ListTile(
          leading: const Icon(Icons.fingerprint),
          title: const Text('Autenticación biométrica'),
          subtitle: const Text('Usar huella o Face ID'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implementar configuración biométrica
          },
        ),
      ],
    );

  Widget _buildSupportSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Soporte',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Centro de ayuda'),
          subtitle: const Text('Preguntas frecuentes y guías'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, '/help');
          },
        ),
        ListTile(
          leading: const Icon(Icons.contact_support),
          title: const Text('Contactar soporte'),
          subtitle: const Text('Envía un mensaje al equipo'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, '/contact-support');
          },
        ),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: const Text('Reportar problema'),
          subtitle: const Text('Informa sobre errores o problemas'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, '/report-bug');
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Acerca de'),
          subtitle: const Text('Versión ${AppConstants.appVersion}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showAboutDialog,
        ),
      ],
    );

  Widget _buildAccountSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Cuenta',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Descargar mis datos'),
          subtitle: const Text('Obtén una copia de tu información'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showDataDownloadDialog,
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text(
            'Eliminar cuenta',
            style: TextStyle(color: Colors.red),
          ),
          subtitle: const Text('Elimina permanentemente tu cuenta'),
          trailing: const Icon(Icons.chevron_right, color: Colors.red),
          onTap: _showDeleteAccountDialog,
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar sesión'),
          subtitle: const Text('Salir de tu cuenta'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showLogoutDialog,
        ),
        const SizedBox(height: 16),
      ],
    );

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'es',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: '© 2024 Salas & Beats. Todos los derechos reservados.',
      children: [
        const SizedBox(height: 16),
        const Text(AppConstants.appDescription),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            // TODO: Abrir términos de servicio
          },
          child: const Text('Términos de servicio'),
        ),
        TextButton(
          onPressed: () {
            // TODO: Abrir política de privacidad
          },
          child: const Text('Política de privacidad'),
        ),
      ],
    );
  }

  void _showDataDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descargar datos'),
        content: const Text(
          'Te enviaremos un archivo con todos tus datos a tu correo electrónico. Este proceso puede tardar hasta 24 horas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar descarga de datos
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Solicitud enviada. Recibirás un email pronto.'),
                ),
              );
            },
            child: const Text('Solicitar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          'Esta acción no se puede deshacer. Se eliminarán todos tus datos, reservas e información personal permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar eliminación de cuenta
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
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
}