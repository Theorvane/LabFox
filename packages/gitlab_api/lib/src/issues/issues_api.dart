import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Whose issues to list on the account-scoped endpoint.
enum IssueScope {
  assignedToMe('assigned_to_me'),
  createdByMe('created_by_me');

  const IssueScope(this.value);

  final String value;
}

/// Which issues to list.
enum IssueState {
  opened('opened'),
  closed('closed'),
  all('all');

  const IssueState(this.value);

  final String value;
}

/// Issue endpoints.
class IssuesApi {
  const IssuesApi(this._dio);

  final Dio _dio;

  /// Lists a project's issues, open by default, most recently updated first.
  ///
  /// A non-empty [search] filters by title and description server-side.
  Future<Paginated<Issue>> list(
    Object projectId, {
    IssueState state = IssueState.opened,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/issues',
        queryParameters: {
          if (state != IssueState.all) 'state': state.value,
          if (search != null && search.isNotEmpty) 'search': search,
          'order_by': 'updated_at',
          // Return each label as an object with its colour, not a bare name, so
          // the UI can render readable label chips.
          'with_labels_details': true,
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing issues',
        );
      }
      final issues = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Issue.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(issues, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing issues');
    }
  }

  /// Lists issues assigned to the authenticated user across every project.
  Future<Paginated<Issue>> listAssignedToMe({
    IssueState state = IssueState.opened,
    int page = 1,
    int perPage = 20,
  }) => listMine(state: state, page: page, perPage: perPage);

  /// Lists the authenticated user's issues across every project — assigned to
  /// or created by them — open by default and most recently updated first.
  ///
  /// This is the account-scoped global `/issues` endpoint, not a project path,
  /// so results span projects; each issue keeps its `project_id` for routing.
  Future<Paginated<Issue>> listMine({
    IssueScope scope = IssueScope.assignedToMe,
    IssueState state = IssueState.opened,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/issues',
        queryParameters: {
          'scope': scope.value,
          if (state != IssueState.all) 'state': state.value,
          'order_by': 'updated_at',
          'with_labels_details': true,
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing assigned issues',
        );
      }
      final issues = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Issue.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(issues, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing assigned issues');
    }
  }

  /// Creates an issue in a project and returns it.
  ///
  /// `POST /projects/:id/issues` — `title` is required; an empty description is
  /// omitted rather than sent blank.
  Future<Issue> create(
    Object projectId, {
    required String title,
    String? description,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/issues',
        data: {
          'title': title,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );
      final data = response.data;
      final status = response.statusCode ?? 0;
      if ((status != 201 && status != 200) || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating the issue',
        );
      }
      return Issue.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating the issue');
    }
  }

  /// Closes or reopens an issue and returns the updated resource.
  ///
  /// `PUT /projects/:id/issues/:iid` with `state_event` — `close` or `reopen`,
  /// the state transitions GitLab exposes.
  Future<Issue> setOpen(
    Object projectId, {
    required int iid,
    required bool open,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/issues/$iid',
        data: {'state_event': open ? 'reopen' : 'close'},
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating the issue',
        );
      }
      return Issue.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating the issue');
    }
  }

  /// Updates an issue's title and description. An empty description clears it.
  Future<Issue> update(
    Object projectId, {
    required int iid,
    required String title,
    required String description,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/issues/$iid',
        data: {'title': title, 'description': description},
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating the issue',
        );
      }
      return Issue.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating the issue');
    }
  }

  /// A single issue by its `iid` — the per-project number a user sees, never
  /// the global `id`.
  Future<Issue> get(Object projectId, {required int iid}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/issues/$iid',
        queryParameters: {'with_labels_details': true},
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the issue',
        );
      }
      return Issue.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the issue');
    }
  }

  static String _enc(Object projectId) =>
      projectId is int ? '$projectId' : Uri.encodeComponent('$projectId');
}
