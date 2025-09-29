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
  String get locationPermissionTitle => 'Lokaliseringstilladelse påkrævet';

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
    return '_ _ PLACEREPORT _ 0 _ _';
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
  String get quietHoursEnabled => 'Aktivér stille timer';

  @override
  String get quietHoursFrom => 'Fra';

  @override
  String get quietHoursUntil => 'Indtil';

  @override
  String get quietHoursDefaultTime => 'Standard stille timer';

  @override
  String get emergencyOverride => 'Nødudgang';

  @override
  String get emergencyOverrideDesc => 'Tillad hurtig varsling i stille timer';

  @override
  String get dndMode => 'Må ikke forstyrres';

  @override
  String get dndUntil => 'Må ikke forstyrres før';

  @override
  String dndEnabled(Object time) {
    return 'DND aktiveret indtil _ _ PLACEREPER _ 0 _ _';
  }

  @override
  String get dndDisabled => 'DND deaktiveret';

  @override
  String quietHoursActive(String startTime, String endTime) {
    return 'Aktiv _ _ PLACEREPORT _ 0 _ - _ _ PLACEREPORT _ 1 _ _';
  }

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Stille timer: _ _ PLACEREPORT _ 0 _ - _ _ PLACEREPORT _ 1 _ _';
  }

  @override
  String get pushNotificationUfoAlert => 'UFO Indberetning';

  @override
  String get pushNotificationAnomalyAlert => 'Anomali alarm';

  @override
  String get pushNotificationNearby => 'I nærheden';

  @override
  String get pushNotificationInYourArea =>
      'i dit område. Tryk på for at se detaljer.';

  @override
  String pushNotificationCommented(Object username) {
    return '_ _ PLACEREPER _ 0 _ _ kommenterede';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '_ _ PLACEREPORT _ 0 _ _ kommenteret _ _ PLACEREPORT _ 1 _ _';
  }

  @override
  String get pushNotificationGeneric => 'UFOBeep';

  @override
  String get pushNotificationNewSighting => 'Ny observation i nærheden';

  @override
  String get language => 'Sprog';

  @override
  String get chooseLanguage => 'Vælg sprog';

  @override
  String get units => 'Enheder';

  @override
  String get unitsImperial => 'Imperial';

  @override
  String get unitsMetric => 'Metric';

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
  String get timeFormat24Hour => '24 timer';

  @override
  String get timeFormat12Hour => '12- time';

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
  String get showLess => 'Få flere detaljer';

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
  String get attachMedia => 'Vedlæg medier';

  @override
  String get addCommentOptional => 'Tilføj en kommentar (valgfri)';

  @override
  String get describeNewMedia => 'Beskriv de nye medier...';

  @override
  String get filesSelected => 'filer valgt';

  @override
  String get selectMediaToAttach =>
      'Vælg billeder eller videoer der skal vedlægges';

  @override
  String get newMediaUploaded => 'Nye medier uploadet';

  @override
  String get mediaFilesUploaded => 'nye mediefiler uploadet';

  @override
  String get filesAttachedSuccessfully => 'filer knyttet med succes';

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
  String get unknown => 'Ukendt';

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
      'Aldrig gå glip af en anden UFO observation i dit område';

  @override
  String get downloadApp => 'Download App';

  @override
  String get viewAllBeeps => 'Vis alle bip';

  @override
  String get sightingsMap => 'Observationskort';

  @override
  String get globalSightingNetwork => 'Global Sighting- netværk';

  @override
  String get howItWorks => 'Sådan virker det';

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
  String get mufonDatabaseReport => 'MUFON Sagsnummer:';

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

  @override
  String get filterAlerts => 'Filterrapporter';

  @override
  String get alertSource => 'Advarselskilde';

  @override
  String get ufobeepOnly => 'Kun UFOBeep';

  @override
  String get ufobeepOnlyDescription =>
      'Vis kun originale UFOBeep rapporter (udelukker MUFON database)';

  @override
  String get alertDistanceRange => 'Advarselsafstand';

  @override
  String get showAllAlerts => 'Vis alle rapporter';

  @override
  String get showAll => 'Vis alle';

  @override
  String get distanceSliderDescription =>
      'Træk for at justere hvor langt du ønsker at se advarsler. Start fra vejrsigtbarhed afstand op til at vise alle indberetninger uanset afstand.';

  @override
  String get applyFilters => 'Anvend filtre';

  @override
  String get notificationRange => 'Meddelelsesområde';

  @override
  String get notificationRangeDescription =>
      'Få push advarsler for observationer inden for denne afstand';

  @override
  String get viewingRange => 'Visningsområde';

  @override
  String get viewingRangeDescription =>
      'Vis observationer inden for denne afstand når du søger';

  @override
  String get weatherVisibility => 'Vejrsigtbarhed (~ 10 km)';

  @override
  String get localArea => 'Lokalt område (25 km)';

  @override
  String get regional => 'Regionalt';

  @override
  String get pushNotifications => 'Trykmeddelelser';

  @override
  String get alertBrowsing => 'Alert browsing';

  @override
  String get pushAlertsWithinDistance =>
      'Få meddelelser inden for dette område';

  @override
  String get showAlertsWhenBrowsing => 'Filtrér hvad du ser på listen';

  @override
  String get heroMainTagline =>
      'Få et bip på telefonen, når ufoer er set i nærheden';

  @override
  String get heroSecondaryTagline =>
      'Find ud af hvornår og hvor man kan se på himlen';

  @override
  String get sourceFilters => 'Kilde';

  @override
  String get sourceFiltersDescription =>
      'Vælg hvilke rapporter der vises i din feed';

  @override
  String get ufobeepAndMufon => 'UFOBeep + MUFON';

  @override
  String get ufobeepOnlySource => 'Kun UFOBeep';

  @override
  String get mufonOnlySource => 'Kun MUFON';

  @override
  String get browseFilters => 'Gennemse';

  @override
  String get browseFiltersDescription =>
      'Hvordan man ser og sorterer indberetninger';

  @override
  String get sortByNewest => 'Nyeste';

  @override
  String get sortByNearest => 'Nærmeste';

  @override
  String get sortBy => 'Sortér efter';

  @override
  String get pushAlertsTitle => 'Push Alerts';

  @override
  String get pushAlertsDescription => 'Hvad pings din telefon';

  @override
  String get alertRadius => 'Alarm Radius';

  @override
  String get mufonNoPushInfo =>
      'MUFON-rapporter importeres hver nat og udløser ikke push-advarsler';

  @override
  String get privacyData => 'Databeskyttelse';

  @override
  String get privacyPolicyDesc => 'Hvordan vi beskytter og bruger dine data';

  @override
  String get termsOfService => 'Tjenestevilkår';

  @override
  String get termsOfServiceDesc => 'Retsforskrifter';

  @override
  String get locationTracking => 'Placering Tracking';

  @override
  String get locationTrackingDesc =>
      'Baggrundsplacering for nærhedsindberetninger';

  @override
  String get locationTrackingTitle => 'Baggrundslokaliseringssporing';

  @override
  String get locationTrackingExplanation =>
      'UFOBeep overvåger din placering i baggrunden for at sende dig nærhed advarsler, når UFO observationer ske i nærheden af din nuværende placering, selv når du er væk fra hjemmet.';

  @override
  String get locationTrackingBattery =>
      'Bruger intelligent geofencing til < 3% batteri sammenstød';

  @override
  String get backgroundLocationTracking => 'Aktivér baggrund Sporing';

  @override
  String get locationTrackingActive =>
      'Overvågningssted for nærhedsindberetninger';

  @override
  String get locationTrackingInactive => 'Lokaliseringssporing er deaktiveret';

  @override
  String get locationTrackingDisabledWarning =>
      'Du vil ikke modtage nærhed advarsler, når du flytter til nye steder';

  @override
  String get trackingStatus => 'Sporingsstatus';

  @override
  String get monitoringStatus => 'Overvågning';

  @override
  String get active => 'Aktiv';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get lastKnownLocation => 'Sidste kendte placering';

  @override
  String get lastLocationUpdate => 'Sidste opdatering';

  @override
  String get movementThreshold => 'Bevægelsestærskel';

  @override
  String get updateFrequency => 'Opdatér frekvens';

  @override
  String get batteryImpact => 'Batterieffekt';

  @override
  String get dataPrivacy => 'Databeskyttelse';

  @override
  String get locationPermissionExplanation =>
      'UFOBeep har brug for \'Always Tillad\' placering tilladelse til at overvåge din bevægelse og sende nærhed advarsler, når du er på nye steder.';

  @override
  String get benefitsTitle => 'Ydelser';

  @override
  String get locationTrackingBenefits =>
      '• Få UFO advarsler, uanset hvor du rejser\n• Automatisk opdatering af placering\n• Ingen manuel opsætning påkrævet';

  @override
  String get allowLocationAccess => 'Tillad stedadgang';

  @override
  String get locationPermissionRequired =>
      'Placering er påkrævet for baggrundssporing';

  @override
  String get locationTrackingEnabled =>
      'Sporing af baggrundsplacering aktiveret';

  @override
  String get locationTrackingDisabled =>
      'Baggrundslokaliseringssporing deaktiveret';

  @override
  String get justNow => 'Lige nu';

  @override
  String minutesAgo(int minutes) {
    return '_ _ PLACEREPER _ 0 _ _ minutter siden';
  }

  @override
  String hoursAgo(int hours) {
    return '_ _ PLACEREPORT _ 0 _ _ timer siden';
  }

  @override
  String daysAgo(int days) {
    return '_ _ PLACEREPORT _ 0 _ _ dage siden';
  }

  @override
  String get dataManagement => 'Datahåndtering';

  @override
  String get dataManagementDesc => 'Eksportér eller slet dine kontodata';

  @override
  String get splashTagline => 'Real- time observation indberetninger';

  @override
  String get splashStartingUp => 'Starter...';

  @override
  String get splashInitializationFailed => 'Initialisering mislykkedes';

  @override
  String get splashInitializationFailedTitle => 'Initialisering mislykkedes';

  @override
  String get splashInitializationError =>
      'App \'en kunne ikke initialisere korrekt:';

  @override
  String get splashRetry => 'Prøv igen';

  @override
  String get splashContinue => 'Fortsæt';

  @override
  String get splashInitializing => 'Initialisering...';

  @override
  String signInWelcome(String username) {
    return 'Velkommen!';
  }

  @override
  String signInFailed(String error) {
    return 'Signal- in mislykkedes: _ _ PLACEREPORT _ 0 _ _';
  }

  @override
  String get signInPleaseEnterEmail => 'Indtast venligst din e-mailadresse';

  @override
  String get signInPleaseEnterValidEmail =>
      'Indtast en gyldig e- mail- adresse';

  @override
  String get signInMagicLinkSent =>
      'Magisk link sendt! Tjek din e-mail og klik på linket for at logge ind.';

  @override
  String get signInMagicLinkFailed =>
      'Kunne ikke sende et magisk link. Prøv igen.';

  @override
  String get signInAllDataCleared => 'Alle data ryddet';

  @override
  String get signInSubtitle =>
      'Real- time UFO observation advarsler og MUFON rapporter';

  @override
  String get signInGoogleLoading => 'Signerer ind...';

  @override
  String get signInContinueWithGoogle => 'Fortsæt med Google';

  @override
  String get signInOr => 'eller';

  @override
  String get signInWithEmail => 'Log ind med e-mail';

  @override
  String get signInEmailDescription => 'Vi sender dig et sikkert link';

  @override
  String get signInEmailAddress => 'E- mail- adresse';

  @override
  String get signInEmailPlaceholder => 'din @ email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'Prøv igen i _ _ PLACEREPER _ 0 _ _ s';
  }

  @override
  String get signInSending => 'Sende...';

  @override
  String get signInSendMagicLink => 'Send magisk link';

  @override
  String get signInCheckEmail =>
      'Tjek din e-mail! Forbindelsen udløber om 15 minutter.';

  @override
  String get signInSecureAuth => 'Sikker autentificering';

  @override
  String get signInSecureAuthDescription =>
      'Brug Google Sign-In til øjeblikkelig adgang, eller e-mail magiske links, der udløber i 15 minutter.';

  @override
  String get signInClearAllDataDebug => 'Ryd alle data (fejl)';

  @override
  String get emailAuthFailedToSend => 'Kunne ikke sende e- mail';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'Kunne ikke sende e- mail. Prøv igen.';

  @override
  String get emailAuthInvalidEmail =>
      'Ugyldig e- mail- adresse. Tjek venligst formatet.';

  @override
  String get emailAuthUserNotFound =>
      'Ingen konto fundet med denne e-mailadresse.';

  @override
  String get emailAuthTooManyRequests => 'For mange forsøg. Prøv igen senere.';

  @override
  String get emailAuthOperationNotAllowed =>
      'E- mail- link sign- in er ikke aktiveret.';

  @override
  String get emailAuthQuotaExceeded =>
      'Email kvote overskredet. Prøv igen i morgen.';

  @override
  String get emailAuthVerificationFailed =>
      'Email-verifikation mislykkedes. Prøv igen.';

  @override
  String get emailAuthTitle => 'E- mail- verificering';

  @override
  String get emailAuthVerifyYourEmail => 'Verificér din e-mail';

  @override
  String get emailAuthDescription =>
      'Tilføj din e-mail-adresse for konto opsving og sikkerhed. Vi sender dig et sikkert signal.';

  @override
  String get emailAuthEmailAddress => 'E- mail- adresse';

  @override
  String get emailAuthEmailPlaceholder => 'your.email @ example.com';

  @override
  String get emailAuthPleaseEnterEmail => 'Indtast venligst din e-mailadresse';

  @override
  String get emailAuthPleaseEnterValidEmail =>
      'Indtast en gyldig e- mail- adresse';

  @override
  String get emailAuthCheckEmailToContinue =>
      'Tjek din e-mail og tap på verifikationslinket for at fortsætte.';

  @override
  String get emailAuthResendEmail => 'Nulstil e- mail';

  @override
  String get emailAuthSendVerificationEmail => 'Send verificering E- mail';

  @override
  String get emailAuthHowItWorks => 'Hvordan e-mail-verifikation virker';

  @override
  String get emailAuthHowItWorksSteps =>
      '1. Vi sender dig et sikkert signal.\n2. Tjek din e-mail og tryk på linket\n3. Din email bliver verificeret automatisk\n4. Ingen adgangskoder behøves!';

  @override
  String get emailAuthSecurityNotice =>
      'Email-verifikation hjælper med at sikre din konto og gør det muligt konto opsving, hvis du mister adgang til din enhed.';

  @override
  String get phoneAuthFailedToSendCode =>
      'Kunne ikke sende verifikationskode. Prøv igen.';

  @override
  String get phoneAuthInvalidCodeTryAgain =>
      'Ugyldig verifikationskode. Prøv igen.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'Bekræftet telefonnummer: _ _ PLACEREPORT _ 0 _ _';
  }

  @override
  String get phoneAuthVerificationFailed =>
      'Telefonbekræftelse mislykkedes. Prøv igen.';

  @override
  String get phoneAuthCodeResent => 'Verifikationskode';

  @override
  String get phoneAuthFailedToResendCode =>
      'Kunne ikke videresende kode. Prøv igen.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'Ugyldigt telefonnummer. Tjek venligst formatet.';

  @override
  String get phoneAuthTooManyRequests => 'For mange forsøg. Prøv igen senere.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'Ugyldig verifikationskode. Tjek og prøv igen.';

  @override
  String get phoneAuthSessionExpired =>
      'Verifikationsmødet udløb. Bed om en ny kode.';

  @override
  String get phoneAuthSmsQuotaExceeded =>
      'SMS kvote overskredet. Prøv igen i morgen.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'Dette telefonnummer er allerede knyttet til en anden konto.';

  @override
  String get phoneAuthVerificationFailedGeneric =>
      'Verifikationen mislykkedes. Prøv igen.';

  @override
  String get phoneAuthTitle => 'Telefonverifikation';

  @override
  String get phoneAuthVerifyYourPhone => 'Verificér din telefon';

  @override
  String get phoneAuthEnterVerificationCode => 'Indtast verifikation Kode';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'Tilføj dit telefonnummer til konto opsving og sikkerhed';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return 'Indtast den 6cifrede kode sendt til _ _ PLACEREPER _ 0 _ _ _';
  }

  @override
  String get phoneAuthPhoneNumber => 'Telefonnummer';

  @override
  String get phoneAuthPhonePlaceholder => '+ 1 (555) 123- 4567';

  @override
  String get phoneAuthPleaseEnterPhone => 'Indtast venligst dit telefonnummer';

  @override
  String get phoneAuthPleaseEnterValidPhone =>
      'Indtast venligst et gyldigt telefonnummer';

  @override
  String get phoneAuthVerificationCode => 'Verifikationskode';

  @override
  String get phoneAuthPleaseEnterSixDigitCode =>
      'Indtast venligst den 6cifrede kode';

  @override
  String get phoneAuthResendCode => 'Nulstil kode';

  @override
  String get phoneAuthSendVerificationCode => 'Send verificering Kode';

  @override
  String get phoneAuthVerifyCode => 'Verificér kode';

  @override
  String get phoneAuthChangePhoneNumber => 'Skift telefonnummer';

  @override
  String get phoneAuthSmsNotice =>
      'Vi sender dig en kode via SMS. Der kan gælde standardsatser for meddelelser.';

  @override
  String get phoneAuthCodeExpires =>
      'Koden udløber om 60 sekunder. Tjek dine beskeder.';

  @override
  String get yourDataRights => 'Dine datarettigheder';

  @override
  String get dataRightsExplanation =>
      'Du har fuld kontrol over dine personlige data. Du kan eksportere alle dine data eller permanent slette din konto til enhver tid.';

  @override
  String get exportYourData => 'Eksportér dine data';

  @override
  String get exportDataDescription => 'Download alle dine kontodata';

  @override
  String get exportData => 'Eksportdata';

  @override
  String get exportingData => 'Eksporterer...';

  @override
  String get exportDataDetails =>
      'Inkluderer: profil, bip, kommentarer, enhedsinfo, og præferencer. Data leveres i JSON-format.';

  @override
  String get dataExportedSuccessfully => 'Data eksporteret med succes';

  @override
  String get dataExportFailed => 'Kunne ikke eksportere data';

  @override
  String get deleteAccount => 'Slet konto';

  @override
  String get deleteAccountDescription =>
      'Fjern permanent din konto og alle data';

  @override
  String get deleteAccountWarning =>
      'Denne handling kan ikke bringes til ophør. Alle dine bip, kommentarer og konto data vil blive slettet permanent.';

  @override
  String get deleteMyAccount => 'Slet min konto';

  @override
  String get deletingAccount => 'Sletning...';

  @override
  String get deleteAccountConfirmTitle => 'Slet konto';

  @override
  String get deleteAccountConfirmMessage =>
      'Er du helt sikker på, at du vil slette din konto? Denne handling er permanent og kan ikke gøres om.';

  @override
  String get dataWillBeDeleted => 'Følgende data slettes permanent:';

  @override
  String get deletedDataList =>
      '• Din profil og brugernavn\n• Alle dine bip og rapporter\n• Alle dine kommentarer\n• Enhedsregistreringsdata\n• Placering og præferencedata';

  @override
  String get deleteAccountPermanent => 'Slet permanent';

  @override
  String get accountDeletedSuccessfully => 'Konto slettet med succes';

  @override
  String get accountDeletionFailed => 'Kunne ikke slette konto';

  @override
  String get onboardingWelcomeTitle => 'Velkommen til UFOBeep';

  @override
  String get onboardingWelcomeBody =>
      'Få realtidsadvarsler, når ufoer bliver set i nærheden. Gå aldrig glip af en observation igen.';

  @override
  String get onboardingAlertsTitle => 'Bliv informeret';

  @override
  String get onboardingAlertsBody =>
      'Angiv hvor langt væk observationer skal være for at udløse advarsler.';

  @override
  String get onboardingReportTitle => 'Kan du se noget? Bip den!';

  @override
  String get onboardingReportBody =>
      'Snap et billede eller video og dele med det samme med nærliggende tilskuere.';

  @override
  String get onboardingPermissionsTitle => 'Dit kamera & placering';

  @override
  String get onboardingPermissionsBody =>
      'Aktivér kamera, placering og meddelelser så du kan:\n- Rapportér observationer hurtigt\n- Få advarsler for ufoer nær dig';

  @override
  String get onboardingCameraTitle => 'Indfangningsbevis';

  @override
  String get onboardingCameraBody =>
      'Del billeder og videoer, du lige fanget fra dit galleri eller lang- tryk på UFOBeep ikonet for at starte i instant kamera tilstand.';

  @override
  String get onboardingCompassTitle => 'Se hvor de kiggede';

  @override
  String get onboardingCompassBody =>
      'Kompas viser dig den præcise retning vidnet kiggede, da de så UFO. Ret din telefon og se!';

  @override
  String get onboardingCommunityTitle => 'Deltag i Skywatchers';

  @override
  String get onboardingCommunityBody =>
      'Gennemse observationer, adgang MUFON rapporter, og oprette forbindelse med andre skywatchers.';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Start';

  @override
  String get viewOnboardingAgain => 'Vis Onboarding igen';

  @override
  String get customAlertRange => 'Brugerdefineret alarmområde';

  @override
  String get enterRangeKm => 'Indtast interval i km (1 - 99999)';

  @override
  String get largeRangeWarning =>
      'Store intervaller (> 100 km) kan generere mange indberetninger';

  @override
  String get globalRangeWarning =>
      'Meget store områder (> 1000 km) vil sende dig advarsler fra hele verden';

  @override
  String get invalidRange => 'Indtast et tal mellem 1 og 99999';

  @override
  String get celestialSunDaylight =>
      'Solen står op - dagslys kan påvirke sigtbarheden';

  @override
  String get celestialSunTwilight =>
      'Twilight betingelser - nogle synlighed, men mørkere end dagslys';

  @override
  String get celestialSunDark =>
      'Mørke forhold - optimal til observation af objekter i himlen';

  @override
  String celestialMoonBright(Object phase) {
    return 'Bright _ _ PLACEREPER _ 0 _ _ moon synlige - kan belyse eller skjule andre objekter';
  }

  @override
  String celestialMoonModerate(Object phase) {
    return '_ _ PLACEREPORT _ 0 _ _ månen synlig - moderate lysforhold';
  }

  @override
  String celestialMoonThin(Object phase) {
    return 'Tynd _ _ PLACEREPORT _ 0 _ _ moon synlig - minimal belysning';
  }

  @override
  String celestialMoonHidden(Object phase) {
    return '_ _ PLACEREPORT _ 0 _ _ månen under horisonten - ingen månebelysning';
  }

  @override
  String get celestialNoPlanets =>
      'Ingen lyse planeter synlige, der kunne forveksles med ufoer';

  @override
  String celestialPlanetHigh(Object altitude, Object planet) {
    return '_ _ PLACEREPORT _ 0 _ _ high overhead (_ _ PLACEREPORT _ 1 _ _ °) - meget fremtrædende';
  }

  @override
  String celestialPlanetMedium(Object altitude, Object planet) {
    return '_ _ PLACEREPORT _ 0 _ _ synlig på _ _ PLACEREPORT _ 1 _ _ ° - kunne forveksles med fly';
  }

  @override
  String celestialPlanetLow(Object altitude, Object planet) {
    return '_ _ PLACEREPORT _ 0 _ _ lav i horisonten (_ _ PLACEREPORT _ 1 _ _ °)';
  }

  @override
  String get celestialNoStars => 'Ingen usædvanligt lyse stjerner synlige';

  @override
  String celestialStarSingle(Object altitude, Object star) {
    return '_ _ PLACEREPORT _ 0 _ _ fremtrædende på _ _ PLACEREPORT _ 1 _ _ _ ° højde';
  }

  @override
  String celestialStarsMultiple(Object count, Object names) {
    return '_ _ PLACEREPORT _ 0 _ _ lyse stjerner synlige - _ _ PLACEREPORT _ 1 _ _';
  }

  @override
  String get celestialSummaryDaylight => 'Dagslys betingelser';

  @override
  String get celestialSummaryDark => 'Mørke himmelforhold';

  @override
  String get celestialSummaryMoonUp => 'månebelysning til stede';

  @override
  String get celestialSummaryMoonDown => 'ingen månebelysning';

  @override
  String celestialSummaryManyObjects(Object count) {
    return '_ _ PLACEREPORT _ 0 _ _ lyse objekter, der kan forveksles med UFO \'er';
  }

  @override
  String celestialSummarySomeObjects(Object count) {
    return '_ _ PLACEREPORT _ 0 _ _ bright objekt (er) synlige';
  }

  @override
  String get celestialSummaryFewObjects => 'minimal lyse objekter i himlen';

  @override
  String celestialSkySummary(Object conditions) {
    return 'Luftforhold: _ _ PLACEREPORT _ 0 _ _';
  }

  @override
  String get planetVenus => 'Venus';

  @override
  String get planetJupiter => 'Jupiter';

  @override
  String get planetSaturn => 'Saturn';

  @override
  String get planetMars => 'Mars';

  @override
  String get planetMercury => 'Kviksølv';

  @override
  String get planetUranus => 'Uranus Formand';

  @override
  String get planetNeptune => 'Neptun';

  @override
  String get starSirius => 'Sirius';

  @override
  String get starCanopus => 'Canopus';

  @override
  String get starArcturus => 'Arcturus';

  @override
  String get starVega => 'Vega';

  @override
  String get starCapella => 'Capella Formand';

  @override
  String get starRigel => 'Rigel';

  @override
  String get starProcyon => 'Procyon';

  @override
  String get starBetelgeuse => 'Betelgeuse';

  @override
  String get moonPhaseNew => 'Ny måne';

  @override
  String get moonPhaseWaxingCrescent => 'Voksende halvmåne';

  @override
  String get moonPhaseFirstQuarter => 'Første kvartal';

  @override
  String get moonPhaseWaxingGibbous => 'Waxing Gibbous';

  @override
  String get moonPhaseFull => 'Fuldmåne';

  @override
  String get moonPhaseWaningGibbous => 'Wening Gibbous';

  @override
  String get moonPhaseThirdQuarter => 'Tredje kvartal';

  @override
  String get moonPhaseWaningCrescent => 'Wening Crescent';

  @override
  String planetBelowHorizon(Object planet) {
    return '_ _ PLACEREPORT _ 0 _ _ under horisont';
  }

  @override
  String planetHighOverheadProminent(Object altitude, Object planet) {
    return '_ _ PLACEREPORT _ 0 _ _ high overhead (_ _ PLACEREPORT _ 1 _ _ °) - meget fremtrædende';
  }

  @override
  String planetMidSkyProminent(Object altitude, Object planet) {
    return '_ _ PLACEREPORT _ 0 _ _ at _ _ PLACEREPORT _ 1 _ _ ° - fremtrædende';
  }

  @override
  String planetMidSky(Object altitude, Object planet) {
    return '_ _ PLACEREPORT _ 0 _ _ at _ _ PLACEREPORT _ 1 _ _ °';
  }

  @override
  String starVeryBright(Object altitude, Object star) {
    return '_ _ PLACEREPORT _ 0 _ _ meget lys på _ _ PLACEREPORT _ 1 _ _ °';
  }

  @override
  String starProminent(Object altitude, Object star) {
    return '_ _ PLACEREPORT _ 0 _ _ fremtrædende på _ _ PLACEREPORT _ 1 _ _ _ ° højde';
  }

  @override
  String starVisible(Object altitude, Object star) {
    return '_ _ PLACEREPORT _ 0 _ _ at _ _ PLACEREPORT _ 1 _ _ °';
  }

  @override
  String get altitudeShort => 'Alt';

  @override
  String get magnitudeShort => 'Mag';

  @override
  String satellitesVisibleMightExplain(Object count) {
    return '_ _ PLACEREPER _ 0 _ _ satellitter synlige - kan forklare observation';
  }

  @override
  String satellitesVisibleUnlikelyExplain(Object count) {
    return '_ _ PLACEREPORT _ 0 _ _ satellitter synlige - usandsynligt at forklare observation';
  }

  @override
  String get noSatellitesVisible => 'Ingen satellitter synlige';

  @override
  String aircraftDetectedInRadius(Object count, Object radius) {
    return '_ _ PLACEREPORT _ 0 _ _ luftfartøjer opdaget inden _ _ PLACEREPORT _ 1 _ _ km';
  }

  @override
  String get processingAlert => 'Behandling af UFO alarm...';

  @override
  String get analyzingEnvironment => 'Analyse af miljøforhold';

  @override
  String get weatherAnalysis => 'Vejranalyse';

  @override
  String get locationAnalysis => 'Lokaliseringsanalyse';

  @override
  String get aircraftTracking => 'Flysporing';

  @override
  String get satelliteAnalysis => 'Satellitanalyse';

  @override
  String get celestialAnalysis => 'Himmelsk analyse';

  @override
  String analyzing(Object processor) {
    return 'Analyse _ _ PLACEREPORT _ 0 _ _...';
  }

  @override
  String get processorWeather => 'vejrforhold';

  @override
  String get processorLocation => 'lokaliseringsoplysninger';

  @override
  String get processorAircraft => 'flyvemaskiner i nærheden';

  @override
  String get processorSatellites => 'satellitposition';

  @override
  String get processorCelestial => 'himmelobjekter';

  @override
  String get calculatingCelestialData => 'Beregning af himmelsk data...';

  @override
  String get sunLabel => 'Sol';

  @override
  String get moonLabel => 'Måne';

  @override
  String planetsVisible(int count) {
    return 'Planeter: _ _ PLACEREPORT _ 0 _ _ visible';
  }

  @override
  String get starsLabel => 'Stjerner';

  @override
  String get planetsLabel => 'Planeter';

  @override
  String moonWithPhase(String phase) {
    return 'Måne (_ _ PLACEREPER _ 0 _ _)';
  }

  @override
  String get noSatellitesVisibleAtTime =>
      'Ingen satellitter var synlige på det nøjagtige tidspunkt for din observation';

  @override
  String get satellitesVisibleOverheadAtTime =>
      'Satellitter synlige overhead ved observation tid & placering';

  @override
  String get belowHorizon => 'under horisonten';

  @override
  String get analysisFailedGeneric => 'Analyse mislykkedes';

  @override
  String get unknownWeather => 'Ukendt';

  @override
  String get noWeatherDescription => 'Ingen beskrivelse';

  @override
  String get altitudeAbbrev => 'Alt';

  @override
  String get azimuthAbbrev => 'Az';

  @override
  String satellitesVisibleNow(int count) {
    return 'Satellitter (_ _ PLACEREPER _ 0 _ _ synlige nu)';
  }

  @override
  String sunWithDescription(String description) {
    return 'Sun: _ _ PLACEREPER _ 0 _ _';
  }

  @override
  String moonWithDescription(String description) {
    return 'Måne: _ _ PLACEREPORT _ 0 _ _';
  }

  @override
  String get unknownPlanet => 'Ukendt planet';

  @override
  String get unknownStar => 'Ukendt stjerne';

  @override
  String get unknownSatellite => 'Ukendt satellit';

  @override
  String get unknownDirection => 'ukendt retning';

  @override
  String get brightStars => 'Lyse stjerner';

  @override
  String get satellites => 'Satellitter';

  @override
  String seeAllSatellites(int count) {
    return 'Se alle _ _ PLACEREPORT _ 0 _ _ satellitter';
  }

  @override
  String maxElevation(String degrees) {
    return 'Maks. højde: _ _ PLACEREPORT _ 0 _ _ °';
  }

  @override
  String magnitude(String value) {
    return 'Størrelse: _ _ PLACEREPORT _ 0 _ _';
  }

  @override
  String get unknownGeneric => 'Ukendt';

  @override
  String altitudeValue(String degrees) {
    return '_ _ PLACEREPORT _ 0 _ _ _ ° højde';
  }

  @override
  String azimuthValue(String degrees) {
    return '_ _ PLACEREPORT _ 0 _ _ _ ° azimuth';
  }

  @override
  String get noCelestialDataAvailable => 'Der foreligger ingen himmelsk data.';

  @override
  String get gettingLocation => 'Få din placering...';

  @override
  String get media => 'Medier';

  @override
  String get locationRequired => 'Sted påkrævet';

  @override
  String get confirmingWitness => 'Bekræftende vidne...';

  @override
  String get chooseYourUsername => 'Vælg dit brugernavn';

  @override
  String get moreNames => 'Flere navne';

  @override
  String get notificationSettings => 'Meddelelsesindstillinger';

  @override
  String get quickActions => 'Hurtige handlinger';

  @override
  String get doNotDisturb => 'Må ikke forstyrres';

  @override
  String get temporarilySilenceNotifications =>
      'Midlertidigt stille alle meddelelser';

  @override
  String get oneHour => '1h';

  @override
  String get eightHours => '8h';

  @override
  String get oneDay => '1 dag';

  @override
  String get startTime => 'Starttidspunkt';

  @override
  String get endTime => 'Sluttidspunkt';

  @override
  String get allowCriticalAlertsDuringQuietHours =>
      'Tillad kritiske advarsler i stille timer';

  @override
  String get silenceNotificationsDuringSleepHours =>
      'Tavshedsanmeldelser under søvntid';

  @override
  String quietHoursActiveTimeRange(String startTime, String endTime) {
    return 'Aktiv _ _ PLACEREPORT _ 0 _ - _ _ PLACEREPORT _ 1 _ _';
  }

  @override
  String get followingAlerts => 'Følgende indberetninger';

  @override
  String activeCount(int count) {
    return '_ _ PLACEREPORT _ 0 _ _ active';
  }

  @override
  String get unfollow => 'Afføl';

  @override
  String get unfollowAlert => 'Afføl alarm';

  @override
  String commentsCount(int count) {
    return '_ _ PLACEREPER _ 0 _ _ kommentarer';
  }

  @override
  String get photo => 'Foto';

  @override
  String get video => 'Video';

  @override
  String get initializationComplete => 'Initialisering fuldført!';

  @override
  String get validatingEnvironment => 'Validerende miljø...';

  @override
  String get requestingPermissions => 'Anmoder om tilladelse...';

  @override
  String get loadingAuthSession => 'Indlæser auth session...';

  @override
  String get checkingUserRegistration => 'Kontrol af brugerregistrering...';

  @override
  String get loadingPreferences => 'Indlæser præferencer...';

  @override
  String get settingUpLocalization => 'Opsætning af lokalisering...';

  @override
  String get checkingConnectivity => 'Tjek forbindelse...';

  @override
  String get gatheringDeviceInfo => 'Indsamling af enhedsinformation...';

  @override
  String get translating => 'Translating...';

  @override
  String get showOriginal => 'Show Original';

  @override
  String translateTo(String language) {
    return 'Translate to $language';
  }

  @override
  String translatedFrom(String language) {
    return 'Translated from $language';
  }

  @override
  String get weatherClear => 'Ryd';

  @override
  String get weatherClearSky => 'klar himmel';

  @override
  String get rain => 'Regn';

  @override
  String get snow => 'Sne';

  @override
  String get thunderstorm => 'Tordenvejr';

  @override
  String get drizzle => 'Støvregn';

  @override
  String get fog => 'Tåge';

  @override
  String get fewClouds => 'få skyer';

  @override
  String get scatteredClouds => 'spredte skyer';

  @override
  String get brokenClouds => 'bristede skyer';

  @override
  String get overcastClouds => 'overskyet skyer';

  @override
  String get lightRain => 'let regn';

  @override
  String get moderateRain => 'moderat regn';

  @override
  String get heavyRain => 'kraftig regn';

  @override
  String aircraftDetectedCurrentPositions(int count, String radius) {
    return '_ _ PLACEREPORT _ 0 _ _ luftfartøj opdaget inden _ _ PLACEREPORT _ 1 _ _ km (nuværende positioner)';
  }

  @override
  String dimSatellitesUnlikely(int count) {
    return '_ _ PLACEREPER _ 0 _ _ dim satellitter synlige - usandsynligt at forklare observation';
  }

  @override
  String get mufonReportingDate => 'MUFON Rapporteringsdato';

  @override
  String satelliteNameDirection(String name, String direction) {
    return '_ _ PLACEREPORT _ 0 _ - _ _ PLACEREPORT _ 1 _ _';
  }
}
