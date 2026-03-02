// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/domain/usecases/get_current_auth_user_usecase.dart'
    as _i830;
import '../../features/auth/domain/usecases/is_authenticated_usecase.dart'
    as _i928;
import '../../features/auth/domain/usecases/sign_in_with_google_usecase.dart'
    as _i673;
import '../../features/auth/domain/usecases/sign_out_usecase.dart' as _i915;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/chats/data/datasources/chat_remote_datasource.dart'
    as _i773;
import '../../features/chats/data/repositories/chat_repository_impl.dart'
    as _i430;
import '../../features/chats/domain/repositories/chat_repository.dart' as _i844;
import '../../features/chats/domain/usecases/create_or_get_chat_room_usecase.dart'
    as _i95;
import '../../features/chats/domain/usecases/get_chat_room_by_id_usecase.dart'
    as _i897;
import '../../features/chats/domain/usecases/get_messages_usecase.dart' as _i24;
import '../../features/chats/domain/usecases/get_user_chat_rooms_usecase.dart'
    as _i117;
import '../../features/chats/domain/usecases/mark_messages_as_read_usecase.dart'
    as _i656;
import '../../features/chats/domain/usecases/send_message_usecase.dart'
    as _i561;
import '../../features/chats/domain/usecases/subscribe_to_chat_room_usecase.dart'
    as _i694;
import '../../features/chats/domain/usecases/subscribe_to_messages_usecase.dart'
    as _i11;
import '../../features/chats/presentation/bloc/chat_bloc.dart' as _i1043;
import '../../features/discover/data/datasources/book_remote_datasource.dart'
    as _i179;
import '../../features/discover/data/repositories/auth_repository_impl.dart'
    as _i186;
import '../../features/discover/data/repositories/book_repository_impl.dart'
    as _i270;
import '../../features/discover/data/repositories/user_repository_impl.dart'
    as _i1016;
import '../../features/discover/domain/repositories/auth_repository.dart'
    as _i854;
import '../../features/discover/domain/repositories/book_repository.dart'
    as _i768;
import '../../features/discover/domain/repositories/user_repository.dart'
    as _i116;
import '../../features/discover/domain/usecases/auth_usecases.dart' as _i562;
import '../../features/discover/domain/usecases/book_usecases.dart' as _i822;
import '../../features/discover/domain/usecases/user_usecases.dart' as _i443;
import '../../features/discover/presentation/bloc/book/book_bloc.dart' as _i862;
import '../../features/discover/presentation/bloc/request/request_bloc.dart'
    as _i803;
import '../../features/discover/presentation/bloc/user/user_bloc.dart' as _i287;
import '../../features/library/data/datasources/request_remote_datasource.dart'
    as _i1026;
import '../../features/library/data/repositories/request_repository_impl.dart'
    as _i125;
import '../../features/library/domain/repositories/request_repository.dart'
    as _i89;
import '../../features/library/domain/usecases/confirm_exchange_usecase.dart'
    as _i271;
import '../../features/library/domain/usecases/create_request_usecase.dart'
    as _i656;
import '../../features/library/domain/usecases/delete_request_usecase.dart'
    as _i153;
import '../../features/library/domain/usecases/get_request_by_id_usecase.dart'
    as _i1071;
import '../../features/library/domain/usecases/get_requests_by_owner_usecase.dart'
    as _i107;
import '../../features/library/domain/usecases/get_requests_by_seeker_usecase.dart'
    as _i1006;
import '../../features/library/domain/usecases/get_requests_for_book_usecase.dart'
    as _i488;
import '../../features/library/domain/usecases/submit_review_usecase.dart'
    as _i331;
import '../../features/library/domain/usecases/update_request_status_usecase.dart'
    as _i552;
import '../../features/profile/data/datasources/user_remote_datasource.dart'
    as _i680;
import '../../features/profile/domain/usecases/get_current_user_profile_usecase.dart'
    as _i588;
import '../../features/profile/domain/usecases/update_profile_photo_usecase.dart'
    as _i669;
import '../../features/profile/domain/usecases/update_profile_usecase.dart'
    as _i478;
