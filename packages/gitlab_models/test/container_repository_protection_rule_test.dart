import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test('maps protection pattern and minimum roles from snake case', () {
    final rule = ContainerRepositoryProtectionRule.fromJson({
      'id': 2,
      'project_id': 7,
      'repository_path_pattern': 'team/app/*',
      'minimum_access_level_for_push': 'maintainer',
      'minimum_access_level_for_delete': 'owner',
    });
    expect(rule.id, 2);
    expect(rule.projectId, 7);
    expect(rule.repositoryPathPattern, 'team/app/*');
    expect(rule.minimumAccessLevelForPush, 'maintainer');
    expect(rule.minimumAccessLevelForDelete, 'owner');
    expect(rule.toJson()['minimum_access_level_for_delete'], 'owner');
  });
  test('preserves absent and unknown roles without inventing permission', () {
    final rule = ContainerRepositoryProtectionRule.fromJson({
      'id': 2,
      'project_id': 7,
      'repository_path_pattern': '*',
      'minimum_access_level_for_delete': 'future_role',
    });
    expect(rule.minimumAccessLevelForPush, isNull);
    expect(rule.minimumAccessLevelForDelete, 'future_role');
  });
}
