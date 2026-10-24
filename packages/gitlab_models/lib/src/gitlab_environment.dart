import 'package:freezed_annotation/freezed_annotation.dart';

part 'gitlab_environment.freezed.dart';
part 'gitlab_environment.g.dart';

/// A deployment target belonging to one GitLab project.
@freezed
abstract class GitLabEnvironment with _$GitLabEnvironment {
  const factory GitLabEnvironment({
    required int id,
    required String name,
    required String state,
    String? slug,
    String? tier,
    String? description,
    @JsonKey(name: 'external_url') String? externalUrl,
    @JsonKey(name: 'auto_stop_at') DateTime? autoStopAt,
    @JsonKey(name: 'last_deployment') EnvironmentDeployment? lastDeployment,
  }) = _GitLabEnvironment;

  factory GitLabEnvironment.fromJson(Map<String, dynamic> json) =>
      _$GitLabEnvironmentFromJson(json);
}

/// Last deployment embedded in an environment detail response.
@freezed
abstract class EnvironmentDeployment with _$EnvironmentDeployment {
  const factory EnvironmentDeployment({
    required int id,
    int? iid,
    String? ref,
    String? sha,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _EnvironmentDeployment;

  factory EnvironmentDeployment.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentDeploymentFromJson(json);
}
