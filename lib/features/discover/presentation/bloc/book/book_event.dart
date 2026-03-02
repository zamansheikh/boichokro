import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/book.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllBooks extends BookEvent {
  const LoadAllBooks();
}

class SearchNearbyBooks extends BookEvent {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String? searchQuery;
  final List<String>? genres;
  final int? minCondition;
  final BookMode? mode;

  const SearchNearbyBooks({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    this.searchQuery,
    this.genres,
    this.minCondition,
    this.mode,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    radiusKm,
    searchQuery,
    genres,
    minCondition,
    mode,
  ];
}

class LoadBookById extends BookEvent {
  final String bookId;

  const LoadBookById(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class LoadMyBooks extends BookEvent {
  final String ownerId;

  const LoadMyBooks(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}

class AddBook extends BookEvent {
  final Book book;

  const AddBook(this.book);

  @override
  List<Object?> get props => [book];
}

class AddBookWithImage extends BookEvent {
  final File coverImage;
  final String title;
  final String author;
  final String? isbn;
  final String? description;
  final List<String> genres;
  final String condition;
  final String mode;
  final double latitude;
  final double longitude;

  const AddBookWithImage({
    required this.coverImage,
    required this.title,
    required this.author,
    this.isbn,
    this.description,
    required this.genres,
    required this.condition,
    required this.mode,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
    coverImage,
    title,
    author,
    isbn,
    description,
    genres,
    condition,
    mode,
    latitude,
    longitude,
  ];
}

class UpdateBook extends BookEvent {
  final Book book;

  const UpdateBook(this.book);

  @override
  List<Object?> get props => [book];
}

class DeleteBook extends BookEvent {
  final String bookId;

  const DeleteBook(this.bookId);

  @override
  List<Object?> get props => [bookId];
}
