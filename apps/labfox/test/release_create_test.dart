import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/releases/data/releases_repository.dart';
import 'package:labfox/features/releases/presentation/controllers/releases_controller.dart';
import 'package:labfox/features/releases/presentation/releases_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Repository extends ReleasesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final creates =
      <
        ({
          String tagName,
          String? ref,
          String? name,
          String? description,
          DateTime? releasedAt,
        })
      >[];
  bool reject = false;

  @override
  Future<Paginated<GitLabRelease>> list(int projectId, {int page = 1}) async =>
      const Paginated(items: []);

  @override
  Future<GitLabRelease> create(
    int projectId, {
    required String tagName,
    String? ref,
    String? name,
    String? description,
    DateTime? releasedAt,
  }) async {
    expect(projectId, 7);
    creates.add((
      tagName: tagName,
      ref: ref,
      name: name,
      description: description,
      releasedAt: releasedAt,
    ));
    if (reject) throw const GitLabForbiddenException('Forbidden');
    return GitLabRelease(name: name ?? tagName, tagName: tagName);
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/releases',
    routes: [
      GoRoute(
        path: '/projects/:id/releases',
        builder: (_, _) => const ReleasesScreen(projectId: 7),
      ),
      GoRoute(
        path: '/projects/:id/releases/:tagName',
        builder: (_, state) => Scaffold(
          body: Text('Created release ${state.pathParameters['tagName']}'),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        releasesRepositoryProvider.overrideWith((ref) async => repository),
      ],
      child: MaterialApp.router(
        theme: ThemeData(brightness: brightness),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [390.0, 1200.0]) {
    testWidgets('creates a release from an empty list at width $width', (
      tester,
    ) async {
      final repository = _Repository();
      await _pump(tester, repository, width: width);
      await tester.tap(find.text('New release'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create release'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a tag name.'), findsOneWidget);
      expect(repository.creates, isEmpty);

      await tester.enterText(find.byType(TextField).at(0), ' release/2 ');
      await tester.enterText(find.byType(TextField).at(1), ' main ');
      await tester.enterText(find.byType(TextField).at(2), ' Version 2 ');
      await tester.enterText(find.byType(TextField).at(3), '## Changes');
      await tester.tap(find.text('Create release'));
      await tester.pumpAndSettle();
      expect(repository.creates.single, (
        tagName: 'release/2',
        ref: 'main',
        name: 'Version 2',
        description: '## Changes',
        releasedAt: null,
      ));
      expect(find.text('Created release release/2'), findsOneWidget);
    });
  }

  testWidgets('keeps a release draft after a forbidden response', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await tester.tap(find.text('New release'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'v2');
    await tester.enterText(find.byType(TextField).at(3), '## Notes');
    await tester.tap(find.text('Create release'));
    await tester.pumpAndSettle();
    expect(find.text('Could not create the release.'), findsOneWidget);
    expect(find.text('v2'), findsOneWidget);
    expect(find.text('## Notes'), findsOneWidget);
    repository.reject = false;
    await tester.tap(find.text('Create release'));
    await tester.pumpAndSettle();
    expect(repository.creates.last, (
      tagName: 'v2',
      ref: null,
      name: null,
      description: '## Notes',
      releasedAt: null,
    ));
    expect(find.text('Created release v2'), findsOneWidget);
  });

  for (final width in [320.0, 390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('optional future date and time at $width $brightness', (
        tester,
      ) async {
        final repository = _Repository()..reject = true;
        await _pump(tester, repository, width: width, brightness: brightness);
        await tester.tap(find.text('New release'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, 'future/1');
        await tester.ensureVisible(find.text('Choose publication date'));
        await tester.tap(find.text('Choose publication date'));
        await tester.pumpAndSettle();
        final initial = tester
            .widget<DatePickerDialog>(find.byType(DatePickerDialog))
            .initialDate!;
        await tester.tap(find.byTooltip('Next month'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('15').last);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Choose publication time'));
        await tester.tap(find.text('Choose publication time'));
        await tester.pumpAndSettle();
        final timeFields = find.descendant(
          of: find.byType(TimePickerDialog),
          matching: find.byType(TextField),
        );
        await tester.enterText(timeFields.at(0), '10');
        await tester.enterText(timeFields.at(1), '30');
        await tester.ensureVisible(find.text('OK'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create release'));
        await tester.pumpAndSettle();
        expect(
          repository.creates.single.releasedAt,
          DateTime(initial.year, initial.month + 1, 15, 10, 30).toUtc(),
        );
        expect(repository.creates.single.releasedAt!.isUtc, isTrue);
        expect(find.text('Could not create the release.'), findsOneWidget);
        repository.reject = false;
        await tester.tap(find.text('Create release'));
        await tester.pumpAndSettle();
        expect(
          repository.creates.last.releasedAt,
          repository.creates.first.releasedAt,
        );
        expect(find.text('Created release future/1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('clearing an explicit date restores server-default publication', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.text('New release'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'v3');
    await tester.ensureVisible(find.text('Choose publication date'));
    await tester.tap(find.text('Choose publication date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Use publication time from GitLab'));
    await tester.tap(find.text('Use publication time from GitLab'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create release'));
    await tester.pumpAndSettle();
    expect(repository.creates.single.releasedAt, isNull);
  });

  testWidgets('cancelled picker does not set an explicit publication time', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.text('New release'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'v4');
    await tester.ensureVisible(find.text('Choose publication date'));
    await tester.tap(find.text('Choose publication date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create release'));
    await tester.pumpAndSettle();
    expect(repository.creates.single.releasedAt, isNull);
  });
}
