import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test('parses issue activity and preserves project-local iid', () {
    final event = ProjectEvent.fromJson({
      'id': 8,
      'project_id': 7,
      'action_name': 'opened',
      'target_id': 160,
      'target_iid': 53,
      'target_type': 'Issue',
      'target_title': 'Fix login',
      'created_at': '2026-09-20T10:43:19.667Z',
      'author': {'id': 25, 'name': 'Test User', 'username': 'tester'},
    });

    expect(event.targetId, 160);
    expect(event.targetIid, 53);
    expect(event.author?.name, 'Test User');
    expect(event.createdAt?.isUtc, isTrue);
  });

  test('parses a bulk push with nullable commit details', () {
    final event = ProjectEvent.fromJson({
      'id': 9,
      'project_id': 7,
      'action_name': 'pushed',
      'target_type': null,
      'push_data': {'commit_count': 0, 'ref_count': 100, 'ref': null},
    });

    expect(event.targetIid, isNull);
    expect(event.pushData?.commitCount, 0);
    expect(event.pushData?.refCount, 100);
    expect(event.pushData?.commitTo, isNull);
  });
}
