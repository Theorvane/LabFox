// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get pipelineScheduleExecutionEdit => 'Edit execution settings';

  @override
  String get pipelineScheduleExecutionSave => 'Save';

  @override
  String get pipelineScheduleExecutionActive => 'Active';

  @override
  String get pipelineScheduleExecutionRefRequired => 'Enter a ref.';

  @override
  String get pipelineScheduleExecutionHint =>
      'GitLab validates the ref. Use a full ref if a branch and tag share a name. Saving reschedules future runs; cron, time zone, variables, and inputs are not changed.';

  @override
  String get pipelineScheduleExecutionError =>
      'Could not update execution settings. Check your permissions and ref, then try again.';

  @override
  String get pipelineScheduleCreate => 'Create schedule';

  @override
  String get pipelineScheduleCreateTitle => 'New pipeline schedule';

  @override
  String get pipelineScheduleCreateDescription => 'Description';

  @override
  String get pipelineScheduleCreateFieldRequired => 'Enter a value.';

  @override
  String get pipelineScheduleCreateActive => 'Active';

  @override
  String get pipelineScheduleCreateHint =>
      'GitLab validates the ref, cron, and time zone. Leave the time zone blank to use UTC. Use a full ref if a branch and tag share a name.';

  @override
  String get pipelineScheduleCreateError =>
      'Could not create this pipeline schedule. Check your permissions, ref, cron, and time zone.';

  @override
  String get releaseCreationMilestoneTitle => 'Milestone title (optional)';

  @override
  String get releaseCreationMilestoneAdd => 'Add milestone';

  @override
  String get releaseCreationMilestoneRequired => 'Enter a milestone title.';

  @override
  String get releaseCreationMilestoneDuplicate =>
      'This milestone is already selected.';

  @override
  String releaseCreationMilestoneRemove(String title) {
    return 'Remove milestone $title';
  }

  @override
  String get releaseCreationMilestoneHelp =>
      'Enter exact existing titles, one at a time. Group milestone availability depends on your GitLab plan.';

  @override
  String get releasePickerTitle => 'Select project milestones';

  @override
  String get releasePickerSearch => 'Search project milestones';

  @override
  String get releasePickerEmpty => 'No project milestones found.';

  @override
  String get releasePickerError => 'Could not load milestones.';

  @override
  String get releasePickerMore => 'Load more milestones';

  @override
  String get releasePickerUse => 'Use milestones';

  @override
  String releasePickerRemove(String title) {
    return 'Remove milestone $title';
  }

  @override
  String get releaseCreationDateLabel => 'Publication date (optional)';

  @override
  String get releaseCreationDateDefault =>
      'Publication time will be set by GitLab.';

  @override
  String get releaseCreationChooseDate => 'Choose publication date';

  @override
  String get releaseCreationChooseTime => 'Choose publication time';

  @override
  String get releaseCreationClearDate => 'Use publication time from GitLab';

  @override
  String releaseCreationDateHelp(String zone) {
    return 'Time zone: $zone. Future dates create upcoming releases; past dates create historical releases.';
  }

  @override
  String get pipelineScheduleDelete => 'Delete schedule';

  @override
  String get pipelineScheduleDeleteConfirmTitle =>
      'Delete this pipeline schedule?';

  @override
  String pipelineScheduleDeleteConfirmBody(String name) {
    return 'The pipeline schedule \"$name\" will be permanently deleted. This cannot be undone.';
  }

  @override
  String get pipelineScheduleDeleteError =>
      'Could not delete this pipeline schedule. Check your permissions and try again.';

  @override
  String get releaseScheduleEdit => 'Edit release date';

  @override
  String get releaseScheduleChangeDate => 'Change date';

  @override
  String get releaseScheduleChangeTime => 'Change time';

  @override
  String get releaseScheduleSave => 'Save release date';

  @override
  String get releaseScheduleError => 'Could not update the release date.';

  @override
  String releaseScheduleHelp(String zone) {
    return 'Times use your device time zone ($zone). A future date schedules an upcoming release.';
  }

  @override
  String get pipelineScheduleEdit => 'Edit schedule';

  @override
  String get pipelineScheduleSave => 'Save';

  @override
  String get pipelineScheduleDescription => 'Description';

  @override
  String get pipelineScheduleFieldRequired => 'Enter a value.';

  @override
  String get pipelineScheduleEditHint =>
      'GitLab validates the cron expression and time zone. Saving reschedules future runs; ref, active state, variables, and inputs are preserved.';

  @override
  String get pipelineScheduleEditError =>
      'Could not update this pipeline schedule. Check your permissions, cron, and time zone.';

  @override
  String get pipelineScheduleTakeOwnership => 'Take ownership';

  @override
  String get pipelineScheduleOwnershipConfirmTitle =>
      'Take ownership of this schedule?';

  @override
  String pipelineScheduleOwnershipConfirmBody(String name) {
    return 'You will become the owner of \"$name\". Scheduled pipelines will run with your permissions. This requires the Maintainer or Owner role.';
  }

  @override
  String get pipelineScheduleOwnershipError =>
      'Could not take ownership of this pipeline schedule. Check your permissions and try again.';

  @override
  String get protectedTagProtectTitle => 'Protect tag';

  @override
  String get protectedTagProtectName => 'Rule name';

  @override
  String get protectedTagProtectRole => 'Who can create matching tags?';

  @override
  String get protectedTagProtectNoOne => 'No one';

  @override
  String get protectedTagProtectDevelopers => 'Developers and Maintainers';

  @override
  String get protectedTagProtectMaintainers => 'Maintainers';

  @override
  String protectedTagProtectWarning(String projectId) {
    return 'This rule changes who can create matching tags and may affect tag pipelines and jobs across project $projectId.';
  }

  @override
  String get protectedTagProtectWildcard =>
      'Wildcard rules can also affect future tags. Check the exact pattern and access level.';

  @override
  String get protectedTagProtectAcknowledge =>
      'I understand the project-wide effect of this rule.';

  @override
  String get protectedTagProtectSubmit => 'Protect tag';

  @override
  String get protectedTagProtectExisting =>
      'Rule already exists. No change was made.';

  @override
  String get protectedTagProtectUncertain =>
      'The result is uncertain. Reload all rules before trying again.';

  @override
  String get protectedTagProtectReload => 'Reload rules';

  @override
  String get protectedTagProtectLoadError =>
      'Could not verify the protected tag rules. Try reloading.';

  @override
  String get protectedTagProtectSessionChanged =>
      'Your account changed. Close this draft and start again.';

  @override
  String get protectedTagProtectCreated => 'Protected tag rule created.';

  @override
  String get protectedTagProtectCancel => 'Cancel';

  @override
  String get protectedTagProtectForbidden =>
      'You do not have permission to create this rule. Reload before trying again.';

  @override
  String get protectedTagProtectUnauthorized =>
      'Your session has expired. Sign in again before creating a rule.';

  @override
  String get protectedTagProtectRateLimited =>
      'GitLab is rate limiting requests. Wait, then reload the rules.';

  @override
  String get protectedTagProtectUnavailable =>
      'This project or protected tag resource is unavailable. Reload before trying again.';

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
  String get protectedBranchProtectTitle => 'Protect branch';

  @override
  String get protectedBranchProtectName => 'Rule name';

  @override
  String get protectedBranchProtectPush => 'Allowed to push';

  @override
  String get protectedBranchProtectMerge => 'Allowed to merge';

  @override
  String get protectedBranchProtectNoOne => 'No one';

  @override
  String get protectedBranchProtectDevelopers => 'Developers and Maintainers';

  @override
  String get protectedBranchProtectMaintainers => 'Maintainers';

  @override
  String protectedBranchProtectWarning(String projectId) {
    return 'This rule changes push and merge access in project $projectId. It can affect merge requests, protected CI variables, and jobs.';
  }

  @override
  String get protectedBranchProtectWildcard =>
      'Wildcard rules may also affect future branches. Check the exact pattern and both permissions.';

  @override
  String get protectedBranchProtectAcknowledge =>
      'I understand the project-wide effect of this rule.';

  @override
  String get protectedBranchProtectSubmit => 'Protect branch';

  @override
  String get protectedBranchProtectExisting =>
      'Rule already exists. No change was made.';

  @override
  String get protectedBranchProtectUncertain =>
      'The result is uncertain. Reload all rules before trying again.';

  @override
  String get protectedBranchProtectReload => 'Reload rules';

  @override
  String get protectedBranchProtectLoadError =>
      'Could not verify protected branch rules. Try reloading.';

  @override
  String get protectedBranchProtectSessionChanged =>
      'Your account changed. Close this draft and start again.';

  @override
  String get protectedBranchProtectCreated => 'Protected branch rule created.';

  @override
  String get protectedBranchProtectCancel => 'Cancel';

  @override
  String get protectedBranchProtectForbidden =>
      'You do not have permission to create this rule. Reload before trying again.';

  @override
  String get protectedBranchProtectUnauthorized =>
      'Your session has expired. Sign in again before creating a rule.';

  @override
  String get protectedBranchProtectRateLimited =>
      'GitLab is rate limiting requests. Wait, then reload the rules.';

  @override
  String get protectedBranchProtectUnavailable =>
      'This project or protected branch resource is unavailable. Reload before trying again.';

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
  String get pipelineScheduleHistoryTitle => 'Execution history';

  @override
  String get pipelineScheduleHistoryEmpty =>
      'No pipelines have run for this schedule yet.';

  @override
  String get pipelineScheduleHistoryError =>
      'Could not load execution history.';

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
  String get releaseEdit => 'Edit release';

  @override
  String get releaseSave => 'Save release';

  @override
  String get releaseEditName => 'Release name';

  @override
  String get releaseEditDescription => 'Description (Markdown)';

  @override
  String get releaseNameRequired => 'Enter a release name.';

  @override
  String get releaseEditError => 'Could not update the release.';

  @override
  String get releaseNew => 'New release';

  @override
  String get releaseCreate => 'Create release';

  @override
  String get releaseTagName => 'Tag name';

  @override
  String get releaseRef => 'Create tag from ref (optional)';

  @override
  String get releaseRefHelp => 'Leave blank if the tag already exists.';

  @override
  String get releaseName => 'Release name (optional)';

  @override
  String get releaseDescription => 'Description (Markdown)';

  @override
  String get releaseTagRequired => 'Enter a tag name.';

  @override
  String get releaseCreateError => 'Could not create the release.';

  @override
  String get releaseAddAssetLink => 'Add asset link';

  @override
  String get releaseAddLink => 'Add link';

  @override
  String get releaseAssetName => 'Link name';

  @override
  String get releaseAssetUrl => 'Link URL';

  @override
  String get releaseAssetNameRequired => 'Enter a link name.';

  @override
  String get releaseAssetUrlInvalid => 'Enter an HTTP or HTTPS URL.';

  @override
  String get releaseAssetNameDuplicate =>
      'A link with this name already exists.';

  @override
  String get releaseAssetCreateError => 'Could not add the asset link.';

  @override
  String get releaseNoAssets => 'No assets yet.';

  @override
  String get releaseDelete => 'Delete release';

  @override
  String get releaseDeleteConfirmTitle => 'Delete this release?';

  @override
  String get releaseDeleteConfirmBody =>
      'The release and its notes will be deleted. The Git tag will remain.';

  @override
  String get releaseDeleteError => 'Could not delete the release.';

  @override
  String get releaseDeleteAssetLink => 'Delete asset link';

  @override
  String get releaseDeleteLink => 'Delete link';

  @override
  String get releaseAssetDeleteConfirmTitle => 'Delete this asset link?';

  @override
  String releaseAssetDeleteConfirmBody(String name) {
    return 'This removes the link named $name. The linked file will not be deleted.';
  }

  @override
  String get releaseAssetDeleteError => 'Could not delete the asset link.';

  @override
  String get releaseEditAssetLink => 'Edit asset link';

  @override
  String get releaseSaveLink => 'Save link';

  @override
  String get releaseAssetEditError => 'Could not update the asset link.';

  @override
  String get releaseMilestonesEdit => 'Edit release milestones';

  @override
  String get releaseMilestonesTitle => 'Milestones';

  @override
  String get releaseMilestonesHelp =>
      'Enter exact milestone titles. Group milestone availability depends on your GitLab plan and project group.';

  @override
  String get releaseMilestoneTitle => 'Milestone title';

  @override
  String get releaseMilestoneAdd => 'Add milestone';

  @override
  String get releaseMilestonesSave => 'Save milestones';

  @override
  String get releaseMilestonesError => 'Could not update release milestones.';

  @override
  String get releaseMilestoneTitleRequired => 'Enter a milestone title.';

  @override
  String get releaseMilestoneDuplicate => 'This milestone is already selected.';

  @override
  String releaseMilestoneRemove(String title) {
    return 'Remove $title';
  }

  @override
  String get releaseAssetDirectPath => 'New direct download path (optional)';

  @override
  String get releaseAssetDirectPathHelp =>
      'Leave blank to keep the current direct download path. Enter a path such as /bin/app.zip to replace it.';

  @override
  String get releaseAssetDirectPathInvalid =>
      'Enter a path starting with /, without a host, query, or fragment.';

  @override
  String get releaseAssetType => 'Link type';

  @override
  String get releaseAssetKeepType => 'Keep current type';

  @override
  String get releaseAssetTypeOther => 'Other';

  @override
  String get releaseAssetTypeRunbook => 'Runbook';

  @override
  String get releaseAssetTypeImage => 'Image';

  @override
  String get releaseAssetTypePackage => 'Package';

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
  String get milestoneNew => 'New milestone';

  @override
  String get milestoneCreate => 'Create milestone';

  @override
  String get milestoneTitleField => 'Title';

  @override
  String get milestoneDescriptionField => 'Description';

  @override
  String get milestoneTitleRequired => 'Enter a milestone title.';

  @override
  String get milestoneDateOrderError =>
      'Start date must be on or before due date.';

  @override
  String get milestoneCreateError => 'Could not create the milestone.';

  @override
  String get milestoneChooseDate => 'Choose date';

  @override
  String get milestoneClearDate => 'Clear date';

  @override
  String get milestoneEdit => 'Edit milestone';

  @override
  String get milestoneSaveChanges => 'Save changes';

  @override
  String get milestoneUpdateError => 'Could not update the milestone.';

  @override
  String get milestoneClearStartDate => 'Clear start date';

  @override
  String get milestoneClearDueDate => 'Clear due date';

  @override
  String get milestoneClose => 'Close milestone';

  @override
  String get milestoneReactivate => 'Reactivate milestone';

  @override
  String get milestoneCloseConfirmTitle => 'Close this milestone?';

  @override
  String get milestoneCloseConfirmBody => 'You can reactivate it later.';

  @override
  String get milestoneStateError => 'Could not change the milestone state.';

  @override
  String get milestoneDelete => 'Delete milestone';

  @override
  String get milestoneDeleteConfirmTitle => 'Delete this milestone?';

  @override
  String get milestoneDeleteConfirmBody => 'This cannot be undone.';

  @override
  String get milestoneDeleteError => 'Could not delete the milestone.';

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
  String get issueEditLabels => 'Edit labels';

  @override
  String get issueSaveLabels => 'Save labels';

  @override
  String get issueLabelsEmpty => 'No labels available';

  @override
  String get issueLabelsLoadError => 'Could not load labels.';

  @override
  String get issueLabelsSaveError =>
      'Could not update labels. Please try again.';

  @override
  String get issueEditDueDate => 'Edit due date';

  @override
  String get issueConfidential => 'Confidential';

  @override
  String get issueMakeConfidential => 'Make confidential';

  @override
  String get issueRemoveConfidentiality => 'Remove confidentiality';

  @override
  String get issueMakeConfidentialExplanation =>
      'Access to this issue will be restricted. Continue?';

  @override
  String get issueRemoveConfidentialityExplanation =>
      'This issue will become visible to everyone who can see the project. Continue?';

  @override
  String get issueConfidentialityConfirm => 'Confirm';

  @override
  String get issueConfidentialityError =>
      'Could not update confidentiality. Check your permissions and try again.';

  @override
  String get issueDiscussionLocked => 'Discussion locked';

  @override
  String get issueLockDiscussion => 'Lock discussion';

  @override
  String get issueUnlockDiscussion => 'Unlock discussion';

  @override
  String get issueLockDiscussionExplanation =>
      'Only project members will be able to add or edit comments. Continue?';

  @override
  String get issueUnlockDiscussionExplanation =>
      'Others with access to this issue will be able to comment again. Continue?';

  @override
  String get issueDiscussionLockConfirm => 'Confirm';

  @override
  String get issueDiscussionLockError =>
      'Could not change the discussion lock. Check your permissions and try again.';

  @override
  String get issueEditMilestone => 'Edit milestone';

  @override
  String get issueEditAssignees => 'Edit assignees';

  @override
  String get issueAssignees => 'Assignees';

  @override
  String get issueSaveAssignees => 'Save assignees';

  @override
  String get issueAssigneesSaveError =>
      'Could not update assignees. Check your permissions and try again.';

  @override
  String get issueNoMilestone => 'No milestone';

  @override
  String get issueMilestonesLoadError => 'Could not load milestones.';

  @override
  String get issueMilestoneSaveError =>
      'Could not update the milestone. Check your permissions and try again.';

  @override
  String get issueDueDate => 'Due date';

  @override
  String issueDueDateValue(String date) {
    return 'Due date: $date';
  }

  @override
  String get issueSelectDueDate => 'Select date';

  @override
  String get issueClearDueDate => 'Clear due date';

  @override
  String get issueDueDateError =>
      'Could not update the due date. Please try again.';

  @override
  String get issueSaveChanges => 'Save changes';

  @override
  String get issueEditError =>
      'Could not save the issue. Check your permissions and try again.';

  @override
  String get issueSubscribe => 'Subscribe to notifications';

  @override
  String get issueUnsubscribe => 'Unsubscribe from notifications';

  @override
  String get issueSubscriptionError =>
      'Could not update issue notifications. Please try again.';

  @override
  String get mrSubscribe => 'Subscribe to notifications';

  @override
  String get mrUnsubscribe => 'Unsubscribe from notifications';

  @override
  String get mrSubscriptionError =>
      'Could not update merge request notifications. Please try again.';

  @override
  String get issueAddTodo => 'Add to To-Do';

  @override
  String get issueTodoAdded => 'Added to your To-Do list.';

  @override
  String get issueTodoExists => 'This issue is already in your To-Do list.';

  @override
  String get issueTodoError =>
      'Could not add the issue to your To-Do list. Please try again.';

  @override
  String get mrAddTodo => 'Add to To-Do';

  @override
  String get mrTodoAdded => 'Added to your To-Do list.';

  @override
  String get mrTodoExists =>
      'This merge request is already in your To-Do list.';

  @override
  String get mrTodoError =>
      'Could not add the merge request to your To-Do list. Please try again.';

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
  String get pipelinesLoadMore => 'Load more';

  @override
  String get pipelinesLoadMoreError => 'Could not load more pipelines.';

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
  String get snippetNew => 'New snippet';

  @override
  String get snippetTitleField => 'Title';

  @override
  String get snippetDescriptionField => 'Description';

  @override
  String get snippetFilePathField => 'File path';

  @override
  String get snippetContentField => 'Content';

  @override
  String get snippetVisibilityField => 'Visibility';

  @override
  String get snippetVisibilityUnchanged => 'Keep current visibility';

  @override
  String get snippetPrivate => 'Private';

  @override
  String get snippetPublic => 'Public';

  @override
  String get snippetCreate => 'Create snippet';

  @override
  String get snippetCreateValidationError =>
      'Enter a title, file path, and content.';

  @override
  String get snippetCreateError => 'Could not create the snippet.';

  @override
  String get snippetAddFile => 'Add file';

  @override
  String get snippetFileAddValidationError =>
      'Enter a unique relative file path and content.';

  @override
  String get snippetFileAddError => 'Could not add the file.';

  @override
  String get snippetFileMoveAction => 'Move file';

  @override
  String get snippetFileMoveTitle => 'Move or rename file';

  @override
  String get snippetFileMovePathField => 'New file path';

  @override
  String get snippetFileMoveValidationError =>
      'Enter a different, unused relative file path.';

  @override
  String get snippetFileMoveError => 'Could not move the file.';

  @override
  String get snippetEditAction => 'Edit snippet';

  @override
  String get snippetEditTitle => 'Edit snippet';

  @override
  String get snippetSaveChanges => 'Save changes';

  @override
  String get snippetEditValidationError => 'Enter a title.';

  @override
  String get snippetEditError => 'Could not save the snippet.';

  @override
  String get snippetDeleteAction => 'Delete snippet';

  @override
  String get snippetDeleteConfirmTitle => 'Delete this snippet?';

  @override
  String get snippetDeleteConfirmMessage =>
      'This permanently deletes the snippet and its files.';

  @override
  String get snippetDeleteButton => 'Delete';

  @override
  String get snippetDeleteError => 'Could not delete the snippet.';

  @override
  String get snippetFileDeleteAction => 'Delete file';

  @override
  String get snippetFileDeleteConfirmTitle => 'Delete this file?';

  @override
  String get snippetFileDeleteConfirmMessage =>
      'This permanently deletes only this file from the snippet.';

  @override
  String get snippetFileDeleteError => 'Could not delete the file.';

  @override
  String get snippetEditContent => 'Edit content';

  @override
  String get snippetSaveContent => 'Save content';

  @override
  String get snippetContentSaveError => 'Could not save snippet content.';

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
  String get wikiNewPage => 'New page';

  @override
  String get wikiPagesSection => 'Pages';

  @override
  String get wikiTemplatesSection => 'Templates';

  @override
  String get wikiTemplateEmpty => 'No templates yet.';

  @override
  String get wikiNewTemplate => 'New template';

  @override
  String get wikiTemplateTitle => 'Template title';

  @override
  String get wikiCreateTemplate => 'Create template';

  @override
  String get wikiCreateTemplateError => 'Could not create the template.';

  @override
  String get wikiPageTitle => 'Title';

  @override
  String get wikiPageContent => 'Content';

  @override
  String get wikiCreatePage => 'Create page';

  @override
  String get wikiChooseTemplate => 'Choose a template';

  @override
  String get wikiReplaceTemplateContent =>
      'Replace the current content with this template?';

  @override
  String get wikiApplyTemplate => 'Apply template';

  @override
  String get wikiTemplateLoadError => 'Could not load the template.';

  @override
  String get wikiCreateValidationError => 'Enter a title and content.';

  @override
  String get wikiCreateError => 'Could not create the wiki page.';

  @override
  String get wikiEditPageAction => 'Edit';

  @override
  String get wikiEditPage => 'Edit wiki page';

  @override
  String get wikiEditTitle => 'Title';

  @override
  String get wikiEditContent => 'Content';

  @override
  String get wikiSaveChanges => 'Save changes';

  @override
  String get wikiEditValidationError => 'Enter a title and content.';

  @override
  String get wikiEditError => 'Could not save the wiki page.';

  @override
  String get wikiEditConflict =>
      'This page changed on GitLab. Reload it before editing again.';

  @override
  String get wikiDeletePageAction => 'Delete page';

  @override
  String get wikiDeleteConfirmTitle => 'Delete this wiki page?';

  @override
  String get wikiDeleteConfirmMessage =>
      'This permanently deletes the page from the project wiki.';

  @override
  String get wikiDeleteError => 'Could not delete the wiki page.';

  @override
  String get wikiDeleteConflict =>
      'This page changed. Reload it before deleting.';

  @override
  String get wikiReloadPage => 'Reload page';

  @override
  String get packageRegistryTitle => 'Package registry';

  @override
  String get packageDelete => 'Delete package';

  @override
  String get packageDeleteConfirmTitle => 'Delete this package?';

  @override
  String packageDeleteConfirmBody(String name) {
    return 'Delete $name and all its files? This cannot be undone.';
  }

  @override
  String get packageDeleteForwardingWarning =>
      'If request forwarding is enabled, deleting this package can create a dependency confusion risk.';

  @override
  String get packageDeleteError =>
      'Could not delete this package. Please try again.';

  @override
  String get packageDeleteForbidden =>
      'This package may be protected, or you may not have permission to delete it.';

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

  @override
  String get protectedTagUnprotectTitle => 'Unprotect tag rule';

  @override
  String protectedTagUnprotectTarget(String projectId, String name) {
    return 'Project $projectId — rule $name';
  }

  @override
  String get protectedTagUnprotectWarning =>
      'Remove this repository tag protection rule. No tags are deleted. A wildcard can affect many existing and future tags. Removing protection may allow more users to create or delete matching tags and change access to tag pipelines and jobs. Other matching rules may still protect tags; GitLab decides effective access. Review the current creation permissions below.';

  @override
  String protectedTagUnprotectAccess(
    String description,
    String role,
    String user,
    String group,
    String key,
  ) {
    return '$description\nRole level: $role; user ID: $user; group ID: $group; deploy key ID: $key';
  }

  @override
  String get protectedTagUnprotectUnreported => 'Not reported';

  @override
  String get protectedTagUnprotectName =>
      'Re-enter the exact rule name or pattern';

  @override
  String get protectedTagUnprotectAcknowledge =>
      'I understand the protection loss for all tags matching this rule and want to remove this rule.';

  @override
  String get protectedTagUnprotectAuth =>
      'Your session was rejected. Sign in again before reviewing the rule.';

  @override
  String get protectedTagUnprotectForbidden =>
      'GitLab denied permission to unprotect this rule. A Maintainer or Owner role is required.';

  @override
  String get protectedTagUnprotectUnavailable =>
      'The rule is missing, private, or unavailable on this instance. Reload to check; no other rule will be removed.';

  @override
  String get protectedTagUnprotectStale =>
      'The rule changed. Reload and confirm the current permissions before removing it.';

  @override
  String get protectedTagUnprotectRateLimited =>
      'GitLab is rate limiting requests. Wait, then reload and confirm the rule again.';

  @override
  String get protectedTagUnprotectError =>
      'The request could not be confirmed. Reload the rule and confirm again before retrying.';

  @override
  String get protectedTagUnprotectReload => 'Reload rule';

  @override
  String get protectedTagUnprotectSessionChanged =>
      'The account changed. Close this dialog and reopen it to review the current project.';

  @override
  String get protectedTagUnprotectAccepted =>
      'Tag protection rule removed. No tags were deleted.';

  @override
  String get protectedBranchForcePushEditTitle => 'Edit force push';

  @override
  String protectedBranchForcePushEditTarget(String project, String name) {
    return 'Project $project: $name';
  }

  @override
  String get protectedBranchForcePushCurrentAllowed =>
      'Force push is currently allowed.';

  @override
  String get protectedBranchForcePushCurrentBlocked =>
      'Force push is currently blocked.';

  @override
  String get protectedBranchForcePushAllow => 'Allow force push';

  @override
  String get protectedBranchForcePushSave => 'Save setting';

  @override
  String get protectedBranchForcePushEnableWarning =>
      'Allowing force pushes can rewrite history on matching branches. A wildcard rule can affect multiple branches.';

  @override
  String get protectedBranchForcePushDisableWarning =>
      'Blocking force pushes changes how members work on matching branches. A wildcard rule can affect multiple branches.';

  @override
  String get protectedBranchForcePushAcknowledge =>
      'I understand this change for matching branches.';

  @override
  String get protectedBranchForcePushReload => 'Check rule again';

  @override
  String get protectedBranchForcePushSuccess => 'Force-push setting updated.';

  @override
  String get protectedBranchForcePushAuth =>
      'Sign in again before changing this rule.';

  @override
  String get protectedBranchForcePushForbidden =>
      'You do not have permission to change this rule.';

  @override
  String get protectedBranchForcePushUnavailable =>
      'This rule is no longer available. Check the list before continuing.';

  @override
  String get protectedBranchForcePushStale =>
      'The rule changed. Check it again before continuing.';

  @override
  String get protectedBranchForcePushRateLimited =>
      'GitLab is limiting requests. Check the rule before trying again.';

  @override
  String get protectedBranchForcePushError =>
      'Could not confirm this change. Check the rule before trying again.';

  @override
  String get protectedBranchForcePushSessionChanged =>
      'The account changed. Close this dialog and open the rule again.';

  @override
  String get protectedBranchMergeRoleEditTitle => 'Edit merge access';

  @override
  String protectedBranchMergeRoleTarget(String project, String name) {
    return 'Project $project: $name';
  }

  @override
  String protectedBranchMergeRoleCurrent(String role) {
    return 'Current merge access: $role';
  }

  @override
  String get protectedBranchMergeRoleNone => 'No one';

  @override
  String get protectedBranchMergeRoleDeveloper => 'Developers + Maintainers';

  @override
  String get protectedBranchMergeRoleMaintainer => 'Maintainers';

  @override
  String get protectedBranchMergeRoleWarning =>
      'Changing merge access affects all branches matching this rule. A wildcard can affect multiple branches and merge request workflows.';

  @override
  String get protectedBranchMergeRoleAcknowledge =>
      'I understand the merge access change for matching branches.';

  @override
  String get protectedBranchMergeRoleSave => 'Save merge access';

  @override
  String get protectedBranchMergeRoleReload => 'Check rule again';

  @override
  String get protectedBranchMergeRoleSuccess => 'Merge access updated.';

  @override
  String get protectedBranchMergeRoleAuth =>
      'Sign in again before changing this rule.';

  @override
  String get protectedBranchMergeRoleForbidden =>
      'You do not have permission to change merge access.';

  @override
  String get protectedBranchMergeRoleUnavailable =>
      'This rule is no longer available. Check the list before continuing.';

  @override
  String get protectedBranchMergeRoleStale =>
      'The rule changed. Check it again before continuing.';

  @override
  String get protectedBranchMergeRoleRateLimited =>
      'GitLab is limiting requests. Check the rule before trying again.';

  @override
  String get protectedBranchMergeRoleError =>
      'Could not confirm this change. Check the rule before trying again.';

  @override
  String get protectedBranchMergeRoleSessionChanged =>
      'The account changed. Close this dialog and open the rule again.';

  @override
  String get protectedBranchPushRoleEditTitle => 'Edit push access';

  @override
  String protectedBranchPushRoleTarget(String project, String name) {
    return 'Project $project: $name';
  }

  @override
  String protectedBranchPushRoleCurrent(String role) {
    return 'Current push access: $role';
  }

  @override
  String get protectedBranchPushRoleNone => 'No one';

  @override
  String get protectedBranchPushRoleDeveloper => 'Developers + Maintainers';

  @override
  String get protectedBranchPushRoleMaintainer => 'Maintainers';

  @override
  String get protectedBranchPushRoleWarning =>
      'Changing push access affects all branches matching this rule. It can change who may commit directly; if force push is enabled, it may also change who can rewrite history. A wildcard can affect multiple branches.';

  @override
  String get protectedBranchPushRoleAcknowledge =>
      'I understand the push access change for matching branches.';

  @override
  String get protectedBranchPushRoleSave => 'Save push access';

  @override
  String get protectedBranchPushRoleReload => 'Check rule again';

  @override
  String get protectedBranchPushRoleSuccess => 'Push access updated.';

  @override
  String get protectedBranchPushRoleAuth =>
      'Sign in again before changing this rule.';

  @override
  String get protectedBranchPushRoleForbidden =>
      'You do not have permission to change push access.';

  @override
  String get protectedBranchPushRoleUnavailable =>
      'This rule is no longer available. Check the list before continuing.';

  @override
  String get protectedBranchPushRoleStale =>
      'The rule changed. Check it again before continuing.';

  @override
  String get protectedBranchPushRoleRateLimited =>
      'GitLab is limiting requests. Check the rule before trying again.';

  @override
  String get protectedBranchPushRoleError =>
      'Could not confirm this change. Check the rule before trying again.';

  @override
  String get protectedBranchPushRoleSessionChanged =>
      'The account changed. Close this dialog and open the rule again.';

  @override
  String get protectedEnvironmentCreateTitle => 'Protect environment';

  @override
  String get protectedEnvironmentCreateName => 'Environment name';

  @override
  String get protectedEnvironmentCreateDeveloper => 'Developers + Maintainers';

  @override
  String get protectedEnvironmentCreateMaintainer => 'Maintainers';

  @override
  String get protectedEnvironmentCreateWarning =>
      'This protection changes who may deploy to the named environment. Approval rules are not added.';

  @override
  String get protectedEnvironmentCreateAcknowledge =>
      'I understand the deployment access change.';

  @override
  String get protectedEnvironmentCreateSave => 'Protect environment';

  @override
  String get protectedEnvironmentCreateReload => 'Check environments again';

  @override
  String get protectedEnvironmentCreateDuplicate =>
      'This environment is already protected. Check the list before continuing.';

  @override
  String get protectedEnvironmentCreateError =>
      'Could not confirm protection. Check the list before trying again.';

  @override
  String get protectedEnvironmentCreateForbidden =>
      'You do not have permission or this feature is unavailable.';

  @override
  String get protectedEnvironmentCreateSessionChanged =>
      'The account changed. Close this dialog and open it again.';

  @override
  String get protectedEnvironmentCreateSuccess => 'Environment protected.';

  @override
  String get protectedEnvironmentCreateInvalidName =>
      'Enter an exact environment name without wildcards.';

  @override
  String get protectedEnvironmentRemoveRoleTitle => 'Remove deploy role';

  @override
  String get protectedEnvironmentRemoveRoleWarning =>
      'Removing this grant may prevent the selected role from deploying. Other deploy grants and approval rules remain. The environment stays protected.';

  @override
  String get protectedEnvironmentRemoveRoleAcknowledge =>
      'I understand this removes the selected deployment grant.';

  @override
  String get protectedEnvironmentRemoveRoleSuccess => 'Deploy role removed.';

  @override
  String get protectedEnvironmentRemoveRoleForbidden =>
      'You do not have permission to remove this deploy grant.';

  @override
  String get protectedEnvironmentRemoveRoleError =>
      'Could not confirm the deploy grant removal. Check the rule before trying again.';

  @override
  String protectedEnvironmentRemoveRoleGrantLabel(String role, String id) {
    return '$role (grant $id)';
  }

  @override
  String get protectedEnvironmentDeployRoleTitle => 'Add deploy role';

  @override
  String get protectedEnvironmentDeployRoleWarning =>
      'The selected role will be allowed to deploy. Existing deploy grants and approval rules remain.';

  @override
  String get protectedEnvironmentDeployRoleAcknowledge =>
      'I understand this expands deployment access.';

  @override
  String get protectedEnvironmentDeployRoleSuccess => 'Deploy role added.';

  @override
  String get protectedEnvironmentDeployRoleForbidden =>
      'You do not have permission to change deploy access.';

  @override
  String get protectedEnvironmentDeployRoleError =>
      'Could not confirm the deploy role update. Check the rule before trying again.';

  @override
  String get protectedEnvironmentUnprotectTitle => 'Unprotect environment';

  @override
  String protectedEnvironmentUnprotectTarget(String project, String name) {
    return 'Project $project: $name';
  }

  @override
  String get protectedEnvironmentUnprotectWarning =>
      'Unprotecting this project rule removes every deploy grant and approval rule shown below. The environment and past deployments remain. Any group protection may still apply.';

  @override
  String get protectedEnvironmentUnprotectName =>
      'Type the exact environment name';

  @override
  String get protectedEnvironmentUnprotectAcknowledge =>
      'I understand that these deployment restrictions and approval rules will be removed.';

  @override
  String get protectedEnvironmentUnprotectReload => 'Check rule again';

  @override
  String get protectedEnvironmentUnprotectAuth =>
      'Sign in again before changing this rule.';

  @override
  String get protectedEnvironmentUnprotectForbidden =>
      'You do not have permission to unprotect this environment.';

  @override
  String get protectedEnvironmentUnprotectUnavailable =>
      'This rule is no longer available. Check the list before continuing.';

  @override
  String get protectedEnvironmentUnprotectStale =>
      'The rule changed. Check it again before continuing.';

  @override
  String get protectedEnvironmentUnprotectRateLimited =>
      'GitLab is limiting requests. Check the rule before trying again.';

  @override
  String get protectedEnvironmentUnprotectError =>
      'Could not confirm removal. Check the rule before trying again.';

  @override
  String get protectedEnvironmentUnprotectSessionChanged =>
      'The account changed. Close this dialog and open the rule again.';

  @override
  String get protectedEnvironmentUnprotectSuccess =>
      'Environment protection removed.';

  @override
  String get protectedEnvironmentUnprotectUnreported => 'Access entry';

  @override
  String get containerPolicyStatus => 'Status';

  @override
  String get containerPolicyTitle => 'Cleanup policy';

  @override
  String get containerPolicyAbsent => 'GitLab did not report a cleanup policy.';

  @override
  String get containerPolicyHint =>
      'Read-only settings for all container image repositories in this project. Cleanup removes matching tags asynchronously, preserving keep rules, latest, protected and immutable tags. Some tags may require multiple runs; image storage is not reclaimed by tag removal.';

  @override
  String get containerPolicyNextRun =>
      'Next run reported by GitLab (local time)';

  @override
  String containerPolicyDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String containerPolicyMonths(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String get containerPolicyEnabled => 'Enabled';

  @override
  String get containerPolicyDisabled => 'Disabled';

  @override
  String get containerPolicyNotReported => 'Not reported';

  @override
  String get containerPolicyCadence => 'Run interval';

  @override
  String get containerCreateTitle => 'Create cleanup policy';

  @override
  String get containerCreateSave => 'Confirm disabled policy creation';

  @override
  String get containerCreateWarning =>
      'Save cleanup criteria for all image repositories. Cleanup stays disabled unless you select activation. The default keep pattern .* preserves all tags by pattern; a blank keep pattern provides no pattern-based retention. Patterns are sent exactly as entered and use GitLab RE2 full-tag matching. Validation may be deferred while disabled. Acceptance does not confirm cleanup completion or reclaimed storage.';

  @override
  String get containerCreateAcknowledge =>
      'I have reviewed these criteria and understand that this policy will stay disabled.';

  @override
  String get containerCreateExisting =>
      'This project already has a cleanup policy. Creation will not replace it; use its existing settings.';

  @override
  String get containerCreateUnknown =>
      'GitLab did not report whether a policy exists. Review it in GitLab; creation is blocked.';

  @override
  String get containerCreateAccepted => 'Cleanup policy creation accepted.';

  @override
  String get containerCreateInvalid =>
      'GitLab rejected these policy settings. Review the criteria, then edit or retry.';

  @override
  String get containerCreateDaily => 'Every day';

  @override
  String get containerCreateWeekly => 'Every week';

  @override
  String get containerCreateFortnightly => 'Every two weeks';

  @override
  String get containerCreateMonthly => 'Every month';

  @override
  String get containerCreateQuarterly => 'Every three months';

  @override
  String containerCreateDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get containerPolicyKeepCount => 'Matching tags to keep per image';

  @override
  String get containerCreateEnable => 'Enable cleanup when creating';

  @override
  String get containerCreateEnabledWarning =>
      'An enabled policy can permanently delete matching tags across all image repositories in this project on its schedule. Review cadence, retention count, age, and both patterns. GitLab controls protected or immutable tag exclusions; saving does not confirm deletion or reclaimed storage.';

  @override
  String get containerCreateEnabledAcknowledge =>
      'I have reviewed every criterion and accept scheduled, permanent deletion of matching tags across this project.';

  @override
  String get containerCreateEnabledSave => 'Confirm enabled policy creation';

  @override
  String get containerCreateSessionChanged =>
      'The account changed. Close this dialog and reopen it to review the current project before creating a policy.';

  @override
  String get containerPolicyAge => 'Remove tags older than';

  @override
  String get containerPolicyDeletePattern => 'Delete pattern';

  @override
  String get containerPolicyLegacyPattern => 'Delete pattern (legacy)';

  @override
  String get containerPolicyKeepPattern => 'Keep pattern';

  @override
  String get containerPolicyEmptyPattern => 'Empty pattern';

  @override
  String get containerPolicyError => 'Could not load the cleanup policy.';

  @override
  String get containerPolicyForbidden =>
      'You do not have permission to view this project cleanup policy.';

  @override
  String get containerPolicyUnavailable =>
      'The project is not accessible, or cleanup policy information is unavailable.';

  @override
  String get containerPolicyEmptySetting => 'Empty setting';

  @override
  String containerActivationTarget(String projectId) {
    return 'Project $projectId — all image repositories';
  }

  @override
  String get containerActivationError =>
      'Could not confirm the update. Reload the policy and try again.';

  @override
  String get containerActivationIncomplete =>
      'To enable cleanup, cadence, retention count, age limit and delete pattern must be reported. Review the policy in GitLab.';

  @override
  String get containerActivationTitle => 'Change cleanup policy status';

  @override
  String get containerActivationEnable => 'Enable cleanup';

  @override
  String get containerActivationDisable => 'Disable cleanup';

  @override
  String get containerActivationEnableWarning =>
      'Enabling this project-wide policy can permanently remove matching tags on scheduled runs. The shown retention settings and patterns will not be changed. Tag removal does not reclaim image storage.';

  @override
  String get containerActivationDisableWarning =>
      'Disable future scheduled cleanup for this project without changing retention settings or patterns. Do not assume cleanup jobs already running are cancelled.';

  @override
  String get containerActivationUnknown =>
      'A known activation status is required. Review policy settings in GitLab.';

  @override
  String get containerActivationInvalid =>
      'GitLab rejected this status change. Review the existing policy settings in GitLab.';

  @override
  String get containerActivationAccepted =>
      'Cleanup policy status update accepted.';

  @override
  String get containerActivationForbidden =>
      'You do not have permission to change this cleanup policy.';

  @override
  String get containerActivationStale =>
      'The policy changed or is no longer reported. Reload and review it before saving.';

  @override
  String get containerActivationReload => 'Reload policy';

  @override
  String get containerActivationRateLimited =>
      'Too many requests. Wait and reload the policy before trying again.';

  @override
  String get containerCadenceTitle => 'Edit cleanup cadence';

  @override
  String get containerCadenceSave => 'Confirm cadence change';

  @override
  String get containerCadenceSelect => 'New cadence (GitLab API interval)';

  @override
  String get containerCadenceWarning =>
      'Changing this project-wide cadence affects future scheduled tag cleanup in all image repositories. Review activation and deletion/retention criteria below. This does not change those settings or confirm cleanup completion.';

  @override
  String get containerCadenceUnknown =>
      'Reported activation, cadence, retention count, age limit and delete pattern are required. Review missing settings in GitLab. No policy will be created.';

  @override
  String get containerCadenceAccepted => 'Cleanup cadence update accepted.';

  @override
  String get containerTagProtectionTitle => 'Tag protection rules';

  @override
  String get containerTagProtectionCreateTitle => 'Create tag protection rule';

  @override
  String get containerTagProtectionCreateSave => 'Create rule';

  @override
  String get containerTagProtectionCreatePattern => 'Tag name pattern';

  @override
  String get containerTagProtectionCreatePush => 'Minimum push role';

  @override
  String get containerTagProtectionCreateDelete => 'Minimum delete role';

  @override
  String get containerTagProtectionCreateUnset => 'Select a role';

  @override
  String get containerTagProtectionCreateWarning =>
      'This project-wide rule restricts pushing and deleting tags matching the exact glob pattern. Wildcards can affect many tags and block existing release or cleanup workflows. Both roles are required. Other rules and permissions still apply; these values do not describe your access or delete images.';

  @override
  String get containerTagProtectionCreateAcknowledge =>
      'I have reviewed the exact tag pattern and both roles and understand the impact on matching tags.';

  @override
  String containerTagProtectionCreateProject(String projectId) {
    return 'Project $projectId';
  }

  @override
  String get containerTagProtectionCreateForbidden =>
      'You do not have permission to create this rule.';

  @override
  String get containerTagProtectionCreateInvalid =>
      'The tag pattern or roles were rejected. Review both required roles and retry.';

  @override
  String get containerTagProtectionCreateError =>
      'Could not confirm tag rule creation. Check the rule list before retrying; the server may have accepted the request.';

  @override
  String get containerTagProtectionCreateSaved => 'The tag rule was created.';

  @override
  String get containerTagProtectionCreateUnavailable =>
      'Tag rule creation requires GitLab 18.8 or later and an accessible project.';

  @override
  String get containerTagProtectionCreateRateLimited =>
      'Too many requests. Wait and retry.';

  @override
  String get containerTagProtectionEmpty => 'No tag protection rules.';

  @override
  String get containerTagProtectionError =>
      'Could not load tag protection rules.';

  @override
  String get containerTagProtectionForbidden =>
      'You do not have permission to view tag protection rules.';

  @override
  String get containerTagProtectionUnavailable =>
      'Tag protection rules are unavailable on this instance, or the project is not accessible.';

  @override
  String containerTagProtectionPushRole(String role) {
    return 'Minimum push role: $role';
  }

  @override
  String get containerTagProtectionPushRoleTitle => 'Edit minimum push role';

  @override
  String get containerTagProtectionPushRoleSave => 'Save push role';

  @override
  String get containerTagProtectionPushRoleWarning =>
      'Changing the minimum push role changes who can push matching container image tags across this project. A lower role weakens protection; a higher role can block existing workflows. The tag pattern and minimum delete role stay unchanged. Other rules and permissions still apply. This does not delete tags or images, affect Git tags, or describe your current access.';

  @override
  String get containerTagProtectionPushRoleAcknowledge =>
      'I have reviewed the rule and new minimum push role and understand the access changes.';

  @override
  String containerTagProtectionPushRoleTarget(String projectId, String ruleId) {
    return 'Project $projectId — rule $ruleId';
  }

  @override
  String get containerTagProtectionPushRoleForbidden =>
      'You do not have permission to change this rule.';

  @override
  String get containerTagProtectionPushRoleError =>
      'Could not confirm the push role update. Check the rule list before retrying; the server may have accepted the request.';

  @override
  String get containerTagProtectionPushRoleStale =>
      'The rule changed since confirmation. Reload and review it before saving.';

  @override
  String get containerTagProtectionPushRoleReload => 'Reload rule';

  @override
  String get containerTagProtectionPushRoleSaved =>
      'Minimum push role updated.';

  @override
  String get containerTagProtectionPushRoleMissing =>
      'The rule is missing, ambiguous, inaccessible, or unsupported. Editing requires GitLab 18.9 or later. Reload before confirming.';

  @override
  String get containerTagProtectionPushRoleRateLimited =>
      'Too many requests. Wait and retry.';

  @override
  String get containerTagProtectionPushRoleInvalid =>
      'The push role was rejected. Choose a supported role and retry.';

  @override
  String get containerTagProtectionPushRoleDraft => 'New minimum push role';

  @override
  String get containerTagProtectionPushRoleSelect => 'Select a push role';

  @override
  String get containerTagProtectionPushRoleUnknown =>
      'The current push role is unknown. Editing is blocked to avoid replacing unsupported settings.';

  @override
  String containerTagProtectionDeleteRole(String role) {
    return 'Minimum delete role: $role';
  }

  @override
  String get containerTagProtectionDeleteRoleTitle =>
      'Edit minimum delete role';

  @override
  String get containerTagProtectionDeleteRoleSave => 'Save delete role';

  @override
  String get containerTagProtectionDeleteRoleWarning =>
      'Changing the minimum delete role changes who can delete matching container image tags across this project. A lower role weakens deletion protection; a higher role can block existing cleanup workflows. The tag pattern and minimum push role stay unchanged. Other rules and permissions still apply. Saving this rule does not delete tags or images, affect Git tags, or describe your current access.';

  @override
  String get containerTagProtectionDeleteRoleAcknowledge =>
      'I have reviewed the rule and new minimum delete role and understand the access changes.';

  @override
  String containerTagProtectionDeleteRoleTarget(
    String projectId,
    String ruleId,
  ) {
    return 'Project $projectId — rule $ruleId';
  }

  @override
  String get containerTagProtectionDeleteRoleForbidden =>
      'You do not have permission to change this rule.';

  @override
  String get containerTagProtectionDeleteRoleError =>
      'Could not confirm the delete role update. Check the rule list before retrying; the server may have accepted the request.';

  @override
  String get containerTagProtectionDeleteRoleStale =>
      'The rule changed since confirmation. Reload and review it before saving.';

  @override
  String get containerTagProtectionDeleteRoleReload => 'Reload rule';

  @override
  String get containerTagProtectionDeleteRoleSaved =>
      'Minimum delete role updated.';

  @override
  String get containerTagProtectionDeleteRoleMissing =>
      'The rule is missing, ambiguous, inaccessible, or unsupported. Editing requires GitLab 18.9 or later. Reload before confirming.';

  @override
  String get containerTagProtectionDeleteRoleRateLimited =>
      'Too many requests. Wait and retry.';

  @override
  String get containerTagProtectionDeleteRoleInvalid =>
      'The delete role was rejected. Choose a supported role and retry.';

  @override
  String get containerTagProtectionDeleteRoleDraft => 'New minimum delete role';

  @override
  String get containerTagProtectionDeleteRoleSelect => 'Select a delete role';

  @override
  String get containerTagProtectionDeleteRoleUnknown =>
      'The current delete role is unknown. Editing is blocked to avoid replacing unsupported settings.';

  @override
  String get containerTagProtectionRoleUnset => 'Not specified by rule';

  @override
  String get containerTagProtectionRoleAdmin => 'Administrator';

  @override
  String get containerTagProtectionHint =>
      'Rules for container image tags, not Git tags. Minimum roles do not confirm your current access. Listing requires GitLab 18.7 or later, creation requires 18.8 or later, and editing requires 18.9 or later.';

  @override
  String get containerTagProtectionPatternTitle =>
      'Edit tag protection pattern';

  @override
  String get containerTagProtectionPatternSave => 'Save pattern';

  @override
  String get containerTagProtectionPatternWarning =>
      'Changing the pattern can remove protection from previously matching container image tags and apply it to others across this project. Wildcards (*) can affect multiple tags. Both minimum roles remain unchanged; other rules and permissions still apply. This does not delete tags or images, affect Git tags, or describe your access.';

  @override
  String get containerTagProtectionPatternAcknowledge =>
      'I have reviewed the current rule and new pattern and understand the protection changes.';

  @override
  String containerTagProtectionPatternTarget(String projectId, String ruleId) {
    return 'Project $projectId — rule $ruleId';
  }

  @override
  String get containerTagProtectionPatternForbidden =>
      'You do not have permission to change this rule.';

  @override
  String get containerTagProtectionPatternError =>
      'Could not confirm the pattern update. Check the rule list before retrying; the server may have accepted the request.';

  @override
  String get containerTagProtectionPatternStale =>
      'The rule changed since confirmation. Reload and review it before saving.';

  @override
  String get containerTagProtectionPatternReload => 'Reload rule';

  @override
  String get containerTagProtectionPatternSaved =>
      'Tag protection pattern updated.';

  @override
  String get containerTagProtectionPatternMissing =>
      'The rule is missing, ambiguous, inaccessible, or unsupported. Editing requires GitLab 18.9 or later. Reload before confirming.';

  @override
  String get containerTagProtectionRemoveTitle => 'Delete tag protection rule';

  @override
  String get containerTagProtectionRemoveSave => 'Delete rule';

  @override
  String get containerTagProtectionRemoveWarning =>
      'Deleting this rule removes its push and delete protection for matching container image tags across this project. Other rules and permissions still apply. It does not delete tags or images, and does not affect Git tags.';

  @override
  String get containerTagProtectionRemoveAcknowledge =>
      'I understand and want to delete this exact rule.';

  @override
  String containerTagProtectionRemoveTarget(String projectId, String ruleId) {
    return 'Project $projectId — rule $ruleId';
  }

  @override
  String get containerTagProtectionRemoveForbidden =>
      'You do not have permission to delete this rule.';

  @override
  String get containerTagProtectionRemoveError =>
      'The request failed and may have reached the server. Inspect the rule list before retrying.';

  @override
  String get containerTagProtectionRemoveStale =>
      'This rule changed or is ambiguous. Reload it and confirm again.';

  @override
  String get containerTagProtectionRemoveReload => 'Reload rule';

  @override
  String get containerTagProtectionRemoveSaved =>
      'Tag protection rule deleted.';

  @override
  String get containerTagProtectionRemoveMissing =>
      'This rule is missing, inaccessible, or unsupported. Deletion requires GitLab 18.9 or later. Reload before continuing.';

  @override
  String get containerTagProtectionRemoveRateLimited =>
      'Too many requests. Wait before retrying.';

  @override
  String get containerTagProtectionPatternRateLimited =>
      'Too many requests. Wait and retry.';

  @override
  String get containerTagProtectionPatternInvalid =>
      'The pattern was rejected or is already taken. Edit the draft and retry.';

  @override
  String get containerTagProtectionPatternDraft => 'New container tag pattern';

  @override
  String get containerTagDelete => 'Delete tag';

  @override
  String get containerTagDeleteConfirmTitle => 'Delete container tag?';

  @override
  String containerTagDeleteConfirmBody(String tagName, String path) {
    return 'Delete tag “$tagName” at “$path”? This cannot be undone.';
  }

  @override
  String get containerTagDeleteWarning =>
      'This removes the tag, not the underlying image blobs. Deleting a tag does not reclaim disk space.';

  @override
  String get containerCleanupTitle => 'Clean up tags';

  @override
  String containerCleanupTarget(String projectId, String repositoryId) {
    return 'Project $projectId, image repository $repositoryId';
  }

  @override
  String get containerCleanupWarning =>
      'Matching tags will be permanently removed. The latest tag and protected tags are excluded. A keep pattern overrides the delete pattern.';

  @override
  String get containerCleanupLimits =>
      'Cleanup runs asynchronously, at most once per hour per repository, and may remove only some matching tags. Age and ordering use manifest creation time, not push time. Removing tags does not reclaim image storage.';

  @override
  String get containerCleanupDeletePattern => 'Delete pattern (RE2, required)';

  @override
  String get containerCleanupKeepPattern => 'Keep pattern (RE2, optional)';

  @override
  String get containerCleanupKeepCount =>
      'Keep newest matching tags (optional)';

  @override
  String get containerCleanupAge => 'Only remove tags older than';

  @override
  String get containerCleanupNoAge => 'No age limit';

  @override
  String get containerCleanupDay => '1 day';

  @override
  String get containerCleanupWeek => '7 days';

  @override
  String get containerCleanupMonth => '1 month';

  @override
  String get containerCleanupRequired => 'Enter an explicit delete pattern.';

  @override
  String get containerCleanupCountError =>
      'Enter a non-negative whole number or leave blank.';

  @override
  String get containerCleanupSchedule => 'Schedule cleanup';

  @override
  String get containerCleanupScheduled =>
      'Cleanup scheduled. Tags may remain until processing completes; refresh later to check progress.';

  @override
  String get containerCleanupError =>
      'Could not schedule cleanup. Check your connection and try again.';

  @override
  String get containerCleanupForbidden =>
      'You do not have permission to clean up tags in this repository.';

  @override
  String get containerCleanupRateLimited =>
      'Cleanup is rate limited. A repository can be cleaned up at most once per hour. Try again later.';

  @override
  String get containerCleanupInvalid =>
      'GitLab rejected the cleanup criteria. Check the RE2 patterns and retention settings.';

  @override
  String get containerTagDeleteForbidden =>
      'You cannot delete this tag. It may be protected or you may not have permission.';

  @override
  String get containerTagDeleteError => 'Could not delete this tag. Try again.';

  @override
  String get containerImmutabilityTitle => 'Immutable tag rules';

  @override
  String get containerImmutabilityEmpty => 'No immutable tag rules.';

  @override
  String get containerImmutabilityError =>
      'Could not load immutable tag rules. Check instance support and retry.';

  @override
  String get containerImmutabilityForbidden =>
      'You do not have permission to view immutable tag rules.';

  @override
  String get containerImmutabilityUnavailable =>
      'The project or rule connection is unavailable. Check access, subscription, and instance support.';

  @override
  String get containerImmutabilityHint =>
      'Immutable tags require Ultimate and a supported registry. These patterns apply across the project\'s container repositories and prevent matching tags from being overwritten or deleted, including by cleanup policies. Listing rules does not confirm an individual tag\'s current protection. Changes may take time to propagate.';

  @override
  String get containerImmutabilityCreateTitle => 'Create immutable rule';

  @override
  String get containerImmutabilityCreateButton => 'Create rule';

  @override
  String get containerImmutabilityCreated => 'Immutable rule created.';

  @override
  String get containerImmutabilityPattern => 'Tag pattern';

  @override
  String get containerImmutabilityPatternHint =>
      'Enter an RE2 pattern, up to 100 characters. Spaces are preserved; GitLab validates the syntax.';

  @override
  String containerImmutabilityProject(String projectId) {
    return 'Project $projectId';
  }

  @override
  String get containerImmutabilityImpact =>
      'This requires Owner access, Ultimate, and a supported registry. The pattern affects every container repository in this project. Matching tags cannot be overwritten or deleted, including by cleanup policies. Direct manifest deletion is blocked while any immutable rule exists. Rules cannot be edited; changes may take time to propagate.';

  @override
  String get containerImmutabilityAcknowledge =>
      'I understand the project-wide protection and workflow impact.';

  @override
  String get containerImmutabilityUncertain =>
      'Creation was not confirmed. Check current rules before trying again; the request may already have succeeded.';

  @override
  String get containerImmutabilityInspect => 'Check current rules';

  @override
  String get containerImmutabilityRejected =>
      'GitLab rejected the request, or an immutable rule already uses this pattern. Check current rules and review the pattern and project limits.';

  @override
  String get containerImmutabilityAuth =>
      'Your session was rejected. Sign in again before creating a rule.';

  @override
  String get containerImmutabilityAccountChanged =>
      'The account changed. Close this dialog and reopen it for the selected account.';

  @override
  String get containerImmutabilityDeleteTitle => 'Delete immutable rule';

  @override
  String get containerImmutabilityDeleteButton => 'Delete rule';

  @override
  String get containerImmutabilityDeleteDone => 'Immutable rule deleted.';

  @override
  String containerImmutabilityDeleteProject(String projectId) {
    return 'Project $projectId';
  }

  @override
  String get containerImmutabilityDeleteRuleId => 'Rule ID';

  @override
  String get containerImmutabilityDeleteConfirm => 'Type the exact pattern';

  @override
  String get containerImmutabilityDeleteImpact =>
      'Deleting this rule removes its protection across every container repository in this project. Matching tags may become overwritable or deletable, including by cleanup policies. Removing the last immutable rule may allow direct manifest deletion. Other rules and permissions can still apply. This does not delete images or tags. Owner access is required, and changes may take time to propagate.';

  @override
  String get containerImmutabilityDeleteAcknowledge =>
      'I understand the project-wide protection loss.';

  @override
  String get containerImmutabilityDeleteUncertain =>
      'Deletion was not confirmed. The request may already have succeeded. Reload the rule before trying again.';

  @override
  String get containerImmutabilityDeleteReload => 'Reload rule';

  @override
  String get containerImmutabilityDeleteRejected =>
      'The rule changed or GitLab rejected the request. Reload and confirm the current rule before trying again.';

  @override
  String get containerImmutabilityDeleteAuth =>
      'Your session was rejected. Sign in again before deleting a rule.';

  @override
  String get containerImmutabilityDeleteAccountChanged =>
      'The account changed. Close this dialog and reopen it for the selected account.';

  @override
  String containerTagProtectionPushClearTarget(
    String projectId,
    String ruleId,
  ) {
    return 'Project $projectId — rule $ruleId';
  }

  @override
  String get containerTagProtectionPushClearForbidden =>
      'You do not have permission to change this rule.';

  @override
  String get containerTagProtectionPushClearStale =>
      'The rule changed since confirmation. Reload and review it before saving.';

  @override
  String get containerTagProtectionPushClearReload => 'Reload rule';

  @override
  String get containerTagProtectionPushClearMissing =>
      'The rule is missing, ambiguous, inaccessible, or unsupported. Editing requires GitLab 18.9 or later. Reload before confirming.';

  @override
  String get containerTagProtectionPushClearRateLimited =>
      'Too many requests. Wait and retry.';

  @override
  String get containerTagProtectionPushClearTitle => 'Clear minimum push role';

  @override
  String get containerTagProtectionPushClearSave => 'Clear push restriction';

  @override
  String get containerTagProtectionPushClearWarning =>
      'This removes this rule\'s minimum push-role restriction for matching container image tags across the project and weakens push protection. The tag pattern and minimum delete role stay unchanged. Other rules and permissions still apply. This does not grant everyone access, delete tags or images, or affect Git tags.';

  @override
  String get containerTagProtectionPushClearAcknowledge =>
      'I have reviewed the rule and understand the loss of this push restriction.';

  @override
  String get containerTagProtectionPushClearError =>
      'Could not confirm that the push restriction was cleared. Check the rule list before retrying; the server may have accepted the request.';

  @override
  String get containerTagProtectionPushClearSaved =>
      'Minimum push-role restriction cleared.';

  @override
  String get containerTagProtectionPushClearInvalid =>
      'The server rejected clearing this push restriction. Check the rule and retry.';

  @override
  String get containerTagProtectionPushClearBlocked =>
      'Clearing requires a supported current push role and a supported nonempty delete role. Already-unset or unknown settings cannot be cleared.';

  @override
  String get packageFileDelete => 'Delete file';

  @override
  String get packageFileDeleteConfirmTitle => 'Delete package file?';

  @override
  String packageFileDeleteConfirmBody(String fileName, String packageName) {
    return 'Delete “$fileName” from “$packageName”? This cannot be undone.';
  }

  @override
  String get packageFileDeleteWarning =>
      'Deleting a file may corrupt this package, making it unusable or unavailable to your package manager.';

  @override
  String get packageFileDeleteForbidden =>
      'You cannot delete this file. The package may be protected or you may not have permission.';

  @override
  String get packageFileDeleteError => 'Could not delete this file. Try again.';

  @override
  String get containerRepositoryDelete => 'Delete repository';

  @override
  String get containerRepositoryDeleteConfirmTitle =>
      'Delete image repository?';

  @override
  String containerRepositoryDeleteConfirmBody(String path) {
    return 'Delete “$path” and all its tags? This cannot be undone.';
  }

  @override
  String get containerRepositoryDeleteWarning =>
      'Removal is scheduled asynchronously and may take time. Refresh the registry to check progress.';

  @override
  String get containerRepositoryDeleteForbidden =>
      'You cannot delete this repository. Check your permissions and protection rules.';

  @override
  String get containerRepositoryDeleteError =>
      'Could not schedule repository deletion. Try again.';

  @override
  String get containerRepositoryDeletionScheduled => 'Deletion scheduled';

  @override
  String get containerRepositoryDeletionNotice =>
      'Repository deletion has been scheduled. Refresh to check progress.';

  @override
  String get containerKeepCountTitle => 'Edit cleanup retention count';

  @override
  String get containerKeepCountSave => 'Confirm retention change';

  @override
  String get containerKeepCountSelect => 'New matching tags to keep per image';

  @override
  String get containerKeepCountWarning =>
      'Lowering this project-wide retention count can permanently remove more matching tags from every image repository on scheduled cleanup runs. Review the current activation and deletion criteria below. Other settings are unchanged; this does not confirm cleanup completion.';

  @override
  String get containerKeepCountUnknown =>
      'Reported activation, cadence, retention count, age limit and delete pattern are required. Review missing settings in GitLab. No policy will be created.';

  @override
  String get containerKeepCountAccepted =>
      'Cleanup retention count update accepted.';

  @override
  String get protectedBranchUnprotectTitle => 'Unprotect branch rule';

  @override
  String protectedBranchUnprotectTarget(String project, String name) {
    return 'Project $project: $name';
  }

  @override
  String get protectedBranchUnprotectWarning =>
      'Removing this rule may allow pushes or merges and change CI behavior. A wildcard rule can affect multiple branches.';

  @override
  String get protectedBranchUnprotectName => 'Type the exact rule name';

  @override
  String get protectedBranchUnprotectAcknowledge =>
      'I understand the effect on matching branches.';

  @override
  String get protectedBranchUnprotectReload => 'Check rule again';

  @override
  String get protectedBranchUnprotectSuccess => 'Branch rule removed.';

  @override
  String get protectedBranchUnprotectAuth =>
      'Sign in again before changing this rule.';

  @override
  String get protectedBranchUnprotectForbidden =>
      'You do not have permission to remove this rule.';

  @override
  String get protectedBranchUnprotectUnavailable =>
      'This rule is no longer available. Check the list before continuing.';

  @override
  String get protectedBranchUnprotectStale =>
      'The rule changed. Check it again before continuing.';

  @override
  String get protectedBranchUnprotectRateLimited =>
      'GitLab is limiting requests. Check the rule before trying again.';

  @override
  String get protectedBranchUnprotectError =>
      'Could not confirm whether the rule was removed. Check it before trying again.';

  @override
  String get protectedBranchUnprotectSessionChanged =>
      'The account changed. Close this dialog and open the rule again.';

  @override
  String get containerKeepPatternTitle => 'Edit cleanup keep pattern';

  @override
  String get containerKeepPatternSave => 'Confirm keep pattern change';

  @override
  String get containerKeepPatternSelect => 'New keep pattern (GitLab RE2)';

  @override
  String get containerKeepPatternWarning =>
      'Narrowing this project-wide keep pattern can expose previously preserved tags to permanent deletion in every image repository on scheduled cleanup runs. Review the current activation and deletion/retention criteria below. GitLab uses RE2 and automatically anchors patterns to the full tag name. Exact input is sent to GitLab for validation. Other settings are unchanged; acceptance does not confirm cleanup completion. Blank input does not clear the pattern.';

  @override
  String get containerKeepPatternUnknown =>
      'Reported activation, cadence, count, age, effective delete pattern and keep pattern are required. A reported empty keep pattern can be replaced; an unreported value cannot. Review missing settings in GitLab. No policy will be created.';

  @override
  String get containerKeepPatternAccepted =>
      'Cleanup keep pattern update accepted.';

  @override
  String get containerKeepPatternInvalid =>
      'GitLab rejected this keep pattern. Review its RE2 syntax and the existing policy, then edit or retry.';

  @override
  String get containerRepositoryProtectionTitle =>
      'Repository protection rules';

  @override
  String get containerProtectionRemoveTitle =>
      'Delete repository protection rule';

  @override
  String get containerProtectionRemoveSave => 'Confirm rule deletion';

  @override
  String get containerProtectionRemoveWarning =>
      'Removing this rule can reduce push or delete restrictions for repositories matching this path pattern. Other rules and permissions still apply. This deletes only the protection rule, not repositories, tags, or images. Review the exact target and minimum roles; these roles do not describe your permissions.';

  @override
  String get containerProtectionRemoveAcknowledge =>
      'I understand that this rule\'s protection restrictions will be removed.';

  @override
  String containerProtectionRemoveTarget(String projectId, String ruleId) {
    return 'Project $projectId — rule $ruleId';
  }

  @override
  String get containerProtectionRemoveForbidden =>
      'You do not have permission to delete this repository protection rule.';

  @override
  String get containerProtectionRemoveError =>
      'Could not confirm rule deletion. Reload or retry.';

  @override
  String get containerProtectionRemoveStale =>
      'The rule changed since confirmation. Reload and review it before deleting.';

  @override
  String get containerProtectionRemoveReload => 'Reload rule';

  @override
  String get containerProtectionRemoveDeleted =>
      'Repository protection rule deleted.';

  @override
  String get containerProtectionRemoveMissing =>
      'The rule was not found, is ambiguous, or is not accessible. Reload before confirming.';

  @override
  String get containerProtectionRemoveRateLimited =>
      'Too many requests. Wait and retry.';

  @override
  String get containerRepositoryProtectionEmpty =>
      'No repository protection rules.';

  @override
  String get containerProtectionCreateTitle =>
      'Create repository protection rule';

  @override
  String get containerProtectionCreateSave => 'Create rule';

  @override
  String get containerProtectionCreatePattern => 'Repository path pattern';

  @override
  String containerProtectionCreateProject(String projectId) {
    return 'Project $projectId';
  }

  @override
  String get containerProtectionCreateWarning =>
      'This rule restricts selected push and delete operations for repositories matching the exact pattern. A wildcard (*) can affect multiple repositories. An unselected role adds no restriction for that operation from this rule. Other rules and permissions still apply; these settings do not describe your access or delete images.';

  @override
  String get containerProtectionCreateAcknowledge =>
      'I have reviewed the pattern and minimum roles and understand their impact.';

  @override
  String get containerProtectionCreateUnset => 'No restriction from this rule';

  @override
  String get containerProtectionCreateCreated => 'The rule was created.';

  @override
  String get containerProtectionCreateForbidden =>
      'You do not have permission to create this rule.';

  @override
  String get containerProtectionCreateInvalid =>
      'The pattern or roles were rejected, or the pattern is already taken. Edit the draft and retry.';

  @override
  String get containerProtectionCreateError =>
      'Could not confirm rule creation. Check the rule list before retrying; the server may have accepted the request.';

  @override
  String get containerProtectionCreatePush => 'Minimum push role';

  @override
  String get containerProtectionCreateDelete => 'Minimum delete role';

  @override
  String get containerRepositoryProtectionError =>
      'Could not load repository protection rules.';

  @override
  String get containerRepositoryProtectionForbidden =>
      'You do not have permission to view repository protection rules.';

  @override
  String containerProtectionDeleteClearTarget(String projectId, String ruleId) {
    return 'Project $projectId — rule $ruleId';
  }

  @override
  String get containerProtectionDeleteClearForbidden =>
      'You do not have permission to change this rule.';

  @override
  String get containerProtectionDeleteClearStale =>
      'The rule changed since confirmation. Reload and review it before saving.';

  @override
  String get containerProtectionDeleteClearReload => 'Reload rule';

  @override
  String get containerProtectionDeleteClearMissing =>
      'The rule is missing, ambiguous, or inaccessible. Reload before confirming.';

  @override
  String get containerProtectionDeleteClearRateLimited =>
      'Too many requests. Wait and retry.';

  @override
  String get containerProtectionDeleteClearTitle => 'Clear minimum delete role';

  @override
  String get containerProtectionDeleteClearSave => 'Clear delete restriction';

  @override
  String get containerProtectionDeleteClearWarning =>
      'This removes this rule\'s minimum delete-role restriction for matching repositories and weakens deletion protection. The path pattern and minimum push role stay unchanged. Other rules and permissions still apply; this does not grant everyone access or delete images.';

  @override
  String get containerProtectionDeleteClearAcknowledge =>
      'I have reviewed the rule and understand the loss of this delete restriction.';

  @override
  String get containerProtectionDeleteClearError =>
      'Could not confirm that the delete restriction was cleared. Check the rule list before retrying; the server may have accepted the request.';

  @override
  String get containerProtectionDeleteClearSaved =>
      'Minimum delete-role restriction cleared.';

  @override
  String get containerProtectionDeleteClearInvalid =>
      'The server rejected clearing this delete restriction. Check the rule and retry.';

  @override
  String get containerProtectionDeleteClearBlocked =>
      'Clearing requires a supported current delete role and a supported nonempty push role. Already-unset or unknown settings cannot be cleared.';

  @override
  String get containerRepositoryProtectionUnavailable =>
      'Repository protection rules are unavailable on this instance, or the project is not accessible.';

  @override
  String containerRepositoryProtectionPushRole(String role) {
    return 'Minimum push role: $role';
  }

  @override
  String containerRepositoryProtectionDeleteRole(String role) {
    return 'Minimum delete role: $role';
  }

  @override
  String get containerRepositoryProtectionRoleUnset => 'Not specified by rule';

  @override
  String containerProtectionPushClearTarget(String projectId, String ruleId) {
    return 'Project $projectId — rule $ruleId';
  }

  @override
  String get containerProtectionPushClearForbidden =>
      'You do not have permission to change this rule.';

  @override
  String get containerProtectionPushClearStale =>
      'The rule changed since confirmation. Reload and review it before saving.';

  @override
  String get containerProtectionPushClearReload => 'Reload rule';

  @override
  String get containerProtectionPushClearMissing =>
      'The rule is missing, ambiguous, or inaccessible. Reload before confirming.';

  @override
  String get containerProtectionPushClearRateLimited =>
      'Too many requests. Wait and retry.';

  @override
  String get containerProtectionPushClearTitle => 'Clear minimum push role';

  @override
  String get containerProtectionPushClearSave => 'Clear push restriction';

  @override
  String get containerProtectionPushClearWarning =>
      'This removes this rule\'s minimum push-role restriction for matching repositories and weakens push protection. The path pattern and minimum delete role stay unchanged. Other rules and permissions still apply; this does not grant everyone access or delete images.';

  @override
  String get containerProtectionPushClearAcknowledge =>
      'I have reviewed the rule and understand the loss of this push restriction.';

  @override
  String get containerProtectionPushClearError =>
      'Could not confirm that the push restriction was cleared. Check the rule list before retrying; the server may have accepted the request.';

  @override
  String get containerProtectionPushClearSaved =>
      'Minimum push-role restriction cleared.';

  @override
  String get containerProtectionPushClearInvalid =>
      'The server rejected clearing this push restriction. Check the rule and retry.';

  @override
  String get containerProtectionPushClearBlocked =>
      'Clearing requires a supported current push role and a supported nonempty delete role. Already-unset or unknown settings cannot be cleared.';

  @override
  String get containerRepositoryProtectionRoleAdmin => 'Administrator';

  @override
  String get containerAgeTitle => 'Edit cleanup age limit';

  @override
  String get containerAgeSave => 'Confirm age limit change';

  @override
  String get containerAgeSelect => 'New age limit (GitLab API duration)';

  @override
  String get containerAgeWarning =>
      'Shortening this project-wide age limit can permanently remove newer matching tags from every image repository on scheduled cleanup runs. Review the current activation and deletion criteria below. Other settings are unchanged; this does not confirm cleanup completion.';

  @override
  String get containerAgeUnknown =>
      'Reported activation, cadence, retention count, age limit and delete pattern are required. Review missing settings in GitLab. No policy will be created.';

  @override
  String get containerAgeAccepted => 'Cleanup age limit update accepted.';

  @override
  String get containerProtectionPatternTitle =>
      'Edit repository protection pattern';

  @override
  String get containerProtectionPatternSave => 'Save pattern';

  @override
  String get containerProtectionPatternWarning =>
      'Changing the pattern can remove protection from previously matching repositories and apply it to others. Wildcards (*) can affect multiple repositories. Both minimum roles remain unchanged; other rules and permissions still apply. This does not delete images or describe your access.';

  @override
  String get containerProtectionPatternAcknowledge =>
      'I have reviewed the current rule and new pattern and understand the protection changes.';

  @override
  String containerProtectionPatternTarget(String projectId, String ruleId) {
    return 'Project $projectId — rule $ruleId';
  }

  @override
  String get containerProtectionPatternForbidden =>
      'You do not have permission to change this rule.';

  @override
  String get containerProtectionPatternError =>
      'Could not confirm the pattern update. Check the rule list before retrying; the server may have accepted the request.';

  @override
  String get containerProtectionPatternStale =>
      'The rule changed since confirmation. Reload and review it before saving.';

  @override
  String get containerProtectionPatternReload => 'Reload rule';

  @override
  String get containerProtectionPatternSaved =>
      'Repository protection pattern updated.';

  @override
  String get containerProtectionPatternMissing =>
      'The rule is missing, ambiguous, or inaccessible. Reload before confirming.';

  @override
  String get containerProtectionPatternRateLimited =>
      'Too many requests. Wait and retry.';

  @override
  String get containerProtectionPatternInvalid =>
      'The pattern was rejected or is already taken. Edit the draft and retry.';

  @override
  String get containerProtectionPatternDraft => 'New repository path pattern';
}
