import 'package:firebase_auth/firebase_auth.dart';
import 'package:salas_beats/config/constants.dart';

// Base exception class
abstract class AppException implements Exception {
  
  const AppException(this.message, {this.code, this.originalError});
  final String message;
  final String? code;
  final dynamic originalError;
  
  @override
  String toString() => message;
}

// Authentication exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});
  
  factory AuthException.fromFirebaseAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException(
          'No se encontró una cuenta con este email',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthException(
          'Contraseña incorrecta',
          code: 'wrong-password',
        );
      case 'email-already-in-use':
        return const AuthException(
          'Ya existe una cuenta con este email',
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return const AuthException(
          'La contraseña es demasiado débil',
          code: 'weak-password',
        );
      case 'invalid-email':
        return const AuthException(
          'El formato del email no es válido',
          code: 'invalid-email',
        );
      case 'user-disabled':
        return const AuthException(
          'Esta cuenta ha sido deshabilitada',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthException(
          'Demasiados intentos fallidos. Intenta más tarde',
          code: 'too-many-requests',
        );
      case 'operation-not-allowed':
        return const AuthException(
          'Operación no permitida',
          code: 'operation-not-allowed',
        );
      case 'invalid-credential':
        return const AuthException(
          'Credenciales inválidas',
          code: 'invalid-credential',
        );
      case 'account-exists-with-different-credential':
        return const AuthException(
          'Ya existe una cuenta con un método de autenticación diferente',
          code: 'account-exists-with-different-credential',
        );
      case 'requires-recent-login':
        return const AuthException(
          'Esta operación requiere autenticación reciente',
          code: 'requires-recent-login',
        );
      case 'provider-already-linked':
        return const AuthException(
          'Este proveedor ya está vinculado a la cuenta',
          code: 'provider-already-linked',
        );
      case 'no-such-provider':
        return const AuthException(
          'No se encontró el proveedor especificado',
          code: 'no-such-provider',
        );
      case 'invalid-verification-code':
        return const AuthException(
          'Código de verificación inválido',
          code: 'invalid-verification-code',
        );
      case 'invalid-verification-id':
        return const AuthException(
          'ID de verificación inválido',
          code: 'invalid-verification-id',
        );
      case 'session-expired':
        return const AuthException(
          'La sesión ha expirado',
          code: 'session-expired',
        );
      default:
        return AuthException(
          e.message ?? 'Error de autenticación',
          code: e.code,
          originalError: e,
        );
    }
  }
}

// Firestore exceptions
class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code, super.originalError});
  
  factory FirestoreException.fromFirestore(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const FirestoreException(
          'No tienes permisos para realizar esta operación',
          code: 'permission-denied',
        );
      case 'not-found':
        return const FirestoreException(
          'El documento solicitado no existe',
          code: 'not-found',
        );
      case 'already-exists':
        return const FirestoreException(
          'El documento ya existe',
          code: 'already-exists',
        );
      case 'resource-exhausted':
        return const FirestoreException(
          'Se ha excedido la cuota de recursos',
          code: 'resource-exhausted',
        );
      case 'failed-precondition':
        return const FirestoreException(
          'La operación falló debido a una condición previa',
          code: 'failed-precondition',
        );
      case 'aborted':
        return const FirestoreException(
          'La operación fue abortada',
          code: 'aborted',
        );
      case 'out-of-range':
        return const FirestoreException(
          'Valor fuera de rango',
          code: 'out-of-range',
        );
      case 'unimplemented':
        return const FirestoreException(
          'Operación no implementada',
          code: 'unimplemented',
        );
      case 'internal':
        return const FirestoreException(
          'Error interno del servidor',
          code: 'internal',
        );
      case 'unavailable':
        return const FirestoreException(
          'Servicio no disponible temporalmente',
          code: 'unavailable',
        );
      case 'data-loss':
        return const FirestoreException(
          'Pérdida de datos irrecuperable',
          code: 'data-loss',
        );
      case 'unauthenticated':
        return const FirestoreException(
          'Usuario no autenticado',
          code: 'unauthenticated',
        );
      case 'invalid-argument':
        return const FirestoreException(
          'Argumento inválido',
          code: 'invalid-argument',
        );
      case 'deadline-exceeded':
        return const FirestoreException(
          'Tiempo de espera agotado',
          code: 'deadline-exceeded',
        );
      case 'cancelled':
        return const FirestoreException(
          'Operación cancelada',
          code: 'cancelled',
        );
      default:
        return FirestoreException(
          e.message ?? 'Error de base de datos',
          code: e.code,
          originalError: e,
        );
    }
  }
}

