// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'UFOBeep';

  @override
  String get ok => 'OKAY';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get close => 'Schließen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get retry => 'Wiederkehr';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Nächste';

  @override
  String get done => 'Artikel 2';

  @override
  String get loading => 'Die..';

  @override
  String get processing => 'Verarbeitung..';

  @override
  String get errorGeneric => 'Etwas ging schief.';

  @override
  String get networkError => 'Netzwerkfehler. Überprüfen Sie Ihre Verbindung.';

  @override
  String get permissionsRequired => 'Erforderliche Genehmigungen';

  @override
  String get learnMore => 'Mehr erfahren';

  @override
  String get welcomeTitle => 'Willkommen bei UFOBeep';

  @override
  String get welcomeSubtitle => 'Echtzeit-UFO-Benachrichtigungen in Ihrer Nähe';

  @override
  String get signIn => 'Anmeldung';

  @override
  String get signOut => 'Anmeldung';

  @override
  String get continueAsGuest => 'Weiter als Gast';

  @override
  String get enterUsername => 'Geben Sie einen Benutzernamen ein';

  @override
  String get username => 'Benutzername';

  @override
  String get usernameUpdated => 'Benutzername aktualisiert';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Einstellungen';

  @override
  String get tabAlerts => 'Alarme';

  @override
  String get tabBeep => 'Beep';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabMap => 'Landkarte';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String get alertsTitle => 'In der Nähe Alerts';

  @override
  String get noAlerts => 'Noch keine Alarme in der Nähe.';

  @override
  String get pullToRefresh => 'Auffrischen';

  @override
  String alertDistance(String distance) {
    return '$distance weg';
  }

  @override
  String alertDirection(int bearing) {
    return 'Lager $bearing°';
  }

  @override
  String get viewAlert => 'Alarm anzeigen';

  @override
  String get viewOnMap => 'Blick auf die Karte';

  @override
  String get iSeeItToo => 'Ich sehe es auch';

  @override
  String get confirmWitnessed =>
      'Bestätigen Sie, dass Sie diese Sicht gesehen haben?';

  @override
  String get witnessConfirmed =>
      'Danke — Ihre Bestätigung wurde veröffentlicht.';

  @override
  String get createBeepTitle => 'Einen Beep schicken';

  @override
  String get beepExplain =>
      'Erfassen Sie das, was Sie sehen und aufmerksam machen in der Nähe der Wachen.';

  @override
  String get capturePhoto => 'Bild erfassen';

  @override
  String get captureVideo => 'Video aufnehmen';

  @override
  String get pickFromGallery => 'Wählen Sie aus der Galerie';

  @override
  String get descriptionHint => 'Beschreiben Sie, was Sie am Himmel sehen..';

  @override
  String get submitBeep => 'Beep';

  @override
  String get beepSent => 'Bitte senden Sie uns';

  @override
  String get uploadingMedia => 'Medien hochladen..';

  @override
  String get includeLocation => 'Inklusive Ort';

  @override
  String get includeTimestamp => 'Inklusive Zeitstempel';

  @override
  String get beepFailed => 'Versäumt, Beep zu schicken.';

  @override
  String get mediaProcessing => 'Medien bearbeiten..';

  @override
  String get cameraPermissionTitle => 'Kamerazugriff erforderlich';

  @override
  String get cameraPermissionBody =>
      'Ermöglichen Sie die Kamera Zugriff auf UFO-Fotos und Videos.';

  @override
  String get locationPermissionTitle => 'Standortzugang erforderlich';

  @override
  String get locationPermissionBody =>
      'Wir nutzen Ihren Standort, um Alarme in der Nähe zu senden und zu empfangen.';

  @override
  String get microphonePermissionTitle => 'Mikrofonzugriff erforderlich';

  @override
  String get microphonePermissionBody =>
      'Geben Sie Mikrofonzugriff für Videoaufnahme mit Audio.';

  @override
  String get openSettings => 'Offene Einstellungen';

  @override
  String get alertDetailTitle => 'Details zum Angebot';

  @override
  String reportedBy(String username) {
    return 'Bericht __PH_0_';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Bericht $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '$distance weg';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Objektträger: $bearing°';
  }

  @override
  String get openCompass => 'Offener Kompass';

  @override
  String get openAR => 'Open AR Overlay';

  @override
  String get openChat => 'Open Chat';

  @override
  String get commentsTitle => 'Bemerkungen';

  @override
  String get addComment => 'Einen Kommentar hinzufügen..';

  @override
  String get send => 'Bitte';

  @override
  String get commentPosted => 'Kommentare gepostet';

  @override
  String get autoFollowEnabled => 'Sie folgen nun dieser Warnung.';

  @override
  String get noCommentsYet => 'Noch keine Kommentare. Sei der Erste!';

  @override
  String get newCommentNotification =>
      'Neuer Kommentar zu einem Anblick folgen Sie.';

  @override
  String get mapTitle => 'Live Map';

  @override
  String get compassTitle => 'Kompass';

  @override
  String get compassSettings => 'Compass-Einstellungen';

  @override
  String get compassMode => 'Überfahrtsmodus';

  @override
  String get compassStandardMode => 'Standard-Modus';

  @override
  String get compassPilotMode => 'Pilotmodus';

  @override
  String get compassStandardDescription => 'Grundüberschrift und Navigation';

  @override
  String get compassPilotDescription =>
      'Erweiterte Navigation mit ETA und Vektorisierung';

  @override
  String pointingTo(String direction) {
    return 'Auf $direction';
  }

  @override
  String get calibratingCompass => 'Kalibrierung Kompass..';

  @override
  String get openAROverlay => 'Open AR Overlay';

  @override
  String get pushTitleAlertNearby => 'UFO Alarm bei Ihnen';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Eine neue Sichtung wurde __PH_0_ weg gemeldet.';
  }

  @override
  String get pushTitleComment => 'Neuer Kommentar';

  @override
  String get pushBodyComment => 'Jemand kam zu einem Anblick, den Sie folgen.';

  @override
  String get pushTitleWitness => 'Bestätigung der Zeugen';

  @override
  String get pushBodyWitness =>
      'Ein Benutzer bestätigt, dass sie das gleiche Objekt sehen.';

  @override
  String get weather => 'Wetter';

  @override
  String cloudCover(int percent) {
    return 'Cloud Cover: __PH_0_%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Wind: $speed $unit';
  }

  @override
  String get nearbyAircraft => 'Flugzeuge in der Nähe';

  @override
  String get noAircraft => 'Keine Flugzeuge in der Nähe';

  @override
  String get loadingContext => 'Umweltkontext laden..';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get notifications => 'Mitteilungen';

  @override
  String get enablePushNotifications => 'Push-Benachrichtigungen aktivieren';

  @override
  String get quietHours => 'Ruhezeiten';

  @override
  String get quietHoursDesc => 'Stille Alarme zwischen ausgewählten Stunden.';

  @override
  String get dndMode => 'Nicht stören';

  @override
  String get dndUntil => 'Nicht stören, bis';

  @override
  String get language => 'Sprache';

  @override
  String get chooseLanguage => 'Sprache auswählen';

  @override
  String get units => 'Einheiten';

  @override
  String get unitsImperial => 'Imperial (mi, mph)';

  @override
  String get unitsMetric => 'Metrische (km, km/h)';

  @override
  String get privacyPolicy => 'Datenschutz';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get errorNoLocation =>
      'Standort nicht verfügbar. Versuchen Sie wieder draußen mit klarem Himmelblick.';

  @override
  String get errorNoCamera => 'Kamera auf diesem Gerät nicht verfügbar.';

  @override
  String get errorUploadFailed =>
      'Hochladen versagt. Bitte versuchen Sie es noch mal.';

  @override
  String get errorPermissionDenied => 'Erlaubnis verweigert.';

  @override
  String get errorInvalidUsername => 'Dieser Benutzername ist nicht verfügbar.';

  @override
  String get nothingToShow => 'Noch nichts zu zeigen.';

  @override
  String get storeShortDesc =>
      'Sofortige UFO-Benachrichtigungen in Ihrer Nähe. Erfassen, bestätigen und chatten in Echtzeit.';

  @override
  String get storeLongDesc =>
      'UFOBeep sendet Echtzeit-Benachrichtigungen, wenn jemand einen UFO in der Nähe entdeckt. Erfassen Sie Fotos und Videos, bestätigen Sie Sichtungen mit einem Tipp, Ansicht Richtung & Distanz, und chatten Sie mit anderen Skywatchern.';

  @override
  String get keywords =>
      'UFO,UAP,OVNI,aliens,sightings,skywatch,alerts,radar,compass';
}
