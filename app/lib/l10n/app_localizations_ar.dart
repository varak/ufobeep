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
  String get edit => 'حرر';

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
  String get locationPermissionTitle => 'المبلغ المطلوب';

  @override
  String get locationPermissionBody =>
      'نستخدم موقعك لإرسال وإستلام إنذارات قريبة.';

  @override
  String get microphonePermissionTitle => 'الوصول إلى الميكروفون';

  @override
  String get microphonePermissionBody =>
      'الحصول على الميكروفون للحصول على الفيديو بالصوت.';

  @override
  String get openSettings => 'Open Settings';

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
    return '_';
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
  String get quietHours => 'ساعة هادئة';

  @override
  String get quietHoursDesc => 'تنبيه الصمت بين ساعات مختارة.';

  @override
  String get quietHoursEnabled => 'ساعات هدوء';

  @override
  String get quietHoursFrom => 'من';

  @override
  String get quietHoursUntil => 'حتى';

  @override
  String get quietHoursDefaultTime => 'ساعات صامتة';

  @override
  String get emergencyOverride => 'تجاوز الطوارئ';

  @override
  String get emergencyOverrideDesc =>
      'السماح بالتنبيهات العاجلة خلال ساعات الهدوء';

  @override
  String get dndMode => 'لا تغضب';

  @override
  String get dndUntil => 'لا تزعج حتى';

  @override
  String dndEnabled(Object time) {
    return 'DND enabled until __PLACEHOLDER_0';
  }

  @override
  String get dndDisabled => 'معوق';

  @override
  String quietHoursActive(String startTime, String endTime) {
    return '-';
  }

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'ساعات هادئة _';
  }

  @override
  String get pushNotificationUfoAlert => 'UFO إنذار';

  @override
  String get pushNotificationAnomalyAlert => 'Anomaly Alert';

  @override
  String get pushNotificationNearby => 'تقريبا';

  @override
  String get pushNotificationInYourArea => 'في منطقتك تلاعب في التفاصيل.';

  @override
  String pushNotificationCommented(Object username) {
    return '_BAR_';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '_BAR_ _BAR_';
  }

  @override
  String get pushNotificationGeneric => 'UFOBeep';

  @override
  String get pushNotificationNewSighting => 'رؤية جديدة قريبة';

  @override
  String get language => 'اللغة';

  @override
  String get chooseLanguage => 'لغة الاختيار';

  @override
  String get units => 'الوحدات';

  @override
  String get unitsImperial => 'الإمبراطورية';

  @override
  String get unitsMetric => 'القياس';

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
  String get reportOnly => 'النص فقط';

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
    return 'قبل أيام';
  }

  @override
  String timeHoursAgo(int count) {
    return 'قبل ساعات';
  }

  @override
  String timeMinutesAgo(int count) {
    return 'قبل دقائق';
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
  String get timeFormat => 'الشكل الزمني';

  @override
  String get timeFormat24Hour => '24 ساعة';

  @override
  String get timeFormat12Hour => '12 ساعة';

  @override
  String get timeFormatDesc => 'وقت العرض على مدار الساعة أو 12 ساعة';

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
  String get showLess => 'عرض أقل';

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
  String get attachMedia => 'إرفاق الوسائط';

  @override
  String get addCommentOptional => 'يضاف تعليق (اختياري)';

  @override
  String get describeNewMedia => 'صفوا وسائل الإعلام الجديدة.';

  @override
  String get filesSelected => 'ملفات مختارة';

  @override
  String get selectMediaToAttach => 'يرجى اختيار الصور أو الفيديو الملحق بها';

  @override
  String get newMediaUploaded => 'تحميل وسائط الإعلام الجديدة';

  @override
  String get mediaFilesUploaded => 'ملفات إعلامية جديدة تم تحميلها';

  @override
  String get filesAttachedSuccessfully => 'الملفات المرفقة بنجاح';

  @override
  String get howToReportToMufon => 'How to Report to MUFON';

  @override
  String get reportToMufon => 'Report to MUFON';

  @override
  String get whyReportToMufon => 'لماذا نبلغ (مافون)؟?';

  @override
  String get openMufonReport => 'مفتوح التقرير';

  @override
  String get howToFormallyReport => 'How to Formally Report';

  @override
  String get formalReportingTitle => 'Formal UFO Reporting';

  @override
  String get ufobeepVsFormalReporting => 'UFOBeep vs Formal Reporting';

  @override
  String get reportingOrganizations => 'Reporting Organizations';

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
  String get noSatellitePasses =>
      'لم يتم العثور على تصاريح مرئية عبر الأقمار الصناعية';

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
  String get unknown => 'غير معروف';

  @override
  String get report => 'التقرير';

  @override
  String get mufon => 'mufon';

  @override
  String get recentUfoBeepsTitle => 'Recent UFO Beeps';

  @override
  String get recentUfoBeepsSubtitle => 'تقارير رؤية مباشرة من مجتمعنا العالمي';

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
  String get ufoSightingAlert => 'UFO إنذار محكم';

  @override
  String get previousPage => 'سابقا';

  @override
  String get nextPage => 'التالي';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Page ${currentPage}______________BAR_ _BAR_';
  }

  @override
  String get firstPage => 'أولا';

  @override
  String get lastPage => 'آخر';

  @override
  String get jumpToPage => 'اقفز على الصفحة';

  @override
  String get heroTagline =>
      'الحصول على تنبيهات عندما يذهب خارج وانظر إلى ما يصل';

  @override
  String get heroDescription => 'لا تفوت أبداً رؤية أخرى في منطقتك';

  @override
  String get downloadApp => 'Download App';

  @override
  String get viewAllBeeps => 'View All Beeps';

  @override
  String get sightingsMap => 'Sightings Map';

  @override
  String get globalSightingNetwork => 'Global Sighting Network';

  @override
  String get howItWorks => 'كيف يعمل';

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
    return '$count الصور';
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
  String get addedToUfobeep => 'مضافا إليها';

  @override
  String get mufonDatabaseReport => 'MUFON القضية رقم:';

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

  @override
  String get locationEnrichmentTitle => 'تفاصيل الموقع';

  @override
  String get aircraftDataSource => 'المصدر';

  @override
  String get noAircraftDetected => 'لم تكتشف أي طائرة';

  @override
  String get sightingReport => 'Sighting Report';

  @override
  String get ufoAlert => 'UFO إنذار';

  @override
  String get alert => 'إنذار';

  @override
  String get notificationTickerUfoAlert =>
      'إنذار من طراز UFO Alert - New Sighting Nearby';

  @override
  String get notificationTickerComment => 'تعليق جديد على تنبيه المنظمة';

  @override
  String get weatherConditions => 'أحوال الطقس';

  @override
  String get visibility => 'الرؤية';

  @override
  String get humidity => 'الهضمية';

  @override
  String get pressure => 'الضغط';

  @override
  String get locationDetails => 'تفاصيل الموقع';

  @override
  String get city => 'المدينة';

  @override
  String get state => 'الدولة';

  @override
  String get country => 'البلد';

  @override
  String get satelliteActivity => 'النشاط الساتلي';

  @override
  String get satellitesVisibleOverhead => 'سواتل مرئية في الموقع';

  @override
  String get dataSource => 'المصدر';

  @override
  String get blackskyImagery => 'بلاك سكاي';

  @override
  String get resolution => 'القرار';

  @override
  String get groundResolution => '35cm ground resolution';

  @override
  String get delivery => 'التسليم';

  @override
  String get averageDelivery => 'متوسط 90 دقيقة';

  @override
  String get cost => 'التكلفة';

  @override
  String get skyfiSatelliteImagery => 'ساتل SkyFi التصوير';

  @override
  String get region => 'المنطقة';

  @override
  String get remoteArea => 'المنطقة النائية';

  @override
  String get startingPrice => 'بدء الأسعار';

  @override
  String get coverage => 'التغطية';

  @override
  String get confidenceCoverage => 'ثقة 95 في المائة';

  @override
  String get status => 'الحالة';

  @override
  String get shareThoughts => 'شارك أفكارك حول هذا المنظر...';

  @override
  String get postCommand => 'القيادة';

  @override
  String get clouds => 'السحابات';

  @override
  String get windLabel => 'الرياح';

  @override
  String get filterAlerts => 'تنبيهات للملفات';

  @override
  String get alertSource => 'المصدر';

  @override
  String get ufobeepOnly => 'UFOBeep Only';

  @override
  String get ufobeepOnlyDescription =>
      'لا تظهر سوى التقارير الأصلية عن الأشعة فوق البنفسجية (باستثناء قاعدة بيانات مونفون)';

  @override
  String get alertDistanceRange => 'Alert Distance Range';

  @override
  String get showAllAlerts => 'اظهروا جميع التنبيهات';

  @override
  String get showAll => 'عرض';

  @override
  String get distanceSliderDescription =>
      'لنعدل إلى أي مدى تريد أن ترى تنبيهات ابدأ من مسافة ظهور الطقس حتى تظهر جميع الإنذارات بغض النظر عن المسافة.';

  @override
  String get applyFilters => 'ملفات التطبيق';

  @override
  String get notificationRange => 'الإخطار';

  @override
  String get notificationRangeDescription =>
      'الحصول على تنبيهات للمشاهدة في هذه المسافة';

  @override
  String get viewingRange => 'Viewing Range';

  @override
  String get viewingRangeDescription => 'مشاهدات في هذه المسافة';

  @override
  String get weatherVisibility => 'Weather Visibility (~10km)';

  @override
  String get localArea => 'المنطقة المحلية (25 كيلومترا)';

  @override
  String get regional => 'إقليمي';

  @override
  String get pushNotifications => 'الإخطارات بالدفع';

  @override
  String get alertBrowsing => 'إنذار بروز';

  @override
  String get pushAlertsWithinDistance => 'الحصول على الإخطارات في هذا النطاق';

  @override
  String get showAlertsWhenBrowsing => 'اكتب ما تراه في القائمة';

  @override
  String get heroMainTagline =>
      'الحصول على الصافرة على هاتفك عندما يتم رصد الأجسام الطائرة في الجوار';

  @override
  String get heroSecondaryTagline => 'معرفة متى وأين للنظر إلى السماء';

  @override
  String get sourceFilters => 'المصدر';

  @override
  String get sourceFiltersDescription => 'اختر أي تقارير تظهر في غلافك';

  @override
  String get ufobeepAndMufon => 'UFOBeep + MUFON';

  @override
  String get ufobeepOnlySource => 'UFOBeep فقط';

  @override
  String get mufonOnlySource => 'فقط';

  @override
  String get browseFilters => 'Browse';

  @override
  String get browseFiltersDescription => 'كيفية مشاهدة وفرز الإنذارات';

  @override
  String get sortByNewest => 'Newest';

  @override
  String get sortByNearest => 'أقرب';

  @override
  String get sortBy => 'نوعا ما';

  @override
  String get pushAlertsTitle => 'تنبيهات';

  @override
  String get pushAlertsDescription => 'ما يدق هاتفك';

  @override
  String get alertRadius => 'Alert Radius';

  @override
  String get mufonNoPushInfo =>
      'تستورد تقارير وزارة المالية الوطنية ليلاً ولا تطلق إنذارات بالدفع';

  @override
  String get privacyData => 'بيانات الخصوصية';

  @override
  String get privacyPolicyDesc => 'كيف نحمي ونستخدم بياناتك';

  @override
  String get termsOfService => 'مدة الخدمة';

  @override
  String get termsOfServiceDesc => 'الأحكام والشروط القانونية';

  @override
  String get locationTracking => 'تعقب الموقع';

  @override
  String get locationTrackingDesc => 'موقع معلومات أساسية لتنبيهات القرب';

  @override
  String get locationTrackingTitle => 'تعقب مواقع المعلومات الأساسية';

  @override
  String get locationTrackingExplanation =>
      'يُراقبُ موقعَكَ في الخلفيةِ لإرسالك تنبيهاتِ قريبةِ عندما يُشاهدُ UFO بالقرب مِنْ موقعِكَ الحاليِ،.';

  @override
  String get locationTrackingBattery =>
      'Uses intelligent geofencing for 3% bat impact';

  @override
  String get backgroundLocationTracking => 'معلومات أساسية التعقب';

  @override
  String get locationTrackingActive => 'رصد مواقع تنبيهات القرب';

  @override
  String get locationTrackingInactive => 'تعقب الموقع معوق';

  @override
  String get locationTrackingDisabledWarning =>
      'لن تتلقى إنذارات عن قرب عندما تنتقل إلى مواقع جديدة';

  @override
  String get trackingStatus => 'Tracking Status';

  @override
  String get monitoringStatus => 'الرصد';

  @override
  String get active => 'النشاط';

  @override
  String get inactive => 'غير فعال';

  @override
  String get lastKnownLocation => 'آخر مكان معروف';

  @override
  String get lastLocationUpdate => 'آخر تحديث';

  @override
  String get movementThreshold => 'Movement Threshold';

  @override
  String get updateFrequency => 'تحديث التردد';

  @override
  String get batteryImpact => 'Battery Impact';

  @override
  String get dataPrivacy => 'خصوصية البيانات';

  @override
  String get locationPermissionExplanation =>
      'يَحتاجُ UFOBeep \'\'Always السماح الموقع لمراقبة حركةِكَ وإرسال إنذارات قريبةِ عندما أنت في مواقعِ جديدةِ.';

  @override
  String get benefitsTitle => 'الاستحقاقات';

  @override
  String get locationTrackingBenefits =>
      '• احصل على تنبيهات الأجسام الطائرة المجهولة أينما سافرت\n• تحديثات الموقع التلقائية\n• لا يلزم الإعداد اليدوي';

  @override
  String get allowLocationAccess => 'السماح بالوصول إلى الموقع';

  @override
  String get locationPermissionRequired =>
      'يلزم الحصول على إذن بالأماكن لتتبع المعلومات الأساسية';

  @override
  String get locationTrackingEnabled => 'تيسير تتبع مواقع المعلومات الأساسية';

  @override
  String get locationTrackingDisabled => 'تعقب المواقع الخلفية';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int minutes) {
    return 'قبل دقائق';
  }

  @override
  String hoursAgo(int hours) {
    return 'قبل ساعات';
  }

  @override
  String daysAgo(int days) {
    return 'قبل أيام';
  }

  @override
  String get dataManagement => 'إدارة البيانات';

  @override
  String get dataManagementDesc => 'تصدير أو حذف بيانات حسابك';

  @override
  String get splashTagline => 'تنبيهات في الوقت الحقيقي';

  @override
  String get splashStartingUp => 'بدأت...';

  @override
  String get splashInitializationFailed => 'فشل بدء التشغيل';

  @override
  String get splashInitializationFailedTitle => 'عدم البدء';

  @override
  String get splashInitializationError =>
      'The app failed to initialize properly:';

  @override
  String get splashRetry => 'Retry';

  @override
  String get splashContinue => 'استمر';

  @override
  String get splashInitializing => 'بدء...';

  @override
  String signInWelcome(String username) {
    return 'مرحباً بك!';
  }

  @override
  String signInFailed(String error) {
    return 'لقد فشلت الإشارة: _';
  }

  @override
  String get signInPleaseEnterEmail => 'من فضلك أدخل عنوان البريد الإلكتروني';

  @override
  String get signInPleaseEnterValidEmail =>
      'يرجى الدخول إلى عنوان بريد إلكتروني صحيح';

  @override
  String get signInMagicLinkSent =>
      'وصلة سحرية أرسلت! تحقق من بريدك الإلكتروني ونقر الرابط للتوقيع.';

  @override
  String get signInMagicLinkFailed =>
      'فشلت في إرسال رابط سحري أرجوك حاول مرة أخرى.';

  @override
  String get signInAllDataCleared => 'جميع البيانات';

  @override
  String get signInSubtitle =>
      'تنبيهات مرئية من طراز UFO في الوقت الحقيقي وتقارير MUFON';

  @override
  String get signInGoogleLoading => 'التوقيع في...';

  @override
  String get signInContinueWithGoogle => 'استمر مع جوجل';

  @override
  String get signInOr => 'أو';

  @override
  String get signInWithEmail => 'وقع مع البريد الإلكتروني';

  @override
  String get signInEmailDescription => 'سنرسل لك وصلة آمنة للتوقيع';

  @override
  String get signInEmailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get signInEmailPlaceholder => '@email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'حاول مرة أخرى في';
  }

  @override
  String get signInSending => 'إرسال...';

  @override
  String get signInSendMagicLink => 'أرسل لينك السحري';

  @override
  String get signInCheckEmail => 'تحقق من بريدك الرابط ينتهي بعد 15 دقيقة.';

  @override
  String get signInSecureAuth => 'السلامة';

  @override
  String get signInSecureAuthDescription =>
      'استخدموا موقع (جوجل) للولوج الفوري، أو وصلات سحرية بالبريد الإلكتروني تنتهي خلال 15 دقيقة.';

  @override
  String get signInClearAllDataDebug => 'All Data (Debug)';

  @override
  String get emailAuthFailedToSend => 'فشل في إرسال البريد الإلكتروني';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'فشل في إرسال البريد الإلكتروني. أرجوك حاول مرة أخرى.';

  @override
  String get emailAuthInvalidEmail =>
      'عنوان بريد إلكتروني غير رسمي يرجى التحقق من الشكل.';

  @override
  String get emailAuthUserNotFound => 'لم يعثر على حساب بهذا العنوان.';

  @override
  String get emailAuthTooManyRequests =>
      'الكثير من المحاولات حاول مرة أخرى لاحقاً.';

  @override
  String get emailAuthOperationNotAllowed => 'لا يمكن للربطة البريدية.';

  @override
  String get emailAuthQuotaExceeded => 'تم تجاوز حصة البريد حاول مرة أخرى غدا.';

  @override
  String get emailAuthVerificationFailed =>
      'فشل التحقق من البريد الإلكتروني. أرجوك حاول مرة أخرى.';

  @override
  String get emailAuthTitle => 'التحقق من البريد الإلكتروني';

  @override
  String get emailAuthVerifyYourEmail => 'تحقق من بريدك الإلكتروني';

  @override
  String get emailAuthDescription =>
      'أضف عنوان البريد الإلكتروني الخاص بك لاسترداد الحسابات والأمن. سنرسل لك وصلة إشارة آمنة.';

  @override
  String get emailAuthEmailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get emailAuthEmailPlaceholder => 'your.email@example.com';

  @override
  String get emailAuthPleaseEnterEmail =>
      'من فضلك أدخل عنوان البريد الإلكتروني';

  @override
  String get emailAuthPleaseEnterValidEmail =>
      'يرجى الدخول إلى عنوان بريد إلكتروني صحيح';

  @override
  String get emailAuthCheckEmailToContinue =>
      'تحقق من بريدك الإلكتروني وتسجل وصلة التحقق للاستمرار.';

  @override
  String get emailAuthResendEmail => 'Resend Email';

  @override
  String get emailAuthSendVerificationEmail => 'إرسال Email';

  @override
  String get emailAuthHowItWorks => 'How Email Verification Works';

  @override
  String get emailAuthHowItWorksSteps =>
      '1 نرسل لك وصلة مؤمنة\n2. تحقق من البريد الإلكتروني الخاص بك وتسجل الرابط\n3 بريدك الإلكتروني يتم التحقق منه تلقائياً\n4 لا حاجة لأي كلمة سر!';

  @override
  String get emailAuthSecurityNotice =>
      'التحقق من البريد الإلكتروني يساعد على تأمين حسابك ويمكّن من استرداد الحساب إذا فقدت إمكانية الوصول إلى جهازك.';

  @override
  String get phoneAuthFailedToSendCode =>
      'فشل في إرسال رمز التحقق. أرجوك حاول مرة أخرى.';

  @override
  String get phoneAuthInvalidCodeTryAgain =>
      'رمز التحقق غير المتوافق أرجوك حاول مرة أخرى.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'تم التحقق من رقم الهاتف: _';
  }

  @override
  String get phoneAuthVerificationFailed =>
      'فشل التحقق من الهواتف. أرجوك حاول مرة أخرى.';

  @override
  String get phoneAuthCodeResent => 'الموافقة على مدونة التحقق';

  @override
  String get phoneAuthFailedToResendCode =>
      'فشل في إلغاء الشفرة أرجوك حاول مرة أخرى.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'رقم هاتف غير مستقر يرجى التحقق من الشكل.';

  @override
  String get phoneAuthTooManyRequests =>
      'الكثير من المحاولات حاول مرة أخرى لاحقاً.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'رمز التحقق غير المتوافق من فضلك تحقق وحاول مرة أخرى.';

  @override
  String get phoneAuthSessionExpired => 'انتهت دورة التحقق. يرجى طلب رمز جديد.';

  @override
  String get phoneAuthSmsQuotaExceeded => 'وتجاوزت الحصة. حاول مرة أخرى غدا.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'هذا الهاتف مرتبط بالفعل بحساب آخر.';

  @override
  String get phoneAuthVerificationFailedGeneric =>
      'فشل التحقق. أرجوك حاول مرة أخرى.';

  @override
  String get phoneAuthTitle => 'التحقق من الهواتف';

  @override
  String get phoneAuthVerifyYourPhone => 'تحقق من هاتفك';

  @override
  String get phoneAuthEnterVerificationCode => 'التحقق المدونة';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'أضف رقم هاتفك لاسترداد الحسابات والأمن';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return 'أدخل رمز 6 أرقام المرسل إلى';
  }

  @override
  String get phoneAuthPhoneNumber => 'رقم الهاتف';

  @override
  String get phoneAuthPhonePlaceholder => '+1 (555) 123-4567';

  @override
  String get phoneAuthPleaseEnterPhone => 'من فضلك أدخل رقم هاتفك';

  @override
  String get phoneAuthPleaseEnterValidPhone => 'من فضلك أدخل رقم هاتف صالح';

  @override
  String get phoneAuthVerificationCode => 'مدونة التحقق';

  @override
  String get phoneAuthPleaseEnterSixDigitCode => 'من فضلك أدخل رمز 6 أرقام';

  @override
  String get phoneAuthResendCode => 'قانون الاسترداد';

  @override
  String get phoneAuthSendVerificationCode => 'إرسال المدونة';

  @override
  String get phoneAuthVerifyCode => 'قانون التصديق';

  @override
  String get phoneAuthChangePhoneNumber => 'رقم الهاتف';

  @override
  String get phoneAuthSmsNotice =>
      'سوف نرسل لك رمز التحقق عبر SMS. ويمكن تطبيق معدلات الرسائل القياسية.';

  @override
  String get phoneAuthCodeExpires =>
      'ينتهي القانون خلال 60 ثانية تحقق من رسائلك.';

  @override
  String get yourDataRights => 'حقوق بياناتك';

  @override
  String get dataRightsExplanation =>
      'لديك السيطرة الكاملة على بياناتك الشخصية يمكنك تصدير كل بياناتك أو حذف حسابك بشكل دائم في أي وقت.';

  @override
  String get exportYourData => 'تصدير بياناتك';

  @override
  String get exportDataDescription => 'تحميل جميع بيانات حسابك';

  @override
  String get exportData => 'بيانات التصدير';

  @override
  String get exportingData => 'التصدير...';

  @override
  String get exportDataDetails =>
      'بما في ذلك: الموجز، والبيب، والتعليقات، والمعلومات عن الأجهزة، والأفضليات. وترد البيانات في شكل \" JSON \" .';

  @override
  String get dataExportedSuccessfully => 'البيانات المصدرة بنجاح';

  @override
  String get dataExportFailed => 'المقصرة على بيانات التصدير';

  @override
  String get deleteAccount => 'يحذف الحساب';

  @override
  String get deleteAccountDescription => 'اسحب حسابك بشكل دائم وجميع البيانات';

  @override
  String get deleteAccountWarning =>
      'هذا العمل لا يمكن أن يزول. كل الصافرة والتعليقات والبيانات الحسابية ستحذف بشكل دائم.';

  @override
  String get deleteMyAccount => 'يحذف حسابي';

  @override
  String get deletingAccount => 'إلغاء...';

  @override
  String get deleteAccountConfirmTitle => 'يحذف الحساب';

  @override
  String get deleteAccountConfirmMessage =>
      'هل أنت متأكد أنك تريد حذف حسابك؟ إن هذا العمل دائم ولا يمكن أن يتراجع.';

  @override
  String get dataWillBeDeleted => 'وستحذف البيانات التالية بصفة دائمة:';

  @override
  String get deletedDataList =>
      '• ملفك الشخصي واسم المستخدم\n• كل الصافرات والتقارير\n• كل تعليقاتك\n● بيانات تسجيل الأجهزة\n● بيانات الموقع والأفضليات';

  @override
  String get deleteAccountPermanent => 'تحذف بصفة دائمة';

  @override
  String get accountDeletedSuccessfully => 'الحساب المحذوف بنجاح';

  @override
  String get accountDeletionFailed => 'عدم حذف الحساب';

  @override
  String get onboardingWelcomeTitle => 'مرحبا بكم في UFOBeep';

  @override
  String get onboardingWelcomeBody =>
      'الحصول على تنبيهات في الوقت الحقيقي عندما يتم رصد طائرات يو إف أو في الجوار. لا تفوتني رؤية ثانية.';

  @override
  String get onboardingAlertsTitle => 'ابقوا على علم';

  @override
  String get onboardingAlertsBody =>
      'حددوا كم ينبغي أن تكون المشاهدات بعيدة عن الأنذار.';

  @override
  String get onboardingReportTitle => 'أترى شيئاً؟ !';

  @override
  String get onboardingReportBody =>
      'نلتقط صورة أو شريط فيديو ونتشارك على الفور مع المشاهدين المجاورين.';

  @override
  String get onboardingPermissionsTitle => 'موقعكم';

  @override
  String get onboardingPermissionsBody =>
      'آلة تصوير وموقع وإخطارات حتى تتمكن من:\n- مشاهدة التقارير بسرعة\n- إحصلْ على تنبيهاتِ مِنْ طائراتِ UFO بالقرب منك';

  @override
  String get onboardingCameraTitle => 'الأدلة';

  @override
  String get onboardingCameraBody =>
      'نتشارك الصور والفيديوات التي التقطتها للتو من معرضك أو كاميرا طويلة.';

  @override
  String get onboardingCompassTitle => 'انظر إلى أين بدوا';

  @override
  String get onboardingCompassBody =>
      'البوصلة تُظهر لك الإتجاه الذي كان ينظر إليه الشاهد عندما رأوا مكتب الطوارئ صوب هاتفك وانظر!';

  @override
  String get onboardingCommunityTitle => 'انضموا إلى \"سكاي واتش\"';

  @override
  String get onboardingCommunityBody =>
      'مشاهدات الحشد، الوصول إلى تقارير (مافون) والتواصل مع الزملاء المشاهدين.';

  @override
  String get skip => 'تخطي';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get viewOnboardingAgain => 'مشاهدة على متن الطائرة مرة أخرى';

  @override
  String get customAlertRange => 'إنذار عرفي';

  @override
  String get enterRangeKm => 'مدى الدخول في الكيلومترات (1-99999)';

  @override
  String get largeRangeWarning => 'قد تولد تنبيهات كثيرة';

  @override
  String get globalRangeWarning =>
      'مجموعة كبيرة جداً سترسل لك تنبيهات من جميع أنحاء العالم';

  @override
  String get invalidRange => 'يرجى الدخول إلى رقم يتراوح بين 1 و 999';

  @override
  String get celestialSunDaylight =>
      'الشمس مستيقظه ظروف النهار قد تؤثر على الرؤية';

  @override
  String get celestialSunTwilight =>
      'ظروف توايلايت بعض الوضوح ولكن أكثر ظلما من ضوء النهار';

  @override
  String get celestialSunDark =>
      'الظروف المظلمة - أمثل لمراقبة الأجسام في السماء';

  @override
  String celestialMoonBright(Object phase) {
    return '? Bright';
  }

  @override
  String celestialMoonModerate(Object phase) {
    return '_PLACEHOLDER_0_قمر مرئي - ظروف إضاءة متوسطة';
  }

  @override
  String celestialMoonThin(Object phase) {
    return '...';
  }

  @override
  String celestialMoonHidden(Object phase) {
    return '_BAR_';
  }

  @override
  String get celestialNoPlanets =>
      'لا توجد كواكب مشرقة مرئية يمكن أن تكون مُخطئة بالنسبة للأجسام الطائرة';

  @override
  String celestialPlanetHigh(Object altitude, Object planet) {
    return '${altitude}__ مرتفعات ($planet°) -';
  }

  @override
  String celestialPlanetMedium(Object altitude, Object planet) {
    return '$planet مرئي عند $altitude ° - يمكن أن يخطئ في الطائرات';
  }

  @override
  String celestialPlanetLow(Object altitude, Object planet) {
    return '$planet منخفض على الأفق (_PLACEHOLDER_1_°)';
  }

  @override
  String get celestialNoStars => 'لا نجوم مشرقة بشكل غير عادي مرئية';

  @override
  String celestialStarSingle(Object altitude, Object star) {
    return '_BAR_';
  }

  @override
  String celestialStarsMultiple(Object count, Object names) {
    return '_BAR_ _BAR_';
  }

  @override
  String get celestialSummaryDaylight => 'الظروف النهارية';

  @override
  String get celestialSummaryDark => 'السماء المظلمة';

  @override
  String get celestialSummaryMoonUp => 'القمر';

  @override
  String get celestialSummaryMoonDown => 'لا ضوء القمر';

  @override
  String celestialSummaryManyObjects(Object count) {
    return 'الأشياء المشرقة التي يمكن الخلط بينها';
  }

  @override
  String celestialSummarySomeObjects(Object count) {
    return '${count}_BAR_';
  }

  @override
  String get celestialSummaryFewObjects =>
      'الحد الأدنى من الأشياء المشرقة في السماء';

  @override
  String celestialSkySummary(Object conditions) {
    return 'Sky conditions: _';
  }

  @override
  String get planetVenus => 'Venus';

  @override
  String get planetJupiter => 'المشتري';

  @override
  String get planetSaturn => 'زحل';

  @override
  String get planetMars => 'المريخ';

  @override
  String get planetMercury => 'الزئبق';

  @override
  String get planetUranus => 'Uranus';

  @override
  String get planetNeptune => 'Neptune';

  @override
  String get starSirius => 'Sirius';

  @override
  String get starCanopus => 'Canopus';

  @override
  String get starArcturus => 'المحاضرات';

  @override
  String get starVega => 'Vega';

  @override
  String get starCapella => 'Capella';

  @override
  String get starRigel => 'ريغل';

  @override
  String get starProcyon => 'Procyon';

  @override
  String get starBetelgeuse => 'Betelgeuse';

  @override
  String get moonPhaseNew => 'القمر الجديد';

  @override
  String get moonPhaseWaxingCrescent => 'واكس الهلال';

  @override
  String get moonPhaseFirstQuarter => 'الربع الأول';

  @override
  String get moonPhaseWaxingGibbous => 'واكس جيبوس';

  @override
  String get moonPhaseFull => 'القمر الكامل';

  @override
  String get moonPhaseWaningGibbous => 'Waning Gibbous';

  @override
  String get moonPhaseThirdQuarter => 'الربع الثالث';

  @override
  String get moonPhaseWaningCrescent => 'Waning Industries';

  @override
  String planetBelowHorizon(Object planet) {
    return '_BAR_';
  }

  @override
  String planetHighOverheadProminent(Object altitude, Object planet) {
    return '${altitude}__ مرتفعات ($planet°) -';
  }

  @override
  String planetMidSkyProminent(Object altitude, Object planet) {
    return '_';
  }

  @override
  String planetMidSky(Object altitude, Object planet) {
    return '_';
  }

  @override
  String starVeryBright(Object altitude, Object star) {
    return '_BAR_ _BAR_';
  }

  @override
  String starProminent(Object altitude, Object star) {
    return '_BAR_';
  }

  @override
  String starVisible(Object altitude, Object star) {
    return '_';
  }

  @override
  String get altitudeShort => 'Alt';

  @override
  String get magnitudeShort => 'Mag';

  @override
  String satellitesVisibleMightExplain(Object count) {
    return 'قد يفسر الرؤية';
  }

  @override
  String satellitesVisibleUnlikelyExplain(Object count) {
    return '$count الأقمار الصناعية المرئية - من غير المرجح أن تفسر الرؤية';
  }

  @override
  String get noSatellitesVisible => 'لا توجد سواتل مرئية';

  @override
  String aircraftDetectedInRadius(Object count, Object radius) {
    return '_BAR_ _BAR_';
  }

  @override
  String get processingAlert => 'تجهيز إنذار \"يو إف أو\".';

  @override
  String get analyzingEnvironment => 'تحليل الظروف البيئية';

  @override
  String get weatherAnalysis => 'تحليل الطقس';

  @override
  String get locationAnalysis => 'تحليل الموقع';

  @override
  String get aircraftTracking => 'تعقب الطائرات';

  @override
  String get satelliteAnalysis => 'التحليل الساتلي';

  @override
  String get celestialAnalysis => 'تحليل المهرجان';

  @override
  String analyzing(Object processor) {
    return 'تحليل.';
  }

  @override
  String get processorWeather => 'الأحوال الجوية';

  @override
  String get processorLocation => 'تفاصيل الموقع';

  @override
  String get processorAircraft => 'طائرة قريبة';

  @override
  String get processorSatellites => 'المواقع الساتلية';

  @override
  String get processorCelestial => 'الأجسام السماوية';

  @override
  String get calculatingCelestialData => 'حساب البيانات السماوية...';

  @override
  String get sunLabel => 'الشمس';

  @override
  String get moonLabel => 'القمر';

  @override
  String planetsVisible(int count) {
    return 'الكواكب: $count مرئي';
  }

  @override
  String get starsLabel => 'النجوم';

  @override
  String get planetsLabel => 'Planets';

  @override
  String moonWithPhase(String phase) {
    return 'مون (_PLACEHOLDER_0__)';
  }

  @override
  String get noSatellitesVisibleAtTime =>
      'لم يكن هناك سواتل مرئية في نفس الوقت من رؤيتك';

  @override
  String get satellitesVisibleOverheadAtTime => 'سواتل مرئية في الموقع';

  @override
  String get belowHorizon => 'أقل من الأفق';

  @override
  String get analysisFailedGeneric => 'التحليل غير مكتمل';

  @override
  String get unknownWeather => 'غير معروف';

  @override
  String get noWeatherDescription => 'لا وصف';

  @override
  String get altitudeAbbrev => 'Alt';

  @override
  String get azimuthAbbrev => 'Az';

  @override
  String satellitesVisibleNow(int count) {
    return 'السواتل (_PLACEHOLDER_0__ مرئية الآن)';
  }

  @override
  String sunWithDescription(String description) {
    return 'شمس:';
  }

  @override
  String moonWithDescription(String description) {
    return 'القمر:';
  }

  @override
  String get unknownPlanet => 'Unknown Planet';

  @override
  String get unknownStar => 'نجم مجهول';

  @override
  String get unknownSatellite => 'ساتل غير معروف';

  @override
  String get unknownDirection => 'اتجاه مجهول';

  @override
  String get brightStars => 'النجوم الجميلة';

  @override
  String get satellites => 'السواتل';

  @override
  String seeAllSatellites(int count) {
    return 'انظر جميع سواتل';
  }

  @override
  String maxElevation(String degrees) {
    return '(ماكس) _';
  }

  @override
  String magnitude(String value) {
    return 'الصلاحية: _';
  }

  @override
  String get unknownGeneric => 'غير معروف';

  @override
  String altitudeValue(String degrees) {
    return '_BAR_';
  }

  @override
  String azimuthValue(String degrees) {
    return '_BAR_';
  }

  @override
  String get noCelestialDataAvailable => 'لا توجد بيانات سماوية متاحة.';

  @override
  String get gettingLocation => 'الحصول على موقعك...';

  @override
  String get media => 'وسائط الإعلام';

  @override
  String get locationRequired => 'الموقع المطلوب';

  @override
  String get confirmingWitness => 'تأكيد الشاهد...';

  @override
  String get chooseYourUsername => 'اختر اسم مستعملك';

  @override
  String get moreNames => 'المزيد من الأسماء';

  @override
  String get notificationSettings => 'مجموعة الإخطارات';

  @override
  String get quickActions => 'الإجراءات السريعة';

  @override
  String get doNotDisturb => 'لا تغضب';

  @override
  String get temporarilySilenceNotifications => 'الصمت المؤقت لجميع الإخطارات';

  @override
  String get oneHour => '1ح';

  @override
  String get eightHours => '8h';

  @override
  String get oneDay => 'يوم واحد';

  @override
  String get startTime => 'بدء';

  @override
  String get endTime => 'نهاية الوقت';

  @override
  String get allowCriticalAlertsDuringQuietHours =>
      'السماح بالإنذارات الحرجة خلال ساعات الهدوء';

  @override
  String get silenceNotificationsDuringSleepHours =>
      'إخطارات الصمت خلال ساعات النوم';

  @override
  String quietHoursActiveTimeRange(String startTime, String endTime) {
    return '-';
  }

  @override
  String get followingAlerts => 'بعد إنذار';

  @override
  String activeCount(int count) {
    return '_BAR_ _BAR_ _BAR_';
  }

  @override
  String get unfollow => 'Unfollow';

  @override
  String get unfollowAlert => 'إنذار غير متوفر';

  @override
  String commentsCount(int count) {
    return '_';
  }

  @override
  String get photo => 'الصورة';

  @override
  String get video => 'Video';

  @override
  String get initializationComplete => 'التمهيد مكتمل!';

  @override
  String get validatingEnvironment => 'البيئة المقيّمة...';

  @override
  String get requestingPermissions => 'طلب الإذن.';

  @override
  String get loadingAuthSession => '....';

  @override
  String get checkingUserRegistration => 'التحقق من تسجيل المستخدمين...';

  @override
  String get loadingPreferences => 'الأفضليات...';

  @override
  String get settingUpLocalization => '....';

  @override
  String get checkingConnectivity => 'التحقق من التواصل...';

  @override
  String get gatheringDeviceInfo => 'جمع المعلومات عن الجهاز.';

  @override
  String get translating => 'ترجمة...';

  @override
  String get showOriginal => 'العرض الأصلي';

  @override
  String translateTo(String language) {
    return 'Translate to __PLACEHOLDER_0';
  }

  @override
  String translatedFrom(String language) {
    return 'Translated from __PLACEHOLDER_0';
  }

  @override
  String translateContent(String language) {
    return 'Translate content to __PLACEHOLDER_0';
  }

  @override
  String get weatherClear => 'آمن';

  @override
  String get weatherClearSky => 'السماء';

  @override
  String get rain => 'Rain';

  @override
  String get snow => 'Snow';

  @override
  String get thunderstorm => 'Thunderstorm';

  @override
  String get drizzle => 'Drizzle';

  @override
  String get fog => 'Fog';

  @override
  String get fewClouds => 'بعض الغيوم';

  @override
  String get scatteredClouds => 'سحابات مبعثرة';

  @override
  String get brokenClouds => 'سحابات مكسورة';

  @override
  String get overcastClouds => 'الغيوم المنبعثة';

  @override
  String get lightRain => 'الأمطار الخفيفة';

  @override
  String get moderateRain => 'الأمطار المتوسطة';

  @override
  String get heavyRain => 'الأمطار الغزيرة';

  @override
  String aircraftDetectedCurrentPositions(
    int count,
    String radius,
    Object raggio,
  ) {
    return '$count تم اكتشاف الطائرات ضمن $radius كم (المواقع الحالية)';
  }

  @override
  String dimSatellitesUnlikely(int count) {
    return '$count الأقمار الصناعية الخافتة المرئية - من غير المرجح أن تفسر الرؤية';
  }

  @override
  String get mufonReportingDate => 'MUFON التاريخ';

  @override
  String satelliteNameDirection(String name, String direction) {
    return '_';
  }
}
