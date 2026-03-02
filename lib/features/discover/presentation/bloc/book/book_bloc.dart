import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:geohash_plus/geohash_plus.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../../../core/network/firebase_service.dart';
import '../../../../../core/network/cloudinary_service.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/usecases/book_usecases.dart';
import 'book_event.dart';
import 'book_state.dart';

@injectable
class BookBloc extends Bloc<BookEvent, BookState> {
  final GetAllBooksUseCase getAllBooksUseCase;
  final SearchNearbyBooksUseCase searchNearbyBooksUseCase;
  final GetBookByIdUseCase getBookByIdUseCase;
  final GetBooksByOwnerUseCase getBooksByOwnerUseCase;
  final AddBookUseCase addBookUseCase;
  final UpdateBookUseCase updateBookUseCase;
  final DeleteBookUseCase deleteBookUseCase;
  final FirebaseService _firebaseService;
  final CloudinaryService _cloudinaryService;

  BookBloc({
    required this.getAllBooksUseCase,
    required this.searchNearbyBooksUseCase,
    required this.getBookByIdUseCase,
    required this.getBooksByOwnerUseCase,
    required this.addBookUseCase,
    required this.updateBookUseCase,
    required this.deleteBookUseCase,
    required FirebaseService firebaseService,
    required CloudinaryService cloudinaryService,
  }) : _firebaseService = firebaseService,
       _cloudinaryService = cloudinaryService,
       super(const BookInitial()) {
    on<LoadAllBooks>(_onLoadAllBooks);
    on<SearchNearbyBooks>(_onSearchNearbyBooks);
    on<LoadBookById>(_onLoadBookById);
    on<LoadMyBooks>(_onLoadMyBooks);
    on<AddBook>(_onAddBook);
    on<AddBookWithImage>(_onAddBookWithImage);
    on<UpdateBook>(_onUpdateBook);
    on<DeleteBook>(_onDeleteBook);
  }

  Future<void> _onLoadAllBooks(
    LoadAllBooks event,
    Emitter<BookState> emit,
  ) async {
    emit(const BookLoading());
    final result = await getAllBooksUseCase(const NoParams());
    
    result.fold(
      (failure) => emit(BookError(failure.message)),
      (books) => emit(BookLoaded(books)),
    );
  }

  Future<void> _onSearchNearbyBooks(
    SearchNearbyBooks event,
    Emitter<BookState> emit,
  ) async {
    emit(const BookLoading());
    final result = await searchNearbyBooksUseCase(
      SearchNearbyBooksParams(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusKm: event.radiusKm,
        searchQuery: event.searchQuery,
        genres: event.genres,
        minCondition: event.minCondition,
        mode: event.mode,
      ),
    );
    
    result.fold(
      (failure) => emit(BookError(failure.message)),
      (books) => emit(BookLoaded(books)),
    );
  }

  Future<void> _onLoadBookById(
    LoadBookById event,
    Emitter<BookState> emit,
  ) async {
    emit(const BookLoading());
    final result = await getBookByIdUseCase(GetBookByIdParams(event.bookId));
    
    result.fold(
      (failure) => emit(BookError(failure.message)),
      (book) => emit(BookDetailLoaded(book)),
    );
  }

  Future<void> _onLoadMyBooks(
    LoadMyBooks event,
    Emitter<BookState> emit,
  ) async {
    emit(const BookLoading());
    final result = await getBooksByOwnerUseCase(
      GetBooksByOwnerParams(event.ownerId),
    );
    
    result.fold(
      (failure) => emit(BookError(failure.message)),
      (books) => emit(BookLoaded(books)),
    );
  }

  Future<void> _onAddBook(AddBook event, Emitter<BookState> emit) async {
    emit(const BookLoading());
    final result = await addBookUseCase(AddBookParams(event.book));
    
    result.fold(
      (failure) => emit(BookError(failure.message)),
      (book) => emit(BookAdded(book)),
    );
  }

  Future<void> _onAddBookWithImage(
    AddBookWithImage event,
    Emitter<BookState> emit,
  ) async {
    try {
      emit(const BookLoading());

      // Get current user
      final currentUser = _firebaseService.auth.currentUser;
      if (currentUser == null) {
        emit(const BookError('User not authenticated'));
        return;
      }

      // Upload image to Cloudinary
      final coverUrl = await _cloudinaryService.uploadImage(
        file: event.coverImage,
        folder: 'book_covers',
      );

      // Calculate geohash
      final geohashString = GeoHash.encode(event.latitude, event.longitude).toString();

      // Determine condition index
      final conditionIndex = event.condition == 'Like New'
          ? 0
          : event.condition == 'Very Good'
              ? 1
              : event.condition == 'Good'
                  ? 2
                  : event.condition == 'Fair'
                      ? 3
                      : 4;

      // Create Book entity
      final book = Book(
        id: '', // Will be set by Firestore
        ownerId: currentUser.uid,
        title: event.title,
        author: event.author,
        isbn: event.isbn,
        coverUrl: coverUrl,
        condition: conditionIndex,
        genres: event.genres,
        mode: event.mode == 'donate' ? BookMode.donate : BookMode.exchange,
        location: BookLocation(
          latitude: event.latitude,
          longitude: event.longitude,
          geohash: geohashString,
        ),
        status: BookStatus.available,
        description: event.description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Call the add book use case
      final result = await addBookUseCase(AddBookParams(book));
      
      result.fold(
        (failure) => emit(BookError(failure.message)),
        (addedBook) => emit(BookAdded(addedBook)),
      );
    } catch (e) {
      emit(BookError('Failed to add book: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateBook(UpdateBook event, Emitter<BookState> emit) async {
    emit(const BookLoading());
    final result = await updateBookUseCase(UpdateBookParams(event.book));
    
    result.fold(
      (failure) => emit(BookError(failure.message)),
      (book) => emit(BookUpdated(book)),
    );
  }

  Future<void> _onDeleteBook(DeleteBook event, Emitter<BookState> emit) async {
    emit(const BookLoading());
    final result = await deleteBookUseCase(DeleteBookParams(event.bookId));
    
    result.fold(
      (failure) => emit(BookError(failure.message)),
      (_) => emit(const BookDeleted()),
    );
  }
}
