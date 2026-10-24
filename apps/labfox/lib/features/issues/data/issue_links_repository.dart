import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Reads linked issues from the authenticated GitLab instance.
class IssueLinksRepository {
  const IssueLinksRepository(this.client);

  final GitLabClient client;

  Future<Paginated<IssueLink>> list(
    int projectId, {
    required int issueIid,
    int page = 1,
  }) => client.issueLinks.list(projectId, issueIid: issueIid, page: page);
}
