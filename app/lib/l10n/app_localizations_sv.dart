// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appName => 'UFOBeep';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Avbokning';

  @override
  String get close => 'Nära';

  @override
  String get save => 'Spara';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Retry';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Ingen';

  @override
  String get back => 'Tillbaka';

  @override
  String get next => 'Nästa';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading..';

  @override
  String get processing => 'Processing..';

  @override
  String get errorGeneric => 'Något gick fel.';

  @override
  String get networkError => 'Network error. Kolla din anslutning.';

  @override
  String get permissionsRequired => 'Tillstånd som krävs';

  @override
  String get learnMore => 'Lär dig mer';

  @override
  String get welcomeTitle => 'Välkommen till UFOBeep';

  @override
  String get welcomeSubtitle => 'UFO-varningar i realtid nära dig';

  @override
  String get signIn => 'Logga in';

  @override
  String get signOut => 'Logga ut';

  @override
  String get continueAsGuest => 'Fortsätt som gäst';

  @override
  String get enterUsername => 'Ange ett användarnamn';

  @override
  String get username => 'Användarnamn';

  @override
  String get usernameUpdated => 'Användarnamn uppdaterat';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Inställningar';

  @override
  String get tabAlerts => 'Varningar';

  @override
  String get tabBeep => 'Beep';

  @override
  String get tabChat => 'Chatta';

  @override
  String get tabMap => 'Karta';

  @override
  String get tabSettings => 'Inställningar';

  @override
  String get alertsTitle => 'Nära Alerts';

  @override
  String get noAlerts => 'Inga varningar i närheten ännu.';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String alertDistance(String distance) {
    return '__PH_0_ bort';
  }

  @override
  String alertDirection(int bearing) {
    return 'Bär __PH_0_°';
  }

  @override
  String get viewAlert => 'Visa alert';

  @override
  String get viewOnMap => 'Visa på karta';

  @override
  String get iSeeItToo => 'Jag ser det också';

  @override
  String get confirmWitnessed =>
      'Bekräfta att du bevittnade denna observation?';

  @override
  String get witnessConfirmed => 'Tack - din bekräftelse publicerades.';

  @override
  String get createBeepTitle => 'Skicka ett Beep';

  @override
  String get beepExplain => 'Fånga vad du ser och varna närliggande tittare.';

  @override
  String get capturePhoto => 'Bildbild';

  @override
  String get captureVideo => 'Fånga video';

  @override
  String get pickFromGallery => 'Välj från galleri';

  @override
  String get descriptionHint => 'Beskriv vad du ser på himlen';

  @override
  String get submitBeep => 'Skicka Beep';

  @override
  String get beepSent => 'Beep skickade';

  @override
  String beepSentWithUrl(String shortUrl) {
    return 'Alert sent! Share at ufobeep.com/$shortUrl';
  }

  @override
  String get uploadingMedia => 'Ladda upp media..';

  @override
  String get includeLocation => 'Inkludera plats';

  @override
  String get includeTimestamp => 'Inkludera timestamp';

  @override
  String get beepFailed => 'Misslyckades med att skicka Beep.';

  @override
  String get mediaProcessing => 'Processing media..';

  @override
  String get cameraPermissionTitle => 'Kameraåtkomst behövs';

  @override
  String get cameraPermissionBody =>
      'Grant kamera tillgång till fånga UFO bilder och videor.';

  @override
  String get locationPermissionTitle => 'Läge tillgång behövs';

  @override
  String get locationPermissionBody =>
      'Vi använder din plats för att skicka och ta emot närliggande varningar.';

  @override
  String get microphonePermissionTitle => 'Mikrofonåtkomst behövs';

  @override
  String get microphonePermissionBody =>
      'Grant mikrofonåtkomst för videoinspelning med ljud.';

  @override
  String get openSettings => 'Öppna inställningar';

  @override
  String get alertDetailTitle => 'Sighting detaljer';

  @override
  String reportedBy(String username) {
    return 'Rapporterad av ${username}_';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Rapporterad ${timeAgo}_';
  }

  @override
  String distanceAway(String distance) {
    return '__PH_0_ bort';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Bär mot objekt: __PH_0_°';
  }

  @override
  String get openCompass => 'Öppen kompass';

  @override
  String get openAR => 'Open AR Overlay';

  @override
  String get openChat => 'Open chat';

  @override
  String get commentsTitle => 'Kommentarer';

  @override
  String get addComment => 'Lägg till en kommentar..';

  @override
  String get send => 'Skicka';

  @override
  String get commentPosted => 'Kommentarer publicerade';

  @override
  String get autoFollowEnabled => 'Du följer nu denna varning.';

  @override
  String get noCommentsYet => 'Inga kommentarer ännu. Bli först!';

  @override
  String get newCommentNotification =>
      'Ny kommentar till en observation du följer.';

  @override
  String get mapTitle => 'Live Map';

  @override
  String get compassTitle => 'Kompass';

  @override
  String get compassSettings => 'Compass Inställningar';

  @override
  String get compassMode => 'Kompassläge';

  @override
  String get compassStandardMode => 'Standardläge';

  @override
  String get compassPilotMode => 'Pilotläge';

  @override
  String get compassStandardDescription =>
      'Grundläggande rubrik och navigering';

  @override
  String get compassPilotDescription =>
      'Avancerad navigering med ETA och vektor';

  @override
  String pointingTo(String direction) {
    return 'Peka på ${direction}_';
  }

  @override
  String get calibratingCompass => 'Kalibrerande kompass..';

  @override
  String get openAROverlay => 'Open AR Overlay';

  @override
  String get pushTitleAlertNearby => 'UFO varning nära dig';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'En ny observation rapporterades __PH_0_.';
  }

  @override
  String get pushTitleComment => 'Ny kommentar';

  @override
  String get pushBodyComment => 'Någon kommenterade en observation du följer.';

  @override
  String get pushTitleWitness => 'Vittnesbekräftelse';

  @override
  String get pushBodyWitness =>
      'En användare bekräftade att de ser samma objekt.';

  @override
  String get weather => 'Vädret';

  @override
  String cloudCover(int percent) {
    return 'Cloud cover: __PH_0_%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Vind: __PH_0_ $unit';
  }

  @override
  String get nearbyAircraft => 'I närheten av flygplan';

  @override
  String get noAircraft => 'Inga flygplan i närheten';

  @override
  String get loadingContext => 'Ledande miljökontext..';

  @override
  String get settingsTitle => 'Inställningar';

  @override
  String get notifications => 'Meddelanden';

  @override
  String get enablePushNotifications =>
      'Få meddelanden för framtida kommentarer';

  @override
  String get quietHours => 'Tyst timmar';

  @override
  String get quietHoursDesc => 'Tystnadsvarningar mellan utvalda timmar.';

  @override
  String get dndMode => 'Stör inte';

  @override
  String get dndUntil => 'Stör inte förrän';

  @override
  String get language => 'Språkspråk';

  @override
  String get chooseLanguage => 'Välj språk';

  @override
  String get units => 'Enheter';

  @override
  String get unitsImperial => 'Imperial (mi, mph)';

  @override
  String get unitsMetric => 'Metric (km, km/h)';

  @override
  String get privacyPolicy => 'Integritetspolicy';

  @override
  String get termsOfUse => 'Användarvillkor';

  @override
  String get errorNoLocation =>
      'Plats otillgänglig. Försök igen utanför med klar himmelvy.';

  @override
  String get errorNoCamera => 'Kamera otillgänglig på denna enhet.';

  @override
  String get errorUploadFailed => 'Uppladdning misslyckades. Försök igen.';

  @override
  String get errorPermissionDenied => 'Tillstånd förnekas.';

  @override
  String get errorInvalidUsername => 'Det användarnamnet är inte tillgängligt.';

  @override
  String get nothingToShow => 'Inget att visa ännu.';

  @override
  String get storeShortDesc =>
      'Omedelbara UFO-varningar nära dig. Fånga, bekräfta och chatta i realtid.';

  @override
  String get storeLongDesc =>
      'UFOBeep skickar realtidsvarningar när någon upptäcker en UFO i närheten. Fånga foton och videor, bekräfta observationer med en kran, visa riktning och avstånd och chatta med andra skywatchers.';

  @override
  String get keywords =>
      'UFO,UAP,OVNI,aliens,sightings,skywatch,alerts,radar,compass';

  @override
  String get noAlertsFound => 'Inga matchande varningar';

  @override
  String get alertsFilterHelp =>
      'Försök att justera dina filter för att se fler resultat';

  @override
  String get verified => 'Verifierad';

  @override
  String get beepOnly => 'beep endast';

  @override
  String get videoOnly => 'video endast';

  @override
  String get imageOnly => 'bild endast';

  @override
  String get timeJustNow => 'Just nu';

  @override
  String timeDaysAgo(int count) {
    return '${count}d för';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count för';
  }

  @override
  String timeMinutesAgo(int count) {
    return '$count för';
  }

  @override
  String get loadMoreAlerts => 'Load More Alerts';

  @override
  String get toggleMufonTooltip => 'Toggle MUFON observationer';

  @override
  String get showMufonData => 'Visa MUFON-data';

  @override
  String get hideMufonData => 'Dölj MUFON-data';

  @override
  String get showingUfoBeepOnly => 'Visa endast UFOBeep-rapporter';

  @override
  String get showingAllReports => 'Visa alla rapporter inklusive MUFON-databas';

  @override
  String get filteredSuffix => 'filtrerad';

  @override
  String get detailsTitle => 'Detaljer';

  @override
  String get mufonCase => 'Mufonen fall';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'Mufonen Fall #__PH_0_ detaljer';
  }

  @override
  String get sightingDate => 'Sighting Date';

  @override
  String get mufonDatabaseEntryDate => 'Datum in i MUFON Databas';

  @override
  String get databaseEntry => 'Databasinträde';

  @override
  String get shareLink => 'Dela Link';

  @override
  String get linkCopied => 'Link kopierad till Clipboard';

  @override
  String get locationLabel => 'Plats';

  @override
  String get distanceLabel => 'Avstånd';

  @override
  String get timeLabel => 'Tid';

  @override
  String get reportedByLabel => 'Rapporterad av';

  @override
  String get unknownLocation => 'Okänd plats';

  @override
  String get locationUnknown => 'Plats okänd';

  @override
  String get witnessesLabel => 'Vittnen';

  @override
  String witnessesCountMessage(int count) {
    return '$count människor bekräftade denna observation';
  }

  @override
  String get photoAnalysisTitle => 'Fotoanalys';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analys: $count media file(s) bearbetad';
  }

  @override
  String get addMoreMedia => 'Lägg till mer';

  @override
  String get addMedia => 'Lägg till media';

  @override
  String get retakePhoto => 'Retake Photo';

  @override
  String get retakeVideo => 'Retake Video';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galleriet';

  @override
  String get basicSettings => 'Grundläggande inställningar';

  @override
  String get appSettings => 'App Inställningar';

  @override
  String get alertRange => 'Alert Range';

  @override
  String get manageNotificationsDesc =>
      'Hantera prenumerationer och inställningar';

  @override
  String get permissionsTitle => 'Tillstånd';

  @override
  String get permissionLocation => 'Plats';

  @override
  String get permissionCamera => 'Kamera';

  @override
  String get permissionNotifications => 'Meddelanden';

  @override
  String get permissionPhotos => 'Foton';

  @override
  String get permissionGranted => 'Beviljas';

  @override
  String get permissionNotGranted => 'Inte beviljad';

  @override
  String get permissionGrant => 'Grant';

  @override
  String get generateUsername => 'Skapa nytt användarnamn';

  @override
  String get adminTools => 'Admin verktyg';

  @override
  String get openAdminPanel => 'Open Admin Panel';

  @override
  String get webAdminInterface => 'Web Admin Interface';

  @override
  String get adminBetaNotice =>
      'Beta bygger bara. Admin verktyg för att testa närhetsvarningar, push-meddelanden och systemdiagnostik.';

  @override
  String get whatDoYouSee => 'Vad ser du?';

  @override
  String get ufoSighting => 'UFO Sighting';

  @override
  String get envAnalysisTitle => 'Miljöanalys';

  @override
  String get envAnalysisPending => 'Analys i väntan';

  @override
  String get envAnalysisPendingDesc =>
      'Miljödata kommer att finnas tillgängliga när behandlingen påbörjas.';

  @override
  String get unknownAircraft => 'Okända flygplan';

  @override
  String get moreAircraft => 'fler flygplan';

  @override
  String get premiumImageryTitle => 'Premium satellit Imagery';

  @override
  String get premiumImagerySubtitle => 'Högupplöst kommersiellt bildspråk';

  @override
  String get sightingTypeLabel => 'Typ';

  @override
  String get ufoTypeSphere => 'Sfären';

  @override
  String get ufoTypeTriangle => 'Triangeln';

  @override
  String get ufoTypeDisk => 'Disk';

  @override
  String get ufoTypeLight => 'Ljus ljus';

  @override
  String get ufoTypeFireball => 'Fireball';

  @override
  String get ufoTypeCylinder => 'Cylinder';

  @override
  String get ufoTypeCigar => 'Cigar';

  @override
  String get ufoTypeRectangle => 'Rectangle';

  @override
  String get ufoTypeFormation => 'Formation';

  @override
  String get ufoTypeUnknown => 'Okänd';

  @override
  String get ufoTypeBoomerang => 'Boomerang';

  @override
  String get ufoTypeDiamond => 'Diamant';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Cone';

  @override
  String get ufoTypeCross => 'Korset korsar';

  @override
  String get ufoTypeDumbbell => 'Dumbbell';

  @override
  String get ufoTypeTeardrop => 'Teardrop';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Bullet';

  @override
  String get ufoTypeSaturn => 'Saturnus';

  @override
  String get ufoTypeStarLike => 'Star-liknande';

  @override
  String get ufoTypeBlimp => 'Blimp';

  @override
  String get actionsTitle => 'Aktiviteter';

  @override
  String get addPhotosAndVideos => 'Lägg till foton och videor';

  @override
  String get howToReportToMufon => 'Hur man rapporterar till Mufon';

  @override
  String get reportToMufon => 'Rapport till MUFON';

  @override
  String get whyReportToMufon => 'Varför rapportera till MUFON?';

  @override
  String get openMufonReport => 'Open MUFON Rapport';

  @override
  String get confirmedWitness => 'Du bekräftade denna observation';

  @override
  String witnessesHaveConfirmed(int count) {
    return '$count människor har bekräftat denna observation';
  }

  @override
  String get aircraftTrackingTitle => 'Aircraft Tracking';

  @override
  String get weatherConditionsTitle => 'Väderförhållanden';

  @override
  String get noSatellitePasses => 'Inga synliga satellitpass hittades';

  @override
  String get contentAnalysisTitle => 'Innehållsanalys';

  @override
  String get contentSafe => 'Innehållet är säkert';

  @override
  String get contentFlagged => 'Innehåll flaggat för granskning';

  @override
  String get confidenceLabel => 'Förtroende';

  @override
  String get methodLabel => 'Metod';

  @override
  String get premiumImageryAccessOnly =>
      'Premium satellitbilder är endast tillgängliga för:';

  @override
  String get premiumAccessCreators => 'Varningsskapare';

  @override
  String get premiumAccessWitnesses =>
      'Bekräftade vittnen inom synlighetsområdet';

  @override
  String get comingSoon => 'Kommer snart';

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

  @override
  String get notificationChannelAlerts => 'UFOBeep Alerts';

  @override
  String get notificationChannelAlertsDesc =>
      'Notifications for UFO beeps and proximity alerts';

  @override
  String get notificationSightingTitle => 'UFO Sighting';

  @override
  String get notificationSightingUrgent => '⚠️ URGENT UFO Sighting';

  @override
  String get notificationSightingEmergency => '🚨 EMERGENCY UFO Sighting';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '$witnessText near $locationName';
  }

  @override
  String notificationCommentTitle(String username) {
    return '💬 $username commented';
  }

  @override
  String get notificationWitnessText => 'New sighting';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '$count witnesses';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Dismiss';

  @override
  String notificationDistance(String distance) {
    return '$distance away';
  }
}
