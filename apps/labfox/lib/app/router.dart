import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/ads/ads_providers.dart';
import '../core/analytics/analytics.dart';
import '../core/auth/auth_controller.dart';
import '../core/auth/auth_state.dart';
import '../features/activity/presentation/project_activity_screen.dart';
import '../features/auth/presentation/accounts_screen.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/branches/presentation/branches_screen.dart';
import '../features/commits/presentation/commit_detail_screen.dart';
import '../features/commits/presentation/commits_screen.dart';
import '../features/container_registry/presentation/container_cleanup_policy_screen.dart';
import '../features/container_registry/presentation/container_registry_screen.dart';
import '../features/container_registry/presentation/container_repository_screen.dart';
import '../features/container_registry/presentation/container_tag_protection_screen.dart';
import '../features/container_registry/presentation/container_tag_screen.dart';
import '../features/deployments/presentation/deployment_detail_screen.dart';
import '../features/deployments/presentation/deployments_screen.dart';
import '../features/diff/presentation/changes_screen.dart';
import '../features/diff/presentation/controllers/diff_controllers.dart';
import '../features/environments/presentation/environment_detail_screen.dart';
import '../features/environments/presentation/environments_screen.dart';
import '../features/groups/presentation/group_detail_screen.dart';
import '../features/groups/presentation/groups_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/inbox/presentation/inbox_screen.dart';
import '../features/issues/presentation/issue_detail_screen.dart';
import '../features/issues/presentation/issues_screen.dart';
import '../features/issues/presentation/my_issues_screen.dart';
import '../features/issues/presentation/new_issue_screen.dart';
import '../features/jobs/presentation/job_detail_screen.dart';
import '../features/members/presentation/project_members_screen.dart';
import '../features/merge_requests/presentation/merge_request_detail_screen.dart';
import '../features/merge_requests/presentation/merge_requests_screen.dart';
import '../features/merge_requests/presentation/my_merge_requests_screen.dart';
import '../features/merge_requests/presentation/new_merge_request_screen.dart';
import '../features/milestones/presentation/milestone_detail_screen.dart';
import '../features/milestones/presentation/milestones_screen.dart';
import '../features/package_registry/presentation/package_detail_screen.dart';
import '../features/package_registry/presentation/package_list_screen.dart';
import '../features/pipeline_schedules/presentation/pipeline_schedule_detail_screen.dart';
import '../features/pipeline_schedules/presentation/pipeline_schedules_screen.dart';
import '../features/pipelines/presentation/pipeline_detail_screen.dart';
import '../features/pipelines/presentation/pipelines_screen.dart';
import '../features/profile/presentation/me_screen.dart';
import '../features/project_labels/presentation/project_labels_screen.dart';
import '../features/project_overview/presentation/project_overview_screen.dart';
import '../features/projects/presentation/projects_screen.dart';
import '../features/protected_branches/presentation/protected_branch_detail_screen.dart';
import '../features/protected_branches/presentation/protected_branches_screen.dart';
import '../features/protected_environments/presentation/protected_environment_detail_screen.dart';
import '../features/protected_environments/presentation/protected_environments_screen.dart';
import '../features/protected_tags/presentation/protected_tag_detail_screen.dart';
import '../features/protected_tags/presentation/protected_tags_screen.dart';
import '../features/releases/presentation/release_detail_screen.dart';
import '../features/releases/presentation/releases_screen.dart';
import '../features/repository/presentation/file_viewer_screen.dart';
import '../features/repository/presentation/repository_browser_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/privacy_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/subscription_screen.dart';
import '../features/shell/presentation/app_shell.dart';
import '../features/snippets/presentation/snippets_screen.dart';
import '../features/tags/presentation/tags_screen.dart';
import '../features/wiki/presentation/wiki_page_screen.dart';
import '../features/wiki/presentation/wiki_pages_screen.dart';

