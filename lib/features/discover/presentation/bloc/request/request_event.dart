import 'package:equatable/equatable.dart';
import '../../../../library/domain/entities/request.dart';

abstract class RequestEvent extends Equatable {
  const RequestEvent();

  @override
  List<Object?> get props => [];
}

class CreateRequest extends RequestEvent {
  final BookRequest request;

  const CreateRequest(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateRequestStatus extends RequestEvent {
  final String requestId;
  final RequestStatus status;

  const UpdateRequestStatus({required this.requestId, required this.status});

  @override
  List<Object?> get props => [requestId, status];
}

class LoadRequestById extends RequestEvent {
  final String requestId;

  const LoadRequestById(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class LoadRequestsForBook extends RequestEvent {
  final String bookId;

  const LoadRequestsForBook(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class LoadMyRequests extends RequestEvent {
  final String seekerId;

  const LoadMyRequests(this.seekerId);

  @override
  List<Object?> get props => [seekerId];
}

class LoadMyIncomingRequests extends RequestEvent {
  final String ownerId;

  const LoadMyIncomingRequests(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}

class DeleteRequest extends RequestEvent {
  final String requestId;

  const DeleteRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class ConfirmExchange extends RequestEvent {
  final String requestId;
  final String userId;

  const ConfirmExchange({required this.requestId, required this.userId});

  @override
  List<Object?> get props => [requestId, userId];
}

class SubmitReview extends RequestEvent {
  final String requestId;
  final String reviewerId;
  final double rating;
  final String reviewText;

  const SubmitReview({
    required this.requestId,
    required this.reviewerId,
    required this.rating,
    required this.reviewText,
  });

  @override
  List<Object?> get props => [requestId, reviewerId, rating, reviewText];
}
