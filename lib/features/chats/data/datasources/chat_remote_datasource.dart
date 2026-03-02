import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<ChatRoomModel> createOrGetChatRoom(
    List<String> participantIds, {
    String? bookId,
    String? bookName,
    String? ownerName,
    String? requesterName,
  });
  Future<ChatRoomModel> getChatRoomById(String chatRoomId);
  Future<List<ChatRoomModel>> getUserChatRooms(String userId);
  Future<MessageModel> sendMessage(MessageModel message);
  Future<List<MessageModel>> getMessages(
    String chatRoomId, {
    int? limit,
    String? lastMessageId,
  });
  Future<void> markMessagesAsRead(String chatRoomId, String userId);
  Stream<MessageModel> subscribeToMessages(String chatRoomId);
  Stream<ChatRoomModel> subscribeToChatRoom(String chatRoomId);
}

@LazySingleton(as: ChatRemoteDataSource)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseService _firebaseService;

  ChatRemoteDataSourceImpl(this._firebaseService);

  @override
  Future<ChatRoomModel> createOrGetChatRoom(
    List<String> participantIds, {
    String? bookId,
    String? bookName,
    String? ownerName,
    String? requesterName,
  }) async {
    try {
      // Try to find existing chat room for these participants and book
      final sortedIds = List<String>.from(participantIds)..sort();

      Query<Map<String, dynamic>> query = _firebaseService.firestore
          .collection(FirebaseConstants.chatRoomsCollection)
          .where('participantIds', isEqualTo: sortedIds);

      // If bookId provided, find chat specific to this book
      if (bookId != null) {
        query = query.where('bookId', isEqualTo: bookId);
      }

      final querySnapshot = await query.limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        data['id'] = doc.id;
        return ChatRoomModel.fromJson(data);
      }

      // Create new chat room with DateTime instead of FieldValue
      final now = DateTime.now();
      final chatRoomData = {
        'participantIds': sortedIds,
        'lastMessage': null,
        'lastMessageTime': null,
        'unreadCount': {for (var id in sortedIds) id: 0},
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'bookId': bookId,
        'bookName': bookName,
        'ownerName': ownerName,
        'requesterName': requesterName,
      };

      final docRef = await _firebaseService.firestore
          .collection(FirebaseConstants.chatRoomsCollection)
          .add(chatRoomData);

      // Return immediately without fetching (avoid timestamp null issue)
      return ChatRoomModel(
        id: docRef.id,
        participantIds: sortedIds,
        lastMessage: null,
        lastMessageTime: null,
        unreadCount: {for (var id in sortedIds) id: 0},
        createdAt: now,
        updatedAt: now,
        bookId: bookId,
        bookName: bookName,
        ownerName: ownerName,
        requesterName: requesterName,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create/get chat room');
    } catch (e) {
      throw ServerException('Failed to create/get chat room: $e');
    }
  }

  @override
  Future<ChatRoomModel> getChatRoomById(String chatRoomId) async {
    try {
      final doc = await _firebaseService.firestore
          .collection(FirebaseConstants.chatRoomsCollection)
          .doc(chatRoomId)
          .get();

      if (!doc.exists) {
        throw ServerException('Chat room not found');
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      return ChatRoomModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get chat room');
    } catch (e) {
      throw ServerException('Failed to get chat room: $e');
    }
  }

  @override
  Future<List<ChatRoomModel>> getUserChatRooms(String userId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection(FirebaseConstants.chatRoomsCollection)
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ChatRoomModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get user chat rooms');
    } catch (e) {
      throw ServerException('Failed to get user chat rooms: $e');
    }
  }

  @override
  Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      // Create message with DateTime instead of FieldValue
      final now = DateTime.now();
      final messageData = message.toJson();
      messageData['createdAt'] = Timestamp.fromDate(now);

      final msgDocRef = await _firebaseService.firestore
          .collection(FirebaseConstants.messagesCollection)
          .add(messageData);

      // Update chat room with last message
      await _firebaseService.firestore
          .collection(FirebaseConstants.chatRoomsCollection)
          .doc(message.chatRoomId)
          .update({
            'lastMessage': message.content,
            'lastMessageTime': Timestamp.fromDate(now),
            'updatedAt': Timestamp.fromDate(now),
          });

      // Return immediately without fetching (avoid timestamp null issue)
      return MessageModel(
        id: msgDocRef.id,
        chatRoomId: message.chatRoomId,
        senderId: message.senderId,
        content: message.content,
        type: message.type,
        isRead: message.isRead,
        createdAt: now,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to send message');
    } catch (e) {
      throw ServerException('Failed to send message: $e');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(
    String chatRoomId, {
    int? limit,
    String? lastMessageId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firebaseService.firestore
          .collection(FirebaseConstants.messagesCollection)
          .where('chatRoomId', isEqualTo: chatRoomId)
          .orderBy('createdAt', descending: true)
          .limit(limit ?? AppConstants.messagePageSize);

      // For pagination: if lastMessageId is provided, start after that document
      if (lastMessageId != null) {
        final lastDoc = await _firebaseService.firestore
            .collection(FirebaseConstants.messagesCollection)
            .doc(lastMessageId)
            .get();

        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MessageModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get messages');
    } catch (e) {
      throw ServerException('Failed to get messages: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      // Update unread count in chat room using transaction for atomicity
      await _firebaseService.firestore.runTransaction((transaction) async {
        final chatRoomRef = _firebaseService.firestore
            .collection(FirebaseConstants.chatRoomsCollection)
            .doc(chatRoomId);

        final chatRoomDoc = await transaction.get(chatRoomRef);
        if (!chatRoomDoc.exists) {
          throw ServerException('Chat room not found');
        }

        final data = chatRoomDoc.data()!;
        final unreadCount = Map<String, dynamic>.from(
          data['unreadCount'] ?? {},
        );
        unreadCount[userId] = 0;

        transaction.update(chatRoomRef, {
          'unreadCount': unreadCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to mark messages as read');
    } catch (e) {
      throw ServerException('Failed to mark messages as read: $e');
    }
  }

  @override
  Stream<MessageModel> subscribeToMessages(String chatRoomId) {
    return _firebaseService.firestore
        .collection(FirebaseConstants.messagesCollection)
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncExpand((snapshot) {
          // Emit only new messages (added documents)
          return Stream.fromIterable(
            snapshot.docChanges
                .where((change) => change.type == DocumentChangeType.added)
                .map((change) {
                  final data = change.doc.data()!;
                  data['id'] = change.doc.id;
                  return MessageModel.fromJson(data);
                }),
          );
        });
  }

  @override
  Stream<ChatRoomModel> subscribeToChatRoom(String chatRoomId) {
    return _firebaseService.firestore
        .collection(FirebaseConstants.chatRoomsCollection)
        .doc(chatRoomId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            throw ServerException('Chat room not found');
          }

          final data = snapshot.data()!;
          data['id'] = snapshot.id;

          return ChatRoomModel.fromJson(data);
        });
  }
}
