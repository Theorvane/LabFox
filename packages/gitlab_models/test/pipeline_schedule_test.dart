import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test('parses a pipeline schedule without retaining variable values', () {
    final schedule = PipelineSchedule.fromJson({
      'id': 13,
      'description': 'Nightly build',
      'ref': 'refs/heads/main',
      'cron': '0 1 * * *',
      'cron_timezone': 'UTC',
      'active': true,
      'next_run_at': '2026-09-27T01:00:00.000Z',
      'last_pipeline': {'id': 332, 'status': 'success'},
      'variables': [
        {'key': 'SECRET', 'value': 'never-retain-this'},
      ],
    });

    expect(schedule.id, 13);
    expect(schedule.nextRunAt, DateTime.utc(2026, 9, 27, 1));
    expect(schedule.lastPipeline?.id, 332);
    expect(schedule.toJson().toString(), isNot(contains('never-retain-this')));
  });
}
