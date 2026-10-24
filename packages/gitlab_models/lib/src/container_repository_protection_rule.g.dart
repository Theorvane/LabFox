// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_repository_protection_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContainerRepositoryProtectionRule _$ContainerRepositoryProtectionRuleFromJson(
  Map<String, dynamic> json,
) => _ContainerRepositoryProtectionRule(
  id: (json['id'] as num).toInt(),
  projectId: (json['project_id'] as num).toInt(),
  repositoryPathPattern: json['repository_path_pattern'] as String,
  minimumAccessLevelForPush: json['minimum_access_level_for_push'] as String?,
  minimumAccessLevelForDelete:
      json['minimum_access_level_for_delete'] as String?,
);

Map<String, dynamic> _$ContainerRepositoryProtectionRuleToJson(
  _ContainerRepositoryProtectionRule instance,
) => <String, dynamic>{
  'id': instance.id,
  'project_id': instance.projectId,
  'repository_path_pattern': instance.repositoryPathPattern,
  'minimum_access_level_for_push': instance.minimumAccessLevelForPush,
  'minimum_access_level_for_delete': instance.minimumAccessLevelForDelete,
};
