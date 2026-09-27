// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get protectedTagsTitle => '保護されたタグ';

  @override
  String get protectedTagsEmpty => '保護タグのルールがありません。';

  @override
  String get protectedTagsError => '保護されたタグを読み込めませんでした。';

  @override
  String get protectedTagsLoadMore => 'さらに表示';

  @override
  String get protectedTagCreateAccess => '作成権限';

  @override
  String get protectedEnvironmentsTitle => '保護された環境';

  @override
  String get protectedEnvironmentsEmpty => '保護環境のルールがありません。';

  @override
  String get protectedEnvironmentsError => '保護された環境を読み込めませんでした。';

  @override
  String get protectedEnvironmentsUnavailable => '保護環境を利用できないか、アクセス権がありません。';

  @override
  String get protectedEnvironmentsLoadMore => 'さらに表示';

  @override
  String get protectedEnvironmentDeployAccess => 'デプロイ権限';

  @override
  String get protectedEnvironmentApprovalRules => '承認ルール';

  @override
  String protectedEnvironmentApprovalCount(int count) {
    return '必要な承認数: $count';
  }

  @override
  String get protectedBranchesTitle => '保護されたブランチ';

  @override
  String get protectedBranchesEmpty => '保護ブランチのルールがありません。';

  @override
  String get protectedBranchesError => '保護されたブランチを読み込めませんでした。';

  @override
  String get protectedBranchesLoadMore => 'さらに表示';

  @override
  String get protectedBranchPushAccess => 'プッシュ権限';

  @override
  String get protectedBranchMergeAccess => 'マージ権限';

  @override
  String get protectedBranchForcePush => '強制プッシュ';

  @override
  String get protectedBranchCodeOwnerApproval => 'コードオーナーの承認';

  @override
  String get protectedBranchInherited => 'グループから継承';

  @override
  String get protectedBranchEnabled => '有効';

  @override
  String get protectedBranchDisabled => '無効';

  @override
  String get protectedBranchNoAccess => '権限ルールなし';

  @override
  String get linkedIssuesTitle => '関連するイシュー';

  @override
  String get linkedIssuesError => '関連するイシューを読み込めませんでした。';

  @override
  String get linkedIssuesLoadMore => 'さらに表示';

  @override
  String get linkedIssuesRelatesTo => '関連あり';

  @override
  String get linkedIssuesBlocks => 'ブロックする';

  @override
  String get linkedIssuesBlockedBy => 'ブロックされる';

  @override
  String get groupLabelsTitle => 'グループラベル';

  @override
  String get groupLabelsEmpty => 'グループラベルはまだありません';

  @override
  String get groupLabelsError => 'グループラベルを読み込めませんでした。';

  @override
  String get groupMembersTitle => 'グループメンバー';

  @override
  String get groupMembersSearch => 'グループメンバーを検索';

  @override
  String get groupMembersEmpty => 'グループメンバーが見つかりません。';

  @override
  String get groupMembersError => 'グループメンバーを読み込めませんでした。';

  @override
  String get pipelineSchedulesTitle => 'パイプラインスケジュール';

  @override
  String get pipelineSchedulesAll => 'すべて';

  @override
  String get pipelineSchedulesActive => '有効';

  @override
  String get pipelineSchedulesInactive => '無効';

  @override
  String get pipelineSchedulesEmpty => 'パイプラインスケジュールがありません。';

  @override
  String get pipelineSchedulesError => 'パイプラインスケジュールを読み込めませんでした。';

  @override
  String get pipelineSchedulesLoadMore => 'さらに読み込む';

  @override
  String get pipelineScheduleDetailError => 'このスケジュールを読み込めませんでした。';

  @override
  String pipelineScheduleNextRun(String date) {
    return '次の実行: $date';
  }

  @override
  String get pipelineScheduleNextRunLabel => '次の実行';

  @override
  String get pipelineScheduleRef => '参照';

  @override
  String get pipelineScheduleCron => 'スケジュール';

  @override
  String get pipelineScheduleTimezone => 'タイムゾーン';

  @override
  String get pipelineScheduleOwner => '所有者';

  @override
  String get pipelineScheduleRunNow => '今すぐ実行';

  @override
  String get pipelineScheduleRunSuccess => 'パイプラインスケジュールを開始しました。';

  @override
  String get pipelineScheduleRunError => 'スケジュールを実行できませんでした。';

  @override
  String get pipelineScheduleLastPipeline => '前回のパイプライン';

  @override
  String pipelineSchedulePipelineNumber(int number) {
    return 'パイプライン #$number';
  }

  @override
  String get deploymentsTitle => 'デプロイ';

  @override
  String get deploymentsAll => 'すべて';

  @override
  String get deploymentsSuccess => '成功';

  @override
  String get deploymentsFailed => '失敗';

  @override
  String get deploymentsRunning => '実行中';

  @override
  String get deploymentsCanceled => 'キャンセル';

  @override
  String get deploymentsCreated => '作成済み';

  @override
  String get deploymentsBlocked => 'ブロック';

  @override
  String get deploymentsUnknownStatus => '不明な状態';

  @override
  String get deploymentsEmpty => 'デプロイはありません。';

  @override
  String get deploymentsError => 'デプロイを読み込めませんでした。';

  @override
  String get deploymentsLoadMore => 'さらに読み込む';

  @override
  String get deploymentsEnvironmentSearch => '環境名で絞り込み';

  @override
  String get deploymentsUnknownEnvironment => '不明な環境';

  @override
  String get deploymentDetailError => 'このデプロイを読み込めませんでした。';

  @override
  String deploymentNumber(int number) {
    return 'デプロイ #$number';
  }

  @override
  String get deploymentEnvironment => '環境';

  @override
  String get deploymentRef => '参照';

  @override
  String get deploymentCommit => 'コミット';

  @override
  String get deploymentJob => 'ジョブ';

  @override
  String get deploymentPipeline => 'パイプライン';

  @override
  String get deploymentCreatedAt => '作成日時';

  @override
  String get deploymentUpdatedAt => '更新日時';

  @override
  String get deploymentUser => 'デプロイ担当';

  @override
  String get releasesTitle => 'リリース';

  @override
  String get releasesEmpty => 'リリースはまだありません。';

  @override
  String get releasesError => 'リリースを読み込めませんでした。';

  @override
  String get releaseDetailError => 'このリリースを読み込めませんでした。';

  @override
  String get releaseAssetsTitle => 'アセット';

  @override
  String get releaseLoadMore => 'さらに読み込む';

  @override
  String get releaseUpcoming => '予定';

  @override
  String get activityTitle => 'アクティビティ';

  @override
  String get activityAll => 'すべて';

  @override
  String get activityIssues => '課題';

  @override
  String get activityMergeRequests => 'マージリクエスト';

  @override
  String get activityEmpty => '最近のアクティビティはありません。';

  @override
  String get activityError => 'プロジェクトのアクティビティを読み込めませんでした。';

  @override
  String get activityLoadMore => 'さらに表示';

  @override
  String get activityUnknownActor => '不明なユーザー';

  @override
  String get activityPush => 'プッシュ';

  @override
  String get activityEvent => 'プロジェクトのアクティビティ';

  @override
  String activityBy(String actor, String action) {
    return '$actorが$action';
  }

  @override
  String get environmentsTitle => '環境';

  @override
  String get environmentsAll => 'すべて';

  @override
  String get environmentsAvailable => '利用可能';

  @override
  String get environmentsStopping => '停止中';

  @override
  String get environmentsStopped => '停止済み';

  @override
  String get environmentsSearch => '環境を検索';

  @override
  String get environmentsSearchLength => '3文字以上入力してください。';

  @override
  String get environmentsEmpty => '環境が見つかりません。';

  @override
  String get environmentsError => '環境を読み込めませんでした。';

  @override
  String get environmentsLoadMore => 'さらに表示';

  @override
  String get environmentDetailError => 'この環境を読み込めませんでした。';

  @override
  String get environmentAutoStop => '自動停止';

  @override
  String get environmentOpenUrl => '環境を開く';

  @override
  String get environmentLatestDeployment => '最新のデプロイ';

  @override
  String get environmentUnknownStatus => '不明な状態';

  @override
  String get projectMembersTitle => 'メンバー';

  @override
  String get projectMembersSearch => 'メンバーを検索';

  @override
  String get projectMembersClearSearch => '検索をクリア';

  @override
  String get projectMembersEmpty => 'メンバーが見つかりません。';

  @override
  String get projectMembersError => 'メンバーを読み込めませんでした。';

  @override
  String get projectMembersLoadMore => 'さらに読み込む';

  @override
  String get projectMembersExpiry => '有効期限';

  @override
  String get memberRoleNoAccess => 'アクセスなし';

  @override
  String get memberRoleMinimal => '最小アクセス';

  @override
  String get memberRoleGuest => 'ゲスト';

  @override
  String get memberRolePlanner => 'プランナー';

  @override
  String get memberRoleReporter => 'レポーター';

  @override
  String get memberRoleSecurityManager => 'セキュリティマネージャー';

  @override
  String get memberRoleDeveloper => 'デベロッパー';

  @override
  String get memberRoleMaintainer => 'メンテナー';

  @override
  String get memberRoleOwner => 'オーナー';

  @override
  String get memberRoleUnknown => '不明なロール';

  @override
  String get containerRegistryTitle => 'コンテナレジストリ';

  @override
  String get containerRegistryEmpty => 'コンテナイメージはまだありません。';

  @override
  String get containerRegistryError => 'コンテナイメージを読み込めませんでした。';

  @override
  String get containerTagsTitle => 'イメージタグ';

  @override
  String get containerTagsEmpty => 'タグはまだありません。';

  @override
  String get containerTagsError => 'イメージタグを読み込めませんでした。';

  @override
  String get containerTagError => 'このタグを読み込めませんでした。';

  @override
  String get containerTagDigest => 'ダイジェスト';

  @override
  String get containerTagRevision => 'リビジョン';

  @override
  String get containerTagSize => 'サイズ（バイト）';

  @override
  String get containerLoadMore => 'さらに読み込む';

  @override
  String get milestonesTitle => 'マイルストーン';

  @override
  String get milestonesActive => '進行中';

  @override
  String get milestonesClosed => '終了';

  @override
  String get milestonesEmpty => 'この状態のマイルストーンはありません。';

  @override
  String get milestonesError => 'マイルストーンを読み込めませんでした。';

  @override
  String get milestoneDetailError => 'このマイルストーンを読み込めませんでした。';

  @override
  String get milestoneStartDate => '開始日';

  @override
  String get milestoneDueDate => '期限';

  @override
  String get milestoneLoadMore => 'さらに読み込む';

  @override
  String get appTitle => 'LabFox';

  @override
  String get homeTitle => 'ホーム';

  @override
  String homeSignedInAs(String username) {
    return '$username としてサインイン中';
  }

  @override
  String get homeEmptyWork => '課題、マージリクエスト、パイプラインがここに表示されます。';

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
  String get signOut => 'サインアウト';

  @override
  String get signInTitle => 'GitLab アカウントを接続';

  @override
  String get signInNoAccountNote =>
      'LabFox に独自のアカウントはありません。お使いの GitLab に接続してください — gitlab.com、または自分でホストしているインスタンス。';

  @override
  String get signInInstanceLabel => 'GitLab インスタンス URL';

  @override
  String get signInInstanceRequired => 'GitLab インスタンスの URL を入力してください。';

  @override
  String get signInInstanceInvalid =>
      '有効な https URL を入力してください。例: https://gitlab.com';

  @override
  String get signInTokenLabel => 'パーソナルアクセストークン';

  @override
  String get signInTokenHelp => 'api と read_user のスコープが必要です。';

  @override
  String get signInTokenToggle => 'トークンの表示 / 非表示';

  @override
  String get signInTokenRequired => 'パーソナルアクセストークンを入力してください。';

  @override
  String get signInSubmit => 'サインイン';

  @override
  String get signInOr => 'または';

  @override
  String get signInOAuthButton => '自分のインスタンスで認可';

  @override
  String get signInClientIdLabel => 'OAuth クライアント ID';

  @override
  String get signInClientIdHelp => 'self-hosted インスタンスで OAuth を使う場合のみ必要です。';

  @override
  String get signInOAuthNeedsClientId => 'このインスタンスの OAuth クライアント ID を入力してください。';

  @override
  String get signInErrorToken => 'トークンが拒否されました。正しいか、有効期限が切れていないか確認してください。';

  @override
  String get signInErrorScope => 'トークンに必要なスコープがありません。api と read_user が必要です。';

  @override
  String get signInErrorUnreachable =>
      'そのインスタンスに接続できませんでした。URL、ネットワーク、証明書の信頼を確認してください。';

  @override
  String get signInErrorGeneric => 'サインインに失敗しました。もう一度お試しください。';

  @override
  String get scopeAssigned => 'Assigned';

  @override
  String get scopeCreated => 'Created';

  @override
  String get homeRefresh => 'Refresh';

  @override
  String get homeFavoritesEmpty => 'Star projects to pin them here.';

  @override
  String get homeMyWork => 'マイワーク';

  @override
  String get homeProjects => 'プロジェクト';

  @override
  String get homeGroups => 'Groups';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupsEmpty => 'You are not a member of any groups yet.';

  @override
  String get groupsError => 'Could not load your groups.';

  @override
  String get groupDetailTitle => 'グループ';

  @override
  String get groupDetailError => 'このグループを読み込めませんでした。';

  @override
  String get groupSubgroups => 'サブグループ';

  @override
  String get groupSubgroupsEmpty => 'サブグループはありません。';

  @override
  String get groupProjects => 'プロジェクト';

  @override
  String get groupProjectsEmpty => 'このグループにプロジェクトはありません。';

  @override
  String get groupLoadMore => 'さらに読み込む';

  @override
  String get projectsTitle => 'プロジェクト';

  @override
  String get projectsEmpty => 'まだどのプロジェクトにも参加していません。';

  @override
  String get projectsError => 'プロジェクトを読み込めませんでした。';

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
  String get retry => '再試行';

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
  String get issueEdit => 'イシューを編集';

  @override
  String get issueSaveChanges => '変更を保存';

  @override
  String get issueEditError => 'イシューを保存できません。権限を確認して再試行してください。';

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
  String get projectOverviewTitle => 'プロジェクト';

  @override
  String get projectOverviewError => 'このプロジェクトを読み込めませんでした。';

  @override
  String get projectOverviewNoReadme => 'このプロジェクトには README がありません。';

  @override
  String get projectOverviewRepository => 'リポジトリ';

  @override
  String get repositoryTitle => 'リポジトリ';

  @override
  String get repositoryError => 'このディレクトリを読み込めませんでした。';

  @override
  String get repositoryEmpty => 'このディレクトリは空です。';

  @override
  String get fileError => 'このファイルを読み込めませんでした。';

  @override
  String get fileNotFound => 'ファイルが見つかりませんでした。';

  @override
  String get fileBinary => 'バイナリファイルのためテキストとして表示できません。';

  @override
  String get fileCopy => 'Copy contents';

  @override
  String get fileCopied => 'Contents copied';

  @override
  String get projectOverviewBranches => 'ブランチ';

  @override
  String get projectOverviewCommits => 'コミット';

  @override
  String get projectOverviewCode => 'Code';

  @override
  String get projectOverviewBrowseCode => 'Browse code';

  @override
  String get branchesTitle => 'ブランチ';

  @override
  String get branchesError => 'ブランチを読み込めませんでした。';

  @override
  String get branchesEmpty => 'このリポジトリにはブランチがありません。';

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
  String get branchDefault => 'デフォルトブランチ';

  @override
  String get commitsTitle => 'コミット';

  @override
  String get commitsError => 'コミットを読み込めませんでした。';

  @override
  String get commitsEmpty => 'このブランチにはまだコミットがありません。';

  @override
  String get commitTitle => 'コミット';

  @override
  String get commitError => 'このコミットを読み込めませんでした。';

  @override
  String get projectOverviewIssues => '課題';

  @override
  String get issuesTitle => '課題';

  @override
  String get issuesFilterOpen => 'オープン';

  @override
  String get issuesFilterClosed => 'クローズ';

  @override
  String get issuesError => '課題を読み込めませんでした。';

  @override
  String get issuesEmpty => '課題はありません。';

  @override
  String get issueError => 'この課題を読み込めませんでした。';

  @override
  String get issueStateOpen => 'オープン';

  @override
  String get issueStateClosed => 'クローズ';

  @override
  String get issueNoDescription => '説明はありません。';

  @override
  String issueOpenedBy(String username) {
    return '$username が作成';
  }

  @override
  String get projectOverviewMergeRequests => 'マージリクエスト';

  @override
  String get mergeRequestsTitle => 'マージリクエスト';

  @override
  String get mrFilterOpen => 'オープン';

  @override
  String get mrFilterMerged => 'マージ済み';

  @override
  String get mrFilterClosed => 'クローズ';

  @override
  String get mergeRequestsError => 'マージリクエストを読み込めませんでした。';

  @override
  String get mergeRequestsEmpty => 'マージリクエストはありません。';

  @override
  String get mergeRequestError => 'このマージリクエストを読み込めませんでした。';

  @override
  String get mergeRequestNoDescription => '説明はありません。';

  @override
  String get mrStateOpen => 'オープン';

  @override
  String get mrStateMerged => 'マージ済み';

  @override
  String get mrStateClosed => 'クローズ';

  @override
  String get mrDraft => '下書き';

  @override
  String get changesTitle => '変更';

  @override
  String get changesError => '変更を読み込めませんでした。';

  @override
  String get changesEmpty => '変更はありません。';

  @override
  String get changesBinary => 'バイナリファイル — 表示しません。';

  @override
  String get commitViewChanges => '変更を表示';

  @override
  String get mrViewChanges => '変更を表示';

  @override
  String get changesOmitted => 'diff が大きすぎるか折りたたまれているため表示しません。';

  @override
  String get commentsHeading => 'コメント';

  @override
  String get commentsError => 'コメントを読み込めませんでした。';

  @override
  String get commentsEmpty => 'まだコメントはありません。';

  @override
  String get commentComposerHint => 'コメントを入力…';

  @override
  String get commentComposerSubmit => 'コメント';

  @override
  String get commentPostForbidden =>
      'ここにコメントする権限がありません。トークンに api スコープがあるか確認してください。';

  @override
  String get commentPostError => 'コメントを投稿できませんでした。もう一度お試しください。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get mrApprove => '承認';

  @override
  String get mrUnapprove => '承認を取り消す';

  @override
  String get mrMerge => 'マージ';

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
  String get mrMergeConfirmTitle => 'このマージリクエストをマージしますか？';

  @override
  String mrMergeConfirmBody(String mr) {
    return '$mr のマージは取り消せません。';
  }

  @override
  String mrApprovalsSummary(int approved, int required) {
    return '承認 $approved/$required';
  }

  @override
  String get mrNotMergeable => '現在マージできません。承認、リベース、またはパイプラインの成功が必要な場合があります。';

  @override
  String get mrActionForbidden => 'この操作の権限がありません。トークンのスコープとロールを確認してください。';

  @override
  String get mrActionError => '操作を完了できませんでした。もう一度お試しください。';

  @override
  String get projectOverviewPipelines => 'パイプライン';

  @override
  String get pipelinesTitle => 'パイプライン';

  @override
  String get pipelinesError => 'パイプラインを読み込めませんでした。';

  @override
  String get pipelinesEmpty => 'まだパイプラインはありません。';

  @override
  String get pipelineError => 'このパイプラインを読み込めませんでした。';

  @override
  String get pipelineJobsError => 'ジョブを読み込めませんでした。';

  @override
  String get pipelineNoJobs => 'このパイプラインにはジョブがありません。';

  @override
  String get jobTitle => 'ジョブ';

  @override
  String get jobError => 'このジョブを読み込めませんでした。';

  @override
  String get jobRefresh => '更新';

  @override
  String get jobLogError => 'ログを読み込めませんでした。';

  @override
  String get jobLogEmpty => 'このジョブにはログ出力がありません。';

  @override
  String get jobActionRetry => '再試行';

  @override
  String get jobActionCancel => 'キャンセル';

  @override
  String get jobActionRun => '実行';

  @override
  String get jobActionForbidden => 'この操作の権限がありません。';

  @override
  String get jobActionInvalid => '現在のジョブの状態ではこの操作はできません。';

  @override
  String get jobActionError => '操作を完了できませんでした。もう一度お試しください。';

  @override
  String get pipelineActionRetry => '再試行';

  @override
  String get pipelineActionCancel => 'キャンセル';

  @override
  String get pipelineActionForbidden => 'この操作の権限がありません。';

  @override
  String get pipelineActionInvalid => '現在のパイプラインの状態ではこの操作はできません。';

  @override
  String get pipelineActionError => '操作を完了できませんでした。もう一度お試しください。';

  @override
  String get accountsTitle => 'アカウント';

  @override
  String get accountAdd => 'アカウントを追加';

  @override
  String get accountRemove => 'アカウントを削除';

  @override
  String get homeSwitchAccount => 'アカウント';

  @override
  String get homeInbox => 'To Do リスト';

  @override
  String get inboxTitle => 'To Do リスト';

  @override
  String get inboxEmpty => 'すべて完了しました。';

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
  String get inboxError => 'To Do を読み込めませんでした。';

  @override
  String get inboxMarkAllDone => 'すべて完了にする';

  @override
  String get inboxMarkDone => '完了にする';

  @override
  String get inboxMarkDoneError => '項目を完了にできませんでした。もう一度お試しください。';

  @override
  String get inboxActionAssigned => 'あなたに割り当て';

  @override
  String get inboxActionMentioned => 'あなたにメンション';

  @override
  String get inboxActionBuildFailed => 'パイプライン失敗';

  @override
  String get inboxActionMarked => 'To Do を追加';

  @override
  String get inboxActionApprovalRequired => '承認が必要';

  @override
  String get inboxActionUnmergeable => 'マージできません';

  @override
  String get inboxActionDirectlyAddressed => 'あなたを直接指定';

  @override
  String get homeSearch => '検索';

  @override
  String get searchTitle => '検索';

  @override
  String get searchHint => 'プロジェクト・イシュー・マージリクエストを検索';

  @override
  String get searchScopeProjects => 'プロジェクト';

  @override
  String get searchScopeIssues => 'イシュー';

  @override
  String get searchScopeMergeRequests => 'マージリクエスト';

  @override
  String get searchInitial => '検索語を入力してください。';

  @override
  String get searchEmpty => '結果が見つかりませんでした。';

  @override
  String get searchError => '検索を完了できませんでした。';

  @override
  String get searchLoadMore => 'さらに読み込む';

  @override
  String get listSearchHint => 'Search by title';

  @override
  String get listSearchClose => 'Close search';

  @override
  String get projectAddFavorite => 'お気に入りに追加';

  @override
  String get projectRemoveFavorite => 'お気に入りから削除';

  @override
  String get homeFavorites => 'お気に入り';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAccounts => 'アカウント';

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
  String get settingsLicenses => 'オープンソースライセンス';

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
  String get navHome => 'ホーム';

  @override
  String get navInbox => '受信箱';

  @override
  String get navSearch => '検索';

  @override
  String get navMe => 'マイページ';

  @override
  String get meTitle => 'マイページ';

  @override
  String get meSettings => '設定';

  @override
  String get meAccounts => 'アカウント切り替え';

  @override
  String get projectLabelsTitle => 'ラベル';

  @override
  String get projectLabelsError => 'ラベルを読み込めませんでした。';

  @override
  String get projectLabelsEmpty => 'ラベルはまだありません';

  @override
  String get projectLabelsNoMatch => '一致するラベルがありません';

  @override
  String get projectLabelSearch => 'ラベルを検索';

  @override
  String get projectLabelNew => '新しいラベル';

  @override
  String get projectLabelGroup => 'グループラベル';

  @override
  String get projectLabelProject => 'プロジェクトラベル';

  @override
  String get projectLabelError => 'このラベルを読み込めませんでした。';

  @override
  String get projectLabelOpenIssues => '未解決の課題';

  @override
  String get projectLabelClosedIssues => '終了した課題';

  @override
  String get projectLabelOpenMrs => '未処理のマージリクエスト';

  @override
  String get projectLabelName => '名前';

  @override
  String get projectLabelColor => '色 (#RRGGBB)';

  @override
  String get projectLabelDescription => '説明（任意）';

  @override
  String get projectLabelRequired => '必須項目です';

  @override
  String get projectLabelInvalidColor => '#5843AD のような色を入力してください';

  @override
  String get projectLabelCreate => 'ラベルを作成';

  @override
  String get projectLabelCreateError => 'ラベルを作成できませんでした。権限と入力内容を確認してください。';

  @override
  String get tagsTitle => 'タグ';

  @override
  String get tagsEmpty => 'タグはまだありません';

  @override
  String get tagsError => 'タグを読み込めませんでした。';

  @override
  String get tagsNoMatch => '一致するタグがありません';

  @override
  String get tagSearchHint => 'タグを検索';

  @override
  String get tagError => 'このタグを読み込めませんでした。';

  @override
  String get tagProtected => '保護されたタグ';

  @override
  String get tagNew => '新しいタグ';

  @override
  String get tagName => 'タグ名';

  @override
  String get tagFromRef => 'ブランチ、タグ、またはコミットSHAから作成';

  @override
  String get tagMessage => 'メッセージ（任意）';

  @override
  String get tagPipelineNotice => 'タグを作成するとCI/CDパイプラインが開始される場合があります。';

  @override
  String get tagFieldRequired => '必須項目です';

  @override
  String get tagCreate => 'タグを作成';

  @override
  String get tagCreateError => 'タグを作成できませんでした。権限と参照元を確認してください。';

  @override
  String get snippetsTitle => 'スニペット';

  @override
  String get snippetsEmpty => 'スニペットはまだありません';

  @override
  String get snippetsError => 'スニペットを読み込めませんでした。';

  @override
  String get snippetError => 'このスニペットを読み込めませんでした。';

  @override
  String get snippetContent => '内容';

  @override
  String get snippetContentError => 'スニペットの内容を読み込めませんでした。';

  @override
  String get homeRecents => '最近';

  @override
  String get wikiTitle => 'Wiki';

  @override
  String get wikiEmpty => 'Wikiページはまだありません。';

  @override
  String get wikiListError => 'Wikiページを読み込めませんでした。';

  @override
  String get wikiPageError => 'このWikiページを読み込めませんでした。';

  @override
  String get packageRegistryTitle => 'パッケージレジストリ';

  @override
  String get packageRegistryEmpty => 'パッケージはまだありません。';

  @override
  String get packageRegistryError => 'パッケージを読み込めませんでした。';

  @override
  String get packageDetailError => 'このパッケージを読み込めませんでした。';

  @override
  String get packageFiles => 'ファイル';

  @override
  String get packageFilesEmpty => 'このパッケージにはファイルがありません。';

  @override
  String get packageLoadMore => 'さらに読み込む';
}
