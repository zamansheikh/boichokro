import 'package:equatable/equatable.dart';

/// Request entity for book exchange/donation requests
class BookRequest extends Equatable {
  final String id;
  final String bookId;
  final String seekerId;
  final String ownerId;
  final String? offeredBookId; // null if donate mode
  final RequestStatus status;
  final String? chatRoomId;
  final DateTime? acceptedAt;
  final bool ownerConfirmed;
  final bool seekerConfirmed;
  final DateTime createdAt;
  final DateTime updatedAt;

  // New fields for exchange arrangements
  final ExchangeMethod? exchangeMethod; // meet-up or courier
  final DateTime? meetingTime;
  final String? meetingLocation;
  final String? courierMethod; // e.g., "Pathao", "Sundarban", etc.
  final String? trackingId;

  // Review/Rating fields
  final double? ownerRating; // Rating given by owner to seeker
  final String? ownerReview;
  final double? seekerRating; // Rating given by seeker to owner
  final String? seekerReview;

  const BookRequest({
    required this.id,
    required this.bookId,
    required this.seekerId,
    required this.ownerId,
    this.offeredBookId,
    required this.status,
    this.chatRoomId,
    this.acceptedAt,
    this.ownerConfirmed = false,
    this.seekerConfirmed = false,
    required this.createdAt,
    required this.updatedAt,
    this.exchangeMethod,
    this.meetingTime,
    this.meetingLocation,
    this.courierMethod,
    this.trackingId,
    this.ownerRating,
    this.ownerReview,
    this.seekerRating,
    this.seekerReview,
  });

  @override
  List<Object?> get props => [
    id,
    bookId,
    seekerId,
    ownerId,
    offeredBookId,
    status,
    chatRoomId,
    acceptedAt,
    ownerConfirmed,
    seekerConfirmed,
    createdAt,
    updatedAt,
    exchangeMethod,
    meetingTime,
    meetingLocation,
    courierMethod,
    trackingId,
    ownerRating,
    ownerReview,
    seekerRating,
    seekerReview,
  ];

  BookRequest copyWith({
    String? id,
    String? bookId,
    String? seekerId,
    String? ownerId,
    String? offeredBookId,
    RequestStatus? status,
    String? chatRoomId,
    DateTime? acceptedAt,
    bool? ownerConfirmed,
    bool? seekerConfirmed,
    DateTime? createdAt,
    DateTime? updatedAt,
    ExchangeMethod? exchangeMethod,
    DateTime? meetingTime,
    String? meetingLocation,
    String? courierMethod,
    String? trackingId,
    double? ownerRating,
    String? ownerReview,
    double? seekerRating,
    String? seekerReview,
  }) {
    return BookRequest(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      seekerId: seekerId ?? this.seekerId,
      ownerId: ownerId ?? this.ownerId,
      offeredBookId: offeredBookId ?? this.offeredBookId,
      status: status ?? this.status,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      ownerConfirmed: ownerConfirmed ?? this.ownerConfirmed,
      seekerConfirmed: seekerConfirmed ?? this.seekerConfirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      exchangeMethod: exchangeMethod ?? this.exchangeMethod,
      meetingTime: meetingTime ?? this.meetingTime,
      meetingLocation: meetingLocation ?? this.meetingLocation,
      courierMethod: courierMethod ?? this.courierMethod,
      trackingId: trackingId ?? this.trackingId,
      ownerRating: ownerRating ?? this.ownerRating,
      ownerReview: ownerReview ?? this.ownerReview,
      seekerRating: seekerRating ?? this.seekerRating,
      seekerReview: seekerReview ?? this.seekerReview,
    );
  }
}

/// Exchange method enum (meet-up or courier)
enum ExchangeMethod {
  meetup,
  courier;

  String get displayName {
    switch (this) {
      case ExchangeMethod.meetup:
        return 'Meet in Person';
      case ExchangeMethod.courier:
        return 'Courier Service';
    }
  }
}

/// Request status enum
enum RequestStatus {
  pending,
  accepted,
  declined,
  cancelled,
  completed;

  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.declined:
        return 'Declined';
      case RequestStatus.cancelled:
        return 'Cancelled';
      case RequestStatus.completed:
        return 'Completed';
    }
  }
}