// Storage exceptions
class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.originalError});
  
  factory StorageException.fromFirebaseStorage(FirebaseException e) {
    switch (e.code) {
      case 'storage/object-not-found':
        return const StorageException(
          'Archivo no encontrado',
          code: 'object-not-found',
        );
      case 'storage/bucket-not-found':
        return const StorageException(
          'Bucket de almacenamiento no encontrado',
          code: 'bucket-not-found',
        );
      case 'storage/project-not-found':
        return const StorageException(
          'Proyecto no encontrado',
          code: 'project-not-found',
        );
      case 'storage/quota-exceeded':
        return const StorageException(
          'Cuota de almacenamiento excedida',
          code: 'quota-exceeded',
        );
      case 'storage/unauthenticated':
        return const StorageException(
          'Usuario no autenticado',
          code: 'unauthenticated',
        );
      case 'storage/unauthorized':
        return const StorageException(
          'No autorizado para esta operación',
          code: 'unauthorized',
        );
      case 'storage/retry-limit-exceeded':
        return const StorageException(
          'Límite de reintentos excedido',
          code: 'retry-limit-exceeded',
        );
      case 'storage/invalid-checksum':
        return const StorageException(
          'Checksum del archivo inválido',
          code: 'invalid-checksum',
        );
      case 'storage/canceled':
        return const StorageException(
          'Operación cancelada',
          code: 'canceled',
        );
      case 'storage/invalid-event-name':
        return const StorageException(
          'Nombre de evento inválido',
          code: 'invalid-event-name',
        );
      case 'storage/invalid-url':
        return const StorageException(
          'URL inválida',
          code: 'invalid-url',
        );
      case 'storage/invalid-argument':
        return const StorageException(
          'Argumento inválido',
          code: 'invalid-argument',
        );
      case 'storage/no-default-bucket':
        return const StorageException(
          'No hay bucket por defecto configurado',
          code: 'no-default-bucket',
        );
      case 'storage/cannot-slice-blob':
        return const StorageException(
          'No se puede procesar el archivo',
          code: 'cannot-slice-blob',
        );
      case 'storage/server-file-wrong-size':
        return const StorageException(
          'Tamaño de archivo incorrecto en el servidor',
          code: 'server-file-wrong-size',
        );
      default:
        return StorageException(
          e.message ?? 'Error de almacenamiento',
          code: e.code,
          originalError: e,
        );
    }
  }
}

// Network exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});
  
  factory NetworkException.noConnection() => const NetworkException(
      'Sin conexión a internet',
      code: 'no-connection',
    );
  
  factory NetworkException.timeout() => const NetworkException(
      'Tiempo de espera agotado',
      code: 'timeout',
    );
  
  factory NetworkException.serverError() => const NetworkException(
      'Error del servidor',
      code: 'server-error',
    );
  
  factory NetworkException.badRequest() => const NetworkException(
      'Solicitud incorrecta',
      code: 'bad-request',
    );
  
  factory NetworkException.unauthorized() => const NetworkException(
      'No autorizado',
      code: 'unauthorized',
    );
  
  factory NetworkException.forbidden() => const NetworkException(
      'Acceso prohibido',
      code: 'forbidden',
    );
  
  factory NetworkException.notFound() => const NetworkException(
      'Recurso no encontrado',
      code: 'not-found',
    );
}

// Validation exceptions
class ValidationException extends AppException {
  
  const ValidationException(
    super.message, {
    super.code,
    super.originalError,
    this.fieldErrors,
  });
  
  factory ValidationException.field(String field, String message) => ValidationException(
      'Error de validación',
      code: 'field-validation',
      fieldErrors: {field: message},
    );
  
  factory ValidationException.multiple(Map<String, String> fieldErrors) => ValidationException(
      'Errores de validación',
      code: 'multiple-validation',
      fieldErrors: fieldErrors,
    );
  
  factory ValidationException.required(String field) => ValidationException.field(field, 'Este campo es obligatorio');
  
  factory ValidationException.invalidFormat(String field) => ValidationException.field(field, 'Formato inválido');
  
  factory ValidationException.tooShort(String field, int minLength) => ValidationException.field(
      field,
      'Debe tener al menos $minLength caracteres',
    );
  
