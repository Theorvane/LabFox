import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/auth_controller.dart';
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

class _DelayedRepository extends PipelineSchedulesRepository {
  _DelayedRepository(this.firstPage)
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  Paginated<PipelineSchedule> firstPage;
  final nextPage = Completer<Paginated<PipelineSchedule>>();

  @override
  Future<Paginated<PipelineSchedule>> list(
    int projectId, {
    bool? active,
    int page = 1,
  }) async {
    expect(projectId, 7);
    return page == 1 ? firstPage : nextPage.future;
  }
}

PipelineSchedule _schedule(int id) => PipelineSchedule(
  id: id,
  description: 'Schedule $id',
  ref: 'main',
  cron: '0 1 * * *',
  active: true,
);

const _firstAccount = Account(
  instanceUrl: 'https://first.gitlab.example',
  user: User(id: 23, username: 'developer', name: 'Developer'),
);
const _secondAccount = Account(
  instanceUrl: 'https://second.gitlab.example',
  user: User(id: 23, username: 'developer', name: 'Developer'),
);

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

  for (final reject in [false, true]) {
    test(
      'old instance page cannot replace new instance schedules ($reject)',
      () async {
        final first = _DelayedRepository(
          Paginated(items: [_schedule(1)], nextPage: 2),
        );
        final second = _DelayedRepository(Paginated(items: [_schedule(9)]));
        final activeAccount = StateProvider<Account?>((ref) => _firstAccount);
        final container = ProviderContainer(
          overrides: [
            currentAccountProvider.overrideWith(
              (ref) => ref.watch(activeAccount),
            ),
            pipelineSchedulesRepositoryProvider.overrideWith((ref) async {
              final account = ref.watch(currentAccountProvider);
              return account?.instanceUrl == _firstAccount.instanceUrl
                  ? first
                  : second;
            }),
          ],
        );
        addTearDown(container.dispose);
        final provider = pipelineScheduleListControllerProvider(
          const PipelineScheduleListRef(projectId: 7),
        );
        final subscription = container.listen(provider, (_, _) {});
        addTearDown(subscription.close);

        await container.read(provider.future);
        final oldPage = container.read(provider.notifier).loadMore();
        await Future<void>.delayed(Duration.zero);
        container.read(activeAccount.notifier).state = _secondAccount;
        await container.read(provider.future);
        if (reject) {
          first.nextPage.completeError(StateError('Old instance page failed'));
        } else {
          first.nextPage.complete(Paginated(items: [_schedule(2)]));
        }
        await oldPage;

        expect(container.read(provider).hasError, isFalse);
        expect(
          container.read(provider).requireValue.items.map((item) => item.id),
          [9],
        );
      },
    );
  }

  for (final reject in [false, true]) {
    test('old page cannot replace refreshed schedule list ($reject)', () async {
      final repository = _DelayedRepository(
        Paginated(items: [_schedule(1)], nextPage: 2),
      );
      final container = ProviderContainer(
        overrides: [
          pipelineSchedulesRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(container.dispose);
      final provider = pipelineScheduleListControllerProvider(
        const PipelineScheduleListRef(projectId: 7),
      );
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      await container.read(provider.future);
      final oldPage = container.read(provider.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      repository.firstPage = Paginated(items: [_schedule(3)]);
      await container.refresh(provider.future);
      if (reject) {
        repository.nextPage.completeError(StateError('Old page failed'));
      } else {
        repository.nextPage.complete(Paginated(items: [_schedule(2)]));
      }
      await oldPage;

      expect(container.read(provider).hasError, isFalse);
      expect(
        container.read(provider).requireValue.items.map((item) => item.id),
        [3],
      );
    });
  }
}
