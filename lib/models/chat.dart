import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'message.dart';

part 'chat.g.dart';

@JsonSerializable()
class Chat {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message> messages;

  Chat({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
  })  : id = id ?? const Uuid().v4(),
        title = title ?? 'New Chat',
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        messages = messages ?? [];

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
  Map<String, dynamic> toJson() => _$ChatToJson(this);

  Chat copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
  }) {
    return Chat(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      messages: messages ?? List.from(this.messages),
    );
  }

  Chat addMessage(Message message) {
    final updatedMessages = List<Message>.from(messages)..add(message);
    return copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
  }

  String get lastMessagePreview {
    if (messages.isEmpty) {
      return 'No messages';
    }
    final lastMessage = messages.last;
    final preview = lastMessage.content.length > 50
        ? '${lastMessage.content.substring(0, 50)}...'
        : lastMessage.content;
    return preview;
  }
} 