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
      if (raw is! List || raw.any((entry) => !_validRule(entry))) {
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
      access.deployKeyId == null &&
      access.memberRoleId == null;

  Future<ProtectedBranch> get(Object projectId, String name) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(name)}',
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a protected branch',
        );
      }
      final raw = response.data;
      if (!_validRule(raw) || (raw as Map<String, dynamic>)['name'] != name) {
        throw const GitLabServerException('Incomplete protected branch detail');
      }
      try {
        return ProtectedBranch.fromJson(raw);
      } on TypeError {
        throw const GitLabServerException('Malformed protected branch detail');
      } on FormatException {
        throw const GitLabServerException('Malformed protected branch detail');
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a protected branch');
    }
  }

  /// Changes only the force-push flag of an exact project rule.
  Future<ProtectedBranch> updateForcePush(
    Object projectId,
    String name, {
    required bool allowForcePush,
  }) async {
    if (name.trim().isEmpty) throw ArgumentError('Exact rule name required');
    try {
      final response = await _dio.patch<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(name)}',
        data: {'allow_force_push': allowForcePush},
        options: Options(
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating protected branch force push',
        );
      }
      final raw = response.data;
      if (!_validRule(raw) ||
          (raw as Map<String, dynamic>)['name'] != name ||
          raw['allow_force_push'] != allowForcePush) {
        throw const GitLabServerException(
          'Unconfirmed protected branch update',
        );
      }
      try {
        return ProtectedBranch.fromJson(raw);
      } on TypeError {
        throw const GitLabServerException('Malformed protected branch update');
      } on FormatException {
        throw const GitLabServerException('Malformed protected branch update');
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'updating protected branch force push');
    }
  }

  /// Changes one existing role-based merge access record on an exact rule.
  Future<ProtectedBranch> updateMergeRole(
    Object projectId,
    String name, {
    required int accessRecordId,
    required int accessLevel,
  }) async {
    if (name.trim().isEmpty ||
        accessRecordId <= 0 ||
        !{0, 30, 40}.contains(accessLevel)) {
      throw ArgumentError('Exact rule and supported merge role required');
    }
    try {
      final response = await _dio.patch<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(name)}',
        data: {
          'allowed_to_merge': [
            {'id': accessRecordId, 'access_level': accessLevel},
          ],
        },
        options: Options(
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating protected branch merge access',
        );
      }
      final raw = response.data;
      if (!_validRule(raw) || (raw as Map<String, dynamic>)['name'] != name) {
        throw const GitLabServerException(
          'Unconfirmed protected branch update',
        );
      }
      try {
        final changed = ProtectedBranch.fromJson(raw);
        final levels = changed.mergeAccessLevels;
        if (levels.length != 1 ||
            levels.single.id != accessRecordId ||
            levels.single.accessLevel != accessLevel ||
            levels.single.userId != null ||
            levels.single.groupId != null ||
            levels.single.deployKeyId != null ||
            levels.single.memberRoleId != null) {
          throw const GitLabServerException(
            'Unconfirmed protected branch merge role',
          );
        }
        return changed;
      } on TypeError {
        throw const GitLabServerException('Malformed protected branch update');
      } on FormatException {
        throw const GitLabServerException('Malformed protected branch update');
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'updating protected branch merge access');
    }
  }

  /// Removes only the named project rule, not the underlying branch.
  Future<void> unprotect(Object projectId, String name) async {
    if (name.trim().isEmpty) throw ArgumentError('Exact rule name required');
    try {
      final response = await _dio.delete<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(name)}',
        options: Options(
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 204) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'unprotecting branch rule',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'unprotecting branch rule');
    }
  }

  /// Changes one existing role-based push access record on an exact rule.
  Future<ProtectedBranch> updatePushRole(
    Object projectId,
    String name, {
    required int accessRecordId,
    required int accessLevel,
  }) async {
    if (name.trim().isEmpty ||
        accessRecordId <= 0 ||
        !{0, 30, 40}.contains(accessLevel)) {
      throw ArgumentError('Exact rule and supported push role required');
    }
    try {
      final response = await _dio.patch<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(name)}',
        data: {
          'allowed_to_push': [
            {'id': accessRecordId, 'access_level': accessLevel},
          ],
        },
        options: Options(
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating protected branch push access',
        );
      }
      final raw = response.data;
      if (!_validRule(raw) || (raw as Map<String, dynamic>)['name'] != name) {
        throw const GitLabServerException(
          'Unconfirmed protected branch update',
        );
      }
      try {
        final changed = ProtectedBranch.fromJson(raw);
        final levels = changed.pushAccessLevels;
        if (levels.length != 1 ||
            levels.single.id != accessRecordId ||
            levels.single.accessLevel != accessLevel ||
            levels.single.userId != null ||
            levels.single.groupId != null ||
            levels.single.deployKeyId != null ||
            levels.single.memberRoleId != null) {
          throw const GitLabServerException(
            'Unconfirmed protected branch push role',
          );
        }
        return changed;
      } on TypeError {
        throw const GitLabServerException('Malformed protected branch update');
      } on FormatException {
        throw const GitLabServerException('Malformed protected branch update');
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'updating protected branch push access');
    }
  }

  bool _validRule(Object? raw) {
    if (raw is! Map<String, dynamic> ||
        raw['name'] is! String ||
        (raw['name'] as String).isEmpty ||
        raw['allow_force_push'] is! bool ||
        raw['push_access_levels'] is! List ||
        raw['merge_access_levels'] is! List ||
        (raw.containsKey('unprotect_access_levels') &&
            raw['unprotect_access_levels'] is! List)) {
      return false;
    }
    return (raw['push_access_levels'] as List).every(_validAccess) &&
        (raw['merge_access_levels'] as List).every(_validAccess) &&
        (raw['unprotect_access_levels'] as List? ?? []).every(_validAccess);
  }

  bool _validAccess(Object? raw) =>
      raw is Map<String, dynamic> &&
      (raw['access_level'] is int ||
          raw['user_id'] is int ||
          raw['group_id'] is int ||
          raw['deploy_key_id'] is int ||
          raw['member_role_id'] is int);
}
