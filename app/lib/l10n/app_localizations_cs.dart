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
    return '_ _ PH _ 0 _ _ pryč';
  }

  @override
  String alertDirection(int bearing) {
    return 'Ložisko _ _ PH _ 0 _ _ °';
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
    return 'Nahlášeno _ _ PH _ 0 _ _';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Hlášený _ _ PH _ 0 _ _';
  }

  @override
  String distanceAway(String distance) {
    return '_ _ PH _ 0 _ _ pryč';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Nošení námitky: _ _ PH _ 0 _ _ °';
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
  String get noCommentsYet => 'Zatím žádné komentáře. Buď první!';

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
    return 'Ukazuji na _ _ PH _ 0 _ _';
  }

  @override
  String get calibratingCompass => 'Kalibrační kompas..';

  @override
  String get openAROverlay => 'Otevřené překrytí AR';

  @override
  String get pushTitleAlertNearby => 'Pozor UFO blízko vás';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Bylo hlášeno nové pozorování _ _ PH _ 0 _ _ away.';
  }

  @override
  String get pushTitleComment => 'Nový komentář';

  @override
  String get pushBodyComment => 'Někdo komentoval pozorování, které sledujete.';

  @override
  String get pushTitleWitness => 'Potvrzení svědka';

  @override
  String get pushBodyWitness => 'Uživatel potvrdil, že vidí stejný objekt.';

  @override
  String get weather => 'Počasí';

  @override
  String cloudCover(int percent) {
    return 'Cloud cover: _ _ PH _ 0 _ _%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Vítr: _ _ PH _ 0 _ _ _ _ PH _ 1 _ _';
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
  String get enablePushNotifications => 'Povolit push notifications';

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
  String get beepOnly => 'pouze pípnutí';

  @override
  String get videoOnly => 'pouze video';

  @override
  String get imageOnly => 'pouze obrázek';

  @override
  String get timeJustNow => 'Právě teď';

  @override
  String timeDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String timeMinutesAgo(int count) {
    return '${count}m ago';
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
  String get sightingDate => 'Datum pozorování';

  @override
  String get databaseEntry => 'Záznam databáze';

  @override
  String get locationLabel => 'Umístění';

  @override
  String get distanceLabel => 'Vzdálenost';

  @override
  String get timeLabel => 'Čas';

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
    return '_ _ PH _ 0 _ _ lidé potvrdili toto pozorování';
  }

  @override
  String get photoAnalysisTitle => 'Analýza fotografií';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analýza: _ _ PH _ 0 _ _ media soubor (y) zpracován';
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
  String get ufoSighting => 'UFO Vidění';

  @override
  String get envAnalysisTitle => 'Environmental Analysis';

  @override
  String get envAnalysisPending => 'Analysis Pending';

  @override
  String get envAnalysisPendingDesc =>
      'Environmental data will be available once processing begins.';

  @override
  String get unknownAircraft => 'Unknown Aircraft';

  @override
  String get moreAircraft => 'more aircraft';

  @override
  String get premiumImageryTitle => 'Premium Satellite Imagery';

  @override
  String get premiumImagerySubtitle => 'High-resolution commercial imagery';

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
  String get ufoTypeBoomerang => 'Boomerang';

  @override
  String get ufoTypeDiamond => 'Diamond';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Cone';

  @override
  String get ufoTypeCross => 'Cross';

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
  String get ufoTypeStarLike => 'Star-like';

  @override
  String get ufoTypeBlimp => 'Blimp';

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
    return 'Lidé potvrdili toto pozorování';
  }

  @override
  String get aircraftTrackingTitle => 'Aircraft Tracking';

  @override
  String get weatherConditionsTitle => 'Weather Conditions';

  @override
  String get noSatellitePasses => 'No visible satellite passes found';

  @override
  String get contentAnalysisTitle => 'Content Analysis';

  @override
  String get contentSafe => 'Content is safe';

  @override
  String get contentFlagged => 'Content flagged for review';

  @override
  String get confidenceLabel => 'Confidence';

  @override
  String get methodLabel => 'Method';

  @override
  String get premiumImageryAccessOnly =>
      'Premium satellite imagery is only available to:';

  @override
  String get premiumAccessCreators => 'Alert creators';

  @override
  String get premiumAccessWitnesses =>
      'Confirmed witnesses within visibility range';

  @override
  String get comingSoon => 'Coming Soon';
}
