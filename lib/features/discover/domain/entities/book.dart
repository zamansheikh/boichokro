import 'package:equatable/equatable.dart';

/// Book entity representing a book in the domain layer
class Book extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String author;
  final String? isbn;
  final String coverUrl;
  final int condition; // 0-4 (Like New to Worn)
  final List<String> genres;
  final BookMode mode; // donate or exchange
  final String? exchangeWithBookId;
  final BookLocation location;
  final BookStatus status;
  final String? activeRequestId; // request currently holding the book
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Book({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.author,
    this.isbn,
    required this.coverUrl,
    required this.condition,
    required this.genres,
    required this.mode,
    this.exchangeWithBookId,
    required this.location,
    required this.status,
    this.activeRequestId,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        author,
        isbn,
        coverUrl,
        condition,
        genres,
        mode,
        exchangeWithBookId,
        location,
        status,
        activeRequestId,
        description,
        createdAt,
        updatedAt,
      ];

  Book copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? author,
    String? isbn,
    String? coverUrl,
    int? condition,
    List<String>? genres,
    BookMode? mode,
    String? exchangeWithBookId,
    BookLocation? location,
    BookStatus? status,
    String? activeRequestId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      coverUrl: coverUrl ?? this.coverUrl,
      condition: condition ?? this.condition,
      genres: genres ?? this.genres,
      mode: mode ?? this.mode,
      exchangeWithBookId: exchangeWithBookId ?? this.exchangeWithBookId,
      location: location ?? this.location,
      status: status ?? this.status,
      activeRequestId: activeRequestId ?? this.activeRequestId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Book location with coordinates and geohash
class BookLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String geohash;
  final String? address;

  const BookLocation({
    required this.latitude,
    required this.longitude,
    required this.geohash,
    this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, geohash, address];
}

/// Book mode enum
enum BookMode {
  donate,
  exchange;

  String get displayName {
    switch (this) {
      case BookMode.donate:
        return 'Donate';
      case BookMode.exchange:
        return 'Exchange';
    }
  }
}

/// Book status enum
enum BookStatus {
  available,
  pending,
  requested,
  completed;

  String get displayName {
    switch (this) {
      case BookStatus.available:
        return 'Available';
      case BookStatus.pending:
        return 'Exchange Pending';
      case BookStatus.requested:
        return 'Requested';
      case BookStatus.completed:
        return 'Completed';
    }
  }
}
