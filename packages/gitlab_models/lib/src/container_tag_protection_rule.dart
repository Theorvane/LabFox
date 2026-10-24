import 'package:freezed_annotation/freezed_annotation.dart';

part 'container_tag_protection_rule.freezed.dart';
part 'container_tag_protection_rule.g.dart';

/// A tag-pattern protection rule; absent roles do not imply access permission.
@freezed
abstract class ContainerTagProtectionRule with _$ContainerTagProtectionRule {
  const factory ContainerTagProtectionRule({
    required int id,
    @JsonKey(name: 'project_id') required int projectId,
    @JsonKey(name: 'tag_name_pattern') required String tagNamePattern,
    @JsonKey(name: 'minimum_access_level_for_push')
    String? minimumAccessLevelForPush,
    @JsonKey(name: 'minimum_access_level_for_delete')
    String? minimumAccessLevelForDelete,
  }) = _ContainerTagProtectionRule;

  factory ContainerTagProtectionRule.fromJson(Map<String, dynamic> json) =>
      _$ContainerTagProtectionRuleFromJson(json);
}
