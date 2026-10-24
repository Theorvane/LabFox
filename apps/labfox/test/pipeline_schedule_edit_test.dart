import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipeline_schedules/data/pipeline_schedules_repository.dart';
import 'package:labfox/features/pipeline_schedules/presentation/controllers/pipeline_schedules_controller.dart';
import 'package:labfox/features/pipeline_schedules/presentation/widgets/pipeline_schedule_edit_dialog.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _schedule = PipelineSchedule(
  id: 13,
  description: 'Nightly',
  ref: 'main',
  cron: '0 1 * * *',
  active: true,
);
const _key = PipelineScheduleRef(projectId: 7, scheduleId: 13);

class _Repository extends PipelineSchedulesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final updates = <Map<String, String?>>[];
  bool reject = false;
  Completer<void>? pending;
  final lists = <bool?>[];
  int gets = 0;
  @override
  Future<PipelineSchedule> get(int projectId, int scheduleId) async {
    gets++;
    return _schedule;
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
  Future<PipelineSchedule> update(
    int projectId,
    int scheduleId, {
    String? description,
    String? cron,
    String? cronTimezone,
  }) async {
    expect(projectId, 7);
    expect(scheduleId, 13);
    updates.add({
      'description': description,
      'cron': cron,
      'cron_timezone': cronTimezone,
    });
    await pending?.future;
    if (reject) throw const GitLabForbiddenException('Forbidden');
    return _schedule.copyWith(
      description: description ?? _schedule.description,
      cron: cron ?? _schedule.cron,
      cronTimezone: cronTimezone,
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
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pipelineSchedulesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const PipelineScheduleEditDialog(
                  schedule: _schedule,
                  scheduleRef: _key,
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('blocks duplicate saves and dismissal during update', (
    tester,
  ) async {
    final repository = _Repository()..pending = Completer<void>();
    await _pump(tester, repository);
    await tester.enterText(find.byType(TextFormField).at(0), 'Weekly');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump();
    expect(repository.updates.length, 1);
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
    for (final field in tester.widgetList<TextFormField>(
      find.byType(TextFormField),
    )) {
      expect(field.enabled, isFalse);
    }
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(PipelineScheduleEditDialog), findsOneWidget);
    repository.pending!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(PipelineScheduleEditDialog), findsNothing);
  });
  for (final width in [320.0, 390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('edits only changed description at $width $brightness', (
        tester,
      ) async {
        final repository = _Repository();
        await _pump(tester, repository, width: width, brightness: brightness);
        await tester.enterText(find.byType(TextFormField).at(0), ' Weekly ');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(repository.updates, [
          {'description': 'Weekly', 'cron': null, 'cron_timezone': null},
        ]);
        expect(find.byType(PipelineScheduleEditDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('unchanged and cancelled forms make no request', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), '0 2 * * *');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.updates, isEmpty);
  });
  testWidgets('validates blanks and retains rejected timing draft for retry', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await tester.enterText(find.byType(TextFormField).at(1), ' ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.updates, isEmpty);
    await tester.enterText(find.byType(TextFormField).at(1), '0 2 * * *');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'America/New_York',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Could not update this pipeline schedule. Check your permissions, cron, and time zone.',
      ),
      findsOneWidget,
    );
    expect(find.text('0 2 * * *'), findsOneWidget);
    repository.reject = false;
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.updates.length, 2);
    expect(find.byType(PipelineScheduleEditDialog), findsNothing);
    expect(repository.updates.last, {
      'description': null,
      'cron': '0 2 * * *',
      'cron_timezone': 'America/New_York',
    });
  });
  test(
    'successful edit refreshes detail and all list filters; no-op does not',
    () async {
      final repository = _Repository();
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
      final edit = pipelineScheduleEditControllerProvider(_key);
      await container.read(edit.future);
      await container.read(edit.notifier).save();
      expect(repository.updates, isEmpty);
      await container.read(edit.notifier).save(description: 'Weekly');
      await container.read(pipelineScheduleDetailProvider(_key).future);
      for (final provider in providers) {
        await container.read(provider.future);
      }
      expect(repository.gets, 2);
      for (final active in <bool?>[null, true, false]) {
        expect(repository.lists.where((value) => value == active).length, 2);
      }
    },
  );
}
