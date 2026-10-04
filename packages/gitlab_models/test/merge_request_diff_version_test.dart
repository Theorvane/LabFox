import 'dart:convert';

import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

Map<String, dynamic> _version() => {
  'id': 110,
  'base_commit_sha': 'base',
  'start_commit_sha': 'start',
  'head_commit_sha': 'head',
  'merge_request_id': 93958054,
  'created_at': '2026-10-05T00:00:00Z',
  'state': 'collected',
  'real_size': '2',
  'patch_id_sha': 'patch',
};
Map<String, dynamic> _file() => {
  'old_path': 'old.dart',
  'new_path': 'new.dart',
  'diff': '@@ -27,1 +29,1 @@\n-context\n+changed\n',
  'a_mode': '100644',
  'b_mode': '100755',
  'new_file': false,
  'deleted_file': false,
  'renamed_file': true,
  'collapsed': false,
  'too_large': false,
  'generated_file': true,
};
MergeRequestDiffVersion _roundTrip(MergeRequestDiffVersion v) =>
    MergeRequestDiffVersion.fromJson(
      jsonDecode(jsonEncode(v)) as Map<String, dynamic>,
    );
void main() {
  test('version identity and SHA triplet retain separate semantics', () {
    final v = MergeRequestDiffVersion.fromJson(_version());
    expect(v.id, 110);
    expect(v.mergeRequestId, 93958054);
    expect(v.baseCommitSha, 'base');
    expect(v.startCommitSha, 'start');
    expect(v.headCommitSha, 'head');
    expect(v.createdAt, DateTime.utc(2026, 10, 5));
    expect(v.state, 'collected');
    expect(v.realSize, '2');
    expect(v.patchIdSha, 'patch');
    expect(_roundTrip(v), v);
  });
  test('omitted files remain different from an explicitly empty snapshot', () {
    final absent = MergeRequestDiffVersion.fromJson(_version());
    final empty = MergeRequestDiffVersion.fromJson({
      ..._version(),
      'diffs': <Map<String, dynamic>>[],
    });
    expect(absent.files, isNull);
    expect(empty.files, isEmpty);
    expect(absent, isNot(empty));
    expect(_roundTrip(absent), absent);
    expect(_roundTrip(empty), empty);
  });
  test('sparse version does not invent SHA, state, time or files', () {
    final v = MergeRequestDiffVersion.fromJson({'id': 110});
    expect(v.baseCommitSha, isNull);
    expect(v.startCommitSha, isNull);
    expect(v.headCommitSha, isNull);
    expect(v.createdAt, isNull);
    expect(v.state, isNull);
    expect(v.files, isNull);
    expect(_roundTrip(v), v);
  });
  test(
    'snapshot preserves renamed paths, exact raw text and file metadata',
    () {
      final v = MergeRequestDiffVersion.fromJson({
        ..._version(),
        'diffs': [_file()],
      });
      final f = v.files!.single;
      expect(f.oldPath, 'old.dart');
      expect(f.newPath, 'new.dart');
      expect(f.diff, _file()['diff']);
      expect(f.oldMode, '100644');
      expect(f.newMode, '100755');
      expect(f.isRenamed, true);
      expect(f.isNew, false);
      expect(f.isDeleted, false);
      expect(f.isCollapsed, false);
      expect(f.isTooLarge, false);
      expect(f.isGenerated, true);
      expect(_roundTrip(v), v);
      expect(() => v.files!.clear(), throwsUnsupportedError);
      final changed = v.copyWith(files: [f.copyWith(newPath: 'other.dart')]);
      expect(changed.files!.single.newPath, 'other.dart');
      expect(v.files!.single.newPath, 'new.dart');
    },
  );
  for (final key in ['collapsed', 'too_large']) {
    test('preserves $key and absent diff text as unknown', () {
      final v = MergeRequestDiffVersion.fromJson({
        ..._version(),
        'state': 'overflow',
        'diffs': [
          {'old_path': 'large.dart', 'new_path': 'large.dart', key: true},
        ],
      });
      final f = v.files!.single;
      expect(f.diff, isNull);
      expect(key == 'collapsed' ? f.isCollapsed : f.isTooLarge, true);
      expect(_roundTrip(v), v);
    });
  }
  test(
    'empty binary text remains explicit and legacy flags remain unknown',
    () {
      final f = MergeRequestVersionFile.fromJson({
        'old_path': 'image.png',
        'new_path': 'image.png',
        'diff': '',
      });
      expect(f.diff, '');
      expect(f.isNew, isNull);
      expect(f.isDeleted, isNull);
      expect(f.isRenamed, isNull);
      expect(f.isCollapsed, isNull);
      expect(f.isTooLarge, isNull);
      expect(f.isGenerated, isNull);
      expect(MergeRequestVersionFile.fromJson(f.toJson()), f);
    },
  );
  test('future collection states remain identifiable', () {
    final v = MergeRequestDiffVersion.fromJson({
      ..._version(),
      'state': 'future-state',
      'real_size': 'overflow',
    });
    expect(v.state, 'future-state');
    expect(v.realSize, 'overflow');
    expect(_roundTrip(v), v);
  });
}
