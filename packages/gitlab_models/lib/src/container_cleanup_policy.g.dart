// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_cleanup_policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContainerCleanupPolicy _$ContainerCleanupPolicyFromJson(
  Map<String, dynamic> json,
) => _ContainerCleanupPolicy(
  enabled: json['enabled'] as bool?,
  cadence: json['cadence'] as String?,
  keepN: (json['keep_n'] as num?)?.toInt(),
  olderThan: json['older_than'] as String?,
  nameRegexDelete: json['name_regex_delete'] as String?,
  nameRegex: json['name_regex'] as String?,
  nameRegexKeep: json['name_regex_keep'] as String?,
  nextRunAt: json['next_run_at'] == null
      ? null
      : DateTime.parse(json['next_run_at'] as String),
);

Map<String, dynamic> _$ContainerCleanupPolicyToJson(
  _ContainerCleanupPolicy instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'cadence': instance.cadence,
  'keep_n': instance.keepN,
  'older_than': instance.olderThan,
  'name_regex_delete': instance.nameRegexDelete,
  'name_regex': instance.nameRegex,
  'name_regex_keep': instance.nameRegexKeep,
  'next_run_at': instance.nextRunAt?.toIso8601String(),
};
