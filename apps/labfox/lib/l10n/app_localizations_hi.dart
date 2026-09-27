// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get protectedTagsTitle => 'सुरक्षित टैग';

  @override
  String get protectedTagsEmpty => 'कोई सुरक्षित टैग नियम नहीं मिला।';

  @override
  String get protectedTagsError => 'सुरक्षित टैग लोड नहीं हो सके।';

  @override
  String get protectedTagsLoadMore => 'और दिखाएं';

  @override
  String get protectedTagCreateAccess => 'बनाने की अनुमति';

  @override
  String get protectedEnvironmentsTitle => 'सुरक्षित परिवेश';

  @override
  String get protectedEnvironmentsEmpty =>
      'कोई सुरक्षित परिवेश नियम नहीं मिला।';

  @override
  String get protectedEnvironmentsError => 'सुरक्षित परिवेश लोड नहीं हो सके।';

  @override
  String get protectedEnvironmentsUnavailable =>
      'सुरक्षित परिवेश उपलब्ध नहीं हैं या आपके पास पहुँच नहीं है।';

  @override
  String get protectedEnvironmentsLoadMore => 'और दिखाएं';

  @override
  String get protectedEnvironmentDeployAccess => 'डिप्लॉय करने की अनुमति';

  @override
  String get protectedEnvironmentApprovalRules => 'अनुमोदन नियम';

  @override
  String protectedEnvironmentApprovalCount(int count) {
    return 'आवश्यक अनुमोदन: $count';
  }

  @override
  String get protectedBranchesTitle => 'सुरक्षित ब्रांच';

  @override
  String get protectedBranchesEmpty => 'कोई सुरक्षित ब्रांच नियम नहीं मिला।';

  @override
  String get protectedBranchesError => 'सुरक्षित ब्रांच लोड नहीं हो सके।';

  @override
  String get protectedBranchesLoadMore => 'और दिखाएं';

  @override
  String get protectedBranchPushAccess => 'पुश की अनुमति';

  @override
  String get protectedBranchMergeAccess => 'मर्ज की अनुमति';

  @override
  String get protectedBranchForcePush => 'फोर्स पुश';

  @override
  String get protectedBranchCodeOwnerApproval => 'कोड स्वामी की स्वीकृति';

  @override
  String get protectedBranchInherited => 'समूह से विरासत में मिला';

  @override
  String get protectedBranchEnabled => 'सक्षम';

  @override
  String get protectedBranchDisabled => 'अक्षम';

  @override
  String get protectedBranchNoAccess => 'कोई अनुमति नियम नहीं';

  @override
  String get linkedIssuesTitle => 'लिंक किए गए इश्यू';

  @override
  String get linkedIssuesError => 'लिंक किए गए इश्यू लोड नहीं हो सके।';

  @override
  String get linkedIssuesLoadMore => 'और दिखाएं';

  @override
  String get linkedIssuesRelatesTo => 'संबंधित';

  @override
  String get linkedIssuesBlocks => 'ब्लॉक करता है';

  @override
  String get linkedIssuesBlockedBy => 'इसके द्वारा ब्लॉक';

  @override
  String get groupLabelsTitle => 'समूह लेबल';

  @override
  String get groupLabelsEmpty => 'अभी कोई समूह लेबल नहीं है';

  @override
  String get groupLabelsError => 'समूह लेबल लोड नहीं हो सके।';

  @override
  String get groupMembersTitle => 'समूह सदस्य';

  @override
  String get groupMembersSearch => 'समूह सदस्यों को खोजें';

  @override
  String get groupMembersEmpty => 'कोई समूह सदस्य नहीं मिला।';

  @override
  String get groupMembersError => 'समूह सदस्यों को लोड नहीं किया जा सका।';

  @override
  String get pipelineSchedulesTitle => 'पाइपलाइन शेड्यूल';

  @override
  String get pipelineSchedulesAll => 'सभी';

  @override
  String get pipelineSchedulesActive => 'सक्रिय';

  @override
  String get pipelineSchedulesInactive => 'निष्क्रिय';

  @override
  String get pipelineSchedulesEmpty => 'कोई पाइपलाइन शेड्यूल नहीं मिला।';

  @override
  String get pipelineSchedulesError => 'पाइपलाइन शेड्यूल लोड नहीं हो सके।';

  @override
  String get pipelineSchedulesLoadMore => 'और लोड करें';

  @override
  String get pipelineScheduleDetailError => 'यह शेड्यूल लोड नहीं हो सका।';

  @override
  String pipelineScheduleNextRun(String date) {
    return 'अगला रन: $date';
  }

  @override
  String get pipelineScheduleNextRunLabel => 'अगला रन';

  @override
  String get pipelineScheduleRef => 'रेफ़';

  @override
  String get pipelineScheduleCron => 'शेड्यूल';

  @override
  String get pipelineScheduleTimezone => 'समय क्षेत्र';

  @override
  String get pipelineScheduleOwner => 'स्वामी';

  @override
  String get pipelineScheduleRunNow => 'अभी चलाएँ';

  @override
  String get pipelineScheduleRunSuccess => 'पाइपलाइन शेड्यूल शुरू हुआ।';

  @override
  String get pipelineScheduleRunError => 'पाइपलाइन शेड्यूल नहीं चल सका।';

  @override
  String get pipelineScheduleLastPipeline => 'पिछली पाइपलाइन';

  @override
  String pipelineSchedulePipelineNumber(int number) {
    return 'पाइपलाइन #$number';
  }

  @override
  String get deploymentsTitle => 'डिप्लॉयमेंट';

  @override
  String get deploymentsAll => 'सभी';

  @override
  String get deploymentsSuccess => 'सफल';

  @override
  String get deploymentsFailed => 'विफल';

  @override
  String get deploymentsRunning => 'चल रहा है';

  @override
  String get deploymentsCanceled => 'रद्द';

  @override
  String get deploymentsCreated => 'बनाया गया';

  @override
  String get deploymentsBlocked => 'अवरुद्ध';

  @override
  String get deploymentsUnknownStatus => 'अज्ञात स्थिति';

  @override
  String get deploymentsEmpty => 'कोई डिप्लॉयमेंट नहीं मिला।';

  @override
  String get deploymentsError => 'डिप्लॉयमेंट लोड नहीं हो सके।';

  @override
  String get deploymentsLoadMore => 'और लोड करें';

  @override
  String get deploymentsEnvironmentSearch => 'परिवेश के नाम से फ़िल्टर करें';

  @override
  String get deploymentsUnknownEnvironment => 'अज्ञात परिवेश';

  @override
  String get deploymentDetailError => 'यह डिप्लॉयमेंट लोड नहीं हो सका।';

  @override
  String deploymentNumber(int number) {
    return 'डिप्लॉयमेंट #$number';
  }

  @override
  String get deploymentEnvironment => 'परिवेश';

  @override
  String get deploymentRef => 'रेफ़';

  @override
  String get deploymentCommit => 'कमिट';

  @override
  String get deploymentJob => 'जॉब';

  @override
  String get deploymentPipeline => 'पाइपलाइन';

  @override
  String get deploymentCreatedAt => 'बनाया गया';

  @override
  String get deploymentUpdatedAt => 'अपडेट किया गया';

  @override
  String get deploymentUser => 'डिप्लॉय करने वाला';

  @override
  String get releasesTitle => 'रिलीज़';

  @override
  String get releasesEmpty => 'अभी कोई रिलीज़ नहीं है।';

  @override
  String get releasesError => 'रिलीज़ लोड नहीं हो सकीं।';

  @override
  String get releaseDetailError => 'यह रिलीज़ लोड नहीं हो सकी।';

  @override
  String get releaseAssetsTitle => 'एसेट';

  @override
  String get releaseLoadMore => 'और लोड करें';

  @override
  String get releaseUpcoming => 'आगामी';

  @override
  String get activityTitle => 'गतिविधि';

  @override
  String get activityAll => 'सभी';

  @override
  String get activityIssues => 'समस्याएँ';

  @override
  String get activityMergeRequests => 'मर्ज अनुरोध';

  @override
  String get activityEmpty => 'हाल की कोई गतिविधि नहीं है।';

  @override
  String get activityError => 'प्रोजेक्ट गतिविधि लोड नहीं हो सकी।';

  @override
  String get activityLoadMore => 'और देखें';

  @override
  String get activityUnknownActor => 'अज्ञात उपयोगकर्ता';

  @override
  String get activityPush => 'पुश';

  @override
  String get activityEvent => 'प्रोजेक्ट गतिविधि';

  @override
  String activityBy(String actor, String action) {
    return '$actor ने $action';
  }

  @override
  String get environmentsTitle => 'परिवेश';

  @override
  String get environmentsAll => 'सभी';

  @override
  String get environmentsAvailable => 'उपलब्ध';

  @override
  String get environmentsStopping => 'रुक रहा है';

  @override
  String get environmentsStopped => 'रुका हुआ';

  @override
  String get environmentsSearch => 'परिवेश खोजें';

  @override
  String get environmentsSearchLength => 'कम से कम 3 अक्षर दर्ज करें।';

  @override
  String get environmentsEmpty => 'कोई परिवेश नहीं मिला।';

  @override
  String get environmentsError => 'परिवेश लोड नहीं हो सके।';

  @override
  String get environmentsLoadMore => 'और देखें';

  @override
  String get environmentDetailError => 'यह परिवेश लोड नहीं हो सका।';

  @override
  String get environmentAutoStop => 'स्वचालित रोक';

  @override
  String get environmentOpenUrl => 'परिवेश खोलें';

  @override
  String get environmentLatestDeployment => 'नवीनतम डिप्लॉयमेंट';

  @override
  String get environmentUnknownStatus => 'अज्ञात स्थिति';

  @override
  String get projectMembersTitle => 'सदस्य';

  @override
  String get projectMembersSearch => 'सदस्य खोजें';

  @override
  String get projectMembersClearSearch => 'खोज साफ़ करें';

  @override
  String get projectMembersEmpty => 'कोई सदस्य नहीं मिला।';

  @override
  String get projectMembersError => 'सदस्य लोड नहीं हो सके।';

  @override
  String get projectMembersLoadMore => 'और लोड करें';

  @override
  String get projectMembersExpiry => 'समाप्ति';

  @override
  String get memberRoleNoAccess => 'कोई पहुँच नहीं';

  @override
  String get memberRoleMinimal => 'न्यूनतम पहुँच';

  @override
  String get memberRoleGuest => 'अतिथि';

  @override
  String get memberRolePlanner => 'योजनाकार';

  @override
  String get memberRoleReporter => 'रिपोर्टर';

  @override
  String get memberRoleSecurityManager => 'सुरक्षा प्रबंधक';

  @override
  String get memberRoleDeveloper => 'डेवलपर';

  @override
  String get memberRoleMaintainer => 'मेंटेनर';

  @override
  String get memberRoleOwner => 'स्वामी';

  @override
  String get memberRoleUnknown => 'अज्ञात भूमिका';

  @override
  String get containerRegistryTitle => 'कंटेनर रजिस्ट्री';

  @override
  String get containerRegistryEmpty => 'अभी कोई कंटेनर इमेज नहीं है।';

  @override
  String get containerRegistryError => 'कंटेनर इमेज लोड नहीं हो सकीं।';

  @override
  String get containerTagsTitle => 'इमेज टैग';

  @override
  String get containerTagsEmpty => 'अभी कोई टैग नहीं है।';

  @override
  String get containerTagsError => 'इमेज टैग लोड नहीं हो सके।';

  @override
  String get containerTagError => 'यह टैग लोड नहीं हो सका।';

  @override
  String get containerTagDigest => 'डाइजेस्ट';

  @override
  String get containerTagRevision => 'रिविज़न';

  @override
  String get containerTagSize => 'आकार (बाइट)';

  @override
  String get containerLoadMore => 'और लोड करें';

  @override
  String get milestonesTitle => 'माइलस्टोन';

  @override
  String get milestonesActive => 'सक्रिय';

  @override
  String get milestonesClosed => 'बंद';

  @override
  String get milestonesEmpty => 'इस स्थिति में कोई माइलस्टोन नहीं है।';

  @override
  String get milestonesError => 'माइलस्टोन लोड नहीं हो सके।';

  @override
  String get milestoneDetailError => 'यह माइलस्टोन लोड नहीं हो सका।';

  @override
  String get milestoneStartDate => 'शुरू होने की तारीख';

  @override
  String get milestoneDueDate => 'नियत तारीख';

  @override
  String get milestoneLoadMore => 'और लोड करें';

  @override
  String get appTitle => 'LabFox';

  @override
  String get homeTitle => 'होम';

  @override
  String homeSignedInAs(String username) {
    return '$username के रूप में साइन इन';
  }

  @override
  String get homeEmptyWork =>
      'आपके इशू, मर्ज रिक्वेस्ट और पाइपलाइन यहाँ दिखाई देंगे।';

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
  String get signOut => 'साइन आउट';

  @override
  String get signInTitle => 'GitLab खाता कनेक्ट करें';

  @override
  String get signInNoAccountNote =>
      'LabFox का अपना कोई खाता नहीं है। जो GitLab आप पहले से उपयोग करते हैं उससे जुड़ें — gitlab.com, या आपका अपना होस्ट किया इंस्टेंस।';

  @override
  String get signInInstanceLabel => 'GitLab इंस्टेंस URL';

  @override
  String get signInInstanceRequired => 'अपना GitLab इंस्टेंस URL दर्ज करें।';

  @override
  String get signInInstanceInvalid =>
      'एक मान्य https URL दर्ज करें, उदाहरण के लिए https://gitlab.com';

  @override
  String get signInTokenLabel => 'पर्सनल एक्सेस टोकन';

  @override
  String get signInTokenHelp => 'api और read_user स्कोप आवश्यक हैं।';

  @override
  String get signInTokenToggle => 'टोकन दिखाएँ या छिपाएँ';

  @override
  String get signInTokenRequired => 'पर्सनल एक्सेस टोकन दर्ज करें।';

  @override
  String get signInSubmit => 'साइन इन';

  @override
  String get signInOr => 'या';

  @override
  String get signInOAuthButton => 'अपने इंस्टेंस से अधिकृत करें';

  @override
  String get signInClientIdLabel => 'OAuth क्लाइंट ID';

  @override
  String get signInClientIdHelp =>
      'केवल self-hosted इंस्टेंस पर OAuth के लिए आवश्यक।';

  @override
  String get signInOAuthNeedsClientId =>
      'इस इंस्टेंस के लिए OAuth क्लाइंट ID दर्ज करें।';

  @override
  String get signInErrorToken =>
      'टोकन अस्वीकृत हो गया। जाँचें कि यह सही है और समाप्त नहीं हुआ है।';

  @override
  String get signInErrorScope =>
      'टोकन में आवश्यक स्कोप नहीं है। इसे api और read_user चाहिए।';

  @override
  String get signInErrorUnreachable =>
      'उस इंस्टेंस तक नहीं पहुँच सके। URL, अपना नेटवर्क और प्रमाणपत्र भरोसे की जाँच करें।';

  @override
  String get signInErrorGeneric => 'साइन इन विफल रहा। कृपया पुनः प्रयास करें।';

  @override
  String get scopeAssigned => 'Assigned';

  @override
  String get scopeCreated => 'Created';

  @override
  String get homeRefresh => 'Refresh';

  @override
  String get homeFavoritesEmpty => 'Star projects to pin them here.';

  @override
  String get homeMyWork => 'मेरा काम';

  @override
  String get homeProjects => 'प्रोजेक्ट';

  @override
  String get homeGroups => 'Groups';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupsEmpty => 'You are not a member of any groups yet.';

  @override
  String get groupsError => 'Could not load your groups.';

  @override
  String get groupDetailTitle => 'समूह';

  @override
  String get groupDetailError => 'इस समूह को लोड नहीं किया जा सका।';

  @override
  String get groupSubgroups => 'उपसमूह';

  @override
  String get groupSubgroupsEmpty => 'कोई उपसमूह नहीं है।';

  @override
  String get groupProjects => 'प्रोजेक्ट';

  @override
  String get groupProjectsEmpty => 'इस समूह में कोई प्रोजेक्ट नहीं है।';

  @override
  String get groupLoadMore => 'और लोड करें';

  @override
  String get projectsTitle => 'प्रोजेक्ट';

  @override
  String get projectsEmpty => 'आप अभी तक किसी प्रोजेक्ट के सदस्य नहीं हैं।';

  @override
  String get projectsError => 'आपके प्रोजेक्ट लोड नहीं हो सके।';

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
  String get retry => 'पुनः प्रयास करें';

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
  String get issueEdit => 'समस्या संपादित करें';

  @override
  String get issueSaveChanges => 'बदलाव सहेजें';

  @override
  String get issueEditError =>
      'समस्या सहेजी नहीं जा सकी। अनुमतियाँ जाँचें और फिर प्रयास करें।';

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
  String get projectOverviewTitle => 'प्रोजेक्ट';

  @override
  String get projectOverviewError => 'यह प्रोजेक्ट लोड नहीं हो सका।';

  @override
  String get projectOverviewNoReadme => 'इस प्रोजेक्ट में कोई README नहीं है।';

  @override
  String get projectOverviewRepository => 'रिपॉज़िटरी';

  @override
  String get repositoryTitle => 'रिपॉज़िटरी';

  @override
  String get repositoryError => 'यह डायरेक्टरी लोड नहीं हो सकी।';

  @override
  String get repositoryEmpty => 'यह डायरेक्टरी खाली है।';

  @override
  String get fileError => 'यह फ़ाइल लोड नहीं हो सकी।';

  @override
  String get fileNotFound => 'यह फ़ाइल नहीं मिली।';

  @override
  String get fileBinary =>
      'यह एक बाइनरी फ़ाइल है और इसे टेक्स्ट के रूप में नहीं दिखाया जा सकता।';

  @override
  String get fileCopy => 'Copy contents';

  @override
  String get fileCopied => 'Contents copied';

  @override
  String get projectOverviewBranches => 'ब्रांच';

  @override
  String get projectOverviewCommits => 'कमिट';

  @override
  String get projectOverviewCode => 'Code';

  @override
  String get projectOverviewBrowseCode => 'Browse code';

  @override
  String get branchesTitle => 'ब्रांच';

  @override
  String get branchesError => 'ब्रांच लोड नहीं हो सकीं।';

  @override
  String get branchesEmpty => 'इस रिपॉज़िटरी में कोई ब्रांच नहीं है।';

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
  String get branchDefault => 'डिफ़ॉल्ट ब्रांच';

  @override
  String get commitsTitle => 'कमिट';

  @override
  String get commitsError => 'कमिट लोड नहीं हो सके।';

  @override
  String get commitsEmpty => 'इस ब्रांच पर अभी कोई कमिट नहीं है।';

  @override
  String get commitTitle => 'कमिट';

  @override
  String get commitError => 'यह कमिट लोड नहीं हो सका।';

  @override
  String get projectOverviewIssues => 'इशू';

  @override
  String get issuesTitle => 'इशू';

  @override
  String get issuesFilterOpen => 'खुले';

  @override
  String get issuesFilterClosed => 'बंद';

  @override
  String get issuesError => 'इशू लोड नहीं हो सके।';

  @override
  String get issuesEmpty => 'यहाँ कोई इशू नहीं है।';

  @override
  String get issueError => 'यह इशू लोड नहीं हो सका।';

  @override
  String get issueStateOpen => 'खुला';

  @override
  String get issueStateClosed => 'बंद';

  @override
  String get issueNoDescription => 'कोई विवरण नहीं दिया गया।';

  @override
  String issueOpenedBy(String username) {
    return '$username द्वारा खोला गया';
  }

  @override
  String get projectOverviewMergeRequests => 'मर्ज रिक्वेस्ट';

  @override
  String get mergeRequestsTitle => 'मर्ज रिक्वेस्ट';

  @override
  String get mrFilterOpen => 'खुले';

  @override
  String get mrFilterMerged => 'मर्ज किए गए';

  @override
  String get mrFilterClosed => 'बंद';

  @override
  String get mergeRequestsError => 'मर्ज रिक्वेस्ट लोड नहीं हो सकीं।';

  @override
  String get mergeRequestsEmpty => 'यहाँ कोई मर्ज रिक्वेस्ट नहीं है।';

  @override
  String get mergeRequestError => 'यह मर्ज रिक्वेस्ट लोड नहीं हो सकी।';

  @override
  String get mergeRequestNoDescription => 'कोई विवरण नहीं दिया गया।';

  @override
  String get mrStateOpen => 'खुला';

  @override
  String get mrStateMerged => 'मर्ज किया गया';

  @override
  String get mrStateClosed => 'बंद';

  @override
  String get mrDraft => 'ड्राफ़्ट';

  @override
  String get changesTitle => 'परिवर्तन';

  @override
  String get changesError => 'परिवर्तन लोड नहीं हो सके।';

  @override
  String get changesEmpty => 'कोई परिवर्तन नहीं।';

  @override
  String get changesBinary => 'बाइनरी फ़ाइल — नहीं दिखाई गई।';

  @override
  String get commitViewChanges => 'परिवर्तन देखें';

  @override
  String get mrViewChanges => 'परिवर्तन देखें';

  @override
  String get changesOmitted =>
      'diff बहुत बड़ा है या संक्षिप्त है, इसलिए नहीं दिखाया गया।';

  @override
  String get commentsHeading => 'टिप्पणियाँ';

  @override
  String get commentsError => 'टिप्पणियाँ लोड नहीं हो सकीं।';

  @override
  String get commentsEmpty => 'अभी तक कोई टिप्पणी नहीं।';

  @override
  String get commentComposerHint => 'एक टिप्पणी लिखें…';

  @override
  String get commentComposerSubmit => 'टिप्पणी करें';

  @override
  String get commentPostForbidden =>
      'आपको यहाँ टिप्पणी करने की अनुमति नहीं है। जाँचें कि आपके टोकन में api स्कोप है।';

  @override
  String get commentPostError =>
      'आपकी टिप्पणी पोस्ट नहीं हो सकी। कृपया पुनः प्रयास करें।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get mrApprove => 'स्वीकृत करें';

  @override
  String get mrUnapprove => 'स्वीकृति वापस लें';

  @override
  String get mrMerge => 'मर्ज करें';

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
  String get mrMergeConfirmTitle => 'इस मर्ज रिक्वेस्ट को मर्ज करें?';

  @override
  String mrMergeConfirmBody(String mr) {
    return '$mr को मर्ज करना पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String mrApprovalsSummary(int approved, int required) {
    return '$required में से $approved स्वीकृतियाँ';
  }

  @override
  String get mrNotMergeable =>
      'अभी यह मर्ज रिक्वेस्ट मर्ज नहीं हो सकती। इसे स्वीकृति, रीबेस, या पास पाइपलाइन की ज़रूरत हो सकती है।';

  @override
  String get mrActionForbidden =>
      'आपके पास इस क्रिया की अनुमति नहीं है। अपने टोकन स्कोप और भूमिका की जाँच करें।';

  @override
  String get mrActionError =>
      'क्रिया पूरी नहीं हो सकी। कृपया पुनः प्रयास करें।';

  @override
  String get projectOverviewPipelines => 'पाइपलाइन';

  @override
  String get pipelinesTitle => 'पाइपलाइन';

  @override
  String get pipelinesError => 'पाइपलाइन लोड नहीं हो सकीं।';

  @override
  String get pipelinesEmpty => 'अभी तक कोई पाइपलाइन नहीं।';

  @override
  String get pipelineError => 'यह पाइपलाइन लोड नहीं हो सकी।';

  @override
  String get pipelineJobsError => 'जॉब लोड नहीं हो सके।';

  @override
  String get pipelineNoJobs => 'इस पाइपलाइन में कोई जॉब नहीं है।';

  @override
  String get jobTitle => 'जॉब';

  @override
  String get jobError => 'यह जॉब लोड नहीं हो सकी।';

  @override
  String get jobRefresh => 'रीफ़्रेश';

  @override
  String get jobLogError => 'लॉग लोड नहीं हो सका।';

  @override
  String get jobLogEmpty => 'इस जॉब में कोई लॉग आउटपुट नहीं है।';

  @override
  String get jobActionRetry => 'पुनः प्रयास';

  @override
  String get jobActionCancel => 'रद्द करें';

  @override
  String get jobActionRun => 'चलाएँ';

  @override
  String get jobActionForbidden => 'आपके पास इस क्रिया की अनुमति नहीं है।';

  @override
  String get jobActionInvalid =>
      'जॉब की वर्तमान स्थिति में यह क्रिया उपलब्ध नहीं है।';

  @override
  String get jobActionError =>
      'क्रिया पूरी नहीं हो सकी। कृपया पुनः प्रयास करें।';

  @override
  String get pipelineActionRetry => 'पुनः प्रयास';

  @override
  String get pipelineActionCancel => 'रद्द करें';

  @override
  String get pipelineActionForbidden => 'आपके पास इस क्रिया की अनुमति नहीं है।';

  @override
  String get pipelineActionInvalid =>
      'पाइपलाइन की वर्तमान स्थिति में यह क्रिया उपलब्ध नहीं है।';

  @override
  String get pipelineActionError =>
      'क्रिया पूरी नहीं हो सकी। कृपया पुनः प्रयास करें।';

  @override
  String get accountsTitle => 'खाते';

  @override
  String get accountAdd => 'खाता जोड़ें';

  @override
  String get accountRemove => 'खाता हटाएँ';

  @override
  String get homeSwitchAccount => 'खाते';

  @override
  String get homeInbox => 'कार्य सूची';

  @override
  String get inboxTitle => 'कार्य सूची';

  @override
  String get inboxEmpty => 'आप पूरी तरह अद्यतित हैं।';

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
  String get inboxError => 'आपकी कार्य सूची लोड नहीं हो सकी।';

  @override
  String get inboxMarkAllDone => 'सभी को पूर्ण करें';

  @override
  String get inboxMarkDone => 'पूर्ण करें';

  @override
  String get inboxMarkDoneError =>
      'आइटम को हटाया नहीं जा सका। कृपया पुनः प्रयास करें।';

  @override
  String get inboxActionAssigned => 'आपको सौंपा गया';

  @override
  String get inboxActionMentioned => 'आपका उल्लेख किया';

  @override
  String get inboxActionBuildFailed => 'पाइपलाइन विफल';

  @override
  String get inboxActionMarked => 'एक कार्य जोड़ा';

  @override
  String get inboxActionApprovalRequired => 'अनुमोदन आवश्यक';

  @override
  String get inboxActionUnmergeable => 'मर्ज नहीं किया जा सकता';

  @override
  String get inboxActionDirectlyAddressed => 'आपको सीधे संबोधित किया';

  @override
  String get homeSearch => 'खोज';

  @override
  String get searchTitle => 'खोज';

  @override
  String get searchHint => 'प्रोजेक्ट, इश्यू, मर्ज अनुरोध खोजें';

  @override
  String get searchScopeProjects => 'प्रोजेक्ट';

  @override
  String get searchScopeIssues => 'इश्यू';

  @override
  String get searchScopeMergeRequests => 'मर्ज अनुरोध';

  @override
  String get searchInitial => 'खोजने के लिए टाइप करें।';

  @override
  String get searchEmpty => 'कोई परिणाम नहीं मिला।';

  @override
  String get searchError => 'खोज पूरी नहीं हो सकी।';

  @override
  String get searchLoadMore => 'और लोड करें';

  @override
  String get listSearchHint => 'Search by title';

  @override
  String get listSearchClose => 'Close search';

  @override
  String get projectAddFavorite => 'पसंदीदा में जोड़ें';

  @override
  String get projectRemoveFavorite => 'पसंदीदा से हटाएं';

  @override
  String get homeFavorites => 'पसंदीदा';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsAccounts => 'खाते';

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
  String get settingsLicenses => 'ओपन सोर्स लाइसेंस';

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
  String get navHome => 'होम';

  @override
  String get navInbox => 'इनबॉक्स';

  @override
  String get navSearch => 'खोज';

  @override
  String get navMe => 'मैं';

  @override
  String get meTitle => 'मैं';

  @override
  String get meSettings => 'सेटिंग्स';

  @override
  String get meAccounts => 'खाता बदलें';

  @override
  String get projectLabelsTitle => 'लेबल';

  @override
  String get projectLabelsError => 'लेबल लोड नहीं हो सके।';

  @override
  String get projectLabelsEmpty => 'अभी कोई लेबल नहीं है';

  @override
  String get projectLabelsNoMatch => 'कोई मेल खाता लेबल नहीं है';

  @override
  String get projectLabelSearch => 'लेबल खोजें';

  @override
  String get projectLabelNew => 'नया लेबल';

  @override
  String get projectLabelGroup => 'समूह लेबल';

  @override
  String get projectLabelProject => 'प्रोजेक्ट लेबल';

  @override
  String get projectLabelError => 'यह लेबल लोड नहीं हो सका।';

  @override
  String get projectLabelOpenIssues => 'खुले इश्यू';

  @override
  String get projectLabelClosedIssues => 'बंद इश्यू';

  @override
  String get projectLabelOpenMrs => 'खुले मर्ज अनुरोध';

  @override
  String get projectLabelName => 'नाम';

  @override
  String get projectLabelColor => 'रंग (#RRGGBB)';

  @override
  String get projectLabelDescription => 'विवरण (वैकल्पिक)';

  @override
  String get projectLabelRequired => 'यह फ़ील्ड आवश्यक है';

  @override
  String get projectLabelInvalidColor => '#5843AD जैसा रंग दर्ज करें';

  @override
  String get projectLabelCreate => 'लेबल बनाएं';

  @override
  String get projectLabelCreateError =>
      'लेबल नहीं बन सका। अनुमतियाँ और इनपुट जांचें।';

  @override
  String get tagsTitle => 'टैग';

  @override
  String get tagsEmpty => 'अभी कोई टैग नहीं है';

  @override
  String get tagsError => 'टैग लोड नहीं हो सके।';

  @override
  String get tagsNoMatch => 'कोई मेल खाता टैग नहीं है';

  @override
  String get tagSearchHint => 'टैग खोजें';

  @override
  String get tagError => 'यह टैग लोड नहीं हो सका।';

  @override
  String get tagProtected => 'सुरक्षित टैग';

  @override
  String get tagNew => 'नया टैग';

  @override
  String get tagName => 'टैग का नाम';

  @override
  String get tagFromRef => 'ब्रांच, टैग या कमिट SHA से बनाएं';

  @override
  String get tagMessage => 'संदेश (वैकल्पिक)';

  @override
  String get tagPipelineNotice =>
      'टैग बनाने से CI/CD पाइपलाइन शुरू हो सकती है।';

  @override
  String get tagFieldRequired => 'यह फ़ील्ड आवश्यक है';

  @override
  String get tagCreate => 'टैग बनाएं';

  @override
  String get tagCreateError => 'टैग नहीं बन सका। अनुमतियाँ और रेफ़रेंस जांचें।';

  @override
  String get snippetsTitle => 'स्निपेट';

  @override
  String get snippetsEmpty => 'अभी कोई स्निपेट नहीं है';

  @override
  String get snippetsError => 'स्निपेट लोड नहीं हो सके।';

  @override
  String get snippetError => 'यह स्निपेट लोड नहीं हो सका।';

  @override
  String get snippetContent => 'सामग्री';

  @override
  String get snippetContentError => 'स्निपेट सामग्री लोड नहीं हो सकी।';

  @override
  String get homeRecents => 'हाल ही में';

  @override
  String get wikiTitle => 'विकी';

  @override
  String get wikiEmpty => 'अभी कोई विकी पृष्ठ नहीं है।';

  @override
  String get wikiListError => 'विकी पृष्ठ लोड नहीं हो सके।';

  @override
  String get wikiPageError => 'यह विकी पृष्ठ लोड नहीं हो सका।';

  @override
  String get packageRegistryTitle => 'पैकेज रजिस्ट्री';

  @override
  String get packageRegistryEmpty => 'अभी कोई पैकेज नहीं है।';

  @override
  String get packageRegistryError => 'पैकेज लोड नहीं हो सके।';

  @override
  String get packageDetailError => 'यह पैकेज लोड नहीं हो सका।';

  @override
  String get packageFiles => 'फ़ाइलें';

  @override
  String get packageFilesEmpty => 'इस पैकेज में कोई फ़ाइल नहीं है।';

  @override
  String get packageLoadMore => 'और लोड करें';
}
