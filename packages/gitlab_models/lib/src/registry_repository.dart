import 'package:freezed_annotation/freezed_annotation.dart';

part 'registry_repository.freezed.dart';
part 'registry_repository.g.dart';

/// A container image repository within a GitLab project.
@freezed
abstract class RegistryRepository with _$RegistryRepository {
  const factory RegistryRepository({
    required int id,
    required String name,
    required String path,
    @JsonKey(name: 'project_id') required int projectId,
    String? location,
    String? status,
    @JsonKey(name: 'tags_count') int? tagsCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _RegistryRepository;

  factory RegistryRepository.fromJson(Map<String, dynamic> json) =>
      _$RegistryRepositoryFromJson(json);
}
