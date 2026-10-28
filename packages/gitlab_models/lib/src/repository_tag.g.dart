// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TagRelease _$TagReleaseFromJson(Map<String, dynamic> json) => _TagRelease(
  tagName: json['tag_name'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$TagReleaseToJson(_TagRelease instance) =>
    <String, dynamic>{
      'tag_name': instance.tagName,
      'description': instance.description,
    };

_RepositoryTag _$RepositoryTagFromJson(Map<String, dynamic> json) =>
    _RepositoryTag(
      name: json['name'] as String,
      message: json['message'] as String?,
      target: json['target'] as String?,
      isProtected: json['protected'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      commit: json['commit'] == null
          ? null
          : Commit.fromJson(json['commit'] as Map<String, dynamic>),
      release: json['release'] == null
          ? null
          : TagRelease.fromJson(json['release'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RepositoryTagToJson(_RepositoryTag instance) =>
    <String, dynamic>{
      'name': instance.name,
      'message': instance.message,
      'target': instance.target,
      'protected': instance.isProtected,
      'created_at': instance.createdAt?.toIso8601String(),
      'commit': instance.commit?.toJson(),
      'release': instance.release?.toJson(),
    };
