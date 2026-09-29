import 'package:gitlab_models/gitlab_models.dart';
import '../common/exceptions.dart';
import '../graphql/graphql_api.dart';

/// GraphQL is necessary here: REST does not expose the immutable flag.
class ContainerImmutabilityApi {
  const ContainerImmutabilityApi(this._graphql);
  final GraphQLApi _graphql;
  Future<void> deleteRule(ContainerTagImmutabilityRule expected) async {
    if (!expected.immutable ||
        expected.id.trim().isEmpty ||
        expected.tagNamePattern.trim().isEmpty) {
      throw ArgumentError('A complete immutable rule is required');
    }
    final data = await _graphql.mutate(
      document: r'''
mutation DeleteContainerImmutabilityRule($input: DeleteContainerProtectionTagRuleInput!) {
  deleteContainerProtectionTagRule(input: $input) {
    errors
    containerProtectionTagRule { id tagNamePattern immutable }
  }
}
''',
      operationName: 'DeleteContainerImmutabilityRule',
      variables: {
        'input': {'id': expected.id},
      },
    );
    try {
      final payload =
          data['deleteContainerProtectionTagRule'] as Map<String, dynamic>;
      final errors = payload['errors'];
      if (errors is! List || errors.any((e) => e is! String)) {
        throw const FormatException('Missing mutation errors');
      }
      if (errors.isNotEmpty) {
        throw const GitLabConflictException(
          'Rule deletion was rejected',
          statusCode: 422,
        );
      }
      final deleted = ContainerTagImmutabilityRule.fromJson(
        payload['containerProtectionTagRule'] as Map<String, dynamic>,
      );
      if (deleted != expected) {
        throw const FormatException('Unconfirmed deleted rule');
      }
    } on GitLabConflictException {
      rethrow;
    } catch (_) {
      throw const GitLabServerException('Rule deletion could not be confirmed');
    }
  }

  static const _document = r'''
query ContainerImmutabilityRules($fullPath: ID!, $after: String) {
  project(fullPath: $fullPath) {
    fullPath
    rules: containerProtectionTagRules(first: 100, after: $after) {
      nodes { id tagNamePattern immutable }
      pageInfo { hasNextPage endCursor }
    }
  }
}
''';
  Future<ContainerTagRuleConnection> listRules(
    String fullPath, {
    String? after,
  }) async {
    if (fullPath.trim().isEmpty) {
      throw ArgumentError('Project full path is required');
    }
    final data = await _graphql.query(
      document: _document,
      operationName: 'ContainerImmutabilityRules',
      variables: {'fullPath': fullPath, 'after': after},
    );
    if (data.containsKey('project') && data['project'] == null) {
      throw const GitLabNotFoundException('Project is unavailable');
    }
    try {
      final project = data['project'] as Map<String, dynamic>;
      if (project['fullPath'] != fullPath) {
        throw const FormatException('Project identity mismatch');
      }
      if (project.containsKey('rules') && project['rules'] == null) {
        throw const GitLabNotFoundException(
          'Tag rule connection is unavailable',
        );
      }
      final page = ContainerTagRuleConnection.fromJson(
        project['rules'] as Map<String, dynamic>,
      );
      if (page.nodes.any(
            (r) => r.id.trim().isEmpty || r.tagNamePattern.trim().isEmpty,
          ) ||
          (page.pageInfo.hasNextPage &&
              (page.pageInfo.endCursor == null ||
                  page.pageInfo.endCursor!.isEmpty))) {
        throw const FormatException('Incomplete tag rule connection');
      }
      return page;
    } on GitLabNotFoundException {
      rethrow;
    } catch (_) {
      throw const GitLabServerException('Invalid tag rule connection response');
    }
  }
}
