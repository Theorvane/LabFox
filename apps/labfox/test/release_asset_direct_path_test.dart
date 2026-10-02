import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/core/ui/link_opener.dart';
import 'package:labfox/features/releases/data/releases_repository.dart';
import 'package:labfox/features/releases/presentation/controllers/releases_controller.dart';
import 'package:labfox/features/releases/presentation/release_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Repository extends ReleasesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  GitLabRelease current = const GitLabRelease(
    name: 'Version 1',
    tagName: 'release/1',
    assets: ReleaseAssets(
      links: [
        ReleaseAssetLink(
          id: 12,
          name: 'Package',
          url: 'https://example.com/app.zip',
          directAssetUrl: 'https://example.com/old-download',
          linkType: 'package',
        ),
      ],
    ),
  );
  final paths = <String?>[];
  bool reject = false;
  @override
  Future<GitLabRelease> get(int projectId, String tagName) async => current;
  @override
  Future<ReleaseAssetLink> updateAssetLink(
    int projectId,
    String tagName,
    int linkId, {
    required String name,
    required String url,
    String? directAssetPath,
    String? linkType,
  }) async {
    expect(projectId, 7);
    expect(tagName, 'release/1');
    expect(linkId, 12);
    expect(url, 'https://example.com/app.zip');
    paths.add(directAssetPath);
    if (reject) throw const GitLabForbiddenException('Forbidden');
    final previous = current.assets!.links.single;
    final link = previous.copyWith(
      name: name,
      url: url,
      linkType: linkType ?? previous.linkType,
      directAssetUrl: directAssetPath == null
          ? previous.directAssetUrl
          : 'https://example.com/downloads$directAssetPath',
    );
    current = current.copyWith(assets: current.assets!.copyWith(links: [link]));
    return link;
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  Brightness brightness = Brightness.light,
  List<Uri>? opened,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/releases/release%2F1',
    routes: [
      GoRoute(
        path: '/projects/:id/releases/:tagName',
        builder: (_, _) =>
            const ReleaseDetailScreen(projectId: 7, tagName: 'release/1'),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        releasesRepositoryProvider.overrideWith((ref) async => repository),
        if (opened != null)
          linkOpenerProvider.overrideWithValue((uri) async => opened.add(uri)),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Edit asset link'));
  await tester.pumpAndSettle();
}

Finder get _pathField =>
    find.widgetWithText(TextField, 'New direct download path (optional)');

void main() {
  testWidgets('saves path and type together without dropping either field', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.enterText(_pathField, '/bin/new.zip');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Image').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save link'));
    await tester.pumpAndSettle();
    expect(repository.paths, ['/bin/new.zip']);
    expect(repository.current.assets!.links.single.linkType, 'image');
    expect(
      repository.current.assets!.links.single.directAssetUrl,
      'https://example.com/downloads/bin/new.zip',
    );
  });
  for (final width in [320.0, 390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('changes direct path at $width in $brightness', (
        tester,
      ) async {
        final repository = _Repository();
        final opened = <Uri>[];
        await _pump(
          tester,
          repository,
          width: width,
          brightness: brightness,
          opened: opened,
        );
        expect(_pathField, findsOneWidget);
        expect(tester.widget<TextField>(_pathField).controller!.text, isEmpty);
        await tester.enterText(_pathField, ' /bin/new.zip ');
        await tester.tap(find.text('Save link'));
        await tester.pumpAndSettle();
        expect(repository.paths, ['/bin/new.zip']);
        expect(
          repository.current.assets!.links.single.directAssetUrl,
          'https://example.com/downloads/bin/new.zip',
        );
        expect(repository.current.assets!.links.single.linkType, 'package');
        expect(find.byType(AlertDialog), findsNothing);
        await tester.tap(find.text('Package'));
        await tester.pumpAndSettle();
        expect(opened, [
          Uri.parse('https://example.com/downloads/bin/new.zip'),
        ]);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('blank path preserves existing download URL on rename', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    expect(_pathField, findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'New package');
    await tester.enterText(_pathField, ' ');
    await tester.tap(find.text('Save link'));
    await tester.pumpAndSettle();
    expect(repository.paths, [null]);
    expect(
      repository.current.assets!.links.single.directAssetUrl,
      'https://example.com/old-download',
    );
    expect(find.text('New package'), findsOneWidget);
  });
  testWidgets('invalid paths do not submit and rejected drafts remain', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    for (final value in [
      'relative.zip',
      'https://example.com/file',
      '//host/file',
      '/bin/file?query',
      '/bin/file#fragment',
    ]) {
      await tester.enterText(_pathField, value);
      await tester.tap(find.text('Save link'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Enter a path starting with /, without a host, query, or fragment.',
        ),
        findsOneWidget,
      );
      expect(repository.paths, isEmpty);
    }
    await tester.enterText(_pathField, '/bin/new.zip');
    await tester.tap(find.text('Save link'));
    await tester.pumpAndSettle();
    expect(find.text('Could not update the asset link.'), findsOneWidget);
    expect(
      tester.widget<TextField>(_pathField).controller!.text,
      '/bin/new.zip',
    );
    expect(
      repository.current.assets!.links.single.directAssetUrl,
      'https://example.com/old-download',
    );
  });
  testWidgets('cancel does not change download path', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.enterText(_pathField, '/bin/new.zip');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.paths, isEmpty);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
