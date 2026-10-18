import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_branches/data/protected_branches_repository.dart';
import 'package:labfox/features/protected_branches/presentation/controllers/protected_branches_controller.dart';
import 'package:labfox/features/protected_branches/presentation/protected_branch_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _rule = ProtectedBranch(
  id: 12,
  name: 'release/*',
  pushAccessLevels: [ProtectedBranchAccess(id: 3, accessLevel: 40)],
  mergeAccessLevels: [ProtectedBranchAccess(id: 4, groupId: 8)],
  unprotectAccessLevels: [ProtectedBranchAccess(id: 5, memberRoleId: 7)],
);

class _Repository extends ProtectedBranchesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  ProtectedBranch detail = _rule;
  var writes = 0;
  var strictReads = 0;
  var uncertain = false;
  Object? readFailure;

  @override
  Future<Paginated<ProtectedBranch>> list(
    int projectId, {
    int page = 1,
  }) async => Paginated(items: [detail]);
  @override
  Future<ProtectedBranch> get(int projectId, String name) async => detail;
  @override
  Future<ProtectedBranch> getForCodeOwnerEdit(
    int projectId,
    String name,
  ) async {
    strictReads++;
    if (readFailure != null) throw readFailure!;
    return detail;
  }

  @override
  Future<ProtectedBranch> updateCodeOwnerApproval(
    int projectId,
    String name, {
    required bool codeOwnerApprovalRequired,
  }) async {
    writes++;
    detail = detail.copyWith(
      codeOwnerApprovalRequired: codeOwnerApprovalRequired,
    );
    if (uncertain) throw const GitLabServerException('Uncertain update');
    return detail;
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  Size size = const Size(1200, 800),
  String language = 'en',
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        protectedBranchesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale(language),
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProtectedBranchDetailScreen(
          projectId: 7,
          name: 'release/*',
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _key(String suffix) =>
    find.byKey(ValueKey('protected-branch-code-owner-$suffix'));
Future<void> _open(WidgetTester tester) async {
  await tester.ensureVisible(_key('edit'));
  await tester.pumpAndSettle();
  await tester.tap(_key('edit'));
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(SwitchListTile));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(SwitchListTile));
  await tester.enterText(_key('name'), 'release/*');
  await tester.ensureVisible(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
}

void main() {
  for (final language in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final size in [
      const Size(320, 800),
      const Size(800, 800),
      const Size(1200, 800),
    ]) {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        testWidgets(
          'changes Code Owner requirement $language ${size.width} $brightness',
          (tester) async {
            final wasRequired = brightness == Brightness.dark;
            final repository = _Repository()
              ..detail = _rule.copyWith(codeOwnerApprovalRequired: wasRequired);
            await _pump(
              tester,
              repository,
              size: size,
              language: language,
              brightness: brightness,
            );
            await _open(tester);
            expect(repository.strictReads, 1);
            expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
            expect(
              tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
              wasRequired,
            );
            await _confirm(tester);
            await tester.tap(_key('save'));
            await tester.pumpAndSettle();
            expect(repository.writes, 1);
            expect(repository.strictReads, 3);
            expect(
              repository.detail,
              _rule.copyWith(codeOwnerApprovalRequired: !wasRequired),
            );
            expect(find.byType(AlertDialog), findsNothing);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets(
    'exact name, changed value and renewed acknowledgement are required',
    (tester) async {
      await _pump(tester, _Repository());
      await _open(tester);
      await tester.enterText(_key('name'), 'release');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
      await tester.tap(find.byType(SwitchListTile));
      await tester.enterText(_key('name'), 'release/*');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
    },
  );

  testWidgets(
    'uncertain writes require read-only inspection and new confirmation',
    (tester) async {
      final repository = _Repository()..uncertain = true;
      await _pump(tester, repository);
      await _open(tester);
      await _confirm(tester);
      await tester.tap(_key('save'));
      await tester.pumpAndSettle();
      expect(repository.writes, 1);
      expect(repository.strictReads, 2);
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
      await tester.tap(_key('reload'));
      await tester.pumpAndSettle();
      expect(repository.writes, 1);
      expect(repository.strictReads, 3);
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
      expect(tester.widget<TextField>(_key('name')).controller!.text, isEmpty);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue,
      );
    },
  );

  testWidgets('an unreported Code Owner flag cannot be edited', (tester) async {
    final repository = _Repository()
      ..readFailure = const GitLabServerException('Missing explicit flag');
    await _pump(tester, repository);
    await _open(tester);
    expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
    expect(find.byType(SwitchListTile), findsNothing);
    expect(repository.writes, 0);
  });

  testWidgets('account replacement disables open Code Owner confirmation', (
    tester,
  ) async {
    await _pump(tester, _Repository());
    await _open(tester);
    await _confirm(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AlertDialog)),
      listen: false,
    );
    container.invalidate(protectedBranchesRepositoryProvider);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
    expect(
      find.text(
        'The account changed. Close this dialog and open the rule again.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('inherited rules do not expose Code Owner editing', (
    tester,
  ) async {
    await _pump(
      tester,
      _Repository()..detail = _rule.copyWith(inherited: true),
    );
    expect(_key('edit'), findsNothing);
  });
}
