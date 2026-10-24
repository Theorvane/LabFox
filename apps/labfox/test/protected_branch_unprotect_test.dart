import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/protected_branches/data/protected_branches_repository.dart';
import 'package:labfox/features/protected_branches/presentation/controllers/protected_branches_controller.dart';
import 'package:labfox/features/protected_branches/presentation/protected_branch_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

const rule = ProtectedBranch(id: 12, name: 'release/*');

class _Repository extends ProtectedBranchesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  int deletes = 0;
  int reads = 0;
  Object? failure;
  Object? readFailure;
  @override
  Future<Paginated<ProtectedBranch>> list(
    int projectId, {
    int page = 1,
  }) async => const Paginated(items: [rule]);
  @override
  Future<ProtectedBranch> get(int projectId, String name) async {
    reads++;
    if (readFailure != null) throw readFailure!;
    return rule;
  }

  @override
  Future<void> unprotect(int projectId, String name) async {
    deletes++;
    if (failure != null) throw failure!;
  }
}

void main() {
  testWidgets('uncertain deletion stays locked after cancel and reopen', (
    tester,
  ) async {
    final repository = _Repository()
      ..failure = const GitLabServerException('Uncertain deletion');
    final router = GoRouter(
      initialLocation: '/projects/7/protected_branches/release%2F%2A',
      routes: [
        GoRoute(
          path: '/projects/:id/protected_branches/:name',
          builder: (_, state) => const ProtectedBranchDetailScreen(
            projectId: 7,
            name: 'release/*',
          ),
        ),
        GoRoute(
          path: '/projects/:id/protected_branches',
          builder: (_, state) => const Scaffold(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          protectedBranchesRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unprotect branch rule'));
    await tester.pumpAndSettle();
    final name = find.byKey(const ValueKey('protected-branch-unprotect-name'));
    final save = find.byKey(const ValueKey('protected-branch-unprotect-save'));
    final reload = find.byKey(
      const ValueKey('protected-branch-unprotect-reload'),
    );
    await tester.enterText(name, 'release/*');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(repository.deletes, 1);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    final readsBeforeReopen = repository.reads;
    await tester.tap(find.text('Unprotect branch rule'));
    await tester.pumpAndSettle();
    expect(reload, findsOneWidget);
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).onChanged,
      isNull,
    );
    expect(repository.reads, readsBeforeReopen);
    repository.failure = null;
    repository.readFailure = const GitLabServerException(
      'Inspection unavailable',
    );
    await tester.tap(reload);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    expect(repository.deletes, 1);
    repository.readFailure = null;
    await tester.tap(reload);
    await tester.pumpAndSettle();
    expect(repository.reads, greaterThan(readsBeforeReopen));
    await tester.enterText(name, 'release/*');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(repository.deletes, 2);
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 800),
    const Size(800, 800),
    const Size(1200, 800),
  ]) {
    testWidgets('exact name and acknowledgement required at ${size.width}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = _Repository();
      final router = GoRouter(
        initialLocation: '/projects/7/protected_branches/release%2F%2A',
        routes: [
          GoRoute(
            path: '/projects/:id/protected_branches/:name',
            builder: (_, state) => const ProtectedBranchDetailScreen(
              projectId: 7,
              name: 'release/*',
            ),
          ),
          GoRoute(
            path: '/projects/:id/protected_branches',
            builder: (_, state) => const Scaffold(),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            protectedBranchesRepositoryProvider.overrideWith(
              (ref) async => repository,
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unprotect branch rule'));
      await tester.pumpAndSettle();
      expect(find.textContaining('wildcard'), findsWidgets);
      final save = find.byKey(
        const ValueKey('protected-branch-unprotect-save'),
      );
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      await tester.enterText(
        find.byKey(const ValueKey('protected-branch-unprotect-name')),
        'Release/*',
      );
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      await tester.enterText(
        find.byKey(const ValueKey('protected-branch-unprotect-name')),
        'release/*',
      );
      await tester.pump();
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
      repository.failure = const GitLabForbiddenException('Denied');
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repository.deletes, 1);
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      expect(
        find.byKey(const ValueKey('protected-branch-unprotect-reload')),
        findsOneWidget,
      );
      repository.failure = null;
      await tester.tap(
        find.byKey(const ValueKey('protected-branch-unprotect-reload')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('protected-branch-unprotect-name')),
        'release/*',
      );
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repository.deletes, 2);
      expect(repository.reads, greaterThanOrEqualTo(4));
      expect(tester.takeException(), isNull);
    });
  }
}
