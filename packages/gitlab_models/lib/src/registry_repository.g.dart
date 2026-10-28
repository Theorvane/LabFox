// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registry_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegistryRepository _$RegistryRepositoryFromJson(Map<String, dynamic> json) =>
    _RegistryRepository(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      path: json['path'] as String,
      projectId: (json['project_id'] as num).toInt(),
      location: json['location'] as String?,
      status: json['status'] as String?,
      tagsCount: (json['tags_count'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RegistryRepositoryToJson(_RegistryRepository instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'path': instance.path,
      'project_id': instance.projectId,
      'location': instance.location,
      'status': instance.status,
      'tags_count': instance.tagsCount,
      'created_at': instance.createdAt?.toIso8601String(),
    };
