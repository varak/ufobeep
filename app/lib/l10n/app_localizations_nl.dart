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
    return 'Koers ${bearing}_°';
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
    return 'Gerapporteerd $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '${distance}_ weg';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Richting tot object: ${bearing}_°';
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
  String get noCommentsYet => 'Nog geen commentaar. Wees de eerste!';

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
    return 'Richting ${direction}_';
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
  String get pushBodyWitness =>
      'Een gebruiker bevestigde dat ze hetzelfde object zien.';

  @override
  String get weather => 'Weer';

  @override
  String cloudCover(int percent) {
    return 'Cloud cover: ${percent}_%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Wind: $speed $unit';
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
  String get dndMode => 'Niet storen';

  @override
  String get dndUntil => 'Niet storen tot';

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
  String get beepOnly => 'alleen piepen';

  @override
  String get videoOnly => 'alleen video';

  @override
  String get imageOnly => 'alleen afbeelding';

  @override
  String get timeJustNow => 'Net';

  @override
  String timeDaysAgo(int count) {
    return '${count}d geleden';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h geleden';
  }

  @override
  String timeMinutesAgo(int count) {
    return '__PH_0_m geleden';
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
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Zaak #${caseNumber}_ Details';
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
  String get locationLabel => 'Locatie';

  @override
  String get distanceLabel => 'Afstand';

  @override
  String get timeLabel => 'Tijd';

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
    return 'Mensen hebben deze waarneming bevestigd';
  }

  @override
  String get photoAnalysisTitle => 'Fotoanalyse';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analyse: $count mediabestand(s) verwerkt';
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
  String get ufoSighting => 'UFO Waarneming';

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
  String get directionDistanceTitle => 'Direction & Distance';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Case #$caseNumber';
  }

  @override
  String get satellitePassesTitle => 'Satellite Passes';

  @override
  String get satellitePassExplanation =>
      'Visible satellite passes during the sighting timeframe. Many UFO reports are actually satellites or space debris.';

  @override
  String get followingAlert =>
      'Following alert - you\'ll get comment notifications';

  @override
  String get unfollowedAlert =>
      'Unfollowed alert - no more comment notifications';

  @override
  String get alertFollowError => 'Error updating follow status';
}
