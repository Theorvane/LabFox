import 'package:dio/dio.dart';

import 'common/exceptions.dart';
import 'container_registry/container_immutability_api.dart';
import 'container_registry/container_registry_api.dart';
import 'deployments/deployments_api.dart';
import 'environments/environments_api.dart';
import 'environments/protected_environments_api.dart';
import 'events/events_api.dart';
import 'graphql/graphql_api.dart';
import 'groups/group_protected_environments_api.dart';
import 'groups/groups_api.dart';
import 'issues/issue_links_api.dart';
import 'issues/issues_api.dart';
import 'jobs/jobs_api.dart';
import 'labels/group_labels_api.dart';
import 'labels/project_labels_api.dart';
import 'members/group_members_api.dart';
import 'members/project_members_api.dart';
import 'merge_requests/merge_requests_api.dart';
import 'milestones/group_milestones_api.dart';
import 'milestones/milestones_api.dart';
import 'notes/notes_api.dart';
import 'packages/packages_api.dart';
import 'pipeline_schedules/pipeline_schedules_api.dart';
import 'pipelines/pipelines_api.dart';
import 'projects/projects_api.dart';
import 'releases/releases_api.dart';
import 'repository/protected_branches_api.dart';
import 'repository/protected_tags_api.dart';
import 'repository/repository_api.dart';
import 'search/search_api.dart';
import 'snippets/snippets_api.dart';
import 'todos/todos_api.dart';
import 'users/users_api.dart';
import 'wikis/wikis_api.dart';

/// Account-bound entry point for GitLab REST and selected GraphQL queries.
///
/// One client is bound to one account: a base URL and a token. Switching
/// accounts means building a new client, never mutating this one, so a request
/// in flight cannot end up authenticated as somebody else.
class GitLabClient {
  /// [bearer] selects how the token is sent: a personal access token goes in
  /// the `PRIVATE-TOKEN` header, an OAuth access token as `Authorization:
  /// Bearer`. The rest of the client is identical.
  GitLabClient({
    required String baseUrl,
    required String token,
    bool bearer = false,
    Future<String?> Function()? onUnauthorized,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = apiBaseUrl(baseUrl)
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      ..headers[bearer ? 'Authorization' : 'PRIVATE-TOKEN'] = bearer
          ? 'Bearer $token'
          : token
      // GitLab returns 4xx as a normal response so error bodies can be read
      // and turned into domain exceptions rather than raw transport errors.
      ..validateStatus = (status) => status != null && status < 500;

    final graphqlEndpoint = graphqlApiUrl(baseUrl);
    // GitLab documents PAT header authentication using Bearer as well as
    // OAuth. Convert only this endpoint's request copy, never REST defaults.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          if (request.uri.toString() == graphqlEndpoint) {
            final pat = request.headers['PRIVATE-TOKEN'];
            request.headers.remove('PRIVATE-TOKEN');
            if (pat != null) request.headers['Authorization'] = 'Bearer $pat';
          }
          handler.next(request);
        },
      ),
    );
    graphql = GraphQLApi(_dio, endpoint: graphqlEndpoint);
    containerImmutability = ContainerImmutabilityApi(graphql);

    if (bearer && onUnauthorized != null) {
      _installRefreshRetry(onUnauthorized);
    }

    users = UsersApi(_dio);
    groups = GroupsApi(_dio);
    groupProtectedEnvironments = GroupProtectedEnvironmentsApi(_dio);
    containerRegistry = ContainerRegistryApi(_dio);
    deployments = DeploymentsApi(_dio);
    environments = EnvironmentsApi(_dio);
    protectedEnvironments = ProtectedEnvironmentsApi(_dio);
    events = EventsApi(_dio);
    projects = ProjectsApi(_dio);
    repository = RepositoryApi(_dio);
    protectedBranches = ProtectedBranchesApi(_dio);
    protectedTags = ProtectedTagsApi(_dio);
    releases = ReleasesApi(_dio);
    issues = IssuesApi(_dio);
    issueLinks = IssueLinksApi(_dio);
    mergeRequests = MergeRequestsApi(_dio);
    groupLabels = GroupLabelsApi(_dio);
    groupMembers = GroupMembersApi(_dio);
    projectMembers = ProjectMembersApi(_dio);
    milestones = MilestonesApi(_dio);
    groupMilestones = GroupMilestonesApi(_dio);
    notes = NotesApi(_dio);
    packages = PackagesApi(_dio);
    pipelineSchedules = PipelineSchedulesApi(_dio);
    pipelines = PipelinesApi(_dio);
    jobs = JobsApi(_dio);
    projectLabels = ProjectLabelsApi(_dio);
    todos = TodosApi(_dio);
    search = SearchApi(_dio);
    snippets = SnippetsApi(_dio);
    wikis = WikisApi(_dio);
  }

  final Dio _dio;

  /// Shared across concurrent 401s so the token is refreshed once, not once per
  /// in-flight request.
  Future<String?>? _refreshInFlight;

  /// On a 401 for a Bearer client, refreshes the token once and retries the
  /// request with it. A request that used a token another request has already
  /// refreshed skips the refresh and just retries with the current one.
  void _installRefreshRetry(Future<String?> Function() onUnauthorized) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) async {
          final request = response.requestOptions;
          if (response.statusCode != 401 ||
              request.extra['labfox_retried'] == true) {
            return handler.next(response);
          }

          final usedAuth = request.headers['Authorization'];
          final currentAuth = _dio.options.headers['Authorization'];
          String? retryAuth;
          if (usedAuth == currentAuth) {
            // This request used the live token, so a refresh is genuinely
            // needed. Concurrent 401s share the one in-flight refresh.
            final fresh = await (_refreshInFlight ??= onUnauthorized());
            _refreshInFlight = null;
            if (fresh == null) {
              return handler.next(response);
            }
            retryAuth = 'Bearer $fresh';
            _dio.options.headers['Authorization'] = retryAuth;
          } else {
            // Another request already refreshed; retry with the newer token
            // rather than refreshing again.
            retryAuth = currentAuth as String?;
            if (retryAuth == null) {
              return handler.next(response);
            }
          }

          try {
            request.extra['labfox_retried'] = true;
            request.headers['Authorization'] = retryAuth;
            final retried = await _dio.fetch<dynamic>(request);
            return handler.resolve(retried);
          } catch (_) {
            return handler.next(response);
          }
        },
      ),
    );
  }

  late final UsersApi users;
  late final GraphQLApi graphql;
  late final ContainerImmutabilityApi containerImmutability;
  late final GroupsApi groups;
  late final GroupProtectedEnvironmentsApi groupProtectedEnvironments;
  late final ContainerRegistryApi containerRegistry;
  late final DeploymentsApi deployments;
  late final EnvironmentsApi environments;
  late final ProtectedEnvironmentsApi protectedEnvironments;
  late final EventsApi events;
  late final ProjectsApi projects;
  late final RepositoryApi repository;
  late final ProtectedBranchesApi protectedBranches;
  late final ProtectedTagsApi protectedTags;
  late final ReleasesApi releases;
  late final IssuesApi issues;
  late final IssueLinksApi issueLinks;
  late final MergeRequestsApi mergeRequests;
  late final ProjectMembersApi projectMembers;
  late final GroupMembersApi groupMembers;
  late final MilestonesApi milestones;
  late final GroupMilestonesApi groupMilestones;
  late final NotesApi notes;
  late final PackagesApi packages;
  late final PipelinesApi pipelines;
  late final PipelineSchedulesApi pipelineSchedules;
  late final JobsApi jobs;
  late final ProjectLabelsApi projectLabels;
  late final GroupLabelsApi groupLabels;
  late final TodosApi todos;
  late final SearchApi search;
  late final SnippetsApi snippets;
  late final WikisApi wikis;

  /// Derives the REST endpoint from an instance URL.
  ///
  /// The instance URL comes from the user, so `gitlab.com` is never hardcoded:
  /// `https://git.company.com` becomes `https://git.company.com/api/v4`.
  /// Trailing slashes are tolerated because people paste them.
  static String apiBaseUrl(String instanceUrl) {
    final trimmed = instanceUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        instanceUrl,
        'instanceUrl',
        'must not be empty',
      );
    }
    if (trimmed.endsWith('/api/v4')) {
      return trimmed;
    }
    return '$trimmed/api/v4';
  }

  /// Derives the sibling GraphQL endpoint without losing a subpath install.
  static String graphqlApiUrl(String instanceUrl) {
    final rest = apiBaseUrl(instanceUrl);
    return '${rest.substring(0, rest.length - '/api/v4'.length)}/api/graphql';
  }

  void close() => _dio.close();
}

