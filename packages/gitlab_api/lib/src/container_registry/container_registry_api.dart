import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/exceptions.dart';
import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Container registry operations for one authenticated client.
class ContainerRegistryApi {
  const ContainerRegistryApi(this._dio);

  final Dio _dio;

  /// Changes only the minimum push role; pattern and delete role are omitted.
  Future<ContainerRepositoryProtectionRule> updateRepositoryProtectionPushRole(
    Object projectId,
    int ruleId,
    String role,
  ) async {
    try {
      final response = await _dio.patch<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/registry/protection/repository/rules/$ruleId',
        data: {'minimum_access_level_for_push': role},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating repository protection push role',
        );
      }
      try {
        return ContainerRepositoryProtectionRule.fromJson(
          response.data as Map<String, dynamic>,
        );
      } catch (_) {
        throw const GitLabServerException(
          'Invalid protection push role update response',
        );
      }
    } on DioException catch (error) {
      throw mapError(
        error,
        context: 'updating repository protection push role',
      );
    }
  }

  /// Creates a rule; omitted role fields impose no restriction from this rule.
  Future<ContainerRepositoryProtectionRule> createRepositoryProtectionRule(
    Object projectId, {
    required String repositoryPathPattern,
    String? minimumAccessLevelForPush,
    String? minimumAccessLevelForDelete,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/registry/protection/repository/rules',
        data: {
          'repository_path_pattern': repositoryPathPattern,
          'minimum_access_level_for_push': ?minimumAccessLevelForPush,
          'minimum_access_level_for_delete': ?minimumAccessLevelForDelete,
        },
      );
      if (response.statusCode != 201) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating container repository protection rule',
        );
      }
      try {
        return ContainerRepositoryProtectionRule.fromJson(
          response.data as Map<String, dynamic>,
        );
      } catch (_) {
        throw const GitLabServerException(
          'Creation response did not contain a valid protection rule',
        );
      }
    } on DioException catch (error) {
      throw mapError(
        error,
        context: 'creating container repository protection rule',
      );
    }
  }

  /// Deletes a rule, not the repositories or images matching its pattern.
  Future<void> deleteRepositoryProtectionRule(
    Object projectId,
    int ruleId,
  ) async {
    try {
      final response = await _dio.delete<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/registry/protection/repository/rules/$ruleId',
      );
      if (response.statusCode != 204) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'deleting container repository protection rule',
        );
      }
    } on DioException catch (error) {
      throw mapError(
        error,
        context: 'deleting container repository protection rule',
      );
    }
  }

  /// Clears only the minimum push role; pattern and delete role are omitted.
  Future<ContainerTagProtectionRule> clearTagProtectionPushRole(
    Object projectId,
    int ruleId,
  ) async {
    try {
      final response = await _dio.patch<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/registry/protection/tag/rules/$ruleId',
        data: {'minimum_access_level_for_push': ''},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'clearing container tag protection push role',
        );
      }
      try {
        final data = response.data as Map<String, dynamic>;
        if (!data.containsKey('minimum_access_level_for_push')) {
          throw const FormatException('Missing cleared push role');
        }
        return ContainerTagProtectionRule.fromJson(data);
      } catch (_) {
        throw const GitLabServerException(
          'Invalid protection push role clear response',
        );
      }
    } on DioException catch (error) {
      throw mapError(
        error,
        context: 'clearing container tag protection push role',
      );
    }
  }

  /// Changes only the tag glob; omitted role fields stay unchanged (18.9+).
  Future<ContainerTagProtectionRule> updateTagProtectionPattern(
    Object projectId,
    int ruleId,
    String pattern,
  ) async {
    try {
      final response = await _dio.patch<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/registry/protection/tag/rules/$ruleId',
        data: {'tag_name_pattern': pattern},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating container tag protection pattern',
        );
      }
      try {
        return ContainerTagProtectionRule.fromJson(
          response.data as Map<String, dynamic>,
        );
      } catch (_) {
        throw const GitLabServerException(
          'Invalid tag protection update response',
        );
      }
    } on DioException catch (error) {
      throw mapError(
        error,
        context: 'updating container tag protection pattern',
      );
    }
  }

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/registry/repositories';

  /// Lists all repository protection rules. This endpoint is not paginated.
  Future<List<ContainerRepositoryProtectionRule>> listRepositoryProtectionRules(
    Object projectId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/registry/protection/repository/rules',
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing container repository protection rules',
        );
      }
      try {
        return (response.data as List<dynamic>)
            .map(
              (item) => ContainerRepositoryProtectionRule.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(growable: false);
      } catch (_) {
        throw const GitLabServerException(
          'Invalid container repository protection rule list response',
        );
      }
    } on DioException catch (error) {
      throw mapError(
        error,
        context: 'listing container repository protection rules',
      );
    }
  }

  /// Schedules asynchronous repository removal; acceptance is not completion.
  Future<void> deleteRepository(Object projectId, int repositoryId) async {
    try {
      final response = await _dio.delete<dynamic>(
        '${_path(projectId)}/$repositoryId',
      );
      if (response.statusCode != 202) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'scheduling container repository deletion',
        );
      }
    } on DioException catch (error) {
      throw mapError(
        error,
        context: 'scheduling container repository deletion',
      );
    }
  }

  /// Deletes one tag, not its blobs or the image repository.
  Future<void> deleteTag(
    Object projectId,
    int repositoryId,
    String tagName,
  ) async {
    try {
      final response = await _dio.delete<dynamic>(
        '${_path(projectId)}/$repositoryId/tags/${Uri.encodeComponent(tagName)}',
      );
      if (response.statusCode != 204) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'deleting a container tag',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'deleting a container tag');
    }
  }

  /// Creates a container tag rule (GitLab 18.8+) with both required roles.
  Future<ContainerTagProtectionRule> createTagProtectionRule(
    Object projectId, {
    required String tagNamePattern,
    required String minimumAccessLevelForPush,
    required String minimumAccessLevelForDelete,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/registry/protection/tag/rules',
        data: {
          'tag_name_pattern': tagNamePattern,
          'minimum_access_level_for_push': minimumAccessLevelForPush,
          'minimum_access_level_for_delete': minimumAccessLevelForDelete,
        },
      );
      if (response.statusCode != 201) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating container tag protection rule',
        );
      }
      try {
        return ContainerTagProtectionRule.fromJson(
          response.data as Map<String, dynamic>,
        );
      } catch (_) {
        throw const GitLabServerException(
          'Invalid tag protection creation response',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'creating container tag protection rule');
    }
  }

  /// Lists project tag protection rules (available from GitLab 18.7).
  Future<List<ContainerTagProtectionRule>> listTagProtectionRules(
    Object projectId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/registry/protection/tag/rules',
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing container tag protection rules',
        );
      }
      try {
        return (response.data as List<dynamic>)
            .map(
              (item) => ContainerTagProtectionRule.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(growable: false);
      } catch (_) {
        throw const GitLabServerException(
          'Invalid container tag protection rule list response',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'listing container tag protection rules');
    }
  }

  /// Lists image repositories in a project.
  Future<Paginated<RegistryRepository>> listRepositories(
    Object projectId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(projectId),
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing container repositories',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(RegistryRepository.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing container repositories');
    }
  }

  /// Schedules asynchronous tag cleanup; acceptance does not mean completion.
  Future<void> deleteTags(
    Object projectId,
    int repositoryId, {
    required String nameRegexDelete,
    String? nameRegexKeep,
    int? keepN,
    String? olderThan,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        '${_path(projectId)}/$repositoryId/tags',
        data: {
          'name_regex_delete': nameRegexDelete,
          'name_regex_keep': ?nameRegexKeep,
          'keep_n': ?keepN,
          'older_than': ?olderThan,
        },
      );
      if (response.statusCode != 202) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'scheduling container tag cleanup',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'scheduling container tag cleanup');
    }
  }

  /// Lists a container repository's tags.
  Future<Paginated<RegistryTag>> listTags(
    Object projectId,
    int repositoryId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/$repositoryId/tags',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing container tags',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(RegistryTag.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing container tags');
    }
  }

  /// Retrieves digest and image metadata for one tag.
  Future<RegistryTag> getTag(
    Object projectId,
    int repositoryId,
    String tagName,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/$repositoryId/tags/${Uri.encodeComponent(tagName)}',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a container tag',
        );
      }
      return RegistryTag.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a container tag');
    }
  }

  /// Deletes only a tag protection rule (GitLab 18.9+), not image tags.
  Future<void> deleteTagProtectionRule(Object projectId, int ruleId) async {
    try {
      final response = await _dio.delete<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/registry/protection/tag/rules/$ruleId',
      );
      if (response.statusCode != 204) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'deleting container tag protection rule',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'deleting container tag protection rule');
    }
  }
}
