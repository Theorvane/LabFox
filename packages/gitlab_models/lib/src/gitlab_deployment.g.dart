// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gitlab_deployment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GitLabDeployment _$GitLabDeploymentFromJson(Map<String, dynamic> json) =>
    _GitLabDeployment(
      id: (json['id'] as num).toInt(),
      iid: (json['iid'] as num?)?.toInt(),
      ref: json['ref'] as String?,
      sha: json['sha'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      environment: json['environment'] == null
          ? null
          : DeploymentEnvironment.fromJson(
              json['environment'] as Map<String, dynamic>,
            ),
      deployable: json['deployable'] == null
          ? null
          : DeploymentJob.fromJson(json['deployable'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : DeploymentActor.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GitLabDeploymentToJson(_GitLabDeployment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'iid': instance.iid,
      'ref': instance.ref,
      'sha': instance.sha,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'environment': instance.environment?.toJson(),
      'deployable': instance.deployable?.toJson(),
      'user': instance.user?.toJson(),
    };

_DeploymentEnvironment _$DeploymentEnvironmentFromJson(
  Map<String, dynamic> json,
) => _DeploymentEnvironment(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  externalUrl: json['external_url'] as String?,
);

Map<String, dynamic> _$DeploymentEnvironmentToJson(
  _DeploymentEnvironment instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'external_url': instance.externalUrl,
};

_DeploymentJob _$DeploymentJobFromJson(Map<String, dynamic> json) =>
    _DeploymentJob(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      status: json['status'] as String?,
      pipeline: json['pipeline'] == null
          ? null
          : DeploymentPipeline.fromJson(
              json['pipeline'] as Map<String, dynamic>,
            ),
      commit: json['commit'] == null
          ? null
          : DeploymentCommit.fromJson(json['commit'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DeploymentJobToJson(_DeploymentJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'pipeline': instance.pipeline?.toJson(),
      'commit': instance.commit?.toJson(),
    };

_DeploymentPipeline _$DeploymentPipelineFromJson(Map<String, dynamic> json) =>
    _DeploymentPipeline(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$DeploymentPipelineToJson(_DeploymentPipeline instance) =>
    <String, dynamic>{'id': instance.id, 'status': instance.status};

_DeploymentCommit _$DeploymentCommitFromJson(Map<String, dynamic> json) =>
    _DeploymentCommit(
      id: json['id'] as String,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$DeploymentCommitToJson(_DeploymentCommit instance) =>
    <String, dynamic>{'id': instance.id, 'title': instance.title};

_DeploymentActor _$DeploymentActorFromJson(Map<String, dynamic> json) =>
    _DeploymentActor(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      username: json['username'] as String?,
    );

Map<String, dynamic> _$DeploymentActorToJson(_DeploymentActor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
    };
