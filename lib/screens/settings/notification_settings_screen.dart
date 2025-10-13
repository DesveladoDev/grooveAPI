import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _bookingNotifications = true;
  bool _messageNotifications = true;
  bool _promotionalNotifications = false;
  bool _reviewNotifications = true;
  bool _paymentNotifications = true;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('General'),
          _buildNotificationTile(
            title: 'Notificaciones push',
            subtitle: 'Recibir notificaciones en el dispositivo',
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          _buildNotificationTile(
            title: 'Notificaciones por email',
            subtitle: 'Recibir notificaciones por correo electrónico',
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Reservas'),
          _buildNotificationTile(
            title: 'Confirmaciones de reserva',
            subtitle: 'Notificaciones sobre el estado de tus reservas',
            value: _bookingNotifications,
            onChanged: (value) {
              setState(() {
                _bookingNotifications = value;
              });
            },
          ),
          _buildNotificationTile(
            title: 'Recordatorios de pago',
            subtitle: 'Recordatorios sobre pagos pendientes',
            value: _paymentNotifications,
            onChanged: (value) {
              setState(() {
                _paymentNotifications = value;
              });
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Comunicación'),
          _buildNotificationTile(
            title: 'Mensajes',
            subtitle: 'Notificaciones de nuevos mensajes',
            value: _messageNotifications,
            onChanged: (value) {
              setState(() {
                _messageNotifications = value;
              });
            },
          ),
          _buildNotificationTile(
            title: 'Reseñas',
            subtitle: 'Notificaciones sobre nuevas reseñas',
            value: _reviewNotifications,
            onChanged: (value) {
              setState(() {
                _reviewNotifications = value;
              });
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Marketing'),
          _buildNotificationTile(
            title: 'Ofertas y promociones',
            subtitle: 'Recibir ofertas especiales y promociones',
            value: _promotionalNotifications,
            onChanged: (value) {
              setState(() {
                _promotionalNotifications = value;
              });
            },
          ),
          
          const SizedBox(height: 32),
          _buildSaveButton(),
        ],
      ),
    );

  Widget _buildSectionHeader(String title) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600]),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Theme.of(context).primaryColor,
      ),
    );

  Widget _buildSaveButton() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Guardar configuración'),
      ),
    );

  void _saveSettings() {
    // TODO: Implement save settings logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada'),
        backgroundColor: Colors.green,
      ),
    );
  }
}