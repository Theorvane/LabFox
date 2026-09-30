import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/protected_tags/data/protected_tags_repository.dart';
import 'package:labfox/features/protected_tags/presentation/controllers/protected_tags_controller.dart';
import 'package:labfox/features/protected_tags/presentation/protected_tags_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class ProtectRepository extends ProtectedTagsRepository {
  ProtectRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final pages = <int, Paginated<ProtectedTag>>{1: const Paginated(items: [])};
  final reads = <int>[];
  final writes = <({String name, int role})>[];
  Completer<void>? pendingRead;
  Completer<void>? pendingWrite;
  Object? readFailure;
  Object? writeFailure;
  ProtectedTag? returned;
  @override
  Future<Paginated<ProtectedTag>> list(int projectId, {int page = 1}) async {
    reads.add(page);
    if (pendingRead != null) await pendingRead!.future;
    if (readFailure != null) throw readFailure!;
    return pages[page] ?? const Paginated(items: []);
  }

  @override
  Future<ProtectedTag> protect(
    int projectId, {
    required String name,
    required int createAccessLevel,
  }) async {
    writes.add((name: name, role: createAccessLevel));
    if (pendingWrite != null) await pendingWrite!.future;
    if (writeFailure != null) throw writeFailure!;
    final rule =
        returned ??
        ProtectedTag(
          name: name,
          createAccessLevels: [
            ProtectedBranchAccess(accessLevel: createAccessLevel),
          ],
        );
    pages[1] = Paginated(items: [rule]);
    return rule;
  }
}

Future<void> pumpProtect(
  WidgetTester tester,
  ProtectRepository repository, {
  double width = 390,
  bool dark = false,
  String locale = 'en',
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/protected_tags',
    routes: [
      GoRoute(
        path: '/projects/:id/protected_tags',
        builder: (_, state) => const ProtectedTagsScreen(projectId: 7),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        protectedTagsRepositoryProvider.overrideWith((ref) async => repository),
      ],
      child: MaterialApp.router(
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('entry opens a draft and does not write', (tester) async {
    final repository = ProtectRepository();
    await pumpProtect(tester, repository);
    final entry = find.byKey(const ValueKey('protected-tag-protect'));
    expect(entry, findsOneWidget);
    await tester.tap(entry);
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
  });
  testWidgets(
    'requires explicit acknowledgement before creating the default Maintainers rule',
    (tester) async {
      final repository = ProtectRepository();
      await pumpProtect(tester, repository);
      await tester.tap(find.byKey(const ValueKey('protected-tag-protect')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('protected-tag-name')),
        'release/*',
      );
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('protected-tag-submit')),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.byKey(const ValueKey('protected-tag-ack')));
      await tester.pump();
      expect(
        find.text('Your account changed. Close this draft and start again.'),
        findsNothing,
      );
      expect(
        tester
            .widget<CheckboxListTile>(
              find.byKey(const ValueKey('protected-tag-ack')),
            )
            .value,
        isTrue,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('protected-tag-submit')),
            )
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.byKey(const ValueKey('protected-tag-submit')));
      await tester.pumpAndSettle();
      expect(repository.writes.single, (name: 'release/*', role: 40));
      expect(find.byKey(const ValueKey('protected-tag-name')), findsNothing);
    },
  );
  testWidgets('failed write requires a fresh scan before retry', (
    tester,
  ) async {
    final repository = ProtectRepository()
      ..writeFailure = const GitLabConnectionException('network');
    await pumpProtect(tester, repository);
    await tester.tap(find.byKey(const ValueKey('protected-tag-protect')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('protected-tag-name')),
      'v*',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('protected-tag-ack')));
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('protected-tag-submit')),
          )
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const ValueKey('protected-tag-submit')));
    await tester.pumpAndSettle();
    expect(repository.writes, hasLength(1));
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('protected-tag-submit')),
          )
          .onPressed,
      isNull,
    );
    repository.writeFailure = null;
    await tester.ensureVisible(
      find.byKey(const ValueKey('protected-tag-reload')),
    );
    await tester.tap(find.byKey(const ValueKey('protected-tag-reload')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('protected-tag-ack')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('protected-tag-submit')));
    await tester.pumpAndSettle();
    expect(repository.writes, hasLength(2));
  });

  for (final role in [0, 30]) {
    testWidgets('creates an exact rule with role $role', (tester) async {
      final repository = ProtectRepository();
      await pumpProtect(tester, repository);
      await tester.tap(find.byKey(const ValueKey('protected-tag-protect')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('protected-tag-name')),
        'Release_$role',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('protected-tag-role')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(role == 0 ? 'No one' : 'Developers and Maintainers').last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('protected-tag-ack')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('protected-tag-submit')));
      await tester.pumpAndSettle();
      expect(repository.writes.single, (name: 'Release_$role', role: role));
    });
  }

  testWidgets('a rule found on the second page blocks creation', (
    tester,
  ) async {
    final repository = ProtectRepository();
    repository.pages[1] = const Paginated(items: [], nextPage: 2);
    repository.pages[2] = const Paginated(items: [ProtectedTag(name: 'v*')]);
    await pumpProtect(tester, repository);
    await tester.tap(find.byKey(const ValueKey('protected-tag-protect')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('protected-tag-name')),
      'v*',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('protected-tag-ack')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('protected-tag-submit')));
    await tester.pumpAndSettle();
    expect(repository.reads, contains(2));
    expect(repository.writes, isEmpty);
    expect(
      find.text('Rule already exists. No change was made.'),
      findsOneWidget,
    );
  });

  for (final width in [320.0, 800.0, 1200.0]) {
    for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
      testWidgets('draft fits width $width in $locale', (tester) async {
        final repository = ProtectRepository();
        await pumpProtect(tester, repository, width: width, locale: locale);
        await tester.tap(find.byKey(const ValueKey('protected-tag-protect')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('protected-tag-submit')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
