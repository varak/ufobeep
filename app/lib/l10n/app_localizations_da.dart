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
    return '_ _ PLACEREPORT _ 0 _ _ væk';
  }

  @override
  String alertDirection(int bearing) {
    return 'Leje _ _ PLACEREPER _ 0 _ _ °';
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
    return 'Rapporteret af _ _ PLACEREPER _ 0 _ _';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Rapporteret _ _ PLACEREPORT _ 0 _ _';
  }

  @override
  String distanceAway(String distance) {
    return 'væk';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Leje til objekt: _ _ _ PLACEREPER _ 0 _ _ °';
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
    return 'At pege på _ _ PLACEREPORT _ 0 _ _';
  }

  @override
  String get calibratingCompass => 'Kalibrerende kompas..';

  @override
  String get openAROverlay => 'Åbne AR-overlay';

  @override
  String get pushTitleAlertNearby => 'UFO alarm nær dig';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'En ny observation blev rapporteret _ _ PLACEREPER _ 0 _ _ away.';
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
    return 'Skydække: _ _ PLACEREPORT _ 0 _ _%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Vind: _ _ PLACEREPORT _ 0 _ _ _ _ PLACEREPORT _ 1 _ _';
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
  String get beepOnly => 'Kun bip';

  @override
  String get reportOnly => 'Kun tekst';

  @override
  String get videoOnly => 'Kun video';

  @override
  String get imageOnly => 'Kun billede';

  @override
  String get mediaOnly => 'Kun medier';

  @override
  String get timeJustNow => 'lige nu';

  @override
  String timeDaysAgo(int count) {
    return '_ _ PLACEREPORT _ 0 _ _ dage siden';
  }

  @override
  String timeHoursAgo(int count) {
    return '_ _ PLACEREPORT _ 0 _ _ timer siden';
  }

  @override
  String timeMinutesAgo(int count) {
    return '_ _ PLACEREPER _ 0 _ _ minutter siden';
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
  String get mufonSighting => 'MUFON Sighting Report';

  @override
  String get mufonLightSighting => 'MUFON Light Sighting Report';

  @override
  String get mufonSphereSighting => 'MUFON Sphere Sightingrapport';

  @override
  String get mufonDiscSighting => 'MUFON Disc Sighting Report';

  @override
  String get mufonTriangleSighting => 'MUFON Trekantssigterapport';

  @override
  String get mufonCigarSighting => 'MUFON Cigar Sighting Report';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sightingrapport';

  @override
  String get mufonRectangleSighting => 'MUFON Rektangel Sighting Report';

  @override
  String get mufonCylinderSighting => 'MUFON Cylinder Sightingrapport';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Sightingrapport';

  @override
  String get mufonStarlikeSighting => 'MUFON Starlike Sighting Report';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON sag # _ _ PLACEREPER _ 0 _ _ Detaljer';
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
    return '_ _ PLACEREPORT _ 0 _ _ folk bekræftede denne observation';
  }

  @override
  String get photoAnalysisTitle => 'Fotoanalyse';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analyse: _ _ PLACEREPORT _ 0 _ _ mediefil (r) behandlet';
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
  String get timeFormat => 'Tidsformat';

  @override
  String get timeFormat24Hour => '24 timer (14: 30)';

  @override
  String get timeFormat12Hour => '12-time (14: 30)';

  @override
  String get timeFormatDesc => 'Vis tid i 24- timers eller 12- timers format';

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
  String get ufoSighting => 'UFOBeep UFO Indberetning';

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
    return '_ _ PLACEREPORT _ 0 _ _ folk har bekræftet denne observation';
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
    return 'MUFON Case # _ _ PLACEREPER _ 0 _ _';
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
  String get notificationSightingTitle => 'UFOBeep UFO Indberetning';

  @override
  String get notificationSightingUrgent => 'STOR UFO Indberetning';

  @override
  String get notificationSightingEmergency =>
      'UFO FOR NØDSITUATIONER Indberetning';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '_ _ PLACEREPORT _ 0 _ _ nær _ _ PLACEREPORT _ 1 _ _';
  }

  @override
  String notificationCommentTitle(String username) {
    return '_ _ PLACEREPER _ 0 _ _ kommenterede';
  }

  @override
  String get notificationWitnessText => 'Ny observation';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '- Vidner';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Frafald';

  @override
  String notificationDistance(String distance) {
    return '_ _ PLACEREPORT _ 0 _ _ væk';
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
      'Live UFO observation rapporter fra vores globale samfund';

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
  String get ufoSightingAlert => 'UFO Observationsadvarsel';

  @override
  String get previousPage => 'Forrige';

  @override
  String get nextPage => 'Næste';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Side _ _ PLACEREPORT _ 0 _ af _ _ PLACEREPORT _ 1 _ _ (_ _ PLACEREPORT _ 2 _ _ i alt bip)';
  }

  @override
  String get firstPage => 'Første';

  @override
  String get lastPage => 'Sidste';

  @override
  String get jumpToPage => 'Spring til side';

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
    return 'MUFON _ _ PLACEREPORT _ 0 _ _ Rapport';
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
    return '_ _ PLACEREPORT _ 0 _ _ billeder';
  }

  @override
  String get mediaCountSingle => '1 billede';

  @override
  String mediaMoreImages(Object count) {
    return '+ _ _ PLACEREPORT _ 0 _ _ mere';
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
  String get addedToUfobeep => 'Tilføjet UFOBeep';

  @override
  String get mufonDatabaseReport => 'MUFON Databaserapport';

  @override
  String get copyShortLinkTitle => 'Kopiér link til udklipsholderen';

  @override
  String get imageNotFound => 'Billede ikke fundet';

  @override
  String get ufoSightingAlt => 'UFO Bip UFO alarm';

  @override
  String get celestialDataTitle => 'Himmelske objekter';

  @override
  String get visiblePlanets => 'Synlige planeter';

  @override
  String get locationDataTitle => 'Lokaliseringsinformation';

  @override
  String get timezone => 'Tidszone';

  @override
  String get coordinates => 'Koordinater';

  @override
  String get processingSummaryTitle => 'Forarbejdningsoversigt';

  @override
  String get processingTime => 'Behandlingstid';

  @override
  String get successful => 'Succesfuld';

  @override
  String get failed => 'Mislykkedes';

  @override
  String get locationEnrichmentTitle => 'Placering';

  @override
  String get aircraftDataSource => 'Datakilde';

  @override
  String get noAircraftDetected => 'Intet luftfartøj detekteret';

  @override
  String get sightingReport => 'Observationsrapport';

  @override
  String get ufoAlert => 'UFO Indberetning';

  @override
  String get alert => 'Indberetning';

  @override
  String get notificationTickerUfoAlert =>
      'UFO Alert - Ny observation i nærheden';

  @override
  String get notificationTickerComment => 'Ny kommentar til UFO Alert';

  @override
  String get weatherConditions => 'Vejrforhold';

  @override
  String get visibility => 'Synlighed';

  @override
  String get humidity => 'Fugtighed';

  @override
  String get pressure => 'Tryk';

  @override
  String get locationDetails => 'Placering';

  @override
  String get city => 'By';

  @override
  String get state => 'Tilstand';

  @override
  String get country => 'Land';

  @override
  String get satelliteActivity => 'Satellitaktivitet';

  @override
  String get satellitesVisibleOverhead =>
      'Satellitter synlige overhead ved observation tid & placering';

  @override
  String get dataSource => 'Datakilde';

  @override
  String get blackskyImagery => 'BlackSky Imagery';

  @override
  String get resolution => 'Opløsning';

  @override
  String get groundResolution => '35cm jordopløsning';

  @override
  String get delivery => 'Levering';

  @override
  String get averageDelivery => '90 minutters gennemsnit';

  @override
  String get cost => 'Omkostninger';

  @override
  String get skyfiSatelliteImagery => 'SkyFi Satellite Imagery';

  @override
  String get region => 'Region';

  @override
  String get remoteArea => 'Fjernområde';

  @override
  String get startingPrice => 'Startpris';

  @override
  String get coverage => 'Dækning';

  @override
  String get confidenceCoverage => '95% konfidensinterval';

  @override
  String get status => 'Status';

  @override
  String get shareThoughts => 'Del dine tanker om denne observation...';

  @override
  String get postCommand => 'Post- kommando';

  @override
  String get clouds => 'Skyer';

  @override
  String get windLabel => 'Vind';
}
