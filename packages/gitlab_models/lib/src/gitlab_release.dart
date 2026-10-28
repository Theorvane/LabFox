import 'package:freezed_annotation/freezed_annotation.dart';

import 'gitlab_milestone.dart';

part 'gitlab_release.freezed.dart';
part 'gitlab_release.g.dart';

/// A project release, including its published asset links and source archives.
@freezed
abstract class GitLabRelease with _$GitLabRelease {
  const factory GitLabRelease({
    required String name,
    @JsonKey(name: 'tag_name') required String tagName,
    String? description,
    @JsonKey(name: 'released_at') DateTime? releasedAt,
    @JsonKey(name: 'upcoming_release') bool? upcomingRelease,
    @JsonKey(name: 'historical_release') bool? historicalRelease,
    ReleaseAssets? assets,
    @Default([]) List<GitLabMilestone> milestones,
  }) = _GitLabRelease;

  factory GitLabRelease.fromJson(Map<String, dynamic> json) =>
      _$GitLabReleaseFromJson(json);
}

@freezed
abstract class ReleaseAssets with _$ReleaseAssets {
  const factory ReleaseAssets({
    @Default([]) List<ReleaseAssetLink> links,
    @Default([]) List<ReleaseSource> sources,
  }) = _ReleaseAssets;

  factory ReleaseAssets.fromJson(Map<String, dynamic> json) =>
      _$ReleaseAssetsFromJson(json);
}

@freezed
abstract class ReleaseAssetLink with _$ReleaseAssetLink {
  const factory ReleaseAssetLink({
    required int id,
    required String name,
    required String url,
    @JsonKey(name: 'direct_asset_url') String? directAssetUrl,
    @JsonKey(name: 'link_type') String? linkType,
  }) = _ReleaseAssetLink;

  factory ReleaseAssetLink.fromJson(Map<String, dynamic> json) =>
      _$ReleaseAssetLinkFromJson(json);
}

@freezed
abstract class ReleaseSource with _$ReleaseSource {
  const factory ReleaseSource({required String format, required String url}) =
      _ReleaseSource;

  factory ReleaseSource.fromJson(Map<String, dynamic> json) =>
      _$ReleaseSourceFromJson(json);
}
