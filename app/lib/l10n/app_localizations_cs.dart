// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appName => 'UFOBEep';

  @override
  String get ok => 'DOBŘE';

  @override
  String get cancel => 'Zrušit';

  @override
  String get close => 'Zavřít';

  @override
  String get save => 'Uložit';

  @override
  String get delete => 'Smazat';

  @override
  String get edit => 'Upravit';

  @override
  String get retry => 'Znovu';

  @override
  String get yes => 'Ano';

  @override
  String get no => 'Ne';

  @override
  String get back => 'Zpět';

  @override
  String get next => 'Další';

  @override
  String get done => 'Hotovo';

  @override
  String get loading => 'Nabíjím..';

  @override
  String get processing => 'Zpracování..';

  @override
  String get errorGeneric => 'Něco se pokazilo.';

  @override
  String get networkError => 'Chyba sítě. Zkontrolujte spojení.';

  @override
  String get permissionsRequired => 'Požadované oprávnění';

  @override
  String get learnMore => 'Přečtěte si více';

  @override
  String get welcomeTitle => 'Vítejte v UFOBeepu';

  @override
  String get welcomeSubtitle => 'Real-time UFO upozornění v blízkosti vás';

  @override
  String get signIn => 'Přihlaste se';

  @override
  String get signOut => 'Odhlásit se';

  @override
  String get continueAsGuest => 'Pokračovat jako host';

  @override
  String get enterUsername => 'Zadejte uživatelské jméno';

  @override
  String get username => 'Uživatelské jméno';

  @override
  String get usernameUpdated => 'Uživatelské jméno aktualizováno';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Nastavení';

  @override
  String get tabAlerts => 'Upozornění';

  @override
  String get tabBeep => 'Píp';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabMap => 'Mapa';

  @override
  String get tabSettings => 'Nastavení';

  @override
  String get alertsTitle => 'Blízké výstrahy';

  @override
  String get noAlerts => 'Zatím žádné varování.';

  @override
  String get pullToRefresh => 'Zatáhněte za obnovení';

  @override
  String alertDistance(String distance) {
    return '$distance away';
  }

  @override
  String alertDirection(int bearing) {
    return 'Ložisko';
  }

  @override
  String get viewAlert => 'Zobrazit upozornění';

  @override
  String get viewOnMap => 'Zobrazit na mapě';

  @override
  String get iSeeItToo => 'Taky to vidím';

  @override
  String get confirmWitnessed =>
      'Potvrďte, že jste byl svědkem tohoto pozorování?';

  @override
  String get witnessConfirmed => 'Díky - vaše potvrzení bylo odesláno.';

  @override
  String get createBeepTitle => 'Poslat píp';

  @override
  String get beepExplain =>
      'Zachyťte to, co vidíte a upozorněte blízké pozorovatele.';

  @override
  String get capturePhoto => 'Zachytit fotografii';

  @override
  String get captureVideo => 'Zachytit video';

  @override
  String get pickFromGallery => 'Vyberte si z galerie';

  @override
  String get descriptionHint => 'Popište, co vidíte na obloze..';

  @override
  String get submitBeep => 'Poslat Beep';

  @override
  String get beepSent => 'Píp odeslán';

  @override
  String beepSentWithUrl(String shortUrl) {
    return 'Píp odeslaný úspěšně';
  }

  @override
  String get uploadingMedia => 'Nahrávání médií..';

  @override
  String get includeLocation => 'Zahrnout umístění';

  @override
  String get includeTimestamp => 'Zahrnout časové razítko';

  @override
  String get beepFailed => 'Nepodařilo se mi poslat Beepa.';

  @override
  String get mediaProcessing => 'Zpracovávání médií..';

  @override
  String get cameraPermissionTitle => 'Potřebný přístup kamery';

  @override
  String get cameraPermissionBody =>
      'Grantová kamera přístup k zachycení UFO fotografie a videa.';

  @override
  String get locationPermissionTitle => 'Je nutný přístup k místu';

  @override
  String get locationPermissionBody =>
      'Vaši polohu využíváme k odesílání a přijímání nedalekých upozornění.';

  @override
  String get microphonePermissionTitle => 'Potřebný mikrofon';

  @override
  String get microphonePermissionBody =>
      'Grant mikrofon přístup pro záznam videa s audio.';

  @override
  String get openSettings => 'Otevřít nastavení';

  @override
  String get alertDetailTitle => 'Detaily pozorování';

  @override
  String reportedBy(String username) {
    return 'Nahlášeno $username';
  }

  @override
  String reportedAt(String timeAgo, Object time) {
    return 'Hlášený čas $time';
  }

  @override
  String distanceAway(String distance) {
    return 'pryč';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Ložisko objektu:  °';
  }

  @override
  String get openCompass => 'Otevřený kompas';

  @override
  String get openAR => 'Otevřené překrytí AR';

  @override
  String get openChat => 'Otevřít chat';

  @override
  String get commentsTitle => 'Poznámky';

  @override
  String get addComment => 'Přidat komentář..';

  @override
  String get send => 'Odeslat';

  @override
  String get commentPosted => 'Comment';

  @override
  String get autoFollowEnabled => 'Nyní sledujete tento poplach.';

  @override
  String get noCommentsYet =>
      'Zatím žádné komentáře. Buďte první, kdo to komentuje!';

  @override
  String get newCommentNotification =>
      'Nový komentář k pozorování, které sledujete.';

  @override
  String get mapTitle => 'Živá mapa';

  @override
  String get compassTitle => 'Kompas';

  @override
  String get compassSettings => 'Nastavení kompas';

  @override
  String get compassMode => 'Režim Compassu';

  @override
  String get compassStandardMode => 'Standardní režim';

  @override
  String get compassPilotMode => 'Režim pilota';

  @override
  String get compassStandardDescription => 'Základní název a navigace';

  @override
  String get compassPilotDescription =>
      'Pokročilá navigace s ETA a vektorováním';

  @override
  String pointingTo(String direction) {
    return 'Ukazuji na';
  }

  @override
  String get calibratingCompass => 'Kalibrační kompas..';

  @override
  String get openAROverlay => 'Otevřené překrytí AR';

  @override
  String get pushTitleAlertNearby => 'Pozor UFO blízko vás';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Bylo nahlášeno nové pozorování.';
  }

  @override
  String get pushTitleComment => 'Nový komentář';

  @override
  String get pushBodyComment => 'Někdo komentoval pozorování, které sledujete.';

  @override
  String get pushTitleWitness => 'Potvrzení svědka';

  @override
  String get temperature => 'Teplota';

  @override
  String get pushBodyWitness => 'Uživatel potvrdil, že vidí stejný objekt.';

  @override
  String get weather => 'Počasí';

  @override
  String cloudCover(int percent) {
    return 'Cloud cover: %';
  }

  @override
  String wind(num speed, String unit) {
    return 'Vítr:';
  }

  @override
  String get nearbyAircraft => 'Nedaleko letadla';

  @override
  String get noAircraft => 'Žádné letadlo poblíž';

  @override
  String get loadingContext => 'Nahrávám kontext prostředí..';

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String get notifications => 'Oznámení';

  @override
  String get enablePushNotifications => 'Získat oznámení pro budoucí komentáře';

  @override
  String get quietHours => 'Tiché hodiny';

  @override
  String get quietHoursDesc => 'Tichá upozornění mezi zvolenými hodinami.';

  @override
  String get dndMode => 'Nerušit';

  @override
  String get dndUntil => 'Nepřerušujte, dokud';

  @override
  String get language => 'Jazyk';

  @override
  String get chooseLanguage => 'Vyberte jazyk';

  @override
  String get units => 'Jednotky';

  @override
  String get unitsImperial => 'Císařský (mi, mph)';

  @override
  String get unitsMetric => 'Metrické (km, km / h)';

  @override
  String get privacyPolicy => 'Ochrana osobních údajů';

  @override
  String get termsOfUse => 'Podmínky použití';

  @override
  String get errorNoLocation =>
      'Místo není k dispozici. Zkuste to znovu venku s jasným výhledem na oblohu.';

  @override
  String get errorNoCamera => 'Kamera není na tomto zařízení k dispozici.';

  @override
  String get errorUploadFailed => 'Nahrávání selhalo. Prosím, zkuste to znovu.';

  @override
  String get errorPermissionDenied => 'Povolení zamítnuto.';

  @override
  String get errorInvalidUsername => 'To uživatelské jméno není k dispozici.';

  @override
  String get nothingToShow => 'Zatím nic.';

  @override
  String get storeShortDesc =>
      'Okamžité varování UFO. Zachycení, potvrzení a rozhovor v reálném čase.';

  @override
  String get storeLongDesc =>
      'UFOBeep posílá upozornění v reálném čase, když někdo spatří poblíž UFO. Zachytit fotografie a videa, potvrdit pozorování s klepnutím, zobrazit směr a vzdálenost, a chatovat s kolegy skywatchers.';

  @override
  String get keywords =>
      'UFO, UAP, OVNI, mimozemšťané, pozorování, Skywatch, upozornění, radar, kompas';

  @override
  String get noAlertsFound => 'Žádné odpovídající záznamy';

  @override
  String get alertsFilterHelp =>
      'Zkuste nastavit filtry, abyste viděli další výsledky';

  @override
  String get verified => 'Ověřeno';

  @override
  String get beepOnly => 'Pouze hlášení';

  @override
  String get reportOnly => 'Pouze hlášení';

  @override
  String get videoOnly => 'pouze video';

  @override
  String get imageOnly => 'pouze obrázek';

  @override
  String get mediaOnly => 'Media Only';

  @override
  String get timeJustNow => 'právě teď';

  @override
  String timeDaysAgo(int count) {
    return 'd před';
  }

  @override
  String timeHoursAgo(int count) {
    return 'h před';
  }

  @override
  String timeMinutesAgo(int count) {
    return 'm před';
  }

  @override
  String get loadMoreAlerts => 'Načíst více upozornění';

  @override
  String get toggleMufonTooltip => 'Zapnout pozorování mufonu';

  @override
  String get showMufonData => 'Zobrazit data MUFON';

  @override
  String get hideMufonData => 'Skrýt data MUFON';

  @override
  String get showingUfoBeepOnly => 'Zobrazení pouze zpráv UFOBeep';

  @override
  String get showingAllReports => 'Zobrazení všech zpráv včetně databáze MUFON';

  @override
  String get filteredSuffix => 'filtrované';

  @override
  String get detailsTitle => 'Podrobnosti';

  @override
  String get mufonCase => 'MUFON Případ';

  @override
  String get mufonSighting => 'MUFON Sighting';

  @override
  String get mufonLightSighting => 'MUFON Light Sighting';

  @override
  String get mufonSphereSighting => 'MUFON Sphere Sighting';

  @override
  String get mufonDiscSighting => 'MUFON Disc Sighting';

  @override
  String get mufonTriangleSighting => 'MUFON Triangle Sighting';

  @override
  String get mufonCigarSighting => 'MUFON Cigar Sighting';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting';

  @override
  String get mufonRectangleSighting => 'MUFON Rectangle Sighting';

  @override
  String get mufonCylinderSighting => 'MUFON Cylinder Sighting';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Sighting';

  @override
  String get mufonStarlikeSighting => 'MUFON Starlike Sighting';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Případ #  Podrobnosti';
  }

  @override
  String get sightingDate => 'Datum pozorování';

  @override
  String get mufonDatabaseEntryDate => 'Datum zařazení do MUFON Databáze';

  @override
  String get databaseEntry => 'Záznam databáze';

  @override
  String get shareLink => 'Sdílet odkaz';

  @override
  String get linkCopied => 'Odkaz zkopírován do schránky';

  @override
  String get locationLabel => 'Umístění:';

  @override
  String get distanceLabel => 'Vzdálenost';

  @override
  String get timeLabel => 'Čas:';

  @override
  String get reportedByLabel => 'Reported by';

  @override
  String get unknownLocation => 'Neznámé umístění';

  @override
  String get locationUnknown => 'Umístění není známo';

  @override
  String get witnessesLabel => 'Svědci';

  @override
  String witnessesCountMessage(int count) {
    return 'lidé potvrdili toto pozorování';
  }

  @override
  String get photoAnalysisTitle => 'Analýza fotografií';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analýza:  media soubor (y) zpracován';
  }

  @override
  String get addMoreMedia => 'Přidat více';

  @override
  String get addMedia => 'Přidat média';

  @override
  String get retakePhoto => 'Fotografie znovu';

  @override
  String get retakeVideo => 'Retake video';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galerie';

  @override
  String get basicSettings => 'Základní nastavení';

  @override
  String get appSettings => 'Nastavení aplikace';

  @override
  String get alertRange => 'Rozsah upozornění';

  @override
  String get manageNotificationsDesc => 'Správa předplatného a nastavení';

  @override
  String get permissionsTitle => 'Povolení';

  @override
  String get permissionLocation => 'Umístění';

  @override
  String get permissionCamera => 'Kamera';

  @override
  String get permissionNotifications => 'Oznámení';

  @override
  String get permissionPhotos => 'Fotografie';

  @override
  String get permissionGranted => 'Povoleno';

  @override
  String get permissionNotGranted => 'Nepřiznáno';

  @override
  String get permissionGrant => 'Grant';

  @override
  String get generateUsername => 'Vytvořit nové uživatelské jméno';

  @override
  String get adminTools => 'Admin nástroje';

  @override
  String get openAdminPanel => 'Otevřít admin panel';

  @override
  String get webAdminInterface => 'Web Admin rozhraní';

  @override
  String get adminBetaNotice =>
      'Beta jen staví. Administrátorské nástroje pro testování upozornění na blízkost, tlačení oznámení a systémové diagnostiky.';

  @override
  String get whatDoYouSee => 'Co vidíš?';

  @override
  String get ufo => 'UFO';

  @override
  String get sighting => 'Vidění';

  @override
  String get ufoSighting => 'UFO Vidění';

  @override
  String get envAnalysisTitle => 'Environmentální analýza';

  @override
  String get envAnalysisPending => 'Probíhá analýza';

  @override
  String get envAnalysisPendingDesc =>
      'Údaje o životním prostředí budou k dispozici, jakmile začne zpracování.';

  @override
  String get unknownAircraft => 'Neznámé letadlo';

  @override
  String get moreAircraft => 'více letadel';

  @override
  String get premiumImageryTitle => 'Premium Satellite Imagery';

  @override
  String get premiumImagerySubtitle => 'Obchodní obrázky s vysokým rozlišením';

  @override
  String get sightingTypeLabel => 'Typ';

  @override
  String get ufoTypeSphere => 'Koule';

  @override
  String get ufoTypeTriangle => 'Trojúhelník';

  @override
  String get ufoTypeDisk => 'Disk';

  @override
  String get ufoTypeLight => 'Světlo';

  @override
  String get ufoTypeFireball => 'Fireball';

  @override
  String get ufoTypeCylinder => 'Válec';

  @override
  String get ufoTypeCigar => 'Doutník';

  @override
  String get ufoTypeRectangle => 'Obdélník';

  @override
  String get ufoTypeFormation => 'Formace';

  @override
  String get ufoTypeUnknown => 'Neznámé';

  @override
  String get ufoTypeBoomerang => 'Bumerang';

  @override
  String get ufoTypeDiamond => 'Diamond';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Kukuřice';

  @override
  String get ufoTypeCross => 'Kříže';

  @override
  String get ufoTypeDumbbell => 'Dumbbell';

  @override
  String get ufoTypeTeardrop => 'Slza';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Kulka';

  @override
  String get ufoTypeSaturn => 'Saturn';

  @override
  String get ufoTypeStarLike => 'Star- like';

  @override
  String get ufoTypeBlimp => 'Balón';

  @override
  String get shapeTriangle => 'trojúhelník';

  @override
  String get shapeDisc => 'disk';

  @override
  String get shapeDisk => 'disk';

  @override
  String get shapeSphere => 'koule';

  @override
  String get shapeCigar => 'doutník';

  @override
  String get shapeLight => 'světlo';

  @override
  String get shapeBoomerang => 'bumerang';

  @override
  String get shapeDiamond => 'diamant';

  @override
  String get shapeRectangle => 'obdélník';

  @override
  String get shapeOval => 'ovál';

  @override
  String get shapeCone => 'kužel';

  @override
  String get shapeCross => 'kříž';

  @override
  String get shapeCylinder => 'válec';

  @override
  String get shapeDumbbell => 'dumbbell';

  @override
  String get shapeTeardrop => 'slzy';

  @override
  String get shapeTicTac => 'tick- tac';

  @override
  String get shapeBullet => 'kulka';

  @override
  String get shapeSaturn => 'saturn';

  @override
  String get shapeStarlike => 'hvězdičky';

  @override
  String get shapeBlimp => 'vzducholoď';

  @override
  String get shapeFireball => 'ohnivá koule';

  @override
  String get shapeFormation => 'tvorba';

  @override
  String get shapeUnknown => 'neznámý';

  @override
  String get actionsTitle => 'Akce';

  @override
  String get addPhotosAndVideos => 'Přidat fotografie a videa';

  @override
  String get howToReportToMufon => 'Jak podat zprávu MUFON';

  @override
  String get reportToMufon => 'Zpráva pro MUFON';

  @override
  String get whyReportToMufon => 'Proč se hlásit na MUFON?';

  @override
  String get openMufonReport => 'Open MUFON Zpráva';

  @override
  String get confirmedWitness => 'Potvrdil jste toto pozorování';

  @override
  String witnessesHaveConfirmed(int count) {
    return 'lidé potvrdili toto pozorování';
  }

  @override
  String get aircraftTrackingTitle => 'Sledování letadel';

  @override
  String get weatherConditionsTitle => 'Podmínky počasí';

  @override
  String get noSatellitePasses =>
      'Žádné viditelné satelitní propustky nalezeny';

  @override
  String get contentAnalysisTitle => 'Analýza obsahu';

  @override
  String get contentSafe => 'Obsah je bezpečný';

  @override
  String get contentFlagged => 'Obsah označený k přezkoumání';

  @override
  String get confidenceLabel => 'Důvěra';

  @override
  String get methodLabel => 'Metoda';

  @override
  String get premiumImageryAccessOnly =>
      'Premium satelitní snímky je k dispozici pouze pro:';

  @override
  String get premiumAccessCreators => 'Tvůrci výstrahy';

  @override
  String get premiumAccessWitnesses => 'Potvrzení svědci v dosahu viditelnosti';

  @override
  String get comingSoon => 'Už brzy';

  @override
  String get directionDistanceTitle => 'Směr a vzdálenost';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Případ #';
  }

  @override
  String get satellitePassesTitle => 'Satelitní průkazy';

  @override
  String get satellitePassExplanation =>
      'Viditelné satelitní propustky během časového rámce pozorování. Mnoho hlášení UFO jsou ve skutečnosti satelity nebo vesmírné trosky.';

  @override
  String get followingAlert =>
      'Po upozornění - obdržíte oznámení o komentářích';

  @override
  String get unfollowedAlert =>
      'Nesledovaná výstraha - žádné další oznámení komentářů';

  @override
  String get alertFollowError => 'Chyba při aktualizaci stavu sledování';

  @override
  String get notificationChannelAlerts => 'UFOBEep upozornění';

  @override
  String get notificationChannelAlertsDesc =>
      'Oznámení o pípnutí UFO a upozornění na blízkost';

  @override
  String get notificationSightingTitle => 'UFO Vidění';

  @override
  String get notificationSightingUrgent => 'Name Vidění';

  @override
  String get notificationSightingEmergency => 'POSLEDNÍ UFO Vidění';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return 'v blízkosti';
  }

  @override
  String notificationCommentTitle(String username) {
    return '$username komentoval';
  }

  @override
  String get notificationWitnessText => 'Nové pozorování';

  @override
  String notificationWitnessTextMultiple(int count) {
    return 'svědci';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Rozpustit';

  @override
  String notificationDistance(String distance) {
    return '$distance away';
  }

  @override
  String get unknown => 'neznámý';

  @override
  String get report => 'zpráva';

  @override
  String get mufon => 'mufon';

  @override
  String get recentUfoBeepsTitle => 'Nedávné UFO Brouci';

  @override
  String get recentUfoBeepsSubtitle =>
      'Živé zprávy komunity UFOBeep a pozorování databáze MUFON';

  @override
  String get recentUfoBeepsDescription =>
      'Toto krmivo kombinuje aktuální UFOBeep \"pípání\" od našich uživatelů mobilních aplikací s historickými zprávami z databáze MUFON.';

  @override
  String get loadingBeeps => 'Načítám poslední pípnutí...';

  @override
  String get noBeepsAvailable => 'Momentálně žádné pípání.';

  @override
  String get anomalyReported => 'Anomálie hlášena';

  @override
  String get copyShortLink => 'Kopírovat krátký odkaz';

  @override
  String get shareAlert => 'Upozornění o sdílení';

  @override
  String get previousPage => 'Předchozí';

  @override
  String get nextPage => 'Další';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Strana  of  ( total pípnutí)';
  }

  @override
  String get heroTagline =>
      'Získejte upozornění, kdy jít ven a podívat se nahoru';

  @override
  String get heroDescription =>
      'Nikdy si nenechte ujít další pozorování UFO. Získejte reálné-čas upozornění, když někdo blízko vás vidí něco divného na obloze. Namiřte telefon a najděte přesně, kde hledat.';

  @override
  String get downloadApp => 'Name';

  @override
  String get viewAllBeeps => 'Zobrazit všechny pípy';

  @override
  String get sightingsMap => 'Name';

  @override
  String get globalSightingNetwork => 'Globální síť pozorování';

  @override
  String get howItWorks => 'Jak funguje UFOBeep';

  @override
  String get backToBeeps => 'Zpět na Beeps';

  @override
  String get loadingDetails => 'Načítám detaily pípnutí...';

  @override
  String get details => 'Podrobnosti';

  @override
  String get location => 'Umístění';

  @override
  String get timeAgo => 'před';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'míle';

  @override
  String get distanceNearby => 'v blízkosti';

  @override
  String get ufobeepWitnesses => 'Svědci';

  @override
  String get ufobeepConfirmations => 'Potvrzení';

  @override
  String get ufobeepAlertLevel => 'Úroveň upozornění';

  @override
  String get ufobeepReportType => 'Zpráva UFOBeep';

  @override
  String get mufonAttribution => 'MUFON Databázová zpráva';

  @override
  String get mufonCaseNumber => 'Případ #';

  @override
  String get mufonGenericTitle => 'Zpráva o pozorování MUFON';

  @override
  String get mufonSphere => 'Koule';

  @override
  String get mufonLight => 'Světlo';

  @override
  String get mufonDisk => 'Disk';

  @override
  String get mufonTriangle => 'Trojúhelník';

  @override
  String get mufonCigar => 'Doutník';

  @override
  String get mufonOval => 'Oval';

  @override
  String get mufonCylinder => 'Válec';

  @override
  String get mufonRectangle => 'Obdélník';

  @override
  String get mufonDiamond => 'Diamond';

  @override
  String get mufonFireball => 'Fireball';

  @override
  String get mufonFlash => 'Flash';

  @override
  String get mufonFormation => 'Formace';

  @override
  String get mufonChanging => 'Změna';

  @override
  String get mufonChevron => 'Chevron';

  @override
  String get mufonCone => 'Kukuřice';

  @override
  String get mufonCross => 'Kříže';

  @override
  String get mufonEgg => 'Vejce';

  @override
  String get mufonOther => 'Předmět';

  @override
  String get mufonUnknown => 'Neznámý objekt';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON  Zpráva';
  }

  @override
  String get nuforcAttribution => 'NUFORC Databázová zpráva';

  @override
  String get nuforcCaseNumber => 'Případ #';

  @override
  String get nuforcGenericTitle => 'NUFORC Zpráva o pozorování';

  @override
  String get mediaImageNotFound => 'Obrázek nenalezen';

  @override
  String get mediaPlayVideo => 'Přehrát video';

  @override
  String get mediaViewImage => 'Zobrazit obrázek';

  @override
  String mediaCount(Object count) {
    return 'obrázky';
  }

  @override
  String get mediaCountSingle => '1 obrázek';

  @override
  String mediaMoreImages(Object count) {
    return '+  více';
  }

  @override
  String get errorNotFound => 'Píp nenalezen';

  @override
  String get errorLoadError => 'Nepodařilo se načíst detaily pípnutí';

  @override
  String get shareYourThoughts =>
      'Podělte se o své myšlenky o tomto pozorování...';

  @override
  String get postComment => 'Comment';

  @override
  String get loggedInAs => 'Přihlášen jako';

  @override
  String get logout => 'Odhlášení';

  @override
  String get notFollowing => 'Nesleduji';

  @override
  String get follow => 'Následujte';

  @override
  String get navRecentBeeps => 'Nedávný Beeps';

  @override
  String get navMap => 'Mapa';

  @override
  String get navDownloadApp => 'Stáhnout aplikaci';

  @override
  String get alertLevel => 'Úroveň upozornění';

  @override
  String get witnesses => 'Svědci';

  @override
  String get confirmations => 'Potvrzení';

  @override
  String get reporterLabel => 'Oznámený uživatelem';

  @override
  String get coordinatesLabel => 'Souřadnice';

  @override
  String get eventTime => 'Doba události';

  @override
  String get reportedTime => 'Vykazovaný čas';

  @override
  String get mufonDatabaseReport => 'MUFON Databázová zpráva';

  @override
  String get copyShortLinkTitle => 'Kopírovat odkaz do schránky';

  @override
  String get imageNotFound => 'Obrázek nenalezen';

  @override
  String get ufoSightingAlt => 'Pozorování UFO';
}
