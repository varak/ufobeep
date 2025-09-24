// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

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
  String beepSentWithUrl(String shortUrl) {
    return 'Beep sent successfully';
  }

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
  String get locationPermissionTitle => 'Location Permission Required';

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
    return '$distance';
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
  String get noCommentsYet => 'No comments yet. Be the first to comment!';

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
  String get temperature => 'Temperature';

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
  String get enablePushNotifications => 'Get notifications for future comments';

  @override
  String get quietHours => 'Quiet hours';

  @override
  String get quietHoursDesc => 'Silence alerts between selected hours.';

  @override
  String get quietHoursEnabled => 'Enable quiet hours';

  @override
  String get quietHoursFrom => 'From';

  @override
  String get quietHoursUntil => 'Until';

  @override
  String get quietHoursDefaultTime => 'Default quiet hours';

  @override
  String get emergencyOverride => 'Emergency override';

  @override
  String get emergencyOverrideDesc => 'Allow urgent alerts during quiet hours';

  @override
  String get dndMode => 'Do Not Disturb';

  @override
  String get dndUntil => 'Do not disturb until';

  @override
  String dndEnabled(Object time) {
    return 'DND enabled until $time';
  }

  @override
  String get dndDisabled => 'DND disabled';

  @override
  String get quietHoursActive => 'Quiet hours active';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Quiet hours: $start - $end';
  }

  @override
  String get pushNotificationUfoAlert => 'UFO Alert';

  @override
  String get pushNotificationAnomalyAlert => 'Anomaly Alert';

  @override
  String get pushNotificationNearby => 'Nearby';

  @override
  String get pushNotificationInYourArea => 'in your area. Tap to view details.';

  @override
  String pushNotificationCommented(Object username) {
    return '$username commented';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '$username commented on $beepTitle';
  }

  @override
  String get pushNotificationGeneric => 'UFOBeep';

  @override
  String get pushNotificationNewSighting => 'New sighting nearby';

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

  @override
  String get noAlertsFound => 'No matching alerts';

  @override
  String get alertsFilterHelp =>
      'Try adjusting your filters to see more results';

  @override
  String get verified => 'Verified';

  @override
  String get beepOnly => 'Beep Only';

  @override
  String get reportOnly => 'Text Only';

  @override
  String get videoOnly => 'Video Only';

  @override
  String get imageOnly => 'Image Only';

  @override
  String get mediaOnly => 'Media Only';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String timeMinutesAgo(int count) {
    return '$count minutes ago';
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

  @override
  String get detailsTitle => 'Details';

  @override
  String get mufonCase => 'MUFON Case';

  @override
  String get mufonSighting => 'MUFON Sighting Report';

  @override
  String get mufonLightSighting => 'MUFON Light Sighting Report';

  @override
  String get mufonSphereSighting => 'MUFON Sphere Sighting Report';

  @override
  String get mufonDiscSighting => 'MUFON Disc Sighting Report';

  @override
  String get mufonTriangleSighting => 'MUFON Triangle Sighting Report';

  @override
  String get mufonCigarSighting => 'MUFON Cigar Sighting Report';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting Report';

  @override
  String get mufonRectangleSighting => 'MUFON Rectangle Sighting Report';

  @override
  String get mufonCylinderSighting => 'MUFON Cylinder Sighting Report';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Sighting Report';

  @override
  String get mufonStarlikeSighting => 'MUFON Starlike Sighting Report';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Case #$caseNumber Details';
  }

  @override
  String get sightingDate => 'Sighting Date';

  @override
  String get mufonDatabaseEntryDate => 'Date Entered into MUFON Database';

  @override
  String get databaseEntry => 'Database Entry';

  @override
  String get shareLink => 'Share Link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get locationLabel => 'Location:';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get timeLabel => 'Time:';

  @override
  String get reportedByLabel => 'Reported by';

  @override
  String get unknownLocation => 'Unknown Location';

  @override
  String get locationUnknown => 'Location Unknown';

  @override
  String get witnessesLabel => 'Witnesses';

  @override
  String witnessesCountMessage(int count) {
    return '$count people confirmed this sighting';
  }

  @override
  String get photoAnalysisTitle => 'Photo Analysis';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analysis: $count media file(s) processed';
  }

  @override
  String get addMoreMedia => 'Add More';

  @override
  String get addMedia => 'Add Media';

  @override
  String get retakePhoto => 'Retake Photo';

  @override
  String get retakeVideo => 'Retake Video';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get basicSettings => 'Basic Settings';

  @override
  String get appSettings => 'App Settings';

  @override
  String get timeFormat => 'Time Format';

  @override
  String get timeFormat24Hour => '24-hour (14:30)';

  @override
  String get timeFormat12Hour => '12-hour (2:30 PM)';

  @override
  String get timeFormatDesc => 'Display time in 24-hour or 12-hour format';

  @override
  String get alertRange => 'Alert Range';

  @override
  String get manageNotificationsDesc => 'Manage subscriptions & settings';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get permissionLocation => 'Location';

  @override
  String get permissionCamera => 'Camera';

  @override
  String get permissionNotifications => 'Notifications';

  @override
  String get permissionPhotos => 'Photos';

  @override
  String get permissionGranted => 'Granted';

  @override
  String get permissionNotGranted => 'Not granted';

  @override
  String get permissionGrant => 'Grant';

  @override
  String get generateUsername => 'Generate new username';

  @override
  String get adminTools => 'Admin Tools';

  @override
  String get openAdminPanel => 'Open Admin Panel';

  @override
  String get webAdminInterface => 'Web Admin Interface';

  @override
  String get adminBetaNotice =>
      'Beta builds only. Admin tools for testing proximity alerts, push notifications, and system diagnostics.';

  @override
  String get whatDoYouSee => 'What do you see?';

  @override
  String get ufo => 'UFO';

  @override
  String get sighting => 'Sighting';

  @override
  String get ufoSighting => 'UFOBeep UFO Alert';

  @override
  String get envAnalysisTitle => 'Environmental Analysis';

  @override
  String get envAnalysisPending => 'Analysis Pending';

  @override
  String get envAnalysisPendingDesc =>
      'Environmental data will be available once processing begins.';

  @override
  String get unknownAircraft => 'Unknown Aircraft';

  @override
  String get moreAircraft => 'more aircraft';

  @override
  String get premiumImageryTitle => 'Premium Satellite Imagery';

  @override
  String get premiumImagerySubtitle => 'High-resolution commercial imagery';

  @override
  String get sightingTypeLabel => 'Type';

  @override
  String get ufoTypeSphere => 'Sphere';

  @override
  String get ufoTypeTriangle => 'Triangle';

  @override
  String get ufoTypeDisk => 'Disk';

  @override
  String get ufoTypeLight => 'Light';

  @override
  String get ufoTypeFireball => 'Fireball';

  @override
  String get ufoTypeCylinder => 'Cylinder';

  @override
  String get ufoTypeCigar => 'Cigar';

  @override
  String get ufoTypeRectangle => 'Rectangle';

  @override
  String get ufoTypeFormation => 'Formation';

  @override
  String get ufoTypeUnknown => 'Unknown';

  @override
  String get ufoTypeBoomerang => 'Boomerang';

  @override
  String get ufoTypeDiamond => 'Diamond';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Cone';

  @override
  String get ufoTypeCross => 'Cross';

  @override
  String get ufoTypeDumbbell => 'Dumbbell';

  @override
  String get ufoTypeTeardrop => 'Teardrop';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Bullet';

  @override
  String get ufoTypeSaturn => 'Saturn';

  @override
  String get ufoTypeStarLike => 'Star-like';

  @override
  String get ufoTypeBlimp => 'Blimp';

  @override
  String get shapeTriangle => 'triangle';

  @override
  String get shapeDisc => 'disc';

  @override
  String get shapeDisk => 'disk';

  @override
  String get shapeSphere => 'sphere';

  @override
  String get shapeCigar => 'cigar';

  @override
  String get shapeLight => 'light';

  @override
  String get shapeBoomerang => 'boomerang';

  @override
  String get shapeDiamond => 'diamond';

  @override
  String get shapeRectangle => 'rectangle';

  @override
  String get shapeOval => 'oval';

  @override
  String get shapeCone => 'cone';

  @override
  String get shapeCross => 'cross';

  @override
  String get shapeCylinder => 'cylinder';

  @override
  String get shapeDumbbell => 'dumbbell';

  @override
  String get shapeTeardrop => 'teardrop';

  @override
  String get shapeTicTac => 'tic-tac';

  @override
  String get shapeBullet => 'bullet';

  @override
  String get shapeSaturn => 'saturn';

  @override
  String get shapeStarlike => 'starlike';

  @override
  String get shapeBlimp => 'blimp';

  @override
  String get shapeFireball => 'fireball';

  @override
  String get shapeFormation => 'formation';

  @override
  String get shapeUnknown => 'unknown';

  @override
  String get actionsTitle => 'Actions';

  @override
  String get addPhotosAndVideos => 'Add Photos & Videos';

  @override
  String get howToReportToMufon => 'How to Report to MUFON';

  @override
  String get reportToMufon => 'Report to MUFON';

  @override
  String get whyReportToMufon => 'Why Report to MUFON?';

  @override
  String get openMufonReport => 'Open MUFON Report';

  @override
  String get confirmedWitness => 'You confirmed this sighting';

  @override
  String witnessesHaveConfirmed(int count) {
    return '$count people have confirmed this sighting';
  }

  @override
  String get aircraftTrackingTitle => 'Aircraft Tracking';

  @override
  String get weatherConditionsTitle => 'Weather Conditions';

  @override
  String get noSatellitePasses => 'No visible satellite passes found';

  @override
  String get contentAnalysisTitle => 'Content Analysis';

  @override
  String get contentSafe => 'Content is safe';

  @override
  String get contentFlagged => 'Content flagged for review';

  @override
  String get confidenceLabel => 'Confidence';

  @override
  String get methodLabel => 'Method';

  @override
  String get premiumImageryAccessOnly =>
      'Premium satellite imagery is only available to:';

  @override
  String get premiumAccessCreators => 'Alert creators';

  @override
  String get premiumAccessWitnesses =>
      'Confirmed witnesses within visibility range';

  @override
  String get comingSoon => 'Coming Soon';

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

  @override
  String get notificationChannelAlerts => 'UFOBeep Alerts';

  @override
  String get notificationChannelAlertsDesc =>
      'Notifications for UFO beeps and proximity alerts';

  @override
  String get notificationSightingTitle => 'UFOBeep UFO Alert';

  @override
  String get notificationSightingUrgent => '⚠️ URGENT UFOBeep UFO Alert';

  @override
  String get notificationSightingEmergency => '🚨 EMERGENCY UFOBeep UFO Alert';

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

  @override
  String get recentUfoBeepsTitle => 'Recent UFO Beeps';

  @override
  String get recentUfoBeepsSubtitle =>
      'Live UFO sighting reports from our global community';

  @override
  String get recentUfoBeepsDescription =>
      'This feed combines real-time UFOBeep \"beeps\" from our mobile app users with historical reports from the MUFON database.';

  @override
  String get loadingBeeps => 'Loading recent beeps...';

  @override
  String get noBeepsAvailable => 'No beeps available at the moment.';

  @override
  String get anomalyReported => 'Anomaly reported';

  @override
  String get copyShortLink => 'Copy short link';

  @override
  String get shareAlert => 'Share alert';

  @override
  String get ufoSightingAlert => 'UFO Sighting Alert';

  @override
  String get previousPage => 'Previous';

  @override
  String get nextPage => 'Next';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Page $currentPage of $totalPages ($totalCount total beeps)';
  }

  @override
  String get firstPage => 'First';

  @override
  String get lastPage => 'Last';

  @override
  String get jumpToPage => 'Jump to page';

  @override
  String get heroTagline => 'Get alerts when to go outside and look up';

  @override
  String get heroDescription => 'Never miss another UFO sighting in your area';

  @override
  String get downloadApp => '📱 Download App';

  @override
  String get viewAllBeeps => '📋 View All Beeps';

  @override
  String get sightingsMap => '🗺️ Sightings Map';

  @override
  String get globalSightingNetwork => 'Global Sighting Network';

  @override
  String get howItWorks => 'How It Works';

  @override
  String get backToBeeps => 'Back to Beeps';

  @override
  String get loadingDetails => 'Loading beep details...';

  @override
  String get details => 'Details';

  @override
  String get location => 'Location';

  @override
  String get timeAgo => 'ago';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'miles';

  @override
  String get distanceNearby => 'nearby';

  @override
  String get ufobeepWitnesses => 'Witnesses';

  @override
  String get ufobeepConfirmations => 'Confirmations';

  @override
  String get ufobeepAlertLevel => 'Alert Level';

  @override
  String get ufobeepReportType => 'UFOBeep Report';

  @override
  String get mufonAttribution => 'MUFON Database Report';

  @override
  String get mufonCaseNumber => 'Case #';

  @override
  String get mufonGenericTitle => 'MUFON Sighting Report';

  @override
  String get mufonSphere => 'Sphere';

  @override
  String get mufonLight => 'Light';

  @override
  String get mufonDisk => 'Disk';

  @override
  String get mufonTriangle => 'Triangle';

  @override
  String get mufonCigar => 'Cigar';

  @override
  String get mufonOval => 'Oval';

  @override
  String get mufonCylinder => 'Cylinder';

  @override
  String get mufonRectangle => 'Rectangle';

  @override
  String get mufonDiamond => 'Diamond';

  @override
  String get mufonFireball => 'Fireball';

  @override
  String get mufonFlash => 'Flash';

  @override
  String get mufonFormation => 'Formation';

  @override
  String get mufonChanging => 'Changing';

  @override
  String get mufonChevron => 'Chevron';

  @override
  String get mufonCone => 'Cone';

  @override
  String get mufonCross => 'Cross';

  @override
  String get mufonEgg => 'Egg';

  @override
  String get mufonOther => 'Object';

  @override
  String get mufonUnknown => 'Unknown Object';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON $classification Report';
  }

  @override
  String get nuforcAttribution => 'NUFORC Database Report';

  @override
  String get nuforcCaseNumber => 'Case #';

  @override
  String get nuforcGenericTitle => 'NUFORC Sighting Report';

  @override
  String get mediaImageNotFound => 'Image not found';

  @override
  String get mediaPlayVideo => 'Play Video';

  @override
  String get mediaViewImage => 'View Image';

  @override
  String mediaCount(Object count) {
    return '$count images';
  }

  @override
  String get mediaCountSingle => '1 image';

  @override
  String mediaMoreImages(Object count) {
    return '+$count more';
  }

  @override
  String get errorNotFound => 'Beep not found';

  @override
  String get errorLoadError => 'Failed to load beep details';

  @override
  String get shareYourThoughts => 'Share your thoughts about this sighting...';

  @override
  String get postComment => 'Post Comment';

  @override
  String get loggedInAs => 'Logged in as';

  @override
  String get logout => 'Logout';

  @override
  String get notFollowing => 'Not following';

  @override
  String get follow => 'Follow';

  @override
  String get navRecentBeeps => 'Recent Beeps';

  @override
  String get navMap => 'Map';

  @override
  String get navDownloadApp => 'Download App';

  @override
  String get alertLevel => 'Alert Level';

  @override
  String get witnesses => 'Witnesses';

  @override
  String get confirmations => 'Confirmations';

  @override
  String get reporterLabel => 'Reported by user';

  @override
  String get coordinatesLabel => 'Coordinates';

  @override
  String get eventTime => 'Event time';

  @override
  String get reportedTime => 'Reported time';

  @override
  String get addedToUfobeep => 'Added to UFOBeep';

  @override
  String get mufonDatabaseReport => 'MUFON Case Number:';

  @override
  String get copyShortLinkTitle => 'Copy link to clipboard';

  @override
  String get imageNotFound => 'Image not found';

  @override
  String get ufoSightingAlt => 'UFOBeep UFO alert';

  @override
  String get celestialDataTitle => 'Celestial Objects';

  @override
  String get visiblePlanets => 'Visible Planets';

  @override
  String get locationDataTitle => 'Location Information';

  @override
  String get timezone => 'Timezone';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get processingSummaryTitle => 'Processing Summary';

  @override
  String get processingTime => 'Processing Time';

  @override
  String get successful => 'Successful';

  @override
  String get failed => 'Failed';

  @override
  String get locationEnrichmentTitle => 'Location Details';

  @override
  String get aircraftDataSource => 'Data Source';

  @override
  String get noAircraftDetected => 'No aircraft detected';

  @override
  String get sightingReport => 'Sighting Report';

  @override
  String get ufoAlert => 'UFO Alert';

  @override
  String get alert => 'Alert';

  @override
  String get notificationTickerUfoAlert => 'UFO Alert - New Sighting Nearby';

  @override
  String get notificationTickerComment => 'New Comment on UFO Alert';

  @override
  String get weatherConditions => 'Weather Conditions';

  @override
  String get visibility => 'Visibility';

  @override
  String get humidity => 'Humidity';

  @override
  String get pressure => 'Pressure';

  @override
  String get locationDetails => 'Location Details';

  @override
  String get city => 'City';

  @override
  String get state => 'State';

  @override
  String get country => 'Country';

  @override
  String get satelliteActivity => 'Satellite Activity';

  @override
  String get satellitesVisibleOverhead =>
      'Satellites visible overhead at sighting time & location';

  @override
  String get dataSource => 'Data Source';

  @override
  String get blackskyImagery => 'BlackSky Imagery';

  @override
  String get resolution => 'Resolution';

  @override
  String get groundResolution => '35cm ground resolution';

  @override
  String get delivery => 'Delivery';

  @override
  String get averageDelivery => '90-minute average';

  @override
  String get cost => 'Cost';

  @override
  String get skyfiSatelliteImagery => 'SkyFi Satellite Imagery';

  @override
  String get region => 'Region';

  @override
  String get remoteArea => 'Remote Area';

  @override
  String get startingPrice => 'Starting Price';

  @override
  String get coverage => 'Coverage';

  @override
  String get confidenceCoverage => '95% confidence';

  @override
  String get status => 'Status';

  @override
  String get shareThoughts => 'Share your thoughts about this sighting...';

  @override
  String get postCommand => 'Post Command';

  @override
  String get clouds => 'Clouds';

  @override
  String get windLabel => 'Wind';

  @override
  String get filterAlerts => 'Filter Alerts';

  @override
  String get alertSource => 'Alert Source';

  @override
  String get ufobeepOnly => 'UFOBeep Only';

  @override
  String get ufobeepOnlyDescription =>
      'Show only original UFOBeep reports (exclude MUFON database)';

  @override
  String get alertDistanceRange => 'Alert Distance Range';

  @override
  String get showAllAlerts => 'Show All Alerts';

  @override
  String get showAll => 'Show All';

  @override
  String get distanceSliderDescription =>
      'Drag to adjust how far you want to see alerts. Start from weather visibility distance up to showing all alerts regardless of distance.';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get notificationRange => 'Notification Range';

  @override
  String get notificationRangeDescription =>
      'Get push alerts for sightings within this distance';

  @override
  String get viewingRange => 'Viewing Range';

  @override
  String get viewingRangeDescription =>
      'Show sightings within this distance when browsing';

  @override
  String get weatherVisibility => 'Weather Visibility (~10km)';

  @override
  String get localArea => 'Local Area (25km)';

  @override
  String get regional => 'Regional';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get alertBrowsing => 'Alert Browsing';

  @override
  String get pushAlertsWithinDistance => 'Get notifications within this range';

  @override
  String get showAlertsWhenBrowsing => 'Filter what you see in the list';

  @override
  String get heroMainTagline =>
      'Get a beep on your phone when UFOs are spotted nearby';

  @override
  String get heroSecondaryTagline =>
      'Find out when and where to look at the sky';

  @override
  String get sourceFilters => 'Source';

  @override
  String get sourceFiltersDescription =>
      'Choose which reports appear in your feed';

  @override
  String get ufobeepAndMufon => 'UFOBeep + MUFON';

  @override
  String get ufobeepOnlySource => 'UFOBeep only';

  @override
  String get mufonOnlySource => 'MUFON only';

  @override
  String get browseFilters => 'Browse';

  @override
  String get browseFiltersDescription => 'How to view and sort alerts';

  @override
  String get sortByNewest => 'Newest';

  @override
  String get sortByNearest => 'Nearest';

  @override
  String get sortBy => 'Sort by';

  @override
  String get pushAlertsTitle => 'Push Alerts';

  @override
  String get pushAlertsDescription => 'What pings your phone';

  @override
  String get alertRadius => 'Alert Radius';

  @override
  String get mufonNoPushInfo =>
      'MUFON reports are imported nightly and do not trigger push alerts';

  @override
  String get privacyData => 'Privacy & Data';

  @override
  String get privacyPolicyDesc => 'How we protect and use your data';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceDesc => 'Legal terms and conditions';

  @override
  String get locationTracking => 'Location Tracking';

  @override
  String get locationTrackingDesc => 'Background location for proximity alerts';

  @override
  String get locationTrackingTitle => 'Background Location Tracking';

  @override
  String get locationTrackingExplanation =>
      'UFOBeep monitors your location in the background to send you proximity alerts when UFO sightings happen near your current location, even when you\'re away from home.';

  @override
  String get locationTrackingBattery =>
      'Uses intelligent geofencing for <3% battery impact';

  @override
  String get backgroundLocationTracking => 'Enable Background Tracking';

  @override
  String get locationTrackingActive =>
      'Monitoring location for proximity alerts';

  @override
  String get locationTrackingInactive => 'Location tracking is disabled';

  @override
  String get locationTrackingDisabledWarning =>
      'You won\'t receive proximity alerts when you move to new locations';

  @override
  String get trackingStatus => 'Tracking Status';

  @override
  String get monitoringStatus => 'Monitoring';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get lastKnownLocation => 'Last Known Location';

  @override
  String get lastLocationUpdate => 'Last Update';

  @override
  String get movementThreshold => 'Movement Threshold';

  @override
  String get updateFrequency => 'Update Frequency';

  @override
  String get batteryImpact => 'Battery Impact';

  @override
  String get dataPrivacy => 'Data Privacy';

  @override
  String get locationPermissionExplanation =>
      'UFOBeep needs \'Always Allow\' location permission to monitor your movement and send proximity alerts when you\'re in new locations.';

  @override
  String get benefitsTitle => 'Benefits';

  @override
  String get locationTrackingBenefits =>
      '• Get UFO alerts wherever you travel\n• Automatic location updates\n• No manual setup required';

  @override
  String get allowLocationAccess => 'Allow Location Access';

  @override
  String get locationPermissionRequired =>
      'Location permission is required for background tracking';

  @override
  String get locationTrackingEnabled => 'Background location tracking enabled';

  @override
  String get locationTrackingDisabled =>
      'Background location tracking disabled';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get dataManagement => 'Data Management';

  @override
  String get dataManagementDesc => 'Export or delete your account data';

  @override
  String get splashTagline => 'Real-time sighting alerts';

  @override
  String get splashStartingUp => 'Starting up...';

  @override
  String get splashInitializationFailed => 'Initialization failed';

  @override
  String get splashInitializationFailedTitle => 'Initialization Failed';

  @override
  String get splashInitializationError =>
      'The app failed to initialize properly:';

  @override
  String get splashRetry => 'Retry';

  @override
  String get splashContinue => 'Continue';

  @override
  String get splashInitializing => 'Initializing...';

  @override
  String signInWelcome(String username) {
    return 'Welcome $username!';
  }

  @override
  String signInFailed(String error) {
    return 'Sign-in failed: $error';
  }

  @override
  String get signInPleaseEnterEmail => 'Please enter your email address';

  @override
  String get signInPleaseEnterValidEmail =>
      'Please enter a valid email address';

  @override
  String get signInMagicLinkSent =>
      'Magic link sent! Check your email and click the link to sign in.';

  @override
  String get signInMagicLinkFailed =>
      'Failed to send magic link. Please try again.';

  @override
  String get signInAllDataCleared => 'All data cleared';

  @override
  String get signInSubtitle =>
      'Real-time UFO sighting alerts and MUFON reports';

  @override
  String get signInGoogleLoading => 'Signing in...';

  @override
  String get signInContinueWithGoogle => 'Continue with Google';

  @override
  String get signInOr => 'or';

  @override
  String get signInWithEmail => 'Sign in with Email';

  @override
  String get signInEmailDescription =>
      'We\'ll send you a secure link to sign in';

  @override
  String get signInEmailAddress => 'Email address';

  @override
  String get signInEmailPlaceholder => 'your@email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'Try again in ${seconds}s';
  }

  @override
  String get signInSending => 'Sending...';

  @override
  String get signInSendMagicLink => 'Send Magic Link';

  @override
  String get signInCheckEmail =>
      'Check your email! The link expires in 15 minutes.';

  @override
  String get signInSecureAuth => 'Secure Authentication';

  @override
  String get signInSecureAuthDescription =>
      'Use Google Sign-In for instant access, or email magic links that expire in 15 minutes.';

  @override
  String get signInClearAllDataDebug => 'Clear All Data (Debug)';

  @override
  String get emailAuthFailedToSend => 'Failed to send email';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'Failed to send email. Please try again.';

  @override
  String get emailAuthInvalidEmail =>
      'Invalid email address. Please check the format.';

  @override
  String get emailAuthUserNotFound =>
      'No account found with this email address.';

  @override
  String get emailAuthTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get emailAuthOperationNotAllowed =>
      'Email link sign-in is not enabled.';

  @override
  String get emailAuthQuotaExceeded =>
      'Email quota exceeded. Please try again tomorrow.';

  @override
  String get emailAuthVerificationFailed =>
      'Email verification failed. Please try again.';

  @override
  String get emailAuthTitle => 'Email Verification';

  @override
  String get emailAuthVerifyYourEmail => 'Verify Your Email';

  @override
  String get emailAuthDescription =>
      'Add your email address for account recovery and security. We\'ll send you a secure sign-in link.';

  @override
  String get emailAuthEmailAddress => 'Email Address';

  @override
  String get emailAuthEmailPlaceholder => 'your.email@example.com';

  @override
  String get emailAuthPleaseEnterEmail => 'Please enter your email address';

  @override
  String get emailAuthPleaseEnterValidEmail =>
      'Please enter a valid email address';

  @override
  String get emailAuthCheckEmailToContinue =>
      'Check your email and tap the verification link to continue.';

  @override
  String get emailAuthResendEmail => 'Resend Email';

  @override
  String get emailAuthSendVerificationEmail => 'Send Verification Email';

  @override
  String get emailAuthHowItWorks => 'How Email Verification Works';

  @override
  String get emailAuthHowItWorksSteps =>
      '1. We send you a secure sign-in link\n2. Check your email and tap the link\n3. Your email gets verified automatically\n4. No passwords needed!';

  @override
  String get emailAuthSecurityNotice =>
      'Email verification helps secure your account and enables account recovery if you lose access to your device.';

  @override
  String get phoneAuthFailedToSendCode =>
      'Failed to send verification code. Please try again.';

  @override
  String get phoneAuthInvalidCodeTryAgain =>
      'Invalid verification code. Please try again.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'Phone number verified: $phoneNumber';
  }

  @override
  String get phoneAuthVerificationFailed =>
      'Phone verification failed. Please try again.';

  @override
  String get phoneAuthCodeResent => 'Verification code resent';

  @override
  String get phoneAuthFailedToResendCode =>
      'Failed to resend code. Please try again.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'Invalid phone number. Please check the format.';

  @override
  String get phoneAuthTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'Invalid verification code. Please check and try again.';

  @override
  String get phoneAuthSessionExpired =>
      'Verification session expired. Please request a new code.';

  @override
  String get phoneAuthSmsQuotaExceeded =>
      'SMS quota exceeded. Please try again tomorrow.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'This phone number is already linked to another account.';

  @override
  String get phoneAuthVerificationFailedGeneric =>
      'Verification failed. Please try again.';

  @override
  String get phoneAuthTitle => 'Phone Verification';

  @override
  String get phoneAuthVerifyYourPhone => 'Verify Your Phone';

  @override
  String get phoneAuthEnterVerificationCode => 'Enter Verification Code';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'Add your phone number for account recovery and security';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return 'Enter the 6-digit code sent to $phoneNumber';
  }

  @override
  String get phoneAuthPhoneNumber => 'Phone Number';

  @override
  String get phoneAuthPhonePlaceholder => '+1 (555) 123-4567';

  @override
  String get phoneAuthPleaseEnterPhone => 'Please enter your phone number';

  @override
  String get phoneAuthPleaseEnterValidPhone =>
      'Please enter a valid phone number';

  @override
  String get phoneAuthVerificationCode => 'Verification Code';

  @override
  String get phoneAuthPleaseEnterSixDigitCode =>
      'Please enter the 6-digit code';

  @override
  String get phoneAuthResendCode => 'Resend Code';

  @override
  String get phoneAuthSendVerificationCode => 'Send Verification Code';

  @override
  String get phoneAuthVerifyCode => 'Verify Code';

  @override
  String get phoneAuthChangePhoneNumber => 'Change Phone Number';

  @override
  String get phoneAuthSmsNotice =>
      'We\'ll send you a verification code via SMS. Standard message rates may apply.';

  @override
  String get phoneAuthCodeExpires =>
      'Code expires in 60 seconds. Check your messages.';

  @override
  String get yourDataRights => 'Your Data Rights';

  @override
  String get dataRightsExplanation =>
      'You have full control over your personal data. You can export all your data or permanently delete your account at any time.';

  @override
  String get exportYourData => 'Export Your Data';

  @override
  String get exportDataDescription => 'Download all your account data';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportingData => 'Exporting...';

  @override
  String get exportDataDetails =>
      'Includes: profile, beeps, comments, device info, and preferences. Data is provided in JSON format.';

  @override
  String get dataExportedSuccessfully => 'Data exported successfully';

  @override
  String get dataExportFailed => 'Failed to export data';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountDescription =>
      'Permanently remove your account and all data';

  @override
  String get deleteAccountWarning =>
      'This action cannot be undone. All your beeps, comments, and account data will be permanently deleted.';

  @override
  String get deleteMyAccount => 'Delete My Account';

  @override
  String get deletingAccount => 'Deleting...';

  @override
  String get deleteAccountConfirmTitle => 'Delete Account';

  @override
  String get deleteAccountConfirmMessage =>
      'Are you absolutely sure you want to delete your account? This action is permanent and cannot be undone.';

  @override
  String get dataWillBeDeleted =>
      'The following data will be permanently deleted:';

  @override
  String get deletedDataList =>
      '• Your profile and username\n• All your beeps and reports\n• All your comments\n• Device registration data\n• Location and preference data';

  @override
  String get deleteAccountPermanent => 'Delete Permanently';

  @override
  String get accountDeletedSuccessfully => 'Account deleted successfully';

  @override
  String get accountDeletionFailed => 'Failed to delete account';

  @override
  String get onboardingWelcomeTitle => 'Welcome to UFOBeep';

  @override
  String get onboardingWelcomeBody =>
      'Get instant alerts when UFOs are spotted near your location. Never miss a sighting again!';

  @override
  String get onboardingReportTitle => 'See something? Beep it!';

  @override
  String get onboardingReportBody =>
      'Capture photos and videos of UFO sightings. Share with the global community instantly.';

  @override
  String get onboardingCompassTitle => 'See Where They Looked';

  @override
  String get onboardingCompassBody =>
      'Compass shows you the exact direction the witness was looking when they saw the UFO. Point your phone and look!';

  @override
  String get onboardingCommunityTitle => 'Connect with Skywatchers';

  @override
  String get onboardingCommunityBody =>
      'Read the latest UFO sightings over your morning coffee. Access professional MUFON data and connect with fellow skywatchers.';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get viewOnboardingAgain => 'View Onboarding Again';

  @override
  String get customAlertRange => 'Custom Alert Range';

  @override
  String get enterRangeKm => 'Enter range in km (1-99999)';

  @override
  String get largeRangeWarning =>
      'Large ranges (>100km) may generate many alerts';

  @override
  String get globalRangeWarning =>
      'Very large ranges (>1000km) will send you alerts from around the world';

  @override
  String get invalidRange => 'Please enter a number between 1 and 99999';
}
