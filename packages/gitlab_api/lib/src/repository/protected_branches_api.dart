import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/exceptions.dart';
import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Protected branch rules for one project.
class ProtectedBranchesApi {
  const ProtectedBranchesApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/protected_branches';

  Future<Paginated<ProtectedBranch>> list(
    Object projectId, {
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(projectId),
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing protected branches',
        );
      }
      final raw = response.data;
      if (raw is! List ||
          raw.any(
            (entry) =>
                entry is! Map<String, dynamic> ||
                entry['name'] is! String ||
                (entry['name'] as String).isEmpty ||
                entry['push_access_levels'] is! List ||
                entry['merge_access_levels'] is! List,
          )) {
        throw const GitLabServerException('Incomplete protected branch list');
      }
      try {
        final items = raw
            .cast<Map<String, dynamic>>()
            .map(ProtectedBranch.fromJson)
            .toList(growable: false);
        return Paginated.fromHeaders(items, response.headers.map);
      } on TypeError {
        throw const GitLabServerException('Malformed protected branch list');
      } on FormatException {
        throw const GitLabServerException('Malformed protected branch list');
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'listing protected branches');
    }
  }

  /// Creates a role-only rule without force push or a tier-specific grant.
  Future<ProtectedBranch> protect(
    Object projectId, {
    required String name,
    required int pushAccessLevel,
    required int mergeAccessLevel,
  }) async {
    const roles = [0, 30, 40];
    if (name.trim().isEmpty ||
        !roles.contains(pushAccessLevel) ||
        !roles.contains(mergeAccessLevel)) {
      throw ArgumentError(
        'Exact name and supported push and merge roles required',
      );
    }
    try {
      final response = await _dio.post<dynamic>(
        _path(projectId),
        data: {
          'name': name,
          'push_access_level': pushAccessLevel,
          'merge_access_level': mergeAccessLevel,
          'allow_force_push': false,
        },
        options: Options(
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 201 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating protected branch rule',
        );
      }
      final raw = response.data;
      if (raw is! Map<String, dynamic> ||
          raw['name'] != name ||
          raw['push_access_levels'] is! List ||
          raw['merge_access_levels'] is! List ||
          raw['allow_force_push'] != false) {
        throw const GitLabServerException(
          'Incomplete protected branch creation',
        );
      }
      try {
        final created = ProtectedBranch.fromJson(raw);
        if (created.pushAccessLevels.length != 1 ||
            created.mergeAccessLevels.length != 1 ||
            !_matchesRole(created.pushAccessLevels.single, pushAccessLevel) ||
            !_matchesRole(created.mergeAccessLevels.single, mergeAccessLevel) ||
            created.allowForcePush ||
            created.codeOwnerApprovalRequired ||
            created.inherited == true) {
          throw const GitLabServerException(
            'Unconfirmed protected branch roles',
          );
        }
        return created;
      } on TypeError {
        throw const GitLabServerException(
          'Malformed protected branch creation',
        );
      } on FormatException {
        throw const GitLabServerException(
          'Malformed protected branch creation',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'creating protected branch rule');
    }
  }

  bool _matchesRole(ProtectedBranchAccess access, int role) =>
      access.accessLevel == role &&
      access.userId == null &&
      access.groupId == null &&
      access.deployKeyId == null;

  Future<ProtectedBranch> get(Object projectId, String name) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(name)}',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a protected branch',
        );
      }
      return ProtectedBranch.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a protected branch');
    }
  }
}
