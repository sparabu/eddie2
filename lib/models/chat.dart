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
    required this.title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
  })  : id = id ?? const Uuid().v4(),
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
      return '';
    }
    
    // Find the first user message
    final firstUserMessage = messages.firstWhere(
      (message) => message.role == MessageRole.user,
      orElse: () => messages.first,
    );
    
    // Don't show any preview text, as per requirements
    return '';
  }
} 