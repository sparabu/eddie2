import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'qa_pair.g.dart';

@JsonSerializable()
class QAPair {
  final String id;
  final String question;
  final String answer;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  QAPair({
    String? id,
    required this.question,
    required this.answer,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        tags = tags ?? [];

  factory QAPair.fromJson(Map<String, dynamic> json) => _$QAPairFromJson(json);
  Map<String, dynamic> toJson() => _$QAPairToJson(this);

  QAPair copyWith({
    String? id,
    String? question,
    String? answer,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return QAPair(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      tags: tags ?? List.from(this.tags),
    );
  }
} 