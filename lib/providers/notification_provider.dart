import 'dart:async';
import 'package:flutter/material.dart';
import 'package:salas_beats/models/notification_model.dart';
import 'package:salas_beats/services/notification_service.dart';
import 'package:salas_beats/utils/logger.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  // Estado de las notificaciones
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;
  
  // Configuración de notificaciones
  NotificationSettings _settings = const NotificationSettings();
  bool _isSettingsLoading = false;
  
  // Contadores
  int _unreadCount = 0;
  
  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  NotificationSettings get settings => _settings;
  bool get isSettingsLoading => _isSettingsLoading;
  int get unreadCount => _unreadCount;
  
  // Getters filtrados
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  
  List<NotificationModel> get todayNotifications => 
      _notifications.where((n) => n.isToday).toList();
  
  List<NotificationModel> get recentNotifications => 
      _notifications.where((n) => n.isRecent).toList();
  
  Map<String, List<NotificationModel>> get notificationsByType {
    final grouped = <String, List<NotificationModel>>{};
    for (final notification in _notifications) {
      if (!grouped.containsKey(notification.type)) {
        grouped[notification.type] = [];
      }
      grouped[notification.type]!.add(notification);
    }
    return grouped;
  }

  /// Inicializa el provider
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Inicializar el servicio de notificaciones
      await _notificationService.initialize();
      
      // Cargar configuración
      await loadSettings();
      
      // Suscribirse a las notificaciones
      _subscribeToNotifications();
      
      Logger.instance.info('NotificationProvider inicializado');
    } catch (e) {
      _setError('Error al inicializar notificaciones: $e');
      Logger.instance.error('Error al inicializar NotificationProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Se suscribe al stream de notificaciones
  void _subscribeToNotifications() {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = _notificationService
        .getUserNotifications()
        .listen(
          _onNotificationsReceived,
          onError: (Object error) {
            _setError('Error al cargar notificaciones: $error');
            Logger.instance.error('Error en stream de notificaciones: $error');
          },
        );
  }

  /// Maneja las notificaciones recibidas del stream
  void _onNotificationsReceived(List<NotificationModel> notifications) {
    _notifications = notifications;
    _updateUnreadCount();
    _clearError();
    notifyListeners();
  }

  /// Actualiza el contador de notificaciones no leídas
  void _updateUnreadCount() {
    final newUnreadCount = _notifications.where((n) => !n.isRead).length;
    if (_unreadCount != newUnreadCount) {
      _unreadCount = newUnreadCount;
      _notificationService.updateBadgeCount(_unreadCount);
    }
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      
      // Actualizar localmente
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].markAsRead();
        _updateUnreadCount();
        notifyListeners();
      }
      
      Logger.instance.info('Notificación marcada como leída: $notificationId');
    } catch (e) {
      _setError('Error al marcar notificación como leída: $e');
      Logger.instance.error('Error al marcar notificación como leída: $e');
    }
  }

  /// Marca todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    try {
      final unreadNotifications = _notifications.where((n) => !n.isRead).toList();
      
      for (final notification in unreadNotifications) {
        await _notificationService.markNotificationAsRead(notification.id);
      }
      
      // Actualizar localmente
      _notifications = _notifications.map((n) => n.isRead ? n : n.markAsRead()).toList();
      _updateUnreadCount();
      notifyListeners();
      
      Logger.instance.info('Todas las notificaciones marcadas como leídas');
    } catch (e) {
      _setError('Error al marcar todas las notificaciones como leídas: $e');
      Logger.instance.error('Error al marcar todas las notificaciones como leídas: $e');
    }
  }

  /// Elimina una notificación
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Actualizar localmente
      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      notifyListeners();
      
      Logger.instance.info('Notificación eliminada: $notificationId');
    } catch (e) {
      _setError('Error al eliminar notificación: $e');
      Logger.instance.error('Error al eliminar notificación: $e');
    }
  }

  /// Elimina todas las notificaciones
  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications();
      
      // Actualizar localmente
      _notifications.clear();
      _updateUnreadCount();
      notifyListeners();
      
      Logger.instance.info('Todas las notificaciones eliminadas');
    } catch (e) {
      _setError('Error al eliminar todas las notificaciones: $e');
      Logger.instance.error('Error al eliminar todas las notificaciones: $e');
    }
  }

  /// Envía una notificación a un usuario
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      await _notificationService.sendNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        data: data,
      );
      
      Logger.instance.info('Notificación enviada a usuario: $userId');
    } catch (e) {
      _setError('Error al enviar notificación: $e');
      Logger.instance.error('Error al enviar notificación: $e');
    }
  }

  /// Carga la configuración de notificaciones
  Future<void> loadSettings() async {
    try {
      _isSettingsLoading = true;
      notifyListeners();
      
      // Aquí cargarías la configuración desde Firestore o SharedPreferences
      // Por ahora usamos valores por defecto
      _settings = const NotificationSettings();
      
      Logger.instance.info('Configuración de notificaciones cargada');
    } catch (e) {
      Logger.instance.error('Error al cargar configuración de notificaciones: $e');
    } finally {
      _isSettingsLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza la configuración de notificaciones
  Future<void> updateSettings(NotificationSettings newSettings) async {
    try {
      _isSettingsLoading = true;
      notifyListeners();
      
      // Aquí guardarías la configuración en Firestore o SharedPreferences
      _settings = newSettings;
      
      Logger.instance.info('Configuración de notificaciones actualizada');
    } catch (e) {
      _setError('Error al actualizar configuración: $e');
      Logger.instance.error('Error al actualizar configuración de notificaciones: $e');
    } finally {
      _isSettingsLoading = false;
      notifyListeners();
    }
  }

  /// Filtra notificaciones por tipo
  List<NotificationModel> getNotificationsByType(String type) => _notifications.where((n) => n.type == type).toList();

  /// Filtra notificaciones por fecha
  List<NotificationModel> getNotificationsByDate(DateTime date) => _notifications.where((n) => n.createdAt.year == date.year &&
             n.createdAt.month == date.month &&
             n.createdAt.day == date.day,).toList();

  /// Busca notificaciones por texto
  List<NotificationModel> searchNotifications(String query) {
    if (query.isEmpty) return _notifications;
    
    final lowerQuery = query.toLowerCase();
    return _notifications.where((n) => n.title.toLowerCase().contains(lowerQuery) ||
             n.body.toLowerCase().contains(lowerQuery),).toList();
  }

  /// Obtiene estadísticas de notificaciones
  Map<String, int> getNotificationStats() {
    final stats = <String, int>{};
    
    stats['total'] = _notifications.length;
    stats['unread'] = unreadCount;
    stats['today'] = todayNotifications.length;
    stats['recent'] = recentNotifications.length;
    
    // Estadísticas por tipo
    for (final type in notificationsByType.keys) {
      stats[type] = notificationsByType[type]!.length;
    }
    
    return stats;
  }

  /// Verifica si hay notificaciones no leídas de un tipo específico
  bool hasUnreadNotificationsOfType(String type) => _notifications.any((n) => n.type == type && !n.isRead);

  /// Obtiene la última notificación de un tipo específico
  NotificationModel? getLatestNotificationOfType(String type) {
    final typeNotifications = getNotificationsByType(type);
    if (typeNotifications.isEmpty) return null;
    
    typeNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return typeNotifications.first;
  }

  /// Refresca las notificaciones
  Future<void> refresh() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Re-suscribirse al stream
      _subscribeToNotifications();
      
      Logger.instance.info('Notificaciones refrescadas');
    } catch (e) {
      _setError('Error al refrescar notificaciones: $e');
      Logger.instance.error('Error al refrescar notificaciones: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Limpia el token FCM (al cerrar sesión)
  Future<void> clearFCMToken() async {
    try {
      await _notificationService.clearFCMToken();
      Logger.instance.info('Token FCM limpiado');
    } catch (e) {
      Logger.instance.error('Error al limpiar token FCM: $e');
    }
  }

  // Métodos privados para manejo de estado
  
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    _notificationService.dispose();
    super.dispose();
  }
}

/// Extensión para facilitar el uso del provider
extension NotificationProviderExtension on NotificationProvider {
  /// Verifica si hay errores
  bool get hasError => error != null;
  
  /// Verifica si hay notificaciones
  bool get hasNotifications => notifications.isNotEmpty;
  
  /// Verifica si hay notificaciones no leídas
  bool get hasUnreadNotifications => unreadCount > 0;
  
  /// Obtiene el texto del contador de no leídas
  String get unreadCountText {
    if (unreadCount == 0) return '';
    if (unreadCount > 99) return '99+';
    return unreadCount.toString();
  }
}