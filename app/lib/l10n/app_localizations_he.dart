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
  String get locationPermissionTitle => 'גישה למיקומים הדרושים';

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
    return 'משם';
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
  String get dndMode => 'אל תתבלבל';

  @override
  String get dndUntil => 'אל תפריע עד';

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
  String get reportOnly => 'דיווח רק';

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
  String get heroDescription =>
      'לעולם אל תחמיצו מראה עב\"מים נוסף. קבל התראות בזמן אמת כאשר מישהו לידך רואה משהו מוזר בשמים. מצא את הטלפון שלך ולמצוא בדיוק איפה להסתכל.';

  @override
  String get downloadApp => 'להורדה App';

  @override
  String get viewAllBeeps => 'צפו בכל הדבורים';

  @override
  String get sightingsMap => '🗺️ Sightings Map';

  @override
  String get globalSightingNetwork => 'רשת Sighting';

  @override
  String get howItWorks => 'כיצד עובד עב\"מ';

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
  String get mufonDatabaseReport => 'MUFON דוח מסד נתונים';

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
}
