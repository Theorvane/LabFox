import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/data/literal_original_diff.dart';
import 'package:labfox/features/merge_requests/data/original_diff_range.dart';

const text = '@@ -1 +1 @@\n-old  \n+new\n';
CommitDiffFile file(String? diff) => CommitDiffFile(
  oldPath: 'lib/a.dart',
  newPath: 'lib/a.dart',
  isNew: false,
  isDeleted: false,
  isRenamed: false,
  diff: diff,
);

void main() {
  for (final (raw, accepted) in [
    (text, true),
    ('@@ -1 +1 @@\n-a\n?ignored\n+b', false),
    ('@@ -1,2 +1 @@\n-a\n+b', false),
    ('$text@@ -5 +5 @@\n-a\n+b', true),
  ]) {
    test(
      'literal endpoint matching validates all input before selection $accepted $raw',
      () {
        final hash = sha1.convert(utf8.encode('lib/a.dart')).toString();
        final endpoint = DiffNoteRangeEndpoint(
          lineCode: '${hash}_2_1',
          type: 'new',
          newLine: 1,
        );
        final range = DiffNoteLineRange(start: endpoint, end: endpoint);
        final result = literalOriginalDiffRange(file(raw), range);
        if (accepted) {
          expect(result!.single.newLine, 1);
          expect(() => result.clear(), throwsUnsupportedError);
        } else {
          expect(result, isNull);
        }
        expect(
          literalOriginalDiffRange(
            file(raw).copyWith(isCollapsed: true),
            range,
          ),
          isNull,
        );
      },
    );
  }
  for (final raw in [
    file('@@ -0,0 +2 @@\n+a').copyWith(isNew: true),
    file('@@ -2 +0,0 @@\n-a').copyWith(isDeleted: true),
  ]) {
    test('new/deleted text must begin at the first existing line $raw', () {
      expect(validateLiteralOriginalDiff(raw), isNull);
    });
  }

  test(
    'retains literal metadata, whitespace, counters and immutable hunks',
    () {
      final raw = file('@@ -1,2 +1,2 @@ label\n same\r\n-old  \n+new\n');
      final result = validateLiteralOriginalDiff(raw)!;
      expect(identical(result.file, raw), isTrue);
      expect(result.hunks.single.header, '@@ -1,2 +1,2 @@ label');
      expect(result.hunks.single.lines.map((l) => l.text), [
        'same\r',
        'old  ',
        'new',
      ]);
      expect(result.hunks.single.lines.map((l) => (l.oldLine, l.newLine)), [
        (1, 1),
        (2, null),
        (null, 2),
      ]);
      expect(() => result.hunks.clear(), throwsUnsupportedError);
      expect(() => result.hunks.single.lines.clear(), throwsUnsupportedError);
    },
  );
  for (final input in [
    null,
    '',
    'Binary files differ',
    'preamble\n$text',
    '@@ -1 +1 @@garbage\n-a\n+b',
    '@@ -01 +1 @@\n-a\n+b',
    '@@ -0 +1 @@\n-a\n+b',
    '@@ -1,0 +1,0 @@',
    '@@ -1,2 +1 @@\n-a\n+b',
    '@@ -1 +1 @@\n-a\n+b\n+extra',
    '@@ -1 +1 @@\n-a\n\n+b',
    '@@ -1 +1 @@\n-a\n?ignored\n+b',
    '@@ -1 +1 @@\n-a\n\\junk\n+b',
    '@@ -999999999999999999999999999999 +1 @@\n-a\n+b',
    '@@ -2147483647,2 +1 @@\n-a\n-b\n+c',
    '$text@@ -1 +1 @@\n-a\n+b',
    '$text@@ -0,0 +2 @@\n+b',
    '$text@@ -3 +4 @@\n-a\n+b',
    '$text@@ -2 +2 @@\n-a\n+b\ntrailer',
    '@@ -1 +1 @@\n\\ No newline at end of file\n-a\n+b',
    '@@ -1 +1 @@\n-a\n\\ No newline at end of file\n\\ No newline at end of file\n+b',
    '@@ -1,2 +1 @@\n-a\n\\ No newline at end of file\n-b\n+c',
  ]) {
    test('rejects malformed or incomplete literal input $input', () {
      expect(validateLiteralOriginalDiff(file(input)), isNull);
    });
  }
  for (final change in [
    file(text).copyWith(isCollapsed: true),
    file(text).copyWith(isTooLarge: true),
    file(text).copyWith(isNew: true, isDeleted: true),
    file(text).copyWith(isRenamed: true),
    file(text).copyWith(newPath: 'other'),
    file(text).copyWith(oldPath: ''),
    file(text).copyWith(newPath: '/dev/null'),
    file(text).copyWith(oldPath: '../secret'),
    file(text).copyWith(newPath: 'lib/../a'),
    file(text).copyWith(newPath: 'lib//a'),
    file(text).copyWith(newPath: 'lib/a\u0000'),
    file(text).copyWith(newPath: 'lib/a\n'),
    file(text).copyWith(isNew: true, isRenamed: true),
    file(text).copyWith(isDeleted: true, isRenamed: true),
    file(text).copyWith(isNew: true),
    file(text).copyWith(isDeleted: true),
  ]) {
    test('rejects contradictory or unsupported metadata $change', () {
      expect(validateLiteralOriginalDiff(change), isNull);
    });
  }
  for (final input in [
    text,
    text.substring(0, text.length - 1),
    '$text@@ -2 +2 @@\n-a\n+b',
    '$text@@ -5 +5 @@\n-a\n+b',
    '@@ -0,0 +1,2 @@\n+a\n+b',
    '@@ -1,2 +0,0 @@\n-a\n-b',
    '@@ -5,0 +6,2 @@\n+a\n+b\n@@ -6 +8 @@\n-a\n+b',
    '@@ -1 +1 @@\n-a\n\\ No newline at end of file\n+b\n\\ No newline at end of file\n',
    '@@ -1 +1 @@\n same\n\\ No newline at end of file',
  ]) {
    test('accepts complete literal hunks $input', () {
      expect(validateLiteralOriginalDiff(file(input)), isNotNull);
    });
  }
  test('new deleted and renamed metadata matches literal sides', () {
    expect(
      validateLiteralOriginalDiff(
        file('@@ -0,0 +1 @@\n+a').copyWith(isNew: true),
      ),
      isNotNull,
    );
    expect(
      validateLiteralOriginalDiff(
        file('@@ -1 +0,0 @@\n-a').copyWith(isDeleted: true),
      ),
      isNotNull,
    );
    expect(
      validateLiteralOriginalDiff(
        file(text).copyWith(isRenamed: true, newPath: 'other'),
      ),
      isNotNull,
    );
  });
  test(
    'unknown omission metadata stays unknown without synthesizing flags',
    () {
      final raw = file(text);
      final result = validateLiteralOriginalDiff(raw)!;
      expect(result.file.isCollapsed, isNull);
      expect(result.file.isTooLarge, isNull);
      expect(result.file.diff, text);
    },
  );
}
