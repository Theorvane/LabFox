// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snippet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnippetFile _$SnippetFileFromJson(Map<String, dynamic> json) => _SnippetFile(
  path: json['path'] as String,
  rawUrl: json['raw_url'] as String?,
);

Map<String, dynamic> _$SnippetFileToJson(_SnippetFile instance) =>
    <String, dynamic>{'path': instance.path, 'raw_url': instance.rawUrl};

_Snippet _$SnippetFromJson(Map<String, dynamic> json) => _Snippet(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  visibility: json['visibility'] as String?,
  fileName: json['file_name'] as String?,
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => SnippetFile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  webUrl: json['web_url'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SnippetToJson(_Snippet instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'visibility': instance.visibility,
  'file_name': instance.fileName,
  'files': instance.files.map((e) => e.toJson()).toList(),
  'web_url': instance.webUrl,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
