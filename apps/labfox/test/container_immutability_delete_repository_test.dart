import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'container_immutability_repository_test.dart' as fixture;
import 'container_immutability_test.dart' show rule;

Map<String, Object> node({
  String? id,
  String? pattern,
  bool immutable = true,
}) => {
  'id': id ?? rule.id,
  'tagNamePattern': pattern ?? rule.tagNamePattern,
  'immutable': immutable,
};
void main() {
  test(
    'full immutable snapshot is checked before exactly one delete',
    () async {
      var writes = 0;
      final r = fixture.create((request) {
        if (request.method == 'GET') {
          return {'id': 7, 'name': 'App', 'path_with_namespace': 'team/app'};
        }
        if (request.data['operationName'] == 'ContainerImmutabilityRules') {
          return fixture.page([node()]);
        }
        writes++;
        expect(request.data['variables']['input'], {'id': rule.id});
        return {
          'data': {
            'deleteContainerProtectionTagRule': {
              'errors': [],
              'containerProtectionTagRule': node(),
            },
          },
        };
      });
      await r.deleteImmutableTagRule(7, rule);
      expect(writes, 1);
    },
  );
  for (final nodes in <List<Object>>[
    [],
    [node(pattern: 'changed')],
    [node(immutable: false)],
    [node(), node()],
  ]) {
    test(
      'missing changed mutable or ambiguous target never writes $nodes',
      () async {
        var writes = 0;
        final r = fixture.create((request) {
          if (request.method == 'GET') {
            return {'id': 7, 'name': 'App', 'path_with_namespace': 'team/app'};
          }
          if (request.data['operationName'] == 'ContainerImmutabilityRules') {
            return fixture.page(nodes);
          }
          writes++;
          return null;
        });
        await expectLater(
          r.deleteImmutableTagRule(7, rule),
          throwsA(isA<GitLabException>()),
        );
        expect(writes, 0);
      },
    );
  }
  test('session change during preflight stops dispatch', () async {
    var current = true;
    var writes = 0;
    final r = fixture.create((request) {
      if (request.method == 'GET') {
        return {'id': 7, 'name': 'App', 'path_with_namespace': 'team/app'};
      }
      if (request.data['operationName'] == 'ContainerImmutabilityRules') {
        current = false;
        return fixture.page([node()]);
      }
      writes++;
      return null;
    });
    await expectLater(
      r.deleteImmutableTagRule(7, rule, isCurrent: () => current),
      throwsStateError,
    );
    expect(writes, 0);
  });
}
