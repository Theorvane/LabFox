import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/exceptions.dart';
import '../common/offset_pagination.dart';
import '../common/paginated.dart';
import '../gitlab_client.dart';
import 'repository_file.dart';

/// Repository tree and file endpoints.
class RepositoryApi {
  const RepositoryApi(this._dio);

  final Dio _dio;

  /// Lists repository tags, most recently updated first by GitLab default.
  Future<Paginated<RepositoryTag>> tags(
    Object projectId, {
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/repository/tags',
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
          context: 'listing repository tags',
        );
      }
      final items = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(RepositoryTag.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(items, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing repository tags');
    }
  }

  /// Loads one tag. Names can contain slashes, so they remain one URL segment.
  Future<RepositoryTag> tag(Object projectId, String name) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/repository/tags/${Uri.encodeComponent(name)}',
      );
      if (response.statusCode != 200 ||
          response.data is! Map<String, dynamic>) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a repository tag',
        );
      }
      return RepositoryTag.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a repository tag');
    }
  }

  /// Creates a lightweight tag, or an annotated tag when [message] is set.
  Future<RepositoryTag> createTag(
    Object projectId, {
    required String name,
    required String ref,
    String? message,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/projects/${_enc(projectId)}/repository/tags',
        queryParameters: {
          'tag_name': name,
          'ref': ref,
          if (message != null && message.isNotEmpty) 'message': message,
        },
      );
      if (response.statusCode != 201 ||
          response.data is! Map<String, dynamic>) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating a repository tag',
        );
      }
      return RepositoryTag.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating a repository tag');
    }
  }

  /// Lists a directory of the tree on a ref.
  ///
  /// [path] is a directory path, empty for the root. Results are sorted
  /// folders-first. Pagination is by page number; the next cursor comes from
  /// the response headers.
  Future<Paginated<RepositoryEntry>> tree(
    Object projectId, {
    required String ref,
    String path = '',
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/repository/tree',
        queryParameters: {
          'ref': ref,
          if (path.isNotEmpty) 'path': path,
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing the tree',
        );
      }
      final entries =
          (response.data as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>()
              .map(RepositoryEntry.fromJson)
              .toList()
            ..sort(RepositoryEntry.compare);
      return Paginated.fromHeaders(entries, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing the tree');
    }
  }

  /// The contents of a file on a ref, or null when it does not exist.
  Future<RepositoryFile?> fileText(
    Object projectId, {
    required String path,
    required String ref,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        // The whole path is one URL segment, so its slashes are encoded.
        '/projects/${_enc(projectId)}/repository/files/${Uri.encodeComponent(path)}/raw',
        queryParameters: {'ref': ref},
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 404) {
        return null;
      }
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'reading the file',
        );
      }
      final bytes = Uint8List.fromList(response.data ?? const []);
      return RepositoryFile.fromBytes(bytes);
    } on DioException catch (error) {
      throw mapError(error, context: 'reading the file');
    }
  }

  /// Lists the repository's branches.
  Future<Paginated<Branch>> branches(
    Object projectId, {
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/repository/branches',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing branches',
        );
      }
      final branches = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Branch.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(branches, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing branches');
    }
  }

  /// Creates a branch [name] from [ref] and returns it.
  ///
  /// `POST /projects/:id/repository/branches` — `branch` and `ref` are query
  /// parameters per the GitLab docs.
  Future<Branch> createBranch(
    Object projectId, {
    required String name,
    required String ref,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/repository/branches',
        queryParameters: {'branch': name, 'ref': ref},
      );
      final data = response.data;
      final status = response.statusCode ?? 0;
      if ((status != 201 && status != 200) || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating the branch',
        );
      }
      return Branch.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating the branch');
    }
  }

  /// Lists commits on a ref, most recent first.
  Future<Paginated<Commit>> commits(
    Object projectId, {
    required String ref,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/repository/commits',
        queryParameters: {'ref_name': ref, 'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing commits',
        );
      }
      final commits = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Commit.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(commits, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing commits');
    }
  }

  /// A single commit by SHA, including its line-change stats.
  Future<Commit> commit(Object projectId, {required String sha}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/repository/commits/${Uri.encodeComponent(sha)}',
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the commit',
        );
      }
      return Commit.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the commit');
    }
  }

  /// Reads one page of literal original diff files for a fixed commit identity.
  /// Preserves unknown text/omission metadata without inferring file coverage.
  /// GitLab diff limits can stop pagination before every changed file is exposed.
  /// This read supplies neither original position references nor write eligibility.
  Future<Paginated<CommitDiffFile>> commitDiffPage(
    Object projectId, {
    required String commitId,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!((projectId is int && projectId > 0) ||
        (projectId is String && projectId.trim().isNotEmpty))) {
      throw ArgumentError.value(projectId, 'projectId');
    }
    if (commitId.length != 40 || RegExp(r'[^0-9a-f]').hasMatch(commitId)) {
      throw ArgumentError.value(commitId, 'commitId');
    }
    if (page < 1) throw ArgumentError.value(page, 'page');
    if (perPage < 1 || perPage > 100) {
      throw ArgumentError.value(perPage, 'perPage');
    }
    try {
      final response = await _dio.get<String>(
        '/projects/${_enc(projectId)}/repository/commits/$commitId/diff',
        queryParameters: {'unidiff': true, 'page': page, 'per_page': perPage},
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
        ),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'reading original commit diff',
        );
      }
      try {
        final payload = jsonDecode(response.data ?? '');
        if (payload is! List) throw const FormatException();
        final paths = <(String, String)>{};
        final items = <CommitDiffFile>[];
        for (final entry in payload) {
          if (entry is! Map<String, dynamic>) throw const FormatException();
          final file = CommitDiffFile.fromJson(entry);
          if (file.oldPath.isEmpty ||
              file.newPath.isEmpty ||
              file.oldPath.contains('\u0000') ||
              file.newPath.contains('\u0000') ||
              !paths.add((file.oldPath, file.newPath))) {
            throw const FormatException();
          }
          items.add(file);
        }
        final next = validatedOffsetNextPage(
          response,
          page: page,
          perPage: perPage,
          fixedQuery: {'unidiff': 'true'},
          routeEchoes: {'id': '$projectId', 'sha': commitId},
        );
        final metadata = Paginated.fromHeaders(items, response.headers.map);
        return Paginated(
          items: List<CommitDiffFile>.unmodifiable(items),
          nextPage: next,
          total: metadata.total,
          totalPages: metadata.totalPages,
        );
      } on FormatException {
        throw const GitLabServerException(
          'Invalid original commit diff response.',
        );
      } on TypeError {
        throw const GitLabServerException(
          'Invalid original commit diff response.',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'reading original commit diff');
    }
  }

  /// The files changed by a commit, as parsed diffs.
  Future<List<FileDiff>> commitDiff(
    Object projectId, {
    required String sha,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/repository/commits/${Uri.encodeComponent(sha)}/diff',
        // unidiff=true returns the diff in unified format, the grammar
        // parseUnifiedDiff accepts. The default (false) is not guaranteed to be
        // that format. Older instances ignore the unknown parameter.
        queryParameters: {'unidiff': true},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the diff',
        );
      }
      return (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(FileDiff.fromJson)
          .toList(growable: false);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the diff');
    }
  }

  /// Encodes a project id: numeric ids pass through, `group/project` paths are
  /// URL-encoded.
  static String _enc(Object projectId) =>
      projectId is int ? '$projectId' : Uri.encodeComponent('$projectId');
}
