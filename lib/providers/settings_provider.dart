import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _pushNotificationsKey = 'push_notifications_enabled';
  static const String _emailNotificationsKey = 'email_notifications_enabled';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _autoPlayVideosKey = 'auto_play_videos';
  static const String _dataSaverKey = 'data_saver_mode';
  static const String _locationSharingKey = 'location_sharing_enabled';
  static const String _analyticsKey = 'analytics_enabled';
  static const String _crashReportingKey = 'crash_reporting_enabled';
  static const String _biometricAuthKey = 'biometric_auth_enabled';
  static const String _autoLockTimeoutKey = 'auto_lock_timeout';
  static const String _chatBackupKey = 'chat_backup_enabled';
  static const String _mediaQualityKey = 'media_quality';
  static const String _downloadOverWifiKey = 'download_over_wifi_only';


  SharedPreferences? _prefs;

  // Theme settings
  ThemeMode _themeMode = ThemeMode.system;
  String _languageCode = 'es';

  // Notification settings
  bool _notificationsEnabled = true;
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Media settings
  bool _autoPlayVideos = false;
  bool _dataSaverMode = false;
  String _mediaQuality = 'high'; // low, medium, high
  bool _downloadOverWifiOnly = true;

  // Privacy settings
  bool _locationSharingEnabled = true;
  bool _analyticsEnabled = true;
  bool _crashReportingEnabled = true;

  // Security settings
  bool _biometricAuthEnabled = false;
  int _autoLockTimeout = 300; // seconds

  // Backup settings
  bool _chatBackupEnabled = true;

  bool _isLoading = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get emailNotificationsEnabled => _emailNotificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get autoPlayVideos => _autoPlayVideos;
  bool get dataSaverMode => _dataSaverMode;
  String get mediaQuality => _mediaQuality;
  bool get downloadOverWifiOnly => _downloadOverWifiOnly;
  bool get locationSharingEnabled => _locationSharingEnabled;
  bool get analyticsEnabled => _analyticsEnabled;
  bool get crashReportingEnabled => _crashReportingEnabled;
  bool get biometricAuthEnabled => _biometricAuthEnabled;
  int get autoLockTimeout => _autoLockTimeout;
  bool get chatBackupEnabled => _chatBackupEnabled;
  bool get isLoading => _isLoading;
  
  Map<String, dynamic> get privacySettings => {
    'locationSharing': _locationSharingEnabled,
    'analytics': _analyticsEnabled,
    'crashReporting': _crashReportingEnabled,
    'emailNotifications': _emailNotificationsEnabled,
  };

  // Computed getters
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isSystemTheme => _themeMode == ThemeMode.system;
  
  String get autoLockTimeoutText {
    if (_autoLockTimeout <= 0) return 'Nunca';
    if (_autoLockTimeout < 60) return '${_autoLockTimeout}s';
    if (_autoLockTimeout < 3600) return '${(_autoLockTimeout / 60).round()}m';
    return '${(_autoLockTimeout / 3600).round()}h';
  }

  String get mediaQualityText {
    switch (_mediaQuality) {
      case 'low':
        return 'Baja';
      case 'medium':
        return 'Media';
      case 'high':
        return 'Alta';
      default:
        return 'Alta';
    }
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSettings();
    } catch (e) {
      debugPrint('Error initializing settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    if (_prefs == null) return;

    // Theme settings
    final themeIndex = _prefs!.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    _languageCode = _prefs!.getString(_languageKey) ?? 'es';

    // Notification settings
    _notificationsEnabled = _prefs!.getBool(_notificationsKey) ?? true;
    _pushNotificationsEnabled = _prefs!.getBool(_pushNotificationsKey) ?? true;
    _emailNotificationsEnabled = _prefs!.getBool(_emailNotificationsKey) ?? true;
    _soundEnabled = _prefs!.getBool(_soundEnabledKey) ?? true;
    _vibrationEnabled = _prefs!.getBool(_vibrationEnabledKey) ?? true;

    // Media settings
    _autoPlayVideos = _prefs!.getBool(_autoPlayVideosKey) ?? false;
    _dataSaverMode = _prefs!.getBool(_dataSaverKey) ?? false;
    _mediaQuality = _prefs!.getString(_mediaQualityKey) ?? 'high';
    _downloadOverWifiOnly = _prefs!.getBool(_downloadOverWifiKey) ?? true;

    // Privacy settings
    _locationSharingEnabled = _prefs!.getBool(_locationSharingKey) ?? true;
    _analyticsEnabled = _prefs!.getBool(_analyticsKey) ?? true;
    _crashReportingEnabled = _prefs!.getBool(_crashReportingKey) ?? true;

    // Security settings
    _biometricAuthEnabled = _prefs!.getBool(_biometricAuthKey) ?? false;
    _autoLockTimeout = _prefs!.getInt(_autoLockTimeoutKey) ?? 300;

    // Backup settings
    _chatBackupEnabled = _prefs!.getBool(_chatBackupKey) ?? true;
  }

  // Theme methods
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    await _prefs?.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (_languageCode == languageCode) return;
    
    _languageCode = languageCode;
    await _prefs?.setString(_languageKey, languageCode);
    notifyListeners();
  }

  // Notification methods
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;
    
    _notificationsEnabled = enabled;
    await _prefs?.setBool(_notificationsKey, enabled);
    
    if (enabled) {
      // TODO: Implement requestPermissions in NotificationService
    } else {
      // TODO: Implement disableNotifications in NotificationService
    }
    
    notifyListeners();
  }

  Future<void> setPushNotificationsEnabled(bool enabled) async {
    if (_pushNotificationsEnabled == enabled) return;
    
    _pushNotificationsEnabled = enabled;
    await _prefs?.setBool(_pushNotificationsKey, enabled);
    
    if (enabled && _notificationsEnabled) {
      // TODO: Implement enablePushNotifications in NotificationService
    } else {
      // TODO: Implement disablePushNotifications in NotificationService
    }
    
    notifyListeners();
  }

  Future<void> setEmailNotificationsEnabled(bool enabled) async {
    if (_emailNotificationsEnabled == enabled) return;
    
    _emailNotificationsEnabled = enabled;
    await _prefs?.setBool(_emailNotificationsKey, enabled);
    
    // Update user preferences on server
    try {
      // TODO: Implement updateUserPreferences in AuthService
      // await _authService.updateUserPreferences({
      //   'emailNotifications': enabled,
      // });
    } catch (e) {
      debugPrint('Error updating email notification preference: $e');
    }
    
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    if (_soundEnabled == enabled) return;
    
    _soundEnabled = enabled;
    await _prefs?.setBool(_soundEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    if (_vibrationEnabled == enabled) return;
    
    _vibrationEnabled = enabled;
    await _prefs?.setBool(_vibrationEnabledKey, enabled);
    notifyListeners();
  }

  // Media methods
  Future<void> setAutoPlayVideos(bool enabled) async {
    if (_autoPlayVideos == enabled) return;
    
    _autoPlayVideos = enabled;
    await _prefs?.setBool(_autoPlayVideosKey, enabled);
    notifyListeners();
  }

  Future<void> setDataSaverMode(bool enabled) async {
    if (_dataSaverMode == enabled) return;
    
    _dataSaverMode = enabled;
    await _prefs?.setBool(_dataSaverKey, enabled);
    notifyListeners();
  }

  Future<void> setMediaQuality(String quality) async {
    if (_mediaQuality == quality) return;
    
    _mediaQuality = quality;
    await _prefs?.setString(_mediaQualityKey, quality);
    notifyListeners();
  }

  Future<void> setDownloadOverWifiOnly(bool enabled) async {
    if (_downloadOverWifiOnly == enabled) return;
    
    _downloadOverWifiOnly = enabled;
    await _prefs?.setBool(_downloadOverWifiKey, enabled);
    notifyListeners();
  }

  // Privacy methods
  Future<void> setLocationSharingEnabled(bool enabled) async {
    if (_locationSharingEnabled == enabled) return;
    
    _locationSharingEnabled = enabled;
    await _prefs?.setBool(_locationSharingKey, enabled);
    
    // Update user preferences on server
    try {
      // Note: For now we just store locally, server sync can be added later
      debugPrint('Location sharing preference updated locally');
    } catch (e) {
      debugPrint('Error updating location sharing preference: $e');
    }
    
    notifyListeners();
  }

  // Actualizar configuraciones de privacidad
  Future<void> updatePrivacySettings(Map<String, dynamic> settings) async {
    try {
      if (settings.containsKey('locationSharing')) {
        await setLocationSharingEnabled(settings['locationSharing'] as bool);
      }
      if (settings.containsKey('analytics')) {
        await setAnalyticsEnabled(settings['analytics'] as bool);
      }
      if (settings.containsKey('crashReporting')) {
        await setCrashReportingEnabled(settings['crashReporting'] as bool);
      }
      if (settings.containsKey('emailNotifications')) {
        await setEmailNotificationsEnabled(settings['emailNotifications'] as bool);
      }
    } catch (e) {
      debugPrint('Error updating privacy settings: $e');
      rethrow;
    }
  }

  Future<void> loadPrivacySettings() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _loadSettings();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setAnalyticsEnabled(bool enabled) async {
    if (_analyticsEnabled == enabled) return;
    
    _analyticsEnabled = enabled;
    await _prefs?.setBool(_analyticsKey, enabled);
    notifyListeners();
  }

  Future<void> setCrashReportingEnabled(bool enabled) async {
    if (_crashReportingEnabled == enabled) return;
    
    _crashReportingEnabled = enabled;
    await _prefs?.setBool(_crashReportingKey, enabled);
    notifyListeners();
  }

  // Security methods
  Future<void> setBiometricAuthEnabled(bool enabled) async {
    if (_biometricAuthEnabled == enabled) return;
    
    _biometricAuthEnabled = enabled;
    await _prefs?.setBool(_biometricAuthKey, enabled);
    notifyListeners();
  }

  Future<void> setAutoLockTimeout(int seconds) async {
    if (_autoLockTimeout == seconds) return;
    
    _autoLockTimeout = seconds;
    await _prefs?.setInt(_autoLockTimeoutKey, seconds);
    notifyListeners();
  }

  // Backup methods
  Future<void> setChatBackupEnabled(bool enabled) async {
    if (_chatBackupEnabled == enabled) return;
    
    _chatBackupEnabled = enabled;
    await _prefs?.setBool(_chatBackupKey, enabled);
    notifyListeners();
  }

  Future<void> performChatBackup() async {
    try {
      // TODO: Implement chat backup logic
      await Future<void>.delayed(const Duration(seconds: 2)); // Simulate backup
    } catch (e) {
      debugPrint('Error performing chat backup: $e');
      rethrow;
    }
  }

  Future<void> restoreChatBackup() async {
    try {
      // TODO: Implement chat restore logic
      await Future<void>.delayed(const Duration(seconds: 3)); // Simulate restore
    } catch (e) {
      debugPrint('Error restoring chat backup: $e');
      rethrow;
    }
  }

  // Utility methods
  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _languageCode = 'es';
    _notificationsEnabled = true;
    _pushNotificationsEnabled = true;
    _emailNotificationsEnabled = true;
    _soundEnabled = true;
    _vibrationEnabled = true;
    _autoPlayVideos = false;
    _dataSaverMode = false;
    _mediaQuality = 'high';
    _downloadOverWifiOnly = true;
    _locationSharingEnabled = true;
    _analyticsEnabled = true;
    _crashReportingEnabled = true;
    _biometricAuthEnabled = false;
    _autoLockTimeout = 300;
    _chatBackupEnabled = true;

    await _prefs?.clear();
    await _saveAllSettings();
    notifyListeners();
  }

  Future<void> _saveAllSettings() async {
    if (_prefs == null) return;

    await Future.wait([
      _prefs!.setInt(_themeKey, _themeMode.index),
      _prefs!.setString(_languageKey, _languageCode),
      _prefs!.setBool(_notificationsKey, _notificationsEnabled),
      _prefs!.setBool(_pushNotificationsKey, _pushNotificationsEnabled),
      _prefs!.setBool(_emailNotificationsKey, _emailNotificationsEnabled),
      _prefs!.setBool(_soundEnabledKey, _soundEnabled),
      _prefs!.setBool(_vibrationEnabledKey, _vibrationEnabled),
      _prefs!.setBool(_autoPlayVideosKey, _autoPlayVideos),
      _prefs!.setBool(_dataSaverKey, _dataSaverMode),
      _prefs!.setString(_mediaQualityKey, _mediaQuality),
      _prefs!.setBool(_downloadOverWifiKey, _downloadOverWifiOnly),
      _prefs!.setBool(_locationSharingKey, _locationSharingEnabled),
      _prefs!.setBool(_analyticsKey, _analyticsEnabled),
      _prefs!.setBool(_crashReportingKey, _crashReportingEnabled),
      _prefs!.setBool(_biometricAuthKey, _biometricAuthEnabled),
      _prefs!.setInt(_autoLockTimeoutKey, _autoLockTimeout),
      _prefs!.setBool(_chatBackupKey, _chatBackupEnabled),
    ]);
  }

  Future<Map<String, dynamic>> exportSettings() async => {
      'theme': _themeMode.index,
      'language': _languageCode,
      'notifications': _notificationsEnabled,
      'pushNotifications': _pushNotificationsEnabled,
      'emailNotifications': _emailNotificationsEnabled,
      'sound': _soundEnabled,
      'vibration': _vibrationEnabled,
      'autoPlayVideos': _autoPlayVideos,
      'dataSaver': _dataSaverMode,
      'mediaQuality': _mediaQuality,
      'downloadOverWifiOnly': _downloadOverWifiOnly,
      'locationSharing': _locationSharingEnabled,
      'analytics': _analyticsEnabled,
      'crashReporting': _crashReportingEnabled,
      'biometricAuth': _biometricAuthEnabled,
      'autoLockTimeout': _autoLockTimeout,
      'chatBackup': _chatBackupEnabled,
    };

  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      _themeMode = ThemeMode.values[(settings['theme'] ?? 0) as int];
      _languageCode = (settings['language'] ?? 'es') as String;
      _notificationsEnabled = (settings['notifications'] ?? true) as bool;
      _pushNotificationsEnabled = (settings['pushNotifications'] ?? true) as bool;
      _emailNotificationsEnabled = (settings['emailNotifications'] ?? true) as bool;
      _soundEnabled = (settings['sound'] ?? true) as bool;
      _vibrationEnabled = (settings['vibration'] ?? true) as bool;
      _autoPlayVideos = (settings['autoPlayVideos'] ?? false) as bool;
      _dataSaverMode = (settings['dataSaver'] ?? false) as bool;
      _mediaQuality = (settings['mediaQuality'] ?? 'high') as String;
      _downloadOverWifiOnly = (settings['downloadOverWifiOnly'] ?? true) as bool;
      _locationSharingEnabled = (settings['locationSharing'] ?? true) as bool;
      _analyticsEnabled = (settings['analytics'] ?? true) as bool;
      _crashReportingEnabled = (settings['crashReporting'] ?? true) as bool;
      _biometricAuthEnabled = (settings['biometricAuth'] ?? false) as bool;
      _autoLockTimeout = (settings['autoLockTimeout'] ?? 300) as int;
      _chatBackupEnabled = (settings['chatBackup'] ?? true) as bool;

      await _saveAllSettings();
      notifyListeners();
    } catch (e) {
      debugPrint('Error importing settings: $e');
      rethrow;
    }
  }

}