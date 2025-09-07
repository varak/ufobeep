// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'UFOBeep';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Anuluj';

  @override
  String get close => 'Zamknij';

  @override
  String get save => 'Zapisz';

  @override
  String get delete => 'Usuń';

  @override
  String get edit => 'Edycja';

  @override
  String get retry => 'Retry';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get back => 'Tył';

  @override
  String get next => 'Następny';

  @override
  String get done => 'Gotowe';

  @override
  String get loading => 'Ładowanie..';

  @override
  String get processing => 'Przetwarzanie..';

  @override
  String get errorGeneric => 'Coś poszło nie tak.';

  @override
  String get networkError => 'Błąd sieci. Sprawdź połączenie.';

  @override
  String get permissionsRequired => 'Wymagane uprawnienia';

  @override
  String get learnMore => 'Więcej informacji';

  @override
  String get welcomeTitle => 'Witamy w UFOBeep';

  @override
  String get welcomeSubtitle => 'Real- time UFO alerts near you';

  @override
  String get signIn => 'Podpisz';

  @override
  String get signOut => 'Podpisz';

  @override
  String get continueAsGuest => 'Kontynuuj jako gość';

  @override
  String get enterUsername => 'Podaj nazwę użytkownika';

  @override
  String get username => 'Nazwa użytkownika';

  @override
  String get usernameUpdated => 'Aktualizacja nazwy użytkownika';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Ustawienia';

  @override
  String get tabAlerts => 'Wpisy';

  @override
  String get tabBeep => 'Beep';

  @override
  String get tabChat => 'Rozmowa';

  @override
  String get tabMap => 'Mapa';

  @override
  String get tabSettings => 'Ustawienia';

  @override
  String get alertsTitle => 'Wpisy w pobliżu';

  @override
  String get noAlerts => 'Żadnych alarmów w pobliżu.';

  @override
  String get pullToRefresh => 'Pociągnij, aby odświeżyć';

  @override
  String alertDistance(String distance) {
    return '_ _ PH _ 0 _ _ _ daleko';
  }

  @override
  String alertDirection(int bearing) {
    return 'Położenie _ _ PH _ 0 _ _ °';
  }

  @override
  String get viewAlert => 'Pokaż wpis';

  @override
  String get viewOnMap => 'Zobacz na mapie';

  @override
  String get iSeeItToo => 'Ja też to widzę';

  @override
  String get confirmWitnessed => 'Potwierdzić, że był pan świadkiem?';

  @override
  String get witnessConfirmed =>
      'Dzięki - twoje potwierdzenie zostało wysłane.';

  @override
  String get createBeepTitle => 'Wyślij sygnał';

  @override
  String get beepExplain =>
      'Uchwyć to, co widzisz i zaalarmuj pobliskich obserwatorów.';

  @override
  String get capturePhoto => 'Przechwytywanie zdjęć';

  @override
  String get captureVideo => 'Przechwytywanie wideo';

  @override
  String get pickFromGallery => 'Wybierz z galerii';

  @override
  String get descriptionHint => 'Opisz to, co widzisz na niebie..';

  @override
  String get submitBeep => 'Wyślij Beep';

  @override
  String get beepSent => 'Beep wysłany';

  @override
  String get uploadingMedia => 'Wysyłanie mediów..';

  @override
  String get includeLocation => 'Dołącz lokalizację';

  @override
  String get includeTimestamp => 'Dołącz znacznik czasu';

  @override
  String get beepFailed => 'Nie udało się wysłać Beepa.';

  @override
  String get mediaProcessing => 'Przetwarzanie mediów..';

  @override
  String get cameraPermissionTitle => 'Wymagany dostęp do kamery';

  @override
  String get cameraPermissionBody =>
      'Dostęp do kamery, aby uchwycić UFO zdjęcia i filmy.';

  @override
  String get locationPermissionTitle => 'Wymagany dostęp do lokalizacji';

  @override
  String get locationPermissionBody =>
      'Używamy Twojej lokalizacji do wysyłania i odbierania pobliskich alarmów.';

  @override
  String get microphonePermissionTitle => 'Potrzebny dostęp do mikrofonu';

  @override
  String get microphonePermissionBody =>
      'Dostęp do mikrofonu Granta do nagrywania wideo z audio.';

  @override
  String get openSettings => 'Otwórz ustawienia';

  @override
  String get alertDetailTitle => 'Podglądanie szczegółów';

  @override
  String reportedBy(String username) {
    return 'Zgłoszony przez _ _ PH _ 0 _ _';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Zgłoszone _ _ PH _ 0 _ _';
  }

  @override
  String distanceAway(String distance) {
    return '_ _ PH _ 0 _ _ _ daleko';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Nakładanie na obiekt: _ _ PH _ 0 _ _ °';
  }

  @override
  String get openCompass => 'Otworzyć kompas';

  @override
  String get openAR => 'Otworzyć nakładkę AR';

  @override
  String get openChat => 'Otwórz czat';

  @override
  String get commentsTitle => 'Uwagi';

  @override
  String get addComment => 'Dodaj komentarz..';

  @override
  String get send => 'Wyślij';

  @override
  String get commentPosted => 'Komentarz opublikowany';

  @override
  String get autoFollowEnabled => 'Teraz podążasz za tym alarmem.';

  @override
  String get noCommentsYet => 'Jeszcze żadnych komentarzy. Bądź pierwszy!';

  @override
  String get newCommentNotification =>
      'Nowy komentarz na temat obserwacji, którą śledzisz.';

  @override
  String get mapTitle => 'Mapa na żywo';

  @override
  String get compassTitle => 'Kompas';

  @override
  String get compassSettings => 'Ustawienia kompasu';

  @override
  String get compassMode => 'Tryb kompasu';

  @override
  String get compassStandardMode => 'Tryb standardowy';

  @override
  String get compassPilotMode => 'Tryb pilota';

  @override
  String get compassStandardDescription => 'Nagłówek i nawigacja';

  @override
  String get compassPilotDescription =>
      'Zaawansowana nawigacja z ETA i wektoring';

  @override
  String pointingTo(String direction) {
    return 'Wskazanie _ _ PH _ 0 _ _';
  }

  @override
  String get calibratingCompass => 'Kalibracyjny kompas..';

  @override
  String get openAROverlay => 'Otworzyć nakładkę AR';

  @override
  String get pushTitleAlertNearby => 'Alarm UFO w pobliżu ciebie';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Zgłoszono nowe spostrzeżenie _ _ PH _ 0 _ _.';
  }

  @override
  String get pushTitleComment => 'Nowy komentarz';

  @override
  String get pushBodyComment => 'Ktoś skomentował twoją obserwację.';

  @override
  String get pushTitleWitness => 'Potwierdzenie świadków';

  @override
  String get pushBodyWitness =>
      'Użytkownik potwierdził, że widzi ten sam obiekt.';

  @override
  String get weather => 'Pogoda';

  @override
  String cloudCover(int percent) {
    return 'Pokrywa chmurowa: _ _ PH _ 0 _ _%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Wiatr: _ _ PH _ 0 _ _ _ _ PH _ 1 _ _';
  }

  @override
  String get nearbyAircraft => 'Pobliskie statki powietrzne';

  @override
  String get noAircraft => 'Brak samolotów w pobliżu';

  @override
  String get loadingContext => 'Wczytywanie kontekstu środowiskowego..';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get notifications => 'Powiadomienia';

  @override
  String get enablePushNotifications =>
      'Uzyskaj powiadomienia o przyszłych komentarzach';

  @override
  String get quietHours => 'Godziny ciszy';

  @override
  String get quietHoursDesc => 'Alarmy ciszy między wybranymi godzinami.';

  @override
  String get dndMode => 'Nie przeszkadzać';

  @override
  String get dndUntil => 'Nie należy przeszkadzać do czasu';

  @override
  String get language => 'Język';

  @override
  String get chooseLanguage => 'Wybierz język';

  @override
  String get units => 'Jednostki';

  @override
  String get unitsImperial => 'Imperial (mi, mph)';

  @override
  String get unitsMetric => 'Metric (km, km / h)';

  @override
  String get privacyPolicy => 'Polityka prywatności';

  @override
  String get termsOfUse => 'Warunki korzystania';

  @override
  String get errorNoLocation =>
      'Lokalizacja niedostępna. Spróbuj ponownie na zewnątrz z czystym widokiem na niebo.';

  @override
  String get errorNoCamera => 'Kamera niedostępna na tym urządzeniu.';

  @override
  String get errorUploadFailed =>
      'Wysyłanie nie powiodło się. Proszę spróbować jeszcze raz.';

  @override
  String get errorPermissionDenied => 'Odmawiam.';

  @override
  String get errorInvalidUsername => 'Ta nazwa użytkownika nie jest dostępna.';

  @override
  String get nothingToShow => 'Jeszcze nic do pokazania.';

  @override
  String get storeShortDesc =>
      'Natychmiastowe alarmy UFO. Złapać, potwierdzić i porozmawiać w czasie rzeczywistym.';

  @override
  String get storeLongDesc =>
      'UFOBeep wysyła ostrzeżenia w czasie rzeczywistym, gdy ktoś widzi UFO w pobliżu. Przechwytywanie zdjęć i filmów wideo, potwierdzanie widoków za pomocą kranu, wyświetlanie kierunku i odległości oraz czat z innymi obserwatorami.';

  @override
  String get keywords =>
      'UFO, UAP, OVNI, kosmici, obserwacje, zegarki, alarmy, radar, kompas';

  @override
  String get noAlertsFound => 'Brak odpowiadających wpisów';

  @override
  String get alertsFilterHelp =>
      'Spróbuj dostosować filtry, aby zobaczyć więcej wyników';

  @override
  String get verified => 'Zweryfikowane';

  @override
  String get beepOnly => 'tylko sygnał dźwiękowy';

  @override
  String get videoOnly => 'tylko wideo';

  @override
  String get imageOnly => 'tylko obraz';

  @override
  String get timeJustNow => 'Przed chwilą';

  @override
  String timeDaysAgo(int count) {
    return '_ _ PH _ 0 _ _ d temu';
  }

  @override
  String timeHoursAgo(int count) {
    return '_ _ PH _ 0 _ _ _ h temu';
  }

  @override
  String timeMinutesAgo(int count) {
    return '_ _ PH _ 0 _ _ m temu';
  }

  @override
  String get loadMoreAlerts => 'Wczytaj więcej alarmów';

  @override
  String get toggleMufonTooltip => 'Włączenie / wyłączenie obserwacji MUFON';

  @override
  String get showMufonData => 'Pokaż dane MUFON';

  @override
  String get hideMufonData => 'Ukryj dane MUFON';

  @override
  String get showingUfoBeepOnly => 'Pokazywanie tylko raportów UFOBeep';

  @override
  String get showingAllReports =>
      'Wyświetlanie wszystkich raportów, w tym bazy danych MUFON';

  @override
  String get filteredSuffix => 'filtrowane';

  @override
  String get detailsTitle => 'Szczegóły';

  @override
  String get mufonCase => 'MUFON Przypadek';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Przypadek # _ _ PH _ 0 _ _ Szczegóły';
  }

  @override
  String get sightingDate => 'Data obserwacji';

  @override
  String get mufonDatabaseEntryDate => 'Data wejścia do MUFON Baza danych';

  @override
  String get databaseEntry => 'Wpis do bazy danych';

  @override
  String get shareLink => 'Udostępnianie odnośnika';

  @override
  String get linkCopied => 'Link skopiowany do schowka';

  @override
  String get locationLabel => 'Lokalizacja';

  @override
  String get distanceLabel => 'Odległość';

  @override
  String get timeLabel => 'Czas';

  @override
  String get reportedByLabel => 'Zgłoszone przez';

  @override
  String get unknownLocation => 'Nieznana lokalizacja';

  @override
  String get locationUnknown => 'Lokalizacja nieznana';

  @override
  String get witnessesLabel => 'Świadkowie';

  @override
  String witnessesCountMessage(int count) {
    return 'Ludzie potwierdzili to rozpoznanie';
  }

  @override
  String get photoAnalysisTitle => 'Analiza zdjęć';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analiza: _ _ PH _ 0 _ _ plik (-y) multimedialny (-e) przetworzony (-e)';
  }

  @override
  String get addMoreMedia => 'Dodaj więcej';

  @override
  String get addMedia => 'Dodaj media';

  @override
  String get retakePhoto => 'Retake Photo';

  @override
  String get retakeVideo => 'Zapisz wideo';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galeria';

  @override
  String get basicSettings => 'Ustawienia podstawowe';

  @override
  String get appSettings => 'Ustawienia aplikacji';

  @override
  String get alertRange => 'Zakres alarmów';

  @override
  String get manageNotificationsDesc =>
      'Zarządzanie subskrypcjami i ustawieniami';

  @override
  String get permissionsTitle => 'Uprawnienia';

  @override
  String get permissionLocation => 'Lokalizacja';

  @override
  String get permissionCamera => 'Kamera';

  @override
  String get permissionNotifications => 'Powiadomienia';

  @override
  String get permissionPhotos => 'Zdjęcia';

  @override
  String get permissionGranted => 'Udzielone';

  @override
  String get permissionNotGranted => 'Nieprzyznane';

  @override
  String get permissionGrant => 'Dotacja';

  @override
  String get generateUsername => 'Generuj nową nazwę użytkownika';

  @override
  String get adminTools => 'Admin Narzędzia';

  @override
  String get openAdminPanel => 'Otwórz panel administracyjny';

  @override
  String get webAdminInterface => 'Interfejs administratora sieci Web';

  @override
  String get adminBetaNotice =>
      'Beta tylko buduje. Admin narzędzia do testowania alarmów zbliżeniowych, powiadomień push i diagnostyki systemu.';

  @override
  String get whatDoYouSee => 'Co widzisz?';

  @override
  String get ufoSighting => 'UFO Zwiedzanie';

  @override
  String get envAnalysisTitle => 'Analiza środowiskowa';

  @override
  String get envAnalysisPending => 'Analiza oczekująca';

  @override
  String get envAnalysisPendingDesc =>
      'Dane środowiskowe będą dostępne po rozpoczęciu przetwarzania.';

  @override
  String get unknownAircraft => 'Nieznane statki powietrzne';

  @override
  String get moreAircraft => 'więcej statków powietrznych';

  @override
  String get premiumImageryTitle => 'Premium Satellite Wyobraźnia';

  @override
  String get premiumImagerySubtitle =>
      'Obrazy komercyjne wysokiej rozdzielczości';

  @override
  String get sightingTypeLabel => 'Rodzaj';

  @override
  String get ufoTypeSphere => 'Kula';

  @override
  String get ufoTypeTriangle => 'Trójkąt';

  @override
  String get ufoTypeDisk => 'Dysk';

  @override
  String get ufoTypeLight => 'Światło';

  @override
  String get ufoTypeFireball => 'Fireball';

  @override
  String get ufoTypeCylinder => 'Cylinder';

  @override
  String get ufoTypeCigar => 'Cygaro';

  @override
  String get ufoTypeRectangle => 'Prostokąt';

  @override
  String get ufoTypeFormation => 'Formacja';

  @override
  String get ufoTypeUnknown => 'Nieznany';

  @override
  String get ufoTypeBoomerang => 'Bumerang';

  @override
  String get ufoTypeDiamond => 'Diament';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Łożysko';

  @override
  String get ufoTypeCross => 'Krzyż';

  @override
  String get ufoTypeDumbbell => 'Dzwonek';

  @override
  String get ufoTypeTeardrop => 'Podłoże';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Kula';

  @override
  String get ufoTypeSaturn => 'Saturn Przewodniczący';

  @override
  String get ufoTypeStarLike => 'Star- like';

  @override
  String get ufoTypeBlimp => 'Sterownik';

  @override
  String get actionsTitle => 'Działania';

  @override
  String get addPhotosAndVideos => 'Dodaj zdjęcia i filmy';

  @override
  String get howToReportToMufon => 'Jak zgłosić się do MUFON';

  @override
  String get reportToMufon => 'Sprawozdanie dla MUFON';

  @override
  String get whyReportToMufon => 'Po co zgłaszać się do MUFON?';

  @override
  String get openMufonReport => 'Otwórz MUFON Sprawozdanie';

  @override
  String get confirmedWitness => 'Potwierdziłeś to';

  @override
  String witnessesHaveConfirmed(int count) {
    return 'Ludzie potwierdzili to rozpoznanie';
  }

  @override
  String get aircraftTrackingTitle => 'Śledzenie statków powietrznych';

  @override
  String get weatherConditionsTitle => 'Warunki pogodowe';

  @override
  String get noSatellitePasses => 'Brak widocznych przejść satelitarnych';

  @override
  String get contentAnalysisTitle => 'Analiza zawartości';

  @override
  String get contentSafe => 'Zawartość jest bezpieczna';

  @override
  String get contentFlagged => 'Zawartość oznaczona do przeglądu';

  @override
  String get confidenceLabel => 'Zaufanie';

  @override
  String get methodLabel => 'Metoda';

  @override
  String get premiumImageryAccessOnly =>
      'Obrazy satelitarne Premium są dostępne tylko dla:';

  @override
  String get premiumAccessCreators => 'Twórcy ostrzeżeń';

  @override
  String get premiumAccessWitnesses =>
      'Potwierdzeni świadkowie w zasięgu widoczności';

  @override
  String get comingSoon => 'Wkrótce';
}
