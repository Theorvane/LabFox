import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/exceptions.dart';
import '../common/paginated.dart';
import '../gitlab_client.dart';
import '../suggestions/suggestion_payload.dart';
import 'positioned_discussion.dart';

/// Which merge requests to list.
enum MergeRequestState {
  opened('opened'),
  merged('merged'),
  closed('closed'),
  all('all');

  const MergeRequestState(this.value);

  final String value;
}

/// Whose merge requests to list on the account-scoped endpoint.
enum MergeRequestScope {
  assignedToMe('assigned_to_me'),
  createdByMe('created_by_me');

  const MergeRequestScope(this.value);

  final String value;
}

/// Review submission outcomes, separate from formal approval.
enum ReviewerSubmissionState {
  reviewed('reviewed'),
  requestedChanges('requested_changes');

  const ReviewerSubmissionState(this.value);
  final String value;
}

/// Merge request endpoints.
class MergeRequestsApi {
  const MergeRequestsApi(this._dio);

  final Dio _dio;

  /// Reads one MR-scoped commit page without substituting project history.
  /// Parent metadata stays unknown when omitted, and returned lists are immutable.
  /// This read is not an atomic membership snapshot or a private-write preflight.
  Future<Paginated<Commit>> commits(
    Object projectId, {
    required int iid,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!((projectId is int && projectId > 0) ||
        (projectId is String && projectId.trim().isNotEmpty))) {
      throw ArgumentError.value(projectId, 'projectId');
    }
    if (iid < 1) throw ArgumentError.value(iid, 'iid');
    if (page < 1) throw ArgumentError.value(page, 'page');
    if (perPage < 1 || perPage > 100) {
      throw ArgumentError.value(perPage, 'perPage');
    }
    try {
      final response = await _dio.get<String>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/commits',
        queryParameters: {'page': page, 'per_page': perPage},
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
        ),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'reading MR commits',
        );
      }
      try {
        final payload = jsonDecode(response.data ?? '');
        if (payload is! List) throw const FormatException();
        final ids = <String>{};
        final items = <Commit>[];
        for (final entry in payload) {
          if (entry is! Map<String, dynamic> || !_validCommitSha(entry['id'])) {
            throw const FormatException();
          }
          final id = entry['id'] as String;
          if (!ids.add(id)) throw const FormatException();
          final parents = entry['parent_ids'];
          if (parents != null) {
            if (parents is! List ||
                parents.any((p) => !_validCommitSha(p) || p == id) ||
                parents.toSet().length != parents.length) {
              throw const FormatException();
            }
          }
          items.add(Commit.fromJson(entry));
        }
        final next = _commitNextPage(response, page, perPage, projectId, iid);
        final metadata = Paginated.fromHeaders(items, response.headers.map);
        return Paginated(
          items: List<Commit>.unmodifiable(items),
          nextPage: next,
          total: metadata.total,
          totalPages: metadata.totalPages,
        );
      } on FormatException {
        throw const GitLabServerException('Invalid MR commits response.');
      } on TypeError {
        throw const GitLabServerException('Invalid MR commits response.');
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'reading MR commits');
    }
  }

  static bool _validCommitSha(Object? value) =>
      value is String &&
      value.length == 40 &&
      !RegExp(r'[^0-9a-f]').hasMatch(value);

  /// Link URLs only provide an offset: the next request keeps the captured route.
  /// Reject contradictory metadata rather than silently truncating membership.
  static int? _commitNextPage(
    Response<String> response,
    int page,
    int perPage,
    Object projectId,
    int iid,
  ) {
    String? single(String key) {
      final values = response.headers[key];
      if (values == null) return null;
      if (values.length != 1) throw const FormatException();
      return values.single;
    }

    int positive(String value) {
      if (value.isEmpty ||
          value.startsWith('0') ||
          RegExp(r'[^0-9]').hasMatch(value)) {
        throw const FormatException();
      }
      final number = int.tryParse(value);
      if (number == null || number < 1) throw const FormatException();
      return number;
    }

    final reportedPage = single('x-page'), reportedSize = single('x-per-page');
    if ((reportedPage != null && positive(reportedPage) != page) ||
        (reportedSize != null && positive(reportedSize) != perPage)) {
      throw const FormatException();
    }
    final rawNext = single('x-next-page');
    final headerNext = rawNext == null || rawNext.isEmpty
        ? null
        : positive(rawNext);
    int? linkNext;
    final links = response.headers['link'];
    if (links != null) {
      for (final value in links) {
        for (final part in value.split(RegExp(r',(?=\s*<)'))) {
          final target = RegExp(r'^\s*<([^<>]+)>(.*)$').firstMatch(part);
          if (target == null) throw const FormatException();
          final suffix = target.group(2)!;
          String? relation;
          var offset = 0;
          for (final attribute in RegExp(
            r';\s*([a-zA-Z][a-zA-Z0-9_-]*)\s*=\s*(?:"([^"]*)"|([!#$%&\x27*+.^_`|~a-zA-Z0-9-]+))',
          ).allMatches(suffix)) {
            if (suffix.substring(offset, attribute.start).trim().isNotEmpty) {
              throw const FormatException();
            }
            offset = attribute.end;
            if (attribute.group(1)!.toLowerCase() == 'anchor') {
              throw const FormatException();
            }
            if (attribute.group(1)!.toLowerCase() == 'rel') {
              if (relation != null) throw const FormatException();
              relation = attribute.group(2) ?? attribute.group(3);
            }
          }
          if (suffix.substring(offset).trim().isNotEmpty || relation == null) {
            throw const FormatException();
          }
          final relations = relation.toLowerCase().trim().split(RegExp(r'\s+'));
          if (relation.trim().isEmpty ||
              relations.any(
                (value) =>
                    !RegExp(r'^[a-z][a-z0-9.-]*$').hasMatch(value) &&
                    Uri.tryParse(value)?.hasScheme != true,
              )) {
            throw const FormatException();
          }
          if (!relations.contains('next')) {
            continue;
          }
          if (linkNext != null) throw const FormatException();
          final request = response.requestOptions.uri;
          final uri = request.resolve(target.group(1)!);
          if (uri.scheme != request.scheme ||
              uri.host != request.host ||
              uri.port != request.port ||
              uri.path != request.path ||
              uri.userInfo.isNotEmpty ||
              uri.fragment.isNotEmpty) {
            throw const FormatException();
          }
          final query = uri.queryParametersAll;
          // GitLab repeats route parameters in offset links. Confirm them;
          // only the page offset is used for the next captured-route request.
          bool matchesRouteEcho(String key, String expected) {
            final values = query[key];
            return values == null ||
                (values.length == 1 && values.single == expected);
          }

          if (query.keys.any(
                (key) => !{
                  'page',
                  'per_page',
                  'id',
                  'merge_request_iid',
                }.contains(key),
              ) ||
              !matchesRouteEcho('id', '$projectId') ||
              !matchesRouteEcho('merge_request_iid', '$iid') ||
              query['page']?.length != 1 ||
              query['per_page']?.length != 1 ||
              positive(query['per_page']!.single) != perPage) {
            throw const FormatException();
          }
          linkNext = positive(query['page']!.single);
        }
      }
    }
    if (linkNext != null && rawNext != null && linkNext != headerNext) {
      throw const FormatException();
    }
    if (links != null && headerNext != null && linkNext == null) {
      throw const FormatException();
    }
    final next = linkNext ?? headerNext;
    if (next != null && next <= page) throw const FormatException();
    return next;
  }

  /// Lists a project's merge requests, open by default, most recently updated
  /// first.
  ///
  /// A non-empty [search] filters by title and description server-side.
  Future<Paginated<MergeRequest>> list(
    Object projectId, {
    MergeRequestState state = MergeRequestState.opened,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests',
        queryParameters: {
          if (state != MergeRequestState.all) 'state': state.value,
          if (search != null && search.isNotEmpty) 'search': search,
          'order_by': 'updated_at',
          // Labels as objects with colours, not bare names.
          'with_labels_details': true,
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing merge requests',
        );
      }
      final mrs = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(MergeRequest.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(mrs, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing merge requests');
    }
  }

  /// Lists merge requests assigned to the authenticated user across every
  /// project, open by default and most recently updated first.
  ///
  /// Account-scoped global `/merge_requests`, not a project path; each MR keeps
  /// its `project_id` for routing.
  Future<Paginated<MergeRequest>> listAssignedToMe({
    MergeRequestState state = MergeRequestState.opened,
    int page = 1,
    int perPage = 20,
  }) => listMine(state: state, page: page, perPage: perPage);

  /// Lists the authenticated user's merge requests across every project —
  /// assigned to or created by them.
  Future<Paginated<MergeRequest>> listMine({
    MergeRequestScope scope = MergeRequestScope.assignedToMe,
    MergeRequestState state = MergeRequestState.opened,
    int page = 1,
    int perPage = 20,
  }) {
    return _listGlobal(
      queryParameters: {'scope': scope.value},
      state: state,
      page: page,
      perPage: perPage,
      context: 'listing my merge requests',
    );
  }

  /// Lists open merge requests for which [reviewerUsername] is a requested
  /// reviewer, across every project, most recently updated first.
  ///
  /// A scope cannot express "review requested of me", so this filters by
  /// `reviewer_username` on the global endpoint.
  Future<Paginated<MergeRequest>> listForReview(
    String reviewerUsername, {
    MergeRequestState state = MergeRequestState.opened,
    int page = 1,
    int perPage = 20,
  }) {
    return _listGlobal(
      queryParameters: {'reviewer_username': reviewerUsername},
      state: state,
      page: page,
      perPage: perPage,
      context: 'listing merge requests to review',
    );
  }

  /// Shared body for the account-scoped `/merge_requests` listings, which
  /// differ only by their filter ([queryParameters]).
  Future<Paginated<MergeRequest>> _listGlobal({
    required Map<String, dynamic> queryParameters,
    required MergeRequestState state,
    required int page,
    required int perPage,
    required String context,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/merge_requests',
        queryParameters: {
          ...queryParameters,
          if (state != MergeRequestState.all) 'state': state.value,
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
          context: context,
        );
      }
      final mrs = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(MergeRequest.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(mrs, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: context);
    }
  }

  /// Opens a merge request from [sourceBranch] into [targetBranch].
  ///
  /// `POST /projects/:id/merge_requests` — source, target and title are
  /// required; an empty description is omitted.
  Future<MergeRequest> create(
    Object projectId, {
    required String sourceBranch,
    required String targetBranch,
    required String title,
    String? description,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/merge_requests',
        data: {
          'source_branch': sourceBranch,
          'target_branch': targetBranch,
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
          context: 'creating the merge request',
        );
      }
      return MergeRequest.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating the merge request');
    }
  }

  /// Adds the merge request to the current user's to-do list. Returns null
  /// for GitLab's idempotent 304 when an item already exists.
  Future<Todo?> createTodo(Object projectId, {required int iid}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/todo',
      );
      if (response.statusCode == 304) return null;
      final data = response.data;
      if ((response.statusCode != 200 && response.statusCode != 201) ||
          data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'adding the merge request to your to-do list',
        );
      }
      return Todo.fromJson(data);
    } on DioException catch (error) {
      throw mapError(
        error,
        context: 'adding the merge request to your to-do list',
      );
    }
  }

  /// Closes or reopens a merge request. `PUT` with `state_event`.
  Future<MergeRequest> setOpen(
    Object projectId, {
    required int iid,
    required bool open,
  }) => _update(projectId, iid, {'state_event': open ? 'reopen' : 'close'});

  /// Marks a merge request draft or ready by adding/removing the `Draft: `
  /// title prefix GitLab recognises. [title] is the current title.
  Future<MergeRequest> setDraft(
    Object projectId, {
    required int iid,
    required bool draft,
    required String title,
  }) {
    final stripped = title.replaceFirst(RegExp(r'^(Draft:|WIP:)\s*'), '');
    return _update(projectId, iid, {
      'title': draft ? 'Draft: $stripped' : stripped,
    });
  }

  /// Subscribes or unsubscribes the current user from MR notifications.
  /// GitLab returns 304 when the user is already in the requested state.
  Future<MergeRequest?> setSubscription(
    Object projectId, {
    required int iid,
    required bool subscribed,
  }) async {
    try {
      final action = subscribed ? 'subscribe' : 'unsubscribe';
      final response = await _dio.post<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/$action',
      );
      if (response.statusCode == 304) return null;
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating merge request notifications',
        );
      }
      return MergeRequest.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating merge request notifications');
    }
  }

  Future<MergeRequest> _update(
    Object projectId,
    int iid,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/merge_requests/$iid',
        data: data,
      );
      final body = response.data;
      if (response.statusCode != 200 || body == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating the merge request',
        );
      }
      return MergeRequest.fromJson(body);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating the merge request');
    }
  }

  /// Rebases a merge request's source branch onto its target. `PUT .../rebase`
  /// returns 202 and rebases asynchronously.
  Future<void> rebase(Object projectId, {required int iid}) async {
    try {
      final response = await _dio.put<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/rebase',
      );
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'rebasing the merge request',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'rebasing the merge request');
    }
  }

  /// A single merge request by its `iid`.
  Future<MergeRequest> get(Object projectId, {required int iid}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/merge_requests/$iid',
        queryParameters: {'with_labels_details': true},
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the merge request',
        );
      }
      return MergeRequest.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the merge request');
    }
  }

  /// The files changed by a merge request, as parsed diffs.
  Future<List<FileDiff>> diffs(Object projectId, {required int iid}) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/diffs',
        // unidiff=true guarantees the unified-diff format the parser expects.
        queryParameters: {'unidiff': true},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the merge request diff',
        );
      }
      return (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(FileDiff.fromJson)
          .toList(growable: false);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the merge request diff');
    }
  }

  /// Reads one page of diff versions in the server's order, without fetching
  /// ahead or assuming total counts. Version IDs are distinct from the MR IID.
  Future<Paginated<MergeRequestDiffVersion>> diffVersions(
    Object projectId, {
    required int iid,
    int page = 1,
    int perPage = 20,
  }) async {
    if (iid < 1) throw ArgumentError.value(iid, 'iid');
    if (page < 1) throw ArgumentError.value(page, 'page');
    if (perPage < 1 || perPage > 100) {
      throw ArgumentError.value(perPage, 'perPage');
    }
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/versions',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading merge request diff versions',
        );
      }
      final List<MergeRequestDiffVersion> versions;
      try {
        final payload = response.data;
        if (payload is! List) throw const FormatException();
        versions = payload.map(_decodeDiffVersion).toList(growable: false);
        if (versions.map((version) => version.id).toSet().length !=
            versions.length) {
          throw const FormatException();
        }
      } on FormatException {
        throw const GitLabServerException(
          'Invalid merge request diff versions response.',
        );
      } on TypeError {
        throw const GitLabServerException(
          'Invalid merge request diff versions response.',
        );
      }
      final cursor = response.headers.value('x-next-page');
      if (cursor != null && cursor.isNotEmpty) {
        final next = int.tryParse(cursor);
        if (next == null || next <= page) {
          throw const GitLabServerException(
            'Invalid diff versions pagination.',
          );
        }
      }
      return Paginated.fromHeaders(
        List<MergeRequestDiffVersion>.unmodifiable(versions),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'loading merge request diff versions');
    }
  }

  /// Reads one explicitly selected version, requesting raw unified diff text.
  /// A different returned version is an error, never a current-diff fallback.
  Future<MergeRequestDiffVersion> diffVersion(
    Object projectId, {
    required int iid,
    required int versionId,
  }) async {
    if (iid < 1) throw ArgumentError.value(iid, 'iid');
    if (versionId < 1) throw ArgumentError.value(versionId, 'versionId');
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/versions/$versionId',
        queryParameters: {'unidiff': true},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a merge request diff version',
        );
      }
      try {
        final version = _decodeDiffVersion(response.data);
        if (version.id != versionId) throw const FormatException();
        return version;
      } on FormatException {
        throw const GitLabServerException(
          'Invalid merge request diff version response.',
        );
      } on TypeError {
        throw const GitLabServerException(
          'Invalid merge request diff version response.',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a merge request diff version');
    }
  }

  static MergeRequestDiffVersion _decodeDiffVersion(Object? payload) {
    if (payload is! Map<String, dynamic>) throw const FormatException();
    final id = payload['id'];
    if (id is! int || id < 1) throw const FormatException();
    final mergeRequestId = payload['merge_request_id'];
    if (mergeRequestId != null &&
        (mergeRequestId is! int || mergeRequestId < 1)) {
      throw const FormatException();
    }
    for (final key in [
      'base_commit_sha',
      'start_commit_sha',
      'head_commit_sha',
      'state',
      'real_size',
      'patch_id_sha',
    ]) {
      final value = payload[key];
      if (value != null && value is! String) throw const FormatException();
    }
    final files = payload['diffs'];
    if (files != null) {
      if (files is! List) throw const FormatException();
      for (final file in files) {
        if (file is! Map<String, dynamic>) throw const FormatException();
        for (final key in ['old_path', 'new_path']) {
          final value = file[key];
          if (value is! String || value.isEmpty) throw const FormatException();
        }
        for (final key in ['diff', 'a_mode', 'b_mode']) {
          final value = file[key];
          if (value != null && value is! String) throw const FormatException();
        }
        for (final key in [
          'new_file',
          'deleted_file',
          'renamed_file',
          'collapsed',
          'too_large',
          'generated_file',
        ]) {
          final value = file[key];
          if (value != null && value is! bool) throw const FormatException();
        }
      }
    }
    return MergeRequestDiffVersion.fromJson(payload);
  }

  /// Approves a merge request.
  Future<void> approve(Object projectId, {required int iid}) =>
      _postAction(projectId, iid: iid, action: 'approve');

  /// Removes the current user's approval.
  Future<void> unapprove(Object projectId, {required int iid}) =>
      _postAction(projectId, iid: iid, action: 'unapprove');

  Future<void> _postAction(
    Object projectId, {
    required int iid,
    required String action,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/$action',
      );
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating the approval',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'updating the approval');
    }
  }

  /// Reads one page of the authenticated author's unpublished review notes.
  /// Empty pages can still have a next cursor; no eager pagination or writes.
  Future<Paginated<MergeRequestDraftNote>> draftNotes(
    Object projectId, {
    required int iid,
    int page = 1,
    int perPage = 20,
  }) async {
    if (iid < 1) throw ArgumentError.value(iid, 'iid');
    if (page < 1) throw ArgumentError.value(page, 'page');
    if (perPage < 1 || perPage > 100) {
      throw ArgumentError.value(perPage, 'perPage');
    }
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/draft_notes',
        queryParameters: {'page': page, 'per_page': perPage},
        options: Options(followRedirects: false),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading draft notes',
        );
      }
      final drafts = _parseDraftNotes(response.data);
      final cursors = response.headers['x-next-page'];
      if (cursors != null && cursors.length != 1) {
        throw const GitLabServerException('Invalid draft notes pagination.');
      }
      final cursor = cursors?.single;
      if (cursor != null && cursor.isNotEmpty) {
        final next = int.tryParse(cursor);
        if (next == null || next <= page) {
          throw const GitLabServerException('Invalid draft notes pagination.');
        }
      }
      return Paginated.fromHeaders(drafts, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading draft notes');
    }
  }

  /// Reads review state rather than the nested user's account state.
  Future<Paginated<MergeRequestReviewer>> reviewers(
    Object projectId, {
    required int iid,
    int page = 1,
    int perPage = 20,
  }) async {
    final path = _draftNotesPath(
      projectId,
      iid,
    ).replaceFirst('/draft_notes', '/reviewers');
    if (page < 1) throw ArgumentError.value(page, 'page');
    if (perPage < 1 || perPage > 100) {
      throw ArgumentError.value(perPage, 'perPage');
    }
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: {'page': page, 'per_page': perPage},
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
        ),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading reviewers',
        );
      }
      try {
        final payload = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        if (payload is! List) throw const FormatException();
        final ids = <int>{};
        final items = payload
            .map((entry) {
              if (entry is! Map<String, dynamic> ||
                  entry['user'] is! Map<String, dynamic>) {
                throw const FormatException();
              }
              final user = entry['user'] as Map<String, dynamic>;
              final id = user['id'];
              if (id is! int || id < 1) throw const FormatException();
              final reviewer = MergeRequestReviewer.fromJson(entry);
              if (reviewer.user.id < 1 ||
                  reviewer.state.trim().isEmpty ||
                  !ids.add(reviewer.user.id)) {
                throw const FormatException();
              }
              return reviewer;
            })
            .toList(growable: false);
        final cursors = response.headers['x-next-page'];
        if (cursors != null && cursors.length != 1) {
          throw const FormatException();
        }
        final cursor = cursors?.single;
        if (cursor != null && cursor.isNotEmpty) {
          final next = int.tryParse(cursor);
          if (next == null || next <= page) throw const FormatException();
        }
        return Paginated.fromHeaders(
          List<MergeRequestReviewer>.unmodifiable(items),
          response.headers.map,
        );
      } on FormatException {
        throw const GitLabServerException('Invalid reviewers response.');
      } on TypeError {
        throw const GitLabServerException('Invalid reviewers response.');
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'loading reviewers');
    }
  }

  /// Saves a new unpublished regular or original text-positioned review note.
  /// A failed/unconfirmed response can follow a successful server write. Callers
  /// must inspect pending drafts before an explicit retry; this never replays.
  Future<MergeRequestDraftNote> createDraftNote(
    Object projectId, {
    required int iid,
    required String note,
    DiffNotePosition? position,
  }) async {
    if (iid < 1) throw ArgumentError.value(iid, 'iid');
    if (note.trim().isEmpty) {
      throw ArgumentError('A draft note is required.', 'note');
    }
    if (position != null && !validTextDiscussionPosition(position)) {
      throw ArgumentError(
        'A complete original text position is required.',
        'position',
      );
    }
    try {
      final response = await _dio.post<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/draft_notes',
        data: {
          'note': note,
          'resolve_discussion': false,
          if (position != null)
            'position': positionedDiscussionPayload(position),
        },
        options: Options(
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode == 409 || response.statusCode == 422) {
        throw GitLabConflictException(
          'The draft could not be saved. Reload before retrying.',
          statusCode: response.statusCode,
        );
      }
      if (response.statusCode != 201) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'saving a review draft',
        );
      }
      try {
        final draft = _parseDraftNotes([response.data]).single;
        if (draft.note != note ||
            draft.resolveDiscussion != false ||
            draft.discussionId != null ||
            draft.commitId != null ||
            !_confirmsDraftPosition(position, draft.position) ||
            (position == null && draft.lineCode != null)) {
          throw const GitLabServerException('Unconfirmed draft note creation.');
        }
        return draft;
      } on GitLabServerException {
        throw const GitLabServerException(
          'Invalid draft note creation response.',
        );
      }
    } on DioException catch (error) {
      if (error.response?.statusCode == 409 ||
          error.response?.statusCode == 422) {
        throw GitLabConflictException(
          'The draft could not be saved. Reload before retrying.',
          statusCode: error.response?.statusCode,
        );
      }
      throw mapError(error, context: 'saving a review draft');
    }
  }

  /// Saves an unpublished draft on an explicitly selected original commit diff.
  /// Supports lowercase full SHA-1 IDs and complete text positions only. The
  /// position's head must be the selected commit; no anchor is reconstructed.
  /// Callers confirm commit membership/session freshness and inspect pending
  /// drafts after any uncertain result before offering an explicit retry.
  Future<MergeRequestDraftNote> createCommitDraftNote(
    Object projectId, {
    required int iid,
    required String commitId,
    required String note,
    required DiffNotePosition position,
  }) async {
    final path = _draftNotesPath(projectId, iid);
    if (commitId.length != 40 || RegExp(r'[^0-9a-f]').hasMatch(commitId)) {
      throw ArgumentError(
        'A full lowercase SHA-1 commit ID is required.',
        'commitId',
      );
    }
    if (note.trim().isEmpty) {
      throw ArgumentError('A private review note is required.', 'note');
    }
    if (!validTextDiscussionPosition(position) ||
        position.headSha != commitId) {
      throw ArgumentError(
        'A complete original text position on the selected commit is required.',
        'position',
      );
    }
    try {
      final response = await _dio.post<String>(
        path,
        data: {
          'note': note,
          'commit_id': commitId,
          'resolve_discussion': false,
          'position': positionedDiscussionPayload(position),
        },
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 201) {
        throw _draftMutationStatus(
          response.statusCode,
          response.headers.map,
          'saving a private commit draft',
        );
      }
      try {
        final draft = _parseDraftNotes([
          jsonDecode(response.data ?? ''),
        ]).single;
        if (draft.note != note ||
            draft.commitId != commitId ||
            draft.discussionId != null ||
            draft.resolveDiscussion != false ||
            !_confirmsDraftPosition(position, draft.position)) {
          throw const GitLabServerException(
            'Unconfirmed private commit draft.',
          );
        }
        return draft;
      } on GitLabServerException {
        throw const GitLabServerException(
          'Invalid private commit draft response.',
        );
      } on FormatException {
        throw const GitLabServerException(
          'Invalid private commit draft response.',
        );
      }
    } on DioException catch (error) {
      if (error.response case final response?) {
        throw _draftMutationStatus(
          response.statusCode,
          response.headers.map,
          'saving a private commit draft',
        );
      }
      throw mapError(error, context: 'saving a private commit draft');
    }
  }

  /// Saves an unpublished reply on one existing discussion without resolving it.
  /// This does not reconstruct an anchor or replay an uncertain private write.
  Future<MergeRequestDraftNote> createDraftReply(
    Object projectId, {
    required int iid,
    required String discussionId,
    required String note,
  }) async {
    final path = _draftNotesPath(projectId, iid);
    if (discussionId.trim().isEmpty || note.trim().isEmpty) {
      throw ArgumentError('A discussion and private reply are required.');
    }
    try {
      final response = await _dio.post<String>(
        path,
        data: {
          'note': note,
          'in_reply_to_discussion_id': discussionId,
          'resolve_discussion': false,
        },
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 201) {
        throw _draftMutationStatus(
          response.statusCode,
          response.headers.map,
          'saving a private reply',
        );
      }
      try {
        final draft = _parseDraftNotes([
          jsonDecode(response.data ?? ''),
        ]).single;
        if (draft.note != note ||
            draft.discussionId != discussionId ||
            draft.resolveDiscussion != false ||
            draft.commitId != null ||
            draft.lineCode != null ||
            !_confirmsDraftPosition(null, draft.position)) {
          throw const GitLabServerException('Unconfirmed private reply.');
        }
        return draft;
      } on GitLabServerException {
        throw const GitLabServerException('Invalid private reply response.');
      } on FormatException {
        throw const GitLabServerException('Invalid private reply response.');
      }
    } on DioException catch (error) {
      if (error.response case final response?) {
        throw _draftMutationStatus(
          response.statusCode,
          response.headers.map,
          'saving a private reply',
        );
      }
      throw mapError(error, context: 'saving a private reply');
    }
  }

  /// Updates exact private Markdown, preserving a supplied original text anchor.
  /// Positioned callers must resend the original position: omission can clear it.
  /// A failed/unconfirmed response requires inspection, never automatic replay.
  Future<MergeRequestDraftNote> updateDraftNote(
    Object projectId, {
    required int iid,
    required int draftNoteId,
    required String note,
    DiffNotePosition? position,
  }) async {
    final path = _draftNotePath(projectId, iid, draftNoteId);
    if (note.trim().isEmpty) {
      throw ArgumentError('A draft note is required.', 'note');
    }
    if (position != null && !validTextDiscussionPosition(position)) {
      throw ArgumentError(
        'A complete original text position is required.',
        'position',
      );
    }
    try {
      final response = await _dio.put<String>(
        path,
        data: {
          'note': note,
          if (position != null)
            'position': positionedDiscussionPayload(position),
        },
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 200) {
        throw _draftMutationStatus(
          response.statusCode,
          response.headers.map,
          'updating a review draft',
        );
      }
      try {
        final draft = _parseDraftNotes([
          jsonDecode(response.data ?? ''),
        ]).single;
        if (draft.id != draftNoteId ||
            draft.note != note ||
            !_confirmsDraftPosition(position, draft.position) ||
            (position == null && draft.lineCode != null)) {
          throw const GitLabServerException('Unconfirmed draft note update.');
        }
        return draft;
      } on GitLabServerException {
        throw const GitLabServerException(
          'Invalid draft note update response.',
        );
      } on FormatException {
        throw const GitLabServerException(
          'Invalid draft note update response.',
        );
      }
    } on DioException catch (error) {
      if (error.response case final response?) {
        throw _draftMutationStatus(
          response.statusCode,
          response.headers.map,
          'updating a review draft',
        );
      }
      throw mapError(error, context: 'updating a review draft');
    }
  }

  /// Deletes only the addressed unpublished note; a 404 is not confirmation.
  /// Callers still validate fresh ownership and inspect an uncertain outcome.
  Future<void> deleteDraftNote(
    Object projectId, {
    required int iid,
    required int draftNoteId,
  }) async {
    final path = _draftNotePath(projectId, iid, draftNoteId);
    try {
      final response = await _dio.delete<dynamic>(
        path,
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 204) {
        throw _draftMutationStatus(
          response.statusCode,
          response.headers.map,
          'deleting a review draft',
        );
      }
    } on DioException catch (error) {
      if (error.response case final response?) {
        throw _draftMutationStatus(
          response.statusCode,
          response.headers.map,
          'deleting a review draft',
        );
      }
      throw mapError(error, context: 'deleting a review draft');
    }
  }

  /// Publishes one owned saved draft by identity; acknowledges only HTTP 204.
  /// Sends no body or reviewer-state update request.
  Future<void> publishDraftNote(
    Object projectId, {
    required int iid,
    required int draftNoteId,
  }) async {
    final path = '${_draftNotePath(projectId, iid, draftNoteId)}/publish';
    try {
      final response = await _dio.put<dynamic>(
        path,
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 204) {
        throw _draftMutationStatus(
          response.statusCode,
          response.headers.map,
          'publishing a review draft',
        );
      }
    } on DioException catch (error) {
      if (error.response case final response?) {
        throw _draftMutationStatus(
          response.statusCode,
          response.headers.map,
          'publishing a review draft',
        );
      }
      throw mapError(error, context: 'publishing a review draft');
    }
  }

  /// Publishes all saved notes owned by the authenticated user, once.
  /// GitLab does not accept a conditional list of selected draft IDs here.
  Future<void> publishDraftNotes(
    Object projectId, {
    required int iid,
    String? summaryNote,
    ReviewerSubmissionState? reviewerState,
  }) async {
    final path = '${_draftNotesPath(projectId, iid)}/bulk_publish';
    if (summaryNote != null && summaryNote.trim().isEmpty) {
      throw ArgumentError(
        'A supplied public summary must not be blank.',
        'summaryNote',
      );
    }
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: summaryNote == null && reviewerState == null
            ? null
            : {
                'note': ?summaryNote,
                if (summaryNote != null) 'internal': false,
                if (reviewerState != null)
                  'reviewer_state': reviewerState.value,
              },
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 204) {
        throw _draftMutationStatus(
          response.statusCode,
          response.headers.map,
          'publishing a pending review',
        );
      }
    } on DioException catch (error) {
      if (error.response case final response?) {
        throw _draftMutationStatus(
          response.statusCode,
          response.headers.map,
          'publishing a pending review',
        );
      }
      throw mapError(error, context: 'publishing a pending review');
    }
  }

  static String _draftNotePath(Object projectId, int iid, int draftNoteId) {
    final path = _draftNotesPath(projectId, iid);
    if (draftNoteId < 1) throw ArgumentError.value(draftNoteId, 'draftNoteId');
    return '$path/$draftNoteId';
  }

  static String _draftNotesPath(Object projectId, int iid) {
    if (!((projectId is int && projectId > 0) ||
        (projectId is String && projectId.trim().isNotEmpty))) {
      throw ArgumentError.value(projectId, 'projectId');
    }
    if (iid < 1) throw ArgumentError.value(iid, 'iid');
    return '/projects/${_enc(projectId)}/merge_requests/$iid/draft_notes';
  }

  static GitLabException _draftMutationStatus(
    int? status,
    Map<String, List<String>> headers,
    String context,
  ) => switch (status) {
    409 || 412 || 422 => GitLabConflictException(
      'The draft changed or could not be modified. Reload before retrying.',
      statusCode: status,
    ),
    _ => mapStatus(status, headers, context: context),
  };

  static bool _confirmsDraftPosition(
    DiffNotePosition? expected,
    DiffNotePosition? returned,
  ) {
    if (expected == null) {
      // GitLab represents a regular draft with null/empty text coordinates.
      return returned == null ||
          ((returned.positionType == null || returned.positionType == 'text') &&
              [
                returned.baseSha,
                returned.startSha,
                returned.headSha,
                returned.oldPath,
                returned.newPath,
                returned.oldLine,
                returned.newLine,
                returned.lineRange,
                returned.width,
                returned.height,
                returned.x,
                returned.y,
              ].every((field) => field == null));
    }
    return returned != null &&
        validTextDiscussionPosition(returned) &&
        returned.baseSha == expected.baseSha &&
        returned.startSha == expected.startSha &&
        returned.headSha == expected.headSha &&
        returned.oldPath == expected.oldPath &&
        returned.newPath == expected.newPath &&
        returned.oldLine == expected.oldLine &&
        returned.newLine == expected.newLine &&
        sameDiscussionRange(expected.lineRange, returned.lineRange);
  }

  static List<MergeRequestDraftNote> _parseDraftNotes(Object? payload) {
    try {
      if (payload is! List) throw const FormatException();
      final ids = <int>{};
      int? mergeRequestId;
      final drafts = <MergeRequestDraftNote>[];
      for (final entry in payload) {
        if (entry is! Map<String, dynamic>) throw const FormatException();
        for (final key in ['id', 'author_id', 'merge_request_id']) {
          final value = entry[key];
          if (value is! int || value < 1) throw const FormatException();
        }
        if (!ids.add(entry['id'] as int)) throw const FormatException();
        mergeRequestId ??= entry['merge_request_id'] as int;
        if (entry['merge_request_id'] != mergeRequestId) {
          throw const FormatException();
        }
        if (entry['note'] is! String) throw const FormatException();
        final resolve = entry['resolve_discussion'];
        if (resolve != null && resolve is! bool) throw const FormatException();
        _validatePositionStrings(entry, [
          'discussion_id',
          'commit_id',
          'line_code',
        ]);
        _validateDiffPosition(entry['position']);
        drafts.add(MergeRequestDraftNote.fromJson(entry));
      }
      return List<MergeRequestDraftNote>.unmodifiable(drafts);
    } on FormatException {
      throw const GitLabServerException('Invalid draft notes response.');
    } on TypeError {
      throw const GitLabServerException('Invalid draft notes response.');
    }
  }

  /// Reads one page of discussion groups, including replies absent from notes.
  /// No total count is assumed; callers follow the returned next-page cursor.
  Future<Paginated<Discussion>> discussions(
    Object projectId, {
    required int iid,
    int page = 1,
    int perPage = 20,
  }) async {
    if (page < 1) throw ArgumentError.value(page, 'page');
    if (perPage < 1 || perPage > 100) {
      throw ArgumentError.value(perPage, 'perPage');
    }
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/discussions',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading discussions',
        );
      }
      final discussions = _parseDiscussions(response.data);
      final cursor = response.headers.value('x-next-page');
      if (cursor != null && cursor.isNotEmpty) {
        final next = int.tryParse(cursor);
        if (next == null || next <= page) {
          throw const GitLabServerException('Invalid discussions pagination.');
        }
      }
      return Paginated.fromHeaders(
        List<Discussion>.unmodifiable(discussions),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'loading discussions');
    }
  }

  /// Fetches one authoritative discussion without following redirects.
  /// Read-only OAuth refresh remains available through the account-bound client.
  Future<Discussion> discussion(
    Object projectId, {
    required int iid,
    required String discussionId,
  }) async {
    if (iid < 1) throw ArgumentError.value(iid, 'iid');
    if (discussionId.trim().isEmpty) {
      throw ArgumentError('A discussion ID is required.', 'discussionId');
    }
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/discussions/'
        '${Uri.encodeComponent(discussionId)}',
        options: Options(followRedirects: false),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'reading a discussion',
        );
      }
      try {
        final result = _parseDiscussions([response.data]).single;
        if (result.id != discussionId) {
          throw const GitLabServerException('Unconfirmed discussion.');
        }
        return result;
      } on GitLabServerException {
        throw const GitLabServerException('Invalid discussion response.');
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'reading a discussion');
    }
  }

  /// Adds a reply to an existing discussion, using its string thread ID.
  ///
  /// Preserves nonempty Markdown exactly. A write is never automatically
  /// replayed after authentication failure; callers can offer explicit retry.
  Future<Note> replyToDiscussion(
    Object projectId, {
    required int iid,
    required String discussionId,
    required String body,
  }) async {
    if (iid < 1) throw ArgumentError.value(iid, 'iid');
    if (discussionId.trim().isEmpty) {
      throw ArgumentError('A discussion ID is required.', 'discussionId');
    }
    if (body.trim().isEmpty) {
      throw ArgumentError('A reply body is required.', 'body');
    }
    try {
      final response = await _dio.post<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/discussions/'
        '${Uri.encodeComponent(discussionId)}/notes',
        data: {'body': body},
        options: Options(extra: {'labfox_no_auth_retry': true}),
      );
      if (response.statusCode != 201) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'replying to a discussion',
        );
      }
      return _parseDiscussionReply(response.data);
    } on DioException catch (error) {
      throw mapError(error, context: 'replying to a discussion');
    }
  }

  /// Creates a text discussion on an explicitly supplied original diff line or range.
  ///
  /// Callers obtain the SHA triplet and coordinates from the selected version.
  /// Markdown and paths are preserved; unsupported anchors are never guessed.
  /// An unconfirmed response may follow a successful write, so retry is explicit.
  Future<Discussion> createPositionedDiscussion(
    Object projectId, {
    required int iid,
    required String body,
    required DiffNotePosition position,
  }) async {
    if (iid < 1) throw ArgumentError.value(iid, 'iid');
    if (body.trim().isEmpty) {
      throw ArgumentError('A discussion body is required.', 'body');
    }
    if (!validTextDiscussionPosition(position)) {
      throw ArgumentError(
        'A complete original text position is required.',
        'position',
      );
    }
    try {
      final response = await _dio.post<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/discussions',
        data: {'body': body, 'position': positionedDiscussionPayload(position)},
        options: Options(
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 201) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating a positioned discussion',
        );
      }
      try {
        final discussion = _parseDiscussions([response.data]).single;
        if (discussion.id.trim().isEmpty ||
            discussion.individualNote ||
            discussion.notes.isEmpty) {
          throw const GitLabServerException(
            'Unconfirmed positioned discussion.',
          );
        }
        final root = discussion.notes.first;
        final returned = root.position;
        if (root.isSystem != false ||
            root.type != 'DiffNote' ||
            returned == null ||
            returned.positionType != position.positionType ||
            returned.baseSha != position.baseSha ||
            returned.startSha != position.startSha ||
            returned.headSha != position.headSha ||
            returned.oldPath != position.oldPath ||
            returned.newPath != position.newPath ||
            returned.oldLine != position.oldLine ||
            returned.newLine != position.newLine ||
            !validMultilinePosition(returned) ||
            !sameDiscussionRange(position.lineRange, returned.lineRange)) {
          throw const GitLabServerException(
            'Unconfirmed positioned discussion.',
          );
        }
        return discussion;
      } on GitLabServerException {
        throw const GitLabServerException(
          'Invalid positioned discussion response.',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'creating a positioned discussion');
    }
  }

  /// Resolves or reopens a discussion and confirms its updated server state.
  /// The mutation is never redirected or replayed after authentication failure.
  Future<Discussion> setDiscussionResolved(
    Object projectId, {
    required int iid,
    required String discussionId,
    required bool resolved,
  }) async {
    if (iid < 1) throw ArgumentError.value(iid, 'iid');
    if (discussionId.trim().isEmpty) {
      throw ArgumentError('A discussion ID is required.', 'discussionId');
    }
    try {
      final response = await _dio.put<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/discussions/'
        '${Uri.encodeComponent(discussionId)}',
        data: {'resolved': resolved},
        options: Options(
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating discussion resolution',
        );
      }
      try {
        final discussion = _parseDiscussions([response.data]).single;
        final notes = discussion.notes.where((note) => note.resolvable == true);
        if (discussion.id != discussionId ||
            notes.isEmpty ||
            notes.any((note) => note.resolved != resolved)) {
          throw const GitLabServerException('Unconfirmed discussion state.');
        }
        return discussion;
      } on GitLabServerException {
        throw const GitLabServerException(
          'Invalid discussion resolution response.',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'updating discussion resolution');
    }
  }

  static Note _parseDiscussionReply(Object? payload) {
    try {
      if (payload is! Map<String, dynamic>) throw const FormatException();
      final id = payload['id'];
      if (id is! int || id <= 0) throw const FormatException();
      for (final key in ['author', 'resolved_by']) {
        final user = payload[key];
        if (user == null) continue;
        if (user is! Map<String, dynamic>) throw const FormatException();
        final userId = user['id'];
        if (userId is! int || userId <= 0) throw const FormatException();
      }
      _validateDiffPosition(payload['position']);
      validateSuggestionPayloads(payload['suggestions']);
      return Note.fromJson(payload);
    } on FormatException {
      throw const GitLabServerException('Invalid discussion reply response.');
    } on TypeError {
      throw const GitLabServerException('Invalid discussion reply response.');
    }
  }

  // Generated integer parsing accepts fractional numbers via toInt(). Validate
  // coordinates first so a malformed response can never point to another line.
  static void _validateDiffPosition(Object? value) {
    if (value == null) return;
    if (value is! Map<String, dynamic>) throw const FormatException();
    _validatePositionStrings(value, [
      'base_sha',
      'start_sha',
      'head_sha',
      'old_path',
      'new_path',
      'position_type',
    ]);
    _validatePositionIntegers(value, [
      'old_line',
      'new_line',
      'width',
      'height',
    ]);
    for (final key in ['x', 'y']) {
      final coordinate = value[key];
      if (coordinate != null &&
          (coordinate is! num || !coordinate.isFinite || coordinate < 0)) {
        throw const FormatException();
      }
    }
    final range = value['line_range'];
    if (range == null) return;
    if (range is! Map<String, dynamic>) throw const FormatException();
    for (final key in ['start', 'end']) {
      final endpoint = range[key];
      if (endpoint == null) continue;
      if (endpoint is! Map<String, dynamic>) throw const FormatException();
      _validatePositionStrings(endpoint, ['line_code', 'type']);
      _validatePositionIntegers(endpoint, ['old_line', 'new_line']);
    }
  }

  static void _validatePositionStrings(
    Map<String, dynamic> fields,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = fields[key];
      if (value != null && value is! String) throw const FormatException();
    }
  }

  static void _validatePositionIntegers(
    Map<String, dynamic> fields,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = fields[key];
      if (value != null && (value is! int || value < 1)) {
        throw const FormatException();
      }
    }
  }

  static List<Discussion> _parseDiscussions(Object? payload) {
    try {
      if (payload is! List) throw const FormatException();
      final suggestionIds = <int>{};
      return payload
          .map((entry) {
            if (entry is! Map<String, dynamic>) throw const FormatException();
            final id = entry['id'];
            if (id is! String || id.isEmpty) throw const FormatException();
            final notes = entry['notes'];
            if (notes is! List) throw const FormatException();
            for (final note in notes) {
              if (note is! Map<String, dynamic>) throw const FormatException();
              _validateDiffPosition(note['position']);
              validateSuggestionPayloads(
                note['suggestions'],
                seenIds: suggestionIds,
              );
              final noteId = note['id'];
              if (noteId is! int || noteId <= 0) throw const FormatException();
              for (final key in ['author', 'resolved_by']) {
                final user = note[key];
                if (user == null) continue;
                if (user is! Map<String, dynamic>) {
                  throw const FormatException();
                }
                final userId = user['id'];
                if (userId is! int || userId <= 0) {
                  throw const FormatException();
                }
              }
            }
            return Discussion.fromJson(entry);
          })
          .toList(growable: false);
    } on FormatException {
      throw const GitLabServerException('Invalid discussions response.');
    } on TypeError {
      throw const GitLabServerException('Invalid discussions response.');
    }
  }

  /// The approval state of a merge request.
  ///
  /// Incomplete successful responses are failures, never an empty approval
  /// state. Every wrapper must contain a valid user so ownership is reliable.
  Future<MergeRequestApprovals> approvals(
    Object projectId, {
    required int iid,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/approvals',
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading approvals',
        );
      }
      return _parseApprovals(response.data);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading approvals');
    }
  }

  static MergeRequestApprovals _parseApprovals(Object? payload) {
    try {
      if (payload is! Map<String, dynamic>) throw const FormatException();
      final approvedBy = payload['approved_by'];
      if (approvedBy is! List) throw const FormatException();
      if (payload.containsKey('approvals_required')) {
        final required = payload['approvals_required'];
        if (required is! int || required < 0) throw const FormatException();
      }
      for (final entry in approvedBy) {
        if (entry is! Map<String, dynamic>) throw const FormatException();
        final user = entry['user'];
        if (user is! Map<String, dynamic>) throw const FormatException();
        // Generated numeric deserialization can truncate fractional IDs.
        final userId = user['id'];
        if (userId is! int || userId <= 0) throw const FormatException();
      }
      return MergeRequestApprovals.fromJson(payload);
    } on FormatException {
      throw const GitLabServerException('Invalid approvals response.');
    } on TypeError {
      // Never expose server values, user records or raw parsing errors.
      throw const GitLabServerException('Invalid approvals response.');
    }
  }

  /// Merges a merge request and returns the updated (merged) resource.
  ///
  /// When [squash] is true, GitLab squashes the commits into one on merge.
  ///
  /// A 405/406/409 means the request is not mergeable in its current state —
  /// distinct from a 403 (no permission) — so it maps to its own exception the
  /// UI can explain.
  Future<MergeRequest> merge(
    Object projectId, {
    required int iid,
    bool squash = false,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/merge',
        queryParameters: {if (squash) 'squash': true},
      );
      final status = response.statusCode ?? 0;
      if (status == 405 || status == 406 || status == 409) {
        throw GitLabNotMergeableException(
          'This merge request cannot be merged in its current state.',
          statusCode: status,
        );
      }
      final data = response.data;
      if (status != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'merging',
        );
      }
      return MergeRequest.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'merging');
    }
  }

  static String _enc(Object projectId) =>
      projectId is int ? '$projectId' : Uri.encodeComponent('$projectId');
}
