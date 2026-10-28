// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Suggestion _$SuggestionFromJson(Map<String, dynamic> json) => _Suggestion(
  id: (json['id'] as num).toInt(),
  fromLine: (json['from_line'] as num?)?.toInt(),
  toLine: (json['to_line'] as num?)?.toInt(),
  fromContent: json['from_content'] as String?,
  toContent: json['to_content'] as String?,
  appliable: json['appliable'] as bool?,
  applicable: json['applicable'] as bool?,
  applied: json['applied'] as bool?,
);

Map<String, dynamic> _$SuggestionToJson(_Suggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'from_line': instance.fromLine,
      'to_line': instance.toLine,
      'from_content': instance.fromContent,
      'to_content': instance.toContent,
      'appliable': instance.appliable,
      'applicable': instance.applicable,
      'applied': instance.applied,
    };
