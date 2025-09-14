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
  String get locationPermissionTitle => 'Accesso alla posizione necessaria';

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
    return 'via';
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
    return 'Copertura cloud: __PLACEHOLDER_0_%';
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
  String get dndMode => 'Non disturbare';

  @override
  String get dndUntil => 'Non disturbare fino a quando';

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
  String get reportOnly => 'Relazione';

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
    return '__PLACEHOLDER_0_d fa';
  }

  @override
  String timeHoursAgo(int count) {
    return '__PLACEHOLDER_0_h fa';
  }

  @override
  String timeMinutesAgo(int count) {
    return 'Traduzione:';
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
    return '__PLACEHOLDER_0_';
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
  String get unknown => 'sconosciuto';

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
  String get previousPage => 'Precedente';

  @override
  String get nextPage => 'Il prossimo';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Pagina $currentPage di ${totalPages}_ (_PLACEHOLDER_2___ total beeps)';
  }

  @override
  String get heroTagline => 'Ricevi avvisi quando uscire e guardare in alto';

  @override
  String get heroDescription =>
      'Non perdere mai un altro avvistamento UFO. Ricevi avvisi in tempo reale quando qualcuno vicino a te vede qualcosa di strano nel cielo. Punta il telefono e trova esattamente dove guardare.';

  @override
  String get downloadApp => '📱 Scarica App';

  @override
  String get viewAllBeeps => '📋 Vedi tutte le pecore';

  @override
  String get sightingsMap => '🗺️ Sightings mappa';

  @override
  String get globalSightingNetwork => 'Rete di visione globale';

  @override
  String get howItWorks => 'Come funziona UFOBeep';

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
  String get mufonDatabaseReport => 'MUFON Rapporto Database';

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
}
