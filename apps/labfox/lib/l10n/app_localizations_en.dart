// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get protectedTagsTitle => 'Protected tags';

  @override
  String get protectedTagsEmpty => 'No protected tag rules found.';

  @override
  String get protectedTagsError => 'Could not load protected tags.';

  @override
  String get protectedTagsLoadMore => 'Load more';

  @override
  String get protectedTagCreateAccess => 'Allowed to create';

  @override
  String get protectedEnvironmentsTitle => 'Protected environments';

  @override
  String get protectedEnvironmentsEmpty =>
      'No protected environment rules found.';

  @override
  String get protectedEnvironmentsError =>
      'Could not load protected environments.';

  @override
  String get protectedEnvironmentsUnavailable =>
      'Protected environments are unavailable or you don\'t have access.';

  @override
  String get protectedEnvironmentsLoadMore => 'Load more';

  @override
  String get protectedEnvironmentDeployAccess => 'Allowed to deploy';

  @override
  String get protectedEnvironmentApprovalRules => 'Approval rules';

  @override
  String protectedEnvironmentApprovalCount(int count) {
    return 'Required approvals: $count';
  }

  @override
  String get protectedBranchesTitle => 'Protected branches';

  @override
  String get protectedBranchesEmpty => 'No protected branch rules found.';

  @override
  String get protectedBranchesError => 'Could not load protected branches.';

  @override
  String get protectedBranchesLoadMore => 'Load more';

  @override
  String get protectedBranchPushAccess => 'Allowed to push';

  @override
  String get protectedBranchMergeAccess => 'Allowed to merge';

  @override
  String get protectedBranchForcePush => 'Force push';

  @override
  String get protectedBranchCodeOwnerApproval => 'Code owner approval';

  @override
  String get protectedBranchInherited => 'Inherited from group';

  @override
  String get protectedBranchEnabled => 'Enabled';

  @override
  String get protectedBranchDisabled => 'Disabled';

  @override
  String get protectedBranchNoAccess => 'No access rules';

  @override
  String get linkedIssuesTitle => 'Linked issues';

  @override
  String get linkedIssuesError => 'Could not load linked issues.';

  @override
  String get linkedIssuesLoadMore => 'Load more';

  @override
  String get linkedIssuesRelatesTo => 'Related to';

  @override
  String get linkedIssuesBlocks => 'Blocks';

  @override
  String get linkedIssuesBlockedBy => 'Blocked by';

  @override
  String get groupLabelsTitle => 'Group labels';

  @override
  String get groupLabelsEmpty => 'No group labels yet';

  @override
  String get groupLabelsError => 'Couldn\'t load group labels.';

  @override
  String get groupMembersTitle => 'Group members';

  @override
  String get groupMembersSearch => 'Search group members';

  @override
  String get groupMembersEmpty => 'No group members found.';

  @override
  String get groupMembersError => 'Could not load group members.';

  @override
  String get pipelineSchedulesTitle => 'Pipeline schedules';

  @override
  String get pipelineSchedulesAll => 'All';

  @override
  String get pipelineSchedulesActive => 'Active';

  @override
  String get pipelineSchedulesInactive => 'Inactive';

  @override
  String get pipelineSchedulesEmpty => 'No pipeline schedules found.';

  @override
  String get pipelineSchedulesError => 'Could not load pipeline schedules.';

  @override
  String get pipelineSchedulesLoadMore => 'Load more';

  @override
  String get pipelineScheduleDetailError =>
      'Could not load this pipeline schedule.';

  @override
  String pipelineScheduleNextRun(String date) {
    return 'Next run: $date';
  }

  @override
  String get pipelineScheduleNextRunLabel => 'Next run';

  @override
  String get pipelineScheduleRef => 'Ref';

  @override
  String get pipelineScheduleCron => 'Schedule';

  @override
  String get pipelineScheduleTimezone => 'Time zone';

  @override
  String get pipelineScheduleOwner => 'Owner';

  @override
  String get pipelineScheduleRunNow => 'Run now';

  @override
  String get pipelineScheduleRunSuccess => 'Pipeline schedule started.';

  @override
  String get pipelineScheduleRunError =>
      'Could not run this pipeline schedule.';

  @override
  String get pipelineScheduleLastPipeline => 'Last pipeline';

  @override
  String pipelineSchedulePipelineNumber(int number) {
    return 'Pipeline #$number';
  }

  @override
  String get deploymentsTitle => 'Deployments';

  @override
  String get deploymentsAll => 'All';

  @override
  String get deploymentsSuccess => 'Success';

  @override
  String get deploymentsFailed => 'Failed';

  @override
  String get deploymentsRunning => 'Running';

  @override
  String get deploymentsCanceled => 'Canceled';

  @override
  String get deploymentsCreated => 'Created';

  @override
  String get deploymentsBlocked => 'Blocked';

  @override
  String get deploymentsUnknownStatus => 'Unknown status';

  @override
  String get deploymentsEmpty => 'No deployments found.';

  @override
  String get deploymentsError => 'Could not load deployments.';

  @override
  String get deploymentsLoadMore => 'Load more';

  @override
  String get deploymentsEnvironmentSearch => 'Filter by environment name';

  @override
  String get deploymentsUnknownEnvironment => 'Unknown environment';

  @override
  String get deploymentDetailError => 'Could not load this deployment.';

  @override
  String deploymentNumber(int number) {
    return 'Deployment #$number';
  }

  @override
  String get deploymentEnvironment => 'Environment';

  @override
  String get deploymentRef => 'Ref';

  @override
  String get deploymentCommit => 'Commit';

  @override
  String get deploymentJob => 'Job';

  @override
  String get deploymentPipeline => 'Pipeline';

  @override
  String get deploymentCreatedAt => 'Created';

  @override
  String get deploymentUpdatedAt => 'Updated';

  @override
  String get deploymentUser => 'Deployed by';

  @override
  String get releasesTitle => 'Releases';

  @override
  String get releasesEmpty => 'No releases yet.';

  @override
  String get releasesError => 'Could not load releases.';

  @override
  String get releaseDetailError => 'Could not load this release.';

  @override
  String get releaseAssetsTitle => 'Assets';

  @override
  String get releaseLoadMore => 'Load more';

  @override
  String get releaseUpcoming => 'Upcoming';

  @override
  String get activityTitle => 'Activity';

  @override
  String get activityAll => 'All';

  @override
  String get activityIssues => 'Issues';

  @override
  String get activityMergeRequests => 'Merge requests';

  @override
  String get activityEmpty => 'No recent activity.';

  @override
  String get activityError => 'Could not load project activity.';

  @override
  String get activityLoadMore => 'Load more';

  @override
  String get activityUnknownActor => 'Unknown user';

  @override
  String get activityPush => 'Push';

  @override
  String get activityEvent => 'Project activity';

  @override
  String activityBy(String actor, String action) {
    return '$actor $action';
  }

  @override
  String get environmentsTitle => 'Environments';

  @override
  String get environmentsAll => 'All';

  @override
  String get environmentsAvailable => 'Available';

  @override
  String get environmentsStopping => 'Stopping';

  @override
  String get environmentsStopped => 'Stopped';

  @override
  String get environmentsSearch => 'Search environments';

  @override
  String get environmentsSearchLength => 'Enter at least 3 characters.';

  @override
  String get environmentsEmpty => 'No environments found.';

  @override
  String get environmentsError => 'Could not load environments.';

  @override
  String get environmentsLoadMore => 'Load more';

  @override
  String get environmentDetailError => 'Could not load this environment.';

  @override
  String get environmentAutoStop => 'Auto-stop';

  @override
  String get environmentOpenUrl => 'Open environment';

  @override
  String get environmentLatestDeployment => 'Latest deployment';

  @override
  String get environmentUnknownStatus => 'Unknown status';

  @override
  String get projectMembersTitle => 'Members';

  @override
  String get projectMembersSearch => 'Search members';

  @override
  String get projectMembersClearSearch => 'Clear search';

  @override
  String get projectMembersEmpty => 'No members found.';

  @override
  String get projectMembersError => 'Could not load members.';

  @override
  String get projectMembersLoadMore => 'Load more';

  @override
  String get projectMembersExpiry => 'Expires';

  @override
  String get memberRoleNoAccess => 'No access';

  @override
  String get memberRoleMinimal => 'Minimal access';

  @override
  String get memberRoleGuest => 'Guest';

  @override
  String get memberRolePlanner => 'Planner';

  @override
  String get memberRoleReporter => 'Reporter';

  @override
  String get memberRoleSecurityManager => 'Security manager';

  @override
  String get memberRoleDeveloper => 'Developer';

  @override
  String get memberRoleMaintainer => 'Maintainer';

  @override
  String get memberRoleOwner => 'Owner';

  @override
  String get memberRoleUnknown => 'Unknown role';

  @override
  String get containerRegistryTitle => 'Container registry';

  @override
  String get containerRegistryEmpty => 'No container images yet.';

  @override
  String get containerRegistryError => 'Could not load container images.';

  @override
  String get containerTagsTitle => 'Image tags';

  @override
  String get containerTagsEmpty => 'No tags yet.';

  @override
  String get containerTagsError => 'Could not load image tags.';

  @override
  String get containerTagError => 'Could not load this tag.';

  @override
  String get containerTagDigest => 'Digest';

  @override
  String get containerTagRevision => 'Revision';

  @override
  String get containerTagSize => 'Size (bytes)';

  @override
  String get containerLoadMore => 'Load more';

  @override
  String get milestonesTitle => 'Milestones';

  @override
  String get milestonesActive => 'Active';

  @override
  String get milestonesClosed => 'Closed';

  @override
  String get milestonesEmpty => 'No milestones in this state.';

  @override
  String get milestonesError => 'Could not load milestones.';

  @override
  String get milestoneDetailError => 'Could not load this milestone.';

  @override
  String get milestoneStartDate => 'Start date';

  @override
  String get milestoneDueDate => 'Due date';

  @override
  String get milestoneLoadMore => 'Load more';

  @override
  String get appTitle => 'LabFox';

  @override
  String get homeTitle => 'Home';

  @override
  String homeSignedInAs(String username) {
    return 'Signed in as $username';
  }

  @override
  String get homeEmptyWork =>
      'Your issues, merge requests and pipelines will appear here.';

  @override
  String get homeReviewRequests => 'Review requests';

  @override
  String get homeAssignedMergeRequests => 'Assigned merge requests';

  @override
  String get homeAssignedIssues => 'Assigned issues';

  @override
  String get homeWorkAllClear => 'You\'re all caught up.';

  @override
  String get homeWorkError => 'Couldn\'t load your work.';

  @override
  String get signOut => 'Sign out';

  @override
  String get signInTitle => 'Connect a GitLab account';

  @override
  String get signInNoAccountNote =>
      'LabFox has no account of its own. Connect the GitLab you already use — gitlab.com, or an instance you host yourself.';

  @override
  String get signInInstanceLabel => 'GitLab instance URL';

  @override
  String get signInInstanceRequired => 'Enter your GitLab instance URL.';

  @override
  String get signInInstanceInvalid =>
      'Enter a valid https URL, for example https://gitlab.com.';

  @override
  String get signInTokenLabel => 'Personal Access Token';

  @override
  String get signInTokenHelp => 'Needs the api and read_user scopes.';

  @override
  String get signInTokenToggle => 'Show or hide the token';

  @override
  String get signInTokenRequired => 'Enter a Personal Access Token.';

  @override
  String get signInSubmit => 'Sign in';

  @override
  String get signInOr => 'or';

  @override
  String get signInOAuthButton => 'Authorize with your instance';

  @override
  String get signInClientIdLabel => 'OAuth client ID';

  @override
  String get signInClientIdHelp => 'Only for OAuth on a self-hosted instance.';

  @override
  String get signInOAuthNeedsClientId =>
      'Enter an OAuth client ID for this instance.';

  @override
  String get signInErrorToken =>
      'The token was rejected. Check that it is correct and has not expired.';

  @override
  String get signInErrorScope =>
      'The token is missing a required scope. It needs api and read_user.';

  @override
  String get signInErrorUnreachable =>
      'Could not reach that instance. Check the URL, your network, and whether the certificate is trusted.';

  @override
  String get signInErrorGeneric => 'Sign-in failed. Please try again.';

  @override
  String get scopeAssigned => 'Assigned';

  @override
  String get scopeCreated => 'Created';

  @override
  String get homeRefresh => 'Refresh';

  @override
  String get homeFavoritesEmpty => 'Star projects to pin them here.';

  @override
  String get homeMyWork => 'My work';

  @override
  String get homeProjects => 'Projects';

  @override
  String get homeGroups => 'Groups';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupsEmpty => 'You are not a member of any groups yet.';

  @override
  String get groupsError => 'Could not load your groups.';

  @override
  String get groupDetailTitle => 'Group';

  @override
  String get groupDetailError => 'Could not load this group.';

  @override
  String get groupSubgroups => 'Subgroups';

  @override
  String get groupSubgroupsEmpty => 'No subgroups.';

  @override
  String get groupProjects => 'Projects';

  @override
  String get groupProjectsEmpty => 'No projects in this group.';

  @override
  String get groupLoadMore => 'Load more';

  @override
  String get projectsTitle => 'Projects';

  @override
  String get projectsEmpty => 'You are not a member of any projects yet.';

  @override
  String get projectsError => 'Could not load your projects.';

  @override
  String get shareLink => 'Share';

  @override
  String get mrClose => 'Close';

  @override
  String get mrReopen => 'Reopen';

  @override
  String get mrRebase => 'Rebase';

  @override
  String get mrMarkDraft => 'Mark as draft';

  @override
  String get mrMarkReady => 'Mark as ready';

  @override
  String get mrBlockerConflicts => 'Conflicts';

  @override
  String get mrBlockerChecksFailed => 'Checks failed';

  @override
  String get mrBlockerCiRunning => 'CI running';

  @override
  String get mrBlockerNeedsApproval => 'Needs approval';

  @override
  String get mrBlockerUnresolved => 'Unresolved threads';

  @override
  String get retry => 'Retry';

  @override
  String get newIssueTitle => 'New issue';

  @override
  String get newIssueTitleLabel => 'Title';

  @override
  String get newIssueTitleRequired => 'Enter a title.';

  @override
  String get newIssueDescriptionLabel => 'Description (optional)';

  @override
  String get newIssueSubmit => 'Create issue';

  @override
  String get newIssueError => 'Could not create the issue. Please try again.';

  @override
  String get newIssueButton => 'New issue';

  @override
  String get issueClose => 'Close issue';

  @override
  String get issueEdit => 'Edit issue';

  @override
  String get issueSaveChanges => 'Save changes';

  @override
  String get issueEditError =>
      'Could not save the issue. Check your permissions and try again.';

  @override
  String get issueReopen => 'Reopen issue';

  @override
  String get issueStateError => 'Could not update the issue. Please try again.';

  @override
  String get newMrTitle => 'New merge request';

  @override
  String get newMrSourceLabel => 'Source branch';

  @override
  String get newMrTargetLabel => 'Target branch';

  @override
  String get newMrTitleLabel => 'Title';

  @override
  String get newMrDescriptionLabel => 'Description (optional)';

  @override
  String get newMrBranchRequired => 'Enter a branch.';

  @override
  String get newMrTitleRequired => 'Enter a title.';

  @override
  String get newMrSubmit => 'Create merge request';

  @override
  String get newMrError =>
      'Could not create the merge request. Please try again.';

  @override
  String get newMrButton => 'New merge request';

  @override
  String get projectOverviewTitle => 'Project';

  @override
  String get projectOverviewError => 'Could not load this project.';

  @override
  String get projectOverviewNoReadme => 'This project has no README.';

  @override
  String get projectOverviewRepository => 'Repository';

  @override
  String get repositoryTitle => 'Repository';

  @override
  String get repositoryError => 'Could not load this directory.';

  @override
  String get repositoryEmpty => 'This directory is empty.';

  @override
  String get fileError => 'Could not load this file.';

  @override
  String get fileNotFound => 'This file was not found.';

  @override
  String get fileBinary => 'This is a binary file and cannot be shown as text.';

  @override
  String get fileCopy => 'Copy contents';

  @override
  String get fileCopied => 'Contents copied';

  @override
  String get projectOverviewBranches => 'Branches';

  @override
  String get projectOverviewCommits => 'Commits';

  @override
  String get projectOverviewCode => 'Code';

  @override
  String get projectOverviewBrowseCode => 'Browse code';

  @override
  String get branchesTitle => 'Branches';

  @override
  String get branchesError => 'Could not load branches.';

  @override
  String get branchesEmpty => 'This repository has no branches.';

  @override
  String get newBranchTitle => 'New branch';

  @override
  String get newBranchNameLabel => 'Branch name';

  @override
  String get newBranchFromLabel => 'Create from';

  @override
  String get newBranchNameRequired => 'Enter a branch name.';

  @override
  String get newBranchFromRequired => 'Enter a source branch or ref.';

  @override
  String get newBranchCreate => 'Create branch';

  @override
  String get newBranchError => 'Could not create the branch. Please try again.';

  @override
  String get newBranchButton => 'New branch';

  @override
  String get branchDefault => 'Default branch';

  @override
  String get commitsTitle => 'Commits';

  @override
  String get commitsError => 'Could not load commits.';

  @override
  String get commitsEmpty => 'No commits on this branch yet.';

  @override
  String get commitTitle => 'Commit';

  @override
  String get commitError => 'Could not load this commit.';

  @override
  String get projectOverviewIssues => 'Issues';

  @override
  String get issuesTitle => 'Issues';

  @override
  String get issuesFilterOpen => 'Open';

  @override
  String get issuesFilterClosed => 'Closed';

  @override
  String get issuesError => 'Could not load issues.';

  @override
  String get issuesEmpty => 'No issues here.';

  @override
  String get issueError => 'Could not load this issue.';

  @override
  String get issueStateOpen => 'Open';

  @override
  String get issueStateClosed => 'Closed';

  @override
  String get issueNoDescription => 'No description provided.';

  @override
  String issueOpenedBy(String username) {
    return 'opened by $username';
  }

  @override
  String get projectOverviewMergeRequests => 'Merge requests';

  @override
  String get mergeRequestsTitle => 'Merge requests';

  @override
  String get mrFilterOpen => 'Open';

  @override
  String get mrFilterMerged => 'Merged';

  @override
  String get mrFilterClosed => 'Closed';

  @override
  String get mergeRequestsError => 'Could not load merge requests.';

  @override
  String get mergeRequestsEmpty => 'No merge requests here.';

  @override
  String get mergeRequestError => 'Could not load this merge request.';

  @override
  String get mergeRequestNoDescription => 'No description provided.';

  @override
  String get mrStateOpen => 'Open';

  @override
  String get mrStateMerged => 'Merged';

  @override
  String get mrStateClosed => 'Closed';

  @override
  String get mrDraft => 'Draft';

  @override
  String get changesTitle => 'Changes';

  @override
  String get changesError => 'Could not load the changes.';

  @override
  String get changesEmpty => 'No changes.';

  @override
  String get changesBinary => 'Binary file — not shown.';

  @override
  String get commitViewChanges => 'View changes';

  @override
  String get mrViewChanges => 'View changes';

  @override
  String get changesOmitted =>
      'Diff not shown because it is too large or collapsed.';

  @override
  String get commentsHeading => 'Comments';

  @override
  String get commentsError => 'Could not load comments.';

  @override
  String get commentsEmpty => 'No comments yet.';

  @override
  String get commentComposerHint => 'Write a comment…';

  @override
  String get commentComposerSubmit => 'Comment';

  @override
  String get commentPostForbidden =>
      'You do not have permission to comment here. Check that your token has the api scope.';

  @override
  String get commentPostError =>
      'Could not post your comment. Please try again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get mrApprove => 'Approve';

  @override
  String get mrUnapprove => 'Revoke approval';

  @override
  String get mrMerge => 'Merge';

  @override
  String get mrMergeMethodTitle => 'Merge method';

  @override
  String get mrMergeCommit => 'Merge commit';

  @override
  String get mrMergeSquash => 'Squash and merge';

  @override
  String get mrReadyToMerge => 'Ready to merge';

  @override
  String get mrCannotMergeNow => 'Cannot be merged yet';

  @override
  String get mrMergeConfirmTitle => 'Merge this merge request?';

  @override
  String mrMergeConfirmBody(String mr) {
    return 'Merging $mr cannot be undone.';
  }

  @override
  String mrApprovalsSummary(int approved, int required) {
    return '$approved of $required approvals';
  }

  @override
  String get mrNotMergeable =>
      'This merge request cannot be merged right now. It may need approval, a rebase, or a passing pipeline.';

  @override
  String get mrActionForbidden =>
      'You do not have permission for this action. Check your token scope and role.';

  @override
  String get mrActionError =>
      'The action could not be completed. Please try again.';

  @override
  String get projectOverviewPipelines => 'Pipelines';

  @override
  String get pipelinesTitle => 'Pipelines';

  @override
  String get pipelinesError => 'Could not load pipelines.';

  @override
  String get pipelinesEmpty => 'No pipelines yet.';

  @override
  String get pipelineError => 'Could not load this pipeline.';

  @override
  String get pipelineJobsError => 'Could not load jobs.';

  @override
  String get pipelineNoJobs => 'This pipeline has no jobs.';

  @override
  String get jobTitle => 'Job';

  @override
  String get jobError => 'Could not load this job.';

  @override
  String get jobRefresh => 'Refresh';

  @override
  String get jobLogError => 'Could not load the log.';

  @override
  String get jobLogEmpty => 'This job has no log output.';

  @override
  String get jobActionRetry => 'Retry';

  @override
  String get jobActionCancel => 'Cancel';

  @override
  String get jobActionRun => 'Run';

  @override
  String get jobActionForbidden =>
      'You do not have permission for this action.';

  @override
  String get jobActionInvalid =>
      'This action is not available for the job\'s current state.';

  @override
  String get jobActionError =>
      'The action could not be completed. Please try again.';

  @override
  String get pipelineActionRetry => 'Retry';

  @override
  String get pipelineActionCancel => 'Cancel';

  @override
  String get pipelineActionForbidden =>
      'You do not have permission for this action.';

  @override
  String get pipelineActionInvalid =>
      'This action is not available for the pipeline\'s current state.';

  @override
  String get pipelineActionError =>
      'The action could not be completed. Please try again.';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get accountAdd => 'Add account';

  @override
  String get accountRemove => 'Remove account';

  @override
  String get homeSwitchAccount => 'Accounts';

  @override
  String get homeInbox => 'To-do list';

  @override
  String get inboxTitle => 'To-do list';

  @override
  String get inboxEmpty => 'You\'re all caught up.';

  @override
  String get inboxDoneEmpty => 'Nothing marked done yet.';

  @override
  String get inboxFilterPending => 'Pending';

  @override
  String get inboxFilterDone => 'Done';

  @override
  String get inboxFilterAllTypes => 'All types';

  @override
  String get inboxTypeIssues => 'Issues';

  @override
  String get inboxTypeMergeRequests => 'Merge requests';

  @override
  String get inboxFilterAllReasons => 'All reasons';

  @override
  String get inboxError => 'Your to-do items could not be loaded.';

  @override
  String get inboxMarkAllDone => 'Mark all as done';

  @override
  String get inboxMarkDone => 'Mark done';

  @override
  String get inboxMarkDoneError =>
      'The item could not be cleared. Please try again.';

  @override
  String get inboxActionAssigned => 'Assigned to you';

  @override
  String get inboxActionMentioned => 'Mentioned you';

  @override
  String get inboxActionBuildFailed => 'Pipeline failed';

  @override
  String get inboxActionMarked => 'Added a to-do';

  @override
  String get inboxActionApprovalRequired => 'Approval required';

  @override
  String get inboxActionUnmergeable => 'Cannot be merged';

  @override
  String get inboxActionDirectlyAddressed => 'Directly addressed you';

  @override
  String get homeSearch => 'Search';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search projects, issues, merge requests';

  @override
  String get searchScopeProjects => 'Projects';

  @override
  String get searchScopeIssues => 'Issues';

  @override
  String get searchScopeMergeRequests => 'Merge requests';

  @override
  String get searchInitial => 'Type to search.';

  @override
  String get searchEmpty => 'No results found.';

  @override
  String get searchError => 'The search could not be completed.';

  @override
  String get searchLoadMore => 'Load more';

  @override
  String get listSearchHint => 'Search by title';

  @override
  String get listSearchClose => 'Close search';

  @override
  String get projectAddFavorite => 'Add to favorites';

  @override
  String get projectRemoveFavorite => 'Remove from favorites';

  @override
  String get homeFavorites => 'Favorites';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccounts => 'Accounts';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsTerms => 'Terms of service';

  @override
  String get settingsWebsite => 'Website';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsBackgroundChecks => 'Background to-do checks';

  @override
  String get settingsBackgroundChecksHelp =>
      'LabFox checks your to-do list in the background and notifies you about new items. Android checks about every 15 minutes; iOS decides when, so this is a background check rather than instant push.';

  @override
  String get paywallNotifications =>
      'Background to-do checks are part of the subscription. The to-do inbox and manual refresh stay free.';

  @override
  String get settingsNotificationsDenied =>
      'LabFox cannot show notifications until you allow them in system settings.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get meShareProfile => 'Share profile';

  @override
  String get settingsLicenses => 'Open source licenses';

  @override
  String get paywallTitle => 'A subscription unlocks this';

  @override
  String get paywallSubscribe => 'See the subscription';

  @override
  String get paywallNotNow => 'Not now';

  @override
  String get paywallMergeRequestActions =>
      'Approving and merging are part of the subscription. Reading merge requests, diffs, and discussions stays free.';

  @override
  String get paywallPipelineActions =>
      'Retrying, cancelling, and running manual jobs are part of the subscription. Watching pipelines and reading job logs stays free.';

  @override
  String get paywallAccounts =>
      'One account is free. Connecting more instances is part of the subscription.';

  @override
  String paywallFavorites(int count) {
    return 'Free keeps $count favorites. The subscription removes the limit.';
  }

  @override
  String get subscriptionTitle => 'LabFox subscription';

  @override
  String get subscriptionActive => 'Subscribed';

  @override
  String get subscriptionInactive => 'Not subscribed';

  @override
  String get subscriptionPitch =>
      'Approve and merge, retry pipelines, and connect more than one account.';

  @override
  String get subscriptionBenefitAccounts =>
      'Connect multiple accounts and self-hosted instances';

  @override
  String get subscriptionBenefitActions =>
      'Approve, merge, retry, cancel, and run manual jobs';

  @override
  String get subscriptionBenefitNotifications =>
      'Background checks that notify you about new to-do items';

  @override
  String get subscriptionBenefitFavorites =>
      'Unlimited favorites, instead of the free limit of three';

  @override
  String subscriptionSubscribe(String price) {
    return 'Subscribe for $price';
  }

  @override
  String get subscriptionRenewalTerms =>
      'The subscription renews every month until you cancel it. Cancel any time in your store account; cancelling takes effect at the end of the paid month.';

  @override
  String get subscriptionTerms => 'Terms of Use';

  @override
  String get subscriptionPrivacy => 'Privacy Policy';

  @override
  String get subscriptionRestore => 'Restore purchases';

  @override
  String get subscriptionUnavailable =>
      'The store is not available right now. Try again later.';

  @override
  String get subscriptionError =>
      'That did not go through. Nothing was charged.';

  @override
  String get subscriptionRestored => 'Your subscription is active.';

  @override
  String get subscriptionNothingToRestore =>
      'No subscription found for this store account.';

  @override
  String get navHome => 'Home';

  @override
  String get navInbox => 'Inbox';

  @override
  String get navSearch => 'Search';

  @override
  String get navMe => 'Me';

  @override
  String get meTitle => 'Me';

  @override
  String get meSettings => 'Settings';

  @override
  String get meAccounts => 'Switch account';

  @override
  String get projectLabelsTitle => 'Labels';

  @override
  String get projectLabelsError => 'Couldn\'t load labels.';

  @override
  String get projectLabelsEmpty => 'No labels yet';

  @override
  String get projectLabelsNoMatch => 'No matching labels';

  @override
  String get projectLabelSearch => 'Search labels';

  @override
  String get projectLabelNew => 'New label';

  @override
  String get projectLabelGroup => 'Group label';

  @override
  String get projectLabelProject => 'Project label';

  @override
  String get projectLabelError => 'Couldn\'t load this label.';

  @override
  String get projectLabelOpenIssues => 'Open issues';

  @override
  String get projectLabelClosedIssues => 'Closed issues';

  @override
  String get projectLabelOpenMrs => 'Open merge requests';

  @override
  String get projectLabelName => 'Name';

  @override
  String get projectLabelColor => 'Color (#RRGGBB)';

  @override
  String get projectLabelDescription => 'Description (optional)';

  @override
  String get projectLabelRequired => 'This field is required';

  @override
  String get projectLabelInvalidColor => 'Enter a color like #5843AD';

  @override
  String get projectLabelCreate => 'Create label';

  @override
  String get projectLabelCreateError =>
      'Couldn\'t create the label. Check your permissions and input.';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get tagsEmpty => 'No tags yet';

  @override
  String get tagsError => 'Couldn\'t load tags.';

  @override
  String get tagsNoMatch => 'No matching tags';

  @override
  String get tagSearchHint => 'Search tags';

  @override
  String get tagError => 'Couldn\'t load this tag.';

  @override
  String get tagProtected => 'Protected tag';

  @override
  String get tagNew => 'New tag';

  @override
  String get tagName => 'Tag name';

  @override
  String get tagFromRef => 'Create from branch, tag, or commit SHA';

  @override
  String get tagMessage => 'Message (optional)';

  @override
  String get tagPipelineNotice => 'Creating a tag may start a CI/CD pipeline.';

  @override
  String get tagFieldRequired => 'This field is required';

  @override
  String get tagCreate => 'Create tag';

  @override
  String get tagCreateError =>
      'Couldn\'t create the tag. Check your permissions and the reference.';

  @override
  String get snippetsTitle => 'Snippets';

  @override
  String get snippetsEmpty => 'No snippets yet';

  @override
  String get snippetsError => 'Couldn\'t load snippets.';

  @override
  String get snippetError => 'Couldn\'t load this snippet.';

  @override
  String get snippetContent => 'Content';

  @override
  String get snippetContentError => 'Couldn\'t load snippet content.';

  @override
  String get homeRecents => 'Recent';

  @override
  String get wikiTitle => 'Wiki';

  @override
  String get wikiEmpty => 'No wiki pages yet.';

  @override
  String get wikiListError => 'Could not load wiki pages.';

  @override
  String get wikiPageError => 'Could not load this wiki page.';

  @override
  String get packageRegistryTitle => 'Package registry';

  @override
  String get packageRegistryEmpty => 'No packages yet.';

  @override
  String get packageRegistryError => 'Could not load packages.';

  @override
  String get packageDetailError => 'Could not load this package.';

  @override
  String get packageFiles => 'Files';

  @override
  String get packageFilesEmpty => 'This package has no files.';

  @override
  String get packageLoadMore => 'Load more';
}
