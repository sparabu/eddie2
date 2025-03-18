import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import 'dart:convert';

part 'project.g.dart';

@JsonSerializable()
class Project {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? imageBytesBase64; // Store image bytes as base64 string for persistence
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> chatIds; // Store IDs of chats associated with this project

  // Transient field - not stored in JSON, but used in memory
  @JsonKey(ignore: true)
  final Uint8List? imageBytes;

  Project({
    String? id,
    required this.title,
    this.description = '',
    this.imageUrl,
    this.imageBytesBase64,
    Uint8List? imageBytes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? chatIds,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        chatIds = chatIds ?? [],
        imageBytes = imageBytes ?? (imageBytesBase64 != null ? base64Decode(imageBytesBase64) : null);

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  
  Map<String, dynamic> toJson() {
    final json = _$ProjectToJson(this);
    
    // Add imageBytes as base64 if available
    if (imageBytes != null) {
      json['imageBytesBase64'] = base64Encode(imageBytes!);
    }
    
    return json;
  }

  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? imageBytesBase64,
    Uint8List? imageBytes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? chatIds,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytesBase64: imageBytesBase64 ?? this.imageBytesBase64,
      imageBytes: imageBytes ?? this.imageBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      chatIds: chatIds ?? List.from(this.chatIds),
    );
  }

  /// Add a chat ID to this project
  Project addChat(String chatId) {
    if (chatIds.contains(chatId)) return this;
    final updatedChatIds = List<String>.from(chatIds)..add(chatId);
    return copyWith(
      chatIds: updatedChatIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove a chat ID from this project
  Project removeChat(String chatId) {
    if (!chatIds.contains(chatId)) return this;
    final updatedChatIds = List<String>.from(chatIds)..remove(chatId);
    return copyWith(
      chatIds: updatedChatIds,
      updatedAt: DateTime.now(),
    );
  }
} 