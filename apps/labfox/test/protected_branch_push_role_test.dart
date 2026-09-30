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
  mergeAccessLevels: [ProtectedBranchAccess(id: 3, accessLevel: 40)],
  pushAccessLevels: [ProtectedBranchAccess(id: 4, accessLevel: 40)],
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
  Future<ProtectedBranch> updatePushRole(
    int projectId,
    String name, {
    required int accessRecordId,
    required int accessLevel,
  }) async {
    writes++;
    if (failure != null) throw failure!;
    current = current.copyWith(
      pushAccessLevels: [
        current.pushAccessLevels.single.copyWith(accessLevel: accessLevel),
      ],
    );
    return current;
  }
}

Future<_Repository> _pumpScreen(
  WidgetTester tester,
  Size size, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
  ProtectedBranch rule = initial,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final repository = _Repository()..current = rule;
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
    testWidgets('push role edit requires acknowledgement at ${size.width}', (
      tester,
    ) async {
      final repository = await _pumpScreen(tester, size);
      await tester.tap(
        find.byKey(const ValueKey('protected-branch-push-role-edit')),
      );
      await tester.pumpAndSettle();
      final save = find.byKey(
        const ValueKey('protected-branch-push-role-save'),
      );
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      await tester.tap(
        find.byKey(const ValueKey('protected-branch-push-role-30')),
      );
      await tester.pump();
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
        find.byKey(const ValueKey('protected-branch-push-role-reload')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('protected-branch-push-role-30')),
      );
      await tester.tap(
        find.byKey(const ValueKey('protected-branch-push-role-30')),
      );
      await tester.pump();
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repository.writes, 2);
      expect(repository.current.pushAccessLevels.single.accessLevel, 30);
      expect(repository.current.mergeAccessLevels.single.accessLevel, 40);
      expect(tester.takeException(), isNull);
    });
  }

  for (final rule in [
    initial.copyWith(inherited: true),
    initial.copyWith(pushAccessLevels: []),
    initial.copyWith(
      pushAccessLevels: [const ProtectedBranchAccess(id: 4, userId: 9)],
    ),
    initial.copyWith(
      pushAccessLevels: [
        ...initial.pushAccessLevels,
        const ProtectedBranchAccess(id: 5, accessLevel: 30),
      ],
    ),
  ]) {
    testWidgets('unsupported rule has no merge edit action $rule', (
      tester,
    ) async {
      await _pumpScreen(tester, const Size(390, 844), rule: rule);
      expect(
        find.byKey(const ValueKey('protected-branch-push-role-edit')),
        findsNothing,
      );
    });
  }

  for (final code in ['en', 'ko', 'ja', 'hi', 'zh']) {
    testWidgets('push role dialog uses locale $code', (tester) async {
      await _pumpScreen(
        tester,
        const Size(390, 844),
        locale: Locale(code),
        brightness: Brightness.dark,
      );
      await tester.tap(
        find.byKey(const ValueKey('protected-branch-push-role-edit')),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AlertDialog)),
      );
      expect(find.text(l10n.protectedBranchPushRoleEditTitle), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
