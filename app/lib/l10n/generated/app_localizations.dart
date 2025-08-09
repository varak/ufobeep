import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'UFOBeep'**
  String get appTitle;

  /// Title for the home/alerts screen
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get homeTitle;

  /// Title for the beep/report screen
  ///
  /// In en, this message translates to:
  /// **'Report Sighting'**
  String get beepTitle;

  /// Title for the chat screen
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// Title for the compass screen
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get compassTitle;

  /// Title for the profile screen
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Title for the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Title for language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// Standard compass mode label
  ///
  /// In en, this message translates to:
  /// **'Standard Mode'**
  String get compassStandardMode;

  /// Pilot compass mode label
  ///
  /// In en, this message translates to:
  /// **'Pilot Mode'**
  String get compassPilotMode;

  /// Description of standard compass mode
  ///
  /// In en, this message translates to:
  /// **'Basic heading and navigation'**
  String get compassStandardDescription;

  /// Description of pilot compass mode
  ///
  /// In en, this message translates to:
  /// **'Advanced navigation with ETA and vectoring'**
  String get compassPilotDescription;

  /// AR view button tooltip
  ///
  /// In en, this message translates to:
  /// **'AR View'**
  String get compassArView;

  /// Compass view button tooltip
  ///
  /// In en, this message translates to:
  /// **'Compass View'**
  String get compassCompassView;

  /// Compass settings button tooltip
  ///
  /// In en, this message translates to:
  /// **'Compass Settings'**
  String get compassSettings;

  /// Compass mode selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Compass Mode'**
  String get compassMode;

  /// Calibrate compass dialog title
  ///
  /// In en, this message translates to:
  /// **'Calibrate Compass'**
  String get calibrateCompass;

  /// Wind information dialog title
  ///
  /// In en, this message translates to:
  /// **'Wind Information'**
  String get windInformation;

  /// Generic message when data is not available
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// Loading state message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Acknowledgment button label
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// Error message when compass is unavailable
  ///
  /// In en, this message translates to:
  /// **'Compass Unavailable'**
  String get compassUnavailable;

  /// Loading message for compass initialization
  ///
  /// In en, this message translates to:
  /// **'Initializing Compass...'**
  String get initializingCompass;

  /// Loading subtitle for sensor access
  ///
  /// In en, this message translates to:
  /// **'Accessing magnetometer and GPS sensors'**
  String get accessingSensors;

  /// Error message when sensor access fails
  ///
  /// In en, this message translates to:
  /// **'Unable to access compass sensors: {error}'**
  String unableToAccessSensors(String error);

  /// Navigation section title with target name
  ///
  /// In en, this message translates to:
  /// **'Navigation to {target}'**
  String navigationTo(String target);

  /// Degrees symbol
  ///
  /// In en, this message translates to:
  /// **'°'**
  String get degrees;

  /// Degrees True symbol
  ///
  /// In en, this message translates to:
  /// **'°T'**
  String get degreesTrue;

  /// Degrees Magnetic symbol
  ///
  /// In en, this message translates to:
  /// **'°M'**
  String get degreesMagnetic;

  /// Heading label
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get heading;

  /// Ground speed label
  ///
  /// In en, this message translates to:
  /// **'Ground Speed'**
  String get groundSpeed;

  /// Altitude label
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get altitude;

  /// Bearing label
  ///
  /// In en, this message translates to:
  /// **'Bearing'**
  String get bearing;

  /// Distance label
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// Wind label
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// Wind component label
  ///
  /// In en, this message translates to:
  /// **'Component'**
  String get component;

  /// Message when wind data is unavailable
  ///
  /// In en, this message translates to:
  /// **'No wind data available'**
  String get noWindData;

  /// Current wind label
  ///
  /// In en, this message translates to:
  /// **'Current Wind:'**
  String get currentWind;

  /// Help text explaining wind component abbreviations
  ///
  /// In en, this message translates to:
  /// **'H=Headwind T=Tailwind X=Crosswind'**
  String get windComponentHelp;

  /// Performance section label
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// Flight instruments section label
  ///
  /// In en, this message translates to:
  /// **'Flight Instruments'**
  String get flightInstruments;

  /// Instructions for compass calibration
  ///
  /// In en, this message translates to:
  /// **'To improve compass accuracy:\\n\\n1. Hold device away from metal objects\\n2. Move device in figure-8 pattern\\n3. Rotate in all directions\\n4. Complete 3-4 full rotations'**
  String get calibrationInstructions;

  /// Alert filter button label
  ///
  /// In en, this message translates to:
  /// **'Filter Alerts'**
  String get alertsFilter;

  /// Message when no alerts are available
  ///
  /// In en, this message translates to:
  /// **'No alerts found'**
  String get noAlertsFound;

  /// Report sighting button label
  ///
  /// In en, this message translates to:
  /// **'Report Sighting'**
  String get reportSighting;

  /// Take photo button label
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Select from gallery button label
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// Submit button label
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Send message placeholder text
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// Message input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
