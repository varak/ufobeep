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
  String get noAlertsFound => 'No matching alerts';

  @override
  String get alertsFilterHelp =>
      'Try adjusting your filters to see more results';

  @override
  String get verified => 'Verified';

  @override
  String get beepOnly => 'beep only';

  @override
  String get videoOnly => 'video only';

  @override
  String get imageOnly => 'image only';

  @override
  String get timeJustNow => 'Just now';

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
  String get loadMoreAlerts => 'Load More Alerts';

  @override
  String get toggleMufonTooltip => 'Toggle MUFON sightings';

  @override
  String get showMufonData => 'Show MUFON data';

  @override
  String get hideMufonData => 'Hide MUFON data';

  @override
  String get showingUfoBeepOnly => 'Showing only UFOBeep reports';

  @override
  String get showingAllReports =>
      'Showing all reports including MUFON database';

  @override
  String get filteredSuffix => 'filtered';
}
