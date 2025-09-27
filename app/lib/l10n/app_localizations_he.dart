// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appName => 'עב\"ם';

  @override
  String get ok => 'בסדר';

  @override
  String get cancel => 'ביטול';

  @override
  String get close => 'סגור';

  @override
  String get save => 'להציל';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Editעריכה';

  @override
  String get retry => 'Retry';

  @override
  String get yes => 'כן';

  @override
  String get no => 'לא';

  @override
  String get back => 'בחזרה';

  @override
  String get next => 'הבא';

  @override
  String get done => 'עשה';

  @override
  String get loading => 'לטעון..';

  @override
  String get processing => 'עיבוד..';

  @override
  String get errorGeneric => 'משהו השתבש.';

  @override
  String get networkError => 'טעות ברשת בדוק את הקשר שלך.';

  @override
  String get permissionsRequired => 'אישורים דרושים';

  @override
  String get learnMore => 'למד עוד';

  @override
  String get welcomeTitle => 'ברוכים הבאים ל- UFOBeep';

  @override
  String get welcomeSubtitle => 'אזהרות עב\"מים בזמן אמת לידך';

  @override
  String get signIn => 'היכנס';

  @override
  String get signOut => 'המונחים';

  @override
  String get continueAsGuest => 'להמשיך כאורח';

  @override
  String get enterUsername => 'הכנס שם משתמש';

  @override
  String get username => 'שם המשתמש';

  @override
  String get usernameUpdated => 'שם המשתמש מעודכן';

  @override
  String get profile => 'פרופיל';

  @override
  String get settings => 'הגדרות';

  @override
  String get tabAlerts => 'התראות';

  @override
  String get tabBeep => 'Beep';

  @override
  String get tabChat => 'צ\'אט Chat';

  @override
  String get tabMap => 'מפה';

  @override
  String get tabSettings => 'הגדרות';

  @override
  String get alertsTitle => 'התראות בקרבת מקום';

  @override
  String get noAlerts => 'עדיין לא אזהרות.';

  @override
  String get pullToRefresh => 'למשוך כדי לרענן';

  @override
  String alertDistance(String distance) {
    return 'שם הסרטון: PLACEHOLDER_0_Out_';
  }

  @override
  String alertDirection(int bearing) {
    return 'תגית: PLACEHOLDER_0_ °';
  }

  @override
  String get viewAlert => 'View alert';

  @override
  String get viewOnMap => 'צפייה במפה';

  @override
  String get iSeeItToo => 'אני רואה את זה גם';

  @override
  String get confirmWitnessed => 'האם הייתם עדים למראה הזה?';

  @override
  String get witnessConfirmed => 'תודה – האישור שלך פורסם.';

  @override
  String get createBeepTitle => 'שלח ביפ';

  @override
  String get beepExplain => 'לתפוס את מה שאתה רואה ולהזהיר צופים סמוכים.';

  @override
  String get capturePhoto => 'ללכוד תמונה';

  @override
  String get captureVideo => 'ללכוד וידאו';

  @override
  String get pickFromGallery => 'בחרו בגלריה';

  @override
  String get descriptionHint => 'תאר מה אתה רואה בשמים..';

  @override
  String get submitBeep => 'שלח Beep';

  @override
  String get beepSent => 'Beep';

  @override
  String beepSentWithUrl(String shortUrl) {
    return 'Beep שלח בהצלחה';
  }

  @override
  String get uploadingMedia => 'העלאת אמצעי התקשורת..';

  @override
  String get includeLocation => 'כולל מיקום';

  @override
  String get includeTimestamp => 'עקבו אחרי Timestamp';

  @override
  String get beepFailed => 'נכשל לשלוח את Beep.';

  @override
  String get mediaProcessing => 'אמצעי עיבוד..';

  @override
  String get cameraPermissionTitle => 'גישה למצלמה הנדרשת';

  @override
  String get cameraPermissionBody =>
      'גישה למצלמה ללכידת תמונות וסרטונים עב\"מים.';

  @override
  String get locationPermissionTitle => 'אישור מיקום נדרש';

  @override
  String get locationPermissionBody =>
      'אנו משתמשים במיקום שלך כדי לשלוח ולקבל התראות הקרובות.';

  @override
  String get microphonePermissionTitle => 'גישה מיקרו-טלפון הנדרשת';

  @override
  String get microphonePermissionBody =>
      'גישה מיקרופון עבור וידאו לכידת עם אודיו.';

  @override
  String get openSettings => 'הגדרות פתוחות';

  @override
  String get alertDetailTitle => 'פרטים';

  @override
  String reportedBy(String username) {
    return 'תגית: PLACEHOLDER_0_____';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'תגית: PLACEHOLDER_0______';
  }

  @override
  String distanceAway(String distance) {
    return 'שם הסרטון: PLACEHOLDER_0______';
  }

  @override
  String bearingToObject(int bearing) {
    return 'תגית:_PLACEHOLDER_0_ °';
  }

  @override
  String get openCompass => 'המצפן הפתוח';

  @override
  String get openAR => 'פתח את AR Overlay';

  @override
  String get openChat => 'צ\'אט פתוח';

  @override
  String get commentsTitle => 'הערות';

  @override
  String get addComment => 'הוסף תגובה..';

  @override
  String get send => 'שלח';

  @override
  String get commentPosted => 'תגית:';

  @override
  String get autoFollowEnabled => 'עכשיו אתה עוקב אחר האזהרה הזו.';

  @override
  String get noCommentsYet => 'עדיין לא הערות. להיות הראשון להגיב!';

  @override
  String get newCommentNotification => 'תגובה חדשה על מראה שאתה עוקב.';

  @override
  String get mapTitle => 'מפה חיה';

  @override
  String get compassTitle => 'Compass';

  @override
  String get compassSettings => 'הגדרות Compass';

  @override
  String get compassMode => 'המונחים:';

  @override
  String get compassStandardMode => 'מצב סטנדרטי';

  @override
  String get compassPilotMode => 'מצב טייס';

  @override
  String get compassStandardDescription => 'כותרות בסיסיות וניווט';

  @override
  String get compassPilotDescription => 'ניווט מתקדם עם ETA וקטורינג';

  @override
  String pointingTo(String direction) {
    return 'תגית: PLACEHOLDER_0_________';
  }

  @override
  String get calibratingCompass => 'מצפן קצר..';

  @override
  String get openAROverlay => 'פתח את AR Overlay';

  @override
  String get pushTitleAlertNearby => 'אזהרות עב\"מ קרוב אליך';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'מראה חדש דווח -_PLACEHOLDER_0____.';
  }

  @override
  String get pushTitleComment => 'תגובה חדשה';

  @override
  String get pushBodyComment => 'מישהו אמר על מראה שאתה עוקב.';

  @override
  String get pushTitleWitness => 'אישור עדים';

  @override
  String get temperature => 'טמפרטורה';

  @override
  String get pushBodyWitness => 'משתמש אישר שהוא רואה את אותו האובייקט.';

  @override
  String get weather => 'מזג אוויר';

  @override
  String cloudCover(int percent) {
    return 'כיסוי ענן: PLACEHOLDER_0_%';
  }

  @override
  String wind(num speed, String unit) {
    return 'רוח:_PLACEHOLDER_0___${unit}_____________________________________________________';
  }

  @override
  String get nearbyAircraft => 'מטוסים בקרבת מקום';

  @override
  String get noAircraft => 'אין מטוס בקרבת מקום';

  @override
  String get loadingContext => 'קשר סביבתי..';

  @override
  String get settingsTitle => 'הגדרות';

  @override
  String get notifications => 'זיהוי';

  @override
  String get enablePushNotifications => 'קבלו הודעות להערות עתידיות';

  @override
  String get quietHours => 'שעות שקטות';

  @override
  String get quietHoursDesc => 'שתיקה מזהירה בין שעות נבחרות.';

  @override
  String get quietHoursEnabled => 'שעות שקטות';

  @override
  String get quietHoursFrom => 'מתוך';

  @override
  String get quietHoursUntil => 'עד';

  @override
  String get quietHoursDefaultTime => 'שעות שקטות';

  @override
  String get emergencyOverride => 'חירום';

  @override
  String get emergencyOverrideDesc => 'לאפשר התראה דחופה בשעות שקטות';

  @override
  String get dndMode => 'אל תתבלבל';

  @override
  String get dndUntil => 'אל תפריע עד';

  @override
  String dndEnabled(Object time) {
    return 'DND זמין עד_PLACEHOLDER_0___________________';
  }

  @override
  String get dndDisabled => 'DND';

  @override
  String get quietHoursActive => 'שעות שקט פעיל';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'שעות שקטות: שם הסרטון: PLACEHOLDER__0_____${start}______________________________________________________________________________';
  }

  @override
  String get pushNotificationUfoAlert => 'עב\"ם התראה';

  @override
  String get pushNotificationAnomalyAlert => 'אזהרה אנונימית';

  @override
  String get pushNotificationNearby => 'בקרבת מקום';

  @override
  String get pushNotificationInYourArea => 'באזור שלך. הקש כדי להציג פרטים.';

  @override
  String pushNotificationCommented(Object username) {
    return 'שם הסרטון: PLACEHOLDER_0_';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return 'PL_PLACEHOLDER_0___ commented${username}_____________________________________________________________________________________';
  }

  @override
  String get pushNotificationGeneric => 'עב\"ם';

  @override
  String get pushNotificationNewSighting => 'מראה חדש סמוך';

  @override
  String get language => 'שפה';

  @override
  String get chooseLanguage => 'בחירת שפה';

  @override
  String get units => 'יחידות';

  @override
  String get unitsImperial => 'אימפריאל (מי, mph)';

  @override
  String get unitsMetric => 'Metric ( ק\"מ, ק\"מ)';

  @override
  String get privacyPolicy => 'מדיניות הפרטיות';

  @override
  String get termsOfUse => 'תנאי שימוש';

  @override
  String get errorNoLocation =>
      'מיקום לא זמין נסה שוב בחוץ עם נוף השמיים ברור.';

  @override
  String get errorNoCamera => 'המצלמה אינה זמינה במכשיר זה.';

  @override
  String get errorUploadFailed => 'ההעלאה נכשלה. אנא נסה שוב.';

  @override
  String get errorPermissionDenied => 'הכחשה.';

  @override
  String get errorInvalidUsername => 'שם משתמש זה אינו זמין.';

  @override
  String get nothingToShow => 'עדיין אין מה להראות.';

  @override
  String get storeShortDesc =>
      'אזהרות עב\"מים מיידיות קרוב אליך. לתפוס, לאשר ולשוחח בזמן אמת.';

  @override
  String get storeLongDesc =>
      'עב\"ם שולח התראות בזמן אמת כאשר מישהו ממקם עב\"מ קרוב. ללכוד תמונות וסרטונים, לאשר מראות עם ברז, כיוון נוף ומרחק, וצ\'אט עם צופים אחרים.';

  @override
  String get keywords =>
      'עב\"מים,UAP,OVNI,aliens,sightings,skywatch,alerts,radar,compass';

  @override
  String get noAlertsFound => 'אין אזהרות';

  @override
  String get alertsFilterHelp =>
      'נסה להתאים את המסננים שלך כדי לראות תוצאות נוספות';

  @override
  String get verified => 'מאומת';

  @override
  String get beepOnly => 'להיות רק';

  @override
  String get reportOnly => 'טקסט רק';

  @override
  String get videoOnly => 'וידאו בלבד';

  @override
  String get imageOnly => 'צילום בלבד';

  @override
  String get mediaOnly => 'רק מדיה';

  @override
  String get timeJustNow => 'רק עכשיו';

  @override
  String timeDaysAgo(int count) {
    return 'שם הסרטון: PLACEHOLDER_0__Day ago';
  }

  @override
  String timeHoursAgo(int count) {
    return 'שם הסרטון: PLACEHOLDER_0___Times ago';
  }

  @override
  String timeMinutesAgo(int count) {
    return 'שם הסרטון: PLACEHOLDER_0___Times ago';
  }

  @override
  String get loadMoreAlerts => 'עוד התראות';

  @override
  String get toggleMufonTooltip => 'משקפי MUFON';

  @override
  String get showMufonData => 'מידע על MUFON';

  @override
  String get hideMufonData => 'מידע על MUFON';

  @override
  String get showingUfoBeepOnly => 'מציג רק דוחות עב\"מ';

  @override
  String get showingAllReports => 'הצג את כל הדיווחים כולל MUFON';

  @override
  String get filteredSuffix => 'סינון';

  @override
  String get detailsTitle => 'פרטים';

  @override
  String get mufonCase => 'MUFON מקרה';

  @override
  String get mufonSighting => 'MUFON Sighting Report';

  @override
  String get mufonLightSighting => 'MUFON Light Sighting Report';

  @override
  String get mufonSphereSighting => 'MUFON Sphere Sighting Report';

  @override
  String get mufonDiscSighting => 'MUFON דוח מאכזב';

  @override
  String get mufonTriangleSighting => 'MUFON דו\"ח משולש';

  @override
  String get mufonCigarSighting => 'MUFON Sighting Report';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting Report';

  @override
  String get mufonRectangleSighting => 'MUFON המונחים: Sighting Report';

  @override
  String get mufonCylinderSighting => 'MUFON Cylinder Sighting Report';

  @override
  String get mufonBoomerangSighting => 'MUFON בומרנג Sighting Report';

  @override
  String get mufonStarlikeSighting => 'MUFON תגית: Sighting Report';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Case #_PLACEHOLDER_0__פרטים';
  }

  @override
  String get sightingDate => 'תאריך יציאה';

  @override
  String get mufonDatabaseEntryDate => 'תאריך כניסה ל MUFON מסד נתונים';

  @override
  String get databaseEntry => 'מסד נתונים כניסה';

  @override
  String get shareLink => 'קישור';

  @override
  String get linkCopied => 'קישור להורדה';

  @override
  String get locationLabel => 'מיקום:';

  @override
  String get distanceLabel => 'מרחק';

  @override
  String get timeLabel => 'זמן:';

  @override
  String get reportedByLabel => 'דיווח על';

  @override
  String get unknownLocation => 'מיקום לא ידוע';

  @override
  String get locationUnknown => 'מיקום לא ידוע';

  @override
  String get witnessesLabel => 'עדים';

  @override
  String witnessesCountMessage(int count) {
    return '_PLACEHOLDER_0__ אנשים אישרו את המראה הזה';
  }

  @override
  String get photoAnalysisTitle => 'Photo Analysis';

  @override
  String mediaItemsProcessed(int count) {
    return 'ניתוח:_PLACEHOLDER_0___קובץ מדיה(s) מעובד';
  }

  @override
  String get addMoreMedia => 'הוסף עוד';

  @override
  String get addMedia => 'הוסף';

  @override
  String get retakePhoto => 'Retake Photo';

  @override
  String get retakeVideo => 'Retake וידאו';

  @override
  String get camera => 'מצלמה';

  @override
  String get gallery => 'גלריה';

  @override
  String get basicSettings => 'הגדרות בסיסיות';

  @override
  String get appSettings => 'הגדרות App Settings';

  @override
  String get timeFormat => 'עיצוב זמן';

  @override
  String get timeFormat24Hour => '24 שעות (14:30)';

  @override
  String get timeFormat12Hour => '12 שעות (2:30 ראש)';

  @override
  String get timeFormatDesc => 'מציג זמן בפורמט 24 שעות או 12 שעות';

  @override
  String get alertRange => 'המונחים';

  @override
  String get manageNotificationsDesc => 'ניהול מנויים והגדרות';

  @override
  String get permissionsTitle => 'הרשאות';

  @override
  String get permissionLocation => 'מיקום Location';

  @override
  String get permissionCamera => 'מצלמה';

  @override
  String get permissionNotifications => 'זיהוי';

  @override
  String get permissionPhotos => 'תמונות';

  @override
  String get permissionGranted => 'גרנט';

  @override
  String get permissionNotGranted => 'לא הוענק';

  @override
  String get permissionGrant => 'גרנט';

  @override
  String get generateUsername => 'ליצור שם משתמש חדש';

  @override
  String get adminTools => 'כלי Admin';

  @override
  String get openAdminPanel => 'Open Admin Panel';

  @override
  String get webAdminInterface => 'Web Admin Interface';

  @override
  String get adminBetaNotice =>
      'Beta בונה רק כלי Admin לבדיקת התראות קרבה, לדחוף הודעות, ואבחון מערכת.';

  @override
  String get whatDoYouSee => 'מה אתה רואה?';

  @override
  String get ufo => 'עב\"ם';

  @override
  String get sighting => 'עקבו';

  @override
  String get ufoSighting => 'עב\"ם התראה';

  @override
  String get envAnalysisTitle => 'ניתוח סביבתי';

  @override
  String get envAnalysisPending => 'ניתוח Pending';

  @override
  String get envAnalysisPendingDesc =>
      'נתונים סביבתיים יהיו זמינים לאחר תחילת העיבוד.';

  @override
  String get unknownAircraft => 'מטוסים לא ידועים';

  @override
  String get moreAircraft => 'יותר מטוסים';

  @override
  String get showLess => 'הצג פחות';

  @override
  String get premiumImageryTitle => 'Premium Satellite צילום';

  @override
  String get premiumImagerySubtitle => 'תמונות מסחריות ברזולוציה גבוהה';

  @override
  String get sightingTypeLabel => 'סוג';

  @override
  String get ufoTypeSphere => 'Sphere';

  @override
  String get ufoTypeTriangle => 'משולש';

  @override
  String get ufoTypeDisk => 'דיסק';

  @override
  String get ufoTypeLight => 'אור';

  @override
  String get ufoTypeFireball => 'כדור האש';

  @override
  String get ufoTypeCylinder => 'Cylinder';

  @override
  String get ufoTypeCigar => 'סיגריה';

  @override
  String get ufoTypeRectangle => 'Rectangle';

  @override
  String get ufoTypeFormation => 'המונחים';

  @override
  String get ufoTypeUnknown => 'לא ידוע';

  @override
  String get ufoTypeBoomerang => 'בומרנג';

  @override
  String get ufoTypeDiamond => 'יהלומים';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Cone';

  @override
  String get ufoTypeCross => 'צלב';

  @override
  String get ufoTypeDumbbell => 'במבוכה';

  @override
  String get ufoTypeTeardrop => 'Teardrop';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'קליעים';

  @override
  String get ufoTypeSaturn => 'שבתאי';

  @override
  String get ufoTypeStarLike => 'כוכבים';

  @override
  String get ufoTypeBlimp => 'Blimp';

  @override
  String get shapeTriangle => 'משולש';

  @override
  String get shapeDisc => 'דיסק';

  @override
  String get shapeDisk => 'דיסק';

  @override
  String get shapeSphere => 'מרחב';

  @override
  String get shapeCigar => 'סיגר';

  @override
  String get shapeLight => 'אור בהיר';

  @override
  String get shapeBoomerang => 'בומרנג';

  @override
  String get shapeDiamond => 'יהלומים';

  @override
  String get shapeRectangle => 'מלבן';

  @override
  String get shapeOval => 'oval';

  @override
  String get shapeCone => 'cone';

  @override
  String get shapeCross => 'צלב חוצה';

  @override
  String get shapeCylinder => 'cylinder';

  @override
  String get shapeDumbbell => 'פעמון מטומטם';

  @override
  String get shapeTeardrop => 'מדמיע';

  @override
  String get shapeTicTac => 'טיק-tac';

  @override
  String get shapeBullet => 'קליע';

  @override
  String get shapeSaturn => 'שוב';

  @override
  String get shapeStarlike => 'כוכבים';

  @override
  String get shapeBlimp => 'blimp';

  @override
  String get shapeFireball => 'כדור אש';

  @override
  String get shapeFormation => 'היווצרות';

  @override
  String get shapeUnknown => 'לא ידוע';

  @override
  String get actionsTitle => 'פעולות';

  @override
  String get addPhotosAndVideos => 'הוסף תמונות וסרטונים';

  @override
  String get howToReportToMufon => 'כיצד לדווח על MUFON';

  @override
  String get reportToMufon => 'דיווח על MUFON';

  @override
  String get whyReportToMufon => 'למה לדווח על MUFON?';

  @override
  String get openMufonReport => 'פתוח MUFON דיווח';

  @override
  String get confirmedWitness => 'אישרת את המראה הזה';

  @override
  String witnessesHaveConfirmed(int count) {
    return '_PLACEHOLDER_0__ אנשים אישרו את המראה הזה';
  }

  @override
  String get aircraftTrackingTitle => 'מעקב מטוסים';

  @override
  String get weatherConditionsTitle => 'תנאי מזג אוויר';

  @override
  String get noSatellitePasses => 'אין מעבר ללוויינים גלויים';

  @override
  String get contentAnalysisTitle => 'ניתוח תוכן';

  @override
  String get contentSafe => 'התוכן בטוח';

  @override
  String get contentFlagged => 'המונחים: review';

  @override
  String get confidenceLabel => 'אמון';

  @override
  String get methodLabel => 'שיטות';

  @override
  String get premiumImageryAccessOnly => 'תמונת לוויין Premium זמינה רק ל:';

  @override
  String get premiumAccessCreators => 'יוצרי התראה';

  @override
  String get premiumAccessWitnesses => 'עדים בולטים בטווח הנראות';

  @override
  String get comingSoon => 'בקרוב';

  @override
  String get directionDistanceTitle => 'המונחים & Distance';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON מקרה #${caseNumber}____________________________________';
  }

  @override
  String get satellitePassesTitle => 'מעברי לווין';

  @override
  String get satellitePassExplanation =>
      'לווין בולט עובר במהלך מסגרת זמן הראייה. דיווחים עב\"מים רבים הם למעשה לווינים או פסולת חלל.';

  @override
  String get followingAlert => 'לאחר התראה - תקבל הודעות תגובה';

  @override
  String get unfollowedAlert => 'הודעות לא עוקבות - לא עוד הערות';

  @override
  String get alertFollowError => 'עדכון מצב';

  @override
  String get notificationChannelAlerts => 'אזהרות עב\"מ';

  @override
  String get notificationChannelAlertsDesc =>
      'תגיות: UFO beeps and Near alerts';

  @override
  String get notificationSightingTitle => 'עב\"ם התראה';

  @override
  String get notificationSightingUrgent => 'המונחים: URGENTBeep UFO התראה';

  @override
  String get notificationSightingEmergency => 'תגית: EMERGCY UFOBeep UFO התראה';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return 'שם הסרטון: PLACEHOLDER_0___b_${locationName}__________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String notificationCommentTitle(String username) {
    return '💬_PLACEHOLDER_0_ commented';
  }

  @override
  String get notificationWitnessText => 'מראה חדש';

  @override
  String notificationWitnessTextMultiple(int count) {
    return 'שם הסרטון: PLACEHOLDER_0_ Witness';
  }

  @override
  String get notificationActionSnooze => 'סנוזה 1h';

  @override
  String get notificationActionDismiss => 'משמעת';

  @override
  String notificationDistance(String distance) {
    return 'שם הסרטון: PLACEHOLDER_0_Out_';
  }

  @override
  String get unknown => 'לא ידוע';

  @override
  String get report => 'דיווח';

  @override
  String get mufon => 'עבריין';

  @override
  String get recentUfoBeepsTitle => 'העב\"ם האחרון הדבורים';

  @override
  String get recentUfoBeepsSubtitle =>
      'חי עב\"מים מלראות דוחות מהקהילה הגלובלית שלנו';

  @override
  String get recentUfoBeepsDescription =>
      'הזנה זו משלבת בזמן אמת עב\"מBeep \"בייפים\" ממשתמשי האפליקציה הניידים שלנו עם דוחות היסטוריים ממסד הנתונים MUFON.';

  @override
  String get loadingBeeps => 'עקבו אחרי beeps...';

  @override
  String get noBeepsAvailable => 'לא זמין כרגע.';

  @override
  String get anomalyReported => 'דיווח: Anomaly';

  @override
  String get copyShortLink => 'קישור קצר';

  @override
  String get shareAlert => 'המונחים:';

  @override
  String get ufoSightingAlert => 'עב\"ם אזהרה';

  @override
  String get previousPage => 'הקודם';

  @override
  String get nextPage => 'הבא';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'דף הבית > PLACEHOLDER_0____${totalPages}______________________________________${totalCount}_ Total beeps)';
  }

  @override
  String get firstPage => 'הראשון';

  @override
  String get lastPage => 'אחרון';

  @override
  String get jumpToPage => 'לקפוץ לדף';

  @override
  String get heroTagline => 'קבלו התראות כשאתם יוצאים החוצה ומתבוננים';

  @override
  String get heroDescription => 'לעולם אל תחמיצו עוד עב\"מים שרואים באזור שלכם';

  @override
  String get downloadApp => 'להורדה App';

  @override
  String get viewAllBeeps => 'צפו בכל הדבורים';

  @override
  String get sightingsMap => '🗺️ Sightings Map';

  @override
  String get globalSightingNetwork => 'רשת Sighting';

  @override
  String get howItWorks => 'איך זה עובד';

  @override
  String get backToBeeps => 'Back to Beeps';

  @override
  String get loadingDetails => 'עקבו אחרי beepפרטים...';

  @override
  String get details => 'פרטים';

  @override
  String get location => 'מיקום Location';

  @override
  String get timeAgo => 'לפני';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'קילומטרים ק\"מ';

  @override
  String get distanceMiles => 'קילומטרים';

  @override
  String get distanceNearby => 'בסביבה הקרובה';

  @override
  String get ufobeepWitnesses => 'עדים';

  @override
  String get ufobeepConfirmations => 'אישורים';

  @override
  String get ufobeepAlertLevel => 'רמת התראה';

  @override
  String get ufobeepReportType => 'דוח UFOBeep';

  @override
  String get mufonAttribution => 'MUFON דוח מסד נתונים';

  @override
  String get mufonCaseNumber => 'מקרה #';

  @override
  String get mufonGenericTitle => 'MUFON Sighting Report';

  @override
  String get mufonSphere => 'Sphere';

  @override
  String get mufonLight => 'אור';

  @override
  String get mufonDisk => 'דיסק';

  @override
  String get mufonTriangle => 'משולש';

  @override
  String get mufonCigar => 'סיגריה';

  @override
  String get mufonOval => 'Oval';

  @override
  String get mufonCylinder => 'Cylinder';

  @override
  String get mufonRectangle => 'Rectangle';

  @override
  String get mufonDiamond => 'יהלומים';

  @override
  String get mufonFireball => 'כדור האש';

  @override
  String get mufonFlash => 'פלאש';

  @override
  String get mufonFormation => 'המונחים';

  @override
  String get mufonChanging => 'שינוי';

  @override
  String get mufonChevron => 'Chevron';

  @override
  String get mufonCone => 'Cone';

  @override
  String get mufonCross => 'צלב';

  @override
  String get mufonEgg => 'ביצים';

  @override
  String get mufonOther => 'אובייקטים';

  @override
  String get mufonUnknown => 'אובייקטים לא ידועים';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON_PLACEHOLDER_0_ Report';
  }

  @override
  String get nuforcAttribution => 'NUFORC דוח מסד נתונים';

  @override
  String get nuforcCaseNumber => 'מקרה #';

  @override
  String get nuforcGenericTitle => 'NUFORC דיווח Sighting';

  @override
  String get mediaImageNotFound => 'תמונה לא נמצאה';

  @override
  String get mediaPlayVideo => 'Play וידאו';

  @override
  String get mediaViewImage => 'View Image';

  @override
  String mediaCount(Object count) {
    return 'PLACEHOLDER_0_תמונות';
  }

  @override
  String get mediaCountSingle => 'תמונה 1';

  @override
  String mediaMoreImages(Object count) {
    return '+_${count}__________________________________________________';
  }

  @override
  String get errorNotFound => 'לא נמצא';

  @override
  String get errorLoadError => 'נכשל לטעון פרטים';

  @override
  String get shareYourThoughts => 'שתפו את המחשבות שלכם על המראה הזה...';

  @override
  String get postComment => 'תגובה';

  @override
  String get loggedInAs => 'התגבש כמו';

  @override
  String get logout => 'Logout';

  @override
  String get notFollowing => 'לא אחרי';

  @override
  String get follow => 'עקבו אחרי Follow';

  @override
  String get navRecentBeeps => 'הדבורים האחרונות';

  @override
  String get navMap => 'מפה';

  @override
  String get navDownloadApp => 'Download App';

  @override
  String get alertLevel => 'רמת התראה';

  @override
  String get witnesses => 'עדים';

  @override
  String get confirmations => 'אישורים';

  @override
  String get reporterLabel => 'דיווח על ידי User';

  @override
  String get coordinatesLabel => 'לתאם';

  @override
  String get eventTime => 'זמן אירוע';

  @override
  String get reportedTime => 'זמן דיווח';

  @override
  String get addedToUfobeep => 'תגית: UFOBeep';

  @override
  String get mufonDatabaseReport => 'MUFON מקרה מספר:';

  @override
  String get copyShortLinkTitle => 'קישור ל-Creboard';

  @override
  String get imageNotFound => 'תמונה לא נמצאה';

  @override
  String get ufoSightingAlt => 'עב\"ם Beep UFO התראה';

  @override
  String get celestialDataTitle => 'אובייקטים דיגיטליים';

  @override
  String get visiblePlanets => 'כוכבי לכת';

  @override
  String get locationDataTitle => 'מידע מיקום';

  @override
  String get timezone => 'Timezone';

  @override
  String get coordinates => 'לתאם';

  @override
  String get processingSummaryTitle => 'המונחים:';

  @override
  String get processingTime => 'עיבוד זמן';

  @override
  String get successful => 'הצלחה מוצלחת';

  @override
  String get failed => 'נכשל';

  @override
  String get locationEnrichmentTitle => 'פרטי מיקום';

  @override
  String get aircraftDataSource => 'מקור נתונים';

  @override
  String get noAircraftDetected => 'שום מטוס לא זיהה';

  @override
  String get sightingReport => 'דיווח Sighting';

  @override
  String get ufoAlert => 'עב\"ם התראה';

  @override
  String get alert => 'התראה';

  @override
  String get notificationTickerUfoAlert => 'תגית: New Sighting Near';

  @override
  String get notificationTickerComment => 'תגית: UFO Alert';

  @override
  String get weatherConditions => 'תנאי מזג אוויר';

  @override
  String get visibility => 'אמינות';

  @override
  String get humidity => 'הומור';

  @override
  String get pressure => 'לחץ';

  @override
  String get locationDetails => 'פרטי מיקום';

  @override
  String get city => 'העיר City';

  @override
  String get state => 'מדינה';

  @override
  String get country => 'מדינה';

  @override
  String get satelliteActivity => 'פעילות לווין';

  @override
  String get satellitesVisibleOverhead => 'לוויינים גלויים לעין בזמן ובמיקום';

  @override
  String get dataSource => 'מקור נתונים';

  @override
  String get blackskyImagery => 'BlackSky Imagery';

  @override
  String get resolution => 'החלטה';

  @override
  String get groundResolution => '35 ס\"מ רזולוציה';

  @override
  String get delivery => 'משלוח';

  @override
  String get averageDelivery => '90 דקות בממוצע';

  @override
  String get cost => 'עלויות המחיר';

  @override
  String get skyfiSatelliteImagery => 'SkyFi Satellite צילום';

  @override
  String get region => 'אזור';

  @override
  String get remoteArea => 'שטח מרוחק';

  @override
  String get startingPrice => 'מתחילים את המחיר';

  @override
  String get coverage => 'Coverage';

  @override
  String get confidenceCoverage => '95% ביטחון';

  @override
  String get status => 'סטטוס';

  @override
  String get shareThoughts => 'שתפו את המחשבות שלכם על המראה הזה...';

  @override
  String get postCommand => 'Post Command';

  @override
  String get clouds => 'עננים';

  @override
  String get windLabel => 'הרוח';

  @override
  String get filterAlerts => 'אזהרות filter';

  @override
  String get alertSource => 'מקור התראה';

  @override
  String get ufobeepOnly => 'עב\"מ רק';

  @override
  String get ufobeepOnlyDescription =>
      'הצג רק דוחות עב\"מ מקוריים (לא כולל MUFON)';

  @override
  String get alertDistanceRange => 'המונחים: Distance';

  @override
  String get showAllAlerts => 'הצג את כל האזהרות';

  @override
  String get showAll => 'הצג All';

  @override
  String get distanceSliderDescription =>
      'היכנסו עד כמה רחוק אתם רוצים לראות התראות. התחל ממזג אוויר חשיפה מרחוק כדי להראות את כל האזהרות ללא קשר למרחק.';

  @override
  String get applyFilters => 'המונחים:';

  @override
  String get notificationRange => 'המונחים Range';

  @override
  String get notificationRangeDescription => 'קבלו התראות לתצפיות במרחק זה';

  @override
  String get viewingRange => 'תגית: Range';

  @override
  String get viewingRangeDescription => 'מראה מראה במרחק זה בעת גלישה';

  @override
  String get weatherVisibility => 'מזג אוויר (10 ק\"מ)';

  @override
  String get localArea => 'האזור המקומי (25 ק\"מ)';

  @override
  String get regional => 'האזור האזורי';

  @override
  String get pushNotifications => 'תגית: Push Notification';

  @override
  String get alertBrowsing => 'תגית: Browsing';

  @override
  String get pushAlertsWithinDistance => 'קבל הודעות בטווח זה';

  @override
  String get showAlertsWhenBrowsing => 'פילטר מה שרואים ברשימה';

  @override
  String get heroMainTagline =>
      'קבל שעון בטלפון שלך כאשר עב\"מים נצפו בקרבת מקום';

  @override
  String get heroSecondaryTagline => 'גלה מתי והיכן להסתכל על השמיים';

  @override
  String get sourceFilters => 'מקור Source';

  @override
  String get sourceFiltersDescription => 'בחרו אילו דוחות מופיעים בהזנתכם';

  @override
  String get ufobeepAndMufon => 'UFOBeep + MUFON';

  @override
  String get ufobeepOnlySource => 'עב\"מ רק';

  @override
  String get mufonOnlySource => 'רק';

  @override
  String get browseFilters => 'Browse';

  @override
  String get browseFiltersDescription => 'כיצד להציג ולמיין התראות';

  @override
  String get sortByNewest => 'חדש';

  @override
  String get sortByNearest => 'קרוב';

  @override
  String get sortBy => 'על ידי';

  @override
  String get pushAlertsTitle => 'תגית: Push';

  @override
  String get pushAlertsDescription => 'מה מוריד את הטלפון שלך';

  @override
  String get alertRadius => 'תגית: Radius';

  @override
  String get mufonNoPushInfo =>
      'דוחות MUFON מיובאים בלילה ואינם מעוררים התראות';

  @override
  String get privacyData => 'פרטיות ונתונים';

  @override
  String get privacyPolicyDesc => 'כיצד להגן ולהשתמש בנתונים שלך';

  @override
  String get termsOfService => 'תנאי שירות';

  @override
  String get termsOfServiceDesc => 'תנאים ותנאים משפטיים';

  @override
  String get locationTracking => 'מיקום Tracking';

  @override
  String get locationTrackingDesc => 'מיקום רקע לכוננות קרבה';

  @override
  String get locationTrackingTitle => 'מיקום רקע Tracking';

  @override
  String get locationTrackingExplanation =>
      'UFOBeep עוקב אחר המיקום שלך ברקע כדי לשלוח לך התראות קרבה כאשר מראות עב\"מים מתרחשים ליד המיקום הנוכחי שלך, גם כאשר אתה הרחק מהבית.';

  @override
  String get locationTrackingBattery =>
      'שימוש בגיאוף אינטליגנטי לאפקט סוללות של <3%';

  @override
  String get backgroundLocationTracking => 'רקע אמין עקבו';

  @override
  String get locationTrackingActive => 'מיקום לכוננות קרבה';

  @override
  String get locationTrackingInactive => 'מעקב מיקום הוא מוגבלויות';

  @override
  String get locationTrackingDisabledWarning =>
      'לא תקבל התראות קרבה בעת המעבר למקומות חדשים';

  @override
  String get trackingStatus => 'עקבו אחרי Status';

  @override
  String get monitoringStatus => 'פיקוח';

  @override
  String get active => 'פעיל';

  @override
  String get inactive => 'Inactive';

  @override
  String get lastKnownLocation => 'מיקום ידוע לאחרונה';

  @override
  String get lastLocationUpdate => 'עדכון אחרון';

  @override
  String get movementThreshold => 'תנועת Threshold';

  @override
  String get updateFrequency => 'עדכון תדירות';

  @override
  String get batteryImpact => 'אפקט סוללה';

  @override
  String get dataPrivacy => 'פרטיות נתונים';

  @override
  String get locationPermissionExplanation =>
      'עב\"מ ביפ צריך \"אפשר תמיד\" מקום אישור לפקח על התנועה שלך ולשלוח התראות קרבה כאשר אתה במקומות חדשים.';

  @override
  String get benefitsTitle => 'יתרונות';

  @override
  String get locationTrackingBenefits =>
      '• קבלו התראות עב\"מים בכל מקום שאתם נוסעים\nעדכוני מיקום אוטומטיים\n• אין צורך בהגדרה ידנית';

  @override
  String get allowLocationAccess => 'לאפשר גישה למיקום';

  @override
  String get locationPermissionRequired => 'אישור מיקום נדרש למעקב רקע';

  @override
  String get locationTrackingEnabled => 'מיקום רקע מאפשר';

  @override
  String get locationTrackingDisabled => 'מיקום רקע מעקב עם מוגבלויות';

  @override
  String get justNow => 'רק עכשיו';

  @override
  String minutesAgo(int minutes) {
    return 'שם הסרטון: PLACEHOLDER_0___Times ago';
  }

  @override
  String hoursAgo(int hours) {
    return 'שם הסרטון: PLACEHOLDER_0___Times ago';
  }

  @override
  String daysAgo(int days) {
    return 'שם הסרטון: PLACEHOLDER_0__Day ago';
  }

  @override
  String get dataManagement => 'ניהול נתונים';

  @override
  String get dataManagementDesc => 'ייצוא או למחוק את נתוני החשבון שלך';

  @override
  String get splashTagline => 'אזהרות בזמן אמת';

  @override
  String get splashStartingUp => 'מתחילים...';

  @override
  String get splashInitializationFailed => 'העדיפות נכשלה';

  @override
  String get splashInitializationFailedTitle => 'העדיפות נכשלה';

  @override
  String get splashInitializationError => 'האפליקציה לא הצליחה להתחיל כראוי:';

  @override
  String get splashRetry => 'Retry';

  @override
  String get splashContinue => 'המשך';

  @override
  String get splashInitializing => 'תחילת...';

  @override
  String signInWelcome(String username) {
    return 'ברוכים הבאים - PLACEHOLDER_0__!';
  }

  @override
  String signInFailed(String error) {
    return 'סימן-אין נכשל: שם הסרטון: PLACEHOLDER_0______';
  }

  @override
  String get signInPleaseEnterEmail => 'אנא הזן את כתובת הדואר האלקטרוני שלך';

  @override
  String get signInPleaseEnterValidEmail => 'אנא הזן כתובת דואר אלקטרוני בתוקף';

  @override
  String get signInMagicLinkSent =>
      'קישור קסם נשלח! בדוק את הדואר האלקטרוני שלך ולחץ על הקישור כדי להיכנס.';

  @override
  String get signInMagicLinkFailed => 'נכשל לשלוח קישור קסם. אנא נסה שוב.';

  @override
  String get signInAllDataCleared => 'כל הנתונים נקיים';

  @override
  String get signInSubtitle => 'עב\"מים בזמן אמת רואים התראות ודיווחי MUFON';

  @override
  String get signInGoogleLoading => 'חתום ב...';

  @override
  String get signInContinueWithGoogle => 'המשך עם Google';

  @override
  String get signInOr => 'או';

  @override
  String get signInWithEmail => 'היכנס עם דואר אלקטרוני';

  @override
  String get signInEmailDescription => 'אנו נשלח לך קישור מאובטח כדי להיכנס';

  @override
  String get signInEmailAddress => 'כתובת דואר אלקטרוני';

  @override
  String get signInEmailPlaceholder => 'כתובת: mail.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'נסה שוב ב-_PLACEHOLDER_0_s';
  }

  @override
  String get signInSending => 'שולח...';

  @override
  String get signInSendMagicLink => 'שלח קישור קסם';

  @override
  String get signInCheckEmail =>
      'בדוק את הדואר האלקטרוני שלך! הקישור מסתיים ב-15 דקות.';

  @override
  String get signInSecureAuth => 'אותנטיות בטוחה';

  @override
  String get signInSecureAuthDescription =>
      'השתמש ב-Google Sign-in לקבלת גישה מיידית, או בקישורי קסם בדוא\"ל שמתפוגגים ב-15 דקות.';

  @override
  String get signInClearAllDataDebug => 'Clear All Data (Debug)';

  @override
  String get emailAuthFailedToSend => 'נכשל לשלוח דואר אלקטרוני';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'נכשל לשלוח דואר אלקטרוני. אנא נסה שוב.';

  @override
  String get emailAuthInvalidEmail =>
      'כתובת דואר אלקטרוני לא חוקית אנא בדוק את התבנית.';

  @override
  String get emailAuthUserNotFound =>
      'שום חשבון לא נמצא עם כתובת דואר אלקטרוני זו.';

  @override
  String get emailAuthTooManyRequests => 'יותר מדי ניסיונות. נסה שוב אחר כך.';

  @override
  String get emailAuthOperationNotAllowed =>
      'הודעת קישור בדואר אלקטרוני אינה זמינה.';

  @override
  String get emailAuthQuotaExceeded =>
      'ציטוט של דואר אלקטרוני עלה. נסה שוב מחר.';

  @override
  String get emailAuthVerificationFailed =>
      'אימות דואר אלקטרוני נכשל. אנא נסה שוב.';

  @override
  String get emailAuthTitle => 'הודעות דואר אלקטרוני';

  @override
  String get emailAuthVerifyYourEmail => 'בדוק את הדואר האלקטרוני שלך';

  @override
  String get emailAuthDescription =>
      'הוסף את כתובת הדואר האלקטרוני שלך לשיקום חשבון וביטחון. אנו נשלח לך קישור מאובטח לחתימה.';

  @override
  String get emailAuthEmailAddress => 'כתובת דואר אלקטרוני';

  @override
  String get emailAuthEmailPlaceholder => 'כתובת: mail@example.com';

  @override
  String get emailAuthPleaseEnterEmail =>
      'אנא הזן את כתובת הדואר האלקטרוני שלך';

  @override
  String get emailAuthPleaseEnterValidEmail =>
      'אנא הזן כתובת דואר אלקטרוני בתוקף';

  @override
  String get emailAuthCheckEmailToContinue =>
      'בדוק את הדוא\"ל שלך ולהקל על הקישור אימות כדי להמשיך.';

  @override
  String get emailAuthResendEmail => 'דואר אלקטרוני';

  @override
  String get emailAuthSendVerificationEmail => 'שלח הודעה דואר אלקטרוני';

  @override
  String get emailAuthHowItWorks => 'כיצד דואר אלקטרוני פועל';

  @override
  String get emailAuthHowItWorksSteps =>
      '1.1 1. אנו שולחים לך קישור מאובטח\n2. בדוק את הדואר האלקטרוני שלך ולהציל את הקישור\n3. הדואר האלקטרוני שלך מאומת באופן אוטומטי\n4. לא צריך סיסמאות!';

  @override
  String get emailAuthSecurityNotice =>
      'אימות דואר אלקטרוני מסייע לאבטח את החשבון שלך ומאפשר שחזור חשבון אם אתה מאבד גישה למכשיר שלך.';

  @override
  String get phoneAuthFailedToSendCode => 'נכשל לשלוח קוד אימות. אנא נסה שוב.';

  @override
  String get phoneAuthInvalidCodeTryAgain => 'קוד אימות לא חוקי אנא נסה שוב.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'מספר טלפון מאומת: שם הסרטון: PLACEHOLDER_0______';
  }

  @override
  String get phoneAuthVerificationFailed => 'אימות הטלפון נכשל. אנא נסה שוב.';

  @override
  String get phoneAuthCodeResent => 'חידוש הקוד';

  @override
  String get phoneAuthFailedToResendCode => 'נכשל לתקן את הקוד. אנא נסה שוב.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'מספר טלפון לא חוקי אנא בדוק את התבנית.';

  @override
  String get phoneAuthTooManyRequests => 'יותר מדי ניסיונות. נסה שוב אחר כך.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'קוד אימות לא חוקי נא לבדוק ולנסות שוב.';

  @override
  String get phoneAuthSessionExpired => 'סיום הישיבה. נא לבקש קוד חדש.';

  @override
  String get phoneAuthSmsQuotaExceeded => 'ציטוט SMS עלה. נסה שוב מחר.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'מספר הטלפון הזה כבר קשור לחשבון אחר.';

  @override
  String get phoneAuthVerificationFailedGeneric => 'גינוי נכשל. אנא נסה שוב.';

  @override
  String get phoneAuthTitle => 'אספקת טלפון';

  @override
  String get phoneAuthVerifyYourPhone => 'בדוק את הטלפון שלך';

  @override
  String get phoneAuthEnterVerificationCode => 'Enter Verification קודקוד';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'הוסף את מספר הטלפון שלך לשיקום חשבון ואבטחה';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return 'היכנס לקוד 6 הספרות שנשלח ל-_PLACEHOLDER_0______________________________';
  }

  @override
  String get phoneAuthPhoneNumber => 'מספר טלפון';

  @override
  String get phoneAuthPhonePlaceholder => '+1 (555) 123-4567';

  @override
  String get phoneAuthPleaseEnterPhone => 'נא להיכנס למספר הטלפון שלך';

  @override
  String get phoneAuthPleaseEnterValidPhone => 'אנא הכנס מספר טלפון תקף';

  @override
  String get phoneAuthVerificationCode => 'המונחים Code';

  @override
  String get phoneAuthPleaseEnterSixDigitCode => 'נא להיכנס לקוד 6 ספרותי';

  @override
  String get phoneAuthResendCode => 'קוד פתוח';

  @override
  String get phoneAuthSendVerificationCode => 'שלח הודעה קודקוד';

  @override
  String get phoneAuthVerifyCode => 'לבדוק קוד';

  @override
  String get phoneAuthChangePhoneNumber => 'שינוי מספר הטלפון';

  @override
  String get phoneAuthSmsNotice =>
      'אנו נשלח לך קוד אימות באמצעות SMS. שיעורי הודעות סטנדרטיים עשויים ליישם.';

  @override
  String get phoneAuthCodeExpires =>
      'הקוד מסתיים ב-60 שניות. בדוק את ההודעות שלך.';

  @override
  String get yourDataRights => 'זכויות הנתונים שלך';

  @override
  String get dataRightsExplanation =>
      'יש לך שליטה מלאה על הנתונים האישיים שלך. אתה יכול לייצא את כל הנתונים שלך או למחוק לצמיתות את החשבון שלך בכל עת.';

  @override
  String get exportYourData => 'ייצוא הנתונים שלך';

  @override
  String get exportDataDescription => 'הורד את כל נתוני החשבון שלך';

  @override
  String get exportData => 'יצוא נתונים';

  @override
  String get exportingData => 'יצוא...';

  @override
  String get exportDataDetails =>
      'כולל: פרופיל, beeps, הערות, פרטי המכשיר והעדפות. הנתונים מסופקים בפורמט JSON.';

  @override
  String get dataExportedSuccessfully => 'הנתונים המייצאים בהצלחה';

  @override
  String get dataExportFailed => 'נכשל לייצא נתונים';

  @override
  String get deleteAccount => 'למחוק חשבון';

  @override
  String get deleteAccountDescription => 'להסיר את החשבון שלך ואת כל הנתונים';

  @override
  String get deleteAccountWarning =>
      'פעולה זו אינה יכולה להיות בלתי מזוינת. כל המשקפיים, התגובות ונתוני החשבון שלך יימחקו לצמיתות.';

  @override
  String get deleteMyAccount => 'למחוק את החשבון שלי';

  @override
  String get deletingAccount => 'מחיקת...';

  @override
  String get deleteAccountConfirmTitle => 'למחוק חשבון';

  @override
  String get deleteAccountConfirmMessage =>
      'אתה בטוח שאתה רוצה למחוק את החשבון שלך? פעולה זו היא קבועה ולא ניתן לבטלה.';

  @override
  String get dataWillBeDeleted => 'הנתונים הבאים יימחקו לצמיתות:';

  @override
  String get deletedDataList =>
      '• פרופיל ושם המשתמש שלך\n• כל החשבונות והדיווחים שלך\n• כל התגובות שלך\n• נתוני רישום מכשירים\n• נתוני מיקום והעדפה';

  @override
  String get deleteAccountPermanent => 'למחוק באופן קבוע';

  @override
  String get accountDeletedSuccessfully => 'החשבון נמחק בהצלחה';

  @override
  String get accountDeletionFailed => 'נכשל למחוק את החשבון';

  @override
  String get onboardingWelcomeTitle => 'ברוכים הבאים ל- UFOBeep';

  @override
  String get onboardingWelcomeBody =>
      'קבל התראות מיידיות כאשר עב\"מים נצפו ליד המיקום שלך. לעולם אל תחמיצו שוב מראה!';

  @override
  String get onboardingReportTitle => 'רואים משהו? היזהרו!';

  @override
  String get onboardingReportBody =>
      'לצלם תמונות וסרטונים של מראה עב\"מים. שתפו עם הקהילה העולמית מיד.';

  @override
  String get onboardingCompassTitle => 'ראו היכן הם נראים';

  @override
  String get onboardingCompassBody =>
      'Compass מראה לך את הכיוון המדויק שהעד חיפש כשראו את העב\"ם. מצא את הטלפון והמראה שלך!';

  @override
  String get onboardingCommunityTitle => 'צור קשר עם Skywatchers';

  @override
  String get onboardingCommunityBody =>
      'קראו את מראה העב\"ם האחרון מעל קפה הבוקר. גישה למידע מקצועי MUFON ולהתחבר עם צופים אחרים.';

  @override
  String get skip => 'דלג';

  @override
  String get getStarted => 'להתחיל';

  @override
  String get viewOnboardingAgain => 'שוב Onboarding';

  @override
  String get customAlertRange => 'המונחים:';

  @override
  String get enterRangeKm => 'טווח כניסה (1-99999)';

  @override
  String get largeRangeWarning =>
      'טווחים גדולים (>100 ק\"מ) עשויים לייצר התראות רבות';

  @override
  String get globalRangeWarning =>
      'מגוון גדול מאוד (>1000 ק\"מ) שולח לך התראות מרחבי העולם';

  @override
  String get invalidRange => 'אנא הכנס מספר בין 1 ל 99999';

  @override
  String get celestialSunDaylight =>
      'השמש עולה - תנאי אור יום עלולים להשפיע על הראייה';

  @override
  String get celestialSunTwilight =>
      'תנאי דמדומים - חשיפה מסוימת אך כהה יותר מאשר אור היום';

  @override
  String get celestialSunDark =>
      'תנאים אפלים – אופטימליים להתבוננות בחפצים בשמים';

  @override
  String celestialMoonBright(Object phase) {
    return 'Bright_PLACEHOLDER_0__הירח גלוי - עשוי להאיר או לטשטש חפצים אחרים';
  }

  @override
  String celestialMoonModerate(Object phase) {
    return 'PLACEHOLDER_0__ירח גלוי - תנאי תאורה בינוניים';
  }

  @override
  String celestialMoonThin(Object phase) {
    return 'T_PLACEHOLDER_0__ הירח גלוי - תאורה מינימלית';
  }

  @override
  String celestialMoonHidden(Object phase) {
    return 'PLACEHOLDER_0_ירח מתחת לאופק - אין תאורה ירחית';
  }

  @override
  String get celestialNoPlanets =>
      'אין כוכבי לכת בהירים שיכולים לטעות עבור עב\"מים';

  @override
  String celestialPlanetHigh(Object altitude, Object planet) {
    return '_PLACEHOLDER_0__High Overhead (_$planet °)';
  }

  @override
  String celestialPlanetMedium(Object altitude, Object planet) {
    return '_PLACEHOLDER_0___ גלוי ב-_PLACEHOLDER_1__ ° - יכול להיות שגוי עבור מטוסים';
  }

  @override
  String celestialPlanetLow(Object altitude, Object planet) {
    return '<PLACEHOLDER_0___נמוך באופק (__PLACEHOLDER_1_ °)';
  }

  @override
  String get celestialNoStars => 'אין כוכבים בהירים במיוחד';

  @override
  String celestialStarSingle(Object altitude, Object star) {
    return '_PLACEHOLDER_0__ בולטת ב-__PLACEHOLDER_1_גבהים';
  }

  @override
  String celestialStarsMultiple(Object count, Object names) {
    return 'PLACEHOLDER_0__ בהיר כוכבים גלויים לעין -_PLACEHOLDER_1_____________________________________________________________________';
  }

  @override
  String get celestialSummaryDaylight => 'תנאי תאורה';

  @override
  String get celestialSummaryDark => 'תנאי השמיים האפלים';

  @override
  String get celestialSummaryMoonUp => 'הירח מציג';

  @override
  String get celestialSummaryMoonDown => 'הירח לא מאיר';

  @override
  String celestialSummaryManyObjects(Object count) {
    return '_PLACEHOLDER_0__ אובייקטים בהירים שיכולים להיות מבולבלים עם עב\"מים';
  }

  @override
  String celestialSummarySomeObjects(Object count) {
    return 'PL_PLACEHOLDER_0__0__אובייקטים בהירים (s)';
  }

  @override
  String get celestialSummaryFewObjects => 'חפצים בהירים מינימליים בשמים';

  @override
  String celestialSkySummary(Object conditions) {
    return 'תנאי השמיים: שם הסרטון: PLACEHOLDER_0______';
  }

  @override
  String get planetVenus => 'ונוס';

  @override
  String get planetJupiter => 'צדק';

  @override
  String get planetSaturn => 'שבתאי';

  @override
  String get planetMars => 'מאדים';

  @override
  String get planetMercury => 'מרקורי';

  @override
  String get planetUranus => 'אורנוס';

  @override
  String get planetNeptune => 'נפטון';

  @override
  String get starSirius => 'Sirius';

  @override
  String get starCanopus => 'Canopus';

  @override
  String get starArcturus => 'Arcturus';

  @override
  String get starVega => 'וגה';

  @override
  String get starCapella => 'Capella';

  @override
  String get starRigel => 'ריגל';

  @override
  String get starProcyon => 'Procyon';

  @override
  String get starBetelgeuse => 'Betelgeuse';

  @override
  String get moonPhaseNew => 'הירח החדש';

  @override
  String get moonPhaseWaxingCrescent => 'המונחים: Crescent';

  @override
  String get moonPhaseFirstQuarter => 'הרובע הראשון';

  @override
  String get moonPhaseWaxingGibbous => 'תגית: Gibbous';

  @override
  String get moonPhaseFull => 'ירח מלא';

  @override
  String get moonPhaseWaningGibbous => 'וואן גיבס';

  @override
  String get moonPhaseThirdQuarter => 'הרובע השלישי';

  @override
  String get moonPhaseWaningCrescent => 'סאהר';

  @override
  String planetBelowHorizon(Object planet) {
    return '<PLACEHOLDER_0__ מתחת לאופק';
  }

  @override
  String planetHighOverheadProminent(Object altitude, Object planet) {
    return '_PLACEHOLDER_0__High Overhead (_$planet °)';
  }

  @override
  String planetMidSkyProminent(Object altitude, Object planet) {
    return '_PLACEHOLDER_0_____PLACEHOLDER_1_ ° - בולט';
  }

  @override
  String planetMidSky(Object altitude, Object planet) {
    return 'שם הסרטון: PLACEHOLDER_0_____PLACEHOLDER_1_°_';
  }

  @override
  String starVeryBright(Object altitude, Object star) {
    return '<PLACEHOLDER_0____ בהיר מאוד ב-__PLACEHOLDER_1_ °_';
  }

  @override
  String starProminent(Object altitude, Object star) {
    return '_PLACEHOLDER_0__ בולטת ב-__PLACEHOLDER_1_גבהים';
  }

  @override
  String starVisible(Object altitude, Object star) {
    return 'שם הסרטון: PLACEHOLDER_0_____PLACEHOLDER_1_°_';
  }

  @override
  String get altitudeShort => 'אליט';

  @override
  String get magnitudeShort => 'מגדל';

  @override
  String satellitesVisibleMightExplain(Object count) {
    return 'PLACEHOLDER_0_לוויינים גלויים - עשויים להסביר את הראייה';
  }

  @override
  String satellitesVisibleUnlikelyExplain(Object count) {
    return 'PLACEHOLDER_0_לוויינים גלויים - לא סביר להסביר את הראייה';
  }

  @override
  String get noSatellitesVisible => 'אין לוויינים גלויים';

  @override
  String aircraftDetectedInRadius(Object count, Object radius) {
    return '* PLACEHOLDER_0__ מטוסים שזוהו בתוך _PLACEHOLDER_1_ ק\"מ';
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
