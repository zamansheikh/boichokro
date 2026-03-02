// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  phone: json['phone'] as String? ?? '',
  name: json['name'] as String? ?? 'Anonymous',
  photoUrl: json['photoUrl'] as String?,
  ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
  totalSwaps: (json['totalSwaps'] as num?)?.toInt() ?? 0,
  verifiedBadge: json['verifiedBadge'] as bool? ?? false,
  blockedBy: (json['blockedBy'] as List<dynamic>? ?? [])
      .map((e) => e as String)
      .toList(),
  createdAt: _parseDateTime(json['createdAt']),
  updatedAt: _parseDateTime(json['updatedAt']),
);

/// Safely parse Firestore Timestamps, ISO8601 strings, or DateTime objects.
DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  // Firestore Timestamp
  if (value is Timestamp) return value.toDate();
  // ISO string
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  // Already DateTime
  if (value is DateTime) return value;
  return DateTime.now();
}

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'name': instance.name,
  'photoUrl': instance.photoUrl,
  'ratingAvg': instance.ratingAvg,
  'totalSwaps': instance.totalSwaps,
  'verifiedBadge': instance.verifiedBadge,
  'blockedBy': instance.blockedBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
