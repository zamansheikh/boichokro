import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../library/domain/entities/request.dart';
import '../../../../library/domain/usecases/create_request_usecase.dart';
import '../../../../library/domain/usecases/update_request_status_usecase.dart';
import '../../../../library/domain/usecases/get_request_by_id_usecase.dart';
import '../../../../library/domain/usecases/get_requests_for_book_usecase.dart';
import '../../../../library/domain/usecases/get_requests_by_seeker_usecase.dart';
import '../../../../library/domain/usecases/get_requests_by_owner_usecase.dart';
import '../../../../library/domain/usecases/delete_request_usecase.dart';
import '../../../../library/domain/usecases/confirm_exchange_usecase.dart';
import '../../../../library/domain/usecases/submit_review_usecase.dart';
import 'request_event.dart';
import 'request_state.dart';

@injectable
class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final CreateRequestUseCase createRequestUseCase;
  final UpdateRequestStatusUseCase updateRequestStatusUseCase;
  final GetRequestByIdUseCase getRequestByIdUseCase;
  final GetRequestsForBookUseCase getRequestsForBookUseCase;
  final GetRequestsBySeekerUseCase getRequestsBySeekerUseCase;
  final GetRequestsByOwnerUseCase getRequestsByOwnerUseCase;
  final DeleteRequestUseCase deleteRequestUseCase;
  final ConfirmExchangeUseCase confirmExchangeUseCase;
  final SubmitReviewUseCase submitReviewUseCase;

  RequestBloc({
    required this.createRequestUseCase,
    required this.updateRequestStatusUseCase,
    required this.getRequestByIdUseCase,
    required this.getRequestsForBookUseCase,
    required this.getRequestsBySeekerUseCase,
    required this.getRequestsByOwnerUseCase,
    required this.deleteRequestUseCase,
    required this.confirmExchangeUseCase,
    required this.submitReviewUseCase,
  }) : super(const RequestInitial()) {
    on<CreateRequest>(_onCreateRequest);
    on<UpdateRequestStatus>(_onUpdateStatus);
    on<LoadRequestById>(_onLoadRequestById);
    on<LoadRequestsForBook>(_onLoadRequestsForBook);
    on<LoadMyRequests>(_onLoadMyRequests);
    on<LoadMyIncomingRequests>(_onLoadMyIncomingRequests);
    on<DeleteRequest>(_onDeleteRequest);
    on<ConfirmExchange>(_onConfirmExchange);
    on<SubmitReview>(_onSubmitReview);
  }

  Future<void> _onCreateRequest(
    CreateRequest event,
    Emitter<RequestState> emit,
  ) async {
    emit(const RequestLoading());
    final result = await createRequestUseCase(
      CreateRequestParams(event.request),
    );

    result.fold(
      (failure) => emit(RequestError(failure.message)),
      (request) => emit(RequestCreated(request)),
    );
  }

  Future<void> _onUpdateStatus(
    UpdateRequestStatus event,
    Emitter<RequestState> emit,
  ) async {
    emit(const RequestLoading());
    final result = await updateRequestStatusUseCase(
      UpdateRequestStatusParams(
        requestId: event.requestId,
        status: event.status,
      ),
    );

    result.fold(
      (failure) => emit(RequestError(failure.message)),
      (request) => emit(RequestUpdated(request)),
    );
  }

  Future<void> _onLoadRequestById(
    LoadRequestById event,
    Emitter<RequestState> emit,
  ) async {
    emit(const RequestLoading());
    final result = await getRequestByIdUseCase(
      GetRequestByIdParams(event.requestId),
    );

    result.fold(
      (failure) => emit(RequestError(failure.message)),
      (request) => emit(RequestDetailLoaded(request)),
    );
  }

  Future<void> _onLoadRequestsForBook(
    LoadRequestsForBook event,
    Emitter<RequestState> emit,
  ) async {
    emit(const RequestLoading());
    final result = await getRequestsForBookUseCase(
      GetRequestsForBookParams(event.bookId),
    );

    result.fold(
      (failure) => emit(RequestError(failure.message)),
      (requests) => emit(RequestLoaded(requests)),
    );
  }

  Future<void> _onLoadMyRequests(
    LoadMyRequests event,
    Emitter<RequestState> emit,
  ) async {
    emit(const RequestLoading());
    final result = await getRequestsBySeekerUseCase(
      GetRequestsBySeekerParams(event.seekerId),
    );

    result.fold(
      (failure) => emit(RequestError(failure.message)),
      (requests) => emit(RequestLoaded(requests)),
    );
  }

  Future<void> _onLoadMyIncomingRequests(
    LoadMyIncomingRequests event,
    Emitter<RequestState> emit,
  ) async {
    emit(const RequestLoading());

    // Load seeker requests (user's own requests) and owner requests (requests to the user) in parallel
    final results = await Future.wait([
      getRequestsBySeekerUseCase(GetRequestsBySeekerParams(event.ownerId)),
      getRequestsByOwnerUseCase(GetRequestsByOwnerParams(event.ownerId)),
    ]);

    final seekerResult = results[0];
    final ownerResult = results[1];

    // Handle errors - if both failed, show error
    if (seekerResult.isLeft() && ownerResult.isLeft()) {
      seekerResult.fold(
        (failure) => emit(RequestError(failure.message)),
        (_) {},
      );
      return;
    }

    // Merge both results
    final merged = <String, BookRequest>{};

    seekerResult.fold(
      (_) {}, // Ignore seeker errors if we have owner results
      (requests) {
        for (final req in requests) {
          merged[req.id] = req;
        }
      },
    );

    ownerResult.fold(
      (_) {}, // Ignore owner errors if we have seeker results
      (requests) {
        for (final req in requests) {
          merged[req.id] = req;
        }
      },
    );

    emit(RequestLoaded(merged.values.toList()));
  }

  Future<void> _onDeleteRequest(
    DeleteRequest event,
    Emitter<RequestState> emit,
  ) async {
    emit(const RequestLoading());
    final result = await deleteRequestUseCase(
      DeleteRequestParams(event.requestId),
    );

    result.fold(
      (failure) => emit(RequestError(failure.message)),
      (_) => emit(const RequestDeleted()),
    );
  }

  Future<void> _onConfirmExchange(
    ConfirmExchange event,
    Emitter<RequestState> emit,
  ) async {
    emit(const RequestLoading());
    final result = await confirmExchangeUseCase(
      ConfirmExchangeParams(requestId: event.requestId, userId: event.userId),
    );

    result.fold(
      (failure) => emit(RequestError(failure.message)),
      (request) => emit(RequestUpdated(request)),
    );
  }

  Future<void> _onSubmitReview(
    SubmitReview event,
    Emitter<RequestState> emit,
  ) async {
    emit(const RequestLoading());
    final result = await submitReviewUseCase(
      SubmitReviewParams(
        requestId: event.requestId,
        reviewerId: event.reviewerId,
        rating: event.rating,
        reviewText: event.reviewText,
      ),
    );

    result.fold(
      (failure) => emit(RequestError(failure.message)),
      (request) => emit(RequestUpdated(request)),
    );
  }
}
