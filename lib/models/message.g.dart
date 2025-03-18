// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String?,
      role: $enumDecode(_$MessageRoleEnumMap, json['role']),
      content: json['content'] as String,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      isError: json['isError'] as bool? ?? false,
      attachmentPath: json['attachmentPath'] as String?,
      attachmentName: json['attachmentName'] as String?,
      additionalAttachments: (json['additionalAttachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      additionalAttachmentNames:
          (json['additionalAttachmentNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'isError': instance.isError,
      'attachmentPath': instance.attachmentPath,
      'attachmentName': instance.attachmentName,
      'additionalAttachments': instance.additionalAttachments,
      'additionalAttachmentNames': instance.additionalAttachmentNames,
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
  MessageRole.system: 'system',
};
