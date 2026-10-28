import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test('parses typed global IDs without confusing the pipeline iid', () {
    final target = PipelineUpstream.fromJson({
      'id': 'gid://gitlab/Ci::Pipeline/33',
      'iid': '2',
      'status': 'RUNNING',
      'ref': 'release/v1',
      'project': {'id': 'gid://gitlab/Project/8'},
    });
    expect(target.pipelineId, 33);
    expect(target.projectId, 8);
    expect(target.ciStatus, CiStatus.running);
    expect(PipelineUpstream.fromJson(target.toJson()), target);
  });
  test('unavailable target project retains readable pipeline metadata', () {
    final target = PipelineUpstream.fromJson({
      'id': 'gid://gitlab/Ci::Pipeline/33',
      'status': 'SUCCESS',
      'project': null,
    });
    expect(target.pipelineId, 33);
    expect(target.projectId, isNull);
    expect(target.ciStatus, CiStatus.success);
  });
  for (final id in [
    '33',
    'gid://gitlab/Project/33',
    'gid://outside/Ci::Pipeline/33',
    'gid://gitlab/Ci::Pipeline/0',
    'gid://gitlab/Ci::Pipeline/-1',
    'gid://gitlab/Ci::Pipeline/033',
    'gid://gitlab/Ci::Pipeline/33?x=1',
    'gid://gitlab/Ci::Pipeline/33/',
    'gid://gitlab/Ci::Pipeline/33\n',
  ]) {
    test('does not route invalid pipeline global ID $id', () {
      expect(PipelineUpstream(id: id, status: 'RUNNING').pipelineId, isNull);
    });
  }
  for (final id in [
    '8',
    'gid://gitlab/Group/8',
    'gid://gitlab/Project/0',
    'gid://gitlab/Project/08',
    'gid://outside/Project/8',
    'gid://gitlab/Project/8#fragment',
  ]) {
    test('does not route invalid project global ID $id', () {
      expect(
        PipelineUpstream(
          id: 'gid://gitlab/Ci::Pipeline/33',
          status: 'RUNNING',
          project: PipelineUpstreamProject(id: id),
        ).projectId,
        isNull,
      );
    });
  }
}
