import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'error_handler.dart';

/// Manejador específico de errores para operaciones de perfil de usuario
class ProfileErrorHandler {
  /// Maneja errores específicos de creación de perfiles
  static AppError handleProfileCreationError(
    dynamic exception, {
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now();

    if (exception is FirebaseAuthException) {
      return _handleFirebaseAuthError(exception, stackTrace: stackTrace, timestamp: timestamp);
    }

    if (exception is FirebaseException) {
      return _handleFirebaseError(exception, stackTrace: stackTrace, timestamp: timestamp);
    }

    if (exception is ArgumentError) {
      return AppError(
        type: AppErrorType.validation,
        code: 'invalid-profile-data',
        message: 'Datos de perfil inválidos: ${exception.message}',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
        timestamp: timestamp,
      );
    }

    if (exception is StateError) {
      return AppError(
        type: AppErrorType.validation,
        code: 'profile-state-error',
        message: 'Error de estado del perfil: ${exception.message}',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
        timestamp: timestamp,
      );
    }

    // Error genérico de creación de perfil
    return AppError(
      type: AppErrorType.unknown,
      code: 'profile-creation-failed',
      message: 'Error al crear el perfil. Verifica que todos los campos estén completos.',
      severity: ErrorSeverity.medium,
      stackTrace: stackTrace,
      timestamp: timestamp,
    );
  }

  /// Maneja errores específicos de actualización de perfiles
  static AppError handleProfileUpdateError(
    dynamic exception, {
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now();

    if (exception is FirebaseAuthException) {
      return _handleFirebaseAuthError(exception, stackTrace: stackTrace, timestamp: timestamp);
    }

    if (exception is FirebaseException) {
      return _handleFirebaseError(exception, stackTrace: stackTrace, timestamp: timestamp);
    }

    if (exception is ArgumentError) {
      return AppError(
        type: AppErrorType.validation,
        code: 'invalid-update-data',
        message: 'Datos de actualización inválidos: ${exception.message}',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
        timestamp: timestamp,
      );
    }

    // Error genérico de actualización de perfil
    return AppError(
      type: AppErrorType.unknown,
      code: 'profile-update-failed',
      message: 'Error al actualizar el perfil. Intenta nuevamente.',
      severity: ErrorSeverity.medium,
      stackTrace: stackTrace,
      timestamp: timestamp,
    );
  }

  /// Valida los datos del perfil y retorna un error si hay problemas
  static AppError? validateProfileData(Map<String, dynamic> profileData) {
    // Validar nombre
    final name = profileData['name'] as String?;
    if (name == null || name.trim().isEmpty) {
      return AppError(
        type: AppErrorType.validation,
        code: 'missing-name',
        message: 'El nombre es requerido',
        severity: ErrorSeverity.medium,
      );
    }

    if (name.trim().length < 2) {
      return AppError(
        type: AppErrorType.validation,
        code: 'name-too-short',
        message: 'El nombre debe tener al menos 2 caracteres',
        severity: ErrorSeverity.medium,
      );
    }

    if (name.trim().length > 100) {
      return AppError(
        type: AppErrorType.validation,
        code: 'name-too-long',
        message: 'El nombre no puede tener más de 100 caracteres',
        severity: ErrorSeverity.medium,
      );
    }

    // Validar email
    final email = profileData['email'] as String?;
    if (email != null && email.isNotEmpty) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(email)) {
        return AppError(
          type: AppErrorType.validation,
          code: 'invalid-email',
          message: 'El formato del email no es válido',
          severity: ErrorSeverity.medium,
        );
      }
    }

    // Validar rol
    final role = profileData['role'] as String?;
    if (role != null && role.isNotEmpty) {
      final validRoles = ['musician', 'host', 'admin', 'guest'];
      if (!validRoles.contains(role)) {
        return AppError(
          type: AppErrorType.validation,
          code: 'invalid-role',
          message: 'El rol especificado no es válido',
          severity: ErrorSeverity.medium,
        );
      }
    }

    // Validar teléfono
    final phone = profileData['phone'] as String?;
    if (phone != null && phone.isNotEmpty) {
      if (phone.length < 10) {
        return AppError(
          type: AppErrorType.validation,
          code: 'invalid-phone',
          message: 'El número de teléfono debe tener al menos 10 dígitos',
          severity: ErrorSeverity.medium,
        );
      }
    }

    // Validar biografía
    final bio = profileData['bio'] as String?;
    if (bio != null && bio.length > 500) {
      return AppError(
        type: AppErrorType.validation,
        code: 'bio-too-long',
        message: 'La biografía no puede tener más de 500 caracteres',
        severity: ErrorSeverity.medium,
      );
    }

    return null; // No hay errores
  }

  /// Maneja errores específicos de Firebase Auth
  static AppError _handleFirebaseAuthError(
    FirebaseAuthException exception, {
    StackTrace? stackTrace,
    DateTime? timestamp,
  }) {
    String message;
    String code = exception.code;

    switch (exception.code) {
      case 'email-already-in-use':
        message = 'Este email ya está registrado. Intenta iniciar sesión.';
        break;
      case 'weak-password':
        message = 'La contraseña es muy débil. Usa al menos 8 caracteres.';
        break;
      case 'invalid-email':
        message = 'El formato del email no es válido.';
        break;
      case 'user-not-found':
        message = 'No se encontró el usuario especificado.';
        break;
      case 'requires-recent-login':
        message = 'Esta operación requiere autenticación reciente.';
        break;
      default:
        message = 'Error de autenticación: ${exception.message ?? 'Error desconocido'}';
    }

    return AppError(
      type: AppErrorType.authentication,
      code: code,
      message: message,
      severity: ErrorSeverity.high,
      stackTrace: stackTrace,
      timestamp: timestamp,
    );
  }

  /// Maneja errores específicos de Firestore
  static AppError _handleFirebaseError(
    FirebaseException exception, {
    StackTrace? stackTrace,
    DateTime? timestamp,
  }) {
    String message;
    String code = exception.code;

    switch (exception.code) {
      case 'permission-denied':
        message = 'No tienes permisos para realizar esta acción.';
        break;
      case 'not-found':
        message = 'El perfil solicitado no existe.';
        break;
      case 'already-exists':
        message = 'Ya tienes un perfil creado.';
        break;
      case 'unavailable':
        message = 'El servicio no está disponible en este momento.';
        break;
      case 'deadline-exceeded':
        message = 'La operación tardó demasiado tiempo. Intenta nuevamente.';
        break;
      case 'data-loss':
        message = 'No se pudo guardar tu perfil.';
        break;
      default:
        message = 'Error del servidor: ${exception.message ?? 'Error desconocido'}';
    }

    return AppError(
      type: AppErrorType.firestore,
      code: code,
      message: message,
      severity: ErrorSeverity.high,
      stackTrace: stackTrace,
      timestamp: timestamp,
    );
  }
}