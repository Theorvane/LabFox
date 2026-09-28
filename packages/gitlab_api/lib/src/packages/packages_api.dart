import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Project package registry endpoints.
class PackagesApi {
  const PackagesApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/packages';

  /// Deletes one package file. Only 204 confirms deletion.
  Future<void> deleteFile(Object projectId, int packageId, int fileId) async {
    try {
      final response = await _dio.delete<dynamic>(
        '${_path(projectId)}/$packageId/package_files/$fileId',
      );
      if (response.statusCode != 204) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'deleting the package file',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'deleting the package file');
    }
  }

  /// Lists a project's packages, newest first.
  Future<Paginated<GitLabPackage>> list(
    Object projectId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(projectId),
        queryParameters: {
          'order_by': 'created_at',
          'sort': 'desc',
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing packages',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(GitLabPackage.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing packages');
    }
  }

  /// Retrieves a published package by its global package ID.
  Future<GitLabPackage> get(Object projectId, int packageId) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/$packageId',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the package',
        );
      }
      return GitLabPackage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the package');
    }
  }

  /// Lists files belonging to a package.
  Future<Paginated<PackageFile>> listFiles(
    Object projectId,
    int packageId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/$packageId/package_files',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing package files',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(PackageFile.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing package files');
    }
  }
}
