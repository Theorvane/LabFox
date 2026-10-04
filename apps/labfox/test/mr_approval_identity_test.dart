import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/core/auth/gitlab_client_provider.dart';
import 'package:labfox/core/entitlement/entitlement.dart';
import 'package:labfox/core/entitlement/entitlement_providers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_actions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/widgets/mr_actions.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _ref = MergeRequestRef(projectId: 8, iid: 142);
Account _account(int id) => Account(
  instanceUrl: 'https://gitlab.example.com',
  user: User(id: id, username: 'reviewer', name: 'Reviewer'),
);
final _accountProvider = StateProvider<Account?>((ref) => _account(7));

class _Adapter implements HttpClientAdapter {
  _Adapter(this.body);
  Map<String, Object?> body;
  final writes = <String>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method != 'GET') writes.add(options.path);
    return ResponseBody.fromString(
      jsonEncode(options.method == 'GET' ? body : {}),
      options.method == 'GET' ? 200 : 201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _Entitlement extends EntitlementController {
  @override
  Entitlement build() => Entitlement.subscribed;
}

class _Analytics implements Analytics {
  @override
  Future<void> track(String name, [Map<String, Object?>? properties]) async {}
}

void main() {
  for (final width in [390.0, 1200.0]) {
    for (final dark in [false, true]) {
      for (final member in [false, true]) {
        testWidgets(
          'documented response dispatches correct toggle $width dark=$dark member=$member',
          (tester) async {
            tester.view.physicalSize = Size(width, 1000);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final adapter = _Adapter({
              'approvals_required': 2,
              'approved_by': [
                {
                  'user': {
                    'id': member ? 7 : 8,
                    'username': 'reviewer',
                    'name': 'Reviewer',
                  },
                },
              ],
            });
            final client = GitLabClient(
              baseUrl: 'https://gitlab.example.com',
              token: 'glpat-xxxxxxxxxxxx',
              dio: Dio()..httpClientAdapter = adapter,
            );
            addTearDown(client.close);
            await tester.pumpWidget(
              ProviderScope(
                overrides: [
                  currentAccountProvider.overrideWith((ref) => _account(7)),
                  gitLabClientProvider.overrideWith((ref) async => client),
                  entitlementProvider.overrideWith(_Entitlement.new),
                  analyticsProvider.overrideWithValue(_Analytics()),
                ],
                child: MaterialApp(
                  theme: ThemeData(
                    brightness: dark ? Brightness.dark : Brightness.light,
                  ),
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: const Scaffold(
                    body: MrActions(
                      projectId: 8,
                      mr: MergeRequest(
                        id: 900,
                        iid: 142,
                        title: 'Review',
                        state: 'opened',
                        sourceBranch: 'feature',
                        targetBranch: 'dev',
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            final l10n = AppLocalizations.of(
              tester.element(find.byType(MrActions)),
            );
            final button = find.byType(OutlinedButton).first;
            expect(
              find.descendant(
                of: button,
                matching: find.text(member ? l10n.mrUnapprove : l10n.mrApprove),
              ),
              findsOneWidget,
            );
            await tester.tap(button);
            await tester.pumpAndSettle();
            expect(adapter.writes, [
              '/projects/8/merge_requests/142/${member ? 'unapprove' : 'approve'}',
            ]);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  for (final legacyFlag in [null, false, true]) {
    for (final member in [false, true]) {
      test(
        'approval ownership uses user ID with flag $legacyFlag, member $member',
        () async {
          final adapter = _Adapter({
            'approvals_required': 2,
            'user_has_approved': ?legacyFlag,
            'approved_by': [
              {
                'user': {
                  'id': member ? 7 : 8,
                  'username': 'reviewer',
                  'name': 'Reviewer',
                },
              },
            ],
          });
          final client = GitLabClient(
            baseUrl: 'https://gitlab.example.com',
            token: 'glpat-xxxxxxxxxxxx',
            dio: Dio()..httpClientAdapter = adapter,
          );
          final container = ProviderContainer(
            overrides: [
              currentAccountProvider.overrideWith(
                (ref) => ref.watch(_accountProvider),
              ),
              gitLabClientProvider.overrideWith((ref) async => client),
            ],
          );
          addTearDown(container.dispose);
          addTearDown(client.close);
          final approvals = await container.read(
            mrApprovalsProvider(_ref).future,
          );
          expect(approvals!.userHasApproved, member);
          expect(approvals.approvalsRequired, 2);
          expect(approvals.approvedCount, 1);
          expect(approvals.approvedBy.single.id, member ? 7 : 8);
        },
      );
    }
  }

  test(
    'account replacement recomputes membership even for an unchanged client',
    () async {
      final adapter = _Adapter({
        'approvals_required': 1,
        'approved_by': [
          {
            'user': {'id': 7, 'username': 'reviewer', 'name': 'Reviewer'},
          },
        ],
      });
      final client = GitLabClient(
        baseUrl: 'https://gitlab.example.com',
        token: 'glpat-xxxxxxxxxxxx',
        dio: Dio()..httpClientAdapter = adapter,
      );
      final container = ProviderContainer(
        overrides: [
          currentAccountProvider.overrideWith(
            (ref) => ref.watch(_accountProvider),
          ),
          gitLabClientProvider.overrideWith((ref) async => client),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(client.close);
      expect(
        (await container.read(
          mrApprovalsProvider(_ref).future,
        ))!.userHasApproved,
        true,
      );
      container.read(_accountProvider.notifier).state = _account(8);
      expect(
        (await container.read(
          mrApprovalsProvider(_ref).future,
        ))!.userHasApproved,
        false,
      );
      container.read(_accountProvider.notifier).state = null;
      expect(await container.read(mrApprovalsProvider(_ref).future), isNull);
    },
  );
}
