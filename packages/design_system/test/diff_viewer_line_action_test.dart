import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';

FileDiff _file() => FileDiff(
  oldPath: 'a',
  newPath: 'a',
  isNew: false,
  isDeleted: false,
  isRenamed: false,
  diff: '@@ -1,2 +1,2 @@\n context\n-old\n+new\n',
);
void main() {
  for (final dark in [false, true]) {
    testWidgets('line actions retain a minimum 44 dp touch target dark=$dark', (
      tester,
    ) async {
      final file = _file();
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? LabFoxTheme.dark : LabFoxTheme.light,
          home: Scaffold(
            body: DiffViewer(
              file: file,
              onLineSelected: (_) {},
              lineActionLabel: 'End range on this line',
            ),
          ),
        ),
      );
      for (final button in find.byType(IconButton).evaluate()) {
        final size = tester.getSize(find.byWidget(button.widget));
        expect(size.width, greaterThanOrEqualTo(44));
        expect(size.height, greaterThanOrEqualTo(44));
      }
    });
  }
  for (final dark in [false, true]) {
    for (final type in DiffLineType.values) {
      testWidgets('selects exact $type line dark=$dark', (tester) async {
        final file = _file();
        final line = file.hunks.single.lines.singleWhere((l) => l.type == type);
        DiffLine? selected;
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? LabFoxTheme.dark : LabFoxTheme.light,
            home: Scaffold(
              body: DiffViewer(
                file: file,
                onLineSelected: (l) => selected = l,
                canSelectLine: (l) => identical(l, line),
                lineActionLabel: 'Add discussion on this line',
              ),
            ),
          ),
        );
        expect(find.byTooltip('Add discussion on this line'), findsOneWidget);
        await tester.tap(find.byTooltip('Add discussion on this line'));
        expect(identical(selected, line), true);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('default and unavailable lines have no action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DiffViewer(file: _file())),
      ),
    );
    expect(find.byType(IconButton), findsNothing);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiffViewer(
            file: _file(),
            onLineSelected: (_) {
              fail('Unavailable line selected');
            },
            canSelectLine: (_) => false,
            lineActionLabel: 'Add discussion on this line',
          ),
        ),
      ),
    );
    expect(find.byType(IconButton), findsNothing);
  });
}
