// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String?,
      email: json['email'] as String,
      displayName: json['displayName'] as String? ?? '',
      photoURL: json['photoURL'] as String?,
      username: json['username'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      provider: json['provider'] as String? ?? 'password',
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoURL': instance.photoURL,
      'username': instance.username,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'isEmailVerified': instance.isEmailVerified,
      'provider': instance.provider,
    };
