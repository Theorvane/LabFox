import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/features/shell/presentation/app_shell.dart';
import 'package:labfox/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester, double width) async {
  await tester.pumpWidget(
    // The shell hosts the ad banner slot, which reads providers.
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 900)),
          child: const AppShell(
            currentIndex: 0,
            child: Scaffold(body: Text('content')),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('uses a bottom navigation bar on a phone width', (tester) async {
    await _pump(tester, 400);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    for (final label in ['Home', 'Settings', 'Search', 'Me']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('uses a navigation rail once there is room', (tester) async {
    await _pump(tester, 900);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
