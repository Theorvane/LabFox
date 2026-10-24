// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gitlab_release.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GitLabRelease _$GitLabReleaseFromJson(Map<String, dynamic> json) =>
    _GitLabRelease(
      name: json['name'] as String,
      tagName: json['tag_name'] as String,
      description: json['description'] as String?,
      releasedAt: json['released_at'] == null
          ? null
          : DateTime.parse(json['released_at'] as String),
      upcomingRelease: json['upcoming_release'] as bool?,
      historicalRelease: json['historical_release'] as bool?,
      assets: json['assets'] == null
          ? null
          : ReleaseAssets.fromJson(json['assets'] as Map<String, dynamic>),
      milestones:
          (json['milestones'] as List<dynamic>?)
              ?.map((e) => GitLabMilestone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$GitLabReleaseToJson(_GitLabRelease instance) =>
    <String, dynamic>{
      'name': instance.name,
      'tag_name': instance.tagName,
      'description': instance.description,
      'released_at': instance.releasedAt?.toIso8601String(),
      'upcoming_release': instance.upcomingRelease,
      'historical_release': instance.historicalRelease,
      'assets': instance.assets?.toJson(),
      'milestones': instance.milestones.map((e) => e.toJson()).toList(),
    };

_ReleaseAssets _$ReleaseAssetsFromJson(Map<String, dynamic> json) =>
    _ReleaseAssets(
      links:
          (json['links'] as List<dynamic>?)
              ?.map((e) => ReleaseAssetLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sources:
          (json['sources'] as List<dynamic>?)
              ?.map((e) => ReleaseSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ReleaseAssetsToJson(_ReleaseAssets instance) =>
    <String, dynamic>{
      'links': instance.links.map((e) => e.toJson()).toList(),
      'sources': instance.sources.map((e) => e.toJson()).toList(),
    };

_ReleaseAssetLink _$ReleaseAssetLinkFromJson(Map<String, dynamic> json) =>
    _ReleaseAssetLink(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      url: json['url'] as String,
      directAssetUrl: json['direct_asset_url'] as String?,
      linkType: json['link_type'] as String?,
    );

Map<String, dynamic> _$ReleaseAssetLinkToJson(_ReleaseAssetLink instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'direct_asset_url': instance.directAssetUrl,
      'link_type': instance.linkType,
    };

_ReleaseSource _$ReleaseSourceFromJson(Map<String, dynamic> json) =>
    _ReleaseSource(
      format: json['format'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$ReleaseSourceToJson(_ReleaseSource instance) =>
    <String, dynamic>{'format': instance.format, 'url': instance.url};
