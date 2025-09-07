// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian (`no`).
class AppLocalizationsNo extends AppLocalizations {
  AppLocalizationsNo([String locale = 'no']) : super(locale);

  @override
  String get appName => 'UFOBeep';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Avbryt';

  @override
  String get close => 'Lukk';

  @override
  String get save => 'Lagre';

  @override
  String get delete => 'Slett';

  @override
  String get edit => 'Rediger';

  @override
  String get retry => 'Prøv på nytt';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nei';

  @override
  String get back => 'Tilbake';

  @override
  String get next => 'Neste';

  @override
  String get done => 'Ferdig';

  @override
  String get loading => 'Laster inn..';

  @override
  String get processing => 'Behandler..';

  @override
  String get errorGeneric => 'Noe gikk galt.';

  @override
  String get networkError => 'Nettverksfeil. Sjekk tilkoblingen.';

  @override
  String get permissionsRequired => 'Tillatelser som kreves';

  @override
  String get learnMore => 'Les mer';

  @override
  String get welcomeTitle => 'Velkommen til UFOBeep';

  @override
  String get welcomeSubtitle => 'UFO-varsler i sanntid i nærheten av deg';

  @override
  String get signIn => 'Logg inn';

  @override
  String get signOut => 'Logg ut';

  @override
  String get continueAsGuest => 'Fortsett som gjest';

  @override
  String get enterUsername => 'Skriv inn et brukernavn';

  @override
  String get username => 'Brukernavn';

  @override
  String get usernameUpdated => 'Brukernavn oppdatert';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Innstillinger';

  @override
  String get tabAlerts => 'Varsler';

  @override
  String get tabBeep => 'Pip';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabMap => 'Kart';

  @override
  String get tabSettings => 'Innstillinger';

  @override
  String get alertsTitle => 'Nærliggende varslinger';

  @override
  String get noAlerts => 'Ingen varsler i nærheten ennå.';

  @override
  String get pullToRefresh => 'Dra for å oppdatere';

  @override
  String alertDistance(String distance) {
    return '${distance}____ away';
  }

  @override
  String alertDirection(int bearing) {
    return 'Belegg $bearing°';
  }

  @override
  String get viewAlert => 'Vis varsling';

  @override
  String get viewOnMap => 'Vis på kart';

  @override
  String get iSeeItToo => 'Jeg ser det også';

  @override
  String get confirmWitnessed => 'Bekreft at du bevitnet dette synet?';

  @override
  String get witnessConfirmed => 'Takk — din bekreftelse ble lagt ut.';

  @override
  String get createBeepTitle => 'Send et pip';

  @override
  String get beepExplain => 'Ta det du ser og varsle i nærheten.';

  @override
  String get capturePhoto => 'Opptaksfoto';

  @override
  String get captureVideo => 'Opptaksvideo';

  @override
  String get pickFromGallery => 'Velg fra galleri';

  @override
  String get descriptionHint => 'Beskriv hva du ser på himmelen..';

  @override
  String get submitBeep => 'Send pip';

  @override
  String get beepSent => 'Pip sendt';

  @override
  String get uploadingMedia => 'Laster opp medier..';

  @override
  String get includeLocation => 'Inkluder plassering';

  @override
  String get includeTimestamp => 'Inkluder tidsstempel';

  @override
  String get beepFailed => 'Klarte ikke å sende pip.';

  @override
  String get mediaProcessing => 'Behandler medier..';

  @override
  String get cameraPermissionTitle => 'Kameratilgang nødvendig';

  @override
  String get cameraPermissionBody =>
      'Tilgang til kamera til å fange UFO bilder og videoer.';

  @override
  String get locationPermissionTitle => 'Beliggenhet nødvendig';

  @override
  String get locationPermissionBody =>
      'Vi bruker din beliggenhet til å sende og motta nærliggende varsler.';

  @override
  String get microphonePermissionTitle => 'Mikrofon tilgang nødvendig';

  @override
  String get microphonePermissionBody =>
      'Gi mikrofon tilgang til videoopptak med lyd.';

