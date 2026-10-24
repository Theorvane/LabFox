import 'package:freezed_annotation/freezed_annotation.dart';

part 'gitlab_milestone.freezed.dart';
part 'gitlab_milestone.g.dart';

/// A project or group milestone. [id] is global; [iid] is namespace-local.
@freezed
abstract class GitLabMilestone with _$GitLabMilestone {
  const factory GitLabMilestone({
    required int id,
    required int iid,
    required String title,
    required String state,
    @JsonKey(name: 'project_id') int? projectId,
    @JsonKey(name: 'group_id') int? groupId,
    String? description,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    bool? expired,
    @JsonKey(name: 'web_url') String? webUrl,
  }) = _GitLabMilestone;

  factory GitLabMilestone.fromJson(Map<String, dynamic> json) =>
      _$GitLabMilestoneFromJson(json);
}