import '../../features/profile/presentation/bloc/profile_bloc.dart' as _i469;
import '../network/cloudinary_service.dart' as _i152;
import '../network/firebase_service.dart' as _i413;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i152.CloudinaryService>(() => _i152.CloudinaryService());
    gh.lazySingleton<_i413.FirebaseService>(() => _i413.FirebaseService());
    gh.lazySingleton<_i179.BookRemoteDataSource>(
      () => _i179.BookRemoteDataSourceImpl(gh<_i413.FirebaseService>()),
    );
    gh.lazySingleton<_i773.ChatRemoteDataSource>(
      () => _i773.ChatRemoteDataSourceImpl(gh<_i413.FirebaseService>()),
    );
    gh.lazySingleton<_i680.UserRemoteDataSource>(
      () => _i680.UserRemoteDataSourceImpl(
        gh<_i413.FirebaseService>(),
        gh<_i152.CloudinaryService>(),
      ),
    );
    gh.lazySingleton<_i1026.RequestRemoteDataSource>(
      () => _i1026.RequestRemoteDataSourceImpl(gh<_i413.FirebaseService>()),
    );
    gh.lazySingleton<_i161.AuthRemoteDataSource>(
      () => _i161.AuthRemoteDataSourceImpl(gh<_i413.FirebaseService>()),
    );
    gh.lazySingleton<_i768.BookRepository>(
      () => _i270.BookRepositoryImpl(gh<_i179.BookRemoteDataSource>()),
    );
    gh.lazySingleton<_i854.AuthRepository>(
      () => _i186.AuthRepositoryImpl(gh<_i161.AuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i844.ChatRepository>(
      () => _i430.ChatRepositoryImpl(gh<_i773.ChatRemoteDataSource>()),
    );
    gh.lazySingleton<_i116.UserRepository>(
      () => _i1016.UserRepositoryImpl(gh<_i680.UserRemoteDataSource>()),
    );
    gh.lazySingleton<_i89.RequestRepository>(
      () => _i125.RequestRepositoryImpl(gh<_i1026.RequestRemoteDataSource>()),
    );
    gh.factory<_i271.ConfirmExchangeUseCase>(
      () => _i271.ConfirmExchangeUseCase(gh<_i89.RequestRepository>()),
    );
    gh.factory<_i656.CreateRequestUseCase>(
      () => _i656.CreateRequestUseCase(gh<_i89.RequestRepository>()),
    );
    gh.factory<_i153.DeleteRequestUseCase>(
      () => _i153.DeleteRequestUseCase(gh<_i89.RequestRepository>()),
    );
    gh.factory<_i1071.GetRequestByIdUseCase>(
      () => _i1071.GetRequestByIdUseCase(gh<_i89.RequestRepository>()),
    );
    gh.factory<_i107.GetRequestsByOwnerUseCase>(
      () => _i107.GetRequestsByOwnerUseCase(gh<_i89.RequestRepository>()),
    );
    gh.factory<_i1006.GetRequestsBySeekerUseCase>(
      () => _i1006.GetRequestsBySeekerUseCase(gh<_i89.RequestRepository>()),
    );
    gh.factory<_i488.GetRequestsForBookUseCase>(
      () => _i488.GetRequestsForBookUseCase(gh<_i89.RequestRepository>()),
    );
    gh.factory<_i331.SubmitReviewUseCase>(
      () => _i331.SubmitReviewUseCase(gh<_i89.RequestRepository>()),
    );
    gh.factory<_i552.UpdateRequestStatusUseCase>(
      () => _i552.UpdateRequestStatusUseCase(gh<_i89.RequestRepository>()),
    );
    gh.factory<_i822.AddBookUseCase>(
      () => _i822.AddBookUseCase(gh<_i768.BookRepository>()),
    );
    gh.factory<_i822.UpdateBookUseCase>(
      () => _i822.UpdateBookUseCase(gh<_i768.BookRepository>()),
    );
    gh.factory<_i822.DeleteBookUseCase>(
      () => _i822.DeleteBookUseCase(gh<_i768.BookRepository>()),
    );
    gh.factory<_i822.GetBookByIdUseCase>(
      () => _i822.GetBookByIdUseCase(gh<_i768.BookRepository>()),
    );
    gh.factory<_i822.GetBooksByOwnerUseCase>(
      () => _i822.GetBooksByOwnerUseCase(gh<_i768.BookRepository>()),
    );
    gh.factory<_i822.SearchNearbyBooksUseCase>(
      () => _i822.SearchNearbyBooksUseCase(gh<_i768.BookRepository>()),
    );
    gh.factory<_i822.GetAllBooksUseCase>(
      () => _i822.GetAllBooksUseCase(gh<_i768.BookRepository>()),
    );
    gh.factory<_i830.GetCurrentAuthUserUseCase>(
      () => _i830.GetCurrentAuthUserUseCase(gh<_i854.AuthRepository>()),
    );
    gh.factory<_i928.IsAuthenticatedUseCase>(
      () => _i928.IsAuthenticatedUseCase(gh<_i854.AuthRepository>()),
    );
    gh.factory<_i673.SignInWithGoogleUseCase>(
      () => _i673.SignInWithGoogleUseCase(gh<_i854.AuthRepository>()),
    );
    gh.factory<_i915.SignOutUseCase>(
      () => _i915.SignOutUseCase(gh<_i854.AuthRepository>()),
    );
    gh.factory<_i562.SignInWithGoogleUseCase>(
      () => _i562.SignInWithGoogleUseCase(gh<_i854.AuthRepository>()),
    );
    gh.factory<_i562.SignOutUseCase>(
      () => _i562.SignOutUseCase(gh<_i854.AuthRepository>()),
    );
    gh.factory<_i562.IsAuthenticatedUseCase>(
      () => _i562.IsAuthenticatedUseCase(gh<_i854.AuthRepository>()),
    );
    gh.factory<_i562.GetCurrentUserIdUseCase>(
      () => _i562.GetCurrentUserIdUseCase(gh<_i854.AuthRepository>()),
    );
    gh.factory<_i562.GetCurrentAuthUserUseCase>(
      () => _i562.GetCurrentAuthUserUseCase(gh<_i854.AuthRepository>()),
    );
    gh.factory<_i95.CreateOrGetChatRoomUseCase>(
      () => _i95.CreateOrGetChatRoomUseCase(gh<_i844.ChatRepository>()),
    );
    gh.factory<_i897.GetChatRoomByIdUseCase>(
      () => _i897.GetChatRoomByIdUseCase(gh<_i844.ChatRepository>()),
    );
    gh.factory<_i24.GetMessagesUseCase>(
      () => _i24.GetMessagesUseCase(gh<_i844.ChatRepository>()),
    );
    gh.factory<_i117.GetUserChatRoomsUseCase>(
      () => _i117.GetUserChatRoomsUseCase(gh<_i844.ChatRepository>()),
    );
    gh.factory<_i656.MarkMessagesAsReadUseCase>(
      () => _i656.MarkMessagesAsReadUseCase(gh<_i844.ChatRepository>()),
    );
    gh.factory<_i561.SendMessageUseCase>(
      () => _i561.SendMessageUseCase(gh<_i844.ChatRepository>()),
    );
    gh.factory<_i694.SubscribeToChatRoomUseCase>(
      () => _i694.SubscribeToChatRoomUseCase(gh<_i844.ChatRepository>()),
    );
    gh.factory<_i11.SubscribeToMessagesUseCase>(
      () => _i11.SubscribeToMessagesUseCase(gh<_i844.ChatRepository>()),
    );
    gh.factory<_i803.RequestBloc>(
      () => _i803.RequestBloc(
        createRequestUseCase: gh<_i656.CreateRequestUseCase>(),
        updateRequestStatusUseCase: gh<_i552.UpdateRequestStatusUseCase>(),
        getRequestByIdUseCase: gh<_i1071.GetRequestByIdUseCase>(),
        getRequestsForBookUseCase: gh<_i488.GetRequestsForBookUseCase>(),
        getRequestsBySeekerUseCase: gh<_i1006.GetRequestsBySeekerUseCase>(),
        getRequestsByOwnerUseCase: gh<_i107.GetRequestsByOwnerUseCase>(),
        deleteRequestUseCase: gh<_i153.DeleteRequestUseCase>(),
        confirmExchangeUseCase: gh<_i271.ConfirmExchangeUseCase>(),
        submitReviewUseCase: gh<_i331.SubmitReviewUseCase>(),
      ),
    );
    gh.factory<_i443.GetCurrentUserUseCase>(
      () => _i443.GetCurrentUserUseCase(gh<_i116.UserRepository>()),
    );
    gh.factory<_i443.GetUserByIdUseCase>(
      () => _i443.GetUserByIdUseCase(gh<_i116.UserRepository>()),
    );
    gh.factory<_i443.UpdateUserProfileUseCase>(
      () => _i443.UpdateUserProfileUseCase(gh<_i116.UserRepository>()),
    );
    gh.factory<_i443.UpdateUserPhotoUseCase>(
      () => _i443.UpdateUserPhotoUseCase(gh<_i116.UserRepository>()),
    );
    gh.factory<_i443.BlockUserUseCase>(
      () => _i443.BlockUserUseCase(gh<_i116.UserRepository>()),
    );
    gh.factory<_i443.ReportUserUseCase>(
      () => _i443.ReportUserUseCase(gh<_i116.UserRepository>()),
    );
    gh.factory<_i443.RateUserUseCase>(
      () => _i443.RateUserUseCase(gh<_i116.UserRepository>()),
    );
    gh.factory<_i588.GetCurrentUserProfileUseCase>(
      () => _i588.GetCurrentUserProfileUseCase(gh<_i116.UserRepository>()),
    );
    gh.factory<_i669.UpdateProfilePhotoUseCase>(
      () => _i669.UpdateProfilePhotoUseCase(gh<_i116.UserRepository>()),
    );
    gh.factory<_i478.UpdateProfileUseCase>(
      () => _i478.UpdateProfileUseCase(gh<_i116.UserRepository>()),
    );
    gh.factory<_i862.BookBloc>(
      () => _i862.BookBloc(
        getAllBooksUseCase: gh<_i822.GetAllBooksUseCase>(),
        searchNearbyBooksUseCase: gh<_i822.SearchNearbyBooksUseCase>(),
        getBookByIdUseCase: gh<_i822.GetBookByIdUseCase>(),
        getBooksByOwnerUseCase: gh<_i822.GetBooksByOwnerUseCase>(),
        addBookUseCase: gh<_i822.AddBookUseCase>(),
        updateBookUseCase: gh<_i822.UpdateBookUseCase>(),
        deleteBookUseCase: gh<_i822.DeleteBookUseCase>(),
        firebaseService: gh<_i413.FirebaseService>(),
        cloudinaryService: gh<_i152.CloudinaryService>(),
      ),
    );
    gh.factory<_i1043.ChatBloc>(
      () => _i1043.ChatBloc(
        getUserChatRoomsUseCase: gh<_i117.GetUserChatRoomsUseCase>(),
        getChatRoomByIdUseCase: gh<_i897.GetChatRoomByIdUseCase>(),
        createOrGetChatRoomUseCase: gh<_i95.CreateOrGetChatRoomUseCase>(),
        getMessagesUseCase: gh<_i24.GetMessagesUseCase>(),
        sendMessageUseCase: gh<_i561.SendMessageUseCase>(),
        markMessagesAsReadUseCase: gh<_i656.MarkMessagesAsReadUseCase>(),
        subscribeToMessagesUseCase: gh<_i11.SubscribeToMessagesUseCase>(),
      ),
    );
    gh.factory<_i287.UserBloc>(
      () => _i287.UserBloc(
        getCurrentUserUseCase: gh<_i443.GetCurrentUserUseCase>(),
        getUserByIdUseCase: gh<_i443.GetUserByIdUseCase>(),
        updateUserProfileUseCase: gh<_i443.UpdateUserProfileUseCase>(),
        updateUserPhotoUseCase: gh<_i443.UpdateUserPhotoUseCase>(),
        blockUserUseCase: gh<_i443.BlockUserUseCase>(),
        reportUserUseCase: gh<_i443.ReportUserUseCase>(),
        rateUserUseCase: gh<_i443.RateUserUseCase>(),
      ),
    );
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        signInWithGoogleUseCase: gh<_i673.SignInWithGoogleUseCase>(),
        signOutUseCase: gh<_i915.SignOutUseCase>(),
        isAuthenticatedUseCase: gh<_i928.IsAuthenticatedUseCase>(),
        getCurrentAuthUserUseCase: gh<_i830.GetCurrentAuthUserUseCase>(),
      ),
    );
    gh.factory<_i469.ProfileBloc>(
      () => _i469.ProfileBloc(
        getCurrentUserProfileUseCase: gh<_i588.GetCurrentUserProfileUseCase>(),
        updateProfileUseCase: gh<_i478.UpdateProfileUseCase>(),
        updateProfilePhotoUseCase: gh<_i669.UpdateProfilePhotoUseCase>(),
      ),
    );
    return this;
  }
}
