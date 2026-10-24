import 'dart:convert';

import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test('discussion preserves note order and nullable resolution metadata', () {
    final discussion = Discussion.fromJson({
      'id': 'thread-1',
      'individual_note': false,
      'notes': [
        {
          'id': 301,
          'body': 'Review this change.',
          'type': 'DiscussionNote',
          'resolvable': true,
          'resolved': false,
        },
        {
          'id': 302,
          'body': 'Updated.',
          'type': 'DiscussionNote',
          'resolvable': true,
          'resolved': true,
          'resolved_by': {'id': 7, 'username': 'reviewer', 'name': 'Reviewer'},
          'resolved_at': '2026-10-04T00:00:00Z',
          'updated_at': '2026-10-04T00:01:00Z',
        },
      ],
    });
    expect(discussion.id, 'thread-1');
    expect(discussion.individualNote, false);
    expect(discussion.notes.map((n) => n.id), [301, 302]);
    expect(discussion.notes.first.type, 'DiscussionNote');
    expect(discussion.notes.first.resolved, false);
    expect(discussion.notes.first.resolvedBy, isNull);
    expect(discussion.notes.last.resolvable, true);
    expect(discussion.notes.last.resolvedBy!.id, 7);
    expect(discussion.notes.last.resolvedAt, DateTime.utc(2026, 10, 4));
    expect(discussion.notes.last.updatedAt, DateTime.utc(2026, 10, 4, 0, 1));
    expect(
      Discussion.fromJson(
        jsonDecode(jsonEncode(discussion)) as Map<String, dynamic>,
      ),
      discussion,
    );
    expect(
      () => discussion.notes.add(const Note(id: 303, body: 'Reply')),
      throwsUnsupportedError,
    );
  });
  test('legacy notes keep absent resolution values unknown', () {
    final note = Note.fromJson({'id': 1, 'body': 'Comment'});
    expect(note.type, isNull);
    expect(note.resolvable, isNull);
    expect(note.resolved, isNull);
    expect(note.resolvedBy, isNull);
    expect(note.resolvedAt, isNull);
    expect(note.updatedAt, isNull);
  });
  test('individual notes and empty groups round trip', () {
    final discussion = Discussion.fromJson({
      'id': 'single-1',
      'individual_note': true,
      'notes': [],
    });
    expect(Discussion.fromJson(discussion.toJson()), discussion);
  });
}
