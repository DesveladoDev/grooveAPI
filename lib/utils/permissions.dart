import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionType {
  camera,
  photos,
  microphone,
  location,
  locationWhenInUse,
  locationAlways,
  notification,
  storage,
  contacts,
  calendar,
  reminders,
  speech,
  mediaLibrary,
  bluetooth,
  bluetoothScan,
  bluetoothAdvertise,
  bluetoothConnect,
}

class PermissionResult {
  
  const PermissionResult({
    required this.isGranted,
    required this.isPermanentlyDenied,
    required this.shouldShowRationale,
    required this.status,
    this.errorMessage,
  });
  
  factory PermissionResult.fromStatus(PermissionStatus status) => PermissionResult(
      isGranted: status.isGranted,
      isPermanentlyDenied: status.isPermanentlyDenied,
      shouldShowRationale: status.isDenied && !status.isPermanentlyDenied,
      status: status,
    );
  
  factory PermissionResult.error(String message) => PermissionResult(
      isGranted: false,
      isPermanentlyDenied: false,
      shouldShowRationale: false,
      status: PermissionStatus.denied,
      errorMessage: message,
    );
  final bool isGranted;
  final bool isPermanentlyDenied;
  final bool shouldShowRationale;
  final PermissionStatus status;
  final String? errorMessage;
}

