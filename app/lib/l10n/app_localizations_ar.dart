// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'UFOBeep';

  @override
  String get ok => 'حسناً';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'اقترب';

  @override
  String get save => 'أنقذ';

  @override
  String get delete => 'تحذف';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Retry';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get back => 'العودة';

  @override
  String get next => 'التالي';

  @override
  String get done => 'تم';

  @override
  String get loading => 'التعبئة..';

  @override
  String get processing => 'تجهيز..';

  @override
  String get errorGeneric => 'حدث شيء خاطئ.';

  @override
  String get networkError => 'خطأ الشبكة تحقق من اتصالك.';

  @override
  String get permissionsRequired => 'الأذون المطلوبة';

  @override
  String get learnMore => 'تعلم المزيد';

  @override
  String get welcomeTitle => 'مرحبا بكم في UFOBeep';

  @override
  String get welcomeSubtitle => 'في الوقت الحقيقي تنبيه يو إف أو بالقرب منك';

  @override
  String get signIn => 'وقع';

  @override
  String get signOut => 'وقع';

  @override
  String get continueAsGuest => 'استمر كضيف';

  @override
  String get enterUsername => 'أدخل اسم المستخدم';

  @override
  String get username => 'المستعمل';

  @override
  String get usernameUpdated => 'تحديث لقب المستخدم';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'التركيبات';

  @override
  String get tabAlerts => 'إنذار';

  @override
  String get tabBeep => 'Beep';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabMap => 'خريطة';

  @override
  String get tabSettings => 'التركيبات';

  @override
  String get alertsTitle => 'تنبيهات قريبة';

  @override
  String get noAlerts => 'لا تنبيهات قريبة بعد.';

  @override
  String get pullToRefresh => 'سحب لتنعش';

  @override
  String alertDistance(String distance) {
    return '_';
  }

  @override
  String alertDirection(int bearing) {
    return '-';
  }

  @override
  String get viewAlert => 'تحذير';

  @override
  String get viewOnMap => 'مشاهدة على الخريطة';

  @override
  String get iSeeItToo => 'أراه أيضاً';

  @override
  String get confirmWitnessed => 'هل تؤكد أنك شاهدت هذا المشهد؟?';

  @override
  String get witnessConfirmed => 'شكراً - تم نشر تأكيدك.';

  @override
  String get createBeepTitle => 'أرسل سيارة بيب';

  @override
  String get beepExplain => 'التقط ما تراه و تنبيه الساعين القريبين.';

  @override
  String get capturePhoto => 'صورة التقطت';

  @override
  String get captureVideo => 'الفيديو';

  @override
  String get pickFromGallery => 'اختر من المعرض';

  @override
  String get descriptionHint => 'صف ما تراه في السماء';

  @override
  String get submitBeep => 'إرسال Beep';

  @override
  String get beepSent => 'Beep sent';

  @override
  String get uploadingMedia => 'تحميل وسائل الإعلام..';

  @override
  String get includeLocation => 'يشمل الموقع';

  @override
  String get includeTimestamp => 'Include timestamp';

  @override
  String get beepFailed => 'فشل في إرسال بيب.';

  @override
  String get mediaProcessing => 'وسائل الإعلام';

  @override
  String get cameraPermissionTitle => 'الوصول إلى الكاميرا';

  @override
  String get cameraPermissionBody =>
      'الحصول على الكاميرا لالتقاط الصور والفيديو.';

  @override
  String get locationPermissionTitle => 'الحاجة إلى الوصول إلى الموقع';

  @override
  String get locationPermissionBody =>
      'نستخدم موقعك لإرسال وإستلام إنذارات قريبة.';

  @override
  String get microphonePermissionTitle => 'الوصول إلى الميكروفون';

  @override
  String get microphonePermissionBody =>
      'الحصول على الميكروفون للحصول على الفيديو بالصوت.';

  @override
  String get openSettings => 'الأطر المفتوحة';

  @override
  String get alertDetailTitle => 'تفاصيل النظر';

  @override
  String reportedBy(String username) {
    return 'Reported by_PH_0';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Reported __PH_0_';
  }

  @override
  String distanceAway(String distance) {
    return '_';
  }

  @override
  String bearingToObject(int bearing) {
    return 'وإذ يعترض على ما يلي: _';
  }

  @override
  String get openCompass => 'البوصلة المفتوحة';

  @override
  String get openAR => 'فتح النفقة';

  @override
  String get openChat => 'محادثة مفتوحة';

  @override
  String get commentsTitle => 'التعليقات';

  @override
  String get addComment => 'أضف تعليق';

  @override
  String get send => 'أرسل';

  @override
  String get commentPosted => 'التعليق';

  @override
  String get autoFollowEnabled => 'وتتبعون الآن هذا الإنذار.';

  @override
  String get noCommentsYet => 'لا تعليقات بعد كن الأول!';

  @override
  String get newCommentNotification => 'تعليق جديد على مشاهدتك.';

  @override
  String get mapTitle => 'Live Map';

  @override
  String get compassTitle => 'Compass';

  @override
  String get compassSettings => 'مجموعة البوصلة';

  @override
  String get compassMode => 'Compass Mode';

  @override
  String get compassStandardMode => 'النموذج المعياري';

  @override
  String get compassPilotMode => 'Pilot Mode';

  @override
  String get compassStandardDescription => 'العنوان الأساسي والملاحة';

  @override
  String get compassPilotDescription =>
      'الملاحة المتقدمة مع اتفاق التجارة الحرة والمبادرة';

  @override
  String pointingTo(String direction) {
    return 'نشير إلى';
  }

  @override
  String get calibratingCompass => 'البوصلة المعايرة..';

  @override
  String get openAROverlay => 'فتح النفقة';

  @override
  String get pushTitleAlertNearby => 'إنذار يو إف أو بالقرب منك';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'A new sighting was reported __PH_0_ away.';
  }

  @override
  String get pushTitleComment => 'تعليق جديد';

  @override
  String get pushBodyComment => 'شخص ما علّقَ على a مشاهد أنت تَتْبعُ.';

  @override
  String get pushTitleWitness => 'تأكيد الشهود';

  @override
  String get pushBodyWitness => 'المستعمل أكد أنهم يرون نفس الجسم.';

  @override
  String get weather => 'الطقس';

  @override
  String cloudCover(int percent) {
    return 'غطاء السحاب: _';
  }

  @override
  String wind(num speed, String unit) {
    return 'الفائز: __PH_0 ________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get nearbyAircraft => 'طائرات قريبة';

  @override
  String get noAircraft => 'لا توجد طائرات قريبة';

  @override
  String get loadingContext => 'وضع السياق البيئي';

  @override
  String get settingsTitle => 'التركيبات';

  @override
  String get notifications => 'الإخطارات';

  @override
  String get enablePushNotifications => 'إخطارات الدفع التمكينية';

  @override
  String get quietHours => 'ساعات هادئة';

  @override
  String get quietHoursDesc => 'تنبيه الصمت بين ساعات مختارة.';

  @override
  String get dndMode => 'لا تغضب';

  @override
  String get dndUntil => 'لا تزعج حتى';

  @override
  String get language => 'اللغة';

  @override
  String get chooseLanguage => 'لغة الاختيار';

  @override
  String get units => 'الوحدات';

  @override
  String get unitsImperial => 'امبراطورية (مي، م ف)';

  @override
  String get unitsMetric => 'Metric (km, km/h)';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfUse => 'مدة الاستخدام';

  @override
  String get errorNoLocation =>
      'المكان غير متاح حاول مرة أخرى في الخارج مع منظر السماء الواضح.';

  @override
  String get errorNoCamera => 'الكاميرا غير متاحة على هذا الجهاز.';

  @override
  String get errorUploadFailed => 'لقد فشلت الحمولة أرجوك حاول مرة أخرى.';

  @override
  String get errorPermissionDenied => 'رفض الإذن.';

  @override
  String get errorInvalidUsername => 'وهذا الاسم المستخدم غير متاح.';

  @override
  String get nothingToShow => 'لا شيء لنظهره بعد.';

  @override
  String get storeShortDesc =>
      'تنبيهات (أوفو) على مقربة منك التقاط، تأكيد، والحديث في الوقت الحقيقي.';

  @override
  String get storeLongDesc =>
      '(أوفيب) يرسل تنبيهات في الوقت الحقيقي عندما يكتشف شخص ما طائرة مروحية قريبة التقط صوراً و أشرطة فيديو، تأكد من مشاهدتها بمسافة من النقر، وجهة النظر.';

  @override
  String get keywords =>
      'UFO,UAP,OVNI,aliens,sightings,skywatch,alerts,radar,compass';

  @override
  String get noAlertsFound => 'No matching alerts';

  @override
  String get alertsFilterHelp =>
      'Try adjusting your filters to see more results';

  @override
  String get verified => 'Verified';

  @override
  String get beepOnly => 'beep only';

  @override
  String get videoOnly => 'video only';

  @override
  String get imageOnly => 'image only';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String timeMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String get loadMoreAlerts => 'Load More Alerts';

  @override
  String get toggleMufonTooltip => 'Toggle MUFON sightings';

  @override
  String get showMufonData => 'Show MUFON data';

  @override
  String get hideMufonData => 'Hide MUFON data';

  @override
  String get showingUfoBeepOnly => 'Showing only UFOBeep reports';

  @override
  String get showingAllReports =>
      'Showing all reports including MUFON database';

  @override
  String get filteredSuffix => 'filtered';
}
