import 'package:freezed_annotation/freezed_annotation.dart';

part 'issue_link.freezed.dart';
part 'issue_link.g.dart';

/// An issue linked to another issue. [iid] is local to [projectId].
@freezed
abstract class IssueLink with _$IssueLink {
  const factory IssueLink({
    required int id,
    required int iid,
    @JsonKey(name: 'project_id') required int projectId,
    required String title,
    required String state,
    @JsonKey(name: 'link_type') required String linkType,
    @JsonKey(name: 'issue_link_id') int? issueLinkId,
  }) = _IssueLink;

  factory IssueLink.fromJson(Map<String, dynamic> json) =>
      _$IssueLinkFromJson(json);
}
