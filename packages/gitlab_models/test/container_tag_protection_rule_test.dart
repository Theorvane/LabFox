import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test(
    'round trips an explicitly unset role without inventing permissions',
    () {
      final rule = ContainerTagProtectionRule.fromJson({
        'id': 2,
        'project_id': 7,
        'tag_name_pattern': 'latest',
        'minimum_access_level_for_push': '',
        'minimum_access_level_for_delete': 'admin',
      });
      expect(rule.minimumAccessLevelForPush, '');
      expect(rule.minimumAccessLevelForDelete, 'admin');
      expect(ContainerTagProtectionRule.fromJson(rule.toJson()), rule);
    },
  );
  test('maps protection pattern and minimum roles from snake case', () {
    final rule = ContainerTagProtectionRule.fromJson({
      'id': 2,
      'project_id': 7,
      'tag_name_pattern': 'v*-release',
      'minimum_access_level_for_push': 'maintainer',
      'minimum_access_level_for_delete': 'owner',
    });
    expect(rule.id, 2);
    expect(rule.projectId, 7);
    expect(rule.tagNamePattern, 'v*-release');
    expect(rule.minimumAccessLevelForPush, 'maintainer');
    expect(rule.minimumAccessLevelForDelete, 'owner');
    expect(rule.toJson()['minimum_access_level_for_delete'], 'owner');
  });
  test('preserves absent and unknown roles without inventing permission', () {
    final rule = ContainerTagProtectionRule.fromJson({
      'id': 2,
      'project_id': 7,
      'tag_name_pattern': '*',
      'minimum_access_level_for_delete': 'future_role',
    });
    expect(rule.minimumAccessLevelForPush, isNull);
    expect(rule.minimumAccessLevelForDelete, 'future_role');
  });
}
