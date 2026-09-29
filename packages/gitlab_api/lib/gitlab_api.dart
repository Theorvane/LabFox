/// GitLab REST and selected GraphQL operation client for LabFox.
///
/// Pure Dart: this package must never import `package:flutter`, so it stays
/// unit testable without a widget binding.
library;

export 'src/common/exceptions.dart';
export 'src/common/paginated.dart';
export 'src/container_registry/container_registry_api.dart';
export 'src/deployments/deployments_api.dart';
export 'src/environments/environments_api.dart';
export 'src/environments/protected_environments_api.dart';
export 'src/events/events_api.dart';
export 'src/gitlab_client.dart';
export 'src/graphql/graphql_api.dart';
export 'src/groups/group_protected_environments_api.dart';
export 'src/groups/groups_api.dart';
export 'src/issues/issue_links_api.dart';
export 'src/issues/issues_api.dart';
export 'src/jobs/jobs_api.dart';
export 'src/labels/group_labels_api.dart';
export 'src/labels/project_labels_api.dart';
export 'src/members/group_members_api.dart';
export 'src/members/project_members_api.dart';
export 'src/merge_requests/merge_requests_api.dart';
export 'src/milestones/group_milestones_api.dart';
export 'src/milestones/milestones_api.dart';
export 'src/notes/notes_api.dart';
export 'src/oauth/oauth_api.dart';
export 'src/oauth/pkce.dart';
export 'src/packages/packages_api.dart';
export 'src/pipeline_schedules/pipeline_schedules_api.dart';
export 'src/pipelines/pipelines_api.dart';
export 'src/projects/projects_api.dart';
export 'src/releases/releases_api.dart';
export 'src/repository/protected_branches_api.dart';
export 'src/repository/protected_tags_api.dart';
export 'src/repository/repository_api.dart';
export 'src/repository/repository_file.dart';
export 'src/search/search_api.dart';
export 'src/snippets/snippets_api.dart';
export 'src/todos/todos_api.dart';
export 'src/users/users_api.dart';
export 'src/wikis/wikis_api.dart';
