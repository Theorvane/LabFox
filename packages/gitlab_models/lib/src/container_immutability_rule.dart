import 'package:freezed_annotation/freezed_annotation.dart';
part 'container_immutability_rule.freezed.dart';
part 'container_immutability_rule.g.dart';

/// GraphQL tag-rule projection; global IDs remain opaque strings.
@freezed
abstract class ContainerTagImmutabilityRule
    with _$ContainerTagImmutabilityRule {
  const factory ContainerTagImmutabilityRule({
    required String id,
    required String tagNamePattern,
    required bool immutable,
  }) = _ContainerTagImmutabilityRule;
  factory ContainerTagImmutabilityRule.fromJson(Map<String, dynamic> json) =>
      _$ContainerTagImmutabilityRuleFromJson(json);
}

@freezed
abstract class ContainerTagRulePageInfo with _$ContainerTagRulePageInfo {
  const factory ContainerTagRulePageInfo({
    required bool hasNextPage,
    String? endCursor,
  }) = _ContainerTagRulePageInfo;
  factory ContainerTagRulePageInfo.fromJson(Map<String, dynamic> json) =>
      _$ContainerTagRulePageInfoFromJson(json);
}

/// Complete connection page, including non-immutable protection rules.
@freezed
abstract class ContainerTagRuleConnection with _$ContainerTagRuleConnection {
  const factory ContainerTagRuleConnection({
    required List<ContainerTagImmutabilityRule> nodes,
    required ContainerTagRulePageInfo pageInfo,
  }) = _ContainerTagRuleConnection;
  factory ContainerTagRuleConnection.fromJson(Map<String, dynamic> json) =>
      _$ContainerTagRuleConnectionFromJson(json);
}