/// Route paths.
///
/// Paths mirror GitLab's own URL shape so a deep link from the web can map
/// straight onto a screen. The number in a merge request or issue path is the
/// `iid`, the per-project number a user sees, never the global `id`.
abstract final class Routes {
  static const String home = '/';
  static const String signIn = '/sign-in';
  static const String accounts = '/accounts';
  // Reuses the sign-in screen to add another account while already signed in.
  static const String addAccount = '/sign-in?add=1';
  static const String inbox = '/inbox';
  static const String search = '/search';
  static const String me = '/me';
  static const String settings = '/settings';
  static const String privacy = '/settings/privacy';
  static const String subscription = '/settings/subscription';
  static const String groups = '/groups';
  static String group(int id) => '/groups/$id';
  static String groupMilestones(int id) => '/groups/$id/milestones';
  static String groupMilestone(int id, int milestoneId) =>
      '/groups/$id/milestones/$milestoneId';
  static String groupLabels(int id) => '/groups/$id/labels';
  static String groupLabel(int id, int labelId) =>
      '/groups/$id/labels/$labelId';
  static String groupMembers(int id) => '/groups/$id/members';
  static String groupProtectedEnvironments(int id) =>
      '/groups/$id/protected_environments';
  static String groupProtectedEnvironment(int id, String name) =>
      '/groups/$id/protected_environments/${Uri.encodeComponent(name)}';
  static const String projects = '/projects';
  // Account-level lists, mirroring GitLab's /dashboard URLs.
  static const String myIssues = '/dashboard/issues';
  static const String myMergeRequests = '/dashboard/merge_requests';

  static String projectOverview(int id) => '/projects/$id';
  static String projectActivity(int id) => '/projects/$id/activity';
  static String projectLabels(int id) => '/projects/$id/labels';
  static String projectLabel(int id, int labelId) =>
      '/projects/$id/labels/$labelId';
  static String releases(int id) => '/projects/$id/releases';
  static String release(int id, String tagName) =>
      '/projects/$id/releases/${Uri.encodeComponent(tagName)}';
  static String tags(int id) => '/projects/$id/tags';
  static String tag(int id, String name) =>
      '/projects/$id/tags/view?name=${Uri.encodeQueryComponent(name)}';
  static String snippets(int id) => '/projects/$id/snippets';
  static String snippet(int id, int snippetId) =>
      '/projects/$id/snippets/$snippetId';
  static String snippetFile(int id, int snippetId, String path) =>
      '/projects/$id/snippets/$snippetId/file?path=${Uri.encodeQueryComponent(path)}';
  static String projectMembers(int id) => '/projects/$id/members';
  static String containerRegistry(int id) => '/projects/$id/container_registry';
  static String containerCleanupPolicy(int id) =>
      '/projects/$id/container_registry/cleanup_policy';
  static String containerTagProtectionRules(int id) =>
      '/projects/$id/container_registry/protection/tags';
  static String containerRepository(int id, int repositoryId) =>
      '/projects/$id/container_registry/$repositoryId';
  static String containerTag(int id, int repositoryId, String tagName) =>
      '/projects/$id/container_registry/$repositoryId/tags/${Uri.encodeComponent(tagName)}';
  static String wiki(int id) => '/projects/$id/wikis';
  static String wikiPage(int id, String slug) =>
      '/projects/$id/wikis/page?slug=${Uri.encodeQueryComponent(slug)}';
  static String packages(int id) => '/projects/$id/packages';
  static String packageDetail(int id, int packageId) =>
      '/projects/$id/packages/$packageId';
  static String milestones(int id) => '/projects/$id/milestones';
  static String milestone(int id, int milestoneId) =>
      '/projects/$id/milestones/$milestoneId';
  static String environments(int id) => '/projects/$id/environments';
  static String environment(int id, int environmentId) =>
      '/projects/$id/environments/$environmentId';
  static String protectedEnvironments(int id) =>
      '/projects/$id/protected_environments';
  static String protectedEnvironment(int id, String name) =>
      '/projects/$id/protected_environments/${Uri.encodeComponent(name)}';
  static String deployments(int id, {String? environment}) =>
      '/projects/$id/deployments${environment == null ? '' : '?environment=${Uri.encodeQueryComponent(environment)}'}';
  static String deployment(int id, int deploymentId) =>
      '/projects/$id/deployments/$deploymentId';

