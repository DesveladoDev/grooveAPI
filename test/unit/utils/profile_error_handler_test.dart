import 'package:flutter_test/flutter_test.dart';
import 'package:salas_beats/utils/profile_error_handler.dart';
import 'package:salas_beats/utils/error_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('ProfileErrorHandler Tests', () {
    group('Profile Data Validation', () {
      test('should return null for valid profile data', () {
        final profileData = {
          'name': 'John Doe',
          'email': 'john@example.com',
          'role': 'musician',
          'phone': '+1234567890',
          'bio': 'Test bio',
        };

        final result = ProfileErrorHandler.validateProfileData(profileData);
        expect(result, isNull);
      });

      test('should return error for missing name', () {
        final profileData = {
          'email': 'john@example.com',
          'role': 'musician',
        };

        final result = ProfileErrorHandler.validateProfileData(profileData);
        expect(result, isNotNull);
        expect(result!.message, contains('nombre'));
      });

      test('should return error for invalid email format', () {
        final profileData = {
          'name': 'John Doe',
          'email': 'invalid-email',
          'role': 'musician',
        };

        final result = ProfileErrorHandler.validateProfileData(profileData);
        expect(result, isNotNull);
        expect(result!.message, contains('email'));
      });

      test('should return error for invalid role', () {
        final profileData = {
          'name': 'John Doe',
          'email': 'john@example.com',
          'role': 'invalid-role',
        };

        final result = ProfileErrorHandler.validateProfileData(profileData);
        expect(result, isNotNull);
        expect(result!.message, contains('rol'));
      });

      test('should return error for name too short', () {
        final profileData = {
          'name': 'A',
          'email': 'john@example.com',
          'role': 'musician',
        };

        final result = ProfileErrorHandler.validateProfileData(profileData);
        expect(result, isNotNull);
        expect(result!.message, contains('nombre'));
      });

      test('should return error for name too long', () {
        final profileData = {
          'name': 'A' * 101, // 101 characters
          'email': 'john@example.com',
          'role': 'musician',
        };

        final result = ProfileErrorHandler.validateProfileData(profileData);
        expect(result, isNotNull);
        expect(result!.message, contains('nombre'));
      });

      test('should return error for bio too long', () {
        final profileData = {
          'name': 'John Doe',
          'email': 'john@example.com',
          'role': 'musician',
          'bio': 'A' * 501, // 501 characters
        };

        final result = ProfileErrorHandler.validateProfileData(profileData);
        expect(result, isNotNull);
        expect(result!.message, contains('biografía'));
      });

      test('should return error for invalid phone format', () {
        final profileData = {
          'name': 'John Doe',
          'email': 'john@example.com',
          'role': 'musician',
          'phone': '123', // Too short
        };

        final result = ProfileErrorHandler.validateProfileData(profileData);
        expect(result, isNotNull);
        expect(result!.message, contains('teléfono'));
      });
    });

    group('Profile Creation Error Handling', () {
      test('should handle FirebaseAuthException with specific message', () {
        final exception = FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The email address is already in use by another account.',
        );

        final result = ProfileErrorHandler.handleProfileCreationError(exception);
        expect(result.message, contains('email'));
        expect(result.severity, equals(ErrorSeverity.high));
      });

      test('should handle FirebaseException with specific message', () {
        final exception = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Missing or insufficient permissions.',
        );

        final result = ProfileErrorHandler.handleProfileCreationError(exception);
        expect(result.message, contains('permisos'));
        expect(result.severity, equals(ErrorSeverity.high));
      });

      test('should handle generic exception with fallback message', () {
        final exception = Exception('Generic error');

        final result = ProfileErrorHandler.handleProfileCreationError(exception);
        expect(result.message, contains('crear'));
        expect(result.severity, equals(ErrorSeverity.medium));
      });
    });

    group('Profile Update Error Handling', () {
      test('should handle network error with specific message', () {
        final exception = Exception('Network error');

        final result = ProfileErrorHandler.handleProfileUpdateError(exception);
        expect(result.message, contains('actualizar'));
        expect(result.severity, equals(ErrorSeverity.medium));
      });

      test('should handle timeout error with specific message', () {
        final exception = Exception('Timeout');

        final result = ProfileErrorHandler.handleProfileUpdateError(exception);
        expect(result.message, contains('actualizar'));
        expect(result.severity, equals(ErrorSeverity.medium));
      });
    });
  });
}