  factory ValidationException.tooLong(String field, int maxLength) => ValidationException.field(
      field,
      'No puede tener más de $maxLength caracteres',
    );
  
  factory ValidationException.outOfRange(String field, num min, num max) => ValidationException.field(
      field,
      'Debe estar entre $min y $max',
    );
  final Map<String, String>? fieldErrors;
}

// Business logic exceptions
class BusinessException extends AppException {
  const BusinessException(super.message, {super.code, super.originalError});
  
  factory BusinessException.bookingNotAvailable() => const BusinessException(
      'La sala no está disponible en el horario seleccionado',
      code: 'booking-not-available',
    );
  
  factory BusinessException.insufficientFunds() => const BusinessException(
      'Fondos insuficientes',
      code: 'insufficient-funds',
    );
  
  factory BusinessException.bookingTooEarly() => const BusinessException(
      'No se puede reservar con tan poca antelación',
      code: 'booking-too-early',
    );
  
  factory BusinessException.bookingTooLate() => const BusinessException(
      'No se puede reservar con tanta antelación',
      code: 'booking-too-late',
    );
  
  factory BusinessException.maxBookingsExceeded() => const BusinessException(
      'Has excedido el número máximo de reservas',
      code: 'max-bookings-exceeded',
    );
  
  factory BusinessException.hostNotVerified() => const BusinessException(
      'El anfitrión no está verificado',
      code: 'host-not-verified',
    );
  
  factory BusinessException.listingInactive() => const BusinessException(
      'La sala no está activa',
      code: 'listing-inactive',
    );
  
  factory BusinessException.paymentFailed() => const BusinessException(
      'El pago no pudo ser procesado',
      code: 'payment-failed',
    );
  
  factory BusinessException.refundNotAllowed() => const BusinessException(
      'No se puede procesar el reembolso',
      code: 'refund-not-allowed',
    );
  
  factory BusinessException.cancellationNotAllowed() => const BusinessException(
      'No se puede cancelar esta reserva',
      code: 'cancellation-not-allowed',
    );
}

// File exceptions
class FileException extends AppException {
  const FileException(super.message, {super.code, super.originalError});
  
  factory FileException.notFound() => const FileException(
      'Archivo no encontrado',
      code: 'file-not-found',
    );
  
  factory FileException.tooLarge(int maxSize) => FileException(
      'El archivo es demasiado grande. Tamaño máximo: ${maxSize}MB',
      code: 'file-too-large',
    );
  
  factory FileException.invalidFormat(List<String> allowedFormats) => FileException(
      'Formato no válido. Formatos permitidos: ${allowedFormats.join(", ")}',
      code: 'invalid-format',
    );
  
  factory FileException.uploadFailed() => const FileException(
      'Error al subir el archivo',
      code: 'upload-failed',
    );
  
  factory FileException.downloadFailed() => const FileException(
      'Error al descargar el archivo',
      code: 'download-failed',
    );
  
  factory FileException.corruptedFile() => const FileException(
      'El archivo está corrupto',
      code: 'corrupted-file',
    );
  
  factory FileException.permissionDenied(String message) => FileException(
      message,
      code: 'permission-denied',
    );
  
  factory FileException.unsupportedFormat(String message) => FileException(
      message,
      code: 'unsupported-format',
    );
  
  factory FileException.fileTooLarge(String message) => FileException(
      message,
      code: 'file-too-large',
    );
  
  factory FileException.processingError(String message) => FileException(
      message,
      code: 'processing-error',
    );
}

// Location exceptions
class LocationException extends AppException {
  const LocationException(super.message, {super.code, super.originalError});
  
  factory LocationException.permissionDenied() => const LocationException(
      'Permisos de ubicación denegados',
      code: 'permission-denied',
    );
  
  factory LocationException.serviceDisabled() => const LocationException(
      'Servicios de ubicación deshabilitados',
      code: 'service-disabled',
    );
  
  factory LocationException.timeout() => const LocationException(
      'Tiempo de espera agotado al obtener ubicación',
      code: 'timeout',
    );
  
  factory LocationException.unavailable() => const LocationException(
      'Ubicación no disponible',
      code: 'unavailable',
    );
  
  factory LocationException.unknown(String message) => LocationException(
      message,
      code: 'unknown',
    );
  
  factory LocationException.alreadyTracking(String message) => LocationException(
      message,
      code: 'already-tracking',
    );
  
