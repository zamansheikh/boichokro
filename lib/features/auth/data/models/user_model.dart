import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../discover/domain/entities/user.dart';

part 'user_model.g.dart';

/// Custom converter for DateTime fields that handles both Firestore Timestamp and ISO string formats
class FirestoreDateTimeConverter implements JsonConverter<DateTime, dynamic> {
  const FirestoreDateTimeConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    } else if (json is DateTime) {
      return json;
    }
    throw TypeError();
  }

  @override
  dynamic toJson(DateTime dateTime) {
    // Return DateTime - Firestore will handle it when sending to server
    return dateTime;
  }
}

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.phone,
    required super.name,
    super.photoUrl,
    required super.ratingAvg,
    required super.totalSwaps,
    required super.verifiedBadge,
    required super.blockedBy,
    @FirestoreDateTimeConverter() required super.createdAt,
    @FirestoreDateTimeConverter() required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      phone: user.phone,
      name: user.name,
      photoUrl: user.photoUrl,
      ratingAvg: user.ratingAvg,
      totalSwaps: user.totalSwaps,
      verifiedBadge: user.verifiedBadge,
      blockedBy: user.blockedBy,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  User toEntity() => this;
}
