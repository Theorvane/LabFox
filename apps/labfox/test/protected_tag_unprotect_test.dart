import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/protected_tags/data/protected_tags_repository.dart';
import 'package:labfox/features/protected_tags/presentation/controllers/protected_tags_controller.dart';
import 'package:labfox/features/protected_tags/presentation/protected_tag_detail_screen.dart';
import 'package:labfox/features/protected_tags/presentation/protected_tags_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

const unprotectRule = ProtectedTag(
  name: 'release/*',
  createAccessLevels: [
    ProtectedBranchAccess(id: 1, accessLevel: 40, description: 'Maintainers'),
    ProtectedBranchAccess(id: 2, userId: 9, description: 'Release user'),
    ProtectedBranchAccess(id: 3, groupId: 20, description: 'Release team'),
    ProtectedBranchAccess(id: 4, deployKeyId: 30, description: 'Deploy key'),
  ],
);

class UnprotectRepository extends ProtectedTagsRepository {
  UnprotectRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  ProtectedTag rule = unprotectRule;
  bool removed = false;
  int reads = 0;
  int lists = 0;
  int deletes = 0;
  Object? failure;
  Object? readFailure;
  Completer<void>? pendingRead;
  Completer<void>? pendingDelete;
  @override
  Future<ProtectedTag> get(int projectId, String name) async {
    reads++;
    if (pendingRead != null) await pendingRead!.future;
    if (readFailure != null) throw readFailure!;
    if (removed) throw const GitLabNotFoundException('private');
    return rule;
  }

  @override
  Future<Paginated<ProtectedTag>> list(int projectId, {int page = 1}) async {
    lists++;
    return Paginated(items: removed ? [] : [rule]);
  }

  @override
  Future<void> unprotect(int projectId, String name) async {
    expect(projectId, 7);
    expect(name, 'release/*');
    deletes++;
    if (pendingDelete != null) await pendingDelete!.future;
    if (failure != null) throw failure!;
    removed = true;
  }
}

