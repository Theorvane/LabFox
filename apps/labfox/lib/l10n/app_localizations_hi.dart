// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get pipelineScheduleExecutionEdit => 'निष्पादन सेटिंग संपादित करें';

  @override
  String get pipelineScheduleExecutionSave => 'सहेजें';

  @override
  String get pipelineScheduleExecutionActive => 'सक्रिय';

  @override
  String get pipelineScheduleExecutionRefRequired => 'रेफ़ दर्ज करें।';

  @override
  String get pipelineScheduleExecutionHint =>
      'GitLab रेफ़ की जाँच करता है। ब्रांच और टैग का नाम समान हो तो पूर्ण रेफ़ दर्ज करें। सहेजने पर भविष्य के रन पुनर्निर्धारित होते हैं; cron, समय क्षेत्र, वेरिएबल और इनपुट नहीं बदलते।';

  @override
  String get pipelineScheduleExecutionError =>
      'निष्पादन सेटिंग अपडेट नहीं की जा सकीं। अनुमतियाँ और रेफ़ जाँचें, फिर दोबारा प्रयास करें।';

  @override
  String get pipelineScheduleCreate => 'शेड्यूल बनाएँ';

  @override
  String get pipelineScheduleCreateTitle => 'नया पाइपलाइन शेड्यूल';

  @override
  String get pipelineScheduleCreateDescription => 'विवरण';

  @override
  String get pipelineScheduleCreateFieldRequired => 'कोई मान दर्ज करें।';

  @override
  String get pipelineScheduleCreateActive => 'सक्रिय';

  @override
  String get pipelineScheduleCreateHint =>
      'GitLab रेफ़, cron और समय क्षेत्र की जाँच करता है। UTC के लिए समय क्षेत्र खाली छोड़ें। ब्रांच और टैग का नाम समान हो तो पूर्ण रेफ़ दर्ज करें।';

  @override
  String get pipelineScheduleCreateError =>
      'इस पाइपलाइन शेड्यूल को बनाया नहीं जा सका। अनुमतियाँ, रेफ़, cron और समय क्षेत्र जाँचें।';

  @override
  String get releaseCreationMilestoneTitle => 'माइलस्टोन का शीर्षक (वैकल्पिक)';

  @override
  String get releaseCreationMilestoneAdd => 'माइलस्टोन जोड़ें';

  @override
  String get releaseCreationMilestoneRequired =>
      'माइलस्टोन का शीर्षक दर्ज करें।';

  @override
  String get releaseCreationMilestoneDuplicate =>
      'यह माइलस्टोन पहले से चुना गया है।';

  @override
  String releaseCreationMilestoneRemove(String title) {
    return 'माइलस्टोन $title हटाएँ';
  }

  @override
  String get releaseCreationMilestoneHelp =>
      'मौजूदा सटीक शीर्षक एक-एक करके दर्ज करें। समूह माइलस्टोन की उपलब्धता आपके GitLab प्लान पर निर्भर करती है।';

  @override
  String get releasePickerTitle => 'प्रोजेक्ट माइलस्टोन चुनें';

  @override
  String get releasePickerSearch => 'प्रोजेक्ट माइलस्टोन खोजें';

  @override
  String get releasePickerEmpty => 'कोई प्रोजेक्ट माइलस्टोन नहीं मिला।';

  @override
  String get releasePickerError => 'माइलस्टोन लोड नहीं हो सके।';

  @override
  String get releasePickerMore => 'और माइलस्टोन लोड करें';

  @override
  String get releasePickerUse => 'माइलस्टोन इस्तेमाल करें';

  @override
  String releasePickerRemove(String title) {
    return 'माइलस्टोन $title हटाएँ';
  }

  @override
  String get releaseCreationDateLabel => 'प्रकाशन की तारीख (वैकल्पिक)';

  @override
  String get releaseCreationDateDefault => 'प्रकाशन का समय GitLab तय करेगा।';

  @override
  String get releaseCreationChooseDate => 'प्रकाशन की तारीख चुनें';

  @override
  String get releaseCreationChooseTime => 'प्रकाशन का समय चुनें';

  @override
  String get releaseCreationClearDate => 'GitLab का प्रकाशन समय इस्तेमाल करें';

  @override
  String releaseCreationDateHelp(String zone) {
    return 'समय क्षेत्र: $zone। भविष्य की तारीख आगामी रिलीज़ और पिछली तारीख ऐतिहासिक रिलीज़ बनाती है।';
  }

  @override
  String get pipelineScheduleDelete => 'शेड्यूल हटाएँ';

  @override
  String get pipelineScheduleDeleteConfirmTitle => 'यह पाइपलाइन शेड्यूल हटाएँ?';

  @override
  String pipelineScheduleDeleteConfirmBody(String name) {
    return 'पाइपलाइन शेड्यूल \"$name\" स्थायी रूप से हटा दिया जाएगा। इसे पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String get pipelineScheduleDeleteError =>
      'इस पाइपलाइन शेड्यूल को हटाया नहीं जा सका। अपनी अनुमतियाँ जाँचें और फिर से प्रयास करें।';

  @override
  String get releaseScheduleEdit => 'रिलीज़ की तारीख संपादित करें';

  @override
  String get releaseScheduleChangeDate => 'तारीख बदलें';

  @override
  String get releaseScheduleChangeTime => 'समय बदलें';

  @override
  String get releaseScheduleSave => 'रिलीज़ की तारीख सहेजें';

  @override
  String get releaseScheduleError => 'रिलीज़ की तारीख अपडेट नहीं हो सकी।';

  @override
  String releaseScheduleHelp(String zone) {
    return 'समय आपके डिवाइस के समय क्षेत्र ($zone) में है। भविष्य की तारीख आगामी रिलीज़ निर्धारित करती है।';
  }

  @override
  String get pipelineScheduleEdit => 'शेड्यूल संपादित करें';

  @override
  String get pipelineScheduleSave => 'सहेजें';

  @override
  String get pipelineScheduleDescription => 'विवरण';

  @override
  String get pipelineScheduleFieldRequired => 'कोई मान दर्ज करें।';

  @override
  String get pipelineScheduleEditHint =>
      'GitLab cron अभिव्यक्ति और समय क्षेत्र की जाँच करता है। सहेजने पर भविष्य के रन पुनर्निर्धारित होते हैं; रेफ़, सक्रिय स्थिति, वेरिएबल और इनपुट सुरक्षित रहते हैं।';

  @override
  String get pipelineScheduleEditError =>
      'इस पाइपलाइन शेड्यूल को अपडेट नहीं किया जा सका। अनुमतियाँ, cron और समय क्षेत्र जाँचें।';

  @override
  String get pipelineScheduleTakeOwnership => 'स्वामित्व लें';

  @override
  String get pipelineScheduleOwnershipConfirmTitle =>
      'इस शेड्यूल का स्वामित्व लें?';

  @override
  String pipelineScheduleOwnershipConfirmBody(String name) {
    return 'आप \"$name\" के स्वामी बनेंगे। निर्धारित पाइपलाइन आपकी अनुमतियों से चलेंगी। इसके लिए Maintainer या Owner भूमिका आवश्यक है।';
  }

  @override
  String get pipelineScheduleOwnershipError =>
      'इस पाइपलाइन शेड्यूल का स्वामित्व नहीं लिया जा सका। अपनी अनुमतियाँ जाँचें और फिर से प्रयास करें।';

  @override
  String get protectedTagProtectTitle => 'टैग सुरक्षित करें';

  @override
  String get protectedTagProtectName => 'नियम का नाम';

  @override
  String get protectedTagProtectRole => 'मेल खाने वाले टैग कौन बना सकता है?';

  @override
  String get protectedTagProtectNoOne => 'कोई नहीं';

  @override
  String get protectedTagProtectDevelopers => 'डेवलपर और मेंटेनर';

  @override
  String get protectedTagProtectMaintainers => 'मेंटेनर';

  @override
  String protectedTagProtectWarning(String projectId) {
    return 'यह नियम प्रोजेक्ट $projectId में मेल खाने वाले टैग बनाने की अनुमति बदलता है और टैग पाइपलाइन तथा जॉब को प्रभावित कर सकता है।';
  }

  @override
  String get protectedTagProtectWildcard =>
      'वाइल्डकार्ड नियम भविष्य के टैग को भी प्रभावित कर सकते हैं। सटीक पैटर्न और अनुमति जाँचें।';

  @override
  String get protectedTagProtectAcknowledge =>
      'मैं इस नियम के पूरे प्रोजेक्ट पर प्रभाव को समझता हूँ।';

  @override
  String get protectedTagProtectSubmit => 'टैग सुरक्षित करें';

  @override
  String get protectedTagProtectExisting =>
      'नियम पहले से मौजूद है। कोई बदलाव नहीं हुआ।';

  @override
  String get protectedTagProtectUncertain =>
      'परिणाम अनिश्चित है। फिर से कोशिश करने से पहले सभी नियम दोबारा लोड करें।';

  @override
  String get protectedTagProtectReload => 'नियम दोबारा लोड करें';

  @override
  String get protectedTagProtectLoadError =>
      'सुरक्षित टैग नियमों की पुष्टि नहीं हो सकी। दोबारा लोड करें।';

  @override
  String get protectedTagProtectSessionChanged =>
      'आपका खाता बदल गया है। इस ड्राफ्ट को बंद करके फिर शुरू करें।';

  @override
  String get protectedTagProtectCreated => 'सुरक्षित टैग नियम बनाया गया।';

  @override
  String get protectedTagProtectCancel => 'रद्द करें';

  @override
  String get protectedTagProtectForbidden =>
      'आपको यह नियम बनाने की अनुमति नहीं है। फिर कोशिश करने से पहले दोबारा लोड करें।';

  @override
  String get protectedTagProtectUnauthorized =>
      'आपका सत्र समाप्त हो गया है। नियम बनाने से पहले फिर से साइन इन करें।';

  @override
  String get protectedTagProtectRateLimited =>
      'GitLab अनुरोधों को सीमित कर रहा है। प्रतीक्षा करें, फिर नियम दोबारा लोड करें।';

  @override
  String get protectedTagProtectUnavailable =>
      'यह प्रोजेक्ट या सुरक्षित टैग उपलब्ध नहीं है। फिर कोशिश करने से पहले दोबारा लोड करें।';

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
  String get protectedBranchProtectTitle => 'ब्रांच सुरक्षित करें';

  @override
  String get protectedBranchProtectName => 'नियम का नाम';

  @override
  String get protectedBranchProtectPush => 'पुश की अनुमति';

  @override
  String get protectedBranchProtectMerge => 'मर्ज की अनुमति';

  @override
  String get protectedBranchProtectNoOne => 'कोई नहीं';

  @override
  String get protectedBranchProtectDevelopers => 'डेवलपर और मेंटेनर';

  @override
  String get protectedBranchProtectMaintainers => 'मेंटेनर';

  @override
  String protectedBranchProtectWarning(String projectId) {
    return 'यह नियम प्रोजेक्ट $projectId में पुश और मर्ज की अनुमति बदलता है। इससे मर्ज अनुरोध, सुरक्षित CI वेरिएबल और जॉब प्रभावित हो सकते हैं।';
  }

  @override
  String get protectedBranchProtectWildcard =>
      'वाइल्डकार्ड नियम भविष्य की ब्रांच को भी प्रभावित कर सकते हैं। सटीक पैटर्न और दोनों अनुमतियाँ जाँचें।';

  @override
  String get protectedBranchProtectAcknowledge =>
      'मैं इस नियम के पूरे प्रोजेक्ट पर प्रभाव को समझता हूँ।';

  @override
  String get protectedBranchProtectSubmit => 'ब्रांच सुरक्षित करें';

  @override
  String get protectedBranchProtectExisting =>
      'नियम पहले से मौजूद है। कोई बदलाव नहीं हुआ।';

  @override
  String get protectedBranchProtectUncertain =>
      'परिणाम अनिश्चित है। फिर कोशिश करने से पहले सभी नियम दोबारा लोड करें।';

  @override
  String get protectedBranchProtectReload => 'नियम दोबारा लोड करें';

  @override
  String get protectedBranchProtectLoadError =>
      'सुरक्षित ब्रांच नियमों की पुष्टि नहीं हो सकी। दोबारा लोड करें।';

  @override
  String get protectedBranchProtectSessionChanged =>
      'आपका खाता बदल गया है। इस ड्राफ्ट को बंद करके फिर शुरू करें।';

  @override
  String get protectedBranchProtectCreated => 'सुरक्षित ब्रांच नियम बनाया गया।';

  @override
  String get protectedBranchProtectCancel => 'रद्द करें';

  @override
  String get protectedBranchProtectForbidden =>
      'आपको यह नियम बनाने की अनुमति नहीं है। फिर कोशिश करने से पहले दोबारा लोड करें।';

  @override
  String get protectedBranchProtectUnauthorized =>
      'आपका सत्र समाप्त हो गया है। नियम बनाने से पहले फिर से साइन इन करें।';

  @override
  String get protectedBranchProtectRateLimited =>
      'GitLab अनुरोधों को सीमित कर रहा है। प्रतीक्षा करें, फिर नियम दोबारा लोड करें।';

  @override
  String get protectedBranchProtectUnavailable =>
      'यह प्रोजेक्ट या सुरक्षित ब्रांच उपलब्ध नहीं है। फिर कोशिश करने से पहले दोबारा लोड करें।';

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
  String get pipelineScheduleHistoryTitle => 'निष्पादन इतिहास';

  @override
  String get pipelineScheduleHistoryEmpty =>
      'इस शेड्यूल के लिए अभी तक कोई पाइपलाइन नहीं चली है।';

  @override
  String get pipelineScheduleHistoryError =>
      'निष्पादन इतिहास लोड नहीं किया जा सका।';

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
  String get releaseEdit => 'रिलीज़ संपादित करें';

  @override
  String get releaseSave => 'रिलीज़ सहेजें';

  @override
  String get releaseEditName => 'रिलीज़ का नाम';

  @override
  String get releaseEditDescription => 'विवरण (Markdown)';

  @override
  String get releaseNameRequired => 'रिलीज़ का नाम दर्ज करें।';

  @override
  String get releaseEditError => 'रिलीज़ अपडेट नहीं हो सकी।';

  @override
  String get releaseNew => 'नई रिलीज़';

  @override
  String get releaseCreate => 'रिलीज़ बनाएँ';

  @override
  String get releaseTagName => 'टैग का नाम';

  @override
  String get releaseRef => 'टैग बनाने का रेफ़ (वैकल्पिक)';

  @override
  String get releaseRefHelp => 'यदि टैग पहले से मौजूद है, तो खाली छोड़ दें।';

  @override
  String get releaseName => 'रिलीज़ का नाम (वैकल्पिक)';

  @override
  String get releaseDescription => 'विवरण (Markdown)';

  @override
  String get releaseTagRequired => 'टैग का नाम दर्ज करें।';

  @override
  String get releaseCreateError => 'रिलीज़ नहीं बनाई जा सकी।';

  @override
  String get releaseAddAssetLink => 'एसेट लिंक जोड़ें';

  @override
  String get releaseAddLink => 'लिंक जोड़ें';

  @override
  String get releaseAssetName => 'लिंक का नाम';

  @override
  String get releaseAssetUrl => 'लिंक URL';

  @override
  String get releaseAssetNameRequired => 'लिंक का नाम दर्ज करें।';

  @override
  String get releaseAssetUrlInvalid => 'HTTP या HTTPS URL दर्ज करें।';

  @override
  String get releaseAssetNameDuplicate => 'इस नाम का लिंक पहले से मौजूद है।';

  @override
  String get releaseAssetCreateError => 'एसेट लिंक नहीं जोड़ा जा सका।';

  @override
  String get releaseNoAssets => 'अभी कोई एसेट नहीं है।';

  @override
  String get releaseDelete => 'रिलीज़ हटाएँ';

  @override
  String get releaseDeleteConfirmTitle => 'यह रिलीज़ हटाएँ?';

  @override
  String get releaseDeleteConfirmBody =>
      'रिलीज़ और उसके नोट हट जाएँगे। Git टैग बना रहेगा।';

  @override
  String get releaseDeleteError => 'रिलीज़ हटाई नहीं जा सकी।';

  @override
  String get releaseDeleteAssetLink => 'एसेट लिंक हटाएँ';

  @override
  String get releaseDeleteLink => 'लिंक हटाएँ';

  @override
  String get releaseAssetDeleteConfirmTitle => 'यह एसेट लिंक हटाएँ?';

  @override
  String releaseAssetDeleteConfirmBody(String name) {
    return '$name नाम का लिंक हट जाएगा। लिंक की गई फ़ाइल नहीं हटेगी।';
  }

  @override
  String get releaseAssetDeleteError => 'एसेट लिंक हटाया नहीं जा सका।';

  @override
  String get releaseEditAssetLink => 'एसेट लिंक संपादित करें';

  @override
  String get releaseSaveLink => 'लिंक सहेजें';

  @override
  String get releaseAssetEditError => 'एसेट लिंक अपडेट नहीं किया जा सका।';

  @override
  String get releaseMilestonesEdit => 'रिलीज़ माइलस्टोन संपादित करें';

  @override
  String get releaseMilestonesTitle => 'माइलस्टोन';

  @override
  String get releaseMilestonesHelp =>
      'सटीक माइलस्टोन शीर्षक डालें। समूह माइलस्टोन की उपलब्धता आपके GitLab प्लान और परियोजना समूह पर निर्भर है।';

  @override
  String get releaseMilestoneTitle => 'माइलस्टोन शीर्षक';

  @override
  String get releaseMilestoneAdd => 'माइलस्टोन जोड़ें';

  @override
  String get releaseMilestonesSave => 'माइलस्टोन सहेजें';

  @override
  String get releaseMilestonesError => 'रिलीज़ माइलस्टोन अपडेट नहीं हो सके।';

  @override
  String get releaseMilestoneTitleRequired => 'माइलस्टोन शीर्षक डालें।';

  @override
  String get releaseMilestoneDuplicate => 'यह माइलस्टोन पहले से चुना गया है।';

  @override
  String releaseMilestoneRemove(String title) {
    return '$title हटाएँ';
  }

  @override
  String get releaseAssetDirectPath => 'नया सीधा डाउनलोड पथ (वैकल्पिक)';

  @override
  String get releaseAssetDirectPathHelp =>
      'खाली छोड़ने पर मौजूदा सीधा डाउनलोड पथ बना रहेगा। बदलने के लिए /bin/app.zip जैसा पथ डालें।';

  @override
  String get releaseAssetDirectPathInvalid =>
      'होस्ट, क्वेरी या फ़्रैगमेंट के बिना / से शुरू होने वाला पथ डालें।';

  @override
  String get releaseAssetType => 'लिंक का प्रकार';

  @override
  String get releaseAssetKeepType => 'मौजूदा प्रकार रखें';

  @override
  String get releaseAssetTypeOther => 'अन्य';

  @override
  String get releaseAssetTypeRunbook => 'रनबुक';

  @override
  String get releaseAssetTypeImage => 'छवि';

  @override
  String get releaseAssetTypePackage => 'पैकेज';

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
  String get milestoneNew => 'नया माइलस्टोन';

  @override
  String get milestoneCreate => 'माइलस्टोन बनाएं';

  @override
  String get milestoneTitleField => 'शीर्षक';

  @override
  String get milestoneDescriptionField => 'विवरण';

  @override
  String get milestoneTitleRequired => 'माइलस्टोन का शीर्षक दर्ज करें।';

  @override
  String get milestoneDateOrderError =>
      'आरंभ तिथि नियत तिथि के बाद नहीं हो सकती।';

  @override
  String get milestoneCreateError => 'माइलस्टोन नहीं बनाया जा सका।';

  @override
  String get milestoneChooseDate => 'तिथि चुनें';

  @override
  String get milestoneClearDate => 'तिथि हटाएं';

  @override
  String get milestoneEdit => 'माइलस्टोन संपादित करें';

  @override
  String get milestoneSaveChanges => 'बदलाव सहेजें';

  @override
  String get milestoneUpdateError => 'माइलस्टोन अपडेट नहीं हो सका।';

  @override
  String get milestoneClearStartDate => 'शुरू होने की तारीख हटाएं';

  @override
  String get milestoneClearDueDate => 'नियत तारीख हटाएं';

  @override
  String get milestoneClose => 'माइलस्टोन बंद करें';

  @override
  String get milestoneReactivate => 'माइलस्टोन फिर सक्रिय करें';

  @override
  String get milestoneCloseConfirmTitle => 'क्या यह माइलस्टोन बंद करें?';

  @override
  String get milestoneCloseConfirmBody =>
      'इसे बाद में फिर सक्रिय किया जा सकता है।';

  @override
  String get milestoneStateError => 'माइलस्टोन की स्थिति नहीं बदली जा सकी।';

  @override
  String get milestoneDelete => 'माइलस्टोन हटाएं';

  @override
  String get milestoneDeleteConfirmTitle => 'क्या यह माइलस्टोन हटाएं?';

  @override
  String get milestoneDeleteConfirmBody => 'इसे वापस नहीं लाया जा सकता।';

  @override
  String get milestoneDeleteError => 'माइलस्टोन हटाया नहीं जा सका।';

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
  String get issueEditLabels => 'लेबल संपादित करें';

  @override
  String get issueSaveLabels => 'लेबल सहेजें';

  @override
  String get issueLabelsEmpty => 'कोई लेबल उपलब्ध नहीं है';

  @override
  String get issueLabelsLoadError => 'लेबल लोड नहीं हो सके।';

  @override
  String get issueLabelsSaveError =>
      'लेबल अपडेट नहीं हो सके। फिर से कोशिश करें।';

  @override
  String get issueEditDueDate => 'नियत तारीख संपादित करें';

  @override
  String get issueConfidential => 'गोपनीय';

  @override
  String get issueMakeConfidential => 'गोपनीय बनाएं';

  @override
  String get issueRemoveConfidentiality => 'गोपनीयता हटाएं';

  @override
  String get issueMakeConfidentialExplanation =>
      'इस इश्यू तक पहुँच सीमित हो जाएगी। जारी रखें?';

  @override
  String get issueRemoveConfidentialityExplanation =>
      'प्रोजेक्ट देखने वाले सभी लोगों को यह इश्यू दिखाई देगा। जारी रखें?';

  @override
  String get issueConfidentialityConfirm => 'पुष्टि करें';

  @override
  String get issueConfidentialityError =>
      'गोपनीयता अपडेट नहीं हो सकी। अनुमतियाँ जाँचें और फिर कोशिश करें।';

  @override
  String get issueDiscussionLocked => 'चर्चा लॉक है';

  @override
  String get issueLockDiscussion => 'चर्चा लॉक करें';

  @override
  String get issueUnlockDiscussion => 'चर्चा अनलॉक करें';

  @override
  String get issueLockDiscussionExplanation =>
      'केवल प्रोजेक्ट सदस्य टिप्पणियाँ जोड़ या संपादित कर सकेंगे। जारी रखें?';

  @override
  String get issueUnlockDiscussionExplanation =>
      'इस इश्यू तक पहुँच वाले लोग फिर से टिप्पणी कर सकेंगे। जारी रखें?';

  @override
  String get issueDiscussionLockConfirm => 'पुष्टि करें';

  @override
  String get issueDiscussionLockError =>
      'चर्चा लॉक नहीं बदल सका। अनुमतियाँ जाँचें और फिर कोशिश करें।';

  @override
  String get issueEditMilestone => 'माइलस्टोन संपादित करें';

  @override
  String get issueEditAssignees => 'असाइनी संपादित करें';

  @override
  String get issueAssignees => 'असाइनी';

  @override
  String get issueSaveAssignees => 'असाइनी सहेजें';

  @override
  String get issueAssigneesSaveError =>
      'असाइनी अपडेट नहीं हो सके। अनुमतियाँ जाँचें और फिर कोशिश करें।';

  @override
  String get issueNoMilestone => 'कोई माइलस्टोन नहीं';

  @override
  String get issueMilestonesLoadError => 'माइलस्टोन लोड नहीं हो सके।';

  @override
  String get issueMilestoneSaveError =>
      'माइलस्टोन अपडेट नहीं हो सका। अनुमतियाँ जाँचें और फिर कोशिश करें।';

  @override
  String get issueDueDate => 'नियत तारीख';

  @override
  String issueDueDateValue(String date) {
    return 'नियत तारीख: $date';
  }

  @override
  String get issueSelectDueDate => 'तारीख चुनें';

  @override
  String get issueClearDueDate => 'नियत तारीख हटाएँ';

  @override
  String get issueDueDateError =>
      'नियत तारीख अपडेट नहीं हो सकी। फिर से कोशिश करें।';

  @override
  String get issueSaveChanges => 'बदलाव सहेजें';

  @override
  String get issueEditError =>
      'समस्या सहेजी नहीं जा सकी। अनुमतियाँ जाँचें और फिर प्रयास करें।';

  @override
  String get issueSubscribe => 'सूचनाओं की सदस्यता लें';

  @override
  String get issueUnsubscribe => 'सूचनाओं की सदस्यता छोड़ें';

  @override
  String get issueSubscriptionError =>
      'समस्या की सूचनाएँ बदली नहीं जा सकीं। फिर प्रयास करें।';

  @override
  String get mrSubscribe => 'सूचनाओं की सदस्यता लें';

  @override
  String get mrUnsubscribe => 'सूचनाओं की सदस्यता छोड़ें';

  @override
  String get mrSubscriptionError =>
      'मर्ज अनुरोध की सूचनाएँ बदली नहीं जा सकीं। फिर प्रयास करें।';

  @override
  String get issueAddTodo => 'कार्य सूची में जोड़ें';

  @override
  String get issueTodoAdded => 'आपकी कार्य सूची में जोड़ दिया गया।';

  @override
  String get issueTodoExists => 'यह समस्या पहले से आपकी कार्य सूची में है।';

  @override
  String get issueTodoError =>
      'समस्या को कार्य सूची में नहीं जोड़ा जा सका। फिर प्रयास करें।';

  @override
  String get mrAddTodo => 'कार्य सूची में जोड़ें';

  @override
  String get mrTodoAdded => 'आपकी कार्य सूची में जोड़ दिया गया।';

  @override
  String get mrTodoExists => 'यह मर्ज अनुरोध पहले से आपकी कार्य सूची में है।';

  @override
  String get mrTodoError =>
      'मर्ज अनुरोध को कार्य सूची में नहीं जोड़ा जा सका। फिर प्रयास करें।';

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
  String get pipelinesStatusAll => 'सभी स्थितियाँ';

  @override
  String get pipelinesStatusCreated => 'बनाया गया';

  @override
  String get pipelinesStatusPending => 'लंबित';

  @override
  String get pipelinesStatusRunning => 'चल रहा है';

  @override
  String get pipelinesStatusSuccess => 'सफल';

  @override
  String get pipelinesStatusFailed => 'विफल';

  @override
  String get pipelinesStatusCanceled => 'रद्द किया गया';

  @override
  String get pipelinesStatusSkipped => 'छोड़ दिया गया';

  @override
  String get pipelinesStatusManual => 'मैन्युअल';

  @override
  String get pipelinesFilteredEmpty =>
      'इन फ़िल्टर से मेल खाने वाली कोई पाइपलाइन नहीं है।';

  @override
  String get pipelinesError => 'पाइपलाइन लोड नहीं हो सकीं।';

  @override
  String get pipelinesEmpty => 'अभी तक कोई पाइपलाइन नहीं।';

  @override
  String get pipelinesLoadMore => 'और लोड करें';

  @override
  String get pipelinesLoadMoreError => 'और पाइपलाइन लोड नहीं की जा सकीं।';

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
  String get snippetNew => 'नया स्निपेट';

  @override
  String get snippetTitleField => 'शीर्षक';

  @override
  String get snippetDescriptionField => 'विवरण';

  @override
  String get snippetFilePathField => 'फ़ाइल पथ';

  @override
  String get snippetContentField => 'सामग्री';

  @override
  String get snippetVisibilityField => 'दृश्यता';

  @override
  String get snippetVisibilityUnchanged => 'मौजूदा दृश्यता बनाए रखें';

  @override
  String get snippetPrivate => 'निजी';

  @override
  String get snippetPublic => 'सार्वजनिक';

  @override
  String get snippetCreate => 'स्निपेट बनाएं';

  @override
  String get snippetCreateValidationError =>
      'शीर्षक, फ़ाइल पथ और सामग्री दर्ज करें।';

  @override
  String get snippetCreateError => 'स्निपेट नहीं बनाया जा सका।';

  @override
  String get snippetAddFile => 'फ़ाइल जोड़ें';

  @override
  String get snippetFileAddValidationError =>
      'अद्वितीय सापेक्ष फ़ाइल पथ और सामग्री दर्ज करें।';

  @override
  String get snippetFileAddError => 'फ़ाइल नहीं जोड़ी जा सकी।';

  @override
  String get snippetFileMoveAction => 'फ़ाइल स्थानांतरित करें';

  @override
  String get snippetFileMoveTitle => 'फ़ाइल स्थानांतरित करें या नाम बदलें';

  @override
  String get snippetFileMovePathField => 'नया फ़ाइल पथ';

  @override
  String get snippetFileMoveValidationError =>
      'कोई अलग, अप्रयुक्त सापेक्ष फ़ाइल पथ दर्ज करें।';

  @override
  String get snippetFileMoveError => 'फ़ाइल स्थानांतरित नहीं की जा सकी।';

  @override
  String get snippetEditAction => 'स्निपेट संपादित करें';

  @override
  String get snippetEditTitle => 'स्निपेट संपादित करें';

  @override
  String get snippetSaveChanges => 'बदलाव सहेजें';

  @override
  String get snippetEditValidationError => 'शीर्षक दर्ज करें।';

  @override
  String get snippetEditError => 'स्निपेट सहेजा नहीं जा सका।';

  @override
  String get snippetDeleteAction => 'स्निपेट हटाएँ';

  @override
  String get snippetDeleteConfirmTitle => 'यह स्निपेट हटाएँ?';

  @override
  String get snippetDeleteConfirmMessage =>
      'स्निपेट और इसकी फ़ाइलें स्थायी रूप से हटा दी जाएँगी।';

  @override
  String get snippetDeleteButton => 'हटाएँ';

  @override
  String get snippetDeleteError => 'स्निपेट हटाया नहीं जा सका।';

  @override
  String get snippetFileDeleteAction => 'फ़ाइल हटाएँ';

  @override
  String get snippetFileDeleteConfirmTitle => 'यह फ़ाइल हटाएँ?';

  @override
  String get snippetFileDeleteConfirmMessage =>
      'स्निपेट से केवल यह फ़ाइल स्थायी रूप से हटाई जाएगी।';

  @override
  String get snippetFileDeleteError => 'फ़ाइल हटाई नहीं जा सकी।';

  @override
  String get snippetEditContent => 'सामग्री संपादित करें';

  @override
  String get snippetSaveContent => 'सामग्री सहेजें';

  @override
  String get snippetContentSaveError => 'स्निपेट सामग्री सहेजी नहीं जा सकी।';

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
  String get wikiNewPage => 'नया पृष्ठ';

  @override
  String get wikiPagesSection => 'पृष्ठ';

  @override
  String get wikiTemplatesSection => 'टेम्पलेट';

  @override
  String get wikiTemplateEmpty => 'अभी कोई टेम्पलेट नहीं है।';

  @override
  String get wikiNewTemplate => 'नया टेम्पलेट';

  @override
  String get wikiTemplateTitle => 'टेम्पलेट का शीर्षक';

  @override
  String get wikiCreateTemplate => 'टेम्पलेट बनाएं';

  @override
  String get wikiCreateTemplateError => 'टेम्पलेट नहीं बनाया जा सका।';

  @override
  String get wikiPageTitle => 'शीर्षक';

  @override
  String get wikiPageContent => 'सामग्री';

  @override
  String get wikiCreatePage => 'पृष्ठ बनाएं';

  @override
  String get wikiChooseTemplate => 'टेम्पलेट चुनें';

  @override
  String get wikiReplaceTemplateContent =>
      'क्या मौजूदा सामग्री को इस टेम्पलेट से बदलना है?';

  @override
  String get wikiApplyTemplate => 'टेम्पलेट लागू करें';

  @override
  String get wikiTemplateLoadError => 'टेम्पलेट लोड नहीं हो सका।';

  @override
  String get wikiCreateValidationError => 'शीर्षक और सामग्री दर्ज करें।';

  @override
  String get wikiCreateError => 'विकी पृष्ठ नहीं बनाया जा सका।';

  @override
  String get wikiEditPageAction => 'संपादित करें';

  @override
  String get wikiEditPage => 'विकी पृष्ठ संपादित करें';

  @override
  String get wikiEditTitle => 'शीर्षक';

  @override
  String get wikiEditContent => 'सामग्री';

  @override
  String get wikiSaveChanges => 'बदलाव सहेजें';

  @override
  String get wikiEditValidationError => 'शीर्षक और सामग्री दर्ज करें।';

  @override
  String get wikiEditError => 'विकी पृष्ठ सहेजा नहीं जा सका।';

  @override
  String get wikiEditConflict =>
      'यह पृष्ठ GitLab पर बदल गया है। दोबारा संपादित करने से पहले इसे रीलोड करें।';

  @override
  String get wikiDeletePageAction => 'पृष्ठ हटाएँ';

  @override
  String get wikiDeleteConfirmTitle => 'यह विकी पृष्ठ हटाएँ?';

  @override
  String get wikiDeleteConfirmMessage =>
      'यह पृष्ठ परियोजना विकी से स्थायी रूप से हटा दिया जाएगा।';

  @override
  String get wikiDeleteError => 'विकी पृष्ठ हटाया नहीं जा सका।';

  @override
  String get wikiDeleteConflict =>
      'यह पृष्ठ बदल गया है। हटाने से पहले इसे रीलोड करें।';

  @override
  String get wikiReloadPage => 'पृष्ठ रीलोड करें';

  @override
  String get packageRegistryTitle => 'पैकेज रजिस्ट्री';

  @override
  String get packageDelete => 'पैकेज हटाएँ';

  @override
  String get packageDeleteConfirmTitle => 'यह पैकेज हटाएँ?';

  @override
  String packageDeleteConfirmBody(String name) {
    return '$name और उसकी सभी फ़ाइलें हटाएँ? इसे वापस नहीं किया जा सकता।';
  }

  @override
  String get packageDeleteForwardingWarning =>
      'यदि अनुरोध अग्रेषण सक्षम है, तो इस पैकेज को हटाने से निर्भरता भ्रम हमले का जोखिम हो सकता है।';

  @override
  String get packageDeleteError =>
      'यह पैकेज हटाया नहीं जा सका। कृपया फिर से कोशिश करें।';

  @override
  String get packageDeleteForbidden =>
      'यह पैकेज संरक्षित हो सकता है, या आपके पास इसे हटाने की अनुमति नहीं है।';

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

  @override
  String get protectedTagUnprotectTitle => 'टैग नियम की सुरक्षा हटाएँ';

  @override
  String protectedTagUnprotectTarget(String projectId, String name) {
    return 'प्रोजेक्ट $projectId — नियम $name';
  }

  @override
  String get protectedTagUnprotectWarning =>
      'रिपॉज़िटरी टैग सुरक्षा नियम हटाएँ। कोई टैग नहीं हटाया जाता। वाइल्डकार्ड कई मौजूदा और भविष्य के टैग को प्रभावित कर सकता है। सुरक्षा हटाने से अधिक उपयोगकर्ता मेल खाने वाले टैग बना या हटा सकते हैं और टैग पाइपलाइन व जॉब तक पहुँच बदल सकती है। अन्य मेल खाने वाले नियम टैग को सुरक्षित रख सकते हैं; वास्तविक पहुँच GitLab तय करता है। नीचे वर्तमान निर्माण अनुमतियाँ जाँचें।';

  @override
  String protectedTagUnprotectAccess(
    String description,
    String role,
    String user,
    String group,
    String key,
  ) {
    return '$description\nभूमिका स्तर: $role; उपयोगकर्ता ID: $user; समूह ID: $group; डिप्लॉय कुंजी ID: $key';
  }

  @override
  String get protectedTagUnprotectUnreported => 'जानकारी उपलब्ध नहीं';

  @override
  String get protectedTagUnprotectName =>
      'सटीक नियम नाम या पैटर्न दोबारा दर्ज करें';

  @override
  String get protectedTagUnprotectAcknowledge =>
      'मैं इस नियम से मेल खाने वाले सभी टैग की सुरक्षा खोने को समझता हूँ और यह नियम हटाना चाहता हूँ।';

  @override
  String get protectedTagUnprotectAuth =>
      'आपका सत्र अस्वीकार कर दिया गया। नियम की समीक्षा से पहले फिर साइन इन करें।';

  @override
  String get protectedTagUnprotectForbidden =>
      'GitLab ने सुरक्षा हटाने की अनुमति नहीं दी। Maintainer या Owner भूमिका आवश्यक है।';

  @override
  String get protectedTagUnprotectUnavailable =>
      'नियम मौजूद नहीं है, निजी है या इस इंस्टेंस पर उपलब्ध नहीं है। जाँचने के लिए पुनः लोड करें; कोई अन्य नियम नहीं हटाया जाएगा।';

  @override
  String get protectedTagUnprotectStale =>
      'नियम बदल गया है। हटाने से पहले पुनः लोड करके वर्तमान अनुमतियों की पुष्टि करें।';

  @override
  String get protectedTagUnprotectRateLimited =>
      'GitLab अनुरोध सीमित कर रहा है। प्रतीक्षा करें, फिर नियम पुनः लोड करके पुष्टि करें।';

  @override
  String get protectedTagUnprotectError =>
      'अनुरोध का परिणाम पुष्ट नहीं हो सका। दोबारा प्रयास से पहले नियम पुनः लोड करके पुष्टि करें।';

  @override
  String get protectedTagUnprotectReload => 'नियम पुनः लोड करें';

  @override
  String get protectedTagUnprotectSessionChanged =>
      'खाता बदल गया है। वर्तमान प्रोजेक्ट की समीक्षा के लिए संवाद बंद करके दोबारा खोलें।';

  @override
  String get protectedTagUnprotectAccepted =>
      'टैग सुरक्षा नियम हटा दिया गया। कोई टैग नहीं हटाया गया।';

  @override
  String get protectedBranchForcePushEditTitle => 'फ़ोर्स पुश संपादित करें';

  @override
  String protectedBranchForcePushEditTarget(String project, String name) {
    return 'प्रोजेक्ट $project: $name';
  }

  @override
  String get protectedBranchForcePushCurrentAllowed =>
      'फ़ोर्स पुश अभी अनुमत है।';

  @override
  String get protectedBranchForcePushCurrentBlocked =>
      'फ़ोर्स पुश अभी अवरुद्ध है।';

  @override
  String get protectedBranchForcePushAllow => 'फ़ोर्स पुश की अनुमति दें';

  @override
  String get protectedBranchForcePushSave => 'सेटिंग सहेजें';

  @override
  String get protectedBranchForcePushEnableWarning =>
      'फ़ोर्स पुश की अनुमति देने से मिलान वाली ब्रांचों का इतिहास फिर लिखा जा सकता है। वाइल्डकार्ड नियम कई ब्रांचों को प्रभावित कर सकता है।';

  @override
  String get protectedBranchForcePushDisableWarning =>
      'फ़ोर्स पुश रोकने से मिलान वाली ब्रांचों पर काम करने का तरीका बदलता है। वाइल्डकार्ड नियम कई ब्रांचों को प्रभावित कर सकता है।';

  @override
  String get protectedBranchForcePushAcknowledge =>
      'मैं मिलान वाली ब्रांचों पर इस बदलाव का प्रभाव समझता/समझती हूं।';

  @override
  String get protectedBranchForcePushReload => 'नियम फिर जांचें';

  @override
  String get protectedBranchForcePushSuccess =>
      'फ़ोर्स पुश सेटिंग अपडेट की गई।';

  @override
  String get protectedBranchForcePushAuth =>
      'इस नियम को बदलने से पहले फिर साइन इन करें।';

  @override
  String get protectedBranchForcePushForbidden =>
      'आपको यह नियम बदलने की अनुमति नहीं है।';

  @override
  String get protectedBranchForcePushUnavailable =>
      'यह नियम अब उपलब्ध नहीं है। आगे बढ़ने से पहले सूची जांचें।';

  @override
  String get protectedBranchForcePushStale =>
      'नियम बदल गया है। आगे बढ़ने से पहले फिर जांचें।';

  @override
  String get protectedBranchForcePushRateLimited =>
      'GitLab अनुरोध सीमित कर रहा है। फिर प्रयास करने से पहले नियम जांचें।';

  @override
  String get protectedBranchForcePushError =>
      'बदलाव की पुष्टि नहीं हो सकी। फिर प्रयास करने से पहले नियम जांचें।';

  @override
  String get protectedBranchForcePushSessionChanged =>
      'खाता बदल गया है। यह संवाद बंद करें और नियम दोबारा खोलें।';

  @override
  String get protectedBranchMergeRoleEditTitle => 'मर्ज अनुमति संपादित करें';

  @override
  String protectedBranchMergeRoleTarget(String project, String name) {
    return 'प्रोजेक्ट $project: $name';
  }

  @override
  String protectedBranchMergeRoleCurrent(String role) {
    return 'वर्तमान मर्ज अनुमति: $role';
  }

  @override
  String get protectedBranchMergeRoleNone => 'कोई नहीं';

  @override
  String get protectedBranchMergeRoleDeveloper => 'डेवलपर और मेंटेनर';

  @override
  String get protectedBranchMergeRoleMaintainer => 'मेंटेनर';

  @override
  String get protectedBranchMergeRoleWarning =>
      'मर्ज अनुमति बदलने से इस नियम से मेल खाने वाली सभी ब्रांच प्रभावित होंगी। वाइल्डकार्ड कई ब्रांच और मर्ज अनुरोध कार्यप्रवाह प्रभावित कर सकता है।';

  @override
  String get protectedBranchMergeRoleAcknowledge =>
      'मैं मेल खाने वाली ब्रांच की मर्ज अनुमति में बदलाव समझता हूँ।';

  @override
  String get protectedBranchMergeRoleSave => 'मर्ज अनुमति सहेजें';

  @override
  String get protectedBranchMergeRoleReload => 'नियम फिर जाँचें';

  @override
  String get protectedBranchMergeRoleSuccess => 'मर्ज अनुमति अपडेट की गई।';

  @override
  String get protectedBranchMergeRoleAuth =>
      'नियम बदलने से पहले फिर साइन इन करें।';

  @override
  String get protectedBranchMergeRoleForbidden =>
      'आपको मर्ज अनुमति बदलने की अनुमति नहीं है।';

  @override
  String get protectedBranchMergeRoleUnavailable =>
      'यह नियम अब उपलब्ध नहीं है। आगे बढ़ने से पहले सूची जाँचें।';

  @override
  String get protectedBranchMergeRoleStale =>
      'नियम बदल गया है। आगे बढ़ने से पहले फिर जाँचें।';

  @override
  String get protectedBranchMergeRoleRateLimited =>
      'GitLab अनुरोध सीमित कर रहा है। फिर कोशिश से पहले नियम जाँचें।';

  @override
  String get protectedBranchMergeRoleError =>
      'बदलाव की पुष्टि नहीं हो सकी। फिर कोशिश से पहले नियम जाँचें।';

  @override
  String get protectedBranchMergeRoleSessionChanged =>
      'खाता बदल गया है। यह संवाद बंद करके नियम फिर खोलें।';

  @override
  String get protectedBranchPushRoleEditTitle => 'पुश अनुमति संपादित करें';

  @override
  String protectedBranchPushRoleTarget(String project, String name) {
    return 'प्रोजेक्ट $project: $name';
  }

  @override
  String protectedBranchPushRoleCurrent(String role) {
    return 'वर्तमान पुश अनुमति: $role';
  }

  @override
  String get protectedBranchPushRoleNone => 'कोई नहीं';

  @override
  String get protectedBranchPushRoleDeveloper => 'डेवलपर और मेंटेनर';

  @override
  String get protectedBranchPushRoleMaintainer => 'मेंटेनर';

  @override
  String get protectedBranchPushRoleWarning =>
      'पुश अनुमति बदलने से इस नियम से मेल खाने वाली सभी ब्रांच प्रभावित होंगी। सीधे कमिट करने वाले लोग बदल सकते हैं; फ़ोर्स पुश चालू होने पर इतिहास बदलने वाले लोग भी बदल सकते हैं। वाइल्डकार्ड कई ब्रांच प्रभावित कर सकता है।';

  @override
  String get protectedBranchPushRoleAcknowledge =>
      'मैं मेल खाने वाली ब्रांच की पुश अनुमति में बदलाव समझता हूँ।';

  @override
  String get protectedBranchPushRoleSave => 'पुश अनुमति सहेजें';

  @override
  String get protectedBranchPushRoleReload => 'नियम फिर जाँचें';

  @override
  String get protectedBranchPushRoleSuccess => 'पुश अनुमति अपडेट की गई।';

  @override
  String get protectedBranchPushRoleAuth =>
      'नियम बदलने से पहले फिर साइन इन करें।';

  @override
  String get protectedBranchPushRoleForbidden =>
      'आपको पुश अनुमति बदलने की अनुमति नहीं है।';

  @override
  String get protectedBranchPushRoleUnavailable =>
      'यह नियम अब उपलब्ध नहीं है। आगे बढ़ने से पहले सूची जाँचें।';

  @override
  String get protectedBranchPushRoleStale =>
      'नियम बदल गया है। आगे बढ़ने से पहले फिर जाँचें।';

  @override
  String get protectedBranchPushRoleRateLimited =>
      'GitLab अनुरोध सीमित कर रहा है। फिर कोशिश से पहले नियम जाँचें।';

  @override
  String get protectedBranchPushRoleError =>
      'बदलाव की पुष्टि नहीं हो सकी। फिर कोशिश से पहले नियम जाँचें।';

  @override
  String get protectedBranchPushRoleSessionChanged =>
      'खाता बदल गया है। यह संवाद बंद करके नियम फिर खोलें।';

  @override
  String get protectedEnvironmentCreateTitle => 'परिवेश सुरक्षित करें';

  @override
  String get protectedEnvironmentCreateName => 'परिवेश का नाम';

  @override
  String get protectedEnvironmentCreateDeveloper => 'डेवलपर और मेंटेनर';

  @override
  String get protectedEnvironmentCreateMaintainer => 'मेंटेनर';

  @override
  String get protectedEnvironmentCreateWarning =>
      'यह सुरक्षा तय करती है कि नामित परिवेश में कौन डिप्लॉय कर सकता है। अनुमोदन नियम नहीं जोड़े जाते।';

  @override
  String get protectedEnvironmentCreateAcknowledge =>
      'मैं डिप्लॉय पहुँच में बदलाव समझता हूँ।';

  @override
  String get protectedEnvironmentCreateSave => 'परिवेश सुरक्षित करें';

  @override
  String get protectedEnvironmentCreateReload => 'परिवेश सूची फिर जाँचें';

  @override
  String get protectedEnvironmentCreateDuplicate =>
      'यह परिवेश पहले से सुरक्षित है। आगे बढ़ने से पहले सूची जाँचें।';

  @override
  String get protectedEnvironmentCreateError =>
      'सुरक्षा की पुष्टि नहीं हो सकी। फिर प्रयास करने से पहले सूची जाँचें।';

  @override
  String get protectedEnvironmentCreateForbidden =>
      'आपके पास अनुमति नहीं है या यह सुविधा उपलब्ध नहीं है।';

  @override
  String get protectedEnvironmentCreateSessionChanged =>
      'खाता बदल गया है। यह संवाद बंद करके फिर खोलें।';

  @override
  String get protectedEnvironmentCreateSuccess => 'परिवेश सुरक्षित हो गया।';

  @override
  String get protectedEnvironmentCreateInvalidName =>
      'वाइल्डकार्ड के बिना सटीक परिवेश नाम दर्ज करें।';

  @override
  String get protectedEnvironmentRemoveRoleTitle => 'डिप्लॉय भूमिका हटाएँ';

  @override
  String get protectedEnvironmentRemoveRoleWarning =>
      'यह अनुमति हटाने से चुनी गई भूमिका डिप्लॉय नहीं कर पाएगी। अन्य डिप्लॉय अनुमतियाँ और अनुमोदन नियम बने रहेंगे, और परिवेश सुरक्षित रहेगा।';

  @override
  String get protectedEnvironmentRemoveRoleAcknowledge =>
      'मैं समझता हूँ कि चुनी गई डिप्लॉय अनुमति हट जाएगी।';

  @override
  String get protectedEnvironmentRemoveRoleSuccess =>
      'डिप्लॉय भूमिका हटा दी गई।';

  @override
  String get protectedEnvironmentRemoveRoleForbidden =>
      'आपके पास यह डिप्लॉय अनुमति हटाने की अनुमति नहीं है।';

  @override
  String get protectedEnvironmentRemoveRoleError =>
      'डिप्लॉय अनुमति हटने की पुष्टि नहीं हो सकी। फिर प्रयास करने से पहले नियम जाँचें।';

  @override
  String protectedEnvironmentRemoveRoleGrantLabel(String role, String id) {
    return '$role (अनुमति $id)';
  }

  @override
  String get protectedEnvironmentDeployRoleTitle => 'डिप्लॉय भूमिका जोड़ें';

  @override
  String get protectedEnvironmentDeployRoleWarning =>
      'चुनी गई भूमिका को डिप्लॉय करने की अनुमति मिलेगी। मौजूदा डिप्लॉय अनुमतियाँ और अनुमोदन नियम बने रहेंगे।';

  @override
  String get protectedEnvironmentDeployRoleAcknowledge =>
      'मैं समझता हूँ कि इससे डिप्लॉय पहुँच बढ़ती है।';

  @override
  String get protectedEnvironmentDeployRoleSuccess =>
      'डिप्लॉय भूमिका जोड़ दी गई।';

  @override
  String get protectedEnvironmentDeployRoleForbidden =>
      'आपके पास डिप्लॉय पहुँच बदलने की अनुमति नहीं है।';

  @override
  String get protectedEnvironmentDeployRoleError =>
      'डिप्लॉय भूमिका बदलाव की पुष्टि नहीं हो सकी। फिर प्रयास करने से पहले नियम जाँचें।';

  @override
  String get protectedEnvironmentUnprotectTitle => 'परिवेश की सुरक्षा हटाएँ';

  @override
  String protectedEnvironmentUnprotectTarget(String project, String name) {
    return 'प्रोजेक्ट $project: $name';
  }

  @override
  String get protectedEnvironmentUnprotectWarning =>
      'इस प्रोजेक्ट नियम की सुरक्षा हटाने से नीचे दिखाई गई सभी डिप्लॉय अनुमतियाँ और अनुमोदन नियम हट जाएँगे। परिवेश और पिछले डिप्लॉयमेंट बने रहेंगे। समूह की सुरक्षा अभी भी लागू हो सकती है।';

  @override
  String get protectedEnvironmentUnprotectName => 'परिवेश का सटीक नाम लिखें';

  @override
  String get protectedEnvironmentUnprotectAcknowledge =>
      'मैं समझता हूँ कि ये डिप्लॉय प्रतिबंध और अनुमोदन नियम हट जाएँगे।';

  @override
  String get protectedEnvironmentUnprotectReload => 'नियम फिर जाँचें';

  @override
  String get protectedEnvironmentUnprotectAuth =>
      'इस नियम को बदलने से पहले फिर साइन इन करें।';

  @override
  String get protectedEnvironmentUnprotectForbidden =>
      'आपके पास इस परिवेश की सुरक्षा हटाने की अनुमति नहीं है।';

  @override
  String get protectedEnvironmentUnprotectUnavailable =>
      'यह नियम अब उपलब्ध नहीं है। आगे बढ़ने से पहले सूची जाँचें।';

  @override
  String get protectedEnvironmentUnprotectStale =>
      'नियम बदल गया है। आगे बढ़ने से पहले इसे फिर जाँचें।';

  @override
  String get protectedEnvironmentUnprotectRateLimited =>
      'GitLab अनुरोध सीमित कर रहा है। फिर प्रयास करने से पहले नियम जाँचें।';

  @override
  String get protectedEnvironmentUnprotectError =>
      'हटाने की पुष्टि नहीं हो सकी। फिर प्रयास करने से पहले नियम जाँचें।';

  @override
  String get protectedEnvironmentUnprotectSessionChanged =>
      'खाता बदल गया है। यह संवाद बंद करके नियम फिर खोलें।';

  @override
  String get protectedEnvironmentUnprotectSuccess =>
      'परिवेश की सुरक्षा हटा दी गई।';

  @override
  String get protectedEnvironmentUnprotectUnreported => 'पहुँच प्रविष्टि';

  @override
  String get containerPolicyStatus => 'स्थिति';

  @override
  String get containerPolicyTitle => 'सफ़ाई नीति';

  @override
  String get containerPolicyAbsent =>
      'GitLab ने सफ़ाई नीति की जानकारी नहीं दी।';

  @override
  String get containerPolicyHint =>
      'इस प्रोजेक्ट की सभी कंटेनर इमेज रिपॉज़िटरी के लिए केवल-पढ़ने योग्य सेटिंग। सफ़ाई मिलते टैग असमकालिक रूप से हटाती है, जबकि रखने के नियम, latest, संरक्षित और अपरिवर्तनीय टैग सुरक्षित रहते हैं। कई बार चलाना पड़ सकता है; टैग हटाने से इमेज संग्रहण खाली नहीं होता।';

  @override
  String get containerPolicyNextRun =>
      'GitLab द्वारा बताया अगला रन (स्थानीय समय)';

  @override
  String containerPolicyDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString दिन',
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
      other: '$countString महीने',
      one: '1 महीना',
    );
    return '$_temp0';
  }

  @override
  String get containerPolicyEnabled => 'सक्रिय';

  @override
  String get containerPolicyDisabled => 'निष्क्रिय';

  @override
  String get containerPolicyNotReported => 'जानकारी नहीं दी गई';

  @override
  String get containerPolicyCadence => 'चलने का अंतराल';

  @override
  String get containerCreateTitle => 'सफाई नीति बनाएँ';

  @override
  String get containerCreateSave => 'निष्क्रिय नीति बनाने की पुष्टि करें';

  @override
  String get containerCreateWarning =>
      'सभी इमेज रिपॉज़िटरी के लिए सफाई मानदंड सहेजें। सक्रियण चुनने तक सफाई निष्क्रिय रहती है। डिफ़ॉल्ट रखने का पैटर्न .* सभी टैग रखता है; खाली पैटर्न कोई पैटर्न-आधारित संरक्षण नहीं देता। पैटर्न ठीक वैसे ही भेजे जाते हैं जैसे दर्ज किए गए हैं और GitLab RE2 पूरे टैग का मिलान करता है। निष्क्रिय अवस्था में सत्यापन बाद में हो सकता है। स्वीकृति सफाई पूरी होने या संग्रहण खाली होने की पुष्टि नहीं करती।';

  @override
  String get containerCreateAcknowledge =>
      'मैंने मानदंडों की समीक्षा की है और समझता हूँ कि यह नीति निष्क्रिय रहेगी।';

  @override
  String get containerCreateExisting =>
      'इस प्रोजेक्ट में पहले से क्लीनअप नीति है। बनाने से उसे बदला नहीं जाएगा; मौजूदा सेटिंग इस्तेमाल करें।';

  @override
  String get containerCreateUnknown =>
      'GitLab ने नीति मौजूद होने की जानकारी नहीं दी। GitLab में समीक्षा करें; नीति बनाना रोका गया है।';

  @override
  String get containerCreateAccepted =>
      'सफाई नीति बनाने का अनुरोध स्वीकार किया गया।';

  @override
  String get containerCreateInvalid =>
      'GitLab ने नीति की सेटिंग अस्वीकार की। शर्तों की समीक्षा करें, फिर संपादित करें या पुनः प्रयास करें।';

  @override
  String get containerCreateDaily => 'हर दिन';

  @override
  String get containerCreateWeekly => 'हर सप्ताह';

  @override
  String get containerCreateFortnightly => 'हर दो सप्ताह';

  @override
  String get containerCreateMonthly => 'हर महीने';

  @override
  String get containerCreateQuarterly => 'हर तीन महीने';

  @override
  String containerCreateDays(int days) {
    return '$days दिन';
  }

  @override
  String get containerPolicyKeepCount => 'हर इमेज के लिए रखने वाले मिलते टैग';

  @override
  String get containerCreateEnable => 'बनाते समय सफाई सक्रिय करें';

  @override
  String get containerCreateEnabledWarning =>
      'सक्रिय नीति अपने समयानुसार इस प्रोजेक्ट की सभी इमेज रिपॉज़िटरी में मेल खाने वाले टैग स्थायी रूप से हटा सकती है। आवृत्ति, रखने की संख्या, आयु और दोनों पैटर्न जाँचें। संरक्षित या अपरिवर्तनीय टैग के अपवाद GitLab तय करता है; सहेजना हटाने या संग्रहण खाली होने की पुष्टि नहीं करता।';

  @override
  String get containerCreateEnabledAcknowledge =>
      'मैंने हर मानदंड की समीक्षा की है और इस प्रोजेक्ट में मेल खाने वाले टैग के नियत समय पर स्थायी विलोपन को स्वीकार करता हूँ।';

  @override
  String get containerCreateEnabledSave => 'सक्रिय नीति बनाने की पुष्टि करें';

  @override
  String get containerCreateSessionChanged =>
      'खाता बदल गया है। नीति बनाने से पहले यह संवाद बंद करके फिर खोलें और वर्तमान प्रोजेक्ट की समीक्षा करें।';

  @override
  String get containerPolicyAge => 'इससे पुराने टैग हटाएँ';

  @override
  String get containerPolicyDeletePattern => 'हटाने का पैटर्न';

  @override
  String get containerPolicyLegacyPattern => 'हटाने का पैटर्न (पुराना)';

  @override
  String get containerPolicyKeepPattern => 'रखने का पैटर्न';

  @override
  String get containerPolicyEmptyPattern => 'खाली पैटर्न';

  @override
  String get containerPolicyError => 'सफ़ाई नीति लोड नहीं हो सकी।';

  @override
  String get containerPolicyForbidden =>
      'इस प्रोजेक्ट की सफ़ाई नीति देखने की अनुमति नहीं है।';

  @override
  String get containerPolicyUnavailable =>
      'प्रोजेक्ट सुलभ नहीं है या सफ़ाई नीति की जानकारी उपलब्ध नहीं है।';

  @override
  String get containerPolicyEmptySetting => 'खाली सेटिंग';

  @override
  String containerActivationTarget(String projectId) {
    return 'प्रोजेक्ट $projectId — सभी इमेज रिपॉज़िटरी';
  }

  @override
  String get containerActivationError =>
      'अपडेट की पुष्टि नहीं हो सकी। नीति फिर लोड करें और पुनः प्रयास करें।';

  @override
  String get containerActivationIncomplete =>
      'सफ़ाई सक्रिय करने के लिए अंतराल, रखने की संख्या, आयु सीमा और हटाने का पैटर्न ज्ञात होना चाहिए। GitLab में नीति देखें।';

  @override
  String get containerActivationTitle => 'सफ़ाई नीति की स्थिति बदलें';

  @override
  String get containerActivationEnable => 'सफ़ाई सक्रिय करें';

  @override
  String get containerActivationDisable => 'सफ़ाई निष्क्रिय करें';

  @override
  String get containerActivationEnableWarning =>
      'यह प्रोजेक्ट-व्यापी नीति सक्रिय करने पर निर्धारित रन में मिलते टैग स्थायी रूप से हट सकते हैं। दिखाई गई रखने की सेटिंग और पैटर्न नहीं बदलेंगे। टैग हटाने से इमेज संग्रहण खाली नहीं होता।';

  @override
  String get containerActivationDisableWarning =>
      'रखने की सेटिंग या पैटर्न बदले बिना इस प्रोजेक्ट की आगामी निर्धारित सफ़ाई निष्क्रिय करें। पहले से चल रहे सफ़ाई जॉब रद्द हो जाने की धारणा न रखें।';

  @override
  String get containerActivationUnknown =>
      'सक्रिय होने की ज्ञात स्थिति आवश्यक है। GitLab में नीति सेटिंग देखें।';

  @override
  String get containerActivationInvalid =>
      'GitLab ने स्थिति बदलाव अस्वीकार किया। GitLab में मौजूदा नीति सेटिंग देखें।';

  @override
  String get containerActivationAccepted =>
      'सफ़ाई नीति का स्थिति अपडेट स्वीकार हुआ।';

  @override
  String get containerActivationForbidden =>
      'इस सफ़ाई नीति को बदलने की अनुमति नहीं है।';

  @override
  String get containerActivationStale =>
      'नीति बदल गई है या जानकारी नहीं मिल रही। सहेजने से पहले फिर लोड कर समीक्षा करें।';

  @override
  String get containerActivationReload => 'नीति फिर लोड करें';

  @override
  String get containerActivationRateLimited =>
      'बहुत अधिक अनुरोध हैं। प्रतीक्षा करें और दोबारा प्रयास से पहले नीति फिर लोड करें।';

  @override
  String get containerCadenceTitle => 'सफ़ाई अंतराल संपादित करें';

  @override
  String get containerCadenceSave => 'अंतराल परिवर्तन की पुष्टि करें';

  @override
  String get containerCadenceSelect => 'नया अंतराल (GitLab API)';

  @override
  String get containerCadenceWarning =>
      'परियोजना का अंतराल बदलने से सभी इमेज रिपॉज़िटरी में भविष्य की नियोजित टैग सफ़ाई प्रभावित होती है। नीचे सक्रिय स्थिति और हटाने/रखने के मानदंड जाँचें। ये सेटिंग नहीं बदलतीं और सफ़ाई पूर्ण होने की पुष्टि नहीं होती।';

  @override
  String get containerCadenceUnknown =>
      'सक्रिय स्थिति, अंतराल, रखने की संख्या, आयु सीमा और हटाने का पैटर्न ज्ञात होना आवश्यक है। GitLab में अनुपलब्ध सेटिंग जाँचें। नई नीति नहीं बनाई जाएगी।';

  @override
  String get containerCadenceAccepted => 'सफ़ाई अंतराल अपडेट स्वीकार किया गया।';

  @override
  String get containerTagProtectionTitle => 'टैग सुरक्षा नियम';

  @override
  String get containerTagProtectionCreateTitle => 'टैग सुरक्षा नियम बनाएँ';

  @override
  String get containerTagProtectionCreateSave => 'नियम बनाएँ';

  @override
  String get containerTagProtectionCreatePattern => 'टैग नाम पैटर्न';

  @override
  String get containerTagProtectionCreatePush => 'न्यूनतम पुश भूमिका';

  @override
  String get containerTagProtectionCreateDelete => 'न्यूनतम हटाने की भूमिका';

  @override
  String get containerTagProtectionCreateUnset => 'भूमिका चुनें';

  @override
  String get containerTagProtectionCreateWarning =>
      'यह पूरे प्रोजेक्ट का नियम सटीक glob पैटर्न से मेल खाने वाले टैग के पुश और हटाने को सीमित करता है। वाइल्डकार्ड कई टैग को प्रभावित कर सकते हैं और मौजूदा रिलीज़ या सफ़ाई रोक सकते हैं। दोनों भूमिकाएँ आवश्यक हैं। अन्य नियम और अनुमतियाँ लागू रहती हैं; ये मान आपकी पहुँच नहीं बताते और इमेज नहीं हटाते।';

  @override
  String get containerTagProtectionCreateAcknowledge =>
      'मैंने सटीक टैग पैटर्न और दोनों भूमिकाएँ जाँच ली हैं और मेल खाने वाले टैग पर प्रभाव समझता हूँ।';

  @override
  String containerTagProtectionCreateProject(String projectId) {
    return 'प्रोजेक्ट $projectId';
  }

  @override
  String get containerTagProtectionCreateForbidden =>
      'आपको यह नियम बनाने की अनुमति नहीं है।';

  @override
  String get containerTagProtectionCreateInvalid =>
      'टैग पैटर्न या भूमिकाएँ अस्वीकार हुईं। दोनों आवश्यक भूमिकाएँ जाँचकर फिर प्रयास करें।';

  @override
  String get containerTagProtectionCreateError =>
      'टैग नियम बनने की पुष्टि नहीं हुई। फिर प्रयास करने से पहले नियम सूची जाँचें; सर्वर ने अनुरोध स्वीकार किया हो सकता है।';

  @override
  String get containerTagProtectionCreateSaved => 'टैग नियम बन गया।';

  @override
  String get containerTagProtectionCreateUnavailable =>
      'टैग नियम बनाने के लिए GitLab 18.8 या नया संस्करण और उपलब्ध प्रोजेक्ट आवश्यक है।';

  @override
  String get containerTagProtectionCreateRateLimited =>
      'बहुत अधिक अनुरोध हैं। प्रतीक्षा करके फिर प्रयास करें।';

  @override
  String get containerTagProtectionEmpty => 'कोई टैग सुरक्षा नियम नहीं है।';

  @override
  String get containerTagProtectionError => 'टैग सुरक्षा नियम लोड नहीं हो सके।';

  @override
  String get containerTagProtectionForbidden =>
      'टैग सुरक्षा नियम देखने की अनुमति नहीं है।';

  @override
  String get containerTagProtectionUnavailable =>
      'इस इंस्टेंस पर टैग सुरक्षा नियम उपलब्ध नहीं हैं, या प्रोजेक्ट सुलभ नहीं है।';

  @override
  String containerTagProtectionPushRole(String role) {
    return 'पुश के लिए न्यूनतम भूमिका: $role';
  }

  @override
  String get containerTagProtectionPushRoleTitle => 'न्यूनतम पुश भूमिका बदलें';

  @override
  String get containerTagProtectionPushRoleSave => 'पुश भूमिका सहेजें';

  @override
  String get containerTagProtectionPushRoleWarning =>
      'न्यूनतम पुश भूमिका बदलने से इस प्रोजेक्ट में मेल खाने वाले कंटेनर इमेज टैग को पुश करने वाले लोग बदलते हैं। कम भूमिका सुरक्षा कमजोर करती है; अधिक भूमिका मौजूदा कार्यप्रवाह रोक सकती है। टैग पैटर्न और न्यूनतम हटाने की भूमिका अपरिवर्तित रहते हैं। अन्य नियम और अनुमतियाँ लागू रहती हैं। इससे टैग या इमेज नहीं हटते, Git टैग प्रभावित नहीं होते और आपकी वर्तमान पहुँच नहीं बताई जाती।';

  @override
  String get containerTagProtectionPushRoleAcknowledge =>
      'मैंने नियम और नई न्यूनतम पुश भूमिका जाँच ली है और पहुँच के बदलाव समझता हूँ।';

  @override
  String containerTagProtectionPushRoleTarget(String projectId, String ruleId) {
    return 'प्रोजेक्ट $projectId — नियम $ruleId';
  }

  @override
  String get containerTagProtectionPushRoleForbidden =>
      'आपको यह नियम बदलने की अनुमति नहीं है।';

  @override
  String get containerTagProtectionPushRoleError =>
      'पुश भूमिका बदलाव की पुष्टि नहीं हुई। फिर प्रयास करने से पहले नियम सूची जाँचें; सर्वर ने अनुरोध स्वीकार किया हो सकता है।';

  @override
  String get containerTagProtectionPushRoleStale =>
      'पुष्टि के बाद नियम बदल गया। सहेजने से पहले पुनः लोड करके जाँचें।';

  @override
  String get containerTagProtectionPushRoleReload => 'नियम पुनः लोड करें';

  @override
  String get containerTagProtectionPushRoleSaved =>
      'न्यूनतम पुश भूमिका बदल गई।';

  @override
  String get containerTagProtectionPushRoleMissing =>
      'नियम उपलब्ध नहीं है, अस्पष्ट है, पहुँच योग्य नहीं है या समर्थित नहीं है। संपादन के लिए GitLab 18.9 या बाद का संस्करण चाहिए। पुष्टि से पहले दोबारा लोड करें।';

  @override
  String get containerTagProtectionPushRoleRateLimited =>
      'बहुत अधिक अनुरोध हैं। प्रतीक्षा करके फिर प्रयास करें।';

  @override
  String get containerTagProtectionPushRoleInvalid =>
      'पुश भूमिका अस्वीकार हुई। समर्थित भूमिका चुनकर फिर प्रयास करें।';

  @override
  String get containerTagProtectionPushRoleDraft => 'नई न्यूनतम पुश भूमिका';

  @override
  String get containerTagProtectionPushRoleSelect => 'पुश भूमिका चुनें';

  @override
  String get containerTagProtectionPushRoleUnknown =>
      'वर्तमान पुश भूमिका अज्ञात है। असमर्थित सेटिंग बदलने से बचाने के लिए संपादन रोका गया है।';

  @override
  String containerTagProtectionDeleteRole(String role) {
    return 'हटाने के लिए न्यूनतम भूमिका: $role';
  }

  @override
  String get containerTagProtectionDeleteRoleTitle =>
      'न्यूनतम हटाने की भूमिका बदलें';

  @override
  String get containerTagProtectionDeleteRoleSave => 'हटाने की भूमिका सहेजें';

  @override
  String get containerTagProtectionDeleteRoleWarning =>
      'न्यूनतम हटाने की भूमिका बदलने से इस प्रोजेक्ट में मेल खाने वाले कंटेनर इमेज टैग हटाने वाले लोग बदलते हैं। कम भूमिका हटाने की सुरक्षा कमजोर करती है; अधिक भूमिका मौजूदा सफ़ाई कार्यप्रवाह रोक सकती है। टैग पैटर्न और न्यूनतम पुश भूमिका अपरिवर्तित रहते हैं। अन्य नियम और अनुमतियाँ लागू रहती हैं। नियम सहेजने से टैग या इमेज नहीं हटते, Git टैग प्रभावित नहीं होते और आपकी वर्तमान पहुँच नहीं बताई जाती।';

  @override
  String get containerTagProtectionDeleteRoleAcknowledge =>
      'मैंने नियम और नई न्यूनतम हटाने की भूमिका जाँच ली है और पहुँच के बदलाव समझता हूँ।';

  @override
  String containerTagProtectionDeleteRoleTarget(
    String projectId,
    String ruleId,
  ) {
    return 'प्रोजेक्ट $projectId — नियम $ruleId';
  }

  @override
  String get containerTagProtectionDeleteRoleForbidden =>
      'आपको यह नियम बदलने की अनुमति नहीं है।';

  @override
  String get containerTagProtectionDeleteRoleError =>
      'हटाने की भूमिका बदलाव की पुष्टि नहीं हुई। फिर प्रयास करने से पहले नियम सूची जाँचें; सर्वर ने अनुरोध स्वीकार किया हो सकता है।';

  @override
  String get containerTagProtectionDeleteRoleStale =>
      'पुष्टि के बाद नियम बदल गया। सहेजने से पहले पुनः लोड करके जाँचें।';

  @override
  String get containerTagProtectionDeleteRoleReload => 'नियम पुनः लोड करें';

  @override
  String get containerTagProtectionDeleteRoleSaved =>
      'न्यूनतम हटाने की भूमिका बदल गई।';

  @override
  String get containerTagProtectionDeleteRoleMissing =>
      'नियम उपलब्ध नहीं है, अस्पष्ट है, पहुँच योग्य नहीं है या समर्थित नहीं है। संपादन के लिए GitLab 18.9 या बाद का संस्करण चाहिए। पुष्टि से पहले दोबारा लोड करें।';

  @override
  String get containerTagProtectionDeleteRoleRateLimited =>
      'बहुत अधिक अनुरोध हैं। प्रतीक्षा करके फिर प्रयास करें।';

  @override
  String get containerTagProtectionDeleteRoleInvalid =>
      'हटाने की भूमिका अस्वीकार हुई। समर्थित भूमिका चुनकर फिर प्रयास करें।';

  @override
  String get containerTagProtectionDeleteRoleDraft =>
      'नई न्यूनतम हटाने की भूमिका';

  @override
  String get containerTagProtectionDeleteRoleSelect => 'हटाने की भूमिका चुनें';

  @override
  String get containerTagProtectionDeleteRoleUnknown =>
      'वर्तमान हटाने की भूमिका अज्ञात है। असमर्थित सेटिंग बदलने से बचाने के लिए संपादन रोका गया है।';

  @override
  String get containerTagProtectionRoleUnset => 'नियम में निर्दिष्ट नहीं';

  @override
  String get containerTagProtectionRoleAdmin => 'व्यवस्थापक';

  @override
  String get containerTagProtectionHint =>
      'ये कंटेनर इमेज टैग के नियम हैं, Git टैग के नहीं। न्यूनतम भूमिकाएँ आपकी मौजूदा पहुँच की पुष्टि नहीं करतीं। सूची के लिए GitLab 18.7 या नया संस्करण, बनाने के लिए 18.8 या नया संस्करण और संपादन के लिए 18.9 या नया संस्करण चाहिए।';

  @override
  String get containerTagProtectionPatternTitle =>
      'टैग सुरक्षा पैटर्न संपादित करें';

  @override
  String get containerTagProtectionPatternSave => 'पैटर्न सहेजें';

  @override
  String get containerTagProtectionPatternWarning =>
      'पैटर्न बदलने से इस प्रोजेक्ट में पहले मेल खाने वाले कंटेनर इमेज टैग की सुरक्षा हट सकती है और अन्य टैग पर लागू हो सकती है। वाइल्डकार्ड(*) कई टैग को प्रभावित कर सकता है। दोनों न्यूनतम भूमिकाएँ अपरिवर्तित रहती हैं; अन्य नियम और अनुमतियाँ लागू रहती हैं। इससे टैग या इमेज नहीं हटते, Git टैग प्रभावित नहीं होते और आपकी पहुँच नहीं बताई जाती।';

  @override
  String get containerTagProtectionPatternAcknowledge =>
      'मैंने वर्तमान नियम और नया पैटर्न जाँच लिया है और सुरक्षा में बदलाव समझता हूँ।';

  @override
  String containerTagProtectionPatternTarget(String projectId, String ruleId) {
    return 'प्रोजेक्ट $projectId — नियम $ruleId';
  }

  @override
  String get containerTagProtectionPatternForbidden =>
      'आपको यह नियम बदलने की अनुमति नहीं है।';

  @override
  String get containerTagProtectionPatternError =>
      'पैटर्न अपडेट की पुष्टि नहीं हो सकी। सर्वर अनुरोध स्वीकार कर चुका हो सकता है; पुनः प्रयास से पहले नियम सूची जाँचें।';

  @override
  String get containerTagProtectionPatternStale =>
      'पुष्टि के बाद नियम बदल गया है। सहेजने से पहले दोबारा लोड करके जाँचें।';

  @override
  String get containerTagProtectionPatternReload => 'नियम दोबारा लोड करें';

  @override
  String get containerTagProtectionPatternSaved =>
      'टैग सुरक्षा पैटर्न अपडेट किया गया।';

  @override
  String get containerTagProtectionPatternMissing =>
      'नियम उपलब्ध नहीं है, अस्पष्ट है, पहुँच योग्य नहीं है या समर्थित नहीं है। संपादन के लिए GitLab 18.9 या बाद का संस्करण चाहिए। पुष्टि से पहले दोबारा लोड करें।';

  @override
  String get containerTagProtectionRemoveTitle => 'टैग सुरक्षा नियम हटाएँ';

  @override
  String get containerTagProtectionRemoveSave => 'नियम हटाएँ';

  @override
  String get containerTagProtectionRemoveWarning =>
      'इस नियम को हटाने से इस प्रोजेक्ट में मेल खाने वाले कंटेनर इमेज टैग की पुश और हटाने की सुरक्षा हट जाती है। अन्य नियम और अनुमतियाँ लागू रहती हैं। इससे टैग या इमेज नहीं हटते और Git टैग प्रभावित नहीं होते।';

  @override
  String get containerTagProtectionRemoveAcknowledge =>
      'मैं समझता हूँ और इसी नियम को हटाना चाहता हूँ।';

  @override
  String containerTagProtectionRemoveTarget(String projectId, String ruleId) {
    return 'प्रोजेक्ट $projectId — नियम $ruleId';
  }

  @override
  String get containerTagProtectionRemoveForbidden =>
      'आपको यह नियम हटाने की अनुमति नहीं है।';

  @override
  String get containerTagProtectionRemoveError =>
      'अनुरोध विफल हुआ लेकिन सर्वर तक पहुँच सकता है। पुनः प्रयास से पहले नियम सूची जाँचें।';

  @override
  String get containerTagProtectionRemoveStale =>
      'नियम बदल गया है या अस्पष्ट है। दोबारा लोड करके पुष्टि करें।';

  @override
  String get containerTagProtectionRemoveReload => 'नियम दोबारा लोड करें';

  @override
  String get containerTagProtectionRemoveSaved =>
      'टैग सुरक्षा नियम हटा दिया गया।';

  @override
  String get containerTagProtectionRemoveMissing =>
      'नियम उपलब्ध नहीं है, पहुँच योग्य नहीं है या समर्थित नहीं है। हटाने के लिए GitLab 18.9 या बाद का संस्करण चाहिए। जारी रखने से पहले दोबारा लोड करें।';

  @override
  String get containerTagProtectionRemoveRateLimited =>
      'बहुत अधिक अनुरोध हैं। पुनः प्रयास से पहले प्रतीक्षा करें।';

  @override
  String get containerTagProtectionPatternRateLimited =>
      'बहुत अधिक अनुरोध हैं। प्रतीक्षा करें और पुनः प्रयास करें।';

  @override
  String get containerTagProtectionPatternInvalid =>
      'पैटर्न अस्वीकार हुआ या पहले से उपयोग में है। ड्राफ़्ट बदलें और पुनः प्रयास करें।';

  @override
  String get containerTagProtectionPatternDraft => 'नया कंटेनर टैग पैटर्न';

  @override
  String get containerTagDelete => 'टैग हटाएँ';

  @override
  String get containerTagDeleteConfirmTitle => 'कंटेनर टैग हटाएँ?';

  @override
  String containerTagDeleteConfirmBody(String tagName, String path) {
    return '“$path” पर टैग “$tagName” हटाएँ? इसे पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String get containerTagDeleteWarning =>
      'इससे केवल टैग हटता है, इमेज ब्लॉब नहीं। टैग हटाने से डिस्क स्थान खाली नहीं होता।';

  @override
  String get containerCleanupTitle => 'टैग साफ़ करें';

  @override
  String containerCleanupTarget(String projectId, String repositoryId) {
    return 'प्रोजेक्ट $projectId, इमेज रिपॉज़िटरी $repositoryId';
  }

  @override
  String get containerCleanupWarning =>
      'मेल खाने वाले टैग स्थायी रूप से हटेंगे। latest और संरक्षित टैग शामिल नहीं हैं। रखने का पैटर्न हटाने के पैटर्न पर प्राथमिकता रखता है।';

  @override
  String get containerCleanupLimits =>
      'सफ़ाई हर रिपॉज़िटरी में अधिकतम एक बार प्रति घंटे असमकालिक रूप से होती है और कुछ मिलते टैग ही हट सकते हैं। आयु और क्रम मैनिफ़ेस्ट बनने के समय पर आधारित हैं, पुश समय पर नहीं। टैग हटाने से इमेज संग्रहण खाली नहीं होता।';

  @override
  String get containerCleanupDeletePattern => 'हटाने का पैटर्न (RE2, आवश्यक)';

  @override
  String get containerCleanupKeepPattern => 'रखने का पैटर्न (RE2, वैकल्पिक)';

  @override
  String get containerCleanupKeepCount =>
      'नवीनतम मिलते टैग रखने की संख्या (वैकल्पिक)';

  @override
  String get containerCleanupAge => 'इससे पुराने टैग ही हटाएँ';

  @override
  String get containerCleanupNoAge => 'आयु सीमा नहीं';

  @override
  String get containerCleanupDay => '1 दिन';

  @override
  String get containerCleanupWeek => '7 दिन';

  @override
  String get containerCleanupMonth => '1 महीना';

  @override
  String get containerCleanupRequired => 'हटाने का स्पष्ट पैटर्न दर्ज करें।';

  @override
  String get containerCleanupCountError =>
      'शून्य या धनात्मक पूर्णांक दर्ज करें या खाली छोड़ें।';

  @override
  String get containerCleanupSchedule => 'सफ़ाई शेड्यूल करें';

  @override
  String get containerCleanupScheduled =>
      'सफ़ाई शेड्यूल हुई। प्रक्रिया पूरी होने तक टैग रह सकते हैं; प्रगति देखने के लिए बाद में रीफ़्रेश करें।';

  @override
  String get containerCleanupError =>
      'सफ़ाई शेड्यूल नहीं हो सकी। कनेक्शन जाँचें और पुनः प्रयास करें।';

  @override
  String get containerCleanupForbidden =>
      'इस रिपॉज़िटरी के टैग साफ़ करने की अनुमति नहीं है।';

  @override
  String get containerCleanupRateLimited =>
      'सफ़ाई अनुरोध सीमित है। हर रिपॉज़िटरी में अधिकतम एक बार प्रति घंटे सफ़ाई हो सकती है। बाद में प्रयास करें।';

  @override
  String get containerCleanupInvalid =>
      'GitLab ने सफ़ाई मानदंड अस्वीकार किए। RE2 पैटर्न और रखने की सेटिंग जाँचें।';

  @override
  String get containerTagDeleteForbidden =>
      'आप यह टैग नहीं हटा सकते। यह सुरक्षित हो सकता है या आपके पास अनुमति नहीं है।';

  @override
  String get containerTagDeleteError =>
      'यह टैग नहीं हटाया जा सका। फिर प्रयास करें।';

  @override
  String get containerImmutabilityTitle => 'अपरिवर्तनीय टैग नियम';

  @override
  String get containerImmutabilityEmpty => 'कोई अपरिवर्तनीय टैग नियम नहीं है।';

  @override
  String get containerImmutabilityError =>
      'अपरिवर्तनीय टैग नियम लोड नहीं हुए। इंस्टेंस समर्थन जाँचकर फिर प्रयास करें।';

  @override
  String get containerImmutabilityForbidden =>
      'आपको अपरिवर्तनीय टैग नियम देखने की अनुमति नहीं है।';

  @override
  String get containerImmutabilityUnavailable =>
      'प्रोजेक्ट या नियम सूची उपलब्ध नहीं है। पहुँच, सदस्यता और इंस्टेंस समर्थन जाँचें।';

  @override
  String get containerImmutabilityHint =>
      'अपरिवर्तनीय टैग के लिए Ultimate और समर्थित रजिस्ट्री आवश्यक हैं। ये पैटर्न प्रोजेक्ट की सभी कंटेनर रिपॉज़िटरी पर लागू होते हैं और सफ़ाई नीतियों सहित मेल खाने वाले टैग को ओवरराइट करने या हटाने से रोकते हैं। नियम देखना किसी टैग की वर्तमान सुरक्षा की पुष्टि नहीं करता। बदलाव लागू होने में समय लग सकता है।';

  @override
  String get containerImmutabilityCreateTitle => 'अपरिवर्तनीय नियम बनाएँ';

  @override
  String get containerImmutabilityCreateButton => 'नियम बनाएँ';

  @override
  String get containerImmutabilityCreated => 'अपरिवर्तनीय नियम बनाया गया।';

  @override
  String get containerImmutabilityPattern => 'टैग पैटर्न';

  @override
  String get containerImmutabilityPatternHint =>
      'अधिकतम 100 अक्षरों का RE2 पैटर्न दर्ज करें। रिक्त स्थान सुरक्षित रहते हैं; GitLab सिंटैक्स की जाँच करता है।';

  @override
  String containerImmutabilityProject(String projectId) {
    return 'प्रोजेक्ट $projectId';
  }

  @override
  String get containerImmutabilityImpact =>
      'Owner पहुँच, Ultimate और समर्थित रजिस्ट्री आवश्यक हैं। पैटर्न इस प्रोजेक्ट के सभी कंटेनर रिपॉज़िटरी पर लागू होता है। मेल खाने वाले टैग को क्लीनअप नीतियों से भी ओवरराइट या हटाया नहीं जा सकता। कोई भी अपरिवर्तनीय नियम मौजूद रहने तक मैनिफेस्ट को सीधे हटाना भी अवरुद्ध रहता है। नियम संपादित नहीं किए जा सकते; बदलाव लागू होने में समय लग सकता है।';

  @override
  String get containerImmutabilityAcknowledge =>
      'मैं पूरे प्रोजेक्ट की सुरक्षा और वर्कफ़्लो पर प्रभाव समझता हूँ।';

  @override
  String get containerImmutabilityUncertain =>
      'नियम बनने की पुष्टि नहीं हुई। अनुरोध पहले ही सफल हो सकता है; फिर से प्रयास करने से पहले वर्तमान नियम जाँचें।';

  @override
  String get containerImmutabilityInspect => 'वर्तमान नियम जाँचें';

  @override
  String get containerImmutabilityRejected =>
      'GitLab ने अनुरोध अस्वीकार किया, या इस पैटर्न का अपरिवर्तनीय नियम पहले से मौजूद है। वर्तमान नियम, पैटर्न और प्रोजेक्ट सीमाएँ जाँचें।';

  @override
  String get containerImmutabilityAuth =>
      'सत्र अस्वीकार कर दिया गया। नियम बनाने से पहले फिर से साइन इन करें।';

  @override
  String get containerImmutabilityAccountChanged =>
      'खाता बदल गया। यह संवाद बंद करें और चयनित खाते के लिए फिर से खोलें।';

  @override
  String get containerImmutabilityDeleteTitle => 'अपरिवर्तनीय नियम हटाएँ';

  @override
  String get containerImmutabilityDeleteButton => 'नियम हटाएँ';

  @override
  String get containerImmutabilityDeleteDone => 'अपरिवर्तनीय नियम हटाया गया।';

  @override
  String containerImmutabilityDeleteProject(String projectId) {
    return 'प्रोजेक्ट $projectId';
  }

  @override
  String get containerImmutabilityDeleteRuleId => 'नियम ID';

  @override
  String get containerImmutabilityDeleteConfirm => 'सटीक पैटर्न दर्ज करें';

  @override
  String get containerImmutabilityDeleteImpact =>
      'इस नियम को हटाने से इस प्रोजेक्ट के सभी कंटेनर रिपॉज़िटरी में इसकी सुरक्षा हट जाती है। मेल खाने वाले टैग ओवरराइट किए जा सकते हैं या क्लीनअप नीतियों से भी हटाए जा सकते हैं। अंतिम अपरिवर्तनीय नियम हटाने से मैनिफेस्ट को सीधे हटाना संभव हो सकता है। अन्य नियम और अनुमतियाँ फिर भी लागू हो सकती हैं। इससे इमेज या टैग नहीं हटते। Owner पहुँच आवश्यक है और बदलाव लागू होने में समय लग सकता है।';

  @override
  String get containerImmutabilityDeleteAcknowledge =>
      'मैं पूरे प्रोजेक्ट में सुरक्षा हटने का प्रभाव समझता हूँ।';

  @override
  String get containerImmutabilityDeleteUncertain =>
      'हटाने की पुष्टि नहीं हुई। अनुरोध पहले ही सफल हो सकता है। फिर से प्रयास करने से पहले नियम दोबारा लोड करें।';

  @override
  String get containerImmutabilityDeleteReload => 'नियम दोबारा लोड करें';

  @override
  String get containerImmutabilityDeleteRejected =>
      'नियम बदल गया है या GitLab ने अनुरोध अस्वीकार किया है। फिर से प्रयास करने से पहले वर्तमान नियम दोबारा लोड करके पुष्टि करें।';

  @override
  String get containerImmutabilityDeleteAuth =>
      'सत्र अस्वीकार कर दिया गया। नियम हटाने से पहले फिर से साइन इन करें।';

  @override
  String get containerImmutabilityDeleteAccountChanged =>
      'खाता बदल गया। यह संवाद बंद करें और चयनित खाते के लिए फिर से खोलें।';

  @override
  String containerTagProtectionPushClearTarget(
    String projectId,
    String ruleId,
  ) {
    return 'प्रोजेक्ट $projectId — नियम $ruleId';
  }

  @override
  String containerTagProtectionDeleteClearTarget(
    String projectId,
    String ruleId,
  ) {
    return 'प्रोजेक्ट $projectId — नियम $ruleId';
  }

  @override
  String get containerTagProtectionDeleteClearForbidden =>
      'आपको यह नियम बदलने की अनुमति नहीं है।';

  @override
  String get containerTagProtectionDeleteClearStale =>
      'पुष्टि के बाद नियम बदल गया। सहेजने से पहले पुनः लोड करके जाँचें।';

  @override
  String get containerTagProtectionDeleteClearReload => 'नियम पुनः लोड करें';

  @override
  String get containerTagProtectionDeleteClearMissing =>
      'नियम नहीं मिला, अस्पष्ट है, उपलब्ध नहीं है या यह इंस्टेंस अपडेट समर्थित नहीं करता (GitLab 18.9+)। पुष्टि से पहले पुनः लोड करें।';

  @override
  String get containerTagProtectionDeleteClearRateLimited =>
      'बहुत अधिक अनुरोध हैं। प्रतीक्षा करके फिर प्रयास करें।';

  @override
  String get containerTagProtectionDeleteClearTitle =>
      'न्यूनतम हटाने की भूमिका हटाएँ';

  @override
  String get containerTagProtectionDeleteClearSave => 'हटाने की प्रतिबंध हटाएँ';

  @override
  String get containerTagProtectionDeleteClearWarning =>
      'यह इस नियम का न्यूनतम हटाने की भूमिका का प्रतिबंध हटाता है और पूरे प्रोजेक्ट में मेल खाने वाले कंटेनर टैग की हटाने की सुरक्षा कम करता है। टैग पैटर्न और न्यूनतम पुश भूमिका नहीं बदलते। अन्य नियम और अनुमतियाँ लागू रहती हैं; इससे सभी को पहुँच नहीं मिलती और टैग या इमेज नहीं हटते।';

  @override
  String get containerTagProtectionDeleteClearAcknowledge =>
      'मैंने नियम जाँच लिया है और इस हटाने की प्रतिबंध को हटाने का प्रभाव समझता हूँ।';

  @override
  String get containerTagProtectionDeleteClearError =>
      'हटाने की प्रतिबंध हटने की पुष्टि नहीं हुई। फिर प्रयास करने से पहले नियम सूची जाँचें; सर्वर ने अनुरोध स्वीकार किया हो सकता है।';

  @override
  String get containerTagProtectionDeleteClearSaved =>
      'न्यूनतम हटाने की-भूमिका प्रतिबंध हट गया।';

  @override
  String get containerTagProtectionDeleteClearInvalid =>
      'सर्वर ने हटाने की प्रतिबंध हटाना अस्वीकार किया। नियम जाँचकर फिर प्रयास करें।';

  @override
  String get containerTagProtectionDeleteClearBlocked =>
      'हटाने के लिए समर्थित वर्तमान हटाने की भूमिका और समर्थित गैर-खाली पुश भूमिका आवश्यक हैं। पहले से हटाई गई या अज्ञात सेटिंग नहीं हटाई जा सकती।';

  @override
  String get containerTagProtectionPushClearForbidden =>
      'आपको यह नियम बदलने की अनुमति नहीं है।';

  @override
  String get containerTagProtectionPushClearStale =>
      'पुष्टि के बाद नियम बदल गया। सहेजने से पहले पुनः लोड करके जाँचें।';

  @override
  String get containerTagProtectionPushClearReload => 'नियम पुनः लोड करें';

  @override
  String get containerTagProtectionPushClearMissing =>
      'नियम उपलब्ध नहीं है, अस्पष्ट है, पहुँच योग्य नहीं है या समर्थित नहीं है। संपादन के लिए GitLab 18.9 या बाद का संस्करण चाहिए। पुष्टि से पहले दोबारा लोड करें।';

  @override
  String get containerTagProtectionPushClearRateLimited =>
      'बहुत अधिक अनुरोध हैं। प्रतीक्षा करके फिर प्रयास करें।';

  @override
  String get containerTagProtectionPushClearTitle => 'न्यूनतम पुश भूमिका हटाएँ';

  @override
  String get containerTagProtectionPushClearSave => 'पुश प्रतिबंध हटाएँ';

  @override
  String get containerTagProtectionPushClearWarning =>
      'इस नियम की न्यूनतम पुश भूमिका का प्रतिबंध हटाने से प्रोजेक्ट में मेल खाने वाले कंटेनर इमेज टैग की पुश सुरक्षा कमजोर होती है। टैग पैटर्न और न्यूनतम हटाने की भूमिका अपरिवर्तित रहते हैं। अन्य नियम और अनुमतियाँ लागू रहती हैं। इससे सभी को पहुँच नहीं मिलती, टैग या इमेज नहीं हटते और Git टैग प्रभावित नहीं होते।';

  @override
  String get containerTagProtectionPushClearAcknowledge =>
      'मैंने नियम जाँच लिया है और इस पुश प्रतिबंध को हटाने का प्रभाव समझता हूँ।';

  @override
  String get containerTagProtectionPushClearError =>
      'पुश प्रतिबंध हटने की पुष्टि नहीं हुई। फिर प्रयास करने से पहले नियम सूची जाँचें; सर्वर ने अनुरोध स्वीकार किया हो सकता है।';

  @override
  String get containerTagProtectionPushClearSaved =>
      'न्यूनतम पुश-भूमिका प्रतिबंध हट गया।';

  @override
  String get containerTagProtectionPushClearInvalid =>
      'सर्वर ने पुश प्रतिबंध हटाना अस्वीकार किया। नियम जाँचकर फिर प्रयास करें।';

  @override
  String get containerTagProtectionPushClearBlocked =>
      'हटाने के लिए समर्थित वर्तमान पुश भूमिका और समर्थित गैर-खाली हटाने की भूमिका आवश्यक हैं। पहले से हटाई गई या अज्ञात सेटिंग नहीं हटाई जा सकती।';

  @override
  String get packageFileDelete => 'फ़ाइल हटाएँ';

  @override
  String get packageFileDeleteConfirmTitle => 'पैकेज फ़ाइल हटाएँ?';

  @override
  String packageFileDeleteConfirmBody(String fileName, String packageName) {
    return '“$packageName” से “$fileName” हटाएँ? इसे पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String get packageFileDeleteWarning =>
      'फ़ाइल हटाने से पैकेज खराब हो सकता है, जिससे वह अनुपयोगी हो सकता है या पैकेज मैनेजर से प्राप्त नहीं किया जा सकता।';

  @override
  String get packageFileDeleteForbidden =>
      'आप यह फ़ाइल नहीं हटा सकते। पैकेज सुरक्षित हो सकता है या आपके पास अनुमति नहीं है।';

  @override
  String get packageFileDeleteError =>
      'यह फ़ाइल नहीं हटाई जा सकी। फिर प्रयास करें।';

  @override
  String get containerRepositoryDelete => 'रिपॉज़िटरी हटाएँ';

  @override
  String get containerRepositoryDeleteConfirmTitle => 'इमेज रिपॉज़िटरी हटाएँ?';

  @override
  String containerRepositoryDeleteConfirmBody(String path) {
    return '“$path” और उसके सभी टैग हटाएँ? इसे पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String get containerRepositoryDeleteWarning =>
      'हटाना पृष्ठभूमि में निर्धारित होता है और इसमें समय लग सकता है। प्रगति देखने के लिए रजिस्ट्री रीफ़्रेश करें।';

  @override
  String get containerRepositoryDeleteForbidden =>
      'आप यह रिपॉज़िटरी नहीं हटा सकते। अपनी अनुमतियाँ और सुरक्षा नियम जाँचें।';

  @override
  String get containerRepositoryDeleteError =>
      'रिपॉज़िटरी हटाना निर्धारित नहीं किया जा सका। फिर प्रयास करें।';

  @override
  String get containerRepositoryDeletionScheduled => 'हटाना निर्धारित है';

  @override
  String get containerRepositoryDeletionNotice =>
      'रिपॉज़िटरी हटाना निर्धारित हो गया है। प्रगति देखने के लिए रीफ़्रेश करें।';

  @override
  String get containerKeepCountTitle => 'सफ़ाई में रखने की संख्या संपादित करें';

  @override
  String get containerKeepCountSave =>
      'रखने की संख्या में बदलाव की पुष्टि करें';

  @override
  String get containerKeepCountSelect =>
      'प्रत्येक इमेज में रखने वाले मिलते टैग की नई संख्या';

  @override
  String get containerKeepCountWarning =>
      'परियोजना में रखने की संख्या घटाने से नियोजित सफ़ाई में हर इमेज रिपॉज़िटरी के अधिक मिलते टैग स्थायी रूप से हट सकते हैं। नीचे सक्रिय स्थिति और हटाने के मानदंड जाँचें। अन्य सेटिंग नहीं बदलतीं और सफ़ाई पूर्ण होने की पुष्टि नहीं होती।';

  @override
  String get containerKeepCountUnknown =>
      'सक्रिय स्थिति, अंतराल, रखने की संख्या, आयु सीमा और हटाने का पैटर्न ज्ञात होना आवश्यक है। GitLab में अनुपलब्ध सेटिंग जाँचें। नई नीति नहीं बनाई जाएगी।';

  @override
  String get containerKeepCountAccepted =>
      'सफ़ाई में रखने की संख्या का अपडेट स्वीकार किया गया।';

  @override
  String get protectedBranchUnprotectTitle => 'ब्रांच नियम से सुरक्षा हटाएं';

  @override
  String protectedBranchUnprotectTarget(String project, String name) {
    return 'प्रोजेक्ट $project: $name';
  }

  @override
  String get protectedBranchUnprotectWarning =>
      'इस नियम को हटाने से पुश या मर्ज की अनुमति मिल सकती है और CI का व्यवहार बदल सकता है। वाइल्डकार्ड नियम कई ब्रांचों को प्रभावित कर सकता है।';

  @override
  String get protectedBranchUnprotectName => 'नियम का सटीक नाम लिखें';

  @override
  String get protectedBranchUnprotectAcknowledge =>
      'मैं मिलान वाली ब्रांचों पर इसका प्रभाव समझता/समझती हूं।';

  @override
  String get protectedBranchUnprotectReload => 'नियम फिर जांचें';

  @override
  String get protectedBranchUnprotectSuccess => 'ब्रांच नियम हटा दिया गया।';

  @override
  String get protectedBranchUnprotectAuth =>
      'इस नियम को बदलने से पहले फिर साइन इन करें।';

  @override
  String get protectedBranchUnprotectForbidden =>
      'आपको यह नियम हटाने की अनुमति नहीं है।';

  @override
  String get protectedBranchUnprotectUnavailable =>
      'यह नियम अब उपलब्ध नहीं है। आगे बढ़ने से पहले सूची जांचें।';

  @override
  String get protectedBranchUnprotectStale =>
      'नियम बदल गया है। आगे बढ़ने से पहले फिर जांचें।';

  @override
  String get protectedBranchUnprotectRateLimited =>
      'GitLab अनुरोध सीमित कर रहा है। फिर प्रयास करने से पहले नियम जांचें।';

  @override
  String get protectedBranchUnprotectError =>
      'नियम हटाया गया या नहीं, इसकी पुष्टि नहीं हो सकी। फिर प्रयास करने से पहले जांचें।';

  @override
  String get protectedBranchUnprotectSessionChanged =>
      'खाता बदल गया है। यह संवाद बंद करें और नियम दोबारा खोलें।';

  @override
  String get containerKeepPatternTitle => 'सफ़ाई रखने का पैटर्न संपादित करें';

  @override
  String get containerKeepPatternSave =>
      'रखने के पैटर्न में बदलाव की पुष्टि करें';

  @override
  String get containerKeepPatternSelect => 'नया रखने का पैटर्न (GitLab RE2)';

  @override
  String get containerKeepPatternWarning =>
      'परियोजना के रखने के पैटर्न का दायरा घटाने से नियोजित सफ़ाई में हर रिपॉज़िटरी के पहले संरक्षित टैग स्थायी रूप से हटने के पात्र हो सकते हैं। नीचे सक्रिय स्थिति और हटाने/रखने के मानदंड जाँचें। GitLab RE2 उपयोग करता है और पूरे टैग नाम पर पैटर्न लागू करता है। इनपुट जैसा है वैसा भेजा जाता है और GitLab जाँचता है। अन्य सेटिंग नहीं बदलतीं और स्वीकृति सफ़ाई पूर्ण होने की पुष्टि नहीं है। खाली इनपुट पैटर्न नहीं मिटाता।';

  @override
  String get containerKeepPatternUnknown =>
      'सक्रिय स्थिति, अंतराल, संख्या, आयु और प्रभावी हटाने/रखने के पैटर्न ज्ञात होना आवश्यक है। रिपोर्ट किया खाली रखने का पैटर्न बदला जा सकता है, अज्ञात मान नहीं। GitLab में अनुपलब्ध सेटिंग जाँचें। नई नीति नहीं बनाई जाएगी।';

  @override
  String get containerKeepPatternAccepted =>
      'सफ़ाई रखने के पैटर्न का अपडेट स्वीकार किया गया।';

  @override
  String get containerKeepPatternInvalid =>
      'GitLab ने रखने का पैटर्न अस्वीकार किया। RE2 सिंटैक्स और मौजूदा नीति जाँचें, फिर संपादित करें या पुनः प्रयास करें।';

  @override
  String get containerProtectionPatternTitle =>
      'रिपॉज़िटरी सुरक्षा पैटर्न बदलें';

  @override
  String get containerProtectionPatternSave => 'पैटर्न सहेजें';

  @override
  String get containerProtectionPatternWarning =>
      'पैटर्न बदलने से पहले मेल खाने वाली रिपॉज़िटरी की सुरक्षा हट सकती है और अन्य पर लागू हो सकती है। वाइल्डकार्ड (*) कई रिपॉज़िटरी को प्रभावित कर सकता है। दोनों न्यूनतम भूमिकाएँ नहीं बदलतीं; अन्य नियम और अनुमतियाँ लागू रहती हैं। इससे इमेज नहीं हटतीं और आपकी पहुँच नहीं बताई जाती।';

  @override
  String get containerProtectionPatternAcknowledge =>
      'मैंने वर्तमान नियम और नया पैटर्न जाँच लिया है और सुरक्षा के बदलाव समझता हूँ।';

  @override
  String containerProtectionPatternTarget(String projectId, String ruleId) {
    return 'प्रोजेक्ट $projectId — नियम $ruleId';
  }

  @override
  String get containerProtectionPatternForbidden =>
      'आपको यह नियम बदलने की अनुमति नहीं है।';

  @override
  String get containerProtectionPatternError =>
      'पैटर्न बदलाव की पुष्टि नहीं हुई। फिर प्रयास करने से पहले नियम सूची जाँचें; सर्वर ने अनुरोध स्वीकार किया हो सकता है।';

  @override
  String get containerProtectionPatternStale =>
      'पुष्टि के बाद नियम बदल गया। सहेजने से पहले पुनः लोड करके जाँचें।';

  @override
  String get containerProtectionPatternReload => 'नियम पुनः लोड करें';

  @override
  String get containerProtectionPatternSaved =>
      'रिपॉज़िटरी सुरक्षा पैटर्न बदल गया।';

  @override
  String get containerProtectionPatternMissing =>
      'नियम नहीं मिला, अस्पष्ट है या उपलब्ध नहीं है। पुष्टि से पहले पुनः लोड करें।';

  @override
  String get containerProtectionPatternRateLimited =>
      'बहुत अधिक अनुरोध हैं। प्रतीक्षा करके फिर प्रयास करें।';

  @override
  String get containerProtectionPatternInvalid =>
      'पैटर्न अस्वीकार हुआ या पहले से उपयोग में है। मसौदा बदलकर फिर प्रयास करें।';

  @override
  String get containerProtectionPatternDraft => 'नया रिपॉज़िटरी पथ पैटर्न';

  @override
  String get containerRepositoryProtectionTitle => 'रिपॉज़िटरी सुरक्षा नियम';

  @override
  String get containerProtectionRemoveTitle => 'रिपॉज़िटरी सुरक्षा नियम हटाएँ';

  @override
  String get containerProtectionRemoveSave => 'नियम हटाने की पुष्टि करें';

  @override
  String get containerProtectionRemoveWarning =>
      'यह नियम हटाने से पथ पैटर्न से मेल खाने वाली रिपॉज़िटरी के पुश या हटाने के प्रतिबंध कम हो सकते हैं। अन्य नियम और अनुमतियाँ लागू रहेंगे। केवल सुरक्षा नियम हटता है, रिपॉज़िटरी, टैग या इमेज नहीं। सटीक लक्ष्य और न्यूनतम भूमिकाओं की समीक्षा करें; ये भूमिकाएँ आपकी अनुमतियाँ नहीं बतातीं।';

  @override
  String get containerProtectionRemoveAcknowledge =>
      'मैं समझता हूँ कि इस नियम के सुरक्षा प्रतिबंध हटेंगे।';

  @override
  String containerProtectionRemoveTarget(String projectId, String ruleId) {
    return 'प्रोजेक्ट $projectId — नियम $ruleId';
  }

  @override
  String get containerProtectionRemoveForbidden =>
      'आपको यह रिपॉज़िटरी सुरक्षा नियम हटाने की अनुमति नहीं है।';

  @override
  String get containerProtectionRemoveError =>
      'नियम हटाने की पुष्टि नहीं हुई। पुनः लोड करें या फिर प्रयास करें।';

  @override
  String get containerProtectionRemoveStale =>
      'पुष्टि के बाद नियम बदला है। हटाने से पहले पुनः लोड करके समीक्षा करें।';

  @override
  String get containerProtectionRemoveReload => 'नियम पुनः लोड करें';

  @override
  String get containerProtectionRemoveDeleted =>
      'रिपॉज़िटरी सुरक्षा नियम हटा दिया गया।';

  @override
  String get containerProtectionRemoveMissing =>
      'नियम नहीं मिला, लक्ष्य अस्पष्ट है या पहुँच नहीं है। पुष्टि से पहले पुनः लोड करें।';

  @override
  String get containerProtectionRemoveRateLimited =>
      'बहुत अधिक अनुरोध। प्रतीक्षा करें और फिर प्रयास करें।';

  @override
  String get containerRepositoryProtectionEmpty =>
      'कोई रिपॉज़िटरी सुरक्षा नियम नहीं है।';

  @override
  String get containerProtectionCreateTitle => 'रिपॉज़िटरी सुरक्षा नियम बनाएँ';

  @override
  String get containerProtectionCreateSave => 'नियम बनाएँ';

  @override
  String get containerProtectionCreatePattern => 'रिपॉज़िटरी पथ पैटर्न';

  @override
  String containerProtectionCreateProject(String projectId) {
    return 'प्रोजेक्ट $projectId';
  }

  @override
  String get containerProtectionCreateWarning =>
      'यह नियम सटीक पैटर्न से मेल खाने वाली रिपॉज़िटरी में चुने गए पुश और हटाने के कार्यों को सीमित करता है। वाइल्डकार्ड (*) कई रिपॉज़िटरी को प्रभावित कर सकता है। न चुनी गई भूमिका के कार्य पर इस नियम से कोई प्रतिबंध नहीं लगता। अन्य नियम और अनुमतियाँ लागू रहती हैं। ये सेटिंग आपकी पहुँच नहीं बतातीं और इमेज नहीं हटातीं।';

  @override
  String get containerProtectionCreateAcknowledge =>
      'मैंने पैटर्न और न्यूनतम भूमिकाएँ जाँच ली हैं और उनका प्रभाव समझता हूँ।';

  @override
  String get containerProtectionCreateUnset => 'इस नियम से कोई प्रतिबंध नहीं';

  @override
  String get containerProtectionCreateCreated => 'नियम बनाया गया।';

  @override
  String get containerProtectionCreateForbidden =>
      'आपको यह नियम बनाने की अनुमति नहीं है।';

  @override
  String get containerProtectionCreateInvalid =>
      'पैटर्न या भूमिकाएँ अस्वीकार हुईं या पैटर्न पहले से उपयोग में है। मसौदा बदलकर फिर प्रयास करें।';

  @override
  String get containerProtectionCreateError =>
      'नियम बनने की पुष्टि नहीं हुई। फिर प्रयास करने से पहले नियम सूची जाँचें; सर्वर ने अनुरोध स्वीकार किया हो सकता है।';

  @override
  String get containerProtectionCreatePush => 'न्यूनतम पुश भूमिका';

  @override
  String get containerProtectionCreateDelete => 'न्यूनतम हटाने की भूमिका';

  @override
  String get containerRepositoryProtectionError =>
      'रिपॉज़िटरी सुरक्षा नियम लोड नहीं किए जा सके।';

  @override
  String get containerRepositoryProtectionForbidden =>
      'आपके पास रिपॉज़िटरी सुरक्षा नियम देखने की अनुमति नहीं है।';

  @override
  String containerProtectionDeleteClearTarget(String projectId, String ruleId) {
    return 'प्रोजेक्ट $projectId — नियम $ruleId';
  }

  @override
  String get containerProtectionDeleteClearForbidden =>
      'आपको यह नियम बदलने की अनुमति नहीं है।';

  @override
  String get containerProtectionDeleteClearStale =>
      'पुष्टि के बाद नियम बदल गया। सहेजने से पहले पुनः लोड करके जाँचें।';

  @override
  String get containerProtectionDeleteClearReload => 'नियम पुनः लोड करें';

  @override
  String get containerProtectionDeleteClearMissing =>
      'नियम नहीं मिला, अस्पष्ट है या उपलब्ध नहीं है। पुष्टि से पहले पुनः लोड करें।';

  @override
  String get containerProtectionDeleteClearRateLimited =>
      'बहुत अधिक अनुरोध हैं। प्रतीक्षा करके फिर प्रयास करें।';

  @override
  String get containerProtectionDeleteRoleTitle =>
      'न्यूनतम हटाने की भूमिका बदलें';

  @override
  String get containerProtectionDeleteRoleSave => 'हटाने की भूमिका सहेजें';

  @override
  String get containerProtectionDeleteRoleWarning =>
      'न्यूनतम हटाने की भूमिका बदलने से मेल खाने वाली रिपॉज़िटरी में इमेज हटाने वाले लोग बदलते हैं। निचली भूमिका हटाने की सुरक्षा कम करती है; ऊँची भूमिका मौजूदा सफ़ाई कार्यप्रवाह रोक सकती है। पथ पैटर्न और न्यूनतम पुश भूमिका नहीं बदलते। अन्य नियम और अनुमतियाँ लागू रहती हैं; ये मान आपकी पहुँच नहीं बताते। नियम सहेजने से इमेज नहीं हटतीं।';

  @override
  String get containerProtectionDeleteRoleAcknowledge =>
      'मैंने नियम और नई न्यूनतम हटाने की भूमिका जाँच ली है और पहुँच के बदलाव समझता हूँ।';

  @override
  String containerProtectionDeleteRoleTarget(String projectId, String ruleId) {
    return 'प्रोजेक्ट $projectId — नियम $ruleId';
  }

  @override
  String get containerProtectionDeleteRoleForbidden =>
      'आपको यह नियम बदलने की अनुमति नहीं है।';

  @override
  String get containerProtectionDeleteRoleError =>
      'हटाने की भूमिका बदलाव की पुष्टि नहीं हुई। फिर प्रयास करने से पहले नियम सूची जाँचें; सर्वर ने अनुरोध स्वीकार किया हो सकता है।';

  @override
  String get containerProtectionDeleteRoleStale =>
      'पुष्टि के बाद नियम बदल गया। सहेजने से पहले पुनः लोड करके जाँचें।';

  @override
  String get containerProtectionDeleteRoleReload => 'नियम पुनः लोड करें';

  @override
  String get containerProtectionDeleteRoleSaved =>
      'न्यूनतम हटाने की भूमिका बदल गई।';

  @override
  String get containerProtectionDeleteRoleMissing =>
      'नियम नहीं मिला, अस्पष्ट है या उपलब्ध नहीं है। पुष्टि से पहले पुनः लोड करें।';

  @override
  String get containerProtectionDeleteRoleRateLimited =>
      'बहुत अधिक अनुरोध हैं। प्रतीक्षा करके फिर प्रयास करें।';

  @override
  String get containerProtectionDeleteRoleInvalid =>
      'हटाने की भूमिका अस्वीकार हुई। समर्थित भूमिका चुनकर फिर प्रयास करें।';

  @override
  String get containerProtectionDeleteRoleDraft => 'नई न्यूनतम हटाने की भूमिका';

  @override
  String get containerProtectionDeleteRoleSelect => 'हटाने की भूमिका चुनें';

  @override
  String get containerProtectionDeleteRoleUnknown =>
      'वर्तमान हटाने की भूमिका अज्ञात है। असमर्थित सेटिंग बदलने से बचाने के लिए संपादन रोका गया है।';

  @override
  String get containerProtectionDeleteClearTitle =>
      'न्यूनतम हटाने की भूमिका हटाएँ';

  @override
  String get containerProtectionDeleteClearSave => 'हटाने की प्रतिबंध हटाएँ';

  @override
  String get containerProtectionDeleteClearWarning =>
      'यह इस नियम का न्यूनतम हटाने की भूमिका का प्रतिबंध हटाता है और मेल खाने वाली रिपॉज़िटरी की हटाने की सुरक्षा कम करता है। पथ पैटर्न और न्यूनतम पुश भूमिका नहीं बदलते। अन्य नियम और अनुमतियाँ लागू रहती हैं; इससे सभी को पहुँच नहीं मिलती और इमेज नहीं हटतीं।';

  @override
  String get containerProtectionDeleteClearAcknowledge =>
      'मैंने नियम जाँच लिया है और इस हटाने की प्रतिबंध को हटाने का प्रभाव समझता हूँ।';

  @override
  String get containerProtectionDeleteClearError =>
      'हटाने की प्रतिबंध हटने की पुष्टि नहीं हुई। फिर प्रयास करने से पहले नियम सूची जाँचें; सर्वर ने अनुरोध स्वीकार किया हो सकता है।';

  @override
  String get containerProtectionDeleteClearSaved =>
      'न्यूनतम हटाने की-भूमिका प्रतिबंध हट गया।';

  @override
  String get containerProtectionDeleteClearInvalid =>
      'सर्वर ने हटाने की प्रतिबंध हटाना अस्वीकार किया। नियम जाँचकर फिर प्रयास करें।';

  @override
  String get containerProtectionDeleteClearBlocked =>
      'हटाने के लिए समर्थित वर्तमान हटाने की भूमिका और समर्थित गैर-खाली पुश भूमिका आवश्यक हैं। पहले से हटाई गई या अज्ञात सेटिंग नहीं हटाई जा सकती।';

  @override
  String get containerRepositoryProtectionUnavailable =>
      'इस इंस्टेंस पर रिपॉज़िटरी सुरक्षा नियम उपलब्ध नहीं हैं या प्रोजेक्ट तक पहुँच नहीं है।';

  @override
  String containerRepositoryProtectionPushRole(String role) {
    return 'पुश करने के लिए न्यूनतम भूमिका: $role';
  }

  @override
  String containerRepositoryProtectionDeleteRole(String role) {
    return 'हटाने के लिए न्यूनतम भूमिका: $role';
  }

  @override
  String get containerRepositoryProtectionRoleUnset =>
      'नियम में निर्दिष्ट नहीं';

  @override
  String containerProtectionPushClearTarget(String projectId, String ruleId) {
    return 'प्रोजेक्ट $projectId — नियम $ruleId';
  }

  @override
  String get containerProtectionPushClearForbidden =>
      'आपको यह नियम बदलने की अनुमति नहीं है।';

  @override
  String get containerProtectionPushClearStale =>
      'पुष्टि के बाद नियम बदल गया। सहेजने से पहले पुनः लोड करके जाँचें।';

  @override
  String get containerProtectionPushClearReload => 'नियम पुनः लोड करें';

  @override
  String get containerProtectionPushClearMissing =>
      'नियम नहीं मिला, अस्पष्ट है या उपलब्ध नहीं है। पुष्टि से पहले पुनः लोड करें।';

  @override
  String get containerProtectionPushClearRateLimited =>
      'बहुत अधिक अनुरोध हैं। प्रतीक्षा करके फिर प्रयास करें।';

  @override
  String get containerProtectionPushRoleTitle => 'न्यूनतम पुश भूमिका बदलें';

  @override
  String get containerProtectionPushRoleSave => 'पुश भूमिका सहेजें';

  @override
  String get containerProtectionPushRoleWarning =>
      'न्यूनतम पुश भूमिका बदलने से मेल खाने वाली रिपॉज़िटरी में पुश करने वाले लोग बदलते हैं। निचली भूमिका सुरक्षा कम करती है; ऊँची भूमिका मौजूदा कार्यप्रवाह रोक सकती है। पथ पैटर्न और न्यूनतम हटाने की भूमिका नहीं बदलते। अन्य नियम और अनुमतियाँ लागू रहती हैं; ये मान आपकी पहुँच नहीं बताते और इमेज नहीं हटाते।';

  @override
  String get containerProtectionPushRoleAcknowledge =>
      'मैंने नियम और नई न्यूनतम पुश भूमिका जाँच ली है और पहुँच के बदलाव समझता हूँ।';

  @override
  String containerProtectionPushRoleTarget(String projectId, String ruleId) {
    return 'प्रोजेक्ट $projectId — नियम $ruleId';
  }

  @override
  String get containerProtectionPushRoleForbidden =>
      'आपको यह नियम बदलने की अनुमति नहीं है।';

  @override
  String get containerProtectionPushRoleError =>
      'पुश भूमिका बदलाव की पुष्टि नहीं हुई। फिर प्रयास करने से पहले नियम सूची जाँचें; सर्वर ने अनुरोध स्वीकार किया हो सकता है।';

  @override
  String get containerProtectionPushRoleStale =>
      'पुष्टि के बाद नियम बदल गया। सहेजने से पहले पुनः लोड करके जाँचें।';

  @override
  String get containerProtectionPushRoleReload => 'नियम पुनः लोड करें';

  @override
  String get containerProtectionPushRoleSaved => 'न्यूनतम पुश भूमिका बदल गई।';

  @override
  String get containerProtectionPushRoleMissing =>
      'नियम नहीं मिला, अस्पष्ट है या उपलब्ध नहीं है। पुष्टि से पहले पुनः लोड करें।';

  @override
  String get containerProtectionPushRoleRateLimited =>
      'बहुत अधिक अनुरोध हैं। प्रतीक्षा करके फिर प्रयास करें।';

  @override
  String get containerProtectionPushRoleInvalid =>
      'पुश भूमिका अस्वीकार हुई। समर्थित भूमिका चुनकर फिर प्रयास करें।';

  @override
  String get containerProtectionPushRoleDraft => 'नई न्यूनतम पुश भूमिका';

  @override
  String get containerProtectionPushRoleSelect => 'पुश भूमिका चुनें';

  @override
  String get containerProtectionPushRoleUnknown =>
      'वर्तमान पुश भूमिका अज्ञात है। असमर्थित सेटिंग बदलने से बचाने के लिए संपादन रोका गया है।';

  @override
  String get containerProtectionPushClearTitle => 'न्यूनतम पुश भूमिका हटाएँ';

  @override
  String get containerProtectionPushClearSave => 'पुश प्रतिबंध हटाएँ';

  @override
  String get containerProtectionPushClearWarning =>
      'यह इस नियम का न्यूनतम पुश-भूमिका प्रतिबंध हटाता है और मेल खाने वाली रिपॉज़िटरी की पुश सुरक्षा कम करता है। पथ पैटर्न और न्यूनतम हटाने की भूमिका नहीं बदलते। अन्य नियम और अनुमतियाँ लागू रहती हैं; इससे सभी को पहुँच नहीं मिलती और इमेज नहीं हटतीं।';

  @override
  String get containerProtectionPushClearAcknowledge =>
      'मैंने नियम जाँच लिया है और इस पुश प्रतिबंध को हटाने का प्रभाव समझता हूँ।';

  @override
  String get containerProtectionPushClearError =>
      'पुश प्रतिबंध हटने की पुष्टि नहीं हुई। फिर प्रयास करने से पहले नियम सूची जाँचें; सर्वर ने अनुरोध स्वीकार किया हो सकता है।';

  @override
  String get containerProtectionPushClearSaved =>
      'न्यूनतम पुश-भूमिका प्रतिबंध हट गया।';

  @override
  String get containerProtectionPushClearInvalid =>
      'सर्वर ने पुश प्रतिबंध हटाना अस्वीकार किया। नियम जाँचकर फिर प्रयास करें।';

  @override
  String get containerProtectionPushClearBlocked =>
      'हटाने के लिए समर्थित वर्तमान पुश भूमिका और समर्थित गैर-खाली हटाने की भूमिका आवश्यक हैं। पहले से हटाई गई या अज्ञात सेटिंग नहीं हटाई जा सकती।';

  @override
  String get containerRepositoryProtectionRoleAdmin => 'प्रशासक';

  @override
  String get containerAgeTitle => 'सफ़ाई आयु सीमा संपादित करें';

  @override
  String get containerAgeSave => 'आयु सीमा में बदलाव की पुष्टि करें';

  @override
  String get containerAgeSelect => 'नई आयु सीमा (GitLab API अवधि)';

  @override
  String get containerAgeWarning =>
      'परियोजना की आयु सीमा घटाने से नियोजित सफ़ाई में हर इमेज रिपॉज़िटरी के नए मिलते टैग भी स्थायी रूप से हट सकते हैं। नीचे सक्रिय स्थिति और हटाने के मानदंड जाँचें। अन्य सेटिंग नहीं बदलतीं और सफ़ाई पूर्ण होने की पुष्टि नहीं होती।';

  @override
  String get containerAgeUnknown =>
      'सक्रिय स्थिति, अंतराल, रखने की संख्या, आयु सीमा और हटाने का पैटर्न ज्ञात होना आवश्यक है। GitLab में अनुपलब्ध सेटिंग जाँचें। नई नीति नहीं बनाई जाएगी।';

  @override
  String get containerAgeAccepted =>
      'सफ़ाई आयु सीमा का अपडेट स्वीकार किया गया।';

  @override
  String get containerDeletePatternTitle =>
      'सफ़ाई हटाने का पैटर्न संपादित करें';

  @override
  String get containerDeletePatternSave =>
      'हटाने के पैटर्न में बदलाव की पुष्टि करें';

  @override
  String get containerDeletePatternSelect => 'नया हटाने का पैटर्न (GitLab RE2)';

  @override
  String get containerDeletePatternWarning =>
      'परियोजना के हटाने के पैटर्न का दायरा बढ़ाने से नियोजित सफ़ाई में हर इमेज रिपॉज़िटरी के अधिक मिलते टैग स्थायी रूप से हट सकते हैं। नीचे सक्रिय स्थिति और रखने के मानदंड जाँचें। GitLab RE2 उपयोग करता है और पूरे टैग नाम पर पैटर्न लागू करता है। इनपुट जैसा है वैसा भेजा जाता है और GitLab जाँचता है। अन्य सेटिंग नहीं बदलतीं और स्वीकृति सफ़ाई पूर्ण होने की पुष्टि नहीं है।';

  @override
  String get containerDeletePatternUnknown =>
      'सक्रिय स्थिति, अंतराल, रखने की संख्या, आयु सीमा और प्रभावी हटाने का पैटर्न ज्ञात होना आवश्यक है। GitLab में अनुपलब्ध सेटिंग जाँचें। नई नीति नहीं बनाई जाएगी।';

  @override
  String get containerDeletePatternAccepted =>
      'सफ़ाई हटाने के पैटर्न का अपडेट स्वीकार किया गया।';

  @override
  String get containerDeletePatternInvalid =>
      'GitLab ने पैटर्न अस्वीकार किया। RE2 सिंटैक्स और मौजूदा नीति जाँचें, फिर संपादित करें या पुनः प्रयास करें।';

  @override
  String get containerKeepPatternClearTitle => 'क्लीनअप रखने का पैटर्न हटाएँ';

  @override
  String get containerKeepPatternClearSave =>
      'रखने के पैटर्न को हटाने की पुष्टि करें';

  @override
  String get containerKeepPatternClearWarning =>
      'प्रोजेक्ट का रखने वाला पैटर्न हटाने से सभी इमेज रिपॉज़िटरी में पहले सुरक्षित टैग निर्धारित क्लीनअप के दौरान स्थायी रूप से हटाए जाने योग्य हो सकते हैं। latest टैग और अन्य रखने तथा सुरक्षा नियम लागू रहेंगे; टैग तुरंत नहीं हटते। नीचे वर्तमान शर्तों की समीक्षा करें। केवल खाली रखने वाला पैटर्न भेजा जाता है। अन्य नीति फ़ील्ड नहीं बदलते, लेकिन GitLab अगला रन फिर निर्धारित कर सकता है। अनुरोध स्वीकार होने का अर्थ क्लीनअप पूरा होना या स्टोरेज खाली होना नहीं है।';

  @override
  String get containerKeepPatternClearAcknowledge =>
      'मैं समझता हूँ कि पहले सुरक्षित टैग स्थायी रूप से हटाए जाने योग्य हो सकते हैं।';

  @override
  String get containerKeepPatternClearUnknown =>
      'सक्रिय स्थिति, अंतराल, संख्या, उम्र, प्रभावी हटाने का पैटर्न और गैर-खाली रखने का पैटर्न रिपोर्ट होना आवश्यक है। खाली या रिपोर्ट न किए गए रखने के पैटर्न को यहाँ नहीं हटाया जा सकता। कोई नीति नहीं बनाई जाएगी।';

  @override
  String get containerKeepPatternClearAccepted =>
      'रखने का पैटर्न हटाने का अनुरोध स्वीकार हुआ।';

  @override
  String get containerKeepPatternClearInvalid =>
      'GitLab ने रखने का पैटर्न हटाने से मना किया। मौजूदा नीति की समीक्षा करें और फिर प्रयास करें या पुनः लोड करें।';

  @override
  String get pipelinesRefAll => 'सभी रेफ़';

  @override
  String get pipelinesRefTitle => 'ब्रांच या टैग';

  @override
  String pipelinesRefSelected(String ref) {
    return 'रेफ़: $ref';
  }

  @override
  String get pipelinesRefApply => 'लागू करें';

  @override
  String get pipelinesRefClear => 'हटाएँ';

  @override
  String get pipelinesRefHint => 'ब्रांच या टैग का सटीक नाम दर्ज करें।';

  @override
  String get pipelinesSourceAll => 'सभी शीर्ष स्तर के स्रोत';

  @override
  String get pipelinesSourcePush => 'पुश';

  @override
  String get pipelinesSourceWeb => 'वेब';

  @override
  String get pipelinesSourceApi => 'API';

  @override
  String get pipelinesSourceSchedule => 'शेड्यूल';

  @override
  String get pipelinesSourceTrigger => 'ट्रिगर';

  @override
  String get pipelinesSourcePipeline => 'बहु-प्रोजेक्ट पाइपलाइन';

  @override
  String get pipelinesSourceMergeRequest => 'मर्ज अनुरोध';

  @override
  String get pipelinesSourceChild => 'चाइल्ड पाइपलाइन';

  @override
  String get pipelinesChildHint =>
      'चाइल्ड पाइपलाइन खोजने के लिए GitLab 17.0 या बाद का संस्करण आवश्यक है।';

  @override
  String get pipelineDownstreamTitle => 'डाउनस्ट्रीम पाइपलाइन';

  @override
  String get pipelineDownstreamEmpty => 'कोई पाइपलाइन ट्रिगर नहीं है।';

  @override
  String get pipelineDownstreamError =>
      'डाउनस्ट्रीम पाइपलाइन लोड नहीं हो सकीं।';

  @override
  String get pipelineDownstreamLoadMoreError =>
      'और डाउनस्ट्रीम पाइपलाइन लोड नहीं हो सकीं।';

  @override
  String get pipelineDownstreamUnavailable =>
      'डाउनस्ट्रीम पाइपलाइन खोलना उपलब्ध नहीं है।';

  @override
  String pipelineDownstreamTarget(int projectId, int pipelineId) {
    final intl.NumberFormat projectIdNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String projectIdString = projectIdNumberFormat.format(projectId);
    final intl.NumberFormat pipelineIdNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String pipelineIdString = pipelineIdNumberFormat.format(pipelineId);

    return 'प्रोजेक्ट $projectIdString · पाइपलाइन #$pipelineIdString';
  }

  @override
  String get pipelineUpstreamTitle => 'अपस्ट्रीम पाइपलाइन';

  @override
  String get pipelineUpstreamEmpty => 'कोई अपस्ट्रीम पाइपलाइन उपलब्ध नहीं है।';

  @override
  String get pipelineUpstreamError => 'अपस्ट्रीम पाइपलाइन लोड नहीं हो सकी।';

  @override
  String get pipelineUpstreamUnavailable =>
      'अपस्ट्रीम पाइपलाइन खोलना उपलब्ध नहीं है।';

  @override
  String pipelineUpstreamTarget(int projectId, int pipelineId) {
    final intl.NumberFormat projectIdNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String projectIdString = projectIdNumberFormat.format(projectId);
    final intl.NumberFormat pipelineIdNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String pipelineIdString = pipelineIdNumberFormat.format(pipelineId);

    return 'प्रोजेक्ट $projectIdString · पाइपलाइन #$pipelineIdString';
  }

  @override
  String get pipelineJobsTitle => 'जॉब';

  @override
  String get pipelineJobsStatusAll => 'सभी जॉब स्थितियाँ';

  @override
  String get pipelineJobsFilteredEmpty =>
      'इस स्थिति से मेल खाने वाला कोई जॉब नहीं है।';

  @override
  String get pipelineJobsAttemptsLatest => 'नवीनतम जॉब';

  @override
  String get pipelineJobsAttemptsAll => 'सभी प्रयास';

  @override
  String pipelineJobIdentifier(int jobId) {
    final intl.NumberFormat jobIdNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String jobIdString = jobIdNumberFormat.format(jobId);

    return 'जॉब #$jobIdString';
  }

  @override
  String get pipelineJobsPartialList =>
      'केवल लोड किए गए जॉब दिखाए गए हैं। बाकी देखने के लिए और लोड करें।';

  @override
  String get pipelineJobsLoadMoreError => 'और जॉब लोड नहीं हो सके।';

  @override
  String get mrApprovalStatusLoading => 'स्वीकृति की स्थिति लोड हो रही है…';

  @override
  String get mrApprovalStatusError => 'स्वीकृति की स्थिति लोड नहीं हो सकी।';

  @override
  String get mrDiscussionResolved => 'समाधान किया गया';

  @override
  String get mrDiscussionUnresolved => 'अनसुलझा';

  @override
  String get mrDiscussionsLoadMore => 'और चर्चाएँ लोड करें';

  @override
  String get mrDiscussionsMoreError => 'और चर्चाएँ लोड नहीं हो सकीं।';

  @override
  String get mrDiscussionsPartial => 'और चर्चाएँ उपलब्ध हैं।';

  @override
  String get mrDiscussionReplyButton => 'जवाब दें';

  @override
  String get mrDiscussionReplyTitle => 'चर्चा का जवाब दें';

  @override
  String get mrDiscussionReplyHint => 'जवाब लिखें…';

  @override
  String get mrDiscussionResolveButton => 'चर्चा हल करें';

  @override
  String get mrDiscussionReopenButton => 'चर्चा फिर से खोलें';

  @override
  String get mrDiscussionResolveForbidden =>
      'आप इस चर्चा को बदल नहीं सकते। अपने खाते की अनुमतियाँ जाँचें।';

  @override
  String get mrDiscussionResolveError =>
      'चर्चा अपडेट नहीं हो सकी। फिर से प्रयास करें।';

  @override
  String get mrDiscussionContextViewButton => 'मूल अंतर देखें';

  @override
  String get mrDiscussionContextHideButton => 'मूल अंतर छिपाएँ';

  @override
  String mrDiscussionContextTitle(String version) {
    return 'मूल अंतर · संस्करण $version';
  }

  @override
  String get mrDiscussionContextUnavailable =>
      'इस टिप्पणी का मूल अंतर संदर्भ उपलब्ध नहीं है।';

  @override
  String get mrDiscussionContextError =>
      'मूल अंतर लोड नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get mrDiscussionContextOlderButton => 'पुराने संस्करण खोजें';

  @override
  String get mrDiscussionContextLineLabel => 'टिप्पणी वाली पंक्ति';

  @override
  String get mrDiscussionContextLoading => 'मूल अंतर लोड हो रहा है';

  @override
  String get mrDiffDiscussLineButton => 'इस पंक्ति पर चर्चा जोड़ें';

  @override
  String mrDiffDiscussionTitle(String path, String version) {
    return '$path पर चर्चा · संस्करण $version';
  }

  @override
  String get mrDiffDiscussionHint => 'समीक्षा टिप्पणी लिखें…';

  @override
  String get mrDiffDiscussionSubmit => 'चर्चा शुरू करें';

  @override
  String get mrDiffDiscussionCancel => 'रद्द करें';

  @override
  String get mrDiffDiscussionCreated => 'चर्चा बनाई गई।';

  @override
  String get mrDiffDiscussionError => 'चर्चा बनाए जाने की पुष्टि नहीं हो सकी।';

  @override
  String get mrDiffDiscussionPermissionError =>
      'आपको यह चर्चा बनाने की अनुमति नहीं है।';

  @override
  String get mrDiffDiscussionReloadButton => 'चर्चाएँ रीफ़्रेश करें';

  @override
  String get mrDiffDiscussionReloadRequired =>
      'फिर से भेजने से पहले चर्चाएँ रीफ़्रेश करें। पिछला अनुरोध स्वीकार हो चुका हो सकता है।';

  @override
  String get mrDiffDiscussionReloadFailed =>
      'चर्चाएँ रीफ़्रेश नहीं हो सकीं। फिर से प्रयास करें।';

  @override
  String get mrReviewUnavailable =>
      'इस डिफ़ संस्करण पर इनलाइन समीक्षा उपलब्ध नहीं है।';

  @override
  String mrReviewVersionTitle(String version) {
    return 'डिफ़ संस्करण $version की समीक्षा';
  }

  @override
  String get mrDiffDiscussionPending => 'चर्चा बनाई जा रही है…';

  @override
  String get mrDiffDiscussionReloading => 'चर्चाएँ रीफ़्रेश की जा रही हैं…';

  @override
  String get mrDiffDiscussionInspect =>
      'दोबारा भेजने से पहले इस चयन की चर्चाएँ देखें।';

  @override
  String get mrDiffDiscussionNoMatches =>
      'लोड किए गए पृष्ठों में इस चयन की कोई चर्चा नहीं है।';

  @override
  String mrSuggestionTitle(String number) {
    return 'सुझाव $number';
  }

  @override
  String mrSuggestionRange(String from, String to) {
    return 'मूल पंक्तियाँ $from–$to';
  }

  @override
  String get mrSuggestionRangeUnknown => 'मूल पंक्ति सीमा उपलब्ध नहीं है';

  @override
  String get mrSuggestionApplied => 'लागू किया गया';

  @override
  String get mrSuggestionNotApplied => 'लागू नहीं किया गया';

  @override
  String get mrSuggestionAppliedUnknown => 'लागू होने की स्थिति अज्ञात';

  @override
  String get mrSuggestionApplicable => 'पैच लागू किया जा सकता है';

  @override
  String get mrSuggestionNotApplicable => 'पैच लागू नहीं किया जा सकता';

  @override
  String get mrSuggestionApplicableUnknown => 'पैच लागू होने की क्षमता अज्ञात';

  @override
  String get mrSuggestionOriginal => 'मूल कोड';

  @override
  String get mrSuggestionReplacement => 'सुझाया गया कोड';

  @override
  String get mrSuggestionContentUnknown => 'सामग्री उपलब्ध नहीं है';

  @override
  String get mrSuggestionContentEmpty => 'खाली सामग्री';

  @override
  String get mrSuggestionViewButton => 'सुझाव देखें';

  @override
  String get mrSuggestionHideButton => 'सुझाव छिपाएँ';

  @override
  String get mrSuggestionApplyButton => 'सुझाव लागू करें';

  @override
  String mrSuggestionApplyTitle(String suggestionId) {
    return 'सुझाव $suggestionId लागू करें?';
  }

  @override
  String get mrSuggestionApplyImpact =>
      'यह मर्ज अनुरोध की स्रोत शाखा पर एक कमिट बनाता है। लागू करने से पहले प्रतिस्थापन कोड की समीक्षा करें।';

  @override
  String get mrSuggestionCommitMessageLabel => 'कमिट संदेश (वैकल्पिक)';

  @override
  String get mrSuggestionCommitMessageHint =>
      'GitLab का डिफ़ॉल्ट संदेश उपयोग करने के लिए खाली छोड़ें।';

  @override
  String get mrSuggestionApplyProgress =>
      'सुझाव की जाँच और लागू किया जा रहा है…';

  @override
  String get mrSuggestionApplySuccess => 'सुझाव लागू हुआ।';

  @override
  String get mrSuggestionApplyError =>
      'लागू होने की पुष्टि नहीं हो सकी। फिर कोशिश करने से पहले चर्चा दोबारा लोड करके वर्तमान स्थिति जाँचें।';

  @override
  String get mrSuggestionApplyForbidden =>
      'GitLab ने यह कार्रवाई अस्वीकार कर दी। अपना एक्सेस जाँचें और फिर कोशिश करने से पहले दोबारा लोड करें।';

  @override
  String get mrSuggestionApplyChanged =>
      'सुझाव बदल गया है। दोबारा लोड करें और लागू करने से पहले वर्तमान कोड की समीक्षा करें।';

  @override
  String get mrSuggestionReloadButton => 'चर्चा दोबारा लोड करें';

  @override
  String get mrSuggestionReloadProgress => 'चर्चा दोबारा लोड हो रही है…';

  @override
  String get mrSuggestionReloadError =>
      'चर्चा दोबारा लोड नहीं हो सकी। दोबारा लोड करने की कोशिश करें।';

  @override
  String get mrSuggestionUnavailable =>
      'यह सुझाव लागू करने के लिए उपलब्ध नहीं है।';

  @override
  String get mrSuggestionSessionChanged =>
      'खाता या मर्ज अनुरोध बदल गया है। यह संवाद बंद करके सुझाव दोबारा खोलें।';

  @override
  String get mrSuggestionsBatchButton => 'कई सुझाव लागू करें';

  @override
  String get mrSuggestionsSelectTitle => 'सुझाव चुनें';

  @override
  String get mrSuggestionsSelectHint =>
      'लोड की गई चर्चाओं से कम से कम दो सुझाव चुनें।';

  @override
  String get mrSuggestionsReviewButton => 'चुने हुए सुझावों की समीक्षा करें';

  @override
  String mrSuggestionsReviewTitle(String count) {
    return '$count सुझाव लागू करें?';
  }

  @override
  String get mrSuggestionsApplyButton => 'चुने हुए सुझाव लागू करें';

  @override
  String get mrSuggestionsApplyImpact =>
      'ये बदलाव मर्ज अनुरोध की स्रोत शाखा में एक साथ भेजे जाएंगे। लागू करने से पहले हर प्रतिस्थापन की समीक्षा करें।';

  @override
  String get mrSuggestionsApplyProgress =>
      'सुझावों की जाँच और लागू करना जारी है…';

  @override
  String get mrSuggestionsApplySuccess => 'चुने हुए सुझाव लागू किए गए।';

  @override
  String get mrSuggestionsApplyError =>
      'बैच की पुष्टि नहीं हो सकी। फिर कोशिश करने से पहले सभी चुनी हुई चर्चाएँ फिर से लोड करें।';

  @override
  String get mrSuggestionsApplyChanged =>
      'एक या अधिक सुझाव बदल गए हैं। हर चुने हुए पैच को फिर से लोड करके समीक्षा करें।';

  @override
  String get mrSuggestionsReloadButton => 'चुनी हुई चर्चाएँ फिर से लोड करें';

  @override
  String get mrSuggestionsReloadProgress => 'चुनी हुई चर्चाएँ लोड हो रही हैं…';

  @override
  String get mrSuggestionsReloadError =>
      'सभी चर्चाएँ लोड नहीं हो सकीं। लागू करने से पहले फिर से लोड करें।';

  @override
  String get mrSuggestionsApplyForbidden =>
      'GitLab ने इस कार्रवाई को अस्वीकार किया। अपनी पहुँच जाँचें और फिर कोशिश करने से पहले सभी चुनी हुई चर्चाएँ फिर से लोड करें।';

  @override
  String get mrSuggestionsBackButton => 'चयन पर वापस जाएँ';

  @override
  String mrDiscussionContextRangeLabel(String start, String end) {
    return 'टिप्पणी वाली पंक्तियाँ $start–$end';
  }

  @override
  String get mrDiscussionContextRangeLineLabel => 'टिप्पणी की सीमा में पंक्ति';

  @override
  String get mrDiffSelectRangeButton => 'सीमा चुनें';

  @override
  String get mrDiffRangeEndButton => 'इस पंक्ति पर सीमा समाप्त करें';

  @override
  String get mrDiffRangeChooseEnd =>
      'इस फ़ाइल में अंतिम पंक्ति चुनें। पहली पंक्ति के बाद केवल पूरी सीमाएँ उपलब्ध हैं।';

  @override
  String get mrDiffSingleLineButton => 'एक पंक्ति का उपयोग करें';

  @override
  String mrDiffSelectedRangeLabel(String start, String end) {
    return 'चुनी गई सीमा: $start से $end';
  }

  @override
  String get mrDiffSelectedLineLabel => 'चर्चा के लिए चुनी गई पंक्ति';

  @override
  String get mrPendingReviewTitle => 'आपकी अप्रकाशित समीक्षा';

  @override
  String get mrPendingReviewPrivate =>
      'प्रकाशित करने से पहले ये नोट केवल आप देख सकते हैं।';

  @override
  String get mrPendingReviewLoading => 'अप्रकाशित समीक्षा नोट लोड हो रहे हैं…';

  @override
  String get mrPendingReviewEmpty => 'आपके कोई अप्रकाशित समीक्षा नोट नहीं हैं।';

  @override
  String get mrPendingReviewError =>
      'अप्रकाशित समीक्षा नोट लोड नहीं हो सके। सूची फिर से लोड करने के लिए पुनः प्रयास करें।';

  @override
  String get mrPendingReviewRefresh => 'अप्रकाशित समीक्षा नोट रीफ़्रेश करें';

  @override
  String get mrPendingReviewLoadMore => 'और नोट लोड करें';

  @override
  String get mrPendingReviewMore =>
      'और नोट उपलब्ध हैं। जारी रखने के लिए अगला पृष्ठ लोड करें।';

  @override
  String mrPendingReviewCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString नोट लोड हुए';
  }

  @override
  String get mrPendingReviewGeneralNote => 'सामान्य नोट';

  @override
  String get mrPendingReviewReplyNote => 'चर्चा का उत्तर';

  @override
  String get mrPendingReviewCommitNote => 'कमिट नोट';

  @override
  String get mrPendingReviewTextNote => 'डिफ़ नोट';

  @override
  String get mrPendingReviewMultilineNote => 'कई पंक्तियों का डिफ़ नोट';

  @override
  String get mrPendingReviewImageNote => 'चित्र नोट';

  @override
  String get mrPendingReviewFileNote => 'फ़ाइल नोट';

  @override
  String get mrPendingReviewPositionedNote => 'स्थान वाला नोट';

  @override
  String get mrPendingReviewResolve => 'प्रकाशित होने पर चर्चा हल होगी';

  @override
  String mrPendingReviewOldPath(String path) {
    return 'पहले: $path';
  }

  @override
  String mrPendingReviewNewPath(String path) {
    return 'बाद में: $path';
  }

  @override
  String mrPendingReviewOldLine(String line) {
    return 'पुरानी पंक्ति $line';
  }

  @override
  String mrPendingReviewNewLine(String line) {
    return 'नई पंक्ति $line';
  }

  @override
  String mrPendingReviewCommit(String sha) {
    return 'कमिट: $sha';
  }

  @override
  String get mrPendingComposeOpen => 'समीक्षा नोट जोड़ें';

  @override
  String get mrPendingComposeTitle => 'नया समीक्षा नोट';

  @override
  String get mrPendingComposeLabel => 'समीक्षा नोट';

  @override
  String get mrPendingComposeHint =>
      'समीक्षा प्रकाशित करने तक यह नोट केवल आपको दिखाई देगा।';

  @override
  String get mrPendingComposeSave => 'अप्रकाशित नोट सहेजें';

  @override
  String get mrPendingComposeSaved =>
      'नोट आपकी अप्रकाशित समीक्षा में सहेज दिया गया।';

  @override
  String get mrPendingComposeSaving => 'समीक्षा नोट सहेजा जा रहा है…';

  @override
  String get mrPendingComposePrepare => 'समीक्षा नोट तैयार किए जा रहे हैं…';

  @override
  String get mrPendingComposePrepareError =>
      'समीक्षा नोट उपलब्ध नहीं हैं। आपका लिखा पाठ सुरक्षित है।';

  @override
  String get mrPendingComposeSaveError =>
      'इस बार सहेजे जाने की पुष्टि नहीं हुई। आपका लिखा पाठ सुरक्षित है।';

  @override
  String get mrPendingComposeUncertain =>
      'आपका नोट पहले ही सहेजा गया हो सकता है। दोबारा सहेजने से पहले अपनी अप्रकाशित समीक्षा जाँचें।';

  @override
  String get mrPendingComposeInspect => 'अप्रकाशित समीक्षा जाँचें';

  @override
  String get mrPendingComposeInspecting =>
      'सभी अप्रकाशित समीक्षा नोट जाँचे जा रहे हैं…';

  @override
  String get mrPendingComposeInspectError =>
      'अप्रकाशित समीक्षा नहीं जाँची जा सकी। आपका लिखा पाठ सुरक्षित है।';

  @override
  String get mrPendingComposeInspectionTitle => 'वर्तमान अप्रकाशित समीक्षा';

  @override
  String get mrPendingComposeInspectionHint =>
      'ये आपके वर्तमान सहेजे गए नोट हैं। समान पाठ से यह पता नहीं चलता कि किस अनुरोध ने नोट बनाया।';

  @override
  String get mrPendingComposeAcknowledge =>
      'मैंने ये नोट जाँच लिए हैं और एक और नोट सहेजना चाहता हूँ।';

  @override
  String get mrPendingComposeChanged =>
      'समीक्षा सत्र बदल गया है। यह संवाद बंद करके फिर से शुरू करें।';
}
