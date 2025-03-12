import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? username;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final String? provider; // 'password', 'google', etc.

  User({
    String? id,
    required this.email,
    this.displayName = '',
    this.photoURL,
    this.username,
    DateTime? createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.provider = 'password',
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Create a copy of this User with the given fields replaced
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? username,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    String? provider,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      provider: provider ?? this.provider,
    );
  }

  // Factory constructor for creating a User from Firebase User
  factory User.fromFirebase(dynamic firebaseUser) {
    // Determine provider
    String provider = 'password';
    if (firebaseUser.providerData.isNotEmpty) {
      final providerData = firebaseUser.providerData[0];
      if (providerData.providerId == 'google.com') {
        provider = 'google';
      }
    }
    
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      photoURL: firebaseUser.photoURL,
      username: null, // Username is stored separately in Firestore
      isEmailVerified: firebaseUser.emailVerified ?? false,
      lastLoginAt: firebaseUser.metadata?.lastSignInTime,
      createdAt: firebaseUser.metadata?.creationTime ?? DateTime.now(),
      provider: provider,
    );
  }

  // JSON serialization
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
} 