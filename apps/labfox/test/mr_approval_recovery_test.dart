import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/core/entitlement/entitlement.dart';
import 'package:labfox/core/entitlement/entitlement_providers.dart';
import 'package:labfox/features/merge_requests/data/mr_actions_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_actions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/widgets/mr_actions.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _key = MergeRequestRef(projectId: 8, iid: 142);
const _mr = MergeRequest(
  id: 900,
  iid: 142,
  title: 'Review',
  state: 'opened',
  sourceBranch: 'feature',
  targetBranch: 'dev',
);

class _Entitlement extends EntitlementController {
  @override
  Entitlement build() => Entitlement.subscribed;
}

class _Analytics implements Analytics {
  @override
  Future<void> track(String name, [Map<String, Object?>? properties]) async {}
}

class _Repository extends MrActionsRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final reads = <(int, int)>[];
  final writes = <String>[];
  Completer<MergeRequestApprovals?>? pending;
  Completer<void>? pendingWrite;
  GitLabException? error;
  bool approved = false;
  bool unavailable = false;
  @override
  Future<MergeRequestApprovals?> approvals({
    required int projectId,
    required int iid,
  }) async {
    reads.add((projectId, iid));
    if (pending != null) return pending!.future;
    if (error != null) throw error!;
    return unavailable
        ? null
        : MergeRequestApprovals(
            approvalsRequired: 1,
            userHasApproved: approved,
            approvedBy: const [],
          );
  }

  @override
  Future<void> approve({required int projectId, required int iid}) async {
    writes.add('approve');
    if (pendingWrite != null) await pendingWrite!.future;
    approved = true;
  }

  @override
  Future<void> unapprove({required int projectId, required int iid}) async {
    writes.add('unapprove');
    approved = false;
  }
}

