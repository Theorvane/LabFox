import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

const head = '0123456789abcdef0123456789abcdef01234567';
const parent = '1123456789abcdef0123456789abcdef01234567';
const second = '2123456789abcdef0123456789abcdef01234567';
void main() {
  for (final extra in [
    <String, Object?>{},
    {'parent_ids': null},
  ]) {
    test('unreported commit parents stay unknown $extra', () {
      final c = Commit.fromJson({'id': head, 'title': '', ...extra});
      expect(c.parentIds, isNull);
    });
  }
  test(
    'explicit empty parents describe a root commit without inventing a parent',
    () {
      final c = Commit.fromJson({
        'id': head,
        'title': 'Root',
        'parent_ids': [],
      });
      expect(c.parentIds, isEmpty);
      expect(c.toJson()['parent_ids'], isEmpty);
    },
  );
  test('ordered merge parents survive parsing and serialization', () {
    final c = Commit.fromJson({
      'id': head,
      'title': 'Merge',
      'parent_ids': [parent, second],
    });
    expect(c.parentIds, [parent, second]);
    expect(c.toJson()['parent_ids'], [parent, second]);
    expect(Commit.fromJson(c.toJson()), c);
  });
  test('parent lists cannot be changed through a parsed commit', () {
    final c = Commit.fromJson({
      'id': head,
      'title': 'Commit',
      'parent_ids': [parent],
    });
    expect(() => c.parentIds!.add(second), throwsUnsupportedError);
    expect(c.parentIds, [parent]);
  });
  test('copyWith preserves or explicitly clears original parents', () {
    const c = Commit(id: head, title: 'Commit', parentIds: [parent, second]);
    expect(c.copyWith(title: 'Updated').parentIds, [parent, second]);
    expect(c.copyWith(parentIds: null).parentIds, isNull);
  });
  test('parent metadata participates in value equality', () {
    const c = Commit(id: head, title: 'Commit', parentIds: [parent]);
    expect(c.copyWith(parentIds: [second]), isNot(c));
    expect(c.copyWith(parentIds: []), isNot(c.copyWith(parentIds: null)));
  });
}
