import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
      description: 'Release team',
      requiredApprovals: 2,
    ),
    ProtectedEnvironmentAccess(
      id: 39,
      userId: 5,
      description: 'Release manager',
      requiredApprovals: 1,
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
  int? selectedId;
  int? selectedCount;

  @override
  Future<Paginated<ProtectedEnvironment>> list(
    int projectId, {
    int page = 1,
  }) async => Paginated(items: [detail]);

  @override
  Future<ProtectedEnvironment> getComplete(int projectId, String name) async {
    reads++;
    return detail;
  }

  @override
  Future<void> editApprovalCount(
    int projectId,
    String name, {
    required int ruleId,
    required int requiredApprovals,
  }) async {
    writes++;
    selectedId = ruleId;
    selectedCount = requiredApprovals;
    detail = detail.copyWith(
      approvalRules: [
        for (final rule in detail.approvalRules)
          rule.id == ruleId
              ? rule.copyWith(requiredApprovals: requiredApprovals)
              : rule,
      ],
    );
    if (uncertain) throw const GitLabServerException('Unconfirmed write');
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
    find.byKey(ValueKey('protected-environment-approval-count-$suffix'));

Future<void> _open(WidgetTester tester) async {
  await tester.ensureVisible(_key('open'));
  await tester.pumpAndSettle();
  await tester.tap(_key('open'));
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.ensureVisible(_key('rule-38'));
  await tester.pumpAndSettle();
  await tester.tap(_key('rule-38'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(_key('count-3'));
  await tester.pumpAndSettle();
  await tester.tap(_key('count-3'));
  await tester.enterText(_key('name'), 'review/production');
  await tester.ensureVisible(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'long approval rule labels do not hide identity or current count',
    (tester) async {
      final repository = _Repository()
        ..detail = _rule.copyWith(
          approvalRules: [
            _rule.approvalRules.first.copyWith(
              description: List.filled(8, 'Release approval team').join(' '),
            ),
          ],
        );
      await _pump(tester, repository, size: const Size(320, 720));
      await _open(tester);
      final label = find.descendant(
        of: _key('rule-38'),
        matching: find.byType(Text),
      );
      final paragraph = tester.renderObject<RenderParagraph>(label);
      final length = paragraph.text.toPlainText().length;
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: length - 1, extentOffset: length),
      );
      expect(boxes, isNotEmpty);
      expect(boxes.last.right, lessThanOrEqualTo(paragraph.size.width + 1));
      expect(boxes.last.bottom, lessThanOrEqualTo(paragraph.size.height + 1));
      expect(tester.takeException(), isNull);
    },
  );

  for (final language in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final size in [const Size(320, 720), const Size(1200, 800)]) {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        testWidgets(
          'changes selected rule count $language ${size.width} $brightness',
          (tester) async {
            final repository = _Repository();
            await _pump(
              tester,
              repository,
              size: size,
              language: language,
              brightness: brightness,
            );
            await _open(tester);
            expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
            await _confirm(tester);
            expect(
              tester.widget<FilledButton>(_key('save')).onPressed,
              isNotNull,
            );
            await tester.tap(_key('save'));
            await tester.pumpAndSettle();
            expect(repository.writes, 1);
            expect(repository.selectedId, 38);
            expect(repository.selectedCount, 3);
            expect(
              repository.detail.approvalRules.last,
              _rule.approvalRules.last,
            );
            expect(find.byType(AlertDialog), findsNothing);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('exact name, changed count and renewed consent are required', (
    tester,
  ) async {
    await _pump(tester, _Repository());
    await _open(tester);
    await tester.tap(_key('rule-38'));
    await tester.pumpAndSettle();
    expect(tester.widget<ChoiceChip>(_key('count-2')).onSelected, isNull);
    await tester.tap(_key('count-3'));
    await tester.enterText(_key('name'), 'review/prod');
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
    await tester.enterText(_key('name'), 'review/production');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );
  });

  testWidgets(
    'uncertain write requires read-only reload before another attempt',
    (tester) async {
      final repository = _Repository()..uncertain = true;
      await _pump(tester, repository);
      await _open(tester);
      await _confirm(tester);
      await tester.tap(_key('save'));
      await tester.pumpAndSettle();
      expect(repository.writes, 1);
      expect(repository.reads, 2);
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
      await tester.tap(_key('reload'));
      await tester.pumpAndSettle();
      expect(repository.writes, 1);
      expect(repository.reads, 3);
      expect(tester.widget<FilledButton>(_key('save')).onPressed, isNull);
      expect(tester.widget<TextField>(_key('name')).controller!.text, isEmpty);
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
    },
  );

  testWidgets('account change disables an open confirmation', (tester) async {
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

  testWidgets('group and unreported approval rules remain read-only', (
    tester,
  ) async {
    await _pump(tester, _Repository(), group: true);
    expect(_key('open'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await _pump(
      tester,
      _Repository()
        ..detail = _rule.copyWith(
          approvalRules: [
            const ProtectedEnvironmentAccess(id: 38, groupId: 134),
          ],
        ),
    );
    expect(_key('open'), findsNothing);
  });
}
