import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/container_registry/presentation/container_repository_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/l10n/app_localizations.dart';

import 'container_tag_cleanup_controller_test.dart' show CleanupRepository;

Future<void> pumpCleanup(
  WidgetTester tester,
  CleanupRepository repository, {
  double width = 390,
  bool dark = false,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
      child: MaterialApp(
        theme: dark ? ThemeData.dark() : ThemeData.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ContainerRepositoryScreen(projectId: 7, repositoryId: 3),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Clean up tags'));
  await tester.pumpAndSettle();
}

Future<void> enterDelete(WidgetTester tester, String value) async {
  await tester.enterText(find.byKey(const ValueKey('cleanup-delete')), value);
}

void main() {
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('cleanup confirmation fits width $width dark $dark', (
        tester,
      ) async {
        final repository = CleanupRepository();
        await pumpCleanup(tester, repository, width: width, dark: dark);
        expect(find.text('Project 7, image repository 3'), findsOneWidget);
        expect(repository.calls, 0);
        final fields = tester
            .widgetList<TextFormField>(find.byType(TextFormField))
            .toList();
        expect(fields.first.controller!.text, isEmpty);
        expect(fields[2].controller!.text, '10');
        expect(find.text('7 days'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(repository.calls, 0);
      });
    }
  }

  testWidgets('requires explicit pattern and a valid retention count', (
    tester,
  ) async {
    final repository = CleanupRepository();
    await pumpCleanup(tester, repository);
    await tester.tap(find.text('Schedule cleanup'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an explicit delete pattern.'), findsOneWidget);
    await enterDelete(tester, 'release.+');
    await tester.ensureVisible(find.byKey(const ValueKey('cleanup-count')));
    await tester.enterText(find.byKey(const ValueKey('cleanup-count')), '-1');
    await tester.tap(find.text('Schedule cleanup'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a non-negative whole number or leave blank.'),
      findsOneWidget,
    );
    expect(repository.calls, 0);
  });

  testWidgets('sends defaults and displays scheduled rather than deleted', (
    tester,
  ) async {
    final repository = CleanupRepository();
    await pumpCleanup(tester, repository);
    await enterDelete(tester, 'release.+');
    await tester.tap(find.text('Schedule cleanup'));
    await tester.pumpAndSettle();
    expect(repository.criteria, {
      'delete': 'release.+',
      'keep': null,
      'count': 10,
      'age': '7d',
    });
    expect(find.textContaining('Cleanup scheduled.'), findsOneWidget);
    expect(find.text('read-2'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('pending request cannot be duplicated or dismissed', (
    tester,
  ) async {
    final repository = CleanupRepository()..pending = Completer<void>();
    await pumpCleanup(tester, repository);
    await enterDelete(tester, 'release.+');
    await tester.tap(find.text('Schedule cleanup'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
          .onPressed,
      isNull,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(repository.calls, 1);
    repository.pending!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  for (final count in ['', '0']) {
    testWidgets('optional criteria preserve count "$count" and no age limit', (
      tester,
    ) async {
      final repository = CleanupRepository();
      await pumpCleanup(tester, repository, width: 1200);
      await enterDelete(tester, 'release.+');
      await tester.enterText(
        find.byKey(const ValueKey('cleanup-keep')),
        'stable',
      );
      await tester.enterText(
        find.byKey(const ValueKey('cleanup-count')),
        count,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('cleanup-age')));
      await tester.tap(find.byKey(const ValueKey('cleanup-age')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('No age limit').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Schedule cleanup'));
      await tester.pumpAndSettle();
      expect(repository.criteria, {
        'delete': 'release.+',
        'keep': 'stable',
        'count': count.isEmpty ? null : 0,
        'age': null,
      });
    });
  }

  for (final (error, message) in <(GitLabException, String)>[
    (
      const GitLabForbiddenException('sensitive detail', statusCode: 403),
      'You do not have permission to clean up tags in this repository.',
    ),
    (
      const GitLabRateLimitException('sensitive detail', statusCode: 429),
      'Cleanup is rate limited. A repository can be cleaned up at most once per hour. Try again later.',
    ),
    (
      const GitLabServerException('sensitive detail', statusCode: 400),
      'GitLab rejected the cleanup criteria. Check the RE2 patterns and retention settings.',
    ),
    (
      const GitLabServerException('sensitive detail', statusCode: 422),
      'GitLab rejected the cleanup criteria. Check the RE2 patterns and retention settings.',
    ),
    (
      const GitLabServerException('sensitive detail', statusCode: 500),
      'Could not schedule cleanup. Check your connection and try again.',
    ),
  ]) {
    testWidgets(
      'typed failure ${error.statusCode} preserves criteria for retry',
      (tester) async {
        final repository = CleanupRepository()..failure = error;
        await pumpCleanup(tester, repository);
        await enterDelete(tester, 'release.+');
        await tester.tap(find.text('Schedule cleanup'));
        await tester.pumpAndSettle();
        expect(find.text(message), findsOneWidget);
        expect(find.text('sensitive detail'), findsNothing);
        expect(
          tester
              .widget<TextFormField>(
                find.byKey(const ValueKey('cleanup-delete')),
              )
              .controller!
              .text,
          'release.+',
        );
        expect(repository.tagReads, 1);
        repository.failure = null;
        await tester.tap(find.text('Schedule cleanup'));
        await tester.pumpAndSettle();
        expect(repository.calls, 2);
        expect(find.byType(AlertDialog), findsNothing);
      },
    );
  }
}
