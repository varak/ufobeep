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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  /// **'Location access needed'**
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
  /// **'{distance} away'**
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
  /// **'No comments yet. Be the first!'**
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
  /// **'Enable push notifications'**
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
