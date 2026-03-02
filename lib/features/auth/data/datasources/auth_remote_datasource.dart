import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<bool> isAuthenticated();
  Future<String> getCurrentUserId();
  Future<UserModel> getCurrentUser();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseService _firebaseService;

  AuthRemoteDataSourceImpl(this._firebaseService);

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Get GoogleSignIn instance
      final google = GoogleSignIn.instance;
      await google.initialize();

      // Authenticate with Google using the new API (Google Sign In 7.x.x)
      final account = await google.authenticate();
      final auth = account.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        // accessToken can be omitted if not needed
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _firebaseService.auth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;
      
      if (firebaseUser == null) {
        throw const AuthException('Failed to sign in with Google');
      }

      // Check if user document exists in Firestore
      final userDoc = await _firebaseService.firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      UserModel userModel;

      if (!userDoc.exists) {
        // Create new user document
        userModel = UserModel(
          id: firebaseUser.uid,
          phone: firebaseUser.phoneNumber ?? '',
          name: firebaseUser.displayName ?? 'Anonymous',
          photoUrl: firebaseUser.photoURL,
          ratingAvg: 0.0,
          totalSwaps: 0,
          verifiedBadge: firebaseUser.emailVerified,
          blockedBy: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save to Firestore
        await _firebaseService.firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(firebaseUser.uid)
            .set(userModel.toJson());
      } else {
        // User exists, load from Firestore
        userModel = UserModel.fromJson(userDoc.data()!);
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Firebase authentication failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseService.auth.signOut(),
        GoogleSignIn.instance.signOut(),
      ]);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return _firebaseService.isAuthenticated;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<String> getCurrentUserId() async {
    try {
      final userId = _firebaseService.currentUserId;
      if (userId == null) {
        throw const AuthException('No authenticated user');
      }
      return userId;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final userId = _firebaseService.currentUserId;
      
      if (userId == null) {
        throw const AuthException('No authenticated user');
      }

      final userDoc = await _firebaseService.firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw const AuthException('User document not found');
      }

      return UserModel.fromJson(userDoc.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get current user');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}
