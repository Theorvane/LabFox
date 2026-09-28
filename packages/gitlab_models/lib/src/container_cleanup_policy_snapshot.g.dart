// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_cleanup_policy_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContainerCleanupPolicySnapshot _$ContainerCleanupPolicySnapshotFromJson(
  Map<String, dynamic> json,
) => _ContainerCleanupPolicySnapshot(
  reported: json['reported'] as bool,
  policy: json['policy'] == null
      ? null
      : ContainerCleanupPolicy.fromJson(json['policy'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ContainerCleanupPolicySnapshotToJson(
  _ContainerCleanupPolicySnapshot instance,
) => <String, dynamic>{
  'reported': instance.reported,
  'policy': instance.policy?.toJson(),
};
