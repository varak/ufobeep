// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'UFOBeep';

  @override
  String get homeTitle => 'Alarme';

  @override
  String get beepTitle => 'Sichtung Melden';

  @override
  String get chatTitle => 'Chat';

  @override
  String get compassTitle => 'Kompass';

  @override
  String get profileTitle => 'Profil';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get compassStandardMode => 'Standard-Modus';

  @override
  String get compassPilotMode => 'Piloten-Modus';

  @override
  String get compassStandardDescription =>
      'Grundlegende Kurs- und Navigationsanzeige';

  @override
  String get compassPilotDescription =>
      'Erweiterte Navigation mit ETA und Vektorisierung';

  @override
  String get compassArView => 'AR-Ansicht';

  @override
  String get compassCompassView => 'Kompass-Ansicht';

  @override
  String get compassSettings => 'Kompass-Einstellungen';

  @override
  String get compassMode => 'Kompass-Modus';

  @override
  String get calibrateCompass => 'Kompass Kalibrieren';

  @override
  String get windInformation => 'Wind-Information';

  @override
  String get noDataAvailable => 'Keine Daten verfügbar';

  @override
  String get loading => 'Wird geladen...';

  @override
  String get error => 'Fehler';

  @override
  String get retry => 'Wiederholen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get close => 'Schließen';

  @override
  String get gotIt => 'Verstanden';

  @override
  String get compassUnavailable => 'Kompass Nicht Verfügbar';

  @override
  String get initializingCompass => 'Kompass wird initialisiert...';

  @override
  String get accessingSensors => 'Zugriff auf Magnetometer- und GPS-Sensoren';

  @override
  String unableToAccessSensors(String error) {
    return 'Zugriff auf Kompass-Sensoren nicht möglich: $error';
  }

  @override
  String navigationTo(String target) {
    return 'Navigation zu $target';
  }

  @override
  String get degrees => '°';

  @override
  String get degreesTrue => '°w';

  @override
  String get degreesMagnetic => '°m';

  @override
  String get heading => 'Kurs';

  @override
  String get groundSpeed => 'Bodengeschwindigkeit';

  @override
  String get altitude => 'Höhe';

  @override
  String get bearing => 'Peilung';

  @override
  String get distance => 'Entfernung';

  @override
  String get wind => 'Wind';

  @override
  String get component => 'Komponente';

  @override
  String get noWindData => 'Keine Winddaten verfügbar';

  @override
  String get currentWind => 'Aktueller Wind:';

  @override
  String get windComponentHelp => 'H=Gegenwind T=Rückenwind X=Seitenwind';

  @override
  String get performance => 'Leistung';

  @override
  String get flightInstruments => 'Fluginstrumente';

  @override
  String get calibrationInstructions =>
      'Zur Verbesserung der Kompass-Genauigkeit:\\n\\n1. Gerät von metallischen Objekten fernhalten\\n2. Gerät in Achter-Bewegung führen\\n3. In alle Richtungen rotieren\\n4. 3-4 vollständige Drehungen ausführen';

  @override
  String get alertsFilter => 'Alarme Filtern';

  @override
  String get noAlertsFound => 'Keine Alarme gefunden';

  @override
  String get reportSighting => 'Sichtung Melden';

  @override
  String get takePhoto => 'Foto Aufnehmen';

  @override
  String get selectFromGallery => 'Aus Galerie Auswählen';

  @override
  String get submit => 'Senden';

  @override
  String get sendMessage => 'Nachricht senden';

  @override
  String get typeMessage => 'Nachricht eingeben...';
}
