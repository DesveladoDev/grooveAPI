import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Tipos de errores de la aplicación
enum AppErrorType {
  authentication,
  authorization,
  validation,
  network,
  firestore,
  payment,
  unknown,
}

/// Severidad del error
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Clase para representar errores de la aplicación
class AppError {
  const AppError({
    required this.type,
    required this.message,
    required this.severity,
    this.code,
    this.details,
    this.stackTrace,
    this.timestamp,
  });

  final AppErrorType type;
  final String message;
  final ErrorSeverity severity;
  final String? code;
  final Map<String, dynamic>? details;
  final StackTrace? stackTrace;
  final DateTime? timestamp;

  /// Crea un AppError desde una excepción
  factory AppError.fromException(
    dynamic exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? details,
  }) {
    return ErrorHandler.handleException(
      exception,
      stackTrace: stackTrace,
      details: details,
    );
  }

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, code: $code)';
  }
}

/// Manejador centralizado de errores
class ErrorHandler {
  static final Map<String, String> _errorMessages = {
    // Errores de autenticación
    'user-not-found': 'No se encontró una cuenta con este email',
    'wrong-password': 'Contraseña incorrecta',
    'email-already-in-use': 'Ya existe una cuenta con este email',
    'weak-password': 'La contraseña es muy débil',
    'invalid-email': 'El formato del email es inválido',
    'user-disabled': 'Esta cuenta ha sido deshabilitada',
    'too-many-requests': 'Demasiados intentos fallidos. Intenta más tarde',
    'operation-not-allowed': 'Operación no permitida',
    'requires-recent-login': 'Esta operación requiere autenticación reciente',
    
    // Errores de Firestore
    'permission-denied': 'No tienes permisos para realizar esta acción',
    'not-found': 'El documento solicitado no existe',
    'already-exists': 'El documento ya existe',
    'resource-exhausted': 'Se ha excedido la cuota de recursos',
    'failed-precondition': 'No se cumplieron las condiciones previas',
    'aborted': 'La operación fue cancelada',
    'out-of-range': 'Valor fuera del rango permitido',
    'unimplemented': 'Funcionalidad no implementada',
    'internal': 'Error interno del servidor',
    'unavailable': 'Servicio temporalmente no disponible',
    'data-loss': 'Pérdida de datos irrecuperable',
    'unauthenticated': 'Usuario no autenticado',
    
    // Errores de red
    'network-request-failed': 'Error de conexión. Verifica tu internet',
    'timeout': 'La operación tardó demasiado tiempo',
    
    // Errores de validación
    'invalid-argument': 'Argumento inválido',
    'invalid-data': 'Los datos proporcionados son inválidos',
    'missing-required-field': 'Falta un campo obligatorio',
    
    // Errores de pago
    'payment-failed': 'El pago no pudo ser procesado',
    'insufficient-funds': 'Fondos insuficientes',
    'card-declined': 'La tarjeta fue rechazada',
    'expired-card': 'La tarjeta ha expirado',
    'invalid-card': 'Información de tarjeta inválida',
    
    // Errores específicos de creación de perfiles
    'profile-creation-failed': 'No se pudo crear el perfil. Intenta nuevamente.',
    'profile-validation-failed': 'Los datos del perfil no son válidos. Revisa la información ingresada.',
    'profile-name-required': 'El nombre es obligatorio para crear tu perfil.',
    'profile-email-required': 'El email es obligatorio para crear tu perfil.',
    'profile-role-required': 'Debes seleccionar un tipo de cuenta (Músico o Anfitrión).',
    'profile-name-too-short': 'El nombre debe tener al menos 2 caracteres.',
    'profile-name-too-long': 'El nombre no puede tener más de 50 caracteres.',
    'profile-email-invalid': 'El formato del email no es válido.',
    'profile-phone-invalid': 'El formato del teléfono no es válido.',
    'profile-bio-too-long': 'La biografía no puede tener más de 500 caracteres.',
    'profile-incomplete': 'Tu perfil está incompleto. Completa todos los campos requeridos.',
    'profile-update-failed': 'No se pudo actualizar el perfil. Intenta nuevamente.',
    'profile-permission-denied': 'No tienes permisos para modificar este perfil.',
    'profile-not-found': 'No se encontró el perfil del usuario.',
    'profile-already-exists': 'Ya existe un perfil para este usuario.',
  };

