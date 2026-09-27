import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @protectedTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Protected tags'**
  String get protectedTagsTitle;

  /// No description provided for @protectedTagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No protected tag rules found.'**
  String get protectedTagsEmpty;

  /// No description provided for @protectedTagsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load protected tags.'**
  String get protectedTagsError;

  /// No description provided for @protectedTagsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get protectedTagsLoadMore;

  /// No description provided for @protectedTagCreateAccess.
  ///
  /// In en, this message translates to:
  /// **'Allowed to create'**
  String get protectedTagCreateAccess;

  /// No description provided for @protectedEnvironmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Protected environments'**
  String get protectedEnvironmentsTitle;

  /// No description provided for @protectedEnvironmentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No protected environment rules found.'**
  String get protectedEnvironmentsEmpty;

  /// No description provided for @protectedEnvironmentsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load protected environments.'**
  String get protectedEnvironmentsError;

  /// No description provided for @protectedEnvironmentsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Protected environments are unavailable or you don\'t have access.'**
  String get protectedEnvironmentsUnavailable;

  /// No description provided for @protectedEnvironmentsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get protectedEnvironmentsLoadMore;

  /// No description provided for @protectedEnvironmentDeployAccess.
  ///
  /// In en, this message translates to:
  /// **'Allowed to deploy'**
  String get protectedEnvironmentDeployAccess;

  /// No description provided for @protectedEnvironmentApprovalRules.
  ///
  /// In en, this message translates to:
  /// **'Approval rules'**
  String get protectedEnvironmentApprovalRules;

  /// No description provided for @protectedEnvironmentApprovalCount.
  ///
  /// In en, this message translates to:
  /// **'Required approvals: {count}'**
  String protectedEnvironmentApprovalCount(int count);

  /// No description provided for @protectedBranchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Protected branches'**
  String get protectedBranchesTitle;

  /// No description provided for @protectedBranchesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No protected branch rules found.'**
  String get protectedBranchesEmpty;

  /// No description provided for @protectedBranchesError.
  ///
  /// In en, this message translates to:
  /// **'Could not load protected branches.'**
  String get protectedBranchesError;

  /// No description provided for @protectedBranchesLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get protectedBranchesLoadMore;

  /// No description provided for @protectedBranchPushAccess.
  ///
  /// In en, this message translates to:
  /// **'Allowed to push'**
  String get protectedBranchPushAccess;

  /// No description provided for @protectedBranchMergeAccess.
  ///
  /// In en, this message translates to:
  /// **'Allowed to merge'**
  String get protectedBranchMergeAccess;

  /// No description provided for @protectedBranchForcePush.
  ///
  /// In en, this message translates to:
  /// **'Force push'**
  String get protectedBranchForcePush;

  /// No description provided for @protectedBranchCodeOwnerApproval.
  ///
  /// In en, this message translates to:
  /// **'Code owner approval'**
  String get protectedBranchCodeOwnerApproval;

  /// No description provided for @protectedBranchInherited.
  ///
  /// In en, this message translates to:
  /// **'Inherited from group'**
  String get protectedBranchInherited;

  /// No description provided for @protectedBranchEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get protectedBranchEnabled;

  /// No description provided for @protectedBranchDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get protectedBranchDisabled;

  /// No description provided for @protectedBranchNoAccess.
  ///
  /// In en, this message translates to:
  /// **'No access rules'**
  String get protectedBranchNoAccess;

  /// No description provided for @linkedIssuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Linked issues'**
  String get linkedIssuesTitle;

  /// No description provided for @linkedIssuesError.
  ///
  /// In en, this message translates to:
  /// **'Could not load linked issues.'**
  String get linkedIssuesError;

  /// No description provided for @linkedIssuesLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get linkedIssuesLoadMore;

  /// No description provided for @linkedIssuesRelatesTo.
  ///
  /// In en, this message translates to:
  /// **'Related to'**
  String get linkedIssuesRelatesTo;

  /// No description provided for @linkedIssuesBlocks.
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get linkedIssuesBlocks;

  /// No description provided for @linkedIssuesBlockedBy.
  ///
  /// In en, this message translates to:
  /// **'Blocked by'**
  String get linkedIssuesBlockedBy;

  /// No description provided for @groupLabelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group labels'**
  String get groupLabelsTitle;

  /// No description provided for @groupLabelsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No group labels yet'**
  String get groupLabelsEmpty;

  /// No description provided for @groupLabelsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load group labels.'**
  String get groupLabelsError;

  /// No description provided for @groupMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Group members'**
  String get groupMembersTitle;

  /// No description provided for @groupMembersSearch.
  ///
  /// In en, this message translates to:
  /// **'Search group members'**
  String get groupMembersSearch;

  /// No description provided for @groupMembersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No group members found.'**
  String get groupMembersEmpty;

  /// No description provided for @groupMembersError.
  ///
  /// In en, this message translates to:
  /// **'Could not load group members.'**
  String get groupMembersError;

  /// No description provided for @pipelineSchedulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pipeline schedules'**
  String get pipelineSchedulesTitle;

  /// No description provided for @pipelineSchedulesAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get pipelineSchedulesAll;

  /// No description provided for @pipelineSchedulesActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get pipelineSchedulesActive;

  /// No description provided for @pipelineSchedulesInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get pipelineSchedulesInactive;

  /// No description provided for @pipelineSchedulesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pipeline schedules found.'**
  String get pipelineSchedulesEmpty;

  /// No description provided for @pipelineSchedulesError.
  ///
  /// In en, this message translates to:
  /// **'Could not load pipeline schedules.'**
  String get pipelineSchedulesError;

  /// No description provided for @pipelineSchedulesLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get pipelineSchedulesLoadMore;

  /// No description provided for @pipelineScheduleDetailError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this pipeline schedule.'**
  String get pipelineScheduleDetailError;

  /// No description provided for @pipelineScheduleNextRun.
  ///
  /// In en, this message translates to:
  /// **'Next run: {date}'**
  String pipelineScheduleNextRun(String date);

  /// No description provided for @pipelineScheduleNextRunLabel.
  ///
  /// In en, this message translates to:
  /// **'Next run'**
  String get pipelineScheduleNextRunLabel;

  /// No description provided for @pipelineScheduleRef.
  ///
  /// In en, this message translates to:
  /// **'Ref'**
  String get pipelineScheduleRef;

  /// No description provided for @pipelineScheduleCron.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get pipelineScheduleCron;

  /// No description provided for @pipelineScheduleTimezone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get pipelineScheduleTimezone;

  /// No description provided for @pipelineScheduleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get pipelineScheduleOwner;

  /// No description provided for @pipelineScheduleRunNow.
  ///
  /// In en, this message translates to:
  /// **'Run now'**
  String get pipelineScheduleRunNow;

  /// No description provided for @pipelineScheduleRunSuccess.
  ///
  /// In en, this message translates to:
  /// **'Pipeline schedule started.'**
  String get pipelineScheduleRunSuccess;

  /// No description provided for @pipelineScheduleRunError.
  ///
  /// In en, this message translates to:
  /// **'Could not run this pipeline schedule.'**
  String get pipelineScheduleRunError;

  /// No description provided for @pipelineScheduleLastPipeline.
  ///
  /// In en, this message translates to:
  /// **'Last pipeline'**
  String get pipelineScheduleLastPipeline;

  /// No description provided for @pipelineSchedulePipelineNumber.
  ///
  /// In en, this message translates to:
  /// **'Pipeline #{number}'**
  String pipelineSchedulePipelineNumber(int number);

  /// No description provided for @deploymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deployments'**
  String get deploymentsTitle;

  /// No description provided for @deploymentsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get deploymentsAll;

  /// No description provided for @deploymentsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get deploymentsSuccess;

  /// No description provided for @deploymentsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get deploymentsFailed;

  /// No description provided for @deploymentsRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get deploymentsRunning;

  /// No description provided for @deploymentsCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get deploymentsCanceled;

  /// No description provided for @deploymentsCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get deploymentsCreated;

  /// No description provided for @deploymentsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get deploymentsBlocked;

  /// No description provided for @deploymentsUnknownStatus.
  ///
  /// In en, this message translates to:
  /// **'Unknown status'**
  String get deploymentsUnknownStatus;

  /// No description provided for @deploymentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No deployments found.'**
  String get deploymentsEmpty;

  /// No description provided for @deploymentsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load deployments.'**
  String get deploymentsError;

  /// No description provided for @deploymentsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get deploymentsLoadMore;

  /// No description provided for @deploymentsEnvironmentSearch.
  ///
  /// In en, this message translates to:
  /// **'Filter by environment name'**
  String get deploymentsEnvironmentSearch;

  /// No description provided for @deploymentsUnknownEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Unknown environment'**
  String get deploymentsUnknownEnvironment;

  /// No description provided for @deploymentDetailError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this deployment.'**
  String get deploymentDetailError;

  /// No description provided for @deploymentNumber.
  ///
  /// In en, this message translates to:
  /// **'Deployment #{number}'**
  String deploymentNumber(int number);

  /// No description provided for @deploymentEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get deploymentEnvironment;

  /// No description provided for @deploymentRef.
  ///
  /// In en, this message translates to:
  /// **'Ref'**
  String get deploymentRef;

  /// No description provided for @deploymentCommit.
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get deploymentCommit;

  /// No description provided for @deploymentJob.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get deploymentJob;

  /// No description provided for @deploymentPipeline.
  ///
  /// In en, this message translates to:
  /// **'Pipeline'**
  String get deploymentPipeline;

  /// No description provided for @deploymentCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get deploymentCreatedAt;

  /// No description provided for @deploymentUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get deploymentUpdatedAt;

  /// No description provided for @deploymentUser.
  ///
  /// In en, this message translates to:
  /// **'Deployed by'**
  String get deploymentUser;

  /// No description provided for @releasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Releases'**
  String get releasesTitle;

  /// No description provided for @releasesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No releases yet.'**
  String get releasesEmpty;

  /// No description provided for @releasesError.
  ///
  /// In en, this message translates to:
  /// **'Could not load releases.'**
  String get releasesError;

  /// No description provided for @releaseDetailError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this release.'**
  String get releaseDetailError;

  /// No description provided for @releaseAssetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get releaseAssetsTitle;

  /// No description provided for @releaseLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get releaseLoadMore;

  /// No description provided for @releaseUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get releaseUpcoming;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @activityAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get activityAll;

  /// No description provided for @activityIssues.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get activityIssues;

  /// No description provided for @activityMergeRequests.
  ///
  /// In en, this message translates to:
  /// **'Merge requests'**
  String get activityMergeRequests;

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent activity.'**
  String get activityEmpty;

  /// No description provided for @activityError.
  ///
  /// In en, this message translates to:
  /// **'Could not load project activity.'**
  String get activityError;

  /// No description provided for @activityLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get activityLoadMore;

  /// No description provided for @activityUnknownActor.
  ///
  /// In en, this message translates to:
  /// **'Unknown user'**
  String get activityUnknownActor;

  /// No description provided for @activityPush.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get activityPush;

  /// No description provided for @activityEvent.
  ///
  /// In en, this message translates to:
  /// **'Project activity'**
  String get activityEvent;

  /// No description provided for @activityBy.
  ///
  /// In en, this message translates to:
  /// **'{actor} {action}'**
  String activityBy(String actor, String action);

  /// No description provided for @environmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Environments'**
  String get environmentsTitle;

  /// No description provided for @environmentsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get environmentsAll;

  /// No description provided for @environmentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get environmentsAvailable;

  /// No description provided for @environmentsStopping.
  ///
  /// In en, this message translates to:
  /// **'Stopping'**
  String get environmentsStopping;

  /// No description provided for @environmentsStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get environmentsStopped;

  /// No description provided for @environmentsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search environments'**
  String get environmentsSearch;

  /// No description provided for @environmentsSearchLength.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 3 characters.'**
  String get environmentsSearchLength;

  /// No description provided for @environmentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No environments found.'**
  String get environmentsEmpty;

  /// No description provided for @environmentsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load environments.'**
  String get environmentsError;

  /// No description provided for @environmentsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get environmentsLoadMore;

  /// No description provided for @environmentDetailError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this environment.'**
  String get environmentDetailError;

  /// No description provided for @environmentAutoStop.
  ///
  /// In en, this message translates to:
  /// **'Auto-stop'**
  String get environmentAutoStop;

  /// No description provided for @environmentOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Open environment'**
  String get environmentOpenUrl;

  /// No description provided for @environmentLatestDeployment.
  ///
  /// In en, this message translates to:
  /// **'Latest deployment'**
  String get environmentLatestDeployment;

  /// No description provided for @environmentUnknownStatus.
  ///
  /// In en, this message translates to:
  /// **'Unknown status'**
  String get environmentUnknownStatus;

  /// No description provided for @projectMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get projectMembersTitle;

  /// No description provided for @projectMembersSearch.
  ///
  /// In en, this message translates to:
  /// **'Search members'**
  String get projectMembersSearch;

  /// No description provided for @projectMembersClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get projectMembersClearSearch;

  /// No description provided for @projectMembersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No members found.'**
  String get projectMembersEmpty;

  /// No description provided for @projectMembersError.
  ///
  /// In en, this message translates to:
  /// **'Could not load members.'**
  String get projectMembersError;

  /// No description provided for @projectMembersLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get projectMembersLoadMore;

  /// No description provided for @projectMembersExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get projectMembersExpiry;

  /// No description provided for @memberRoleNoAccess.
  ///
  /// In en, this message translates to:
  /// **'No access'**
  String get memberRoleNoAccess;

  /// No description provided for @memberRoleMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal access'**
  String get memberRoleMinimal;

  /// No description provided for @memberRoleGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get memberRoleGuest;

  /// No description provided for @memberRolePlanner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get memberRolePlanner;

  /// No description provided for @memberRoleReporter.
  ///
  /// In en, this message translates to:
  /// **'Reporter'**
  String get memberRoleReporter;

  /// No description provided for @memberRoleSecurityManager.
  ///
  /// In en, this message translates to:
  /// **'Security manager'**
  String get memberRoleSecurityManager;

  /// No description provided for @memberRoleDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get memberRoleDeveloper;

  /// No description provided for @memberRoleMaintainer.
  ///
  /// In en, this message translates to:
  /// **'Maintainer'**
  String get memberRoleMaintainer;

  /// No description provided for @memberRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get memberRoleOwner;

  /// No description provided for @memberRoleUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown role'**
  String get memberRoleUnknown;

  /// No description provided for @containerRegistryTitle.
  ///
  /// In en, this message translates to:
  /// **'Container registry'**
  String get containerRegistryTitle;

  /// No description provided for @containerRegistryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No container images yet.'**
  String get containerRegistryEmpty;

  /// No description provided for @containerRegistryError.
  ///
  /// In en, this message translates to:
  /// **'Could not load container images.'**
  String get containerRegistryError;

  /// No description provided for @containerTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Image tags'**
  String get containerTagsTitle;

  /// No description provided for @containerTagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tags yet.'**
  String get containerTagsEmpty;

  /// No description provided for @containerTagsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load image tags.'**
  String get containerTagsError;

  /// No description provided for @containerTagError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this tag.'**
  String get containerTagError;

  /// No description provided for @containerTagDigest.
  ///
  /// In en, this message translates to:
  /// **'Digest'**
  String get containerTagDigest;

  /// No description provided for @containerTagRevision.
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get containerTagRevision;

  /// No description provided for @containerTagSize.
  ///
  /// In en, this message translates to:
  /// **'Size (bytes)'**
  String get containerTagSize;

  /// No description provided for @containerLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get containerLoadMore;

  /// No description provided for @milestonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestonesTitle;

  /// No description provided for @milestonesActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get milestonesActive;

  /// No description provided for @milestonesClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get milestonesClosed;

  /// No description provided for @milestonesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No milestones in this state.'**
  String get milestonesEmpty;

  /// No description provided for @milestonesError.
  ///
  /// In en, this message translates to:
  /// **'Could not load milestones.'**
  String get milestonesError;

  /// No description provided for @milestoneDetailError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this milestone.'**
  String get milestoneDetailError;

  /// No description provided for @milestoneStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get milestoneStartDate;

  /// No description provided for @milestoneDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get milestoneDueDate;

  /// No description provided for @milestoneLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get milestoneLoadMore;

  /// The application name, shown in the task switcher and app bar
  ///
  /// In en, this message translates to:
  /// **'LabFox'**
  String get appTitle;

  /// Title of the home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Shown on the home screen with the signed-in user's username
  ///
  /// In en, this message translates to:
  /// **'Signed in as {username}'**
  String homeSignedInAs(String username);

  /// Placeholder on the home screen before feature work lands
  ///
  /// In en, this message translates to:
  /// **'Your issues, merge requests and pipelines will appear here.'**
  String get homeEmptyWork;

  /// Home section heading for merge requests awaiting the user's review
  ///
  /// In en, this message translates to:
  /// **'Review requests'**
  String get homeReviewRequests;

  /// Home section heading for merge requests assigned to the user
  ///
  /// In en, this message translates to:
  /// **'Assigned merge requests'**
  String get homeAssignedMergeRequests;

  /// Home section heading for issues assigned to the user
  ///
  /// In en, this message translates to:
  /// **'Assigned issues'**
  String get homeAssignedIssues;

  /// Shown on the home feed when the user has no review requests or assigned work
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get homeWorkAllClear;

  /// Shown when the home work feed fails to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your work.'**
  String get homeWorkError;

  /// Label for the sign-out action
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Heading on the sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Connect a GitLab account'**
  String get signInTitle;

  /// Explains, on the sign-in screen, that the app has no account of its own and connects to the user's own GitLab
  ///
  /// In en, this message translates to:
  /// **'LabFox has no account of its own. Connect the GitLab you already use — gitlab.com, or an instance you host yourself.'**
  String get signInNoAccountNote;

  /// Label for the instance URL field
  ///
  /// In en, this message translates to:
  /// **'GitLab instance URL'**
  String get signInInstanceLabel;

  /// Validation when the instance URL is empty
  ///
  /// In en, this message translates to:
  /// **'Enter your GitLab instance URL.'**
  String get signInInstanceRequired;

  /// Validation when the instance URL is not a valid https URL
  ///
  /// In en, this message translates to:
  /// **'Enter a valid https URL, for example https://gitlab.com.'**
  String get signInInstanceInvalid;

  /// Label for the token field
  ///
  /// In en, this message translates to:
  /// **'Personal Access Token'**
  String get signInTokenLabel;

  /// Helper text under the token field
  ///
  /// In en, this message translates to:
  /// **'Needs the api and read_user scopes.'**
  String get signInTokenHelp;

  /// Tooltip for the token visibility toggle
  ///
  /// In en, this message translates to:
  /// **'Show or hide the token'**
  String get signInTokenToggle;

  /// Validation when the token is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a Personal Access Token.'**
  String get signInTokenRequired;

  /// Label for the sign-in button
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInSubmit;

  /// Divider between the token and OAuth sign-in options
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get signInOr;

  /// Button that starts the OAuth browser sign-in. Deliberately not "Sign in with GitLab": that is the grammar of a social login button, and App Review twice read it as a third-party login creating an account with the app. The button authorizes against the instance the user typed above it, which is often one they host themselves.
  ///
  /// In en, this message translates to:
  /// **'Authorize with your instance'**
  String get signInOAuthButton;

  /// Label for the OAuth client id field
  ///
  /// In en, this message translates to:
  /// **'OAuth client ID'**
  String get signInClientIdLabel;

  /// Helper text for the OAuth client id field
  ///
  /// In en, this message translates to:
  /// **'Only for OAuth on a self-hosted instance.'**
  String get signInClientIdHelp;

  /// Shown when OAuth is started without a usable client id
  ///
  /// In en, this message translates to:
  /// **'Enter an OAuth client ID for this instance.'**
  String get signInOAuthNeedsClientId;

  /// Shown when the instance returns 401
  ///
  /// In en, this message translates to:
  /// **'The token was rejected. Check that it is correct and has not expired.'**
  String get signInErrorToken;

  /// Shown when the instance returns 403
  ///
  /// In en, this message translates to:
  /// **'The token is missing a required scope. It needs api and read_user.'**
  String get signInErrorScope;

  /// Shown when the instance cannot be reached
  ///
  /// In en, this message translates to:
  /// **'Could not reach that instance. Check the URL, your network, and whether the certificate is trusted.'**
  String get signInErrorUnreachable;

  /// Fallback sign-in error
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get signInErrorGeneric;

  /// Account-level list scope: items assigned to the user
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get scopeAssigned;

  /// Account-level list scope: items created by the user
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get scopeCreated;

  /// Tooltip for the home refresh action
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get homeRefresh;

  /// Hint shown in the empty favorites section
  ///
  /// In en, this message translates to:
  /// **'Star projects to pin them here.'**
  String get homeFavoritesEmpty;

  /// Section heading on the home screen
  ///
  /// In en, this message translates to:
  /// **'My work'**
  String get homeMyWork;

  /// Home entry that opens the projects list
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get homeProjects;

  /// Home entry that opens the groups list
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get homeGroups;

  /// Title of the groups list screen
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTitle;

  /// Shown when the groups list is empty
  ///
  /// In en, this message translates to:
  /// **'You are not a member of any groups yet.'**
  String get groupsEmpty;

  /// Shown when the groups list fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load your groups.'**
  String get groupsError;

  /// Fallback title while a group detail is loading
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupDetailTitle;

  /// Shown when a group detail or its children fail to load
  ///
  /// In en, this message translates to:
  /// **'Could not load this group.'**
  String get groupDetailError;

  /// Section title for direct child groups
  ///
  /// In en, this message translates to:
  /// **'Subgroups'**
  String get groupSubgroups;

  /// Shown when a group has no visible direct subgroups
  ///
  /// In en, this message translates to:
  /// **'No subgroups.'**
  String get groupSubgroupsEmpty;

  /// Section title for projects directly in a group
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get groupProjects;

  /// Shown when a group has no visible direct projects
  ///
  /// In en, this message translates to:
  /// **'No projects in this group.'**
  String get groupProjectsEmpty;

  /// Loads the next page of group projects or subgroups
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get groupLoadMore;

  /// Title of the projects list screen
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsTitle;

  /// Shown when the projects list is empty
  ///
  /// In en, this message translates to:
  /// **'You are not a member of any projects yet.'**
  String get projectsEmpty;

  /// Shown when the projects list fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load your projects.'**
  String get projectsError;

  /// Tooltip for the action that shares the item's web link
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareLink;

  /// Menu action that closes the merge request
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get mrClose;

  /// Menu action that reopens the merge request
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get mrReopen;

  /// Menu action that rebases the merge request
  ///
  /// In en, this message translates to:
  /// **'Rebase'**
  String get mrRebase;

  /// Menu action that marks the MR as a draft
  ///
  /// In en, this message translates to:
  /// **'Mark as draft'**
  String get mrMarkDraft;

  /// Menu action that marks a draft MR as ready
  ///
  /// In en, this message translates to:
  /// **'Mark as ready'**
  String get mrMarkReady;

  /// Row chip when a merge request has merge conflicts
  ///
  /// In en, this message translates to:
  /// **'Conflicts'**
  String get mrBlockerConflicts;

  /// Row chip when a merge request's required pipeline has not passed
  ///
  /// In en, this message translates to:
  /// **'Checks failed'**
  String get mrBlockerChecksFailed;

  /// Row chip when a merge request's pipeline is still running
  ///
  /// In en, this message translates to:
  /// **'CI running'**
  String get mrBlockerCiRunning;

  /// Row chip when a merge request still needs approval
  ///
  /// In en, this message translates to:
  /// **'Needs approval'**
  String get mrBlockerNeedsApproval;

  /// Row chip when a merge request has unresolved discussion threads
  ///
  /// In en, this message translates to:
  /// **'Unresolved threads'**
  String get mrBlockerUnresolved;

  /// Label for a retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Title of the create-issue screen
  ///
  /// In en, this message translates to:
  /// **'New issue'**
  String get newIssueTitle;

  /// Label for the issue title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get newIssueTitleLabel;

  /// Validation when the issue title is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a title.'**
  String get newIssueTitleRequired;

  /// Label for the issue description field
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get newIssueDescriptionLabel;

  /// Button that creates the issue
  ///
  /// In en, this message translates to:
  /// **'Create issue'**
  String get newIssueSubmit;

  /// Shown when creating an issue fails
  ///
  /// In en, this message translates to:
  /// **'Could not create the issue. Please try again.'**
  String get newIssueError;

  /// Tooltip for the create-issue action on the issues list
  ///
  /// In en, this message translates to:
  /// **'New issue'**
  String get newIssueButton;

  /// Menu action that closes the issue
  ///
  /// In en, this message translates to:
  /// **'Close issue'**
  String get issueClose;

  /// No description provided for @issueEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit issue'**
  String get issueEdit;

  /// No description provided for @issueSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get issueSaveChanges;

  /// No description provided for @issueEditError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the issue. Check your permissions and try again.'**
  String get issueEditError;

  /// Menu action that reopens the issue
  ///
  /// In en, this message translates to:
  /// **'Reopen issue'**
  String get issueReopen;

  /// Shown when closing or reopening an issue fails
  ///
  /// In en, this message translates to:
  /// **'Could not update the issue. Please try again.'**
  String get issueStateError;

  /// Title of the create-MR screen
  ///
  /// In en, this message translates to:
  /// **'New merge request'**
  String get newMrTitle;

  /// Label for the source branch field
  ///
  /// In en, this message translates to:
  /// **'Source branch'**
  String get newMrSourceLabel;

  /// Label for the target branch field
  ///
  /// In en, this message translates to:
  /// **'Target branch'**
  String get newMrTargetLabel;

  /// Label for the MR title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get newMrTitleLabel;

  /// Label for the MR description field
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get newMrDescriptionLabel;

  /// Validation when a branch is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a branch.'**
  String get newMrBranchRequired;

  /// Validation when the MR title is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a title.'**
  String get newMrTitleRequired;

  /// Button that creates the merge request
  ///
  /// In en, this message translates to:
  /// **'Create merge request'**
  String get newMrSubmit;

  /// Shown when creating an MR fails
  ///
  /// In en, this message translates to:
  /// **'Could not create the merge request. Please try again.'**
  String get newMrError;

  /// Tooltip for the create-MR action on the MR list
  ///
  /// In en, this message translates to:
  /// **'New merge request'**
  String get newMrButton;

  /// Fallback title for the project overview screen
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get projectOverviewTitle;

  /// Shown when the project overview fails
  ///
  /// In en, this message translates to:
  /// **'Could not load this project.'**
  String get projectOverviewError;

  /// Shown when a project has no README
  ///
  /// In en, this message translates to:
  /// **'This project has no README.'**
  String get projectOverviewNoReadme;

  /// Overview link that opens the repository browser
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get projectOverviewRepository;

  /// Title of the repository browser at the root
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get repositoryTitle;

  /// Shown when a directory listing fails
  ///
  /// In en, this message translates to:
  /// **'Could not load this directory.'**
  String get repositoryError;

  /// Shown for an empty directory
  ///
  /// In en, this message translates to:
  /// **'This directory is empty.'**
  String get repositoryEmpty;

  /// Shown when a file fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load this file.'**
  String get fileError;

  /// Shown when a file does not exist
  ///
  /// In en, this message translates to:
  /// **'This file was not found.'**
  String get fileNotFound;

  /// Shown for a binary file
  ///
  /// In en, this message translates to:
  /// **'This is a binary file and cannot be shown as text.'**
  String get fileBinary;

  /// Tooltip for the action that copies the file contents
  ///
  /// In en, this message translates to:
  /// **'Copy contents'**
  String get fileCopy;

  /// Confirmation after the file contents are copied
  ///
  /// In en, this message translates to:
  /// **'Contents copied'**
  String get fileCopied;

  /// Overview link that opens the branches list
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get projectOverviewBranches;

  /// Overview link that opens the commits list
  ///
  /// In en, this message translates to:
  /// **'Commits'**
  String get projectOverviewCommits;

  /// Overview section header for the branch and file entries
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get projectOverviewCode;

  /// Overview link that opens the file tree of the default branch
  ///
  /// In en, this message translates to:
  /// **'Browse code'**
  String get projectOverviewBrowseCode;

  /// Title of the branches screen
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get branchesTitle;

  /// Shown when the branches list fails
  ///
  /// In en, this message translates to:
  /// **'Could not load branches.'**
  String get branchesError;

  /// Shown for a repository with no branches
  ///
  /// In en, this message translates to:
  /// **'This repository has no branches.'**
  String get branchesEmpty;

  /// Title of the create-branch dialog
  ///
  /// In en, this message translates to:
  /// **'New branch'**
  String get newBranchTitle;

  /// Label for the new branch name field
  ///
  /// In en, this message translates to:
  /// **'Branch name'**
  String get newBranchNameLabel;

  /// Label for the source ref field
  ///
  /// In en, this message translates to:
  /// **'Create from'**
  String get newBranchFromLabel;

  /// Validation when the branch name is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a branch name.'**
  String get newBranchNameRequired;

  /// Validation when the source ref is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a source branch or ref.'**
  String get newBranchFromRequired;

  /// Button that creates the branch
  ///
  /// In en, this message translates to:
  /// **'Create branch'**
  String get newBranchCreate;

  /// Shown when creating a branch fails
  ///
  /// In en, this message translates to:
  /// **'Could not create the branch. Please try again.'**
  String get newBranchError;

  /// Tooltip for the create-branch action
  ///
  /// In en, this message translates to:
  /// **'New branch'**
  String get newBranchButton;

  /// Label marking the default branch
  ///
  /// In en, this message translates to:
  /// **'Default branch'**
  String get branchDefault;

  /// Title of the commits screen
  ///
  /// In en, this message translates to:
  /// **'Commits'**
  String get commitsTitle;

  /// Shown when the commits list fails
  ///
  /// In en, this message translates to:
  /// **'Could not load commits.'**
  String get commitsError;

  /// Shown for a branch with no commits
  ///
  /// In en, this message translates to:
  /// **'No commits on this branch yet.'**
  String get commitsEmpty;

  /// Fallback title for the commit detail screen
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get commitTitle;

  /// Shown when a commit fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load this commit.'**
  String get commitError;

  /// Overview link that opens the issues list
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get projectOverviewIssues;

  /// Title of the issues list screen
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get issuesTitle;

  /// Label for the open-issues filter
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get issuesFilterOpen;

  /// Label for the closed-issues filter
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get issuesFilterClosed;

  /// Shown when the issues list fails
  ///
  /// In en, this message translates to:
  /// **'Could not load issues.'**
  String get issuesError;

  /// Shown when the issues list is empty
  ///
  /// In en, this message translates to:
  /// **'No issues here.'**
  String get issuesEmpty;

  /// Shown when an issue fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load this issue.'**
  String get issueError;

  /// Issue state badge, open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get issueStateOpen;

  /// Issue state badge, closed
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get issueStateClosed;

  /// Shown when an issue has no description
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get issueNoDescription;

  /// Attribution line on an issue
  ///
  /// In en, this message translates to:
  /// **'opened by {username}'**
  String issueOpenedBy(String username);

  /// Overview link that opens the merge requests list
  ///
  /// In en, this message translates to:
  /// **'Merge requests'**
  String get projectOverviewMergeRequests;

  /// Title of the merge requests list screen
  ///
  /// In en, this message translates to:
  /// **'Merge requests'**
  String get mergeRequestsTitle;

  /// Merge requests filter, open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get mrFilterOpen;

  /// Merge requests filter, merged
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get mrFilterMerged;

  /// Merge requests filter, closed
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get mrFilterClosed;

  /// Shown when the MR list fails
  ///
  /// In en, this message translates to:
  /// **'Could not load merge requests.'**
  String get mergeRequestsError;

  /// Shown when the MR list is empty
  ///
  /// In en, this message translates to:
  /// **'No merge requests here.'**
  String get mergeRequestsEmpty;

  /// Shown when an MR fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load this merge request.'**
  String get mergeRequestError;

  /// Shown when an MR has no description
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get mergeRequestNoDescription;

  /// MR state badge, open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get mrStateOpen;

  /// MR state badge, merged
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get mrStateMerged;

  /// MR state badge, closed
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get mrStateClosed;

  /// Label marking a draft MR
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get mrDraft;

  /// Title of the changed-files (diff) screen
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get changesTitle;

  /// Shown when a diff fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load the changes.'**
  String get changesError;

  /// Shown when there are no file changes
  ///
  /// In en, this message translates to:
  /// **'No changes.'**
  String get changesEmpty;

  /// Shown for a binary file in a diff
  ///
  /// In en, this message translates to:
  /// **'Binary file — not shown.'**
  String get changesBinary;

  /// Button on commit detail that opens the diff
  ///
  /// In en, this message translates to:
  /// **'View changes'**
  String get commitViewChanges;

  /// Button on MR detail that opens the diff
  ///
  /// In en, this message translates to:
  /// **'View changes'**
  String get mrViewChanges;

  /// Shown for a text file whose diff GitLab omitted (too large or collapsed)
  ///
  /// In en, this message translates to:
  /// **'Diff not shown because it is too large or collapsed.'**
  String get changesOmitted;

  /// Heading above a comment thread
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsHeading;

  /// Shown when comments fail to load
  ///
  /// In en, this message translates to:
  /// **'Could not load comments.'**
  String get commentsError;

  /// Shown when there are no comments
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get commentsEmpty;

  /// Placeholder in the comment composer
  ///
  /// In en, this message translates to:
  /// **'Write a comment…'**
  String get commentComposerHint;

  /// Button to post a comment
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentComposerSubmit;

  /// Shown when posting a comment is forbidden (403)
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to comment here. Check that your token has the api scope.'**
  String get commentPostForbidden;

  /// Generic comment post error
  ///
  /// In en, this message translates to:
  /// **'Could not post your comment. Please try again.'**
  String get commentPostError;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button to approve a merge request
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get mrApprove;

  /// Button to remove approval
  ///
  /// In en, this message translates to:
  /// **'Revoke approval'**
  String get mrUnapprove;

  /// Button to merge a merge request
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get mrMerge;

  /// Title of the sheet that lets the user pick how to merge
  ///
  /// In en, this message translates to:
  /// **'Merge method'**
  String get mrMergeMethodTitle;

  /// Merge method that keeps every commit and adds a merge commit
  ///
  /// In en, this message translates to:
  /// **'Merge commit'**
  String get mrMergeCommit;

  /// Merge method that squashes all commits into one
  ///
  /// In en, this message translates to:
  /// **'Squash and merge'**
  String get mrMergeSquash;

  /// Shown when GitLab reports the merge request can be merged
  ///
  /// In en, this message translates to:
  /// **'Ready to merge'**
  String get mrReadyToMerge;

  /// Shown when GitLab reports the merge request is not mergeable
  ///
  /// In en, this message translates to:
  /// **'Cannot be merged yet'**
  String get mrCannotMergeNow;

  /// Merge confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Merge this merge request?'**
  String get mrMergeConfirmTitle;

  /// Merge confirmation dialog body
  ///
  /// In en, this message translates to:
  /// **'Merging {mr} cannot be undone.'**
  String mrMergeConfirmBody(String mr);

  /// Approval summary line
  ///
  /// In en, this message translates to:
  /// **'{approved} of {required} approvals'**
  String mrApprovalsSummary(int approved, int required);

  /// Shown when a merge is rejected as not mergeable
  ///
  /// In en, this message translates to:
  /// **'This merge request cannot be merged right now. It may need approval, a rebase, or a passing pipeline.'**
  String get mrNotMergeable;

  /// Shown when an approve/merge is forbidden
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action. Check your token scope and role.'**
  String get mrActionForbidden;

  /// Generic MR action error
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed. Please try again.'**
  String get mrActionError;

  /// Overview link that opens the pipelines list
  ///
  /// In en, this message translates to:
  /// **'Pipelines'**
  String get projectOverviewPipelines;

  /// Title of the pipelines list screen
  ///
  /// In en, this message translates to:
  /// **'Pipelines'**
  String get pipelinesTitle;

  /// Shown when the pipelines list fails
  ///
  /// In en, this message translates to:
  /// **'Could not load pipelines.'**
  String get pipelinesError;

  /// Shown when there are no pipelines
  ///
  /// In en, this message translates to:
  /// **'No pipelines yet.'**
  String get pipelinesEmpty;

  /// Shown when a pipeline fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load this pipeline.'**
  String get pipelineError;

  /// Shown when a pipeline's jobs fail to load
  ///
  /// In en, this message translates to:
  /// **'Could not load jobs.'**
  String get pipelineJobsError;

  /// Shown when a pipeline has no jobs
  ///
  /// In en, this message translates to:
  /// **'This pipeline has no jobs.'**
  String get pipelineNoJobs;

  /// Fallback title for the job detail screen
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get jobTitle;

  /// Shown when a job fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load this job.'**
  String get jobError;

  /// Tooltip for the job refresh action
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get jobRefresh;

  /// Shown when a job log fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load the log.'**
  String get jobLogError;

  /// Shown when a job has no log
  ///
  /// In en, this message translates to:
  /// **'This job has no log output.'**
  String get jobLogEmpty;

  /// Button to retry a job
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get jobActionRetry;

  /// Button to cancel a job
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get jobActionCancel;

  /// Button to run a manual job
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get jobActionRun;

  /// Shown when a job action is forbidden
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action.'**
  String get jobActionForbidden;

  /// Shown when a job action conflicts with status
  ///
  /// In en, this message translates to:
  /// **'This action is not available for the job\'s current state.'**
  String get jobActionInvalid;

  /// Generic job action error
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed. Please try again.'**
  String get jobActionError;

  /// Button to retry a pipeline
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get pipelineActionRetry;

  /// Button to cancel a pipeline
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pipelineActionCancel;

  /// Shown when a pipeline action is forbidden
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action.'**
  String get pipelineActionForbidden;

  /// Shown when a pipeline action conflicts with status
  ///
  /// In en, this message translates to:
  /// **'This action is not available for the pipeline\'s current state.'**
  String get pipelineActionInvalid;

  /// Generic pipeline action error
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed. Please try again.'**
  String get pipelineActionError;

  /// Title of the accounts switcher screen
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsTitle;

  /// Button to add another account
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get accountAdd;

  /// Tooltip for removing an account
  ///
  /// In en, this message translates to:
  /// **'Remove account'**
  String get accountRemove;

  /// Home action that opens the account switcher
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get homeSwitchAccount;

  /// Home entry that opens the to-do inbox
  ///
  /// In en, this message translates to:
  /// **'To-do list'**
  String get homeInbox;

  /// Title of the to-do inbox screen
  ///
  /// In en, this message translates to:
  /// **'To-do list'**
  String get inboxTitle;

  /// Shown when the to-do inbox has no pending items
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get inboxEmpty;

  /// Shown when the done view of the inbox is empty
  ///
  /// In en, this message translates to:
  /// **'Nothing marked done yet.'**
  String get inboxDoneEmpty;

  /// Inbox state filter: items awaiting action
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get inboxFilterPending;

  /// Inbox state filter: items already marked done
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get inboxFilterDone;

  /// Inbox type filter: no type restriction
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get inboxFilterAllTypes;

  /// Inbox type filter: issue todos only
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get inboxTypeIssues;

  /// Inbox type filter: merge request todos only
  ///
  /// In en, this message translates to:
  /// **'Merge requests'**
  String get inboxTypeMergeRequests;

  /// Inbox reason filter: no reason restriction
  ///
  /// In en, this message translates to:
  /// **'All reasons'**
  String get inboxFilterAllReasons;

  /// Shown when the to-do list fails to load
  ///
  /// In en, this message translates to:
  /// **'Your to-do items could not be loaded.'**
  String get inboxError;

  /// Action that clears every pending to-do item
  ///
  /// In en, this message translates to:
  /// **'Mark all as done'**
  String get inboxMarkAllDone;

  /// Tooltip for clearing a single to-do item
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get inboxMarkDone;

  /// Shown when marking a to-do item done fails
  ///
  /// In en, this message translates to:
  /// **'The item could not be cleared. Please try again.'**
  String get inboxMarkDoneError;

  /// To-do reason: the item was assigned to the user
  ///
  /// In en, this message translates to:
  /// **'Assigned to you'**
  String get inboxActionAssigned;

  /// To-do reason: the user was mentioned
  ///
  /// In en, this message translates to:
  /// **'Mentioned you'**
  String get inboxActionMentioned;

  /// To-do reason: a pipeline the user owns failed
  ///
  /// In en, this message translates to:
  /// **'Pipeline failed'**
  String get inboxActionBuildFailed;

  /// To-do reason: the user added the item to their list
  ///
  /// In en, this message translates to:
  /// **'Added a to-do'**
  String get inboxActionMarked;

  /// To-do reason: the user's approval is required
  ///
  /// In en, this message translates to:
  /// **'Approval required'**
  String get inboxActionApprovalRequired;

  /// To-do reason: the merge request cannot be merged
  ///
  /// In en, this message translates to:
  /// **'Cannot be merged'**
  String get inboxActionUnmergeable;

  /// To-do reason: the user was directly addressed
  ///
  /// In en, this message translates to:
  /// **'Directly addressed you'**
  String get inboxActionDirectlyAddressed;

  /// Home entry that opens search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeSearch;

  /// Title of the search screen
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// Placeholder in the search field
  ///
  /// In en, this message translates to:
  /// **'Search projects, issues, merge requests'**
  String get searchHint;

  /// Search scope: projects
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get searchScopeProjects;

  /// Search scope: issues
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get searchScopeIssues;

  /// Search scope: merge requests
  ///
  /// In en, this message translates to:
  /// **'Merge requests'**
  String get searchScopeMergeRequests;

  /// Shown before the user has entered a search term
  ///
  /// In en, this message translates to:
  /// **'Type to search.'**
  String get searchInitial;

  /// Shown when a search returns nothing
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get searchEmpty;

  /// Shown when a search request fails
  ///
  /// In en, this message translates to:
  /// **'The search could not be completed.'**
  String get searchError;

  /// Button that loads the next page of search results
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get searchLoadMore;

  /// Placeholder of the inline search field on list screens
  ///
  /// In en, this message translates to:
  /// **'Search by title'**
  String get listSearchHint;

  /// Tooltip for the button that closes the inline list search
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get listSearchClose;

  /// Tooltip for favoriting a project
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get projectAddFavorite;

  /// Tooltip for unfavoriting a project
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get projectRemoveFavorite;

  /// Home section title for favorited projects
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get homeFavorites;

  /// Title of the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings entry that opens the account switcher
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get settingsAccounts;

  /// Settings entry that opens the bundled privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// Settings entry that opens the terms page on the company site
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get settingsTerms;

  /// Settings entry that opens the company website
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get settingsWebsite;

  /// Settings section for background checks
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Switch that turns on periodic background checks of the to-do list
  ///
  /// In en, this message translates to:
  /// **'Background to-do checks'**
  String get settingsBackgroundChecks;

  /// Explains the platform-dependent timing of background checks
  ///
  /// In en, this message translates to:
  /// **'LabFox checks your to-do list in the background and notifies you about new items. Android checks about every 15 minutes; iOS decides when, so this is a background check rather than instant push.'**
  String get settingsBackgroundChecksHelp;

  /// Paywall reason shown for background notifications
  ///
  /// In en, this message translates to:
  /// **'Background to-do checks are part of the subscription. The to-do inbox and manual refresh stay free.'**
  String get paywallNotifications;

  /// Shown when the system refused the notification permission
  ///
  /// In en, this message translates to:
  /// **'LabFox cannot show notifications until you allow them in system settings.'**
  String get settingsNotificationsDenied;

  /// Settings section for the theme choice
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Theme option that follows the device
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Theme option forcing the light theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Theme option forcing the dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Settings section for app information
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// Row showing the installed app version
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// Me action that shares the user's GitLab profile link
  ///
  /// In en, this message translates to:
  /// **'Share profile'**
  String get meShareProfile;

  /// Settings entry that opens the open-source license page
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get settingsLicenses;

  /// Heading of the sheet offered when a free user taps a paid action
  ///
  /// In en, this message translates to:
  /// **'A subscription unlocks this'**
  String get paywallTitle;

  /// Button on the paywall sheet that opens the subscription screen
  ///
  /// In en, this message translates to:
  /// **'See the subscription'**
  String get paywallSubscribe;

  /// Button that dismisses the paywall sheet
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get paywallNotNow;

  /// Paywall reason shown for approve and merge
  ///
  /// In en, this message translates to:
  /// **'Approving and merging are part of the subscription. Reading merge requests, diffs, and discussions stays free.'**
  String get paywallMergeRequestActions;

  /// Paywall reason shown for pipeline and job actions
  ///
  /// In en, this message translates to:
  /// **'Retrying, cancelling, and running manual jobs are part of the subscription. Watching pipelines and reading job logs stays free.'**
  String get paywallPipelineActions;

  /// Paywall reason shown when adding a second account
  ///
  /// In en, this message translates to:
  /// **'One account is free. Connecting more instances is part of the subscription.'**
  String get paywallAccounts;

  /// Paywall reason shown when the free favorite limit is reached
  ///
  /// In en, this message translates to:
  /// **'Free keeps {count} favorites. The subscription removes the limit.'**
  String paywallFavorites(int count);

  /// Title of the subscription screen
  ///
  /// In en, this message translates to:
  /// **'LabFox subscription'**
  String get subscriptionTitle;

  /// Shown when the user has an active subscription
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscriptionActive;

  /// Shown when the user has no active subscription
  ///
  /// In en, this message translates to:
  /// **'Not subscribed'**
  String get subscriptionInactive;

  /// One-line summary of what the subscription unlocks
  ///
  /// In en, this message translates to:
  /// **'Approve and merge, retry pipelines, and connect more than one account.'**
  String get subscriptionPitch;

  /// Subscription benefit: multiple accounts
  ///
  /// In en, this message translates to:
  /// **'Connect multiple accounts and self-hosted instances'**
  String get subscriptionBenefitAccounts;

  /// Subscription benefit: write actions
  ///
  /// In en, this message translates to:
  /// **'Approve, merge, retry, cancel, and run manual jobs'**
  String get subscriptionBenefitActions;

  /// Subscription benefit: background to-do checks
  ///
  /// In en, this message translates to:
  /// **'Background checks that notify you about new to-do items'**
  String get subscriptionBenefitNotifications;

  /// Subscription benefit: productivity limits lifted
  ///
  /// In en, this message translates to:
  /// **'Unlimited favorites, instead of the free limit of three'**
  String get subscriptionBenefitFavorites;

  /// Purchase button, with the price as the store formats it
  ///
  /// In en, this message translates to:
  /// **'Subscribe for {price}'**
  String subscriptionSubscribe(String price);

  /// Auto-renewal terms shown at the point of purchase, required by App Store Review Guideline 3.1.2
  ///
  /// In en, this message translates to:
  /// **'The subscription renews every month until you cancel it. Cancel any time in your store account; cancelling takes effect at the end of the paid month.'**
  String get subscriptionRenewalTerms;

  /// Link to the Terms of Use (EULA) shown at the point of purchase
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get subscriptionTerms;

  /// Link to the privacy policy shown at the point of purchase
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get subscriptionPrivacy;

  /// Restores an existing subscription on a new device
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get subscriptionRestore;

  /// Shown when the store returns no product to sell
  ///
  /// In en, this message translates to:
  /// **'The store is not available right now. Try again later.'**
  String get subscriptionUnavailable;

  /// Shown when a purchase or restore fails
  ///
  /// In en, this message translates to:
  /// **'That did not go through. Nothing was charged.'**
  String get subscriptionError;

  /// Confirms a successful restore
  ///
  /// In en, this message translates to:
  /// **'Your subscription is active.'**
  String get subscriptionRestored;

  /// Shown when a restore finds nothing to restore
  ///
  /// In en, this message translates to:
  /// **'No subscription found for this store account.'**
  String get subscriptionNothingToRestore;

  /// Bottom navigation / rail label for the home destination
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation / rail label for the inbox destination
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get navInbox;

  /// Bottom navigation / rail label for the search destination
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Bottom navigation / rail label for the profile destination
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// Title of the profile (Me) screen
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meTitle;

  /// Profile entry that opens settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get meSettings;

  /// Profile entry that opens the account switcher
  ///
  /// In en, this message translates to:
  /// **'Switch account'**
  String get meAccounts;

  /// No description provided for @projectLabelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get projectLabelsTitle;

  /// No description provided for @projectLabelsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load labels.'**
  String get projectLabelsError;

  /// No description provided for @projectLabelsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No labels yet'**
  String get projectLabelsEmpty;

  /// No description provided for @projectLabelsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching labels'**
  String get projectLabelsNoMatch;

  /// No description provided for @projectLabelSearch.
  ///
  /// In en, this message translates to:
  /// **'Search labels'**
  String get projectLabelSearch;

  /// No description provided for @projectLabelNew.
  ///
  /// In en, this message translates to:
  /// **'New label'**
  String get projectLabelNew;

  /// No description provided for @projectLabelGroup.
  ///
  /// In en, this message translates to:
  /// **'Group label'**
  String get projectLabelGroup;

  /// No description provided for @projectLabelProject.
  ///
  /// In en, this message translates to:
  /// **'Project label'**
  String get projectLabelProject;

  /// No description provided for @projectLabelError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this label.'**
  String get projectLabelError;

  /// No description provided for @projectLabelOpenIssues.
  ///
  /// In en, this message translates to:
  /// **'Open issues'**
  String get projectLabelOpenIssues;

  /// No description provided for @projectLabelClosedIssues.
  ///
  /// In en, this message translates to:
  /// **'Closed issues'**
  String get projectLabelClosedIssues;

  /// No description provided for @projectLabelOpenMrs.
  ///
  /// In en, this message translates to:
  /// **'Open merge requests'**
  String get projectLabelOpenMrs;

  /// No description provided for @projectLabelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get projectLabelName;

  /// No description provided for @projectLabelColor.
  ///
  /// In en, this message translates to:
  /// **'Color (#RRGGBB)'**
  String get projectLabelColor;

  /// No description provided for @projectLabelDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get projectLabelDescription;

  /// No description provided for @projectLabelRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get projectLabelRequired;

  /// No description provided for @projectLabelInvalidColor.
  ///
  /// In en, this message translates to:
  /// **'Enter a color like #5843AD'**
  String get projectLabelInvalidColor;

  /// No description provided for @projectLabelCreate.
  ///
  /// In en, this message translates to:
  /// **'Create label'**
  String get projectLabelCreate;

  /// No description provided for @projectLabelCreateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the label. Check your permissions and input.'**
  String get projectLabelCreateError;

  /// No description provided for @tagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsTitle;

  /// No description provided for @tagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get tagsEmpty;

  /// No description provided for @tagsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load tags.'**
  String get tagsError;

  /// No description provided for @tagsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching tags'**
  String get tagsNoMatch;

  /// No description provided for @tagSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tags'**
  String get tagSearchHint;

  /// No description provided for @tagError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this tag.'**
  String get tagError;

  /// No description provided for @tagProtected.
  ///
  /// In en, this message translates to:
  /// **'Protected tag'**
  String get tagProtected;

  /// No description provided for @tagNew.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get tagNew;

  /// No description provided for @tagName.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagName;

  /// No description provided for @tagFromRef.
  ///
  /// In en, this message translates to:
  /// **'Create from branch, tag, or commit SHA'**
  String get tagFromRef;

  /// No description provided for @tagMessage.
  ///
  /// In en, this message translates to:
  /// **'Message (optional)'**
  String get tagMessage;

  /// No description provided for @tagPipelineNotice.
  ///
  /// In en, this message translates to:
  /// **'Creating a tag may start a CI/CD pipeline.'**
  String get tagPipelineNotice;

  /// No description provided for @tagFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get tagFieldRequired;

  /// No description provided for @tagCreate.
  ///
  /// In en, this message translates to:
  /// **'Create tag'**
  String get tagCreate;

  /// No description provided for @tagCreateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the tag. Check your permissions and the reference.'**
  String get tagCreateError;

  /// No description provided for @snippetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Snippets'**
  String get snippetsTitle;

  /// No description provided for @snippetsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No snippets yet'**
  String get snippetsEmpty;

  /// No description provided for @snippetsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load snippets.'**
  String get snippetsError;

  /// No description provided for @snippetError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this snippet.'**
  String get snippetError;

  /// No description provided for @snippetContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get snippetContent;

  /// No description provided for @snippetContentError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load snippet content.'**
  String get snippetContentError;

  /// Home section title for recently opened projects
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homeRecents;

  /// Title of the project wiki page list
  ///
  /// In en, this message translates to:
  /// **'Wiki'**
  String get wikiTitle;

  /// Shown when a project wiki has no pages
  ///
  /// In en, this message translates to:
  /// **'No wiki pages yet.'**
  String get wikiEmpty;

  /// Shown when loading the project wiki fails
  ///
  /// In en, this message translates to:
  /// **'Could not load wiki pages.'**
  String get wikiListError;

  /// Shown when reading a wiki page fails
  ///
  /// In en, this message translates to:
  /// **'Could not load this wiki page.'**
  String get wikiPageError;

  /// Project package registry title and entry
  ///
  /// In en, this message translates to:
  /// **'Package registry'**
  String get packageRegistryTitle;

  /// Empty project package registry
  ///
  /// In en, this message translates to:
  /// **'No packages yet.'**
  String get packageRegistryEmpty;

  /// Package list loading error
  ///
  /// In en, this message translates to:
  /// **'Could not load packages.'**
  String get packageRegistryError;

  /// Package detail loading error
  ///
  /// In en, this message translates to:
  /// **'Could not load this package.'**
  String get packageDetailError;

  /// Package files section title
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get packageFiles;

  /// Empty package files section
  ///
  /// In en, this message translates to:
  /// **'This package has no files.'**
  String get packageFilesEmpty;

  /// Load the next page of packages or package files
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get packageLoadMore;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
