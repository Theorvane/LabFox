import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/app/router.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/container_immutability_screen.dart';
import 'package:labfox/features/container_registry/presentation/container_registry_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_immutability_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/l10n/app_localizations.dart';

const rule = ContainerTagImmutabilityRule(
  id: 'gid://gitlab/Rule/9',
  tagNamePattern: r'^v\d+.*$',
  immutable: true,
);

class FakeRepository extends ContainerRegistryRepository {
  FakeRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  List<ContainerTagImmutabilityRule> rules = [rule];
  Object? failure;
  Completer<List<ContainerTagImmutabilityRule>>? pending;
  final reads = <int>[];
  @override
  Future<Paginated<RegistryRepository>> repositories(
    int projectId, {
    int page = 1,
  }) async => const Paginated(items: []);
  @override
  Future<List<ContainerTagImmutabilityRule>> immutableTagRules(
    int projectId,
  ) async {
    reads.add(projectId);
    if (pending != null) return pending!.future;
    if (failure != null) throw failure!;
    return rules;
  }
}

Future<void> open(
  WidgetTester tester,
  FakeRepository repository, {
  double width = 390,
  bool dark = false,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
      child: MaterialApp(
        theme: dark ? ThemeData.dark() : ThemeData.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ContainerImmutabilityScreen(projectId: 7),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pending read shows loading rather than an empty result', (
    tester,
  ) async {
    final repository = FakeRepository()
      ..pending = Completer<List<ContainerTagImmutabilityRule>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          containerRegistryRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ContainerImmutabilityScreen(projectId: 7),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No immutable tag rules.'), findsNothing);
    repository.pending!.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('No immutable tag rules.'), findsOneWidget);
  });
  testWidgets('refresh rejection is rendered without an uncaught future', (
    tester,
  ) async {
    final repository = FakeRepository();
    await open(tester, repository);
    repository.failure = const GitLabServerException('private refresh');
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('private'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('registry entry works even without image repositories', (
    tester,
  ) async {
    final repository = FakeRepository();
    final router = GoRouter(
      initialLocation: Routes.containerRegistry(7),
      routes: [
        GoRoute(
          path: '/projects/:id/container_registry',
          builder: (_, _) => const ContainerRegistryScreen(projectId: 7),
          routes: [
            GoRoute(
              path: 'immutable_rules',
              builder: (_, _) =>
                  const ContainerImmutabilityScreen(projectId: 7),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          containerRegistryRepositoryProvider.overrideWith(
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
    await tester.tap(find.byTooltip('Immutable tag rules'));
    await tester.pumpAndSettle();
    expect(find.byType(ContainerImmutabilityScreen), findsOneWidget);
    expect(repository.reads, [7]);
  });
  test('route stores only project ID', () {
    expect(
      Routes.containerImmutability(7),
      '/projects/7/container_registry/immutable_rules',
    );
  });
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('read-only rule fits $width dark=$dark', (tester) async {
        final repository = FakeRepository();
        await open(tester, repository, width: width, dark: dark);
        expect(find.text(rule.tagNamePattern), findsOneWidget);
        expect(find.text('Immutable tag rules'), findsOneWidget);
        expect(find.textContaining('Ultimate'), findsOneWidget);
        expect(find.textContaining('Minimum'), findsNothing);
        expect(find.textContaining('gid://'), findsNothing);
        expect(repository.reads, [7]);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('empty state remains refreshable', (tester) async {
    final repository = FakeRepository()..rules = [];
    await open(tester, repository);
    expect(find.text('No immutable tag rules.'), findsOneWidget);
    repository.rules = [rule];
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(find.text(rule.tagNamePattern), findsOneWidget);
  });
  for (final error in [
    const GitLabForbiddenException('private details'),
    const GitLabNotFoundException('private details'),
    const GitLabServerException('private details'),
  ]) {
    testWidgets('typed failure retries without private data $error', (
      tester,
    ) async {
      final repository = FakeRepository()..failure = error;
      await open(tester, repository);
      expect(find.text('No immutable tag rules.'), findsNothing);
      expect(find.textContaining('private'), findsNothing);
      repository.failure = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text(rule.tagNamePattern), findsOneWidget);
    });
  }
  test('account changes discard an older pending rule read', () async {
    final old = FakeRepository()
      ..pending = Completer<List<ContainerTagImmutabilityRule>>();
    final fresh = FakeRepository()..rules = [];
    final account = StateProvider<FakeRepository>((ref) => old);
    final container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => ref.watch(account),
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = containerImmutabilityControllerProvider(7);
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);
    await Future<void>.delayed(Duration.zero);
    container.read(account.notifier).state = fresh;
    await Future<void>.delayed(Duration.zero);
    expect(await container.read(provider.future), isEmpty);
    old.pending!.complete([rule]);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(provider).requireValue, isEmpty);
  });
  testWidgets('direct route restores by ID and back falls to registry', (
    tester,
  ) async {
    final repository = FakeRepository();
    final router = GoRouter(
      initialLocation: Routes.containerImmutability(7),
      routes: [
        GoRoute(
          path: '/projects/:projectId/container_registry/immutable_rules',
          builder: (context, state) => ContainerImmutabilityScreen(
            projectId: int.parse(state.pathParameters['projectId']!),
          ),
        ),
        GoRoute(
          path: '/projects/:projectId/container_registry',
          builder: (_, _) =>
              const Scaffold(body: Text('Registry test destination')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          containerRegistryRepositoryProvider.overrideWith(
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
    expect(repository.reads, [7]);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Registry test destination'), findsOneWidget);
  });
}
