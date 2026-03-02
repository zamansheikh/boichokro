import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

/// Firebase Service - Singleton providing access to Firebase services
@lazySingleton
class FirebaseService {
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  // Helper method to check if user is authenticated
  bool get isAuthenticated => auth.currentUser != null;
  
  // Helper method to get current user ID
  String? get currentUserId => auth.currentUser?.uid;
  
  // Helper method to get current user
  User? get currentUser => auth.currentUser;
}

