// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'UFOBeep';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annulla';

  @override
  String get close => 'Chiudi';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Cancella';

  @override
  String get edit => 'Modifica';

  @override
  String get retry => 'Retry';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get back => 'Indietro';

  @override
  String get next => 'Il prossimo';

  @override
  String get done => 'Fatto';

  @override
  String get loading => 'Caricamento..';

  @override
  String get processing => 'Elaborazione..';

  @override
  String get errorGeneric => 'Qualcosa è andato storto.';

  @override
  String get networkError => 'Errore di rete. Controlla la connessione.';

  @override
  String get permissionsRequired => 'Permissioni richieste';

  @override
  String get learnMore => 'Per saperne di più';

  @override
  String get welcomeTitle => 'Benvenuti a UFOBeep';

  @override
  String get welcomeSubtitle => 'Avvisi UFO in tempo reale vicino a te';

  @override
  String get signIn => 'Firma';

  @override
  String get signOut => 'Firma';

  @override
  String get continueAsGuest => 'Continua come ospite';

  @override
  String get enterUsername => 'Inserisci un nome utente';

  @override
  String get username => 'Nome utente';

  @override
  String get usernameUpdated => 'Nome utente aggiornato';

  @override
  String get profile => 'Profilo';

  @override
  String get settings => 'Impostazioni impostazioni';

  @override
  String get tabAlerts => 'Avvisi';

  @override
  String get tabBeep => 'Beep';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabMap => 'Mappa';

  @override
  String get tabSettings => 'Impostazioni impostazioni';

  @override
  String get alertsTitle => 'Avvisi nelle vicinanze';

  @override
  String get noAlerts => 'Non ci sono ancora avvisi nelle vicinanze.';

  @override
  String get pullToRefresh => 'Tirare a rinfrescare';

  @override
  String alertDistance(String distance) {
    return 'Traduzione:';
  }

  @override
  String alertDirection(int bearing) {
    return 'Cuscinetto $bearing°';
  }

  @override
  String get viewAlert => 'Visualizza l\'avviso';

  @override
  String get viewOnMap => 'Visualizza sulla mappa';

  @override
  String get iSeeItToo => 'Lo vedo anche io';

  @override
  String get confirmWitnessed =>
      'Conferma di aver assistito a questo avvistamento?';

  @override
  String get witnessConfirmed => 'Grazie — la conferma è stata postata.';

  @override
  String get createBeepTitle => 'Invia un messaggio';

  @override
  String get beepExplain =>
      'Cattura ciò che vedi e allerta gli spettatori vicini.';

  @override
  String get capturePhoto => 'Foto di cattura';

  @override
  String get captureVideo => 'Video di cattura';

  @override
  String get pickFromGallery => 'Scegli dalla galleria';

  @override
  String get descriptionHint => 'Descrivi cosa vedi nel cielo..';

  @override
  String get submitBeep => 'Invia a Beep';

  @override
  String get beepSent => 'Beep inviato';

  @override
  String beepSentWithUrl(String shortUrl) {
    return 'Beep inviato con successo';
  }

  @override
  String get uploadingMedia => 'Caricare i media..';

  @override
  String get includeLocation => 'Includi la posizione';

  @override
  String get includeTimestamp => 'Includere il timestamp';

  @override
  String get beepFailed => 'Non ho mandato Beep.';

  @override
  String get mediaProcessing => 'Elaborazione dei media..';

  @override
  String get cameraPermissionTitle => 'Accesso telecamera necessaria';

  @override
  String get cameraPermissionBody =>
      'Garantire l\'accesso della fotocamera per catturare foto e video UFO.';

  @override
  String get locationPermissionTitle => 'Permesso di posizione richiesto';

  @override
  String get locationPermissionBody =>
      'Utilizziamo la tua posizione per inviare e ricevere avvisi nelle vicinanze.';

  @override
  String get microphonePermissionTitle => 'Accesso microfonico necessario';

  @override
  String get microphonePermissionBody =>
      'Garantire l\'accesso al microfono per la cattura video con audio.';

  @override
  String get openSettings => 'Impostazioni aperte';

  @override
  String get alertDetailTitle => 'Dettagli di tenuta';

  @override
  String reportedBy(String username) {
    return 'Segnalato da $username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Relazione $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '#';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Cuscinetto per oggetto: $bearing°';
  }

  @override
  String get openCompass => 'Bussola aperta';

  @override
  String get openAR => 'Sovrapposizione AR aperta';

  @override
  String get openChat => 'Apri chat';

  @override
  String get commentsTitle => 'Osservazioni';

  @override
  String get addComment => 'Aggiungi un commento..';

  @override
  String get send => 'Invia';

  @override
  String get commentPosted => 'Commento inviato';

  @override
  String get autoFollowEnabled => 'Ora stai seguendo questo avviso.';

  @override
  String get noCommentsYet => 'Nessun commento. Siate il primo a commentare!';

  @override
  String get newCommentNotification =>
      'Nuovo commento su un avvistamento si segue.';

  @override
  String get mapTitle => 'Mappa dal vivo';

  @override
  String get compassTitle => 'Compasso';

  @override
  String get compassSettings => 'Impostazioni bus';

  @override
  String get compassMode => 'Modalità bussola';

  @override
  String get compassStandardMode => 'Modalità standard';

  @override
  String get compassPilotMode => 'Modalità pilota';

  @override
  String get compassStandardDescription => 'Intestazione di base e navigazione';

  @override
  String get compassPilotDescription =>
      'Navigazione avanzata con ETA e vettori';

  @override
  String pointingTo(String direction) {
    return 'Punta a $direction';
  }

  @override
  String get calibratingCompass => 'Calibrazione bussola..';

  @override
  String get openAROverlay => 'Sovrapposizione AR aperta';

  @override
  String get pushTitleAlertNearby => 'UFO alert vicino a te';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'È stato segnalato un nuovo avvistamento $distance.';
  }

  @override
  String get pushTitleComment => 'Nuovo commento';

  @override
  String get pushBodyComment =>
      'Qualcuno ha commentato un avvistamento che segui.';

  @override
  String get pushTitleWitness => 'Conferma del testimone';

  @override
  String get temperature => 'Temperatura';

  @override
  String get pushBodyWitness =>
      'Un utente ha confermato di vedere lo stesso oggetto.';

  @override
  String get weather => 'Tempo';

  @override
  String cloudCover(int percent) {
    return 'Nuvolosità: $percent%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Eolico: $speed $unit';
  }

  @override
  String get nearbyAircraft => 'Aeromobili vicini';

  @override
  String get noAircraft => 'Nessun aereo nelle vicinanze';

  @override
  String get loadingContext => 'Carico contesto ambientale..';

  @override
  String get settingsTitle => 'Impostazioni impostazioni';

  @override
  String get notifications => 'Notifica';

  @override
  String get enablePushNotifications =>
      'Ricevi notifiche per i commenti futuri';

  @override
  String get quietHours => 'Ore tranquille';

  @override
  String get quietHoursDesc => 'Silenzio avvisi tra le ore selezionate.';

  @override
  String get quietHoursEnabled => 'Abilitare ore tranquille';

  @override
  String get quietHoursFrom => 'Da';

  @override
  String get quietHoursUntil => 'Fino a';

  @override
  String get quietHoursDefaultTime => 'Ore tranquille predefinite';

  @override
  String get emergencyOverride => 'Override di emergenza';

  @override
  String get emergencyOverrideDesc =>
      'Consentire avvisi urgenti durante ore tranquille';

  @override
  String get dndMode => 'Non disturbare';

  @override
  String get dndUntil => 'Non disturbare fino a quando';

  @override
  String dndEnabled(Object time) {
    return 'DND abilitato fino a $time';
  }

  @override
  String get dndDisabled => 'DISOCCUPATI';

  @override
  String get quietHoursActive => 'Ore tranquille attive';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Ore tranquille: Traduzione:';
  }

  @override
  String get pushNotificationUfoAlert => 'UFO Avviso';

  @override
  String get pushNotificationAnomalyAlert => 'Allarme Anomalia';

  @override
  String get pushNotificationNearby => 'Nelle vicinanze';

  @override
  String get pushNotificationInYourArea =>
      'nella tua zona. Tocca per visualizzare i dettagli.';

  @override
  String pushNotificationCommented(Object username) {
    return '$username ha commentato';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '$beepTitle ha commentato su $username';
  }

  @override
  String get pushNotificationGeneric => 'UFOBeep';

  @override
  String get pushNotificationNewSighting =>
      'Nuovi avvistamenti nelle vicinanze';

  @override
  String get language => 'Lingua';

  @override
  String get chooseLanguage => 'Scegli la lingua';

  @override
  String get units => 'Unità';

  @override
  String get unitsImperial => 'Imperial (mi, mph)';

  @override
  String get unitsMetric => 'Metrico (km, km/h)';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get termsOfUse => 'Condizioni d\'uso';

  @override
  String get errorNoLocation =>
      'Posizione non disponibile. Riprova fuori con vista cielo chiaro.';

  @override
  String get errorNoCamera =>
      'Macchina fotografica non disponibile su questo dispositivo.';

  @override
  String get errorUploadFailed =>
      'Il carico e\' fallito. Per favore riprovate.';

  @override
  String get errorPermissionDenied => 'Permesso negato.';

  @override
  String get errorInvalidUsername => 'Questo nome utente non è disponibile.';

  @override
  String get nothingToShow => 'Ancora niente da mostrare.';

  @override
  String get storeShortDesc =>
      'Avviso UFO istantaneo vicino a te. Catturare, confermare e chattare in tempo reale.';

  @override
  String get storeLongDesc =>
      'UFOBeep invia avvisi in tempo reale quando qualcuno trova un UFO nelle vicinanze. Cattura foto e video, conferma avvistamenti con un tocco, visualizzare direzione e distanza, e chattare con altri skywatchers.';

  @override
  String get keywords =>
      'UFO, UAP, OVNI,aliens,sightings,skywatch,alerts,radar,compass';

  @override
  String get noAlertsFound => 'Nessun avviso di corrispondenza';

  @override
  String get alertsFilterHelp =>
      'Prova a regolare i filtri per visualizzare più risultati';

  @override
  String get verified => 'Verificato';

  @override
  String get beepOnly => 'Beep Solo';

  @override
  String get reportOnly => 'Testo';

  @override
  String get videoOnly => 'Solo video';

  @override
  String get imageOnly => 'Immagine solo';

  @override
  String get mediaOnly => 'Solo';

  @override
  String get timeJustNow => 'ora';

  @override
  String timeDaysAgo(int count) {
    return '$count giorni fa';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count ore fa';
  }

  @override
  String timeMinutesAgo(int count) {
    return '$count minuto fa';
  }

  @override
  String get loadMoreAlerts => 'Carica più avvisi';

  @override
  String get toggleMufonTooltip => 'Toggle MUFON avvistamenti';

  @override
  String get showMufonData => 'Mostra i dati MUFON';

  @override
  String get hideMufonData => 'Nascondi dati MUFON';

  @override
  String get showingUfoBeepOnly => 'Mostra solo report UFOBeep';

  @override
  String get showingAllReports =>
      'Mostra tutti i rapporti, compreso il database MUFON';

  @override
  String get filteredSuffix => 'filtrato';

  @override
  String get detailsTitle => 'Dettagli';

  @override
  String get mufonCase => 'MUFON Caso';

  @override
  String get mufonSighting => 'MUFON Rapporto di tenuta';

  @override
  String get mufonLightSighting => 'MUFON Light Sighting Report';

  @override
  String get mufonSphereSighting => 'MUFON Sphere Sighting Report';

  @override
  String get mufonDiscSighting => 'MUFON Rapporto di visione';

  @override
  String get mufonTriangleSighting => 'MUFON Rapporto di visione del triangolo';

  @override
  String get mufonCigarSighting => 'MUFON Cigar Sighting Report';

  @override
  String get mufonOvalSighting => 'MUFON Rapporto di tenuta ovale';

  @override
  String get mufonRectangleSighting => 'MUFON Rapporto di tenuta rettangolare';

  @override
  String get mufonCylinderSighting => 'Rapporto di tenuta del cilindro MUFON';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Rapporto di tenuta';

  @override
  String get mufonStarlikeSighting => 'MUFON Rapporto Starlike Sighting';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Case #$caseNumber Dettagli';
  }

  @override
  String get sightingDate => 'Data di tenuta';

  @override
  String get mufonDatabaseEntryDate => 'Data inserita in MUFON Database';

  @override
  String get databaseEntry => 'Entrata del database';

  @override
  String get shareLink => 'Link di condivisione';

  @override
  String get linkCopied => 'Link copiato a clipboard';

  @override
  String get locationLabel => 'Posizione:';

  @override
  String get distanceLabel => 'Distanza';

  @override
  String get timeLabel => 'Tempo:';

  @override
  String get reportedByLabel => 'Relazione';

  @override
  String get unknownLocation => 'Location sconosciuta';

  @override
  String get locationUnknown => 'Ubicazione Sconosciuto';

  @override
  String get witnessesLabel => 'Testimoni';

  @override
  String witnessesCountMessage(int count) {
    return 'La gente ha confermato questo avvistamento';
  }

  @override
  String get photoAnalysisTitle => 'Analisi delle foto';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analisi: $count media file(s) processati';
  }

  @override
  String get addMoreMedia => 'Ulteriori informazioni';

  @override
  String get addMedia => 'Aggiungi i media';

  @override
  String get retakePhoto => 'Recuperare foto';

  @override
  String get retakeVideo => 'Recuperare video';

  @override
  String get camera => 'Macchina fotografica';

  @override
  String get gallery => 'Galleria';

  @override
  String get basicSettings => 'Impostazioni di base';

  @override
  String get appSettings => 'Impostazioni app';

  @override
  String get timeFormat => 'Formato del tempo';

  @override
  String get timeFormat24Hour => '24 ore (14:30)';

  @override
  String get timeFormat12Hour => '12 ore (2:30 PM)';

  @override
  String get timeFormatDesc =>
      'Tempo di visualizzazione in formato 24 ore o 12 ore';

  @override
  String get alertRange => 'Gamma di allarme';

  @override
  String get manageNotificationsDesc =>
      'Gestione degli abbonamenti e delle impostazioni';

  @override
  String get permissionsTitle => 'Permissioni';

  @override
  String get permissionLocation => 'Location';

  @override
  String get permissionCamera => 'Macchina fotografica';

  @override
  String get permissionNotifications => 'Notifica';

  @override
  String get permissionPhotos => 'Fotografie';

  @override
  String get permissionGranted => 'Concesso';

  @override
  String get permissionNotGranted => 'Non concesso';

  @override
  String get permissionGrant => 'Grant';

  @override
  String get generateUsername => 'Generare nuovo nome utente';

  @override
  String get adminTools => 'Strumenti di amministrazione';

  @override
  String get openAdminPanel => 'Pannello di amministrazione aperto';

  @override
  String get webAdminInterface => 'Interfaccia Web Admin';

  @override
  String get adminBetaNotice =>
      'Beta costruisce solo. Strumenti di amministrazione per la prova di avvisi di prossimità, notifiche push e diagnostica di sistema.';

  @override
  String get whatDoYouSee => 'Cosa vedi?';

  @override
  String get ufo => 'UFO';

  @override
  String get sighting => 'Sighting';

  @override
  String get ufoSighting => 'UFOBeep UFO Avviso';

  @override
  String get envAnalysisTitle => 'Analisi ambientale';

  @override
  String get envAnalysisPending => 'Analisi dei finanziamenti';

  @override
  String get envAnalysisPendingDesc =>
      'I dati ambientali saranno disponibili una volta che l\'elaborazione inizia.';

  @override
  String get unknownAircraft => 'Aereo sconosciuto';

  @override
  String get moreAircraft => 'più aerei';

  @override
  String get showLess => 'Mostra meno';

  @override
  String get premiumImageryTitle => 'Premium Satellite Immagine';

  @override
  String get premiumImagerySubtitle =>
      'Immagini commerciali ad alta risoluzione';

  @override
  String get sightingTypeLabel => 'Tipo';

  @override
  String get ufoTypeSphere => 'Sfera';

  @override
  String get ufoTypeTriangle => 'Triangolo';

  @override
  String get ufoTypeDisk => 'Disk';

  @override
  String get ufoTypeLight => 'Luce';

  @override
  String get ufoTypeFireball => 'Fireball';

  @override
  String get ufoTypeCylinder => 'Cilindro';

  @override
  String get ufoTypeCigar => 'Sigari';

  @override
  String get ufoTypeRectangle => 'Rettangolo';

  @override
  String get ufoTypeFormation => 'Formazione';

  @override
  String get ufoTypeUnknown => 'Sconosciuto';

  @override
  String get ufoTypeBoomerang => 'Boomerang';

  @override
  String get ufoTypeDiamond => 'Diamante';

  @override
  String get ufoTypeOval => 'Ovale';

  @override
  String get ufoTypeCone => 'Cone';

  @override
  String get ufoTypeCross => 'Croce';

  @override
  String get ufoTypeDumbbell => 'Manubrio';

  @override
  String get ufoTypeTeardrop => 'Lacrima';

  @override
  String get ufoTypeTicTac => 'Tac Tac';

  @override
  String get ufoTypeBullet => 'Bullet';

  @override
  String get ufoTypeSaturn => 'Saturno';

  @override
  String get ufoTypeStarLike => 'Star-like';

  @override
  String get ufoTypeBlimp => 'Blimp';

  @override
  String get shapeTriangle => 'triangolo';

  @override
  String get shapeDisc => 'disco a disco';

  @override
  String get shapeDisk => 'disco rigido';

  @override
  String get shapeSphere => 'sfera';

  @override
  String get shapeCigar => 'sigaro';

  @override
  String get shapeLight => 'luce';

  @override
  String get shapeBoomerang => 'boomerang';

  @override
  String get shapeDiamond => 'diamante';

  @override
  String get shapeRectangle => 'rettangolo';

  @override
  String get shapeOval => 'o';

  @override
  String get shapeCone => 'con';

  @override
  String get shapeCross => 'croce';

  @override
  String get shapeCylinder => 'cilindro';

  @override
  String get shapeDumbbell => 'manubrio';

  @override
  String get shapeTeardrop => 'goccia';

  @override
  String get shapeTicTac => 'tic-tac';

  @override
  String get shapeBullet => 'proiettile';

  @override
  String get shapeSaturn => 'saturno';

  @override
  String get shapeStarlike => 'stella';

  @override
  String get shapeBlimp => '#';

  @override
  String get shapeFireball => 'fuoco palla';

  @override
  String get shapeFormation => 'formazione';

  @override
  String get shapeUnknown => 'sconosciuto';

  @override
  String get actionsTitle => 'Azioni';

  @override
  String get addPhotosAndVideos => 'Aggiungi foto e video';

  @override
  String get attachMedia => 'Attacca i media';

  @override
  String get addCommentOptional => 'Aggiungi un commento (opzionale)';

  @override
  String get describeNewMedia => 'Descrivi i nuovi media...';

  @override
  String get filesSelected => 'file selezionati';

  @override
  String get selectMediaToAttach =>
      'Si prega di selezionare foto o video per allegare';

  @override
  String get newMediaUploaded => 'Nuovi media caricati';

  @override
  String get mediaFilesUploaded => 'nuovi file multimediali caricati';

  @override
  String get filesAttachedSuccessfully => 'file allegati con successo';

  @override
  String get howToReportToMufon => 'Come arrivare a MUFON';

  @override
  String get reportToMufon => 'Rapporto a MUFON';

  @override
  String get whyReportToMufon => 'Perché segnalare a MUFON?';

  @override
  String get openMufonReport => 'Aprire MUFON Relazione';

  @override
  String get confirmedWitness => 'Hai confermato questo avvistamento';

  @override
  String witnessesHaveConfirmed(int count) {
    return 'La gente ha confermato questo avvistamento';
  }

  @override
  String get aircraftTrackingTitle => 'Tracciamento di aerei';

  @override
  String get weatherConditionsTitle => 'Condizioni meteo';

  @override
  String get noSatellitePasses =>
      'Nessun passaggio satellitare visibile trovato';

  @override
  String get contentAnalysisTitle => 'Analisi dei contenuti';

  @override
  String get contentSafe => 'I contenuti sono sicuri';

  @override
  String get contentFlagged => 'Contenuto segnalato per la recensione';

  @override
  String get confidenceLabel => 'Confidenza';

  @override
  String get methodLabel => 'Metodo';

  @override
  String get premiumImageryAccessOnly =>
      'Le immagini satellitari Premium sono disponibili solo per:';

  @override
  String get premiumAccessCreators => 'Creatori di avvisi';

  @override
  String get premiumAccessWitnesses =>
      'Testimoni confermati all\'interno della gamma di visibilità';

  @override
  String get comingSoon => 'Arrivo presto';

  @override
  String get directionDistanceTitle => 'Direzione & Distanza';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Caso #_PLACEHOLDER_0__';
  }

  @override
  String get satellitePassesTitle => 'Passi satellitari';

  @override
  String get satellitePassExplanation =>
      'Passa satellite visibile durante il tempo di avvistamento. Molti rapporti UFO sono in realtà satelliti o detriti spaziali.';

  @override
  String get followingAlert =>
      'In seguito all\'avviso - otterrai notifiche di commento';

  @override
  String get unfollowedAlert =>
      'Avviso non seguito - non più notifiche di commento';

  @override
  String get alertFollowError => 'Aggiornamento degli errori';

  @override
  String get notificationChannelAlerts => 'UFOBeep Alerts';

  @override
  String get notificationChannelAlertsDesc =>
      'Notifiche per UFO beep e avvisi di prossimità';

  @override
  String get notificationSightingTitle => 'UFOBeep UFO Avviso';

  @override
  String get notificationSightingUrgent => '⚠️ URGENT UFOBeep UFO Avviso';

  @override
  String get notificationSightingEmergency =>
      '🚨 EMERGENCENZA UFOBeep UFO Avviso';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '$witnessText vicino ${locationName}_';
  }

  @override
  String notificationCommentTitle(String username) {
    return '💬 $username ha commentato';
  }

  @override
  String get notificationWitnessText => 'Nuovo avvistamento';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '$count testimoni';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Oggetto';

  @override
  String notificationDistance(String distance) {
    return 'Traduzione:';
  }

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get report => 'relazione';

  @override
  String get mufon => 'oh';

  @override
  String get recentUfoBeepsTitle => 'Recenti UFO Beeps';

  @override
  String get recentUfoBeepsSubtitle =>
      'Live UFO avvistamento report dalla nostra comunità globale';

  @override
  String get recentUfoBeepsDescription =>
      'Questo feed combina in tempo reale UFOBeep \"beeps\" dai nostri utenti di app mobile con rapporti storici dal database MUFON.';

  @override
  String get loadingBeeps => 'Caricamento recenti beeps...';

  @override
  String get noBeepsAvailable => 'Non ci sono beep disponibili al momento.';

  @override
  String get anomalyReported => 'Anomalia riportata';

  @override
  String get copyShortLink => 'Copia collegamento breve';

  @override
  String get shareAlert => 'Condividi alert';

  @override
  String get ufoSightingAlert => 'UFO Avviso di tenuta';

  @override
  String get previousPage => 'Precedente';

  @override
  String get nextPage => 'Il prossimo';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Pagina $currentPage di ${totalPages}_ (_PLACEHOLDER_2___ total beeps)';
  }

  @override
  String get firstPage => 'Primo';

  @override
  String get lastPage => 'Ultimo';

  @override
  String get jumpToPage => 'Vai alla pagina';

  @override
  String get heroTagline => 'Ricevi avvisi quando uscire e guardare in alto';

  @override
  String get heroDescription =>
      'Non perdere mai un altro avvistamento UFO nella tua zona';

  @override
  String get downloadApp => '📱 Scarica App';

  @override
  String get viewAllBeeps => '📋 Vedi tutte le pecore';

  @override
  String get sightingsMap => '🗺️ Sightings mappa';

  @override
  String get globalSightingNetwork => 'Rete di visione globale';

  @override
  String get howItWorks => 'Come funziona';

  @override
  String get backToBeeps => 'Torna a Beeps';

  @override
  String get loadingDetails => 'Caricamento in dettaglio...';

  @override
  String get details => 'Dettagli';

  @override
  String get location => 'Location';

  @override
  String get timeAgo => 'fa';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'miglia';

  @override
  String get distanceNearby => 'nelle vicinanze';

  @override
  String get ufobeepWitnesses => 'Testimoni';

  @override
  String get ufobeepConfirmations => 'Conferma';

  @override
  String get ufobeepAlertLevel => 'Livello di allarme';

  @override
  String get ufobeepReportType => 'Rapporto UFOBeep';

  @override
  String get mufonAttribution => 'MUFON Rapporto Database';

  @override
  String get mufonCaseNumber => 'Caso..';

  @override
  String get mufonGenericTitle => 'MUFON Rapporto di tenuta';

  @override
  String get mufonSphere => 'Sfera';

  @override
  String get mufonLight => 'Luce';

  @override
  String get mufonDisk => 'Disk';

  @override
  String get mufonTriangle => 'Triangolo';

  @override
  String get mufonCigar => 'Sigari';

  @override
  String get mufonOval => 'Ovale';

  @override
  String get mufonCylinder => 'Cilindro';

  @override
  String get mufonRectangle => 'Rettangolo';

  @override
  String get mufonDiamond => 'Diamante';

  @override
  String get mufonFireball => 'Fireball';

  @override
  String get mufonFlash => 'Flash';

  @override
  String get mufonFormation => 'Formazione';

  @override
  String get mufonChanging => 'Cambiamento';

  @override
  String get mufonChevron => 'Chevron';

  @override
  String get mufonCone => 'Cone';

  @override
  String get mufonCross => 'Croce';

  @override
  String get mufonEgg => 'Uova';

  @override
  String get mufonOther => 'Oggetto';

  @override
  String get mufonUnknown => 'Oggetto sconosciuto';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON $classification Relazione';
  }

  @override
  String get nuforcAttribution => 'NUFORC Rapporto Database';

  @override
  String get nuforcCaseNumber => 'Caso..';

  @override
  String get nuforcGenericTitle => 'NUFORC Rapporto di tenuta';

  @override
  String get mediaImageNotFound => 'Immagine non trovata';

  @override
  String get mediaPlayVideo => 'Giocare video';

  @override
  String get mediaViewImage => 'Visualizza immagine';

  @override
  String mediaCount(Object count) {
    return '$count immagini';
  }

  @override
  String get mediaCountSingle => '1 immagine';

  @override
  String mediaMoreImages(Object count) {
    return '+$count di più';
  }

  @override
  String get errorNotFound => 'Beep non trovato';

  @override
  String get errorLoadError => 'Non caricare i dettagli del segnale acustico';

  @override
  String get shareYourThoughts =>
      'Condividi i tuoi pensieri su questo avvistamento...';

  @override
  String get postComment => 'Messaggio';

  @override
  String get loggedInAs => 'Come si fa';

  @override
  String get logout => 'Logout';

  @override
  String get notFollowing => 'Non successivo';

  @override
  String get follow => 'Seguici';

  @override
  String get navRecentBeeps => 'Pecore recenti';

  @override
  String get navMap => 'Mappa';

  @override
  String get navDownloadApp => 'Scarica App';

  @override
  String get alertLevel => 'Livello di allarme';

  @override
  String get witnesses => 'Testimoni';

  @override
  String get confirmations => 'Conferma';

  @override
  String get reporterLabel => 'Segnalato dall\'utente';

  @override
  String get coordinatesLabel => 'Coordinate';

  @override
  String get eventTime => 'Tempo degli eventi';

  @override
  String get reportedTime => 'Tempo segnalato';

  @override
  String get addedToUfobeep => 'Aggiunto a UFOBeep';

  @override
  String get mufonDatabaseReport => 'MUFON Numero di causa:';

  @override
  String get copyShortLinkTitle => 'Copia collegamento a clipboard';

  @override
  String get imageNotFound => 'Immagine non trovata';

  @override
  String get ufoSightingAlt => 'UFO Beep UFO alert';

  @override
  String get celestialDataTitle => 'Oggetti celesti';

  @override
  String get visiblePlanets => 'Pianeti visibili';

  @override
  String get locationDataTitle => 'Informazioni sulla posizione';

  @override
  String get timezone => 'Tempo';

  @override
  String get coordinates => 'Coordinate';

  @override
  String get processingSummaryTitle => 'Sintesi del processo';

  @override
  String get processingTime => 'Tempo di elaborazione';

  @override
  String get successful => 'Successo';

  @override
  String get failed => 'Sfigato';

  @override
  String get locationEnrichmentTitle => 'Dettagli della posizione';

  @override
  String get aircraftDataSource => 'Fonte dei dati';

  @override
  String get noAircraftDetected => 'Nessun aereo rilevato';

  @override
  String get sightingReport => 'Rapporto di tenuta';

  @override
  String get ufoAlert => 'UFO Avviso';

  @override
  String get alert => 'Avviso';

  @override
  String get notificationTickerUfoAlert =>
      'Avviso UFO - Nuova vista nelle vicinanze';

  @override
  String get notificationTickerComment => 'Nuovo commento su UFO Alert';

  @override
  String get weatherConditions => 'Condizioni meteo';

  @override
  String get visibility => 'Visibilità';

  @override
  String get humidity => 'Umidità';

  @override
  String get pressure => 'Pressione';

  @override
  String get locationDetails => 'Dettagli della posizione';

  @override
  String get city => 'Città';

  @override
  String get state => 'Stato';

  @override
  String get country => 'Paese';

  @override
  String get satelliteActivity => 'Attività satellite';

  @override
  String get satellitesVisibleOverhead =>
      'Satelliti visibili in alto a tempo di avvistamento e posizione';

  @override
  String get dataSource => 'Fonte dei dati';

  @override
  String get blackskyImagery => 'BlackSky Imagery';

  @override
  String get resolution => 'Risoluzione';

  @override
  String get groundResolution => 'risoluzione del suolo 35cm';

  @override
  String get delivery => 'Consegna';

  @override
  String get averageDelivery => 'media di 90 minuti';

  @override
  String get cost => 'Costo';

  @override
  String get skyfiSatelliteImagery => 'SkyFi Satellite Immagine';

  @override
  String get region => 'Regione';

  @override
  String get remoteArea => 'Area remota';

  @override
  String get startingPrice => 'Prezzo di partenza';

  @override
  String get coverage => 'Copertura';

  @override
  String get confidenceCoverage => '95% di fiducia';

  @override
  String get status => 'Stato';

  @override
  String get shareThoughts =>
      'Condividi i tuoi pensieri su questo avvistamento...';

  @override
  String get postCommand => 'Comando post';

  @override
  String get clouds => 'Nuvole';

  @override
  String get windLabel => 'Vento vento';

  @override
  String get filterAlerts => 'Filtri avvisi';

  @override
  String get alertSource => 'Fonte di avviso';

  @override
  String get ufobeepOnly => 'UFOBeep Solo';

  @override
  String get ufobeepOnlyDescription =>
      'Mostra solo report originali UFOBeep (escluso database MUFON)';

  @override
  String get alertDistanceRange => 'Distanza di allarme';

  @override
  String get showAllAlerts => 'Mostra tutti gli avvisi';

  @override
  String get showAll => 'Mostra tutto';

  @override
  String get distanceSliderDescription =>
      'Trascina per regolare quanto si desidera vedere gli avvisi. Inizia dalla distanza di visibilità meteo fino a mostrare tutti gli avvisi indipendentemente dalla distanza.';

  @override
  String get applyFilters => 'Applicare filtri';

  @override
  String get notificationRange => 'Gamma di notifica';

  @override
  String get notificationRangeDescription =>
      'Ricevi avvisi push per avvistamenti a distanza';

  @override
  String get viewingRange => 'Gamma di visualizzazione';

  @override
  String get viewingRangeDescription =>
      'Mostra avvistamenti a questa distanza durante la navigazione';

  @override
  String get weatherVisibility => 'Visibilità meteo (~10km)';

  @override
  String get localArea => 'Area locale (25km)';

  @override
  String get regional => 'Regione';

  @override
  String get pushNotifications => 'Spingere le notifiche';

  @override
  String get alertBrowsing => 'Avviso di navigazione';

  @override
  String get pushAlertsWithinDistance =>
      'Ricevi notifiche all\'interno di questo range';

  @override
  String get showAlertsWhenBrowsing => 'Filtra ciò che vedi nella lista';

  @override
  String get heroMainTagline =>
      'Ottenere un segnale acustico sul telefono quando gli UFO sono individuati nelle vicinanze';

  @override
  String get heroSecondaryTagline => 'Scopri quando e dove guardare il cielo';

  @override
  String get sourceFilters => 'Fonte';

  @override
  String get sourceFiltersDescription =>
      'Scegli quali report appaiono nel tuo feed';

  @override
  String get ufobeepAndMufon => 'UFOBeep + MUFON';

  @override
  String get ufobeepOnlySource => 'UFOBeep solo';

  @override
  String get mufonOnlySource => 'MUFON solo';

  @override
  String get browseFilters => 'Sfoglia';

  @override
  String get browseFiltersDescription => 'Come visualizzare e ordinare avvisi';

  @override
  String get sortByNewest => 'Nuovo';

  @override
  String get sortByNearest => 'Più vicino';

  @override
  String get sortBy => 'Ordina per';

  @override
  String get pushAlertsTitle => 'Avvisi di spinta';

  @override
  String get pushAlertsDescription => 'Quali pings il telefono';

  @override
  String get alertRadius => 'Allerta Radius';

  @override
  String get mufonNoPushInfo =>
      'I rapporti MUFON sono importati di notte e non attivano gli avvisi push';

  @override
  String get privacyData => 'Privacy e dati';

  @override
  String get privacyPolicyDesc => 'Come proteggiamo e utilizziamo i tuoi dati';

  @override
  String get termsOfService => 'Termini di servizio';

  @override
  String get termsOfServiceDesc => 'Termini e condizioni legali';

  @override
  String get locationTracking => 'Monitoraggio della posizione';

  @override
  String get locationTrackingDesc =>
      'Posizione di sfondo per avvisi di prossimità';

  @override
  String get locationTrackingTitle => 'Background Location Tracking';

  @override
  String get locationTrackingExplanation =>
      'UFOBeep monitora la tua posizione in background per inviare avvisi di prossimità quando gli avvistamenti UFO avvengono vicino alla tua posizione attuale, anche quando sei lontano da casa.';

  @override
  String get locationTrackingBattery =>
      'Utilizza la geofencing intelligente per l\'impatto della batteria <3%';

  @override
  String get backgroundLocationTracking => 'Abilitare lo sfondo Monitoraggio';

  @override
  String get locationTrackingActive =>
      'Luogo di monitoraggio per avvisi di prossimità';

  @override
  String get locationTrackingInactive =>
      'Il monitoraggio della posizione è disattivato';

  @override
  String get locationTrackingDisabledWarning =>
      'Non riceverai avvisi di prossimità quando ti trasferisci in nuovi luoghi';

  @override
  String get trackingStatus => 'Stato di monitoraggio';

  @override
  String get monitoringStatus => 'Monitoraggio';

  @override
  String get active => 'Attivo';

  @override
  String get inactive => 'Inattivo';

  @override
  String get lastKnownLocation => 'Ultima posizione nota';

  @override
  String get lastLocationUpdate => 'Ultimo aggiornamento';

  @override
  String get movementThreshold => 'Movimento Soglia';

  @override
  String get updateFrequency => 'Frequenza di aggiornamento';

  @override
  String get batteryImpact => 'Impatto della batteria';

  @override
  String get dataPrivacy => 'Privacy';

  @override
  String get locationPermissionExplanation =>
      'UFOBeep ha bisogno del permesso di posizione \'Always Allow\' per monitorare il movimento e inviare avvisi di prossimità quando si è in nuove posizioni.';

  @override
  String get benefitsTitle => 'Vantaggi';

  @override
  String get locationTrackingBenefits =>
      '• Ricevi avvisi UFO ovunque viaggi\n• Aggiornamenti automatici della posizione\n• Nessuna configurazione manuale richiesta';

  @override
  String get allowLocationAccess => 'Consentire l\'accesso alla posizione';

  @override
  String get locationPermissionRequired =>
      'Il permesso di localizzazione è necessario per il monitoraggio di sfondo';

  @override
  String get locationTrackingEnabled =>
      'Inseguimento della posizione di sfondo abilitato';

  @override
  String get locationTrackingDisabled =>
      'Inseguimento della posizione di sfondo disabilitato';

  @override
  String get justNow => 'Adesso';

  @override
  String minutesAgo(int minutes) {
    return '$minutes minuto fa';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours ore fa';
  }

  @override
  String daysAgo(int days) {
    return '$days giorni fa';
  }

  @override
  String get dataManagement => 'Gestione dei dati';

  @override
  String get dataManagementDesc => 'Esporta o elimina i dati del tuo account';

  @override
  String get splashTagline => 'Avvisi di avvistamento in tempo reale';

  @override
  String get splashStartingUp => 'Cominciare...';

  @override
  String get splashInitializationFailed => 'L\'inizializzazione fallita';

  @override
  String get splashInitializationFailedTitle => 'Inizializzazione non riuscita';

  @override
  String get splashInitializationError =>
      'L\'app non ha inizializzato correttamente:';

  @override
  String get splashRetry => 'Retry';

  @override
  String get splashContinue => 'Continua';

  @override
  String get splashInitializing => 'Inizializzazione...';

  @override
  String signInWelcome(String username) {
    return 'Benvenuto!';
  }

  @override
  String signInFailed(String error) {
    return 'Iscrizione fallita: #';
  }

  @override
  String get signInPleaseEnterEmail => 'Inserisci il tuo indirizzo email';

  @override
  String get signInPleaseEnterValidEmail =>
      'Inserisci un indirizzo email valido';

  @override
  String get signInMagicLinkSent =>
      'Link magico inviato! Controlla la tua email e clicca sul link per accedere.';

  @override
  String get signInMagicLinkFailed =>
      'Non ha mandato link magico. Per favore riprovate.';

  @override
  String get signInAllDataCleared => 'Tutti i dati cancellati';

  @override
  String get signInSubtitle =>
      'Avvisi di avvistamento UFO in tempo reale e rapporti MUFON';

  @override
  String get signInGoogleLoading => 'Firma in...';

  @override
  String get signInContinueWithGoogle => 'Continua con Google';

  @override
  String get signInOr => 'o';

  @override
  String get signInWithEmail => 'Accedi con Email';

  @override
  String get signInEmailDescription =>
      'Ti invieremo un link sicuro per accedere';

  @override
  String get signInEmailAddress => 'Indirizzo email';

  @override
  String get signInEmailPlaceholder => 'tuo@email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'Riprova in ${seconds}s';
  }

  @override
  String get signInSending => 'Invio...';

  @override
  String get signInSendMagicLink => 'Inviare Magic Link';

  @override
  String get signInCheckEmail =>
      'Controlla la tua email! Il link scade tra 15 minuti.';

  @override
  String get signInSecureAuth => 'Autenticazione sicura';

  @override
  String get signInSecureAuthDescription =>
      'Utilizzare Google Sign-In per l\'accesso istantaneo, o link magici e-mail che scadono in 15 minuti.';

  @override
  String get signInClearAllDataDebug => 'Cancella tutti i dati (Debug)';

  @override
  String get emailAuthFailedToSend => 'Non inviare e-mail';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'Non ha inviato email. Per favore riprovate.';

  @override
  String get emailAuthInvalidEmail =>
      'Indirizzo email non valido. Si prega di controllare il formato.';

  @override
  String get emailAuthUserNotFound =>
      'Nessun account trovato con questo indirizzo email.';

  @override
  String get emailAuthTooManyRequests => 'Troppi tentativi. Riprova più tardi.';

  @override
  String get emailAuthOperationNotAllowed => 'Il link email non è abilitato.';

  @override
  String get emailAuthQuotaExceeded => 'Quota e-mail superata. Riprova domani.';

  @override
  String get emailAuthVerificationFailed =>
      'La verifica e-mail è fallita. Per favore riprovate.';

  @override
  String get emailAuthTitle => 'Verifica e-mail';

  @override
  String get emailAuthVerifyYourEmail => 'Verifica la tua email';

  @override
  String get emailAuthDescription =>
      'Aggiungi il tuo indirizzo email per il recupero e la sicurezza dell\'account. Ti invieremo un link sicuro.';

  @override
  String get emailAuthEmailAddress => 'Indirizzo email';

  @override
  String get emailAuthEmailPlaceholder => 'your.email@example.com';

  @override
  String get emailAuthPleaseEnterEmail => 'Inserisci il tuo indirizzo email';

  @override
  String get emailAuthPleaseEnterValidEmail =>
      'Inserisci un indirizzo email valido';

  @override
  String get emailAuthCheckEmailToContinue =>
      'Controlla la tua email e tocca il link di verifica per continuare.';

  @override
  String get emailAuthResendEmail => 'Invia un\'email';

  @override
  String get emailAuthSendVerificationEmail => 'Invia la verifica Email';

  @override
  String get emailAuthHowItWorks => 'Come funziona la verifica e-mail';

  @override
  String get emailAuthHowItWorksSteps =>
      '1. Ti inviamo un link sicuro di accesso\n2. Controlla la tua email e tocca il link\n3. La tua email viene verificata automaticamente\n4. Nessuna password necessaria!';

  @override
  String get emailAuthSecurityNotice =>
      'La verifica e-mail aiuta a proteggere il tuo account e consente il ripristino dell\'account se si perde l\'accesso al dispositivo.';

  @override
  String get phoneAuthFailedToSendCode =>
      'Non ha inviato il codice di verifica. Per favore riprovate.';

  @override
  String get phoneAuthInvalidCodeTryAgain =>
      'Codice di verifica non valido. Per favore riprovate.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'Numero di telefono verificato: #';
  }

  @override
  String get phoneAuthVerificationFailed =>
      'La verifica del telefono è fallita. Per favore riprovate.';

  @override
  String get phoneAuthCodeResent => 'Codice di verifica risentimento';

  @override
  String get phoneAuthFailedToResendCode =>
      'Non ha rimesso in riga il codice. Per favore riprovate.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'Numero di telefono non valido. Si prega di controllare il formato.';

  @override
  String get phoneAuthTooManyRequests => 'Troppi tentativi. Riprova più tardi.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'Codice di verifica non valido. Si prega di controllare e riprovare.';

  @override
  String get phoneAuthSessionExpired =>
      'Sessione di verifica scaduta. Si prega di richiedere un nuovo codice.';

  @override
  String get phoneAuthSmsQuotaExceeded =>
      'La quota SMS è superata. Riprova domani.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'Questo numero di telefono è già collegato ad un altro account.';

  @override
  String get phoneAuthVerificationFailedGeneric =>
      'La verifica è fallita. Per favore riprovate.';

  @override
  String get phoneAuthTitle => 'Verifica del telefono';

  @override
  String get phoneAuthVerifyYourPhone => 'Verifica il tuo telefono';

  @override
  String get phoneAuthEnterVerificationCode => 'Inserisci la verifica Codice';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'Aggiungi il tuo numero di telefono per il recupero del conto e la sicurezza';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return 'Inserisci il codice a 6 cifre inviato a $phoneNumber';
  }

  @override
  String get phoneAuthPhoneNumber => 'Numero di telefono';

  @override
  String get phoneAuthPhonePlaceholder => '+1 (555) 123-4567';

  @override
  String get phoneAuthPleaseEnterPhone => 'Inserisci il tuo numero di telefono';

  @override
  String get phoneAuthPleaseEnterValidPhone =>
      'Inserisci un numero di telefono valido';

  @override
  String get phoneAuthVerificationCode => 'Codice di verifica';

  @override
  String get phoneAuthPleaseEnterSixDigitCode =>
      'Inserisci il codice a 6 cifre';

  @override
  String get phoneAuthResendCode => 'Codice di invio';

  @override
  String get phoneAuthSendVerificationCode => 'Invia la verifica Codice';

  @override
  String get phoneAuthVerifyCode => 'Codice di verifica';

  @override
  String get phoneAuthChangePhoneNumber => 'Cambia il numero di telefono';

  @override
  String get phoneAuthSmsNotice =>
      'Ti invieremo un codice di verifica tramite SMS. Possono essere applicate le tariffe dei messaggi standard.';

  @override
  String get phoneAuthCodeExpires =>
      'Il codice scade in 60 secondi. Controlla i messaggi.';

  @override
  String get yourDataRights => 'Diritti dei dati';

  @override
  String get dataRightsExplanation =>
      'Hai il pieno controllo sui tuoi dati personali. Puoi esportare tutti i tuoi dati o eliminare definitivamente il tuo account in qualsiasi momento.';

  @override
  String get exportYourData => 'Esporta i tuoi dati';

  @override
  String get exportDataDescription => 'Scarica tutti i dati del tuo account';

  @override
  String get exportData => 'Esportazione dei dati';

  @override
  String get exportingData => 'Esportazione...';

  @override
  String get exportDataDetails =>
      'Include: profilo, bip, commenti, informazioni sul dispositivo e preferenze. I dati sono forniti in formato JSON.';

  @override
  String get dataExportedSuccessfully => 'I dati esportati con successo';

  @override
  String get dataExportFailed => 'Non esportare dati';

  @override
  String get deleteAccount => 'Cancella account';

  @override
  String get deleteAccountDescription =>
      'Rimuovere permanentemente il vostro account e tutti i dati';

  @override
  String get deleteAccountWarning =>
      'Questa azione non può essere annullata. Tutti i tuoi dati di segnale acustico, commenti e account verranno cancellati definitivamente.';

  @override
  String get deleteMyAccount => 'Cancella il mio account';

  @override
  String get deletingAccount => 'Deleting...';

  @override
  String get deleteAccountConfirmTitle => 'Cancella account';

  @override
  String get deleteAccountConfirmMessage =>
      'Sei assolutamente sicuro di voler cancellare il tuo account? Questa azione è permanente e non può essere annullata.';

  @override
  String get dataWillBeDeleted =>
      'I seguenti dati verranno cancellati definitivamente:';

  @override
  String get deletedDataList =>
      '• Il tuo profilo e nome utente\n• Tutti i tuoi beep e report\n• Tutti i tuoi commenti\n• Dati di registrazione del dispositivo\n• Dati di localizzazione e preferenza';

  @override
  String get deleteAccountPermanent => 'Eliminare permanentemente';

  @override
  String get accountDeletedSuccessfully => 'Account cancellato con successo';

  @override
  String get accountDeletionFailed => 'Non riuscita a cancellare l\'account';

  @override
  String get onboardingWelcomeTitle => 'Benvenuti a UFOBeep';

  @override
  String get onboardingWelcomeBody =>
      'Ricevi avvisi in tempo reale quando gli UFO sono avvistati nelle vicinanze. Non perdere mai più un avvistamento.';

  @override
  String get onboardingAlertsTitle => 'Resta informato';

  @override
  String get onboardingAlertsBody =>
      'Impostare quanto lontano avvistamento dovrebbe essere per attivare avvisi.';

  @override
  String get onboardingReportTitle => 'Vedi qualcosa? Beep it!';

  @override
  String get onboardingReportBody =>
      'Scattare una foto o un video e condividere istantaneamente con gli spettatori vicini.';

  @override
  String get onboardingPermissionsTitle => 'La tua camera & posizione';

  @override
  String get onboardingPermissionsBody =>
      'Attiva fotocamera, posizione e notifiche in modo da poter:\n– Segnala avvistamenti veloci\n– Ricevi avvisi per UFOs vicino a te';

  @override
  String get onboardingCameraTitle => 'Prove di cattura';

  @override
  String get onboardingCameraBody =>
      'Condividi foto e video che hai appena catturato dalla tua galleria o premi a lungo l\'icona UFOBeep per iniziare in modalità fotocamera istantanea.';

  @override
  String get onboardingCompassTitle => 'Vedi dove guardavano';

  @override
  String get onboardingCompassBody =>
      'Compasso mostra la direzione esatta che il testimone stava guardando quando hanno visto l\'UFO. Punta il telefono e guarda!';

  @override
  String get onboardingCommunityTitle => 'Iscriviti al Skywatchers';

  @override
  String get onboardingCommunityBody =>
      'Sfoglia avvistamenti, accedi ai report MUFON e collega con altri skywatcher.';

  @override
  String get skip => 'Salta';

  @override
  String get getStarted => 'Iniziare';

  @override
  String get viewOnboardingAgain => 'Visualizza di nuovo a bordo';

  @override
  String get customAlertRange => 'Gamma di allarme personalizzata';

  @override
  String get enterRangeKm => 'Inserisci l\'intervallo in km (1-99999)';

  @override
  String get largeRangeWarning =>
      'Grandi gamme (>100km) possono generare molti avvisi';

  @override
  String get globalRangeWarning =>
      'Gamme molto grandi (> 1000km) vi invierà avvisi da tutto il mondo';

  @override
  String get invalidRange => 'Inserisci un numero tra 1 e 99999';

  @override
  String get celestialSunDaylight =>
      'Il sole è in su - condizioni di luce del giorno possono influenzare la visibilità di avvistamento';

  @override
  String get celestialSunTwilight =>
      'Condizioni di luce crepuscolare - qualche visibilità ma più scuro della luce del giorno';

  @override
  String get celestialSunDark =>
      'Condizioni scure - ottimale per osservare gli oggetti in cielo';

  @override
  String celestialMoonBright(Object phase) {
    return 'Bright $phase moon visibile - può illuminare o oscurare altri oggetti';
  }

  @override
  String celestialMoonModerate(Object phase) {
    return '${phase}lune visibile - condizioni di illuminazione moderate';
  }

  @override
  String celestialMoonThin(Object phase) {
    return 'Thin ${phase}luce visibile - illuminazione minima';
  }

  @override
  String celestialMoonHidden(Object phase) {
    return '$phase luna sotto orizzonte - nessuna illuminazione lunare';
  }

  @override
  String get celestialNoPlanets =>
      'Nessun pianeta luminoso visibile che potrebbe essere sbagliato per UFOs';

  @override
  String celestialPlanetHigh(Object altitude, Object planet) {
    return '$planet high overhead (_PLACEHOLDER_1__°) - molto prominente';
  }

  @override
  String celestialPlanetMedium(Object altitude, Object planet) {
    return '$altitude visibile a $planet° - potrebbero essere scambiati per aerei';
  }

  @override
  String celestialPlanetLow(Object altitude, Object planet) {
    return '$planet basso all\'orizzonte (_PLACEHOLDER_1__°)';
  }

  @override
  String get celestialNoStars =>
      'Nessuna stella insolitamente luminosa visibile';

  @override
  String celestialStarSingle(Object altitude, Object star) {
    return '$altitude prominente a $star° altitudine';
  }

  @override
  String celestialStarsMultiple(Object count, Object names) {
    return '$names stelle luminose visibili - $count';
  }

  @override
  String get celestialSummaryDaylight => 'Condizioni diurne';

  @override
  String get celestialSummaryDark => 'Condizioni del cielo scuro';

  @override
  String get celestialSummaryMoonUp => 'illuminazione della luna presente';

  @override
  String get celestialSummaryMoonDown => 'nessuna illuminazione di luna';

  @override
  String celestialSummaryManyObjects(Object count) {
    return '$count oggetti luminosi che potrebbero essere confusi con gli UFO';
  }

  @override
  String celestialSummarySomeObjects(Object count) {
    return '$count oggetti luminosi visibili';
  }

  @override
  String get celestialSummaryFewObjects => 'oggetti luminosi minimi in cielo';

  @override
  String celestialSkySummary(Object conditions) {
    return 'Condizioni Sky: #';
  }

  @override
  String get planetVenus => 'Venere';

  @override
  String get planetJupiter => 'Giove';

  @override
  String get planetSaturn => 'Saturno';

  @override
  String get planetMars => 'Marte';

  @override
  String get planetMercury => 'Mercurio';

  @override
  String get planetUranus => 'Urano';

  @override
  String get planetNeptune => 'Nettuno';

  @override
  String get starSirius => 'Si';

  @override
  String get starCanopus => 'Canopus';

  @override
  String get starArcturus => 'Arcturus';

  @override
  String get starVega => 'Vega';

  @override
  String get starCapella => 'Capella';

  @override
  String get starRigel => 'Rigel';

  @override
  String get starProcyon => 'Procyon';

  @override
  String get starBetelgeuse => 'Betelgeuse';

  @override
  String get moonPhaseNew => 'Nuova luna';

  @override
  String get moonPhaseWaxingCrescent => 'Crescente sulla cera';

  @override
  String get moonPhaseFirstQuarter => 'Primo trimestre';

  @override
  String get moonPhaseWaxingGibbous => 'Waxing Gibbous';

  @override
  String get moonPhaseFull => 'Luna piena';

  @override
  String get moonPhaseWaningGibbous => 'Waning Gibbous';

  @override
  String get moonPhaseThirdQuarter => 'Terzo trimestre';

  @override
  String get moonPhaseWaningCrescent => 'Crescente della vita';

  @override
  String planetBelowHorizon(Object planet) {
    return '$planet sotto orizzonte';
  }

  @override
  String planetHighOverheadProminent(Object altitude, Object planet) {
    return '$planet high overhead (_PLACEHOLDER_1__°) - molto prominente';
  }

  @override
  String planetMidSkyProminent(Object altitude, Object planet) {
    return '${altitude}_ a $planet° - prominente';
  }

  @override
  String planetMidSky(Object altitude, Object planet) {
    return '${altitude}_ $planet';
  }

  @override
  String starVeryBright(Object altitude, Object star) {
    return '$altitude molto luminoso a $star°';
  }

  @override
  String starProminent(Object altitude, Object star) {
    return '$altitude prominente a $star° altitudine';
  }

  @override
  String starVisible(Object altitude, Object star) {
    return '${altitude}_ $star';
  }

  @override
  String get altitudeShort => 'Alt';

  @override
  String get magnitudeShort => 'Mag';

  @override
  String satellitesVisibleMightExplain(Object count) {
    return '$count satelliti visibili - potrebbe spiegare avvistamento';
  }

  @override
  String satellitesVisibleUnlikelyExplain(Object count) {
    return '$count satelliti visibili - improbabile spiegare avvistamento';
  }

  @override
  String get noSatellitesVisible => 'Nessun satellite visibile';

  @override
  String aircraftDetectedInRadius(Object count, Object radius) {
    return '${radius}_ aeromobili rilevati in ${count}km';
  }

  @override
  String get processingAlert => 'Lavorazione UFO Alert...';

  @override
  String get analyzingEnvironment => 'Analisi delle condizioni ambientali';

  @override
  String get weatherAnalysis => 'Analisi del tempo';

  @override
  String get locationAnalysis => 'Analisi della posizione';

  @override
  String get aircraftTracking => 'Tracciamento di aerei';

  @override
  String get satelliteAnalysis => 'Analisi satellitare';

  @override
  String get celestialAnalysis => 'Analisi Celeste';

  @override
  String analyzing(Object processor) {
    return 'Analisi di $processor...';
  }

  @override
  String get processorWeather => 'condizioni meteorologiche';

  @override
  String get processorLocation => 'dettagli della posizione';

  @override
  String get processorAircraft => 'aerei vicini';

  @override
  String get processorSatellites => 'posizioni satellitari';

  @override
  String get processorCelestial => 'oggetti celesti';

  @override
  String get calculatingCelestialData => 'Calcolo dei dati celesti...';

  @override
  String get sunLabel => 'Sole';

  @override
  String get moonLabel => 'Luna';

  @override
  String planetsVisible(int count) {
    return 'Planets: $count visibile';
  }

  @override
  String get starsLabel => 'Stelle';

  @override
  String get planetsLabel => 'Pianeti';

  @override
  String moonWithPhase(String phase) {
    return 'Luna (_PLACEHOLDER_0__)';
  }

  @override
  String get noSatellitesVisibleAtTime =>
      'Nessun satellite era visibile al momento esatto del vostro avvistamento';

  @override
  String get satellitesVisibleOverheadAtTime =>
      'Satelliti visibili in alto a tempo di avvistamento e posizione';

  @override
  String get belowHorizon => 'sotto orizzonte';

  @override
  String get analysisFailedGeneric => 'Analisi non riuscita';

  @override
  String get unknownWeather => 'Sconosciuto';

  @override
  String get noWeatherDescription => 'Nessuna descrizione';

  @override
  String get altitudeAbbrev => 'Alt';

  @override
  String get azimuthAbbrev => 'Az';

  @override
  String satellitesVisibleNow(int count) {
    return 'Satelliti (_PLACEHOLDER_0__ visibili ora)';
  }

  @override
  String sunWithDescription(String description) {
    return 'Sole:';
  }

  @override
  String moonWithDescription(String description) {
    return 'Luna:';
  }

  @override
  String get unknownPlanet => 'Il pianeta sconosciuto';

  @override
  String get unknownStar => 'Stella sconosciuta';

  @override
  String get unknownSatellite => 'Satellite sconosciuto';

  @override
  String get unknownDirection => 'direzione sconosciuta';

  @override
  String get brightStars => 'Stelle luminose';

  @override
  String get satellites => 'Satelliti';

  @override
  String seeAllSatellites(int count) {
    return 'Vedere tutti i satelliti $count';
  }

  @override
  String maxElevation(String degrees) {
    return 'Elevazione massima: #';
  }

  @override
  String magnitude(String value) {
    return 'Magnitudine: #';
  }

  @override
  String get unknownGeneric => 'Sconosciuto';

  @override
  String altitudeValue(String degrees) {
    return '$degrees° altitudine';
  }

  @override
  String azimuthValue(String degrees) {
    return '$degrees° azimuth';
  }

  @override
  String get noCelestialDataAvailable => 'Nessun dato celeste disponibile.';

  @override
  String get gettingLocation => 'Trovare la tua posizione...';

  @override
  String get media => 'Media';

  @override
  String get locationRequired => 'Location richiesta';

  @override
  String get confirmingWitness => 'Confermare il testimone...';

  @override
  String get chooseYourUsername => 'Scegli il tuo nome utente';

  @override
  String get moreNames => 'More Names';

  @override
  String get weatherClear => 'Libero';

  @override
  String get weatherClearSky => 'cielo limpido';

  @override
  String get rain => 'Pioggia';

  @override
  String get snow => 'Neve';

  @override
  String get thunderstorm => 'Thunderstorm';

  @override
  String get drizzle => 'Dritto';

  @override
  String get fog => 'Fog';

  @override
  String get fewClouds => 'poche nuvole';

  @override
  String get scatteredClouds => 'nuvole sparse';

  @override
  String get brokenClouds => 'nuvole rotte';

  @override
  String get overcastClouds => 'cloud coperto';

  @override
  String get lightRain => 'pioggia leggera';

  @override
  String get moderateRain => 'pioggia moderata';

  @override
  String get heavyRain => 'pioggia pesante';

  @override
  String aircraftDetectedCurrentPositions(
    int count,
    String radius,
    Object raggio,
  ) {
    return 'Aerei rilevati entro ${raggio}km (posizioni attuali)';
  }

  @override
  String dimSatellitesUnlikely(int count) {
    return '$count dim satelliti visibili - improbabile spiegare avvistamento';
  }

  @override
  String get mufonReportingDate => 'MUFON Data di segnalazione';

  @override
  String satelliteNameDirection(String name, String direction) {
    return 'TRADUZIONE:';
  }
}
