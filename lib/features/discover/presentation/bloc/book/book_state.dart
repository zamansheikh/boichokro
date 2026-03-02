import 'package:equatable/equatable.dart';
import '../../../domain/entities/book.dart';

abstract class BookState extends Equatable {
  const BookState();

  @override
  List<Object?> get props => [];
}

class BookInitial extends BookState {
  const BookInitial();
}

class BookLoading extends BookState {
  const BookLoading();
}

class BookLoaded extends BookState {
  final List<Book> books;

  const BookLoaded(this.books);

  @override
  List<Object?> get props => [books];
}

class BookDetailLoaded extends BookState {
  final Book book;

  const BookDetailLoaded(this.book);

  @override
  List<Object?> get props => [book];
}

class BookAdded extends BookState {
  final Book book;

  const BookAdded(this.book);

  @override
  List<Object?> get props => [book];
}

class BookUpdated extends BookState {
  final Book book;

  const BookUpdated(this.book);

  @override
  List<Object?> get props => [book];
}

class BookDeleted extends BookState {
  const BookDeleted();
}

class BookError extends BookState {
  final String message;

  const BookError(this.message);

  @override
  List<Object?> get props => [message];
}
