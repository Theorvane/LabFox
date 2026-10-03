import 'package:freezed_annotation/freezed_annotation.dart';

part 'container_repository_protection_rule.freezed.dart';
part 'container_repository_protection_rule.g.dart';

/// A path-pattern protection rule; absent roles do not imply access permission.
@freezed
abstract class ContainerRepositoryProtectionRule
    with _$ContainerRepositoryProtectionRule {
  const factory ContainerRepositoryProtectionRule({
    required int id,
    @JsonKey(name: 'project_id') required int projectId,
    @JsonKey(name: 'repository_path_pattern')
    required String repositoryPathPattern,
    @JsonKey(name: 'minimum_access_level_for_push')
    String? minimumAccessLevelForPush,
    @JsonKey(name: 'minimum_access_level_for_delete')
    String? minimumAccessLevelForDelete,
  }) = _ContainerRepositoryProtectionRule;

  factory ContainerRepositoryProtectionRule.fromJson(
    Map<String, dynamic> json,
  ) => _$ContainerRepositoryProtectionRuleFromJson(json);
}
