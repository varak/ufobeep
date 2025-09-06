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
    return 'Cuscinetto __PH_0_°';
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
    return 'Segnalato da __PH_0_';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Relazione $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return 'Traduzione:';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Cuscinetto a oggetto: Traduzione:';
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
  String get noCommentsYet => 'Nessun commento. Sii il primo!';

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
    return 'Punta a __PH_0_';
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
  String get pushBodyWitness =>
      'Un utente ha confermato di vedere lo stesso oggetto.';

  @override
  String get weather => 'Tempo';

  @override
  String cloudCover(int percent) {
    return 'Copertura cloud: __PH_0_%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Eoooooooooaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
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
  String get enablePushNotifications => 'Attivare le notifiche push';

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
  String get beepOnly => 'solo';

  @override
  String get videoOnly => 'video solo';

  @override
  String get imageOnly => 'immagine solo';

  @override
  String get timeJustNow => 'Adesso';

  @override
  String timeDaysAgo(int count) {
    return 'Traduzione:';
  }

  @override
  String timeHoursAgo(int count) {
    return 'Traduzione:';
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
  String get sightingDate => 'Data di tenuta';

  @override
  String get databaseEntry => 'Entrata del database';

  @override
  String get locationLabel => 'Location';

  @override
  String get distanceLabel => 'Distanza';

  @override
  String get timeLabel => 'Tempo';

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
    return 'Analisi: __PH_0_ media file(s) processati';
  }

  @override
  String get addMoreMedia => 'Ulteriori informazioni';

  @override
  String get addMedia => 'Aggiungi i media';

  @override
  String get retakePhoto => 'Recuperare foto';

  @override
  String get retakeVideo => 'Recuperare video';
}
