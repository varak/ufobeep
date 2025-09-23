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
  String get locationPermissionTitle => 'Locatie Toestemming vereist';

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
    return '__PLAATSHOLDER_0___';
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
  String get quietHoursEnabled => 'Rustige uren inschakelen';

  @override
  String get quietHoursFrom => 'Van';

  @override
  String get quietHoursUntil => 'Tot';

  @override
  String get quietHoursDefaultTime => 'Standaard rustige uren';

  @override
  String get emergencyOverride => 'Noodoverschrijving';

  @override
  String get emergencyOverrideDesc =>
      'Noodoproepen tijdens stille uren toestaan';

  @override
  String get dndMode => 'Niet storen';

  @override
  String get dndUntil => 'Niet storen tot';

  @override
  String dndEnabled(Object time) {
    return 'DND ingeschakeld tot $time';
  }

  @override
  String get dndDisabled => 'DND uitgeschakeld';

  @override
  String get quietHoursActive => 'Rustige uren actief';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Rustige uren: __PLAATSHOLDER_0__ - __PLAATSHOLDER_1__';
  }

  @override
  String get pushNotificationUfoAlert => 'UFO Waarschuwing';

  @override
  String get pushNotificationAnomalyAlert => 'Anomaly Alert';

  @override
  String get pushNotificationNearby => 'In de buurt';

  @override
  String get pushNotificationInYourArea =>
      'in uw gebied. Tik op details weergeven.';

  @override
  String pushNotificationCommented(Object username) {
    return '${username}commentaar';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '__PLAATSHOLDER_0__ commentaar op __PLAATSHOLDER_1__';
  }

  @override
  String get pushNotificationGeneric => 'UFOBEEP';

  @override
  String get pushNotificationNewSighting => 'Nieuwe waarnemingen in de buurt';

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
      'Mis nooit een andere UFO waarneming in uw gebied';

  @override
  String get downloadApp => 'Download App';

  @override
  String get viewAllBeeps => 'Bekijk alle piepers';

  @override
  String get sightingsMap => 'Kaart van de waarneming';

  @override
  String get globalSightingNetwork => 'Wereldwijd waarnemingsnetwerk';

  @override
  String get howItWorks => 'Hoe het werkt';

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
  String get mufonDatabaseReport => 'MUFON Zaaknummer:';

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

  @override
  String get filterAlerts => 'Filterwaarschuwingen';

  @override
  String get alertSource => 'Waarschuwingsbron';

  @override
  String get ufobeepOnly => 'UFObeep alleen';

  @override
  String get ufobeepOnlyDescription =>
      'Alleen originele UFObeep-rapporten tonen (exclusief MUFON-database)';

  @override
  String get alertDistanceRange => 'Waarschuwingsafstand';

  @override
  String get showAllAlerts => 'Alle waarschuwingen tonen';

  @override
  String get showAll => 'Alles tonen';

  @override
  String get distanceSliderDescription =>
      'Sleep om aan te passen hoe ver u alerts wilt zien. Begin vanaf de zichtafstand tot alle waarschuwingen, ongeacht de afstand.';

  @override
  String get applyFilters => 'Filters toepassen';

  @override
  String get notificationRange => 'Notificatiebereik';

  @override
  String get notificationRangeDescription =>
      'Krijg push waarschuwingen voor waarnemingen binnen deze afstand';

  @override
  String get viewingRange => 'Beeldbereik';

  @override
  String get viewingRangeDescription =>
      'Toon waarnemingen binnen deze afstand bij het surfen';

  @override
  String get weatherVisibility => 'Weerzicht (~10km)';

  @override
  String get localArea => 'Plaatselijk gebied (25 km)';

  @override
  String get regional => 'Regionaal';

  @override
  String get pushNotifications => 'Aanmeldingen pushen';

  @override
  String get alertBrowsing => 'Alert bladeren';

  @override
  String get pushAlertsWithinDistance =>
      'Notificatieberichten binnen dit bereik ophalen';

  @override
  String get showAlertsWhenBrowsing => 'Filter wat je ziet in de lijst';

  @override
  String get heroMainTagline =>
      'Haal een piep op je telefoon als UFO\'s in de buurt worden gezien';

  @override
  String get heroSecondaryTagline =>
      'Zoek uit wanneer en waar naar de hemel te kijken';

  @override
  String get sourceFilters => 'Bron';

  @override
  String get sourceFiltersDescription =>
      'Kies welke rapporten in uw feed verschijnen';

  @override
  String get ufobeepAndMufon => 'UFOBEEP + MUFON';

  @override
  String get ufobeepOnlySource => 'UFObeep alleen';

  @override
  String get mufonOnlySource => 'Uitsluitend MUFON';

  @override
  String get browseFilters => 'Bladeren';

  @override
  String get browseFiltersDescription =>
      'Hoe waarschuwingen te bekijken en te sorteren';

  @override
  String get sortByNewest => 'Nieuwste';

  @override
  String get sortByNearest => 'Dichtstbijzijnde';

  @override
  String get sortBy => 'Sorteren op';

  @override
  String get pushAlertsTitle => 'Waarschuwingen indrukken';

  @override
  String get pushAlertsDescription => 'Wat pings je telefoon';

  @override
  String get alertRadius => 'Waarschuw Straal';

  @override
  String get mufonNoPushInfo =>
      'MUFON rapporten worden \'s nachts geïmporteerd en niet push waarschuwingen veroorzaken';

  @override
  String get privacyData => 'Privacy & gegevens';

  @override
  String get privacyPolicyDesc => 'Hoe wij uw gegevens beschermen en gebruiken';

  @override
  String get termsOfService => 'Servicevoorwaarden';

  @override
  String get termsOfServiceDesc => 'Juridische voorwaarden';

  @override
  String get locationTracking => 'Locatie volgen';

  @override
  String get locationTrackingDesc =>
      'Achtergrondlocatie voor nabijheidswaarschuwingen';

  @override
  String get locationTrackingTitle => 'Achtergrondlocatie volgen';

  @override
  String get locationTrackingExplanation =>
      'UFObeep bewaakt uw locatie op de achtergrond om u nabijheid waarschuwingen te sturen wanneer UFO waarnemingen gebeuren in de buurt van uw huidige locatie, zelfs als je weg van huis.';

  @override
  String get locationTrackingBattery =>
      'Gebruikt intelligente geofencing voor <3% batterij impact';

  @override
  String get backgroundLocationTracking => 'Achtergrond inschakelen Tracking';

  @override
  String get locationTrackingActive =>
      'Waarnemingslocatie voor nabijheidswaarschuwingen';

  @override
  String get locationTrackingInactive => 'Locatie volgen is uitgeschakeld';

  @override
  String get locationTrackingDisabledWarning =>
      'U ontvangt geen nabijheidswaarschuwingen wanneer u naar nieuwe locaties verhuist';

  @override
  String get trackingStatus => 'Trackingstatus';

  @override
  String get monitoringStatus => 'Toezicht';

  @override
  String get active => 'Actief';

  @override
  String get inactive => 'Inactief';

  @override
  String get lastKnownLocation => 'Laatste bekende locatie';

  @override
  String get lastLocationUpdate => 'Laatste update';

  @override
  String get movementThreshold => 'Bewegingsdrempel';

  @override
  String get updateFrequency => 'Frequentie bijwerken';

  @override
  String get batteryImpact => 'Inslag van de batterij';

  @override
  String get dataPrivacy => 'Gegevensbescherming';

  @override
  String get locationPermissionExplanation =>
      'UFObeep heeft \'Always Allow\' location permissie nodig om uw beweging te monitoren en nabijheidswaarschuwingen te verzenden wanneer u op nieuwe locaties bent.';

  @override
  String get benefitsTitle => 'Voordelen';

  @override
  String get locationTrackingBenefits =>
      '• Ontvang UFO waarschuwingen overal waar u reist\n• Automatische locatie updates\n• Geen handmatige installatie vereist';

  @override
  String get allowLocationAccess => 'Locatietoegang toestaan';

  @override
  String get locationPermissionRequired =>
      'Locatie toestemming is vereist voor achtergrond tracking';

  @override
  String get locationTrackingEnabled =>
      'Achtergrondlocatie traceren ingeschakeld';

  @override
  String get locationTrackingDisabled =>
      'Achtergrondlocatie volgen uitgeschakeld';

  @override
  String get justNow => 'Net';

  @override
  String minutesAgo(int minutes) {
    return '__PLAATSHOLDER_0___ minuten geleden';
  }

  @override
  String hoursAgo(int hours) {
    return '__PLAATSHOLDER_0___ uren geleden';
  }

  @override
  String daysAgo(int days) {
    return '__PLAATSHOLDER_0__ dagen geleden';
  }

  @override
  String get dataManagement => 'Gegevensbeheer';

  @override
  String get dataManagementDesc =>
      'Uw accountgegevens exporteren of verwijderen';

  @override
  String get splashTagline => 'Signaleringen in realtime';

  @override
  String get splashStartingUp => 'Starten...';

  @override
  String get splashInitializationFailed => 'Initialisatie mislukt';

  @override
  String get splashInitializationFailedTitle => 'Initialisatie mislukt';

  @override
  String get splashInitializationError => 'De app kon niet goed initialiseren:';

  @override
  String get splashRetry => 'Opnieuw proberen';

  @override
  String get splashContinue => 'Doorgaan';

  @override
  String get splashInitializing => 'Initialiseren...';

  @override
  String signInWelcome(String username) {
    return 'Welkom!';
  }

  @override
  String signInFailed(String error) {
    return 'Aanmelden mislukt: __PLAATSHOLDER_0___';
  }

  @override
  String get signInPleaseEnterEmail => 'Vul uw e-mailadres in';

  @override
  String get signInPleaseEnterValidEmail => 'Vul een geldig e-mailadres in';

  @override
  String get signInMagicLinkSent =>
      'Magische link verzonden! Controleer uw e-mail en klik op de link om u aan te melden.';

  @override
  String get signInMagicLinkFailed =>
      'Kon magische verwijzing niet versturen. Probeer het nog eens.';

  @override
  String get signInAllDataCleared => 'Alle gegevens zijn gewist';

  @override
  String get signInSubtitle => 'Real-time UFO waarnemingen en MUFON rapporten';

  @override
  String get signInGoogleLoading => 'Aanmelden...';

  @override
  String get signInContinueWithGoogle => 'Doorgaan met Google';

  @override
  String get signInOr => 'of';

  @override
  String get signInWithEmail => 'Aanmelden met e-mail';

  @override
  String get signInEmailDescription =>
      'We sturen je een beveiligde link om je aan te melden';

  @override
  String get signInEmailAddress => 'E-mailadres';

  @override
  String get signInEmailPlaceholder => 'your@email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'Probeer opnieuw in __PLACEHOLDER_0_s';
  }

  @override
  String get signInSending => 'Verzenden...';

  @override
  String get signInSendMagicLink => 'Magische koppeling versturen';

  @override
  String get signInCheckEmail =>
      'Check je e-mail! De verbinding verloopt over 15 minuten.';

  @override
  String get signInSecureAuth => 'Veilige authenticatie';

  @override
  String get signInSecureAuthDescription =>
      'Gebruik Google Sign-In voor directe toegang, of e-mail magische links die vervallen in 15 minuten.';

  @override
  String get signInClearAllDataDebug => 'Alle gegevens wissen (debug)';

  @override
  String get emailAuthFailedToSend => 'Versturen van e-mail is mislukt';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'Versturen van e-mail is mislukt. Probeer het nog eens.';

  @override
  String get emailAuthInvalidEmail =>
      'Ongeldig e-mailadres. Controleer het formaat.';

  @override
  String get emailAuthUserNotFound =>
      'Geen account gevonden met dit e-mailadres.';

  @override
  String get emailAuthTooManyRequests =>
      'Te veel pogingen. Probeer het later nog eens.';

  @override
  String get emailAuthOperationNotAllowed =>
      'Aanmelden van e-maillink is niet ingeschakeld.';

  @override
  String get emailAuthQuotaExceeded =>
      'E-mailquota overschreden. Probeer het morgen opnieuw.';

  @override
  String get emailAuthVerificationFailed =>
      'E-mailverificatie mislukt. Probeer het nog eens.';

  @override
  String get emailAuthTitle => 'E-mailverificatie';

  @override
  String get emailAuthVerifyYourEmail => 'Uw e-mail verifiëren';

  @override
  String get emailAuthDescription =>
      'Voeg uw e-mailadres toe voor accountherstel en beveiliging. We sturen je een beveiligde link.';

  @override
  String get emailAuthEmailAddress => 'E-mailadres';

  @override
  String get emailAuthEmailPlaceholder => 'your.email@example.com';

  @override
  String get emailAuthPleaseEnterEmail => 'Vul uw e-mailadres in';

  @override
  String get emailAuthPleaseEnterValidEmail => 'Vul een geldig e-mailadres in';

  @override
  String get emailAuthCheckEmailToContinue =>
      'Controleer uw e-mail en tik op de verificatie-link om verder te gaan.';

  @override
  String get emailAuthResendEmail => 'E-mail opnieuw verzenden';

  @override
  String get emailAuthSendVerificationEmail => 'Verificatie verzenden E-mail';

  @override
  String get emailAuthHowItWorks => 'Hoe e-mailverificatie werkt';

  @override
  String get emailAuthHowItWorksSteps =>
      '1. Wij sturen u een veilige inlog link\n2. Controleer uw e-mail en tik op de link\n3. Uw e-mail wordt automatisch geverifieerd\n4. Geen wachtwoorden nodig!';

  @override
  String get emailAuthSecurityNotice =>
      'E-mailverificatie helpt uw account veilig te stellen en maakt accountherstel mogelijk als u de toegang tot uw apparaat verliest.';

  @override
  String get phoneAuthFailedToSendCode =>
      'Kon verificatiecode niet versturen. Probeer het nog eens.';

  @override
  String get phoneAuthInvalidCodeTryAgain =>
      'Ongeldige verificatiecode. Probeer het nog eens.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'Telefoonnummer geverifieerd: __PLAATSHOLDER_0___';
  }

  @override
  String get phoneAuthVerificationFailed =>
      'Telefoonverificatie mislukt. Probeer het nog eens.';

  @override
  String get phoneAuthCodeResent => 'Verificatiecode';

  @override
  String get phoneAuthFailedToResendCode =>
      'Hersturen van code is mislukt. Probeer het nog eens.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'Ongeldig telefoonnummer. Controleer het formaat.';

  @override
  String get phoneAuthTooManyRequests =>
      'Te veel pogingen. Probeer het later nog eens.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'Ongeldige verificatiecode. Controleer en probeer het opnieuw.';

  @override
  String get phoneAuthSessionExpired =>
      'De verificatiesessie is verlopen. Vraag een nieuwe code aan.';

  @override
  String get phoneAuthSmsQuotaExceeded =>
      'SMS-quotum overschreden. Probeer het morgen opnieuw.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'Dit telefoonnummer is al gekoppeld aan een ander account.';

  @override
  String get phoneAuthVerificationFailedGeneric =>
      'Verificatie mislukt. Probeer het nog eens.';

  @override
  String get phoneAuthTitle => 'Telefooncontrole';

  @override
  String get phoneAuthVerifyYourPhone => 'Uw telefoon controleren';

  @override
  String get phoneAuthEnterVerificationCode => 'Verificatie invoeren Rubriek';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'Voeg uw telefoonnummer voor account herstel en beveiliging';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return 'Voer de 6-cijferige code in die naar $phoneNumber is verzonden';
  }

  @override
  String get phoneAuthPhoneNumber => 'Telefoonnummer';

  @override
  String get phoneAuthPhonePlaceholder => '+1 (555) 123-4567';

  @override
  String get phoneAuthPleaseEnterPhone => 'Voer uw telefoonnummer in';

  @override
  String get phoneAuthPleaseEnterValidPhone =>
      'Voer een geldig telefoonnummer in';

  @override
  String get phoneAuthVerificationCode => 'Verificatiecode';

  @override
  String get phoneAuthPleaseEnterSixDigitCode => 'Voer de 6-cijferige code in';

  @override
  String get phoneAuthResendCode => 'Code opnieuw verzenden';

  @override
  String get phoneAuthSendVerificationCode => 'Verificatie verzenden Rubriek';

  @override
  String get phoneAuthVerifyCode => 'Code verifiëren';

  @override
  String get phoneAuthChangePhoneNumber => 'Telefoonnummer wijzigen';

  @override
  String get phoneAuthSmsNotice =>
      'We sturen je een verificatiecode via SMS. Standaard berichtentarieven kunnen van toepassing zijn.';

  @override
  String get phoneAuthCodeExpires =>
      'Code verloopt over 60 seconden. Controleer je berichten.';

  @override
  String get yourDataRights => 'Uw gegevensrechten';

  @override
  String get dataRightsExplanation =>
      'U heeft volledige controle over uw persoonlijke gegevens. U kunt al uw gegevens exporteren of permanent uw account te allen tijde verwijderen.';

  @override
  String get exportYourData => 'Uw gegevens exporteren';

  @override
  String get exportDataDescription => 'Download al uw accountgegevens';

  @override
  String get exportData => 'Gegevens exporteren';

  @override
  String get exportingData => 'Exporteren...';

  @override
  String get exportDataDetails =>
      'Omvat: profiel, piepers, opmerkingen, apparaatinformatie en voorkeuren. Gegevens worden verstrekt in JSON formaat.';

  @override
  String get dataExportedSuccessfully => 'Gegevens met succes geëxporteerd';

  @override
  String get dataExportFailed => 'Exporteren van gegevens is mislukt';

  @override
  String get deleteAccount => 'Account verwijderen';

  @override
  String get deleteAccountDescription =>
      'Uw account en alle gegevens definitief verwijderen';

  @override
  String get deleteAccountWarning =>
      'Deze actie kan niet ongedaan worden gemaakt. Al uw piepers, opmerkingen en accountgegevens worden permanent verwijderd.';

  @override
  String get deleteMyAccount => 'Mijn account verwijderen';

  @override
  String get deletingAccount => 'Verwijderen...';

  @override
  String get deleteAccountConfirmTitle => 'Account verwijderen';

  @override
  String get deleteAccountConfirmMessage =>
      'Weet u absoluut zeker dat u uw account wilt verwijderen? Deze actie is permanent en kan niet ongedaan worden gemaakt.';

  @override
  String get dataWillBeDeleted =>
      'De volgende gegevens worden definitief verwijderd:';

  @override
  String get deletedDataList =>
      '• Uw profiel en gebruikersnaam\n• Al je piepjes en rapporten\n• Al uw opmerkingen\n• Device registratie gegevens\n• Locatie en voorkeursgegevens';

  @override
  String get deleteAccountPermanent => 'Permanent verwijderen';

  @override
  String get accountDeletedSuccessfully => 'Account succesvol verwijderd';

  @override
  String get accountDeletionFailed => 'Verwijderen van account mislukt';

  @override
  String get onboardingWelcomeTitle => 'Welkom bij UFObeep';

  @override
  String get onboardingWelcomeBody =>
      'Ontvang onmiddellijke waarschuwingen wanneer UFO\'s worden gezien in de buurt van uw locatie. Mis nooit meer een waarneming!';

  @override
  String get onboardingReportTitle => 'Zie je iets? Piep het!';

  @override
  String get onboardingReportBody =>
      'Foto\'s en video\'s van UFO waarnemingen. Deel direct met de wereldwijde gemeenschap.';

  @override
  String get onboardingCompassTitle => 'Kijk waar ze keken';

  @override
  String get onboardingCompassBody =>
      'Kompas toont je de exacte richting die de getuige keek toen ze de UFO zagen. Richt je telefoon en kijk!';

  @override
  String get onboardingCommunityTitle => 'Verbinden met Skywatchers';

  @override
  String get onboardingCommunityBody =>
      'Lees de laatste UFO waarnemingen over uw ochtend koffie. Toegang tot professionele MUFON gegevens en verbinding met collega-skywatchers.';

  @override
  String get skip => 'Overslaan';

  @override
  String get getStarted => 'Starten';

  @override
  String get viewOnboardingAgain => 'Weer aan boord bekijken';
}
