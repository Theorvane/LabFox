import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/pipeline_schedules/data/pipeline_schedules_repository.dart';
import 'package:labfox/features/pipeline_schedules/presentation/controllers/pipeline_schedule_create_controller.dart';
import 'package:labfox/features/pipeline_schedules/presentation/controllers/pipeline_schedules_controller.dart';
import 'package:labfox/features/pipeline_schedules/presentation/pipeline_schedule_detail_screen.dart';
import 'package:labfox/features/pipeline_schedules/presentation/pipeline_schedules_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Repository extends PipelineSchedulesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final calls = <Map<String, Object?>>[];
  final lists = <bool?>[];
  Object? failure;
  Completer<void>? pending;
  PipelineSchedule? created;
  @override
  Future<Paginated<PipelineSchedule>> list(
    int projectId, {
    bool? active,
    int page = 1,
  }) async {
    lists.add(active);
    return Paginated(items: created == null ? [] : [created!]);
  }

  @override
  Future<PipelineSchedule> get(int projectId, int scheduleId) async {
    expect(scheduleId, 29);
    return created!;
  }

  @override
  Future<PipelineSchedule> create(
    int projectId, {
    required String description,
    required String ref,
    required String cron,
    String? cronTimezone,
    bool active = true,
  }) async {
    expect(projectId, 7);
    calls.add({
      'description': description,
      'ref': ref,
      'cron': cron,
      'cron_timezone': cronTimezone,
      'active': active,
    });
    await pending?.future;
    if (failure != null) throw failure!;
    return created = PipelineSchedule(
      id: 29,
      description: description,
      ref: ref,
      cron: cron,
      cronTimezone: cronTimezone,
      active: active,
    );
  }
}

Future<GoRouter> _pump(
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
    initialLocation: '/projects/7/pipeline_schedules',
    routes: [
      GoRoute(
        path: '/projects/:id/pipeline_schedules',
        builder: (_, _) => const PipelineSchedulesScreen(projectId: 7),
      ),
      GoRoute(
        path: '/projects/:id/pipeline_schedules/:scheduleId',
        builder: (_, state) => PipelineScheduleDetailScreen(
          projectId: 7,
          scheduleId: int.parse(state.pathParameters['scheduleId']!),
        ),
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
  await tester.tap(find.byTooltip('Create schedule'));
  await tester.pumpAndSettle();
  return router;
}

Future<void> _fill(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), ' Nightly ');
  await tester.enterText(find.byType(TextFormField).at(1), ' refs/tags/main ');
  await tester.enterText(find.byType(TextFormField).at(2), ' 0 1 * * * ');
}

void main() {
  for (final width in [320.0, 390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('creates from empty list at $width $brightness', (
        tester,
      ) async {
        final repository = _Repository();
        final router = await _pump(
          tester,
          repository,
          width: width,
          brightness: brightness,
        );
        await _fill(tester);
        await tester.enterText(find.byType(TextFormField).at(3), '   ');
        await tester.tap(find.text('Create schedule'));
        await tester.pumpAndSettle();
        expect(repository.calls, [
          {
            'description': 'Nightly',
            'ref': 'refs/tags/main',
            'cron': '0 1 * * *',
            'cron_timezone': null,
            'active': true,
          },
        ]);
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          '/projects/7/pipeline_schedules/29',
        );
        expect(find.text('Nightly'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
    'validates all required fields and cancellation makes no request',
    (tester) async {
      final repository = _Repository();
      await _pump(tester, repository);
      await tester.tap(find.text('Create schedule'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a value.'), findsNWidgets(3));
      expect(repository.calls, isEmpty);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.calls, isEmpty);
    },
  );
  for (final error in <GitLabException>[
    const GitLabForbiddenException('Private details'),
    const GitLabServerException('Private details', statusCode: 422),
  ]) {
    testWidgets(
      'retains rejected inputs, time zone and inactive state for retry $error',
      (tester) async {
        final repository = _Repository()..failure = error;
        final router = await _pump(tester, repository);
        await _fill(tester);
        await tester.enterText(find.byType(TextFormField).at(3), ' UTC ');
        await tester.tap(find.byType(Switch));
        await tester.tap(find.text('Create schedule'));
        await tester.pumpAndSettle();
        expect(
          find.text(
            'Could not create this pipeline schedule. Check your permissions, ref, cron, and time zone.',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('Private details'), findsNothing);
        expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
        expect(
          router.routeInformationProvider.value.uri.path,
          '/projects/7/pipeline_schedules',
        );
        repository.failure = null;
        await tester.tap(find.text('Create schedule'));
        await tester.pumpAndSettle();
        expect(repository.calls.length, 2);
        expect(repository.calls.last['cron_timezone'], 'UTC');
        expect(repository.calls.last['active'], false);
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          '/projects/7/pipeline_schedules/29',
        );
      },
    );
  }
  testWidgets('blocks dismissal and duplicate submission while creating', (
    tester,
  ) async {
    final repository = _Repository()..pending = Completer<void>();
    await _pump(tester, repository);
    await _fill(tester);
    await tester.tap(find.text('Create schedule'));
    await tester.pump();
    await tester.pump();
    expect(repository.calls.length, 1);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Create schedule'),
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
    expect(repository.calls.length, 1);
  });
  test('creation refreshes every list filter after success', () async {
    final repository = _Repository();
    final container = ProviderContainer(
      overrides: [
        pipelineSchedulesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final providers = [
      for (final active in <bool?>[null, true, false])
        pipelineScheduleListControllerProvider(
          PipelineScheduleListRef(projectId: 7, active: active),
        ),
    ];
    for (final provider in providers) {
      await container.read(provider.future);
    }
    final result = await container
        .read(pipelineScheduleCreateControllerProvider(7).notifier)
        .create(description: 'Nightly', ref: 'main', cron: '0 1 * * *');
    expect(result.id, 29);
    for (final provider in providers) {
      expect((await container.read(provider.future)).items.single.id, 29);
    }
    for (final active in <bool?>[null, true, false]) {
      expect(repository.lists.where((value) => value == active).length, 2);
    }
  });

  test('failed creation retains every cached list filter', () async {
    final repository = _Repository()
      ..failure = const GitLabForbiddenException('Forbidden');
    final container = ProviderContainer(
      overrides: [
        pipelineSchedulesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final providers = [
      for (final active in <bool?>[null, true, false])
        pipelineScheduleListControllerProvider(
          PipelineScheduleListRef(projectId: 7, active: active),
        ),
    ];
    for (final provider in providers) {
      await container.read(provider.future);
    }
    await expectLater(
      container
          .read(pipelineScheduleCreateControllerProvider(7).notifier)
          .create(description: 'Nightly', ref: 'main', cron: '0 1 * * *'),
      throwsA(isA<GitLabForbiddenException>()),
    );
    for (final provider in providers) {
      expect((await container.read(provider.future)).items, isEmpty);
    }
    expect(repository.lists.length, 3);
  });
}
