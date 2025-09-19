// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'UFOBEEP';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuleren';

  @override
  String get close => 'Sluiten';

  @override
  String get save => 'Opslaan';

  @override
  String get delete => 'Verwijderen';

  @override
  String get edit => 'Bewerken';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nee';

  @override
  String get back => 'Terug';

  @override
  String get next => 'Volgende';

  @override
  String get done => 'Klaar';

  @override
  String get loading => 'Laden..';

  @override
  String get processing => 'Verwerken..';

  @override
  String get errorGeneric => 'Er ging iets mis.';

  @override
  String get networkError => 'Netwerkfout. Controleer je verbinding.';

  @override
  String get permissionsRequired => 'Toestemmingen vereist';

  @override
  String get learnMore => 'Meer informatie';

  @override
  String get welcomeTitle => 'Welkom bij UFObeep';

  @override
  String get welcomeSubtitle => 'Real-time UFO waarschuwingen in uw buurt';

  @override
  String get signIn => 'Aanmelden';

  @override
  String get signOut => 'Afmelden';

  @override
  String get continueAsGuest => 'Doorgaan als gast';

  @override
  String get enterUsername => 'Gebruikersnaam invoeren';

  @override
  String get username => 'Gebruikersnaam';

  @override
  String get usernameUpdated => 'Gebruikersnaam bijgewerkt';

  @override
  String get profile => 'Profiel';

  @override
  String get settings => 'Instellingen';

  @override
  String get tabAlerts => 'Waarschuwingen';

  @override
  String get tabBeep => 'Piep';

  @override
  String get tabChat => 'Gesprek';

  @override
  String get tabMap => 'Kaart';

  @override
  String get tabSettings => 'Instellingen';

  @override
  String get alertsTitle => 'Waarschuwingen nabijgelegen';

  @override
  String get noAlerts => 'Nog geen waarschuwingen in de buurt.';

  @override
  String get pullToRefresh => 'Trek om te vernieuwen';

  @override
  String alertDistance(String distance) {
    return '${distance}_ weg';
  }

  @override
  String alertDirection(int bearing) {
    return '__PLAATSHOLDER_0__°';
  }

  @override
  String get viewAlert => 'Alert weergeven';

  @override
  String get viewOnMap => 'Bekijk op kaart';

  @override
  String get iSeeItToo => 'Ik zie het ook';

  @override
  String get confirmWitnessed =>
      'Bevestigd dat je getuige was van deze waarneming?';

  @override
  String get witnessConfirmed => 'Bedankt, uw bevestiging is geplaatst.';

  @override
  String get createBeepTitle => 'Stuur een pieper';

  @override
  String get beepExplain =>
      'Neem wat je ziet en waarschuw de bewakers in de buurt.';

  @override
  String get capturePhoto => 'Foto vastleggen';

  @override
  String get captureVideo => 'Video vastleggen';

  @override
  String get pickFromGallery => 'Kies uit galerij';

  @override
  String get descriptionHint => 'Beschrijf wat je ziet in de lucht..';

  @override
  String get submitBeep => 'Beep sturen';

  @override
  String get beepSent => 'Piep verzonden';

  @override
  String beepSentWithUrl(String shortUrl) {
    return 'Beep succesvol verzonden';
  }

  @override
  String get uploadingMedia => 'Media uploaden..';

  @override
  String get includeLocation => 'Plaats';

  @override
  String get includeTimestamp => 'Tijdstempel invoegen';

  @override
  String get beepFailed => 'Kon Beep niet sturen.';

  @override
  String get mediaProcessing => 'Media verwerken..';

  @override
  String get cameraPermissionTitle => 'Cameratoegang nodig';

  @override
  String get cameraPermissionBody =>
      'Grant camera toegang tot UFO foto\'s en video\'s vastleggen.';

  @override
  String get locationPermissionTitle => 'Toegang tot de locatie vereist';

  @override
  String get locationPermissionBody =>
      'Wij gebruiken uw locatie om waarschuwingen in de buurt te versturen en te ontvangen.';

  @override
  String get microphonePermissionTitle => 'Microfoontoegang nodig';

  @override
  String get microphonePermissionBody =>
      'Geef microfoon toegang voor video-opname met audio.';

  @override
  String get openSettings => 'Instellingen openen';

  @override
  String get alertDetailTitle => 'Waarnemingsdetails';

  @override
  String reportedBy(String username) {
    return 'Gerapporteerd door $username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Gerapporteerd __PLAATSHOLDER_0__';
  }

  @override
  String distanceAway(String distance) {
    return 'weg';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Richting naar object: __PLAATSHOLDER_0__°';
  }

  @override
  String get openCompass => 'Open kompas';

  @override
  String get openAR => 'Open AR-overlay';

  @override
  String get openChat => 'Gesprek openen';

  @override
  String get commentsTitle => 'Opmerkingen';

  @override
  String get addComment => 'Een commentaar toevoegen..';

  @override
  String get send => 'Verzenden';

  @override
  String get commentPosted => 'Commentaar geplaatst';

  @override
  String get autoFollowEnabled => 'Je volgt nu dit alarm.';

  @override
  String get noCommentsYet =>
      'Nog geen commentaar. Wees de eerste om te reageren!';

  @override
  String get newCommentNotification =>
      'Nieuw commentaar op een waarneming die je volgt.';

  @override
  String get mapTitle => 'Live map';

  @override
  String get compassTitle => 'Kompas';

  @override
  String get compassSettings => 'Compass-instellingen';

  @override
  String get compassMode => 'Kompasmodus';

  @override
  String get compassStandardMode => 'Standaardmodus';

  @override
  String get compassPilotMode => 'Pilootmodus';

  @override
  String get compassStandardDescription => 'Basisrichting en navigatie';

  @override
  String get compassPilotDescription =>
      'Geavanceerde navigatie met ETA en vectoring';

  @override
  String pointingTo(String direction) {
    return '$direction';
  }

  @override
  String get calibratingCompass => 'Kalibreren kompas..';

  @override
  String get openAROverlay => 'Open AR-overlay';

  @override
  String get pushTitleAlertNearby => 'UFO-alarm nabij u';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Er werd een nieuwe waarneming gemeld.';
  }

  @override
  String get pushTitleComment => 'Nieuwe opmerking';

  @override
  String get pushBodyComment =>
      'Iemand zei iets over een waarneming die je volgt.';

  @override
  String get pushTitleWitness => 'Getuigenbevestiging';

  @override
  String get temperature => 'Temperatuur';

  @override
  String get pushBodyWitness =>
      'Een gebruiker bevestigde dat ze hetzelfde object zien.';

  @override
  String get weather => 'Weer';

  @override
  String cloudCover(int percent) {
    return 'Cloud cover: __PLAATSHOLDER_0___%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Wind: __PLAATSHOLDER_0__ __PLAATSHOLDER_1__';
  }

  @override
  String get nearbyAircraft => 'Luchtvaartuigen in de buurt';

  @override
  String get noAircraft => 'Geen vliegtuig in de buurt';

  @override
  String get loadingContext => 'Milieucontext wordt geladen..';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get notifications => 'Kennisgevingen';

  @override
  String get enablePushNotifications =>
      'Notificaties opvragen voor toekomstige reacties';

  @override
  String get quietHours => 'Rustige uren';

  @override
  String get quietHoursDesc => 'Stiltemeldingen tussen geselecteerde uren.';

  @override
  String get quietHoursEnabled => 'Enable quiet hours';

  @override
  String get quietHoursFrom => 'From';

  @override
  String get quietHoursUntil => 'Until';

  @override
  String get quietHoursDefaultTime => 'Default quiet hours';

  @override
  String get emergencyOverride => 'Emergency override';

  @override
  String get emergencyOverrideDesc => 'Allow urgent alerts during quiet hours';

  @override
  String get dndMode => 'Niet storen';

  @override
  String get dndUntil => 'Niet storen tot';

  @override
  String dndEnabled(Object time) {
    return 'DND enabled until $time';
  }

  @override
  String get dndDisabled => 'DND disabled';

  @override
  String get quietHoursActive => 'Quiet hours active';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Quiet hours: $start - $end';
  }

  @override
  String get language => 'Taal';

  @override
  String get chooseLanguage => 'Taal kiezen';

  @override
  String get units => 'Eenheden';

  @override
  String get unitsImperial => 'Keizerlijk (mi, mph)';

  @override
  String get unitsMetric => 'Metrisch (km, km/h)';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get termsOfUse => 'Gebruiksvoorwaarden';

  @override
  String get errorNoLocation =>
      'Locatie is niet beschikbaar. Probeer het nog eens buiten met helder uitzicht op de hemel.';

  @override
  String get errorNoCamera => 'Camera niet beschikbaar op dit apparaat.';

  @override
  String get errorUploadFailed => 'Uploaden mislukt. Probeer het nog eens.';

  @override
  String get errorPermissionDenied => 'Toestemming geweigerd.';

  @override
  String get errorInvalidUsername => 'Die gebruikersnaam is niet beschikbaar.';

  @override
  String get nothingToShow => 'Nog niets te zien.';

  @override
  String get storeShortDesc =>
      'Instant UFO waarschuwingen in uw buurt. Vangen, bevestigen en praten in real time.';

  @override
  String get storeLongDesc =>
      'UFObeep stuurt real-time waarschuwingen als iemand een UFO in de buurt ziet. Foto\'s en video\'s vastleggen, waarnemingen bevestigen met een tik, richting en afstand bekijken en chatten met collega-skywatchers.';

  @override
  String get keywords =>
      'UFO,UAP,OVNI,aliens,sightings,skywatch,alerts,radar,compass';

  @override
  String get noAlertsFound => 'Geen overeenkomstige waarschuwingen';

  @override
  String get alertsFilterHelp =>
      'Probeer uw filters aan te passen om meer resultaten te zien';

  @override
  String get verified => 'Geverifieerd';

  @override
  String get beepOnly => 'Alleen piepen';

  @override
  String get reportOnly => 'Alleen tekst';

  @override
  String get videoOnly => 'Alleen video';

  @override
  String get imageOnly => 'Alleen afbeelding';

  @override
  String get mediaOnly => 'Alleen media';

  @override
  String get timeJustNow => 'net';

  @override
  String timeDaysAgo(int count) {
    return '__PLAATSHOLDER_0__ dagen geleden';
  }

  @override
  String timeHoursAgo(int count) {
    return '__PLAATSHOLDER_0___ uren geleden';
  }

  @override
  String timeMinutesAgo(int count) {
    return '__PLAATSHOLDER_0___ minuten geleden';
  }

  @override
  String get loadMoreAlerts => 'Meer waarschuwingen laden';

  @override
  String get toggleMufonTooltip => 'MUFON waarnemingen aan/uit';

  @override
  String get showMufonData => 'MUFON-gegevens tonen';

  @override
  String get hideMufonData => 'MUFON-gegevens verbergen';

  @override
  String get showingUfoBeepOnly => 'Alleen UFObeep-rapporten tonen';

  @override
  String get showingAllReports =>
      'Alle rapporten inclusief MUFON-database tonen';

  @override
  String get filteredSuffix => 'gefilterd';

  @override
  String get detailsTitle => 'Gegevens';

  @override
  String get mufonCase => 'MUFON Zaak';

  @override
  String get mufonSighting => 'MUFON-waarnemingsrapport';

  @override
  String get mufonLightSighting => 'MUFON Lichtzichtrapport';

  @override
  String get mufonSphereSighting => 'MUFON Sphere Sighting Report';

  @override
  String get mufonDiscSighting => 'MUFON Schijfzichtrapport';

  @override
  String get mufonTriangleSighting => 'MUFON Driehoekverslag';

  @override
  String get mufonCigarSighting => 'MUFON Cigar Sighting Report';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting Report';

  @override
  String get mufonRectangleSighting => 'MUFON Rechthoekig overzichtsrapport';

  @override
  String get mufonCylinderSighting => 'MUFON-cilinderzichtrapport';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Sighting Report';

  @override
  String get mufonStarlikeSighting => 'MUFON Starlike Sighting Report';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON-geval #__PLAATSHOLDER_0_ Details';
  }

  @override
  String get sightingDate => 'Datum van waarneming';

  @override
  String get mufonDatabaseEntryDate => 'Datum ingevoerd in MUFON Database';

  @override
  String get databaseEntry => 'Databaseinvoer';

  @override
  String get shareLink => 'Link delen';

  @override
  String get linkCopied => 'Koppeling naar klembord';

  @override
  String get locationLabel => 'Locatie:';

  @override
  String get distanceLabel => 'Afstand';

  @override
  String get timeLabel => 'Tijd:';

  @override
  String get reportedByLabel => 'Gerapporteerd door';

  @override
  String get unknownLocation => 'Onbekende locatie';

  @override
  String get locationUnknown => 'Locatie onbekend';

  @override
  String get witnessesLabel => 'Getuigen';

  @override
  String witnessesCountMessage(int count) {
    return 'De mensen hebben deze waarneming bevestigd';
  }

  @override
  String get photoAnalysisTitle => 'Fotoanalyse';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analyse: __PLAATSHOLDER_0__ mediabestand(s) verwerkt';
  }

  @override
  String get addMoreMedia => 'Meer toevoegen';

  @override
  String get addMedia => 'Media toevoegen';

  @override
  String get retakePhoto => 'Foto hernemen';

  @override
  String get retakeVideo => 'Video opnieuw opnemen';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Galerij';

  @override
  String get basicSettings => 'Basisinstellingen';

  @override
  String get appSettings => 'Appinstellingen';

  @override
  String get timeFormat => 'Tijdformaat';

  @override
  String get timeFormat24Hour => '24 uur (14:30)';

  @override
  String get timeFormat12Hour => '12 uur (2.30 uur)';

  @override
  String get timeFormatDesc => 'Weergavetijd in 24-uurs- of 12-uursformaat';

  @override
  String get alertRange => 'Waarschuwingsbereik';

  @override
  String get manageNotificationsDesc => 'Abonnementeninstellingen beheren';

  @override
  String get permissionsTitle => 'Rechten';

  @override
  String get permissionLocation => 'Locatie';

  @override
  String get permissionCamera => 'Camera';

  @override
  String get permissionNotifications => 'Kennisgevingen';

  @override
  String get permissionPhotos => 'Foto\'s';

  @override
  String get permissionGranted => 'Toegestaan';

  @override
  String get permissionNotGranted => 'Niet toegekend';

  @override
  String get permissionGrant => 'Subsidie';

  @override
  String get generateUsername => 'Nieuwe gebruikersnaam aanmaken';

  @override
  String get adminTools => 'Beheergereedschappen';

  @override
  String get openAdminPanel => 'Beheerpaneel openen';

  @override
  String get webAdminInterface => 'Webbeheerderinterface';

  @override
  String get adminBetaNotice =>
      'Beta bouwt alleen. Admin tools voor het testen van nabijheid waarschuwingen, push meldingen, en systeemdiagnostiek.';

  @override
  String get whatDoYouSee => 'Wat zie je?';

  @override
  String get ufo => 'UFO';

  @override
  String get sighting => 'Waarneming';

  @override
  String get ufoSighting => 'UFOPEEP UFO Waarschuwing';

  @override
  String get envAnalysisTitle => 'Milieuanalyse';

  @override
  String get envAnalysisPending => 'Analyse in afwachting';

  @override
  String get envAnalysisPendingDesc =>
      'Milieugegevens zullen beschikbaar zijn zodra de verwerking begint.';

  @override
  String get unknownAircraft => 'Onbekend vliegtuig';

  @override
  String get moreAircraft => 'meer vliegtuigen';

  @override
  String get premiumImageryTitle => 'Premium satelliet Afbeelding';

  @override
  String get premiumImagerySubtitle => 'Handelsbeelden met hoge resolutie';

  @override
  String get sightingTypeLabel => 'Type';

  @override
  String get ufoTypeSphere => 'Bol';

  @override
  String get ufoTypeTriangle => 'Driehoek';

  @override
  String get ufoTypeDisk => 'Schijf';

  @override
  String get ufoTypeLight => 'Licht';

  @override
  String get ufoTypeFireball => 'Vuurbal';

  @override
  String get ufoTypeCylinder => 'Cilinder';

  @override
  String get ufoTypeCigar => 'Sigaren';

  @override
  String get ufoTypeRectangle => 'Rechthoek';

  @override
  String get ufoTypeFormation => 'Vorming';

  @override
  String get ufoTypeUnknown => 'Onbekend';

  @override
  String get ufoTypeBoomerang => 'Boomerang';

  @override
  String get ufoTypeDiamond => 'Diamant';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Cone';

  @override
  String get ufoTypeCross => 'Kruis';

  @override
  String get ufoTypeDumbbell => 'Dumbbell';

  @override
  String get ufoTypeTeardrop => 'Teardrop';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Kogel';

  @override
  String get ufoTypeSaturn => 'Saturnus';

  @override
  String get ufoTypeStarLike => 'Sterrenachtig';

  @override
  String get ufoTypeBlimp => 'Blimp';

  @override
  String get shapeTriangle => 'driehoek';

  @override
  String get shapeDisc => 'schijf';

  @override
  String get shapeDisk => 'schijf';

  @override
  String get shapeSphere => 'bol';

  @override
  String get shapeCigar => 'sigaren';

  @override
  String get shapeLight => 'licht';

  @override
  String get shapeBoomerang => 'boemerang';

  @override
  String get shapeDiamond => 'diamant';

  @override
  String get shapeRectangle => 'rechthoek';

  @override
  String get shapeOval => 'ovaal';

  @override
  String get shapeCone => 'kegel';

  @override
  String get shapeCross => 'kruis';

  @override
  String get shapeCylinder => 'cilinder';

  @override
  String get shapeDumbbell => 'halter';

  @override
  String get shapeTeardrop => 'traanwortel';

  @override
  String get shapeTicTac => 'tic-tac';

  @override
  String get shapeBullet => 'kogel';

  @override
  String get shapeSaturn => 'saturnus';

  @override
  String get shapeStarlike => 'sterachtig';

  @override
  String get shapeBlimp => 'zeppelin';

  @override
  String get shapeFireball => 'vuurbal';

  @override
  String get shapeFormation => 'vorming';

  @override
  String get shapeUnknown => 'onbekend';

  @override
  String get actionsTitle => 'Acties';

  @override
  String get addPhotosAndVideos => 'Foto\'s en video\'s toevoegen';

  @override
  String get howToReportToMufon => 'Hoe rapporteren aan MUFON';

  @override
  String get reportToMufon => 'Verslag aan MUFON';

  @override
  String get whyReportToMufon => 'Waarom verslag uitbrengen aan MUFON?';

  @override
  String get openMufonReport => 'MUFON openen Verslag';

  @override
  String get confirmedWitness => 'Je hebt deze waarneming bevestigd';

  @override
  String witnessesHaveConfirmed(int count) {
    return 'Mensen hebben deze waarneming bevestigd';
  }

  @override
  String get aircraftTrackingTitle => 'Tracking van luchtvaartuigen';

  @override
  String get weatherConditionsTitle => 'Weersomstandigheden';

  @override
  String get noSatellitePasses => 'Geen zichtbare satellietpassen gevonden';

  @override
  String get contentAnalysisTitle => 'Inhoudsanalyse';

  @override
  String get contentSafe => 'Inhoud is veilig';

  @override
  String get contentFlagged => 'Inhoud gemarkeerd voor beoordeling';

  @override
  String get confidenceLabel => 'Vertrouwen';

  @override
  String get methodLabel => 'Methode';

  @override
  String get premiumImageryAccessOnly =>
      'Premium satellietbeelden zijn alleen beschikbaar voor:';

  @override
  String get premiumAccessCreators => 'Waarschuwingsmakers';

  @override
  String get premiumAccessWitnesses => 'Bevestigde getuigen binnen zichtbereik';

  @override
  String get comingSoon => 'Binnenkort';

  @override
  String get directionDistanceTitle => 'Richting en afstand';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Zaak #__PLAATSHOLDER_0__';
  }

  @override
  String get satellitePassesTitle => 'Satellietpassen';

  @override
  String get satellitePassExplanation =>
      'Zichtbare satelliet passeert tijdens de waarneming. Veel UFO rapporten zijn eigenlijk satellieten of ruimte puin.';

  @override
  String get followingAlert =>
      'Na waarschuwing - je krijgt commentaar meldingen';

  @override
  String get unfollowedAlert =>
      'Ongevolgd alarm - geen commentaarmeldingen meer';

  @override
  String get alertFollowError => 'Fout bij bijwerken van volgstatus';

  @override
  String get notificationChannelAlerts => 'UFOBEEP-waarschuwingen';

  @override
  String get notificationChannelAlertsDesc =>
      'Kennisgevingen voor UFO-pieps en nabijheidswaarschuwingen';

  @override
  String get notificationSightingTitle => 'UFOPEEP UFO Waarschuwing';

  @override
  String get notificationSightingUrgent => 'UFO UFO UFO Waarschuwing';

  @override
  String get notificationSightingEmergency => 'Ufobeep UFO Waarschuwing';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '__PLAATSHOLDER_0__ in de buurt __PLAATSHOLDER_1__';
  }

  @override
  String notificationCommentTitle(String username) {
    return '${username}commentaar';
  }

  @override
  String get notificationWitnessText => 'Nieuwe waarneming';

  @override
  String notificationWitnessTextMultiple(int count) {
    return 'Getuigen';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Ingetrokken';

  @override
  String notificationDistance(String distance) {
    return '${distance}_ weg';
  }

  @override
  String get unknown => 'onbekend';

  @override
  String get report => 'rapport';

  @override
  String get mufon => 'mufon';

  @override
  String get recentUfoBeepsTitle => 'Recente UFO Pieps';

  @override
  String get recentUfoBeepsSubtitle =>
      'Live UFO waarnemingen van onze wereldwijde gemeenschap';

  @override
  String get recentUfoBeepsDescription =>
      'Deze feed combineert real-time UFObeep \"pieps\" van onze mobiele app gebruikers met historische rapporten uit de MUFON database.';

  @override
  String get loadingBeeps => 'Laden van recente piepers...';

  @override
  String get noBeepsAvailable => 'Er zijn momenteel geen piepers beschikbaar.';

  @override
  String get anomalyReported => 'Anomalie gemeld';

  @override
  String get copyShortLink => 'Korte verwijzing kopiëren';

  @override
  String get shareAlert => 'Alert delen';

  @override
  String get ufoSightingAlert => 'UFO Waarnemingsalarm';

  @override
  String get previousPage => 'Vorige';

  @override
  String get nextPage => 'Volgende';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Pagina __PLAATSHOLDER_0__ van __PLAATSHOLDER_1__ (__PLAATSHOLDER_2__ totale piepers)';
  }

  @override
  String get firstPage => 'Eerste';

  @override
  String get lastPage => 'Laatste';

  @override
  String get jumpToPage => 'Naar pagina springen';

  @override
  String get heroTagline =>
      'Ontvang waarschuwingen wanneer naar buiten te gaan en op te zoeken';

  @override
  String get heroDescription =>
      'Mis nooit meer een UFO waarneming. Ontvang real-time waarschuwingen als iemand bij je in de buurt iets raars ziet in de lucht. Richt je telefoon en vind precies waar je moet zoeken.';

  @override
  String get downloadApp => 'Download App';

  @override
  String get viewAllBeeps => 'Bekijk alle piepers';

  @override
  String get sightingsMap => 'Kaart van de waarneming';

  @override
  String get globalSightingNetwork => 'Wereldwijd waarnemingsnetwerk';

  @override
  String get howItWorks => 'Hoe werkt UFObeep';

  @override
  String get backToBeeps => 'Terug naar Beeps';

  @override
  String get loadingDetails => 'Bezig met laden van piepgegevens...';

  @override
  String get details => 'Gegevens';

  @override
  String get location => 'Locatie';

  @override
  String get timeAgo => 'geleden';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'mijl';

  @override
  String get distanceNearby => 'dichtbij';

  @override
  String get ufobeepWitnesses => 'Getuigen';

  @override
  String get ufobeepConfirmations => 'Bevestigingen';

  @override
  String get ufobeepAlertLevel => 'Waarschuwingsniveau';

  @override
  String get ufobeepReportType => 'UFObeep-rapport';

  @override
  String get mufonAttribution => 'MUFON Databaserapport';

  @override
  String get mufonCaseNumber => 'Zaak #';

  @override
  String get mufonGenericTitle => 'MUFON-waarnemingsrapport';

  @override
  String get mufonSphere => 'Bol';

  @override
  String get mufonLight => 'Licht';

  @override
  String get mufonDisk => 'Schijf';

  @override
  String get mufonTriangle => 'Driehoek';

  @override
  String get mufonCigar => 'Sigaren';

  @override
  String get mufonOval => 'Oval';

  @override
  String get mufonCylinder => 'Cilinder';

  @override
  String get mufonRectangle => 'Rechthoek';

  @override
  String get mufonDiamond => 'Diamant';

  @override
  String get mufonFireball => 'Vuurbal';

  @override
  String get mufonFlash => 'Flits';

  @override
  String get mufonFormation => 'Vorming';

  @override
  String get mufonChanging => 'Veranderen';

  @override
  String get mufonChevron => 'Chevron';

  @override
  String get mufonCone => 'Cone';

  @override
  String get mufonCross => 'Kruis';

  @override
  String get mufonEgg => 'Eieren';

  @override
  String get mufonOther => 'Object';

  @override
  String get mufonUnknown => 'Onbekend object';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON __PLAATSHOLDER_0__ Verslag';
  }

  @override
  String get nuforcAttribution => 'NUFORC Databaserapport';

  @override
  String get nuforcCaseNumber => 'Zaak #';

  @override
  String get nuforcGenericTitle => 'NUFORC Waarnemingsrapport';

  @override
  String get mediaImageNotFound => 'Afbeelding niet gevonden';

  @override
  String get mediaPlayVideo => 'Video afspelen';

  @override
  String get mediaViewImage => 'Afbeelding bekijken';

  @override
  String mediaCount(Object count) {
    return '$count afbeeldingen';
  }

  @override
  String get mediaCountSingle => '1 afbeelding';

  @override
  String mediaMoreImages(Object count) {
    return 'Meer';
  }

  @override
  String get errorNotFound => 'Piep niet gevonden';

  @override
  String get errorLoadError => 'Kon piepgegevens niet laden';

  @override
  String get shareYourThoughts => 'Deel je gedachten over deze waarneming...';

  @override
  String get postComment => 'Postcommentaar';

  @override
  String get loggedInAs => 'Aangemeld als';

  @override
  String get logout => 'Afmelden';

  @override
  String get notFollowing => 'Niet volgen';

  @override
  String get follow => 'Volgen';

  @override
  String get navRecentBeeps => 'Recente piepers';

  @override
  String get navMap => 'Kaart';

  @override
  String get navDownloadApp => 'App downloaden';

  @override
  String get alertLevel => 'Waarschuwingsniveau';

  @override
  String get witnesses => 'Getuigen';

  @override
  String get confirmations => 'Bevestigingen';

  @override
  String get reporterLabel => 'Gerapporteerd door gebruiker';

  @override
  String get coordinatesLabel => 'Coördinaten';

  @override
  String get eventTime => 'Gebeurtenistijd';

  @override
  String get reportedTime => 'Gerapporteerde tijd';

  @override
  String get addedToUfobeep => 'Toegevoegd aan UFObeep';

  @override
  String get mufonDatabaseReport => 'MUFON Databaserapport';

  @override
  String get copyShortLinkTitle => 'Verwijzing naar klembord kopiëren';

  @override
  String get imageNotFound => 'Afbeelding niet gevonden';

  @override
  String get ufoSightingAlt => 'UFO Beep UFO alarm';

  @override
  String get celestialDataTitle => 'Hemelse objecten';

  @override
  String get visiblePlanets => 'Zichtbare planeten';

  @override
  String get locationDataTitle => 'Informatie over de locatie';

  @override
  String get timezone => 'Tijdzone';

  @override
  String get coordinates => 'Coördinaten';

  @override
  String get processingSummaryTitle => 'Samenvatting van de verwerking';

  @override
  String get processingTime => 'Verwerkingstijd';

  @override
  String get successful => 'Succesvol';

  @override
  String get failed => 'Mislukt';

  @override
  String get locationEnrichmentTitle => 'Locatiedetails';

  @override
  String get aircraftDataSource => 'Gegevensbron';

  @override
  String get noAircraftDetected => 'Geen vliegtuig gedetecteerd';

  @override
  String get sightingReport => 'Waarnemingsrapport';

  @override
  String get ufoAlert => 'UFO Waarschuwing';

  @override
  String get alert => 'Waarschuwing';

  @override
  String get notificationTickerUfoAlert =>
      'UFO Alert - Nieuwe Waarneming nabij';

  @override
  String get notificationTickerComment => 'Nieuwe reactie op UFO-alarm';

  @override
  String get weatherConditions => 'Weersomstandigheden';

  @override
  String get visibility => 'Zichtbaarheid';

  @override
  String get humidity => 'Vochtigheid';

  @override
  String get pressure => 'Druk';

  @override
  String get locationDetails => 'Locatiedetails';

  @override
  String get city => 'Stad';

  @override
  String get state => 'Staat';

  @override
  String get country => 'Land';

  @override
  String get satelliteActivity => 'Satellietactiviteit';

  @override
  String get satellitesVisibleOverhead =>
      'Satellieten zichtbaar overhead op waarnemingstijd en locatie';

  @override
  String get dataSource => 'Gegevensbron';

  @override
  String get blackskyImagery => 'BlackSky Imagery';

  @override
  String get resolution => 'Resolutie';

  @override
  String get groundResolution => '35cm grondresolutie';

  @override
  String get delivery => 'Levering';

  @override
  String get averageDelivery => 'gemiddeld 90 minuten';

  @override
  String get cost => 'Kosten';

  @override
  String get skyfiSatelliteImagery => 'SkyFi Satellite Afbeelding';

  @override
  String get region => 'Gebieden';

  @override
  String get remoteArea => 'Gebied op afstand';

  @override
  String get startingPrice => 'Startprijs';

  @override
  String get coverage => 'Dekking';

  @override
  String get confidenceCoverage => '95% betrouwbaarheid';

  @override
  String get status => 'Status';

  @override
  String get shareThoughts => 'Deel je gedachten over deze waarneming...';

  @override
  String get postCommand => 'Postopdracht';

  @override
  String get clouds => 'Wolken';

  @override
  String get windLabel => 'Wind';
}
