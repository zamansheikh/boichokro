import 'package:equatable/equatable.dart';

/// User entity representing a user in the domain layer
class User extends Equatable {
  final String id;
  final String phone;
  final String name;
  final String? photoUrl;
  final double ratingAvg;
  final int totalSwaps;
  final bool verifiedBadge;
  final List<String> blockedBy;
  final List<String> blockedUsers;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.phone,
    required this.name,
    this.photoUrl,
    required this.ratingAvg,
    required this.totalSwaps,
    required this.verifiedBadge,
    required this.blockedBy,
    required this.blockedUsers,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    phone,
    name,
    photoUrl,
    ratingAvg,
    totalSwaps,
    verifiedBadge,
    blockedBy,
    blockedUsers,
    createdAt,
    updatedAt,
  ];

  User copyWith({
    String? id,
    String? phone,
    String? name,
    String? photoUrl,
    double? ratingAvg,
    int? totalSwaps,
    bool? verifiedBadge,
    List<String>? blockedBy,
    List<String>? blockedUsers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      totalSwaps: totalSwaps ?? this.totalSwaps,
      verifiedBadge: verifiedBadge ?? this.verifiedBadge,
      blockedBy: blockedBy ?? this.blockedBy,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