  // Repository browsing. The tree path and file path travel as a query
  // parameter, not a nested segment, because a repository path contains its own
  // slashes; encoding it as one query value keeps go_router from splitting it
  // into route segments.
  static String repository(int id, String ref) =>
      '/projects/$id/tree?ref=${Uri.encodeQueryComponent(ref)}';
  static String repositoryPath(int id, String ref, String path) =>
      '/projects/$id/tree?ref=${Uri.encodeQueryComponent(ref)}'
      '&path=${Uri.encodeQueryComponent(path)}';
  static String file(int id, String ref, String path) =>
      '/projects/$id/file?ref=${Uri.encodeQueryComponent(ref)}'
      '&path=${Uri.encodeQueryComponent(path)}';
  static String branches(int id) => '/projects/$id/branches';
  static String protectedBranches(int id) => '/projects/$id/protected_branches';
  static String protectedBranch(int id, String name) =>
      '/projects/$id/protected_branches/${Uri.encodeComponent(name)}';
  static String protectedTags(int id) => '/projects/$id/protected_tags';
  static String protectedTag(int id, String name) =>
      '/projects/$id/protected_tags/${Uri.encodeComponent(name)}';
  static String commits(int id, String ref) =>
      '/projects/$id/commits?ref=${Uri.encodeQueryComponent(ref)}';
  static String commit(int id, String sha) => '/projects/$id/commit/$sha';
  static String issues(int id) => '/projects/$id/issues';
  static String newIssue(int id) => '/projects/$id/issues/new';
  // The user-facing issue number is the iid, not the global id.
  static String issue(int id, int iid) => '/projects/$id/issues/$iid';
  static String mergeRequests(int id) => '/projects/$id/merge_requests';
  static String newMergeRequest(int id) => '/projects/$id/merge_requests/new';
  // The user-facing MR number is the iid, not the global id.
  static String mergeRequest(int id, int iid) =>
      '/projects/$id/merge_requests/$iid';
  static String pipelines(int id) => '/projects/$id/pipelines';
  static String pipelineSchedules(int id) => '/projects/$id/pipeline_schedules';
  static String pipelineSchedule(int id, int scheduleId) =>
      '/projects/$id/pipeline_schedules/$scheduleId';
  static String pipeline(int id, int pipelineId) =>
      '/projects/$id/pipelines/$pipelineId';
  static String job(int id, int jobId) => '/projects/$id/jobs/$jobId';
  static String commitChanges(int id, String sha) =>
      '/projects/$id/commit/$sha/changes';
  static String mergeRequestChanges(int id, int iid) =>
      '/projects/$id/merge_requests/$iid/changes';
}