/// Translates a transport or HTTP failure into a [GitLabException].
///
/// Lives next to the client so every API surface reports failures the same way.
GitLabException mapError(Object error, {String? context}) {
  final where = context == null ? '' : ' while $context';

  if (error is DioException) {
    final response = error.response;
    if (response == null) {
      return GitLabConnectionException(
        'Could not reach the GitLab instance$where. Check the instance URL, '
        'your network, and whether the certificate is trusted.',
      );
    }
    return mapStatus(
      response.statusCode,
      response.headers.map,
      context: context,
    );
  }

  return GitLabServerException('Unexpected error$where: $error');
}

/// Translates a status code into a [GitLabException].
GitLabException mapStatus(
  int? status,
  Map<String, List<String>> headers, {
  String? context,
}) {
  final where = context == null ? '' : ' while $context';

  switch (status) {
    case 401:
      return GitLabAuthException(
        'The token was rejected$where. It may be expired or revoked.',
        statusCode: status,
      );
    case 403:
      return GitLabForbiddenException(
        'The token lacks permission$where. Check its scopes and your role.',
        statusCode: status,
      );
    case 404:
      return GitLabNotFoundException(
        'Not found$where. The resource may not exist, or the token may not be '
        'allowed to see it.',
        statusCode: status,
      );
    case 429:
      final raw = headers['retry-after']?.firstOrNull;
      final seconds = raw == null ? null : int.tryParse(raw);
      return GitLabRateLimitException(
        'Rate limited$where.',
        statusCode: status,
        retryAfter: seconds == null ? null : Duration(seconds: seconds),
      );
    default:
      return GitLabServerException(
        'The GitLab instance returned $status$where.',
        statusCode: status,
      );
  }
}
