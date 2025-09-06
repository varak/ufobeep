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
  String get enablePushNotifications => 'הודעות דחיפה';

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
