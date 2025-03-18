import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'message.g.dart';

enum MessageRole {
  user,
  assistant,
  system,
}

@JsonSerializable()
class Message {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isError;
  
  // Primary attachment (for backward compatibility)
  final String? attachmentPath;
  final String? attachmentName;
  
  // Additional attachments (for multiple file support)
  final List<String>? additionalAttachments;
  final List<String>? additionalAttachmentNames;

  Message({
    String? id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.isError = false,
    this.attachmentPath,
    this.attachmentName,
    this.additionalAttachments,
    this.additionalAttachmentNames,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isError,
    String? attachmentPath,
    String? attachmentName,
    List<String>? additionalAttachments,
    List<String>? additionalAttachmentNames,
  }) {
    return Message(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      attachmentName: attachmentName ?? this.attachmentName,
      additionalAttachments: additionalAttachments ?? this.additionalAttachments,
      additionalAttachmentNames: additionalAttachmentNames ?? this.additionalAttachmentNames,
    );
  }
  
  // Helper method to get all attachment paths (main + additional)
  List<String> getAllAttachmentPaths() {
    final List<String> paths = [];
    
    if (attachmentPath != null) {
      paths.add(attachmentPath!);
    }
    
    if (additionalAttachments != null && additionalAttachments!.isNotEmpty) {
      paths.addAll(additionalAttachments!);
    }
    
    return paths;
  }
  
  // Helper method to get all attachment names (main + additional)
  List<String> getAllAttachmentNames() {
    final List<String> names = [];
    
    if (attachmentName != null) {
      names.add(attachmentName!);
    }
    
    if (additionalAttachmentNames != null && additionalAttachmentNames!.isNotEmpty) {
      names.addAll(additionalAttachmentNames!);
    } else if (additionalAttachments != null) {
      // Extract filenames from paths if names weren't provided
      names.addAll(additionalAttachments!.map((path) => path.split('/').last));
    }
    
    return names;
  }
} 