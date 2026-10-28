import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_label.freezed.dart';
part 'project_label.g.dart';

/// A project or inherited group label with its management metadata.
@freezed
abstract class ProjectLabel with _$ProjectLabel {
  const factory ProjectLabel({
    required int id,
    required String name,
    required String color,
    @JsonKey(name: 'text_color') String? textColor,
    String? description,
    @JsonKey(name: 'open_issues_count') @Default(0) int openIssuesCount,
    @JsonKey(name: 'closed_issues_count') @Default(0) int closedIssuesCount,
    @JsonKey(name: 'open_merge_requests_count')
    @Default(0)
    int openMergeRequestsCount,
    @JsonKey(name: 'is_project_label') @Default(true) bool isProjectLabel,
    @Default(false) bool archived,
  }) = _ProjectLabel;

  factory ProjectLabel.fromJson(Map<String, dynamic> json) =>
      _$ProjectLabelFromJson(json);
}
