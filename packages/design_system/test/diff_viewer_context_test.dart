import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';

FileDiff _file() => FileDiff(
  oldPath: 'old.dart',
  newPath: 'new.dart',
  isNew: false,
  isDeleted: false,
  isRenamed: true,
  diff:
      '@@ -1,1 +1,1 @@\n earlier hunk\n@@ -27,2 +29,2 @@\n context line\n-old line\n+new line\n',
);
void main() {
  for (final dark in [false, true]) {
    for (final type in DiffLineType.values) {
      testWidgets('highlights $type with an accessible marker in dark=$dark', (
        tester,
      ) async {
        final file = _file();
        final line = file.hunks.last.lines.firstWhere(
          (line) => line.type == type,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? LabFoxTheme.dark : LabFoxTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: DiffViewer(
                  file: file,
                  highlightedLine: line,
                  highlightedLineLabel: 'Commented line',
                  focusOnHighlightedLine: true,
                ),
              ),
            ),
          ),
        );
        expect(find.textContaining('earlier hunk'), findsNothing);
        expect(find.textContaining(line.text), findsOneWidget);
        expect(find.byIcon(LabFoxIcons.comment), findsOneWidget);
        final marked = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Commented line' &&
              widget.properties.selected == true,
        );
        expect(marked, findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('highlighting without focus retains all hunks', (tester) async {
    final file = _file();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiffViewer(
            file: file,
            highlightedLine: file.hunks.last.lines.first,
            highlightedLineLabel: 'Commented line',
          ),
        ),
      ),
    );
    expect(find.textContaining('earlier hunk'), findsOneWidget);
    expect(find.textContaining('context line'), findsOneWidget);
    expect(find.byIcon(LabFoxIcons.comment), findsOneWidget);
  });
  testWidgets('a foreign line neither hides hunks nor fabricates a marker', (
    tester,
  ) async {
    final file = _file();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiffViewer(
            file: file,
            highlightedLine: const DiffLine(
              type: DiffLineType.added,
              text: 'foreign',
              newLine: 30,
            ),
            highlightedLineLabel: 'Commented line',
            focusOnHighlightedLine: true,
          ),
        ),
      ),
    );
    expect(find.textContaining('earlier hunk'), findsOneWidget);
    expect(find.textContaining('context line'), findsOneWidget);
    expect(find.byIcon(LabFoxIcons.comment), findsNothing);
  });
}
