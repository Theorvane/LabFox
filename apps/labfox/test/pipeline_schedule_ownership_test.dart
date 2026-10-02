import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/pipeline_schedules/data/pipeline_schedules_repository.dart';
import 'package:labfox/features/pipeline_schedules/presentation/controllers/pipeline_schedule_ownership_controller.dart';
import 'package:labfox/features/pipeline_schedules/presentation/controllers/pipeline_schedules_controller.dart';
import 'package:labfox/features/pipeline_schedules/presentation/pipeline_schedule_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _key = PipelineScheduleRef(projectId: 7, scheduleId: 13);
const _schedule = PipelineSchedule(
  id: 13,
  description: 'Nightly build',
  ref: 'main',
  cron: '0 1 * * *',
  active: true,
  owner: ScheduleOwner(id: 12, name: 'Original owner'),
);

class _Repository extends PipelineSchedulesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  int transfers = 0;
  int gets = 0;
  bool transferred = false;
  Object? failure;
  Completer<void>? pending;
  final lists = <bool?>[];
  @override
  Future<PipelineSchedule> get(int projectId, int scheduleId) async {
    gets++;
    return transferred
        ? _schedule.copyWith(
            owner: const ScheduleOwner(id: 50, name: 'New owner'),
          )
        : _schedule;
  }

  @override
  Future<Paginated<PipelineSchedule>> list(
    int projectId, {
    bool? active,
    int page = 1,
  }) async {
    lists.add(active);
    return const Paginated(items: [_schedule]);
  }

  @override
  Future<PipelineSchedule> takeOwnership(int projectId, int scheduleId) async {
    expect(projectId, 7);
    expect(scheduleId, 13);
    transfers++;
    await pending?.future;
    if (failure != null) throw failure!;
    transferred = true;
    return _schedule.copyWith(owner: null);
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = Size(width, 850);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/pipeline_schedules/13',
    routes: [
      GoRoute(
        path: '/projects/:id/pipeline_schedules/:scheduleId',
        builder: (_, _) =>
            const PipelineScheduleDetailScreen(projectId: 7, scheduleId: 13),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pipelineSchedulesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Take ownership'));
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [320.0, 390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('confirms ownership and reloads owner at $width $brightness', (
        tester,
      ) async {
        final repository = _Repository();
        await _pump(tester, repository, width: width, brightness: brightness);
        expect(find.text('Take ownership of this schedule?'), findsOneWidget);
        expect(
          find.text(
            'You will become the owner of "Nightly build". Scheduled pipelines will run with your permissions. This requires the Maintainer or Owner role.',
          ),
          findsOneWidget,
        );
        expect(repository.transfers, 0);
        await tester.tap(find.widgetWithText(FilledButton, 'Take ownership'));
        await tester.pumpAndSettle();
        expect(repository.transfers, 1);
        expect(find.text('New owner'), findsOneWidget);
        expect(find.text('Original owner'), findsNothing);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('cancellation and dismissal do not transfer ownership', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Take ownership'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(repository.transfers, 0);
    expect(find.text('Original owner'), findsOneWidget);
  });
  testWidgets('retains rejected confirmation for a real retry', (tester) async {
    final repository = _Repository()
      ..failure = const GitLabForbiddenException('Private details');
    await _pump(tester, repository);
    await tester.tap(find.widgetWithText(FilledButton, 'Take ownership'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Could not take ownership of this pipeline schedule. Check your permissions and try again.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Private details'), findsNothing);
    expect(find.text('Original owner'), findsOneWidget);
    repository.failure = null;
    await tester.tap(find.widgetWithText(FilledButton, 'Take ownership'));
    await tester.pumpAndSettle();
    expect(repository.transfers, 2);
    expect(find.text('New owner'), findsOneWidget);
  });
  testWidgets('blocks duplicate confirmation and dismissal during transfer', (
    tester,
  ) async {
    final repository = _Repository()..pending = Completer<void>();
    await _pump(tester, repository);
    await tester.tap(find.widgetWithText(FilledButton, 'Take ownership'));
    await tester.pump();
    await tester.pump();
    expect(repository.transfers, 1);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Take ownership'),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
          .onPressed,
      isNull,
    );
    await tester.binding.handlePopRoute();
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    repository.pending!.complete();
    await tester.pumpAndSettle();
    expect(repository.transfers, 1);
  });
  for (final reject in [false, true]) {
    test(
      'refreshes all filters only after successful transfer: reject=$reject',
      () async {
        final repository = _Repository();
        if (reject) {
          repository.failure = const GitLabForbiddenException('Forbidden');
        }
        final container = ProviderContainer(
          overrides: [
            pipelineSchedulesRepositoryProvider.overrideWith(
              (ref) async => repository,
            ),
          ],
        );
        addTearDown(container.dispose);
        await container.read(pipelineScheduleDetailProvider(_key).future);
        final providers = [
          for (final active in <bool?>[null, true, false])
            pipelineScheduleListControllerProvider(
              PipelineScheduleListRef(projectId: 7, active: active),
            ),
        ];
        for (final provider in providers) {
          await container.read(provider.future);
        }
        final command = container.read(
          pipelineScheduleOwnershipControllerProvider(_key).notifier,
        );
        if (reject) {
          await expectLater(
            command.takeOwnership(),
            throwsA(isA<GitLabForbiddenException>()),
          );
        } else {
          await command.takeOwnership();
        }
        final detail = await container.read(
          pipelineScheduleDetailProvider(_key).future,
        );
        expect(detail.owner?.name, reject ? 'Original owner' : 'New owner');
        for (final provider in providers) {
          await container.read(provider.future);
        }
        for (final active in <bool?>[null, true, false]) {
          expect(
            repository.lists.where((value) => value == active).length,
            reject ? 1 : 2,
          );
        }
        expect(repository.gets, reject ? 1 : 2);
      },
    );
  }

  test('controller prevents a second transfer while one is pending', () async {
    final repository = _Repository()..pending = Completer<void>();
    final container = ProviderContainer(
      overrides: [
        pipelineSchedulesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(pipelineSchedulesRepositoryProvider.future);
    final command = container.read(
      pipelineScheduleOwnershipControllerProvider(_key).notifier,
    );
    final first = command.takeOwnership();
    await expectLater(command.takeOwnership(), throwsA(isA<StateError>()));
    repository.pending!.complete();
    await first;
    expect(repository.transfers, 1);
  });
}
