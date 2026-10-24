import 'package:freezed_annotation/freezed_annotation.dart';

import 'diff_note_position.dart';

part 'merge_request_draft_note.freezed.dart';
part 'merge_request_draft_note.g.dart';

/// An unpublished review note visible only to its author on the server.
///
/// The MR identity here is global, not the per-project IID used for routing.
/// Absent reply, resolution and original-position metadata stays unknown.
@freezed
abstract class MergeRequestDraftNote with _$MergeRequestDraftNote {
  const factory MergeRequestDraftNote({
    required int id,
    @JsonKey(name: 'author_id') required int authorId,
    @JsonKey(name: 'merge_request_id') required int mergeRequestId,
    required String note,
    @JsonKey(name: 'resolve_discussion') bool? resolveDiscussion,
    @JsonKey(name: 'discussion_id') String? discussionId,
    @JsonKey(name: 'commit_id') String? commitId,
    @JsonKey(name: 'line_code') String? lineCode,
    DiffNotePosition? position,
  }) = _MergeRequestDraftNote;

  factory MergeRequestDraftNote.fromJson(Map<String, dynamic> json) =>
      _$MergeRequestDraftNoteFromJson(json);
}
