import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/request.dart';

class BookRequestModel extends BookRequest {
  const BookRequestModel({
    required super.id,
    required super.bookId,
    required super.seekerId,
    required super.ownerId,
    super.offeredBookId,
    required super.status,
    super.chatRoomId,
    super.acceptedAt,
    super.ownerConfirmed = false,
    super.seekerConfirmed = false,
    required super.createdAt,
    required super.updatedAt,
    super.exchangeMethod,
    super.meetingTime,
    super.meetingLocation,
    super.courierMethod,
    super.trackingId,
    super.ownerRating,
    super.ownerReview,
    super.seekerRating,
    super.seekerReview,
  });

  factory BookRequestModel.fromJson(Map<String, dynamic> json) {
    return BookRequestModel(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      seekerId: json['seekerId'] as String,
      ownerId: json['ownerId'] as String? ?? '',
      offeredBookId: json['offeredBookId'] as String?,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      chatRoomId: json['chatRoomId'] as String?,
      acceptedAt: _convertTimestamp(json['acceptedAt']),
      ownerConfirmed: json['ownerConfirmed'] as bool? ?? false,
      seekerConfirmed: json['seekerConfirmed'] as bool? ?? false,
      createdAt: _convertTimestamp(json['createdAt']),
      updatedAt: _convertTimestamp(json['updatedAt']),
      exchangeMethod: json['exchangeMethod'] != null
          ? ExchangeMethod.values.firstWhere(
              (e) => e.name == json['exchangeMethod'],
              orElse: () => ExchangeMethod.meetup,
            )
          : null,
      meetingTime: _convertTimestampNullable(json['meetingTime']),
      meetingLocation: json['meetingLocation'] as String?,
      courierMethod: json['courierMethod'] as String?,
      trackingId: json['trackingId'] as String?,
      ownerRating: (json['ownerRating'] as num?)?.toDouble(),
      ownerReview: json['ownerReview'] as String?,
      seekerRating: (json['seekerRating'] as num?)?.toDouble(),
      seekerReview: json['seekerReview'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'seekerId': seekerId,
      'ownerId': ownerId,
      'offeredBookId': offeredBookId,
      'status': status.name,
      'chatRoomId': chatRoomId,
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'ownerConfirmed': ownerConfirmed,
      'seekerConfirmed': seekerConfirmed,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'exchangeMethod': exchangeMethod?.name,
      'meetingTime': meetingTime != null
          ? Timestamp.fromDate(meetingTime!)
          : null,
      'meetingLocation': meetingLocation,
      'courierMethod': courierMethod,
      'trackingId': trackingId,
      'ownerRating': ownerRating,
      'ownerReview': ownerReview,
      'seekerRating': seekerRating,
      'seekerReview': seekerReview,
    };
  }

  factory BookRequestModel.fromEntity(BookRequest request) {
    return BookRequestModel(
      id: request.id,
      bookId: request.bookId,
      seekerId: request.seekerId,
      ownerId: request.ownerId,
      offeredBookId: request.offeredBookId,
      status: request.status,
      chatRoomId: request.chatRoomId,
      acceptedAt: request.acceptedAt,
      ownerConfirmed: request.ownerConfirmed,
      seekerConfirmed: request.seekerConfirmed,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
      exchangeMethod: request.exchangeMethod,
      meetingTime: request.meetingTime,
      meetingLocation: request.meetingLocation,
      courierMethod: request.courierMethod,
      trackingId: request.trackingId,
      ownerRating: request.ownerRating,
      ownerReview: request.ownerReview,
      seekerRating: request.seekerRating,
      seekerReview: request.seekerReview,
    );
  }

  BookRequest toEntity() => this;
}

// Helper function to convert Firestore Timestamp to DateTime
DateTime _convertTimestamp(dynamic timestamp) {
  if (timestamp == null) return DateTime.now();
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is String) return DateTime.parse(timestamp);
  if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateTime.now();
}

// Helper function to convert Firestore Timestamp to nullable DateTime
DateTime? _convertTimestampNullable(dynamic timestamp) {
  if (timestamp == null) return null;
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is String) return DateTime.parse(timestamp);
  if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
  return null;
}
