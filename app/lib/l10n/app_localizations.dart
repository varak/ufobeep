import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_no.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('no'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('sv'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'UFOBeep'**
  String get appName;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processing;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGeneric;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get networkError;

  /// No description provided for @permissionsRequired.
  ///
  /// In en, this message translates to:
  /// **'Permissions required'**
  String get permissionsRequired;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to UFOBeep'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time UFO alerts near you'**
  String get welcomeSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter a username'**
  String get enterUsername;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Username updated'**
  String get usernameUpdated;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @tabAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get tabAlerts;

  /// No description provided for @tabBeep.
  ///
  /// In en, this message translates to:
  /// **'Beep'**
  String get tabBeep;

  /// No description provided for @tabChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get tabChat;

  /// No description provided for @tabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get tabMap;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby Alerts'**
  String get alertsTitle;

  /// No description provided for @noAlerts.
  ///
  /// In en, this message translates to:
  /// **'No alerts nearby yet.'**
  String get noAlerts;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @alertDistance.
  ///
  /// In en, this message translates to:
  /// **'{distance} away'**
  String alertDistance(String distance);

  /// No description provided for @alertDirection.
  ///
  /// In en, this message translates to:
  /// **'Bearing {bearing}°'**
  String alertDirection(int bearing);

  /// No description provided for @viewAlert.
  ///
  /// In en, this message translates to:
  /// **'View alert'**
  String get viewAlert;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get viewOnMap;

  /// No description provided for @iSeeItToo.
  ///
  /// In en, this message translates to:
  /// **'I see it too'**
  String get iSeeItToo;

  /// No description provided for @confirmWitnessed.
  ///
  /// In en, this message translates to:
  /// **'Confirm you witnessed this sighting?'**
  String get confirmWitnessed;

  /// No description provided for @witnessConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Thanks — your confirmation was posted.'**
  String get witnessConfirmed;

  /// No description provided for @createBeepTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a Beep'**
  String get createBeepTitle;

  /// No description provided for @beepExplain.
  ///
  /// In en, this message translates to:
  /// **'Capture what you see and alert nearby watchers.'**
  String get beepExplain;

  /// No description provided for @capturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Capture photo'**
  String get capturePhoto;

  /// No description provided for @captureVideo.
  ///
  /// In en, this message translates to:
  /// **'Capture video'**
  String get captureVideo;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get pickFromGallery;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what you\'re seeing in the sky…'**
  String get descriptionHint;

  /// No description provided for @submitBeep.
  ///
  /// In en, this message translates to:
  /// **'Send Beep'**
  String get submitBeep;

  /// No description provided for @beepSent.
  ///
  /// In en, this message translates to:
  /// **'Beep sent'**
  String get beepSent;

  /// No description provided for @beepSentWithUrl.
  ///
  /// In en, this message translates to:
  /// **'Beep sent successfully'**
  String beepSentWithUrl(String shortUrl);

  /// No description provided for @uploadingMedia.
  ///
  /// In en, this message translates to:
  /// **'Uploading media…'**
  String get uploadingMedia;

  /// No description provided for @includeLocation.
  ///
  /// In en, this message translates to:
  /// **'Include location'**
  String get includeLocation;

  /// No description provided for @includeTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Include timestamp'**
  String get includeTimestamp;

  /// No description provided for @beepFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send Beep.'**
  String get beepFailed;

  /// No description provided for @mediaProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing media…'**
  String get mediaProcessing;

  /// No description provided for @cameraPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access needed'**
  String get cameraPermissionTitle;

  /// No description provided for @cameraPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Grant camera access to capture UFO photos and videos.'**
  String get cameraPermissionBody;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'We use your location to send and receive nearby alerts.'**
  String get locationPermissionBody;

  /// No description provided for @microphonePermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone access needed'**
  String get microphonePermissionTitle;

  /// No description provided for @microphonePermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Grant microphone access for video capture with audio.'**
  String get microphonePermissionBody;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @alertDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Sighting Details'**
  String get alertDetailTitle;

  /// No description provided for @reportedBy.
  ///
  /// In en, this message translates to:
  /// **'Reported by {username}'**
  String reportedBy(String username);

  /// No description provided for @reportedAt.
  ///
  /// In en, this message translates to:
  /// **'Reported {timeAgo}'**
  String reportedAt(String timeAgo);

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance}'**
  String distanceAway(String distance);

  /// No description provided for @bearingToObject.
  ///
  /// In en, this message translates to:
  /// **'Bearing to object: {bearing}°'**
  String bearingToObject(int bearing);

  /// No description provided for @openCompass.
  ///
  /// In en, this message translates to:
  /// **'Open compass'**
  String get openCompass;

  /// No description provided for @openAR.
  ///
  /// In en, this message translates to:
  /// **'Open AR overlay'**
  String get openAR;

  /// No description provided for @openChat.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get openChat;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment…'**
  String get addComment;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @commentPosted.
  ///
  /// In en, this message translates to:
  /// **'Comment posted'**
  String get commentPosted;

  /// No description provided for @autoFollowEnabled.
  ///
  /// In en, this message translates to:
  /// **'You’re now following this alert.'**
  String get autoFollowEnabled;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first to comment!'**
  String get noCommentsYet;

  /// No description provided for @newCommentNotification.
  ///
  /// In en, this message translates to:
  /// **'New comment on a sighting you follow.'**
  String get newCommentNotification;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Map'**
  String get mapTitle;

  /// No description provided for @compassTitle.
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get compassTitle;

  /// No description provided for @compassSettings.
  ///
  /// In en, this message translates to:
  /// **'Compass Settings'**
  String get compassSettings;

  /// No description provided for @compassMode.
  ///
  /// In en, this message translates to:
  /// **'Compass Mode'**
  String get compassMode;

  /// No description provided for @compassStandardMode.
  ///
  /// In en, this message translates to:
  /// **'Standard Mode'**
  String get compassStandardMode;

  /// No description provided for @compassPilotMode.
  ///
  /// In en, this message translates to:
  /// **'Pilot Mode'**
  String get compassPilotMode;

  /// No description provided for @compassStandardDescription.
  ///
  /// In en, this message translates to:
  /// **'Basic heading and navigation'**
  String get compassStandardDescription;

  /// No description provided for @compassPilotDescription.
  ///
  /// In en, this message translates to:
  /// **'Advanced navigation with ETA and vectoring'**
  String get compassPilotDescription;

  /// No description provided for @pointingTo.
  ///
  /// In en, this message translates to:
  /// **'Pointing to {direction}'**
  String pointingTo(String direction);

  /// No description provided for @calibratingCompass.
  ///
  /// In en, this message translates to:
  /// **'Calibrating compass…'**
  String get calibratingCompass;

  /// No description provided for @openAROverlay.
  ///
  /// In en, this message translates to:
  /// **'Open AR overlay'**
  String get openAROverlay;

  /// No description provided for @pushTitleAlertNearby.
  ///
  /// In en, this message translates to:
  /// **'UFO alert near you'**
  String get pushTitleAlertNearby;

  /// No description provided for @pushBodyAlertNearby.
  ///
  /// In en, this message translates to:
  /// **'A new sighting was reported {distance} away.'**
  String pushBodyAlertNearby(String distance);

  /// No description provided for @pushTitleComment.
  ///
  /// In en, this message translates to:
  /// **'New comment'**
  String get pushTitleComment;

  /// No description provided for @pushBodyComment.
  ///
  /// In en, this message translates to:
  /// **'Someone commented on a sighting you follow.'**
  String get pushBodyComment;

  /// No description provided for @pushTitleWitness.
  ///
  /// In en, this message translates to:
  /// **'Witness confirmation'**
  String get pushTitleWitness;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @pushBodyWitness.
  ///
  /// In en, this message translates to:
  /// **'A user confirmed they see the same object.'**
  String get pushBodyWitness;

  /// No description provided for @weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// No description provided for @cloudCover.
  ///
  /// In en, this message translates to:
  /// **'Cloud cover: {percent}%'**
  String cloudCover(int percent);

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind: {speed} {unit}'**
  String wind(num speed, String unit);

  /// No description provided for @nearbyAircraft.
  ///
  /// In en, this message translates to:
  /// **'Nearby aircraft'**
  String get nearbyAircraft;

  /// No description provided for @noAircraft.
  ///
  /// In en, this message translates to:
  /// **'No aircraft nearby'**
  String get noAircraft;

  /// No description provided for @loadingContext.
  ///
  /// In en, this message translates to:
  /// **'Loading environmental context…'**
  String get loadingContext;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enablePushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Get notifications for future comments'**
  String get enablePushNotifications;

  /// No description provided for @quietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get quietHours;

  /// No description provided for @quietHoursDesc.
  ///
  /// In en, this message translates to:
  /// **'Silence alerts between selected hours.'**
  String get quietHoursDesc;

  /// No description provided for @quietHoursEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable quiet hours'**
  String get quietHoursEnabled;

  /// No description provided for @quietHoursFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get quietHoursFrom;

  /// No description provided for @quietHoursUntil.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get quietHoursUntil;

  /// No description provided for @quietHoursDefaultTime.
  ///
  /// In en, this message translates to:
  /// **'Default quiet hours'**
  String get quietHoursDefaultTime;

  /// No description provided for @emergencyOverride.
  ///
  /// In en, this message translates to:
  /// **'Emergency override'**
  String get emergencyOverride;

  /// No description provided for @emergencyOverrideDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow urgent alerts during quiet hours'**
  String get emergencyOverrideDesc;

  /// No description provided for @dndMode.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb'**
  String get dndMode;

  /// No description provided for @dndUntil.
  ///
  /// In en, this message translates to:
  /// **'Do not disturb until'**
  String get dndUntil;

  /// No description provided for @dndEnabled.
  ///
  /// In en, this message translates to:
  /// **'DND enabled until {time}'**
  String dndEnabled(Object time);

  /// No description provided for @dndDisabled.
  ///
  /// In en, this message translates to:
  /// **'DND disabled'**
  String get dndDisabled;

  /// No description provided for @quietHoursActive.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours active'**
  String get quietHoursActive;

  /// No description provided for @quietHoursScheduled.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours: {start} - {end}'**
  String quietHoursScheduled(Object end, Object start);

  /// No description provided for @pushNotificationUfoAlert.
  ///
  /// In en, this message translates to:
  /// **'UFO Alert'**
  String get pushNotificationUfoAlert;

  /// No description provided for @pushNotificationAnomalyAlert.
  ///
  /// In en, this message translates to:
  /// **'Anomaly Alert'**
  String get pushNotificationAnomalyAlert;

  /// No description provided for @pushNotificationNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get pushNotificationNearby;

  /// No description provided for @pushNotificationInYourArea.
  ///
  /// In en, this message translates to:
  /// **'in your area. Tap to view details.'**
  String get pushNotificationInYourArea;

  /// No description provided for @pushNotificationCommented.
  ///
  /// In en, this message translates to:
  /// **'{username} commented'**
  String pushNotificationCommented(Object username);

  /// No description provided for @pushNotificationCommentedOn.
  ///
  /// In en, this message translates to:
  /// **'{username} commented on {beepTitle}'**
  String pushNotificationCommentedOn(Object beepTitle, Object username);

  /// No description provided for @pushNotificationGeneric.
  ///
  /// In en, this message translates to:
  /// **'UFOBeep'**
  String get pushNotificationGeneric;

  /// No description provided for @pushNotificationNewSighting.
  ///
  /// In en, this message translates to:
  /// **'New sighting nearby'**
  String get pushNotificationNewSighting;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @unitsImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial (mi, mph)'**
  String get unitsImperial;

  /// No description provided for @unitsMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric (km, km/h)'**
  String get unitsMetric;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @errorNoLocation.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable. Try again outside with clear sky view.'**
  String get errorNoLocation;

  /// No description provided for @errorNoCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable on this device.'**
  String get errorNoCamera;

  /// No description provided for @errorUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Please try again.'**
  String get errorUploadFailed;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied.'**
  String get errorPermissionDenied;

  /// No description provided for @errorInvalidUsername.
  ///
  /// In en, this message translates to:
  /// **'That username isn’t available.'**
  String get errorInvalidUsername;

  /// No description provided for @nothingToShow.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show yet.'**
  String get nothingToShow;

  /// No description provided for @storeShortDesc.
  ///
  /// In en, this message translates to:
  /// **'Instant UFO alerts near you. Capture, confirm, and chat in real time.'**
  String get storeShortDesc;

  /// No description provided for @storeLongDesc.
  ///
  /// In en, this message translates to:
  /// **'UFOBeep sends real-time alerts when someone spots a UFO nearby. Capture photos and videos, confirm sightings with a tap, view direction & distance, and chat with fellow skywatchers.'**
  String get storeLongDesc;

  /// No description provided for @keywords.
  ///
  /// In en, this message translates to:
  /// **'UFO,UAP,OVNI,aliens,sightings,skywatch,alerts,radar,compass'**
  String get keywords;

  /// No description provided for @noAlertsFound.
  ///
  /// In en, this message translates to:
  /// **'No matching alerts'**
  String get noAlertsFound;

  /// No description provided for @alertsFilterHelp.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters to see more results'**
  String get alertsFilterHelp;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @beepOnly.
  ///
  /// In en, this message translates to:
  /// **'Beep Only'**
  String get beepOnly;

  /// No description provided for @reportOnly.
  ///
  /// In en, this message translates to:
  /// **'Text Only'**
  String get reportOnly;

  /// No description provided for @videoOnly.
  ///
  /// In en, this message translates to:
  /// **'Video Only'**
  String get videoOnly;

  /// No description provided for @imageOnly.
  ///
  /// In en, this message translates to:
  /// **'Image Only'**
  String get imageOnly;

  /// No description provided for @mediaOnly.
  ///
  /// In en, this message translates to:
  /// **'Media Only'**
  String get mediaOnly;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String timeDaysAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String timeHoursAgo(int count);

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String timeMinutesAgo(int count);

  /// No description provided for @loadMoreAlerts.
  ///
  /// In en, this message translates to:
  /// **'Load More Alerts'**
  String get loadMoreAlerts;

  /// No description provided for @toggleMufonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle MUFON sightings'**
  String get toggleMufonTooltip;

  /// No description provided for @showMufonData.
  ///
  /// In en, this message translates to:
  /// **'Show MUFON data'**
  String get showMufonData;

  /// No description provided for @hideMufonData.
  ///
  /// In en, this message translates to:
  /// **'Hide MUFON data'**
  String get hideMufonData;

  /// No description provided for @showingUfoBeepOnly.
  ///
  /// In en, this message translates to:
  /// **'Showing only UFOBeep reports'**
  String get showingUfoBeepOnly;

  /// No description provided for @showingAllReports.
  ///
  /// In en, this message translates to:
  /// **'Showing all reports including MUFON database'**
  String get showingAllReports;

  /// No description provided for @filteredSuffix.
  ///
  /// In en, this message translates to:
  /// **'filtered'**
  String get filteredSuffix;

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsTitle;

  /// No description provided for @mufonCase.
  ///
  /// In en, this message translates to:
  /// **'MUFON Case'**
  String get mufonCase;

  /// No description provided for @mufonSighting.
  ///
  /// In en, this message translates to:
  /// **'MUFON Sighting Report'**
  String get mufonSighting;

  /// No description provided for @mufonLightSighting.
  ///
  /// In en, this message translates to:
  /// **'MUFON Light Sighting Report'**
  String get mufonLightSighting;

  /// No description provided for @mufonSphereSighting.
  ///
  /// In en, this message translates to:
  /// **'MUFON Sphere Sighting Report'**
  String get mufonSphereSighting;

  /// No description provided for @mufonDiscSighting.
  ///
  /// In en, this message translates to:
  /// **'MUFON Disc Sighting Report'**
  String get mufonDiscSighting;

  /// No description provided for @mufonTriangleSighting.
  ///
  /// In en, this message translates to:
  /// **'MUFON Triangle Sighting Report'**
  String get mufonTriangleSighting;

  /// No description provided for @mufonCigarSighting.
  ///
  /// In en, this message translates to:
  /// **'MUFON Cigar Sighting Report'**
  String get mufonCigarSighting;

  /// No description provided for @mufonOvalSighting.
  ///
  /// In en, this message translates to:
  /// **'MUFON Oval Sighting Report'**
  String get mufonOvalSighting;

  /// No description provided for @mufonRectangleSighting.
  ///
  /// In en, this message translates to:
  /// **'MUFON Rectangle Sighting Report'**
  String get mufonRectangleSighting;

  /// No description provided for @mufonCylinderSighting.
  ///
  /// In en, this message translates to:
  /// **'MUFON Cylinder Sighting Report'**
  String get mufonCylinderSighting;

  /// No description provided for @mufonBoomerangSighting.
  ///
  /// In en, this message translates to:
  /// **'MUFON Boomerang Sighting Report'**
  String get mufonBoomerangSighting;

  /// No description provided for @mufonStarlikeSighting.
  ///
  /// In en, this message translates to:
  /// **'MUFON Starlike Sighting Report'**
  String get mufonStarlikeSighting;

  /// No description provided for @mufonCaseDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'MUFON Case #{caseNumber} Details'**
  String mufonCaseDetailsTitle(String caseNumber);

  /// No description provided for @sightingDate.
  ///
  /// In en, this message translates to:
  /// **'Sighting Date'**
  String get sightingDate;

  /// No description provided for @mufonDatabaseEntryDate.
  ///
  /// In en, this message translates to:
  /// **'Date Entered into MUFON Database'**
  String get mufonDatabaseEntryDate;

  /// No description provided for @databaseEntry.
  ///
  /// In en, this message translates to:
  /// **'Database Entry'**
  String get databaseEntry;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get shareLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopied;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location:'**
  String get locationLabel;

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time:'**
  String get timeLabel;

  /// No description provided for @reportedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Reported by'**
  String get reportedByLabel;

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown Location'**
  String get unknownLocation;

  /// No description provided for @locationUnknown.
  ///
  /// In en, this message translates to:
  /// **'Location Unknown'**
  String get locationUnknown;

  /// No description provided for @witnessesLabel.
  ///
  /// In en, this message translates to:
  /// **'Witnesses'**
  String get witnessesLabel;

  /// No description provided for @witnessesCountMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} people confirmed this sighting'**
  String witnessesCountMessage(int count);

  /// No description provided for @photoAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Analysis'**
  String get photoAnalysisTitle;

  /// No description provided for @mediaItemsProcessed.
  ///
  /// In en, this message translates to:
  /// **'Analysis: {count} media file(s) processed'**
  String mediaItemsProcessed(int count);

  /// No description provided for @addMoreMedia.
  ///
  /// In en, this message translates to:
  /// **'Add More'**
  String get addMoreMedia;

  /// No description provided for @addMedia.
  ///
  /// In en, this message translates to:
  /// **'Add Media'**
  String get addMedia;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake Photo'**
  String get retakePhoto;

  /// No description provided for @retakeVideo.
  ///
  /// In en, this message translates to:
  /// **'Retake Video'**
  String get retakeVideo;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @basicSettings.
  ///
  /// In en, this message translates to:
  /// **'Basic Settings'**
  String get basicSettings;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'Time Format'**
  String get timeFormat;

  /// No description provided for @timeFormat24Hour.
  ///
  /// In en, this message translates to:
  /// **'24-hour (14:30)'**
  String get timeFormat24Hour;

  /// No description provided for @timeFormat12Hour.
  ///
  /// In en, this message translates to:
  /// **'12-hour (2:30 PM)'**
  String get timeFormat12Hour;

  /// No description provided for @timeFormatDesc.
  ///
  /// In en, this message translates to:
  /// **'Display time in 24-hour or 12-hour format'**
  String get timeFormatDesc;

  /// No description provided for @alertRange.
  ///
  /// In en, this message translates to:
  /// **'Alert Range'**
  String get alertRange;

  /// No description provided for @manageNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage subscriptions & settings'**
  String get manageNotificationsDesc;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// No description provided for @permissionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get permissionLocation;

  /// No description provided for @permissionCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get permissionCamera;

  /// No description provided for @permissionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permissionNotifications;

  /// No description provided for @permissionPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get permissionPhotos;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get permissionGranted;

  /// No description provided for @permissionNotGranted.
  ///
  /// In en, this message translates to:
  /// **'Not granted'**
  String get permissionNotGranted;

  /// No description provided for @permissionGrant.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get permissionGrant;

  /// No description provided for @generateUsername.
  ///
  /// In en, this message translates to:
  /// **'Generate new username'**
  String get generateUsername;

  /// No description provided for @adminTools.
  ///
  /// In en, this message translates to:
  /// **'Admin Tools'**
  String get adminTools;

  /// No description provided for @openAdminPanel.
  ///
  /// In en, this message translates to:
  /// **'Open Admin Panel'**
  String get openAdminPanel;

  /// No description provided for @webAdminInterface.
  ///
  /// In en, this message translates to:
  /// **'Web Admin Interface'**
  String get webAdminInterface;

  /// No description provided for @adminBetaNotice.
  ///
  /// In en, this message translates to:
  /// **'Beta builds only. Admin tools for testing proximity alerts, push notifications, and system diagnostics.'**
  String get adminBetaNotice;

  /// No description provided for @whatDoYouSee.
  ///
  /// In en, this message translates to:
  /// **'What do you see?'**
  String get whatDoYouSee;

  /// No description provided for @ufo.
  ///
  /// In en, this message translates to:
  /// **'UFO'**
  String get ufo;

  /// No description provided for @sighting.
  ///
  /// In en, this message translates to:
  /// **'Sighting'**
  String get sighting;

  /// No description provided for @ufoSighting.
  ///
  /// In en, this message translates to:
  /// **'UFOBeep UFO Alert'**
  String get ufoSighting;

  /// No description provided for @envAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Environmental Analysis'**
  String get envAnalysisTitle;

  /// No description provided for @envAnalysisPending.
  ///
  /// In en, this message translates to:
  /// **'Analysis Pending'**
  String get envAnalysisPending;

  /// No description provided for @envAnalysisPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'Environmental data will be available once processing begins.'**
  String get envAnalysisPendingDesc;

  /// No description provided for @unknownAircraft.
  ///
  /// In en, this message translates to:
  /// **'Unknown Aircraft'**
  String get unknownAircraft;

  /// No description provided for @moreAircraft.
  ///
  /// In en, this message translates to:
  /// **'more aircraft'**
  String get moreAircraft;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @premiumImageryTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Satellite Imagery'**
  String get premiumImageryTitle;

  /// No description provided for @premiumImagerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'High-resolution commercial imagery'**
  String get premiumImagerySubtitle;

  /// No description provided for @sightingTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get sightingTypeLabel;

  /// No description provided for @ufoTypeSphere.
  ///
  /// In en, this message translates to:
  /// **'Sphere'**
  String get ufoTypeSphere;

  /// No description provided for @ufoTypeTriangle.
  ///
  /// In en, this message translates to:
  /// **'Triangle'**
  String get ufoTypeTriangle;

  /// No description provided for @ufoTypeDisk.
  ///
  /// In en, this message translates to:
  /// **'Disk'**
  String get ufoTypeDisk;

  /// No description provided for @ufoTypeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get ufoTypeLight;

  /// No description provided for @ufoTypeFireball.
  ///
  /// In en, this message translates to:
  /// **'Fireball'**
  String get ufoTypeFireball;

  /// No description provided for @ufoTypeCylinder.
  ///
  /// In en, this message translates to:
  /// **'Cylinder'**
  String get ufoTypeCylinder;

  /// No description provided for @ufoTypeCigar.
  ///
  /// In en, this message translates to:
  /// **'Cigar'**
  String get ufoTypeCigar;

  /// No description provided for @ufoTypeRectangle.
  ///
  /// In en, this message translates to:
  /// **'Rectangle'**
  String get ufoTypeRectangle;

  /// No description provided for @ufoTypeFormation.
  ///
  /// In en, this message translates to:
  /// **'Formation'**
  String get ufoTypeFormation;

  /// No description provided for @ufoTypeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get ufoTypeUnknown;

  /// No description provided for @ufoTypeBoomerang.
  ///
  /// In en, this message translates to:
  /// **'Boomerang'**
  String get ufoTypeBoomerang;

  /// No description provided for @ufoTypeDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get ufoTypeDiamond;

  /// No description provided for @ufoTypeOval.
  ///
  /// In en, this message translates to:
  /// **'Oval'**
  String get ufoTypeOval;

  /// No description provided for @ufoTypeCone.
  ///
  /// In en, this message translates to:
  /// **'Cone'**
  String get ufoTypeCone;

  /// No description provided for @ufoTypeCross.
  ///
  /// In en, this message translates to:
  /// **'Cross'**
  String get ufoTypeCross;

  /// No description provided for @ufoTypeDumbbell.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get ufoTypeDumbbell;

  /// No description provided for @ufoTypeTeardrop.
  ///
  /// In en, this message translates to:
  /// **'Teardrop'**
  String get ufoTypeTeardrop;

  /// No description provided for @ufoTypeTicTac.
  ///
  /// In en, this message translates to:
  /// **'Tic Tac'**
  String get ufoTypeTicTac;

  /// No description provided for @ufoTypeBullet.
  ///
  /// In en, this message translates to:
  /// **'Bullet'**
  String get ufoTypeBullet;

  /// No description provided for @ufoTypeSaturn.
  ///
  /// In en, this message translates to:
  /// **'Saturn'**
  String get ufoTypeSaturn;

  /// No description provided for @ufoTypeStarLike.
  ///
  /// In en, this message translates to:
  /// **'Star-like'**
  String get ufoTypeStarLike;

  /// No description provided for @ufoTypeBlimp.
  ///
  /// In en, this message translates to:
  /// **'Blimp'**
  String get ufoTypeBlimp;

  /// No description provided for @shapeTriangle.
  ///
  /// In en, this message translates to:
  /// **'triangle'**
  String get shapeTriangle;

  /// No description provided for @shapeDisc.
  ///
  /// In en, this message translates to:
  /// **'disc'**
  String get shapeDisc;

  /// No description provided for @shapeDisk.
  ///
  /// In en, this message translates to:
  /// **'disk'**
  String get shapeDisk;

  /// No description provided for @shapeSphere.
  ///
  /// In en, this message translates to:
  /// **'sphere'**
  String get shapeSphere;

  /// No description provided for @shapeCigar.
  ///
  /// In en, this message translates to:
  /// **'cigar'**
  String get shapeCigar;

  /// No description provided for @shapeLight.
  ///
  /// In en, this message translates to:
  /// **'light'**
  String get shapeLight;

  /// No description provided for @shapeBoomerang.
  ///
  /// In en, this message translates to:
  /// **'boomerang'**
  String get shapeBoomerang;

  /// No description provided for @shapeDiamond.
  ///
  /// In en, this message translates to:
  /// **'diamond'**
  String get shapeDiamond;

  /// No description provided for @shapeRectangle.
  ///
  /// In en, this message translates to:
  /// **'rectangle'**
  String get shapeRectangle;

  /// No description provided for @shapeOval.
  ///
  /// In en, this message translates to:
  /// **'oval'**
  String get shapeOval;

  /// No description provided for @shapeCone.
  ///
  /// In en, this message translates to:
  /// **'cone'**
  String get shapeCone;

  /// No description provided for @shapeCross.
  ///
  /// In en, this message translates to:
  /// **'cross'**
  String get shapeCross;

  /// No description provided for @shapeCylinder.
  ///
  /// In en, this message translates to:
  /// **'cylinder'**
  String get shapeCylinder;

  /// No description provided for @shapeDumbbell.
  ///
  /// In en, this message translates to:
  /// **'dumbbell'**
  String get shapeDumbbell;

  /// No description provided for @shapeTeardrop.
  ///
  /// In en, this message translates to:
  /// **'teardrop'**
  String get shapeTeardrop;

  /// No description provided for @shapeTicTac.
  ///
  /// In en, this message translates to:
  /// **'tic-tac'**
  String get shapeTicTac;

  /// No description provided for @shapeBullet.
  ///
  /// In en, this message translates to:
  /// **'bullet'**
  String get shapeBullet;

  /// No description provided for @shapeSaturn.
  ///
  /// In en, this message translates to:
  /// **'saturn'**
  String get shapeSaturn;

  /// No description provided for @shapeStarlike.
  ///
  /// In en, this message translates to:
  /// **'starlike'**
  String get shapeStarlike;

  /// No description provided for @shapeBlimp.
  ///
  /// In en, this message translates to:
  /// **'blimp'**
  String get shapeBlimp;

  /// No description provided for @shapeFireball.
  ///
  /// In en, this message translates to:
  /// **'fireball'**
  String get shapeFireball;

  /// No description provided for @shapeFormation.
  ///
  /// In en, this message translates to:
  /// **'formation'**
  String get shapeFormation;

  /// No description provided for @shapeUnknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get shapeUnknown;

  /// No description provided for @actionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsTitle;

  /// No description provided for @addPhotosAndVideos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos & Videos'**
  String get addPhotosAndVideos;

  /// No description provided for @howToReportToMufon.
  ///
  /// In en, this message translates to:
  /// **'How to Report to MUFON'**
  String get howToReportToMufon;

  /// No description provided for @reportToMufon.
  ///
  /// In en, this message translates to:
  /// **'Report to MUFON'**
  String get reportToMufon;

  /// No description provided for @whyReportToMufon.
  ///
  /// In en, this message translates to:
  /// **'Why Report to MUFON?'**
  String get whyReportToMufon;

  /// No description provided for @openMufonReport.
  ///
  /// In en, this message translates to:
  /// **'Open MUFON Report'**
  String get openMufonReport;

  /// No description provided for @confirmedWitness.
  ///
  /// In en, this message translates to:
  /// **'You confirmed this sighting'**
  String get confirmedWitness;

  /// No description provided for @witnessesHaveConfirmed.
  ///
  /// In en, this message translates to:
  /// **'{count} people have confirmed this sighting'**
  String witnessesHaveConfirmed(int count);

  /// No description provided for @aircraftTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Aircraft Tracking'**
  String get aircraftTrackingTitle;

  /// No description provided for @weatherConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather Conditions'**
  String get weatherConditionsTitle;

  /// No description provided for @noSatellitePasses.
  ///
  /// In en, this message translates to:
  /// **'No visible satellite passes found'**
  String get noSatellitePasses;

  /// No description provided for @contentAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Analysis'**
  String get contentAnalysisTitle;

  /// No description provided for @contentSafe.
  ///
  /// In en, this message translates to:
  /// **'Content is safe'**
  String get contentSafe;

  /// No description provided for @contentFlagged.
  ///
  /// In en, this message translates to:
  /// **'Content flagged for review'**
  String get contentFlagged;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidenceLabel;

  /// No description provided for @methodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get methodLabel;

  /// No description provided for @premiumImageryAccessOnly.
  ///
  /// In en, this message translates to:
  /// **'Premium satellite imagery is only available to:'**
  String get premiumImageryAccessOnly;

  /// No description provided for @premiumAccessCreators.
  ///
  /// In en, this message translates to:
  /// **'Alert creators'**
  String get premiumAccessCreators;

  /// No description provided for @premiumAccessWitnesses.
  ///
  /// In en, this message translates to:
  /// **'Confirmed witnesses within visibility range'**
  String get premiumAccessWitnesses;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @directionDistanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Direction & Distance'**
  String get directionDistanceTitle;

  /// No description provided for @mufonCaseTitle.
  ///
  /// In en, this message translates to:
  /// **'MUFON Case #{caseNumber}'**
  String mufonCaseTitle(String caseNumber);

  /// No description provided for @satellitePassesTitle.
  ///
  /// In en, this message translates to:
  /// **'Satellite Passes'**
  String get satellitePassesTitle;

  /// No description provided for @satellitePassExplanation.
  ///
  /// In en, this message translates to:
  /// **'Visible satellite passes during the sighting timeframe. Many UFO reports are actually satellites or space debris.'**
  String get satellitePassExplanation;

  /// No description provided for @followingAlert.
  ///
  /// In en, this message translates to:
  /// **'Following alert - you\'ll get comment notifications'**
  String get followingAlert;

  /// No description provided for @unfollowedAlert.
  ///
  /// In en, this message translates to:
  /// **'Unfollowed alert - no more comment notifications'**
  String get unfollowedAlert;

  /// No description provided for @alertFollowError.
  ///
  /// In en, this message translates to:
  /// **'Error updating follow status'**
  String get alertFollowError;

  /// No description provided for @notificationChannelAlerts.
  ///
  /// In en, this message translates to:
  /// **'UFOBeep Alerts'**
  String get notificationChannelAlerts;

  /// No description provided for @notificationChannelAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications for UFO beeps and proximity alerts'**
  String get notificationChannelAlertsDesc;

  /// No description provided for @notificationSightingTitle.
  ///
  /// In en, this message translates to:
  /// **'UFOBeep UFO Alert'**
  String get notificationSightingTitle;

  /// No description provided for @notificationSightingUrgent.
  ///
  /// In en, this message translates to:
  /// **'⚠️ URGENT UFOBeep UFO Alert'**
  String get notificationSightingUrgent;

  /// No description provided for @notificationSightingEmergency.
  ///
  /// In en, this message translates to:
  /// **'🚨 EMERGENCY UFOBeep UFO Alert'**
  String get notificationSightingEmergency;

  /// No description provided for @notificationSightingBody.
  ///
  /// In en, this message translates to:
  /// **'{witnessText} near {locationName}'**
  String notificationSightingBody(String witnessText, String locationName);

  /// No description provided for @notificationCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'💬 {username} commented'**
  String notificationCommentTitle(String username);

  /// No description provided for @notificationWitnessText.
  ///
  /// In en, this message translates to:
  /// **'New sighting'**
  String get notificationWitnessText;

  /// No description provided for @notificationWitnessTextMultiple.
  ///
  /// In en, this message translates to:
  /// **'{count} witnesses'**
  String notificationWitnessTextMultiple(int count);

  /// No description provided for @notificationActionSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze 1h'**
  String get notificationActionSnooze;

  /// No description provided for @notificationActionDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get notificationActionDismiss;

  /// No description provided for @notificationDistance.
  ///
  /// In en, this message translates to:
  /// **'{distance} away'**
  String notificationDistance(String distance);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get unknown;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'report'**
  String get report;

  /// No description provided for @mufon.
  ///
  /// In en, this message translates to:
  /// **'mufon'**
  String get mufon;

  /// No description provided for @recentUfoBeepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent UFO Beeps'**
  String get recentUfoBeepsTitle;

  /// No description provided for @recentUfoBeepsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live UFO sighting reports from our global community'**
  String get recentUfoBeepsSubtitle;

  /// No description provided for @recentUfoBeepsDescription.
  ///
  /// In en, this message translates to:
  /// **'This feed combines real-time UFOBeep \"beeps\" from our mobile app users with historical reports from the MUFON database.'**
  String get recentUfoBeepsDescription;

  /// No description provided for @loadingBeeps.
  ///
  /// In en, this message translates to:
  /// **'Loading recent beeps...'**
  String get loadingBeeps;

  /// No description provided for @noBeepsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No beeps available at the moment.'**
  String get noBeepsAvailable;

  /// No description provided for @anomalyReported.
  ///
  /// In en, this message translates to:
  /// **'Anomaly reported'**
  String get anomalyReported;

  /// No description provided for @copyShortLink.
  ///
  /// In en, this message translates to:
  /// **'Copy short link'**
  String get copyShortLink;

  /// No description provided for @shareAlert.
  ///
  /// In en, this message translates to:
  /// **'Share alert'**
  String get shareAlert;

  /// No description provided for @ufoSightingAlert.
  ///
  /// In en, this message translates to:
  /// **'UFO Sighting Alert'**
  String get ufoSightingAlert;

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextPage;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {currentPage} of {totalPages} ({totalCount} total beeps)'**
  String pageOf(Object currentPage, Object totalCount, Object totalPages);

  /// No description provided for @firstPage.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get firstPage;

  /// No description provided for @lastPage.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get lastPage;

  /// No description provided for @jumpToPage.
  ///
  /// In en, this message translates to:
  /// **'Jump to page'**
  String get jumpToPage;

  /// No description provided for @heroTagline.
  ///
  /// In en, this message translates to:
  /// **'Get alerts when to go outside and look up'**
  String get heroTagline;

  /// No description provided for @heroDescription.
  ///
  /// In en, this message translates to:
  /// **'Never miss another UFO sighting in your area'**
  String get heroDescription;

  /// No description provided for @downloadApp.
  ///
  /// In en, this message translates to:
  /// **'📱 Download App'**
  String get downloadApp;

  /// No description provided for @viewAllBeeps.
  ///
  /// In en, this message translates to:
  /// **'📋 View All Beeps'**
  String get viewAllBeeps;

  /// No description provided for @sightingsMap.
  ///
  /// In en, this message translates to:
  /// **'🗺️ Sightings Map'**
  String get sightingsMap;

  /// No description provided for @globalSightingNetwork.
  ///
  /// In en, this message translates to:
  /// **'Global Sighting Network'**
  String get globalSightingNetwork;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get howItWorks;

  /// No description provided for @backToBeeps.
  ///
  /// In en, this message translates to:
  /// **'Back to Beeps'**
  String get backToBeeps;

  /// No description provided for @loadingDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading beep details...'**
  String get loadingDetails;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @timeAgo.
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get timeAgo;

  /// No description provided for @timeMinutes.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get timeMinutes;

  /// No description provided for @timeHours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get timeHours;

  /// No description provided for @timeDays.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get timeDays;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get distanceKm;

  /// No description provided for @distanceMiles.
  ///
  /// In en, this message translates to:
  /// **'miles'**
  String get distanceMiles;

  /// No description provided for @distanceNearby.
  ///
  /// In en, this message translates to:
  /// **'nearby'**
  String get distanceNearby;

  /// No description provided for @ufobeepWitnesses.
  ///
  /// In en, this message translates to:
  /// **'Witnesses'**
  String get ufobeepWitnesses;

  /// No description provided for @ufobeepConfirmations.
  ///
  /// In en, this message translates to:
  /// **'Confirmations'**
  String get ufobeepConfirmations;

  /// No description provided for @ufobeepAlertLevel.
  ///
  /// In en, this message translates to:
  /// **'Alert Level'**
  String get ufobeepAlertLevel;

  /// No description provided for @ufobeepReportType.
  ///
  /// In en, this message translates to:
  /// **'UFOBeep Report'**
  String get ufobeepReportType;

  /// No description provided for @mufonAttribution.
  ///
  /// In en, this message translates to:
  /// **'MUFON Database Report'**
  String get mufonAttribution;

  /// No description provided for @mufonCaseNumber.
  ///
  /// In en, this message translates to:
  /// **'Case #'**
  String get mufonCaseNumber;

  /// No description provided for @mufonGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'MUFON Sighting Report'**
  String get mufonGenericTitle;

  /// No description provided for @mufonSphere.
  ///
  /// In en, this message translates to:
  /// **'Sphere'**
  String get mufonSphere;

  /// No description provided for @mufonLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get mufonLight;

  /// No description provided for @mufonDisk.
  ///
  /// In en, this message translates to:
  /// **'Disk'**
  String get mufonDisk;

  /// No description provided for @mufonTriangle.
  ///
  /// In en, this message translates to:
  /// **'Triangle'**
  String get mufonTriangle;

  /// No description provided for @mufonCigar.
  ///
  /// In en, this message translates to:
  /// **'Cigar'**
  String get mufonCigar;

  /// No description provided for @mufonOval.
  ///
  /// In en, this message translates to:
  /// **'Oval'**
  String get mufonOval;

  /// No description provided for @mufonCylinder.
  ///
  /// In en, this message translates to:
  /// **'Cylinder'**
  String get mufonCylinder;

  /// No description provided for @mufonRectangle.
  ///
  /// In en, this message translates to:
  /// **'Rectangle'**
  String get mufonRectangle;

  /// No description provided for @mufonDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get mufonDiamond;

  /// No description provided for @mufonFireball.
  ///
  /// In en, this message translates to:
  /// **'Fireball'**
  String get mufonFireball;

  /// No description provided for @mufonFlash.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get mufonFlash;

  /// No description provided for @mufonFormation.
  ///
  /// In en, this message translates to:
  /// **'Formation'**
  String get mufonFormation;

  /// No description provided for @mufonChanging.
  ///
  /// In en, this message translates to:
  /// **'Changing'**
  String get mufonChanging;

  /// No description provided for @mufonChevron.
  ///
  /// In en, this message translates to:
  /// **'Chevron'**
  String get mufonChevron;

  /// No description provided for @mufonCone.
  ///
  /// In en, this message translates to:
  /// **'Cone'**
  String get mufonCone;

  /// No description provided for @mufonCross.
  ///
  /// In en, this message translates to:
  /// **'Cross'**
  String get mufonCross;

  /// No description provided for @mufonEgg.
  ///
  /// In en, this message translates to:
  /// **'Egg'**
  String get mufonEgg;

  /// No description provided for @mufonOther.
  ///
  /// In en, this message translates to:
  /// **'Object'**
  String get mufonOther;

  /// No description provided for @mufonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Object'**
  String get mufonUnknown;

  /// No description provided for @mufonTitleFormat.
  ///
  /// In en, this message translates to:
  /// **'MUFON {classification} Report'**
  String mufonTitleFormat(Object classification);

  /// No description provided for @nuforcAttribution.
  ///
  /// In en, this message translates to:
  /// **'NUFORC Database Report'**
  String get nuforcAttribution;

  /// No description provided for @nuforcCaseNumber.
  ///
  /// In en, this message translates to:
  /// **'Case #'**
  String get nuforcCaseNumber;

  /// No description provided for @nuforcGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'NUFORC Sighting Report'**
  String get nuforcGenericTitle;

  /// No description provided for @mediaImageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Image not found'**
  String get mediaImageNotFound;

  /// No description provided for @mediaPlayVideo.
  ///
  /// In en, this message translates to:
  /// **'Play Video'**
  String get mediaPlayVideo;

  /// No description provided for @mediaViewImage.
  ///
  /// In en, this message translates to:
  /// **'View Image'**
  String get mediaViewImage;

  /// No description provided for @mediaCount.
  ///
  /// In en, this message translates to:
  /// **'{count} images'**
  String mediaCount(Object count);

  /// No description provided for @mediaCountSingle.
  ///
  /// In en, this message translates to:
  /// **'1 image'**
  String get mediaCountSingle;

  /// No description provided for @mediaMoreImages.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String mediaMoreImages(Object count);

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Beep not found'**
  String get errorNotFound;

  /// No description provided for @errorLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load beep details'**
  String get errorLoadError;

  /// No description provided for @shareYourThoughts.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts about this sighting...'**
  String get shareYourThoughts;

  /// No description provided for @postComment.
  ///
  /// In en, this message translates to:
  /// **'Post Comment'**
  String get postComment;

  /// No description provided for @loggedInAs.
  ///
  /// In en, this message translates to:
  /// **'Logged in as'**
  String get loggedInAs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @notFollowing.
  ///
  /// In en, this message translates to:
  /// **'Not following'**
  String get notFollowing;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @navRecentBeeps.
  ///
  /// In en, this message translates to:
  /// **'Recent Beeps'**
  String get navRecentBeeps;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navDownloadApp.
  ///
  /// In en, this message translates to:
  /// **'Download App'**
  String get navDownloadApp;

  /// No description provided for @alertLevel.
  ///
  /// In en, this message translates to:
  /// **'Alert Level'**
  String get alertLevel;

  /// No description provided for @witnesses.
  ///
  /// In en, this message translates to:
  /// **'Witnesses'**
  String get witnesses;

  /// No description provided for @confirmations.
  ///
  /// In en, this message translates to:
  /// **'Confirmations'**
  String get confirmations;

  /// No description provided for @reporterLabel.
  ///
  /// In en, this message translates to:
  /// **'Reported by user'**
  String get reporterLabel;

  /// No description provided for @coordinatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinatesLabel;

  /// No description provided for @eventTime.
  ///
  /// In en, this message translates to:
  /// **'Event time'**
  String get eventTime;

  /// No description provided for @reportedTime.
  ///
  /// In en, this message translates to:
  /// **'Reported time'**
  String get reportedTime;

  /// No description provided for @addedToUfobeep.
  ///
  /// In en, this message translates to:
  /// **'Added to UFOBeep'**
  String get addedToUfobeep;

  /// No description provided for @mufonDatabaseReport.
  ///
  /// In en, this message translates to:
  /// **'MUFON Case Number:'**
  String get mufonDatabaseReport;

  /// No description provided for @copyShortLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy link to clipboard'**
  String get copyShortLinkTitle;

  /// No description provided for @imageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Image not found'**
  String get imageNotFound;

  /// No description provided for @ufoSightingAlt.
  ///
  /// In en, this message translates to:
  /// **'UFOBeep UFO alert'**
  String get ufoSightingAlt;

  /// No description provided for @celestialDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Celestial Objects'**
  String get celestialDataTitle;

  /// No description provided for @visiblePlanets.
  ///
  /// In en, this message translates to:
  /// **'Visible Planets'**
  String get visiblePlanets;

  /// No description provided for @locationDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Information'**
  String get locationDataTitle;

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @processingSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing Summary'**
  String get processingSummaryTitle;

  /// No description provided for @processingTime.
  ///
  /// In en, this message translates to:
  /// **'Processing Time'**
  String get processingTime;

  /// No description provided for @successful.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get successful;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @locationEnrichmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Details'**
  String get locationEnrichmentTitle;

  /// No description provided for @aircraftDataSource.
  ///
  /// In en, this message translates to:
  /// **'Data Source'**
  String get aircraftDataSource;

  /// No description provided for @noAircraftDetected.
  ///
  /// In en, this message translates to:
  /// **'No aircraft detected'**
  String get noAircraftDetected;

  /// No description provided for @sightingReport.
  ///
  /// In en, this message translates to:
  /// **'Sighting Report'**
  String get sightingReport;

  /// No description provided for @ufoAlert.
  ///
  /// In en, this message translates to:
  /// **'UFO Alert'**
  String get ufoAlert;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @notificationTickerUfoAlert.
  ///
  /// In en, this message translates to:
  /// **'UFO Alert - New Sighting Nearby'**
  String get notificationTickerUfoAlert;

  /// No description provided for @notificationTickerComment.
  ///
  /// In en, this message translates to:
  /// **'New Comment on UFO Alert'**
  String get notificationTickerComment;

  /// No description provided for @weatherConditions.
  ///
  /// In en, this message translates to:
  /// **'Weather Conditions'**
  String get weatherConditions;

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @pressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressure;

  /// No description provided for @locationDetails.
  ///
  /// In en, this message translates to:
  /// **'Location Details'**
  String get locationDetails;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @satelliteActivity.
  ///
  /// In en, this message translates to:
  /// **'Satellite Activity'**
  String get satelliteActivity;

  /// No description provided for @satellitesVisibleOverhead.
  ///
  /// In en, this message translates to:
  /// **'Satellites visible overhead at sighting time & location'**
  String get satellitesVisibleOverhead;

  /// No description provided for @dataSource.
  ///
  /// In en, this message translates to:
  /// **'Data Source'**
  String get dataSource;

  /// No description provided for @blackskyImagery.
  ///
  /// In en, this message translates to:
  /// **'BlackSky Imagery'**
  String get blackskyImagery;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @groundResolution.
  ///
  /// In en, this message translates to:
  /// **'35cm ground resolution'**
  String get groundResolution;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @averageDelivery.
  ///
  /// In en, this message translates to:
  /// **'90-minute average'**
  String get averageDelivery;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @skyfiSatelliteImagery.
  ///
  /// In en, this message translates to:
  /// **'SkyFi Satellite Imagery'**
  String get skyfiSatelliteImagery;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @remoteArea.
  ///
  /// In en, this message translates to:
  /// **'Remote Area'**
  String get remoteArea;

  /// No description provided for @startingPrice.
  ///
  /// In en, this message translates to:
  /// **'Starting Price'**
  String get startingPrice;

  /// No description provided for @coverage.
  ///
  /// In en, this message translates to:
  /// **'Coverage'**
  String get coverage;

  /// No description provided for @confidenceCoverage.
  ///
  /// In en, this message translates to:
  /// **'95% confidence'**
  String get confidenceCoverage;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @shareThoughts.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts about this sighting...'**
  String get shareThoughts;

  /// No description provided for @postCommand.
  ///
  /// In en, this message translates to:
  /// **'Post Command'**
  String get postCommand;

  /// No description provided for @clouds.
  ///
  /// In en, this message translates to:
  /// **'Clouds'**
  String get clouds;

  /// No description provided for @windLabel.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get windLabel;

  /// No description provided for @filterAlerts.
  ///
  /// In en, this message translates to:
  /// **'Filter Alerts'**
  String get filterAlerts;

  /// No description provided for @alertSource.
  ///
  /// In en, this message translates to:
  /// **'Alert Source'**
  String get alertSource;

  /// No description provided for @ufobeepOnly.
  ///
  /// In en, this message translates to:
  /// **'UFOBeep Only'**
  String get ufobeepOnly;

  /// No description provided for @ufobeepOnlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Show only original UFOBeep reports (exclude MUFON database)'**
  String get ufobeepOnlyDescription;

  /// No description provided for @alertDistanceRange.
  ///
  /// In en, this message translates to:
  /// **'Alert Distance Range'**
  String get alertDistanceRange;

  /// No description provided for @showAllAlerts.
  ///
  /// In en, this message translates to:
  /// **'Show All Alerts'**
  String get showAllAlerts;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAll;

  /// No description provided for @distanceSliderDescription.
  ///
  /// In en, this message translates to:
  /// **'Drag to adjust how far you want to see alerts. Start from weather visibility distance up to showing all alerts regardless of distance.'**
  String get distanceSliderDescription;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @notificationRange.
  ///
  /// In en, this message translates to:
  /// **'Notification Range'**
  String get notificationRange;

  /// No description provided for @notificationRangeDescription.
  ///
  /// In en, this message translates to:
  /// **'Get push alerts for sightings within this distance'**
  String get notificationRangeDescription;

  /// No description provided for @viewingRange.
  ///
  /// In en, this message translates to:
  /// **'Viewing Range'**
  String get viewingRange;

  /// No description provided for @viewingRangeDescription.
  ///
  /// In en, this message translates to:
  /// **'Show sightings within this distance when browsing'**
  String get viewingRangeDescription;

  /// No description provided for @weatherVisibility.
  ///
  /// In en, this message translates to:
  /// **'Weather Visibility (~10km)'**
  String get weatherVisibility;

  /// No description provided for @localArea.
  ///
  /// In en, this message translates to:
  /// **'Local Area (25km)'**
  String get localArea;

  /// No description provided for @regional.
  ///
  /// In en, this message translates to:
  /// **'Regional'**
  String get regional;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @alertBrowsing.
  ///
  /// In en, this message translates to:
  /// **'Alert Browsing'**
  String get alertBrowsing;

  /// No description provided for @pushAlertsWithinDistance.
  ///
  /// In en, this message translates to:
  /// **'Get notifications within this range'**
  String get pushAlertsWithinDistance;

  /// No description provided for @showAlertsWhenBrowsing.
  ///
  /// In en, this message translates to:
  /// **'Filter what you see in the list'**
  String get showAlertsWhenBrowsing;

  /// No description provided for @heroMainTagline.
  ///
  /// In en, this message translates to:
  /// **'Get a beep on your phone when UFOs are spotted nearby'**
  String get heroMainTagline;

  /// No description provided for @heroSecondaryTagline.
  ///
  /// In en, this message translates to:
  /// **'Find out when and where to look at the sky'**
  String get heroSecondaryTagline;

  /// No description provided for @sourceFilters.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceFilters;

  /// No description provided for @sourceFiltersDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose which reports appear in your feed'**
  String get sourceFiltersDescription;

  /// No description provided for @ufobeepAndMufon.
  ///
  /// In en, this message translates to:
  /// **'UFOBeep + MUFON'**
  String get ufobeepAndMufon;

  /// No description provided for @ufobeepOnlySource.
  ///
  /// In en, this message translates to:
  /// **'UFOBeep only'**
  String get ufobeepOnlySource;

  /// No description provided for @mufonOnlySource.
  ///
  /// In en, this message translates to:
  /// **'MUFON only'**
  String get mufonOnlySource;

  /// No description provided for @browseFilters.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browseFilters;

  /// No description provided for @browseFiltersDescription.
  ///
  /// In en, this message translates to:
  /// **'How to view and sort alerts'**
  String get browseFiltersDescription;

  /// No description provided for @sortByNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortByNewest;

  /// No description provided for @sortByNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get sortByNearest;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @pushAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Push Alerts'**
  String get pushAlertsTitle;

  /// No description provided for @pushAlertsDescription.
  ///
  /// In en, this message translates to:
  /// **'What pings your phone'**
  String get pushAlertsDescription;

  /// No description provided for @alertRadius.
  ///
  /// In en, this message translates to:
  /// **'Alert Radius'**
  String get alertRadius;

  /// No description provided for @mufonNoPushInfo.
  ///
  /// In en, this message translates to:
  /// **'MUFON reports are imported nightly and do not trigger push alerts'**
  String get mufonNoPushInfo;

  /// No description provided for @privacyData.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data'**
  String get privacyData;

  /// No description provided for @privacyPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'How we protect and use your data'**
  String get privacyPolicyDesc;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsOfServiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Legal terms and conditions'**
  String get termsOfServiceDesc;

  /// No description provided for @locationTracking.
  ///
  /// In en, this message translates to:
  /// **'Location Tracking'**
  String get locationTracking;

  /// No description provided for @locationTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'Background location for proximity alerts'**
  String get locationTrackingDesc;

  /// No description provided for @locationTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Background Location Tracking'**
  String get locationTrackingTitle;

  /// No description provided for @locationTrackingExplanation.
  ///
  /// In en, this message translates to:
  /// **'UFOBeep monitors your location in the background to send you proximity alerts when UFO sightings happen near your current location, even when you\'re away from home.'**
  String get locationTrackingExplanation;

  /// No description provided for @locationTrackingBattery.
  ///
  /// In en, this message translates to:
  /// **'Uses intelligent geofencing for <3% battery impact'**
  String get locationTrackingBattery;

  /// No description provided for @backgroundLocationTracking.
  ///
  /// In en, this message translates to:
  /// **'Enable Background Tracking'**
  String get backgroundLocationTracking;

  /// No description provided for @locationTrackingActive.
  ///
  /// In en, this message translates to:
  /// **'Monitoring location for proximity alerts'**
  String get locationTrackingActive;

  /// No description provided for @locationTrackingInactive.
  ///
  /// In en, this message translates to:
  /// **'Location tracking is disabled'**
  String get locationTrackingInactive;

  /// No description provided for @locationTrackingDisabledWarning.
  ///
  /// In en, this message translates to:
  /// **'You won\'t receive proximity alerts when you move to new locations'**
  String get locationTrackingDisabledWarning;

  /// No description provided for @trackingStatus.
  ///
  /// In en, this message translates to:
  /// **'Tracking Status'**
  String get trackingStatus;

  /// No description provided for @monitoringStatus.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get monitoringStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @lastKnownLocation.
  ///
  /// In en, this message translates to:
  /// **'Last Known Location'**
  String get lastKnownLocation;

  /// No description provided for @lastLocationUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get lastLocationUpdate;

  /// No description provided for @movementThreshold.
  ///
  /// In en, this message translates to:
  /// **'Movement Threshold'**
  String get movementThreshold;

  /// No description provided for @updateFrequency.
  ///
  /// In en, this message translates to:
  /// **'Update Frequency'**
  String get updateFrequency;

  /// No description provided for @batteryImpact.
  ///
  /// In en, this message translates to:
  /// **'Battery Impact'**
  String get batteryImpact;

  /// No description provided for @dataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data Privacy'**
  String get dataPrivacy;

  /// No description provided for @locationPermissionExplanation.
  ///
  /// In en, this message translates to:
  /// **'UFOBeep needs \'Always Allow\' location permission to monitor your movement and send proximity alerts when you\'re in new locations.'**
  String get locationPermissionExplanation;

  /// No description provided for @benefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefitsTitle;

  /// No description provided for @locationTrackingBenefits.
  ///
  /// In en, this message translates to:
  /// **'• Get UFO alerts wherever you travel\n• Automatic location updates\n• No manual setup required'**
  String get locationTrackingBenefits;

  /// No description provided for @allowLocationAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow Location Access'**
  String get allowLocationAccess;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required for background tracking'**
  String get locationPermissionRequired;

  /// No description provided for @locationTrackingEnabled.
  ///
  /// In en, this message translates to:
  /// **'Background location tracking enabled'**
  String get locationTrackingEnabled;

  /// No description provided for @locationTrackingDisabled.
  ///
  /// In en, this message translates to:
  /// **'Background location tracking disabled'**
  String get locationTrackingDisabled;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @dataManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Export or delete your account data'**
  String get dataManagementDesc;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Real-time sighting alerts'**
  String get splashTagline;

  /// No description provided for @splashStartingUp.
  ///
  /// In en, this message translates to:
  /// **'Starting up...'**
  String get splashStartingUp;

  /// No description provided for @splashInitializationFailed.
  ///
  /// In en, this message translates to:
  /// **'Initialization failed'**
  String get splashInitializationFailed;

  /// No description provided for @splashInitializationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Initialization Failed'**
  String get splashInitializationFailedTitle;

  /// No description provided for @splashInitializationError.
  ///
  /// In en, this message translates to:
  /// **'The app failed to initialize properly:'**
  String get splashInitializationError;

  /// No description provided for @splashRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get splashRetry;

  /// No description provided for @splashContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get splashContinue;

  /// No description provided for @splashInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get splashInitializing;

  /// No description provided for @signInWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome {username}!'**
  String signInWelcome(String username);

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: {error}'**
  String signInFailed(String error);

  /// No description provided for @signInPleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get signInPleaseEnterEmail;

  /// No description provided for @signInPleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get signInPleaseEnterValidEmail;

  /// No description provided for @signInMagicLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Magic link sent! Check your email and click the link to sign in.'**
  String get signInMagicLinkSent;

  /// No description provided for @signInMagicLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send magic link. Please try again.'**
  String get signInMagicLinkFailed;

  /// No description provided for @signInAllDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get signInAllDataCleared;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time UFO sighting alerts and MUFON reports'**
  String get signInSubtitle;

  /// No description provided for @signInGoogleLoading.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signInGoogleLoading;

  /// No description provided for @signInContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInContinueWithGoogle;

  /// No description provided for @signInOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get signInOr;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get signInWithEmail;

  /// No description provided for @signInEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a secure link to sign in'**
  String get signInEmailDescription;

  /// No description provided for @signInEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get signInEmailAddress;

  /// No description provided for @signInEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get signInEmailPlaceholder;

  /// No description provided for @signInTryAgainIn.
  ///
  /// In en, this message translates to:
  /// **'Try again in {seconds}s'**
  String signInTryAgainIn(int seconds);

  /// No description provided for @signInSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get signInSending;

  /// No description provided for @signInSendMagicLink.
  ///
  /// In en, this message translates to:
  /// **'Send Magic Link'**
  String get signInSendMagicLink;

  /// No description provided for @signInCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email! The link expires in 15 minutes.'**
  String get signInCheckEmail;

  /// No description provided for @signInSecureAuth.
  ///
  /// In en, this message translates to:
  /// **'Secure Authentication'**
  String get signInSecureAuth;

  /// No description provided for @signInSecureAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'Use Google Sign-In for instant access, or email magic links that expire in 15 minutes.'**
  String get signInSecureAuthDescription;

  /// No description provided for @signInClearAllDataDebug.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data (Debug)'**
  String get signInClearAllDataDebug;

  /// No description provided for @emailAuthFailedToSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to send email'**
  String get emailAuthFailedToSend;

  /// No description provided for @emailAuthFailedToSendTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to send email. Please try again.'**
  String get emailAuthFailedToSendTryAgain;

  /// No description provided for @emailAuthInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address. Please check the format.'**
  String get emailAuthInvalidEmail;

  /// No description provided for @emailAuthUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email address.'**
  String get emailAuthUserNotFound;

  /// No description provided for @emailAuthTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get emailAuthTooManyRequests;

  /// No description provided for @emailAuthOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Email link sign-in is not enabled.'**
  String get emailAuthOperationNotAllowed;

  /// No description provided for @emailAuthQuotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'Email quota exceeded. Please try again tomorrow.'**
  String get emailAuthQuotaExceeded;

  /// No description provided for @emailAuthVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Email verification failed. Please try again.'**
  String get emailAuthVerificationFailed;

  /// No description provided for @emailAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailAuthTitle;

  /// No description provided for @emailAuthVerifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get emailAuthVerifyYourEmail;

  /// No description provided for @emailAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your email address for account recovery and security. We\'ll send you a secure sign-in link.'**
  String get emailAuthDescription;

  /// No description provided for @emailAuthEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAuthEmailAddress;

  /// No description provided for @emailAuthEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'your.email@example.com'**
  String get emailAuthEmailPlaceholder;

  /// No description provided for @emailAuthPleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get emailAuthPleaseEnterEmail;

  /// No description provided for @emailAuthPleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailAuthPleaseEnterValidEmail;

  /// No description provided for @emailAuthCheckEmailToContinue.
  ///
  /// In en, this message translates to:
  /// **'Check your email and tap the verification link to continue.'**
  String get emailAuthCheckEmailToContinue;

  /// No description provided for @emailAuthResendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get emailAuthResendEmail;

  /// No description provided for @emailAuthSendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Email'**
  String get emailAuthSendVerificationEmail;

  /// No description provided for @emailAuthHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How Email Verification Works'**
  String get emailAuthHowItWorks;

  /// No description provided for @emailAuthHowItWorksSteps.
  ///
  /// In en, this message translates to:
  /// **'1. We send you a secure sign-in link\n2. Check your email and tap the link\n3. Your email gets verified automatically\n4. No passwords needed!'**
  String get emailAuthHowItWorksSteps;

  /// No description provided for @emailAuthSecurityNotice.
  ///
  /// In en, this message translates to:
  /// **'Email verification helps secure your account and enables account recovery if you lose access to your device.'**
  String get emailAuthSecurityNotice;

  /// No description provided for @phoneAuthFailedToSendCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification code. Please try again.'**
  String get phoneAuthFailedToSendCode;

  /// No description provided for @phoneAuthInvalidCodeTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please try again.'**
  String get phoneAuthInvalidCodeTryAgain;

  /// No description provided for @phoneAuthPhoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone number verified: {phoneNumber}'**
  String phoneAuthPhoneVerified(String phoneNumber);

  /// No description provided for @phoneAuthVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Phone verification failed. Please try again.'**
  String get phoneAuthVerificationFailed;

  /// No description provided for @phoneAuthCodeResent.
  ///
  /// In en, this message translates to:
  /// **'Verification code resent'**
  String get phoneAuthCodeResent;

  /// No description provided for @phoneAuthFailedToResendCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend code. Please try again.'**
  String get phoneAuthFailedToResendCode;

  /// No description provided for @phoneAuthInvalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number. Please check the format.'**
  String get phoneAuthInvalidPhoneNumber;

  /// No description provided for @phoneAuthTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get phoneAuthTooManyRequests;

  /// No description provided for @phoneAuthInvalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please check and try again.'**
  String get phoneAuthInvalidVerificationCode;

  /// No description provided for @phoneAuthSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification session expired. Please request a new code.'**
  String get phoneAuthSessionExpired;

  /// No description provided for @phoneAuthSmsQuotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'SMS quota exceeded. Please try again tomorrow.'**
  String get phoneAuthSmsQuotaExceeded;

  /// No description provided for @phoneAuthCredentialAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already linked to another account.'**
  String get phoneAuthCredentialAlreadyInUse;

  /// No description provided for @phoneAuthVerificationFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Verification failed. Please try again.'**
  String get phoneAuthVerificationFailedGeneric;

  /// No description provided for @phoneAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Verification'**
  String get phoneAuthTitle;

  /// No description provided for @phoneAuthVerifyYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Phone'**
  String get phoneAuthVerifyYourPhone;

  /// No description provided for @phoneAuthEnterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get phoneAuthEnterVerificationCode;

  /// No description provided for @phoneAuthAddPhoneForSecurity.
  ///
  /// In en, this message translates to:
  /// **'Add your phone number for account recovery and security'**
  String get phoneAuthAddPhoneForSecurity;

  /// No description provided for @phoneAuthEnterSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phoneNumber}'**
  String phoneAuthEnterSixDigitCode(String phoneNumber);

  /// No description provided for @phoneAuthPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneAuthPhoneNumber;

  /// No description provided for @phoneAuthPhonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'+1 (555) 123-4567'**
  String get phoneAuthPhonePlaceholder;

  /// No description provided for @phoneAuthPleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get phoneAuthPleaseEnterPhone;

  /// No description provided for @phoneAuthPleaseEnterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get phoneAuthPleaseEnterValidPhone;

  /// No description provided for @phoneAuthVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get phoneAuthVerificationCode;

  /// No description provided for @phoneAuthPleaseEnterSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code'**
  String get phoneAuthPleaseEnterSixDigitCode;

  /// No description provided for @phoneAuthResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get phoneAuthResendCode;

  /// No description provided for @phoneAuthSendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get phoneAuthSendVerificationCode;

  /// No description provided for @phoneAuthVerifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get phoneAuthVerifyCode;

  /// No description provided for @phoneAuthChangePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Change Phone Number'**
  String get phoneAuthChangePhoneNumber;

  /// No description provided for @phoneAuthSmsNotice.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a verification code via SMS. Standard message rates may apply.'**
  String get phoneAuthSmsNotice;

  /// No description provided for @phoneAuthCodeExpires.
  ///
  /// In en, this message translates to:
  /// **'Code expires in 60 seconds. Check your messages.'**
  String get phoneAuthCodeExpires;

  /// No description provided for @yourDataRights.
  ///
  /// In en, this message translates to:
  /// **'Your Data Rights'**
  String get yourDataRights;

  /// No description provided for @dataRightsExplanation.
  ///
  /// In en, this message translates to:
  /// **'You have full control over your personal data. You can export all your data or permanently delete your account at any time.'**
  String get dataRightsExplanation;

  /// No description provided for @exportYourData.
  ///
  /// In en, this message translates to:
  /// **'Export Your Data'**
  String get exportYourData;

  /// No description provided for @exportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Download all your account data'**
  String get exportDataDescription;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportingData.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exportingData;

  /// No description provided for @exportDataDetails.
  ///
  /// In en, this message translates to:
  /// **'Includes: profile, beeps, comments, device info, and preferences. Data is provided in JSON format.'**
  String get exportDataDetails;

  /// No description provided for @dataExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get dataExportedSuccessfully;

  /// No description provided for @dataExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export data'**
  String get dataExportFailed;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account and all data'**
  String get deleteAccountDescription;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your beeps, comments, and account data will be permanently deleted.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deletingAccount;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to delete your account? This action is permanent and cannot be undone.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @dataWillBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'The following data will be permanently deleted:'**
  String get dataWillBeDeleted;

  /// No description provided for @deletedDataList.
  ///
  /// In en, this message translates to:
  /// **'• Your profile and username\n• All your beeps and reports\n• All your comments\n• Device registration data\n• Location and preference data'**
  String get deletedDataList;

  /// No description provided for @deleteAccountPermanent.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deleteAccountPermanent;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccessfully;

  /// No description provided for @accountDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get accountDeletionFailed;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to UFOBeep'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Get instant alerts when UFOs are spotted near your location. Never miss a sighting again!'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingReportTitle.
  ///
  /// In en, this message translates to:
  /// **'See something? Beep it!'**
  String get onboardingReportTitle;

  /// No description provided for @onboardingReportBody.
  ///
  /// In en, this message translates to:
  /// **'Capture photos and videos of UFO sightings. Share with the global community instantly.'**
  String get onboardingReportBody;

  /// No description provided for @onboardingCompassTitle.
  ///
  /// In en, this message translates to:
  /// **'See Where They Looked'**
  String get onboardingCompassTitle;

  /// No description provided for @onboardingCompassBody.
  ///
  /// In en, this message translates to:
  /// **'Compass shows you the exact direction the witness was looking when they saw the UFO. Point your phone and look!'**
  String get onboardingCompassBody;

  /// No description provided for @onboardingCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with Skywatchers'**
  String get onboardingCommunityTitle;

  /// No description provided for @onboardingCommunityBody.
  ///
  /// In en, this message translates to:
  /// **'Read the latest UFO sightings over your morning coffee. Access professional MUFON data and connect with fellow skywatchers.'**
  String get onboardingCommunityBody;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @viewOnboardingAgain.
  ///
  /// In en, this message translates to:
  /// **'View Onboarding Again'**
  String get viewOnboardingAgain;

  /// No description provided for @customAlertRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Alert Range'**
  String get customAlertRange;

  /// No description provided for @enterRangeKm.
  ///
  /// In en, this message translates to:
  /// **'Enter range in km (1-99999)'**
  String get enterRangeKm;

  /// No description provided for @largeRangeWarning.
  ///
  /// In en, this message translates to:
  /// **'Large ranges (>100km) may generate many alerts'**
  String get largeRangeWarning;

  /// No description provided for @globalRangeWarning.
  ///
  /// In en, this message translates to:
  /// **'Very large ranges (>1000km) will send you alerts from around the world'**
  String get globalRangeWarning;

  /// No description provided for @invalidRange.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number between 1 and 99999'**
  String get invalidRange;

  /// No description provided for @celestialSunDaylight.
  ///
  /// In en, this message translates to:
  /// **'Sun is up - daylight conditions may affect sighting visibility'**
  String get celestialSunDaylight;

  /// No description provided for @celestialSunTwilight.
  ///
  /// In en, this message translates to:
  /// **'Twilight conditions - some visibility but darker than daylight'**
  String get celestialSunTwilight;

  /// No description provided for @celestialSunDark.
  ///
  /// In en, this message translates to:
  /// **'Dark conditions - optimal for observing objects in sky'**
  String get celestialSunDark;

  /// No description provided for @celestialMoonBright.
  ///
  /// In en, this message translates to:
  /// **'Bright {phase} moon visible - may illuminate or obscure other objects'**
  String celestialMoonBright(Object phase);

  /// No description provided for @celestialMoonModerate.
  ///
  /// In en, this message translates to:
  /// **'{phase} moon visible - moderate lighting conditions'**
  String celestialMoonModerate(Object phase);

  /// No description provided for @celestialMoonThin.
  ///
  /// In en, this message translates to:
  /// **'Thin {phase} moon visible - minimal lighting'**
  String celestialMoonThin(Object phase);

  /// No description provided for @celestialMoonHidden.
  ///
  /// In en, this message translates to:
  /// **'{phase} moon below horizon - no lunar illumination'**
  String celestialMoonHidden(Object phase);

  /// No description provided for @celestialNoPlanets.
  ///
  /// In en, this message translates to:
  /// **'No bright planets visible that could be mistaken for UFOs'**
  String get celestialNoPlanets;

  /// No description provided for @celestialPlanetHigh.
  ///
  /// In en, this message translates to:
  /// **'{planet} high overhead ({altitude}°) - very prominent'**
  String celestialPlanetHigh(Object altitude, Object planet);

  /// No description provided for @celestialPlanetMedium.
  ///
  /// In en, this message translates to:
  /// **'{planet} visible at {altitude}° - could be mistaken for aircraft'**
  String celestialPlanetMedium(Object altitude, Object planet);

  /// No description provided for @celestialPlanetLow.
  ///
  /// In en, this message translates to:
  /// **'{planet} low on horizon ({altitude}°)'**
  String celestialPlanetLow(Object altitude, Object planet);

  /// No description provided for @celestialNoStars.
  ///
  /// In en, this message translates to:
  /// **'No unusually bright stars visible'**
  String get celestialNoStars;

  /// No description provided for @celestialStarSingle.
  ///
  /// In en, this message translates to:
  /// **'{star} prominent at {altitude}° altitude'**
  String celestialStarSingle(Object altitude, Object star);

  /// No description provided for @celestialStarsMultiple.
  ///
  /// In en, this message translates to:
  /// **'{count} bright stars visible - {names}'**
  String celestialStarsMultiple(Object count, Object names);

  /// No description provided for @celestialSummaryDaylight.
  ///
  /// In en, this message translates to:
  /// **'Daylight conditions'**
  String get celestialSummaryDaylight;

  /// No description provided for @celestialSummaryDark.
  ///
  /// In en, this message translates to:
  /// **'Dark sky conditions'**
  String get celestialSummaryDark;

  /// No description provided for @celestialSummaryMoonUp.
  ///
  /// In en, this message translates to:
  /// **'moon illumination present'**
  String get celestialSummaryMoonUp;

  /// No description provided for @celestialSummaryMoonDown.
  ///
  /// In en, this message translates to:
  /// **'no moon illumination'**
  String get celestialSummaryMoonDown;

  /// No description provided for @celestialSummaryManyObjects.
  ///
  /// In en, this message translates to:
  /// **'{count} bright objects that could be confused with UFOs'**
  String celestialSummaryManyObjects(Object count);

  /// No description provided for @celestialSummarySomeObjects.
  ///
  /// In en, this message translates to:
  /// **'{count} bright object(s) visible'**
  String celestialSummarySomeObjects(Object count);

  /// No description provided for @celestialSummaryFewObjects.
  ///
  /// In en, this message translates to:
  /// **'minimal bright objects in sky'**
  String get celestialSummaryFewObjects;

  /// No description provided for @celestialSkySummary.
  ///
  /// In en, this message translates to:
  /// **'Sky conditions: {conditions}'**
  String celestialSkySummary(Object conditions);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'fi',
    'fr',
    'he',
    'hi',
    'it',
    'ja',
    'ko',
    'nl',
    'no',
    'pl',
    'pt',
    'ru',
    'sv',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'no':
      return AppLocalizationsNo();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sv':
      return AppLocalizationsSv();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
