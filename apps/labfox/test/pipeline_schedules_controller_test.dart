import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipeline_schedules/data/pipeline_schedules_repository.dart';
import 'package:labfox/features/pipeline_schedules/presentation/controllers/pipeline_schedules_controller.dart';

class _FakeRepository extends PipelineSchedulesRepository {
  _FakeRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final requestedPages = <int>[];
  final played = <int>[];

  @override
  Future<Paginated<PipelineSchedule>> list(
    int projectId, {
    bool? active,
    int page = 1,
  }) async {
    expect(active, true);
    requestedPages.add(page);
    return Paginated(
      items: [
        PipelineSchedule(
          id: page,
          description: 'Nightly',
          ref: 'main',
          cron: '0 1 * * *',
          active: true,
        ),
      ],
      nextPage: page == 1 ? 2 : null,
    );
  }

  @override
  Future<void> play(int projectId, int scheduleId) async {
    played.add(scheduleId);
  }
}

void main() {
  test('loads schedule pages once and runs selected schedule', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        pipelineSchedulesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final list = pipelineScheduleListControllerProvider(
      const PipelineScheduleListRef(projectId: 7, active: true),
    );

    await container.read(list.future);
    await container.read(list.notifier).loadMore();
    await container.read(list.notifier).loadMore();
    expect(repository.requestedPages, [1, 2]);
    expect(container.read(list).requireValue.items.map((item) => item.id), [
      1,
      2,
    ]);

    final action = pipelineScheduleActionControllerProvider(
      const PipelineScheduleRef(projectId: 7, scheduleId: 1),
    );
    await container.read(action.future);
    await container.read(action.notifier).play();
    expect(repository.played, [1]);
  });
}
