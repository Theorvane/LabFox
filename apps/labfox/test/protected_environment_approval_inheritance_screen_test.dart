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
      accessLevel: 40,
      description: 'Maintainers',
    ),
  ],
  approvalRules: [
    ProtectedEnvironmentAccess(
      id: 38,
      groupId: 134,
      groupInheritanceType: 0,
      requiredApprovals: 2,
      description: 'Release team',
    ),
    ProtectedEnvironmentAccess(
      id: 39,
      userId: 5,
      requiredApprovals: 1,
      description: 'Release manager',
    ),
    ProtectedEnvironmentAccess(
      id: 40,
      groupId: 135,
      groupInheritanceType: 1,
      requiredApprovals: 1,
      description: 'Security team',
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
  ProtectedEnvironment? inspected;
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
  Future<ProtectedEnvironment> getForApprovalGroupEdit(
    int projectId,
    String name,
  ) async {
    reads++;
    if (readFailure != null) throw readFailure!;
    return inspected ?? detail;
  }

  @override
  Future<ProtectedEnvironment> editApprovalGroupInheritance(
    int projectId,
    String name, {
    required int ruleId,
    required int groupInheritanceType,
  }) async {
    writes++;
    await writeGate?.future;
    detail = detail.copyWith(
      approvalRules: [
        for (final rule in detail.approvalRules)
          rule.id == ruleId
              ? rule.copyWith(groupInheritanceType: groupInheritanceType)
              : rule,
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
    find.byKey(ValueKey('protected-environment-approval-inheritance-$suffix'));
Future<void> _open(WidgetTester tester) async {
  await tester.ensureVisible(_key('open'));
  await tester.pumpAndSettle();
  await tester.tap(_key('open'));
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester, {int membership = 1}) async {
  await tester.ensureVisible(_key('rule-38'));
  await tester.pumpAndSettle();
  await tester.tap(_key('rule-38'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(_key('membership-$membership'));
  await tester.pumpAndSettle();
  await tester.tap(_key('membership-$membership'));
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
        testWidgets('edits group membership $language $width $brightness', (
          tester,
        ) async {
          final membership = brightness == Brightness.light ? 1 : 0;
          final expected = _rule.copyWith(
            approvalRules: [
              _rule.approvalRules.first.copyWith(
                groupInheritanceType: 1 - membership,
              ),
              ..._rule.approvalRules.skip(1),
            ],
          );
          final repository = _Repository()..detail = expected;
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
          expect(_key('rule-39'), findsNothing);
          await _confirm(tester, membership: membership);
          await tester.tap(_key('save'));
          await tester.pumpAndSettle();
          expect(repository.writes, 1);
          expect(repository.reads, 3);
          expect(
            repository.detail,
            expected.copyWith(
              approvalRules: [
                expected.approvalRules.first.copyWith(
                  groupInheritanceType: membership,
                ),
                ...expected.approvalRules.skip(1),
              ],
            ),
          );
          expect(find.byType(AlertDialog), findsNothing);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets(
    'unchanged membership and wrong name cannot save; rule changes reset consent',
    (tester) async {
      await _pump(tester, _Repository());
      await _open(tester);
      await tester.tap(_key('rule-38'));
      await tester.pumpAndSettle();
      await tester.enterText(_key('name'), 'review/production');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
      expect(tester.widget<ChoiceChip>(_key('membership-0')).selected, isTrue);
      await _confirm(tester);
      await tester.enterText(_key('name'), 'production');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
      await _confirm(tester);
      await tester.ensureVisible(_key('rule-40'));
      await tester.pumpAndSettle();
      await tester.tap(_key('rule-40'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
    },
  );
  testWidgets('unknown membership from strict inspection is not editable', (
    tester,
  ) async {
    final repository = _Repository()
      ..inspected = _rule.copyWith(
        approvalRules: [
          _rule.approvalRules.first.copyWith(groupInheritanceType: null),
        ],
      );
    await _pump(tester, repository);
    await _open(tester);
    expect(find.byType(RadioListTile<int>), findsNothing);
    expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
    expect(repository.writes, 0);
  });
  testWidgets(
    'uncertain applied write requires inspection and new changed choice',
    (tester) async {
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
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
      await tester.ensureVisible(_key('rule-38'));
      await tester.pumpAndSettle();
      await tester.tap(_key('rule-38'));
      await tester.pumpAndSettle();
      expect(tester.widget<ChoiceChip>(_key('membership-1')).selected, isTrue);
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
    },
  );
  testWidgets('group-level and unknown-only rules expose no edit action', (
    tester,
  ) async {
    await _pump(tester, _Repository(), group: true);
    expect(_key('open'), findsNothing);
    await _pump(
      tester,
      _Repository()
        ..detail = _rule.copyWith(
          approvalRules: [
            _rule.approvalRules.first.copyWith(groupInheritanceType: null),
          ],
        ),
    );
    expect(_key('open'), findsNothing);
  });
  testWidgets('failed inspection cannot authorize editing', (tester) async {
    final repository = _Repository()
      ..readFailure = const GitLabForbiddenException('Unavailable');
    await _pump(tester, repository);
    await _open(tester);
    expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
    expect(repository.writes, 0);
  });
  testWidgets('account replacement locks open membership confirmation', (
    tester,
  ) async {
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
  testWidgets(
    'pending membership writes block input dismissal and duplicate writes',
    (tester) async {
      final repository = _Repository()..writeGate = Completer<void>();
      await _pump(tester, repository);
      await _open(tester);
      await _confirm(tester);
      await tester.tap(_key('save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(repository.writes, 1);
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
      expect(tester.widget<TextField>(_key('name')).readOnly, isTrue);
      expect(
        tester.widget<PopScope>(find.byType(PopScope).last).canPop,
        isFalse,
      );
      repository.writeGate!.complete();
      await tester.pumpAndSettle();
      expect(repository.writes, 1);
    },
  );
}
