import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/book.dart';

part 'book_model.g.dart';

@JsonSerializable(explicitToJson: true)
class BookModel extends Book {
  @override
  @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)
  final BookLocation location;

  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime updatedAt;

  const BookModel({
    required super.id,
    required super.ownerId,
    required super.title,
    required super.author,
    super.isbn,
    required super.coverUrl,
    required super.condition,
    required super.genres,
    required super.mode,
    super.exchangeWithBookId,
    required this.location,
    required super.status,
    super.activeRequestId,
    super.description,
    required this.createdAt,
    required this.updatedAt,
  }) : super(location: location, createdAt: createdAt, updatedAt: updatedAt);

  static BookLocation _locationFromJson(Map<String, dynamic> json) =>
      BookLocationModel.fromJson(json);

  static Map<String, dynamic> _locationToJson(BookLocation location) =>
      BookLocationModel.fromEntity(location).toJson();

  static DateTime _dateTimeFromJson(dynamic json) {
    if (json == null) return DateTime.now();
    if (json is Timestamp) {
      return json.toDate();
    }
    if (json is String) {
      return DateTime.parse(json);
    }
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    return DateTime.now();
  }

  static dynamic _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();

  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookModelToJson(this);

  factory BookModel.fromEntity(Book book) {
    return BookModel(
      id: book.id,
      ownerId: book.ownerId,
      title: book.title,
      author: book.author,
      isbn: book.isbn,
      coverUrl: book.coverUrl,
      condition: book.condition,
      genres: book.genres,
      mode: book.mode,
      exchangeWithBookId: book.exchangeWithBookId,
      location: BookLocationModel.fromEntity(book.location),
      status: book.status,
      activeRequestId: book.activeRequestId,
      description: book.description,
      createdAt: book.createdAt,
      updatedAt: book.updatedAt,
    );
  }

  Book toEntity() => this;
}

@JsonSerializable()
class BookLocationModel extends BookLocation {
  const BookLocationModel({
    required super.latitude,
    required super.longitude,
    required super.geohash,
    super.address,
  });

  factory BookLocationModel.fromJson(Map<String, dynamic> json) =>
      _$BookLocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookLocationModelToJson(this);

  factory BookLocationModel.fromEntity(BookLocation location) {
    return BookLocationModel(
      latitude: location.latitude,
      longitude: location.longitude,
      geohash: location.geohash,
      address: location.address,
    );
  }

  BookLocation toEntity() => this;
}
