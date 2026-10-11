import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';

List<DiffHunk> hunks() => FileDiff(
  oldPath: 'a.dart',
  newPath: 'a.dart',
  isNew: false,
  isDeleted: false,
  isRenamed: false,
  diff: '@@ -1,2 +1,2 @@\n same\n-old\n+new\n@@ -10 +10 @@\n distant\n',
).hunks;
void main() {
  for (final width in [320.0, 800.0, 1280.0]) {
    for (final dark in [false, true]) {
      testWidgets('captured rows retain identity $width $dark', (t) async {
        t.view.physicalSize = Size(width, 800);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        final h = hunks();
        final row = h.first.lines.last;
        DiffLine? selected;
        await t.pumpWidget(
          MaterialApp(
            theme: dark ? LabFoxTheme.dark : LabFoxTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: DiffHunksViewer(
                  hunks: h,
                  highlightedLines: [row],
                  highlightedLineLabel: 'Selected',
                  lineActionLabel: 'Select',
                  canSelectLine: (l) => identical(l, row),
                  onLineSelected: (l) => selected = l,
                ),
              ),
            ),
          ),
        );
        expect(find.textContaining('same'), findsOneWidget);
        expect(find.textContaining('distant'), findsOneWidget);
        await t.tap(find.byTooltip('Select'));
        expect(identical(selected, row), true);
        expect(t.takeException(), null);
      });
    }
  }
  testWidgets('focus uses captured identities and ignores foreign equal rows', (
    t,
  ) async {
    final h = hunks();
    final row = h.first.lines.last;
    final foreign = hunks().last.lines.single;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiffHunksViewer(
            hunks: h,
            highlightedLines: [row, row, foreign],
            highlightedLineLabel: 'Selected',
            focusOnHighlightedLine: true,
          ),
        ),
      ),
    );
    expect(find.textContaining('new'), findsOneWidget);
    expect(find.textContaining('distant'), findsNothing);
    expect(find.textContaining('@@ -10'), findsNothing);
  });
  testWidgets('no selection callback means no action even with a label', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiffHunksViewer(hunks: hunks(), lineActionLabel: 'Select'),
        ),
      ),
    );
    expect(find.byTooltip('Select'), findsNothing);
  });
}
