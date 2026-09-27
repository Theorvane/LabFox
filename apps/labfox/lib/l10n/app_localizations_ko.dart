// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get protectedTagsTitle => '보호 태그';

  @override
  String get protectedTagsEmpty => '보호 태그 규칙이 없습니다.';

  @override
  String get protectedTagsError => '보호 태그를 불러올 수 없습니다.';

  @override
  String get protectedTagsLoadMore => '더 보기';

  @override
  String get protectedTagCreateAccess => '생성 권한';

  @override
  String get protectedEnvironmentsTitle => '보호 환경';

  @override
  String get protectedEnvironmentsEmpty => '보호 환경 규칙이 없습니다.';

  @override
  String get protectedEnvironmentsError => '보호 환경을 불러올 수 없습니다.';

  @override
  String get protectedEnvironmentsUnavailable =>
      '보호 환경을 사용할 수 없거나 접근 권한이 없습니다.';

  @override
  String get protectedEnvironmentsLoadMore => '더 보기';

  @override
  String get protectedEnvironmentDeployAccess => '배포 권한';

  @override
  String get protectedEnvironmentApprovalRules => '승인 규칙';

  @override
  String protectedEnvironmentApprovalCount(int count) {
    return '필요한 승인: $count';
  }

  @override
  String get protectedBranchesTitle => '보호 브랜치';

  @override
  String get protectedBranchesEmpty => '보호 브랜치 규칙이 없습니다.';

  @override
  String get protectedBranchesError => '보호 브랜치를 불러올 수 없습니다.';

  @override
  String get protectedBranchesLoadMore => '더 보기';

  @override
  String get protectedBranchPushAccess => '푸시 권한';

  @override
  String get protectedBranchMergeAccess => '병합 권한';

  @override
  String get protectedBranchForcePush => '강제 푸시';

  @override
  String get protectedBranchCodeOwnerApproval => '코드 소유자 승인';

  @override
  String get protectedBranchInherited => '그룹에서 상속됨';

  @override
  String get protectedBranchEnabled => '사용';

  @override
  String get protectedBranchDisabled => '사용 안 함';

  @override
  String get protectedBranchNoAccess => '권한 규칙 없음';

  @override
  String get linkedIssuesTitle => '연결된 이슈';

  @override
  String get linkedIssuesError => '연결된 이슈를 불러올 수 없습니다.';

  @override
  String get linkedIssuesLoadMore => '더 보기';

  @override
  String get linkedIssuesRelatesTo => '관련됨';

  @override
  String get linkedIssuesBlocks => '차단함';

  @override
  String get linkedIssuesBlockedBy => '차단됨';

  @override
  String get groupLabelsTitle => '그룹 라벨';

  @override
  String get groupLabelsEmpty => '그룹 라벨이 아직 없습니다';

  @override
  String get groupLabelsError => '그룹 라벨을 불러올 수 없습니다.';

  @override
  String get groupMembersTitle => '그룹 멤버';

  @override
  String get groupMembersSearch => '그룹 멤버 검색';

  @override
  String get groupMembersEmpty => '그룹 멤버를 찾을 수 없습니다.';

  @override
  String get groupMembersError => '그룹 멤버를 불러올 수 없습니다.';

  @override
  String get pipelineSchedulesTitle => '파이프라인 일정';

  @override
  String get pipelineSchedulesAll => '전체';

  @override
  String get pipelineSchedulesActive => '활성';

  @override
  String get pipelineSchedulesInactive => '비활성';

  @override
  String get pipelineSchedulesEmpty => '파이프라인 일정이 없습니다.';

  @override
  String get pipelineSchedulesError => '파이프라인 일정을 불러올 수 없습니다.';

  @override
  String get pipelineSchedulesLoadMore => '더 보기';

  @override
  String get pipelineScheduleDetailError => '이 파이프라인 일정을 불러올 수 없습니다.';

  @override
  String pipelineScheduleNextRun(String date) {
    return '다음 실행: $date';
  }

  @override
  String get pipelineScheduleNextRunLabel => '다음 실행';

  @override
  String get pipelineScheduleRef => '참조';

  @override
  String get pipelineScheduleCron => '일정';

  @override
  String get pipelineScheduleTimezone => '시간대';

  @override
  String get pipelineScheduleOwner => '소유자';

  @override
  String get pipelineScheduleRunNow => '지금 실행';

  @override
  String get pipelineScheduleRunSuccess => '파이프라인 일정을 실행했습니다.';

  @override
  String get pipelineScheduleRunError => '파이프라인 일정을 실행할 수 없습니다.';

  @override
  String get pipelineScheduleLastPipeline => '마지막 파이프라인';

  @override
  String pipelineSchedulePipelineNumber(int number) {
    return '파이프라인 #$number';
  }

  @override
  String get deploymentsTitle => '배포';

  @override
  String get deploymentsAll => '전체';

  @override
  String get deploymentsSuccess => '성공';

  @override
  String get deploymentsFailed => '실패';

  @override
  String get deploymentsRunning => '진행 중';

  @override
  String get deploymentsCanceled => '취소됨';

  @override
  String get deploymentsCreated => '생성됨';

  @override
  String get deploymentsBlocked => '차단됨';

  @override
  String get deploymentsUnknownStatus => '알 수 없는 상태';

  @override
  String get deploymentsEmpty => '배포 내역이 없습니다.';

  @override
  String get deploymentsError => '배포 내역을 불러올 수 없습니다.';

  @override
  String get deploymentsLoadMore => '더 보기';

  @override
  String get deploymentsEnvironmentSearch => '환경 이름으로 필터';

  @override
  String get deploymentsUnknownEnvironment => '알 수 없는 환경';

  @override
  String get deploymentDetailError => '이 배포를 불러올 수 없습니다.';

  @override
  String deploymentNumber(int number) {
    return '배포 #$number';
  }

  @override
  String get deploymentEnvironment => '환경';

  @override
  String get deploymentRef => '참조';

  @override
  String get deploymentCommit => '커밋';

  @override
  String get deploymentJob => '작업';

  @override
  String get deploymentPipeline => '파이프라인';

  @override
  String get deploymentCreatedAt => '생성';

  @override
  String get deploymentUpdatedAt => '업데이트';

  @override
  String get deploymentUser => '배포자';

  @override
  String get releasesTitle => '릴리스';

  @override
  String get releasesEmpty => '릴리스가 아직 없습니다.';

  @override
  String get releasesError => '릴리스를 불러올 수 없습니다.';

  @override
  String get releaseDetailError => '이 릴리스를 불러올 수 없습니다.';

  @override
  String get releaseAssetsTitle => '에셋';

  @override
  String get releaseLoadMore => '더 보기';

  @override
  String get releaseUpcoming => '예정';

  @override
  String get activityTitle => '활동';

  @override
  String get activityAll => '전체';

  @override
  String get activityIssues => '이슈';

  @override
  String get activityMergeRequests => '병합 요청';

  @override
  String get activityEmpty => '최근 활동이 없습니다.';

  @override
  String get activityError => '프로젝트 활동을 불러올 수 없습니다.';

  @override
  String get activityLoadMore => '더 보기';

  @override
  String get activityUnknownActor => '알 수 없는 사용자';

  @override
  String get activityPush => '푸시';

  @override
  String get activityEvent => '프로젝트 활동';

  @override
  String activityBy(String actor, String action) {
    return '$actor님이 $action';
  }

  @override
  String get environmentsTitle => '환경';

  @override
  String get environmentsAll => '전체';

  @override
  String get environmentsAvailable => '사용 가능';

  @override
  String get environmentsStopping => '중지 중';

  @override
  String get environmentsStopped => '중지됨';

  @override
  String get environmentsSearch => '환경 검색';

  @override
  String get environmentsSearchLength => '3자 이상 입력하세요.';

  @override
  String get environmentsEmpty => '환경을 찾을 수 없습니다.';

  @override
  String get environmentsError => '환경을 불러올 수 없습니다.';

  @override
  String get environmentsLoadMore => '더 보기';

  @override
  String get environmentDetailError => '이 환경을 불러올 수 없습니다.';

  @override
  String get environmentAutoStop => '자동 중지';

  @override
  String get environmentOpenUrl => '환경 열기';

  @override
  String get environmentLatestDeployment => '최근 배포';

  @override
  String get environmentUnknownStatus => '알 수 없는 상태';

  @override
  String get projectMembersTitle => '멤버';

  @override
  String get projectMembersSearch => '멤버 검색';

  @override
  String get projectMembersClearSearch => '검색 지우기';

  @override
  String get projectMembersEmpty => '멤버를 찾을 수 없습니다.';

  @override
  String get projectMembersError => '멤버를 불러올 수 없습니다.';

  @override
  String get projectMembersLoadMore => '더 보기';

  @override
  String get projectMembersExpiry => '만료일';

  @override
  String get memberRoleNoAccess => '접근 권한 없음';

  @override
  String get memberRoleMinimal => '최소 접근 권한';

  @override
  String get memberRoleGuest => '게스트';

  @override
  String get memberRolePlanner => '플래너';

  @override
  String get memberRoleReporter => '리포터';

  @override
  String get memberRoleSecurityManager => '보안 관리자';

  @override
  String get memberRoleDeveloper => '개발자';

  @override
  String get memberRoleMaintainer => '메인테이너';

  @override
  String get memberRoleOwner => '소유자';

  @override
  String get memberRoleUnknown => '알 수 없는 역할';

  @override
  String get containerRegistryTitle => '컨테이너 레지스트리';

  @override
  String get containerRegistryEmpty => '컨테이너 이미지가 아직 없습니다.';

  @override
  String get containerRegistryError => '컨테이너 이미지를 불러올 수 없습니다.';

  @override
  String get containerTagsTitle => '이미지 태그';

  @override
  String get containerTagsEmpty => '태그가 아직 없습니다.';

  @override
  String get containerTagsError => '이미지 태그를 불러올 수 없습니다.';

  @override
  String get containerTagError => '이 태그를 불러올 수 없습니다.';

  @override
  String get containerTagDigest => '다이제스트';

  @override
  String get containerTagRevision => '리비전';

  @override
  String get containerTagSize => '크기(바이트)';

  @override
  String get containerLoadMore => '더 보기';

  @override
  String get milestonesTitle => '마일스톤';

  @override
  String get milestonesActive => '진행 중';

  @override
  String get milestonesClosed => '종료됨';

  @override
  String get milestonesEmpty => '이 상태의 마일스톤이 없습니다.';

  @override
  String get milestonesError => '마일스톤을 불러올 수 없습니다.';

  @override
  String get milestoneDetailError => '이 마일스톤을 불러올 수 없습니다.';

  @override
  String get milestoneStartDate => '시작일';

  @override
  String get milestoneDueDate => '마감일';

  @override
  String get milestoneLoadMore => '더 보기';

  @override
  String get appTitle => 'LabFox';

  @override
  String get homeTitle => '홈';

  @override
  String homeSignedInAs(String username) {
    return '$username 님으로 로그인됨';
  }

  @override
  String get homeEmptyWork => '이슈, 병합 요청, 파이프라인이 여기에 표시됩니다.';

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
  String get signOut => '로그아웃';

  @override
  String get signInTitle => 'GitLab 계정 연결';

  @override
  String get signInNoAccountNote =>
      'LabFox에는 자체 계정이 없습니다. 이미 쓰고 계신 GitLab에 연결하세요 — gitlab.com이나 직접 호스팅하는 인스턴스.';

  @override
  String get signInInstanceLabel => 'GitLab 인스턴스 URL';

  @override
  String get signInInstanceRequired => 'GitLab 인스턴스 URL을 입력하세요.';

  @override
  String get signInInstanceInvalid =>
      '올바른 https URL을 입력하세요. 예: https://gitlab.com';

  @override
  String get signInTokenLabel => 'Personal Access Token';

  @override
  String get signInTokenHelp => 'api 및 read_user 스코프가 필요합니다.';

  @override
  String get signInTokenToggle => '토큰 표시 또는 숨기기';

  @override
  String get signInTokenRequired => 'Personal Access Token을 입력하세요.';

  @override
  String get signInSubmit => '로그인';

  @override
  String get signInOr => '또는';

  @override
  String get signInOAuthButton => '내 인스턴스에 인가하기';

  @override
  String get signInClientIdLabel => 'OAuth 클라이언트 ID';

  @override
  String get signInClientIdHelp => 'self-hosted 인스턴스에서 OAuth를 쓸 때만 필요합니다.';

  @override
  String get signInOAuthNeedsClientId => '이 인스턴스의 OAuth 클라이언트 ID를 입력하세요.';

  @override
  String get signInErrorToken => '토큰이 거부되었습니다. 올바른지, 만료되지 않았는지 확인하세요.';

  @override
  String get signInErrorScope => '토큰에 필요한 스코프가 없습니다. api와 read_user가 필요합니다.';

  @override
  String get signInErrorUnreachable =>
      '해당 인스턴스에 연결할 수 없습니다. URL, 네트워크, 인증서 신뢰 여부를 확인하세요.';

  @override
  String get signInErrorGeneric => '로그인에 실패했습니다. 다시 시도하세요.';

  @override
  String get scopeAssigned => 'Assigned';

  @override
  String get scopeCreated => 'Created';

  @override
  String get homeRefresh => 'Refresh';

  @override
  String get homeFavoritesEmpty => 'Star projects to pin them here.';

  @override
  String get homeMyWork => '내 작업';

  @override
  String get homeProjects => '프로젝트';

  @override
  String get homeGroups => 'Groups';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupsEmpty => 'You are not a member of any groups yet.';

  @override
  String get groupsError => 'Could not load your groups.';

  @override
  String get groupDetailTitle => '그룹';

  @override
  String get groupDetailError => '이 그룹을 불러오지 못했습니다.';

  @override
  String get groupSubgroups => '하위 그룹';

  @override
  String get groupSubgroupsEmpty => '하위 그룹이 없습니다.';

  @override
  String get groupProjects => '프로젝트';

  @override
  String get groupProjectsEmpty => '이 그룹에 프로젝트가 없습니다.';

  @override
  String get groupLoadMore => '더 보기';

  @override
  String get projectsTitle => '프로젝트';

  @override
  String get projectsEmpty => '아직 참여 중인 프로젝트가 없습니다.';

  @override
  String get projectsError => '프로젝트를 불러올 수 없습니다.';

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
  String get retry => '다시 시도';

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
  String get issueEdit => '이슈 수정';

  @override
  String get issueSaveChanges => '변경 사항 저장';

  @override
  String get issueEditError => '이슈를 저장할 수 없습니다. 권한을 확인하고 다시 시도하세요.';

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
  String get projectOverviewTitle => '프로젝트';

  @override
  String get projectOverviewError => '이 프로젝트를 불러올 수 없습니다.';

  @override
  String get projectOverviewNoReadme => '이 프로젝트에는 README가 없습니다.';

  @override
  String get projectOverviewRepository => '저장소';

  @override
  String get repositoryTitle => '저장소';

  @override
  String get repositoryError => '이 디렉터리를 불러올 수 없습니다.';

  @override
  String get repositoryEmpty => '이 디렉터리는 비어 있습니다.';

  @override
  String get fileError => '이 파일을 불러올 수 없습니다.';

  @override
  String get fileNotFound => '파일을 찾을 수 없습니다.';

  @override
  String get fileBinary => '바이너리 파일이라 텍스트로 표시할 수 없습니다.';

  @override
  String get fileCopy => 'Copy contents';

  @override
  String get fileCopied => 'Contents copied';

  @override
  String get projectOverviewBranches => '브랜치';

  @override
  String get projectOverviewCommits => '커밋';

  @override
  String get projectOverviewCode => 'Code';

  @override
  String get projectOverviewBrowseCode => 'Browse code';

  @override
  String get branchesTitle => '브랜치';

  @override
  String get branchesError => '브랜치를 불러올 수 없습니다.';

  @override
  String get branchesEmpty => '이 저장소에는 브랜치가 없습니다.';

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
  String get branchDefault => '기본 브랜치';

  @override
  String get commitsTitle => '커밋';

  @override
  String get commitsError => '커밋을 불러올 수 없습니다.';

  @override
  String get commitsEmpty => '이 브랜치에는 아직 커밋이 없습니다.';

  @override
  String get commitTitle => '커밋';

  @override
  String get commitError => '이 커밋을 불러올 수 없습니다.';

  @override
  String get projectOverviewIssues => '이슈';

  @override
  String get issuesTitle => '이슈';

  @override
  String get issuesFilterOpen => '열림';

  @override
  String get issuesFilterClosed => '닫힘';

  @override
  String get issuesError => '이슈를 불러올 수 없습니다.';

  @override
  String get issuesEmpty => '이슈가 없습니다.';

  @override
  String get issueError => '이 이슈를 불러올 수 없습니다.';

  @override
  String get issueStateOpen => '열림';

  @override
  String get issueStateClosed => '닫힘';

  @override
  String get issueNoDescription => '설명이 없습니다.';

  @override
  String issueOpenedBy(String username) {
    return '$username 님이 열었습니다';
  }

  @override
  String get projectOverviewMergeRequests => '병합 요청';

  @override
  String get mergeRequestsTitle => '병합 요청';

  @override
  String get mrFilterOpen => '열림';

  @override
  String get mrFilterMerged => '병합됨';

  @override
  String get mrFilterClosed => '닫힘';

  @override
  String get mergeRequestsError => '병합 요청을 불러올 수 없습니다.';

  @override
  String get mergeRequestsEmpty => '병합 요청이 없습니다.';

  @override
  String get mergeRequestError => '이 병합 요청을 불러올 수 없습니다.';

  @override
  String get mergeRequestNoDescription => '설명이 없습니다.';

  @override
  String get mrStateOpen => '열림';

  @override
  String get mrStateMerged => '병합됨';

  @override
  String get mrStateClosed => '닫힘';

  @override
  String get mrDraft => '초안';

  @override
  String get changesTitle => '변경 사항';

  @override
  String get changesError => '변경 사항을 불러올 수 없습니다.';

  @override
  String get changesEmpty => '변경 사항이 없습니다.';

  @override
  String get changesBinary => '바이너리 파일 — 표시하지 않음.';

  @override
  String get commitViewChanges => '변경 사항 보기';

  @override
  String get mrViewChanges => '변경 사항 보기';

  @override
  String get changesOmitted => 'diff가 너무 크거나 접혀 있어 표시하지 않습니다.';

  @override
  String get commentsHeading => '댓글';

  @override
  String get commentsError => '댓글을 불러올 수 없습니다.';

  @override
  String get commentsEmpty => '아직 댓글이 없습니다.';

  @override
  String get commentComposerHint => '댓글을 작성하세요…';

  @override
  String get commentComposerSubmit => '댓글 달기';

  @override
  String get commentPostForbidden =>
      '여기에 댓글을 달 권한이 없습니다. 토큰에 api 스코프가 있는지 확인하세요.';

  @override
  String get commentPostError => '댓글을 게시할 수 없습니다. 다시 시도하세요.';

  @override
  String get cancel => '취소';

  @override
  String get mrApprove => '승인';

  @override
  String get mrUnapprove => '승인 취소';

  @override
  String get mrMerge => '병합';

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
  String get mrMergeConfirmTitle => '이 병합 요청을 병합할까요?';

  @override
  String mrMergeConfirmBody(String mr) {
    return '$mr 병합은 되돌릴 수 없습니다.';
  }

  @override
  String mrApprovalsSummary(int approved, int required) {
    return '승인 $approved/$required';
  }

  @override
  String get mrNotMergeable =>
      '지금은 병합할 수 없습니다. 승인, 리베이스, 또는 통과된 파이프라인이 필요할 수 있습니다.';

  @override
  String get mrActionForbidden => '이 작업을 수행할 권한이 없습니다. 토큰 스코프와 역할을 확인하세요.';

  @override
  String get mrActionError => '작업을 완료할 수 없습니다. 다시 시도하세요.';

  @override
  String get projectOverviewPipelines => '파이프라인';

  @override
  String get pipelinesTitle => '파이프라인';

  @override
  String get pipelinesError => '파이프라인을 불러올 수 없습니다.';

  @override
  String get pipelinesEmpty => '아직 파이프라인이 없습니다.';

  @override
  String get pipelineError => '이 파이프라인을 불러올 수 없습니다.';

  @override
  String get pipelineJobsError => '잡을 불러올 수 없습니다.';

  @override
  String get pipelineNoJobs => '이 파이프라인에는 잡이 없습니다.';

  @override
  String get jobTitle => '잡';

  @override
  String get jobError => '이 잡을 불러올 수 없습니다.';

  @override
  String get jobRefresh => '새로고침';

  @override
  String get jobLogError => '로그를 불러올 수 없습니다.';

  @override
  String get jobLogEmpty => '이 잡에는 로그 출력이 없습니다.';

  @override
  String get jobActionRetry => '다시 시도';

  @override
  String get jobActionCancel => '취소';

  @override
  String get jobActionRun => '실행';

  @override
  String get jobActionForbidden => '이 작업을 수행할 권한이 없습니다.';

  @override
  String get jobActionInvalid => '현재 잡 상태에서는 이 작업을 할 수 없습니다.';

  @override
  String get jobActionError => '작업을 완료할 수 없습니다. 다시 시도하세요.';

  @override
  String get pipelineActionRetry => '다시 시도';

  @override
  String get pipelineActionCancel => '취소';

  @override
  String get pipelineActionForbidden => '이 작업을 수행할 권한이 없습니다.';

  @override
  String get pipelineActionInvalid => '현재 파이프라인 상태에서는 이 작업을 할 수 없습니다.';

  @override
  String get pipelineActionError => '작업을 완료할 수 없습니다. 다시 시도하세요.';

  @override
  String get accountsTitle => '계정';

  @override
  String get accountAdd => '계정 추가';

  @override
  String get accountRemove => '계정 제거';

  @override
  String get homeSwitchAccount => '계정';

  @override
  String get homeInbox => '할 일 목록';

  @override
  String get inboxTitle => '할 일 목록';

  @override
  String get inboxEmpty => '모두 처리했습니다.';

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
  String get inboxError => '할 일 목록을 불러오지 못했습니다.';

  @override
  String get inboxMarkAllDone => '모두 완료 처리';

  @override
  String get inboxMarkDone => '완료 처리';

  @override
  String get inboxMarkDoneError => '항목을 완료 처리하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get inboxActionAssigned => '나에게 할당됨';

  @override
  String get inboxActionMentioned => '나를 언급함';

  @override
  String get inboxActionBuildFailed => '파이프라인 실패';

  @override
  String get inboxActionMarked => '할 일 추가됨';

  @override
  String get inboxActionApprovalRequired => '승인 필요';

  @override
  String get inboxActionUnmergeable => '병합할 수 없음';

  @override
  String get inboxActionDirectlyAddressed => '나를 직접 지목함';

  @override
  String get homeSearch => '검색';

  @override
  String get searchTitle => '검색';

  @override
  String get searchHint => '프로젝트, 이슈, 병합 요청 검색';

  @override
  String get searchScopeProjects => '프로젝트';

  @override
  String get searchScopeIssues => '이슈';

  @override
  String get searchScopeMergeRequests => '병합 요청';

  @override
  String get searchInitial => '검색어를 입력하세요.';

  @override
  String get searchEmpty => '검색 결과가 없습니다.';

  @override
  String get searchError => '검색을 완료할 수 없습니다.';

  @override
  String get searchLoadMore => '더 보기';

  @override
  String get listSearchHint => 'Search by title';

  @override
  String get listSearchClose => 'Close search';

  @override
  String get projectAddFavorite => '즐겨찾기에 추가';

  @override
  String get projectRemoveFavorite => '즐겨찾기에서 제거';

  @override
  String get homeFavorites => '즐겨찾기';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsAccounts => '계정';

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
  String get settingsLicenses => '오픈소스 라이선스';

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
  String get navHome => '홈';

  @override
  String get navInbox => '받은함';

  @override
  String get navSearch => '검색';

  @override
  String get navMe => '내 정보';

  @override
  String get meTitle => '내 정보';

  @override
  String get meSettings => '설정';

  @override
  String get meAccounts => '계정 전환';

  @override
  String get projectLabelsTitle => '라벨';

  @override
  String get projectLabelsError => '라벨을 불러올 수 없습니다.';

  @override
  String get projectLabelsEmpty => '라벨이 없습니다';

  @override
  String get projectLabelsNoMatch => '일치하는 라벨이 없습니다';

  @override
  String get projectLabelSearch => '라벨 검색';

  @override
  String get projectLabelNew => '새 라벨';

  @override
  String get projectLabelGroup => '그룹 라벨';

  @override
  String get projectLabelProject => '프로젝트 라벨';

  @override
  String get projectLabelError => '이 라벨을 불러올 수 없습니다.';

  @override
  String get projectLabelOpenIssues => '열린 이슈';

  @override
  String get projectLabelClosedIssues => '닫힌 이슈';

  @override
  String get projectLabelOpenMrs => '열린 머지 리퀘스트';

  @override
  String get projectLabelName => '이름';

  @override
  String get projectLabelColor => '색상 (#RRGGBB)';

  @override
  String get projectLabelDescription => '설명 (선택 사항)';

  @override
  String get projectLabelRequired => '필수 입력 항목입니다';

  @override
  String get projectLabelInvalidColor => '#5843AD와 같은 색상을 입력하세요';

  @override
  String get projectLabelCreate => '라벨 만들기';

  @override
  String get projectLabelCreateError => '라벨을 만들 수 없습니다. 권한과 입력값을 확인하세요.';

  @override
  String get tagsTitle => '태그';

  @override
  String get tagsEmpty => '태그가 없습니다';

  @override
  String get tagsError => '태그를 불러올 수 없습니다.';

  @override
  String get tagsNoMatch => '일치하는 태그가 없습니다';

  @override
  String get tagSearchHint => '태그 검색';

  @override
  String get tagError => '이 태그를 불러올 수 없습니다.';

  @override
  String get tagProtected => '보호된 태그';

  @override
  String get tagNew => '새 태그';

  @override
  String get tagName => '태그 이름';

  @override
  String get tagFromRef => '브랜치, 태그 또는 커밋 SHA에서 만들기';

  @override
  String get tagMessage => '메시지 (선택 사항)';

  @override
  String get tagPipelineNotice => '태그를 만들면 CI/CD 파이프라인이 시작될 수 있습니다.';

  @override
  String get tagFieldRequired => '필수 입력 항목입니다';

  @override
  String get tagCreate => '태그 만들기';

  @override
  String get tagCreateError => '태그를 만들 수 없습니다. 권한과 기준 ref를 확인하세요.';

  @override
  String get snippetsTitle => '스니펫';

  @override
  String get snippetsEmpty => '스니펫이 없습니다';

  @override
  String get snippetsError => '스니펫을 불러올 수 없습니다.';

  @override
  String get snippetError => '스니펫을 불러올 수 없습니다.';

  @override
  String get snippetContent => '내용';

  @override
  String get snippetContentError => '스니펫 내용을 불러올 수 없습니다.';

  @override
  String get homeRecents => '최근';

  @override
  String get wikiTitle => '위키';

  @override
  String get wikiEmpty => '아직 위키 페이지가 없습니다.';

  @override
  String get wikiListError => '위키 페이지를 불러올 수 없습니다.';

  @override
  String get wikiPageError => '이 위키 페이지를 불러올 수 없습니다.';

  @override
  String get packageRegistryTitle => '패키지 레지스트리';

  @override
  String get packageRegistryEmpty => '아직 패키지가 없습니다.';

  @override
  String get packageRegistryError => '패키지를 불러올 수 없습니다.';

  @override
  String get packageDetailError => '이 패키지를 불러올 수 없습니다.';

  @override
  String get packageFiles => '파일';

  @override
  String get packageFilesEmpty => '이 패키지에는 파일이 없습니다.';

  @override
  String get packageLoadMore => '더 보기';
}