Future<void> pumpUnprotect(
  WidgetTester tester,
  UnprotectRepository repository, {
  double width = 390,
  bool dark = false,
  String locale = 'en',
}) async {
  tester.view.physicalSize = Size(width, 950);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/protected_tags/release%2F*',
    routes: [
      GoRoute(
        path: '/projects/:id/protected_tags',
        builder: (_, state) => const ProtectedTagsScreen(projectId: 7),
        routes: [
          GoRoute(
            path: ':name',
            builder: (_, state) => ProtectedTagDetailScreen(
              projectId: 7,
              name: state.pathParameters['name']!,
            ),
          ),
        ],
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

Future<void> openUnprotect(WidgetTester tester) async {
  final entry = find.byKey(const ValueKey('protected-tag-unprotect'));
  expect(entry, findsOneWidget);
  await tester.ensureVisible(entry);
  await tester.tap(entry);
  await tester.pumpAndSettle();
}

Future<void> confirmUnprotect(
  WidgetTester tester, {
  String text = 'release/*',
}) async {
  final field = find.byKey(const ValueKey('protected-tag-unprotect-name'));
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pumpAndSettle();
  final ack = find.byType(CheckboxListTile);
  await tester.ensureVisible(ack);
  await tester.tap(ack);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'exact confirmation unprotects and navigates to refreshed rules',
    (tester) async {
      final repository = UnprotectRepository();
      await pumpUnprotect(tester, repository);
      await openUnprotect(tester);
      expect(repository.deletes, 0);
      expect(find.textContaining('Project 7'), findsOneWidget);
      await confirmUnprotect(tester, text: 'release/* ');
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('protected-tag-unprotect-save')),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(
        find.byKey(const ValueKey('protected-tag-unprotect-name')),
        'release/*',
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('protected-tag-unprotect-save')),
      );
      await tester.pumpAndSettle();
      expect(repository.deletes, 1);
      expect(find.byType(ProtectedTagsScreen), findsOneWidget);
      expect(find.text('No protected tag rules found.'), findsOneWidget);
    },
  );
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('unprotection confirmation fits $width dark=$dark', (
        tester,
      ) async {
        final repository = UnprotectRepository();
        await pumpUnprotect(tester, repository, width: width, dark: dark);
        await openUnprotect(tester);
        expect(find.textContaining('Project 7'), findsOneWidget);
        expect(find.textContaining('Release user'), findsWidgets);
        expect(find.textContaining('Release team'), findsWidgets);
        expect(find.textContaining('Deploy key'), findsWidgets);
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const ValueKey('protected-tag-unprotect-save')),
              )
              .onPressed,
          isNull,
        );
        await confirmUnprotect(tester);
        expect(repository.deletes, 0);
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    testWidgets('unprotection confirmation is localized $locale', (
      tester,
    ) async {
      final repository = UnprotectRepository();
      await pumpUnprotect(tester, repository, width: 320, locale: locale);
      await openUnprotect(tester);
      await confirmUnprotect(tester);
      expect(repository.deletes, 0);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'changed permissions block deletion until reload and renewed confirmation',
    (tester) async {
      final repository = UnprotectRepository();
      await pumpUnprotect(tester, repository);
      await openUnprotect(tester);
      await confirmUnprotect(tester);
      repository.rule = unprotectRule.copyWith(
        createAccessLevels: [
          const ProtectedBranchAccess(
            accessLevel: 30,
            description: 'Developers',
          ),
        ],
      );
      await tester.tap(
        find.byKey(const ValueKey('protected-tag-unprotect-save')),
      );
      await tester.pumpAndSettle();
      expect(repository.deletes, 0);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('protected-tag-unprotect-save')),
            )
            .onPressed,
        isNull,
      );
      expect(find.text('Developers'), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey('protected-tag-unprotect-reload')),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Developers'), findsWidgets);
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
      await confirmUnprotect(tester);
      await tester.tap(
        find.byKey(const ValueKey('protected-tag-unprotect-save')),
      );
      await tester.pumpAndSettle();
      expect(repository.deletes, 1);
    },
  );
  for (final error in [
    const GitLabConnectionException('private server details'),
    const GitLabForbiddenException('private server details'),
  ]) {
    testWidgets('failure requires reload and hides private details $error', (
      tester,
    ) async {
      final repository = UnprotectRepository()..failure = error;
      await pumpUnprotect(tester, repository);
      await openUnprotect(tester);
      await confirmUnprotect(tester);
      await tester.tap(
        find.byKey(const ValueKey('protected-tag-unprotect-save')),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('private server'), findsNothing);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('protected-tag-unprotect-save')),
            )
            .onPressed,
        isNull,
      );
      expect(repository.deletes, 1);
      repository.failure = null;
      await tester.tap(
        find.byKey(const ValueKey('protected-tag-unprotect-reload')),
      );
      await tester.pumpAndSettle();
      await confirmUnprotect(tester);
      await tester.tap(
        find.byKey(const ValueKey('protected-tag-unprotect-save')),
      );
      await tester.pumpAndSettle();
      expect(repository.deletes, 2);
    });
  }
  testWidgets('missing rule after uncertain failure cannot be deleted again', (
    tester,
  ) async {
    final repository = UnprotectRepository()
      ..failure = const GitLabConnectionException('private');
    await pumpUnprotect(tester, repository);
    await openUnprotect(tester);
    await confirmUnprotect(tester);
    await tester.tap(
      find.byKey(const ValueKey('protected-tag-unprotect-save')),
    );
    await tester.pumpAndSettle();
    repository.removed = true;
    await tester.tap(
      find.byKey(const ValueKey('protected-tag-unprotect-reload')),
    );
    await tester.pumpAndSettle();
    expect(repository.deletes, 1);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('protected-tag-unprotect-save')),
          )
          .onPressed,
      isNull,
    );
  });
  testWidgets(
    'pending deletion locks edit, dismissal, and duplicate dispatch',
    (tester) async {
      final repository = UnprotectRepository()
        ..pendingDelete = Completer<void>();
      await pumpUnprotect(tester, repository);
      await openUnprotect(tester);
      await confirmUnprotect(tester);
      await tester.tap(
        find.byKey(const ValueKey('protected-tag-unprotect-save')),
      );
      await tester.pump();
      expect(repository.deletes, 1);
      expect(
        tester
            .widget<CheckboxListTile>(find.byType(CheckboxListTile))
            .onChanged,
        isNull,
      );
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('protected-tag-unprotect-name')),
            )
            .readOnly,
        isTrue,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('protected-tag-unprotect-save')),
            )
            .onPressed,
        isNull,
      );
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(
        find.byKey(const ValueKey('protected-tag-unprotect-name')),
        findsOneWidget,
      );
      repository.pendingDelete!.complete();
      await tester.pumpAndSettle();
    },
  );
  testWidgets('account change locks confirmed dialog and permits close', (
    tester,
  ) async {
    final repository = UnprotectRepository();
    await pumpUnprotect(tester, repository);
    await openUnprotect(tester);
    await confirmUnprotect(tester);
    final container = ProviderScope.containerOf(
      tester.element(
        find.byKey(const ValueKey('protected-tag-unprotect-name')),
      ),
    );
    container.invalidate(protectedTagsRepositoryProvider);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('protected-tag-unprotect-save')),
          )
          .onPressed,
      isNull,
    );
    expect(repository.deletes, 0);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('protected-tag-unprotect-name')),
      findsNothing,
    );
  });
}
