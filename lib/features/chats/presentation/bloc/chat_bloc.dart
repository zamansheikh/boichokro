import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_user_chat_rooms_usecase.dart';
import '../../domain/usecases/get_chat_room_by_id_usecase.dart';
import '../../domain/usecases/create_or_get_chat_room_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/mark_messages_as_read_usecase.dart';
import '../../domain/usecases/subscribe_to_messages_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetUserChatRoomsUseCase getUserChatRoomsUseCase;
  final GetChatRoomByIdUseCase getChatRoomByIdUseCase;
  final CreateOrGetChatRoomUseCase createOrGetChatRoomUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final MarkMessagesAsReadUseCase markMessagesAsReadUseCase;
  final SubscribeToMessagesUseCase subscribeToMessagesUseCase;

  StreamSubscription? _messageSubscription;

  ChatBloc({
    required this.getUserChatRoomsUseCase,
    required this.getChatRoomByIdUseCase,
    required this.createOrGetChatRoomUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.markMessagesAsReadUseCase,
    required this.subscribeToMessagesUseCase,
  }) : super(const ChatInitial()) {
    on<LoadChatRooms>(_onLoadChatRooms);
    on<LoadChatRoom>(_onLoadChatRoom);
    on<CreateOrGetChatRoom>(_onCreateOrGetChatRoom);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkAsRead>(_onMarkAsRead);
    on<SubscribeToMessages>(_onSubscribeToMessages);
    on<NewMessageReceived>(_onNewMessageReceived);
  }

  Future<void> _onLoadChatRooms(
    LoadChatRooms event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    final result = await getUserChatRoomsUseCase(
      GetUserChatRoomsParams(event.userId),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (chatRooms) => emit(ChatRoomsLoaded(chatRooms)),
    );
  }

  Future<void> _onLoadChatRoom(
    LoadChatRoom event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    final result = await getChatRoomByIdUseCase(
      GetChatRoomByIdParams(event.chatRoomId),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (chatRoom) => emit(ChatRoomLoaded(chatRoom)),
    );
  }

  Future<void> _onCreateOrGetChatRoom(
    CreateOrGetChatRoom event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    final result = await createOrGetChatRoomUseCase(
      CreateOrGetChatRoomParams(
        participantIds: event.participantIds,
        bookId: event.bookId,
        bookName: event.bookName,
        ownerName: event.ownerName,
        requesterName: event.requesterName,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (chatRoom) => emit(ChatRoomLoaded(chatRoom)),
    );
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    final result = await getMessagesUseCase(
      GetMessagesParams(
        chatRoomId: event.chatRoomId,
        limit: event.limit,
        lastMessageId: event.lastMessageId,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) => emit(MessagesLoaded(messages)),
    );
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    // Send message to Firebase - real-time subscription will handle the update
    final result = await sendMessageUseCase(SendMessageParams(event.message));

    result.fold(
      (failure) {
        // Show error if sending fails
        emit(ChatError(failure.message));
      },
      (message) {
        // Message sent successfully - the real-time subscription will handle the update
        // Don't emit any state to preserve current messagesLoaded state
      },
    );
  }

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<ChatState> emit) async {
    final result = await markMessagesAsReadUseCase(
      MarkMessagesAsReadParams(
        chatRoomId: event.chatRoomId,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) => emit(const MarkedAsRead()),
    );
  }

  Future<void> _onSubscribeToMessages(
    SubscribeToMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    // First, load existing messages
    final messagesResult = await getMessagesUseCase(
      GetMessagesParams(chatRoomId: event.chatRoomId, limit: 100),
    );

    messagesResult.fold((failure) => emit(ChatError(failure.message)), (
      messages,
    ) {
      // Emit loaded messages
      emit(MessagesLoaded(messages));

      // Then subscribe to new messages
      _messageSubscription?.cancel();
      _messageSubscription = subscribeToMessagesUseCase(event.chatRoomId)
          .listen(
            (message) {
              // Add new message to the existing list
              add(NewMessageReceived(message));
            },
            onError: (error) {
              add(LoadMessages(chatRoomId: event.chatRoomId, limit: 100));
            },
          );
    });
  }

  void _onNewMessageReceived(
    NewMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    // Get current messages from state
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      // Add new message to the beginning of the list (since reversed)
      final updatedMessages = [event.message, ...currentState.messages];
      emit(MessagesLoaded(updatedMessages));
    } else {
      // If no current messages, just emit the new one
      emit(MessagesLoaded([event.message]));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
