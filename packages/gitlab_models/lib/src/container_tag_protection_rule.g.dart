// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_tag_protection_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContainerTagProtectionRule _$ContainerTagProtectionRuleFromJson(
  Map<String, dynamic> json,
) => _ContainerTagProtectionRule(
  id: (json['id'] as num).toInt(),
  projectId: (json['project_id'] as num).toInt(),
  tagNamePattern: json['tag_name_pattern'] as String,
  minimumAccessLevelForPush: json['minimum_access_level_for_push'] as String?,
  minimumAccessLevelForDelete:
      json['minimum_access_level_for_delete'] as String?,
);

Map<String, dynamic> _$ContainerTagProtectionRuleToJson(
  _ContainerTagProtectionRule instance,
) => <String, dynamic>{
  'id': instance.id,
  'project_id': instance.projectId,
  'tag_name_pattern': instance.tagNamePattern,
  'minimum_access_level_for_push': instance.minimumAccessLevelForPush,
  'minimum_access_level_for_delete': instance.minimumAccessLevelForDelete,
};