  @override
  String get openSettings => 'Åpne innstillinger';

  @override
  String get alertDetailTitle => 'Se detaljer';

  @override
  String reportedBy(String username) {
    return 'Rapportert av ${username}_';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Rapportert ${timeAgo}_';
  }

  @override
  String distanceAway(String distance) {
    return '${distance}____ away';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Legg til objekt: $bearing°';
  }

  @override
  String get openCompass => 'Åpen kompass';

  @override
  String get openAR => 'Åpne AR overlegg';

  @override
  String get openChat => 'Åpne chat';

  @override
  String get commentsTitle => 'Kommentarer';

  @override
  String get addComment => 'Legg til en kommentar..';

  @override
  String get send => 'Send';

  @override
  String get commentPosted => 'Kommentar lagt ut';

  @override
  String get autoFollowEnabled => 'Nå følger du denne advarselen.';

  @override
  String get noCommentsYet => 'Ingen kommentarer ennå. Bli den første!';

  @override
  String get newCommentNotification => 'Ny kommentar til en seing du følger.';

  @override
  String get mapTitle => 'Live Map';

  @override
  String get compassTitle => 'Kompass';

  @override
  String get compassSettings => 'Kompassinnstillinger';

  @override
  String get compassMode => 'Kompassmodus';

  @override
  String get compassStandardMode => 'Standardmodus';

  @override
  String get compassPilotMode => 'Pilotmodus';

  @override
  String get compassStandardDescription =>
      'Grunnleggende overskrift og navigasjon';

  @override
  String get compassPilotDescription =>
      'Avansert navigering med ETA og vektorering';

  @override
  String pointingTo(String direction) {
    return 'Viser til ${direction}_';
  }

  @override
  String get calibratingCompass => 'Kalibrerende kompass..';

  @override
  String get openAROverlay => 'Åpne AR overlegg';

