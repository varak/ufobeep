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
    return '_ _ PH _ 0 _ _ væk';
  }

  @override
  String alertDirection(int bearing) {
    return 'Leje _ _ PH _ 0 _ _ °';
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
    return 'Indberettet af _ _ PH _ 0 _ _';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Indberettet _ _ PH _ 0 _ _';
  }

  @override
  String distanceAway(String distance) {
    return '_ _ PH _ 0 _ _ væk';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Leje til objekt: _ _ PH _ 0 _ _ °';
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
  String get noCommentsYet => 'Ingen kommentarer endnu. Vær den første!';

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
    return 'Skriver til _ _ PH _ 0 _ _';
  }

  @override
  String get calibratingCompass => 'Kalibrerende kompas..';

  @override
  String get openAROverlay => 'Åbne AR-overlay';

  @override
  String get pushTitleAlertNearby => 'UFO alarm nær dig';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'En ny observation blev rapporteret _ _ PH _ 0 _ _ væk.';
  }

  @override
  String get pushTitleComment => 'Ny kommentar';

  @override
  String get pushBodyComment => 'Nogen kommenterede en observation du følger.';

  @override
  String get pushTitleWitness => 'Vidnebekræftelse';

  @override
  String get pushBodyWitness =>
      'En bruger bekræftede, at de ser det samme objekt.';

  @override
  String get weather => 'Vejret';

  @override
  String cloudCover(int percent) {
    return 'Skydække: _ _ PH _ 0 _ _%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Vind: _ _ PH _ 0 _ _ _ _ PH _ 1 _ _';
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
  String get beepOnly => 'kun bip';

  @override
  String get videoOnly => 'kun video';

  @override
  String get imageOnly => 'kun billede';

  @override
  String get timeJustNow => 'Lige nu';

  @override
  String timeDaysAgo(int count) {
    return '- For nylig';
  }

  @override
  String timeHoursAgo(int count) {
    return '- For længe siden';
  }

  @override
  String timeMinutesAgo(int count) {
    return '_ _ PH _ 0 _ m siden';
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
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Sag # _ _ PH _ 0 _ _ Detaljer';
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
  String get locationLabel => 'Sted';

  @override
  String get distanceLabel => 'Afstand';

  @override
  String get timeLabel => 'Tid';

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
    return '_ _ PH _ 0 _ _ folk bekræftede denne observation';
  }

  @override
  String get photoAnalysisTitle => 'Fotoanalyse';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analyse: _ _ PH _ 0 _ _ mediefiler behandlet';
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
    return '_ _ PH _ 0 _ _ folk har bekræftet denne observation';
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
}
