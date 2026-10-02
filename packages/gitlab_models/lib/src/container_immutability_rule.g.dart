// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_immutability_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContainerTagImmutabilityRule _$ContainerTagImmutabilityRuleFromJson(
  Map<String, dynamic> json,
) => _ContainerTagImmutabilityRule(
  id: json['id'] as String,
  tagNamePattern: json['tagNamePattern'] as String,
  immutable: json['immutable'] as bool,
);

Map<String, dynamic> _$ContainerTagImmutabilityRuleToJson(
  _ContainerTagImmutabilityRule instance,
) => <String, dynamic>{
  'id': instance.id,
  'tagNamePattern': instance.tagNamePattern,
  'immutable': instance.immutable,
};

_ContainerTagRulePageInfo _$ContainerTagRulePageInfoFromJson(
  Map<String, dynamic> json,
) => _ContainerTagRulePageInfo(
  hasNextPage: json['hasNextPage'] as bool,
  endCursor: json['endCursor'] as String?,
);

Map<String, dynamic> _$ContainerTagRulePageInfoToJson(
  _ContainerTagRulePageInfo instance,
) => <String, dynamic>{
  'hasNextPage': instance.hasNextPage,
  'endCursor': instance.endCursor,
};

_ContainerTagRuleConnection _$ContainerTagRuleConnectionFromJson(
  Map<String, dynamic> json,
) => _ContainerTagRuleConnection(
  nodes: (json['nodes'] as List<dynamic>)
      .map(
        (e) => ContainerTagImmutabilityRule.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  pageInfo: ContainerTagRulePageInfo.fromJson(
    json['pageInfo'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ContainerTagRuleConnectionToJson(
  _ContainerTagRuleConnection instance,
) => <String, dynamic>{
  'nodes': instance.nodes.map((e) => e.toJson()).toList(),
  'pageInfo': instance.pageInfo.toJson(),
};
