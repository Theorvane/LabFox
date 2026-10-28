import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';
import 'container_immutability_api_test.dart' as fixture;

final expectedRule = ContainerTagImmutabilityRule.fromJson(fixture.rule);
Object envelope(Object? payload) => {
  'data': {'deleteContainerProtectionTagRule': payload},
};
void main() {
  test(
    'deletes the exact opaque rule ID once without auth retry or redirects',
    () async {
      var writes = 0;
      final c = fixture.client((r) {
        writes++;
        expect(r.data['operationName'], 'DeleteContainerImmutabilityRule');
        expect(
          r.data['query'],
          contains('DeleteContainerProtectionTagRuleInput!'),
        );
        expect(r.data['variables'], {
          'input': {'id': expectedRule.id},
        });
        expect(r.followRedirects, isFalse);
        expect(r.extra['labfox_no_auth_retry'], isTrue);
        return envelope({
          'errors': [],
          'containerProtectionTagRule': fixture.rule,
        });
      });
      addTearDown(c.close);
      await c.containerImmutability.deleteRule(expectedRule);
      expect(writes, 1);
    },
  );
  for (final payload in [
    null,
    {},
    {'errors': null},
    {'errors': []},
    {'errors': [], 'containerProtectionTagRule': null},
    {
      'errors': [7],
      'containerProtectionTagRule': fixture.rule,
    },
    {
      'errors': [],
      'containerProtectionTagRule': {...fixture.rule, 'id': 'other'},
    },
    {
      'errors': [],
      'containerProtectionTagRule': {
        ...fixture.rule,
        'tagNamePattern': 'other',
      },
    },
    {
      'errors': [],
      'containerProtectionTagRule': {...fixture.rule, 'immutable': false},
    },
    {
      'errors': [],
      'containerProtectionTagRule': {
        'id': expectedRule.id,
        'tagNamePattern': expectedRule.tagNamePattern,
      },
    },
  ]) {
    test('unconfirmed deletion fails closed $payload', () async {
      final c = fixture.client((_) => envelope(payload));
      addTearDown(c.close);
      await expectLater(
        c.containerImmutability.deleteRule(expectedRule),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  test(
    'payload rejection remains private even when a deleted rule is returned',
    () async {
      final c = fixture.client(
        (_) => envelope({
          'errors': ['private text'],
          'containerProtectionTagRule': fixture.rule,
        }),
      );
      addTearDown(c.close);
      await expectLater(
        c.containerImmutability.deleteRule(expectedRule),
        throwsA(
          isA<GitLabConflictException>().having(
            (e) => e.message,
            'message',
            isNot(contains('private')),
          ),
        ),
      );
    },
  );
  for (final rule in [
    expectedRule.copyWith(id: ''),
    expectedRule.copyWith(tagNamePattern: ' '),
    expectedRule.copyWith(immutable: false),
  ]) {
    test('invalid target never writes $rule', () async {
      final c = fixture.client((_) => fail('must not write'));
      addTearDown(c.close);
      await expectLater(
        c.containerImmutability.deleteRule(rule),
        throwsArgumentError,
      );
    });
  }
}
