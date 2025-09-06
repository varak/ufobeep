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
  String get ok => 'OK';

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
  String get retry => 'Erneut versuchen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get done => 'Fertig';

  @override
  String get loading => 'Wird geladen…';

  @override
  String get processing => 'Verarbeite…';

  @override
  String get errorGeneric => 'Etwas ist schief gelaufen.';

  @override
  String get networkError => 'Netzwerkfehler. Verbindung prüfen.';

  @override
  String get permissionsRequired => 'Berechtigungen erforderlich';

  @override
  String get learnMore => 'Mehr erfahren';

  @override
  String get welcomeTitle => 'Willkommen bei UFOBeep';

  @override
  String get welcomeSubtitle => 'UFO‑Warnungen in Echtzeit in deiner Nähe';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signOut => 'Abmelden';

  @override
  String get continueAsGuest => 'Als Gast fortfahren';

  @override
  String get enterUsername => 'Benutzername eingeben';

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
  String get tabMap => 'Karte';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String get alertsTitle => 'Alarme in der Nähe';

  @override
  String get noAlerts => 'Noch keine Alarme in der Nähe.';

  @override
  String get pullToRefresh => 'Zum Aktualisieren ziehen';

  @override
  String alertDistance(String distance) {
    return '$distance away';
  }

  @override
  String alertDirection(int bearing) {
    return 'Peilung $bearing°';
  }

  @override
  String get viewAlert => 'Alarm ansehen';

  @override
  String get viewOnMap => 'Auf Karte anzeigen';

  @override
  String get iSeeItToo => 'Ich sehe es auch';

  @override
  String get confirmWitnessed => 'Bestätigst du die Sichtung?';

  @override
  String get witnessConfirmed =>
      'Danke — deine Bestätigung wurde veröffentlicht.';

  @override
  String get createBeepTitle => 'Beep senden';

  @override
  String get beepExplain =>
      'Halte fest, was du siehst, und warne Beobachter in der Nähe.';

  @override
  String get capturePhoto => 'Foto aufnehmen';

  @override
  String get captureVideo => 'Video aufnehmen';

  @override
  String get pickFromGallery => 'Aus Galerie wählen';

  @override
  String get descriptionHint => 'Beschreibe, was du am Himmel siehst…';

  @override
  String get submitBeep => 'Beep senden';

  @override
  String get beepSent => 'Beep gesendet';

  @override
  String get uploadingMedia => 'Medien werden hochgeladen…';

  @override
  String get includeLocation => 'Standort einbeziehen';

  @override
  String get includeTimestamp => 'Zeitstempel einbeziehen';

  @override
  String get beepFailed => 'Beep konnte nicht gesendet werden.';

  @override
  String get mediaProcessing => 'Medien werden verarbeitet…';

  @override
  String get cameraPermissionTitle => 'Kamerazugriff erforderlich';

  @override
  String get cameraPermissionBody =>
      'Erlaube Kamera, um UFO‑Fotos und ‑Videos aufzunehmen.';

  @override
  String get locationPermissionTitle => 'Standortzugriff erforderlich';

  @override
  String get locationPermissionBody =>
      'Wir nutzen deinen Standort für Alarme in der Nähe.';

  @override
  String get microphonePermissionTitle => 'Mikrofonzugriff erforderlich';

  @override
  String get microphonePermissionBody => 'Erlaube Mikrofon für Video mit Ton.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get alertDetailTitle => 'Sichtungsdetails';

  @override
  String reportedBy(String username) {
    return 'Gemeldet von $username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Gemeldet vor $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return 'in $distance';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Peilung zum Objekt: $bearing°';
  }

  @override
  String get openCompass => 'Kompass öffnen';

  @override
  String get openAR => 'AR‑Overlay öffnen';

  @override
  String get openChat => 'Chat öffnen';

  @override
  String get commentsTitle => 'Kommentare';

  @override
  String get addComment => 'Kommentar hinzufügen…';

  @override
  String get send => 'Senden';

  @override
  String get commentPosted => 'Kommentar veröffentlicht';

  @override
  String get autoFollowEnabled => 'Du folgst diesem Alarm jetzt.';

  @override
  String get noCommentsYet => 'Noch keine Kommentare. Sei der Erste!';

  @override
  String get newCommentNotification =>
      'Neuer Kommentar zu einer Sichtung, der du folgst.';

  @override
  String get mapTitle => 'Live‑Karte';

  @override
  String get compassTitle => 'Kompass';

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
  String get calibratingCompass => 'Kompass wird kalibriert…';

  @override
  String get openAROverlay => 'AR‑Overlay öffnen';

  @override
  String get pushTitleAlertNearby => 'UFO‑Alarm in deiner Nähe';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Neue Sichtung gemeldet, $distance entfernt.';
  }

  @override
  String get pushTitleComment => 'Neuer Kommentar';

  @override
  String get pushBodyComment =>
      'Jemand hat eine Sichtung kommentiert, der du folgst.';

  @override
  String get pushTitleWitness => 'Zeugenbestätigung';

  @override
  String get pushBodyWitness => 'Ein Nutzer hat dieselbe Sichtung bestätigt.';

  @override
  String get weather => 'Wetter';

  @override
  String cloudCover(int percent) {
    return 'Cloud cover: $percent%';
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
  String get loadingContext => 'Umgebung wird geladen…';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get enablePushNotifications => 'Push‑Benachrichtigungen aktivieren';

  @override
  String get quietHours => 'Ruhezeiten';

  @override
  String get quietHoursDesc =>
      'Alarme zwischen gewählten Zeiten stummschalten.';

  @override
  String get dndMode => 'Nicht stören';

  @override
  String get dndUntil => 'Nicht stören bis';

  @override
  String get language => 'Sprache';

  @override
  String get chooseLanguage => 'Sprache wählen';

  @override
  String get units => 'Einheiten';

  @override
  String get unitsImperial => 'Imperial (mi, mph)';

  @override
  String get unitsMetric => 'Metrisch (km, km/h)';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get errorNoLocation =>
      'Standort nicht verfügbar. Draußen mit freiem Himmel versuchen.';

  @override
  String get errorNoCamera => 'Kamera auf diesem Gerät nicht verfügbar.';

  @override
  String get errorUploadFailed =>
      'Upload fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get errorPermissionDenied => 'Zugriff verweigert.';

  @override
  String get errorInvalidUsername => 'Dieser Benutzername ist nicht verfügbar.';

  @override
  String get nothingToShow => 'Noch nichts anzuzeigen.';

  @override
  String get storeShortDesc =>
      'UFO‑Alarme in Echtzeit in deiner Nähe. Aufnehmen, bestätigen und chatten.';

  @override
  String get storeLongDesc =>
      'UFOBeep sendet Echtzeit‑Alarme, wenn jemand in deiner Nähe ein UFO sichtet. Nimm Fotos/Videos auf, bestätige mit einem Tippen, sieh Richtung & Entfernung und chatte mit Beobachtern.';

  @override
  String get keywords =>
      'UFO,UAP,Aliens,Sichtungen,Beobachtung,Alarme,radar,kompass';
}
