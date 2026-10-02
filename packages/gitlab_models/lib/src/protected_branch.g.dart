// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protected_branch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProtectedBranch _$ProtectedBranchFromJson(Map<String, dynamic> json) =>
    _ProtectedBranch(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      pushAccessLevels:
          (json['push_access_levels'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ProtectedBranchAccess.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ProtectedBranchAccess>[],
      mergeAccessLevels:
          (json['merge_access_levels'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ProtectedBranchAccess.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ProtectedBranchAccess>[],
      unprotectAccessLevels:
          (json['unprotect_access_levels'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ProtectedBranchAccess.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ProtectedBranchAccess>[],
      allowForcePush: json['allow_force_push'] as bool? ?? false,
      codeOwnerApprovalRequired:
          json['code_owner_approval_required'] as bool? ?? false,
      inherited: json['inherited'] as bool?,
    );

Map<String, dynamic> _$ProtectedBranchToJson(_ProtectedBranch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'push_access_levels': instance.pushAccessLevels
          .map((e) => e.toJson())
          .toList(),
      'merge_access_levels': instance.mergeAccessLevels
          .map((e) => e.toJson())
          .toList(),
      'unprotect_access_levels': instance.unprotectAccessLevels
          .map((e) => e.toJson())
          .toList(),
      'allow_force_push': instance.allowForcePush,
      'code_owner_approval_required': instance.codeOwnerApprovalRequired,
      'inherited': instance.inherited,
    };

_ProtectedBranchAccess _$ProtectedBranchAccessFromJson(
  Map<String, dynamic> json,
) => _ProtectedBranchAccess(
  id: (json['id'] as num?)?.toInt(),
  accessLevel: (json['access_level'] as num?)?.toInt(),
  description: json['access_level_description'] as String?,
  userId: (json['user_id'] as num?)?.toInt(),
  groupId: (json['group_id'] as num?)?.toInt(),
  deployKeyId: (json['deploy_key_id'] as num?)?.toInt(),
  memberRoleId: (json['member_role_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProtectedBranchAccessToJson(
  _ProtectedBranchAccess instance,
) => <String, dynamic>{
  'id': instance.id,
  'access_level': instance.accessLevel,
  'access_level_description': instance.description,
  'user_id': instance.userId,
  'group_id': instance.groupId,
  'deploy_key_id': instance.deployKeyId,
  'member_role_id': instance.memberRoleId,
};
