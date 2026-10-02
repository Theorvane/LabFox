// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get pipelineScheduleDelete => '删除计划';

  @override
  String get pipelineScheduleDeleteConfirmTitle => '删除此流水线计划？';

  @override
  String pipelineScheduleDeleteConfirmBody(String name) {
    return '流水线计划“$name”将被永久删除。此操作无法撤销。';
  }

  @override
  String get pipelineScheduleDeleteError => '无法删除此流水线计划。请检查权限并重试。';

  @override
  String get releaseScheduleEdit => '编辑发布日期';

  @override
  String get releaseScheduleChangeDate => '更改日期';

  @override
  String get releaseScheduleChangeTime => '更改时间';

  @override
  String get releaseScheduleSave => '保存发布日期';

  @override
  String get releaseScheduleError => '无法更新发布日期。';

  @override
  String releaseScheduleHelp(String zone) {
    return '时间使用设备时区（$zone）。选择未来日期会安排即将发布的版本。';
  }

  @override
  String get pipelineScheduleEdit => '编辑计划';

  @override
  String get pipelineScheduleSave => '保存';

  @override
  String get pipelineScheduleDescription => '描述';

  @override
  String get pipelineScheduleFieldRequired => '请输入一个值。';

  @override
  String get pipelineScheduleEditHint =>
      'GitLab 会验证 cron 表达式和时区。保存将重新安排后续运行；引用、启用状态、变量和输入保持不变。';

  @override
  String get pipelineScheduleEditError => '无法更新此流水线计划。请检查权限、cron 表达式和时区。';

  @override
  String get pipelineScheduleTakeOwnership => '获取所有权';

  @override
  String get pipelineScheduleOwnershipConfirmTitle => '获取此计划的所有权？';

  @override
  String pipelineScheduleOwnershipConfirmBody(String name) {
    return '您将成为“$name”的所有者。计划流水线将使用您的权限运行。需要 Maintainer 或 Owner 角色。';
  }

  @override
  String get pipelineScheduleOwnershipError => '无法获取此流水线计划的所有权。请检查权限并重试。';

  @override
  String get protectedTagProtectTitle => '保护标签';

  @override
  String get protectedTagProtectName => '规则名称';

  @override
  String get protectedTagProtectRole => '谁可以创建匹配的标签？';

  @override
  String get protectedTagProtectNoOne => '任何人都不能';

  @override
  String get protectedTagProtectDevelopers => '开发者和维护者';

  @override
  String get protectedTagProtectMaintainers => '维护者';

  @override
  String protectedTagProtectWarning(String projectId) {
    return '此规则会更改项目 $projectId 中匹配标签的创建权限，并可能影响标签流水线和作业。';
  }

  @override
  String get protectedTagProtectWildcard => '通配符规则也可能影响将来的标签。请检查准确的模式和权限。';

  @override
  String get protectedTagProtectAcknowledge => '我了解此规则对整个项目的影响。';

  @override
  String get protectedTagProtectSubmit => '保护标签';

  @override
  String get protectedTagProtectExisting => '规则已存在。未进行更改。';

  @override
  String get protectedTagProtectUncertain => '结果不确定。重试前请重新加载所有规则。';

  @override
  String get protectedTagProtectReload => '重新加载规则';

  @override
  String get protectedTagProtectLoadError => '无法验证受保护标签规则。请重新加载。';

  @override
  String get protectedTagProtectSessionChanged => '账号已更改。请关闭此草稿并重新开始。';

  @override
  String get protectedTagProtectCreated => '已创建受保护标签规则。';

  @override
  String get protectedTagProtectCancel => '取消';

  @override
  String get protectedTagProtectForbidden => '您无权创建此规则。重试前请重新加载。';

  @override
  String get protectedTagProtectUnauthorized => '会话已过期。请重新登录后再创建规则。';

  @override
  String get protectedTagProtectRateLimited => 'GitLab 正在限制请求。请稍后重新加载规则。';

  @override
  String get protectedTagProtectUnavailable => '此项目或受保护标签资源不可用。重试前请重新加载。';

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
  String get protectedBranchProtectTitle => '保护分支';

  @override
  String get protectedBranchProtectName => '规则名称';

  @override
  String get protectedBranchProtectPush => '允许推送';

  @override
  String get protectedBranchProtectMerge => '允许合并';

  @override
  String get protectedBranchProtectNoOne => '任何人都不能';

  @override
  String get protectedBranchProtectDevelopers => '开发者和维护者';

  @override
  String get protectedBranchProtectMaintainers => '维护者';

  @override
  String protectedBranchProtectWarning(String projectId) {
    return '此规则会更改项目 $projectId 的推送和合并权限，并可能影响合并请求、受保护的 CI 变量及作业。';
  }

  @override
  String get protectedBranchProtectWildcard => '通配符规则也可能影响将来的分支。请检查准确的模式和两项权限。';

  @override
  String get protectedBranchProtectAcknowledge => '我了解此规则对整个项目的影响。';

  @override
  String get protectedBranchProtectSubmit => '保护分支';

  @override
  String get protectedBranchProtectExisting => '规则已存在。未进行更改。';

  @override
  String get protectedBranchProtectUncertain => '结果不确定。重试前请重新加载所有规则。';

  @override
  String get protectedBranchProtectReload => '重新加载规则';

  @override
  String get protectedBranchProtectLoadError => '无法验证受保护分支规则。请重新加载。';

  @override
  String get protectedBranchProtectSessionChanged => '账号已更改。请关闭此草稿并重新开始。';

  @override
  String get protectedBranchProtectCreated => '已创建受保护分支规则。';

  @override
  String get protectedBranchProtectCancel => '取消';

  @override
  String get protectedBranchProtectForbidden => '您无权创建此规则。重试前请重新加载。';

  @override
  String get protectedBranchProtectUnauthorized => '会话已过期。请重新登录后再创建规则。';

  @override
  String get protectedBranchProtectRateLimited => 'GitLab 正在限制请求。请稍后重新加载规则。';

  @override
  String get protectedBranchProtectUnavailable => '此项目或受保护分支资源不可用。重试前请重新加载。';

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
  String get pipelineScheduleHistoryTitle => '运行历史';

  @override
  String get pipelineScheduleHistoryEmpty => '此计划尚未运行任何流水线。';

  @override
  String get pipelineScheduleHistoryError => '无法加载运行历史。';

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
  String get releaseEdit => '编辑发行版';

  @override
  String get releaseSave => '保存发行版';

  @override
  String get releaseEditName => '发行版名称';

  @override
  String get releaseEditDescription => '描述（Markdown）';

  @override
  String get releaseNameRequired => '请输入发行版名称。';

  @override
  String get releaseEditError => '无法更新发行版。';

  @override
  String get releaseNew => '新建发行版';

  @override
  String get releaseCreate => '创建发行版';

  @override
  String get releaseTagName => '标签名称';

  @override
  String get releaseRef => '创建标签所用的引用（可选）';

  @override
  String get releaseRefHelp => '如果标签已存在，请留空。';

  @override
  String get releaseName => '发行版名称（可选）';

  @override
  String get releaseDescription => '描述（Markdown）';

  @override
  String get releaseTagRequired => '请输入标签名称。';

  @override
  String get releaseCreateError => '无法创建发行版。';

  @override
  String get releaseAddAssetLink => '添加资源链接';

  @override
  String get releaseAddLink => '添加链接';

  @override
  String get releaseAssetName => '链接名称';

  @override
  String get releaseAssetUrl => '链接 URL';

  @override
  String get releaseAssetNameRequired => '请输入链接名称。';

  @override
  String get releaseAssetUrlInvalid => '请输入 HTTP 或 HTTPS URL。';

  @override
  String get releaseAssetNameDuplicate => '已存在同名链接。';

  @override
  String get releaseAssetCreateError => '无法添加资源链接。';

  @override
  String get releaseNoAssets => '暂无资源。';

  @override
  String get releaseDelete => '删除发行版';

  @override
  String get releaseDeleteConfirmTitle => '删除此发行版？';

  @override
  String get releaseDeleteConfirmBody => '发行版及其说明将被删除。Git 标签会保留。';

  @override
  String get releaseDeleteError => '无法删除发行版。';

  @override
  String get releaseDeleteAssetLink => '删除资源链接';

  @override
  String get releaseDeleteLink => '删除链接';

  @override
  String get releaseAssetDeleteConfirmTitle => '删除此资源链接？';

  @override
  String releaseAssetDeleteConfirmBody(String name) {
    return '将移除名为 $name 的链接。链接指向的文件不会被删除。';
  }

  @override
  String get releaseAssetDeleteError => '无法删除资源链接。';

  @override
  String get releaseEditAssetLink => '编辑资源链接';

  @override
  String get releaseSaveLink => '保存链接';

  @override
  String get releaseAssetEditError => '无法更新资源链接。';

  @override
  String get releaseMilestonesEdit => '编辑发布里程碑';

  @override
  String get releaseMilestonesTitle => '里程碑';

  @override
  String get releaseMilestonesHelp =>
      '请输入准确的里程碑标题。群组里程碑是否可用取决于您的 GitLab 计划和项目群组。';

  @override
  String get releaseMilestoneTitle => '里程碑标题';

  @override
  String get releaseMilestoneAdd => '添加里程碑';

  @override
  String get releaseMilestonesSave => '保存里程碑';

  @override
  String get releaseMilestonesError => '无法更新发布里程碑。';

  @override
  String get releaseMilestoneTitleRequired => '请输入里程碑标题。';

  @override
  String get releaseMilestoneDuplicate => '此里程碑已选中。';

  @override
  String releaseMilestoneRemove(String title) {
    return '移除 $title';
  }

  @override
  String get releaseAssetDirectPath => '新的直接下载路径（可选）';

  @override
  String get releaseAssetDirectPathHelp =>
      '留空以保留当前直接下载路径。输入 /bin/app.zip 等路径以替换。';

  @override
  String get releaseAssetDirectPathInvalid => '请输入以 / 开头且不包含主机、查询或片段的路径。';

  @override
  String get releaseAssetType => '链接类型';

  @override
  String get releaseAssetKeepType => '保留当前类型';

  @override
  String get releaseAssetTypeOther => '其他';

  @override
  String get releaseAssetTypeRunbook => '操作手册';

  @override
  String get releaseAssetTypeImage => '图片';

  @override
  String get releaseAssetTypePackage => '软件包';

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
  String get milestoneNew => '新建里程碑';

  @override
  String get milestoneCreate => '创建里程碑';

  @override
  String get milestoneTitleField => '标题';

  @override
  String get milestoneDescriptionField => '描述';

  @override
  String get milestoneTitleRequired => '请输入里程碑标题。';

  @override
  String get milestoneDateOrderError => '开始日期不能晚于截止日期。';

  @override
  String get milestoneCreateError => '无法创建里程碑。';

  @override
  String get milestoneChooseDate => '选择日期';

  @override
  String get milestoneClearDate => '清除日期';

  @override
  String get milestoneEdit => '编辑里程碑';

  @override
  String get milestoneSaveChanges => '保存更改';

  @override
  String get milestoneUpdateError => '无法更新里程碑。';

  @override
  String get milestoneClearStartDate => '清除开始日期';

  @override
  String get milestoneClearDueDate => '清除截止日期';

  @override
  String get milestoneClose => '关闭里程碑';

  @override
  String get milestoneReactivate => '重新激活里程碑';

  @override
  String get milestoneCloseConfirmTitle => '关闭此里程碑？';

  @override
  String get milestoneCloseConfirmBody => '稍后可以重新激活。';

  @override
  String get milestoneStateError => '无法更改里程碑状态。';

  @override
  String get milestoneDelete => '删除里程碑';

  @override
  String get milestoneDeleteConfirmTitle => '删除此里程碑？';

  @override
  String get milestoneDeleteConfirmBody => '此操作无法撤销。';

  @override
  String get milestoneDeleteError => '无法删除里程碑。';

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
  String get issueEditLabels => '编辑标签';

  @override
  String get issueSaveLabels => '保存标签';

  @override
  String get issueLabelsEmpty => '没有可用标签';

  @override
  String get issueLabelsLoadError => '无法加载标签。';

  @override
  String get issueLabelsSaveError => '无法更新标签，请重试。';

  @override
  String get issueEditDueDate => '编辑截止日期';

  @override
  String get issueConfidential => '机密';

  @override
  String get issueMakeConfidential => '设为机密';

  @override
  String get issueRemoveConfidentiality => '取消机密';

  @override
  String get issueMakeConfidentialExplanation => '此议题的访问权限将受到限制。是否继续？';

  @override
  String get issueRemoveConfidentialityExplanation =>
      '所有可以查看项目的用户都将看到此议题。是否继续？';

  @override
  String get issueConfidentialityConfirm => '确认';

  @override
  String get issueConfidentialityError => '无法更新机密状态。请检查权限后重试。';

  @override
  String get issueDiscussionLocked => '讨论已锁定';

  @override
  String get issueLockDiscussion => '锁定讨论';

  @override
  String get issueUnlockDiscussion => '解锁讨论';

  @override
  String get issueLockDiscussionExplanation => '只有项目成员可以添加或编辑评论。是否继续？';

  @override
  String get issueUnlockDiscussionExplanation => '可以访问此议题的用户将能够再次发表评论。是否继续？';

  @override
  String get issueDiscussionLockConfirm => '确认';

  @override
  String get issueDiscussionLockError => '无法更改讨论锁定状态。请检查权限后重试。';

  @override
  String get issueEditMilestone => '编辑里程碑';

  @override
  String get issueEditAssignees => '编辑指派人';

  @override
  String get issueAssignees => '指派人';

  @override
  String get issueSaveAssignees => '保存指派人';

  @override
  String get issueAssigneesSaveError => '无法更新指派人。请检查权限后重试。';

  @override
  String get issueNoMilestone => '无里程碑';

  @override
  String get issueMilestonesLoadError => '无法加载里程碑。';

  @override
  String get issueMilestoneSaveError => '无法更新里程碑。请检查权限后重试。';

  @override
  String get issueDueDate => '截止日期';

  @override
  String issueDueDateValue(String date) {
    return '截止日期：$date';
  }

  @override
  String get issueSelectDueDate => '选择日期';

  @override
  String get issueClearDueDate => '清除截止日期';

  @override
  String get issueDueDateError => '无法更新截止日期，请重试。';

  @override
  String get issueSaveChanges => '保存更改';

  @override
  String get issueEditError => '无法保存议题。请检查权限后重试。';

  @override
  String get issueSubscribe => '订阅通知';

  @override
  String get issueUnsubscribe => '取消订阅通知';

  @override
  String get issueSubscriptionError => '无法更新议题通知。请重试。';

  @override
  String get mrSubscribe => '订阅通知';

  @override
  String get mrUnsubscribe => '取消订阅通知';

  @override
  String get mrSubscriptionError => '无法更新合并请求通知。请重试。';

  @override
  String get issueAddTodo => '添加到待办事项';

  @override
  String get issueTodoAdded => '已添加到待办事项。';

  @override
  String get issueTodoExists => '该议题已在待办事项中。';

  @override
  String get issueTodoError => '无法将议题添加到待办事项。请重试。';

  @override
  String get mrAddTodo => '添加到待办事项';

  @override
  String get mrTodoAdded => '已添加到待办事项。';

  @override
  String get mrTodoExists => '该合并请求已在待办事项中。';

  @override
  String get mrTodoError => '无法将合并请求添加到待办事项。请重试。';

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
  String get pipelinesLoadMore => '加载更多';

  @override
  String get pipelinesLoadMoreError => '无法加载更多流水线。';

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
  String get snippetNew => '新建代码片段';

  @override
  String get snippetTitleField => '标题';

  @override
  String get snippetDescriptionField => '描述';

  @override
  String get snippetFilePathField => '文件路径';

  @override
  String get snippetContentField => '内容';

  @override
  String get snippetVisibilityField => '可见性';

  @override
  String get snippetVisibilityUnchanged => '保持当前可见性';

  @override
  String get snippetPrivate => '私有';

  @override
  String get snippetPublic => '公开';

  @override
  String get snippetCreate => '创建代码片段';

  @override
  String get snippetCreateValidationError => '请输入标题、文件路径和内容。';

  @override
  String get snippetCreateError => '无法创建代码片段。';

  @override
  String get snippetAddFile => '添加文件';

  @override
  String get snippetFileAddValidationError => '请输入不重复的相对文件路径和内容。';

  @override
  String get snippetFileAddError => '无法添加文件。';

  @override
  String get snippetFileMoveAction => '移动文件';

  @override
  String get snippetFileMoveTitle => '移动或重命名文件';

  @override
  String get snippetFileMovePathField => '新文件路径';

  @override
  String get snippetFileMoveValidationError => '请输入不同且未使用的相对文件路径。';

  @override
  String get snippetFileMoveError => '无法移动文件。';

  @override
  String get snippetEditAction => '编辑代码片段';

  @override
  String get snippetEditTitle => '编辑代码片段';

  @override
  String get snippetSaveChanges => '保存更改';

  @override
  String get snippetEditValidationError => '请输入标题。';

  @override
  String get snippetEditError => '无法保存代码片段。';

  @override
  String get snippetDeleteAction => '删除代码片段';

  @override
  String get snippetDeleteConfirmTitle => '删除此代码片段？';

  @override
  String get snippetDeleteConfirmMessage => '代码片段及其文件将被永久删除。';

  @override
  String get snippetDeleteButton => '删除';

  @override
  String get snippetDeleteError => '无法删除代码片段。';

  @override
  String get snippetFileDeleteAction => '删除文件';

  @override
  String get snippetFileDeleteConfirmTitle => '删除此文件？';

  @override
  String get snippetFileDeleteConfirmMessage => '只会从代码片段中永久删除此文件。';

  @override
  String get snippetFileDeleteError => '无法删除文件。';

  @override
  String get snippetEditContent => '编辑内容';

  @override
  String get snippetSaveContent => '保存内容';

  @override
  String get snippetContentSaveError => '无法保存代码片段内容。';

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
  String get wikiNewPage => '新建页面';

  @override
  String get wikiPagesSection => '页面';

  @override
  String get wikiTemplatesSection => '模板';

  @override
  String get wikiTemplateEmpty => '还没有模板。';

  @override
  String get wikiNewTemplate => '新建模板';

  @override
  String get wikiTemplateTitle => '模板标题';

  @override
  String get wikiCreateTemplate => '创建模板';

  @override
  String get wikiCreateTemplateError => '无法创建模板。';

  @override
  String get wikiPageTitle => '标题';

  @override
  String get wikiPageContent => '内容';

  @override
  String get wikiCreatePage => '创建页面';

  @override
  String get wikiChooseTemplate => '选择模板';

  @override
  String get wikiReplaceTemplateContent => '要用此模板替换当前内容吗？';

  @override
  String get wikiApplyTemplate => '应用模板';

  @override
  String get wikiTemplateLoadError => '无法加载模板。';

  @override
  String get wikiCreateValidationError => '请输入标题和内容。';

  @override
  String get wikiCreateError => '无法创建维基页面。';

  @override
  String get wikiEditPageAction => '编辑';

  @override
  String get wikiEditPage => '编辑 Wiki 页面';

  @override
  String get wikiEditTitle => '标题';

  @override
  String get wikiEditContent => '内容';

  @override
  String get wikiSaveChanges => '保存更改';

  @override
  String get wikiEditValidationError => '请输入标题和内容。';

  @override
  String get wikiEditError => '无法保存 Wiki 页面。';

  @override
  String get wikiEditConflict => '此页面已在 GitLab 上更改。请重新加载后再编辑。';

  @override
  String get wikiDeletePageAction => '删除页面';

  @override
  String get wikiDeleteConfirmTitle => '删除此维基页面？';

  @override
  String get wikiDeleteConfirmMessage => '此页面将从项目维基中永久删除。';

  @override
  String get wikiDeleteError => '无法删除维基页面。';

  @override
  String get wikiDeleteConflict => '此页面已更改。请重新加载后再删除。';

  @override
  String get wikiReloadPage => '重新加载页面';

  @override
  String get packageRegistryTitle => '软件包仓库';

  @override
  String get packageDelete => '删除软件包';

  @override
  String get packageDeleteConfirmTitle => '删除此软件包？';

  @override
  String packageDeleteConfirmBody(String name) {
    return '删除 $name 及其所有文件？此操作无法撤销。';
  }

  @override
  String get packageDeleteForwardingWarning => '如果启用了请求转发，删除此软件包可能会产生依赖混淆攻击风险。';

  @override
  String get packageDeleteError => '无法删除此软件包。请重试。';

  @override
  String get packageDeleteForbidden => '此软件包可能受保护，或者您没有删除权限。';

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

  @override
  String get protectedTagUnprotectTitle => '解除标签规则保护';

  @override
  String protectedTagUnprotectTarget(String projectId, String name) {
    return '项目 $projectId — 规则 $name';
  }

  @override
  String get protectedTagUnprotectWarning =>
      '移除此仓库标签保护规则。不会删除标签。通配符可能影响许多现有和未来的标签。解除保护可能使更多用户能够创建或删除匹配的标签，并改变标签流水线和作业的访问权限。其他匹配规则可能仍然保护标签；实际访问权限由 GitLab 决定。请检查下方当前的创建权限。';

  @override
  String protectedTagUnprotectAccess(
    String description,
    String role,
    String user,
    String group,
    String key,
  ) {
    return '$description\n角色级别：$role；用户 ID：$user；群组 ID：$group；部署密钥 ID：$key';
  }

  @override
  String get protectedTagUnprotectUnreported => '未报告';

  @override
  String get protectedTagUnprotectName => '重新输入准确的规则名称或模式';

  @override
  String get protectedTagUnprotectAcknowledge =>
      '我理解此规则匹配的所有标签将失去此规则的保护，并希望移除此规则。';

  @override
  String get protectedTagUnprotectAuth => '您的会话被拒绝。请重新登录后检查规则。';

  @override
  String get protectedTagUnprotectForbidden =>
      'GitLab 拒绝了解除保护的权限。需要 Maintainer 或 Owner 角色。';

  @override
  String get protectedTagUnprotectUnavailable =>
      '规则不存在、是私有的或在此实例上不可用。请重新加载检查；不会移除其他规则。';

  @override
  String get protectedTagUnprotectStale => '规则已更改。请重新加载并确认当前权限后再移除。';

  @override
  String get protectedTagUnprotectRateLimited =>
      'GitLab 正在限制请求。请等待，然后重新加载并确认规则。';

  @override
  String get protectedTagUnprotectError => '无法确认请求结果。重试之前请重新加载并再次确认规则。';

  @override
  String get protectedTagUnprotectReload => '重新加载规则';

  @override
  String get protectedTagUnprotectSessionChanged =>
      '账户已更改。请关闭并重新打开此对话框，检查当前项目。';

  @override
  String get protectedTagUnprotectAccepted => '标签保护规则已移除。未删除任何标签。';

  @override
  String get protectedBranchForcePushEditTitle => '编辑强制推送';

  @override
  String protectedBranchForcePushEditTarget(String project, String name) {
    return '项目 $project：$name';
  }

  @override
  String get protectedBranchForcePushCurrentAllowed => '目前允许强制推送。';

  @override
  String get protectedBranchForcePushCurrentBlocked => '目前禁止强制推送。';

  @override
  String get protectedBranchForcePushAllow => '允许强制推送';

  @override
  String get protectedBranchForcePushSave => '保存设置';

  @override
  String get protectedBranchForcePushEnableWarning =>
      '允许强制推送可能改写匹配分支的历史。通配符规则可能影响多个分支。';

  @override
  String get protectedBranchForcePushDisableWarning =>
      '禁止强制推送会改变成员在匹配分支上的工作方式。通配符规则可能影响多个分支。';

  @override
  String get protectedBranchForcePushAcknowledge => '我了解此更改对匹配分支的影响。';

  @override
  String get protectedBranchForcePushReload => '重新检查规则';

  @override
  String get protectedBranchForcePushSuccess => '强制推送设置已更新。';

  @override
  String get protectedBranchForcePushAuth => '请重新登录后再更改此规则。';

  @override
  String get protectedBranchForcePushForbidden => '您没有权限更改此规则。';

  @override
  String get protectedBranchForcePushUnavailable => '此规则已不可用。继续前请检查列表。';

  @override
  String get protectedBranchForcePushStale => '规则已更改。继续前请重新检查。';

  @override
  String get protectedBranchForcePushRateLimited => 'GitLab 正在限制请求。重试前请检查规则。';

  @override
  String get protectedBranchForcePushError => '无法确认此更改。重试前请先检查规则。';

  @override
  String get protectedBranchForcePushSessionChanged => '账户已更改。请关闭此对话框并重新打开规则。';

  @override
  String get protectedBranchMergeRoleEditTitle => '编辑合并权限';

  @override
  String protectedBranchMergeRoleTarget(String project, String name) {
    return '项目 $project：$name';
  }

  @override
  String protectedBranchMergeRoleCurrent(String role) {
    return '当前合并权限：$role';
  }

  @override
  String get protectedBranchMergeRoleNone => '无人';

  @override
  String get protectedBranchMergeRoleDeveloper => '开发者和维护者';

  @override
  String get protectedBranchMergeRoleMaintainer => '维护者';

  @override
  String get protectedBranchMergeRoleWarning =>
      '更改合并权限会影响所有匹配此规则的分支。通配符可能影响多个分支和合并请求流程。';

  @override
  String get protectedBranchMergeRoleAcknowledge => '我了解匹配分支的合并权限将发生变化。';

  @override
  String get protectedBranchMergeRoleSave => '保存合并权限';

  @override
  String get protectedBranchMergeRoleReload => '重新检查规则';

  @override
  String get protectedBranchMergeRoleSuccess => '合并权限已更新。';

  @override
  String get protectedBranchMergeRoleAuth => '请重新登录后再更改此规则。';

  @override
  String get protectedBranchMergeRoleForbidden => '您无权更改合并权限。';

  @override
  String get protectedBranchMergeRoleUnavailable => '此规则已不可用。继续之前请检查列表。';

  @override
  String get protectedBranchMergeRoleStale => '规则已更改。继续之前请重新检查。';

  @override
  String get protectedBranchMergeRoleRateLimited => 'GitLab 正在限制请求。重试前请检查规则。';

  @override
  String get protectedBranchMergeRoleError => '无法确认更改。重试前请检查规则。';

  @override
  String get protectedBranchMergeRoleSessionChanged => '账户已更改。请关闭此对话框并重新打开规则。';

  @override
  String get protectedBranchPushRoleEditTitle => '编辑推送权限';

  @override
  String protectedBranchPushRoleTarget(String project, String name) {
    return '项目 $project：$name';
  }

  @override
  String protectedBranchPushRoleCurrent(String role) {
    return '当前推送权限：$role';
  }

  @override
  String get protectedBranchPushRoleNone => '无人';

  @override
  String get protectedBranchPushRoleDeveloper => '开发者和维护者';

  @override
  String get protectedBranchPushRoleMaintainer => '维护者';

  @override
  String get protectedBranchPushRoleWarning =>
      '更改推送权限会影响所有匹配此规则的分支。可以直接提交的人员可能改变；如果允许强制推送，可以改写历史的人员也可能改变。通配符可能影响多个分支。';

  @override
  String get protectedBranchPushRoleAcknowledge => '我了解匹配分支的推送权限将发生变化。';

  @override
  String get protectedBranchPushRoleSave => '保存推送权限';

  @override
  String get protectedBranchPushRoleReload => '重新检查规则';

  @override
  String get protectedBranchPushRoleSuccess => '推送权限已更新。';

  @override
  String get protectedBranchPushRoleAuth => '请重新登录后再更改此规则。';

  @override
  String get protectedBranchPushRoleForbidden => '您无权更改推送权限。';

  @override
  String get protectedBranchPushRoleUnavailable => '此规则已不可用。继续之前请检查列表。';

  @override
  String get protectedBranchPushRoleStale => '规则已更改。继续之前请重新检查。';

  @override
  String get protectedBranchPushRoleRateLimited => 'GitLab 正在限制请求。重试前请检查规则。';

  @override
  String get protectedBranchPushRoleError => '无法确认更改。重试前请检查规则。';

  @override
  String get protectedBranchPushRoleSessionChanged => '账户已更改。请关闭此对话框并重新打开规则。';

  @override
  String get protectedEnvironmentCreateTitle => '保护环境';

  @override
  String get protectedEnvironmentCreateName => '环境名称';

  @override
  String get protectedEnvironmentCreateDeveloper => '开发者和维护者';

  @override
  String get protectedEnvironmentCreateMaintainer => '维护者';

  @override
  String get protectedEnvironmentCreateWarning => '此保护设置会改变谁能部署到指定环境。不会添加审批规则。';

  @override
  String get protectedEnvironmentCreateAcknowledge => '我了解部署权限的变更。';

  @override
  String get protectedEnvironmentCreateSave => '保护环境';

  @override
  String get protectedEnvironmentCreateReload => '重新检查环境列表';

  @override
  String get protectedEnvironmentCreateDuplicate => '此环境已受保护。继续前请检查列表。';

  @override
  String get protectedEnvironmentCreateError => '无法确认保护设置。重试前请检查列表。';

  @override
  String get protectedEnvironmentCreateForbidden => '您没有权限，或此功能不可用。';

  @override
  String get protectedEnvironmentCreateSessionChanged => '账户已更改。请关闭并重新打开此对话框。';

  @override
  String get protectedEnvironmentCreateSuccess => '环境已受保护。';

  @override
  String get protectedEnvironmentCreateInvalidName => '请输入不含通配符的准确环境名称。';

  @override
  String get protectedEnvironmentRemoveRoleTitle => '移除部署角色';

  @override
  String get protectedEnvironmentRemoveRoleWarning =>
      '移除此授权后，所选角色可能无法部署。其他部署授权和审批规则保持不变，环境仍受保护。';

  @override
  String get protectedEnvironmentRemoveRoleAcknowledge => '我了解所选部署授权将被移除。';

  @override
  String get protectedEnvironmentRemoveRoleSuccess => '已移除部署角色。';

  @override
  String get protectedEnvironmentRemoveRoleForbidden => '您没有权限移除此部署授权。';

  @override
  String get protectedEnvironmentRemoveRoleError => '无法确认部署授权已移除。重试前请检查规则。';

  @override
  String protectedEnvironmentRemoveRoleGrantLabel(String role, String id) {
    return '$role（授权 $id）';
  }

  @override
  String get protectedEnvironmentDeployRoleTitle => '添加部署角色';

  @override
  String get protectedEnvironmentDeployRoleWarning =>
      '所选角色将获得部署权限。现有部署授权和审批规则保持不变。';

  @override
  String get protectedEnvironmentDeployRoleAcknowledge => '我了解这会扩大部署权限。';

  @override
  String get protectedEnvironmentDeployRoleSuccess => '已添加部署角色。';

  @override
  String get protectedEnvironmentDeployRoleForbidden => '您没有权限更改部署权限。';

  @override
  String get protectedEnvironmentDeployRoleError => '无法确认部署角色变更。重试前请检查规则。';

  @override
  String get protectedEnvironmentUnprotectTitle => '取消环境保护';

  @override
  String protectedEnvironmentUnprotectTarget(String project, String name) {
    return '项目 $project：$name';
  }

  @override
  String get protectedEnvironmentUnprotectWarning =>
      '取消此项目保护规则会移除下方显示的所有部署授权和审批规则。环境及历史部署仍会保留。群组保护规则可能继续生效。';

  @override
  String get protectedEnvironmentUnprotectName => '输入准确的环境名称';

  @override
  String get protectedEnvironmentUnprotectAcknowledge => '我了解这些部署限制和审批规则将被移除。';

  @override
  String get protectedEnvironmentUnprotectReload => '重新检查规则';

  @override
  String get protectedEnvironmentUnprotectAuth => '更改此规则前请重新登录。';

  @override
  String get protectedEnvironmentUnprotectForbidden => '您没有权限取消此环境的保护。';

  @override
  String get protectedEnvironmentUnprotectUnavailable => '此规则已不可用。继续前请检查列表。';

  @override
  String get protectedEnvironmentUnprotectStale => '规则已更改。继续前请重新检查。';

  @override
  String get protectedEnvironmentUnprotectRateLimited =>
      'GitLab 正在限制请求。重试前请检查规则。';

  @override
  String get protectedEnvironmentUnprotectError => '无法确认保护已取消。重试前请检查规则。';

  @override
  String get protectedEnvironmentUnprotectSessionChanged =>
      '账户已更改。请关闭此对话框并重新打开规则。';

  @override
  String get protectedEnvironmentUnprotectSuccess => '环境保护已取消。';

  @override
  String get protectedEnvironmentUnprotectUnreported => '访问条目';

  @override
  String get containerPolicyStatus => '状态';

  @override
  String get containerPolicyEnabled => '已启用';

  @override
  String get containerPolicyDisabled => '已禁用';

  @override
  String get containerPolicyNotReported => '未报告';

  @override
  String get containerPolicyCadence => '运行间隔';

  @override
  String get containerPolicyKeepCount => '每个镜像保留的匹配标签数';

  @override
  String get containerPolicyAge => '删除早于以下时间的标签';

  @override
  String get containerPolicyDeletePattern => '删除模式';

  @override
  String get containerPolicyLegacyPattern => '删除模式（旧版）';

  @override
  String get containerPolicyKeepPattern => '保留模式';

  @override
  String get containerPolicyEmptyPattern => '空模式';

  @override
  String get containerPolicyError => '无法加载清理策略。';

  @override
  String get containerPolicyForbidden => '您无权查看此项目的清理策略。';

  @override
  String get containerPolicyUnavailable => '无法访问项目，或清理策略信息不可用。';

  @override
  String get containerPolicyEmptySetting => '空设置';

  @override
  String containerActivationTarget(String projectId) {
    return '项目 $projectId — 所有镜像仓库';
  }

  @override
  String get containerActivationError => '无法确认更新。请重新加载策略后重试。';

  @override
  String get containerActivationForbidden => '您无权更改此清理策略。';

  @override
  String get containerActivationStale => '策略已更改或不再报告。请在保存前重新加载并检查。';

  @override
  String get containerActivationReload => '重新加载策略';

  @override
  String get containerActivationRateLimited => '请求过多。请稍等并重新加载策略后重试。';

  @override
  String get containerCadenceTitle => '编辑清理周期';

  @override
  String get containerCadenceSave => '确认周期变更';

  @override
  String get containerCadenceSelect => '新周期 (GitLab API 间隔)';

  @override
  String get containerCadenceWarning =>
      '更改项目级周期会影响所有镜像仓库未来的计划标签清理。请检查下面的启用状态和删除/保留条件。这不会更改这些设置，也不表示清理已完成。';

  @override
  String get containerCadenceUnknown =>
      '需要已报告的启用状态、周期、保留数量、期限和删除模式。请在 GitLab 中检查缺失设置。不会创建新策略。';

  @override
  String get containerCadenceAccepted => '清理周期更新已接受。';

  @override
  String get containerTagProtectionTitle => '标签保护规则';

  @override
  String get containerTagProtectionEmpty => '没有标签保护规则。';

  @override
  String get containerTagProtectionError => '无法加载标签保护规则。';

  @override
  String get containerTagProtectionForbidden => '您无权查看标签保护规则。';

  @override
  String get containerTagProtectionUnavailable => '此实例不支持标签保护规则，或项目无法访问。';

  @override
  String containerTagProtectionPushRole(String role) {
    return '推送所需最低角色：$role';
  }

  @override
  String containerTagProtectionDeleteRole(String role) {
    return '删除所需最低角色：$role';
  }

  @override
  String get containerTagProtectionRoleUnset => '规则未指定';

  @override
  String get containerTagProtectionRoleAdmin => '管理员';

  @override
  String get containerTagProtectionHint =>
      '这些规则用于容器镜像标签，而非 Git 标签。最低角色不代表您的当前访问权限。查看需要 GitLab 18.7 或更高版本，编辑需要 18.9 或更高版本。';

  @override
  String get containerTagProtectionPatternTitle => '编辑标签保护模式';

  @override
  String get containerTagProtectionPatternSave => '保存模式';

  @override
  String get containerTagProtectionPatternWarning =>
      '更改模式可能解除本项目中原先匹配的容器镜像标签的保护，并将保护应用于其他标签。通配符(*)可能影响多个标签。两个最低角色保持不变，其他规则和权限仍然适用。此操作不会删除标签或镜像，不影响 Git 标签，也不代表您的访问权限。';

  @override
  String get containerTagProtectionPatternAcknowledge =>
      '我已检查当前规则和新模式，并了解保护范围的变化。';

  @override
  String containerTagProtectionPatternTarget(String projectId, String ruleId) {
    return '项目 $projectId — 规则 $ruleId';
  }

  @override
  String get containerTagProtectionPatternForbidden => '您没有更改此规则的权限。';

  @override
  String get containerTagProtectionPatternError =>
      '无法确认模式更新。服务器可能已处理请求，请在重试前检查规则列表。';

  @override
  String get containerTagProtectionPatternStale => '规则在确认后已更改。保存前请重新加载并检查。';

  @override
  String get containerTagProtectionPatternReload => '重新加载规则';

  @override
  String get containerTagProtectionPatternSaved => '标签保护模式已更新。';

  @override
  String get containerTagProtectionPatternMissing =>
      '规则不存在、重复、无法访问或不受支持。编辑需要 GitLab 18.9 或更高版本。请重新加载后确认。';

  @override
  String get containerTagProtectionPatternRateLimited => '请求过多。请稍后重试。';

  @override
  String get containerTagProtectionPatternInvalid => '模式被拒绝或已被使用。请编辑草稿后重试。';

  @override
  String get containerTagProtectionPatternDraft => '新容器标签模式';

  @override
  String get containerTagDelete => '删除标签';

  @override
  String get containerTagDeleteConfirmTitle => '删除容器标签？';

  @override
  String containerTagDeleteConfirmBody(String tagName, String path) {
    return '删除“$path”中的标签“$tagName”？此操作无法撤销。';
  }

  @override
  String get containerTagDeleteWarning => '此操作仅删除标签，不会删除底层镜像数据。删除标签不会释放磁盘空间。';

  @override
  String get containerTagDeleteForbidden => '无法删除此标签。它可能受保护，或您没有权限。';

  @override
  String get containerTagDeleteError => '无法删除此标签。请重试。';

  @override
  String get containerImmutabilityTitle => '不可变标签规则';

  @override
  String get containerImmutabilityEmpty => '没有不可变标签规则。';

  @override
  String get containerImmutabilityError => '无法加载不可变标签规则。请检查实例支持情况后重试。';

  @override
  String get containerImmutabilityForbidden => '你没有查看不可变标签规则的权限。';

  @override
  String get containerImmutabilityUnavailable =>
      '项目或规则列表不可用。请检查访问权限、订阅和实例支持情况。';

  @override
  String get containerImmutabilityHint =>
      '不可变标签需要 Ultimate 和受支持的镜像仓库。这些模式适用于项目中的所有容器仓库，防止匹配标签被覆盖或删除，包括清理策略的删除。查看规则并不确认单个标签当前的保护状态。更改可能需要时间才能生效。';

  @override
  String get containerImmutabilityCreateTitle => '创建不可变规则';

  @override
  String get containerImmutabilityCreateButton => '创建规则';

  @override
  String get containerImmutabilityCreated => '不可变规则已创建。';

  @override
  String get containerImmutabilityPattern => '标签模式';

  @override
  String get containerImmutabilityPatternHint =>
      '输入不超过100个字符的RE2模式。空格会保留；GitLab会验证语法。';

  @override
  String containerImmutabilityProject(String projectId) {
    return '项目 $projectId';
  }

  @override
  String get containerImmutabilityImpact =>
      '需要Owner权限、Ultimate和受支持的注册表。此模式适用于项目中的所有容器仓库。匹配的标签无法覆盖或删除，包括通过清理策略删除。只要存在任何不可变规则，直接删除清单也会被阻止。规则无法编辑，变更生效可能需要一些时间。';

  @override
  String get containerImmutabilityAcknowledge => '我了解项目范围的保护和工作流影响。';

  @override
  String get containerImmutabilityUncertain => '无法确认创建结果。请求可能已经成功；重试前请检查当前规则。';

  @override
  String get containerImmutabilityInspect => '检查当前规则';

  @override
  String get containerImmutabilityRejected =>
      'GitLab拒绝了请求，或者相同模式的不可变规则已存在。请检查当前规则、模式和项目限制。';

  @override
  String get containerImmutabilityAuth => '会话被拒绝。创建规则前请重新登录。';

  @override
  String get containerImmutabilityAccountChanged =>
      '账户已更改。请关闭此对话框，然后为所选账户重新打开。';

  @override
  String get containerImmutabilityDeleteTitle => '删除不可变规则';

  @override
  String get containerImmutabilityDeleteButton => '删除规则';

  @override
  String get containerImmutabilityDeleteDone => '不可变规则已删除。';

  @override
  String containerImmutabilityDeleteProject(String projectId) {
    return '项目 $projectId';
  }

  @override
  String get containerImmutabilityDeleteRuleId => '规则ID';

  @override
  String get containerImmutabilityDeleteConfirm => '输入完全相同的模式';

  @override
  String get containerImmutabilityDeleteImpact =>
      '删除此规则会移除其对项目中所有容器仓库的保护。匹配的标签可能可以被覆盖或删除，包括通过清理策略删除。移除最后一条不可变规则可能允许直接删除清单。其他规则和权限仍可能适用。此操作不会删除镜像或标签。需要Owner权限，变更生效可能需要一些时间。';

  @override
  String get containerImmutabilityDeleteAcknowledge => '我了解项目范围的保护丢失风险。';

  @override
  String get containerImmutabilityDeleteUncertain =>
      '无法确认删除结果。请求可能已经成功。重试前请重新加载规则。';

  @override
  String get containerImmutabilityDeleteReload => '重新加载规则';

  @override
  String get containerImmutabilityDeleteRejected =>
      '规则已更改或GitLab拒绝了请求。重试前请重新加载并确认当前规则。';

  @override
  String get containerImmutabilityDeleteAuth => '会话被拒绝。删除规则前请重新登录。';

  @override
  String get containerImmutabilityDeleteAccountChanged =>
      '账户已更改。请关闭此对话框，然后为所选账户重新打开。';
}
