import 'package:freezed_annotation/freezed_annotation.dart';

part 'commit.freezed.dart';
part 'commit.g.dart';

/// Line-change counts for a commit, when the endpoint includes them.
@freezed
abstract class CommitStats with _$CommitStats {
  const factory CommitStats({
    @Default(0) int additions,
    @Default(0) int deletions,
    @Default(0) int total,
  }) = _CommitStats;

  factory CommitStats.fromJson(Map<String, dynamic> json) =>
      _$CommitStatsFromJson(json);
}

/// A repository commit.
@freezed
abstract class Commit with _$Commit {
  const factory Commit({
    required String id,

    /// Null means unreported; an empty list explicitly identifies a root commit.
    @JsonKey(name: 'parent_ids') List<String>? parentIds,
    @JsonKey(name: 'short_id') String? rawShortId,
    required String title,
    String? message,
    @JsonKey(name: 'author_name') String? authorName,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'authored_date') DateTime? authoredDate,
    CommitStats? stats,
  }) = _Commit;

  const Commit._();

  factory Commit.fromJson(Map<String, dynamic> json) => _$CommitFromJson(json);

  /// The short SHA the user sees. Falls back to the first 8 chars of [id] when
  /// the endpoint omits `short_id`, so there is always a stable handle.
  String get shortId {
    final raw = rawShortId;
    if (raw != null && raw.isNotEmpty) {
      return raw;
    }
    return id.length <= 8 ? id : id.substring(0, 8);
  }
}