final routerProvider = Provider<GoRouter>((ref) {
  // Rebuild the router when auth changes so the redirect below re-runs and the
  // user is moved between the sign-in screen and the app.
  final authState = ref.watch(authControllerProvider);

  // Screen views only. app_open belongs to the app's lifetime, not the
  // router's: this provider is rebuilt on every auth change, so emitting a
  // launch event here would count sign-ins. See AppLifecycle.
  //
  // read, not watch: the tracker must survive this provider's rebuilds, since
  // it is what remembers which screen the user is already on.
  final routeTracker = ref.read(routeTrackerProvider);
  final interstitials = ref.read(interstitialAdsProvider);

  final router = GoRouter(
    initialLocation: Routes.home,
    redirect: (context, state) {
      // Only wait during the very first load, before any session value
      // exists, so a returning user is not flashed the sign-in screen before
      // their persisted account is read. A failed sign-in attempt is an error
      // that still carries the previous SignedOut value, so it must NOT be
      // treated as "no opinion" — routing is decided by whether a session
      // exists, never by the transient state of a sign-in attempt.
      if (authState.isLoading && !authState.hasValue) {
        return null;
      }
      final signedIn = authState.valueOrNull is SignedIn;
      final atSignIn = state.matchedLocation == Routes.signIn;
      // A signed-in user may reach the sign-in screen only to add an account.
      final addingAccount = state.uri.queryParameters['add'] == '1';

      if (!signedIn) {
        return atSignIn ? null : Routes.signIn;
      }
      if (atSignIn && !addingAccount) {
        return Routes.home;
      }
      return null;
    },
    routes: [
      // Primary destinations, wrapped in the responsive navigation shell.
      GoRoute(
        path: Routes.home,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: AppShell(currentIndex: 0, child: HomeScreen()),
        ),
      ),
      GoRoute(
        path: Routes.inbox,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: AppShell(currentIndex: 1, child: InboxScreen()),
        ),
      ),
      GoRoute(
        path: Routes.search,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: AppShell(currentIndex: 2, child: SearchScreen()),
        ),
      ),
      GoRoute(
        path: Routes.me,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: AppShell(currentIndex: 3, child: MeScreen()),
        ),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.accounts,
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'privacy',
            builder: (context, state) => const PrivacyScreen(),
          ),
          GoRoute(
            path: 'subscription',
            builder: (context, state) => const SubscriptionScreen(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.myIssues,
        builder: (context, state) => const MyIssuesScreen(),
      ),
      GoRoute(
        path: Routes.myMergeRequests,
        builder: (context, state) => const MyMergeRequestsScreen(),
      ),
      GoRoute(
        path: Routes.groups,
        builder: (context, state) => const GroupsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => GroupDetailScreen(
              groupId: int.parse(state.pathParameters['id']!),
            ),
            routes: [
              GoRoute(
                path: 'milestones',
                builder: (context, state) => MilestonesScreen.group(
                  groupId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: ':milestoneId',
                    builder: (context, state) => MilestoneDetailScreen.group(
                      groupId: int.parse(state.pathParameters['id']!),
                      milestoneId: int.parse(
                        state.pathParameters['milestoneId']!,
                      ),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'labels',
                builder: (context, state) => GroupLabelsScreen(
                  groupId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: ':labelId',
                    builder: (context, state) => GroupLabelDetailScreen(
                      groupId: int.parse(state.pathParameters['id']!),
                      labelId: int.parse(state.pathParameters['labelId']!),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'members',
                builder: (context, state) => GroupMembersScreen(
                  groupId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'protected_environments',
                builder: (context, state) => ProtectedEnvironmentsScreen.group(
                  groupId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: ':name',
                    builder: (context, state) =>
                        ProtectedEnvironmentDetailScreen.group(
                          groupId: int.parse(state.pathParameters['id']!),
                          name: state.pathParameters['name']!,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.projects,
        builder: (context, state) => const ProjectsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return ProjectOverviewScreen(projectId: id);
            },
            routes: [
              GoRoute(
                path: 'activity',
                builder: (context, state) => ProjectActivityScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'releases',
                builder: (context, state) => ReleasesScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: ':tagName',
                    builder: (context, state) => ReleaseDetailScreen(
                      projectId: int.parse(state.pathParameters['id']!),
                      tagName: state.pathParameters['tagName']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'members',
                builder: (context, state) => ProjectMembersScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'container_registry',
                builder: (context, state) => ContainerRegistryScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: 'cleanup_policy',
                    builder: (context, state) => ContainerCleanupPolicyScreen(
                      projectId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'protection/tags',
                    builder: (context, state) => ContainerTagProtectionScreen(
                      projectId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: ':repositoryId',
                    builder: (context, state) => ContainerRepositoryScreen(
                      projectId: int.parse(state.pathParameters['id']!),
                      repositoryId: int.parse(
                        state.pathParameters['repositoryId']!,
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'tags/:tagName',
                        builder: (context, state) => ContainerTagScreen(
                          projectId: int.parse(state.pathParameters['id']!),
                          repositoryId: int.parse(
                            state.pathParameters['repositoryId']!,
                          ),
                          tagName: state.pathParameters['tagName']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'wikis',
                builder: (context, state) => WikiPagesScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: 'page',
                    builder: (context, state) => WikiPageScreen(
                      projectId: int.parse(state.pathParameters['id']!),
                      slug: state.uri.queryParameters['slug']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'packages',
                builder: (context, state) => PackageListScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: ':packageId',
                    builder: (context, state) => PackageDetailScreen(
                      projectId: int.parse(state.pathParameters['id']!),
                      packageId: int.parse(state.pathParameters['packageId']!),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'milestones',
                builder: (context, state) => MilestonesScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: ':milestoneId',
                    builder: (context, state) => MilestoneDetailScreen(
                      projectId: int.parse(state.pathParameters['id']!),
                      milestoneId: int.parse(
                        state.pathParameters['milestoneId']!,
                      ),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'environments',
                builder: (context, state) => EnvironmentsScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: ':environmentId',
                    builder: (context, state) => EnvironmentDetailScreen(
                      projectId: int.parse(state.pathParameters['id']!),
                      environmentId: int.parse(
                        state.pathParameters['environmentId']!,
                      ),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'protected_environments',
                builder: (context, state) => ProtectedEnvironmentsScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: ':name',
                    builder: (context, state) =>
                        ProtectedEnvironmentDetailScreen(
                          projectId: int.parse(state.pathParameters['id']!),
                          name: state.pathParameters['name']!,
                        ),
                  ),
                ],
              ),
              GoRoute(
                path: 'deployments',
                builder: (context, state) => DeploymentsScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  initialEnvironment: state.uri.queryParameters['environment'],
                ),
                routes: [
                  GoRoute(
                    path: ':deploymentId',
                    builder: (context, state) => DeploymentDetailScreen(
                      projectId: int.parse(state.pathParameters['id']!),
                      deploymentId: int.parse(
                        state.pathParameters['deploymentId']!,
                      ),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'tree',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  final ref = state.uri.queryParameters['ref']!;
                  final path = state.uri.queryParameters['path'] ?? '';
                  return RepositoryBrowserScreen(
                    projectId: id,
                    ref: ref,
                    path: path,
                  );
                },
              ),
              GoRoute(
                path: 'labels',
                builder: (context, state) => ProjectLabelsScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'labels/:labelId',
                builder: (context, state) => ProjectLabelDetailScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  labelId: int.parse(state.pathParameters['labelId']!),
                ),
              ),
              GoRoute(
                path: 'snippets',
                builder: (context, state) => SnippetsScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'snippets/:snippetId',
                builder: (context, state) => SnippetDetailScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  snippetId: int.parse(state.pathParameters['snippetId']!),
                ),
              ),
              GoRoute(
                path: 'snippets/:snippetId/file',
                builder: (context, state) => SnippetFileScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  snippetId: int.parse(state.pathParameters['snippetId']!),
                  path: state.uri.queryParameters['path']!,
                ),
              ),
              GoRoute(
                path: 'file',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  final ref = state.uri.queryParameters['ref']!;
                  final path = state.uri.queryParameters['path']!;
                  return FileViewerScreen(projectId: id, ref: ref, path: path);
                },
              ),
              GoRoute(
                path: 'branches',
                builder: (context, state) => BranchesScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'protected_branches',
                builder: (context, state) => ProtectedBranchesScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: ':name',
                    builder: (context, state) => ProtectedBranchDetailScreen(
                      projectId: int.parse(state.pathParameters['id']!),
                      name: state.pathParameters['name']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'protected_tags',
                builder: (context, state) => ProtectedTagsScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: ':name',
                    builder: (context, state) => ProtectedTagDetailScreen(
                      projectId: int.parse(state.pathParameters['id']!),
                      name: state.pathParameters['name']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'tags',
                builder: (context, state) => TagsScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'tags/view',
                builder: (context, state) => TagDetailScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  name: state.uri.queryParameters['name']!,
                ),
              ),
              GoRoute(
                path: 'commits',
                builder: (context, state) => CommitsScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  ref: state.uri.queryParameters['ref']!,
                ),
              ),
              GoRoute(
                path: 'commit/:sha',
                builder: (context, state) => CommitDetailScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  sha: state.pathParameters['sha']!,
                ),
                routes: [
                  GoRoute(
                    path: 'changes',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final sha = state.pathParameters['sha']!;
                      return ChangesScreen(
                        title: sha.length > 8 ? sha.substring(0, 8) : sha,
                        provider: commitDiffControllerProvider(
                          CommitDiffRef(projectId: id, sha: sha),
                        ),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'issues',
                builder: (context, state) => IssuesScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'issues/new',
                builder: (context, state) => NewIssueScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'issues/:iid',
                builder: (context, state) => IssueDetailScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  iid: int.parse(state.pathParameters['iid']!),
                ),
              ),
              GoRoute(
                path: 'merge_requests',
                builder: (context, state) => MergeRequestsScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'merge_requests/new',
                builder: (context, state) => NewMergeRequestScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'pipeline_schedules',
                builder: (context, state) => PipelineSchedulesScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: ':scheduleId',
                    builder: (context, state) => PipelineScheduleDetailScreen(
                      projectId: int.parse(state.pathParameters['id']!),
                      scheduleId: int.parse(
                        state.pathParameters['scheduleId']!,
                      ),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'pipelines',
                builder: (context, state) => PipelinesScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'pipelines/:pid',
                builder: (context, state) => PipelineDetailScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  pipelineId: int.parse(state.pathParameters['pid']!),
                ),
              ),
              GoRoute(
                path: 'jobs/:jid',
                builder: (context, state) => JobDetailScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  jobId: int.parse(state.pathParameters['jid']!),
                ),
              ),
              GoRoute(
                path: 'merge_requests/:iid',
                builder: (context, state) => MergeRequestDetailScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  iid: int.parse(state.pathParameters['iid']!),
                ),
                routes: [
                  GoRoute(
                    path: 'changes',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final iid = int.parse(state.pathParameters['iid']!);
                      return ChangesScreen(
                        title: '!$iid',
                        provider: mergeRequestDiffControllerProvider(
                          MergeRequestDiffRef(projectId: id, iid: iid),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // One screen_view per navigation, with numeric ids collapsed so the route
  // never identifies a project or item.
  router.routerDelegate.addListener(() {
    routeTracker.visit(router.routerDelegate.currentConfiguration.uri.path);
    // Interstitial pacing rides the same signal; the service checks the
    // entitlement gate and its own policy before anything shows.
    if (ref.read(adsEnabledProvider)) {
      interstitials.onTransition();
    }
  });
  return router;
});
