import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';
import 'package:labfox/features/pipelines/presentation/pipelines_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubPipelines extends PipelinesController {
  _StubPipelines(this._value);
  final AsyncValue<List<Pipeline>> _value;

  @override
  Future<Paginated<Pipeline>> build(int projectId) {
    return _value.when(
      data: (v) => Future.value(Paginated(items: v)),
      loading: () => Completer<Paginated<Pipeline>>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  AsyncValue<List<Pipeline>> value,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pipelinesControllerProvider.overrideWith(() => _StubPipelines(value)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PipelinesScreen(projectId: 1),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('lists pipelines with a status icon', (tester) async {
    await _pump(
      tester,
      const AsyncData([Pipeline(id: 944, status: 'failed', ref: 'main')]),
    );
    await tester.pumpAndSettle();

    expect(find.text('main'), findsOneWidget);
    expect(find.textContaining('#944'), findsOneWidget);
    // Failed pipeline shows the Failed status pill and the failed glyph.
    expect(find.text('Failed'), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
  });

  testWidgets('shows an empty message when there are no pipelines', (
    tester,
  ) async {
    await _pump(tester, const AsyncData(<Pipeline>[]));
    await tester.pumpAndSettle();
    expect(find.textContaining('No pipelines'), findsOneWidget);
  });
}
