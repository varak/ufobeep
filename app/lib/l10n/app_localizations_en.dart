// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String reportedAt(String timeAgo, Object time) {
    return 'Reported $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return 'away';
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
  String get reportOnly => 'Report Only';

  @override
  String get videoOnly => 'video only';

  @override
  String get imageOnly => 'image only';

  @override
  String get timeJustNow => 'just now';

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

  @override
  String get detailsTitle => 'Details';

  @override
  String get mufonCase => 'MUFON Case';

  @override
  String get mufonSighting => 'MUFON Sighting';

  @override
  String get mufonLightSighting => 'MUFON Light Sighting';

  @override
  String get mufonSphereSighting => 'MUFON Sphere Sighting';

  @override
  String get mufonDiscSighting => 'MUFON Disc Sighting';

  @override
  String get mufonTriangleSighting => 'MUFON Triangle Sighting';

  @override
  String get mufonCigarSighting => 'MUFON Cigar Sighting';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting';

  @override
  String get mufonRectangleSighting => 'MUFON Rectangle Sighting';

  @override
  String get mufonCylinderSighting => 'MUFON Cylinder Sighting';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Sighting';

  @override
  String get mufonStarlikeSighting => 'MUFON Starlike Sighting';

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
  String get ufoSighting => 'UFO Sighting';

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

  @override
  String get recentUfoBeepsTitle => 'Recent UFO Beeps';

  @override
  String get recentUfoBeepsSubtitle =>
      'Live UFOBeep community reports & MUFON database sightings';

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
  String get previousPage => 'Previous';

  @override
  String get nextPage => 'Next';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Page $currentPage of $totalPages ($totalCount total beeps)';
  }

  @override
  String get heroTagline => 'Get alerts when to go outside and look up';

  @override
  String get heroDescription =>
      'Never miss another UFO sighting. Get real-time alerts when someone near you sees something weird in the sky. Point your phone and find exactly where to look.';

  @override
  String get downloadApp => '📱 Download App';

  @override
  String get viewAllBeeps => '📋 View All Beeps';

  @override
  String get sightingsMap => '🗺️ Sightings Map';

  @override
  String get globalSightingNetwork => 'Global Sighting Network';

  @override
  String get howItWorks => 'How UFOBeep Works';

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
  String get mufonDatabaseReport => 'MUFON Database Report';

  @override
  String get copyShortLinkTitle => 'Copy link to clipboard';

  @override
  String get imageNotFound => 'Image not found';

  @override
  String get ufoSightingAlt => 'UFO sighting';
}
