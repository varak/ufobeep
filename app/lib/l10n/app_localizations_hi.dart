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
  String get locationPermissionTitle => 'आवश्यक स्थान';

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
    return 'दूर';
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
  String get dndMode => 'Disturb';

  @override
  String get dndUntil => 'जब तक परेशान न हों';

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
  String get reportOnly => 'केवल रिपोर्ट करें';

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
    return 'To get the time';
  }

  @override
  String timeHoursAgo(int count) {
    return 'To get the time';
  }

  @override
  String timeMinutesAgo(int count) {
    return 'To make a word';
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
  String get previousPage => 'पिछला';

  @override
  String get nextPage => 'अगला';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'पृष्ठ ${currentPage}__${totalCount}________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get heroTagline => 'बाहर जाने और देखने के लिए अलर्ट प्राप्त करें';

  @override
  String get heroDescription =>
      'कभी किसी अन्य यूएफओ दर्शन को याद न करें। जब आपके पास कोई व्यक्ति आकाश में कुछ अजीब चीज़ देखता है तो वास्तविक समय अलर्ट प्राप्त करें। अपने फोन को इंगित करें और ठीक उसी तरह खोजें जहां देखने के लिए।.';

  @override
  String get downloadApp => 'App डाउनलोड';

  @override
  String get viewAllBeeps => 'All Beeps';

  @override
  String get sightingsMap => 'Sightings Map';

  @override
  String get globalSightingNetwork => 'वैश्विक दृष्टि नेटवर्क';

  @override
  String get howItWorks => 'कैसे UFOBeep वर्क्स';

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
  String get mufonDatabaseReport => 'MUFON डेटाबेस रिपोर्ट';

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
}
