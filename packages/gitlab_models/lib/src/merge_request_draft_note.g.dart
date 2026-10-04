// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merge_request_draft_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MergeRequestDraftNote _$MergeRequestDraftNoteFromJson(
  Map<String, dynamic> json,
) => _MergeRequestDraftNote(
  id: (json['id'] as num).toInt(),
  authorId: (json['author_id'] as num).toInt(),
  mergeRequestId: (json['merge_request_id'] as num).toInt(),
  note: json['note'] as String,
  resolveDiscussion: json['resolve_discussion'] as bool?,
  discussionId: json['discussion_id'] as String?,
  commitId: json['commit_id'] as String?,
  lineCode: json['line_code'] as String?,
  position: json['position'] == null
      ? null
      : DiffNotePosition.fromJson(json['position'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MergeRequestDraftNoteToJson(
  _MergeRequestDraftNote instance,
) => <String, dynamic>{
  'id': instance.id,
  'author_id': instance.authorId,
  'merge_request_id': instance.mergeRequestId,
  'note': instance.note,
  'resolve_discussion': instance.resolveDiscussion,
  'discussion_id': instance.discussionId,
  'commit_id': instance.commitId,
  'line_code': instance.lineCode,
  'position': instance.position?.toJson(),
};
