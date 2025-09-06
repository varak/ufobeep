// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'UFOBeep';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Retry';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading…';

  @override
  String get processing => 'Processing…';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get networkError => 'Network error. Check your connection.';

  @override
  String get permissionsRequired => 'Permissions required';

  @override
  String get learnMore => 'Learn more';

  @override
  String get welcomeTitle => 'Welcome to UFOBeep';

  @override
  String get welcomeSubtitle => 'Real-time UFO alerts near you';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get enterUsername => 'Enter a username';

  @override
  String get username => 'Username';

  @override
  String get usernameUpdated => 'Username updated';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get tabAlerts => 'Alerts';

  @override
  String get tabBeep => 'Beep';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabMap => 'Map';

  @override
  String get tabSettings => 'Settings';

  @override
  String get alertsTitle => 'Nearby Alerts';

  @override
  String get noAlerts => 'No alerts nearby yet.';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String alertDistance(String distance) {
    return '$distance away';
  }

  @override
  String alertDirection(int bearing) {
    return 'Bearing $bearing°';
  }

  @override
  String get viewAlert => 'View alert';

  @override
  String get viewOnMap => 'View on map';

  @override
  String get iSeeItToo => 'I see it too';

  @override
  String get confirmWitnessed => 'Confirm you witnessed this sighting?';

  @override
  String get witnessConfirmed => 'Thanks — your confirmation was posted.';

  @override
  String get createBeepTitle => 'Send a Beep';

  @override
  String get beepExplain => 'Capture what you see and alert nearby watchers.';

  @override
  String get capturePhoto => 'Capture photo';

  @override
  String get captureVideo => 'Capture video';

  @override
  String get pickFromGallery => 'Choose from gallery';

  @override
  String get descriptionHint => 'Describe what you\'re seeing in the sky…';

  @override
  String get submitBeep => 'Send Beep';

  @override
  String get beepSent => 'Beep sent';

  @override
  String get uploadingMedia => 'Uploading media…';

  @override
  String get includeLocation => 'Include location';

  @override
  String get includeTimestamp => 'Include timestamp';

  @override
  String get beepFailed => 'Failed to send Beep.';

  @override
  String get mediaProcessing => 'Processing media…';

  @override
  String get cameraPermissionTitle => 'Camera access needed';

  @override
  String get cameraPermissionBody =>
      'Grant camera access to capture UFO photos and videos.';

  @override
  String get locationPermissionTitle => 'Location access needed';

  @override
  String get locationPermissionBody =>
      'We use your location to send and receive nearby alerts.';

  @override
  String get microphonePermissionTitle => 'Microphone access needed';

  @override
  String get microphonePermissionBody =>
      'Grant microphone access for video capture with audio.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get alertDetailTitle => 'Sighting Details';

  @override
  String reportedBy(String username) {
    return 'Reported by $username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Reported $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '$distance away';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Bearing to object: $bearing°';
  }

  @override
  String get openCompass => 'Open compass';

  @override
  String get openAR => 'Open AR overlay';

  @override
  String get openChat => 'Open chat';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get addComment => 'Add a comment…';

  @override
  String get send => 'Send';

  @override
  String get commentPosted => 'Comment posted';

  @override
  String get autoFollowEnabled => 'You’re now following this alert.';

  @override
  String get noCommentsYet => 'No comments yet. Be the first!';

  @override
  String get newCommentNotification => 'New comment on a sighting you follow.';

  @override
  String get mapTitle => 'Live Map';

  @override
  String get compassTitle => 'Compass';

  @override
  String get compassSettings => 'Compass Settings';

  @override
  String get compassMode => 'Compass Mode';

  @override
  String get compassStandardMode => 'Standard Mode';

  @override
  String get compassPilotMode => 'Pilot Mode';

  @override
  String get compassStandardDescription => 'Basic heading and navigation';

  @override
  String get compassPilotDescription =>
      'Advanced navigation with ETA and vectoring';

  @override
  String pointingTo(String direction) {
    return 'Pointing to $direction';
  }

  @override
  String get calibratingCompass => 'Calibrating compass…';

  @override
  String get openAROverlay => 'Open AR overlay';

  @override
  String get pushTitleAlertNearby => 'UFO alert near you';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'A new sighting was reported $distance away.';
  }

  @override
  String get pushTitleComment => 'New comment';

  @override
  String get pushBodyComment => 'Someone commented on a sighting you follow.';

  @override
  String get pushTitleWitness => 'Witness confirmation';

  @override
  String get pushBodyWitness => 'A user confirmed they see the same object.';

  @override
  String get weather => 'Weather';

  @override
  String cloudCover(int percent) {
    return 'Cloud cover: $percent%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Wind: $speed $unit';
  }

  @override
  String get nearbyAircraft => 'Nearby aircraft';

  @override
  String get noAircraft => 'No aircraft nearby';

  @override
  String get loadingContext => 'Loading environmental context…';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get enablePushNotifications => 'Enable push notifications';

  @override
  String get quietHours => 'Quiet hours';

  @override
  String get quietHoursDesc => 'Silence alerts between selected hours.';

  @override
  String get dndMode => 'Do Not Disturb';

  @override
  String get dndUntil => 'Do not disturb until';

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get units => 'Units';

  @override
  String get unitsImperial => 'Imperial (mi, mph)';

  @override
  String get unitsMetric => 'Metric (km, km/h)';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get errorNoLocation =>
      'Location unavailable. Try again outside with clear sky view.';

  @override
  String get errorNoCamera => 'Camera unavailable on this device.';

  @override
  String get errorUploadFailed => 'Upload failed. Please try again.';

  @override
  String get errorPermissionDenied => 'Permission denied.';

  @override
  String get errorInvalidUsername => 'That username isn’t available.';

  @override
  String get nothingToShow => 'Nothing to show yet.';

  @override
  String get storeShortDesc =>
      'Instant UFO alerts near you. Capture, confirm, and chat in real time.';

  @override
  String get storeLongDesc =>
      'UFOBeep sends real-time alerts when someone spots a UFO nearby. Capture photos and videos, confirm sightings with a tap, view direction & distance, and chat with fellow skywatchers.';

  @override
  String get keywords =>
      'UFO,UAP,OVNI,aliens,sightings,skywatch,alerts,radar,compass';
}
