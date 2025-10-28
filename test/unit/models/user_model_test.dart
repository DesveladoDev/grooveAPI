import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salas_beats/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    group('Role Functionality', () {
      test('should create user with musician role', () {
        // Arrange & Act
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        // Assert
        expect(user.role, equals(UserRole.musician));
      });

      test('should create user with host role', () {
        // Arrange & Act
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.host,
          createdAt: DateTime.now(),
        );

        // Assert
        expect(user.role, equals(UserRole.host));
      });

      test('should update user role using copyWith', () {
        // Arrange
        final originalUser = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        // Act
        final updatedUser = originalUser.copyWith(role: UserRole.host);

        // Assert
        expect(originalUser.role, equals(UserRole.musician));
        expect(updatedUser.role, equals(UserRole.host));
        expect(updatedUser.id, equals(originalUser.id));
        expect(updatedUser.email, equals(originalUser.email));
        expect(updatedUser.name, equals(originalUser.name));
      });
    });

    group('Firestore Serialization', () {
      test('should serialize user to Firestore correctly', () {
        // Arrange
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          verified: true,
          photoURL: 'https://example.com/photo.jpg',
          createdAt: DateTime(2024, 1, 1),
          isOnboardingComplete: true,
        );

        // Act
        final firestoreData = user.toFirestore();

        // Assert
        expect(firestoreData['role'], equals('musician'));
        expect(firestoreData['email'], equals('test@example.com'));
        expect(firestoreData['name'], equals('Test User'));
        expect(firestoreData['verified'], equals(true));
        expect(firestoreData['photoURL'], equals('https://example.com/photo.jpg'));
        expect(firestoreData['isOnboardingComplete'], equals(true));
        expect(firestoreData['createdAt'], isA<Timestamp>());
      });
    });

    group('User Properties', () {
      test('should have correct display properties', () {
        // Arrange
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          verified: true,
          photoURL: 'https://example.com/photo.jpg',
          createdAt: DateTime.now(),
          rating: 4.5,
          reviewCount: 10,
        );

        // Act & Assert
        expect(user.displayName, equals('Test User'));
        expect(user.isVerified, equals(true));
        expect(user.ratingDisplay, equals('4.5'));
        expect(user.hasRating, isTrue);
        expect(user.hasReviews, isTrue);
        expect(user.reviewCountDisplay, equals('10 reseñas'));
      });
    });

    group('Rating and Review Methods', () {
      test('should update rating correctly', () {
        // Arrange
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          createdAt: DateTime.now(),
          rating: 3.0,
          reviewCount: 5,
        );

        // Act
        final updatedUser = user.updateRating(4.5, 10);

        // Assert
        expect(updatedUser.rating, equals(4.5));
        expect(updatedUser.reviewCount, equals(10));
        expect(updatedUser.updatedAt, isNotNull);
      });

      test('should validate rating bounds', () {
        // Arrange
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        // Act
        final updatedUser1 = user.updateRating(-1.0, 5);
        final updatedUser2 = user.updateRating(6.0, 5);

        // Assert
        expect(updatedUser1.rating, equals(0.0));
        expect(updatedUser2.rating, equals(5.0));
      });
    });

    group('Object Properties', () {
      test('should have correct properties when created', () {
        // Arrange
        final dateTime = DateTime.now();
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.musician,
          verified: true,
          photoURL: 'https://example.com/photo.jpg',
          createdAt: dateTime,
        );

        // Act & Assert
        expect(user.id, equals('test-id'));
        expect(user.email, equals('test@example.com'));
        expect(user.name, equals('Test User'));
        expect(user.role, equals(UserRole.musician));
        expect(user.verified, equals(true));
        expect(user.photoURL, equals('https://example.com/photo.jpg'));
        expect(user.createdAt, equals(dateTime));
      });

      test('should handle different roles correctly', () {
        // Arrange
        final musicianUser = UserModel(
          id: 'musician-id',
          email: 'musician@example.com',
          name: 'Musician User',
          role: UserRole.musician,
          createdAt: DateTime.now(),
        );

        final hostUser = UserModel(
          id: 'host-id',
          email: 'host@example.com',
          name: 'Host User',
          role: UserRole.host,
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(musicianUser.role, equals(UserRole.musician));
        expect(hostUser.role, equals(UserRole.host));
        expect(musicianUser.role, isNot(equals(hostUser.role)));
      });
    });
  });
}