import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/network/cloudinary_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getCurrentUser();
  Future<UserModel> getUserById(String userId);
  Future<UserModel> updateUserProfile(UserModel user);
  Future<String> updateUserPhoto(String userId, String filePath);
  Future<void> blockUser(String userId);
  Future<void> reportUser(String userId, String reason);
  Future<void> rateUser({
    required String userId,
    required int rating,
    String? comment,
  });
}

@LazySingleton(as: UserRemoteDataSource)
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseService _firebaseService;
  final CloudinaryService _cloudinaryService;

  UserRemoteDataSourceImpl(this._firebaseService, this._cloudinaryService);

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw ServerException('No authenticated user');
      }

      final userDoc = await _firebaseService.firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        throw ServerException('User not found');
      }

      final data = userDoc.data()!;
      data['id'] = userDoc.id;

      return UserModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get current user');
    } catch (e) {
      throw ServerException('Failed to get current user: $e');
    }
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      final userDoc = await _firebaseService.firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw ServerException('User not found');
      }

      final data = userDoc.data()!;
      data['id'] = userDoc.id;

      return UserModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get user');
    } catch (e) {
      throw ServerException('Failed to get user: $e');
    }
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      final userData = user.toJson();
      // Remove createdAt - never update it
      userData.remove('createdAt');
      // Update updatedAt as ISO string to keep consistency with createdAt format
      userData['updatedAt'] = DateTime.now().toIso8601String();

      await _firebaseService.firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.id)
          .update(userData);

      final userDoc = await _firebaseService.firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.id)
          .get();

      final data = userDoc.data()!;
      data['id'] = userDoc.id;

      return UserModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update user profile');
    } catch (e) {
      throw ServerException('Failed to update user profile: $e');
    }
  }

  @override
  Future<String> updateUserPhoto(String userId, String filePath) async {
    try {
      // Upload file to Cloudinary
      final file = File(filePath);
      final photoUrl = await _cloudinaryService.uploadImage(
        file: file,
        folder: 'profile_photos',
        publicId: userId,
      );

      // Update user document with new photo URL
      await _firebaseService.firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update({
            'photoUrl': photoUrl,
            'updatedAt': DateTime.now().toIso8601String(),
          });

      return photoUrl;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update user photo');
    } catch (e) {
      throw ServerException('Failed to update user photo: $e');
    }
  }

  @override
  Future<void> blockUser(String userId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser.id == userId) {
        throw ServerException('Cannot block yourself');
      }

      final targetUser = await getUserById(userId);

      final blockedBy = List<String>.from(targetUser.blockedBy);
      if (!blockedBy.contains(currentUser.id)) {
        blockedBy.add(currentUser.id);
      }

      final blockedUsers = List<String>.from(currentUser.blockedUsers);
      if (!blockedUsers.contains(userId)) {
        blockedUsers.add(userId);
      }

      final batch = _firebaseService.firestore.batch();

      // Update target user's blockedBy list
      final targetRef = _firebaseService.firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId);
      batch.update(targetRef, {
        'blockedBy': blockedBy,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update current user's blockedUsers list
      final currentUserRef = _firebaseService.firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(currentUser.id);
      batch.update(currentUserRef, {
        'blockedUsers': blockedUsers,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to block user');
    } catch (e) {
      throw ServerException('Failed to block user: $e');
    }
  }

  @override
  Future<void> reportUser(String userId, String reason) async {
    try {
      final currentUserId = _firebaseService.currentUserId;
      if (currentUserId == null) {
        throw ServerException('No authenticated user');
      }

      // Create a report document
      await _firebaseService.firestore
          .collection('reports') // TODO: Add to FirebaseConstants
          .add({
            'reportedUserId': userId,
            'reporterId': currentUserId,
            'reason': reason,
            'createdAt': FieldValue.serverTimestamp(),
            'status': 'pending',
          });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to report user');
    } catch (e) {
      throw ServerException('Failed to report user: $e');
    }
  }

  @override
  Future<void> rateUser({
    required String userId,
    required int rating,
    String? comment,
  }) async {
    try {
      // Use Firestore transaction for atomic rating update
      await _firebaseService.firestore.runTransaction((transaction) async {
        final userRef = _firebaseService.firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(userId);

        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) {
          throw ServerException('User not found');
        }

        final userData = userDoc.data()!;
        final currentAvg = (userData['ratingAvg'] as num?)?.toDouble() ?? 0.0;
        final currentTotal = (userData['totalSwaps'] as int?) ?? 0;

        // Calculate new average
        final newTotal = currentTotal + 1;
        final newAvg = ((currentAvg * currentTotal) + rating) / newTotal;

        transaction.update(userRef, {
          'ratingAvg': newAvg,
          'totalSwaps': newTotal,
          'verifiedBadge': newTotal >= AppConstants.minRatingForVerified,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to rate user');
    } catch (e) {
      throw ServerException('Failed to rate user: $e');
    }
  }
}
