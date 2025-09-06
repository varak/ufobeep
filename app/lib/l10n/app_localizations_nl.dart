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
  String get enablePushNotifications => 'Pushmeldingen inschakelen';

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
}
