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
    return 'Beep أرسل بنجاح';
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
    return 'Reported by __PLACEHOLDER_0';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Reported_PLACEHOLDER_0';
  }

  @override
  String distanceAway(String distance) {
    return 'بعيدا';
  }

  @override
  String bearingToObject(int bearing) {
    return 'اعتراض:';
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
  String get noCommentsYet => 'لا تعليقات بعد كن أول من يعلق!';

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
    return 'A new sighting was reported $distance away.';
  }

  @override
  String get pushTitleComment => 'تعليق جديد';

  @override
  String get pushBodyComment => 'شخص ما علّقَ على a مشاهد أنت تَتْبعُ.';

  @override
  String get pushTitleWitness => 'تأكيد الشهود';

  @override
  String get temperature => 'درجة الحرارة';

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
    return 'الفائز: ${speed}__________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
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
  String get beepOnly => 'Beep فقط';

  @override
  String get reportOnly => 'التقرير فقط';

  @override
  String get videoOnly => 'الفيديو فقط';

  @override
  String get imageOnly => 'التصوير فقط';

  @override
  String get mediaOnly => 'وسائط الإعلام فقط';

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
    return '_BAR_';
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
  String get mufonSighting => 'تقرير المصارعة';

  @override
  String get mufonLightSighting => 'تقرير مصارعة الضوء';

  @override
  String get mufonSphereSighting => 'MFON Sphere Sighting Report';

  @override
  String get mufonDiscSighting => 'MUFON Disc Sighting Report';

  @override
  String get mufonTriangleSighting => 'MUFON Triangle Sighting Report';

  @override
  String get mufonCigarSighting => 'تقرير مصارعة السيجار';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting Report';

  @override
  String get mufonRectangleSighting => 'MUFON Rectangle Sighting Report';

  @override
  String get mufonCylinderSighting => 'MUFON Cylinder Sighting Report';

  @override
  String get mufonBoomerangSighting => 'MFON Boomerang Sighting Report';

  @override
  String get mufonStarlikeSighting => 'MUFON Starlike Sighting Report';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Case #_PLACEHOLDER_0_تفاصيل';
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
  String get locationLabel => 'الموقع:';

  @override
  String get distanceLabel => 'المسافة';

  @override
  String get timeLabel => 'الوقت:';

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
    return 'Analysis: ${count}media file(s) processed';
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
  String get ufo => 'UFO';

  @override
  String get sighting => 'البصر';

  @override
  String get ufoSighting => 'UFOBeep UFO إنذار';

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
  String get shapeTriangle => 'مثلث';

  @override
  String get shapeDisc => '(ج)';

  @override
  String get shapeDisk => 'قرص';

  @override
  String get shapeSphere => 'المجال';

  @override
  String get shapeCigar => 'السيجار';

  @override
  String get shapeLight => 'الضوء';

  @override
  String get shapeBoomerang => 'boomerang';

  @override
  String get shapeDiamond => 'الماس';

  @override
  String get shapeRectangle => 'التراجع';

  @override
  String get shapeOval => 'oval';

  @override
  String get shapeCone => 'cone';

  @override
  String get shapeCross => 'الصليب';

  @override
  String get shapeCylinder => 'الأسطوانة';

  @override
  String get shapeDumbbell => 'غبي';

  @override
  String get shapeTeardrop => 'الدموع';

  @override
  String get shapeTicTac => 'tic-tac';

  @override
  String get shapeBullet => 'رصاصة';

  @override
  String get shapeSaturn => 'العودة';

  @override
  String get shapeStarlike => 'النجمة';

  @override
  String get shapeBlimp => 'blimp';

  @override
  String get shapeFireball => 'إطلاق النار';

  @override
  String get shapeFormation => 'التشكيل';

  @override
  String get shapeUnknown => 'مجهول';

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
      'الإخطارات المتعلقة بأجهزة الإنذار بالأشعة فوق البنفسجية';

  @override
  String get notificationSightingTitle => 'UFOBeep UFO إنذار';

  @override
  String get notificationSightingUrgent => 'URGENT UFOBeep UFO إنذار';

  @override
  String get notificationSightingEmergency => 'EMERGENCY UFOBeep UFO إنذار';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '_BAR_ _BAR_ _BAR_';
  }

  @override
  String notificationCommentTitle(String username) {
    return '💬 __PLACEHOLDER_0 علق';
  }

  @override
  String get notificationWitnessText => 'مشاهدة جديدة';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '_BAR_ _BAR_ _BAR_';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'الانصراف';

  @override
  String notificationDistance(String distance) {
    return '_';
  }

  @override
  String get unknown => 'مجهول';

  @override
  String get report => 'التقرير';

  @override
  String get mufon => 'mufon';

  @override
  String get recentUfoBeepsTitle => 'Recent UFO Beeps';

  @override
  String get recentUfoBeepsSubtitle =>
      'Live UFOBeep community reports \' MUFON database sightings';

  @override
  String get recentUfoBeepsDescription =>
      'هذا التغذّي يُجمّعُ في الوقت الحقيقي يُدعى (يوفو بيب) من مستعملي تطبيقاتنا المتنقلة مع تقارير تاريخية من قاعدة بيانات (مافون).';

  @override
  String get loadingBeeps => 'وضع البيب الأخيرة...';

  @override
  String get noBeepsAvailable => 'لا يوجد صافرات في الوقت الحالي.';

  @override
  String get anomalyReported => 'Anomaly reported';

  @override
  String get copyShortLink => 'وصلة قصيرة';

  @override
  String get shareAlert => 'تحذير';

  @override
  String get previousPage => 'سابقا';

  @override
  String get nextPage => 'التالي';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Page ${currentPage}______________BAR_ _BAR_';
  }

  @override
  String get heroTagline =>
      'الحصول على تنبيهات عندما يذهب خارج وانظر إلى ما يصل';

  @override
  String get heroDescription =>
      'لا تفوتني رؤية أخرى الحصول على إنذارات في الوقت الحقيقي عندما شخص ما بالقرب منك يرى شيء غريب في السماء. اوجهي هاتفك وابحثي عن المكان المناسب.';

  @override
  String get downloadApp => 'Download App';

  @override
  String get viewAllBeeps => 'View All Beeps';

  @override
  String get sightingsMap => 'Sightings Map';

  @override
  String get globalSightingNetwork => 'Global Sighting Network';

  @override
  String get howItWorks => 'كَمْ يَعمَلُ';

  @override
  String get backToBeeps => 'العودة إلى بيبس';

  @override
  String get loadingDetails => 'تفاصيل الصافرة.';

  @override
  String get details => 'التفاصيل';

  @override
  String get location => 'الموقع';

  @override
  String get timeAgo => 'منذ';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'الأميال';

  @override
  String get distanceNearby => 'قريب';

  @override
  String get ufobeepWitnesses => 'الشهود';

  @override
  String get ufobeepConfirmations => 'التأكيدات';

  @override
  String get ufobeepAlertLevel => 'مستوى الإنذار';

  @override
  String get ufobeepReportType => 'التقرير الأول';

  @override
  String get mufonAttribution => 'MUFON تقرير قاعدة البيانات';

  @override
  String get mufonCaseNumber => 'القضية';

  @override
  String get mufonGenericTitle => 'تقرير المصارعة';

  @override
  String get mufonSphere => 'نصف الكرة';

  @override
  String get mufonLight => 'الضوء';

  @override
  String get mufonDisk => 'Disk';

  @override
  String get mufonTriangle => 'المثلث';

  @override
  String get mufonCigar => 'سيجار';

  @override
  String get mufonOval => 'Oval';

  @override
  String get mufonCylinder => 'Cylinder';

  @override
  String get mufonRectangle => 'Rectangle';

  @override
  String get mufonDiamond => 'الماس';

  @override
  String get mufonFireball => 'كرة نارية';

  @override
  String get mufonFlash => 'فلاش';

  @override
  String get mufonFormation => 'الاستمارة';

  @override
  String get mufonChanging => 'التغير';

  @override
  String get mufonChevron => 'Chevron';

  @override
  String get mufonCone => 'Cone';

  @override
  String get mufonCross => 'الصليب';

  @override
  String get mufonEgg => 'البيض';

  @override
  String get mufonOther => 'اعتراض';

  @override
  String get mufonUnknown => 'غير معروف';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON __PLACEHOLDER_0';
  }

  @override
  String get nuforcAttribution => 'NUFORC تقرير قاعدة البيانات';

  @override
  String get nuforcCaseNumber => 'القضية';

  @override
  String get nuforcGenericTitle => 'NUFORC Sighting Report';

  @override
  String get mediaImageNotFound => 'لم يعثر على صورة';

  @override
  String get mediaPlayVideo => 'العب فيديو';

  @override
  String get mediaViewImage => 'الصورة البصرية';

  @override
  String mediaCount(Object count) {
    return '__PLACEHOLDER_0_صور';
  }

  @override
  String get mediaCountSingle => 'صورة واحدة';

  @override
  String mediaMoreImages(Object count) {
    return 'أكثر';
  }

  @override
  String get errorNotFound => 'بيب لم يعثر عليه';

  @override
  String get errorLoadError => 'فشل في تحميل تفاصيل الصافرة';

  @override
  String get shareYourThoughts => 'شارك أفكارك حول هذا المنظر...';

  @override
  String get postComment => 'التعليق';

  @override
  String get loggedInAs => 'مقفلة';

  @override
  String get logout => 'Logout';

  @override
  String get notFollowing => 'لا يلي:';

  @override
  String get follow => 'اتبع';

  @override
  String get navRecentBeeps => 'Beeps Recent';

  @override
  String get navMap => 'خريطة';

  @override
  String get navDownloadApp => 'الحمولة';

  @override
  String get alertLevel => 'مستوى الإنذار';

  @override
  String get witnesses => 'الشهود';

  @override
  String get confirmations => 'التأكيدات';

  @override
  String get reporterLabel => 'أبلغ عنه المستخدم';

  @override
  String get coordinatesLabel => 'التنسيق';

  @override
  String get eventTime => 'وقت الحدث';

  @override
  String get reportedTime => 'الوقت المبلغ عنه';

  @override
  String get mufonDatabaseReport => 'MUFON تقرير قاعدة البيانات';

  @override
  String get copyShortLinkTitle => 'وصلة نسخ إلى لوح مشبك';

  @override
  String get imageNotFound => 'لم يعثر على صورة';

  @override
  String get ufoSightingAlt => 'UFO تنبيه Beep UFO';

  @override
  String get celestialDataTitle => 'أهداف المهرجان';

  @override
  String get visiblePlanets => 'Planets Visible';

  @override
  String get locationDataTitle => 'معلومات الموقع';

  @override
  String get timezone => 'Timezone';

  @override
  String get coordinates => 'التنسيق';

  @override
  String get processingSummaryTitle => 'موجز المعالجة';

  @override
  String get processingTime => 'تجهيز الوقت';

  @override
  String get successful => 'ناجح';

  @override
  String get failed => 'فشل';
}
