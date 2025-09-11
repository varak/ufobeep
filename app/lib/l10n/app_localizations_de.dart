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
  String beepSentWithUrl(String shortUrl) {
    return 'Alert sent! Share at ufobeep.com/$shortUrl';
  }

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
  String get enablePushNotifications =>
      'Erhalten Sie Benachrichtigungen für zukünftige Kommentare';

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

  @override
  String get noAlertsFound => 'Keine passenden Alarme';

  @override
  String get alertsFilterHelp =>
      'Versuchen Sie, Ihre Filter anzupassen, um mehr Ergebnisse zu sehen';

  @override
  String get verified => 'Verifiziert';

  @override
  String get beepOnly => 'nur noch';

  @override
  String get videoOnly => 'nur';

  @override
  String get imageOnly => 'nur';

  @override
  String get timeJustNow => 'Jetzt';

  @override
  String timeDaysAgo(int count) {
    return '${count}d vor';
  }

  @override
  String timeHoursAgo(int count) {
    return '__PH_0_h vor';
  }

  @override
  String timeMinutesAgo(int count) {
    return '__PH_0_m vor';
  }

  @override
  String get loadMoreAlerts => 'Mehr Informationen';

  @override
  String get toggleMufonTooltip => 'Toggle MUFON Visier';

  @override
  String get showMufonData => 'MUFON Daten anzeigen';

  @override
  String get hideMufonData => 'MUFON Daten verbergen';

  @override
  String get showingUfoBeepOnly => 'Nur UFOBeep-Berichte anzeigen';

  @override
  String get showingAllReports =>
      'Alle Berichte einschließlich MUFON-Datenbank anzeigen';

  @override
  String get filteredSuffix => 'filtriert';

  @override
  String get detailsTitle => 'Details';

  @override
  String get mufonCase => 'MUFON Rechtssache';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Fall #$caseNumber Details';
  }

  @override
  String get sightingDate => 'Sighting Date';

  @override
  String get mufonDatabaseEntryDate => 'Eingetragen in MUFON Datenbank';

  @override
  String get databaseEntry => 'Datenbankeintrag';

  @override
  String get shareLink => 'Link teilen';

  @override
  String get linkCopied => 'Link kopiert zu Clipboard';

  @override
  String get locationLabel => 'Standort';

  @override
  String get distanceLabel => 'Entfernung';

  @override
  String get timeLabel => 'Zeit';

  @override
  String get reportedByLabel => 'Bericht';

  @override
  String get unknownLocation => 'Unbekannte Lage';

  @override
  String get locationUnknown => 'Ort Unbekannt';

  @override
  String get witnessesLabel => 'Zeugen';

  @override
  String witnessesCountMessage(int count) {
    return '$count Personen haben diese Sichtweise bestätigt';
  }

  @override
  String get photoAnalysisTitle => 'Photoanalyse';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analyse: __PH_0_ Mediendatei(en) verarbeitet';
  }

  @override
  String get addMoreMedia => 'Mehr erfahren';

  @override
  String get addMedia => 'Medien hinzufügen';

  @override
  String get retakePhoto => 'Retake Photo';

  @override
  String get retakeVideo => 'Retake Video';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galerie';

  @override
  String get basicSettings => 'Grundeinstellungen';

  @override
  String get appSettings => 'App-Einstellungen';

  @override
  String get alertRange => 'Alarmbereich';

  @override
  String get manageNotificationsDesc => 'Abonnements verwalten & Einstellungen';

  @override
  String get permissionsTitle => 'Genehmigungen';

  @override
  String get permissionLocation => 'Standort';

  @override
  String get permissionCamera => 'Kamera';

  @override
  String get permissionNotifications => 'Mitteilungen';

  @override
  String get permissionPhotos => 'Fotos';

  @override
  String get permissionGranted => 'Gefördert';

  @override
  String get permissionNotGranted => 'Nicht gewährt';

  @override
  String get permissionGrant => 'Beihilfe';

  @override
  String get generateUsername => 'Neue Benutzernamen generieren';

  @override
  String get adminTools => 'Admin Tools';

  @override
  String get openAdminPanel => 'Open Admin Panel';

  @override
  String get webAdminInterface => 'Web Admin Interface';

  @override
  String get adminBetaNotice =>
      'Beta baut nur. Admin-Tools zum Testen von Nähenwarnungen, Push-Benachrichtigungen und Systemdiagnosen.';

  @override
  String get whatDoYouSee => 'Was siehst du?';

  @override
  String get ufoSighting => 'UFO Sichtung';

  @override
  String get envAnalysisTitle => 'Umweltanalyse';

  @override
  String get envAnalysisPending => 'Analyse';

  @override
  String get envAnalysisPendingDesc =>
      'Umweltdaten werden nach Beginn der Verarbeitung verfügbar sein.';

  @override
  String get unknownAircraft => 'Unbekanntes Flugzeug';

  @override
  String get moreAircraft => 'mehr flugzeuge';

  @override
  String get premiumImageryTitle => 'Premium Satellite Bilder';

  @override
  String get premiumImagerySubtitle => 'Hochauflösende kommerzielle Bilder';

  @override
  String get sightingTypeLabel => 'Typ';

  @override
  String get ufoTypeSphere => 'Sphäre';

  @override
  String get ufoTypeTriangle => 'Dreieck';

  @override
  String get ufoTypeDisk => 'Festplattenspeicher';

  @override
  String get ufoTypeLight => 'Licht';

  @override
  String get ufoTypeFireball => 'Feuerball';

  @override
  String get ufoTypeCylinder => 'Zylinder';

  @override
  String get ufoTypeCigar => 'Zigarren';

  @override
  String get ufoTypeRectangle => 'Rechteck';

  @override
  String get ufoTypeFormation => 'Bildung';

  @override
  String get ufoTypeUnknown => 'Unbekannt';

  @override
  String get ufoTypeBoomerang => 'Boomerang';

  @override
  String get ufoTypeDiamond => 'Diamant';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Cone';

  @override
  String get ufoTypeCross => 'Kreuz';

  @override
  String get ufoTypeDumbbell => 'Dummkopf';

  @override
  String get ufoTypeTeardrop => 'Teardrop';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Bullen';

  @override
  String get ufoTypeSaturn => 'Saturn';

  @override
  String get ufoTypeStarLike => 'Starartig';

  @override
  String get ufoTypeBlimp => 'Blüten';

  @override
  String get actionsTitle => 'Maßnahmen';

  @override
  String get addPhotosAndVideos => 'Fotos und Videos hinzufügen';

  @override
  String get howToReportToMufon => 'Wie man MUFON meldet';

  @override
  String get reportToMufon => 'Bericht an MUFON';

  @override
  String get whyReportToMufon => 'Warum Bericht an MUFON?';

  @override
  String get openMufonReport => 'Open MUFON Bericht';

  @override
  String get confirmedWitness => 'Sie haben diese Sichtweise bestätigt';

  @override
  String witnessesHaveConfirmed(int count) {
    return '$count Menschen haben diese Sichtweise bestätigt';
  }

  @override
  String get aircraftTrackingTitle => 'Luftfahrzeugverfolgung';

  @override
  String get weatherConditionsTitle => 'Wetterbedingungen';

  @override
  String get noSatellitePasses => 'Keine sichtbaren Satelliten Pässe gefunden';

  @override
  String get contentAnalysisTitle => 'Inhaltsanalyse';

  @override
  String get contentSafe => 'Inhalt ist sicher';

  @override
  String get contentFlagged => 'Inhalt markiert für die Überprüfung';

  @override
  String get confidenceLabel => 'Vertrauen';

  @override
  String get methodLabel => 'Methode';

  @override
  String get premiumImageryAccessOnly =>
      'Premium-Satellitenbilder sind nur verfügbar für:';

  @override
  String get premiumAccessCreators => 'Alarm-Ersteller';

  @override
  String get premiumAccessWitnesses => 'Bestätigte Zeugen im Sichtbereich';

  @override
  String get comingSoon => 'Ich komme bald';

  @override
  String get directionDistanceTitle => 'Richtung und Distanz';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Rechtssache';
  }

  @override
  String get satellitePassesTitle => 'Satellitenempfang';

  @override
  String get satellitePassExplanation =>
      'Sichtbare Satelliten passieren während der Sichtzeit. Viele UFO-Berichte sind tatsächlich Satelliten oder Leerzeichen.';

  @override
  String get followingAlert =>
      'Nach dem Alarm - Sie erhalten Kommentare Benachrichtigungen';

  @override
  String get unfollowedAlert =>
      'Unfollowed alert - no more comment Benachrichtigungen';

  @override
  String get alertFollowError => 'Fehler bei der Aktualisierung';

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
}
