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
    return '__PLACEHOLDER_0_ bort';
  }

  @override
  String alertDirection(int bearing) {
    return 'Bär __PLACEHOLDER_0_°';
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
    return 'Beep skickas framgångsrikt';
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
    return 'Rapporterad av ${username}__';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Rapporterad ${timeAgo}__';
  }

  @override
  String distanceAway(String distance) {
    return '$distance';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Bär mot objekt: __PLACEHOLDER_0_°';
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
  String get noCommentsYet =>
      'Inga kommentarer ännu. Bli först med att kommentera!';

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
    return 'Peka på ${direction}___';
  }

  @override
  String get calibratingCompass => 'Kalibrerande kompass..';

  @override
  String get openAROverlay => 'Open AR Overlay';

  @override
  String get pushTitleAlertNearby => 'UFO varning nära dig';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'En ny observation rapporterades __PLACEHOLDER_0_ bort.';
  }

  @override
  String get pushTitleComment => 'Ny kommentar';

  @override
  String get pushBodyComment => 'Någon kommenterade en observation du följer.';

  @override
  String get pushTitleWitness => 'Vittnesbekräftelse';

  @override
  String get temperature => 'Temperatur';

  @override
  String get pushBodyWitness =>
      'En användare bekräftade att de ser samma objekt.';

  @override
  String get weather => 'Vädret';

  @override
  String cloudCover(int percent) {
    return 'Cloud cover: __PLACEHOLDER_0_%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Vind: ${speed}_${unit}__________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
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
  String get quietHoursEnabled => 'Aktivera tysta timmar';

  @override
  String get quietHoursFrom => 'Från';

  @override
  String get quietHoursUntil => 'Fram till';

  @override
  String get quietHoursDefaultTime => 'Standard tysta timmar';

  @override
  String get emergencyOverride => 'Nödläge överskrider';

  @override
  String get emergencyOverrideDesc =>
      'Tillåt akuta varningar under tysta timmar';

  @override
  String get dndMode => 'Stör inte';

  @override
  String get dndUntil => 'Stör inte förrän';

  @override
  String dndEnabled(Object time) {
    return 'DND aktiverad till ${time}__';
  }

  @override
  String get dndDisabled => 'DND inaktiverad';

  @override
  String get quietHoursActive => 'Tyst timmar aktiv';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Tyst timmar: $start ${start}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get pushNotificationUfoAlert => 'UFO Alert';

  @override
  String get pushNotificationAnomalyAlert => 'Anomaly Alert';

  @override
  String get pushNotificationNearby => 'I närheten';

  @override
  String get pushNotificationInYourArea =>
      'i ditt område. Tryck för att visa detaljer.';

  @override
  String pushNotificationCommented(Object username) {
    return '$username kommenterade';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '$username kommenterade ${username}_';
  }

  @override
  String get pushNotificationGeneric => 'UFOBeep';

  @override
  String get pushNotificationNewSighting => 'Ny observation i närheten';

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
  String get beepOnly => 'Beep Only';

  @override
  String get reportOnly => 'Text Endast';

  @override
  String get videoOnly => 'Video Endast';

  @override
  String get imageOnly => 'Bild endast';

  @override
  String get mediaOnly => 'Media Endast';

  @override
  String get timeJustNow => 'just nu';

  @override
  String timeDaysAgo(int count) {
    return '__PLACEHOLDER_0_dagar sedan';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}_ för några timmar sedan';
  }

  @override
  String timeMinutesAgo(int count) {
    return '$count för några minuter sedan';
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
  String get mufonSighting => 'MUFON Sighting Report';

  @override
  String get mufonLightSighting => 'Mufon Light Sighting Report';

  @override
  String get mufonSphereSighting => 'MUFON Sphere Sighting Report';

  @override
  String get mufonDiscSighting => 'Mufonen Disc Sighting Report';

  @override
  String get mufonTriangleSighting => 'Mufonen Triangle Sighting Report';

  @override
  String get mufonCigarSighting => 'MUFON Cigar Sighting Report';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting Report';

  @override
  String get mufonRectangleSighting => 'Mufonen Rectangle Sighting Report';

  @override
  String get mufonCylinderSighting => 'MUFON Cylinder Sighting Report';

  @override
  String get mufonBoomerangSighting => 'Mufon Boomerang Sighting Report';

  @override
  String get mufonStarlikeSighting => 'Mufonen Starlike Sighting Report';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Case #_PLACEHOLDER_0_ Detaljer';
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
  String get locationLabel => 'Plats:';

  @override
  String get distanceLabel => 'Avstånd';

  @override
  String get timeLabel => 'Tid:';

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
    return 'Analys: $count media file(s) bearbetade';
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
  String get timeFormat => 'Tidsformat';

  @override
  String get timeFormat24Hour => '24 timmar (14:30)';

  @override
  String get timeFormat12Hour => '12 timmar (2:30 PM)';

  @override
  String get timeFormatDesc => 'Visa tid i 24-timmars eller 12-timmars format';

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
  String get ufo => 'UFO';

  @override
  String get sighting => 'Sighting';

  @override
  String get ufoSighting => 'UFOBeep UFO Alert';

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
  String get shapeTriangle => 'triangel';

  @override
  String get shapeDisc => 'disk';

  @override
  String get shapeDisk => 'disk';

  @override
  String get shapeSphere => 'sfären';

  @override
  String get shapeCigar => 'cigarr';

  @override
  String get shapeLight => 'ljust ljus';

  @override
  String get shapeBoomerang => 'boomerang';

  @override
  String get shapeDiamond => 'diamant';

  @override
  String get shapeRectangle => 'rectangle';

  @override
  String get shapeOval => 'oval';

  @override
  String get shapeCone => 'cone';

  @override
  String get shapeCross => 'korsar kors';

  @override
  String get shapeCylinder => 'cylinder';

  @override
  String get shapeDumbbell => 'dumbbell';

  @override
  String get shapeTeardrop => 'teardrop';

  @override
  String get shapeTicTac => 'tic-tac';

  @override
  String get shapeBullet => 'bullet';

  @override
  String get shapeSaturn => 'saturnus';

  @override
  String get shapeStarlike => 'starlike';

  @override
  String get shapeBlimp => 'blimp';

  @override
  String get shapeFireball => 'fireball';

  @override
  String get shapeFormation => 'bildandet';

  @override
  String get shapeUnknown => 'okänd';

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
    return 'Mufonen Fall #_PLACEHOLDER_0__';
  }

  @override
  String get satellitePassesTitle => 'Satellitpass';

  @override
  String get satellitePassExplanation =>
      'Synlig satellit passerar under siktetiden. Många UFO-rapporter är faktiskt satelliter eller rymdskrot.';

  @override
  String get followingAlert => 'Efter varning - du får kommentarmeddelanden';

  @override
  String get unfollowedAlert =>
      'Slutförd varning - inga fler kommentarmeddelanden';

  @override
  String get alertFollowError => 'Feluppdatering följer status';

  @override
  String get notificationChannelAlerts => 'UFOBeep Alerts';

  @override
  String get notificationChannelAlertsDesc =>
      'Meddelanden för UFO-pips och närhetsvarningar';

  @override
  String get notificationSightingTitle => 'UFOBeep UFO Alert';

  @override
  String get notificationSightingUrgent => 'URGENT UFOBEep UFO Alert';

  @override
  String get notificationSightingEmergency => 'EMERGENCY UFOBEep UFO Alert';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '__PLACEHOLDER_0_ nära ${locationName}_';
  }

  @override
  String notificationCommentTitle(String username) {
    return '$username kommenterade';
  }

  @override
  String get notificationWitnessText => 'Ny observation';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '__PLACEHOLDER_0_ vittnen';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Avfärda';

  @override
  String notificationDistance(String distance) {
    return '__PLACEHOLDER_0_ bort';
  }

  @override
  String get unknown => 'okänd';

  @override
  String get report => 'rapportrapport';

  @override
  String get mufon => 'mufon';

  @override
  String get recentUfoBeepsTitle => 'Nyligen UFO Beeps';

  @override
  String get recentUfoBeepsSubtitle =>
      'Live UFO-observationsrapporter från vårt globala samhälle';

  @override
  String get recentUfoBeepsDescription =>
      'Detta foder kombinerar realtids UFOBeep \"pips\" från våra mobilappanvändare med historiska rapporter från MUFON-databasen.';

  @override
  String get loadingBeeps => 'Loading new beeps...';

  @override
  String get noBeepsAvailable => 'Inga pip tillgängliga för tillfället.';

  @override
  String get anomalyReported => 'Anomaly rapporterade';

  @override
  String get copyShortLink => 'Kopiera kort länk';

  @override
  String get shareAlert => 'Dela alert';

  @override
  String get ufoSightingAlert => 'UFO Sighting Alert';

  @override
  String get previousPage => 'Föregående';

  @override
  String get nextPage => 'Nästa';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Page $currentPage av ${totalPages}_ (_PLACEHOLDER_2_______________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get firstPage => 'Först först';

  @override
  String get lastPage => 'Senaste';

  @override
  String get jumpToPage => 'Hoppa till sida';

  @override
  String get heroTagline => 'Få varningar när du ska gå ut och titta upp';

  @override
  String get heroDescription =>
      'Missa aldrig en annan UFO-observation. Få realtidsvarningar när någon nära dig ser något konstigt på himlen. Peka din telefon och hitta exakt var du ska titta.';

  @override
  String get downloadApp => 'Nedladdning App';

  @override
  String get viewAllBeeps => 'Visa alla Beeps';

  @override
  String get sightingsMap => 'Sightings Map';

  @override
  String get globalSightingNetwork => 'Global Sighting Network';

  @override
  String get howItWorks => 'Hur UFOBeep fungerar';

  @override
  String get backToBeeps => 'Tillbaka till Beeps';

  @override
  String get loadingDetails => 'Loading beep detaljer...';

  @override
  String get details => 'Detaljer';

  @override
  String get location => 'Plats';

  @override
  String get timeAgo => 'för länge sedan';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'miljö';

  @override
  String get distanceNearby => 'närliggande';

  @override
  String get ufobeepWitnesses => 'Vittnen';

  @override
  String get ufobeepConfirmations => 'Bekräftelser';

  @override
  String get ufobeepAlertLevel => 'Alert Level';

  @override
  String get ufobeepReportType => 'UFOBeep-rapport';

  @override
  String get mufonAttribution => 'Mufonen Databasrapport';

  @override
  String get mufonCaseNumber => 'Fall #';

  @override
  String get mufonGenericTitle => 'MUFON Sighting Report';

  @override
  String get mufonSphere => 'Sfären';

  @override
  String get mufonLight => 'Ljus ljus';

  @override
  String get mufonDisk => 'Disk';

  @override
  String get mufonTriangle => 'Triangeln';

  @override
  String get mufonCigar => 'Cigar';

  @override
  String get mufonOval => 'Oval';

  @override
  String get mufonCylinder => 'Cylinder';

  @override
  String get mufonRectangle => 'Rectangle';

  @override
  String get mufonDiamond => 'Diamant';

  @override
  String get mufonFireball => 'Fireball';

  @override
  String get mufonFlash => 'Flash';

  @override
  String get mufonFormation => 'Formation';

  @override
  String get mufonChanging => 'Ändra';

  @override
  String get mufonChevron => 'Chevron';

  @override
  String get mufonCone => 'Cone';

  @override
  String get mufonCross => 'Korset korsar';

  @override
  String get mufonEgg => 'Ägg';

  @override
  String get mufonOther => 'Objekt';

  @override
  String get mufonUnknown => 'Okända objekt';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON $classification Rapport';
  }

  @override
  String get nuforcAttribution => 'NUFORC Databasrapport';

  @override
  String get nuforcCaseNumber => 'Fall #';

  @override
  String get nuforcGenericTitle => 'NUFORC Sighting Report';

  @override
  String get mediaImageNotFound => 'Bild som inte hittats';

  @override
  String get mediaPlayVideo => 'Spela Video';

  @override
  String get mediaViewImage => 'Visa bild';

  @override
  String mediaCount(Object count) {
    return '${count}_ bilder';
  }

  @override
  String get mediaCountSingle => '1 bild';

  @override
  String mediaMoreImages(Object count) {
    return '+_PLACEHOLDER_0_ mer';
  }

  @override
  String get errorNotFound => 'Beep hittades inte';

  @override
  String get errorLoadError => 'Misslyckades med att ladda beep detaljer';

  @override
  String get shareYourThoughts => 'Dela dina tankar om denna observation...';

  @override
  String get postComment => 'Post Comment';

  @override
  String get loggedInAs => 'Logga in som';

  @override
  String get logout => 'Logout';

  @override
  String get notFollowing => 'Inte följa';

  @override
  String get follow => 'Följ';

  @override
  String get navRecentBeeps => 'Nyligen Beeps';

  @override
  String get navMap => 'Karta';

  @override
  String get navDownloadApp => 'Ladda ner App';

  @override
  String get alertLevel => 'Alert Level';

  @override
  String get witnesses => 'Vittnen';

  @override
  String get confirmations => 'Bekräftelser';

  @override
  String get reporterLabel => 'Rapporterad av användaren';

  @override
  String get coordinatesLabel => 'Koordinater';

  @override
  String get eventTime => 'Event Time';

  @override
  String get reportedTime => 'Rapporterad tid';

  @override
  String get addedToUfobeep => 'Tillagd till UFOBeep';

  @override
  String get mufonDatabaseReport => 'Mufonen Fallnummer:';

  @override
  String get copyShortLinkTitle => 'Kopiera länk till Clipboard';

  @override
  String get imageNotFound => 'Bild som inte hittats';

  @override
  String get ufoSightingAlt => 'UFO Beep UFO varning';

  @override
  String get celestialDataTitle => 'Celestial Objects';

  @override
  String get visiblePlanets => 'Synliga planeter';

  @override
  String get locationDataTitle => 'Platsinformation';

  @override
  String get timezone => 'Timezone';

  @override
  String get coordinates => 'Koordinater';

  @override
  String get processingSummaryTitle => 'Processing Sammanfattning';

  @override
  String get processingTime => 'Bearbetningstid';

  @override
  String get successful => 'Framgång';

  @override
  String get failed => 'Misslyckades';

  @override
  String get locationEnrichmentTitle => 'Plats detaljer';

  @override
  String get aircraftDataSource => 'Datakälla';

  @override
  String get noAircraftDetected => 'Inga flygplan upptäckta';

  @override
  String get sightingReport => 'Sighting Report';

  @override
  String get ufoAlert => 'UFO Alert';

  @override
  String get alert => 'Alert';

  @override
  String get notificationTickerUfoAlert => 'UFO Alert - Ny syn i närheten';

  @override
  String get notificationTickerComment => 'Ny kommentar till UFO Alert';

  @override
  String get weatherConditions => 'Väderförhållanden';

  @override
  String get visibility => 'Synlighet';

  @override
  String get humidity => 'Humidity';

  @override
  String get pressure => 'Tryck';

  @override
  String get locationDetails => 'Plats detaljer';

  @override
  String get city => 'Staden City';

  @override
  String get state => 'Staten';

  @override
  String get country => 'Landet';

  @override
  String get satelliteActivity => 'Satellitaktivitet';

  @override
  String get satellitesVisibleOverhead =>
      'Satelliter synliga överhuvudet vid observationstid och plats';

  @override
  String get dataSource => 'Datakälla';

  @override
  String get blackskyImagery => 'BlackSky Imagery';

  @override
  String get resolution => 'Resolution';

  @override
  String get groundResolution => '35cm grundupplösning';

  @override
  String get delivery => 'Leverans';

  @override
  String get averageDelivery => '90 minuter genomsnitt';

  @override
  String get cost => 'Kostnad';

  @override
  String get skyfiSatelliteImagery => 'SkyFi satellit Imagery';

  @override
  String get region => 'Region';

  @override
  String get remoteArea => 'Fjärrområde';

  @override
  String get startingPrice => 'Starta pris';

  @override
  String get coverage => 'Täckning';

  @override
  String get confidenceCoverage => '95% förtroende';

  @override
  String get status => 'Status';

  @override
  String get shareThoughts => 'Dela dina tankar om denna observation...';

  @override
  String get postCommand => 'Postkommando';

  @override
  String get clouds => 'Moln';

  @override
  String get windLabel => 'Vind';

  @override
  String get filterAlerts => 'Filter Alerts';

  @override
  String get alertSource => 'Alert Source';

  @override
  String get ufobeepOnly => 'Ufobeep bara';

  @override
  String get ufobeepOnlyDescription =>
      'Visa endast original UFOBeep-rapporter (exkludera MUFON-databas)';

  @override
  String get alertDistanceRange => 'Alert Distance Range';

  @override
  String get showAllAlerts => 'Visa alla varningar';

  @override
  String get showAll => 'Visa alla';

  @override
  String get distanceSliderDescription =>
      'Dra för att justera hur långt du vill se varningar. Börja från väder synlighet avstånd upp till att visa alla varningar oavsett avstånd.';

  @override
  String get applyFilters => 'Applicera filter';

  @override
  String get notificationRange => 'Anmälan Range';

  @override
  String get notificationRangeDescription =>
      'Få push-varningar för observationer inom detta avstånd';

  @override
  String get viewingRange => 'Visa Range';

  @override
  String get viewingRangeDescription =>
      'Visa observationer inom detta avstånd när du surfar';

  @override
  String get weatherVisibility => 'Vädersynlighet (~10 km)';

  @override
  String get localArea => 'Lokalt område (25 km)';

  @override
  String get regional => 'Regional';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get alertBrowsing => 'Alert Browsing';

  @override
  String get pushAlertsWithinDistance => 'Get notifications within this range';

  @override
  String get showAlertsWhenBrowsing => 'Filter what you see in the list';
}