  /// Maneja una excepción y la convierte en AppError
  static AppError handleException(
    dynamic exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? details,
  }) {
    final timestamp = DateTime.now();
    
    // Log del error para debugging
    if (kDebugMode) {
      print('Error handled at ${timestamp.toIso8601String()}: $exception');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }

    if (exception is FirebaseAuthException) {
      return AppError(
        type: AppErrorType.authentication,
        message: _getLocalizedMessage(exception.code),
        severity: _getAuthErrorSeverity(exception.code),
        code: exception.code,
        details: details,
        stackTrace: stackTrace,
        timestamp: timestamp,
      );
    }

    if (exception is FirebaseException) {
      return AppError(
        type: AppErrorType.firestore,
        message: _getLocalizedMessage(exception.code),
        severity: _getFirestoreErrorSeverity(exception.code),
        code: exception.code,
        details: details,
        stackTrace: stackTrace,
        timestamp: timestamp,
      );
    }

    if (exception is ArgumentError) {
      return AppError(
        type: AppErrorType.validation,
        message: exception.message?.toString() ?? 'Error de validación',
        severity: ErrorSeverity.medium,
        details: details,
        stackTrace: stackTrace,
        timestamp: timestamp,
      );
    }

    if (exception is FormatException) {
      return AppError(
        type: AppErrorType.validation,
        message: 'Formato de datos inválido: ${exception.message}',
        severity: ErrorSeverity.medium,
        details: details,
        stackTrace: stackTrace,
        timestamp: timestamp,
      );
    }

    // Error genérico
    return AppError(
      type: AppErrorType.unknown,
      message: exception.toString(),
      severity: ErrorSeverity.high,
      details: details,
      stackTrace: stackTrace,
      timestamp: timestamp,
    );
  }

  /// Obtiene el mensaje localizado para un código de error
  static String _getLocalizedMessage(String? code) {
    if (code == null) return 'Error desconocido';
    return _errorMessages[code] ?? 'Error: $code';
  }

  /// Determina la severidad de errores de autenticación
  static ErrorSeverity _getAuthErrorSeverity(String code) {
    switch (code) {
      case 'user-disabled':
      case 'too-many-requests':
        return ErrorSeverity.critical;
      case 'user-not-found':
      case 'wrong-password':
      case 'email-already-in-use':
        return ErrorSeverity.high;
      case 'weak-password':
      case 'invalid-email':
        return ErrorSeverity.medium;
      default:
        return ErrorSeverity.medium;
    }
  }

  /// Determina la severidad de errores de Firestore
  static ErrorSeverity _getFirestoreErrorSeverity(String code) {
    switch (code) {
      case 'permission-denied':
      case 'unauthenticated':
        return ErrorSeverity.critical;
      case 'resource-exhausted':
      case 'internal':
      case 'data-loss':
        return ErrorSeverity.high;
      case 'not-found':
      case 'already-exists':
      case 'failed-precondition':
        return ErrorSeverity.medium;
      default:
        return ErrorSeverity.medium;
    }
  }

  /// Registra un error para análisis
  static void logError(AppError error) {
    // En producción, aquí se enviaría a un servicio de logging
    // como Firebase Crashlytics, Sentry, etc.
    if (kDebugMode) {
      print('Error logged: ${error.toString()}');
      if (error.stackTrace != null) {
        print('Stack trace: ${error.stackTrace}');
      }
    }
    
    // TODO: Implementar envío a servicio de logging en producción
    // Crashlytics.recordError(error, error.stackTrace);
  }

  /// Maneja errores de forma segura con callback
  static Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    void Function(AppError error)? onError,
    T? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      final appError = handleException(e, stackTrace: stackTrace);
      logError(appError);
      
      if (onError != null) {
        onError(appError);
      }
      
      return defaultValue;
    }
  }

  /// Maneja errores síncronos de forma segura
  static T? handleSync<T>(
    T Function() operation, {
    void Function(AppError error)? onError,
    T? defaultValue,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      final appError = handleException(e, stackTrace: stackTrace);
      logError(appError);
      
      if (onError != null) {
        onError(appError);
      }
      
      return defaultValue;
    }
  }
}

/// Extensión para manejar errores en Future
extension FutureErrorHandling<T> on Future<T> {
  Future<T?> handleErrors({
    void Function(AppError error)? onError,
    T? defaultValue,
  }) {
    return ErrorHandler.handleAsync(
      () => this,
      onError: onError,
      defaultValue: defaultValue,
    );
  }
}