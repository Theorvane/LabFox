import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';
part 'merge_request_reviewer.freezed.dart';
part 'merge_request_reviewer.g.dart';

/// Reviewer state belongs to the MR; nested user state belongs to the account.
@freezed
abstract class MergeRequestReviewer with _$MergeRequestReviewer {
  const factory MergeRequestReviewer({
    required User user,
    required String state,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _MergeRequestReviewer;
  factory MergeRequestReviewer.fromJson(Map<String, dynamic> json) =>
      _$MergeRequestReviewerFromJson(json);
}