class PermissionManager {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  // Permission mapping
  static Permission _getPermission(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return Permission.camera;
      case PermissionType.photos:
        return Permission.photos;
      case PermissionType.microphone:
        return Permission.microphone;
      case PermissionType.location:
        return Permission.location;
      case PermissionType.locationWhenInUse:
        return Permission.locationWhenInUse;
      case PermissionType.locationAlways:
        return Permission.locationAlways;
      case PermissionType.notification:
        return Permission.notification;
      case PermissionType.storage:
        return Permission.storage;
      case PermissionType.contacts:
        return Permission.contacts;
      case PermissionType.calendar:
        return Permission.calendarWriteOnly;
      case PermissionType.reminders:
        return Permission.reminders;
      case PermissionType.speech:
        return Permission.speech;
      case PermissionType.mediaLibrary:
        return Permission.mediaLibrary;
      case PermissionType.bluetooth:
        return Permission.bluetooth;
      case PermissionType.bluetoothScan:
        return Permission.bluetoothScan;
      case PermissionType.bluetoothAdvertise:
        return Permission.bluetoothAdvertise;
      case PermissionType.bluetoothConnect:
        return Permission.bluetoothConnect;
    }
  }
  
  // Get permission name for display
  static String getPermissionName(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return 'Cámara';
      case PermissionType.photos:
        return 'Fotos';
      case PermissionType.microphone:
        return 'Micrófono';
      case PermissionType.location:
      case PermissionType.locationWhenInUse:
      case PermissionType.locationAlways:
        return 'Ubicación';
      case PermissionType.notification:
        return 'Notificaciones';
      case PermissionType.storage:
        return 'Almacenamiento';
      case PermissionType.contacts:
        return 'Contactos';
      case PermissionType.calendar:
        return 'Calendario';
      case PermissionType.reminders:
        return 'Recordatorios';
      case PermissionType.speech:
        return 'Reconocimiento de voz';
      case PermissionType.mediaLibrary:
        return 'Biblioteca multimedia';
      case PermissionType.bluetooth:
      case PermissionType.bluetoothScan:
      case PermissionType.bluetoothAdvertise:
      case PermissionType.bluetoothConnect:
        return 'Bluetooth';
    }
  }
  
  // Get permission description
  static String getPermissionDescription(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return 'Necesario para tomar fotos de las salas y equipos';
      case PermissionType.photos:
        return 'Necesario para seleccionar fotos de la galería';
      case PermissionType.microphone:
        return 'Necesario para grabar audio y probar equipos de sonido';
      case PermissionType.location:
      case PermissionType.locationWhenInUse:
      case PermissionType.locationAlways:
        return 'Necesario para encontrar salas cercanas y mostrar ubicaciones';
      case PermissionType.notification:
        return 'Necesario para recibir notificaciones de reservas y mensajes';
      case PermissionType.storage:
        return 'Necesario para guardar archivos y datos de la aplicación';
      case PermissionType.contacts:
        return 'Necesario para invitar contactos a eventos';
      case PermissionType.calendar:
        return 'Necesario para agregar eventos de reservas al calendario';
      case PermissionType.reminders:
        return 'Necesario para crear recordatorios de reservas';
      case PermissionType.speech:
        return 'Necesario para búsqueda por voz';
      case PermissionType.mediaLibrary:
        return 'Necesario para acceder a archivos multimedia';
      case PermissionType.bluetooth:
      case PermissionType.bluetoothScan:
      case PermissionType.bluetoothAdvertise:
      case PermissionType.bluetoothConnect:
        return 'Necesario para conectar con equipos de audio Bluetooth';
    }
  }
  
  // Check if permission is supported on current platform
  static bool isPermissionSupported(PermissionType type) {
    if (Platform.isIOS) {
      switch (type) {
        case PermissionType.storage:
        case PermissionType.bluetoothScan:
        case PermissionType.bluetoothAdvertise:
        case PermissionType.bluetoothConnect:
          return false;
        default:
          return true;
      }
    } else if (Platform.isAndroid) {
      switch (type) {
        case PermissionType.reminders:
        case PermissionType.mediaLibrary:
          return false;
        default:
          return true;
      }
    }
    return false;
  }
  
  // Check single permission status
  static Future<PermissionResult> checkPermission(PermissionType type) async {
    try {
      if (!isPermissionSupported(type)) {
        return PermissionResult.error('Permiso no soportado en esta plataforma');
      }
      
      final permission = _getPermission(type);
      final status = await permission.status;
      
      return PermissionResult.fromStatus(status);
    } catch (e) {
      return PermissionResult.error('Error al verificar permisos: $e');
    }
  }
  
  // Request single permission
  static Future<PermissionResult> requestPermission(PermissionType type) async {
    try {
      if (!isPermissionSupported(type)) {
        return PermissionResult.error('Permiso no soportado en esta plataforma');
      }
      
      final permission = _getPermission(type);
      final status = await permission.request();
      
      return PermissionResult.fromStatus(status);
    } catch (e) {
      return PermissionResult.error('Error al solicitar permisos: $e');
    }
  }
  
  // Check multiple permissions
  static Future<Map<PermissionType, PermissionResult>> checkPermissions(
    List<PermissionType> types,
  ) async {
    final results = <PermissionType, PermissionResult>{};
    
    for (final type in types) {
      results[type] = await checkPermission(type);
    }
    
    return results;
  }
  
  // Request multiple permissions
  static Future<Map<PermissionType, PermissionResult>> requestPermissions(
    List<PermissionType> types,
  ) async {
    try {
      final supportedTypes = types.where(isPermissionSupported).toList();
      final permissions = supportedTypes.map(_getPermission).toList();
      
      final statuses = await permissions.request();
      final results = <PermissionType, PermissionResult>{};
      
      for (var i = 0; i < supportedTypes.length; i++) {
        final type = supportedTypes[i];
        final permission = permissions[i];
        final status = statuses[permission] ?? PermissionStatus.denied;
        
        results[type] = PermissionResult.fromStatus(status);
      }
      
      // Add unsupported permissions as errors
      for (final type in types.where((t) => !isPermissionSupported(t))) {
        results[type] = PermissionResult.error('Permiso no soportado');
      }
      
      return results;
    } catch (e) {
      final results = <PermissionType, PermissionResult>{};
      for (final type in types) {
        results[type] = PermissionResult.error('Error al solicitar permisos: $e');
      }
      return results;
    }
  }
  
  // Check if all permissions are granted
  static bool areAllPermissionsGranted(Map<PermissionType, PermissionResult> results) => results.values.every((result) => result.isGranted);
  
  // Get denied permissions
  static List<PermissionType> getDeniedPermissions(
    Map<PermissionType, PermissionResult> results,
  ) => results.entries
        .where((entry) => !entry.value.isGranted)
        .map((entry) => entry.key)
        .toList();
  
  // Get permanently denied permissions
  static List<PermissionType> getPermanentlyDeniedPermissions(
    Map<PermissionType, PermissionResult> results,
  ) => results.entries
        .where((entry) => entry.value.isPermanentlyDenied)
        .map((entry) => entry.key)
        .toList();
  
  // Open app settings
  static Future<bool> openAppSettings() async {
    try {
      await AppSettings.openAppSettings();
      return true;
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }
  
  // Show permission dialog
  static Future<bool?> showPermissionDialog(
    BuildContext context,
    PermissionType type, {
    String? customTitle,
    String? customMessage,
  }) async {
    final permissionName = getPermissionName(type);
    final permissionDescription = getPermissionDescription(type);
    
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(customTitle ?? 'Permiso de $permissionName'),
        content: Text(
          customMessage ?? 
          '$permissionDescription\n\n¿Deseas otorgar este permiso?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Permitir'),
          ),
        ],
      ),
    );
  }
  
  // Show settings dialog for permanently denied permissions
  static Future<bool?> showSettingsDialog(
    BuildContext context,
    List<PermissionType> deniedPermissions,
  ) async {
    final permissionNames = deniedPermissions
        .map(getPermissionName)
        .join(', ');
    
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permisos Requeridos'),
        content: Text(
          'Los siguientes permisos son necesarios para el funcionamiento de la aplicación: $permissionNames.\n\n'
          'Por favor, ve a Configuración y habilita estos permisos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ir a Configuración'),
          ),
        ],
      ),
    );
  }
  
  // Request permission with dialog
  static Future<PermissionResult> requestPermissionWithDialog(
    BuildContext context,
    PermissionType type, {
    String? customTitle,
    String? customMessage,
    bool showSettingsOnDenied = true,
  }) async {
    // First check current status
    final currentResult = await checkPermission(type);
    
    if (currentResult.isGranted) {
      return currentResult;
    }
    
    if (currentResult.isPermanentlyDenied && showSettingsOnDenied) {
      final shouldOpenSettings = await showSettingsDialog(context, [type]);
      if (shouldOpenSettings ?? false) {
        await openAppSettings();
      }
      return currentResult;
    }
    
    // Show permission dialog
    final shouldRequest = await showPermissionDialog(
      context,
      type,
      customTitle: customTitle,
      customMessage: customMessage,
    );
    
    if (shouldRequest != true) {
      return currentResult;
    }
    
    // Request permission
    final result = await requestPermission(type);
    
    // If permanently denied after request, show settings dialog
    if (result.isPermanentlyDenied && showSettingsOnDenied) {
      final shouldOpenSettings = await showSettingsDialog(context, [type]);
      if (shouldOpenSettings ?? false) {
        await openAppSettings();
      }
    }
    
    return result;
  }
  
  // Request multiple permissions with dialogs
  static Future<Map<PermissionType, PermissionResult>> requestPermissionsWithDialogs(
    BuildContext context,
    List<PermissionType> types, {
    bool showSettingsOnDenied = true,
  }) async {
    final results = <PermissionType, PermissionResult>{};
    
    for (final type in types) {
      results[type] = await requestPermissionWithDialog(
        context,
        type,
        showSettingsOnDenied: showSettingsOnDenied,
      );
    }
    
    return results;
  }
  
  // Location-specific methods
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }
  
  static Future<LocationPermission> getLocationPermission() async => Geolocator.checkPermission();
  
  static Future<LocationPermission> requestLocationPermission() async => Geolocator.requestPermission();
  
  static Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      return false;
    }
  }
  
  // Check if device supports specific features
  static Future<bool> supportsCamera() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.systemFeatures.contains('android.hardware.camera');
      } else if (Platform.isIOS) {
        // iOS devices generally have cameras
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> supportsBluetooth() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.systemFeatures.contains('android.hardware.bluetooth');
      } else if (Platform.isIOS) {
        // iOS devices generally have Bluetooth
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> supportsLocation() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.systemFeatures.contains('android.hardware.location') ||
               androidInfo.systemFeatures.contains('android.hardware.location.gps');
      } else if (Platform.isIOS) {
        // iOS devices generally have location services
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Get Android SDK version
  static Future<int?> getAndroidSdkVersion() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.version.sdkInt;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Check if permission requires special handling on Android 13+
  static Future<bool> requiresAndroid13Handling(PermissionType type) async {
    final sdkVersion = await getAndroidSdkVersion();
    if (sdkVersion == null || sdkVersion < 33) return false;
    
    switch (type) {
      case PermissionType.photos:
      case PermissionType.notification:
        return true;
      default:
        return false;
    }
  }
  
  // Utility method to handle all app permissions at once
  static Future<bool> requestAllAppPermissions(BuildContext context) async {
    final requiredPermissions = [
      PermissionType.camera,
      PermissionType.photos,
      PermissionType.location,
      PermissionType.notification,
    ];
    
    final results = await requestPermissionsWithDialogs(
      context,
      requiredPermissions,
    );
    
    return areAllPermissionsGranted(results);
  }
  
  // Check critical permissions for core app functionality
  static Future<bool> checkCriticalPermissions() async {
    final criticalPermissions = [
      PermissionType.location,
      PermissionType.notification,
    ];
    
    final results = await checkPermissions(criticalPermissions);
    return areAllPermissionsGranted(results);
  }
}

// Extension methods for easier permission handling
extension PermissionTypeExtension on PermissionType {
  String get name => PermissionManager.getPermissionName(this);
  String get description => PermissionManager.getPermissionDescription(this);
  bool get isSupported => PermissionManager.isPermissionSupported(this);
  
  Future<PermissionResult> check() => PermissionManager.checkPermission(this);
  Future<PermissionResult> request() => PermissionManager.requestPermission(this);
  
  Future<PermissionResult> requestWithDialog(
    BuildContext context, {
    String? customTitle,
    String? customMessage,
    bool showSettingsOnDenied = true,
  }) => PermissionManager.requestPermissionWithDialog(
      context,
      this,
      customTitle: customTitle,
      customMessage: customMessage,
      showSettingsOnDenied: showSettingsOnDenied,
    );
}