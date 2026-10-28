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
  Future<Paginated<ProjectMember>> build(MemberListRef arg) async {
    expect(arg.groupId, 7);
    return Paginated(
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
}

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [projectMembersControllerProvider.overrideWith(_List.new)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GroupMembersScreen(groupId: 7),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows effective group members and searches on mobile', (
    tester,
  ) async {
    await _pump(tester, const Size(390, 844));
    expect(find.text('Group members'), findsOneWidget);
    expect(find.text('Alex Smith'), findsOneWidget);
    expect(find.text('Developer'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('No group members found.'), findsOneWidget);
  });

  testWidgets('shows role beside identity on wide screens', (tester) async {
    await _pump(tester, const Size(1200, 800));
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('Developer')).dx,
      greaterThan(tester.getTopLeft(find.text('Alex Smith')).dx + 150),
    );
  });
}
