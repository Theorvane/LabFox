import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test(
    'parses nested pipeline and target project separately from trigger IDs',
    () {
      final job = PipelineTriggerJob.fromJson({
        'id': 10,
        'name': 'deploy',
        'status': 'success',
        'stage': 'release',
        'downstream_pipeline': {
          'id': 33,
          'project_id': 8,
          'status': 'running',
          'ref': 'release/v1',
        },
      });
      expect(job.downstreamPipeline?.id, 33);
      expect(job.downstreamPipeline?.projectId, 8);
      expect(job.ciStatus, CiStatus.success);
      expect(PipelineTriggerJob.fromJson(job.toJson()), job);
    },
  );
  test('null or missing downstream targets remain representable', () {
    for (final json in [
      {'id': 10, 'name': 'deploy', 'status': 'pending'},
      {
        'id': 10,
        'name': 'deploy',
        'status': 'pending',
        'downstream_pipeline': null,
      },
    ]) {
      expect(PipelineTriggerJob.fromJson(json).downstreamPipeline, isNull);
    }
  });
  test('a pipeline may omit its target project on older instances', () {
    expect(
      Pipeline.fromJson({'id': 33, 'status': 'running'}).projectId,
      isNull,
    );
  });
}
