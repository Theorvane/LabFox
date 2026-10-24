import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test('retains opaque global ID and exact pattern', () {
    const json = {
      'id': 'gid://gitlab/Rule/4',
      'tagNamePattern': r'^v\d+.*$',
      'immutable': true,
    };
    final rule = ContainerTagImmutabilityRule.fromJson(json);
    expect(rule.toJson(), json);
    expect(rule.copyWith(immutable: false).immutable, isFalse);
  });
  test('missing immutable flag is not silently false', () {
    expect(
      () => ContainerTagImmutabilityRule.fromJson({
        'id': 'gid://gitlab/Rule/4',
        'tagNamePattern': '.*',
      }),
      throwsA(anything),
    );
  });
}