  factory LocationException.trackingError(String message) => LocationException(
      message,
      code: 'tracking-error',
    );
  
  factory LocationException.geocodingError(String message) => LocationException(
      message,
      code: 'geocoding-error',
    );
  
  factory LocationException.searchError(String message) => LocationException(
      message,
      code: 'search-error',
    );
}

// Payment exceptions
class PaymentException extends AppException {
  const PaymentException(super.message, {super.code, super.originalError});
  
  factory PaymentException.cardDeclined() => const PaymentException(
      'Tarjeta rechazada',
      code: 'card-declined',
    );
  
  factory PaymentException.insufficientFunds() => const PaymentException(
      'Fondos insuficientes',
      code: 'insufficient-funds',
    );
  
  factory PaymentException.expiredCard() => const PaymentException(
      'Tarjeta expirada',
      code: 'expired-card',
    );
  
  factory PaymentException.invalidCard() => const PaymentException(
      'Tarjeta inválida',
      code: 'invalid-card',
    );
  
  factory PaymentException.processingError() => const PaymentException(
      'Error al procesar el pago',
      code: 'processing-error',
    );
  
  factory PaymentException.fraudSuspected() => const PaymentException(
      'Transacción sospechosa de fraude',
      code: 'fraud-suspected',
    );
  
  factory PaymentException.limitExceeded() => const PaymentException(
      'Límite de transacción excedido',
      code: 'limit-exceeded',
    );
  
  factory PaymentException.paymentFailed(String message) => PaymentException(
      message,
      code: 'payment-failed',
    );
  
  factory PaymentException.apiError(String message) => PaymentException(
      message,
      code: 'api-error',
    );
  
  factory PaymentException.networkError(String message) => PaymentException(
      message,
      code: 'network-error',
    );
}

// Generic exceptions
class GenericException extends AppException {
  const GenericException(super.message, {super.code, super.originalError});
}

// Cache exceptions
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.originalError});
  
  factory CacheException.notFound() => const CacheException(
      'Datos no encontrados en caché',
      code: 'cache-not-found',
    );
  
  factory CacheException.expired() => const CacheException(
      'Datos de caché expirados',
      code: 'cache-expired',
    );
  
  factory CacheException.storageError() => const CacheException(
      'Error al almacenar en caché',
      code: 'cache-storage-error',
    );
}

// Exception handler utility
class ExceptionHandler {
  static AppException handleException(error) {
    if (error is AppException) {
      return error;
    }
    
    if (error is FirebaseAuthException) {
      return AuthException.fromFirebaseAuth(error);
    }
    
    if (error is FirebaseException) {
      if (error.plugin == 'cloud_firestore') {
        return FirestoreException.fromFirestore(error);
      } else if (error.plugin == 'firebase_storage') {
        return StorageException.fromFirebaseStorage(error);
      }
    }
    
    // Handle common network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return NetworkException.noConnection();
    }
    
    if (error.toString().contains('TimeoutException')) {
      return NetworkException.timeout();
    }
    
    // Default to generic app exception
    return GenericException(
      error.toString().isNotEmpty 
        ? error.toString() 
        : AppConstants.genericErrorMessage,
      originalError: error,
    );
  }
  
  static String getErrorMessage(error) {
    final exception = handleException(error);
    return exception.message;
  }
  
  static String getErrorCode(error) {
    final exception = handleException(error);
    return exception.code ?? 'unknown';
  }
  
  static bool isNetworkError(error) {
    final exception = handleException(error);
    return exception is NetworkException;
  }
  
  static bool isAuthError(error) {
    final exception = handleException(error);
    return exception is AuthException;
  }
  
  static bool isValidationError(error) {
    final exception = handleException(error);
    return exception is ValidationException;
  }
  
  static bool isBusinessError(error) {
    final exception = handleException(error);
    return exception is BusinessException;
  }
  
  static bool isRetryableError(error) {
    final exception = handleException(error);
    
    if (exception is NetworkException) {
      return exception.code == 'timeout' || 
             exception.code == 'server-error' ||
             exception.code == 'no-connection';
    }
    
    if (exception is FirestoreException) {
      return exception.code == 'unavailable' ||
             exception.code == 'deadline-exceeded' ||
             exception.code == 'internal';
    }
    
    if (exception is StorageException) {
      return exception.code == 'retry-limit-exceeded';
    }
    
    return false;
  }
}