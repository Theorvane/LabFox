import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test('parses an environment with its latest deployment', () {
    final environment = GitLabEnvironment.fromJson(const {
      'id': 9,
      'name': 'production',
      'slug': 'production',
      'state': 'available',
      'tier': 'production',
      'description': 'Customer-facing deployment',
      'external_url': 'https://example.com',
      'auto_stop_at': '2026-10-01T10:00:00Z',
      'last_deployment': {
        'id': 42,
        'iid': 7,
        'ref': 'main',
        'sha': 'abcdef123456',
        'status': 'success',
        'created_at': '2026-09-01T10:00:00Z',
      },
    });

    expect(environment.id, 9);
    expect(environment.externalUrl, 'https://example.com');
    expect(environment.autoStopAt, DateTime.utc(2026, 10, 1, 10));
    expect(environment.lastDeployment?.id, 42);
    expect(environment.lastDeployment?.iid, 7);
    expect(environment.lastDeployment?.status, 'success');
  });

  test('accepts an environment without optional deployment details', () {
    final environment = GitLabEnvironment.fromJson(const {
      'id': 10,
      'name': 'review/test',
      'state': 'stopped',
    });

    expect(environment.lastDeployment, isNull);
    expect(environment.externalUrl, isNull);
    expect(environment.description, isNull);
  });
}
