import 'package:freezed_annotation/freezed_annotation.dart';

part 'protected_branch.freezed.dart';
part 'protected_branch.g.dart';

/// A GitLab protected branch rule; [name] may be a wildcard.
@freezed
abstract class ProtectedBranch with _$ProtectedBranch {
  const factory ProtectedBranch({
    int? id,
    required String name,
    @JsonKey(name: 'push_access_levels')
    @Default(<ProtectedBranchAccess>[])
    List<ProtectedBranchAccess> pushAccessLevels,
    @JsonKey(name: 'merge_access_levels')
    @Default(<ProtectedBranchAccess>[])
    List<ProtectedBranchAccess> mergeAccessLevels,
    @JsonKey(name: 'unprotect_access_levels')
    @Default(<ProtectedBranchAccess>[])
    List<ProtectedBranchAccess> unprotectAccessLevels,
    @JsonKey(name: 'allow_force_push') @Default(false) bool allowForcePush,
    @JsonKey(name: 'code_owner_approval_required')
    @Default(false)
    bool codeOwnerApprovalRequired,
    bool? inherited,
  }) = _ProtectedBranch;

  factory ProtectedBranch.fromJson(Map<String, dynamic> json) =>
      _$ProtectedBranchFromJson(json);
}

/// One push or merge permission entry on a protected branch.
@freezed
abstract class ProtectedBranchAccess with _$ProtectedBranchAccess {
  const factory ProtectedBranchAccess({
    int? id,
    @JsonKey(name: 'access_level') int? accessLevel,
    @JsonKey(name: 'access_level_description') String? description,
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'group_id') int? groupId,
    @JsonKey(name: 'deploy_key_id') int? deployKeyId,
    @JsonKey(name: 'member_role_id') int? memberRoleId,
  }) = _ProtectedBranchAccess;

  factory ProtectedBranchAccess.fromJson(Map<String, dynamic> json) =>
      _$ProtectedBranchAccessFromJson(json);
}
