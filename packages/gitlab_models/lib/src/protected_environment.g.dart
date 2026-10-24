// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protected_environment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProtectedEnvironment _$ProtectedEnvironmentFromJson(
  Map<String, dynamic> json,
) => _ProtectedEnvironment(
  name: json['name'] as String,
  deployAccessLevels:
      (json['deploy_access_levels'] as List<dynamic>?)
          ?.map(
            (e) =>
                ProtectedEnvironmentAccess.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ProtectedEnvironmentAccess>[],
  approvalRules:
      (json['approval_rules'] as List<dynamic>?)
          ?.map(
            (e) =>
                ProtectedEnvironmentAccess.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ProtectedEnvironmentAccess>[],
  requiredApprovalCount:
      (json['required_approval_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ProtectedEnvironmentToJson(
  _ProtectedEnvironment instance,
) => <String, dynamic>{
  'name': instance.name,
  'deploy_access_levels': instance.deployAccessLevels
      .map((e) => e.toJson())
      .toList(),
  'approval_rules': instance.approvalRules.map((e) => e.toJson()).toList(),
  'required_approval_count': instance.requiredApprovalCount,
};

_ProtectedEnvironmentAccess _$ProtectedEnvironmentAccessFromJson(
  Map<String, dynamic> json,
) => _ProtectedEnvironmentAccess(
  id: (json['id'] as num?)?.toInt(),
  accessLevel: (json['access_level'] as num?)?.toInt(),
  description: json['access_level_description'] as String?,
  userId: (json['user_id'] as num?)?.toInt(),
  groupId: (json['group_id'] as num?)?.toInt(),
  groupInheritanceType: (json['group_inheritance_type'] as num?)?.toInt(),
  requiredApprovals: (json['required_approvals'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProtectedEnvironmentAccessToJson(
  _ProtectedEnvironmentAccess instance,
) => <String, dynamic>{
  'id': instance.id,
  'access_level': instance.accessLevel,
  'access_level_description': instance.description,
  'user_id': instance.userId,
  'group_id': instance.groupId,
  'group_inheritance_type': instance.groupInheritanceType,
  'required_approvals': instance.requiredApprovals,
};
