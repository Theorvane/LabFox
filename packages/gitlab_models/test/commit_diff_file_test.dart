import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

const literal = '@@ -1 +1 @@\n-old  \n+new\n\\ No newline at end of file\n';
Map<String, Object?> entry() => {
  'old_path': ' old/path +.dart',
  'new_path': 'new/path .dart ',
  'new_file': false,
  'deleted_file': false,
  'renamed_file': true,
  'diff': literal,
  'a_mode': '100644',
  'b_mode': '100755',
};
void main() {
  test(
    'literal paths, diff whitespace and no-newline markers round trip unchanged',
    () {
      final json = entry();
      final file = CommitDiffFile.fromJson(json);
      expect(file.oldPath, json['old_path']);
      expect(file.newPath, json['new_path']);
      expect(file.diff, literal);
      expect(file.oldMode, '100644');
      expect(file.newMode, '100755');
      expect(file.isNew, false);
      expect(file.isDeleted, false);
      expect(file.isRenamed, true);
      expect(CommitDiffFile.fromJson(file.toJson()), file);
      for (final e in json.entries) {
        expect(file.toJson()[e.key], e.value);
      }
    },
  );
  for (final flags in [
    <String, Object?>{},
    {'collapsed': null, 'too_large': null, 'generated_file': null},
  ]) {
    test('unreported omission and generated flags remain unknown $flags', () {
      final file = CommitDiffFile.fromJson({...entry(), ...flags});
      expect(file.isCollapsed, isNull);
      expect(file.isTooLarge, isNull);
      expect(file.isGenerated, isNull);
    });
  }
  test('explicit false flags are distinct from unknown metadata', () {
    final file = CommitDiffFile.fromJson({
      ...entry(),
      'collapsed': false,
      'too_large': false,
      'generated_file': false,
    });
    expect(file.isCollapsed, false);
    expect(file.isTooLarge, false);
    expect(file.isGenerated, false);
    expect(file, isNot(CommitDiffFile.fromJson(entry())));
  });
  test(
    'omitted, null and empty literal diff text are not synthesized into hunks',
    () {
      final json = entry()..remove('diff');
      expect(CommitDiffFile.fromJson(json).diff, isNull);
      expect(CommitDiffFile.fromJson({...json, 'diff': null}).diff, isNull);
      expect(CommitDiffFile.fromJson({...json, 'diff': ''}).diff, '');
    },
  );
  test(
    'reported omission flags survive alongside any supplied literal text',
    () {
      final file = CommitDiffFile.fromJson({
        ...entry(),
        'collapsed': true,
        'too_large': true,
        'generated_file': true,
      });
      expect(file.diff, literal);
      expect(file.isCollapsed, true);
      expect(file.isTooLarge, true);
      expect(file.isGenerated, true);
      expect(CommitDiffFile.fromJson(file.toJson()), file);
    },
  );
  test(
    'copyWith can explicitly clear nullable metadata without losing paths',
    () {
      final file = CommitDiffFile.fromJson(entry());
      final cleared = file.copyWith(diff: null, oldMode: null, newMode: null);
      expect(cleared.diff, isNull);
      expect(cleared.oldMode, isNull);
      expect(cleared.newMode, isNull);
      expect(cleared.oldPath, file.oldPath);
      expect(cleared.newPath, file.newPath);
    },
  );
  test('literal text and path identities participate in value equality', () {
    final file = CommitDiffFile.fromJson(entry());
    expect(file.copyWith(diff: '$literal '), isNot(file));
    expect(file.copyWith(newPath: 'other.dart'), isNot(file));
  });
}
