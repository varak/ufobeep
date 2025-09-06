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
    return '0 _ 0 _ 0';
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
    return 'द्वारा रिपोर्ट किया गया $username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'रिपोर्ट $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '0 _ 0 _ 0';
  }

  @override
  String bearingToObject(int bearing) {
    return 'वस्तु पर असर: 0 _ 0 _ 0';
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
  String get noCommentsYet => 'अभी तक कोई टिप्पणी नहीं। पहले हो!';

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
    return 'Pointing to $direction';
  }

  @override
  String get calibratingCompass => 'Calibrating compass ..';

  @override
  String get openAROverlay => 'ओपन एआर ओवरले';

  @override
  String get pushTitleAlertNearby => 'आपके पास यूएफओ अलर्ट';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'एक नए दर्शन की सूचना ${distance}_____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________.';
  }

  @override
  String get pushTitleComment => 'नई टिप्पणी';

  @override
  String get pushBodyComment => 'किसी ने आप का पालन करते हुए देखा।.';

  @override
  String get pushTitleWitness => 'गवाह पुष्टि';

  @override
  String get pushBodyWitness =>
      'एक उपयोगकर्ता ने पुष्टि की कि वे उसी वस्तु को देखते हैं।.';

  @override
  String get weather => 'मौसम';

  @override
  String cloudCover(int percent) {
    return 'क्लाउड कवर: 0';
  }

  @override
  String wind(num speed, String unit) {
    return 'पवन: $speed $unit';
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
  String get enablePushNotifications => 'पुश नोटिफिकेशन सक्षम करें';

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
  String get videoOnly => 'केवल वीडियो';

  @override
  String get imageOnly => 'केवल छवि';

  @override
  String get timeJustNow => 'अभी';

  @override
  String timeDaysAgo(int count) {
    return 'To make a ph_0_d';
  }

  @override
  String timeHoursAgo(int count) {
    return 'H_0_h__h___h____h___h___h___h____h_____h___h___h____h_________h________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String timeMinutesAgo(int count) {
    return '^PH_0_m पहले';
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
  String get sightingDate => 'दर्शन तिथि';

  @override
  String get databaseEntry => 'डेटाबेस प्रविष्टि';

  @override
  String get locationLabel => 'स्थान';

  @override
  String get distanceLabel => 'दूरी';

  @override
  String get timeLabel => 'समय';

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
    return '${count}________________________________________________________________________________________________________________________________________';
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
}
