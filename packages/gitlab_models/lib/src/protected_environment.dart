import 'package:freezed_annotation/freezed_annotation.dart';

part 'protected_environment.freezed.dart';
part 'protected_environment.g.dart';

/// A project environment protected by deployment and approval rules.
@freezed
abstract class ProtectedEnvironment with _$ProtectedEnvironment {
  const factory ProtectedEnvironment({
    required String name,
    @JsonKey(name: 'deploy_access_levels')
    @Default(<ProtectedEnvironmentAccess>[])
    List<ProtectedEnvironmentAccess> deployAccessLevels,
    @JsonKey(name: 'approval_rules')
    @Default(<ProtectedEnvironmentAccess>[])
    List<ProtectedEnvironmentAccess> approvalRules,
    @JsonKey(name: 'required_approval_count')
    @Default(0)
    int requiredApprovalCount,
  }) = _ProtectedEnvironment;

  factory ProtectedEnvironment.fromJson(Map<String, dynamic> json) =>
      _$ProtectedEnvironmentFromJson(json);
}

/// One permitted deployer or approver on a protected environment.
@freezed
abstract class ProtectedEnvironmentAccess with _$ProtectedEnvironmentAccess {
  const factory ProtectedEnvironmentAccess({
    int? id,
    @JsonKey(name: 'access_level') int? accessLevel,
    @JsonKey(name: 'access_level_description') String? description,
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'group_id') int? groupId,
    @JsonKey(name: 'group_inheritance_type') int? groupInheritanceType,
    @JsonKey(name: 'required_approvals') int? requiredApprovals,
  }) = _ProtectedEnvironmentAccess;

  factory ProtectedEnvironmentAccess.fromJson(Map<String, dynamic> json) =>
      _$ProtectedEnvironmentAccessFromJson(json);
}
