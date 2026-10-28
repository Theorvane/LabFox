// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gitlab_environment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GitLabEnvironment _$GitLabEnvironmentFromJson(Map<String, dynamic> json) =>
    _GitLabEnvironment(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      state: json['state'] as String,
      slug: json['slug'] as String?,
      tier: json['tier'] as String?,
      description: json['description'] as String?,
      externalUrl: json['external_url'] as String?,
      autoStopAt: json['auto_stop_at'] == null
          ? null
          : DateTime.parse(json['auto_stop_at'] as String),
      lastDeployment: json['last_deployment'] == null
          ? null
          : EnvironmentDeployment.fromJson(
              json['last_deployment'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$GitLabEnvironmentToJson(_GitLabEnvironment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'state': instance.state,
      'slug': instance.slug,
      'tier': instance.tier,
      'description': instance.description,
      'external_url': instance.externalUrl,
      'auto_stop_at': instance.autoStopAt?.toIso8601String(),
      'last_deployment': instance.lastDeployment?.toJson(),
    };

_EnvironmentDeployment _$EnvironmentDeploymentFromJson(
  Map<String, dynamic> json,
) => _EnvironmentDeployment(
  id: (json['id'] as num).toInt(),
  iid: (json['iid'] as num?)?.toInt(),
  ref: json['ref'] as String?,
  sha: json['sha'] as String?,
  status: json['status'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$EnvironmentDeploymentToJson(
  _EnvironmentDeployment instance,
) => <String, dynamic>{
  'id': instance.id,
  'iid': instance.iid,
  'ref': instance.ref,
  'sha': instance.sha,
  'status': instance.status,
  'created_at': instance.createdAt?.toIso8601String(),
};
