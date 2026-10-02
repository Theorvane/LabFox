import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Project Releases endpoints.
class ReleasesApi {
  const ReleasesApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/releases';

  Future<Paginated<GitLabRelease>> list(
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
          context: 'listing releases',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(GitLabRelease.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing releases');
    }
  }

  Future<GitLabRelease> get(Object projectId, String tagName) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(tagName)}',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a release',
        );
      }
      return GitLabRelease.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a release');
    }
  }

  Future<GitLabRelease> update(
    Object projectId,
    String tagName, {
    required String name,
    required String description,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(tagName)}',
        data: {'name': name, 'description': description},
      );
      if (response.statusCode != 200 || response.data is! Map) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating a release',
        );
      }
      return GitLabRelease.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating a release');
    }
  }

  /// Replaces milestone associations without modifying other release fields.
  Future<GitLabRelease> updateMilestones(
    Object projectId,
    String tagName,
    List<String> titles,
  ) async {
    try {
      final response = await _dio.put<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(tagName)}',
        data: {'milestones': titles},
      );
      if (response.statusCode != 200 || response.data is! Map) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating release milestones',
        );
      }
      return GitLabRelease.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating release milestones');
    }
  }

  Future<GitLabRelease> create(
    Object projectId, {
    required String tagName,
    String? ref,
    String? name,
    String? description,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        _path(projectId),
        data: {
          'tag_name': tagName,
          'ref': ?ref,
          'name': ?name,
          'description': ?description,
        },
      );
      if (response.statusCode != 201 || response.data is! Map) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating a release',
        );
      }
      return GitLabRelease.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating a release');
    }
  }

  Future<ReleaseAssetLink> createAssetLink(
    Object projectId,
    String tagName, {
    required String name,
    required String url,
    String? directAssetPath,
    String? linkType,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(tagName)}/assets/links',
        data: {
          'name': name,
          'url': url,
          'direct_asset_path': ?directAssetPath,
          'link_type': ?linkType,
        },
      );
      if (response.statusCode != 201 || response.data is! Map) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating a release asset link',
        );
      }
      return ReleaseAssetLink.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating a release asset link');
    }
  }

  /// Deletes the release record without deleting its Git tag.
  Future<void> delete(Object projectId, String tagName) async {
    try {
      final response = await _dio.delete<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(tagName)}',
      );
      if (response.statusCode != 204) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'deleting a release',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'deleting a release');
    }
  }

  Future<ReleaseAssetLink> updateAssetLink(
    Object projectId,
    String tagName,
    int linkId, {
    required String name,
    required String url,
    String? directAssetPath,
    String? linkType,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(tagName)}/assets/links/$linkId',
        data: {
          'name': name,
          'url': url,
          'direct_asset_path': ?directAssetPath,
          'link_type': ?linkType,
        },
      );
      if (response.statusCode != 200 || response.data is! Map) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating a release asset link',
        );
      }
      return ReleaseAssetLink.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating a release asset link');
    }
  }

  /// Removes only the asset link record, not the release or linked file.
  Future<void> deleteAssetLink(
    Object projectId,
    String tagName,
    int linkId,
  ) async {
    try {
      final response = await _dio.delete<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(tagName)}/assets/links/$linkId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'deleting a release asset link',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'deleting a release asset link');
    }
  }
}
