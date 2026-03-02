import 'package:equatable/equatable.dart';
import '../../../../library/domain/entities/request.dart';

abstract class RequestState extends Equatable {
  const RequestState();

  @override
  List<Object?> get props => [];
}

class RequestInitial extends RequestState {
  const RequestInitial();
}

class RequestLoading extends RequestState {
  const RequestLoading();
}

class RequestLoaded extends RequestState {
  final List<BookRequest> requests;

  const RequestLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class RequestDetailLoaded extends RequestState {
  final BookRequest request;

  const RequestDetailLoaded(this.request);

  @override
  List<Object?> get props => [request];
}

class RequestCreated extends RequestState {
  final BookRequest request;

  const RequestCreated(this.request);

  @override
  List<Object?> get props => [request];
}

class RequestUpdated extends RequestState {
  final BookRequest request;

  const RequestUpdated(this.request);

  @override
  List<Object?> get props => [request];
}

class RequestDeleted extends RequestState {
  const RequestDeleted();
}

class RequestError extends RequestState {
  final String message;

  const RequestError(this.message);

  @override
  List<Object?> get props => [message];
}
