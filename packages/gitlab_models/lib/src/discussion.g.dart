// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Discussion _$DiscussionFromJson(Map<String, dynamic> json) => _Discussion(
  id: json['id'] as String,
  individualNote: json['individual_note'] as bool,
  notes: (json['notes'] as List<dynamic>)
      .map((e) => Note.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DiscussionToJson(_Discussion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'individual_note': instance.individualNote,
      'notes': instance.notes.map((e) => e.toJson()).toList(),
    };
