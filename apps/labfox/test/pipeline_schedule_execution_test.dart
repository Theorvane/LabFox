import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/pipeline_schedules/data/pipeline_schedules_repository.dart';
import 'package:labfox/features/pipeline_schedules/presentation/controllers/pipeline_schedule_execution_controller.dart';
import 'package:labfox/features/pipeline_schedules/presentation/controllers/pipeline_schedules_controller.dart';
import 'package:labfox/features/pipeline_schedules/presentation/pipeline_schedule_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _key = PipelineScheduleRef(projectId: 7, scheduleId: 13);
const _initial = PipelineSchedule(
  id: 13,
  description: 'Nightly build',
  ref: 'main',
  cron: '0 1 * * *',
  cronTimezone: 'UTC',
  active: true,
);

class _Repository extends PipelineSchedulesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  PipelineSchedule schedule = _initial;
  final calls = <Map<String, Object?>>[];
  final lists = <bool?>[];
  int gets = 0;
  Object? failure;
  Completer<void>? pending;
  @override
  Future<PipelineSchedule> get(int projectId, int scheduleId) async {
    gets++;
    return schedule;
  }

  @override
  Future<Paginated<PipelineSchedule>> list(
    int projectId, {
    bool? active,
    int page = 1,
  }) async {
    lists.add(active);
    return Paginated(items: [schedule]);
  }

  @override
  Future<PipelineSchedule> updateExecution(
    int projectId,
    int scheduleId, {
    String? ref,
    bool? active,
  }) async {
    expect(projectId, 7);
    expect(scheduleId, 13);
    calls.add({'ref': ref, 'active': active});
    await pending?.future;
    if (failure != null) throw failure!;
    return schedule = schedule.copyWith(
      ref: ref ?? schedule.ref,
      active: active ?? schedule.active,
    );
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
  await tester.tap(find.byTooltip('Edit execution settings'));
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [320.0, 390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('edits ref and disables schedule at $width $brightness', (
        tester,
      ) async {
        final repository = _Repository();
        await _pump(tester, repository, width: width, brightness: brightness);
        await tester.enterText(find.byType(TextFormField), ' refs/tags/main ');
        await tester.tap(find.byType(Switch));
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(repository.calls, [
          {'ref': 'refs/tags/main', 'active': false},
        ]);
        expect(find.text('refs/tags/main'), findsOneWidget);
        expect(repository.schedule.cron, _initial.cron);
        expect(repository.schedule.cronTimezone, _initial.cronTimezone);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('unchanged saves and cancellation make no request', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.enterText(find.byType(TextFormField), ' main ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit execution settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.calls, isEmpty);
  });
  testWidgets(
    'blank ref fails validation and ref-only edit preserves inactive state',
    (tester) async {
      final repository = _Repository()
        ..schedule = _initial.copyWith(active: false);
      await _pump(tester, repository);
      expect(tester.widget<Switch>(find.byType(Switch)).value, false);
      await tester.enterText(find.byType(TextFormField), ' ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repository.calls, isEmpty);
      expect(find.text('Enter a ref.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'refs/heads/release');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repository.calls, [
        {'ref': 'refs/heads/release', 'active': null},
      ]);
      expect(repository.schedule.active, false);
    },
  );
  testWidgets('activates an inactive schedule without rewriting ref', (
    tester,
  ) async {
    final repository = _Repository()
      ..schedule = _initial.copyWith(active: false);
    await _pump(tester, repository);
    await tester.tap(find.byType(Switch));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.calls, [
      {'ref': null, 'active': true},
    ]);
  });
  for (final error in <GitLabException>[
    const GitLabForbiddenException('Private details'),
    const GitLabServerException('Private details', statusCode: 422),
  ]) {
    testWidgets('retains rejected execution draft for actual retry $error', (
      tester,
    ) async {
      final repository = _Repository()..failure = error;
      await _pump(tester, repository);
      await tester.tap(find.byType(Switch));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Could not update execution settings. Check your permissions and ref, then try again.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Private details'), findsNothing);
      expect(tester.widget<Switch>(find.byType(Switch)).value, false);
      repository.failure = null;
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repository.calls.length, 2);
      expect(repository.calls.last, {'ref': null, 'active': false});
    });
  }
  testWidgets('blocks dismissal and duplicate submission during save', (
    tester,
  ) async {
    final repository = _Repository()..pending = Completer<void>();
    await _pump(tester, repository);
    await tester.tap(find.byType(Switch));
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump();
    expect(repository.calls.length, 1);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).enabled,
      false,
    );
    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
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
    expect(repository.calls.length, 1);
  });
  for (final reject in [false, true]) {
    test(
      'reloads detail and all filters only on success: reject=$reject',
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
          pipelineScheduleExecutionControllerProvider(_key).notifier,
        );
        await command.save();
        expect(repository.calls, isEmpty);
        if (reject) {
          await expectLater(
            command.save(active: false),
            throwsA(isA<GitLabForbiddenException>()),
          );
        } else {
          await command.save(active: false);
        }
        await container.read(pipelineScheduleDetailProvider(_key).future);
        for (final provider in providers) {
          await container.read(provider.future);
        }
        expect(repository.gets, reject ? 1 : 2);
        for (final active in <bool?>[null, true, false]) {
          expect(
            repository.lists.where((value) => value == active).length,
            reject ? 1 : 2,
          );
        }
      },
    );
  }
}
