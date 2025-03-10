// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qa_pair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QAPair _$QAPairFromJson(Map<String, dynamic> json) => QAPair(
      id: json['id'] as String?,
      question: json['question'] as String,
      answer: json['answer'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$QAPairToJson(QAPair instance) => <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tags': instance.tags,
    };
