import 'package:freezed_annotation/freezed_annotation.dart';

import 'gitlab_milestone.dart';
import 'label.dart';
import 'user.dart';

part 'issue.freezed.dart';
part 'issue.g.dart';

/// A GitLab issue.
///
/// `iid` and `id` are both kept and never conflated. The number a user sees
/// (`#282`) is the `iid`, the per-project number; `id` is the global
/// identifier. API paths for a single issue use the `iid`.
@freezed
abstract class Issue with _$Issue {
  const factory Issue({
    required int id,
    required int iid,
    required String title,
    required String state,
    // Present in list and search responses; lets a search hit route to its
    // project. Absent when a single issue is fetched under a known project.
    @JsonKey(name: 'project_id') int? projectId,
    String? description,
    User? author,
    @Default(<User>[]) List<User> assignees,
    @JsonKey(fromJson: Label.listFromJson)
    @Default(<Label>[])
    List<Label> labels,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'user_notes_count') @Default(0) int commentCount,
    bool? subscribed,
    bool? confidential,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    GitLabMilestone? milestone,
  }) = _Issue;

  const Issue._();

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);

  bool get isOpen => state == 'opened';
}
