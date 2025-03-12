import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;

  User({
    String? id,
    required this.email,
    this.displayName = '',
    DateTime? createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Create a copy of this User with the given fields replaced
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  // Factory constructor for creating a User from Firebase User
  factory User.fromFirebase(dynamic firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      isEmailVerified: firebaseUser.emailVerified ?? false,
      lastLoginAt: firebaseUser.metadata?.lastSignInTime,
      createdAt: firebaseUser.metadata?.creationTime ?? DateTime.now(),
    );
  }

  // JSON serialization
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
} 