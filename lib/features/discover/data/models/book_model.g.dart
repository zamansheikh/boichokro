// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookModel _$BookModelFromJson(Map<String, dynamic> json) => BookModel(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  title: json['title'] as String,
  author: json['author'] as String,
  isbn: json['isbn'] as String?,
  coverUrl: json['coverUrl'] as String,
  condition: (json['condition'] as num).toInt(),
  genres: (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
  mode: $enumDecode(_$BookModeEnumMap, json['mode']),
  exchangeWithBookId: json['exchangeWithBookId'] as String?,
  location: BookModel._locationFromJson(
    json['location'] as Map<String, dynamic>,
  ),
  status: $enumDecode(_$BookStatusEnumMap, json['status']),
  activeRequestId: json['activeRequestId'] as String?,
  description: json['description'] as String?,
  createdAt: BookModel._dateTimeFromJson(json['createdAt']),
  updatedAt: BookModel._dateTimeFromJson(json['updatedAt']),
);

Map<String, dynamic> _$BookModelToJson(BookModel instance) => <String, dynamic>{
  'id': instance.id,
  'ownerId': instance.ownerId,
  'title': instance.title,
  'author': instance.author,
  'isbn': instance.isbn,
  'coverUrl': instance.coverUrl,
  'condition': instance.condition,
  'genres': instance.genres,
  'mode': _$BookModeEnumMap[instance.mode]!,
  'exchangeWithBookId': instance.exchangeWithBookId,
  'status': _$BookStatusEnumMap[instance.status]!,
  'activeRequestId': instance.activeRequestId,
  'description': instance.description,
  'location': BookModel._locationToJson(instance.location),
  'createdAt': BookModel._dateTimeToJson(instance.createdAt),
  'updatedAt': BookModel._dateTimeToJson(instance.updatedAt),
};

const _$BookModeEnumMap = {
  BookMode.donate: 'donate',
  BookMode.exchange: 'exchange',
};

const _$BookStatusEnumMap = {
  BookStatus.available: 'available',
  BookStatus.pending: 'pending',
  BookStatus.requested: 'requested',
  BookStatus.completed: 'completed',
};

BookLocationModel _$BookLocationModelFromJson(Map<String, dynamic> json) =>
    BookLocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      geohash: json['geohash'] as String,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$BookLocationModelToJson(BookLocationModel instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'geohash': instance.geohash,
      'address': instance.address,
    };
