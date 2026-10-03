// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get pipelineScheduleExecutionEdit => '実行設定を編集';

  @override
  String get pipelineScheduleExecutionSave => '保存';

  @override
  String get pipelineScheduleExecutionActive => '有効';

  @override
  String get pipelineScheduleExecutionRefRequired => '参照を入力してください。';

  @override
  String get pipelineScheduleExecutionHint =>
      'GitLab が参照を検証します。ブランチとタグが同名の場合は完全な参照を入力してください。保存すると今後の実行予定が再計算され、cron、タイムゾーン、変数、入力は変更されません。';

  @override
  String get pipelineScheduleExecutionError =>
      '実行設定を更新できませんでした。権限と参照を確認して再試行してください。';

  @override
  String get pipelineScheduleCreate => 'スケジュールを作成';

  @override
  String get pipelineScheduleCreateTitle => '新しいパイプラインスケジュール';

  @override
  String get pipelineScheduleCreateDescription => '説明';

  @override
  String get pipelineScheduleCreateFieldRequired => '値を入力してください。';

  @override
  String get pipelineScheduleCreateActive => '有効';

  @override
  String get pipelineScheduleCreateHint =>
      'GitLab が参照、cron 式、タイムゾーンを検証します。タイムゾーンを空欄にすると UTC を使用します。ブランチとタグが同名の場合は完全な参照を入力してください。';

  @override
  String get pipelineScheduleCreateError =>
      'このパイプラインスケジュールを作成できませんでした。権限、参照、cron 式、タイムゾーンを確認してください。';

  @override
  String get releaseCreationMilestoneTitle => 'マイルストーンのタイトル（任意）';

  @override
  String get releaseCreationMilestoneAdd => 'マイルストーンを追加';

  @override
  String get releaseCreationMilestoneRequired => 'マイルストーンのタイトルを入力してください。';

  @override
  String get releaseCreationMilestoneDuplicate => 'このマイルストーンは既に選択されています。';

  @override
  String releaseCreationMilestoneRemove(String title) {
    return 'マイルストーン $title を削除';
  }

  @override
  String get releaseCreationMilestoneHelp =>
      '既存のタイトルを1つずつ正確に入力してください。グループマイルストーンの利用可否はGitLabのプランによって異なります。';

  @override
  String get releasePickerTitle => 'プロジェクトのマイルストーンを選択';

  @override
  String get releasePickerSearch => 'プロジェクトのマイルストーンを検索';

  @override
  String get releasePickerEmpty => 'プロジェクトのマイルストーンが見つかりません。';

  @override
  String get releasePickerError => 'マイルストーンを読み込めませんでした。';

  @override
  String get releasePickerMore => 'マイルストーンをさらに読み込む';

  @override
  String get releasePickerUse => 'マイルストーンを使用';

  @override
  String releasePickerRemove(String title) {
    return 'マイルストーン $title を削除';
  }

  @override
  String get releaseCreationDateLabel => '公開日時（任意）';

  @override
  String get releaseCreationDateDefault => '公開日時はGitLabが設定します。';

  @override
  String get releaseCreationChooseDate => '公開日を選択';

  @override
  String get releaseCreationChooseTime => '公開時刻を選択';

  @override
  String get releaseCreationClearDate => 'GitLabの公開日時を使用';

  @override
  String releaseCreationDateHelp(String zone) {
    return 'タイムゾーン: $zone。未来の日時は予定リリース、過去の日時は過去のリリースを作成します。';
  }

  @override
  String get pipelineScheduleDelete => 'スケジュールを削除';

  @override
  String get pipelineScheduleDeleteConfirmTitle => 'このパイプラインスケジュールを削除しますか？';

  @override
  String pipelineScheduleDeleteConfirmBody(String name) {
    return 'パイプラインスケジュール「$name」は完全に削除されます。この操作は元に戻せません。';
  }

  @override
  String get pipelineScheduleDeleteError =>
      'このパイプラインスケジュールを削除できませんでした。権限を確認して再試行してください。';

  @override
  String get releaseScheduleEdit => 'リリース日時を編集';

  @override
  String get releaseScheduleChangeDate => '日付を変更';

  @override
  String get releaseScheduleChangeTime => '時刻を変更';

  @override
  String get releaseScheduleSave => 'リリース日時を保存';

  @override
  String get releaseScheduleError => 'リリース日時を更新できませんでした。';

  @override
  String releaseScheduleHelp(String zone) {
    return '時刻にはデバイスのタイムゾーン（$zone）を使用します。未来の日時は予定リリースとして設定されます。';
  }

  @override
  String get pipelineScheduleEdit => 'スケジュールを編集';

  @override
  String get pipelineScheduleSave => '保存';

  @override
  String get pipelineScheduleDescription => '説明';

  @override
  String get pipelineScheduleFieldRequired => '値を入力してください。';

  @override
  String get pipelineScheduleEditHint =>
      'GitLab が cron 式とタイムゾーンを検証します。保存すると今後の実行予定が変更され、対象の参照、有効状態、変数、入力は保持されます。';

  @override
  String get pipelineScheduleEditError =>
      'パイプラインスケジュールを更新できませんでした。権限、cron 式、タイムゾーンを確認してください。';

  @override
  String get pipelineScheduleTakeOwnership => '所有権を取得';

  @override
  String get pipelineScheduleOwnershipConfirmTitle => 'このスケジュールの所有権を取得しますか？';

  @override
  String pipelineScheduleOwnershipConfirmBody(String name) {
    return '「$name」の所有者になります。スケジュールされたパイプラインはあなたの権限で実行されます。Maintainer または Owner ロールが必要です。';
  }

  @override
  String get pipelineScheduleOwnershipError =>
      'このパイプラインスケジュールの所有権を取得できませんでした。権限を確認して再試行してください。';

  @override
  String get protectedTagProtectTitle => 'タグを保護';

  @override
  String get protectedTagProtectName => 'ルール名';

  @override
  String get protectedTagProtectRole => '一致するタグを作成できるユーザー';

  @override
  String get protectedTagProtectNoOne => 'なし';

  @override
  String get protectedTagProtectDevelopers => '開発者とメンテナー';

  @override
  String get protectedTagProtectMaintainers => 'メンテナー';

  @override
  String protectedTagProtectWarning(String projectId) {
    return 'このルールはプロジェクト $projectId で一致するタグの作成権限を変更し、タグのパイプラインやジョブに影響する場合があります。';
  }

  @override
  String get protectedTagProtectWildcard =>
      'ワイルドカードルールは今後のタグにも影響します。パターンと権限を確認してください。';

  @override
  String get protectedTagProtectAcknowledge => 'このルールがプロジェクト全体に及ぼす影響を理解しました。';

  @override
  String get protectedTagProtectSubmit => 'タグを保護';

  @override
  String get protectedTagProtectExisting => 'ルールは既に存在します。変更はありません。';

  @override
  String get protectedTagProtectUncertain =>
      '結果を確認できません。再試行する前にすべてのルールを再読み込みしてください。';

  @override
  String get protectedTagProtectReload => 'ルールを再読み込み';

  @override
  String get protectedTagProtectLoadError => '保護タグのルールを確認できません。再読み込みしてください。';

  @override
  String get protectedTagProtectSessionChanged =>
      'アカウントが変更されました。この画面を閉じてやり直してください。';

  @override
  String get protectedTagProtectCreated => '保護タグのルールを作成しました。';

  @override
  String get protectedTagProtectCancel => 'キャンセル';

  @override
  String get protectedTagProtectForbidden =>
      'このルールを作成する権限がありません。再試行前に再読み込みしてください。';

  @override
  String get protectedTagProtectUnauthorized =>
      'セッションの有効期限が切れました。再度サインインしてください。';

  @override
  String get protectedTagProtectRateLimited =>
      'GitLab がリクエストを制限しています。待ってからルールを再読み込みしてください。';

  @override
  String get protectedTagProtectUnavailable =>
      'このプロジェクトまたは保護タグを利用できません。再試行前に再読み込みしてください。';

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
  String get protectedBranchProtectTitle => 'ブランチを保護';

  @override
  String get protectedBranchProtectName => 'ルール名';

  @override
  String get protectedBranchProtectPush => 'プッシュを許可';

  @override
  String get protectedBranchProtectMerge => 'マージを許可';

  @override
  String get protectedBranchProtectNoOne => 'なし';

  @override
  String get protectedBranchProtectDevelopers => '開発者とメンテナー';

  @override
  String get protectedBranchProtectMaintainers => 'メンテナー';

  @override
  String protectedBranchProtectWarning(String projectId) {
    return 'このルールはプロジェクト $projectId のプッシュとマージの権限を変更します。マージリクエスト、保護された CI 変数、ジョブに影響する場合があります。';
  }

  @override
  String get protectedBranchProtectWildcard =>
      'ワイルドカードルールは今後のブランチにも影響します。パターンと両方の権限を確認してください。';

  @override
  String get protectedBranchProtectAcknowledge =>
      'このルールがプロジェクト全体に及ぼす影響を理解しました。';

  @override
  String get protectedBranchProtectSubmit => 'ブランチを保護';

  @override
  String get protectedBranchProtectExisting => 'ルールは既に存在します。変更はありません。';

  @override
  String get protectedBranchProtectUncertain =>
      '結果を確認できません。再試行する前にすべてのルールを再読み込みしてください。';

  @override
  String get protectedBranchProtectReload => 'ルールを再読み込み';

  @override
  String get protectedBranchProtectLoadError =>
      '保護ブランチのルールを確認できません。再読み込みしてください。';

  @override
  String get protectedBranchProtectSessionChanged =>
      'アカウントが変更されました。この画面を閉じてやり直してください。';

  @override
  String get protectedBranchProtectCreated => '保護ブランチのルールを作成しました。';

  @override
  String get protectedBranchProtectCancel => 'キャンセル';

  @override
  String get protectedBranchProtectForbidden =>
      'このルールを作成する権限がありません。再試行前に再読み込みしてください。';

  @override
  String get protectedBranchProtectUnauthorized =>
      'セッションの有効期限が切れました。再度サインインしてください。';

  @override
  String get protectedBranchProtectRateLimited =>
      'GitLab がリクエストを制限しています。待ってからルールを再読み込みしてください。';

  @override
  String get protectedBranchProtectUnavailable =>
      'このプロジェクトまたは保護ブランチを利用できません。再試行前に再読み込みしてください。';

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
  String get pipelineScheduleHistoryTitle => '実行履歴';

  @override
  String get pipelineScheduleHistoryEmpty => 'このスケジュールで実行されたパイプラインはまだありません。';

  @override
  String get pipelineScheduleHistoryError => '実行履歴を読み込めませんでした。';

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
  String get releaseEdit => 'リリースを編集';

  @override
  String get releaseSave => 'リリースを保存';

  @override
  String get releaseEditName => 'リリース名';

  @override
  String get releaseEditDescription => '説明（Markdown）';

  @override
  String get releaseNameRequired => 'リリース名を入力してください。';

  @override
  String get releaseEditError => 'リリースを更新できませんでした。';

  @override
  String get releaseNew => '新しいリリース';

  @override
  String get releaseCreate => 'リリースを作成';

  @override
  String get releaseTagName => 'タグ名';

  @override
  String get releaseRef => 'タグ作成元のref（任意）';

  @override
  String get releaseRefHelp => 'タグがすでに存在する場合は空欄にしてください。';

  @override
  String get releaseName => 'リリース名（任意）';

  @override
  String get releaseDescription => '説明（Markdown）';

  @override
  String get releaseTagRequired => 'タグ名を入力してください。';

  @override
  String get releaseCreateError => 'リリースを作成できませんでした。';

  @override
  String get releaseAddAssetLink => 'アセットリンクを追加';

  @override
  String get releaseAddLink => 'リンクを追加';

  @override
  String get releaseAssetName => 'リンク名';

  @override
  String get releaseAssetUrl => 'リンク URL';

  @override
  String get releaseAssetNameRequired => 'リンク名を入力してください。';

  @override
  String get releaseAssetUrlInvalid => 'HTTP または HTTPS の URL を入力してください。';

  @override
  String get releaseAssetNameDuplicate => '同じ名前のリンクが既にあります。';

  @override
  String get releaseAssetCreateError => 'アセットリンクを追加できませんでした。';

  @override
  String get releaseNoAssets => 'アセットはまだありません。';

  @override
  String get releaseDelete => 'リリースを削除';

  @override
  String get releaseDeleteConfirmTitle => 'このリリースを削除しますか？';

  @override
  String get releaseDeleteConfirmBody => 'リリースとリリースノートが削除されます。Git タグは残ります。';

  @override
  String get releaseDeleteError => 'リリースを削除できませんでした。';

  @override
  String get releaseDeleteAssetLink => 'アセットリンクを削除';

  @override
  String get releaseDeleteLink => 'リンクを削除';

  @override
  String get releaseAssetDeleteConfirmTitle => 'このアセットリンクを削除しますか？';

  @override
  String releaseAssetDeleteConfirmBody(String name) {
    return '$name というリンクを削除します。リンク先のファイルは削除されません。';
  }

  @override
  String get releaseAssetDeleteError => 'アセットリンクを削除できませんでした。';

  @override
  String get releaseEditAssetLink => 'アセットリンクを編集';

  @override
  String get releaseSaveLink => 'リンクを保存';

  @override
  String get releaseAssetEditError => 'アセットリンクを更新できませんでした。';

  @override
  String get releaseMilestonesEdit => 'リリースのマイルストーンを編集';

  @override
  String get releaseMilestonesTitle => 'マイルストーン';

  @override
  String get releaseMilestonesHelp =>
      '正確なマイルストーン名を入力してください。グループマイルストーンの利用可否は GitLab プランとプロジェクトのグループによって異なります。';

  @override
  String get releaseMilestoneTitle => 'マイルストーン名';

  @override
  String get releaseMilestoneAdd => 'マイルストーンを追加';

  @override
  String get releaseMilestonesSave => 'マイルストーンを保存';

  @override
  String get releaseMilestonesError => 'リリースのマイルストーンを更新できませんでした。';

  @override
  String get releaseMilestoneTitleRequired => 'マイルストーン名を入力してください。';

  @override
  String get releaseMilestoneDuplicate => 'このマイルストーンは選択済みです。';

  @override
  String releaseMilestoneRemove(String title) {
    return '$title を削除';
  }

  @override
  String get releaseAssetDirectPath => '新しい直接ダウンロードパス（任意）';

  @override
  String get releaseAssetDirectPathHelp =>
      '空欄の場合は現在の直接ダウンロードパスを維持します。変更するには /bin/app.zip などのパスを入力してください。';

  @override
  String get releaseAssetDirectPathInvalid =>
      'ホスト、クエリ、フラグメントを含まない、/ で始まるパスを入力してください。';

  @override
  String get releaseAssetType => 'リンクの種類';

  @override
  String get releaseAssetKeepType => '現在の種類を維持';

  @override
  String get releaseAssetTypeOther => 'その他';

  @override
  String get releaseAssetTypeRunbook => 'ランブック';

  @override
  String get releaseAssetTypeImage => '画像';

  @override
  String get releaseAssetTypePackage => 'パッケージ';

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
  String get milestoneNew => '新しいマイルストーン';

  @override
  String get milestoneCreate => 'マイルストーンを作成';

  @override
  String get milestoneTitleField => 'タイトル';

  @override
  String get milestoneDescriptionField => '説明';

  @override
  String get milestoneTitleRequired => 'マイルストーンのタイトルを入力してください。';

  @override
  String get milestoneDateOrderError => '開始日は期限以前にしてください。';

  @override
  String get milestoneCreateError => 'マイルストーンを作成できませんでした。';

  @override
  String get milestoneChooseDate => '日付を選択';

  @override
  String get milestoneClearDate => '日付を消去';

  @override
  String get milestoneEdit => 'マイルストーンを編集';

  @override
  String get milestoneSaveChanges => '変更を保存';

  @override
  String get milestoneUpdateError => 'マイルストーンを更新できませんでした。';

  @override
  String get milestoneClearStartDate => '開始日を消去';

  @override
  String get milestoneClearDueDate => '期限を消去';

  @override
  String get milestoneClose => 'マイルストーンを閉じる';

  @override
  String get milestoneReactivate => 'マイルストーンを再開';

  @override
  String get milestoneCloseConfirmTitle => 'このマイルストーンを閉じますか？';

  @override
  String get milestoneCloseConfirmBody => '後で再開できます。';

  @override
  String get milestoneStateError => 'マイルストーンの状態を変更できませんでした。';

  @override
  String get milestoneDelete => 'マイルストーンを削除';

  @override
  String get milestoneDeleteConfirmTitle => 'このマイルストーンを削除しますか？';

  @override
  String get milestoneDeleteConfirmBody => 'この操作は元に戻せません。';

  @override
  String get milestoneDeleteError => 'マイルストーンを削除できませんでした。';

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
  String get issueEditLabels => 'ラベルを編集';

  @override
  String get issueSaveLabels => 'ラベルを保存';

  @override
  String get issueLabelsEmpty => '利用できるラベルがありません';

  @override
  String get issueLabelsLoadError => 'ラベルを読み込めませんでした。';

  @override
  String get issueLabelsSaveError => 'ラベルを更新できませんでした。もう一度お試しください。';

  @override
  String get issueEditDueDate => '期限を編集';

  @override
  String get issueConfidential => '機密';

  @override
  String get issueMakeConfidential => '機密にする';

  @override
  String get issueRemoveConfidentiality => '機密を解除';

  @override
  String get issueMakeConfidentialExplanation => 'このイシューへのアクセスが制限されます。続行しますか？';

  @override
  String get issueRemoveConfidentialityExplanation =>
      'プロジェクトを閲覧できる全員にこのイシューが表示されます。続行しますか？';

  @override
  String get issueConfidentialityConfirm => '確認';

  @override
  String get issueConfidentialityError => '機密設定を更新できませんでした。権限を確認して再試行してください。';

  @override
  String get issueDiscussionLocked => 'ディスカッションはロックされています';

  @override
  String get issueLockDiscussion => 'ディスカッションをロック';

  @override
  String get issueUnlockDiscussion => 'ディスカッションのロックを解除';

  @override
  String get issueLockDiscussionExplanation =>
      'プロジェクトメンバーのみコメントを追加・編集できます。続行しますか？';

  @override
  String get issueUnlockDiscussionExplanation =>
      'このイシューにアクセスできるユーザーが再びコメントできます。続行しますか？';

  @override
  String get issueDiscussionLockConfirm => '確認';

  @override
  String get issueDiscussionLockError =>
      'ディスカッションのロックを変更できませんでした。権限を確認して再試行してください。';

  @override
  String get issueEditMilestone => 'マイルストーンを編集';

  @override
  String get issueEditAssignees => '担当者を編集';

  @override
  String get issueAssignees => '担当者';

  @override
  String get issueSaveAssignees => '担当者を保存';

  @override
  String get issueAssigneesSaveError => '担当者を更新できませんでした。権限を確認して再試行してください。';

  @override
  String get issueNoMilestone => 'マイルストーンなし';

  @override
  String get issueMilestonesLoadError => 'マイルストーンを読み込めませんでした。';

  @override
  String get issueMilestoneSaveError => 'マイルストーンを更新できませんでした。権限を確認して再試行してください。';

  @override
  String get issueDueDate => '期限';

  @override
  String issueDueDateValue(String date) {
    return '期限: $date';
  }

  @override
  String get issueSelectDueDate => '日付を選択';

  @override
  String get issueClearDueDate => '期限を削除';

  @override
  String get issueDueDateError => '期限を更新できませんでした。もう一度お試しください。';

  @override
  String get issueSaveChanges => '変更を保存';

  @override
  String get issueEditError => 'イシューを保存できません。権限を確認して再試行してください。';

  @override
  String get issueSubscribe => '通知を購読';

  @override
  String get issueUnsubscribe => '通知の購読を解除';

  @override
  String get issueSubscriptionError => 'イシューの通知を変更できません。再試行してください。';

  @override
  String get mrSubscribe => '通知を購読';

  @override
  String get mrUnsubscribe => '通知の購読を解除';

  @override
  String get mrSubscriptionError => 'マージリクエストの通知を変更できません。再試行してください。';

  @override
  String get issueAddTodo => 'To-Do に追加';

  @override
  String get issueTodoAdded => 'To-Do リストに追加しました。';

  @override
  String get issueTodoExists => 'このイシューは既に To-Do リストにあります。';

  @override
  String get issueTodoError => 'イシューを To-Do リストに追加できません。再試行してください。';

  @override
  String get mrAddTodo => 'To-Do に追加';

  @override
  String get mrTodoAdded => 'To-Do リストに追加しました。';

  @override
  String get mrTodoExists => 'このマージリクエストは既に To-Do リストにあります。';

  @override
  String get mrTodoError => 'マージリクエストを To-Do リストに追加できません。再試行してください。';

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
  String get pipelinesLoadMore => 'さらに読み込む';

  @override
  String get pipelinesLoadMoreError => '追加のパイプラインを読み込めませんでした。';

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
  String get snippetNew => '新しいスニペット';

  @override
  String get snippetTitleField => 'タイトル';

  @override
  String get snippetDescriptionField => '説明';

  @override
  String get snippetFilePathField => 'ファイルパス';

  @override
  String get snippetContentField => '内容';

  @override
  String get snippetVisibilityField => '公開範囲';

  @override
  String get snippetVisibilityUnchanged => '現在の公開範囲を維持';

  @override
  String get snippetPrivate => '非公開';

  @override
  String get snippetPublic => '公開';

  @override
  String get snippetCreate => 'スニペットを作成';

  @override
  String get snippetCreateValidationError => 'タイトル、ファイルパス、内容を入力してください。';

  @override
  String get snippetCreateError => 'スニペットを作成できませんでした。';

  @override
  String get snippetAddFile => 'ファイルを追加';

  @override
  String get snippetFileAddValidationError => '重複しない相対ファイルパスと内容を入力してください。';

  @override
  String get snippetFileAddError => 'ファイルを追加できませんでした。';

  @override
  String get snippetFileMoveAction => 'ファイルを移動';

  @override
  String get snippetFileMoveTitle => 'ファイルの移動または名前の変更';

  @override
  String get snippetFileMovePathField => '新しいファイルパス';

  @override
  String get snippetFileMoveValidationError => '別の未使用の相対ファイルパスを入力してください。';

  @override
  String get snippetFileMoveError => 'ファイルを移動できませんでした。';

  @override
  String get snippetEditAction => 'スニペットを編集';

  @override
  String get snippetEditTitle => 'スニペットを編集';

  @override
  String get snippetSaveChanges => '変更を保存';

  @override
  String get snippetEditValidationError => 'タイトルを入力してください。';

  @override
  String get snippetEditError => 'スニペットを保存できませんでした。';

  @override
  String get snippetDeleteAction => 'スニペットを削除';

  @override
  String get snippetDeleteConfirmTitle => 'このスニペットを削除しますか？';

  @override
  String get snippetDeleteConfirmMessage => 'スニペットとファイルは完全に削除されます。';

  @override
  String get snippetDeleteButton => '削除';

  @override
  String get snippetDeleteError => 'スニペットを削除できませんでした。';

  @override
  String get snippetFileDeleteAction => 'ファイルを削除';

  @override
  String get snippetFileDeleteConfirmTitle => 'このファイルを削除しますか？';

  @override
  String get snippetFileDeleteConfirmMessage => 'スニペットからこのファイルのみを完全に削除します。';

  @override
  String get snippetFileDeleteError => 'ファイルを削除できませんでした。';

  @override
  String get snippetEditContent => '内容を編集';

  @override
  String get snippetSaveContent => '内容を保存';

  @override
  String get snippetContentSaveError => 'スニペットの内容を保存できませんでした。';

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
  String get wikiNewPage => '新しいページ';

  @override
  String get wikiPagesSection => 'ページ';

  @override
  String get wikiTemplatesSection => 'テンプレート';

  @override
  String get wikiTemplateEmpty => 'テンプレートはまだありません。';

  @override
  String get wikiNewTemplate => '新しいテンプレート';

  @override
  String get wikiTemplateTitle => 'テンプレートのタイトル';

  @override
  String get wikiCreateTemplate => 'テンプレートを作成';

  @override
  String get wikiCreateTemplateError => 'テンプレートを作成できませんでした。';

  @override
  String get wikiPageTitle => 'タイトル';

  @override
  String get wikiPageContent => '内容';

  @override
  String get wikiCreatePage => 'ページを作成';

  @override
  String get wikiChooseTemplate => 'テンプレートを選択';

  @override
  String get wikiReplaceTemplateContent => '現在の内容をこのテンプレートで置き換えますか？';

  @override
  String get wikiApplyTemplate => 'テンプレートを適用';

  @override
  String get wikiTemplateLoadError => 'テンプレートを読み込めませんでした。';

  @override
  String get wikiCreateValidationError => 'タイトルと内容を入力してください。';

  @override
  String get wikiCreateError => 'Wikiページを作成できませんでした。';

  @override
  String get wikiEditPageAction => '編集';

  @override
  String get wikiEditPage => 'Wikiページを編集';

  @override
  String get wikiEditTitle => 'タイトル';

  @override
  String get wikiEditContent => '内容';

  @override
  String get wikiSaveChanges => '変更を保存';

  @override
  String get wikiEditValidationError => 'タイトルと内容を入力してください。';

  @override
  String get wikiEditError => 'Wikiページを保存できませんでした。';

  @override
  String get wikiEditConflict => 'このページはGitLabで変更されました。再編集する前にページを再読み込みしてください。';

  @override
  String get wikiDeletePageAction => 'ページを削除';

  @override
  String get wikiDeleteConfirmTitle => 'このWikiページを削除しますか？';

  @override
  String get wikiDeleteConfirmMessage => 'プロジェクトWikiからこのページを完全に削除します。';

  @override
  String get wikiDeleteError => 'Wikiページを削除できませんでした。';

  @override
  String get wikiDeleteConflict => 'ページが変更されました。削除する前に再読み込みしてください。';

  @override
  String get wikiReloadPage => 'ページを再読み込み';

  @override
  String get packageRegistryTitle => 'パッケージレジストリ';

  @override
  String get packageDelete => 'パッケージを削除';

  @override
  String get packageDeleteConfirmTitle => 'このパッケージを削除しますか？';

  @override
  String packageDeleteConfirmBody(String name) {
    return '$nameとすべてのファイルを削除しますか？この操作は元に戻せません。';
  }

  @override
  String get packageDeleteForwardingWarning =>
      'リクエスト転送が有効な場合、このパッケージを削除すると依存関係混乱攻撃のリスクが生じる可能性があります。';

  @override
  String get packageDeleteError => 'このパッケージを削除できませんでした。もう一度お試しください。';

  @override
  String get packageDeleteForbidden => 'このパッケージは保護されているか、削除権限がない可能性があります。';

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

  @override
  String get protectedTagUnprotectTitle => 'タグ保護ルールを解除';

  @override
  String protectedTagUnprotectTarget(String projectId, String name) {
    return 'プロジェクト $projectId — ルール $name';
  }

  @override
  String get protectedTagUnprotectWarning =>
      'リポジトリのタグ保護ルールを削除します。タグは削除されません。ワイルドカードは既存と今後の多くのタグに影響する場合があります。保護の解除により、一致するタグを作成・削除できるユーザーが増え、タグのパイプラインやジョブへのアクセスが変わる可能性があります。他の一致ルールで保護が続く場合もあり、実際のアクセスはGitLabが決定します。以下の現在の作成権限を確認してください。';

  @override
  String protectedTagUnprotectAccess(
    String description,
    String role,
    String user,
    String group,
    String key,
  ) {
    return '$description\nロールレベル: $role; ユーザーID: $user; グループID: $group; デプロイキーID: $key';
  }

  @override
  String get protectedTagUnprotectUnreported => '未報告';

  @override
  String get protectedTagUnprotectName => 'ルール名またはパターンを正確に再入力';

  @override
  String get protectedTagUnprotectAcknowledge =>
      'このルールに一致するすべてのタグの保護が失われることを理解し、このルールを削除します。';

  @override
  String get protectedTagUnprotectAuth =>
      'セッションが拒否されました。再ログインしてからルールを確認してください。';

  @override
  String get protectedTagUnprotectForbidden =>
      'GitLabが保護解除を拒否しました。MaintainerまたはOwnerのロールが必要です。';

  @override
  String get protectedTagUnprotectUnavailable =>
      'ルールが存在しない、非公開、またはこのインスタンスで利用できません。再読み込みしてください。他のルールは削除されません。';

  @override
  String get protectedTagUnprotectStale =>
      'ルールが変更されました。再読み込みし、現在の権限を確認してから削除してください。';

  @override
  String get protectedTagUnprotectRateLimited =>
      'GitLabがリクエストを制限しています。しばらく待ち、ルールを再読み込みして確認してください。';

  @override
  String get protectedTagUnprotectError =>
      'リクエストの結果を確認できませんでした。再試行前にルールを再読み込みして確認してください。';

  @override
  String get protectedTagUnprotectReload => 'ルールを再読み込み';

  @override
  String get protectedTagUnprotectSessionChanged =>
      'アカウントが変更されました。このダイアログを閉じて開き直し、現在のプロジェクトを確認してください。';

  @override
  String get protectedTagUnprotectAccepted => 'タグ保護ルールを削除しました。タグは削除されていません。';

  @override
  String get protectedBranchForcePushEditTitle => '強制プッシュを編集';

  @override
  String protectedBranchForcePushEditTarget(String project, String name) {
    return 'プロジェクト $project: $name';
  }

  @override
  String get protectedBranchForcePushCurrentAllowed => '現在、強制プッシュは許可されています。';

  @override
  String get protectedBranchForcePushCurrentBlocked => '現在、強制プッシュは禁止されています。';

  @override
  String get protectedBranchForcePushAllow => '強制プッシュを許可';

  @override
  String get protectedBranchForcePushSave => '設定を保存';

  @override
  String get protectedBranchForcePushEnableWarning =>
      '強制プッシュを許可すると、対象ブランチの履歴を書き換えられます。ワイルドカードは複数のブランチに影響します。';

  @override
  String get protectedBranchForcePushDisableWarning =>
      '強制プッシュを禁止すると、対象ブランチでの作業方法が変わります。ワイルドカードは複数のブランチに影響します。';

  @override
  String get protectedBranchForcePushAcknowledge => '対象ブランチへの変更の影響を理解しました。';

  @override
  String get protectedBranchForcePushReload => 'ルールを再確認';

  @override
  String get protectedBranchForcePushSuccess => '強制プッシュ設定を更新しました。';

  @override
  String get protectedBranchForcePushAuth => 'このルールを変更するには再度サインインしてください。';

  @override
  String get protectedBranchForcePushForbidden => 'このルールを変更する権限がありません。';

  @override
  String get protectedBranchForcePushUnavailable =>
      'このルールは利用できません。続行する前に一覧を確認してください。';

  @override
  String get protectedBranchForcePushStale => 'ルールが変更されました。続行する前に再確認してください。';

  @override
  String get protectedBranchForcePushRateLimited =>
      'GitLab がリクエストを制限しています。再試行前にルールを確認してください。';

  @override
  String get protectedBranchForcePushError => '変更を確認できません。再試行前にルールを確認してください。';

  @override
  String get protectedBranchForcePushSessionChanged =>
      'アカウントが変わりました。ダイアログを閉じてルールを開き直してください。';

  @override
  String get protectedBranchMergeRoleEditTitle => 'マージ権限を編集';

  @override
  String protectedBranchMergeRoleTarget(String project, String name) {
    return 'プロジェクト $project: $name';
  }

  @override
  String protectedBranchMergeRoleCurrent(String role) {
    return '現在のマージ権限: $role';
  }

  @override
  String get protectedBranchMergeRoleNone => 'なし';

  @override
  String get protectedBranchMergeRoleDeveloper => '開発者とメンテナー';

  @override
  String get protectedBranchMergeRoleMaintainer => 'メンテナー';

  @override
  String get protectedBranchMergeRoleWarning =>
      'マージ権限の変更は、このルールに一致するすべてのブランチに影響します。ワイルドカードは複数のブランチとマージリクエストの作業に影響する場合があります。';

  @override
  String get protectedBranchMergeRoleAcknowledge =>
      '一致するブランチのマージ権限が変更されることを理解しました。';

  @override
  String get protectedBranchMergeRoleSave => 'マージ権限を保存';

  @override
  String get protectedBranchMergeRoleReload => 'ルールを再確認';

  @override
  String get protectedBranchMergeRoleSuccess => 'マージ権限を更新しました。';

  @override
  String get protectedBranchMergeRoleAuth => 'ルールを変更する前に再度サインインしてください。';

  @override
  String get protectedBranchMergeRoleForbidden => 'マージ権限を変更する権限がありません。';

  @override
  String get protectedBranchMergeRoleUnavailable =>
      'このルールは利用できません。続行する前に一覧を確認してください。';

  @override
  String get protectedBranchMergeRoleStale => 'ルールが変更されました。続行する前に再確認してください。';

  @override
  String get protectedBranchMergeRoleRateLimited =>
      'GitLabがリクエストを制限しています。再試行前にルールを確認してください。';

  @override
  String get protectedBranchMergeRoleError =>
      '変更を確認できませんでした。再試行前にルールを確認してください。';

  @override
  String get protectedBranchMergeRoleSessionChanged =>
      'アカウントが変更されました。このダイアログを閉じてルールを開き直してください。';

  @override
  String get protectedBranchPushRoleEditTitle => 'プッシュ権限を編集';

  @override
  String protectedBranchPushRoleTarget(String project, String name) {
    return 'プロジェクト $project: $name';
  }

  @override
  String protectedBranchPushRoleCurrent(String role) {
    return '現在のプッシュ権限: $role';
  }

  @override
  String get protectedBranchPushRoleNone => 'なし';

  @override
  String get protectedBranchPushRoleDeveloper => '開発者とメンテナー';

  @override
  String get protectedBranchPushRoleMaintainer => 'メンテナー';

  @override
  String get protectedBranchPushRoleWarning =>
      'プッシュ権限の変更は、このルールに一致するすべてのブランチに影響します。直接コミットできる人が変わり、強制プッシュが許可されている場合は履歴を書き換えられる人も変わる可能性があります。ワイルドカードは複数のブランチに影響します。';

  @override
  String get protectedBranchPushRoleAcknowledge =>
      '一致するブランチのプッシュ権限が変更されることを理解しました。';

  @override
  String get protectedBranchPushRoleSave => 'プッシュ権限を保存';

  @override
  String get protectedBranchPushRoleReload => 'ルールを再確認';

  @override
  String get protectedBranchPushRoleSuccess => 'プッシュ権限を更新しました。';

  @override
  String get protectedBranchPushRoleAuth => 'ルールを変更する前に再度サインインしてください。';

  @override
  String get protectedBranchPushRoleForbidden => 'プッシュ権限を変更する権限がありません。';

  @override
  String get protectedBranchPushRoleUnavailable =>
      'このルールは利用できません。続行する前に一覧を確認してください。';

  @override
  String get protectedBranchPushRoleStale => 'ルールが変更されました。続行する前に再確認してください。';

  @override
  String get protectedBranchPushRoleRateLimited =>
      'GitLabがリクエストを制限しています。再試行前にルールを確認してください。';

  @override
  String get protectedBranchPushRoleError => '変更を確認できませんでした。再試行前にルールを確認してください。';

  @override
  String get protectedBranchPushRoleSessionChanged =>
      'アカウントが変更されました。このダイアログを閉じてルールを開き直してください。';

  @override
  String get protectedEnvironmentCreateTitle => '環境を保護';

  @override
  String get protectedEnvironmentCreateName => '環境名';

  @override
  String get protectedEnvironmentCreateDeveloper => '開発者とメンテナー';

  @override
  String get protectedEnvironmentCreateMaintainer => 'メンテナー';

  @override
  String get protectedEnvironmentCreateWarning =>
      'この保護設定は指定した環境にデプロイできるユーザーを変更します。承認ルールは追加されません。';

  @override
  String get protectedEnvironmentCreateAcknowledge => 'デプロイ権限の変更を理解しました。';

  @override
  String get protectedEnvironmentCreateSave => '環境を保護';

  @override
  String get protectedEnvironmentCreateReload => '環境一覧を再確認';

  @override
  String get protectedEnvironmentCreateDuplicate =>
      'この環境はすでに保護されています。続行する前に一覧を確認してください。';

  @override
  String get protectedEnvironmentCreateError =>
      '保護を確認できませんでした。再試行する前に一覧を確認してください。';

  @override
  String get protectedEnvironmentCreateForbidden => '権限がないか、この機能を利用できません。';

  @override
  String get protectedEnvironmentCreateSessionChanged =>
      'アカウントが変更されました。このダイアログを閉じて開き直してください。';

  @override
  String get protectedEnvironmentCreateSuccess => '環境を保護しました。';

  @override
  String get protectedEnvironmentCreateInvalidName =>
      'ワイルドカードを含まない正確な環境名を入力してください。';

  @override
  String get protectedEnvironmentRemoveRoleTitle => 'デプロイロールを削除';

  @override
  String get protectedEnvironmentRemoveRoleWarning =>
      'この権限を削除すると、選択したロールはデプロイできなくなる場合があります。他のデプロイ権限と承認ルールは維持され、環境の保護も続きます。';

  @override
  String get protectedEnvironmentRemoveRoleAcknowledge =>
      '選択したデプロイ権限が削除されることを理解しました。';

  @override
  String get protectedEnvironmentRemoveRoleSuccess => 'デプロイロールを削除しました。';

  @override
  String get protectedEnvironmentRemoveRoleForbidden =>
      'このデプロイ権限を削除する権限がありません。';

  @override
  String get protectedEnvironmentRemoveRoleError =>
      'デプロイ権限の削除を確認できませんでした。再試行する前にルールを確認してください。';

  @override
  String protectedEnvironmentRemoveRoleGrantLabel(String role, String id) {
    return '$role（権限 $id）';
  }

  @override
  String get protectedEnvironmentDeployRoleTitle => 'デプロイロールを追加';

  @override
  String get protectedEnvironmentDeployRoleWarning =>
      '選択したロールにデプロイ権限が付与されます。既存のデプロイ権限と承認ルールは維持されます。';

  @override
  String get protectedEnvironmentDeployRoleAcknowledge =>
      'デプロイ権限が拡大することを理解しました。';

  @override
  String get protectedEnvironmentDeployRoleSuccess => 'デプロイロールを追加しました。';

  @override
  String get protectedEnvironmentDeployRoleForbidden => 'デプロイ権限を変更する権限がありません。';

  @override
  String get protectedEnvironmentDeployRoleError =>
      'デプロイロールの変更を確認できませんでした。再試行する前にルールを確認してください。';

  @override
  String get protectedEnvironmentUnprotectTitle => '環境の保護を解除';

  @override
  String protectedEnvironmentUnprotectTarget(String project, String name) {
    return 'プロジェクト $project: $name';
  }

  @override
  String get protectedEnvironmentUnprotectWarning =>
      'このプロジェクトの保護を解除すると、以下のデプロイ許可と承認ルールがすべて削除されます。環境と過去のデプロイは残ります。グループの保護は引き続き適用される場合があります。';

  @override
  String get protectedEnvironmentUnprotectName => '正確な環境名を入力';

  @override
  String get protectedEnvironmentUnprotectAcknowledge =>
      'これらのデプロイ制限と承認ルールが削除されることを理解しました。';

  @override
  String get protectedEnvironmentUnprotectReload => 'ルールを再確認';

  @override
  String get protectedEnvironmentUnprotectAuth => 'ルールを変更する前に再度サインインしてください。';

  @override
  String get protectedEnvironmentUnprotectForbidden => 'この環境の保護を解除する権限がありません。';

  @override
  String get protectedEnvironmentUnprotectUnavailable =>
      'このルールは利用できません。続行する前に一覧を確認してください。';

  @override
  String get protectedEnvironmentUnprotectStale =>
      'ルールが変更されました。続行する前に再確認してください。';

  @override
  String get protectedEnvironmentUnprotectRateLimited =>
      'GitLabがリクエストを制限しています。再試行する前にルールを確認してください。';

  @override
  String get protectedEnvironmentUnprotectError =>
      '解除を確認できませんでした。再試行する前にルールを確認してください。';

  @override
  String get protectedEnvironmentUnprotectSessionChanged =>
      'アカウントが変更されました。このダイアログを閉じてルールを開き直してください。';

  @override
  String get protectedEnvironmentUnprotectSuccess => '環境の保護を解除しました。';

  @override
  String get protectedEnvironmentUnprotectUnreported => 'アクセス項目';

  @override
  String get containerPolicyStatus => '状態';

  @override
  String get containerPolicyTitle => 'クリーンアップポリシー';

  @override
  String get containerPolicyAbsent => 'GitLab からクリーンアップポリシーが報告されていません。';

  @override
  String get containerPolicyHint =>
      'このプロジェクトのすべてのコンテナイメージリポジトリに適用される読み取り専用設定です。一致するタグを非同期で削除し、保持ルール、latest、保護されたタグと不変タグを維持します。複数回の実行が必要な場合があり、タグの削除ではイメージ容量は解放されません。';

  @override
  String get containerPolicyNextRun => 'GitLab が報告した次回実行日時（現地時間）';

  @override
  String containerPolicyDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString日',
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
      other: '$countStringか月',
    );
    return '$_temp0';
  }

  @override
  String get containerPolicyEnabled => '有効';

  @override
  String get containerPolicyDisabled => '無効';

  @override
  String get containerPolicyNotReported => '未報告';

  @override
  String get containerPolicyCadence => '実行間隔';

  @override
  String get containerCreateTitle => 'クリーンアップポリシーを作成';

  @override
  String get containerCreateSave => '無効なポリシーの作成を確認';

  @override
  String get containerCreateWarning =>
      'すべてのイメージリポジトリのクリーンアップ条件を保存します。有効化を選択しない限り無効のままです。既定の保持パターン .* はすべてのタグを保持し、空の保持パターンはパターンによる保持を行いません。パターンは入力どおり送信され、GitLab RE2でタグ全体に一致します。無効時は検証が後回しになる場合があります。受理は処理完了や容量の解放を意味しません。';

  @override
  String get containerCreateAcknowledge => '条件を確認し、このポリシーが無効のままであることを理解しました。';

  @override
  String get containerCreateExisting =>
      'このプロジェクトには既存のクリーンアップポリシーがあります。作成では上書きしません。既存の設定を使用してください。';

  @override
  String get containerCreateUnknown =>
      'GitLab がポリシーの有無を報告していません。GitLab で確認してください。作成はできません。';

  @override
  String get containerCreateAccepted => 'クリーンアップポリシーの作成が受理されました。';

  @override
  String get containerCreateInvalid =>
      'GitLab が設定を拒否しました。条件を確認し、編集するか再試行してください。';

  @override
  String get containerCreateDaily => '毎日';

  @override
  String get containerCreateWeekly => '毎週';

  @override
  String get containerCreateFortnightly => '2週間ごと';

  @override
  String get containerCreateMonthly => '毎月';

  @override
  String get containerCreateQuarterly => '3か月ごと';

  @override
  String containerCreateDays(int days) {
    return '$days日';
  }

  @override
  String get containerPolicyKeepCount => 'イメージごとに保持する一致タグ数';

  @override
  String get containerCreateEnable => '作成時にクリーンアップを有効化';

  @override
  String get containerCreateEnabledWarning =>
      '有効なポリシーは、スケジュールに従い、このプロジェクトのすべてのイメージリポジトリから一致するタグを完全に削除する可能性があります。実行間隔、保持数、期間、両方のパターンを確認してください。保護されたタグや不変タグの除外はGitLabが決定します。保存は削除や容量解放の完了を意味しません。';

  @override
  String get containerCreateEnabledAcknowledge =>
      'すべての条件を確認し、プロジェクト全体で一致するタグが定期的に完全削除されることに同意します。';

  @override
  String get containerCreateEnabledSave => '有効なポリシーの作成を確認';

  @override
  String get containerCreateSessionChanged =>
      'アカウントが変更されました。このダイアログを閉じて開き直し、現在のプロジェクトを確認してからポリシーを作成してください。';

  @override
  String get containerPolicyAge => '次の期間より古いタグを削除';

  @override
  String get containerPolicyDeletePattern => '削除パターン';

  @override
  String get containerPolicyLegacyPattern => '削除パターン（従来）';

  @override
  String get containerPolicyKeepPattern => '保持パターン';

  @override
  String get containerPolicyEmptyPattern => '空のパターン';

  @override
  String get containerPolicyError => 'クリーンアップポリシーを読み込めませんでした。';

  @override
  String get containerPolicyForbidden => 'このプロジェクトのクリーンアップポリシーを表示する権限がありません。';

  @override
  String get containerPolicyUnavailable =>
      'プロジェクトにアクセスできないか、クリーンアップポリシー情報が利用できません。';

  @override
  String get containerPolicyEmptySetting => '空の設定値';

  @override
  String containerActivationTarget(String projectId) {
    return 'プロジェクト $projectId — すべてのイメージリポジトリ';
  }

  @override
  String get containerActivationError => '更新を確認できませんでした。ポリシーを再読み込みして再試行してください。';

  @override
  String get containerActivationIncomplete =>
      'クリーンアップを有効化するには、実行間隔、保持数、期間制限、削除パターンが報告されている必要があります。GitLab でポリシーを確認してください。';

  @override
  String get containerActivationTitle => 'クリーンアップポリシーの状態を変更';

  @override
  String get containerActivationEnable => 'クリーンアップを有効化';

  @override
  String get containerActivationDisable => 'クリーンアップを無効化';

  @override
  String get containerActivationEnableWarning =>
      'プロジェクト全体のポリシーを有効化すると、定期実行で一致するタグが完全に削除される可能性があります。表示された保持設定とパターンは変更しません。タグの削除ではイメージ容量は解放されません。';

  @override
  String get containerActivationDisableWarning =>
      '保持設定やパターンを変更せず、このプロジェクトの今後の定期クリーンアップを無効化します。実行中のジョブがキャンセルされるとは限りません。';

  @override
  String get containerActivationUnknown =>
      '既知の有効化状態が必要です。GitLab でポリシー設定を確認してください。';

  @override
  String get containerActivationInvalid =>
      'GitLab が状態変更を拒否しました。GitLab で既存のポリシー設定を確認してください。';

  @override
  String get containerActivationAccepted => 'クリーンアップポリシーの状態更新が受け付けられました。';

  @override
  String get containerActivationForbidden => 'このクリーンアップポリシーを変更する権限がありません。';

  @override
  String get containerActivationStale =>
      'ポリシーが変更されたか、報告されなくなりました。保存する前に再読み込みして確認してください。';

  @override
  String get containerActivationReload => 'ポリシーを再読み込み';

  @override
  String get containerActivationRateLimited =>
      'リクエストが多すぎます。しばらく待ち、ポリシーを再読み込みして再試行してください。';

  @override
  String get containerCadenceTitle => 'クリーンアップ間隔を編集';

  @override
  String get containerCadenceSave => '間隔の変更を確認';

  @override
  String get containerCadenceSelect => '新しい間隔 (GitLab API)';

  @override
  String get containerCadenceWarning =>
      'プロジェクト全体の間隔変更は、すべてのイメージリポジトリで今後のタグ削除に影響します。以下の有効状態と削除・保持条件を確認してください。これらの設定は変更されず、削除完了も意味しません。';

  @override
  String get containerCadenceUnknown =>
      '有効状態、間隔、保持数、期限、削除パターンの報告が必要です。不足する設定をGitLabで確認してください。新しいポリシーは作成しません。';

  @override
  String get containerCadenceAccepted => 'クリーンアップ間隔の更新が受理されました。';

  @override
  String get containerTagProtectionTitle => 'タグ保護ルール';

  @override
  String get containerTagProtectionCreateTitle => 'タグ保護ルールを作成';

  @override
  String get containerTagProtectionCreateSave => 'ルールを作成';

  @override
  String get containerTagProtectionCreatePattern => 'タグ名パターン';

  @override
  String get containerTagProtectionCreatePush => '最低プッシュロール';

  @override
  String get containerTagProtectionCreateDelete => '最低削除ロール';

  @override
  String get containerTagProtectionCreateUnset => 'ロールを選択';

  @override
  String get containerTagProtectionCreateWarning =>
      'このプロジェクト全体のルールは正確なglobパターンに一致するタグのプッシュと削除を制限します。ワイルドカードは多くのタグに影響し、既存のリリースやクリーンアップを妨げる可能性があります。両方のロールが必須です。他のルールと権限は引き続き適用され、この値は自分のアクセス権を示したりイメージを削除したりするものではありません。';

  @override
  String get containerTagProtectionCreateAcknowledge =>
      '正確なタグパターンと両方のロールを確認し、一致するタグへの影響を理解しました。';

  @override
  String containerTagProtectionCreateProject(String projectId) {
    return 'プロジェクト $projectId';
  }

  @override
  String get containerTagProtectionCreateForbidden => 'このルールを作成する権限がありません。';

  @override
  String get containerTagProtectionCreateInvalid =>
      'タグパターンまたはロールが拒否されました。必須の両ロールを確認して再試行してください。';

  @override
  String get containerTagProtectionCreateError =>
      'タグルールの作成を確認できませんでした。再試行前にルール一覧を確認してください。サーバーが要求を受理した可能性があります。';

  @override
  String get containerTagProtectionCreateSaved => 'タグルールを作成しました。';

  @override
  String get containerTagProtectionCreateUnavailable =>
      'タグルールの作成にはGitLab 18.8以降とアクセス可能なプロジェクトが必要です。';

  @override
  String get containerTagProtectionCreateRateLimited =>
      '要求が多すぎます。待ってから再試行してください。';

  @override
  String get containerTagProtectionEmpty => 'タグ保護ルールはありません。';

  @override
  String get containerTagProtectionError => 'タグ保護ルールを読み込めませんでした。';

  @override
  String get containerTagProtectionForbidden => 'タグ保護ルールを表示する権限がありません。';

  @override
  String get containerTagProtectionUnavailable =>
      'このインスタンスでタグ保護ルールが利用できないか、プロジェクトにアクセスできません。';

  @override
  String containerTagProtectionPushRole(String role) {
    return 'プッシュの最低ロール: $role';
  }

  @override
  String get containerTagProtectionPushRoleTitle => '最低プッシュロールを編集';

  @override
  String get containerTagProtectionPushRoleSave => 'プッシュロールを保存';

  @override
  String get containerTagProtectionPushRoleWarning =>
      '最低プッシュロールを変更すると、プロジェクト内の一致するコンテナイメージタグをプッシュできる対象が変わります。低いロールは保護を弱め、高いロールは既存のワークフローを妨げる場合があります。タグパターンと最低削除ロールは維持され、他のルールと権限も引き続き適用されます。タグやイメージは削除されず、Gitタグには影響せず、現在のアクセス権も示しません。';

  @override
  String get containerTagProtectionPushRoleAcknowledge =>
      'ルールと新しい最低プッシュロールを確認し、アクセスの変更を理解しました。';

  @override
  String containerTagProtectionPushRoleTarget(String projectId, String ruleId) {
    return 'プロジェクト $projectId — ルール $ruleId';
  }

  @override
  String get containerTagProtectionPushRoleForbidden => 'このルールを変更する権限がありません。';

  @override
  String get containerTagProtectionPushRoleError =>
      'プッシュロールの更新を確認できませんでした。再試行前にルール一覧を確認してください。サーバーが要求を受理した可能性があります。';

  @override
  String get containerTagProtectionPushRoleStale =>
      '確認後にルールが変更されました。再読み込みして確認してから保存してください。';

  @override
  String get containerTagProtectionPushRoleReload => 'ルールを再読み込み';

  @override
  String get containerTagProtectionPushRoleSaved => '最低プッシュロールを更新しました。';

  @override
  String get containerTagProtectionPushRoleMissing =>
      'ルールが存在しないか、重複しているか、アクセスできないか、未対応です。編集にはGitLab 18.9以降が必要です。再読み込みして確認してください。';

  @override
  String get containerTagProtectionPushRoleRateLimited =>
      '要求が多すぎます。待ってから再試行してください。';

  @override
  String get containerTagProtectionPushRoleInvalid =>
      'プッシュロールが拒否されました。対応するロールを選んで再試行してください。';

  @override
  String get containerTagProtectionPushRoleDraft => '新しい最低プッシュロール';

  @override
  String get containerTagProtectionPushRoleSelect => 'プッシュロールを選択';

  @override
  String get containerTagProtectionPushRoleUnknown =>
      '現在のプッシュロールは不明です。未対応の設定を上書きしないよう編集を無効にしています。';

  @override
  String containerTagProtectionDeleteRole(String role) {
    return '削除の最低ロール: $role';
  }

  @override
  String get containerTagProtectionDeleteRoleTitle => '最低削除ロールを編集';

  @override
  String get containerTagProtectionDeleteRoleSave => '削除ロールを保存';

  @override
  String get containerTagProtectionDeleteRoleWarning =>
      '最低削除ロールを変更すると、プロジェクト内の一致するコンテナイメージタグを削除できる対象が変わります。低いロールは削除保護を弱め、高いロールは既存のクリーンアップを妨げる場合があります。タグパターンと最低プッシュロールは維持され、他のルールと権限も引き続き適用されます。保存してもタグやイメージは削除されず、Gitタグに影響せず、現在のアクセス権も示しません。';

  @override
  String get containerTagProtectionDeleteRoleAcknowledge =>
      'ルールと新しい最低削除ロールを確認し、アクセスの変更を理解しました。';

  @override
  String containerTagProtectionDeleteRoleTarget(
    String projectId,
    String ruleId,
  ) {
    return 'プロジェクト $projectId — ルール $ruleId';
  }

  @override
  String get containerTagProtectionDeleteRoleForbidden => 'このルールを変更する権限がありません。';

  @override
  String get containerTagProtectionDeleteRoleError =>
      '削除ロールの更新を確認できませんでした。再試行前にルール一覧を確認してください。サーバーが要求を受理した可能性があります。';

  @override
  String get containerTagProtectionDeleteRoleStale =>
      '確認後にルールが変更されました。再読み込みして確認してから保存してください。';

  @override
  String get containerTagProtectionDeleteRoleReload => 'ルールを再読み込み';

  @override
  String get containerTagProtectionDeleteRoleSaved => '最低削除ロールを更新しました。';

  @override
  String get containerTagProtectionDeleteRoleMissing =>
      'ルールが存在しないか、重複しているか、アクセスできないか、未対応です。編集にはGitLab 18.9以降が必要です。再読み込みして確認してください。';

  @override
  String get containerTagProtectionDeleteRoleRateLimited =>
      '要求が多すぎます。待ってから再試行してください。';

  @override
  String get containerTagProtectionDeleteRoleInvalid =>
      '削除ロールが拒否されました。対応するロールを選んで再試行してください。';

  @override
  String get containerTagProtectionDeleteRoleDraft => '新しい最低削除ロール';

  @override
  String get containerTagProtectionDeleteRoleSelect => '削除ロールを選択';

  @override
  String get containerTagProtectionDeleteRoleUnknown =>
      '現在の削除ロールは不明です。未対応の設定を上書きしないよう編集を無効にしています。';

  @override
  String get containerTagProtectionRoleUnset => 'ルールで未指定';

  @override
  String get containerTagProtectionRoleAdmin => '管理者';

  @override
  String get containerTagProtectionHint =>
      'Git タグではなくコンテナイメージタグのルールです。最低ロールは現在のアクセス権限を保証しません。表示には GitLab 18.7 以降、作成には 18.8 以降、編集には 18.9 以降が必要です。';

  @override
  String get containerTagProtectionPatternTitle => 'タグ保護パターンを編集';

  @override
  String get containerTagProtectionPatternSave => 'パターンを保存';

  @override
  String get containerTagProtectionPatternWarning =>
      'パターンを変更すると、プロジェクト内で従来一致していたコンテナイメージタグの保護が解除され、他のタグに適用される場合があります。ワイルドカード(*)は複数のタグに影響します。両方の最低ロールは維持され、他のルールと権限も引き続き適用されます。タグやイメージは削除されず、Gitタグに影響せず、現在のアクセス権を示しません。';

  @override
  String get containerTagProtectionPatternAcknowledge =>
      '現在のルールと新しいパターンを確認し、保護の変更を理解しました。';

  @override
  String containerTagProtectionPatternTarget(String projectId, String ruleId) {
    return 'プロジェクト $projectId — ルール $ruleId';
  }

  @override
  String get containerTagProtectionPatternForbidden => 'このルールを変更する権限がありません。';

  @override
  String get containerTagProtectionPatternError =>
      'パターンの更新を確認できません。サーバーで処理された可能性があるため、再試行前にルール一覧を確認してください。';

  @override
  String get containerTagProtectionPatternStale =>
      '確認後にルールが変更されました。保存前に再読み込みして確認してください。';

  @override
  String get containerTagProtectionPatternReload => 'ルールを再読み込み';

  @override
  String get containerTagProtectionPatternSaved => 'タグ保護パターンを更新しました。';

  @override
  String get containerTagProtectionPatternMissing =>
      'ルールが存在しないか、重複しているか、アクセスできないか、未対応です。編集にはGitLab 18.9以降が必要です。再読み込みして確認してください。';

  @override
  String get containerTagProtectionRemoveTitle => 'タグ保護ルールを削除';

  @override
  String get containerTagProtectionRemoveSave => 'ルールを削除';

  @override
  String get containerTagProtectionRemoveWarning =>
      'このルールを削除すると、プロジェクト内の一致するコンテナイメージタグのプッシュと削除の保護が解除されます。他のルールと権限は引き続き適用されます。タグやイメージは削除されず、Gitタグにも影響しません。';

  @override
  String get containerTagProtectionRemoveAcknowledge => '内容を理解し、このルールを削除します。';

  @override
  String containerTagProtectionRemoveTarget(String projectId, String ruleId) {
    return 'プロジェクト $projectId — ルール $ruleId';
  }

  @override
  String get containerTagProtectionRemoveForbidden => 'このルールを削除する権限がありません。';

  @override
  String get containerTagProtectionRemoveError =>
      '要求は失敗しましたが、サーバーに届いた可能性があります。再試行前にルール一覧を確認してください。';

  @override
  String get containerTagProtectionRemoveStale =>
      'ルールが変更されたか重複しています。再読み込みして確認してください。';

  @override
  String get containerTagProtectionRemoveReload => 'ルールを再読み込み';

  @override
  String get containerTagProtectionRemoveSaved => 'タグ保護ルールを削除しました。';

  @override
  String get containerTagProtectionRemoveMissing =>
      'ルールが存在しないか、アクセスできないか、未対応です。削除にはGitLab 18.9以降が必要です。続行前に再読み込みしてください。';

  @override
  String get containerTagProtectionRemoveRateLimited =>
      '要求が多すぎます。しばらく待って再試行してください。';

  @override
  String get containerTagProtectionPatternRateLimited =>
      '要求が多すぎます。しばらく待って再試行してください。';

  @override
  String get containerTagProtectionPatternInvalid =>
      'パターンが拒否されたか、既に使用されています。下書きを編集して再試行してください。';

  @override
  String get containerTagProtectionPatternDraft => '新しいコンテナタグパターン';

  @override
  String get containerTagDelete => 'タグを削除';

  @override
  String get containerTagDeleteConfirmTitle => 'コンテナタグを削除しますか？';

  @override
  String containerTagDeleteConfirmBody(String tagName, String path) {
    return '「$path」のタグ「$tagName」を削除しますか？この操作は取り消せません。';
  }

  @override
  String get containerTagDeleteWarning =>
      'タグのみが削除され、画像のブロブは削除されません。タグを削除してもディスク容量は解放されません。';

  @override
  String get containerCleanupTitle => 'タグを整理';

  @override
  String containerCleanupTarget(String projectId, String repositoryId) {
    return 'プロジェクト $projectId、イメージリポジトリ $repositoryId';
  }

  @override
  String get containerCleanupWarning =>
      '一致するタグは完全に削除されます。latest と保護されたタグは除外されます。保持パターンは削除パターンより優先されます。';

  @override
  String get containerCleanupLimits =>
      '整理はリポジトリごとに最大1時間に1回、非同期で実行され、一部のタグのみ削除される場合があります。期間と順序はプッシュ日時ではなくマニフェスト作成日時に基づきます。タグの削除でイメージの容量は解放されません。';

  @override
  String get containerCleanupDeletePattern => '削除パターン（RE2、必須）';

  @override
  String get containerCleanupKeepPattern => '保持パターン（RE2、任意）';

  @override
  String get containerCleanupKeepCount => '最新の一致タグを保持する数（任意）';

  @override
  String get containerCleanupAge => '次の期間より古いタグのみ削除';

  @override
  String get containerCleanupNoAge => '期間の制限なし';

  @override
  String get containerCleanupDay => '1日';

  @override
  String get containerCleanupWeek => '7日';

  @override
  String get containerCleanupMonth => '1か月';

  @override
  String get containerCleanupRequired => '削除パターンを明示的に入力してください。';

  @override
  String get containerCleanupCountError => '0以上の整数を入力するか、空欄にしてください。';

  @override
  String get containerCleanupSchedule => '整理を予約';

  @override
  String get containerCleanupScheduled =>
      '整理を予約しました。処理が完了するまでタグが残る場合があります。後で更新して確認してください。';

  @override
  String get containerCleanupError => '整理を予約できませんでした。接続を確認して再試行してください。';

  @override
  String get containerCleanupForbidden => 'このリポジトリのタグを整理する権限がありません。';

  @override
  String get containerCleanupRateLimited =>
      '整理の回数が制限されています。リポジトリごとに最大1時間に1回です。後で再試行してください。';

  @override
  String get containerCleanupInvalid =>
      'GitLab が整理条件を拒否しました。RE2 パターンと保持設定を確認してください。';

  @override
  String get containerTagDeleteForbidden =>
      'このタグを削除できません。保護されているか、権限がない可能性があります。';

  @override
  String get containerTagDeleteError => 'タグを削除できませんでした。再試行してください。';

  @override
  String get containerImmutabilityTitle => 'イミュータブルタグのルール';

  @override
  String get containerImmutabilityEmpty => 'イミュータブルタグのルールはありません。';

  @override
  String get containerImmutabilityError =>
      'ルールを読み込めませんでした。インスタンスの対応状況を確認して再試行してください。';

  @override
  String get containerImmutabilityForbidden => 'イミュータブルタグのルールを表示する権限がありません。';

  @override
  String get containerImmutabilityUnavailable =>
      'プロジェクトまたはルール一覧を利用できません。アクセス権、サブスクリプション、インスタンスの対応状況を確認してください。';

  @override
  String get containerImmutabilityHint =>
      'イミュータブルタグにはUltimateと対応するレジストリが必要です。パターンはプロジェクトのすべてのコンテナリポジトリに適用され、クリーンアップポリシーを含め、一致するタグの上書きと削除を防ぎます。ルールの表示だけでは個々のタグの現在の保護状態は確認できません。変更の反映には時間がかかる場合があります。';

  @override
  String get containerImmutabilityCreateTitle => '不変ルールを作成';

  @override
  String get containerImmutabilityCreateButton => 'ルールを作成';

  @override
  String get containerImmutabilityCreated => '不変ルールを作成しました。';

  @override
  String get containerImmutabilityPattern => 'タグパターン';

  @override
  String get containerImmutabilityPatternHint =>
      '100文字以内のRE2パターンを入力してください。空白は保持され、構文はGitLabが検証します。';

  @override
  String containerImmutabilityProject(String projectId) {
    return 'プロジェクト $projectId';
  }

  @override
  String get containerImmutabilityImpact =>
      'Owner権限、Ultimate、対応レジストリが必要です。このパターンはプロジェクト内のすべてのコンテナリポジトリに適用されます。一致するタグはクリーンアップポリシーでも上書きや削除ができません。不変ルールが存在する間、マニフェストの直接削除も禁止されます。ルールは編集できず、変更の反映には時間がかかる場合があります。';

  @override
  String get containerImmutabilityAcknowledge =>
      'プロジェクト全体の保護とワークフローへの影響を理解しました。';

  @override
  String get containerImmutabilityUncertain =>
      '作成結果を確認できません。既に成功している可能性があるため、再試行前に現在のルールを確認してください。';

  @override
  String get containerImmutabilityInspect => '現在のルールを確認';

  @override
  String get containerImmutabilityRejected =>
      'GitLabが要求を拒否したか、同じパターンの不変ルールが既に存在します。現在のルール、パターン、プロジェクトの制限を確認してください。';

  @override
  String get containerImmutabilityAuth =>
      'セッションが拒否されました。ルールを作成する前に再度サインインしてください。';

  @override
  String get containerImmutabilityAccountChanged =>
      'アカウントが変更されました。このダイアログを閉じ、選択したアカウントで開き直してください。';

  @override
  String get containerImmutabilityDeleteTitle => '不変ルールを削除';

  @override
  String get containerImmutabilityDeleteButton => 'ルールを削除';

  @override
  String get containerImmutabilityDeleteDone => '不変ルールを削除しました。';

  @override
  String containerImmutabilityDeleteProject(String projectId) {
    return 'プロジェクト $projectId';
  }

  @override
  String get containerImmutabilityDeleteRuleId => 'ルールID';

  @override
  String get containerImmutabilityDeleteConfirm => 'パターンを正確に入力してください';

  @override
  String get containerImmutabilityDeleteImpact =>
      'このルールを削除すると、プロジェクト内のすべてのコンテナリポジトリでこの保護が解除されます。一致するタグは上書きやクリーンアップポリシーによる削除が可能になる場合があります。最後の不変ルールを削除すると、マニフェストの直接削除が許可される場合があります。他のルールや権限は引き続き適用されます。画像やタグ自体は削除しません。Owner権限が必要で、変更の反映には時間がかかる場合があります。';

  @override
  String get containerImmutabilityDeleteAcknowledge =>
      'プロジェクト全体で保護が失われる影響を理解しました。';

  @override
  String get containerImmutabilityDeleteUncertain =>
      '削除結果を確認できません。既に成功している可能性があります。再試行前にルールを再読み込みしてください。';

  @override
  String get containerImmutabilityDeleteReload => 'ルールを再読み込み';

  @override
  String get containerImmutabilityDeleteRejected =>
      'ルールが変更されたか、GitLabが要求を拒否しました。再試行前に現在のルールを再読み込みして確認してください。';

  @override
  String get containerImmutabilityDeleteAuth =>
      'セッションが拒否されました。ルールを削除する前に再度サインインしてください。';

  @override
  String get containerImmutabilityDeleteAccountChanged =>
      'アカウントが変更されました。このダイアログを閉じ、選択したアカウントで開き直してください。';

  @override
  String containerTagProtectionPushClearTarget(
    String projectId,
    String ruleId,
  ) {
    return 'プロジェクト $projectId — ルール $ruleId';
  }

  @override
  String containerTagProtectionDeleteClearTarget(
    String projectId,
    String ruleId,
  ) {
    return 'プロジェクト $projectId — ルール $ruleId';
  }

  @override
  String get containerTagProtectionDeleteClearForbidden =>
      'このルールを変更する権限がありません。';

  @override
  String get containerTagProtectionDeleteClearStale =>
      '確認後にルールが変更されました。再読み込みして確認してから保存してください。';

  @override
  String get containerTagProtectionDeleteClearReload => 'ルールを再読み込み';

  @override
  String get containerTagProtectionDeleteClearMissing =>
      'ルールが存在しない、重複している、アクセスできない、またはこのインスタンスが更新をサポートしていません（GitLab 18.9以降）。確認前に再読み込みしてください。';

  @override
  String get containerTagProtectionDeleteClearRateLimited =>
      '要求が多すぎます。待ってから再試行してください。';

  @override
  String get containerTagProtectionDeleteClearTitle => '最低削除ロールを解除';

  @override
  String get containerTagProtectionDeleteClearSave => '削除制限を解除';

  @override
  String get containerTagProtectionDeleteClearWarning =>
      'このルールの最低削除ロール制限を解除し、プロジェクト全体で一致するコンテナタグの削除保護を弱めます。タグのパターンと最低プッシュロールは変わりません。他のルールと権限は引き続き適用され、全員にアクセスを許可したりタグやイメージを削除したりするものではありません。';

  @override
  String get containerTagProtectionDeleteClearAcknowledge =>
      'ルールを確認し、この削除制限を解除する影響を理解しました。';

  @override
  String get containerTagProtectionDeleteClearError =>
      '削除制限の解除を確認できませんでした。再試行前にルール一覧を確認してください。サーバーが要求を受理した可能性があります。';

  @override
  String get containerTagProtectionDeleteClearSaved => '最低削除ロール制限を解除しました。';

  @override
  String get containerTagProtectionDeleteClearInvalid =>
      'サーバーが削除制限の解除を拒否しました。ルールを確認して再試行してください。';

  @override
  String get containerTagProtectionDeleteClearBlocked =>
      '解除には対応する現在の削除ロールと空でないプッシュロールが必要です。解除済みまたは不明な設定は解除できません。';

  @override
  String get containerTagProtectionPushClearForbidden => 'このルールを変更する権限がありません。';

  @override
  String get containerTagProtectionPushClearStale =>
      '確認後にルールが変更されました。再読み込みして確認してから保存してください。';

  @override
  String get containerTagProtectionPushClearReload => 'ルールを再読み込み';

  @override
  String get containerTagProtectionPushClearMissing =>
      'ルールが存在しないか、重複しているか、アクセスできないか、未対応です。編集にはGitLab 18.9以降が必要です。再読み込みして確認してください。';

  @override
  String get containerTagProtectionPushClearRateLimited =>
      '要求が多すぎます。待ってから再試行してください。';

  @override
  String get containerTagProtectionPushClearTitle => '最低プッシュロールを解除';

  @override
  String get containerTagProtectionPushClearSave => 'プッシュ制限を解除';

  @override
  String get containerTagProtectionPushClearWarning =>
      'このルールの最低プッシュロール制限を解除すると、プロジェクト内の一致するコンテナイメージタグのプッシュ保護が弱まります。タグパターンと最低削除ロールは維持され、他のルールと権限も引き続き適用されます。全員にアクセス権を与えることはなく、タグやイメージは削除されず、Gitタグにも影響しません。';

  @override
  String get containerTagProtectionPushClearAcknowledge =>
      'ルールを確認し、このプッシュ制限を解除する影響を理解しました。';

  @override
  String get containerTagProtectionPushClearError =>
      'プッシュ制限の解除を確認できませんでした。再試行前にルール一覧を確認してください。サーバーが要求を受理した可能性があります。';

  @override
  String get containerTagProtectionPushClearSaved => '最低プッシュロール制限を解除しました。';

  @override
  String get containerTagProtectionPushClearInvalid =>
      'サーバーがプッシュ制限の解除を拒否しました。ルールを確認して再試行してください。';

  @override
  String get containerTagProtectionPushClearBlocked =>
      '解除には対応する現在のプッシュロールと空でない削除ロールが必要です。解除済みまたは不明な設定は解除できません。';

  @override
  String get packageFileDelete => 'ファイルを削除';

  @override
  String get packageFileDeleteConfirmTitle => 'パッケージファイルを削除しますか？';

  @override
  String packageFileDeleteConfirmBody(String fileName, String packageName) {
    return '「$packageName」から「$fileName」を削除しますか？この操作は取り消せません。';
  }

  @override
  String get packageFileDeleteWarning =>
      'ファイルを削除するとパッケージが破損し、使用やパッケージマネージャーからの取得ができなくなる可能性があります。';

  @override
  String get packageFileDeleteForbidden =>
      'このファイルを削除できません。パッケージが保護されているか、権限がない可能性があります。';

  @override
  String get packageFileDeleteError => 'ファイルを削除できませんでした。再試行してください。';

  @override
  String get containerRepositoryDelete => 'リポジトリを削除';

  @override
  String get containerRepositoryDeleteConfirmTitle => 'イメージリポジトリを削除しますか？';

  @override
  String containerRepositoryDeleteConfirmBody(String path) {
    return '「$path」とすべてのタグを削除しますか？この操作は取り消せません。';
  }

  @override
  String get containerRepositoryDeleteWarning =>
      '削除は非同期で予約され、時間がかかる場合があります。レジストリを更新して進行状況を確認してください。';

  @override
  String get containerRepositoryDeleteForbidden =>
      'このリポジトリを削除できません。権限と保護ルールを確認してください。';

  @override
  String get containerRepositoryDeleteError => 'リポジトリの削除を予約できませんでした。再試行してください。';

  @override
  String get containerRepositoryDeletionScheduled => '削除予約済み';

  @override
  String get containerRepositoryDeletionNotice =>
      'リポジトリの削除が予約されました。更新して進行状況を確認してください。';

  @override
  String get containerKeepCountTitle => 'クリーンアップ保持数を編集';

  @override
  String get containerKeepCountSave => '保持数の変更を確認';

  @override
  String get containerKeepCountSelect => 'イメージごとに保持する一致タグ数';

  @override
  String get containerKeepCountWarning =>
      'プロジェクト全体の保持数を減らすと、定期クリーンアップで各イメージリポジトリの一致タグがさらに多く完全に削除される可能性があります。以下の有効状態と削除条件を確認してください。他の設定は変更されず、削除完了も意味しません。';

  @override
  String get containerKeepCountUnknown =>
      '有効状態、間隔、保持数、期限、削除パターンの報告が必要です。不足する設定をGitLabで確認してください。新しいポリシーは作成しません。';

  @override
  String get containerKeepCountAccepted => 'クリーンアップ保持数の更新が受理されました。';

  @override
  String get protectedBranchUnprotectTitle => 'ブランチルールの保護を解除';

  @override
  String protectedBranchUnprotectTarget(String project, String name) {
    return 'プロジェクト $project: $name';
  }

  @override
  String get protectedBranchUnprotectWarning =>
      'このルールを削除すると、プッシュやマージが許可され、CI の動作が変わる場合があります。ワイルドカードは複数のブランチに影響します。';

  @override
  String get protectedBranchUnprotectName => '正確なルール名を入力';

  @override
  String get protectedBranchUnprotectAcknowledge => '対象ブランチへの影響を理解しました。';

  @override
  String get protectedBranchUnprotectReload => 'ルールを再確認';

  @override
  String get protectedBranchUnprotectSuccess => 'ブランチルールを削除しました。';

  @override
  String get protectedBranchUnprotectAuth => 'このルールを変更するには再度サインインしてください。';

  @override
  String get protectedBranchUnprotectForbidden => 'このルールを削除する権限がありません。';

  @override
  String get protectedBranchUnprotectUnavailable =>
      'このルールは利用できません。続行する前に一覧を確認してください。';

  @override
  String get protectedBranchUnprotectStale => 'ルールが変更されました。続行する前に再確認してください。';

  @override
  String get protectedBranchUnprotectRateLimited =>
      'GitLab がリクエストを制限しています。再試行前にルールを確認してください。';

  @override
  String get protectedBranchUnprotectError =>
      'ルールが削除されたか確認できません。再試行前に確認してください。';

  @override
  String get protectedBranchUnprotectSessionChanged =>
      'アカウントが変わりました。ダイアログを閉じてルールを開き直してください。';

  @override
  String get containerKeepPatternTitle => 'クリーンアップ保持パターンを編集';

  @override
  String get containerKeepPatternSave => '保持パターンの変更を確認';

  @override
  String get containerKeepPatternSelect => '新しい保持パターン (GitLab RE2)';

  @override
  String get containerKeepPatternWarning =>
      'プロジェクト全体の保持パターンを狭めると、定期クリーンアップで各リポジトリの以前保持されたタグが完全削除の対象になる可能性があります。以下の有効状態と削除・保持条件を確認してください。GitLabはRE2を使い、タグ名全体にパターンを適用します。入力はそのまま送信されGitLabが検証します。他の設定は変更されず、受理は削除完了を意味しません。空の入力ではパターンを消去しません。';

  @override
  String get containerKeepPatternUnknown =>
      '有効状態、間隔、保持数、期限、有効な削除・保持パターンの報告が必要です。報告された空の保持パターンは変更できますが、未報告の値は変更できません。不足する設定をGitLabで確認してください。新しいポリシーは作成しません。';

  @override
  String get containerKeepPatternAccepted => 'クリーンアップ保持パターンの更新が受理されました。';

  @override
  String get containerKeepPatternInvalid =>
      'GitLabが保持パターンを拒否しました。RE2構文と既存のポリシーを確認し、編集または再試行してください。';

  @override
  String get containerProtectionPatternTitle => 'リポジトリ保護パターンを編集';

  @override
  String get containerProtectionPatternSave => 'パターンを保存';

  @override
  String get containerProtectionPatternWarning =>
      'パターンの変更により、以前一致したリポジトリの保護が外れ、他のリポジトリに適用される場合があります。ワイルドカード(*)は複数のリポジトリに影響します。両方の最低ロールは変更せず、他のルールと権限は引き続き適用されます。イメージを削除したり、自分のアクセス権を示したりするものではありません。';

  @override
  String get containerProtectionPatternAcknowledge =>
      '現在のルールと新しいパターンを確認し、保護の変更を理解しました。';

  @override
  String containerProtectionPatternTarget(String projectId, String ruleId) {
    return 'プロジェクト $projectId — ルール $ruleId';
  }

  @override
  String get containerProtectionPatternForbidden => 'このルールを変更する権限がありません。';

  @override
  String get containerProtectionPatternError =>
      'パターンの更新を確認できませんでした。再試行前にルール一覧を確認してください。サーバーが要求を受理した可能性があります。';

  @override
  String get containerProtectionPatternStale =>
      '確認後にルールが変更されました。再読み込みして確認してから保存してください。';

  @override
  String get containerProtectionPatternReload => 'ルールを再読み込み';

  @override
  String get containerProtectionPatternSaved => 'リポジトリ保護パターンを更新しました。';

  @override
  String get containerProtectionPatternMissing =>
      'ルールが存在しない、重複している、またはアクセスできません。確認前に再読み込みしてください。';

  @override
  String get containerProtectionPatternRateLimited =>
      '要求が多すぎます。待ってから再試行してください。';

  @override
  String get containerProtectionPatternInvalid =>
      'パターンが拒否されたか、既に使用されています。入力を編集して再試行してください。';

  @override
  String get containerProtectionPatternDraft => '新しいリポジトリパスのパターン';

  @override
  String get containerRepositoryProtectionTitle => 'リポジトリ保護ルール';

  @override
  String get containerProtectionRemoveTitle => 'リポジトリ保護ルールを削除';

  @override
  String get containerProtectionRemoveSave => 'ルール削除を確認';

  @override
  String get containerProtectionRemoveWarning =>
      'このルールを削除すると、パスパターンに一致するリポジトリのプッシュまたは削除制限が緩和される場合があります。他のルールと権限は引き続き適用されます。保護ルールのみ削除し、リポジトリ、タグ、イメージは削除しません。対象と最低ロールを確認してください。これらのロールはユーザーの権限を示しません。';

  @override
  String get containerProtectionRemoveAcknowledge =>
      'このルールによる保護制限が削除されることを理解しました。';

  @override
  String containerProtectionRemoveTarget(String projectId, String ruleId) {
    return 'プロジェクト $projectId — ルール $ruleId';
  }

  @override
  String get containerProtectionRemoveForbidden => 'このリポジトリ保護ルールを削除する権限がありません。';

  @override
  String get containerProtectionRemoveError =>
      'ルール削除を確認できません。再読み込みまたは再試行してください。';

  @override
  String get containerProtectionRemoveStale =>
      '確認後にルールが変更されました。削除前に再読み込みして確認してください。';

  @override
  String get containerProtectionRemoveReload => 'ルールを再読み込み';

  @override
  String get containerProtectionRemoveDeleted => 'リポジトリ保護ルールを削除しました。';

  @override
  String get containerProtectionRemoveMissing =>
      'ルールが見つからない、対象が曖昧、またはアクセスできません。確認前に再読み込みしてください。';

  @override
  String get containerProtectionRemoveRateLimited =>
      'リクエストが多すぎます。しばらく待って再試行してください。';

  @override
  String get containerRepositoryProtectionEmpty => 'リポジトリ保護ルールはありません。';

  @override
  String get containerProtectionCreateTitle => 'リポジトリ保護ルールを作成';

  @override
  String get containerProtectionCreateSave => 'ルールを作成';

  @override
  String get containerProtectionCreatePattern => 'リポジトリパスのパターン';

  @override
  String containerProtectionCreateProject(String projectId) {
    return 'プロジェクト $projectId';
  }

  @override
  String get containerProtectionCreateWarning =>
      'このルールは、正確なパターンに一致するリポジトリの選択したプッシュと削除操作を制限します。ワイルドカード(*)は複数のリポジトリに影響します。未選択のロールは、その操作をこのルールでは制限しません。他のルールと権限は引き続き適用されます。この設定は自分のアクセス権を示すものではなく、イメージも削除しません。';

  @override
  String get containerProtectionCreateAcknowledge =>
      'パターンと最低ロールを確認し、その影響を理解しました。';

  @override
  String get containerProtectionCreateUnset => 'このルールによる制限なし';

  @override
  String get containerProtectionCreateCreated => 'ルールを作成しました。';

  @override
  String get containerProtectionCreateForbidden => 'このルールを作成する権限がありません。';

  @override
  String get containerProtectionCreateInvalid =>
      'パターンまたはロールが拒否されたか、パターンが既に使用されています。入力を編集して再試行してください。';

  @override
  String get containerProtectionCreateError =>
      'ルールの作成を確認できませんでした。再試行の前にルール一覧を確認してください。サーバーが要求を受理した可能性があります。';

  @override
  String get containerProtectionCreatePush => '最低プッシュロール';

  @override
  String get containerProtectionCreateDelete => '最低削除ロール';

  @override
  String get containerRepositoryProtectionError => 'リポジトリ保護ルールを読み込めませんでした。';

  @override
  String get containerRepositoryProtectionForbidden =>
      'リポジトリ保護ルールを表示する権限がありません。';

  @override
  String containerProtectionDeleteClearTarget(String projectId, String ruleId) {
    return 'プロジェクト $projectId — ルール $ruleId';
  }

  @override
  String get containerProtectionDeleteClearForbidden => 'このルールを変更する権限がありません。';

  @override
  String get containerProtectionDeleteClearStale =>
      '確認後にルールが変更されました。再読み込みして確認してから保存してください。';

  @override
  String get containerProtectionDeleteClearReload => 'ルールを再読み込み';

  @override
  String get containerProtectionDeleteClearMissing =>
      'ルールが存在しない、重複している、またはアクセスできません。確認前に再読み込みしてください。';

  @override
  String get containerProtectionDeleteClearRateLimited =>
      '要求が多すぎます。待ってから再試行してください。';

  @override
  String get containerProtectionDeleteRoleTitle => '最低削除ロールを編集';

  @override
  String get containerProtectionDeleteRoleSave => '削除ロールを保存';

  @override
  String get containerProtectionDeleteRoleWarning =>
      '最低削除ロールを変更すると、一致するリポジトリのイメージを削除できる人が変わります。低いロールは削除保護を弱め、高いロールは既存のクリーンアップを妨げる可能性があります。パスのパターンと最低プッシュロールは変わりません。他のルールと権限は引き続き適用され、この値は自分のアクセス権を示しません。ルールの保存ではイメージは削除されません。';

  @override
  String get containerProtectionDeleteRoleAcknowledge =>
      'ルールと新しい最低削除ロールを確認し、アクセスの変更を理解しました。';

  @override
  String containerProtectionDeleteRoleTarget(String projectId, String ruleId) {
    return 'プロジェクト $projectId — ルール $ruleId';
  }

  @override
  String get containerProtectionDeleteRoleForbidden => 'このルールを変更する権限がありません。';

  @override
  String get containerProtectionDeleteRoleError =>
      '削除ロールの更新を確認できませんでした。再試行前にルール一覧を確認してください。サーバーが要求を受理した可能性があります。';

  @override
  String get containerProtectionDeleteRoleStale =>
      '確認後にルールが変更されました。再読み込みして確認してから保存してください。';

  @override
  String get containerProtectionDeleteRoleReload => 'ルールを再読み込み';

  @override
  String get containerProtectionDeleteRoleSaved => '最低削除ロールを更新しました。';

  @override
  String get containerProtectionDeleteRoleMissing =>
      'ルールが存在しない、重複している、またはアクセスできません。確認前に再読み込みしてください。';

  @override
  String get containerProtectionDeleteRoleRateLimited =>
      '要求が多すぎます。待ってから再試行してください。';

  @override
  String get containerProtectionDeleteRoleInvalid =>
      '削除ロールが拒否されました。対応するロールを選んで再試行してください。';

  @override
  String get containerProtectionDeleteRoleDraft => '新しい最低削除ロール';

  @override
  String get containerProtectionDeleteRoleSelect => '削除ロールを選択';

  @override
  String get containerProtectionDeleteRoleUnknown =>
      '現在の削除ロールは不明です。未対応の設定を上書きしないよう編集を無効にしています。';

  @override
  String get containerProtectionDeleteClearTitle => '最低削除ロールを解除';

  @override
  String get containerProtectionDeleteClearSave => '削除制限を解除';

  @override
  String get containerProtectionDeleteClearWarning =>
      'このルールの最低削除ロール制限を解除し、一致するリポジトリの削除保護を弱めます。パスのパターンと最低プッシュロールは変わりません。他のルールと権限は引き続き適用され、全員にアクセスを許可したりイメージを削除したりするものではありません。';

  @override
  String get containerProtectionDeleteClearAcknowledge =>
      'ルールを確認し、この削除制限を解除する影響を理解しました。';

  @override
  String get containerProtectionDeleteClearError =>
      '削除制限の解除を確認できませんでした。再試行前にルール一覧を確認してください。サーバーが要求を受理した可能性があります。';

  @override
  String get containerProtectionDeleteClearSaved => '最低削除ロール制限を解除しました。';

  @override
  String get containerProtectionDeleteClearInvalid =>
      'サーバーが削除制限の解除を拒否しました。ルールを確認して再試行してください。';

  @override
  String get containerProtectionDeleteClearBlocked =>
      '解除には対応する現在の削除ロールと空でないプッシュロールが必要です。解除済みまたは不明な設定は解除できません。';

  @override
  String get containerRepositoryProtectionUnavailable =>
      'このインスタンスではリポジトリ保護ルールを利用できないか、プロジェクトにアクセスできません。';

  @override
  String containerRepositoryProtectionPushRole(String role) {
    return 'プッシュに必要な最小ロール: $role';
  }

  @override
  String containerRepositoryProtectionDeleteRole(String role) {
    return '削除に必要な最小ロール: $role';
  }

  @override
  String get containerRepositoryProtectionRoleUnset => 'ルールで未指定';

  @override
  String containerProtectionPushClearTarget(String projectId, String ruleId) {
    return 'プロジェクト $projectId — ルール $ruleId';
  }

  @override
  String get containerProtectionPushClearForbidden => 'このルールを変更する権限がありません。';

  @override
  String get containerProtectionPushClearStale =>
      '確認後にルールが変更されました。再読み込みして確認してから保存してください。';

  @override
  String get containerProtectionPushClearReload => 'ルールを再読み込み';

  @override
  String get containerProtectionPushClearMissing =>
      'ルールが存在しない、重複している、またはアクセスできません。確認前に再読み込みしてください。';

  @override
  String get containerProtectionPushClearRateLimited =>
      '要求が多すぎます。待ってから再試行してください。';

  @override
  String get containerProtectionPushRoleTitle => '最低プッシュロールを編集';

  @override
  String get containerProtectionPushRoleSave => 'プッシュロールを保存';

  @override
  String get containerProtectionPushRoleWarning =>
      '最低プッシュロールを変更すると、一致するリポジトリにプッシュできる人が変わります。低いロールは保護を弱め、高いロールは既存のワークフローを妨げる可能性があります。パスのパターンと最低削除ロールは変わりません。他のルールと権限は引き続き適用され、この値は自分のアクセス権を示したり、イメージを削除したりするものではありません。';

  @override
  String get containerProtectionPushRoleAcknowledge =>
      'ルールと新しい最低プッシュロールを確認し、アクセスの変更を理解しました。';

  @override
  String containerProtectionPushRoleTarget(String projectId, String ruleId) {
    return 'プロジェクト $projectId — ルール $ruleId';
  }

  @override
  String get containerProtectionPushRoleForbidden => 'このルールを変更する権限がありません。';

  @override
  String get containerProtectionPushRoleError =>
      'プッシュロールの更新を確認できませんでした。再試行前にルール一覧を確認してください。サーバーが要求を受理した可能性があります。';

  @override
  String get containerProtectionPushRoleStale =>
      '確認後にルールが変更されました。再読み込みして確認してから保存してください。';

  @override
  String get containerProtectionPushRoleReload => 'ルールを再読み込み';

  @override
  String get containerProtectionPushRoleSaved => '最低プッシュロールを更新しました。';

  @override
  String get containerProtectionPushRoleMissing =>
      'ルールが存在しない、重複している、またはアクセスできません。確認前に再読み込みしてください。';

  @override
  String get containerProtectionPushRoleRateLimited =>
      '要求が多すぎます。待ってから再試行してください。';

  @override
  String get containerProtectionPushRoleInvalid =>
      'プッシュロールが拒否されました。対応するロールを選んで再試行してください。';

  @override
  String get containerProtectionPushRoleDraft => '新しい最低プッシュロール';

  @override
  String get containerProtectionPushRoleSelect => 'プッシュロールを選択';

  @override
  String get containerProtectionPushRoleUnknown =>
      '現在のプッシュロールは不明です。未対応の設定を上書きしないよう編集を無効にしています。';

  @override
  String get containerProtectionPushClearTitle => '最低プッシュロールを解除';

  @override
  String get containerProtectionPushClearSave => 'プッシュ制限を解除';

  @override
  String get containerProtectionPushClearWarning =>
      'このルールの最低プッシュロール制限を解除し、一致するリポジトリのプッシュ保護を弱めます。パスのパターンと最低削除ロールは変わりません。他のルールと権限は引き続き適用され、全員にアクセスを許可したりイメージを削除したりするものではありません。';

  @override
  String get containerProtectionPushClearAcknowledge =>
      'ルールを確認し、このプッシュ制限を解除する影響を理解しました。';

  @override
  String get containerProtectionPushClearError =>
      'プッシュ制限の解除を確認できませんでした。再試行前にルール一覧を確認してください。サーバーが要求を受理した可能性があります。';

  @override
  String get containerProtectionPushClearSaved => '最低プッシュロール制限を解除しました。';

  @override
  String get containerProtectionPushClearInvalid =>
      'サーバーがプッシュ制限の解除を拒否しました。ルールを確認して再試行してください。';

  @override
  String get containerProtectionPushClearBlocked =>
      '解除には対応する現在のプッシュロールと空でない削除ロールが必要です。解除済みまたは不明な設定は解除できません。';

  @override
  String get containerRepositoryProtectionRoleAdmin => '管理者';

  @override
  String get containerAgeTitle => 'クリーンアップ期限を編集';

  @override
  String get containerAgeSave => '期限の変更を確認';

  @override
  String get containerAgeSelect => '新しい期限 (GitLab API期間)';

  @override
  String get containerAgeWarning =>
      'プロジェクト全体の期限を短くすると、定期クリーンアップで各イメージリポジトリの新しい一致タグも完全に削除される可能性があります。以下の有効状態と削除条件を確認してください。他の設定は変更されず、削除完了も意味しません。';

  @override
  String get containerAgeUnknown =>
      '有効状態、間隔、保持数、期限、削除パターンの報告が必要です。不足する設定をGitLabで確認してください。新しいポリシーは作成しません。';

  @override
  String get containerAgeAccepted => 'クリーンアップ期限の更新が受理されました。';

  @override
  String get containerDeletePatternTitle => 'クリーンアップ削除パターンを編集';

  @override
  String get containerDeletePatternSave => '削除パターンの変更を確認';

  @override
  String get containerDeletePatternSelect => '新しい削除パターン (GitLab RE2)';

  @override
  String get containerDeletePatternWarning =>
      'プロジェクト全体の削除パターンを広げると、定期クリーンアップで各イメージリポジトリの一致タグがさらに多く完全に削除される可能性があります。以下の有効状態と保持条件を確認してください。GitLabはRE2を使い、タグ名全体にパターンを適用します。入力はそのまま送信されGitLabが検証します。他の設定は変更されず、受理は削除完了も意味しません。';

  @override
  String get containerDeletePatternUnknown =>
      '有効状態、間隔、保持数、期限、有効な削除パターンの報告が必要です。不足する設定をGitLabで確認してください。新しいポリシーは作成しません。';

  @override
  String get containerDeletePatternAccepted => 'クリーンアップ削除パターンの更新が受理されました。';

  @override
  String get containerDeletePatternInvalid =>
      'GitLabがパターンを拒否しました。RE2構文と既存のポリシーを確認し、編集または再試行してください。';

  @override
  String get containerKeepPatternClearTitle => 'クリーンアップ保持パターンを削除';

  @override
  String get containerKeepPatternClearSave => '保持パターンの削除を確認';

  @override
  String get containerKeepPatternClearWarning =>
      'プロジェクト全体の保持パターンを削除すると、すべてのイメージリポジトリで以前保持されていたタグが定期クリーンアップによる完全削除の対象になる場合があります。latest タグと他の保持・保護ルールは引き続き適用され、タグが直ちに削除されるわけではありません。以下の現在の条件を確認してください。空の保持パターン文字列のみ送信します。他のポリシーフィールドは変更しませんが、GitLab が次回実行を再設定する場合があります。リクエストの受理はクリーンアップの完了や容量の回復を意味しません。';

  @override
  String get containerKeepPatternClearAcknowledge =>
      '以前保持されていたタグが完全削除の対象になる場合があることを理解しました。';

  @override
  String get containerKeepPatternClearUnknown =>
      '有効状態、実行間隔、保持数、期間、有効な削除パターン、および空でない保持パターンの報告が必要です。空または未報告の保持パターンはここでは削除できません。ポリシーは作成しません。';

  @override
  String get containerKeepPatternClearAccepted => '保持パターン削除リクエストが受理されました。';

  @override
  String get containerKeepPatternClearInvalid =>
      'GitLab が保持パターンの削除を拒否しました。既存のポリシーを確認し、再試行するか再読み込みしてください。';
}
