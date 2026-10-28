import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/members/presentation/controllers/members_controller.dart';
import 'package:labfox/features/members/presentation/project_members_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _List extends ProjectMembersController {
  @override
  Future<Paginated<ProjectMember>> build(MemberListRef arg) async => Paginated(
    items: arg.query == 'missing'
        ? []
        : const [
            ProjectMember(
              id: 11,
              name: 'Alex Smith',
              username: 'alex',
              accessLevel: 30,
            ),
          ],
  );
}

Future<void> _pump(WidgetTester tester, {Size? size, bool dark = false}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [projectMembersControllerProvider.overrideWith(_List.new)],
      child: MaterialApp(
        theme: dark ? ThemeData.dark() : ThemeData.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProjectMembersScreen(projectId: 7),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows effective member role and server-side search', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('Alex Smith'), findsOneWidget);
    expect(find.text('Developer'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('No members found.'), findsOneWidget);
  });

  testWidgets('fits a narrow dark screen', (tester) async {
    await _pump(tester, size: const Size(390, 844), dark: true);
    expect(find.text('Alex Smith'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows role beside member identity on wide screens', (
    tester,
  ) async {
    await _pump(tester, size: const Size(1200, 800));
    expect(
      tester.getTopLeft(find.text('Developer')).dx,
      greaterThan(tester.getTopLeft(find.text('Alex Smith')).dx + 150),
    );
  });
}
