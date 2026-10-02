import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';
import 'container_immutability_api_test.dart' as fixture;

Object envelope(Object? payload) => {
  'data': {'createContainerProtectionTagRule': payload},
};
void main() {
  test(
    'creates immutable rule with explicit null roles and exact regex',
    () async {
      final c = fixture.client((r) {
        expect(r.data['operationName'], 'CreateContainerImmutabilityRule');
        expect(
          r.data['query'],
          contains('createContainerProtectionTagRuleInput!'),
        );
        expect(r.data['variables'], {
          'input': {
            'projectPath': 'team/app',
            'tagNamePattern': fixture.rule['tagNamePattern'],
            'minimumAccessLevelForPush': null,
            'minimumAccessLevelForDelete': null,
          },
        });
        expect(r.followRedirects, isFalse);
        expect(r.extra['labfox_no_auth_retry'], isTrue);
        return envelope({
          'errors': [],
          'containerProtectionTagRule': fixture.rule,
        });
      });
      addTearDown(c.close);
      final rule = await c.containerImmutability.createRule(
        'team/app',
        fixture.rule['tagNamePattern']! as String,
      );
      expect(rule.immutable, isTrue);
    },
  );
  for (final payload in [
    null,
    {},
    {'errors': null},
    {'errors': [], 'containerProtectionTagRule': null},
    {
      'errors': [],
      'containerProtectionTagRule': {...fixture.rule, 'immutable': false},
    },
    {
      'errors': [],
      'containerProtectionTagRule': {
        ...fixture.rule,
        'tagNamePattern': 'different',
      },
    },
    {
      'errors': [],
      'containerProtectionTagRule': {...fixture.rule, 'id': ' '},
    },
    {
      'errors': [7],
      'containerProtectionTagRule': fixture.rule,
    },
  ]) {
    test('unconfirmed result fails closed: $payload', () async {
      final c = fixture.client((_) => envelope(payload));
      addTearDown(c.close);
      await expectLater(
        c.containerImmutability.createRule(
          'team/app',
          fixture.rule['tagNamePattern']! as String,
        ),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  test('payload errors are sanitized even when a rule is returned', () async {
    final c = fixture.client(
      (_) => envelope({
        'errors': ['private pattern'],
        'containerProtectionTagRule': fixture.rule,
      }),
    );
    addTearDown(c.close);
    await expectLater(
      c.containerImmutability.createRule(
        'team/app',
        fixture.rule['tagNamePattern']! as String,
      ),
      throwsA(
        isA<GitLabConflictException>().having(
          (e) => e.message,
          'safe message',
          isNot(contains('private')),
        ),
      ),
    );
  });
  for (final pattern in ['', ' ', 'x' * 101]) {
    test('invalid pattern never writes $pattern', () async {
      final c = fixture.client((_) => fail('must not send'));
      addTearDown(c.close);
      await expectLater(
        c.containerImmutability.createRule('team/app', pattern),
        throwsArgumentError,
      );
    });
  }
}
