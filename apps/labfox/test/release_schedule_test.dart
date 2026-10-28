import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/releases/data/releases_repository.dart';
import 'package:labfox/features/releases/presentation/controllers/releases_controller.dart';
import 'package:labfox/features/releases/presentation/widgets/release_schedule_dialog.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Repository extends ReleasesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final dates = <DateTime>[];
  bool reject = false;
  @override
  Future<GitLabRelease> updateReleasedAt(
    int projectId,
    String tagName,
    DateTime date,
  ) async {
    expect(projectId, 7);
    expect(tagName, 'release/1');
    dates.add(date);
    if (reject) throw const GitLabForbiddenException('Forbidden');
    return GitLabRelease(name: 'Release', tagName: tagName, releasedAt: date);
  }
}

final _original = DateTime.utc(2027, 1, 2, 3, 4, 5, 123);
Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        releasesRepositoryProvider.overrideWith((ref) async => repository),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => ReleaseScheduleDialog(
                  keyRef: const ReleaseRef(projectId: 7, tagName: 'release/1'),
                  releasedAt: _original,
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [320.0, 390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('preserves exact untouched timestamp at $width $brightness', (
        tester,
      ) async {
        final repository = _Repository();
        await _pump(tester, repository, width: width, brightness: brightness);
        await tester.tap(find.text('Change time'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TimePickerDialog>(find.byType(TimePickerDialog))
              .initialTime,
          TimeOfDay.fromDateTime(_original.toLocal()),
        );
        await tester.tap(find.text('Cancel').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save release date'));
        await tester.pumpAndSettle();
        expect(repository.dates, isEmpty);
        expect(find.byType(ReleaseScheduleDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('changed time sends UTC and retains rejected draft for retry', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await tester.tap(find.text('Change time'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '10');
    await tester.enterText(find.byType(TextField).at(1), '30');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save release date'));
    await tester.pumpAndSettle();
    final local = _original.toLocal();
    expect(
      repository.dates.single,
      DateTime(local.year, local.month, local.day, 10, 30).toUtc(),
    );
    expect(repository.dates.single.isUtc, isTrue);
    expect(find.text('Could not update the release date.'), findsOneWidget);
    repository.reject = false;
    await tester.tap(find.text('Save release date'));
    await tester.pumpAndSettle();
    expect(repository.dates.last, repository.dates.first);
    expect(find.byType(ReleaseScheduleDialog), findsNothing);
  });
  testWidgets('cancel never changes publication time', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.dates, isEmpty);
  });

  testWidgets('date picker retains local time and sub-minute precision', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.text('Change date'));
    await tester.pumpAndSettle();
    final local = _original.toLocal();
    expect(
      tester
          .widget<DatePickerDialog>(find.byType(DatePickerDialog))
          .initialDate,
      DateTime(local.year, local.month, local.day),
    );
    await tester.tap(find.text('10').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save release date'));
    await tester.pumpAndSettle();
    expect(
      repository.dates.single,
      DateTime(
        local.year,
        local.month,
        10,
        local.hour,
        local.minute,
        local.second,
        local.millisecond,
        local.microsecond,
      ).toUtc(),
    );
  });
}
