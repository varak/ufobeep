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
    return '__PLACEHOLDER_0_ weg';
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
    return 'Erfolgreich gesendet';
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
    return 'Bericht $username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Bericht $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '$distance';
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
  String get noCommentsYet => 'Noch keine Kommentare. Sei der erste Kommentar!';

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
    return 'Eine neue Sichtung wurde __PLACEHOLDER_0_ weg gemeldet.';
  }

  @override
  String get pushTitleComment => 'Neuer Kommentar';

  @override
  String get pushBodyComment => 'Jemand kam zu einem Anblick, den Sie folgen.';

  @override
  String get pushTitleWitness => 'Bestätigung der Zeugen';

  @override
  String get temperature => 'Temperatur';

  @override
  String get pushBodyWitness =>
      'Ein Benutzer bestätigt, dass sie das gleiche Objekt sehen.';

  @override
  String get weather => 'Wetter';

  @override
  String cloudCover(int percent) {
    return 'Cloud Cover: __PLACEHOLDER_0_%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Wind: $speed ${unit}_';
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
  String get quietHoursEnabled => 'Ruhezeiten aktivieren';

  @override
  String get quietHoursFrom => 'Von';

  @override
  String get quietHoursUntil => 'Bis';

  @override
  String get quietHoursDefaultTime => 'Default Ruhezeiten';

  @override
  String get emergencyOverride => 'Notüberschreitung';

  @override
  String get emergencyOverrideDesc =>
      'Erlauben Sie dringende Warnungen während der ruhigen Stunden';

  @override
  String get dndMode => 'Nicht stören';

  @override
  String get dndUntil => 'Nicht stören, bis';

  @override
  String dndEnabled(Object time) {
    return 'DND aktiviert bis $time';
  }

  @override
  String get dndDisabled => 'DND deaktiviert';

  @override
  String get quietHoursActive => 'Ruhezeiten aktiv';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Ruhezeiten: $start ${start}_';
  }

  @override
  String get pushNotificationUfoAlert => 'UFO Alarmstufe';

  @override
  String get pushNotificationAnomalyAlert => 'Anomaly Alert';

  @override
  String get pushNotificationNearby => 'In der Nähe';

  @override
  String get pushNotificationInYourArea =>
      'in deiner Umgebung. Tippen Sie auf Details zu sehen.';

  @override
  String pushNotificationCommented(Object username) {
    return '__PLACEHOLDER_0_ kommentiert';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '$username kommentiert auf ${username}_';
  }

  @override
  String get pushNotificationGeneric => 'UFOBeep';

  @override
  String get pushNotificationNewSighting => 'Neue Sicht in der Nähe';

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
  String get beepOnly => 'Nur seufzen';

  @override
  String get reportOnly => 'Nur noch';

  @override
  String get videoOnly => 'Nur Video';

  @override
  String get imageOnly => 'Nur Bilder';

  @override
  String get mediaOnly => 'Nur Medien';

  @override
  String get timeJustNow => 'jetzt';

  @override
  String timeDaysAgo(int count) {
    return '__PLACEHOLDER_0_ vor Tagen';
  }

  @override
  String timeHoursAgo(int count) {
    return '__PLACEHOLDER_0_ vor Stunden';
  }

  @override
  String timeMinutesAgo(int count) {
    return '__PLACEHOLDER_0_ vor Minuten';
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
  String get mufonSighting => 'MUFON Sighting Report';

  @override
  String get mufonLightSighting => 'MUFON Lichtblickbericht';

  @override
  String get mufonSphereSighting => 'MUFON Sphere Sighting Report';

  @override
  String get mufonDiscSighting => 'MUFON Disk Sighting Report';

  @override
  String get mufonTriangleSighting => 'MUFON Triangle Sighting Report';

  @override
  String get mufonCigarSighting => 'MUFON Cigar Sighting Report';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting Report';

  @override
  String get mufonRectangleSighting => 'MUFON Rechteckblickbericht';

  @override
  String get mufonCylinderSighting => 'MUFON Zylinder Sichtbericht';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Sichtbericht';

  @override
  String get mufonStarlikeSighting => 'MUFON Starlike Sighting Report';

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
  String get locationLabel => 'Standort:';

  @override
  String get distanceLabel => 'Entfernung';

  @override
  String get timeLabel => 'Zeit:';

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
    return 'Analyse: __PLACEHOLDER_0_ Mediendatei(en) verarbeitet';
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
  String get timeFormat => 'Zeitformat';

  @override
  String get timeFormat24Hour => '24-stunden (14:30)';

  @override
  String get timeFormat12Hour => '12-Stunden (2:30 Uhr)';

  @override
  String get timeFormatDesc =>
      'Anzeigezeit im 24-Stunden- oder 12-Stunden-Format';

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
  String get ufo => 'UFO';

  @override
  String get sighting => 'Sichtung';

  @override
  String get ufoSighting => 'UFOBeep UFO Alarmstufe';

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
  String get shapeTriangle => 'dreieck';

  @override
  String get shapeDisc => 'scheibe';

  @override
  String get shapeDisk => 'festplatte';

  @override
  String get shapeSphere => 'sphäre';

  @override
  String get shapeCigar => 'zigarren';

  @override
  String get shapeLight => 'licht';

  @override
  String get shapeBoomerang => 'das ist der hammer';

  @override
  String get shapeDiamond => 'diamant';

  @override
  String get shapeRectangle => 'rechteck';

  @override
  String get shapeOval => 'oval';

  @override
  String get shapeCone => 'cone';

  @override
  String get shapeCross => 'kreuz';

  @override
  String get shapeCylinder => 'zylinder';

  @override
  String get shapeDumbbell => 'dummkopf';

  @override
  String get shapeTeardrop => 'risse';

  @override
  String get shapeTicTac => 'tic-tac';

  @override
  String get shapeBullet => 'kugel';

  @override
  String get shapeSaturn => 'saturn';

  @override
  String get shapeStarlike => 'stern';

  @override
  String get shapeBlimp => 'blimp';

  @override
  String get shapeFireball => 'feuerball';

  @override
  String get shapeFormation => 'bildung';

  @override
  String get shapeUnknown => 'unbekannt';

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
    return '__PLACEHOLDER_0_ Menschen haben diese Sichtweise bestätigt';
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
    return 'MUFON Rechtssache #$caseNumber';
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
      'Meldungen für UFO-Beeps und Näherungsalarme';

  @override
  String get notificationSightingTitle => 'UFOBeep UFO Alarmstufe';

  @override
  String get notificationSightingUrgent => 'ZEITSCHRIFTEN Alarmstufe';

  @override
  String get notificationSightingEmergency =>
      '🚨 EMERGENCY UFOBeep UFO Alarmstufe';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '__PLACEHOLDER_0_ in der Nähe ${locationName}_';
  }

  @override
  String notificationCommentTitle(String username) {
    return '💬 __PLACEHOLDER_0_ kommentiert';
  }

  @override
  String get notificationWitnessText => 'Neue Sichtung';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '__PLACEHOLDER_0_ Zeugen';
  }

  @override
  String get notificationActionSnooze => 'Snooz 1h';

  @override
  String get notificationActionDismiss => 'Entlassung';

  @override
  String notificationDistance(String distance) {
    return '__PLACEHOLDER_0_ weg';
  }

  @override
  String get unknown => 'unbekannt';

  @override
  String get report => 'bericht';

  @override
  String get mufon => 'melonen';

  @override
  String get recentUfoBeepsTitle => 'Neuer UFO Schafe';

  @override
  String get recentUfoBeepsSubtitle =>
      'Live-UFO-Sichtberichte aus unserer globalen Gemeinschaft';

  @override
  String get recentUfoBeepsDescription =>
      'Dieser Feed kombiniert Echtzeit-UFOBeep \"beeps\" von unseren mobilen App-Nutzern mit historischen Berichten aus der MUFON-Datenbank.';

  @override
  String get loadingBeeps => 'Die letzten...';

  @override
  String get noBeepsAvailable => 'Momentan gibt es keine Piepen.';

  @override
  String get anomalyReported => 'Anomaly berichtet';

  @override
  String get copyShortLink => 'Kurzer Link kopieren';

  @override
  String get shareAlert => 'Alarmstufe';

  @override
  String get ufoSightingAlert => 'UFO Sighting Alert';

  @override
  String get previousPage => 'Vorherige';

  @override
  String get nextPage => 'Nächste';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Seite $currentPage von $totalPages (___PLACEHOLDER_2_ insgesamt beeps)';
  }

  @override
  String get firstPage => 'Erste';

  @override
  String get lastPage => 'Letzter Beitrag';

  @override
  String get jumpToPage => 'Zur Seite springen';

  @override
  String get heroTagline =>
      'Erhalten Sie Alarme, wenn Sie nach draußen gehen und nach oben schauen';

  @override
  String get heroDescription =>
      'Verpassen Sie nie ein weiteres UFO-Sicht in Ihrer Gegend';

  @override
  String get downloadApp => '📱 App herunterladen';

  @override
  String get viewAllBeeps => 'Alle Beeps anzeigen';

  @override
  String get sightingsMap => '🗺️ Sehenswürdigkeiten Karte';

  @override
  String get globalSightingNetwork => 'Global Sighting Network';

  @override
  String get howItWorks => 'Wie UFOBeep funktioniert';

  @override
  String get backToBeeps => 'Zurück zu Beeps';

  @override
  String get loadingDetails => 'Beep Details laden...';

  @override
  String get details => 'Details';

  @override
  String get location => 'Standort';

  @override
  String get timeAgo => 'vorwärts';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'meilen';

  @override
  String get distanceNearby => 'in der nähe';

  @override
  String get ufobeepWitnesses => 'Zeugen';

  @override
  String get ufobeepConfirmations => 'Bestätigungen';

  @override
  String get ufobeepAlertLevel => 'Alarmstufe';

  @override
  String get ufobeepReportType => 'UFOBeep Report';

  @override
  String get mufonAttribution => 'MUFON Datenbankbericht';

  @override
  String get mufonCaseNumber => 'Fall';

  @override
  String get mufonGenericTitle => 'MUFON Sighting Report';

  @override
  String get mufonSphere => 'Sphäre';

  @override
  String get mufonLight => 'Licht';

  @override
  String get mufonDisk => 'Festplattenspeicher';

  @override
  String get mufonTriangle => 'Dreieck';

  @override
  String get mufonCigar => 'Zigarren';

  @override
  String get mufonOval => 'Oval';

  @override
  String get mufonCylinder => 'Zylinder';

  @override
  String get mufonRectangle => 'Rechteck';

  @override
  String get mufonDiamond => 'Diamant';

  @override
  String get mufonFireball => 'Feuerball';

  @override
  String get mufonFlash => 'Flash';

  @override
  String get mufonFormation => 'Bildung';

  @override
  String get mufonChanging => 'Ändern';

  @override
  String get mufonChevron => 'Chevron';

  @override
  String get mufonCone => 'Cone';

  @override
  String get mufonCross => 'Kreuz';

  @override
  String get mufonEgg => 'Eier';

  @override
  String get mufonOther => 'Gegenstand';

  @override
  String get mufonUnknown => 'Unbekanntes Objekt';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON $classification Bericht';
  }

  @override
  String get nuforcAttribution => 'NUFORC Datenbankbericht';

  @override
  String get nuforcCaseNumber => 'Fall';

  @override
  String get nuforcGenericTitle => 'NUFORC Sichtbericht';

  @override
  String get mediaImageNotFound => 'Bild nicht gefunden';

  @override
  String get mediaPlayVideo => 'Video spielen';

  @override
  String get mediaViewImage => 'Bild anzeigen';

  @override
  String mediaCount(Object count) {
    return '__PLACEHOLDER_0_ Bilder';
  }

  @override
  String get mediaCountSingle => '1 bild';

  @override
  String mediaMoreImages(Object count) {
    return '+__PLACEHOLDER_0_ mehr';
  }

  @override
  String get errorNotFound => 'Beep nicht gefunden';

  @override
  String get errorLoadError => 'Versäumt, um Details zu laden';

  @override
  String get shareYourThoughts =>
      'Teilen Sie Ihre Gedanken über dieses Sehen...';

  @override
  String get postComment => 'Post-Kommando';

  @override
  String get loggedInAs => 'Eingeloggt als';

  @override
  String get logout => 'Anmeldung';

  @override
  String get notFollowing => 'Nicht folgen';

  @override
  String get follow => 'Folgen';

  @override
  String get navRecentBeeps => 'Letzter Beitrag';

  @override
  String get navMap => 'Landkarte';

  @override
  String get navDownloadApp => 'App herunterladen';

  @override
  String get alertLevel => 'Alarmstufe';

  @override
  String get witnesses => 'Zeugen';

  @override
  String get confirmations => 'Bestätigungen';

  @override
  String get reporterLabel => 'Vom Benutzer gemeldet';

  @override
  String get coordinatesLabel => 'Koordinaten';

  @override
  String get eventTime => 'Veranstaltungszeit';

  @override
  String get reportedTime => 'Gemeldete Zeit';

  @override
  String get addedToUfobeep => 'Zusätzlich zu UFOBeep';

  @override
  String get mufonDatabaseReport => 'MUFON Rechtssache:';

  @override
  String get copyShortLinkTitle => 'Kopieren Sie Link zur Zwischenablage';

  @override
  String get imageNotFound => 'Bild nicht gefunden';

  @override
  String get ufoSightingAlt => 'UFO Beep UFO Alarm';

  @override
  String get celestialDataTitle => 'Keltische Objekte';

  @override
  String get visiblePlanets => 'Sichtbare Planeten';

  @override
  String get locationDataTitle => 'Location Information';

  @override
  String get timezone => 'Zeitzone';

  @override
  String get coordinates => 'Koordinaten';

  @override
  String get processingSummaryTitle => 'Zusammenfassung der Verarbeitung';

  @override
  String get processingTime => 'Bearbeitungszeit';

  @override
  String get successful => 'Erfolgreich';

  @override
  String get failed => 'Versäumt';

  @override
  String get locationEnrichmentTitle => 'Location Details';

  @override
  String get aircraftDataSource => 'Datenquelle';

  @override
  String get noAircraftDetected => 'Keine Luftfahrzeuge erfasst';

  @override
  String get sightingReport => 'Sichtbericht';

  @override
  String get ufoAlert => 'UFO Alarmstufe';

  @override
  String get alert => 'Alarmstufe';

  @override
  String get notificationTickerUfoAlert =>
      'UFO Alert - Neue Sehenswürdigkeiten in der Nähe';

  @override
  String get notificationTickerComment => 'Neuer Kommentar zu UFO Alert';

  @override
  String get weatherConditions => 'Wetterbedingungen';

  @override
  String get visibility => 'Sichtbarkeit';

  @override
  String get humidity => 'Luftfeuchtigkeit';

  @override
  String get pressure => 'Druck';

  @override
  String get locationDetails => 'Location Details';

  @override
  String get city => 'Stadt';

  @override
  String get state => 'Staat';

  @override
  String get country => 'Land';

  @override
  String get satelliteActivity => 'Satellitenaktivität';

  @override
  String get satellitesVisibleOverhead =>
      'Satelliten sichtbar über Kopf bei Sichtzeit & Lage';

  @override
  String get dataSource => 'Datenquelle';

  @override
  String get blackskyImagery => 'BlackSky Imagery';

  @override
  String get resolution => 'Entschließung';

  @override
  String get groundResolution => '35cm bodenauflösung';

  @override
  String get delivery => 'Lieferung';

  @override
  String get averageDelivery => 'durchschnitt 90 minuten';

  @override
  String get cost => 'Kosten';

  @override
  String get skyfiSatelliteImagery => 'SkyFi Satelliten Bilder';

  @override
  String get region => 'Region';

  @override
  String get remoteArea => 'Fernbereich';

  @override
  String get startingPrice => 'Anfangspreis';

  @override
  String get coverage => 'Deckung';

  @override
  String get confidenceCoverage => '95% vertrauen';

  @override
  String get status => 'Status';

  @override
  String get shareThoughts => 'Teilen Sie Ihre Gedanken über dieses Sehen...';

  @override
  String get postCommand => 'Post Command';

  @override
  String get clouds => 'Wolken';

  @override
  String get windLabel => 'Wind';

  @override
  String get filterAlerts => 'Filter Alerts';

  @override
  String get alertSource => 'Alert Source';

  @override
  String get ufobeepOnly => 'Nur noch';

  @override
  String get ufobeepOnlyDescription =>
      'Nur originale UFOBeep-Berichte anzeigen (ohne MUFON-Datenbank)';

  @override
  String get alertDistanceRange => 'Alarm Entfernungsbereich';

  @override
  String get showAllAlerts => 'Alle Alarme anzeigen';

  @override
  String get showAll => 'Alle anzeigen';

  @override
  String get distanceSliderDescription =>
      'Ziehen Sie um, wie weit Sie Alarme sehen möchten. Beginnen Sie von der Entfernung der Wettersicht bis zu allen Warnungen unabhängig von der Entfernung.';

  @override
  String get applyFilters => 'Filter anwenden';

  @override
  String get notificationRange => 'Meldebereich';

  @override
  String get notificationRangeDescription =>
      'Holen Sie sich Push-Benachrichtigungen für Sehenswürdigkeiten in dieser Entfernung';

  @override
  String get viewingRange => 'Reichweite anzeigen';

  @override
  String get viewingRangeDescription =>
      'Zeige Sichtungen in dieser Entfernung beim Surfen';

  @override
  String get weatherVisibility => 'Wetter Sichtbarkeit (~10km)';

  @override
  String get localArea => 'Gebiet (25km)';

  @override
  String get regional => 'Gebiet';

  @override
  String get pushNotifications => 'Push-Benachrichtigungen';

  @override
  String get alertBrowsing => 'Alert Browsing';

  @override
  String get pushAlertsWithinDistance =>
      'Erhalten Sie Benachrichtigungen in diesem Bereich';

  @override
  String get showAlertsWhenBrowsing => 'Filtern, was Sie in der Liste sehen';

  @override
  String get heroMainTagline =>
      'Erhalten Sie einen Piep auf Ihrem Handy, wenn UFOs in der Nähe entdeckt werden';

  @override
  String get heroSecondaryTagline =>
      'Finden Sie heraus, wann und wo Sie den Himmel sehen';

  @override
  String get sourceFilters => 'Quelle';

  @override
  String get sourceFiltersDescription =>
      'Wählen Sie, welche Berichte in Ihrem Feed erscheinen';

  @override
  String get ufobeepAndMufon => 'UFOBeep + MUFON';

  @override
  String get ufobeepOnlySource => 'UFOBeep nur';

  @override
  String get mufonOnlySource => 'Nur MUFON';

  @override
  String get browseFilters => 'Nach oben';

  @override
  String get browseFiltersDescription => 'Wie man Alarme sieht und sortiert';

  @override
  String get sortByNewest => 'Neues';

  @override
  String get sortByNearest => 'Nächst';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get pushAlertsTitle => 'Pressalerts';

  @override
  String get pushAlertsDescription => 'Was pings your phone';

  @override
  String get alertRadius => 'Über uns';

  @override
  String get mufonNoPushInfo =>
      'MUFON-Berichte werden nachts importiert und keine Push-Benachrichtigungen auslösen';
}
