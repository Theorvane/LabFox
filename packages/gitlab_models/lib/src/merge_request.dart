import 'package:freezed_annotation/freezed_annotation.dart';

import 'label.dart';
import 'user.dart';

part 'merge_request.freezed.dart';
part 'merge_request.g.dart';

/// A GitLab merge request.
///
/// `iid` and `id` are kept distinct: the number a user sees (`!142`) is the
/// `iid`, used in routes and API paths. A merge request has three states —
/// opened, merged, closed — unlike an issue's two.
@freezed
abstract class MergeRequest with _$MergeRequest {
  const factory MergeRequest({
    required int id,
    required int iid,
    required String title,
    required String state,
    @JsonKey(name: 'source_branch') required String sourceBranch,
    @JsonKey(name: 'target_branch') required String targetBranch,
    // Routes list/search hits. Some detail responses omit this metadata.
    @JsonKey(name: 'project_id') int? projectId,
    // Fork projects are distinct; missing/deleted source metadata stays unknown.
    // Do not infer either identity from projectId or branch names.
    @JsonKey(name: 'source_project_id') int? sourceProjectId,
    @JsonKey(name: 'target_project_id') int? targetProjectId,
    String? description,
    User? author,
    @Default(<User>[]) List<User> assignees,
    @JsonKey(fromJson: Label.listFromJson)
    @Default(<Label>[])
    List<Label> labels,
    @Default(false) bool draft,
    @JsonKey(name: 'merge_status') String? mergeStatus,
    @JsonKey(name: 'detailed_merge_status') String? detailedMergeStatus,
    @JsonKey(name: 'user_notes_count') @Default(0) int commentCount,
    bool? subscribed,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _MergeRequest;

  const MergeRequest._();

  factory MergeRequest.fromJson(Map<String, dynamic> json) =>
      _$MergeRequestFromJson(json);

  bool get isOpen => state == 'opened';
  bool get isMerged => state == 'merged';
  bool get isClosed => state == 'closed';

  /// True for a draft (work-in-progress) merge request.
  bool get isDraft => draft;

  /// Whether GitLab reports the merge request as mergeable right now, from its
  /// `merge_status`. Null when the instance did not report a status, so the UI
  /// can stay quiet rather than claim either way.
  bool? get isMergeable => switch (mergeStatus) {
    null => null,
    'can_be_merged' => true,
    _ => false,
  };
}
