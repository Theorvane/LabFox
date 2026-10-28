import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test('parses deployment details and nested job links', () {
    final deployment = GitLabDeployment.fromJson({
      'id': 42,
      'iid': 2,
      'ref': 'main',
      'sha': 'a91957a8',
      'status': 'success',
      'created_at': '2026-09-20T10:43:19.667Z',
      'environment': {
        'id': 9,
        'name': 'production',
        'external_url': 'https://example.com',
      },
      'deployable': {
        'id': 664,
        'name': 'deploy',
        'status': 'success',
        'pipeline': {'id': 37, 'status': 'success'},
        'commit': {'id': 'a91957a8', 'title': 'Deploy release'},
      },
    });

    expect(deployment.id, 42);
    expect(deployment.iid, 2);
    expect(deployment.environment?.name, 'production');
    expect(deployment.deployable?.pipeline?.id, 37);
    expect(deployment.createdAt?.isUtc, isTrue);
  });

  test('accepts a deployment without a deployable job', () {
    final deployment = GitLabDeployment.fromJson({
      'id': 43,
      'status': 'created',
      'deployable': null,
    });

    expect(deployment.deployable, isNull);
    expect(deployment.environment, isNull);
  });
}
