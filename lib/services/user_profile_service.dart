import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/error_handler.dart';
import '../utils/profile_error_handler.dart';

class UserProfileResult {
  final bool success;
  final String? error;
  final UserModel? user;

  const UserProfileResult.success(this.user) : success = true, error = null;
  const UserProfileResult.error(this.error) : success = false, user = null;
}

class UserProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  /// Actualiza el rating de un usuario
  static Future<UserProfileResult> updateUserRating({
    required String userId,
    required double newRating,
    required int newReviewCount,
  }) async {
    return await ErrorHandler.safeExecuteAsync<UserProfileResult>(
      () async {
        // Validar parámetros
        if (userId.isEmpty) {
          throw ArgumentError('El ID del usuario no puede estar vacío');
        }

        if (newRating < 0.0 || newRating > 5.0) {
          throw ArgumentError('El rating debe estar entre 0.0 y 5.0');
        }

        if (newReviewCount < 0) {
          throw ArgumentError('El número de reseñas no puede ser negativo');
        }

        // Obtener el documento del usuario
        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          throw StateError('Usuario no encontrado');
        }

        // Crear el modelo actualizado
        final currentUser = UserModel.fromFirestore(userDoc);
        final updatedUser = currentUser.updateRating(newRating, newReviewCount);

        // Actualizar en Firestore
        await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .update({
          'rating': updatedUser.rating,
          'reviewCount': updatedUser.reviewCount,
          'updatedAt': Timestamp.fromDate(updatedUser.updatedAt!),
        });

        return UserProfileResult.success(updatedUser);
      },
      fallback: (error) {
        final appError = ProfileErrorHandler.handleProfileUpdateError(error);
        return UserProfileResult.error(appError.message);
      },
    );
  }

  /// Agrega un badge a un usuario
  static Future<UserProfileResult> addUserBadge({
    required String userId,
    required UserBadge badge,
  }) async {
    return await ErrorHandler.safeExecuteAsync<UserProfileResult>(
      () async {
        if (userId.isEmpty) {
          throw ArgumentError('El ID del usuario no puede estar vacío');
        }

        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          throw StateError('Usuario no encontrado');
        }

        final currentUser = UserModel.fromFirestore(userDoc);
        final updatedUser = currentUser.addBadge(badge);

        // Solo actualizar si realmente se agregó el badge
        if (updatedUser.badges.length != currentUser.badges.length) {
          await _firestore
              .collection(_usersCollection)
              .doc(userId)
              .update({
            'badges': updatedUser.badges
                .map((b) => b.toString().split('.').last)
                .toList(),
            'updatedAt': Timestamp.fromDate(updatedUser.updatedAt!),
          });
        }

        return UserProfileResult.success(updatedUser);
      },
      fallback: (error) {
        final appError = ProfileErrorHandler.handleProfileUpdateError(error);
        return UserProfileResult.error(appError.message);
      },
    );
  }

  /// Remueve un badge de un usuario
  static Future<UserProfileResult> removeUserBadge({
    required String userId,
    required UserBadge badge,
  }) async {
    return await ErrorHandler.safeExecuteAsync<UserProfileResult>(
      () async {
        if (userId.isEmpty) {
          throw ArgumentError('El ID del usuario no puede estar vacío');
        }

        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          throw StateError('Usuario no encontrado');
        }

        final currentUser = UserModel.fromFirestore(userDoc);
        final updatedUser = currentUser.removeBadge(badge);

        // Solo actualizar si realmente se removió el badge
        if (updatedUser.badges.length != currentUser.badges.length) {
          await _firestore
              .collection(_usersCollection)
              .doc(userId)
              .update({
            'badges': updatedUser.badges
                .map((b) => b.toString().split('.').last)
                .toList(),
            'updatedAt': Timestamp.fromDate(updatedUser.updatedAt!),
          });
        }

        return UserProfileResult.success(updatedUser);
      },
      fallback: (error) {
        final appError = ProfileErrorHandler.handleProfileUpdateError(error);
        return UserProfileResult.error(appError.message);
      },
    );
  }

  /// Actualiza el status de un usuario
  static Future<UserProfileResult> updateUserStatus({
    required String userId,
    required UserStatus status,
  }) async {
    return await ErrorHandler.safeExecuteAsync<UserProfileResult>(
      () async {
        if (userId.isEmpty) {
          throw ArgumentError('El ID del usuario no puede estar vacío');
        }

        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          throw StateError('Usuario no encontrado');
        }

        final currentUser = UserModel.fromFirestore(userDoc);
        final updatedUser = currentUser.updateStatus(status);

        await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .update({
          'status': updatedUser.status.toString().split('.').last,
          'updatedAt': Timestamp.fromDate(updatedUser.updatedAt!),
        });

        return UserProfileResult.success(updatedUser);
      },
      fallback: (error) {
        final appError = ProfileErrorHandler.handleProfileUpdateError(error);
        return UserProfileResult.error(appError.message);
      },
    );
  }

  /// Actualiza la biografía de un usuario
  static Future<UserProfileResult> updateUserBio({
    required String userId,
    required String bio,
  }) async {
    return await ErrorHandler.safeExecuteAsync<UserProfileResult>(
      () async {
        if (userId.isEmpty) {
          throw ArgumentError('El ID del usuario no puede estar vacío');
        }

        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          throw StateError('Usuario no encontrado');
        }

        final currentUser = UserModel.fromFirestore(userDoc);
        final updatedUser = currentUser.updateBio(bio);

        await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .update({
          'bio': updatedUser.bio,
          'updatedAt': Timestamp.fromDate(updatedUser.updatedAt!),
        });

        return UserProfileResult.success(updatedUser);
      },
      fallback: (error) {
        final appError = ProfileErrorHandler.handleProfileUpdateError(error);
        return UserProfileResult.error(appError.message);
      },
    );
  }

  /// Obtiene el perfil completo de un usuario
  static Future<UserProfileResult> getUserProfile(String userId) async {
    return await ErrorHandler.safeExecuteAsync<UserProfileResult>(
      () async {
        if (userId.isEmpty) {
          throw ArgumentError('El ID del usuario no puede estar vacío');
        }

        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          throw StateError('Usuario no encontrado');
        }

        final user = UserModel.fromFirestore(userDoc);
        return UserProfileResult.success(user);
      },
      fallback: (error) {
        final appError = ProfileErrorHandler.handleProfileUpdateError(error);
        return UserProfileResult.error(appError.message);
      },
    );
  }

  /// Actualiza múltiples campos del perfil de usuario
  static Future<UserProfileResult> updateUserProfile({
    required String userId,
    String? bio,
    UserStatus? status,
    List<UserBadge>? badges,
  }) async {
    return await ErrorHandler.safeExecuteAsync<UserProfileResult>(
      () async {
        if (userId.isEmpty) {
          throw ArgumentError('El ID del usuario no puede estar vacío');
        }

        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          throw StateError('Usuario no encontrado');
        }

        final currentUser = UserModel.fromFirestore(userDoc);
        
        // Preparar los datos de actualización
        final updateData = <String, dynamic>{
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        };

        if (bio != null) {
          updateData['bio'] = UserModel._validateBio(bio);
        }

        if (status != null) {
          updateData['status'] = status.toString().split('.').last;
        }

        if (badges != null) {
          updateData['badges'] = badges
              .map((b) => b.toString().split('.').last)
              .toList();
        }

        // Actualizar en Firestore
        await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .update(updateData);

        // Obtener el usuario actualizado
        final updatedDoc = await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .get();

        final updatedUser = UserModel.fromFirestore(updatedDoc);
        return UserProfileResult.success(updatedUser);
      },
      fallback: (error) {
        final appError = ProfileErrorHandler.handleProfileUpdateError(error);
        return UserProfileResult.error(appError.message);
      },
    );
  }

  /// Calcula y actualiza automáticamente badges basados en la actividad del usuario
  static Future<UserProfileResult> updateAutomaticBadges({
    required String userId,
    required int totalBookings,
    required int totalHostings,
    required double averageRating,
    required int reviewCount,
    required DateTime memberSince,
  }) async {
    return await ErrorHandler.safeExecuteAsync<UserProfileResult>(
      () async {
        final userResult = await getUserProfile(userId);
        if (!userResult.success) {
          throw StateError(userResult.error ?? 'Error al obtener el usuario');
        }

        final user = userResult.user!;
        final newBadges = <UserBadge>[];

        // Badge de usuario nuevo (menos de 30 días)
        if (DateTime.now().difference(memberSince).inDays < 30) {
          newBadges.add(UserBadge.newUser);
        }

        // Badge de huésped frecuente (más de 10 reservas)
        if (totalBookings >= 10) {
          newBadges.add(UserBadge.frequentGuest);
        }

        // Badge de super host (más de 20 hostings y rating > 4.5)
        if (totalHostings >= 20 && averageRating >= 4.5) {
          newBadges.add(UserBadge.superHost);
        }

        // Badge de top host (más de 50 hostings y rating > 4.8)
        if (totalHostings >= 50 && averageRating >= 4.8) {
          newBadges.add(UserBadge.topHost);
        }

        // Badge de experto en música (más de 100 reseñas)
        if (reviewCount >= 100) {
          newBadges.add(UserBadge.musicExpert);
        }

        // Mantener badges existentes que no son automáticos
        final manualBadges = user.badges.where((badge) => 
          badge == UserBadge.verified ||
          badge == UserBadge.premium ||
          badge == UserBadge.earlyAdopter ||
          badge == UserBadge.studioOwner
        ).toList();

        final finalBadges = [...manualBadges, ...newBadges].toSet().toList();

        return await updateUserProfile(
          userId: userId,
          badges: finalBadges,
        );
      },
      fallback: (error) {
        final appError = ProfileErrorHandler.handleProfileUpdateError(error);
        return UserProfileResult.error(appError.message);
      },
    );
  }
}