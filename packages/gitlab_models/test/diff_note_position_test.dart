import 'dart:convert';

import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

Map<String, dynamic> _position() => {
  'base_sha': 'base-version',
  'start_sha': 'target-version',
  'head_sha': 'source-version',
  'old_path': 'old/file.dart',
  'new_path': 'new/file.dart',
  'position_type': 'text',
  'old_line': 27,
  'new_line': 29,
};
Note _note(Object? position) => Note.fromJson({
  'id': 1128,
  'body': 'Review this line.',
  'type': 'DiffNote',
  'position': position,
});
Note _roundTrip(Note note) =>
    Note.fromJson(jsonDecode(jsonEncode(note)) as Map<String, dynamic>);

void main() {
  test('preserves diff identity, renamed paths and distinct context lines', () {
    final note = _note(_position());
    final p = note.position!;
    expect(p.baseSha, 'base-version');
    expect(p.startSha, 'target-version');
    expect(p.headSha, 'source-version');
    expect(p.oldPath, 'old/file.dart');
    expect(p.newPath, 'new/file.dart');
    expect(p.positionType, 'text');
    expect(p.oldLine, 27);
    expect(p.newLine, 29);
    expect(p.lineRange, isNull);
    expect(_roundTrip(note), note);
    final changed = note.copyWith(position: p.copyWith(newLine: 30));
    expect(changed.position!.newLine, 30);
    expect(note.position!.newLine, 29);
  });
  for (final side in ['old', 'new']) {
    test(
      'preserves single-sided $side lines without inventing the other side',
      () {
        final p = _position()..remove(side == 'old' ? 'new_line' : 'old_line');
        final note = _note(p);
        expect(
          side == 'old' ? note.position!.newLine : note.position!.oldLine,
          isNull,
        );
        expect(
          side == 'old' ? note.position!.oldLine : note.position!.newLine,
          side == 'old' ? 27 : 29,
        );
        expect(_roundTrip(note), note);
      },
    );
  }
  test(
    'preserves multiline endpoint sides, codes and nullable line numbers',
    () {
      final note = _note({
        ..._position(),
        'line_range': {
          'start': {
            'line_code': 'filename-hash_0_10',
            'type': 'new',
            'old_line': null,
            'new_line': 10,
          },
          'end': {
            'line_code': 'filename-hash_11_11',
            'type': 'old',
            'old_line': 11,
            'new_line': 11,
          },
        },
      });
      final range = note.position!.lineRange!;
      expect(range.start!.lineCode, 'filename-hash_0_10');
      expect(range.start!.type, 'new');
      expect(range.start!.oldLine, isNull);
      expect(range.start!.newLine, 10);
      expect(range.end!.type, 'old');
      expect(range.end!.oldLine, 11);
      expect(range.end!.newLine, 11);
      expect(_roundTrip(note), note);
    },
  );
  test('preserves image metadata without pretending it is a text line', () {
    final note = _note({
      'position_type': 'image',
      'old_path': 'image.png',
      'new_path': 'image.png',
      'width': 640,
      'height': 480,
      'x': 0,
      'y': 12.5,
    });
    final p = note.position!;
    expect(p.width, 640);
    expect(p.height, 480);
    expect(p.x, 0.0);
    expect(p.y, 12.5);
    expect(p.oldLine, isNull);
    expect(p.newLine, isNull);
    expect(_roundTrip(note), note);
  });
  for (final type in ['file', 'future-type']) {
    test('preserves $type position without assigning default coordinates', () {
      final note = _note({'position_type': type, 'new_path': 'file.dart'});
      expect(note.position!.positionType, type);
      expect(note.position!.oldLine, isNull);
      expect(note.position!.newLine, isNull);
      expect(_roundTrip(note), note);
    });
  }
  test('legacy and explicitly null positions stay absent', () {
    expect(Note.fromJson({'id': 1, 'body': 'Overview'}).position, isNull);
    expect(_note(null).position, isNull);
  });
  test('sparse position and range values remain unknown', () {
    final note = _note({
      'line_range': {'start': <String, dynamic>{}},
    });
    final p = note.position!;
    expect(p.baseSha, isNull);
    expect(p.headSha, isNull);
    expect(p.startSha, isNull);
    expect(p.oldPath, isNull);
    expect(p.newPath, isNull);
    expect(p.positionType, isNull);
    expect(p.lineRange!.end, isNull);
    expect(p.lineRange!.start!.lineCode, isNull);
    expect(p.lineRange!.start!.type, isNull);
    expect(_roundTrip(note), note);
  });
  test('discussion preserves positioned root and unpositioned replies', () {
    final discussion = Discussion.fromJson({
      'id': 'thread',
      'individual_note': false,
      'notes': [
        {..._note(_position()).toJson()},
        {'id': 1129, 'body': 'Reply'},
      ],
    });
    expect(discussion.notes.first.position!.headSha, 'source-version');
    expect(discussion.notes.last.position, isNull);
    expect(
      Discussion.fromJson(
        jsonDecode(jsonEncode(discussion)) as Map<String, dynamic>,
      ),
      discussion,
    );
  });
}
