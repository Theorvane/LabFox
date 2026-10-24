import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';

FileDiff _file() => FileDiff(
  oldPath: 'file.dart',
  newPath: 'file.dart',
  isNew: false,
  isDeleted: false,
  isRenamed: false,
  diff:
      '@@ -1,1 +1,1 @@\n unrelated\n@@ -10,2 +10,2 @@\n first\n second\n@@ -20,1 +20,1 @@\n third\n',
);
void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'each range member has an accessible non-color marker dark=$dark',
      (tester) async {
        final file = _file();
        final selected = [...file.hunks[1].lines, file.hunks[2].lines.single];
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? LabFoxTheme.dark : LabFoxTheme.light,
            home: Scaffold(
              body: DiffViewer(
                file: file,
                highlightedLines: selected,
                highlightedLine: selected.first,
                highlightedLineLabel: 'Line in commented range',
                focusOnHighlightedLine: true,
              ),
            ),
          ),
        );
        expect(find.textContaining('unrelated'), findsNothing);
        expect(find.byIcon(LabFoxIcons.comment), findsNWidgets(3));
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics &&
                w.properties.label == 'Line in commented range' &&
                w.properties.selected == true,
          ),
          findsNWidgets(3),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'foreign and duplicate members never fabricate markers or hide context',
    (tester) async {
      final file = _file();
      const foreign = DiffLine(
        type: DiffLineType.context,
        text: 'foreign',
        oldLine: 10,
        newLine: 10,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiffViewer(
              file: file,
              highlightedLines: [foreign, foreign],
              highlightedLineLabel: 'Range',
              focusOnHighlightedLine: true,
            ),
          ),
        ),
      );
      expect(find.textContaining('unrelated'), findsOneWidget);
      expect(find.byIcon(LabFoxIcons.comment), findsNothing);
    },
  );
  testWidgets('without focus highlighting retains unselected hunks', (
    tester,
  ) async {
    final file = _file();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiffViewer(
            file: file,
            highlightedLines: file.hunks[1].lines,
            highlightedLineLabel: 'Range',
          ),
        ),
      ),
    );
    expect(find.textContaining('unrelated'), findsOneWidget);
    expect(find.textContaining('third'), findsOneWidget);
    expect(find.byIcon(LabFoxIcons.comment), findsNWidgets(2));
  });
}