  @override
  String get pushTitleAlertNearby => 'UFO-varsel nær deg';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'En ny observasjon ble rapportert ${distance}_______________________________________________________________.';
  }

  @override
  String get pushTitleComment => 'Ny kommentar';

  @override
  String get pushBodyComment => 'Noen kommenterte en observasjon du følger.';

  @override
  String get pushTitleWitness => 'Vitnebekreftelse';

  @override
  String get pushBodyWitness =>
      'En bruker bekrefter at de ser det samme objektet.';

  @override
  String get weather => 'Vær';

  @override
  String cloudCover(int percent) {
    return 'Skydekke: ${percent}_%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Vind: ${speed}_$unit';
  }

  @override
  String get nearbyAircraft => 'Nærliggende fly';

  @override
  String get noAircraft => 'Ingen fly i nærheten';

  @override
  String get loadingContext => 'Laster inn miljøkontekst..';

  @override
  String get settingsTitle => 'Innstillinger';

  @override
  String get notifications => 'Varsler';

  @override
  String get enablePushNotifications =>
      'Få meldinger for fremtidige kommentarer';

  @override
  String get quietHours => 'Stille timer';

  @override
  String get quietHoursDesc => 'Stille varsler mellom utvalgte timer.';

  @override
  String get dndMode => 'Ikke forstyrr';

  @override
  String get dndUntil => 'Ikke forstyrre før';

  @override
  String get language => 'Språk';

  @override
  String get chooseLanguage => 'Velg språk';

  @override
  String get units => 'Enheter';

  @override
  String get unitsImperial => 'Imperial (mi, mph)';

  @override
  String get unitsMetric => 'Metrisk (km, km/t)';

  @override
  String get privacyPolicy => 'Personvernerklæring';

  @override
  String get termsOfUse => 'Vilkår for bruk';

  @override
  String get errorNoLocation =>
      'Sted ikke tilgjengelig. Prøv igjen utenfor med klar himmelutsikt.';

  @override
  String get errorNoCamera => 'Kamera tilgjengelig på denne enheten.';

  @override
  String get errorUploadFailed => 'Opplasting mislyktes. Prøv igjen.';

  @override
  String get errorPermissionDenied => 'Tilgang nektet.';

  @override
  String get errorInvalidUsername => 'Dette brukernavnet er ikke tilgjengelig.';

  @override
  String get nothingToShow => 'Ingenting å vise ennå.';

  @override
  String get storeShortDesc =>
      'UFO varsler nær deg. Fange, bekrefte og chat i sanntid.';

  @override
  String get storeLongDesc =>
      'UFOBeep sender varsler i sanntid når noen oppdager en UFO i nærheten. Ta bilder og videoer, bekrefte severdigheter med trykk, se retning og avstand og chat med andre skywatchere.';

  @override
  String get keywords =>
      'UFO,UAP,OVNI,aliens, severdigheter, skywatch,alerter, radar,compass';

  @override
  String get noAlertsFound => 'Ingen matchende varsler';

  @override
  String get alertsFilterHelp =>
      'Prøv å justere filtrene dine for å se flere resultater';

  @override
  String get verified => 'Bekreftet';

  @override
  String get beepOnly => 'bare bip';

  @override
  String get videoOnly => 'kun video';

  @override
  String get imageOnly => 'bare bilde';

  @override
  String get timeJustNow => 'Akkurat nå';

  @override
  String timeDaysAgo(int count) {
    return '_PH_0_d siden';
  }

  @override
  String timeHoursAgo(int count) {
    return '__PH_0_h ago';
  }

  @override
  String timeMinutesAgo(int count) {
    return '_PH_0_m ago';
  }

  @override
  String get loadMoreAlerts => 'Last inn flere varsler';

  @override
  String get toggleMufonTooltip => 'Bytt MUFON-syn';

  @override
  String get showMufonData => 'Vis MUFON-data';

  @override
  String get hideMufonData => 'Skjul MUFON-data';

  @override
  String get showingUfoBeepOnly => 'Viser kun UFOBeep-rapporter';

  @override
  String get showingAllReports =>
      'Viser alle rapporter inkludert MUFON-databasen';

  @override
  String get filteredSuffix => 'filtrert';

  @override
  String get detailsTitle => 'Detaljer';

  @override
  String get mufonCase => 'MUFON Case';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Case #$caseNumber detaljer';
  }

  @override
  String get sightingDate => 'Sighting Dato';

  @override
  String get mufonDatabaseEntryDate => 'Datoen gikk inn i MUFON Database';

  @override
  String get databaseEntry => 'Databaseoppføring';

  @override
  String get shareLink => 'Share Link';

  @override
  String get linkCopied => 'Koble til utklippstavle';

  @override
  String get locationLabel => 'Beliggenhet';

  @override
  String get distanceLabel => 'Avstand';

  @override
  String get timeLabel => 'Tid';

  @override
  String get reportedByLabel => 'Rapportert av';

  @override
  String get unknownLocation => 'Ukjend plassering';

  @override
  String get locationUnknown => 'Plassering ukjent';

  @override
  String get witnessesLabel => 'Vitner';

  @override
  String witnessesCountMessage(int count) {
    return '${count}_-folk bekreftet denne observasjonen';
  }

  @override
  String get photoAnalysisTitle => 'Fotoanalyse';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analyse: $count mediefil(er) behandlet';
  }

  @override
  String get addMoreMedia => 'Legg til mer';

  @override
  String get addMedia => 'Legg til medier';

  @override
  String get retakePhoto => 'Retake Photo';

  @override
  String get retakeVideo => 'Retake Video';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galleri';

  @override
  String get basicSettings => 'Basisinnstillinger';

  @override
  String get appSettings => 'Appinnstillinger';

  @override
  String get alertRange => 'Varselområde';

  @override
  String get manageNotificationsDesc =>
      'Administrer abonnementer og innstillinger';

  @override
  String get permissionsTitle => 'Tillatelser';

  @override
  String get permissionLocation => 'Beliggenhet';

  @override
  String get permissionCamera => 'Kamera';

  @override
  String get permissionNotifications => 'Varsler';

  @override
  String get permissionPhotos => 'Bilder';

  @override
  String get permissionGranted => 'Forutsetning';

  @override
  String get permissionNotGranted => 'Ikke gitt';

  @override
  String get permissionGrant => 'Grant';

  @override
  String get generateUsername => 'Opprett nytt brukernavn';

  @override
  String get adminTools => 'Admin verktøy';

  @override
  String get openAdminPanel => 'Åpne Admin-panelet';

  @override
  String get webAdminInterface => 'Web Admin-grensesnitt';

  @override
  String get adminBetaNotice =>
      'Beta bygger bare. Administrasjonsverktøy for å teste nærhetsvarsler, pressevarsler og systemdiagnostikk.';

  @override
  String get whatDoYouSee => 'Hva ser du?';

  @override
  String get ufoSighting => 'UFO Sighting';

  @override
  String get envAnalysisTitle => 'Miljøanalyse';

  @override
  String get envAnalysisPending => 'Analyse avventer';

  @override
  String get envAnalysisPendingDesc =>
      'Miljødata vil være tilgjengelige når behandlingen starter.';

  @override
  String get unknownAircraft => 'Ukjent fly';

  @override
  String get moreAircraft => 'mer fly';

  @override
  String get premiumImageryTitle => 'Premium Satellitt Imagery';

  @override
  String get premiumImagerySubtitle => 'Høyoppløselige kommersielle bilder';

  @override
  String get sightingTypeLabel => 'Type';

  @override
  String get ufoTypeSphere => 'Skulen';

  @override
  String get ufoTypeTriangle => 'Trekant';

  @override
  String get ufoTypeDisk => 'Disk';

  @override
  String get ufoTypeLight => 'Lys';

  @override
  String get ufoTypeFireball => 'Fireball';

  @override
  String get ufoTypeCylinder => 'Sylinder';

  @override
  String get ufoTypeCigar => 'Cigar';

  @override
  String get ufoTypeRectangle => 'Rektangel';

  @override
  String get ufoTypeFormation => 'Formasjon';

  @override
  String get ufoTypeUnknown => 'Ukjend';

  @override
  String get ufoTypeBoomerang => 'Boomerang';

  @override
  String get ufoTypeDiamond => 'Diamant';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Cone';

  @override
  String get ufoTypeCross => 'Kors';

  @override
  String get ufoTypeDumbbell => 'Dumbbell';

  @override
  String get ufoTypeTeardrop => 'Teardrop';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Bullet';

  @override
  String get ufoTypeSaturn => 'Saturn';

  @override
  String get ufoTypeStarLike => 'Stjernelignende';

  @override
  String get ufoTypeBlimp => 'Blimp';

  @override
  String get actionsTitle => 'Handlinger';

  @override
  String get addPhotosAndVideos => 'Legg til bilder og videoer';

  @override
  String get howToReportToMufon => 'Hvordan rapportere til MUFON';

  @override
  String get reportToMufon => 'Rapporter til MUFON';

  @override
  String get whyReportToMufon => 'Hvorfor rapportere til MUFON?';

  @override
  String get openMufonReport => 'Åpne MUFON Rapport';

  @override
  String get confirmedWitness => 'Du bekreftet dette synet';

  @override
  String witnessesHaveConfirmed(int count) {
    return '${count}_ personer har bekreftet denne observasjonen';
  }

  @override
  String get aircraftTrackingTitle => 'Flysporing';

  @override
  String get weatherConditionsTitle => 'Værforhold';

  @override
  String get noSatellitePasses => 'Ingen synlige satellittpass funnet';

  @override
  String get contentAnalysisTitle => 'Innholdsanalyse';

  @override
  String get contentSafe => 'Innhold er trygt';

  @override
  String get contentFlagged => 'Innhold flagget for gjennomgang';

  @override
  String get confidenceLabel => 'Tillit';

  @override
  String get methodLabel => 'Metode';

  @override
  String get premiumImageryAccessOnly =>
      'Premium satellittbilder er kun tilgjengelig for:';

  @override
  String get premiumAccessCreators => 'Varselskapere';

  @override
  String get premiumAccessWitnesses =>
      'Bekreftede vitner innen synlighetsområdet';

  @override
  String get comingSoon => 'Kommer snart';
}
