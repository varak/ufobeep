// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'यूएफओबीप';

  @override
  String get ok => 'ठीक';

  @override
  String get cancel => 'रद्द करना';

  @override
  String get close => 'बंद';

  @override
  String get save => 'सहेजें';

  @override
  String get delete => 'डिलीट';

  @override
  String get edit => 'संपादित करें';

  @override
  String get retry => 'Retry';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get back => 'वापस';

  @override
  String get next => 'अगला';

  @override
  String get done => 'दान';

  @override
  String get loading => 'लोड ..';

  @override
  String get processing => 'प्रसंस्करण..';

  @override
  String get errorGeneric => 'कुछ गलत हो गया।.';

  @override
  String get networkError => 'नेटवर्क त्रुटि। अपने कनेक्शन की जाँच करें।.';

  @override
  String get permissionsRequired => 'अनुमति की आवश्यकता';

  @override
  String get learnMore => 'अधिक जानें';

  @override
  String get welcomeTitle => 'UFOBeep में आपका स्वागत है';

  @override
  String get welcomeSubtitle => 'रियल टाइम यूएफओ आपके पास अलर्ट करता है';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get continueAsGuest => 'पढ़ना';

  @override
  String get enterUsername => 'उपयोगकर्ता नाम दर्ज करें';

  @override
  String get username => 'उपयोगकर्ता नाम';

  @override
  String get usernameUpdated => 'उपयोगकर्ता नाम अद्यतन';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get settings => 'सेटिंग';

  @override
  String get tabAlerts => 'चेतावनी';

  @override
  String get tabBeep => 'बीप';

  @override
  String get tabChat => 'चैट';

  @override
  String get tabMap => 'नक्शा';

  @override
  String get tabSettings => 'सेटिंग';

  @override
  String get alertsTitle => 'निकट अलर्ट';

  @override
  String get noAlerts => 'अभी तक कोई अलर्ट नहीं है।.';

  @override
  String get pullToRefresh => 'ताज़ा करने के लिए खींचें';

  @override
  String alertDistance(String distance) {
    return '0_____________________________________________________________________________________________________________________________';
  }

  @override
  String alertDirection(int bearing) {
    return 'असर $bearing°';
  }

  @override
  String get viewAlert => 'चेतावनी देखें';

  @override
  String get viewOnMap => 'मानचित्र पर देखें';

  @override
  String get iSeeItToo => 'मैं इसे भी देखता हूँ';

  @override
  String get confirmWitnessed => 'क्या आप इस बात की पुष्टि करते हैं?';

  @override
  String get witnessConfirmed => 'धन्यवाद - आपकी पुष्टि पोस्ट की गई थी।.';

  @override
  String get createBeepTitle => 'एक Beep भेजें';

  @override
  String get beepExplain =>
      'क्या आप देखते हैं और आसपास के दर्शकों को चेतावनी देते हैं।.';

  @override
  String get capturePhoto => 'कैप्चर फोटो';

  @override
  String get captureVideo => 'कैप्चर वीडियो';

  @override
  String get pickFromGallery => 'गैलरी से चुनें';

  @override
  String get descriptionHint => 'क्या आप आकाश में देख रहे हैं';

  @override
  String get submitBeep => 'बीप';

  @override
  String get beepSent => 'बीप भेजा';

  @override
  String beepSentWithUrl(String shortUrl) {
    return 'बीप सफलतापूर्वक भेजा गया';
  }

  @override
  String get uploadingMedia => 'मीडिया अपलोड करना';

  @override
  String get includeLocation => 'स्थान शामिल करें';

  @override
  String get includeTimestamp => 'टाइमस्टैम्प शामिल करें';

  @override
  String get beepFailed => 'बीप भेजने में विफल रहा।.';

  @override
  String get mediaProcessing => 'प्रसंस्करण मीडिया..';

  @override
  String get cameraPermissionTitle => 'कैमरा एक्सेस की जरूरत';

  @override
  String get cameraPermissionBody =>
      'UFO फ़ोटो और वीडियो पर कब्जा करने के लिए कैमरा का उपयोग करें।.';

  @override
  String get locationPermissionTitle => 'स्थान अनुमति आवश्यक';

  @override
  String get locationPermissionBody =>
      'हम पास के अलर्ट भेजने और प्राप्त करने के लिए अपने स्थान का उपयोग करते हैं।.';

  @override
  String get microphonePermissionTitle => 'माइक्रोफोन पहुँच की जरूरत';

  @override
  String get microphonePermissionBody =>
      'ऑडियो के साथ वीडियो कैप्चर के लिए माइक्रोफोन एक्सेस प्रदान करें।.';

  @override
  String get openSettings => 'ओपन सेटिंग्स';

  @override
  String get alertDetailTitle => 'Sighting Details';

  @override
  String reportedBy(String username) {
    return 'द्वारा रिपोर्ट किया गया _PLACEHOLDER_0_';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'रिपोर्ट $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '_';
  }

  @override
  String bearingToObject(int bearing) {
    return 'ऑब्जेक्ट करने के लिए असर: __PLACEHOLDER_0_°';
  }

  @override
  String get openCompass => 'ओपन कम्पास';

  @override
  String get openAR => 'ओपन एआर ओवरले';

  @override
  String get openChat => 'ओपन चैट';

  @override
  String get commentsTitle => 'टिप्पणियाँ';

  @override
  String get addComment => 'एक टिप्पणी जोड़ें..';

  @override
  String get send => 'भेजें';

  @override
  String get commentPosted => 'पोस्ट';

  @override
  String get autoFollowEnabled => 'अब आप इस चेतावनी का पालन कर रहे हैं।.';

  @override
  String get noCommentsYet =>
      'अभी तक कोई टिप्पणी नहीं। टिप्पणी करने वाले पहले व्यक्ति बनें!';

  @override
  String get newCommentNotification => 'नई टिप्पणी आप का पालन करते हैं।.';

  @override
  String get mapTitle => 'लाइव मानचित्र';

  @override
  String get compassTitle => 'कम्पास';

  @override
  String get compassSettings => 'Compass सेटिंग्स';

  @override
  String get compassMode => 'कम्पास मोड';

  @override
  String get compassStandardMode => 'मानक मोड';

  @override
  String get compassPilotMode => 'पायलट मोड';

  @override
  String get compassStandardDescription => 'बुनियादी शीर्षक और नेविगेशन';

  @override
  String get compassPilotDescription => 'ETA और वेक्टर के साथ उन्नत नेविगेशन';

  @override
  String pointingTo(String direction) {
    return 'पॉइंट टू __PLACEHOLDER_0_';
  }

  @override
  String get calibratingCompass => 'Calibrating compass ..';

  @override
  String get openAROverlay => 'ओपन एआर ओवरले';

  @override
  String get pushTitleAlertNearby => 'आपके पास यूएफओ अलर्ट';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'एक नए दर्शन की सूचना मिली थी ${distance}_______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________.';
  }

  @override
  String get pushTitleComment => 'नई टिप्पणी';

  @override
  String get pushBodyComment => 'किसी ने आप का पालन करते हुए देखा।.';

  @override
  String get pushTitleWitness => 'गवाह पुष्टि';

  @override
  String get temperature => 'तापमान';

  @override
  String get pushBodyWitness =>
      'एक उपयोगकर्ता ने पुष्टि की कि वे उसी वस्तु को देखते हैं।.';

  @override
  String get weather => 'मौसम';

  @override
  String cloudCover(int percent) {
    return 'क्लाउड कवर: 0 _ 0';
  }

  @override
  String wind(num speed, String unit) {
    return 'पवन: ${speed}_${unit}_';
  }

  @override
  String get nearbyAircraft => 'निकटवर्ती विमान';

  @override
  String get noAircraft => 'पास में कोई विमान नहीं';

  @override
  String get loadingContext => 'पर्यावरण संदर्भ लोड हो रहा है ..';

  @override
  String get settingsTitle => 'सेटिंग';

  @override
  String get notifications => 'अधिसूचनाएं';

  @override
  String get enablePushNotifications =>
      'भविष्य की टिप्पणियों के लिए अधिसूचनाएं प्राप्त करें';

  @override
  String get quietHours => 'चुप घंटे';

  @override
  String get quietHoursDesc => 'चयनित घंटों के बीच मौन अलर्ट।.';

  @override
  String get quietHoursEnabled => 'शांत घंटे';

  @override
  String get quietHoursFrom => 'से';

  @override
  String get quietHoursUntil => 'जब तक';

  @override
  String get quietHoursDefaultTime => 'डिफ़ॉल्ट शांत घंटे';

  @override
  String get emergencyOverride => 'आपातकालीन ओवरराइड';

  @override
  String get emergencyOverrideDesc =>
      'शांत घंटों के दौरान तत्काल अलर्ट की अनुमति दें';

  @override
  String get dndMode => 'Disturb';

  @override
  String get dndUntil => 'जब तक परेशान न हों';

  @override
  String dndEnabled(Object time) {
    return 'डीएनडी ने $time';
  }

  @override
  String get dndDisabled => 'DND विकलांग';

  @override
  String get quietHoursActive => 'शांत घंटे सक्रिय';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'शांत समय: _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _';
  }

  @override
  String get pushNotificationUfoAlert => 'यूएफओ चेतावनी';

  @override
  String get pushNotificationAnomalyAlert => 'Anomaly चेतावनी';

  @override
  String get pushNotificationNearby => 'नजदीक';

  @override
  String get pushNotificationInYourArea =>
      'अपने क्षेत्र में। विवरण देखने के लिए टैप करें।.';

  @override
  String pushNotificationCommented(Object username) {
    return '${username}_________________________________________________________________________________________________________________________________';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '${username}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get pushNotificationGeneric => 'यूएफओबीप';

  @override
  String get pushNotificationNewSighting => 'पास में नया दर्शन';

  @override
  String get language => 'भाषा';

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get units => 'यूनिट';

  @override
  String get unitsImperial => 'इंपीरियल (mi, mph)';

  @override
  String get unitsMetric => 'मीट्रिक (किमी, km/h)';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get termsOfUse => 'उपयोग की शर्तें';

  @override
  String get errorNoLocation =>
      'स्थान अनुपलब्ध फिर से स्पष्ट आकाश दृश्य के साथ बाहर की कोशिश करें।.';

  @override
  String get errorNoCamera => 'इस उपकरण पर कैमरा अनुपलब्ध है।.';

  @override
  String get errorUploadFailed => 'अपलोड विफल रहा। फिर से प्रयास करें।.';

  @override
  String get errorPermissionDenied => 'अनुमति से इनकार कर दिया।.';

  @override
  String get errorInvalidUsername => 'यह उपयोगकर्ता नाम उपलब्ध नहीं है।.';

  @override
  String get nothingToShow => 'अभी तक दिखाने के लिए कुछ नहीं है।.';

  @override
  String get storeShortDesc =>
      'तत्काल यूएफओ आपके पास अलर्ट करता है। वास्तविक समय में कैप्चर, पुष्टि और चैट करें।.';

  @override
  String get storeLongDesc =>
      'UFOBeep वास्तविक समय अलर्ट भेजता है जब कोई UFO पास रखता है। फ़ोटो और वीडियो कैप्चर करें, एक टैप के साथ दृश्यों की पुष्टि करें, दिशा और दूरी देखें, और साथी स्काईवॉकर्स के साथ चैट करें।.';

  @override
  String get keywords =>
      'यूएफओ, यूएपी, ओवीएनआई, एलियंस, दर्शन, स्काईवॉच, एलर्ट्स, रडार,कम्पास';

  @override
  String get noAlertsFound => 'कोई मेलिंग अलर्ट नहीं';

  @override
  String get alertsFilterHelp =>
      'अधिक परिणाम देखने के लिए अपने फिल्टर को समायोजित करने की कोशिश करें';

  @override
  String get verified => 'सत्यापित';

  @override
  String get beepOnly => 'केवल बीप';

  @override
  String get reportOnly => 'केवल पाठ';

  @override
  String get videoOnly => 'केवल वीडियो';

  @override
  String get imageOnly => 'केवल छवि';

  @override
  String get mediaOnly => 'केवल मीडिया';

  @override
  String get timeJustNow => 'अभी';

  @override
  String timeDaysAgo(int count) {
    return '${count}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String timeMinutesAgo(int count) {
    return '0_0_0_0_0 मिनट पहले';
  }

  @override
  String get loadMoreAlerts => 'लोड अधिक अलर्ट';

  @override
  String get toggleMufonTooltip => 'टॉगल MUFON sighting';

  @override
  String get showMufonData => 'MUFON डेटा दिखाएं';

  @override
  String get hideMufonData => 'MUFON डेटा छुपाएं';

  @override
  String get showingUfoBeepOnly => 'केवल UFOBeep रिपोर्ट दिखा रहा है';

  @override
  String get showingAllReports => 'MUFON डेटाबेस सहित सभी रिपोर्ट दिखा रहा है';

  @override
  String get filteredSuffix => 'फ़िल्टर';

  @override
  String get detailsTitle => 'विवरण';

  @override
  String get mufonCase => 'MUFON मामला';

  @override
  String get mufonSighting => 'MUFON Sighting Report';

  @override
  String get mufonLightSighting => 'MUFON लाइट Sighting रिपोर्ट';

  @override
  String get mufonSphereSighting => 'MUFON Sphere Sighting Report';

  @override
  String get mufonDiscSighting => 'MUFON डिस्क Sighting रिपोर्ट';

  @override
  String get mufonTriangleSighting => 'MUFON त्रिभुज दृष्टि रिपोर्ट';

  @override
  String get mufonCigarSighting => 'MUFON Cigar Sighting Report';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting Report';

  @override
  String get mufonRectangleSighting => 'MUFON आयत दृष्टि रिपोर्ट';

  @override
  String get mufonCylinderSighting => 'MUFON सिलेंडर दृष्टि रिपोर्ट';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Sighting Report';

  @override
  String get mufonStarlikeSighting => 'MUFON स्टारलाइक साइटिंग रिपोर्ट';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Case #_PLACEHOLDER_0__ Details';
  }

  @override
  String get sightingDate => 'दर्शन तिथि';

  @override
  String get mufonDatabaseEntryDate => 'तारीख MUFON में प्रवेश किया डेटाबेस';

  @override
  String get databaseEntry => 'डेटाबेस प्रविष्टि';

  @override
  String get shareLink => 'शेयर लिंक';

  @override
  String get linkCopied => 'लिंक क्लिपबोर्ड पर कॉपी';

  @override
  String get locationLabel => 'स्थान:';

  @override
  String get distanceLabel => 'दूरी';

  @override
  String get timeLabel => 'समय:';

  @override
  String get reportedByLabel => 'रिपोर्ट द्वारा';

  @override
  String get unknownLocation => 'अज्ञात स्थान';

  @override
  String get locationUnknown => 'अज्ञात';

  @override
  String get witnessesLabel => 'गवाही';

  @override
  String witnessesCountMessage(int count) {
    return '${count}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get photoAnalysisTitle => 'फोटो विश्लेषण';

  @override
  String mediaItemsProcessed(int count) {
    return 'विश्लेषण: $count मीडिया फ़ाइल (s) संसाधित';
  }

  @override
  String get addMoreMedia => 'अधिक जानिए';

  @override
  String get addMedia => 'मीडिया जोड़ें';

  @override
  String get retakePhoto => 'फोटो';

  @override
  String get retakeVideo => 'वीडियो';

  @override
  String get camera => 'कैमरा';

  @override
  String get gallery => 'गैलरी';

  @override
  String get basicSettings => 'मूल सेटिंग';

  @override
  String get appSettings => 'ऐप सेटिंग';

  @override
  String get timeFormat => 'समय स्वरूप';

  @override
  String get timeFormat24Hour => '24 घंटे (14:30)';

  @override
  String get timeFormat12Hour => '12 घंटे (2:30 अपराह्न)';

  @override
  String get timeFormatDesc =>
      '24 घंटे या 12 घंटे के प्रारूप में समय प्रदर्शित करें';

  @override
  String get alertRange => 'चेतावनी रेंज';

  @override
  String get manageNotificationsDesc => 'सदस्यता और सेटिंग्स प्रबंधित करें';

  @override
  String get permissionsTitle => 'अनुमतियां';

  @override
  String get permissionLocation => 'स्थान';

  @override
  String get permissionCamera => 'कैमरा';

  @override
  String get permissionNotifications => 'अधिसूचनाएं';

  @override
  String get permissionPhotos => 'तस्वीरें';

  @override
  String get permissionGranted => 'अनुदान';

  @override
  String get permissionNotGranted => 'नहीं देना';

  @override
  String get permissionGrant => 'अनुदान';

  @override
  String get generateUsername => 'नया उपयोगकर्ता नाम जेनरेट करें';

  @override
  String get adminTools => 'व्यवस्थापक उपकरण';

  @override
  String get openAdminPanel => 'ओपन एडमिन पैनल';

  @override
  String get webAdminInterface => 'वेब व्यवस्थापक इंटरफ़ेस';

  @override
  String get adminBetaNotice =>
      'बीटा केवल बनाता है। निकटता अलर्ट, पुश नोटिफिकेशन और सिस्टम निदान के परीक्षण के लिए व्यवस्थापक उपकरण।.';

  @override
  String get whatDoYouSee => 'आप क्या देखते हैं?';

  @override
  String get ufo => 'यूएफओ';

  @override
  String get sighting => 'दृष्टि';

  @override
  String get ufoSighting => 'UFOBep चेतावनी';

  @override
  String get envAnalysisTitle => 'पर्यावरणीय विश्लेषण';

  @override
  String get envAnalysisPending => 'विश्लेषण लंबित';

  @override
  String get envAnalysisPendingDesc =>
      'प्रक्रिया शुरू होने के बाद पर्यावरण डेटा उपलब्ध होगा।.';

  @override
  String get unknownAircraft => 'अज्ञात विमान';

  @override
  String get moreAircraft => 'विमान';

  @override
  String get showLess => 'कम दिखाएं';

  @override
  String get premiumImageryTitle => 'प्रीमियम सैटेलाइट इमेजरी';

  @override
  String get premiumImagerySubtitle => 'उच्च संकल्प वाणिज्यिक imagery';

  @override
  String get sightingTypeLabel => 'प्रकार';

  @override
  String get ufoTypeSphere => 'क्षेत्र';

  @override
  String get ufoTypeTriangle => 'त्रिभुज';

  @override
  String get ufoTypeDisk => 'डिस्क';

  @override
  String get ufoTypeLight => 'प्रकाश';

  @override
  String get ufoTypeFireball => 'फायरबॉल';

  @override
  String get ufoTypeCylinder => 'सिलेंडर';

  @override
  String get ufoTypeCigar => 'सिगार';

  @override
  String get ufoTypeRectangle => 'आयत';

  @override
  String get ufoTypeFormation => 'गठन';

  @override
  String get ufoTypeUnknown => 'अज्ञात';

  @override
  String get ufoTypeBoomerang => 'बुमेरांग';

  @override
  String get ufoTypeDiamond => 'हीरा';

  @override
  String get ufoTypeOval => 'ओवल';

  @override
  String get ufoTypeCone => 'शंकु';

  @override
  String get ufoTypeCross => 'क्रॉस';

  @override
  String get ufoTypeDumbbell => 'डंबल';

  @override
  String get ufoTypeTeardrop => 'टियरड्रॉप';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'बुलेट';

  @override
  String get ufoTypeSaturn => 'शनि';

  @override
  String get ufoTypeStarLike => 'स्टार लाइक';

  @override
  String get ufoTypeBlimp => 'ब्लींप';

  @override
  String get shapeTriangle => 'त्रिभुज';

  @override
  String get shapeDisc => 'डिस्क';

  @override
  String get shapeDisk => 'डिस्क';

  @override
  String get shapeSphere => 'क्षेत्र';

  @override
  String get shapeCigar => 'सिगार';

  @override
  String get shapeLight => 'प्रकाश';

  @override
  String get shapeBoomerang => 'बूमरंग';

  @override
  String get shapeDiamond => 'हीरा';

  @override
  String get shapeRectangle => 'आयत';

  @override
  String get shapeOval => 'अंडाकार';

  @override
  String get shapeCone => 'शंकु';

  @override
  String get shapeCross => 'पार';

  @override
  String get shapeCylinder => 'सिलेंडर';

  @override
  String get shapeDumbbell => 'डम्बल';

  @override
  String get shapeTeardrop => 'टट्टू';

  @override
  String get shapeTicTac => 'टिक टीएसी';

  @override
  String get shapeBullet => 'बुलेट';

  @override
  String get shapeSaturn => 'शनि';

  @override
  String get shapeStarlike => 'स्टारलाइक';

  @override
  String get shapeBlimp => 'ब्लींप';

  @override
  String get shapeFireball => 'फायरबॉल';

  @override
  String get shapeFormation => 'संरचना';

  @override
  String get shapeUnknown => 'अज्ञात';

  @override
  String get actionsTitle => 'कार्य';

  @override
  String get addPhotosAndVideos => 'फ़ोटो और वीडियो जोड़ें';

  @override
  String get howToReportToMufon => 'कैसे रिपोर्ट करने के लिए MUFON';

  @override
  String get reportToMufon => 'MUFON की रिपोर्ट';

  @override
  String get whyReportToMufon => 'क्यों रिपोर्ट करने के लिए MUFON?';

  @override
  String get openMufonReport => 'ओपन MUFON रिपोर्ट';

  @override
  String get confirmedWitness => 'आपने इस दर्शन की पुष्टि की';

  @override
  String witnessesHaveConfirmed(int count) {
    return '${count}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get aircraftTrackingTitle => 'विमान ट्रैकिंग';

  @override
  String get weatherConditionsTitle => 'मौसम की स्थिति';

  @override
  String get noSatellitePasses => 'कोई दृश्य उपग्रह नहीं मिला';

  @override
  String get contentAnalysisTitle => 'सामग्री विश्लेषण';

  @override
  String get contentSafe => 'सामग्री सुरक्षित है';

  @override
  String get contentFlagged => 'समीक्षा के लिए सामग्री ध्वजांकित';

  @override
  String get confidenceLabel => 'गोपनीयता';

  @override
  String get methodLabel => 'विधि';

  @override
  String get premiumImageryAccessOnly =>
      'प्रीमियम उपग्रह इमेजरी केवल उपलब्ध है:';

  @override
  String get premiumAccessCreators => 'चेतावनी निर्माता';

  @override
  String get premiumAccessWitnesses =>
      'दृश्यता रेंज के भीतर गवाहों की पुष्टि की';

  @override
  String get comingSoon => 'सोन';

  @override
  String get directionDistanceTitle => 'दिशा और दूरी';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON केस #$caseNumber';
  }

  @override
  String get satellitePassesTitle => 'सैटेलाइट पास';

  @override
  String get satellitePassExplanation =>
      'दर्शनीय समय सीमा के दौरान दर्शनीय उपग्रह गुजरता है। कई यूएफओ रिपोर्ट वास्तव में उपग्रह या अंतरिक्ष मलबे हैं।.';

  @override
  String get followingAlert =>
      'चेतावनी के बाद - आपको टिप्पणी नोटिफिकेशन मिलेगी';

  @override
  String get unfollowedAlert => 'अनफॉल्ड अलर्ट - कोई टिप्पणी नोटिफिकेशन नहीं';

  @override
  String get alertFollowError => 'स्थिति का पालन करने में त्रुटि';

  @override
  String get notificationChannelAlerts => 'यूएफओबीप अलर्ट';

  @override
  String get notificationChannelAlertsDesc =>
      'यूएफओ बीप और निकटता अलर्ट के लिए अधिसूचनाएं';

  @override
  String get notificationSightingTitle => 'UFOBep चेतावनी';

  @override
  String get notificationSightingUrgent => 'UFOBep UFO चेतावनी';

  @override
  String get notificationSightingEmergency => 'EMERGENCY UFOBeep UFO चेतावनी';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '${witnessText}________________________________________________________________________________________________________________________________________';
  }

  @override
  String notificationCommentTitle(String username) {
    return 'One who has been commented by the post of the post';
  }

  @override
  String get notificationWitnessText => 'नया दर्शन';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '${count}_ गवाह';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Dismis';

  @override
  String notificationDistance(String distance) {
    return '0_____________________________________________________________________________________________________________________________';
  }

  @override
  String get unknown => 'अज्ञात';

  @override
  String get report => 'रिपोर्ट';

  @override
  String get mufon => 'mufon';

  @override
  String get recentUfoBeepsTitle => 'यूएफओ बीप';

  @override
  String get recentUfoBeepsSubtitle =>
      'हमारे वैश्विक समुदाय से लाइव यूएफओ दर्शन रिपोर्ट';

  @override
  String get recentUfoBeepsDescription =>
      'यह फ़ीड हमारे मोबाइल ऐप उपयोगकर्ताओं से वास्तविक समय के UFOBeep \"beeps\" को जोड़ती है जिसमें MUFON डेटाबेस से ऐतिहासिक रिपोर्ट होती है।.';

  @override
  String get loadingBeeps => 'हाल ही में बीप लोड हो रहा है...';

  @override
  String get noBeepsAvailable => 'वर्तमान में उपलब्ध नहीं है।.';

  @override
  String get anomalyReported => 'Anomaly रिपोर्ट';

  @override
  String get copyShortLink => 'लघु लिंक कॉपी करें';

  @override
  String get shareAlert => 'शेयर अलर्ट';

  @override
  String get ufoSightingAlert => 'यूएफओ दृष्टि चेतावनी';

  @override
  String get previousPage => 'पिछला';

  @override
  String get nextPage => 'अगला';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'पृष्ठ ${currentPage}__${totalCount}________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get firstPage => 'पहला';

  @override
  String get lastPage => 'अंतिम';

  @override
  String get jumpToPage => 'पृष्ठ पर जाएं';

  @override
  String get heroTagline => 'बाहर जाने और देखने के लिए अलर्ट प्राप्त करें';

  @override
  String get heroDescription =>
      'कभी भी अपने क्षेत्र में किसी अन्य यूएफओ दर्शन को याद न करें';

  @override
  String get downloadApp => 'App डाउनलोड';

  @override
  String get viewAllBeeps => 'All Beeps';

  @override
  String get sightingsMap => 'Sightings Map';

  @override
  String get globalSightingNetwork => 'वैश्विक दृष्टि नेटवर्क';

  @override
  String get howItWorks => 'यह कैसे काम करता है';

  @override
  String get backToBeeps => 'बैक टू बीप';

  @override
  String get loadingDetails => 'बीप विवरण लोड हो रहा है...';

  @override
  String get details => 'विवरण';

  @override
  String get location => 'स्थान';

  @override
  String get timeAgo => 'पहले';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'किमी';

  @override
  String get distanceMiles => 'मील';

  @override
  String get distanceNearby => 'पास';

  @override
  String get ufobeepWitnesses => 'गवाही';

  @override
  String get ufobeepConfirmations => 'पुष्टिकरण';

  @override
  String get ufobeepAlertLevel => 'चेतावनी स्तर';

  @override
  String get ufobeepReportType => 'UFOBeep Report';

  @override
  String get mufonAttribution => 'MUFON डेटाबेस रिपोर्ट';

  @override
  String get mufonCaseNumber => 'केस #';

  @override
  String get mufonGenericTitle => 'MUFON Sighting Report';

  @override
  String get mufonSphere => 'क्षेत्र';

  @override
  String get mufonLight => 'प्रकाश';

  @override
  String get mufonDisk => 'डिस्क';

  @override
  String get mufonTriangle => 'त्रिभुज';

  @override
  String get mufonCigar => 'सिगार';

  @override
  String get mufonOval => 'ओवल';

  @override
  String get mufonCylinder => 'सिलेंडर';

  @override
  String get mufonRectangle => 'आयत';

  @override
  String get mufonDiamond => 'हीरा';

  @override
  String get mufonFireball => 'फायरबॉल';

  @override
  String get mufonFlash => 'फ्लैश';

  @override
  String get mufonFormation => 'गठन';

  @override
  String get mufonChanging => 'बदलना';

  @override
  String get mufonChevron => 'शेवरॉन';

  @override
  String get mufonCone => 'शंकु';

  @override
  String get mufonCross => 'क्रॉस';

  @override
  String get mufonEgg => 'अंडा';

  @override
  String get mufonOther => 'वस्तु';

  @override
  String get mufonUnknown => 'अज्ञात वस्तु';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON $classification रिपोर्ट';
  }

  @override
  String get nuforcAttribution => 'NUFORC डेटाबेस रिपोर्ट';

  @override
  String get nuforcCaseNumber => 'केस #';

  @override
  String get nuforcGenericTitle => 'NUFORC Sighting Report';

  @override
  String get mediaImageNotFound => 'छवि नहीं मिली';

  @override
  String get mediaPlayVideo => 'वीडियो';

  @override
  String get mediaViewImage => 'छवि देखें';

  @override
  String mediaCount(Object count) {
    return '0 _ 0';
  }

  @override
  String get mediaCountSingle => '1 छवि';

  @override
  String mediaMoreImages(Object count) {
    return '+_PLACEHOLDER_0_______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get errorNotFound => 'बीप नहीं मिला';

  @override
  String get errorLoadError => 'बीप विवरण लोड करने में विफल';

  @override
  String get shareYourThoughts =>
      'इस विचार के बारे में अपने विचारों को साझा करें ...';

  @override
  String get postComment => 'पोस्ट';

  @override
  String get loggedInAs => 'लॉग इन';

  @override
  String get logout => 'लॉग-इन';

  @override
  String get notFollowing => 'निम्नलिखित नहीं है';

  @override
  String get follow => 'पालन करना';

  @override
  String get navRecentBeeps => 'हाल ही में बीप';

  @override
  String get navMap => 'नक्शा';

  @override
  String get navDownloadApp => 'ऐप डाउनलोड करें';

  @override
  String get alertLevel => 'चेतावनी स्तर';

  @override
  String get witnesses => 'गवाही';

  @override
  String get confirmations => 'पुष्टिकरण';

  @override
  String get reporterLabel => 'उपयोगकर्ता द्वारा रिपोर्ट';

  @override
  String get coordinatesLabel => 'निर्देशांक';

  @override
  String get eventTime => 'घटना समय';

  @override
  String get reportedTime => 'रिपोर्ट समय';

  @override
  String get addedToUfobeep => 'UFOBeep में जोड़ा गया';

  @override
  String get mufonDatabaseReport => 'MUFON प्रकरण संख्या:';

  @override
  String get copyShortLinkTitle => 'क्लिपबोर्ड के लिए लिंक कॉपी करें';

  @override
  String get imageNotFound => 'छवि नहीं मिली';

  @override
  String get ufoSightingAlt => 'यूएफओ बीप यूएफओ चेतावनी';

  @override
  String get celestialDataTitle => 'Celestial ऑब्जेक्ट';

  @override
  String get visiblePlanets => 'दर्शनीय ग्रह';

  @override
  String get locationDataTitle => 'स्थान सूचना';

  @override
  String get timezone => 'मौसम';

  @override
  String get coordinates => 'निर्देशांक';

  @override
  String get processingSummaryTitle => 'प्रसंस्करण सारांश';

  @override
  String get processingTime => 'प्रसंस्करण समय';

  @override
  String get successful => 'सफल';

  @override
  String get failed => 'विफल';

  @override
  String get locationEnrichmentTitle => 'स्थान विवरण';

  @override
  String get aircraftDataSource => 'डेटा स्रोत';

  @override
  String get noAircraftDetected => 'कोई विमान नहीं पाया';

  @override
  String get sightingReport => 'Sighting Report';

  @override
  String get ufoAlert => 'यूएफओ चेतावनी';

  @override
  String get alert => 'चेतावनी';

  @override
  String get notificationTickerUfoAlert => 'यूएफओ अलर्ट';

  @override
  String get notificationTickerComment => 'यूएफओ अलर्ट पर नई टिप्पणी';

  @override
  String get weatherConditions => 'मौसम की स्थिति';

  @override
  String get visibility => 'दृश्यता';

  @override
  String get humidity => 'आर्द्रता';

  @override
  String get pressure => 'दबाव';

  @override
  String get locationDetails => 'स्थान विवरण';

  @override
  String get city => 'शहर';

  @override
  String get state => 'राज्य';

  @override
  String get country => 'देश';

  @override
  String get satelliteActivity => 'उपग्रह गतिविधि';

  @override
  String get satellitesVisibleOverhead =>
      'उपग्रह दृष्टि समय और स्थान पर दिखाई देते हैं';

  @override
  String get dataSource => 'डेटा स्रोत';

  @override
  String get blackskyImagery => 'ब्लैकस्की इमेजरी';

  @override
  String get resolution => 'संकल्प';

  @override
  String get groundResolution => '35 सेमी ग्राउंड रिज़ॉल्यूशन';

  @override
  String get delivery => 'डिलिवरी';

  @override
  String get averageDelivery => '90 मिनट औसत';

  @override
  String get cost => 'लागत';

  @override
  String get skyfiSatelliteImagery => 'स्काईफाई सैटेलाइट इमेजरी';

  @override
  String get region => 'क्षेत्र';

  @override
  String get remoteArea => 'रिमोट एरिया';

  @override
  String get startingPrice => 'मूल्य';

  @override
  String get coverage => 'कवरेज';

  @override
  String get confidenceCoverage => '95% आत्मविश्वास';

  @override
  String get status => 'स्थिति';

  @override
  String get shareThoughts =>
      'इस विचार के बारे में अपने विचारों को साझा करें ...';

  @override
  String get postCommand => 'पोस्ट कमांड';

  @override
  String get clouds => 'क्लाउड';

  @override
  String get windLabel => 'हवा';

  @override
  String get filterAlerts => 'फ़िल्टर अलर्ट';

  @override
  String get alertSource => 'चेतावनी स्रोत';

  @override
  String get ufobeepOnly => 'केवल UFOBeep';

  @override
  String get ufobeepOnlyDescription =>
      'केवल मूल UFOBeep रिपोर्ट (MUFON डेटाबेस को छोड़कर) दिखाएं';

  @override
  String get alertDistanceRange => 'चेतावनी दूरी रेंज';

  @override
  String get showAllAlerts => 'सभी अलर्ट दिखाएं';

  @override
  String get showAll => 'सब दिखाओ';

  @override
  String get distanceSliderDescription =>
      'जब तक आप अलर्ट देखना चाहते हैं, तब तक समायोजित करने के लिए खींचें। दूरी की परवाह किए बिना सभी अलर्ट दिखाने के लिए मौसम दृश्यता दूरी से शुरू करें।.';

  @override
  String get applyFilters => 'फ़िल्टर लागू करें';

  @override
  String get notificationRange => 'अधिसूचना रेंज';

  @override
  String get notificationRangeDescription =>
      'इस दूरी के भीतर दर्शन के लिए पुश अलर्ट प्राप्त करें';

  @override
  String get viewingRange => 'देखने की रेंज';

  @override
  String get viewingRangeDescription =>
      'ब्राउज़ करते समय इस दूरी के भीतर दर्शनों को दिखाएं';

  @override
  String get weatherVisibility => 'मौसम दृश्यता (~10 किमी)';

  @override
  String get localArea => 'स्थानीय क्षेत्र (25 km)';

  @override
  String get regional => 'क्षेत्रीय';

  @override
  String get pushNotifications => 'पुश नोटिफिकेशन';

  @override
  String get alertBrowsing => 'चेतावनी ब्राउज़िंग';

  @override
  String get pushAlertsWithinDistance => 'इस रेंज के भीतर सूचनाएं प्राप्त करें';

  @override
  String get showAlertsWhenBrowsing => 'क्या आप सूची में देखते हैं फ़िल्टर';

  @override
  String get heroMainTagline =>
      'जब UFOs पास में देखा जाता है तो अपने फोन पर एक बीप प्राप्त करें';

  @override
  String get heroSecondaryTagline => 'जब और कहाँ आकाश को देखने के लिए';

  @override
  String get sourceFilters => 'स्रोत';

  @override
  String get sourceFiltersDescription =>
      'अपनी फ़ीड में कौन सी रिपोर्ट दिखाई देती है';

  @override
  String get ufobeepAndMufon => 'UFOBeep + MUFON';

  @override
  String get ufobeepOnlySource => 'केवल UFOBeep';

  @override
  String get mufonOnlySource => 'केवल MUFON';

  @override
  String get browseFilters => 'दृश्य';

  @override
  String get browseFiltersDescription => 'अलर्ट कैसे देखें और सॉर्ट करें';

  @override
  String get sortByNewest => 'नवीनतम';

  @override
  String get sortByNearest => 'निकटतम';

  @override
  String get sortBy => 'द्वारा क्रमबद्ध';

  @override
  String get pushAlertsTitle => 'पुश अलर्ट';

  @override
  String get pushAlertsDescription => 'अपने फोन को क्या पिंग करता है';

  @override
  String get alertRadius => 'चेतावनी त्रिज्या';

  @override
  String get mufonNoPushInfo =>
      'MUFON रिपोर्ट को रात में आयात किया जाता है और पुश अलर्ट को ट्रिगर नहीं करता है';

  @override
  String get privacyData => 'गोपनीयता और डेटा';

  @override
  String get privacyPolicyDesc =>
      'हम आपके डेटा की सुरक्षा और उपयोग कैसे करते हैं';

  @override
  String get termsOfService => 'सेवा की शर्तें';

  @override
  String get termsOfServiceDesc => 'नियम और शर्तें';

  @override
  String get locationTracking => 'स्थान ट्रैकिंग';

  @override
  String get locationTrackingDesc => 'निकटता अलर्ट के लिए पृष्ठभूमि स्थान';

  @override
  String get locationTrackingTitle => 'पृष्ठभूमि स्थान ट्रैकिंग';

  @override
  String get locationTrackingExplanation =>
      'यूएफओबीप पृष्ठभूमि में आपके स्थान की निगरानी करता है ताकि आप निकटता अलर्ट भेज सकें जब यूएफओ दर्शन आपके वर्तमान स्थान के पास हो, भले ही आप घर से दूर हों।.';

  @override
  String get locationTrackingBattery =>
      '<3% बैटरी प्रभाव के लिए बुद्धिमान geofencing का उपयोग करता है';

  @override
  String get backgroundLocationTracking => 'पृष्ठभूमि सक्षम करें ट्रैकिंग';

  @override
  String get locationTrackingActive => 'निकटता अलर्ट के लिए निगरानी स्थान';

  @override
  String get locationTrackingInactive => 'स्थान ट्रैकिंग अक्षम है';

  @override
  String get locationTrackingDisabledWarning =>
      'जब आप नए स्थानों पर जाते हैं तो आपको निकटता अलर्ट नहीं मिलेगा';

  @override
  String get trackingStatus => 'ट्रैकिंग स्थिति';

  @override
  String get monitoringStatus => 'निगरानी';

  @override
  String get active => 'सक्रिय';

  @override
  String get inactive => 'निष्क्रिय';

  @override
  String get lastKnownLocation => 'अंतिम ज्ञात स्थान';

  @override
  String get lastLocationUpdate => 'अंतिम अपडेट';

  @override
  String get movementThreshold => 'आंदोलन थ्रेसहोल्ड';

  @override
  String get updateFrequency => 'अद्यतन आवृत्ति';

  @override
  String get batteryImpact => 'बैटरी प्रभाव';

  @override
  String get dataPrivacy => 'गोपनीयता';

  @override
  String get locationPermissionExplanation =>
      'UFOBeep को अपने आंदोलन की निगरानी के लिए \'Always Allow\' स्थान अनुमति की आवश्यकता होती है और जब आप नए स्थानों में हों तो निकटता अलर्ट भेज सकते हैं।.';

  @override
  String get benefitsTitle => 'लाभ';

  @override
  String get locationTrackingBenefits =>
      '• जहां भी आप यात्रा करते हैं, यूएफओ अलर्ट प्राप्त करें\n• स्वचालित स्थान अद्यतन\n• मैनुअल सेटअप की आवश्यकता नहीं है';

  @override
  String get allowLocationAccess => 'स्थान पहुँच की अनुमति';

  @override
  String get locationPermissionRequired =>
      'पृष्ठभूमि ट्रैकिंग के लिए स्थान अनुमति की आवश्यकता है';

  @override
  String get locationTrackingEnabled => 'पृष्ठभूमि स्थान ट्रैकिंग सक्षम';

  @override
  String get locationTrackingDisabled => 'पृष्ठभूमि स्थान ट्रैकिंग अक्षम';

  @override
  String get justNow => 'अभी';

  @override
  String minutesAgo(int minutes) {
    return '0_0_0_0_0 मिनट पहले';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String daysAgo(int days) {
    return '${days}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get dataManagement => 'डेटा प्रबंधन';

  @override
  String get dataManagementDesc => 'अपने खाता डेटा को निर्यात या हटाएं';

  @override
  String get splashTagline => 'रियल टाइम दर्शन अलर्ट';

  @override
  String get splashStartingUp => 'शुरू करना.';

  @override
  String get splashInitializationFailed => 'आरंभीकरण विफल';

  @override
  String get splashInitializationFailedTitle => 'आरंभीकरण विफल';

  @override
  String get splashInitializationError =>
      'एप्लिकेशन ठीक से शुरू करने में विफल रहा:';

  @override
  String get splashRetry => 'Retry';

  @override
  String get splashContinue => 'जारी';

  @override
  String get splashInitializing => 'शुरू करना.';

  @override
  String signInWelcome(String username) {
    return 'आपका स्वागत है!';
  }

  @override
  String signInFailed(String error) {
    return 'साइन-इन विफल: _ _ _ _ _ _ _ _ _';
  }

  @override
  String get signInPleaseEnterEmail => 'कृपया अपना ईमेल पता दर्ज करें';

  @override
  String get signInPleaseEnterValidEmail => 'कृपया एक वैध ईमेल पता दर्ज करें';

  @override
  String get signInMagicLinkSent =>
      'जादू लिंक भेजा! अपने ईमेल को चेक करें और साइन इन करने के लिए लिंक पर क्लिक करें।.';

  @override
  String get signInMagicLinkFailed =>
      'जादू लिंक भेजने में विफल रहा। फिर से प्रयास करें।.';

  @override
  String get signInAllDataCleared => 'सभी डेटा समाशोधित';

  @override
  String get signInSubtitle =>
      'रियल टाइम यूएफओ दर्शन अलर्ट और एमयूएफएन रिपोर्ट';

  @override
  String get signInGoogleLoading => 'साइन इन करें...';

  @override
  String get signInContinueWithGoogle => 'गूगल के साथ जारी';

  @override
  String get signInOr => 'या';

  @override
  String get signInWithEmail => 'ईमेल के साथ साइन इन करें';

  @override
  String get signInEmailDescription =>
      'हम आपको साइन इन करने के लिए एक सुरक्षित लिंक भेज देंगे';

  @override
  String get signInEmailAddress => 'ईमेल पता';

  @override
  String get signInEmailPlaceholder => 'email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'फिर से कोशिश करो __PLACEHOLDER_0_s';
  }

  @override
  String get signInSending => 'भेजना...';

  @override
  String get signInSendMagicLink => 'जादू लिंक भेजें';

  @override
  String get signInCheckEmail =>
      'अपने ईमेल की जाँच करें! लिंक 15 मिनट में समाप्त हो जाता है।.';

  @override
  String get signInSecureAuth => 'सुरक्षित प्रमाणीकरण';

  @override
  String get signInSecureAuthDescription =>
      'तत्काल पहुंच के लिए Google साइन-इन का उपयोग करें, या ईमेल जादू लिंक जो 15 मिनट में समाप्त हो जाते हैं।.';

  @override
  String get signInClearAllDataDebug => 'सभी डेटा (Debug) साफ़ करें';

  @override
  String get emailAuthFailedToSend => 'ईमेल भेजने में विफल';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'ईमेल भेजने में विफल रहा। फिर से प्रयास करें।.';

  @override
  String get emailAuthInvalidEmail =>
      'अमान्य ईमेल पता। कृपया प्रारूप की जांच करें।.';

  @override
  String get emailAuthUserNotFound => 'इस ईमेल पते के साथ कोई खाता नहीं मिला।.';

  @override
  String get emailAuthTooManyRequests =>
      'बहुत सारे प्रयास। बाद में फिर से प्रयास करें।.';

  @override
  String get emailAuthOperationNotAllowed =>
      'ईमेल लिंक साइन-इन सक्षम नहीं है।.';

  @override
  String get emailAuthQuotaExceeded =>
      'ईमेल कोटा से अधिक हो गया। कल फिर से प्रयास करें।.';

  @override
  String get emailAuthVerificationFailed =>
      'ईमेल सत्यापन विफल रहा। फिर से प्रयास करें।.';

  @override
  String get emailAuthTitle => 'ईमेल सत्यापन';

  @override
  String get emailAuthVerifyYourEmail => 'अपना ईमेल सत्यापित करें';

  @override
  String get emailAuthDescription =>
      'खाता वसूली और सुरक्षा के लिए अपना ईमेल पता जोड़ें। हम आपको एक सुरक्षित साइन-इन लिंक भेज देंगे।.';

  @override
  String get emailAuthEmailAddress => 'ईमेल पता';

  @override
  String get emailAuthEmailPlaceholder => 'email@example.com';

  @override
  String get emailAuthPleaseEnterEmail => 'कृपया अपना ईमेल पता दर्ज करें';

  @override
  String get emailAuthPleaseEnterValidEmail =>
      'कृपया एक वैध ईमेल पता दर्ज करें';

  @override
  String get emailAuthCheckEmailToContinue =>
      'अपने ईमेल की जाँच करें और सत्यापन लिंक को जारी रखने के लिए टैप करें।.';

  @override
  String get emailAuthResendEmail => 'ईमेल भेजना';

  @override
  String get emailAuthSendVerificationEmail => 'सत्यापन ईमेल';

  @override
  String get emailAuthHowItWorks => 'कैसे ईमेल सत्यापन कार्य';

  @override
  String get emailAuthHowItWorksSteps =>
      '1. हम आपको एक सुरक्षित साइन-इन लिंक भेजते हैं\n2. अपने ईमेल की जाँच करें और लिंक टैप करें\n3. आपका ईमेल स्वचालित रूप से सत्यापित हो जाता है\n4. पासवर्ड की जरूरत नहीं!';

  @override
  String get emailAuthSecurityNotice =>
      'ईमेल सत्यापन आपके खाते को सुरक्षित रखने में मदद करता है और खाते की वसूली को सक्षम बनाता है यदि आप अपने डिवाइस तक पहुंच खो देते हैं।.';

  @override
  String get phoneAuthFailedToSendCode =>
      'सत्यापन कोड भेजने में विफल रहा। फिर से प्रयास करें।.';

  @override
  String get phoneAuthInvalidCodeTryAgain =>
      'अमान्य सत्यापन कोड। फिर से प्रयास करें।.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'फोन नंबर सत्यापित: _ _ _ _ _ _ _ _ _';
  }

  @override
  String get phoneAuthVerificationFailed =>
      'फोन सत्यापन विफल रहा। फिर से प्रयास करें।.';

  @override
  String get phoneAuthCodeResent => 'सत्यापन कोड resent';

  @override
  String get phoneAuthFailedToResendCode =>
      'कोड को पुनः भेजने में विफल रहा। फिर से प्रयास करें।.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'फोन नंबर कृपया प्रारूप की जांच करें।.';

  @override
  String get phoneAuthTooManyRequests =>
      'बहुत सारे प्रयास। बाद में फिर से प्रयास करें।.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'अमान्य सत्यापन कोड। फिर से जाँच करें और कोशिश करें।.';

  @override
  String get phoneAuthSessionExpired =>
      'सत्यापन सत्र समाप्त हो गया। कृपया एक नया कोड अनुरोध करें।.';

  @override
  String get phoneAuthSmsQuotaExceeded =>
      'एसएमएस कोटा से अधिक हो गया। कल फिर से प्रयास करें।.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'यह फ़ोन नंबर पहले से ही दूसरे खाते से जुड़ा हुआ है।.';

  @override
  String get phoneAuthVerificationFailedGeneric =>
      'सत्यापन विफल रहा। फिर से प्रयास करें।.';

  @override
  String get phoneAuthTitle => 'फोन सत्यापन';

  @override
  String get phoneAuthVerifyYourPhone => 'अपने फ़ोन को सत्यापित करें';

  @override
  String get phoneAuthEnterVerificationCode => 'सत्यापन कोड';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'खाता वसूली और सुरक्षा के लिए अपना फोन नंबर जोड़ें';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return '6-digits कोड में प्रवेश करें __PLACEHOLDER_0_';
  }

  @override
  String get phoneAuthPhoneNumber => 'फ़ोन नंबर';

  @override
  String get phoneAuthPhonePlaceholder => '+18 (5123-4567)';

  @override
  String get phoneAuthPleaseEnterPhone => 'कृपया अपना फ़ोन नंबर दर्ज करें';

  @override
  String get phoneAuthPleaseEnterValidPhone => 'कृपया मान्य फोन नंबर दर्ज करें';

  @override
  String get phoneAuthVerificationCode => 'सत्यापन कोड';

  @override
  String get phoneAuthPleaseEnterSixDigitCode => 'कृपया 6-digit कोड दर्ज करें';

  @override
  String get phoneAuthResendCode => 'कोड भेजना';

  @override
  String get phoneAuthSendVerificationCode => 'सत्यापन कोड';

  @override
  String get phoneAuthVerifyCode => 'कोड सत्यापित करें';

  @override
  String get phoneAuthChangePhoneNumber => 'फोन नंबर बदलें';

  @override
  String get phoneAuthSmsNotice =>
      'हम आपको एसएमएस के माध्यम से सत्यापन कोड भेजेंगे। मानक संदेश दरें लागू हो सकती हैं।.';

  @override
  String get phoneAuthCodeExpires =>
      'कोड 60 सेकंड में समाप्त हो जाता है। अपने संदेश की जाँच करें।.';

  @override
  String get yourDataRights => 'आपका डेटा अधिकार';

  @override
  String get dataRightsExplanation =>
      'आपके पास अपने व्यक्तिगत डेटा पर पूर्ण नियंत्रण है। आप अपने सभी डेटा को निर्यात कर सकते हैं या स्थायी रूप से किसी भी समय अपने खाते को हटा सकते हैं।.';

  @override
  String get exportYourData => 'अपना डेटा निर्यात करें';

  @override
  String get exportDataDescription => 'अपने सभी खाता डेटा को डाउनलोड करें';

  @override
  String get exportData => 'निर्यात डेटा';

  @override
  String get exportingData => 'निर्यात...';

  @override
  String get exportDataDetails =>
      'इसमें शामिल हैं: प्रोफाइल, बीप, टिप्पणियां, डिवाइस की जानकारी, और प्राथमिकताएं। डेटा JSON प्रारूप में प्रदान किया जाता है।.';

  @override
  String get dataExportedSuccessfully => 'सफलतापूर्वक निर्यात किया गया';

  @override
  String get dataExportFailed => 'डेटा निर्यात करने में विफल';

  @override
  String get deleteAccount => 'खाता हटाएं';

  @override
  String get deleteAccountDescription =>
      'अपने खाते और सभी डेटा को स्थायी रूप से हटा दें';

  @override
  String get deleteAccountWarning =>
      'यह कार्रवाई नहीं की जा सकती है। आपके सभी बीप, टिप्पणियां और खाता डेटा को स्थायी रूप से हटा दिया जाएगा।.';

  @override
  String get deleteMyAccount => 'मेरा खाता हटाएं';

  @override
  String get deletingAccount => '...';

  @override
  String get deleteAccountConfirmTitle => 'खाता हटाएं';

  @override
  String get deleteAccountConfirmMessage =>
      'क्या आप अपने खाते को हटाना चाहते हैं? यह क्रिया स्थायी है और इसे बिना सोचे समझे नहीं सकता।.';

  @override
  String get dataWillBeDeleted =>
      'निम्नलिखित डेटा को स्थायी रूप से हटा दिया जाएगा:';

  @override
  String get deletedDataList =>
      '• आपकी प्रोफ़ाइल और उपयोगकर्ता नाम\n• आपकी बीप और रिपोर्ट\n• आपकी टिप्पणियां\n• डिवाइस पंजीकरण डेटा\n• स्थान और वरीयता डेटा';

  @override
  String get deleteAccountPermanent => 'स्थायी रूप से हटाएं';

  @override
  String get accountDeletedSuccessfully => 'खाता सफलतापूर्वक हटा दिया गया';

  @override
  String get accountDeletionFailed => 'खाते को हटाने में विफल';

  @override
  String get onboardingWelcomeTitle => 'UFOBeep में आपका स्वागत है';

  @override
  String get onboardingWelcomeBody =>
      'तत्काल अलर्ट प्राप्त करें जब यूएफओ आपके स्थान के पास स्पॉट हो जाता है। फिर कभी नहीं याद आती!';

  @override
  String get onboardingReportTitle => 'कुछ देखें? इसे बीप करें!';

  @override
  String get onboardingReportBody =>
      'यूएफओ दर्शनों की तस्वीरें और वीडियो कैप्चर करें। तत्काल वैश्विक समुदाय के साथ साझा करें।.';

  @override
  String get onboardingCompassTitle => 'वे कहाँ दिखते हैं';

  @override
  String get onboardingCompassBody =>
      'कम्पास आपको सटीक दिशा दिखाता है कि गवाह यूएफओ को देखने पर देख रहे थे। अपने फोन और देखो!';

  @override
  String get onboardingCommunityTitle => 'Skywatchers';

  @override
  String get onboardingCommunityBody =>
      'अपनी सुबह की कॉफी पर नवीनतम यूएफओ दृश्यों को पढ़ें। पेशेवर MUFON डेटा तक पहुंचें और साथी स्काईवॉशर से जुड़ें।.';

  @override
  String get skip => 'लॉग इन';

  @override
  String get getStarted => 'शुरू करना';

  @override
  String get viewOnboardingAgain => 'फिर से ऑनबोर्डिंग देखें';

  @override
  String get customAlertRange => 'कस्टम अलर्ट रेंज';

  @override
  String get enterRangeKm => 'किमी (1-99999) में रेंज दर्ज करें';

  @override
  String get largeRangeWarning =>
      'बड़ी रेंज (> 100 किमी) कई अलर्ट उत्पन्न कर सकती है';

  @override
  String get globalRangeWarning =>
      'बहुत बड़ी रेंज (> 1000 किमी) आपको दुनिया भर से सतर्क भेज देगी';

  @override
  String get invalidRange => 'कृपया 1 और 99999 के बीच नंबर दर्ज करें';

  @override
  String get celestialSunDaylight =>
      'सूर्य ऊपर है - दिन की रोशनी की स्थिति दृष्टि दृश्यता को प्रभावित कर सकती है';

  @override
  String get celestialSunTwilight =>
      'Twilight की स्थिति - कुछ दृश्यता लेकिन डेलाइट से अंधेरा';

  @override
  String get celestialSunDark =>
      'अंधेरे की स्थिति - आकाश में वस्तुओं को देखने के लिए इष्टतम';

  @override
  String celestialMoonBright(Object phase) {
    return 'Bright __PLACEHOLDER_0_ चंद्रमा दृश्य - अन्य वस्तुओं को रोशनी या अस्पष्ट कर सकता है';
  }

  @override
  String celestialMoonModerate(Object phase) {
    return '__PLACEHOLDER_0_ चंद्रमा दृश्य - मध्यम प्रकाश की स्थिति';
  }

  @override
  String celestialMoonThin(Object phase) {
    return 'पतला $phase चंद्र दृश्य - न्यूनतम प्रकाश';
  }

  @override
  String celestialMoonHidden(Object phase) {
    return '$phase चंद्र क्षितिज से नीचे - कोई चंद्र रोशनी नहीं';
  }

  @override
  String get celestialNoPlanets =>
      'यूएफओ के लिए कोई उज्ज्वल ग्रह दिखाई नहीं दे सकता है';

  @override
  String celestialPlanetHigh(Object altitude, Object planet) {
    return '${planet}_ उच्च ओवरहेड (_PLACEHOLDER_1_°) - बहुत प्रमुख';
  }

  @override
  String celestialPlanetMedium(Object altitude, Object planet) {
    return '${planet}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String celestialPlanetLow(Object altitude, Object planet) {
    return '${planet}_____________________________________________________________________________________________________________________________';
  }

  @override
  String get celestialNoStars => 'असामान्य रूप से उज्ज्वल सितारे दृश्यमान';

  @override
  String celestialStarSingle(Object altitude, Object star) {
    return '${star}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String celestialStarsMultiple(Object count, Object names) {
    return '${count}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get celestialSummaryDaylight => 'डेलाइट की स्थिति';

  @override
  String get celestialSummaryDark => 'अंधेरे आकाश की स्थिति';

  @override
  String get celestialSummaryMoonUp => 'चंद्रमा रोशनी';

  @override
  String get celestialSummaryMoonDown => 'कोई चाँद रोशनी';

  @override
  String celestialSummaryManyObjects(Object count) {
    return '${count}_ उज्ज्वल वस्तुएं जो UFO के साथ भ्रमित हो सकती हैं';
  }

  @override
  String celestialSummarySomeObjects(Object count) {
    return '$count उज्ज्वल वस्तु (s) दिखाई देता है';
  }

  @override
  String get celestialSummaryFewObjects => 'आकाश में न्यूनतम उज्ज्वल वस्तुएं';

  @override
  String celestialSkySummary(Object conditions) {
    return 'आकाश की स्थिति: _ _ _ _ _ _ _ _ _';
  }

  @override
  String get planetVenus => 'शुक्र';

  @override
  String get planetJupiter => 'गुरु';

  @override
  String get planetSaturn => 'शनि';

  @override
  String get planetMars => 'मार्च';

  @override
  String get planetMercury => 'बुध';

  @override
  String get planetUranus => 'यूरेनस';

  @override
  String get planetNeptune => 'नेप्च्यून';

  @override
  String get starSirius => 'सरियस';

  @override
  String get starCanopus => 'कैनोपस';

  @override
  String get starArcturus => 'Arcturus';

  @override
  String get starVega => 'वेगा';

  @override
  String get starCapella => 'कैपेला';

  @override
  String get starRigel => 'रिगेल';

  @override
  String get starProcyon => 'Procyon';

  @override
  String get starBetelgeuse => 'बेल्जूस';

  @override
  String get moonPhaseNew => 'न्यू चाँद';

  @override
  String get moonPhaseWaxingCrescent => 'वैक्सिंग क्रिसेंट';

  @override
  String get moonPhaseFirstQuarter => 'पहला क्वार्टर';

  @override
  String get moonPhaseWaxingGibbous => 'वैक्सिंग गिबस';

  @override
  String get moonPhaseFull => 'पूर्णिमा';

  @override
  String get moonPhaseWaningGibbous => 'Waning Gibbous';

  @override
  String get moonPhaseThirdQuarter => 'तीसरा तिमाही';

  @override
  String get moonPhaseWaningCrescent => 'Waning Crescent';

  @override
  String planetBelowHorizon(Object planet) {
    return '${planet}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String planetHighOverheadProminent(Object altitude, Object planet) {
    return '${planet}_ उच्च ओवरहेड (_PLACEHOLDER_1_°) - बहुत प्रमुख';
  }

  @override
  String planetMidSkyProminent(Object altitude, Object planet) {
    return '${planet}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String planetMidSky(Object altitude, Object planet) {
    return '${planet}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String starVeryBright(Object altitude, Object star) {
    return '${star}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String starProminent(Object altitude, Object star) {
    return '${star}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String starVisible(Object altitude, Object star) {
    return '${star}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get altitudeShort => 'Alt';

  @override
  String get magnitudeShort => 'मग';

  @override
  String satellitesVisibleMightExplain(Object count) {
    return '${count}0__ उपग्रह दृश्यमान - दृष्टि की व्याख्या कर सकते हैं';
  }

  @override
  String satellitesVisibleUnlikelyExplain(Object count) {
    return '${count}0__ उपग्रह दृश्य - देखने की व्याख्या करने की संभावना नहीं';
  }

  @override
  String get noSatellitesVisible => 'कोई उपग्रह दिखाई नहीं देता';

  @override
  String aircraftDetectedInRadius(Object count, Object radius) {
    return '__PLACEHOLDER_0_0__ विमान का पता __PLACEHOLDER_1_Km के भीतर हुआ।';
  }

  @override
  String get processingAlert => 'Processing Your UFO Alert...';

  @override
  String get analyzingEnvironment => 'Analyzing environmental conditions';

  @override
  String get weatherAnalysis => 'Weather Analysis';

  @override
  String get locationAnalysis => 'Location Analysis';

  @override
  String get aircraftTracking => 'Aircraft Tracking';

  @override
  String get satelliteAnalysis => 'Satellite Analysis';

  @override
  String get celestialAnalysis => 'Celestial Analysis';

  @override
  String analyzing(Object processor) {
    return 'Analyzing $processor...';
  }

  @override
  String get processorWeather => 'weather conditions';

  @override
  String get processorLocation => 'location details';

  @override
  String get processorAircraft => 'nearby aircraft';

  @override
  String get processorSatellites => 'satellite positions';

  @override
  String get processorCelestial => 'celestial objects';
}
