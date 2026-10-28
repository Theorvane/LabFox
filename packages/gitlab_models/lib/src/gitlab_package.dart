import 'package:freezed_annotation/freezed_annotation.dart';

part 'gitlab_package.freezed.dart';
part 'gitlab_package.g.dart';

/// One published package in a GitLab project registry.
@freezed
abstract class GitLabPackage with _$GitLabPackage {
  const factory GitLabPackage({
    required int id,
    required String name,
    @JsonKey(name: 'package_type') required String packageType,
    String? version,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'last_downloaded_at') DateTime? lastDownloadedAt,
  }) = _GitLabPackage;

  factory GitLabPackage.fromJson(Map<String, dynamic> json) =>
      _$GitLabPackageFromJson(json);
}
