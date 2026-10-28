import 'package:freezed_annotation/freezed_annotation.dart';

part 'gitlab_deployment.freezed.dart';
part 'gitlab_deployment.g.dart';

/// One deployment of a project ref to an environment.
@freezed
abstract class GitLabDeployment with _$GitLabDeployment {
  const factory GitLabDeployment({
    required int id,
    int? iid,
    String? ref,
    String? sha,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    DeploymentEnvironment? environment,
    DeploymentJob? deployable,
    DeploymentActor? user,
  }) = _GitLabDeployment;

  factory GitLabDeployment.fromJson(Map<String, dynamic> json) =>
      _$GitLabDeploymentFromJson(json);
}

@freezed
abstract class DeploymentEnvironment with _$DeploymentEnvironment {
  const factory DeploymentEnvironment({
    int? id,
    required String name,
    @JsonKey(name: 'external_url') String? externalUrl,
  }) = _DeploymentEnvironment;

  factory DeploymentEnvironment.fromJson(Map<String, dynamic> json) =>
      _$DeploymentEnvironmentFromJson(json);
}

@freezed
abstract class DeploymentJob with _$DeploymentJob {
  const factory DeploymentJob({
    required int id,
    String? name,
    String? status,
    DeploymentPipeline? pipeline,
    DeploymentCommit? commit,
  }) = _DeploymentJob;

  factory DeploymentJob.fromJson(Map<String, dynamic> json) =>
      _$DeploymentJobFromJson(json);
}

@freezed
abstract class DeploymentPipeline with _$DeploymentPipeline {
  const factory DeploymentPipeline({required int id, String? status}) =
      _DeploymentPipeline;

  factory DeploymentPipeline.fromJson(Map<String, dynamic> json) =>
      _$DeploymentPipelineFromJson(json);
}

@freezed
abstract class DeploymentCommit with _$DeploymentCommit {
  const factory DeploymentCommit({required String id, String? title}) =
      _DeploymentCommit;

  factory DeploymentCommit.fromJson(Map<String, dynamic> json) =>
      _$DeploymentCommitFromJson(json);
}

@freezed
abstract class DeploymentActor with _$DeploymentActor {
  const factory DeploymentActor({int? id, String? name, String? username}) =
      _DeploymentActor;

  factory DeploymentActor.fromJson(Map<String, dynamic> json) =>
      _$DeploymentActorFromJson(json);
}
