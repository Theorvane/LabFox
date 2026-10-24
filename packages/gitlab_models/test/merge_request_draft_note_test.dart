import 'dart:convert';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test('draft keeps global identities and exact unpublished Markdown', () {
    final json = <String, dynamic>{
      'id': 5,
      'author_id': 23,
      'merge_request_id': 1100,
      'note': '  **Review**\n\n```suggestion\nupdated\n```  ',
      'resolve_discussion': false,
      'discussion_id': 'reply/thread',
      'commit_id': 'original-sha',
      'line_code': 'file_1_2',
      'position': {
        'base_sha': 'base',
        'start_sha': 'start',
        'head_sha': 'head',
        'old_path': 'old/file.dart',
        'new_path': 'new/file.dart',
        'position_type': 'text',
        'old_line': 1,
        'new_line': 2,
        'line_range': {
          'start': {'line_code': 'file_1_2', 'type': 'old', 'old_line': 1},
          'end': {'line_code': 'file_2_3', 'type': 'new', 'new_line': 3},
        },
      },
    };
    final draft = MergeRequestDraftNote.fromJson(json);
    expect(draft.id, 5);
    expect(draft.authorId, 23);
    expect(draft.mergeRequestId, 1100);
    expect(draft.note, json['note']);
    expect(draft.resolveDiscussion, false);
    expect(draft.discussionId, 'reply/thread');
    expect(draft.commitId, 'original-sha');
    expect(draft.lineCode, 'file_1_2');
    expect(draft.position!.lineRange!.start!.type, 'old');
    expect(draft.position!.lineRange!.end!.newLine, 3);
    expect(
      MergeRequestDraftNote.fromJson(
        jsonDecode(jsonEncode(draft)) as Map<String, dynamic>,
      ),
      draft,
    );
  });
  test('absent metadata stays unknown instead of false or a text anchor', () {
    final draft = MergeRequestDraftNote.fromJson({
      'id': 5,
      'author_id': 23,
      'merge_request_id': 1100,
      'note': '',
    });
    expect(draft.note, '');
    expect(draft.resolveDiscussion, isNull);
    expect(draft.discussionId, isNull);
    expect(draft.commitId, isNull);
    expect(draft.lineCode, isNull);
    expect(draft.position, isNull);
  });
  test('documented regular-note null coordinates are preserved', () {
    final draft = MergeRequestDraftNote.fromJson({
      'id': 5,
      'author_id': 23,
      'merge_request_id': 11,
      'note': 'Example title',
      'resolve_discussion': false,
      'discussion_id': null,
      'commit_id': null,
      'line_code': null,
      'position': {
        'base_sha': null,
        'start_sha': null,
        'head_sha': null,
        'old_path': null,
        'new_path': null,
        'position_type': 'text',
        'old_line': null,
        'new_line': null,
        'line_range': null,
      },
    });
    expect(draft.position!.positionType, 'text');
    expect(draft.position!.baseSha, isNull);
    expect(draft.position!.newLine, isNull);
    expect(draft.position!.lineRange, isNull);
  });
  test('image and future position types round trip without inference', () {
    for (final type in ['image', 'file', 'future']) {
      final draft = MergeRequestDraftNote.fromJson({
        'id': 5,
        'author_id': 23,
        'merge_request_id': 11,
        'note': 'Review',
        'position': {
          'position_type': type,
          'width': 100,
          'height': 50,
          'x': 0.5,
          'y': 0,
        },
      });
      expect(draft.position!.positionType, type);
      expect(
        MergeRequestDraftNote.fromJson(
          jsonDecode(jsonEncode(draft)) as Map<String, dynamic>,
        ),
        draft,
      );
    }
  });
}
