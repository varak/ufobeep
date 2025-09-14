// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appName => 'UFOBeep';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annullér';

  @override
  String get close => 'Luk';

  @override
  String get save => 'Gem';

  @override
  String get delete => 'Slet';

  @override
  String get edit => 'Redigér';

  @override
  String get retry => 'Prøv igen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nej';

  @override
  String get back => 'Tilbage';

  @override
  String get next => 'Næste';

  @override
  String get done => 'Færdig';

  @override
  String get loading => 'Indlæser..';

  @override
  String get processing => 'Behandler..';

  @override
  String get errorGeneric => 'Noget gik galt.';

  @override
  String get networkError => 'Netværksfejl. Tjek din forbindelse.';

  @override
  String get permissionsRequired => 'Krævede tilladelser';

  @override
  String get learnMore => 'Læs mere';

  @override
  String get welcomeTitle => 'Velkommen til UFOBeep';

  @override
  String get welcomeSubtitle => 'Real- time UFO advarsler i nærheden af dig';

  @override
  String get signIn => 'Log ind';

  @override
  String get signOut => 'Log ud';

  @override
  String get continueAsGuest => 'Fortsæt som gæst';

  @override
  String get enterUsername => 'Indtast et brugernavn';

  @override
  String get username => 'Brugernavn';

  @override
  String get usernameUpdated => 'Brugernavn opdateret';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Indstillinger';

  @override
  String get tabAlerts => 'Indberetninger';

  @override
  String get tabBeep => 'Bip';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabMap => 'Kort';

  @override
  String get tabSettings => 'Indstillinger';

  @override
  String get alertsTitle => 'I nærheden';

  @override
  String get noAlerts => 'Ingen advarsler i nærheden endnu.';

  @override
  String get pullToRefresh => 'Træk for at opdatere';

  @override
  String alertDistance(String distance) {
    return '$distance væk';
  }

  @override
  String alertDirection(int bearing) {
    return 'Leje  °';
  }

  @override
  String get viewAlert => 'Vis alarm';

  @override
  String get viewOnMap => 'Vis på kort';

  @override
  String get iSeeItToo => 'Jeg ser det også';

  @override
  String get confirmWitnessed =>
      'Bekræft at du var vidne til denne observation?';

  @override
  String get witnessConfirmed => 'Tak - din bekræftelse blev sendt.';

  @override
  String get createBeepTitle => 'Send et bip';

  @override
  String get beepExplain =>
      'Indtag, hvad du ser, og alarm i nærheden tilskuere.';

  @override
  String get capturePhoto => 'Fotooptagelse';

  @override
  String get captureVideo => 'Optag video';

  @override
  String get pickFromGallery => 'Vælg mellem galleri';

  @override
  String get descriptionHint => 'Beskriv, hvad du ser på himlen..';

  @override
  String get submitBeep => 'Send Beep';

  @override
  String get beepSent => 'Beep sendt';

  @override
  String beepSentWithUrl(String shortUrl) {
    return 'Beep sendt med succes';
  }

  @override
  String get uploadingMedia => 'Uploader medier..';

  @override
  String get includeLocation => 'Inkludér placering';

  @override
  String get includeTimestamp => 'Inkludér tidsstempel';

  @override
  String get beepFailed => 'Kunne ikke sende Beep.';

  @override
  String get mediaProcessing => 'Behandler medier..';

  @override
  String get cameraPermissionTitle => 'Kameraadgang nødvendig';

  @override
  String get cameraPermissionBody =>
      'Grant kamera adgang til at fange UFO billeder og videoer.';

  @override
  String get locationPermissionTitle => 'Nødvendig lokaliseringsadgang';

  @override
  String get locationPermissionBody =>
      'Vi bruger din placering til at sende og modtage nærliggende advarsler.';

  @override
  String get microphonePermissionTitle => 'Mikrofonadgang nødvendig';

  @override
  String get microphonePermissionBody =>
      'Grant mikrofon adgang til videooptagelse med lyd.';

  @override
  String get openSettings => 'Åbn indstillinger';

  @override
  String get alertDetailTitle => 'Observationsdetaljer';

  @override
  String reportedBy(String username) {
    return 'Indberettet af';
  }

  @override
  String reportedAt(String timeAgo, Object time) {
    return 'Indberettet';
  }

  @override
  String distanceAway(String distance) {
    return 'væk';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Bly til objekt:  °';
  }

  @override
  String get openCompass => 'Åbn kompas';

  @override
  String get openAR => 'Åbne AR-overlay';

  @override
  String get openChat => 'Åbn chat';

  @override
  String get commentsTitle => 'Bemærkninger';

  @override
  String get addComment => 'Tilføj en kommentar..';

  @override
  String get send => 'Send';

  @override
  String get commentPosted => 'Kommentar bogført';

  @override
  String get autoFollowEnabled => 'Du følger nu denne alarm.';

  @override
  String get noCommentsYet =>
      'Ingen kommentarer endnu. Vær den første til at kommentere!';

  @override
  String get newCommentNotification =>
      'Ny kommentar til en observation du følger.';

  @override
  String get mapTitle => 'Live kort';

  @override
  String get compassTitle => 'Kompas';

  @override
  String get compassSettings => 'Kompas indstillinger';

  @override
  String get compassMode => 'Kompas tilstand';

  @override
  String get compassStandardMode => 'Standardtilstand';

  @override
  String get compassPilotMode => 'Pilottilstand';

  @override
  String get compassStandardDescription => 'Overskrift og navigation';

  @override
  String get compassPilotDescription =>
      'Avanceret navigation med ETA og vektoring';

  @override
  String pointingTo(String direction) {
    return 'Angiver til';
  }

  @override
  String get calibratingCompass => 'Kalibrerende kompas..';

  @override
  String get openAROverlay => 'Åbne AR-overlay';

  @override
  String get pushTitleAlertNearby => 'UFO alarm nær dig';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'En ny observation blev rapporteret $distance væk.';
  }

  @override
  String get pushTitleComment => 'Ny kommentar';

  @override
  String get pushBodyComment => 'Nogen kommenterede en observation du følger.';

  @override
  String get pushTitleWitness => 'Vidnebekræftelse';

  @override
  String get temperature => 'Temperatur';

  @override
  String get pushBodyWitness =>
      'En bruger bekræftede, at de ser det samme objekt.';

  @override
  String get weather => 'Vejret';

  @override
  String cloudCover(int percent) {
    return 'Skydække: %';
  }

  @override
  String wind(num speed, String unit) {
    return 'Vind:';
  }

  @override
  String get nearbyAircraft => 'Luftfartøjer i nærheden';

  @override
  String get noAircraft => 'Ingen fly i nærheden';

  @override
  String get loadingContext => 'Indlæser miljøsammenhæng..';

  @override
  String get settingsTitle => 'Indstillinger';

  @override
  String get notifications => 'Meddelelser';

  @override
  String get enablePushNotifications =>
      'Få meddelelser til fremtidige kommentarer';

  @override
  String get quietHours => 'Stille timer';

  @override
  String get quietHoursDesc => 'Tavshedsadvarsler mellem udvalgte timer.';

  @override
  String get dndMode => 'Må ikke forstyrres';

  @override
  String get dndUntil => 'Må ikke forstyrres før';

  @override
  String get language => 'Sprog';

  @override
  String get chooseLanguage => 'Vælg sprog';

  @override
  String get units => 'Enheder';

  @override
  String get unitsImperial => 'Imperial (mi, mph)';

  @override
  String get unitsMetric => 'Metric (km, km / h)';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Betingelser for anvendelse';

  @override
  String get errorNoLocation =>
      'Placering utilgængelig. Prøv igen udenfor med klar himmel udsigt.';

  @override
  String get errorNoCamera => 'Kameraet er ikke tilgængeligt på denne enhed.';

  @override
  String get errorUploadFailed => 'Upload mislykkedes. Prøv igen.';

  @override
  String get errorPermissionDenied => 'Tilladelse nægtet.';

  @override
  String get errorInvalidUsername => 'Det brugernavn er ikke tilgængeligt.';

  @override
  String get nothingToShow => 'Der er intet at vise endnu.';

  @override
  String get storeShortDesc =>
      'Øjeblikkelig UFO advarsler i nærheden af dig. Fange, bekræfte og chatte i realtid.';

  @override
  String get storeLongDesc =>
      'UFOBeep sender real- time advarsler, når nogen ser en UFO i nærheden. Fange billeder og videoer, bekræfte observationer med et tryk, se retning og afstand, og chatte med andre skywatchers.';

  @override
  String get keywords =>
      'UFO, UAP, OVNI, udlændinge, observationer, skywatch, advarsler, radar, kompas';

  @override
  String get noAlertsFound => 'Ingen matchende indberetninger';

  @override
  String get alertsFilterHelp =>
      'Prøv at justere dine filtre for at se flere resultater';

  @override
  String get verified => 'Verificeret';

  @override
  String get beepOnly => 'Kun rapport';

  @override
  String get reportOnly => 'Kun rapport';

  @override
  String get videoOnly => 'kun video';

  @override
  String get imageOnly => 'kun billede';

  @override
  String get mediaOnly => 'Media Only';

  @override
  String get timeJustNow => 'lige nu';

  @override
  String timeDaysAgo(int count) {
    return 'd siden';
  }

  @override
  String timeHoursAgo(int count) {
    return 'h siden';
  }

  @override
  String timeMinutesAgo(int count) {
    return 'm siden';
  }

  @override
  String get loadMoreAlerts => 'Indlæs flere rapporter';

  @override
  String get toggleMufonTooltip => 'Slå MUFON-observationer til og fra';

  @override
  String get showMufonData => 'Vis MUFON data';

  @override
  String get hideMufonData => 'Skjul MUFON data';

  @override
  String get showingUfoBeepOnly => 'Viser kun UFOBeep rapporter';

  @override
  String get showingAllReports =>
      'Viser alle rapporter herunder MUFON database';

  @override
  String get filteredSuffix => 'filtreret';

  @override
  String get detailsTitle => 'Detaljer';

  @override
  String get mufonCase => 'MUFON Sag';

  @override
  String get mufonSighting => 'MUFON Sighting';

  @override
  String get mufonLightSighting => 'MUFON Light Sighting';

  @override
  String get mufonSphereSighting => 'MUFON Sphere Sighting';

  @override
  String get mufonDiscSighting => 'MUFON Disc Sighting';

  @override
  String get mufonTriangleSighting => 'MUFON Triangle Sighting';

  @override
  String get mufonCigarSighting => 'MUFON Cigar Sighting';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting';

  @override
  String get mufonRectangleSighting => 'MUFON Rectangle Sighting';

  @override
  String get mufonCylinderSighting => 'MUFON Cylinder Sighting';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Sighting';

  @override
  String get mufonStarlikeSighting => 'MUFON Starlike Sighting';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Sag #  Detaljer';
  }

  @override
  String get sightingDate => 'Observationsdato';

  @override
  String get mufonDatabaseEntryDate => 'Dato for optagelse i MUFON Database';

  @override
  String get databaseEntry => 'Databaseindgang';

  @override
  String get shareLink => 'Del link';

  @override
  String get linkCopied => 'Link til udklipsholder';

  @override
  String get locationLabel => 'Sted:';

  @override
  String get distanceLabel => 'Afstand';

  @override
  String get timeLabel => 'Tid:';

  @override
  String get reportedByLabel => 'Indberettet af';

  @override
  String get unknownLocation => 'Ukendt placering';

  @override
  String get locationUnknown => 'Sted ukendt';

  @override
  String get witnessesLabel => 'Vidner';

  @override
  String witnessesCountMessage(int count) {
    return 'folk bekræftede denne observation';
  }

  @override
  String get photoAnalysisTitle => 'Fotoanalyse';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analyse:  mediefiler behandlet';
  }

  @override
  String get addMoreMedia => 'Tilføj mere';

  @override
  String get addMedia => 'Tilføj medie';

  @override
  String get retakePhoto => 'Genoptag foto';

  @override
  String get retakeVideo => 'Genoptag video';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galleri';

  @override
  String get basicSettings => 'Grundlæggende indstillinger';

  @override
  String get appSettings => 'App indstillinger';

  @override
  String get alertRange => 'Advarselsområde';

  @override
  String get manageNotificationsDesc =>
      'Administrer abonnementer og indstillinger';

  @override
  String get permissionsTitle => 'Tilladelser';

  @override
  String get permissionLocation => 'Sted';

  @override
  String get permissionCamera => 'Kamera';

  @override
  String get permissionNotifications => 'Meddelelser';

  @override
  String get permissionPhotos => 'Fotos';

  @override
  String get permissionGranted => 'Tildelt';

  @override
  String get permissionNotGranted => 'Ikke tilladt';

  @override
  String get permissionGrant => 'Tilskud';

  @override
  String get generateUsername => 'Generér nyt brugernavn';

  @override
  String get adminTools => 'Admin- værktøjer';

  @override
  String get openAdminPanel => 'Åbn Admin- panel';

  @override
  String get webAdminInterface => 'Web Admin- grænseflade';

  @override
  String get adminBetaNotice =>
      'Beta bygger kun. Adminér værktøjer til test nærhed advarsler, skubbe meddelelser, og system diagnostik.';

  @override
  String get whatDoYouSee => 'Hvad ser du?';

  @override
  String get ufo => 'UFO';

  @override
  String get sighting => 'Sigtning';

  @override
  String get ufoSighting => 'UFO Sigtning';

  @override
  String get envAnalysisTitle => 'Miljøanalyse';

  @override
  String get envAnalysisPending => 'Analyse verserende';

  @override
  String get envAnalysisPendingDesc =>
      'Miljødata vil foreligge, når behandlingen påbegyndes.';

  @override
  String get unknownAircraft => 'Ukendt luftfartøj';

  @override
  String get moreAircraft => 'flere fly';

  @override
  String get premiumImageryTitle => 'Premium Satellit Imagery';

  @override
  String get premiumImagerySubtitle => 'Højopløsnings-kommercielle billeder';

  @override
  String get sightingTypeLabel => 'Type';

  @override
  String get ufoTypeSphere => 'Sphere Formand';

  @override
  String get ufoTypeTriangle => 'Trekant';

  @override
  String get ufoTypeDisk => 'Disk';

  @override
  String get ufoTypeLight => 'Lys';

  @override
  String get ufoTypeFireball => 'Fireball';

  @override
  String get ufoTypeCylinder => 'Cylinder';

  @override
  String get ufoTypeCigar => 'Cigar';

  @override
  String get ufoTypeRectangle => 'Rektangel';

  @override
  String get ufoTypeFormation => 'Dannelse';

  @override
  String get ufoTypeUnknown => 'Ukendt';

  @override
  String get ufoTypeBoomerang => 'BoomerangCity in Germany';

  @override
  String get ufoTypeDiamond => 'Diamant';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Kone';

  @override
  String get ufoTypeCross => 'Kryds';

  @override
  String get ufoTypeDumbbell => 'Håndvægte';

  @override
  String get ufoTypeTeardrop => 'Teardrop';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Bullet';

  @override
  String get ufoTypeSaturn => 'Saturn';

  @override
  String get ufoTypeStarLike => 'Star- like';

  @override
  String get ufoTypeBlimp => 'Blimp';

  @override
  String get shapeTriangle => 'trekant';

  @override
  String get shapeDisc => 'skive';

  @override
  String get shapeDisk => 'disk';

  @override
  String get shapeSphere => 'kugle';

  @override
  String get shapeCigar => 'cigar';

  @override
  String get shapeLight => 'lys';

  @override
  String get shapeBoomerang => 'boomerang';

  @override
  String get shapeDiamond => 'diamant';

  @override
  String get shapeRectangle => 'rektangel';

  @override
  String get shapeOval => 'oval';

  @override
  String get shapeCone => 'kegle';

  @override
  String get shapeCross => 'kors';

  @override
  String get shapeCylinder => 'cylinder';

  @override
  String get shapeDumbbell => 'håndvægt';

  @override
  String get shapeTeardrop => 'teardrop';

  @override
  String get shapeTicTac => 'tic- tac';

  @override
  String get shapeBullet => 'kugle';

  @override
  String get shapeSaturn => 'mættet';

  @override
  String get shapeStarlike => 'starlike';

  @override
  String get shapeBlimp => 'blimp';

  @override
  String get shapeFireball => 'ildkugle';

  @override
  String get shapeFormation => 'formation';

  @override
  String get shapeUnknown => 'ukendt';

  @override
  String get actionsTitle => 'Handlinger';

  @override
  String get addPhotosAndVideos => 'Tilføj billeder og videoer';

  @override
  String get howToReportToMufon => 'Sådan rapporterer du til MUFON';

  @override
  String get reportToMufon => 'Rapport til MUFON';

  @override
  String get whyReportToMufon => 'Hvorfor rapportere til MUFON?';

  @override
  String get openMufonReport => 'Åbne MUFON Rapport';

  @override
  String get confirmedWitness => 'Du bekræftede denne observation';

  @override
  String witnessesHaveConfirmed(int count) {
    return 'folk har bekræftet denne observation';
  }

  @override
  String get aircraftTrackingTitle => 'Flysporing';

  @override
  String get weatherConditionsTitle => 'Vejrforhold';

  @override
  String get noSatellitePasses => 'Ingen synlige satellitpas fundet';

  @override
  String get contentAnalysisTitle => 'Indholdsanalyse';

  @override
  String get contentSafe => 'Indholdet er sikkert';

  @override
  String get contentFlagged => 'Indhold markeret med henblik på anmeldelse';

  @override
  String get confidenceLabel => 'Tillid';

  @override
  String get methodLabel => 'Metode';

  @override
  String get premiumImageryAccessOnly =>
      'Premium satellit billeder er kun tilgængelig for:';

  @override
  String get premiumAccessCreators => 'Advarselsskabere';

  @override
  String get premiumAccessWitnesses => 'Bekræftede vidner inden for sigtbarhed';

  @override
  String get comingSoon => 'Kommer snart';

  @override
  String get directionDistanceTitle => 'Kørselsretning og afstand';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Case #';
  }

  @override
  String get satellitePassesTitle => 'Satellitpas';

  @override
  String get satellitePassExplanation =>
      'Synlig satellit passerer under observation tidsramme. Mange UFO rapporter er faktisk satellitter eller rumaffald.';

  @override
  String get followingAlert => 'Efter alarm - du får kommentarmeddelelser';

  @override
  String get unfollowedAlert =>
      'Ufulgt alarm - ikke flere kommentarmeddelelser';

  @override
  String get alertFollowError => 'Fejl under opdatering af følg status';

  @override
  String get notificationChannelAlerts => 'UFOBeep Alerts';

  @override
  String get notificationChannelAlertsDesc =>
      'Anmeldelser for UFO bipper og nærhed advarsler';

  @override
  String get notificationSightingTitle => 'UFO Sigtning';

  @override
  String get notificationSightingUrgent => 'UFO Sigtning';

  @override
  String get notificationSightingEmergency => 'UFO OM NØDVENDIGT Sigtning';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return 'nær';
  }

  @override
  String notificationCommentTitle(String username) {
    return 'kommenterede';
  }

  @override
  String get notificationWitnessText => 'Ny observation';

  @override
  String notificationWitnessTextMultiple(int count) {
    return 'vidner';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Frafald';

  @override
  String notificationDistance(String distance) {
    return 'væk';
  }

  @override
  String get unknown => 'ukendt';

  @override
  String get report => 'rapport';

  @override
  String get mufon => 'mofon';

  @override
  String get recentUfoBeepsTitle => 'Nylig UFO Bipper';

  @override
  String get recentUfoBeepsSubtitle =>
      'Live UFOBeep community reports & MUFON database observationer';

  @override
  String get recentUfoBeepsDescription =>
      'Dette feed kombinerer real- time UFOBeep \"bipper\" fra vores mobile app-brugere med historiske rapporter fra MUFON databasen.';

  @override
  String get loadingBeeps => 'Indlæser nylige bip...';

  @override
  String get noBeepsAvailable => 'Ingen bip i øjeblikket.';

  @override
  String get anomalyReported => 'Anomali rapporteret';

  @override
  String get copyShortLink => 'Kopiér kort link';

  @override
  String get shareAlert => 'Del alarm';

  @override
  String get previousPage => 'Forrige';

  @override
  String get nextPage => 'Næste';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Side  af  ( totalt bip)';
  }

  @override
  String get heroTagline => 'Få advarsler når du skal gå udenfor og se op';

  @override
  String get heroDescription =>
      'Gå aldrig glip af endnu en UFO observation. Få realtidsadvarsler når nogen nær dig ser noget underligt på himlen. Ret din telefon og find præcis hvor du skal kigge.';

  @override
  String get downloadApp => 'Download App';

  @override
  String get viewAllBeeps => 'Vis alle bip';

  @override
  String get sightingsMap => 'Observationskort';

  @override
  String get globalSightingNetwork => 'Global Sighting- netværk';

  @override
  String get howItWorks => 'Hvordan UFOBeep virker';

  @override
  String get backToBeeps => 'Tilbage til bip';

  @override
  String get loadingDetails => 'Indlæser bip detaljer...';

  @override
  String get details => 'Detaljer';

  @override
  String get location => 'Sted';

  @override
  String get timeAgo => 'siden';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'miles';

  @override
  String get distanceNearby => 'i nærheden';

  @override
  String get ufobeepWitnesses => 'Vidner';

  @override
  String get ufobeepConfirmations => 'Bekræfter';

  @override
  String get ufobeepAlertLevel => 'Alarmniveau';

  @override
  String get ufobeepReportType => 'UFOBeep-rapport';

  @override
  String get mufonAttribution => 'MUFON Databaserapport';

  @override
  String get mufonCaseNumber => 'Case #';

  @override
  String get mufonGenericTitle => 'MUFON Sighting Report';

  @override
  String get mufonSphere => 'Sphere Formand';

  @override
  String get mufonLight => 'Lys';

  @override
  String get mufonDisk => 'Disk';

  @override
  String get mufonTriangle => 'Trekant';

  @override
  String get mufonCigar => 'Cigar';

  @override
  String get mufonOval => 'Oval';

  @override
  String get mufonCylinder => 'Cylinder';

  @override
  String get mufonRectangle => 'Rektangel';

  @override
  String get mufonDiamond => 'Diamant';

  @override
  String get mufonFireball => 'Fireball';

  @override
  String get mufonFlash => 'Flash';

  @override
  String get mufonFormation => 'Dannelse';

  @override
  String get mufonChanging => 'Ændring';

  @override
  String get mufonChevron => 'Chevron Formand';

  @override
  String get mufonCone => 'Kone';

  @override
  String get mufonCross => 'Kryds';

  @override
  String get mufonEgg => 'Æg';

  @override
  String get mufonOther => 'Objekt';

  @override
  String get mufonUnknown => 'Ukendt objekt';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON  Rapport';
  }

  @override
  String get nuforcAttribution => 'NUFORC Databaserapport';

  @override
  String get nuforcCaseNumber => 'Case #';

  @override
  String get nuforcGenericTitle => 'NUFORC Observationsrapport';

  @override
  String get mediaImageNotFound => 'Billede ikke fundet';

  @override
  String get mediaPlayVideo => 'Afspil video';

  @override
  String get mediaViewImage => 'Vis billede';

  @override
  String mediaCount(Object count) {
    return 'billeder';
  }

  @override
  String get mediaCountSingle => '1 billede';

  @override
  String mediaMoreImages(Object count) {
    return '+  mere';
  }

  @override
  String get errorNotFound => 'Bip ikke fundet';

  @override
  String get errorLoadError => 'Kunne ikke indlæse bip detaljer';

  @override
  String get shareYourThoughts => 'Del dine tanker om denne observation...';

  @override
  String get postComment => 'Post Kommentar';

  @override
  String get loggedInAs => 'Indskrevet som';

  @override
  String get logout => 'Logout';

  @override
  String get notFollowing => 'Ikke efter';

  @override
  String get follow => 'Følg';

  @override
  String get navRecentBeeps => 'Nylige bip';

  @override
  String get navMap => 'Kort';

  @override
  String get navDownloadApp => 'Download app';

  @override
  String get alertLevel => 'Alarmniveau';

  @override
  String get witnesses => 'Vidner';

  @override
  String get confirmations => 'Bekræfter';

  @override
  String get reporterLabel => 'Indberettet af brugeren';

  @override
  String get coordinatesLabel => 'Koordinater';

  @override
  String get eventTime => 'Begivenhedstid';

  @override
  String get reportedTime => 'Rapporteret tid';

  @override
  String get mufonDatabaseReport => 'MUFON Databaserapport';

  @override
  String get copyShortLinkTitle => 'Kopiér link til udklipsholderen';

  @override
  String get imageNotFound => 'Billede ikke fundet';

  @override
  String get ufoSightingAlt => 'UFO observation';

  @override
  String get celestialDataTitle => 'Celestial Objects';

  @override
  String get visiblePlanets => 'Visible Planets';

  @override
  String get locationDataTitle => 'Location Information';

  @override
  String get timezone => 'Timezone';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get processingSummaryTitle => 'Processing Summary';

  @override
  String get processingTime => 'Processing Time';

  @override
  String get successful => 'Successful';

  @override
  String get failed => 'Failed';
}
