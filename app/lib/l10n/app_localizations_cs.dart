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
    return '_ _ PLACETETERER _ 0 _ _ away';
  }

  @override
  String alertDirection(int bearing) {
    return 'Ložisko _ _ PLACETETELER _ 0 _ _ °';
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
    return 'Reported by _ _ PLACETIER _ 0 _ _';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Hlášený _ _ PLACETETERER _ 0 _ _';
  }

  @override
  String distanceAway(String distance) {
    return 'pryč';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Nošení objektu: _ _ PLACETETELER _ 0 _ _ °';
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
    return 'Ukazuje na _ _ PLACETETERER _ 0 _ _';
  }

  @override
  String get calibratingCompass => 'Kalibrační kompas..';

  @override
  String get openAROverlay => 'Otevřené překrytí AR';

  @override
  String get pushTitleAlertNearby => 'Pozor UFO blízko vás';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Bylo hlášeno nové pozorování _ _ PLACETETERER _ 0 _ _ away.';
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
    return 'Cloud cover: _ _ PLACETETERER _ 0 _ _%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Vítr: _ _ PLACETETELER _ 0 _ _ _ _ PLACETETELER _ 1 _ _';
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
  String get beepOnly => 'Pouze píp';

  @override
  String get reportOnly => 'Pouze hlášení';

  @override
  String get videoOnly => 'Pouze video';

  @override
  String get imageOnly => 'Pouze obrázek';

  @override
  String get mediaOnly => 'Pouze média';

  @override
  String get timeJustNow => 'právě teď';

  @override
  String timeDaysAgo(int count) {
    return 'Před pár dny';
  }

  @override
  String timeHoursAgo(int count) {
    return 'Před pár hodinami';
  }

  @override
  String timeMinutesAgo(int count) {
    return 'Před pár minutami';
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
  String get mufonSighting => 'Zpráva o pozorování MUFON';

  @override
  String get mufonLightSighting => 'Zpráva o pozorování světla MUFON';

  @override
  String get mufonSphereSighting => 'Zpráva o pozorování mufonové koule';

  @override
  String get mufonDiscSighting => 'MUFON Zpráva o pozorování disku';

  @override
  String get mufonTriangleSighting => 'MUFON Zpráva o pozorování trojúhelníku';

  @override
  String get mufonCigarSighting => 'Zpráva MUFON Cigar Shighting';

  @override
  String get mufonOvalSighting => 'Zpráva o pozorování Oválné pracovnice MUFON';

  @override
  String get mufonRectangleSighting => 'MUFON Zpráva o pozorování obdélníku';

  @override
  String get mufonCylinderSighting => 'Zpráva o pozorování válce MUFON';

  @override
  String get mufonBoomerangSighting => 'Zpráva MUFON Boomerang o pozorování';

  @override
  String get mufonStarlikeSighting => 'MUFON Starlike Fighting Report';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'Případ MUFON # _ _ PLACETETELER _ 0 _ _ Podrobnosti';
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
    return '_ _ PLACETETERER _ 0 _ _ lidé potvrdili toto pozorování';
  }

  @override
  String get photoAnalysisTitle => 'Analýza fotografií';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analýza: _ _ PLACETELER _ 0 _ _ media soubor (y) zpracován';
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
  String get timeFormat => 'Časový formát';

  @override
  String get timeFormat24Hour => '24 hodin (14: 30)';

  @override
  String get timeFormat12Hour => '12- hodina (14: 30)';

  @override
  String get timeFormatDesc =>
      'Doba zobrazení ve formátu 24 hodin nebo 12 hodin';

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
  String get ufoSighting => 'UFOBeep UFO Varování';

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
    return '_ _ PLACETETERER _ 0 _ _ lidé potvrdili toto pozorování';
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
    return 'MUFON Případ # _ _ PLACETIER _ 0 _ _';
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
  String get notificationSightingTitle => 'UFOBeep UFO Varování';

  @override
  String get notificationSightingUrgent => 'Name Varování';

  @override
  String get notificationSightingEmergency => 'UFO Varování';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '_ _ PLACETIER _ 0 _ _ near _ _ PLACETIER _ 1 _ _';
  }

  @override
  String notificationCommentTitle(String username) {
    return 'PLACETELER _ 0 _ _ komentáře';
  }

  @override
  String get notificationWitnessText => 'Nové pozorování';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '_ _ PLACETETELER _ 0 _ _ svědci';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Rozpustit';

  @override
  String notificationDistance(String distance) {
    return '_ _ PLACETETERER _ 0 _ _ away';
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
      'Živé zprávy o pozorování UFO z naší globální komunity';

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
    return 'Page _ _ PLACETIER _ 0 _ _ _ _ PLACETIER _ 1 _ _ (_ _ PLACETIER _ 2 _ _ celkem pípnutí)';
  }

  @override
  String get firstPage => 'První';

  @override
  String get lastPage => 'Poslední';

  @override
  String get jumpToPage => 'Přejít na stránku';

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
    return 'MUFON _ _ PLACETETELER _ 0 _ _ Zpráva';
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
    return '_ _ PLACETETELER _ 0 _ _ obrázky';
  }

  @override
  String get mediaCountSingle => '1 obrázek';

  @override
  String mediaMoreImages(Object count) {
    return '+ _ _ PLACETETELER _ 0 _ _ více';
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
  String get addedToUfobeep => 'Přidáno do UFOBeep';

  @override
  String get mufonDatabaseReport => 'MUFON Databázová zpráva';

  @override
  String get copyShortLinkTitle => 'Kopírovat odkaz do schránky';

  @override
  String get imageNotFound => 'Obrázek nenalezen';

  @override
  String get ufoSightingAlt => 'UFO Poplach proti UFO';

  @override
  String get celestialDataTitle => 'Nebeské objekty';

  @override
  String get visiblePlanets => 'Viditelné planety';

  @override
  String get locationDataTitle => 'Informace o umístění';

  @override
  String get timezone => 'Timezon';

  @override
  String get coordinates => 'Souřadnice';

  @override
  String get processingSummaryTitle => 'Shrnutí zpracování';

  @override
  String get processingTime => 'Doba zpracování';

  @override
  String get successful => 'Úspěšné';

  @override
  String get failed => 'Selhalo';

  @override
  String get locationEnrichmentTitle => 'Podrobnosti o umístění';

  @override
  String get aircraftDataSource => 'Zdroj dat';

  @override
  String get noAircraftDetected => 'Žádné letadlo nebylo detekováno';

  @override
  String get sightingReport => 'Zpráva o pozorování';

  @override
  String get ufoAlert => 'UFO Varování';

  @override
  String get alert => 'Varování';

  @override
  String get notificationTickerUfoAlert =>
      'UFO poplach - nové pozorování v blízkosti';

  @override
  String get notificationTickerComment => 'Nový komentář k UFO upozornění';

  @override
  String get weatherConditions => 'Podmínky počasí';

  @override
  String get visibility => 'Viditelnost';

  @override
  String get humidity => 'Vlhkost';

  @override
  String get pressure => 'Tlak';

  @override
  String get locationDetails => 'Podrobnosti o umístění';

  @override
  String get city => 'Město';

  @override
  String get state => 'Stát';

  @override
  String get country => 'Země';

  @override
  String get satelliteActivity => 'Satelitní činnost';

  @override
  String get satellitesVisibleOverhead =>
      'Satelity viditelné nad hlavou při pozorování času a umístění';

  @override
  String get dataSource => 'Zdroj dat';

  @override
  String get blackskyImagery => 'BlackSky Imagery';

  @override
  String get resolution => 'Usnesení';

  @override
  String get groundResolution => '35 cm zemského rozlišení';

  @override
  String get delivery => 'Dodávka';

  @override
  String get averageDelivery => 'průměr 90 minut';

  @override
  String get cost => 'Náklady';

  @override
  String get skyfiSatelliteImagery => 'SkyFi satelit Imagery';

  @override
  String get region => 'Oblast';

  @override
  String get remoteArea => 'Vzdálená oblast';

  @override
  String get startingPrice => 'Počáteční cena';

  @override
  String get coverage => 'Pokrytí';

  @override
  String get confidenceCoverage => '95% jistota';

  @override
  String get status => 'Stav';

  @override
  String get shareThoughts => 'Podělte se o své myšlenky o tomto pozorování...';

  @override
  String get postCommand => 'Poštovní příkaz';

  @override
  String get clouds => 'Mraky';

  @override
  String get windLabel => 'Vítr';
}
