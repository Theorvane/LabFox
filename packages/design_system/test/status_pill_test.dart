import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: LabFoxTheme.light,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('StatusPill', () {
    for (final dark in [false, true]) {
      testWidgets(
        'long status fits a bounded width and retains its full semantic label dark=$dark',
        (tester) async {
          final semantics = tester.ensureSemantics();
          const label = 'Waiting_for_callback';
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? LabFoxTheme.dark : LabFoxTheme.light,
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 160,
                    child: StatusPill(
                      label: label,
                      colors: dark
                          ? LabFoxStatusColors.dark.pending
                          : LabFoxStatusColors.light.pending,
                      dot: true,
                    ),
                  ),
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(tester.getSemantics(find.text(label)).label, label);
          semantics.dispose();
        },
      );
    }

    testWidgets('filled renders the label on the status colour itself', (
      tester,
    ) async {
      const colors = StatusColor(
        foreground: Color(0xFF1A7F37),
        container: Color(0xFFE9F6EC),
      );
      await _pump(
        tester,
        const StatusPill(
          label: 'Open',
          colors: colors,
          icon: Icons.adjust,
          filled: true,
        ),
      );

      final box = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.text('Open'),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = box.decoration as BoxDecoration;
      // Filled uses the foreground as background; the dark green takes white text.
      expect(decoration.color, colors.foreground);
      expect(tester.widget<Text>(find.text('Open')).style?.color, Colors.white);
    });

    testWidgets('shows the label in the status foreground on its container', (
      tester,
    ) async {
      const colors = LabFoxStatusColors.light;
      await _pump(tester, StatusPill(label: 'Open', colors: colors.open));

      expect(find.text('Open'), findsOneWidget);

      final text = tester.widget<Text>(find.text('Open'));
      expect(text.style?.color, colors.open.foreground);

      final box = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.text('Open'),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect((box.decoration as BoxDecoration).color, colors.open.container);
    });

    testWidgets('renders a leading dot when asked', (tester) async {
      await _pump(
        tester,
        StatusPill(
          label: 'Merged',
          colors: LabFoxStatusColors.light.merged,
          dot: true,
        ),
      );
      // The dot is a small circular decorated box tinted with the foreground.
      final boxes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((b) => b.decoration)
          .whereType<BoxDecoration>();
      expect(
        boxes.any(
          (d) =>
              d.shape == BoxShape.circle &&
              d.color == LabFoxStatusColors.light.merged.foreground,
        ),
        isTrue,
      );
    });

    testWidgets('renders a leading icon when given', (tester) async {
      await _pump(
        tester,
        StatusPill(
          label: 'Failed',
          colors: LabFoxStatusColors.light.closed,
          icon: Icons.close,
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
