// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommitStats _$CommitStatsFromJson(Map<String, dynamic> json) => _CommitStats(
  additions: (json['additions'] as num?)?.toInt() ?? 0,
  deletions: (json['deletions'] as num?)?.toInt() ?? 0,
  total: (json['total'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CommitStatsToJson(_CommitStats instance) =>
    <String, dynamic>{
      'additions': instance.additions,
      'deletions': instance.deletions,
      'total': instance.total,
    };

_Commit _$CommitFromJson(Map<String, dynamic> json) => _Commit(
  id: json['id'] as String,
  parentIds: (json['parent_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  rawShortId: json['short_id'] as String?,
  title: json['title'] as String,
  message: json['message'] as String?,
  authorName: json['author_name'] as String?,
  webUrl: json['web_url'] as String?,
  authoredDate: json['authored_date'] == null
      ? null
      : DateTime.parse(json['authored_date'] as String),
  stats: json['stats'] == null
      ? null
      : CommitStats.fromJson(json['stats'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CommitToJson(_Commit instance) => <String, dynamic>{
  'id': instance.id,
  'parent_ids': instance.parentIds,
  'short_id': instance.rawShortId,
  'title': instance.title,
  'message': instance.message,
  'author_name': instance.authorName,
  'web_url': instance.webUrl,
  'authored_date': instance.authoredDate?.toIso8601String(),
  'stats': instance.stats?.toJson(),
};
