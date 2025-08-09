// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'UFOBeep';

  @override
  String get homeTitle => 'Alerts';

  @override
  String get beepTitle => 'Report Sighting';

  @override
  String get chatTitle => 'Chat';

  @override
  String get compassTitle => 'Compass';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageTitle => 'Language';

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
  String get compassArView => 'AR View';

  @override
  String get compassCompassView => 'Compass View';

  @override
  String get compassSettings => 'Compass Settings';

  @override
  String get compassMode => 'Compass Mode';

  @override
  String get calibrateCompass => 'Calibrate Compass';

  @override
  String get windInformation => 'Wind Information';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get gotIt => 'Got it';

  @override
  String get compassUnavailable => 'Compass Unavailable';

  @override
  String get initializingCompass => 'Initializing Compass...';

  @override
  String get accessingSensors => 'Accessing magnetometer and GPS sensors';

  @override
  String unableToAccessSensors(String error) {
    return 'Unable to access compass sensors: $error';
  }

  @override
  String navigationTo(String target) {
    return 'Navigation to $target';
  }

  @override
  String get degrees => '°';

  @override
  String get degreesTrue => '°T';

  @override
  String get degreesMagnetic => '°M';

  @override
  String get heading => 'Heading';

  @override
  String get groundSpeed => 'Ground Speed';

  @override
  String get altitude => 'Altitude';

  @override
  String get bearing => 'Bearing';

  @override
  String get distance => 'Distance';

  @override
  String get wind => 'Wind';

  @override
  String get component => 'Component';

  @override
  String get noWindData => 'No wind data available';

  @override
  String get currentWind => 'Current Wind:';

  @override
  String get windComponentHelp => 'H=Headwind T=Tailwind X=Crosswind';

  @override
  String get performance => 'Performance';

  @override
  String get flightInstruments => 'Flight Instruments';

  @override
  String get calibrationInstructions =>
      'To improve compass accuracy:\\n\\n1. Hold device away from metal objects\\n2. Move device in figure-8 pattern\\n3. Rotate in all directions\\n4. Complete 3-4 full rotations';

  @override
  String get alertsFilter => 'Filter Alerts';

  @override
  String get noAlertsFound => 'No alerts found';

  @override
  String get reportSighting => 'Report Sighting';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get submit => 'Submit';

  @override
  String get sendMessage => 'Send message';

  @override
  String get typeMessage => 'Type a message...';
}
