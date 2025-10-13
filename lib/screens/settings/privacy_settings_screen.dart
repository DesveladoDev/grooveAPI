import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/providers/settings_provider.dart';
import 'package:salas_beats/widgets/common/loading_widget.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Privacy settings
  bool _profileVisibility = true;
  bool _showOnlineStatus = true;
  bool _allowDirectMessages = true;
  bool _shareLocationData = false;
  bool _allowDataAnalytics = true;
  bool _allowMarketingEmails = false;
  bool _allowPushNotifications = true;
  bool _shareActivityData = false;
  bool _allowThirdPartyIntegrations = false;
  bool _enableTwoFactorAuth = false;
  
  String _dataRetentionPeriod = '2_years';
  String _profileVisibilityLevel = 'public';
  String _messagePrivacyLevel = 'friends';

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settingsProvider = context.read<SettingsProvider>();
      await settingsProvider.loadPrivacySettings();
      
      // Load current settings
      final settings = settingsProvider.privacySettings;
      setState(() {
        _profileVisibility = settings['profileVisibility'] as bool? ?? true;
        _showOnlineStatus = settings['showOnlineStatus'] as bool? ?? true;
        _allowDirectMessages = settings['allowDirectMessages'] as bool? ?? true;
        _shareLocationData = settings['locationSharing'] as bool? ?? false;
        _allowDataAnalytics = settings['analytics'] as bool? ?? true;
        _allowMarketingEmails = settings['emailNotifications'] as bool? ?? false;
        _allowPushNotifications = settings['allowPushNotifications'] as bool? ?? true;
        _shareActivityData = settings['shareActivityData'] as bool? ?? false;
        _allowThirdPartyIntegrations = settings['allowThirdPartyIntegrations'] as bool? ?? false;
        _enableTwoFactorAuth = settings['enableTwoFactorAuth'] as bool? ?? false;
        _dataRetentionPeriod = settings['dataRetentionPeriod'] as String? ?? '2_years';
        _profileVisibilityLevel = settings['profileVisibilityLevel'] as String? ?? 'public';
        _messagePrivacyLevel = settings['messagePrivacyLevel'] as String? ?? 'friends';
      });
    } catch (e) {
      _showErrorSnackBar('Error al cargar configuración de privacidad');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: LoadingWidget(message: 'Cargando configuración...'))
          : _buildContent(),
    );

  PreferredSizeWidget _buildAppBar() => AppBar(
      title: const Text('Configuración de Privacidad'),
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Guardar'),
          ),
      ],
    );

  Widget _buildContent() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfilePrivacySection(),
          const SizedBox(height: 24),
          _buildCommunicationPrivacySection(),
          const SizedBox(height: 24),
          _buildDataPrivacySection(),
          const SizedBox(height: 24),
          _buildSecuritySection(),
          const SizedBox(height: 24),
          _buildDataUsageSection(),
          const SizedBox(height: 24),
          _buildAdvancedOptionsSection(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );

  Widget _buildProfilePrivacySection() => _buildSection(
      title: 'Privacidad del Perfil',
      description: 'Controla quién puede ver tu información personal',
      children: [
        _privacyOptionTile(
          title: 'Perfil visible',
          subtitle: 'Permite que otros usuarios vean tu perfil',
          value: _profileVisibility,
          onChanged: (value) {
            setState(() {
              _profileVisibility = value;
            });
          },
        ),
        _privacyOptionTile(
          title: 'Mostrar estado en línea',
          subtitle: 'Otros usuarios pueden ver cuando estás conectado',
          value: _showOnlineStatus,
          onChanged: (value) {
            setState(() {
              _showOnlineStatus = value;
            });
          },
        ),
        _buildDropdownTile(
          title: 'Nivel de visibilidad del perfil',
          value: _profileVisibilityLevel,
          items: {
            'public': 'Público',
            'friends': 'Solo amigos',
            'private': 'Privado',
          },
          onChanged: (value) {
            setState(() {
              _profileVisibilityLevel = value!;
            });
          },
        ),
      ],
    );

  Widget _buildCommunicationPrivacySection() => _buildSection(
      title: 'Privacidad de Comunicación',
      description: 'Gestiona cómo otros pueden contactarte',
      children: [
        _privacyOptionTile(
          title: 'Permitir mensajes directos',
          subtitle: 'Otros usuarios pueden enviarte mensajes privados',
          value: _allowDirectMessages,
          onChanged: (value) {
            setState(() {
              _allowDirectMessages = value;
            });
          },
        ),
        _privacyOptionTile(
          title: 'Notificaciones push',
          subtitle: 'Recibir notificaciones en tu dispositivo',
          value: _allowPushNotifications,
          onChanged: (value) {
            setState(() {
              _allowPushNotifications = value;
            });
          },
        ),
        _buildDropdownTile(
          title: 'Privacidad de mensajes',
          value: _messagePrivacyLevel,
          items: {
            'everyone': 'Todos',
            'friends': 'Solo amigos',
            'nobody': 'Nadie',
          },
          onChanged: (value) {
            setState(() {
              _messagePrivacyLevel = value!;
            });
          },
        ),
      ],
    );

  Widget _buildDataPrivacySection() => _buildSection(
      title: 'Privacidad de Datos',
      description: 'Controla cómo se utilizan tus datos',
      children: [
        _privacyOptionTile(
          title: 'Compartir datos de ubicación',
          subtitle: 'Permitir el uso de tu ubicación para mejorar el servicio',
          value: _shareLocationData,
          onChanged: (value) {
            setState(() {
              _shareLocationData = value;
            });
          },
        ),
        _privacyOptionTile(
          title: 'Análisis de datos',
          subtitle: 'Ayudar a mejorar la app compartiendo datos de uso anónimos',
          value: _allowDataAnalytics,
          onChanged: (value) {
            setState(() {
              _allowDataAnalytics = value;
            });
          },
        ),
        _privacyOptionTile(
          title: 'Compartir datos de actividad',
          subtitle: 'Permitir que se compartan datos sobre tu actividad en la app',
          value: _shareActivityData,
          onChanged: (value) {
            setState(() {
              _shareActivityData = value;
            });
          },
        ),
        _privacyOptionTile(
          title: 'Emails de marketing',
          subtitle: 'Recibir ofertas y promociones por email',
          value: _allowMarketingEmails,
          onChanged: (value) {
            setState(() {
              _allowMarketingEmails = value;
            });
          },
        ),
        _buildDropdownTile(
          title: 'Período de retención de datos',
          value: _dataRetentionPeriod,
          items: {
            '1_year': '1 año',
            '2_years': '2 años',
            '5_years': '5 años',
            'indefinite': 'Indefinido',
          },
          onChanged: (value) {
            setState(() {
              _dataRetentionPeriod = value!;
            });
          },
        ),
      ],
    );

  Widget _buildSecuritySection() => _buildSection(
      title: 'Seguridad',
      description: 'Configuraciones adicionales de seguridad',
      children: [
        _privacyOptionTile(
          title: 'Autenticación de dos factores',
          subtitle: 'Añade una capa extra de seguridad a tu cuenta',
          value: _enableTwoFactorAuth,
          onChanged: (value) {
            setState(() {
              _enableTwoFactorAuth = value;
            });
            if (value) {
              _showTwoFactorSetupDialog();
            }
          },
        ),
        _privacyOptionTile(
          title: 'Integraciones de terceros',
          subtitle: 'Permitir que aplicaciones externas accedan a tu cuenta',
          value: _allowThirdPartyIntegrations,
          onChanged: (value) {
            setState(() {
              _allowThirdPartyIntegrations = value;
            });
          },
        ),
        ListTile(
          title: const Text('Gestionar sesiones activas'),
          subtitle: const Text('Ver y cerrar sesiones en otros dispositivos'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showActiveSessionsDialog,
        ),
        ListTile(
          title: const Text('Cambiar contraseña'),
          subtitle: const Text('Actualizar tu contraseña de acceso'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showChangePasswordDialog,
        ),
      ],
    );

  Widget _buildDataUsageSection() => _buildSection(
      title: 'Uso de Datos',
      description: 'Información sobre cómo se utilizan tus datos',
      children: [
        _dataUsageCard(
          title: 'Uso de Datos',
          description: 'Información sobre cómo se utilizan tus datos',
          currentUsage: '2.5 GB',
          limit: '5 GB',
          onTap: _showDataUsageDetails,
        ),
      ],
    );

  Widget _buildAdvancedOptionsSection() => _buildSection(
      title: 'Opciones Avanzadas',
      description: 'Configuraciones adicionales de privacidad',
      children: [
        ListTile(
          title: const Text('Política de Privacidad'),
          subtitle: const Text('Lee nuestra política de privacidad completa'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
        ),
        ListTile(
          title: const Text('Términos de Servicio'),
          subtitle: const Text('Consulta nuestros términos y condiciones'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => Navigator.pushNamed(context, '/terms-of-service'),
        ),
        ListTile(
          title: const Text('Configuración de Cookies'),
          subtitle: const Text('Gestiona las preferencias de cookies'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showCookieSettings,
        ),
      ],
    );

  Widget _buildActionButtons() => Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveSettings,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar Configuración'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _resetToDefaults,
            child: const Text('Restaurar Valores por Defecto'),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showDeleteAccountDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar Cuenta'),
          ),
        ),
      ],
    );

  Widget _buildSection({
    required String title,
    required String description,
    required List<Widget> children,
  }) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) => ListTile(
      title: Text(title),
      subtitle: Text(items[value] ?? value),
      trailing: DropdownButton<String>(
        value: value,
        underline: Container(),
        items: items.entries.map((entry) => DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          ),).toList(),
        onChanged: onChanged,
      ),
    );

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final settingsProvider = context.read<SettingsProvider>();
      final privacyData = <String, dynamic>{
        'locationSharing': _shareLocationData,
        'analytics': _allowDataAnalytics,
        'crashReporting': true, // Default value since not in UI
        'emailNotifications': _allowMarketingEmails,
      };
      await settingsProvider.updatePrivacySettings(privacyData);
      
      _showSuccessSnackBar('Configuración guardada correctamente');
    } catch (e) {
      _showErrorSnackBar('Error al guardar configuración: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _resetToDefaults() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Valores por Defecto'),
        content: const Text(
          '¿Estás seguro de que quieres restaurar todas las configuraciones de privacidad a sus valores por defecto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _profileVisibility = true;
                _showOnlineStatus = true;
                _allowDirectMessages = true;
                _shareLocationData = false;
                _allowDataAnalytics = true;
                _allowMarketingEmails = false;
                _allowPushNotifications = true;
                _shareActivityData = false;
                _allowThirdPartyIntegrations = false;
                _enableTwoFactorAuth = false;
                _dataRetentionPeriod = '2_years';
                _profileVisibilityLevel = 'public';
                _messagePrivacyLevel = 'friends';
              });
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorSetupDialog() {
    // TODO: Implementar configuración de 2FA
    _showErrorSnackBar('Configuración de 2FA próximamente');
  }

  void _showActiveSessionsDialog() {
    // TODO: Implementar gestión de sesiones activas
    _showErrorSnackBar('Gestión de sesiones próximamente');
  }

  void _showChangePasswordDialog() {
    // TODO: Implementar cambio de contraseña
    Navigator.pushNamed(context, '/change-password');
  }

  void _showDataUsageDetails() {
    // TODO: Implementar detalles de uso de datos
    _showErrorSnackBar('Detalles de uso de datos próximamente');
  }

  void _downloadUserData() {
    // TODO: Implementar descarga de datos del usuario
    _showErrorSnackBar('Descarga de datos próximamente');
  }

  void _showDeleteDataDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Datos'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todos tus datos? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar eliminación de datos
              _showErrorSnackBar('Eliminación de datos próximamente');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showCookieSettings() {
    // TODO: Implementar configuración de cookies
    _showErrorSnackBar('Configuración de cookies próximamente');
  }

  void _showDeleteAccountDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cuenta'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer y perderás todos tus datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/delete-account');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar Cuenta'),
          ),
        ],
      ),
    );
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

  Widget _privacyOptionTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
  }) => Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600]),
        ),
        value: value,
        onChanged: onChanged,
        secondary: icon != null ? Icon(icon) : null,
        activeThumbColor: Theme.of(context).primaryColor,
      ),
    );

  Widget _dataUsageCard({
    required String title,
    required String description,
    required String currentUsage,
    required String limit,
    VoidCallback? onTap,
  }) => Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Uso actual: ',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  currentUsage,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  'Límite: ',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  limit,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios) : null,
        onTap: onTap,
      ),
    );
}