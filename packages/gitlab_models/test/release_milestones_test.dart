import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test(
    'parses project and group release milestones with global and local ids',
    () {
      final release = GitLabRelease.fromJson({
        'name': 'Version 1',
        'tag_name': 'v1',
        'milestones': [
          {
            'id': 51,
            'iid': 1,
            'title': 'Project target',
            'state': 'closed',
            'project_id': 7,
          },
          {
            'id': 64,
            'iid': 2,
            'title': 'Group target',
            'state': 'active',
            'group_id': 9,
          },
        ],
      });
      expect(release.milestones.map((m) => m.id), [51, 64]);
      expect(release.milestones.map((m) => m.iid), [1, 2]);
      expect(release.milestones.last.groupId, 9);
      expect(
        GitLabRelease.fromJson(release.toJson()).milestones,
        release.milestones,
      );
    },
  );
  test('older release responses default to no milestones', () {
    expect(
      GitLabRelease.fromJson({
        'name': 'Version 1',
        'tag_name': 'v1',
      }).milestones,
      isEmpty,
    );
  });
}
