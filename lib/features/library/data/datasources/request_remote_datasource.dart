import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../models/request_model.dart';

abstract class RequestRemoteDataSource {
  Future<BookRequestModel> createRequest(BookRequestModel request);
  Future<BookRequestModel> updateRequestStatus(String requestId, String status);
  Future<BookRequestModel> confirmExchange(String requestId, String userId);
  Future<BookRequestModel> getRequestById(String requestId);
  Future<List<BookRequestModel>> getRequestsForBook(String bookId);
  Future<List<BookRequestModel>> getRequestsBySeeker(String seekerId);
  Future<List<BookRequestModel>> getRequestsByOwner(String ownerId);
  Future<void> deleteRequest(String requestId);
  Future<BookRequestModel> submitReview({
    required String requestId,
    required String reviewerId,
    required double rating,
    required String reviewText,
  });
}

@LazySingleton(as: RequestRemoteDataSource)
class RequestRemoteDataSourceImpl implements RequestRemoteDataSource {
  final FirebaseService _firebaseService;

  RequestRemoteDataSourceImpl(this._firebaseService);

  @override
  Future<BookRequestModel> createRequest(BookRequestModel request) async {
    try {
      // Use DateTime instead of FieldValue to avoid timestamp null issues
      final now = DateTime.now();
      final requestData = request.toJson();
      requestData['createdAt'] = Timestamp.fromDate(now);
      requestData['updatedAt'] = Timestamp.fromDate(now);

      final docRef = await _firebaseService.firestore
          .collection(FirebaseConstants.requestsCollection)
          .add(requestData);

      // ⭐ KEY CHANGE: DON'T update any book status when creating request
      // Books stay 'available' so multiple people can request the same book
      // Status only changes when owner ACCEPTS a request

      // Return immediately without fetching (avoid timestamp null issue)
      return BookRequestModel(
        id: docRef.id,
        bookId: request.bookId,
        seekerId: request.seekerId,
        ownerId: request.ownerId,
        offeredBookId: request.offeredBookId,
        status: request.status,
        chatRoomId: request.chatRoomId,
        acceptedAt: null,
        ownerConfirmed: false,
        seekerConfirmed: false,
        createdAt: now,
        updatedAt: now,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create request');
    } catch (e) {
      throw ServerException('Failed to create request: $e');
    }
  }

  @override
  Future<BookRequestModel> updateRequestStatus(
    String requestId,
    String status,
  ) async {
    try {
      final now = DateTime.now();
      final firestore = _firebaseService.firestore;
      final requestRef = firestore
          .collection(FirebaseConstants.requestsCollection)
          .doc(requestId);
      final requestDoc = await requestRef.get();

      if (!requestDoc.exists) {
        throw ServerException('Request not found');
      }

      final requestData = requestDoc.data()!;
      final bookId = requestData['bookId'] as String;
      final offeredBookId = requestData['offeredBookId'] as String?;
      String ownerId = requestData['ownerId'] as String? ?? '';
      final seekerId = requestData['seekerId'] as String;
      final existingChatRoomId = requestData['chatRoomId'] as String?;

      if (ownerId.isEmpty) {
        final ownerBookSnapshot = await firestore
            .collection(FirebaseConstants.booksCollection)
            .doc(bookId)
            .get();

        if (!ownerBookSnapshot.exists) {
          throw ServerException('Book not found for request');
        }

        ownerId = ownerBookSnapshot.data()?['ownerId'] as String? ?? '';

        if (ownerId.isEmpty) {
          throw ServerException('Book owner not found for request');
        }
      }

      final requestUpdates = <String, dynamic>{
        'status': status,
        'updatedAt': Timestamp.fromDate(now),
      };

      String? chatRoomId = existingChatRoomId;

      if (status == 'accepted') {
        requestUpdates['acceptedAt'] = Timestamp.fromDate(now);
        requestUpdates['ownerConfirmed'] = false;
        requestUpdates['seekerConfirmed'] = false;

        if (chatRoomId == null) {
          final participants = [ownerId, seekerId]..sort();

          // Get book details for chat room metadata
          final bookSnapshot = await firestore
              .collection(FirebaseConstants.booksCollection)
              .doc(bookId)
              .get();

          String? bookName;
          String? ownerName;
          String? requesterName;

          if (bookSnapshot.exists) {
            final bookData = bookSnapshot.data()!;
            bookName = bookData['title'] as String?;

            // Get owner name
            final ownerUserId = bookData['ownerId'] as String?;
            if (ownerUserId != null) {
              final ownerSnapshot = await firestore
                  .collection(FirebaseConstants.usersCollection)
                  .doc(ownerUserId)
                  .get();
              if (ownerSnapshot.exists) {
                ownerName = ownerSnapshot.data()?['name'] as String?;
              }
            }
          }

          // Get requester name
          final requesterSnapshot = await firestore
              .collection(FirebaseConstants.usersCollection)
              .doc(seekerId)
              .get();
          if (requesterSnapshot.exists) {
            requesterName = requesterSnapshot.data()?['name'] as String?;
          }

          final existingChat = await firestore
              .collection(FirebaseConstants.chatRoomsCollection)
              .where('participantIds', isEqualTo: participants)
              .where('bookId', isEqualTo: bookId)
              .limit(1)
              .get();

          if (existingChat.docs.isNotEmpty) {
            chatRoomId = existingChat.docs.first.id;
            // Update existing chat room with book info if missing
            final existingData = existingChat.docs.first.data();
            if (existingData['bookName'] == null && bookName != null) {
              await existingChat.docs.first.reference.update({
                'bookId': bookId,
                'bookName': bookName,
                'ownerName': ownerName,
                'requesterName': requesterName,
                'updatedAt': Timestamp.fromDate(now),
              });
            }
          } else {
            final chatDoc = await firestore
                .collection(FirebaseConstants.chatRoomsCollection)
                .add({
                  'participantIds': participants,
                  'lastMessage': null,
                  'lastMessageTime': null,
                  'unreadCount': {for (final id in participants) id: 0},
                  'createdAt': Timestamp.fromDate(now),
                  'updatedAt': Timestamp.fromDate(now),
                  'bookId': bookId,
                  'bookName': bookName,
                  'ownerName': ownerName,
                  'requesterName': requesterName,
                });
            chatRoomId = chatDoc.id;
          }
        }

        requestUpdates['chatRoomId'] = chatRoomId;

        await firestore
            .collection(FirebaseConstants.booksCollection)
            .doc(bookId)
            .update({
              'status': 'pending',
              'activeRequestId': requestId,
              'updatedAt': Timestamp.fromDate(now),
            });

        if (offeredBookId != null) {
          await firestore
              .collection(FirebaseConstants.booksCollection)
              .doc(offeredBookId)
              .update({
                'status': 'pending',
                'activeRequestId': requestId,
                'updatedAt': Timestamp.fromDate(now),
              });
        }

        final otherRequests = await firestore
            .collection(FirebaseConstants.requestsCollection)
            .where('bookId', isEqualTo: bookId)
            .where('status', isEqualTo: 'pending')
            .get();

        for (final doc in otherRequests.docs) {
          if (doc.id == requestId) continue;
          await doc.reference.update({
            'status': 'declined',
            'acceptedAt': null,
            'ownerConfirmed': false,
            'seekerConfirmed': false,
            'updatedAt': Timestamp.fromDate(now),
          });
        }
      } else if (status == 'completed') {
        requestUpdates['ownerConfirmed'] = true;
        requestUpdates['seekerConfirmed'] = true;

        await firestore
            .collection(FirebaseConstants.booksCollection)
            .doc(bookId)
            .update({
              'status': 'completed',
              'activeRequestId': null,
              'updatedAt': Timestamp.fromDate(now),
            });

        if (offeredBookId != null) {
          await firestore
              .collection(FirebaseConstants.booksCollection)
              .doc(offeredBookId)
              .update({
                'status': 'completed',
                'activeRequestId': null,
                'updatedAt': Timestamp.fromDate(now),
              });
        }
      } else if (status == 'declined' || status == 'cancelled') {
        requestUpdates['acceptedAt'] = null;
        requestUpdates['ownerConfirmed'] = false;
        requestUpdates['seekerConfirmed'] = false;

        final bookSnapshot = await firestore
            .collection(FirebaseConstants.booksCollection)
            .doc(bookId)
            .get();

        if (bookSnapshot.exists &&
            bookSnapshot.data()?['activeRequestId'] == requestId) {
          await bookSnapshot.reference.update({
            'status': 'available',
            'activeRequestId': null,
            'updatedAt': Timestamp.fromDate(now),
          });
        }

        if (offeredBookId != null) {
          final offeredSnapshot = await firestore
              .collection(FirebaseConstants.booksCollection)
              .doc(offeredBookId)
              .get();

          if (offeredSnapshot.exists &&
              offeredSnapshot.data()?['activeRequestId'] == requestId) {
            await offeredSnapshot.reference.update({
              'status': 'available',
              'activeRequestId': null,
              'updatedAt': Timestamp.fromDate(now),
            });
          }
        }
      }

      await requestRef.update(requestUpdates);

      final updatedDoc = await requestRef.get();
      final data = updatedDoc.data()!;
      data['id'] = updatedDoc.id;

      return BookRequestModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update request status');
    } catch (e) {
      throw ServerException('Failed to update request status: $e');
    }
  }

  @override
  Future<BookRequestModel> confirmExchange(
    String requestId,
    String userId,
  ) async {
    try {
      final now = DateTime.now();
      final firestore = _firebaseService.firestore;
      final requestRef = firestore
          .collection(FirebaseConstants.requestsCollection)
          .doc(requestId);

      final requestSnap = await requestRef.get();
      if (!requestSnap.exists) {
        throw ServerException('Request not found');
      }

      final data = requestSnap.data()!;
      final status = data['status'] as String? ?? 'pending';
      if (status != 'accepted') {
        throw ServerException('Only accepted requests can be confirmed');
      }

      final seekerId = data['seekerId'] as String;
      String ownerId = data['ownerId'] as String? ?? '';
      final bookId = data['bookId'] as String;
      final offeredBookId = data['offeredBookId'] as String?;

      if (ownerId.isEmpty) {
        final ownerBookSnapshot = await firestore
            .collection(FirebaseConstants.booksCollection)
            .doc(bookId)
            .get();

        if (!ownerBookSnapshot.exists) {
          throw ServerException('Book not found for request');
        }

        ownerId = ownerBookSnapshot.data()?['ownerId'] as String? ?? '';

        if (ownerId.isEmpty) {
          throw ServerException('Book owner not found for request');
        }
      }

      if (userId != ownerId && userId != seekerId) {
        throw ServerException('User is not part of this request');
      }

      bool ownerConfirmed = data['ownerConfirmed'] as bool? ?? false;
      bool seekerConfirmed = data['seekerConfirmed'] as bool? ?? false;

      final updates = <String, dynamic>{'updatedAt': Timestamp.fromDate(now)};

      if (userId == ownerId && !ownerConfirmed) {
        ownerConfirmed = true;
        updates['ownerConfirmed'] = true;
      }

      if (userId == seekerId && !seekerConfirmed) {
        seekerConfirmed = true;
        updates['seekerConfirmed'] = true;
      }

      if (ownerConfirmed && seekerConfirmed) {
        updates['status'] = 'completed';
        await requestRef.update(updates);

        await firestore
            .collection(FirebaseConstants.booksCollection)
            .doc(bookId)
            .update({
              'status': 'completed',
              'activeRequestId': null,
              'updatedAt': Timestamp.fromDate(now),
            });

        if (offeredBookId != null) {
          await firestore
              .collection(FirebaseConstants.booksCollection)
              .doc(offeredBookId)
              .update({
                'status': 'completed',
                'activeRequestId': null,
                'updatedAt': Timestamp.fromDate(now),
              });
        }
      } else {
        if (updates.length > 1) {
          await requestRef.update(updates);
        } else {
          // Nothing new to confirm
          final unchangedData = Map<String, dynamic>.from(data)
            ..['id'] = requestId;
          return BookRequestModel.fromJson(unchangedData);
        }
      }

      final updatedSnap = await requestRef.get();
      final updatedData = updatedSnap.data()!;
      updatedData['id'] = updatedSnap.id;
      return BookRequestModel.fromJson(updatedData);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to confirm exchange');
    } catch (e) {
      throw ServerException('Failed to confirm exchange: $e');
    }
  }

  @override
  Future<BookRequestModel> getRequestById(String requestId) async {
    try {
      final doc = await _firebaseService.firestore
          .collection(FirebaseConstants.requestsCollection)
          .doc(requestId)
          .get();

      if (!doc.exists) {
        throw ServerException('Request not found');
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      return BookRequestModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get request');
    } catch (e) {
      throw ServerException('Failed to get request: $e');
    }
  }

  @override
  Future<List<BookRequestModel>> getRequestsForBook(String bookId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection(FirebaseConstants.requestsCollection)
          .where('bookId', isEqualTo: bookId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return BookRequestModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get requests for book');
    } catch (e) {
      throw ServerException('Failed to get requests for book: $e');
    }
  }

  @override
  Future<List<BookRequestModel>> getRequestsBySeeker(String seekerId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection(FirebaseConstants.requestsCollection)
          .where('seekerId', isEqualTo: seekerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return BookRequestModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get requests by seeker');
    } catch (e) {
      throw ServerException('Failed to get requests by seeker: $e');
    }
  }

  @override
  Future<List<BookRequestModel>> getRequestsByOwner(String ownerId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection(FirebaseConstants.requestsCollection)
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return BookRequestModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get requests by owner');
    } catch (e) {
      throw ServerException('Failed to get requests by owner: $e');
    }
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    try {
      await _firebaseService.firestore
          .collection(FirebaseConstants.requestsCollection)
          .doc(requestId)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete request');
    } catch (e) {
      throw ServerException('Failed to delete request: $e');
    }
  }

  @override
  Future<BookRequestModel> submitReview({
    required String requestId,
    required String reviewerId,
    required double rating,
    required String reviewText,
  }) async {
    try {
      final now = DateTime.now();
      final firestore = _firebaseService.firestore;
      final requestRef = firestore
          .collection(FirebaseConstants.requestsCollection)
          .doc(requestId);

      final requestSnap = await requestRef.get();
      if (!requestSnap.exists) throw ServerException('Request not found');

      final data = requestSnap.data()!;
      final seekerId = data['seekerId'] as String;
      final ownerId = data['ownerId'] as String? ?? '';

      final updates = <String, dynamic>{'updatedAt': Timestamp.fromDate(now)};
      String revieweeId;

      if (reviewerId == seekerId) {
        // Seeker is reviewing the owner
        updates['seekerRating'] = rating;
        updates['seekerReview'] = reviewText;
        revieweeId = ownerId;
      } else if (reviewerId == ownerId) {
        // Owner is reviewing the seeker
        updates['ownerRating'] = rating;
        updates['ownerReview'] = reviewText;
        revieweeId = seekerId;
      } else {
        throw ServerException('Reviewer is not part of this request');
      }

      await requestRef.update(updates);

      // Update reviewee's rating average in their user document
      if (revieweeId.isNotEmpty) {
        final userRef = firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(revieweeId);
        final userSnap = await userRef.get();
        if (userSnap.exists) {
          final userData = userSnap.data()!;
          final currentTotal = (userData['totalSwaps'] as num?)?.toInt() ?? 0;
          final currentAvg = (userData['ratingAvg'] as num?)?.toDouble() ?? 0.0;
          final newTotal = currentTotal + 1;
          final newAvg = ((currentAvg * currentTotal) + rating) / newTotal;
          await userRef.update({
            'ratingAvg': double.parse(newAvg.toStringAsFixed(2)),
            'totalSwaps': newTotal,
            'updatedAt': Timestamp.fromDate(now),
          });
        }
      }

      final updatedSnap = await requestRef.get();
      final updatedData = updatedSnap.data()!;
      updatedData['id'] = updatedSnap.id;
      return BookRequestModel.fromJson(updatedData);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to submit review');
    } catch (e) {
      throw ServerException('Failed to submit review: $e');
    }
  }
}
