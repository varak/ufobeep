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
    return 'Ložisko $bearing°';
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
  String get locationPermissionTitle => 'Vyžadováno povolení k umístění';

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
    return 'Reported by $username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Hlášený $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '$distance';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Azimut k objektu: $bearing°';
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
    return 'Ukazuje na $direction';
  }

  @override
  String get calibratingCompass => 'Kalibrační kompas..';

  @override
  String get openAROverlay => 'Otevřené překrytí AR';

  @override
  String get pushTitleAlertNearby => 'Pozor UFO blízko vás';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Bylo hlášeno nové pozorování $distance away.';
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
    return 'Cloud cover: $percent%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Vítr: $speed $unit';
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
  String get quietHoursEnabled => 'Povolit tiché hodiny';

  @override
  String get quietHoursFrom => 'Od';

  @override
  String get quietHoursUntil => 'Dokud';

  @override
  String get quietHoursDefaultTime => 'Výchozí tiché hodiny';

  @override
  String get emergencyOverride => 'Nouzové ukončení';

  @override
  String get emergencyOverrideDesc =>
      'Povolit urgentní upozornění během klidných hodin';

  @override
  String get dndMode => 'Nerušit';

  @override
  String get dndUntil => 'Nepřerušujte, dokud';

  @override
  String dndEnabled(Object time) {
    return 'DND povoleno do $time';
  }

  @override
  String get dndDisabled => 'DND vypnuto';

  @override
  String quietHoursActive(String startTime, String endTime) {
    return 'Active $startTime - $endTime';
  }

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Tiché hodiny: $start - $end';
  }

  @override
  String get pushNotificationUfoAlert => 'UFO Varování';

  @override
  String get pushNotificationAnomalyAlert => 'Anomální poplach';

  @override
  String get pushNotificationNearby => 'Blízko';

  @override
  String get pushNotificationInYourArea =>
      've vaší oblasti. Klepněte na možnost Zobrazit detaily.';

  @override
  String pushNotificationCommented(Object username) {
    return '$username komentáře';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '$username komentuje $beepTitle';
  }

  @override
  String get pushNotificationGeneric => 'UFOBEep';

  @override
  String get pushNotificationNewSighting => 'Nové pozorování v blízkosti';

  @override
  String get language => 'Jazyk';

  @override
  String get chooseLanguage => 'Vyberte jazyk';

  @override
  String get units => 'Jednotky';

  @override
  String get unitsImperial => 'Císařský';

  @override
  String get unitsMetric => 'Metrické';

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
  String get reportOnly => 'Pouze text';

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
    return 'Případ MUFON #$caseNumber Podrobnosti';
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
    return '$count lidé potvrdili toto pozorování';
  }

  @override
  String get photoAnalysisTitle => 'Analýza fotografií';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analýza: $count media soubor (y) zpracován';
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
  String get timeFormat24Hour => '24 hodin';

  @override
  String get timeFormat12Hour => '12 hodin';

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
  String get showLess => 'Zobrazit méně';

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
  String get attachMedia => 'Připojit média';

  @override
  String get addCommentOptional => 'Přidat komentář (nepovinné)';

  @override
  String get describeNewMedia => 'Popište nová média...';

  @override
  String get filesSelected => 'vybrané soubory';

  @override
  String get selectMediaToAttach =>
      'Prosím vyberte fotografie nebo videa k připojení';

  @override
  String get newMediaUploaded => 'Nová média nahraná';

  @override
  String get mediaFilesUploaded => 'nahrané nové soubory médií';

  @override
  String get filesAttachedSuccessfully => 'úspěšně připojené soubory';

  @override
  String get howToReportToMufon => 'Jak podat zprávu MUFON';

  @override
  String get reportToMufon => 'Zpráva pro MUFON';

  @override
  String get whyReportToMufon => 'Proč se hlásit na MUFON?';

  @override
  String get openMufonReport => 'Open MUFON Zpráva';

  @override
  String get howToFormallyReport => 'Jak Formálně podat zprávu';

  @override
  String get formalReportingTitle => 'Formální UFO Podávání zpráv';

  @override
  String get ufobeepVsFormalReporting => 'UFOBeep vs Formální hlášení';

  @override
  String get versus => 'vs';

  @override
  String get formalReporting => 'Formální vykazování';

  @override
  String get reportingOrganizations => 'Zpravodajské organizace';

  @override
  String get ufobeepRealtimeExplanation =>
      'UFOBeep je určen pro upozornění v reálném čase - pomáhá blízkým svědkům okamžitě se připojit, aby ověřili, co právě vidí.';

  @override
  String get formalReportingExplanation =>
      'Pro oficiální vyšetřování a vědeckou dokumentaci můžete podat formální zprávy se zavedenými výzkumnými organizacemi.';

  @override
  String get mufonFullName => 'MUFON (síť vzájemných UFO)';

  @override
  String get mufonDescription =>
      'Největší světová organizace pro vyšetřování UFO s profesionálními terénními vyšetřovateli a vědeckou dokumentací.';

  @override
  String get nuforcFullName => 'NUFORC (Národní centrum pro hlášení UFO)';

  @override
  String get nuforcDescription =>
      'V provozu od roku 1974, NUFORC udržuje komplexní veřejnou databázi pozorování UFO.';

  @override
  String get whatToExpect => 'Co očekávat';

  @override
  String get formalReportRequirements =>
      'Formální zprávy obvykle vyžadují:\n• Podrobná doba, datum a doba trvání\n• Podmínky a viditelnost počasí\n• Úplné svědectví svědka\n• Fotografie nebo video, pokud jsou k dispozici\n\nOrganizace mohou sledovat další podrobnosti. Vaše zpráva přispívá k probíhajícímu výzkumu UFO.';

  @override
  String get confirmedWitness => 'Potvrdil jste toto pozorování';

  @override
  String witnessesHaveConfirmed(int count) {
    return '$count lidé potvrdili toto pozorování';
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
    return 'MUFON Případ #$caseNumber';
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
    return '$witnessText near $locationName';
  }

  @override
  String notificationCommentTitle(String username) {
    return '$username komentáře';
  }

  @override
  String get notificationWitnessText => 'Nové pozorování';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '$count svědci';
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
  String get unknown => 'Neznámé';

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
  String get ufoSightingAlert => 'UFO Upozornění na pozorování';

  @override
  String get previousPage => 'Předchozí';

  @override
  String get nextPage => 'Další';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Page $currentPage $totalPages ($totalCount celkem pípnutí)';
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
      'Nikdy si nenechte ujít další pozorování UFO ve vaší oblasti';

  @override
  String get downloadApp => 'Name';

  @override
  String get viewAllBeeps => 'Zobrazit všechny pípy';

  @override
  String get sightingsMap => 'Name';

  @override
  String get globalSightingNetwork => 'Globální síť pozorování';

  @override
  String get howItWorks => 'Jak to funguje';

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
    return 'MUFON $classification Zpráva';
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
    return '$count obrázky';
  }

  @override
  String get mediaCountSingle => '1 obrázek';

  @override
  String mediaMoreImages(Object count) {
    return '+$count více';
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
  String get mufonDatabaseReport => 'MUFON Číslo případu:';

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

  @override
  String get filterAlerts => 'Comment';

  @override
  String get alertSource => 'Zdroj upozornění';

  @override
  String get ufobeepOnly => 'Pouze UFOBeep';

  @override
  String get ufobeepOnlyDescription =>
      'Zobrazit pouze originální UFOBeep reporty (bez databáze MUFON)';

  @override
  String get alertDistanceRange => 'Varovné vzdálenosti';

  @override
  String get showAllAlerts => 'Zobrazit všechny záznamy';

  @override
  String get showAll => 'Zobrazit vše';

  @override
  String get distanceSliderDescription =>
      'Přetáhněte nastavit, jak daleko chcete vidět upozornění. Začněte od meteorologické dohlednosti až po zobrazení všech záznamů bez ohledu na vzdálenost.';

  @override
  String get applyFilters => 'Aplikovat filtry';

  @override
  String get notificationRange => 'Rozsah oznámení';

  @override
  String get notificationRangeDescription =>
      'Získejte upozornění pro pozorování v této vzdálenosti';

  @override
  String get viewingRange => 'Prohlížení rozsahu';

  @override
  String get viewingRangeDescription =>
      'Zobrazit pozorování v této vzdálenosti při prohlížení';

  @override
  String get weatherVisibility => 'Viditelnost počasí (~ 10 km)';

  @override
  String get localArea => 'Místní oblast (25km)';

  @override
  String get regional => 'Regionální';

  @override
  String get pushNotifications => 'Stiskněte oznámení';

  @override
  String get alertBrowsing => 'Name';

  @override
  String get pushAlertsWithinDistance =>
      'Získat oznámení v rámci tohoto rozsahu';

  @override
  String get showAlertsWhenBrowsing => 'Filtrovat to, co vidíte v seznamu';

  @override
  String get heroMainTagline =>
      'Zapípněte si na telefon, když je poblíž spatřeno UFO';

  @override
  String get heroSecondaryTagline => 'Zjistěte, kdy a kde se dívat na oblohu';

  @override
  String get sourceFilters => 'Zdroj';

  @override
  String get sourceFiltersDescription =>
      'Vyberte si, které zprávy se objeví ve vašem krmivu';

  @override
  String get ufobeepAndMufon => 'UFOBEep + MUFON';

  @override
  String get ufobeepOnlySource => 'Pouze UFOBeep';

  @override
  String get mufonOnlySource => 'Pouze mufon';

  @override
  String get browseFilters => 'Procházet';

  @override
  String get browseFiltersDescription => 'Jak zobrazit a třídit záznamy';

  @override
  String get sortByNewest => 'Nejnovější';

  @override
  String get sortByNearest => 'Nejbližší';

  @override
  String get sortBy => 'Řadit podle';

  @override
  String get pushAlertsTitle => 'Tlačit výstrahy';

  @override
  String get pushAlertsDescription => 'What ping your phone';

  @override
  String get alertRadius => 'Alarm radius';

  @override
  String get mufonNoPushInfo =>
      'Zprávy MUFON jsou dováženy v noci a nespouštějí upozornění na tlačení';

  @override
  String get privacyData => 'Ochrana osobních údajů';

  @override
  String get privacyPolicyDesc => 'Jak chránit a používat Vaše údaje';

  @override
  String get termsOfService => 'Podmínky služby';

  @override
  String get termsOfServiceDesc => 'Právní podmínky';

  @override
  String get locationTracking => 'Sledování polohy';

  @override
  String get locationTrackingDesc => 'Umístění pozadí pro výstrahy v blízkosti';

  @override
  String get locationTrackingTitle => 'Sledování polohy pozadí';

  @override
  String get locationTrackingExplanation =>
      'UFOBeep sleduje vaši polohu v pozadí poslat vám blízkost upozornění, když pozorování UFO se stane v blízkosti vaší současné polohy, i když jste daleko od domova.';

  @override
  String get locationTrackingBattery =>
      'Používá inteligentní geokompresi pro < 3% dopad baterie';

  @override
  String get backgroundLocationTracking => 'Povolit pozadí Sledování';

  @override
  String get locationTrackingActive => 'Místo sledování výstrah v blízkosti';

  @override
  String get locationTrackingInactive => 'Sledování polohy je zakázáno';

  @override
  String get locationTrackingDisabledWarning =>
      'Když se přestěhujete na nová místa, nedostanete upozornění na blízkost';

  @override
  String get trackingStatus => 'Stav sledování';

  @override
  String get monitoringStatus => 'Sledování';

  @override
  String get active => 'Aktivní';

  @override
  String get inactive => 'Neaktivní';

  @override
  String get lastKnownLocation => 'Poslední známé místo';

  @override
  String get lastLocationUpdate => 'Poslední aktualizace';

  @override
  String get movementThreshold => 'Prahová hodnota pohybu';

  @override
  String get updateFrequency => 'Aktualizovat frekvenci';

  @override
  String get batteryImpact => 'Dopad baterie';

  @override
  String get dataPrivacy => 'Ochrana osobních údajů';

  @override
  String get locationPermissionExplanation =>
      'UFOBeep potřebuje \'Vždy povolit\' povolení k monitorování vašeho pohybu a odeslat upozornění na blízkost, když jste na nových místech.';

  @override
  String get benefitsTitle => 'Dávky';

  @override
  String get locationTrackingBenefits =>
      '• Získejte UFO upozornění všude, kde cestujete\n• Automatické aktualizace polohy\n• Není nutné ruční nastavení';

  @override
  String get allowLocationAccess => 'Povolit přístup k umístění';

  @override
  String get locationPermissionRequired =>
      'Pro sledování pozadí je vyžadováno povolení k umístění';

  @override
  String get locationTrackingEnabled => 'Sledování polohy pozadí povoleno';

  @override
  String get locationTrackingDisabled => 'Sledování polohy pozadí zakázáno';

  @override
  String get justNow => 'Právě teď';

  @override
  String minutesAgo(int minutes) {
    return '$minutes Před pár minutami';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours Před pár hodinami';
  }

  @override
  String daysAgo(int days) {
    return '$days Před pár dny';
  }

  @override
  String get dataManagement => 'Správa dat';

  @override
  String get dataManagementDesc => 'Exportovat nebo smazat data vašeho účtu';

  @override
  String get splashTagline => 'Záznamy v reálném čase';

  @override
  String get splashStartingUp => 'Začínám...';

  @override
  String get splashInitializationFailed => 'Inicializace selhala';

  @override
  String get splashInitializationFailedTitle => 'Inicializace selhala';

  @override
  String get splashInitializationError =>
      'Aplikace nebyla správně inicializována:';

  @override
  String get splashRetry => 'Znovu';

  @override
  String get splashContinue => 'Pokračovat';

  @override
  String get splashInitializing => 'Inicializace...';

  @override
  String signInWelcome(String username) {
    return 'Vítejte $username!';
  }

  @override
  String signInFailed(String error) {
    return 'Sign- in selhalo: $error';
  }

  @override
  String get signInPleaseEnterEmail => 'Zadejte prosím svou emailovou adresu';

  @override
  String get signInPleaseEnterValidEmail =>
      'Zadejte prosím platnou e-mailovou adresu';

  @override
  String get signInMagicLinkSent =>
      'Magické spojení odesláno! Zkontrolujte svůj e-mail a klepněte na odkaz se přihlásit.';

  @override
  String get signInMagicLinkFailed =>
      'Nepodařilo se odeslat magický odkaz. Prosím, zkuste to znovu.';

  @override
  String get signInAllDataCleared => 'Všechny údaje vymazány';

  @override
  String get signInSubtitle =>
      'Záznamy o pozorování UFO v reálném čase a zprávy MUFON';

  @override
  String get signInGoogleLoading => 'Přihlašuji...';

  @override
  String get signInContinueWithGoogle => 'Pokračovat s Google';

  @override
  String get signInOr => 'nebo';

  @override
  String get signInWithEmail => 'Přihlaste se e-mailem';

  @override
  String get signInEmailDescription => 'Pošleme vám zabezpečené spojení';

  @override
  String get signInEmailAddress => 'E-mailová adresa';

  @override
  String get signInEmailPlaceholder => 'your @ email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'Zkuste to znovu v $seconds s';
  }

  @override
  String get signInSending => 'Posílám...';

  @override
  String get signInSendMagicLink => 'Poslat magický odkaz';

  @override
  String get signInCheckEmail =>
      'Zkontrolujte si e-mail! Spojení vyprší za 15 minut.';

  @override
  String get signInSecureAuth => 'Zajistit autentizaci';

  @override
  String get signInSecureAuthDescription =>
      'Použijte Google Sign- In pro okamžitý přístup, nebo e-mailové magické odkazy, které vyprší za 15 minut.';

  @override
  String get signInClearAllDataDebug => 'Vyčistit všechna data (ladit)';

  @override
  String get emailAuthFailedToSend => 'Nepodařilo se odeslat email';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'Nepodařilo se mi poslat email. Prosím, zkuste to znovu.';

  @override
  String get emailAuthInvalidEmail =>
      'Neplatná e-mailová adresa. Zkontrolujte prosím formát.';

  @override
  String get emailAuthUserNotFound =>
      'S touto e-mailovou adresou není nalezen žádný účet.';

  @override
  String get emailAuthTooManyRequests =>
      'Příliš mnoho pokusů. Prosím, zkuste to později.';

  @override
  String get emailAuthOperationNotAllowed => 'Sign- in není povolen.';

  @override
  String get emailAuthQuotaExceeded =>
      'E-mailová kvóta překročena. Prosím, zkuste to zítra znovu.';

  @override
  String get emailAuthVerificationFailed =>
      'Ověření e-mailu selhalo. Prosím, zkuste to znovu.';

  @override
  String get emailAuthTitle => 'Ověření e-mailu';

  @override
  String get emailAuthVerifyYourEmail => 'Ověřte svůj e-mail';

  @override
  String get emailAuthDescription =>
      'Přidejte svou e-mailovou adresu pro obnovu účtu a zabezpečení. Pošleme vám zabezpečený signál.';

  @override
  String get emailAuthEmailAddress => 'E-mailová adresa';

  @override
  String get emailAuthEmailPlaceholder => 'your.email @ example.com';

  @override
  String get emailAuthPleaseEnterEmail =>
      'Zadejte prosím svou emailovou adresu';

  @override
  String get emailAuthPleaseEnterValidEmail =>
      'Zadejte prosím platnou e-mailovou adresu';

  @override
  String get emailAuthCheckEmailToContinue =>
      'Zkontrolujte svůj e-mail a klepněte na ověřovací odkaz pokračovat.';

  @override
  String get emailAuthResendEmail => 'Resend Email';

  @override
  String get emailAuthSendVerificationEmail => 'Odeslat ověření E-mail';

  @override
  String get emailAuthHowItWorks => 'Jak funguje e-mailové ověřování';

  @override
  String get emailAuthHowItWorksSteps =>
      '1. Posíláme vám zabezpečený signál.\n2. Zkontrolujte svůj e-mail a klepněte na odkaz\n3. Váš e-mail se ověřuje automaticky\n4. Není potřeba hesla!';

  @override
  String get emailAuthSecurityNotice =>
      'Ověření e-mailu pomáhá zabezpečit váš účet a umožňuje obnovení účtu, pokud ztratíte přístup ke svému zařízení.';

  @override
  String get phoneAuthFailedToSendCode =>
      'Nepodařilo se odeslat ověřovací kód. Prosím, zkuste to znovu.';

  @override
  String get phoneAuthInvalidCodeTryAgain =>
      'Neplatný ověřovací kód. Prosím, zkuste to znovu.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'Číslo telefonu ověřeno: $phoneNumber';
  }

  @override
  String get phoneAuthVerificationFailed =>
      'Ověření telefonu selhalo. Prosím, zkuste to znovu.';

  @override
  String get phoneAuthCodeResent => 'Kód ověření je nepřípustný';

  @override
  String get phoneAuthFailedToResendCode =>
      'Nepodařilo se mi obnovit kód. Prosím, zkuste to znovu.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'Neplatné telefonní číslo. Zkontrolujte prosím formát.';

  @override
  String get phoneAuthTooManyRequests =>
      'Příliš mnoho pokusů. Prosím, zkuste to později.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'Neplatný ověřovací kód. Prosím zkontrolujte to a zkuste to znovu.';

  @override
  String get phoneAuthSessionExpired =>
      'Ověření vypršelo. Vyžádejte si nový kód.';

  @override
  String get phoneAuthSmsQuotaExceeded =>
      'Překročená SMS kvóta. Prosím, zkuste to zítra znovu.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'Toto telefonní číslo je již připojeno k jinému účtu.';

  @override
  String get phoneAuthVerificationFailedGeneric =>
      'Ověření selhalo. Prosím, zkuste to znovu.';

  @override
  String get phoneAuthTitle => 'Ověření telefonu';

  @override
  String get phoneAuthVerifyYourPhone => 'Ověřte svůj telefon';

  @override
  String get phoneAuthEnterVerificationCode => 'Zadejte ověření Kód';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'Přidat své telefonní číslo pro obnovení účtu a zabezpečení';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return 'Zadejte 6místný kód odeslaný na $phoneNumber';
  }

  @override
  String get phoneAuthPhoneNumber => 'Číslo telefonu';

  @override
  String get phoneAuthPhonePlaceholder => '+ 1 (55) 123- 4567';

  @override
  String get phoneAuthPleaseEnterPhone => 'Zadejte prosím své telefonní číslo';

  @override
  String get phoneAuthPleaseEnterValidPhone =>
      'Zadejte prosím platné telefonní číslo';

  @override
  String get phoneAuthVerificationCode => 'Kód ověření';

  @override
  String get phoneAuthPleaseEnterSixDigitCode => 'Zadejte prosím 6místný kód';

  @override
  String get phoneAuthResendCode => 'Kód záznamu';

  @override
  String get phoneAuthSendVerificationCode => 'Odeslat ověření Kód';

  @override
  String get phoneAuthVerifyCode => 'Ověřit kód';

  @override
  String get phoneAuthChangePhoneNumber => 'Změnit telefonní číslo';

  @override
  String get phoneAuthSmsNotice =>
      'Pošleme vám ověřovací kód přes SMS. Mohou se použít standardní sazby zpráv.';

  @override
  String get phoneAuthCodeExpires =>
      'Kód vyprší za 60 sekund. Zkontrolujte si vzkazy.';

  @override
  String get yourDataRights => 'Vaše práva k údajům';

  @override
  String get dataRightsExplanation =>
      'Máte plnou kontrolu nad vašimi osobními údaji. Všechny své údaje můžete kdykoli exportovat nebo trvale smazat.';

  @override
  String get exportYourData => 'Exportovat Vaše data';

  @override
  String get exportDataDescription => 'Stáhnout všechna data vašeho účtu';

  @override
  String get exportData => 'Exportovat údaje';

  @override
  String get exportingData => 'Vývoz...';

  @override
  String get exportDataDetails =>
      'Zahrnuje: profil, pípnutí, komentáře, informace o zařízení a preference. Údaje jsou poskytovány ve formátu JSON.';

  @override
  String get dataExportedSuccessfully => 'Úspěšně exportované údaje';

  @override
  String get dataExportFailed => 'Nepodařilo se exportovat data';

  @override
  String get deleteAccount => 'Smazat účet';

  @override
  String get deleteAccountDescription =>
      'Trvale odstranit váš účet a všechny údaje';

  @override
  String get deleteAccountWarning =>
      'Tuto akci nelze odčinit. Všechny vaše pípnutí, komentáře a údaje o účtu budou trvale vymazány.';

  @override
  String get deleteMyAccount => 'Smazat můj účet';

  @override
  String get deletingAccount => 'Mazání...';

  @override
  String get deleteAccountConfirmTitle => 'Smazat účet';

  @override
  String get deleteAccountConfirmMessage =>
      'Jste si naprosto jisti, že chcete smazat svůj účet? Tato akce je trvalá a nelze ji odčinit.';

  @override
  String get dataWillBeDeleted => 'Následující údaje budou trvale vymazány:';

  @override
  String get deletedDataList =>
      '• Váš profil a uživatelské jméno\n• Všechny vaše pípnutí a zprávy\n• Všechny vaše komentáře\n• Údaje o registraci zařízení\n• Umístění a preference dat';

  @override
  String get deleteAccountPermanent => 'Smazat trvale';

  @override
  String get accountDeletedSuccessfully => 'Účet úspěšně vymazán';

  @override
  String get accountDeletionFailed => 'Nepodařilo se odstranit účet';

  @override
  String get onboardingWelcomeTitle => 'Vítejte v UFOBeepu';

  @override
  String get onboardingWelcomeBody =>
      'Získejte upozornění v reálném čase, když jsou poblíž spatřeni UFO. Už nikdy nezmeškej pozorování.';

  @override
  String get onboardingAlertsTitle => 'Zůstaňte informováni';

  @override
  String get onboardingAlertsBody =>
      'Nastavte, jak daleko by měla být pozorování, aby spustila výstrahy.';

  @override
  String get onboardingReportTitle => 'Vidíš něco? Píp to!';

  @override
  String get onboardingReportBody =>
      'Snap fotografie nebo videa a sdílet okamžitě s blízkými pozorovateli.';

  @override
  String get onboardingPermissionsTitle => 'Vaše kamera & umístění';

  @override
  String get onboardingPermissionsBody =>
      'Povolit fotoaparát, umístění a upozornění, takže můžete:\n- Hlášení pozorování rychle\n- Získejte upozornění pro UFO blízko vás';

  @override
  String get onboardingCameraTitle => 'Důkazy o chycení';

  @override
  String get onboardingCameraBody =>
      'Sdílet fotografie a videa, které jste právě zachytili z vaší galerie nebo dlouhotrvající-stiskněte ikonu UFOBeep pro spuštění v režimu okamžité kamery.';

  @override
  String get onboardingCompassTitle => 'Uvidíme, kde budou hledat';

  @override
  String get onboardingCompassBody =>
      'Kompas ukazuje přesný směr, kterým se svědek díval, když viděl UFO. Namiř telefon a podívej se!';

  @override
  String get onboardingCommunityTitle => 'Připojte se k Skywatchers';

  @override
  String get onboardingCommunityBody =>
      'Procházení pozorování, přístup k hlášení MUFON, a připojit se k kolegům skywatchers.';

  @override
  String get skip => 'Přeskočit';

  @override
  String get getStarted => 'Začít';

  @override
  String get viewOnboardingAgain => 'Zobrazit Znovu na palubě';

  @override
  String get customAlertRange => 'Vlastní rozsah upozornění';

  @override
  String get enterRangeKm => 'Zadejte rozsah v km (1-99999)';

  @override
  String get largeRangeWarning =>
      'Velké rozsahy (> 100 km) mohou generovat mnoho záznamů';

  @override
  String get globalRangeWarning =>
      'Velmi velké rozsahy (> 1000km) vám pošle upozornění z celého světa';

  @override
  String get invalidRange => 'Zadejte prosím číslo mezi 1 a 99999';

  @override
  String get celestialSunDaylight =>
      'Slunce je nahoře - denní podmínky mohou ovlivnit viditelnost pozorování';

  @override
  String get celestialSunTwilight =>
      'Twilight podmínky - některá viditelnost, ale tmavší než denní světlo';

  @override
  String get celestialSunDark =>
      'Tmavé podmínky - optimální pro pozorování objektů na obloze';

  @override
  String celestialMoonBright(Object phase) {
    return 'Bright $phase měsíc viditelný - může osvětlit nebo zakrýt jiné objekty';
  }

  @override
  String celestialMoonModerate(Object phase) {
    return '$phase měsíc viditelný - mírné světelné podmínky';
  }

  @override
  String celestialMoonThin(Object phase) {
    return 'Tenký $phase měsíc viditelný - minimální osvětlení';
  }

  @override
  String celestialMoonHidden(Object phase) {
    return '$phase měsíc pod horizontem - žádné měsíční osvětlení';
  }

  @override
  String get celestialNoPlanets =>
      'Žádné jasné planety viditelné, které by mohly být zaměněny za UFO';

  @override
  String celestialPlanetHigh(Object altitude, Object planet) {
    return '$planet vysoký režijní náklady ($altitude°) - velmi prominentní';
  }

  @override
  String celestialPlanetMedium(Object altitude, Object planet) {
    return '$planet viditelný v $altitude° - může být zaměněn za letadlo';
  }

  @override
  String celestialPlanetLow(Object altitude, Object planet) {
    return '$planet low on obzor ($altitude°)';
  }

  @override
  String get celestialNoStars => 'Žádné neobvykle jasné hvězdy viditelné';

  @override
  String celestialStarSingle(Object altitude, Object star) {
    return '$star prominentní v $altitude° nadmořská výška';
  }

  @override
  String celestialStarsMultiple(Object count, Object names) {
    return '$count jasné hvězdy viditelné - $names';
  }

  @override
  String get celestialSummaryDaylight => 'Podmínky denního světla';

  @override
  String get celestialSummaryDark => 'Podmínky temné oblohy';

  @override
  String get celestialSummaryMoonUp => 'přítomné měsíční osvětlení';

  @override
  String get celestialSummaryMoonDown => 'žádné měsíční osvětlení';

  @override
  String celestialSummaryManyObjects(Object count) {
    return '$count jasné objekty, které by mohly být zaměněny s UFO';
  }

  @override
  String celestialSummarySomeObjects(Object count) {
    return '$count jasný objekt (y) viditelný';
  }

  @override
  String get celestialSummaryFewObjects => 'minimální jasné objekty na obloze';

  @override
  String celestialSkySummary(Object conditions) {
    return 'Sky podmínky: $conditions';
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
  String get planetMercury => 'Rtuť';

  @override
  String get planetUranus => 'Uran';

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
  String get starCapella => 'Kapella';

  @override
  String get starRigel => 'Pevnost';

  @override
  String get starProcyon => 'Procyon';

  @override
  String get starBetelgeuse => 'Betelgeuse';

  @override
  String get moonPhaseNew => 'Nový měsíc';

  @override
  String get moonPhaseWaxingCrescent => 'Voskovací půlměsíc';

  @override
  String get moonPhaseFirstQuarter => 'První čtvrtletí';

  @override
  String get moonPhaseWaxingGibbous => 'Voskování Gibbouse';

  @override
  String get moonPhaseFull => 'Celý měsíc';

  @override
  String get moonPhaseWaningGibbous => 'Zatracení Gibbous';

  @override
  String get moonPhaseThirdQuarter => 'Třetí čtvrtletí';

  @override
  String get moonPhaseWaningCrescent => 'Zapadající půlměsíc';

  @override
  String planetBelowHorizon(Object planet) {
    return '$planet pod horizontem';
  }

  @override
  String planetHighOverheadProminent(Object altitude, Object planet) {
    return '$planet vysoký režijní náklady ($altitude°) - velmi prominentní';
  }

  @override
  String planetMidSkyProminent(Object altitude, Object planet) {
    return '$planet at $altitude° - prominentní';
  }

  @override
  String planetMidSky(Object altitude, Object planet) {
    return '$planet at $altitude°';
  }

  @override
  String starVeryBright(Object altitude, Object star) {
    return '$star velmi jasný na $altitude°';
  }

  @override
  String starProminent(Object altitude, Object star) {
    return '$star prominentní v $altitude° nadmořská výška';
  }

  @override
  String starVisible(Object altitude, Object star) {
    return '$star at $altitude°';
  }

  @override
  String get altitudeShort => 'Alt';

  @override
  String get magnitudeShort => 'Mag';

  @override
  String satellitesVisibleMightExplain(Object count) {
    return '$count satelity viditelné - může vysvětlit pozorování';
  }

  @override
  String satellitesVisibleUnlikelyExplain(Object count) {
    return '$count satelity viditelné - pravděpodobně nevysvětluje pozorování';
  }

  @override
  String get noSatellitesVisible => 'Žádné viditelné družice';

  @override
  String aircraftDetectedInRadius(Object count, Object radius) {
    return '$count zjištěná letadla $radius km';
  }

  @override
  String get processingAlert => 'Zpracování UFO...';

  @override
  String get analyzingEnvironment => 'Analýza podmínek prostředí';

  @override
  String get weatherAnalysis => 'Analýza počasí';

  @override
  String get locationAnalysis => 'Analýza umístění';

  @override
  String get aircraftTracking => 'Sledování letadel';

  @override
  String get satelliteAnalysis => 'Satelitní analýza';

  @override
  String get celestialAnalysis => 'Nebeská analýza';

  @override
  String analyzing(Object processor) {
    return 'Analyzuji $processor...';
  }

  @override
  String get processorWeather => 'povětrnostní podmínky';

  @override
  String get processorLocation => 'údaje o umístění';

  @override
  String get processorAircraft => 'v blízkosti letadla';

  @override
  String get processorSatellites => 'družicové pozice';

  @override
  String get processorCelestial => 'nebeské objekty';

  @override
  String get calculatingCelestialData => 'Vypočítávám nebeská data...';

  @override
  String get sunLabel => 'Slunce';

  @override
  String get moonLabel => 'Měsíc';

  @override
  String planetsVisible(int count) {
    return 'Planety: $count viditelný';
  }

  @override
  String get starsLabel => 'Hvězdy';

  @override
  String get planetsLabel => 'Planety';

  @override
  String moonWithPhase(String phase) {
    return 'Měsíční ($phase)';
  }

  @override
  String get noSatellitesVisibleAtTime =>
      'Žádné satelity nebyly viditelné v přesný čas vašeho pozorování';

  @override
  String get satellitesVisibleOverheadAtTime =>
      'Satelity viditelné nad hlavou při pozorování času a umístění';

  @override
  String get belowHorizon => 'pod horizontem';

  @override
  String get analysisFailedGeneric => 'Analýza selhala';

  @override
  String get unknownWeather => 'Neznámé';

  @override
  String get noWeatherDescription => 'Bez popisu';

  @override
  String get altitudeAbbrev => 'Alt';

  @override
  String get azimuthAbbrev => 'Az';

  @override
  String satellitesVisibleNow(int count) {
    return 'Satelity ($count viditelné nyní)';
  }

  @override
  String sunWithDescription(String description) {
    return 'Sun: $description';
  }

  @override
  String moonWithDescription(String description) {
    return 'Měsíc: $description';
  }

  @override
  String get unknownPlanet => 'Neznámá planeta';

  @override
  String get unknownStar => 'Neznámá hvězda';

  @override
  String get unknownSatellite => 'Neznámý satelit';

  @override
  String get unknownDirection => 'neznámý směr';

  @override
  String get brightStars => 'Světlé hvězdy';

  @override
  String get satellites => 'Satelity';

  @override
  String seeAllSatellites(int count) {
    return 'Viz všechny $count satelity';
  }

  @override
  String maxElevation(String degrees) {
    return 'Maximální výška: $degrees°';
  }

  @override
  String magnitude(String value) {
    return 'Velikost: $value';
  }

  @override
  String get unknownGeneric => 'Neznámé';

  @override
  String altitudeValue(String degrees) {
    return '$degrees° nadmořská výška';
  }

  @override
  String azimuthValue(String degrees) {
    return '$degrees° azimut';
  }

  @override
  String get noCelestialDataAvailable =>
      'Nejsou k dispozici žádné nebeské údaje.';

  @override
  String get gettingLocation => 'Získávám vaši pozici...';

  @override
  String get media => 'Média';

  @override
  String get locationRequired => 'Požadované umístění';

  @override
  String get confirmingWitness => 'Potvrzuji svědka...';

  @override
  String get chooseYourUsername => 'Vyberte si uživatelské jméno';

  @override
  String get moreNames => 'Další jména';

  @override
  String get notificationSettings => 'Nastavení oznámení';

  @override
  String get quickActions => 'Rychlé akce';

  @override
  String get doNotDisturb => 'Nerušit';

  @override
  String get temporarilySilenceNotifications => 'Dočasné mlčení všech oznámení';

  @override
  String get oneHour => '1h';

  @override
  String get eightHours => '8h';

  @override
  String get oneDay => '1 den';

  @override
  String get startTime => 'Čas zahájení';

  @override
  String get endTime => 'Čas ukončení';

  @override
  String get allowCriticalAlertsDuringQuietHours =>
      'Povolit kritické výstrahy během klidných hodin';

  @override
  String get silenceNotificationsDuringSleepHours =>
      'Oznámení o mlčení během spánku';

  @override
  String quietHoursActiveTimeRange(String startTime, String endTime) {
    return 'Active $startTime - $endTime';
  }

  @override
  String get followingAlerts => 'Následující záznamy';

  @override
  String activeCount(int count) {
    return '$count active';
  }

  @override
  String get unfollow => 'Nesledovat';

  @override
  String get unfollowAlert => 'Poplach bez sledování';

  @override
  String commentsCount(int count) {
    return '$count komentáře';
  }

  @override
  String get photo => 'Fotografie';

  @override
  String get video => 'Video';

  @override
  String get initializationComplete => 'Inicializace dokončena!';

  @override
  String get validatingEnvironment => 'Potvrzující prostředí...';

  @override
  String get requestingPermissions => 'Žádám o povolení...';

  @override
  String get loadingAuthSession => 'Nahrávám auth relace...';

  @override
  String get checkingUserRegistration => 'Kontroluji registraci uživatele...';

  @override
  String get loadingPreferences => 'Načítání preferencí...';

  @override
  String get settingUpLocalization => 'Nastavení lokalizace...';

  @override
  String get checkingConnectivity => 'Kontroluji konektivitu...';

  @override
  String get gatheringDeviceInfo => 'Informace o shromažďovacím zařízení...';

  @override
  String get translating => 'Překládám...';

  @override
  String get showOriginal => 'Zobrazit originál';

  @override
  String translateTo(String language) {
    return 'Translate to $language';
  }

  @override
  String translatedFrom(String language) {
    return 'Přeloženo z $language';
  }

  @override
  String translateContent(String language) {
    return 'Přeložit obsah do $language';
  }

  @override
  String get weatherClear => 'Vyčistit';

  @override
  String get weatherClearSky => 'jasná obloha';

  @override
  String get rain => 'Déšť';

  @override
  String get snow => 'Sníh';

  @override
  String get thunderstorm => 'Bouřka';

  @override
  String get drizzle => 'Mrholení';

  @override
  String get fog => 'Mlha';

  @override
  String get fewClouds => 'málo mraků';

  @override
  String get scatteredClouds => 'roztroušené mraky';

  @override
  String get brokenClouds => 'rozbité mraky';

  @override
  String get overcastClouds => 'zatažené mraky';

  @override
  String get lightRain => 'lehký déšť';

  @override
  String get moderateRain => 'střední déšť';

  @override
  String get heavyRain => 'těžký déšť';

  @override
  String aircraftDetectedCurrentPositions(int count, String radius) {
    return '$count zjištěná letadla v $radius km (aktuální polohy)';
  }

  @override
  String dimSatellitesUnlikely(int count) {
    return '$count dim satelity viditelné - pravděpodobně nevysvětluje pozorování';
  }

  @override
  String get mufonReportingDate => 'MUFON Datum podání zprávy';

  @override
  String satelliteNameDirection(String name, String direction) {
    return '$name - $direction';
  }
}
