import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_environments/data/protected_environments_repository.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environments_controller.dart';
import 'package:labfox/features/protected_environments/presentation/protected_environment_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _rule = ProtectedEnvironment(
  name: 'review/production',
  deployAccessLevels: [
    ProtectedEnvironmentAccess(
      id: 12,
      groupId: 134,
      accessLevel: 40,
      groupInheritanceType: 1,
      description: 'Existing deploy team',
    ),
    ProtectedEnvironmentAccess(
      id: 13,
      userId: 5,
      description: 'Release manager',
    ),
    ProtectedEnvironmentAccess(
      id: 14,
      accessLevel: 30,
      description: 'Developers',
    ),
  ],
  approvalRules: [
    ProtectedEnvironmentAccess(
      id: 38,
      groupId: 135,
      groupInheritanceType: 0,
      requiredApprovals: 2,
      description: 'QA team',
    ),
  ],
);

class _Repository extends ProtectedEnvironmentsRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  ProtectedEnvironment detail = _rule;
  var writes = 0;
  var reads = 0;
  var uncertain = false;
  Object? readFailure;
  Completer<void>? writeGate;
  @override
  Future<Paginated<ProtectedEnvironment>> list(
    int projectId, {
    int page = 1,
  }) async => Paginated(items: [detail]);
  @override
  Future<ProtectedEnvironment> getForDeployGroupEdit(
    int projectId,
    String name,
  ) async {
    reads++;
    if (readFailure != null) throw readFailure!;
    return detail;
  }

  @override
  Future<ProtectedEnvironment> addDeployGroup(
    int projectId,
    String name, {
    required int groupId,
  }) async {
    writes++;
    await writeGate?.future;
    detail = detail.copyWith(
      deployAccessLevels: [
        ...detail.deployAccessLevels,
        ProtectedEnvironmentAccess(
          id: 15,
          groupId: groupId,
          groupInheritanceType: 0,
          accessLevel: 40,
        ),
      ],
    );
    if (uncertain) throw const GitLabServerException('Unconfirmed write');
    return detail;
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  Size size = const Size(1200, 800),
  String language = 'en',
  Brightness brightness = Brightness.light,
  bool group = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        protectedEnvironmentsRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
        protectedEnvironmentDetailProvider.overrideWith(
          (ref, key) async => repository.detail,
        ),
        groupProtectedEnvironmentDetailProvider.overrideWith(
          (ref, key) async => repository.detail,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale(language),
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: group
            ? const ProtectedEnvironmentDetailScreen.group(
                groupId: 5,
                name: 'review/production',
              )
            : const ProtectedEnvironmentDetailScreen(
                projectId: 7,
                name: 'review/production',
              ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _key(String suffix) =>
    find.byKey(ValueKey('protected-environment-deploy-group-$suffix'));
Future<void> _open(WidgetTester tester) async {
  await tester.ensureVisible(_key('open'));
  await tester.pumpAndSettle();
  await tester.tap(_key('open'));
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.enterText(_key('group'), '135');
  await tester.enterText(_key('name'), 'review/production');
  await tester.ensureVisible(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
}

void main() {
  for (final language in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        testWidgets('adds deploy group $language $width $brightness', (
          tester,
        ) async {
          final repository = _Repository();
          await _pump(
            tester,
            repository,
            size: Size(width, 800),
            language: language,
            brightness: brightness,
          );
          await _open(tester);
          expect(repository.reads, 1);
          expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
          await _confirm(tester);
          await tester.tap(_key('save'));
          await tester.pumpAndSettle();
          expect(repository.writes, 1);
          expect(repository.reads, 3);
          expect(repository.detail.deployAccessLevels.last.groupId, 135);
          expect(repository.detail.deployAccessLevels.last.accessLevel, 40);
          expect(
            repository.detail.deployAccessLevels.last.groupInheritanceType,
            0,
          );
          expect(repository.detail.approvalRules, _rule.approvalRules);
          expect(
            repository.detail.deployAccessLevels.first,
            _rule.deployAccessLevels.first,
          );
          expect(find.byType(AlertDialog), findsNothing);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets(
    'invalid or duplicate IDs and changed inputs require fresh consent',
    (tester) async {
      await _pump(tester, _Repository());
      await _open(tester);
      await _confirm(tester);
      for (final value in [
        '0',
        '-1',
        '1.5',
        ' 135',
        '135 ',
        '0135',
        '+135',
        '134',
        '',
      ]) {
        await tester.enterText(_key('group'), value);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();
      }
      await tester.enterText(_key('group'), '135');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNotNull);
      await tester.enterText(_key('group'), '136');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
      await tester.enterText(_key('name'), 'production');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
    },
  );
  testWidgets('uncertain writes require inspection and clear confirmation', (
    tester,
  ) async {
    final repository = _Repository()..uncertain = true;
    await _pump(tester, repository);
    await _open(tester);
    await _confirm(tester);
    await tester.tap(_key('save'));
    await tester.pumpAndSettle();
    expect(repository.writes, 1);
    expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
    await tester.tap(_key('reload'));
    await tester.pumpAndSettle();
    expect(repository.writes, 1);
    expect(tester.widget<TextField>(_key('name')).controller!.text, isEmpty);
    expect(tester.widget<TextField>(_key('group')).controller!.text, isEmpty);
    await _confirm(tester);
    expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
  });
  testWidgets('failed inspection cannot authorize a write', (tester) async {
    final repository = _Repository()
      ..readFailure = const GitLabForbiddenException('Unavailable');
    await _pump(tester, repository);
    await _open(tester);
    expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
    expect(repository.writes, 0);
  });
  testWidgets('group protection remains read-only', (tester) async {
    await _pump(tester, _Repository(), group: true);
    expect(_key('open'), findsNothing);
  });
  testWidgets('account replacement locks confirmation', (tester) async {
    await _pump(tester, _Repository());
    await _open(tester);
    await _confirm(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AlertDialog)),
      listen: false,
    );
    container.invalidate(protectedEnvironmentsRepositoryProvider);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
    expect(
      find.text(
        'The account changed. Close this dialog and open the rule again.',
      ),
      findsOneWidget,
    );
  });
  testWidgets('pending writes block inputs, dismissal and repeat submission', (
    tester,
  ) async {
    final repository = _Repository()..writeGate = Completer<void>();
    await _pump(tester, repository);
    await _open(tester);
    await _confirm(tester);
    await tester.tap(_key('save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(repository.writes, 1);
    expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
    expect(tester.widget<TextField>(_key('group')).readOnly, isTrue);
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).onChanged,
      isNull,
    );
    expect(tester.widget<PopScope>(find.byType(PopScope).last).canPop, isFalse);
    repository.writeGate!.complete();
    await tester.pumpAndSettle();
    expect(repository.writes, 1);
  });
}
