// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get protectedTagsTitle => '受保护标签';

  @override
  String get protectedTagsEmpty => '没有受保护标签规则。';

  @override
  String get protectedTagsError => '无法加载受保护标签。';

  @override
  String get protectedTagsLoadMore => '加载更多';

  @override
  String get protectedTagCreateAccess => '允许创建';

  @override
  String get protectedEnvironmentsTitle => '受保护环境';

  @override
  String get protectedEnvironmentsEmpty => '没有受保护环境规则。';

  @override
  String get protectedEnvironmentsError => '无法加载受保护环境。';

  @override
  String get protectedEnvironmentsUnavailable => '受保护环境不可用，或您没有访问权限。';

  @override
  String get protectedEnvironmentsLoadMore => '加载更多';

  @override
  String get protectedEnvironmentDeployAccess => '允许部署';

  @override
  String get protectedEnvironmentApprovalRules => '批准规则';

  @override
  String protectedEnvironmentApprovalCount(int count) {
    return '所需批准数：$count';
  }

  @override
  String get protectedBranchesTitle => '受保护分支';

  @override
  String get protectedBranchesEmpty => '没有受保护分支规则。';

  @override
  String get protectedBranchesError => '无法加载受保护分支。';

  @override
  String get protectedBranchesLoadMore => '加载更多';

  @override
  String get protectedBranchPushAccess => '允许推送';

  @override
  String get protectedBranchMergeAccess => '允许合并';

  @override
  String get protectedBranchForcePush => '强制推送';

  @override
  String get protectedBranchCodeOwnerApproval => '代码所有者批准';

  @override
  String get protectedBranchInherited => '继承自群组';

  @override
  String get protectedBranchEnabled => '启用';

  @override
  String get protectedBranchDisabled => '禁用';

  @override
  String get protectedBranchNoAccess => '无权限规则';

  @override
  String get linkedIssuesTitle => '关联议题';

  @override
  String get linkedIssuesError => '无法加载关联议题。';

  @override
  String get linkedIssuesLoadMore => '加载更多';

  @override
  String get linkedIssuesRelatesTo => '相关';

  @override
  String get linkedIssuesBlocks => '阻塞';

  @override
  String get linkedIssuesBlockedBy => '被阻塞';

  @override
  String get groupLabelsTitle => '群组标签';

  @override
  String get groupLabelsEmpty => '暂无群组标签';

  @override
  String get groupLabelsError => '无法加载群组标签。';

  @override
  String get groupMembersTitle => '群组成员';

  @override
  String get groupMembersSearch => '搜索群组成员';

  @override
  String get groupMembersEmpty => '没有找到群组成员。';

  @override
  String get groupMembersError => '无法加载群组成员。';

  @override
  String get pipelineSchedulesTitle => '流水线计划';

  @override
  String get pipelineSchedulesAll => '全部';

  @override
  String get pipelineSchedulesActive => '启用';

  @override
  String get pipelineSchedulesInactive => '停用';

  @override
  String get pipelineSchedulesEmpty => '没有找到流水线计划。';

  @override
  String get pipelineSchedulesError => '无法加载流水线计划。';

  @override
  String get pipelineSchedulesLoadMore => '加载更多';

  @override
  String get pipelineScheduleDetailError => '无法加载此流水线计划。';

  @override
  String pipelineScheduleNextRun(String date) {
    return '下次运行：$date';
  }

  @override
  String get pipelineScheduleNextRunLabel => '下次运行';

  @override
  String get pipelineScheduleRef => '引用';

  @override
  String get pipelineScheduleCron => '计划';

  @override
  String get pipelineScheduleTimezone => '时区';

  @override
  String get pipelineScheduleOwner => '所有者';

  @override
  String get pipelineScheduleRunNow => '立即运行';

  @override
  String get pipelineScheduleRunSuccess => '流水线计划已启动。';

  @override
  String get pipelineScheduleRunError => '无法运行此流水线计划。';

  @override
  String get pipelineScheduleLastPipeline => '上次流水线';

  @override
  String pipelineSchedulePipelineNumber(int number) {
    return '流水线 #$number';
  }

  @override
  String get deploymentsTitle => '部署';

  @override
  String get deploymentsAll => '全部';

  @override
  String get deploymentsSuccess => '成功';

  @override
  String get deploymentsFailed => '失败';

  @override
  String get deploymentsRunning => '运行中';

  @override
  String get deploymentsCanceled => '已取消';

  @override
  String get deploymentsCreated => '已创建';

  @override
  String get deploymentsBlocked => '已阻止';

  @override
  String get deploymentsUnknownStatus => '未知状态';

  @override
  String get deploymentsEmpty => '没有找到部署。';

  @override
  String get deploymentsError => '无法加载部署。';

  @override
  String get deploymentsLoadMore => '加载更多';

  @override
  String get deploymentsEnvironmentSearch => '按环境名称筛选';

  @override
  String get deploymentsUnknownEnvironment => '未知环境';

  @override
  String get deploymentDetailError => '无法加载此部署。';

  @override
  String deploymentNumber(int number) {
    return '部署 #$number';
  }

  @override
  String get deploymentEnvironment => '环境';

  @override
  String get deploymentRef => '引用';

  @override
  String get deploymentCommit => '提交';

  @override
  String get deploymentJob => '作业';

  @override
  String get deploymentPipeline => '流水线';

  @override
  String get deploymentCreatedAt => '创建时间';

  @override
  String get deploymentUpdatedAt => '更新时间';

  @override
  String get deploymentUser => '部署者';

  @override
  String get releasesTitle => '发行版';

  @override
  String get releasesEmpty => '暂无发行版。';

  @override
  String get releasesError => '无法加载发行版。';

  @override
  String get releaseDetailError => '无法加载此发行版。';

  @override
  String get releaseAssetsTitle => '资源';

  @override
  String get releaseLoadMore => '加载更多';

  @override
  String get releaseUpcoming => '即将发布';

  @override
  String get activityTitle => '动态';

  @override
  String get activityAll => '全部';

  @override
  String get activityIssues => '议题';

  @override
  String get activityMergeRequests => '合并请求';

  @override
  String get activityEmpty => '暂无近期动态。';

  @override
  String get activityError => '无法加载项目动态。';

  @override
  String get activityLoadMore => '加载更多';

  @override
  String get activityUnknownActor => '未知用户';

  @override
  String get activityPush => '推送';

  @override
  String get activityEvent => '项目动态';

  @override
  String activityBy(String actor, String action) {
    return '$actor $action';
  }

  @override
  String get environmentsTitle => '环境';

  @override
  String get environmentsAll => '全部';

  @override
  String get environmentsAvailable => '可用';

  @override
  String get environmentsStopping => '停止中';

  @override
  String get environmentsStopped => '已停止';

  @override
  String get environmentsSearch => '搜索环境';

  @override
  String get environmentsSearchLength => '请至少输入 3 个字符。';

  @override
  String get environmentsEmpty => '未找到环境。';

  @override
  String get environmentsError => '无法加载环境。';

  @override
  String get environmentsLoadMore => '加载更多';

  @override
  String get environmentDetailError => '无法加载此环境。';

  @override
  String get environmentAutoStop => '自动停止';

  @override
  String get environmentOpenUrl => '打开环境';

  @override
  String get environmentLatestDeployment => '最新部署';

  @override
  String get environmentUnknownStatus => '未知状态';

  @override
  String get projectMembersTitle => '成员';

  @override
  String get projectMembersSearch => '搜索成员';

  @override
  String get projectMembersClearSearch => '清除搜索';

  @override
  String get projectMembersEmpty => '未找到成员。';

  @override
  String get projectMembersError => '无法加载成员。';

  @override
  String get projectMembersLoadMore => '加载更多';

  @override
  String get projectMembersExpiry => '到期日';

  @override
  String get memberRoleNoAccess => '无访问权限';

  @override
  String get memberRoleMinimal => '最低访问权限';

  @override
  String get memberRoleGuest => '访客';

  @override
  String get memberRolePlanner => '规划者';

  @override
  String get memberRoleReporter => '报告者';

  @override
  String get memberRoleSecurityManager => '安全管理员';

  @override
  String get memberRoleDeveloper => '开发者';

  @override
  String get memberRoleMaintainer => '维护者';

  @override
  String get memberRoleOwner => '所有者';

  @override
  String get memberRoleUnknown => '未知角色';

  @override
  String get containerRegistryTitle => '容器镜像仓库';

  @override
  String get containerRegistryEmpty => '暂无容器镜像。';

  @override
  String get containerRegistryError => '无法加载容器镜像。';

  @override
  String get containerTagsTitle => '镜像标签';

  @override
  String get containerTagsEmpty => '暂无标签。';

  @override
  String get containerTagsError => '无法加载镜像标签。';

  @override
  String get containerTagError => '无法加载此标签。';

  @override
  String get containerTagDigest => '摘要';

  @override
  String get containerTagRevision => '修订版本';

  @override
  String get containerTagSize => '大小（字节）';

  @override
  String get containerLoadMore => '加载更多';

  @override
  String get milestonesTitle => '里程碑';

  @override
  String get milestonesActive => '进行中';

  @override
  String get milestonesClosed => '已关闭';

  @override
  String get milestonesEmpty => '此状态下没有里程碑。';

  @override
  String get milestonesError => '无法加载里程碑。';

  @override
  String get milestoneDetailError => '无法加载此里程碑。';

  @override
  String get milestoneStartDate => '开始日期';

  @override
  String get milestoneDueDate => '截止日期';

  @override
  String get milestoneLoadMore => '加载更多';

  @override
  String get appTitle => 'LabFox';

  @override
  String get homeTitle => '主页';

  @override
  String homeSignedInAs(String username) {
    return '已登录为 $username';
  }

  @override
  String get homeEmptyWork => '您的议题、合并请求和流水线将显示在这里。';

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
  String get signOut => '退出登录';

  @override
  String get signInTitle => '连接 GitLab 账户';

  @override
  String get signInNoAccountNote =>
      'LabFox 没有自己的账户。连接你已在使用的 GitLab — gitlab.com，或你自己托管的实例。';

  @override
  String get signInInstanceLabel => 'GitLab 实例 URL';

  @override
  String get signInInstanceRequired => '请输入您的 GitLab 实例 URL。';

  @override
  String get signInInstanceInvalid => '请输入有效的 https URL，例如 https://gitlab.com';

  @override
  String get signInTokenLabel => '个人访问令牌';

  @override
  String get signInTokenHelp => '需要 api 和 read_user 权限范围。';

  @override
  String get signInTokenToggle => '显示或隐藏令牌';

  @override
  String get signInTokenRequired => '请输入个人访问令牌。';

  @override
  String get signInSubmit => '登录';

  @override
  String get signInOr => '或';

  @override
  String get signInOAuthButton => '授权你的实例';

  @override
  String get signInClientIdLabel => 'OAuth 客户端 ID';

  @override
  String get signInClientIdHelp => '仅在自托管实例上使用 OAuth 时需要。';

  @override
  String get signInOAuthNeedsClientId => '请输入该实例的 OAuth 客户端 ID。';

  @override
  String get signInErrorToken => '令牌被拒绝。请检查它是否正确且未过期。';

  @override
  String get signInErrorScope => '令牌缺少必需的权限范围。需要 api 和 read_user。';

  @override
  String get signInErrorUnreachable => '无法连接到该实例。请检查 URL、网络以及证书是否受信任。';

  @override
  String get signInErrorGeneric => '登录失败。请重试。';

  @override
  String get scopeAssigned => 'Assigned';

  @override
  String get scopeCreated => 'Created';

  @override
  String get homeRefresh => 'Refresh';

  @override
  String get homeFavoritesEmpty => 'Star projects to pin them here.';

  @override
  String get homeMyWork => '我的工作';

  @override
  String get homeProjects => '项目';

  @override
  String get homeGroups => 'Groups';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupsEmpty => 'You are not a member of any groups yet.';

  @override
  String get groupsError => 'Could not load your groups.';

  @override
  String get groupDetailTitle => '群组';

  @override
  String get groupDetailError => '无法加载此群组。';

  @override
  String get groupSubgroups => '子群组';

  @override
  String get groupSubgroupsEmpty => '没有子群组。';

  @override
  String get groupProjects => '项目';

  @override
  String get groupProjectsEmpty => '此群组中没有项目。';

  @override
  String get groupLoadMore => '加载更多';

  @override
  String get projectsTitle => '项目';

  @override
  String get projectsEmpty => '您还不是任何项目的成员。';

  @override
  String get projectsError => '无法加载您的项目。';

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
  String get retry => '重试';

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
  String get issueEdit => '编辑议题';

  @override
  String get issueSaveChanges => '保存更改';

  @override
  String get issueEditError => '无法保存议题。请检查权限后重试。';

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
  String get projectOverviewTitle => '项目';

  @override
  String get projectOverviewError => '无法加载此项目。';

  @override
  String get projectOverviewNoReadme => '此项目没有 README。';

  @override
  String get projectOverviewRepository => '仓库';

  @override
  String get repositoryTitle => '仓库';

  @override
  String get repositoryError => '无法加载此目录。';

  @override
  String get repositoryEmpty => '此目录为空。';

  @override
  String get fileError => '无法加载此文件。';

  @override
  String get fileNotFound => '未找到此文件。';

  @override
  String get fileBinary => '这是二进制文件，无法作为文本显示。';

  @override
  String get fileCopy => 'Copy contents';

  @override
  String get fileCopied => 'Contents copied';

  @override
  String get projectOverviewBranches => '分支';

  @override
  String get projectOverviewCommits => '提交';

  @override
  String get projectOverviewCode => 'Code';

  @override
  String get projectOverviewBrowseCode => 'Browse code';

  @override
  String get branchesTitle => '分支';

  @override
  String get branchesError => '无法加载分支。';

  @override
  String get branchesEmpty => '此仓库没有分支。';

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
  String get branchDefault => '默认分支';

  @override
  String get commitsTitle => '提交';

  @override
  String get commitsError => '无法加载提交。';

  @override
  String get commitsEmpty => '此分支还没有提交。';

  @override
  String get commitTitle => '提交';

  @override
  String get commitError => '无法加载此提交。';

  @override
  String get projectOverviewIssues => '议题';

  @override
  String get issuesTitle => '议题';

  @override
  String get issuesFilterOpen => '打开';

  @override
  String get issuesFilterClosed => '已关闭';

  @override
  String get issuesError => '无法加载议题。';

  @override
  String get issuesEmpty => '这里没有议题。';

  @override
  String get issueError => '无法加载此议题。';

  @override
  String get issueStateOpen => '打开';

  @override
  String get issueStateClosed => '已关闭';

  @override
  String get issueNoDescription => '未提供描述。';

  @override
  String issueOpenedBy(String username) {
    return '由 $username 创建';
  }

  @override
  String get projectOverviewMergeRequests => '合并请求';

  @override
  String get mergeRequestsTitle => '合并请求';

  @override
  String get mrFilterOpen => '打开';

  @override
  String get mrFilterMerged => '已合并';

  @override
  String get mrFilterClosed => '已关闭';

  @override
  String get mergeRequestsError => '无法加载合并请求。';

  @override
  String get mergeRequestsEmpty => '这里没有合并请求。';

  @override
  String get mergeRequestError => '无法加载此合并请求。';

  @override
  String get mergeRequestNoDescription => '未提供描述。';

  @override
  String get mrStateOpen => '打开';

  @override
  String get mrStateMerged => '已合并';

  @override
  String get mrStateClosed => '已关闭';

  @override
  String get mrDraft => '草稿';

  @override
  String get changesTitle => '变更';

  @override
  String get changesError => '无法加载变更。';

  @override
  String get changesEmpty => '没有变更。';

  @override
  String get changesBinary => '二进制文件 — 不显示。';

  @override
  String get commitViewChanges => '查看变更';

  @override
  String get mrViewChanges => '查看变更';

  @override
  String get changesOmitted => 'diff 太大或已折叠，未显示。';

  @override
  String get commentsHeading => '评论';

  @override
  String get commentsError => '无法加载评论。';

  @override
  String get commentsEmpty => '还没有评论。';

  @override
  String get commentComposerHint => '写评论…';

  @override
  String get commentComposerSubmit => '评论';

  @override
  String get commentPostForbidden => '您没有权限在此评论。请检查您的令牌是否具有 api 权限范围。';

  @override
  String get commentPostError => '无法发布您的评论。请重试。';

  @override
  String get cancel => '取消';

  @override
  String get mrApprove => '批准';

  @override
  String get mrUnapprove => '撤销批准';

  @override
  String get mrMerge => '合并';

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
  String get mrMergeConfirmTitle => '要合并此合并请求吗？';

  @override
  String mrMergeConfirmBody(String mr) {
    return '合并 $mr 无法撤销。';
  }

  @override
  String mrApprovalsSummary(int approved, int required) {
    return '$approved/$required 项批准';
  }

  @override
  String get mrNotMergeable => '目前无法合并。可能需要批准、变基或通过的流水线。';

  @override
  String get mrActionForbidden => '您没有执行此操作的权限。请检查您的令牌范围和角色。';

  @override
  String get mrActionError => '操作无法完成。请重试。';

  @override
  String get projectOverviewPipelines => '流水线';

  @override
  String get pipelinesTitle => '流水线';

  @override
  String get pipelinesError => '无法加载流水线。';

  @override
  String get pipelinesEmpty => '还没有流水线。';

  @override
  String get pipelineError => '无法加载此流水线。';

  @override
  String get pipelineJobsError => '无法加载作业。';

  @override
  String get pipelineNoJobs => '此流水线没有作业。';

  @override
  String get jobTitle => '作业';

  @override
  String get jobError => '无法加载此作业。';

  @override
  String get jobRefresh => '刷新';

  @override
  String get jobLogError => '无法加载日志。';

  @override
  String get jobLogEmpty => '此作业没有日志输出。';

  @override
  String get jobActionRetry => '重试';

  @override
  String get jobActionCancel => '取消';

  @override
  String get jobActionRun => '运行';

  @override
  String get jobActionForbidden => '您没有执行此操作的权限。';

  @override
  String get jobActionInvalid => '作业当前状态下无法执行此操作。';

  @override
  String get jobActionError => '操作无法完成。请重试。';

  @override
  String get pipelineActionRetry => '重试';

  @override
  String get pipelineActionCancel => '取消';

  @override
  String get pipelineActionForbidden => '您没有执行此操作的权限。';

  @override
  String get pipelineActionInvalid => '流水线当前状态下无法执行此操作。';

  @override
  String get pipelineActionError => '操作无法完成。请重试。';

  @override
  String get accountsTitle => '账户';

  @override
  String get accountAdd => '添加账户';

  @override
  String get accountRemove => '移除账户';

  @override
  String get homeSwitchAccount => '账户';

  @override
  String get homeInbox => '待办列表';

  @override
  String get inboxTitle => '待办列表';

  @override
  String get inboxEmpty => '全部处理完毕。';

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
  String get inboxError => '无法加载待办事项。';

  @override
  String get inboxMarkAllDone => '全部标记为完成';

  @override
  String get inboxMarkDone => '标记为完成';

  @override
  String get inboxMarkDoneError => '无法清除该事项，请重试。';

  @override
  String get inboxActionAssigned => '已指派给你';

  @override
  String get inboxActionMentioned => '提到了你';

  @override
  String get inboxActionBuildFailed => '流水线失败';

  @override
  String get inboxActionMarked => '添加了待办';

  @override
  String get inboxActionApprovalRequired => '需要批准';

  @override
  String get inboxActionUnmergeable => '无法合并';

  @override
  String get inboxActionDirectlyAddressed => '直接提及你';

  @override
  String get homeSearch => '搜索';

  @override
  String get searchTitle => '搜索';

  @override
  String get searchHint => '搜索项目、议题、合并请求';

  @override
  String get searchScopeProjects => '项目';

  @override
  String get searchScopeIssues => '议题';

  @override
  String get searchScopeMergeRequests => '合并请求';

  @override
  String get searchInitial => '输入以搜索。';

  @override
  String get searchEmpty => '未找到结果。';

  @override
  String get searchError => '搜索无法完成。';

  @override
  String get searchLoadMore => '加载更多';

  @override
  String get listSearchHint => 'Search by title';

  @override
  String get listSearchClose => 'Close search';

  @override
  String get projectAddFavorite => '添加到收藏';

  @override
  String get projectRemoveFavorite => '从收藏中移除';

  @override
  String get homeFavorites => '收藏';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsAccounts => '账户';

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
  String get settingsLicenses => '开源许可';

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
  String get navHome => '主页';

  @override
  String get navInbox => '收件箱';

  @override
  String get navSearch => '搜索';

  @override
  String get navMe => '我';

  @override
  String get meTitle => '我';

  @override
  String get meSettings => '设置';

  @override
  String get meAccounts => '切换账户';

  @override
  String get projectLabelsTitle => '标签';

  @override
  String get projectLabelsError => '无法加载标签。';

  @override
  String get projectLabelsEmpty => '暂无标签';

  @override
  String get projectLabelsNoMatch => '没有匹配的标签';

  @override
  String get projectLabelSearch => '搜索标签';

  @override
  String get projectLabelNew => '新建标签';

  @override
  String get projectLabelGroup => '群组标签';

  @override
  String get projectLabelProject => '项目标签';

  @override
  String get projectLabelError => '无法加载此标签。';

  @override
  String get projectLabelOpenIssues => '未关闭的议题';

  @override
  String get projectLabelClosedIssues => '已关闭的议题';

  @override
  String get projectLabelOpenMrs => '未关闭的合并请求';

  @override
  String get projectLabelName => '名称';

  @override
  String get projectLabelColor => '颜色 (#RRGGBB)';

  @override
  String get projectLabelDescription => '描述（可选）';

  @override
  String get projectLabelRequired => '此项为必填项';

  @override
  String get projectLabelInvalidColor => '请输入类似 #5843AD 的颜色';

  @override
  String get projectLabelCreate => '创建标签';

  @override
  String get projectLabelCreateError => '无法创建标签。请检查权限和输入内容。';

  @override
  String get tagsTitle => '标签';

  @override
  String get tagsEmpty => '暂无标签';

  @override
  String get tagsError => '无法加载标签。';

  @override
  String get tagsNoMatch => '没有匹配的标签';

  @override
  String get tagSearchHint => '搜索标签';

  @override
  String get tagError => '无法加载此标签。';

  @override
  String get tagProtected => '受保护的标签';

  @override
  String get tagNew => '新建标签';

  @override
  String get tagName => '标签名称';

  @override
  String get tagFromRef => '从分支、标签或提交 SHA 创建';

  @override
  String get tagMessage => '消息（可选）';

  @override
  String get tagPipelineNotice => '创建标签可能会启动 CI/CD 流水线。';

  @override
  String get tagFieldRequired => '此项为必填项';

  @override
  String get tagCreate => '创建标签';

  @override
  String get tagCreateError => '无法创建标签。请检查权限和引用。';

  @override
  String get snippetsTitle => '代码片段';

  @override
  String get snippetsEmpty => '暂无代码片段';

  @override
  String get snippetsError => '无法加载代码片段。';

  @override
  String get snippetError => '无法加载此代码片段。';

  @override
  String get snippetContent => '内容';

  @override
  String get snippetContentError => '无法加载代码片段内容。';

  @override
  String get homeRecents => '最近';

  @override
  String get wikiTitle => 'Wiki';

  @override
  String get wikiEmpty => '还没有 Wiki 页面。';

  @override
  String get wikiListError => '无法加载 Wiki 页面。';

  @override
  String get wikiPageError => '无法加载此 Wiki 页面。';

  @override
  String get packageRegistryTitle => '软件包仓库';

  @override
  String get packageRegistryEmpty => '还没有软件包。';

  @override
  String get packageRegistryError => '无法加载软件包。';

  @override
  String get packageDetailError => '无法加载此软件包。';

  @override
  String get packageFiles => '文件';

  @override
  String get packageFilesEmpty => '此软件包没有文件。';

  @override
  String get packageLoadMore => '加载更多';
}
