import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<BookModel> addBook(BookModel book);
  Future<BookModel> updateBook(BookModel book);
  Future<void> deleteBook(String bookId);
  Future<BookModel> getBookById(String bookId);
  Future<List<BookModel>> getBooksByOwnerId(String ownerId);
  Future<List<BookModel>> searchNearbyBooks({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? searchQuery,
    List<String>? genres,
    int? minCondition,
    String? mode,
  });
  Future<List<BookModel>> getAllBooks();
}

@LazySingleton(as: BookRemoteDataSource)
class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final FirebaseService _firebaseService;

  BookRemoteDataSourceImpl(this._firebaseService);

  @override
  Future<BookModel> addBook(BookModel book) async {
    try {
      final bookData = book.toJson();
      bookData['createdAt'] = FieldValue.serverTimestamp();
      bookData['updatedAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _firebaseService.firestore
          .collection(FirebaseConstants.booksCollection)
          .add(bookData);
      
      final doc = await docRef.get();
      final data = doc.data()!;
      data['id'] = doc.id;
      
      return BookModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to add book');
    } catch (e) {
      throw ServerException('Failed to add book: $e');
    }
  }

  @override
  Future<BookModel> updateBook(BookModel book) async {
    try {
      final bookData = book.toJson();
      bookData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firebaseService.firestore
          .collection(FirebaseConstants.booksCollection)
          .doc(book.id)
          .update(bookData);
      
      final doc = await _firebaseService.firestore
          .collection(FirebaseConstants.booksCollection)
          .doc(book.id)
          .get();
      
      final data = doc.data()!;
      data['id'] = doc.id;
      
      return BookModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update book');
    } catch (e) {
      throw ServerException('Failed to update book: $e');
    }
  }

  @override
  Future<void> deleteBook(String bookId) async {
    try {
      await _firebaseService.firestore
          .collection(FirebaseConstants.booksCollection)
          .doc(bookId)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete book');
    } catch (e) {
      throw ServerException('Failed to delete book: $e');
    }
  }

  @override
  Future<BookModel> getBookById(String bookId) async {
    try {
      final doc = await _firebaseService.firestore
          .collection(FirebaseConstants.booksCollection)
          .doc(bookId)
          .get();
      
      if (!doc.exists) {
        throw ServerException('Book not found');
      }
      
      final data = doc.data()!;
      data['id'] = doc.id;
      
      return BookModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get book');
    } catch (e) {
      throw ServerException('Failed to get book: $e');
    }
  }

  @override
  Future<List<BookModel>> getBooksByOwnerId(String ownerId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection(FirebaseConstants.booksCollection)
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return BookModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get books');
    } catch (e) {
      throw ServerException('Failed to get books: $e');
    }
  }

  @override
  Future<List<BookModel>> searchNearbyBooks({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? searchQuery,
    List<String>? genres,
    int? minCondition,
    String? mode,
  }) async {
    try {
      // Start with base query
    Query<Map<String, dynamic>> query = _firebaseService.firestore
      .collection(FirebaseConstants.booksCollection)
      .where('status', whereIn: ['available', 'pending']);

      // Add filters
      if (genres != null && genres.isNotEmpty) {
        query = query.where('genres', arrayContainsAny: genres);
      }

      if (minCondition != null) {
        query = query.where('condition', isGreaterThanOrEqualTo: minCondition);
      }

      if (mode != null) {
        query = query.where('mode', isEqualTo: mode);
      }

      // Execute query
      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      List<BookModel> books = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return BookModel.fromJson(data);
      }).toList();

      // Filter by search query (client-side since Firestore doesn't have full-text search)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        books = books.where((book) =>
            book.title.toLowerCase().contains(lowerQuery) ||
            book.author.toLowerCase().contains(lowerQuery) ||
            (book.description?.toLowerCase().contains(lowerQuery) ?? false)
        ).toList();
      }

      // TODO: Implement geohash-based distance filtering for location
      // For now, returning all matching books
      // You can add geoflutterfire or similar package for location-based queries

      return books;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to search books');
    } catch (e) {
      throw ServerException('Failed to search books: $e');
    }
  }

  @override
  Future<List<BookModel>> getAllBooks() async {
    try {
      final currentUser = _firebaseService.auth.currentUser;
      
    final querySnapshot = await _firebaseService.firestore
      .collection(FirebaseConstants.booksCollection)
      .where('status', whereIn: ['available', 'pending'])
          .limit(500)
          .get();
      
      // Filter out current user's books (client-side filtering)
      return querySnapshot.docs
          .where((doc) => currentUser == null || doc.data()['ownerId'] != currentUser.uid)
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return BookModel.fromJson(data);
          })
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get all books');
    } catch (e) {
      throw ServerException('Failed to get all books: $e');
    }
  }
}
