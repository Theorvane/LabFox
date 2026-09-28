// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: (json['id'] as num).toInt(),
  namespaceDetails: json['namespace'] == null
      ? null
      : ProjectNamespace.fromJson(json['namespace'] as Map<String, dynamic>),
  name: json['name'] as String,
  pathWithNamespace: json['path_with_namespace'] as String,
  description: json['description'] as String?,
  starCount: (json['star_count'] as num?)?.toInt() ?? 0,
  visibility: json['visibility'] as String?,
  defaultBranch: json['default_branch'] as String?,
  containerRegistryAccessLevel:
      json['container_registry_access_level'] as String?,
  packageRegistryAccessLevel: json['package_registry_access_level'] as String?,
  openIssuesCount: (json['open_issues_count'] as num?)?.toInt(),
  forksCount: (json['forks_count'] as num?)?.toInt(),
  wikiAccessLevel: json['wiki_access_level'] as String?,
  wikiEnabled: json['wiki_enabled'] as bool?,
  avatarUrl: json['avatar_url'] as String?,
  webUrl: json['web_url'] as String?,
  lastActivityAt: json['last_activity_at'] == null
      ? null
      : DateTime.parse(json['last_activity_at'] as String),
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': instance.id,
  'namespace': instance.namespaceDetails?.toJson(),
  'name': instance.name,
  'path_with_namespace': instance.pathWithNamespace,
  'description': instance.description,
  'star_count': instance.starCount,
  'visibility': instance.visibility,
  'default_branch': instance.defaultBranch,
  'container_registry_access_level': instance.containerRegistryAccessLevel,
  'package_registry_access_level': instance.packageRegistryAccessLevel,
  'open_issues_count': instance.openIssuesCount,
  'forks_count': instance.forksCount,
  'wiki_access_level': instance.wikiAccessLevel,
  'wiki_enabled': instance.wikiEnabled,
  'avatar_url': instance.avatarUrl,
  'web_url': instance.webUrl,
  'last_activity_at': instance.lastActivityAt?.toIso8601String(),
};

_ProjectNamespace _$ProjectNamespaceFromJson(Map<String, dynamic> json) =>
    _ProjectNamespace(
      id: (json['id'] as num?)?.toInt(),
      kind: json['kind'] as String?,
    );

Map<String, dynamic> _$ProjectNamespaceToJson(_ProjectNamespace instance) =>
    <String, dynamic>{'id': instance.id, 'kind': instance.kind};
