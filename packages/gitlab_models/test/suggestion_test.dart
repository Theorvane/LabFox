import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

const _raw = <String, dynamic>{
  'id': 5,
  'from_line': 27,
  'to_line': 28,
  'appliable': true,
  'applied': false,
  'from_content': '  original\n',
  'to_content': '  replacement\n',
};
void main() {
  test('round trips legacy suggestion payload and exact content', () {
    final s = Suggestion.fromJson(_raw);
    expect(s.id, 5);
    expect(s.fromLine, 27);
    expect(s.toLine, 28);
    expect(s.fromContent, '  original\n');
    expect(s.toContent, '  replacement\n');
    expect(s.appliable, true);
    expect(s.applicable, isNull);
    expect(s.patchApplicable, true);
    expect(s.applied, false);
    expect(Suggestion.fromJson(s.toJson()), s);
  });
  test('reads documented applicability without rewriting legacy state', () {
    final s = Suggestion.fromJson({
      ..._raw,
      'appliable': null,
      'applicable': false,
    });
    expect(s.appliable, isNull);
    expect(s.applicable, false);
    expect(s.patchApplicable, false);
  });
  test('conflicting applicability spellings remain unknown', () {
    final s = Suggestion.fromJson({..._raw, 'applicable': false});
    expect(s.appliable, true);
    expect(s.applicable, false);
    expect(s.patchApplicable, isNull);
  });
  test('sparse suggestion preserves unknown coordinates and states', () {
    final s = Suggestion.fromJson({'id': 5});
    expect(s.fromLine, isNull);
    expect(s.toLine, isNull);
    expect(s.fromContent, isNull);
    expect(s.toContent, isNull);
    expect(s.patchApplicable, isNull);
    expect(s.applied, isNull);
  });
  test('empty deletion and insertion content stays present', () {
    final s = Suggestion.fromJson({
      ..._raw,
      'from_content': '',
      'to_content': '',
    });
    expect(s.fromContent, '');
    expect(s.toContent, '');
  });
  test('applied state is separate from applicability and user permission', () {
    final s = Suggestion.fromJson({..._raw, 'applied': true});
    expect(s.applied, true);
    expect(s.patchApplicable, true);
  });
  test('unknown future fields do not replace the known suggestion', () {
    expect(
      Suggestion.fromJson({
        ..._raw,
        'future_field': {'unknown': true},
      }),
      Suggestion.fromJson(_raw),
    );
  });
  test('note omitted suggestions differ from an explicit empty list', () {
    expect(Note.fromJson({'id': 301, 'body': 'Review'}).suggestions, isNull);
    expect(
      Note.fromJson({
        'id': 301,
        'body': 'Review',
        'suggestions': [],
      }).suggestions,
      isEmpty,
    );
  });
  test('discussion nested suggestions are immutable and round trip', () {
    final d = Discussion.fromJson({
      'id': 'thread',
      'individual_note': false,
      'notes': [
        {
          'id': 301,
          'body': 'Review',
          'suggestions': [_raw],
        },
      ],
    });
    final notes = d.notes.single;
    expect(notes.suggestions!.single.id, 5);
    expect(() => notes.suggestions!.clear(), throwsUnsupportedError);
    expect(Discussion.fromJson(d.toJson()), d);
    final copy = notes.copyWith(
      suggestions: [notes.suggestions!.single.copyWith(toContent: 'changed')],
    );
    expect(notes.suggestions!.single.toContent, '  replacement\n');
    expect(copy.suggestions!.single.toContent, 'changed');
  });
}
