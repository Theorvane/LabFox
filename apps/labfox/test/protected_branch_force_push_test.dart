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

const initial = ProtectedBranch(
  id: 12,
  name: 'release/*',
  pushAccessLevels: [ProtectedBranchAccess(id: 3, accessLevel: 40)],
);

class _Repository extends ProtectedBranchesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  ProtectedBranch current = initial;
  Object? failure;
  int writes = 0;
  int reads = 0;
  @override
  Future<Paginated<ProtectedBranch>> list(
    int projectId, {
    int page = 1,
  }) async => Paginated(items: [current]);
  @override
  Future<ProtectedBranch> get(int projectId, String name) async {
    reads++;
    return current;
  }

  @override
  Future<ProtectedBranch> updateForcePush(
    int projectId,
    String name, {
    required bool allowForcePush,
  }) async {
    writes++;
    if (failure != null) throw failure!;
    current = current.copyWith(allowForcePush: allowForcePush);
    return current;
  }
}

Future<_Repository> _pump(
  WidgetTester tester,
  Size size, {
  Brightness brightness = Brightness.light,
  bool inherited = false,
  bool allowForcePush = false,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final repository = _Repository();
  repository.current = initial.copyWith(
    inherited: inherited ? true : null,
    allowForcePush: allowForcePush,
  );
  final router = GoRouter(
    initialLocation: '/projects/7/protected_branches/release%2F%2A',
    routes: [
      GoRoute(
        path: '/projects/:id/protected_branches/:name',
        builder: (_, state) =>
            const ProtectedBranchDetailScreen(projectId: 7, name: 'release/*'),
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: brightness),
        locale: locale,
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  for (final size in [
    const Size(320, 800),
    const Size(800, 800),
    const Size(1200, 800),
  ]) {
    testWidgets('force-push edit requires acknowledgement at ${size.width}', (
      tester,
    ) async {
      final repository = await _pump(tester, size);
      await tester.tap(find.text('Edit force push'));
      await tester.pumpAndSettle();
      expect(find.textContaining('wildcard'), findsWidgets);
      final save = find.byKey(
        const ValueKey('protected-branch-force-push-save'),
      );
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
      repository.failure = const GitLabForbiddenException('Denied');
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repository.writes, 1);
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      repository.failure = null;
      await tester.tap(
        find.byKey(const ValueKey('protected-branch-force-push-reload')),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repository.writes, 2);
      expect(repository.current.allowForcePush, isTrue);
      expect(repository.reads, greaterThanOrEqualTo(3));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('inherited rule has no force-push edit action', (tester) async {
    await _pump(tester, const Size(390, 844), inherited: true);
    expect(find.text('Edit force push'), findsNothing);
  });

  for (final size in [const Size(390, 844), const Size(1200, 800)]) {
    testWidgets('disabling force push works in dark theme at ${size.width}', (
      tester,
    ) async {
      final repository = await _pump(
        tester,
        size,
        brightness: Brightness.dark,
        allowForcePush: true,
      );
      await tester.tap(
        find.byKey(const ValueKey('protected-branch-force-push-edit')),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Blocking force pushes'), findsOneWidget);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('protected-branch-force-push-save')),
      );
      await tester.pumpAndSettle();
      expect(repository.current.allowForcePush, isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  for (final code in ['en', 'ko', 'ja', 'hi', 'zh']) {
    testWidgets('force-push dialog uses locale $code', (tester) async {
      await _pump(tester, const Size(390, 844), locale: Locale(code));
      await tester.tap(
        find.byKey(const ValueKey('protected-branch-force-push-edit')),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AlertDialog)),
      );
      expect(find.text(l10n.protectedBranchForcePushEditTitle), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
