import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test('project parses and round trips modern cleanup policy settings', () {
    final project = Project.fromJson({
      'id': 7,
      'name': 'app',
      'path_with_namespace': 'team/app',
      'container_expiration_policy': {
        'enabled': true,
        'cadence': '7d',
        'keep_n': 10,
        'older_than': '14d',
        'name_regex_delete': 'release.+',
        'name_regex': 'legacy',
        'name_regex_keep': 'stable',
        'next_run_at': '2026-09-30T10:00:00Z',
      },
    });
    final policy = project.containerExpirationPolicy!;
    expect(policy.enabled, isTrue);
    expect(policy.cadence, '7d');
    expect(policy.keepN, 10);
    expect(policy.olderThan, '14d');
    expect(policy.nameRegexDelete, 'release.+');
    expect(policy.nameRegex, 'legacy');
    expect(policy.nameRegexKeep, 'stable');
    expect(policy.nextRunAt, DateTime.utc(2026, 9, 30, 10));
    expect(Project.fromJson(project.toJson()), project);
  });

  test('absent and null policies do not mean disabled', () {
    for (final payload in <Map<String, dynamic>>[
      {},
      {'container_expiration_policy': null},
    ]) {
      final project = Project.fromJson({
        'id': 7,
        'name': 'app',
        'path_with_namespace': 'team/app',
        ...payload,
      });
      expect(project.containerExpirationPolicy, isNull);
    }
    final policy = ContainerCleanupPolicy.fromJson({});
    expect(policy.enabled, isNull);
    expect(policy.keepN, isNull);
    expect(policy.nextRunAt, isNull);
  });

  test('legacy, empty, zero and future settings are preserved exactly', () {
    final policy = ContainerCleanupPolicy.fromJson({
      'enabled': false,
      'cadence': 'future-cadence',
      'keep_n': 0,
      'older_than': 'future-age',
      'name_regex': 'legacy',
      'name_regex_delete': '',
      'name_regex_keep': '',
    });
    expect(policy.enabled, isFalse);
    expect(policy.cadence, 'future-cadence');
    expect(policy.keepN, 0);
    expect(policy.olderThan, 'future-age');
    expect(policy.nameRegexDelete, '');
    expect(policy.nameRegexKeep, '');
    expect(ContainerCleanupPolicy.fromJson(policy.toJson()), policy);
  });
}
