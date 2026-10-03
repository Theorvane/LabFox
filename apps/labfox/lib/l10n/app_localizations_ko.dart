// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get pipelineScheduleCreate => '스케줄 생성';

  @override
  String get pipelineScheduleCreateTitle => '새 파이프라인 스케줄';

  @override
  String get pipelineScheduleCreateDescription => '설명';

  @override
  String get pipelineScheduleCreateFieldRequired => '값을 입력하세요.';

  @override
  String get pipelineScheduleCreateActive => '활성';

  @override
  String get pipelineScheduleCreateHint =>
      'GitLab에서 실행 대상, cron 식 및 시간대를 검증합니다. 시간대를 비워 두면 UTC를 사용합니다. 브랜치와 태그 이름이 같으면 전체 ref를 입력하세요.';

  @override
  String get pipelineScheduleCreateError =>
      '파이프라인 스케줄을 생성하지 못했습니다. 권한, 실행 대상, cron 식 및 시간대를 확인하세요.';

  @override
  String get releasePickerTitle => '프로젝트 마일스톤 선택';

  @override
  String get releasePickerSearch => '프로젝트 마일스톤 검색';

  @override
  String get releasePickerEmpty => '프로젝트 마일스톤이 없습니다.';

  @override
  String get releasePickerError => '마일스톤을 불러오지 못했습니다.';

  @override
  String get releasePickerMore => '마일스톤 더 불러오기';

  @override
  String get releasePickerUse => '마일스톤 사용';

  @override
  String releasePickerRemove(String title) {
    return '마일스톤 $title 제거';
  }

  @override
  String get releaseCreationDateLabel => '공개 날짜(선택 사항)';

  @override
  String get releaseCreationDateDefault => '공개 시간은 GitLab에서 설정합니다.';

  @override
  String get releaseCreationChooseDate => '공개 날짜 선택';

  @override
  String get releaseCreationChooseTime => '공개 시간 선택';

  @override
  String get releaseCreationClearDate => 'GitLab 공개 시간 사용';

  @override
  String releaseCreationDateHelp(String zone) {
    return '시간대: $zone. 미래 날짜는 예정된 릴리스, 과거 날짜는 과거 릴리스를 생성합니다.';
  }

  @override
  String get pipelineScheduleDelete => '스케줄 삭제';

  @override
  String get pipelineScheduleDeleteConfirmTitle => '이 파이프라인 스케줄을 삭제하시겠습니까?';

  @override
  String pipelineScheduleDeleteConfirmBody(String name) {
    return '파이프라인 스케줄 \"$name\"이 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get pipelineScheduleDeleteError =>
      '파이프라인 스케줄을 삭제하지 못했습니다. 권한을 확인하고 다시 시도하세요.';

  @override
  String get releaseScheduleEdit => '릴리스 날짜 편집';

  @override
  String get releaseScheduleChangeDate => '날짜 변경';

  @override
  String get releaseScheduleChangeTime => '시간 변경';

  @override
  String get releaseScheduleSave => '릴리스 날짜 저장';

  @override
  String get releaseScheduleError => '릴리스 날짜를 업데이트하지 못했습니다.';

  @override
  String releaseScheduleHelp(String zone) {
    return '시간은 기기 시간대($zone)를 사용합니다. 미래 날짜를 선택하면 예정된 릴리스로 설정됩니다.';
  }

  @override
  String get pipelineScheduleEdit => '스케줄 편집';

  @override
  String get pipelineScheduleSave => '저장';

  @override
  String get pipelineScheduleDescription => '설명';

  @override
  String get pipelineScheduleFieldRequired => '값을 입력하세요.';

  @override
  String get pipelineScheduleEditHint =>
      'GitLab에서 cron 식과 시간대를 검증합니다. 저장하면 향후 실행 일정이 변경되며 실행 대상, 활성 상태, 변수 및 입력은 유지됩니다.';

  @override
  String get pipelineScheduleEditError =>
      '파이프라인 스케줄을 수정하지 못했습니다. 권한, cron 식 및 시간대를 확인하세요.';

  @override
  String get pipelineScheduleTakeOwnership => '소유권 가져오기';

  @override
  String get pipelineScheduleOwnershipConfirmTitle => '이 스케줄의 소유권을 가져오시겠습니까?';

  @override
  String pipelineScheduleOwnershipConfirmBody(String name) {
    return '\"$name\"의 소유자가 됩니다. 예약 파이프라인은 내 권한으로 실행됩니다. Maintainer 또는 Owner 역할이 필요합니다.';
  }

  @override
  String get pipelineScheduleOwnershipError =>
      '파이프라인 스케줄의 소유권을 가져오지 못했습니다. 권한을 확인하고 다시 시도하세요.';

  @override
  String get protectedTagProtectTitle => '태그 보호';

  @override
  String get protectedTagProtectName => '규칙 이름';

  @override
  String get protectedTagProtectRole => '일치하는 태그를 생성할 수 있는 사용자';

  @override
  String get protectedTagProtectNoOne => '아무도 없음';

  @override
  String get protectedTagProtectDevelopers => '개발자 및 관리자';

  @override
  String get protectedTagProtectMaintainers => '관리자';

  @override
  String protectedTagProtectWarning(String projectId) {
    return '이 규칙은 프로젝트 $projectId에서 일치하는 태그의 생성 권한을 변경하며 태그 파이프라인과 작업에 영향을 줄 수 있습니다.';
  }

  @override
  String get protectedTagProtectWildcard =>
      '와일드카드 규칙은 앞으로 생성할 태그에도 적용될 수 있습니다. 정확한 패턴과 권한을 확인하세요.';

  @override
  String get protectedTagProtectAcknowledge => '이 규칙이 프로젝트 전체에 미치는 영향을 이해했습니다.';

  @override
  String get protectedTagProtectSubmit => '태그 보호';

  @override
  String get protectedTagProtectExisting => '규칙이 이미 있습니다. 변경 사항이 없습니다.';

  @override
  String get protectedTagProtectUncertain =>
      '결과를 확인할 수 없습니다. 다시 시도하기 전에 모든 규칙을 새로고침하세요.';

  @override
  String get protectedTagProtectReload => '규칙 새로고침';

  @override
  String get protectedTagProtectLoadError => '보호 태그 규칙을 확인할 수 없습니다. 다시 불러오세요.';

  @override
  String get protectedTagProtectSessionChanged =>
      '계정이 변경되었습니다. 이 창을 닫고 다시 시작하세요.';

  @override
  String get protectedTagProtectCreated => '보호 태그 규칙이 생성되었습니다.';

  @override
  String get protectedTagProtectCancel => '취소';

  @override
  String get protectedTagProtectForbidden =>
      '이 규칙을 생성할 권한이 없습니다. 다시 시도하기 전에 새로고침하세요.';

  @override
  String get protectedTagProtectUnauthorized =>
      '세션이 만료되었습니다. 다시 로그인한 후 규칙을 생성하세요.';

  @override
  String get protectedTagProtectRateLimited =>
      'GitLab이 요청을 제한하고 있습니다. 잠시 기다린 뒤 규칙을 새로고침하세요.';

  @override
  String get protectedTagProtectUnavailable =>
      '프로젝트 또는 보호 태그 리소스에 접근할 수 없습니다. 다시 시도하기 전에 새로고침하세요.';

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
  String get protectedBranchProtectTitle => '브랜치 보호';

  @override
  String get protectedBranchProtectName => '규칙 이름';

  @override
  String get protectedBranchProtectPush => '푸시 허용';

  @override
  String get protectedBranchProtectMerge => '병합 허용';

  @override
  String get protectedBranchProtectNoOne => '아무도 없음';

  @override
  String get protectedBranchProtectDevelopers => '개발자 및 관리자';

  @override
  String get protectedBranchProtectMaintainers => '관리자';

  @override
  String protectedBranchProtectWarning(String projectId) {
    return '이 규칙은 프로젝트 $projectId의 푸시 및 병합 권한을 변경합니다. 병합 요청, 보호된 CI 변수 및 작업에 영향을 줄 수 있습니다.';
  }

  @override
  String get protectedBranchProtectWildcard =>
      '와일드카드 규칙은 앞으로 생성할 브랜치에도 적용될 수 있습니다. 정확한 패턴과 두 권한을 확인하세요.';

  @override
  String get protectedBranchProtectAcknowledge =>
      '이 규칙이 프로젝트 전체에 미치는 영향을 이해했습니다.';

  @override
  String get protectedBranchProtectSubmit => '브랜치 보호';

  @override
  String get protectedBranchProtectExisting => '규칙이 이미 있습니다. 변경 사항이 없습니다.';

  @override
  String get protectedBranchProtectUncertain =>
      '결과를 확인할 수 없습니다. 다시 시도하기 전에 모든 규칙을 새로고침하세요.';

  @override
  String get protectedBranchProtectReload => '규칙 새로고침';

  @override
  String get protectedBranchProtectLoadError =>
      '보호 브랜치 규칙을 확인할 수 없습니다. 다시 불러오세요.';

  @override
  String get protectedBranchProtectSessionChanged =>
      '계정이 변경되었습니다. 이 창을 닫고 다시 시작하세요.';

  @override
  String get protectedBranchProtectCreated => '보호 브랜치 규칙이 생성되었습니다.';

  @override
  String get protectedBranchProtectCancel => '취소';

  @override
  String get protectedBranchProtectForbidden =>
      '이 규칙을 생성할 권한이 없습니다. 다시 시도하기 전에 새로고침하세요.';

  @override
  String get protectedBranchProtectUnauthorized =>
      '세션이 만료되었습니다. 다시 로그인한 후 규칙을 생성하세요.';

  @override
  String get protectedBranchProtectRateLimited =>
      'GitLab이 요청을 제한하고 있습니다. 잠시 기다린 뒤 규칙을 새로고침하세요.';

  @override
  String get protectedBranchProtectUnavailable =>
      '프로젝트 또는 보호 브랜치 리소스에 접근할 수 없습니다. 다시 시도하기 전에 새로고침하세요.';

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
  String get pipelineScheduleHistoryTitle => '실행 이력';

  @override
  String get pipelineScheduleHistoryEmpty => '이 일정에서 실행된 파이프라인이 아직 없습니다.';

  @override
  String get pipelineScheduleHistoryError => '실행 이력을 불러올 수 없습니다.';

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
  String get releaseEdit => '릴리스 편집';

  @override
  String get releaseSave => '릴리스 저장';

  @override
  String get releaseEditName => '릴리스 이름';

  @override
  String get releaseEditDescription => '설명 (Markdown)';

  @override
  String get releaseNameRequired => '릴리스 이름을 입력하세요.';

  @override
  String get releaseEditError => '릴리스를 수정할 수 없습니다.';

  @override
  String get releaseNew => '새 릴리스';

  @override
  String get releaseCreate => '릴리스 만들기';

  @override
  String get releaseTagName => '태그 이름';

  @override
  String get releaseRef => '태그를 만들 기준 ref (선택 사항)';

  @override
  String get releaseRefHelp => '태그가 이미 있으면 비워 두세요.';

  @override
  String get releaseName => '릴리스 이름 (선택 사항)';

  @override
  String get releaseDescription => '설명 (Markdown)';

  @override
  String get releaseTagRequired => '태그 이름을 입력하세요.';

  @override
  String get releaseCreateError => '릴리스를 만들 수 없습니다.';

  @override
  String get releaseAddAssetLink => '자산 링크 추가';

  @override
  String get releaseAddLink => '링크 추가';

  @override
  String get releaseAssetName => '링크 이름';

  @override
  String get releaseAssetUrl => '링크 URL';

  @override
  String get releaseAssetNameRequired => '링크 이름을 입력하세요.';

  @override
  String get releaseAssetUrlInvalid => 'HTTP 또는 HTTPS URL을 입력하세요.';

  @override
  String get releaseAssetNameDuplicate => '같은 이름의 링크가 이미 있습니다.';

  @override
  String get releaseAssetCreateError => '자산 링크를 추가할 수 없습니다.';

  @override
  String get releaseNoAssets => '아직 자산이 없습니다.';

  @override
  String get releaseDelete => '릴리스 삭제';

  @override
  String get releaseDeleteConfirmTitle => '이 릴리스를 삭제할까요?';

  @override
  String get releaseDeleteConfirmBody => '릴리스와 릴리스 노트가 삭제됩니다. Git 태그는 유지됩니다.';

  @override
  String get releaseDeleteError => '릴리스를 삭제할 수 없습니다.';

  @override
  String get releaseDeleteAssetLink => '자산 링크 삭제';

  @override
  String get releaseDeleteLink => '링크 삭제';

  @override
  String get releaseAssetDeleteConfirmTitle => '이 자산 링크를 삭제할까요?';

  @override
  String releaseAssetDeleteConfirmBody(String name) {
    return '$name 링크를 제거합니다. 연결된 파일은 삭제되지 않습니다.';
  }

  @override
  String get releaseAssetDeleteError => '자산 링크를 삭제할 수 없습니다.';

  @override
  String get releaseEditAssetLink => '자산 링크 편집';

  @override
  String get releaseSaveLink => '링크 저장';

  @override
  String get releaseAssetEditError => '자산 링크를 수정할 수 없습니다.';

  @override
  String get releaseMilestonesEdit => '릴리스 마일스톤 편집';

  @override
  String get releaseMilestonesTitle => '마일스톤';

  @override
  String get releaseMilestonesHelp =>
      '정확한 마일스톤 제목을 입력하세요. 그룹 마일스톤 지원 여부는 GitLab 요금제와 프로젝트 그룹에 따라 달라집니다.';

  @override
  String get releaseMilestoneTitle => '마일스톤 제목';

  @override
  String get releaseMilestoneAdd => '마일스톤 추가';

  @override
  String get releaseMilestonesSave => '마일스톤 저장';

  @override
  String get releaseMilestonesError => '릴리스 마일스톤을 업데이트하지 못했습니다.';

  @override
  String get releaseMilestoneTitleRequired => '마일스톤 제목을 입력하세요.';

  @override
  String get releaseMilestoneDuplicate => '이미 선택된 마일스톤입니다.';

  @override
  String releaseMilestoneRemove(String title) {
    return '$title 제거';
  }

  @override
  String get releaseAssetDirectPath => '새 직접 다운로드 경로 (선택 사항)';

  @override
  String get releaseAssetDirectPathHelp =>
      '비워두면 현재 직접 다운로드 경로를 유지합니다. 변경하려면 /bin/app.zip 같은 경로를 입력하세요.';

  @override
  String get releaseAssetDirectPathInvalid =>
      '호스트, 쿼리, 프래그먼트 없이 /로 시작하는 경로를 입력하세요.';

  @override
  String get releaseAssetType => '링크 유형';

  @override
  String get releaseAssetKeepType => '현재 유형 유지';

  @override
  String get releaseAssetTypeOther => '기타';

  @override
  String get releaseAssetTypeRunbook => '런북';

  @override
  String get releaseAssetTypeImage => '이미지';

  @override
  String get releaseAssetTypePackage => '패키지';

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
  String get milestoneNew => '새 마일스톤';

  @override
  String get milestoneCreate => '마일스톤 만들기';

  @override
  String get milestoneTitleField => '제목';

  @override
  String get milestoneDescriptionField => '설명';

  @override
  String get milestoneTitleRequired => '마일스톤 제목을 입력하세요.';

  @override
  String get milestoneDateOrderError => '시작일은 마감일보다 늦을 수 없습니다.';

  @override
  String get milestoneCreateError => '마일스톤을 만들 수 없습니다.';

  @override
  String get milestoneChooseDate => '날짜 선택';

  @override
  String get milestoneClearDate => '날짜 지우기';

  @override
  String get milestoneEdit => '마일스톤 편집';

  @override
  String get milestoneSaveChanges => '변경사항 저장';

  @override
  String get milestoneUpdateError => '마일스톤을 수정할 수 없습니다.';

  @override
  String get milestoneClearStartDate => '시작일 지우기';

  @override
  String get milestoneClearDueDate => '마감일 지우기';

  @override
  String get milestoneClose => '마일스톤 닫기';

  @override
  String get milestoneReactivate => '마일스톤 다시 활성화';

  @override
  String get milestoneCloseConfirmTitle => '이 마일스톤을 닫을까요?';

  @override
  String get milestoneCloseConfirmBody => '나중에 다시 활성화할 수 있습니다.';

  @override
  String get milestoneStateError => '마일스톤 상태를 변경할 수 없습니다.';

  @override
  String get milestoneDelete => '마일스톤 삭제';

  @override
  String get milestoneDeleteConfirmTitle => '이 마일스톤을 삭제할까요?';

  @override
  String get milestoneDeleteConfirmBody => '이 작업은 되돌릴 수 없습니다.';

  @override
  String get milestoneDeleteError => '마일스톤을 삭제할 수 없습니다.';

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
  String get issueEditLabels => '라벨 수정';

  @override
  String get issueSaveLabels => '라벨 저장';

  @override
  String get issueLabelsEmpty => '사용 가능한 라벨이 없습니다';

  @override
  String get issueLabelsLoadError => '라벨을 불러올 수 없습니다.';

  @override
  String get issueLabelsSaveError => '라벨을 변경할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get issueEditDueDate => '마감일 수정';

  @override
  String get issueConfidential => '기밀';

  @override
  String get issueMakeConfidential => '기밀로 설정';

  @override
  String get issueRemoveConfidentiality => '기밀 해제';

  @override
  String get issueMakeConfidentialExplanation =>
      '이 이슈의 접근 권한이 제한됩니다. 계속하시겠습니까?';

  @override
  String get issueRemoveConfidentialityExplanation =>
      '프로젝트를 볼 수 있는 모든 사람에게 이 이슈가 표시됩니다. 계속하시겠습니까?';

  @override
  String get issueConfidentialityConfirm => '확인';

  @override
  String get issueConfidentialityError =>
      '기밀 상태를 변경할 수 없습니다. 권한을 확인하고 다시 시도하세요.';

  @override
  String get issueDiscussionLocked => '토론 잠김';

  @override
  String get issueLockDiscussion => '토론 잠그기';

  @override
  String get issueUnlockDiscussion => '토론 잠금 해제';

  @override
  String get issueLockDiscussionExplanation =>
      '프로젝트 멤버만 댓글을 추가하거나 수정할 수 있습니다. 계속하시겠습니까?';

  @override
  String get issueUnlockDiscussionExplanation =>
      '이 이슈에 접근할 수 있는 사용자가 다시 댓글을 남길 수 있습니다. 계속하시겠습니까?';

  @override
  String get issueDiscussionLockConfirm => '확인';

  @override
  String get issueDiscussionLockError =>
      '토론 잠금 상태를 변경할 수 없습니다. 권한을 확인하고 다시 시도하세요.';

  @override
  String get issueEditMilestone => '마일스톤 편집';

  @override
  String get issueEditAssignees => '담당자 편집';

  @override
  String get issueAssignees => '담당자';

  @override
  String get issueSaveAssignees => '담당자 저장';

  @override
  String get issueAssigneesSaveError => '담당자를 변경할 수 없습니다. 권한을 확인하고 다시 시도하세요.';

  @override
  String get issueNoMilestone => '마일스톤 없음';

  @override
  String get issueMilestonesLoadError => '마일스톤을 불러올 수 없습니다.';

  @override
  String get issueMilestoneSaveError => '마일스톤을 변경할 수 없습니다. 권한을 확인하고 다시 시도하세요.';

  @override
  String get issueDueDate => '마감일';

  @override
  String issueDueDateValue(String date) {
    return '마감일: $date';
  }

  @override
  String get issueSelectDueDate => '날짜 선택';

  @override
  String get issueClearDueDate => '마감일 지우기';

  @override
  String get issueDueDateError => '마감일을 변경할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get issueSaveChanges => '변경 사항 저장';

  @override
  String get issueEditError => '이슈를 저장할 수 없습니다. 권한을 확인하고 다시 시도하세요.';

  @override
  String get issueSubscribe => '알림 구독';

  @override
  String get issueUnsubscribe => '알림 구독 해제';

  @override
  String get issueSubscriptionError => '이슈 알림을 변경할 수 없습니다. 다시 시도하세요.';

  @override
  String get mrSubscribe => '알림 구독';

  @override
  String get mrUnsubscribe => '알림 구독 해제';

  @override
  String get mrSubscriptionError => '병합 요청 알림을 변경할 수 없습니다. 다시 시도하세요.';

  @override
  String get issueAddTodo => '할 일에 추가';

  @override
  String get issueTodoAdded => '할 일 목록에 추가했습니다.';

  @override
  String get issueTodoExists => '이 이슈는 이미 할 일 목록에 있습니다.';

  @override
  String get issueTodoError => '이슈를 할 일 목록에 추가할 수 없습니다. 다시 시도하세요.';

  @override
  String get mrAddTodo => '할 일에 추가';

  @override
  String get mrTodoAdded => '할 일 목록에 추가했습니다.';

  @override
  String get mrTodoExists => '이 병합 요청은 이미 할 일 목록에 있습니다.';

  @override
  String get mrTodoError => '병합 요청을 할 일 목록에 추가할 수 없습니다. 다시 시도하세요.';

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
  String get pipelinesLoadMore => '더 보기';

  @override
  String get pipelinesLoadMoreError => '파이프라인을 더 불러올 수 없습니다.';

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
  String get snippetNew => '새 스니펫';

  @override
  String get snippetTitleField => '제목';

  @override
  String get snippetDescriptionField => '설명';

  @override
  String get snippetFilePathField => '파일 경로';

  @override
  String get snippetContentField => '내용';

  @override
  String get snippetVisibilityField => '공개 범위';

  @override
  String get snippetVisibilityUnchanged => '현재 공개 범위 유지';

  @override
  String get snippetPrivate => '비공개';

  @override
  String get snippetPublic => '공개';

  @override
  String get snippetCreate => '스니펫 만들기';

  @override
  String get snippetCreateValidationError => '제목, 파일 경로, 내용을 입력하세요.';

  @override
  String get snippetCreateError => '스니펫을 만들 수 없습니다.';

  @override
  String get snippetAddFile => '파일 추가';

  @override
  String get snippetFileAddValidationError => '중복되지 않는 상대 파일 경로와 내용을 입력하세요.';

  @override
  String get snippetFileAddError => '파일을 추가할 수 없습니다.';

  @override
  String get snippetFileMoveAction => '파일 이동';

  @override
  String get snippetFileMoveTitle => '파일 이동 또는 이름 변경';

  @override
  String get snippetFileMovePathField => '새 파일 경로';

  @override
  String get snippetFileMoveValidationError => '중복되지 않는 다른 상대 파일 경로를 입력하세요.';

  @override
  String get snippetFileMoveError => '파일을 이동할 수 없습니다.';

  @override
  String get snippetEditAction => '스니펫 편집';

  @override
  String get snippetEditTitle => '스니펫 편집';

  @override
  String get snippetSaveChanges => '변경 사항 저장';

  @override
  String get snippetEditValidationError => '제목을 입력하세요.';

  @override
  String get snippetEditError => '스니펫을 저장할 수 없습니다.';

  @override
  String get snippetDeleteAction => '스니펫 삭제';

  @override
  String get snippetDeleteConfirmTitle => '이 스니펫을 삭제할까요?';

  @override
  String get snippetDeleteConfirmMessage => '스니펫과 파일이 영구적으로 삭제됩니다.';

  @override
  String get snippetDeleteButton => '삭제';

  @override
  String get snippetDeleteError => '스니펫을 삭제할 수 없습니다.';

  @override
  String get snippetFileDeleteAction => '파일 삭제';

  @override
  String get snippetFileDeleteConfirmTitle => '이 파일을 삭제할까요?';

  @override
  String get snippetFileDeleteConfirmMessage => '스니펫에서 이 파일만 영구적으로 삭제됩니다.';

  @override
  String get snippetFileDeleteError => '파일을 삭제할 수 없습니다.';

  @override
  String get snippetEditContent => '내용 편집';

  @override
  String get snippetSaveContent => '내용 저장';

  @override
  String get snippetContentSaveError => '스니펫 내용을 저장할 수 없습니다.';

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
  String get wikiNewPage => '새 페이지';

  @override
  String get wikiPagesSection => '페이지';

  @override
  String get wikiTemplatesSection => '템플릿';

  @override
  String get wikiTemplateEmpty => '아직 템플릿이 없습니다.';

  @override
  String get wikiNewTemplate => '새 템플릿';

  @override
  String get wikiTemplateTitle => '템플릿 제목';

  @override
  String get wikiCreateTemplate => '템플릿 만들기';

  @override
  String get wikiCreateTemplateError => '템플릿을 만들 수 없습니다.';

  @override
  String get wikiPageTitle => '제목';

  @override
  String get wikiPageContent => '내용';

  @override
  String get wikiCreatePage => '페이지 만들기';

  @override
  String get wikiChooseTemplate => '템플릿 선택';

  @override
  String get wikiReplaceTemplateContent => '현재 내용을 이 템플릿으로 바꾸시겠습니까?';

  @override
  String get wikiApplyTemplate => '템플릿 적용';

  @override
  String get wikiTemplateLoadError => '템플릿을 불러올 수 없습니다.';

  @override
  String get wikiCreateValidationError => '제목과 내용을 입력하세요.';

  @override
  String get wikiCreateError => '위키 페이지를 만들 수 없습니다.';

  @override
  String get wikiEditPageAction => '편집';

  @override
  String get wikiEditPage => '위키 페이지 편집';

  @override
  String get wikiEditTitle => '제목';

  @override
  String get wikiEditContent => '내용';

  @override
  String get wikiSaveChanges => '변경 사항 저장';

  @override
  String get wikiEditValidationError => '제목과 내용을 입력하세요.';

  @override
  String get wikiEditError => '위키 페이지를 저장할 수 없습니다.';

  @override
  String get wikiEditConflict =>
      'GitLab에서 이 페이지가 변경되었습니다. 다시 편집하기 전에 페이지를 새로고침하세요.';

  @override
  String get wikiDeletePageAction => '페이지 삭제';

  @override
  String get wikiDeleteConfirmTitle => '이 위키 페이지를 삭제할까요?';

  @override
  String get wikiDeleteConfirmMessage => '프로젝트 위키에서 이 페이지가 영구적으로 삭제됩니다.';

  @override
  String get wikiDeleteError => '위키 페이지를 삭제할 수 없습니다.';

  @override
  String get wikiDeleteConflict => '페이지가 변경되었습니다. 삭제하기 전에 새로고침하세요.';

  @override
  String get wikiReloadPage => '페이지 새로고침';

  @override
  String get packageRegistryTitle => '패키지 레지스트리';

  @override
  String get packageDelete => '패키지 삭제';

  @override
  String get packageDeleteConfirmTitle => '이 패키지를 삭제할까요?';

  @override
  String packageDeleteConfirmBody(String name) {
    return '$name 및 모든 파일을 삭제할까요? 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get packageDeleteForwardingWarning =>
      '요청 전달이 활성화된 경우, 이 패키지를 삭제하면 의존성 혼동 공격 위험이 생길 수 있습니다.';

  @override
  String get packageDeleteError => '이 패키지를 삭제할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get packageDeleteForbidden => '이 패키지가 보호되고 있거나 삭제 권한이 없을 수 있습니다.';

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

  @override
  String get protectedTagUnprotectTitle => '태그 보호 규칙 해제';

  @override
  String protectedTagUnprotectTarget(String projectId, String name) {
    return '프로젝트 $projectId — 규칙 $name';
  }

  @override
  String get protectedTagUnprotectWarning =>
      '저장소 태그 보호 규칙을 제거합니다. 태그는 삭제되지 않습니다. 와일드카드는 현재 및 향후 여러 태그에 영향을 줄 수 있습니다. 보호 해제로 더 많은 사용자가 일치하는 태그를 만들거나 삭제할 수 있으며 태그 파이프라인과 작업의 접근 권한도 바뀔 수 있습니다. 다른 일치 규칙이 태그를 계속 보호할 수 있으며 실제 접근 권한은 GitLab이 결정합니다. 아래의 현재 생성 권한을 검토하세요.';

  @override
  String protectedTagUnprotectAccess(
    String description,
    String role,
    String user,
    String group,
    String key,
  ) {
    return '$description\n역할 수준: $role; 사용자 ID: $user; 그룹 ID: $group; 배포 키 ID: $key';
  }

  @override
  String get protectedTagUnprotectUnreported => '보고되지 않음';

  @override
  String get protectedTagUnprotectName => '정확한 규칙 이름 또는 패턴을 다시 입력하세요';

  @override
  String get protectedTagUnprotectAcknowledge =>
      '이 규칙에 일치하는 모든 태그의 보호가 해제됨을 이해하며 이 규칙을 제거하겠습니다.';

  @override
  String get protectedTagUnprotectAuth => '세션이 거부되었습니다. 다시 로그인한 뒤 규칙을 검토하세요.';

  @override
  String get protectedTagUnprotectForbidden =>
      'GitLab이 보호 해제 권한을 거부했습니다. Maintainer 또는 Owner 역할이 필요합니다.';

  @override
  String get protectedTagUnprotectUnavailable =>
      '규칙이 없거나 비공개이거나 이 인스턴스에서 사용할 수 없습니다. 새로 불러와 확인하세요. 다른 규칙은 제거되지 않습니다.';

  @override
  String get protectedTagUnprotectStale =>
      '규칙이 변경되었습니다. 새로 불러와 현재 권한을 확인한 뒤 제거하세요.';

  @override
  String get protectedTagUnprotectRateLimited =>
      'GitLab이 요청 횟수를 제한하고 있습니다. 잠시 기다린 뒤 규칙을 다시 불러와 확인하세요.';

  @override
  String get protectedTagUnprotectError =>
      '요청 결과를 확인할 수 없습니다. 재시도 전에 규칙을 다시 불러와 확인하세요.';

  @override
  String get protectedTagUnprotectReload => '규칙 다시 불러오기';

  @override
  String get protectedTagUnprotectSessionChanged =>
      '계정이 변경되었습니다. 이 창을 닫고 다시 열어 현재 프로젝트를 검토하세요.';

  @override
  String get protectedTagUnprotectAccepted =>
      '태그 보호 규칙이 제거되었습니다. 태그는 삭제되지 않았습니다.';

  @override
  String get protectedBranchForcePushEditTitle => '강제 푸시 수정';

  @override
  String protectedBranchForcePushEditTarget(String project, String name) {
    return '프로젝트 $project: $name';
  }

  @override
  String get protectedBranchForcePushCurrentAllowed => '현재 강제 푸시가 허용됩니다.';

  @override
  String get protectedBranchForcePushCurrentBlocked => '현재 강제 푸시가 차단됩니다.';

  @override
  String get protectedBranchForcePushAllow => '강제 푸시 허용';

  @override
  String get protectedBranchForcePushSave => '설정 저장';

  @override
  String get protectedBranchForcePushEnableWarning =>
      '강제 푸시를 허용하면 일치하는 브랜치의 기록을 다시 쓸 수 있습니다. 와일드카드 규칙은 여러 브랜치에 영향을 줄 수 있습니다.';

  @override
  String get protectedBranchForcePushDisableWarning =>
      '강제 푸시를 차단하면 일치하는 브랜치에서 구성원의 작업 방식이 바뀝니다. 와일드카드 규칙은 여러 브랜치에 영향을 줄 수 있습니다.';

  @override
  String get protectedBranchForcePushAcknowledge =>
      '일치하는 브랜치에 미치는 이 변경의 영향을 이해했습니다.';

  @override
  String get protectedBranchForcePushReload => '규칙 다시 확인';

  @override
  String get protectedBranchForcePushSuccess => '강제 푸시 설정을 변경했습니다.';

  @override
  String get protectedBranchForcePushAuth => '이 규칙을 변경하려면 다시 로그인하세요.';

  @override
  String get protectedBranchForcePushForbidden => '이 규칙을 변경할 권한이 없습니다.';

  @override
  String get protectedBranchForcePushUnavailable =>
      '이 규칙을 더 이상 사용할 수 없습니다. 계속하기 전에 목록을 확인하세요.';

  @override
  String get protectedBranchForcePushStale => '규칙이 변경되었습니다. 계속하기 전에 다시 확인하세요.';

  @override
  String get protectedBranchForcePushRateLimited =>
      'GitLab에서 요청을 제한하고 있습니다. 다시 시도하기 전에 규칙을 확인하세요.';

  @override
  String get protectedBranchForcePushError =>
      '변경을 확인할 수 없습니다. 다시 시도하기 전에 규칙을 확인하세요.';

  @override
  String get protectedBranchForcePushSessionChanged =>
      '계정이 변경되었습니다. 대화상자를 닫고 규칙을 다시 여세요.';

  @override
  String get protectedBranchMergeRoleEditTitle => '병합 권한 편집';

  @override
  String protectedBranchMergeRoleTarget(String project, String name) {
    return '프로젝트 $project: $name';
  }

  @override
  String protectedBranchMergeRoleCurrent(String role) {
    return '현재 병합 권한: $role';
  }

  @override
  String get protectedBranchMergeRoleNone => '없음';

  @override
  String get protectedBranchMergeRoleDeveloper => '개발자 및 유지 관리자';

  @override
  String get protectedBranchMergeRoleMaintainer => '유지 관리자';

  @override
  String get protectedBranchMergeRoleWarning =>
      '병합 권한을 변경하면 이 규칙과 일치하는 모든 브랜치에 영향을 줍니다. 와일드카드는 여러 브랜치와 병합 요청 작업에 영향을 줄 수 있습니다.';

  @override
  String get protectedBranchMergeRoleAcknowledge =>
      '일치하는 브랜치의 병합 권한 변경을 이해했습니다.';

  @override
  String get protectedBranchMergeRoleSave => '병합 권한 저장';

  @override
  String get protectedBranchMergeRoleReload => '규칙 다시 확인';

  @override
  String get protectedBranchMergeRoleSuccess => '병합 권한을 변경했습니다.';

  @override
  String get protectedBranchMergeRoleAuth => '규칙을 변경하려면 다시 로그인하세요.';

  @override
  String get protectedBranchMergeRoleForbidden => '병합 권한을 변경할 권한이 없습니다.';

  @override
  String get protectedBranchMergeRoleUnavailable =>
      '이 규칙을 더 이상 사용할 수 없습니다. 계속하기 전에 목록을 확인하세요.';

  @override
  String get protectedBranchMergeRoleStale => '규칙이 변경되었습니다. 계속하기 전에 다시 확인하세요.';

  @override
  String get protectedBranchMergeRoleRateLimited =>
      'GitLab이 요청을 제한하고 있습니다. 다시 시도하기 전에 규칙을 확인하세요.';

  @override
  String get protectedBranchMergeRoleError =>
      '변경 결과를 확인할 수 없습니다. 다시 시도하기 전에 규칙을 확인하세요.';

  @override
  String get protectedBranchMergeRoleSessionChanged =>
      '계정이 변경되었습니다. 대화상자를 닫고 규칙을 다시 여세요.';

  @override
  String get protectedBranchPushRoleEditTitle => '푸시 권한 편집';

  @override
  String protectedBranchPushRoleTarget(String project, String name) {
    return '프로젝트 $project: $name';
  }

  @override
  String protectedBranchPushRoleCurrent(String role) {
    return '현재 푸시 권한: $role';
  }

  @override
  String get protectedBranchPushRoleNone => '없음';

  @override
  String get protectedBranchPushRoleDeveloper => '개발자 및 유지 관리자';

  @override
  String get protectedBranchPushRoleMaintainer => '유지 관리자';

  @override
  String get protectedBranchPushRoleWarning =>
      '푸시 권한을 변경하면 이 규칙과 일치하는 모든 브랜치에 영향을 줍니다. 직접 커밋할 수 있는 사람이 달라지고, 강제 푸시가 허용된 경우 기록을 다시 쓸 수 있는 사람도 달라질 수 있습니다. 와일드카드는 여러 브랜치에 영향을 줄 수 있습니다.';

  @override
  String get protectedBranchPushRoleAcknowledge =>
      '일치하는 브랜치의 푸시 권한 변경을 이해했습니다.';

  @override
  String get protectedBranchPushRoleSave => '푸시 권한 저장';

  @override
  String get protectedBranchPushRoleReload => '규칙 다시 확인';

  @override
  String get protectedBranchPushRoleSuccess => '푸시 권한을 변경했습니다.';

  @override
  String get protectedBranchPushRoleAuth => '규칙을 변경하려면 다시 로그인하세요.';

  @override
  String get protectedBranchPushRoleForbidden => '푸시 권한을 변경할 권한이 없습니다.';

  @override
  String get protectedBranchPushRoleUnavailable =>
      '이 규칙을 더 이상 사용할 수 없습니다. 계속하기 전에 목록을 확인하세요.';

  @override
  String get protectedBranchPushRoleStale => '규칙이 변경되었습니다. 계속하기 전에 다시 확인하세요.';

  @override
  String get protectedBranchPushRoleRateLimited =>
      'GitLab이 요청을 제한하고 있습니다. 다시 시도하기 전에 규칙을 확인하세요.';

  @override
  String get protectedBranchPushRoleError =>
      '변경 결과를 확인할 수 없습니다. 다시 시도하기 전에 규칙을 확인하세요.';

  @override
  String get protectedBranchPushRoleSessionChanged =>
      '계정이 변경되었습니다. 대화상자를 닫고 규칙을 다시 여세요.';

  @override
  String get protectedEnvironmentCreateTitle => '환경 보호';

  @override
  String get protectedEnvironmentCreateName => '환경 이름';

  @override
  String get protectedEnvironmentCreateDeveloper => '개발자 + 유지관리자';

  @override
  String get protectedEnvironmentCreateMaintainer => '유지관리자';

  @override
  String get protectedEnvironmentCreateWarning =>
      '이 보호 규칙은 지정한 환경에 배포할 수 있는 사람을 변경합니다. 승인 규칙은 추가되지 않습니다.';

  @override
  String get protectedEnvironmentCreateAcknowledge => '배포 권한 변경을 이해했습니다.';

  @override
  String get protectedEnvironmentCreateSave => '환경 보호';

  @override
  String get protectedEnvironmentCreateReload => '환경 목록 다시 확인';

  @override
  String get protectedEnvironmentCreateDuplicate =>
      '이 환경은 이미 보호되어 있습니다. 계속하기 전에 목록을 확인하세요.';

  @override
  String get protectedEnvironmentCreateError =>
      '보호 설정을 확인할 수 없습니다. 다시 시도하기 전에 목록을 확인하세요.';

  @override
  String get protectedEnvironmentCreateForbidden => '권한이 없거나 이 기능을 사용할 수 없습니다.';

  @override
  String get protectedEnvironmentCreateSessionChanged =>
      '계정이 변경되었습니다. 대화상자를 닫고 다시 여세요.';

  @override
  String get protectedEnvironmentCreateSuccess => '환경이 보호되었습니다.';

  @override
  String get protectedEnvironmentCreateInvalidName =>
      '와일드카드가 없는 정확한 환경 이름을 입력하세요.';

  @override
  String get protectedEnvironmentRemoveRoleTitle => '배포 역할 제거';

  @override
  String get protectedEnvironmentRemoveRoleWarning =>
      '이 권한을 제거하면 선택한 역할이 배포하지 못할 수 있습니다. 다른 배포 권한과 승인 규칙은 유지되며 환경은 계속 보호됩니다.';

  @override
  String get protectedEnvironmentRemoveRoleAcknowledge =>
      '선택한 배포 권한이 제거되는 것을 이해했습니다.';

  @override
  String get protectedEnvironmentRemoveRoleSuccess => '배포 역할이 제거되었습니다.';

  @override
  String get protectedEnvironmentRemoveRoleForbidden =>
      '이 배포 권한을 제거할 권한이 없습니다.';

  @override
  String get protectedEnvironmentRemoveRoleError =>
      '배포 권한 제거를 확인할 수 없습니다. 다시 시도하기 전에 규칙을 확인하세요.';

  @override
  String protectedEnvironmentRemoveRoleGrantLabel(String role, String id) {
    return '$role (권한 $id)';
  }

  @override
  String get protectedEnvironmentDeployRoleTitle => '배포 역할 추가';

  @override
  String get protectedEnvironmentDeployRoleWarning =>
      '선택한 역할에 배포 권한이 부여됩니다. 기존 배포 권한과 승인 규칙은 유지됩니다.';

  @override
  String get protectedEnvironmentDeployRoleAcknowledge =>
      '배포 권한이 확대되는 것을 이해했습니다.';

  @override
  String get protectedEnvironmentDeployRoleSuccess => '배포 역할이 추가되었습니다.';

  @override
  String get protectedEnvironmentDeployRoleForbidden => '배포 권한을 변경할 권한이 없습니다.';

  @override
  String get protectedEnvironmentDeployRoleError =>
      '배포 역할 변경을 확인할 수 없습니다. 다시 시도하기 전에 규칙을 확인하세요.';

  @override
  String get protectedEnvironmentUnprotectTitle => '환경 보호 해제';

  @override
  String protectedEnvironmentUnprotectTarget(String project, String name) {
    return '프로젝트 $project: $name';
  }

  @override
  String get protectedEnvironmentUnprotectWarning =>
      '이 프로젝트 보호 규칙을 해제하면 아래의 모든 배포 허용 항목과 승인 규칙이 제거됩니다. 환경과 이전 배포는 유지됩니다. 그룹 보호 규칙은 계속 적용될 수 있습니다.';

  @override
  String get protectedEnvironmentUnprotectName => '정확한 환경 이름 입력';

  @override
  String get protectedEnvironmentUnprotectAcknowledge =>
      '이 배포 제한과 승인 규칙이 제거됨을 이해했습니다.';

  @override
  String get protectedEnvironmentUnprotectReload => '규칙 다시 확인';

  @override
  String get protectedEnvironmentUnprotectAuth => '규칙을 변경하기 전에 다시 로그인하세요.';

  @override
  String get protectedEnvironmentUnprotectForbidden =>
      '이 환경의 보호를 해제할 권한이 없습니다.';

  @override
  String get protectedEnvironmentUnprotectUnavailable =>
      '이 규칙을 더 이상 사용할 수 없습니다. 계속하기 전에 목록을 확인하세요.';

  @override
  String get protectedEnvironmentUnprotectStale =>
      '규칙이 변경되었습니다. 계속하기 전에 다시 확인하세요.';

  @override
  String get protectedEnvironmentUnprotectRateLimited =>
      'GitLab에서 요청을 제한하고 있습니다. 다시 시도하기 전에 규칙을 확인하세요.';

  @override
  String get protectedEnvironmentUnprotectError =>
      '보호 해제를 확인할 수 없습니다. 다시 시도하기 전에 규칙을 확인하세요.';

  @override
  String get protectedEnvironmentUnprotectSessionChanged =>
      '계정이 변경되었습니다. 대화상자를 닫고 규칙을 다시 여세요.';

  @override
  String get protectedEnvironmentUnprotectSuccess => '환경 보호가 해제되었습니다.';

  @override
  String get protectedEnvironmentUnprotectUnreported => '접근 항목';

  @override
  String get containerPolicyStatus => '상태';

  @override
  String get containerPolicyEnabled => '활성화';

  @override
  String get containerPolicyDisabled => '비활성화';

  @override
  String get containerPolicyNotReported => '보고되지 않음';

  @override
  String get containerPolicyCadence => '실행 주기';

  @override
  String get containerPolicyKeepCount => '이미지당 보존할 일치 태그 개수';

  @override
  String get containerPolicyAge => '제거할 태그의 최소 나이';

  @override
  String get containerPolicyDeletePattern => '삭제 패턴';

  @override
  String get containerPolicyLegacyPattern => '삭제 패턴 (구형)';

  @override
  String get containerPolicyKeepPattern => '보존 패턴';

  @override
  String get containerPolicyEmptyPattern => '빈 패턴';

  @override
  String get containerPolicyError => '정리 정책을 불러오지 못했습니다.';

  @override
  String get containerPolicyForbidden => '이 프로젝트의 정리 정책을 볼 권한이 없습니다.';

  @override
  String get containerPolicyUnavailable =>
      '프로젝트에 접근할 수 없거나 정리 정책 정보를 사용할 수 없습니다.';

  @override
  String get containerPolicyEmptySetting => '빈 설정값';

  @override
  String containerActivationTarget(String projectId) {
    return '프로젝트 $projectId — 모든 이미지 저장소';
  }

  @override
  String get containerActivationError => '변경을 확인하지 못했습니다. 정책을 다시 불러오고 재시도하세요.';

  @override
  String get containerActivationForbidden => '이 정리 정책을 변경할 권한이 없습니다.';

  @override
  String get containerActivationStale =>
      '정책이 변경되었거나 더 이상 보고되지 않습니다. 저장하기 전에 다시 불러와 확인하세요.';

  @override
  String get containerActivationReload => '정책 다시 불러오기';

  @override
  String get containerActivationRateLimited =>
      '요청이 너무 많습니다. 잠시 기다린 후 정책을 다시 불러와 재시도하세요.';

  @override
  String get containerCadenceTitle => '정리 주기 편집';

  @override
  String get containerCadenceSave => '주기 변경 확인';

  @override
  String get containerCadenceSelect => '새 주기 (GitLab API 간격)';

  @override
  String get containerCadenceWarning =>
      '프로젝트 전체 주기를 변경하면 모든 이미지 저장소의 향후 예약된 태그 정리에 영향을 줍니다. 아래 활성화 상태와 삭제·보관 기준을 확인하세요. 해당 설정은 변경되지 않으며 정리 완료를 의미하지 않습니다.';

  @override
  String get containerCadenceUnknown =>
      '활성화 상태, 주기, 보관 개수·기간, 삭제 패턴이 보고되어야 합니다. 누락된 설정을 GitLab에서 확인하세요. 정책을 새로 만들지 않습니다.';

  @override
  String get containerCadenceAccepted => '정리 주기 변경 요청이 수락되었습니다.';

  @override
  String get containerTagProtectionTitle => '태그 보호 규칙';

  @override
  String get containerTagProtectionEmpty => '태그 보호 규칙이 없습니다.';

  @override
  String get containerTagProtectionError => '태그 보호 규칙을 불러오지 못했습니다.';

  @override
  String get containerTagProtectionForbidden => '태그 보호 규칙을 볼 권한이 없습니다.';

  @override
  String get containerTagProtectionUnavailable =>
      '이 인스턴스에서 태그 보호 규칙을 사용할 수 없거나 프로젝트에 접근할 수 없습니다.';

  @override
  String containerTagProtectionPushRole(String role) {
    return '푸시 최소 역할: $role';
  }

  @override
  String containerTagProtectionDeleteRole(String role) {
    return '삭제 최소 역할: $role';
  }

  @override
  String get containerTagProtectionRoleUnset => '규칙에 지정되지 않음';

  @override
  String get containerTagProtectionRoleAdmin => '관리자';

  @override
  String get containerTagProtectionHint =>
      'Git 태그가 아닌 컨테이너 이미지 태그 규칙입니다. 최소 역할은 현재 접근 권한을 보장하지 않습니다. 조회에는 GitLab 18.7 이상, 수정에는 18.9 이상이 필요합니다.';

  @override
  String get containerTagProtectionPatternTitle => '태그 보호 패턴 수정';

  @override
  String get containerTagProtectionPatternSave => '패턴 저장';

  @override
  String get containerTagProtectionPatternWarning =>
      '패턴을 변경하면 프로젝트에서 기존에 일치하던 컨테이너 이미지 태그의 보호가 해제되고 다른 태그에 적용될 수 있습니다. 와일드카드(*)는 여러 태그에 영향을 줍니다. 두 최소 역할은 유지되며 다른 규칙과 권한도 계속 적용됩니다. 태그나 이미지를 삭제하거나 Git 태그에 영향을 주지 않으며 현재 접근 권한을 나타내지 않습니다.';

  @override
  String get containerTagProtectionPatternAcknowledge =>
      '현재 규칙과 새 패턴을 검토했으며 보호 변경을 이해했습니다.';

  @override
  String containerTagProtectionPatternTarget(String projectId, String ruleId) {
    return '프로젝트 $projectId — 규칙 $ruleId';
  }

  @override
  String get containerTagProtectionPatternForbidden => '이 규칙을 변경할 권한이 없습니다.';

  @override
  String get containerTagProtectionPatternError =>
      '패턴 변경을 확인할 수 없습니다. 서버에서 요청을 처리했을 수 있으니 재시도 전에 규칙 목록을 확인하세요.';

  @override
  String get containerTagProtectionPatternStale =>
      '확인 후 규칙이 변경되었습니다. 저장 전에 다시 불러와 검토하세요.';

  @override
  String get containerTagProtectionPatternReload => '규칙 다시 불러오기';

  @override
  String get containerTagProtectionPatternSaved => '태그 보호 패턴을 변경했습니다.';

  @override
  String get containerTagProtectionPatternMissing =>
      '규칙이 없거나 중복되거나 접근할 수 없거나 지원되지 않습니다. 수정에는 GitLab 18.9 이상이 필요합니다. 다시 불러와 확인하세요.';

  @override
  String get containerTagProtectionPatternRateLimited =>
      '요청이 너무 많습니다. 잠시 후 다시 시도하세요.';

  @override
  String get containerTagProtectionPatternInvalid =>
      '패턴이 거부되었거나 이미 사용 중입니다. 초안을 수정하고 다시 시도하세요.';

  @override
  String get containerTagProtectionPatternDraft => '새 컨테이너 태그 패턴';

  @override
  String get containerTagDelete => '태그 삭제';

  @override
  String get containerTagDeleteConfirmTitle => '컨테이너 태그를 삭제할까요?';

  @override
  String containerTagDeleteConfirmBody(String tagName, String path) {
    return '“$path”의 “$tagName” 태그를 삭제할까요? 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get containerTagDeleteWarning =>
      '태그만 삭제되며 이미지 블롭은 삭제되지 않습니다. 태그를 삭제해도 디스크 공간은 확보되지 않습니다.';

  @override
  String get containerTagDeleteForbidden =>
      '이 태그를 삭제할 수 없습니다. 보호된 태그이거나 권한이 없을 수 있습니다.';

  @override
  String get containerTagDeleteError => '태그를 삭제할 수 없습니다. 다시 시도하세요.';

  @override
  String get containerImmutabilityTitle => '불변 태그 규칙';

  @override
  String get containerImmutabilityEmpty => '불변 태그 규칙이 없습니다.';

  @override
  String get containerImmutabilityError =>
      '불변 태그 규칙을 불러오지 못했습니다. 인스턴스 지원 여부를 확인하고 다시 시도하세요.';

  @override
  String get containerImmutabilityForbidden => '불변 태그 규칙을 볼 권한이 없습니다.';

  @override
  String get containerImmutabilityUnavailable =>
      '프로젝트 또는 규칙 목록을 사용할 수 없습니다. 접근 권한, 구독 및 인스턴스 지원 여부를 확인하세요.';

  @override
  String get containerImmutabilityHint =>
      '불변 태그에는 Ultimate와 지원되는 레지스트리가 필요합니다. 이 패턴은 프로젝트의 모든 컨테이너 저장소에 적용되며 정리 정책을 포함하여 일치하는 태그의 덮어쓰기와 삭제를 방지합니다. 규칙 조회만으로 개별 태그의 현재 보호 상태를 확인할 수 없습니다. 변경 사항이 반영되기까지 시간이 걸릴 수 있습니다.';

  @override
  String get containerImmutabilityCreateTitle => 'Immutable 규칙 생성';

  @override
  String get containerImmutabilityCreateButton => '규칙 생성';

  @override
  String get containerImmutabilityCreated => 'Immutable 규칙을 생성했습니다.';

  @override
  String get containerImmutabilityPattern => '태그 패턴';

  @override
  String get containerImmutabilityPatternHint =>
      '100자 이내의 RE2 패턴을 입력하세요. 공백은 유지되며 문법은 GitLab이 검증합니다.';

  @override
  String containerImmutabilityProject(String projectId) {
    return '프로젝트 $projectId';
  }

  @override
  String get containerImmutabilityImpact =>
      'Owner 권한, Ultimate 및 지원되는 레지스트리가 필요합니다. 이 패턴은 프로젝트의 모든 컨테이너 저장소에 적용됩니다. 일치하는 태그는 정리 정책을 포함하여 덮어쓰거나 삭제할 수 없습니다. Immutable 규칙이 하나라도 있으면 매니페스트 직접 삭제도 차단됩니다. 규칙은 수정할 수 없으며 변경 적용에 시간이 걸릴 수 있습니다.';

  @override
  String get containerImmutabilityAcknowledge =>
      '프로젝트 전체의 보호 및 워크플로 영향을 이해했습니다.';

  @override
  String get containerImmutabilityUncertain =>
      '생성 결과를 확인하지 못했습니다. 요청이 이미 성공했을 수 있으므로 재시도 전에 현재 규칙을 확인하세요.';

  @override
  String get containerImmutabilityInspect => '현재 규칙 확인';

  @override
  String get containerImmutabilityRejected =>
      'GitLab이 요청을 거부했거나 같은 패턴의 Immutable 규칙이 이미 있습니다. 현재 규칙, 패턴 및 프로젝트 제한을 확인하세요.';

  @override
  String get containerImmutabilityAuth => '세션이 거부되었습니다. 규칙 생성 전에 다시 로그인하세요.';

  @override
  String get containerImmutabilityAccountChanged =>
      '계정이 변경되었습니다. 대화상자를 닫고 선택한 계정에서 다시 여세요.';

  @override
  String containerTagProtectionPushClearTarget(
    String projectId,
    String ruleId,
  ) {
    return '프로젝트 $projectId — 규칙 $ruleId';
  }

  @override
  String get containerTagProtectionPushClearForbidden => '이 규칙을 변경할 권한이 없습니다.';

  @override
  String get containerTagProtectionPushClearStale =>
      '확인 이후 규칙이 변경되었습니다. 다시 불러와 검토한 뒤 저장하세요.';

  @override
  String get containerTagProtectionPushClearReload => '규칙 다시 불러오기';

  @override
  String get containerTagProtectionPushClearMissing =>
      '규칙이 없거나 중복되거나 접근할 수 없거나 지원되지 않습니다. 수정에는 GitLab 18.9 이상이 필요합니다. 다시 불러와 확인하세요.';

  @override
  String get containerTagProtectionPushClearRateLimited =>
      '요청이 너무 많습니다. 잠시 기다린 후 다시 시도하세요.';

  @override
  String get containerTagProtectionPushClearTitle => '최소 푸시 역할 해제';

  @override
  String get containerTagProtectionPushClearSave => '푸시 제한 해제';

  @override
  String get containerTagProtectionPushClearWarning =>
      '이 규칙의 최소 푸시 역할 제한을 해제하면 프로젝트에서 일치하는 컨테이너 이미지 태그의 푸시 보호가 약해집니다. 태그 패턴과 최소 삭제 역할은 유지되며 다른 규칙과 권한도 계속 적용됩니다. 모든 사용자에게 접근 권한을 부여하거나 태그 또는 이미지를 삭제하지 않으며 Git 태그에는 영향을 주지 않습니다.';

  @override
  String get containerTagProtectionPushClearAcknowledge =>
      '규칙을 검토했으며 이 푸시 제한 해제의 영향을 이해했습니다.';

  @override
  String get containerTagProtectionPushClearError =>
      '푸시 제한 해제를 확인하지 못했습니다. 재시도 전에 규칙 목록을 확인하세요. 서버가 요청을 수락했을 수 있습니다.';

  @override
  String get containerTagProtectionPushClearSaved => '최소 푸시 역할 제한이 해제되었습니다.';

  @override
  String get containerTagProtectionPushClearInvalid =>
      '서버가 푸시 제한 해제를 거부했습니다. 규칙을 확인하고 다시 시도하세요.';

  @override
  String get containerTagProtectionPushClearBlocked =>
      '해제하려면 지원되는 현재 푸시 역할과 비어 있지 않은 삭제 역할이 필요합니다. 이미 해제되었거나 알 수 없는 설정은 해제할 수 없습니다.';

  @override
  String get packageFileDelete => '파일 삭제';

  @override
  String get packageFileDeleteConfirmTitle => '패키지 파일을 삭제할까요?';

  @override
  String packageFileDeleteConfirmBody(String fileName, String packageName) {
    return '“$packageName”에서 “$fileName”을 삭제할까요? 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get packageFileDeleteWarning =>
      '파일을 삭제하면 패키지가 손상되어 사용할 수 없거나 패키지 관리자로 가져올 수 없게 될 수 있습니다.';

  @override
  String get packageFileDeleteForbidden =>
      '이 파일을 삭제할 수 없습니다. 패키지가 보호되어 있거나 권한이 없을 수 있습니다.';

  @override
  String get packageFileDeleteError => '파일을 삭제할 수 없습니다. 다시 시도하세요.';

  @override
  String get containerRepositoryDelete => '저장소 삭제';

  @override
  String get containerRepositoryDeleteConfirmTitle => '이미지 저장소를 삭제할까요?';

  @override
  String containerRepositoryDeleteConfirmBody(String path) {
    return '“$path”와 모든 태그를 삭제할까요? 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get containerRepositoryDeleteWarning =>
      '삭제는 비동기로 예약되며 시간이 걸릴 수 있습니다. 레지스트리를 새로고침해 진행 상태를 확인하세요.';

  @override
  String get containerRepositoryDeleteForbidden =>
      '이 저장소를 삭제할 수 없습니다. 권한과 보호 규칙을 확인하세요.';

  @override
  String get containerRepositoryDeleteError => '저장소 삭제를 예약할 수 없습니다. 다시 시도하세요.';

  @override
  String get containerRepositoryDeletionScheduled => '삭제 예약됨';

  @override
  String get containerRepositoryDeletionNotice =>
      '저장소 삭제가 예약되었습니다. 새로고침해 진행 상태를 확인하세요.';
}
