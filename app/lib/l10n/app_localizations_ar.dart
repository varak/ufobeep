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
  String beepSentWithUrl(String shortUrl) {
    return 'Beep sent successfully';
  }

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
  String get enablePushNotifications =>
      'الحصول على الإخطارات للتعليقات المستقبلية';

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
  String get noAlertsFound => 'لا تنبيهات مطابقة';

  @override
  String get alertsFilterHelp => 'حاول تعديل مرشحيك لرؤية المزيد من النتائج';

  @override
  String get verified => 'مصدق عليه';

  @override
  String get beepOnly => 'البيرة فقط';

  @override
  String get videoOnly => 'الفيديو فقط';

  @override
  String get imageOnly => 'الصورة فقط';

  @override
  String get timeJustNow => 'الآن';

  @override
  String timeDaysAgo(int count) {
    return 'قبل';
  }

  @override
  String timeHoursAgo(int count) {
    return 'قبل';
  }

  @override
  String timeMinutesAgo(int count) {
    return 'قبل';
  }

  @override
  String get loadMoreAlerts => 'عدد أكبر من التحذيرات';

  @override
  String get toggleMufonTooltip => 'مشاهدات (مافون)';

  @override
  String get showMufonData => 'بيانات البرنامج';

  @override
  String get hideMufonData => 'إخفاء البيانات';

  @override
  String get showingUfoBeepOnly => 'لا تظهر سوى تقارير الجيب';

  @override
  String get showingAllReports =>
      ':: عرض جميع التقارير بما في ذلك قاعدة بيانات مون';

  @override
  String get filteredSuffix => 'ممتلئة';

  @override
  String get detailsTitle => 'التفاصيل';

  @override
  String get mufonCase => 'MUFON القضية';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON القضية';
  }

  @override
  String get sightingDate => 'المصارعة';

  @override
  String get mufonDatabaseEntryDate => 'تاريخ دخوله قاعدة البيانات';

  @override
  String get databaseEntry => 'دخول قاعدة البيانات';

  @override
  String get shareLink => 'Share Link';

  @override
  String get linkCopied => '(لينك) تم نسخه من لوح المشبك';

  @override
  String get locationLabel => 'الموقع';

  @override
  String get distanceLabel => 'المسافة';

  @override
  String get timeLabel => 'الوقت';

  @override
  String get reportedByLabel => 'Reported by';

  @override
  String get unknownLocation => 'مكان مجهول';

  @override
  String get locationUnknown => 'الموقع غير معروف';

  @override
  String get witnessesLabel => 'الشهود';

  @override
  String witnessesCountMessage(int count) {
    return 'الناس أكدوا هذا';
  }

  @override
  String get photoAnalysisTitle => 'تحليل الصور';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analysis: ${count}_media file(s) processed';
  }

  @override
  String get addMoreMedia => 'أكثر';

  @override
  String get addMedia => 'وسائط الإعلام';

  @override
  String get retakePhoto => 'Retake Photo';

  @override
  String get retakeVideo => 'Retake Video';

  @override
  String get camera => 'آلة تصوير';

  @override
  String get gallery => 'Gallery';

  @override
  String get basicSettings => 'الأساسيات';

  @override
  String get appSettings => 'App Settings';

  @override
  String get alertRange => 'إنذار رانج';

  @override
  String get manageNotificationsDesc => 'الاشتراكات في المؤسسة';

  @override
  String get permissionsTitle => 'الانبعاثات';

  @override
  String get permissionLocation => 'الموقع';

  @override
  String get permissionCamera => 'آلة تصوير';

  @override
  String get permissionNotifications => 'الإخطارات';

  @override
  String get permissionPhotos => 'Photos';

  @override
  String get permissionGranted => 'منح';

  @override
  String get permissionNotGranted => 'لم تُمنح';

  @override
  String get permissionGrant => 'غرانت';

  @override
  String get generateUsername => 'توليد اسم مستخدم جديد';

  @override
  String get adminTools => 'الأدوات المخصصة';

  @override
  String get openAdminPanel => 'الفريق المفتوح العضوية';

  @override
  String get webAdminInterface => 'Web Admin Interface';

  @override
  String get adminBetaNotice =>
      'بيتا يبني فقط أداتين لاختبار تنبيهات القرب والإخطارات بالدفع و تشخيص النظام.';

  @override
  String get whatDoYouSee => 'ماذا ترى؟?';

  @override
  String get ufoSighting => 'UFO البصر';

  @override
  String get envAnalysisTitle => 'Environmental Analysis';

  @override
  String get envAnalysisPending => 'تحليل';

  @override
  String get envAnalysisPendingDesc =>
      'وستكون البيانات البيئية متاحة بمجرد بدء التجهيز.';

  @override
  String get unknownAircraft => 'طائرة مجهولة';

  @override
  String get moreAircraft => 'طائرات أخرى';

  @override
  String get premiumImageryTitle => 'ساتل بريميوم التصوير';

  @override
  String get premiumImagerySubtitle => 'الصور التجارية العالية الاستبانة';

  @override
  String get sightingTypeLabel => 'النوع';

  @override
  String get ufoTypeSphere => 'نصف الكرة';

  @override
  String get ufoTypeTriangle => 'المثلث';

  @override
  String get ufoTypeDisk => 'Disk';

  @override
  String get ufoTypeLight => 'الضوء';

  @override
  String get ufoTypeFireball => 'كرة نارية';

  @override
  String get ufoTypeCylinder => 'Cylinder';

  @override
  String get ufoTypeCigar => 'سيجار';

  @override
  String get ufoTypeRectangle => 'Rectangle';

  @override
  String get ufoTypeFormation => 'الاستمارة';

  @override
  String get ufoTypeUnknown => 'غير معروف';

  @override
  String get ufoTypeBoomerang => 'Pomerang';

  @override
  String get ufoTypeDiamond => 'الماس';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Cone';

  @override
  String get ufoTypeCross => 'الصليب';

  @override
  String get ufoTypeDumbbell => 'Dumbbell';

  @override
  String get ufoTypeTeardrop => 'Teardrop';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'الرصاص';

  @override
  String get ufoTypeSaturn => 'زحل';

  @override
  String get ufoTypeStarLike => 'مثل النجوم';

  @override
  String get ufoTypeBlimp => 'Blimp';

  @override
  String get actionsTitle => 'الإجراءات';

  @override
  String get addPhotosAndVideos => 'أضف الصور الفوتوغرافية';

  @override
  String get howToReportToMufon => 'How to Report to MUFON';

  @override
  String get reportToMufon => 'Report to MUFON';

  @override
  String get whyReportToMufon => 'لماذا نبلغ (مافون)؟?';

  @override
  String get openMufonReport => 'مفتوح التقرير';

  @override
  String get confirmedWitness => 'لقد أكدت هذا المشهد';

  @override
  String witnessesHaveConfirmed(int count) {
    return 'الناس أكدوا هذا';
  }

  @override
  String get aircraftTrackingTitle => 'تعقب الطائرات';

  @override
  String get weatherConditionsTitle => 'أحوال الطقس';

  @override
  String get noSatellitePasses => 'No visible satellite passes found';

  @override
  String get contentAnalysisTitle => 'تحليل المحتوى';

  @override
  String get contentSafe => 'المضمون آمن';

  @override
  String get contentFlagged => 'مضمون الاستعراض';

  @override
  String get confidenceLabel => 'الثقة';

  @override
  String get methodLabel => 'المنهجية';

  @override
  String get premiumImageryAccessOnly => 'لا تتوافر سوى صور ساتلية بريميوم:';

  @override
  String get premiumAccessCreators => 'مبدئي إنذار';

  @override
  String get premiumAccessWitnesses => 'الشهود المؤكدون في نطاق الرؤية';

  @override
  String get comingSoon => 'قادم قريبا';

  @override
  String get directionDistanceTitle => 'Direction \' Distance';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON القضية';
  }

  @override
  String get satellitePassesTitle => 'تصاريح ساتلية';

  @override
  String get satellitePassExplanation =>
      'قمر صناعي مرئي يمر خلال الإطار الزمني وكثير من تقارير المدار الثابت بالنسبة للأرض هي في الواقع سواتل أو حطام فضائي.';

  @override
  String get followingAlert => 'بعد تنبيه - سوف تحصل على إشعارات التعليق';

  @override
  String get unfollowedAlert => 'إنذار غير متوفر - لا مزيد من إخطارات التعليق';

  @override
  String get alertFollowError => 'استكمال الأخطاء';

  @override
  String get notificationChannelAlerts => 'UFOBeep Alerts';

  @override
  String get notificationChannelAlertsDesc =>
      'Notifications for UFO beeps and proximity alerts';

  @override
  String get notificationSightingTitle => 'UFO Sighting';

  @override
  String get notificationSightingUrgent => '⚠️ URGENT UFO Sighting';

  @override
  String get notificationSightingEmergency => '🚨 EMERGENCY UFO Sighting';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '$witnessText near $locationName';
  }

  @override
  String notificationCommentTitle(String username) {
    return '💬 $username commented';
  }

  @override
  String get notificationWitnessText => 'New sighting';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '$count witnesses';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Dismiss';

  @override
  String notificationDistance(String distance) {
    return '$distance away';
  }

  @override
  String get unknown => 'unknown';

  @override
  String get report => 'report';

  @override
  String get mufon => 'mufon';
}
