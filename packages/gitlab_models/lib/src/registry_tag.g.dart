// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registry_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegistryTag _$RegistryTagFromJson(Map<String, dynamic> json) => _RegistryTag(
  name: json['name'] as String,
  path: json['path'] as String,
  location: json['location'] as String?,
  revision: json['revision'] as String?,
  shortRevision: json['short_revision'] as String?,
  digest: json['digest'] as String?,
  totalSize: (json['total_size'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$RegistryTagToJson(_RegistryTag instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'location': instance.location,
      'revision': instance.revision,
      'short_revision': instance.shortRevision,
      'digest': instance.digest,
      'total_size': instance.totalSize,
      'created_at': instance.createdAt?.toIso8601String(),
    };