Future<AppLocalizations> _pump(
  WidgetTester tester,
  _Repository repo, {
  double width = 390,
  bool dark = false,
  Locale locale = const Locale('en'),
  bool settle = true,
  MergeRequest mr = _mr,
  ThemeData? theme,
  int projectId = 8,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mrActionsRepositoryProvider.overrideWith((ref) async => repo),
        entitlementProvider.overrideWith(_Entitlement.new),
        analyticsProvider.overrideWithValue(_Analytics()),
      ],
      child: MaterialApp(
        theme:
            theme ??
            ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppBar(title: const Text('!142')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: MrActions(mr: mr, projectId: projectId),
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
  return AppLocalizations.of(tester.element(find.byType(MrActions)));
}

OutlinedButton _approval(WidgetTester tester) =>
    tester.widget<OutlinedButton>(find.byType(OutlinedButton).first);
void main() {
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('approval recovery $locale $width dark=$dark', (
          tester,
        ) async {
          final repo = _Repository()..pending = Completer();
          final pending = repo.pending!;
          final l10n = await _pump(
            tester,
            repo,
            width: width,
            dark: dark,
            locale: Locale(locale),
            settle: false,
          );
          expect(find.text(l10n.mrApprovalStatusLoading), findsOneWidget);
          expect(_approval(tester).onPressed, isNull);
          expect(
            tester
                .widget<FilledButton>(
                  find
                      .byWidgetPredicate((widget) => widget is FilledButton)
                      .first,
                )
                .onPressed,
            isNotNull,
          );
          pending.completeError(
            const GitLabForbiddenException('Private server text'),
          );
          await tester.pumpAndSettle();
          expect(find.text(l10n.mrApprovalStatusError), findsOneWidget);
          expect(find.text('Private server text'), findsNothing);
          expect(_approval(tester).onPressed, isNull);
          tester.view.physicalSize = Size(width == 320 ? 1200 : 320, 1000);
          await tester.pumpAndSettle();
          repo.pending = null;
          repo.approved = true;
          await tester.tap(find.byKey(const ValueKey('mr-approvals-retry')));
          await tester.pumpAndSettle();
          expect(repo.reads, [(8, 142), (8, 142)]);
          expect(repo.writes, isEmpty);
          expect(find.text(l10n.mrUnapprove), findsOneWidget);
          await tester.tap(
            find.widgetWithText(OutlinedButton, l10n.mrUnapprove),
          );
          await tester.pumpAndSettle();
          expect(repo.writes, ['unapprove']);
          expect(find.text(l10n.mrApprove), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets(
    'unavailable approval endpoint retains compatible approve action',
    (tester) async {
      final repo = _Repository()..unavailable = true;
      final l10n = await _pump(tester, repo);
      expect(_approval(tester).onPressed, isNotNull);
      expect(find.text(l10n.mrApprovalStatusError), findsNothing);
      await tester.tap(find.widgetWithText(OutlinedButton, l10n.mrApprove));
      await tester.pumpAndSettle();
      expect(repo.writes, ['approve']);
    },
  );
  testWidgets(
    'retained approval data is disabled during refresh and replaced by the new result',
    (tester) async {
      final repo = _Repository()..approved = true;
      final l10n = await _pump(tester, repo);
      final c = ProviderScope.containerOf(
        tester.element(find.byType(MrActions)),
      );
      repo.pending = Completer();
      final pending = repo.pending!;
      c.invalidate(mrApprovalsProvider(_key));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_approval(tester).onPressed, isNull);
      expect(find.text(l10n.mrApprovalStatusLoading), findsOneWidget);
      pending.complete(
        const MergeRequestApprovals(
          approvalsRequired: 1,
          userHasApproved: false,
          approvedBy: [],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(l10n.mrApprove), findsOneWidget);
    },
  );
  testWidgets('failed read retry remains disabled during an active mutation', (
    tester,
  ) async {
    final repo = _Repository()
      ..error = const GitLabForbiddenException('Private');
    await _pump(tester, repo);
    repo.pendingWrite = Completer();
    final pending = repo.pendingWrite!;
    final c = ProviderScope.containerOf(tester.element(find.byType(MrActions)));
    final action = c.read(mrActionsControllerProvider(_key).notifier).approve();
    await tester.pump();
    final retry = find.byKey(const ValueKey('mr-approvals-retry'));
    expect(tester.widget<TextButton>(retry).onPressed, isNull);
    pending.complete();
    await action;
    await tester.pumpAndSettle();
    expect(tester.widget<TextButton>(retry).onPressed, isNotNull);
  });
  for (final staleError in [false, true]) {
    testWidgets(
      'replaced account ignores old approval read error=$staleError',
      (tester) async {
        final repo = _Repository()..pending = Completer();
        final old = repo.pending!;
        final l10n = await _pump(tester, repo, settle: false);
        final c = ProviderScope.containerOf(
          tester.element(find.byType(MrActions)),
        );
        final next = _Repository()..approved = true;
        c.updateOverrides([
          mrActionsRepositoryProvider.overrideWith((ref) async => next),
          entitlementProvider.overrideWith(_Entitlement.new),
          analyticsProvider.overrideWithValue(_Analytics()),
        ]);
        c.invalidate(mrActionsRepositoryProvider);
        await tester.pumpAndSettle();
        if (staleError) {
          old.completeError(const GitLabForbiddenException('Previous account'));
        } else {
          old.complete(
            const MergeRequestApprovals(
              approvalsRequired: 1,
              userHasApproved: false,
              approvedBy: [],
            ),
          );
        }
        await tester.pumpAndSettle();
        expect(find.text(l10n.mrUnapprove), findsOneWidget);
        expect(find.text(l10n.mrApprovalStatusError), findsNothing);
        expect(next.writes, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('changing project and iid keeps the new approval state', (
    tester,
  ) async {
    final repo = _Repository()..pending = Completer();
    final old = repo.pending!;
    final l10n = await _pump(tester, repo, settle: false);
    repo.pending = null;
    repo.approved = true;
    await _pump(tester, repo, projectId: 9, mr: _mr.copyWith(iid: 143));
    old.complete(
      const MergeRequestApprovals(
        approvalsRequired: 1,
        userHasApproved: false,
        approvedBy: [],
      ),
    );
    await tester.pumpAndSettle();
    expect(repo.reads, [(8, 142), (9, 143)]);
    expect(find.text(l10n.mrUnapprove), findsOneWidget);
  });
  for (final state in ['closed', 'merged']) {
    testWidgets('$state merge request exposes no action or retry', (
      tester,
    ) async {
      await _pump(tester, _Repository(), mr: _mr.copyWith(state: state));
      expect(find.byKey(const ValueKey('mr-approvals-retry')), findsNothing);
      expect(
        find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
        findsNothing,
      );
    });
  }
}
