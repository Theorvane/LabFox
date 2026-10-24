import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test(
    'parses direct namespace identity without changing display namespace',
    () {
      final project = Project.fromJson({
        'id': 7,
        'name': 'app',
        'path_with_namespace': 'parent/direct/app',
        'namespace': {'id': 42, 'kind': 'group', 'parent_id': 99},
      });
      expect(project.namespaceDetails?.id, 42);
      expect(project.namespaceDetails?.kind, 'group');
      expect(project.namespace, 'parent/direct');
      expect(
        Project.fromJson(project.toJson()).namespaceDetails,
        project.namespaceDetails,
      );
    },
  );
  test('absent and reduced namespace payloads remain unknown', () {
    for (final namespace in [
      null,
      <String, dynamic>{},
      {'id': 42},
    ]) {
      final project = Project.fromJson({
        'id': 7,
        'name': 'app',
        'path_with_namespace': 'user/app',
        'namespace': namespace,
      });
      expect(project.namespaceDetails?.kind, isNull);
    }
  });
  test('Project parses container registry availability', () {
    final project = Project.fromJson({
      'id': 7,
      'name': 'app',
      'path_with_namespace': 'team/app',
      'container_registry_access_level': 'disabled',
    });
    expect(project.containerRegistryAccessLevel, 'disabled');
  });
  group('Project', () {
    test('parses a full GitLab payload', () {
      final project = Project.fromJson(const {
        'id': 278964,
        'name': 'backend',
        'path_with_namespace': 'youthpick/backend',
        'description': 'The backend service',
        'star_count': 12,
        'visibility': 'private',
        'last_activity_at': '2026-08-18T02:00:00.000Z',
        'avatar_url': 'https://gitlab.example.com/avatar.png',
        'default_branch': 'main',
        'open_issues_count': 6,
        'forks_count': 3,
      });

      expect(project.id, 278964);
      expect(project.name, 'backend');
      expect(project.pathWithNamespace, 'youthpick/backend');
      expect(project.starCount, 12);
      expect(project.visibility, 'private');
      expect(project.lastActivityAt, DateTime.utc(2026, 8, 18, 2));
      expect(project.defaultBranch, 'main');
      expect(project.openIssuesCount, 6);
      expect(project.forksCount, 3);
    });

    test('default branch is null for an empty repository', () {
      final project = Project.fromJson(const {
        'id': 1,
        'name': 'empty',
        'path_with_namespace': 'me/empty',
      });
      expect(project.defaultBranch, isNull);
    });

    test('parses project wiki availability', () {
      final project = Project.fromJson(const {
        'id': 1,
        'name': 'docs',
        'path_with_namespace': 'team/docs',
        'wiki_access_level': 'disabled',
        'wiki_enabled': false,
      });

      expect(project.wikiAccessLevel, 'disabled');
      expect(project.wikiEnabled, isFalse);
    });

    test('parses package registry availability', () {
      final project = Project.fromJson(const {
        'id': 1,
        'name': 'tools',
        'path_with_namespace': 'team/tools',
        'package_registry_access_level': 'disabled',
      });

      expect(project.packageRegistryAccessLevel, 'disabled');
    });

    test('leaves optional fields null when GitLab omits them', () {
      // A minimal project payload — no description, no avatar. These must read
      // as absent, not as empty strings.
      final project = Project.fromJson(const {
        'id': 1,
        'name': 'scratch',
        'path_with_namespace': 'me/scratch',
      });

      expect(project.description, isNull);
      expect(project.avatarUrl, isNull);
      expect(project.lastActivityAt, isNull);
      // star_count is absent in this payload; default to zero, not null, since
      // the UI always shows a count.
      expect(project.starCount, 0);
      // Counts GitLab omits on reduced payloads stay null — unknown, not zero,
      // so the UI can hide them instead of showing a false 0.
      expect(project.openIssuesCount, isNull);
      expect(project.forksCount, isNull);
    });

    test('ignores fields LabFox does not model', () {
      final project = Project.fromJson(const {
        'id': 1,
        'name': 'scratch',
        'path_with_namespace': 'me/scratch',
        'some_future_field': 'value',
      });

      expect(project.id, 1);
    });

    test('namespace is the path without the project name', () {
      const project = Project(
        id: 1,
        name: 'backend',
        pathWithNamespace: 'youthpick/backend',
      );

      expect(project.namespace, 'youthpick');
    });

    test('namespace handles nested groups', () {
      const project = Project(
        id: 1,
        name: 'api',
        pathWithNamespace: 'org/team/api',
      );

      expect(project.namespace, 'org/team');
    });
  });
}
