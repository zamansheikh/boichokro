// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  phone: json['phone'] as String,
  name: json['name'] as String,
  photoUrl: json['photoUrl'] as String?,
  ratingAvg: (json['ratingAvg'] as num).toDouble(),
  totalSwaps: (json['totalSwaps'] as num).toInt(),
  verifiedBadge: json['verifiedBadge'] as bool,
  blockedBy: (json['blockedBy'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  blockedUsers: (json['blockedUsers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'name': instance.name,
  'photoUrl': instance.photoUrl,
  'ratingAvg': instance.ratingAvg,
  'totalSwaps': instance.totalSwaps,
  'verifiedBadge': instance.verifiedBadge,
  'blockedBy': instance.blockedBy,
  'blockedUsers': instance.blockedUsers,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
