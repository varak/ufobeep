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
    return 'PH_0_______התרחק';
  }

  @override
  String alertDirection(int bearing) {
    return 'המונחים: PH_0_ °';
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
    return 'תגית: PH_0___';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'תגית: PH_0____';
  }

  @override
  String distanceAway(String distance) {
    return 'PH_0_______התרחק';
  }

  @override
  String bearingToObject(int bearing) {
    return 'להתווכח: PH_0__ °';
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
  String get noCommentsYet => 'עדיין לא הערות. להיות הראשון!';

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
    return 'המונחים: PH_0____';
  }

  @override
  String get calibratingCompass => 'מצפן קצר..';

  @override
  String get openAROverlay => 'פתח את AR Overlay';

  @override
  String get pushTitleAlertNearby => 'אזהרות עב\"מ קרוב אליך';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'תצפית חדשה דווחה -_PH_0____.';
  }

  @override
  String get pushTitleComment => 'תגובה חדשה';

  @override
  String get pushBodyComment => 'מישהו אמר על מראה שאתה עוקב.';

  @override
  String get pushTitleWitness => 'אישור עדים';

  @override
  String get pushBodyWitness => 'משתמש אישר שהוא רואה את אותו האובייקט.';

  @override
  String get weather => 'מזג אוויר';

  @override
  String cloudCover(int percent) {
    return 'כיסוי ענן: PH_0__%';
  }

  @override
  String wind(num speed, String unit) {
    return 'רוח:_PH_0_____________________________________________________________________________________';
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
  String get videoOnly => 'וידאו רק';

  @override
  String get imageOnly => 'תמונה רק';

  @override
  String get timeJustNow => 'רק עכשיו';

  @override
  String timeDaysAgo(int count) {
    return 'PH_0____D_ ago';
  }

  @override
  String timeHoursAgo(int count) {
    return 'PH_0_h ago';
  }

  @override
  String timeMinutesAgo(int count) {
    return 'PH_0__m ago';
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
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON מקרה #${caseNumber}_פרטים';
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
  String get locationLabel => 'מיקום Location';

  @override
  String get distanceLabel => 'מרחק';

  @override
  String get timeLabel => 'הזמן';

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
    return '_PH_0___ אנשים אישרו את המראה הזה';
  }

  @override
  String get photoAnalysisTitle => 'Photo Analysis';

  @override
  String mediaItemsProcessed(int count) {
    return 'ניתוח:_PH_0____קובץ מדיה(s) מעובד';
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
  String get ufoSighting => 'עב\"ם עקבו';

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
    return '_PH_0__ אנשים אישרו את המראה הזה';
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
  String get directionDistanceTitle => 'Direction & Distance';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Case #$caseNumber';
  }

  @override
  String get satellitePassesTitle => 'Satellite Passes';

  @override
  String get satellitePassExplanation =>
      'Visible satellite passes during the sighting timeframe. Many UFO reports are actually satellites or space debris.';

  @override
  String get followingAlert =>
      'Following alert - you\'ll get comment notifications';

  @override
  String get unfollowedAlert =>
      'Unfollowed alert - no more comment notifications';

  @override
  String get alertFollowError => 'Error updating follow status';
}
