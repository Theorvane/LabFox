// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Note _$NoteFromJson(Map<String, dynamic> json) => _Note(
  id: (json['id'] as num).toInt(),
  body: json['body'] as String,
  isSystem: json['system'] as bool? ?? false,
  author: json['author'] == null
      ? null
      : User.fromJson(json['author'] as Map<String, dynamic>),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  type: json['type'] as String?,
  resolvable: json['resolvable'] as bool?,
  resolved: json['resolved'] as bool?,
  resolvedBy: json['resolved_by'] == null
      ? null
      : User.fromJson(json['resolved_by'] as Map<String, dynamic>),
  resolvedAt: json['resolved_at'] == null
      ? null
      : DateTime.parse(json['resolved_at'] as String),
);

Map<String, dynamic> _$NoteToJson(_Note instance) => <String, dynamic>{
  'id': instance.id,
  'body': instance.body,
  'system': instance.isSystem,
  'author': instance.author?.toJson(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'type': instance.type,
  'resolvable': instance.resolvable,
  'resolved': instance.resolved,
  'resolved_by': instance.resolvedBy?.toJson(),
  'resolved_at': instance.resolvedAt?.toIso8601String(),
};
