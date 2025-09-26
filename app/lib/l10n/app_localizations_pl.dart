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
    return '_ _ PLACESENT _ 0 _ _ away';
  }

  @override
  String alertDirection(int bearing) {
    return 'Łożysko _ _ PLACESORA _ 0 _ _ °';
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
  String beepSentWithUrl(String shortUrl) {
    return 'Beep wysłany pomyślnie';
  }

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
  String get locationPermissionTitle => 'Wymagane zezwolenie na lokalizację';

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
    return 'Zgłoszony przez _ _ PLACEScorter _ 0 _ _';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Zgłoszony _ _ PLACEScorter _ 0 _ _';
  }

  @override
  String distanceAway(String distance) {
    return '_ _ PLACESENT _ 0 _ _';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Nakładanie na obiekt: _ _ PLACEScorter _ 0 _ _ °';
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
  String get noCommentsYet =>
      'Jeszcze żadnych komentarzy. Bądź pierwszym, który skomentuje!';

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
    return 'Wskazywanie na _ _ PLACEScorpiter _ 0 _ _';
  }

  @override
  String get calibratingCompass => 'Kalibracyjny kompas..';

  @override
  String get openAROverlay => 'Otworzyć nakładkę AR';

  @override
  String get pushTitleAlertNearby => 'Alarm UFO w pobliżu ciebie';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Zgłoszono nowe spostrzeżenie _ _ PLACEScorpiter _ 0 _ _ away.';
  }

  @override
  String get pushTitleComment => 'Nowy komentarz';

  @override
  String get pushBodyComment => 'Ktoś skomentował twoją obserwację.';

  @override
  String get pushTitleWitness => 'Potwierdzenie świadków';

  @override
  String get temperature => 'Temperatura';

  @override
  String get pushBodyWitness =>
      'Użytkownik potwierdził, że widzi ten sam obiekt.';

  @override
  String get weather => 'Pogoda';

  @override
  String cloudCover(int percent) {
    return 'Pokrywa chmurowa: _ _ PLACESENT _ 0 _ _%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Wiatr: _ _ PLACESORA _ 0 _ _ _ _ PLACESORA _ 1 _ _';
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
  String get quietHoursEnabled => 'Włącz ciche godziny';

  @override
  String get quietHoursFrom => 'Od';

  @override
  String get quietHoursUntil => 'Do';

  @override
  String get quietHoursDefaultTime => 'Domyślne godziny ciszy';

  @override
  String get emergencyOverride => 'Niepotrzebne skreślić';

  @override
  String get emergencyOverrideDesc =>
      'Należy zezwolić na pilne wpisy w godzinach ciszy';

  @override
  String get dndMode => 'Nie przeszkadzać';

  @override
  String get dndUntil => 'Nie należy przeszkadzać do czasu';

  @override
  String dndEnabled(Object time) {
    return 'DND włączone do _ _ PLACEScorter _ 0 _ _';
  }

  @override
  String get dndDisabled => 'Wyłączony DND';

  @override
  String get quietHoursActive => 'Godziny ciszy aktywne';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Godziny ciszy: _ _ PLACESECRET _ 0 _ _ _ - _ PLACESECRET _ 1 _ _';
  }

  @override
  String get pushNotificationUfoAlert => 'UFO Alarm';

  @override
  String get pushNotificationAnomalyAlert => 'Alert';

  @override
  String get pushNotificationNearby => 'Niedaleko';

  @override
  String get pushNotificationInYourArea =>
      'w twoim rejonie. Dotknij, aby zobaczyć szczegóły.';

  @override
  String pushNotificationCommented(Object username) {
    return '_ _ PLACESENER _ 0 _ _ skomentowane';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '_ _ PLACESECRET _ 0 _ _ skomentował _ _ PLACESECRET _ 1 _ _';
  }

  @override
  String get pushNotificationGeneric => 'UFOBeep';

  @override
  String get pushNotificationNewSighting => 'Nowy widok w pobliżu';

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
  String get beepOnly => 'Tylko beep';

  @override
  String get reportOnly => 'Tylko tekst';

  @override
  String get videoOnly => 'Tylko wideo';

  @override
  String get imageOnly => 'Tylko obrazek';

  @override
  String get mediaOnly => 'Tylko media';

  @override
  String get timeJustNow => 'właśnie teraz';

  @override
  String timeDaysAgo(int count) {
    return '_ _ PLACESENT _ 0 _ _ dni temu';
  }

  @override
  String timeHoursAgo(int count) {
    return '_ _ PLACESENT _ 0 _ _ godzin temu';
  }

  @override
  String timeMinutesAgo(int count) {
    return '_ _ PLACESENT _ 0 _ _ minutes temu';
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
  String get mufonSighting => 'Sprawozdanie z obserwacji MUFON';

  @override
  String get mufonLightSighting => 'Raport z obserwacji światła MUFON';

  @override
  String get mufonSphereSighting => 'Raport z obserwacji Sfery MUFON';

  @override
  String get mufonDiscSighting => 'MUFON Raport z obserwacji dysku';

  @override
  String get mufonTriangleSighting => 'MUFON Raport z obserwacji trójkąta';

  @override
  String get mufonCigarSighting => 'Raport z obserwacji cygar MUFON';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting Report';

  @override
  String get mufonRectangleSighting => 'MUFON Raport z obserwacji prostokąta';

  @override
  String get mufonCylinderSighting => 'Raport z obserwacji cylindrów MUFON';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Sighting Report';

  @override
  String get mufonStarlikeSighting => 'MUFON Raport o widoczności gwiazd';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'Przypadek MUFON # _ _ PLACEScorpiter _ 0 _ _ Szczegóły';
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
  String get locationLabel => 'Lokalizacja:';

  @override
  String get distanceLabel => 'Odległość';

  @override
  String get timeLabel => 'Czas:';

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
    return '_ _ PLACESENT _ 0 _ _ ludzie potwierdzili to spostrzeżenie';
  }

  @override
  String get photoAnalysisTitle => 'Analiza zdjęć';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analiza: _ _ PLACEScorter _ 0 _ _ media plik (y) przetworzony (y)';
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
  String get timeFormat => 'Format czasu';

  @override
  String get timeFormat24Hour => '24 godziny (14: 30)';

  @override
  String get timeFormat12Hour => '12 godzin (14: 30)';

  @override
  String get timeFormatDesc =>
      'Czas wyświetlania w formacie 24-godzinnym lub 12-godzinnym';

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
  String get ufo => 'UFO';

  @override
  String get sighting => 'Zwiedzanie';

  @override
  String get ufoSighting => 'UFO Alarm';

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
  String get showLess => 'Pokaż mniej';

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
  String get shapeTriangle => 'trójkąt';

  @override
  String get shapeDisc => 'dysk';

  @override
  String get shapeDisk => 'dysk';

  @override
  String get shapeSphere => 'sfera';

  @override
  String get shapeCigar => 'cygaro';

  @override
  String get shapeLight => 'światło';

  @override
  String get shapeBoomerang => 'bumerang';

  @override
  String get shapeDiamond => 'diament';

  @override
  String get shapeRectangle => 'prostokąt';

  @override
  String get shapeOval => 'owalne';

  @override
  String get shapeCone => 'stożek';

  @override
  String get shapeCross => 'krzyż';

  @override
  String get shapeCylinder => 'cylinder';

  @override
  String get shapeDumbbell => 'hantle';

  @override
  String get shapeTeardrop => 'łzawienie';

  @override
  String get shapeTicTac => 'tic- tac';

  @override
  String get shapeBullet => 'kula';

  @override
  String get shapeSaturn => 'saturn';

  @override
  String get shapeStarlike => 'gwiezdne';

  @override
  String get shapeBlimp => 'sterowiec';

  @override
  String get shapeFireball => 'fireball';

  @override
  String get shapeFormation => 'powstawanie';

  @override
  String get shapeUnknown => 'nieznany';

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
    return '_ _ PLACESENER _ 0 _ _ ludzie potwierdzili to spostrzeżenie';
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

  @override
  String get directionDistanceTitle => 'Kierunek i odległość';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Przypadek # _ _ PLACESENER _ 0 _ _';
  }

  @override
  String get satellitePassesTitle => 'Pasy satelitarne';

  @override
  String get satellitePassExplanation =>
      'Widoczne przejścia satelitarne w czasie obserwacji. Wiele raportów UFO to satelity lub kosmiczne szczątki.';

  @override
  String get followingAlert =>
      'Po ostrzeżeniu - otrzymasz powiadomienia o komentarzach';

  @override
  String get unfollowedAlert =>
      'Nieśledzony wpis - brak powiadomień o komentarzach';

  @override
  String get alertFollowError => 'Błąd podczas aktualizacji statusu folderu';

  @override
  String get notificationChannelAlerts => 'Alerty UFOBeep';

  @override
  String get notificationChannelAlertsDesc =>
      'Powiadomienia o dźwiękach UFO i alarmach zbliżeniowych';

  @override
  String get notificationSightingTitle => 'UFO Alarm';

  @override
  String get notificationSightingUrgent => 'UFOBeep UFO Alarm';

  @override
  String get notificationSightingEmergency => 'ANALIZA UFOBeep UFO Alarm';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '_ _ PLACESECRET _ 0 _ _ near _ _ PLACESECRET _ 1 _ _';
  }

  @override
  String notificationCommentTitle(String username) {
    return '_ _ PLACEScorter _ 0 _ _ skomentowane';
  }

  @override
  String get notificationWitnessText => 'Nowy widok';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '_ _ PLACESENT _ 0 _ _ świadkowie';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Rozejść się';

  @override
  String notificationDistance(String distance) {
    return '_ _ PLACESENT _ 0 _ _ away';
  }

  @override
  String get unknown => 'nieznany';

  @override
  String get report => 'raport';

  @override
  String get mufon => 'mufon';

  @override
  String get recentUfoBeepsTitle => 'Najnowsze UFO Dźwięki';

  @override
  String get recentUfoBeepsSubtitle =>
      'Raporty z obserwacji UFO na żywo z naszej globalnej społeczności';

  @override
  String get recentUfoBeepsDescription =>
      'Ten kanał łączy w sobie w czasie rzeczywistym \"beepy\" UFOBeep od naszych użytkowników aplikacji mobilnych z raportami historycznymi z bazy danych MUFON.';

  @override
  String get loadingBeeps => 'Wczytywanie ostatnich sygnałów...';

  @override
  String get noBeepsAvailable => 'W tej chwili nie ma żadnych sygnałów.';

  @override
  String get anomalyReported => 'Anomalia';

  @override
  String get copyShortLink => 'Kopiuj krótki link';

  @override
  String get shareAlert => 'Alert akcji';

  @override
  String get ufoSightingAlert => 'UFO Ostrzeżenie';

  @override
  String get previousPage => 'Poprzedni';

  @override
  String get nextPage => 'Następny';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Page _ _ PLACESECRET _ 0 _ _ of _ _ PLACESECRET _ 1 _ _ (_ _ PLACESECRET _ 2 _ _ total beeps)';
  }

  @override
  String get firstPage => 'Najpierw';

  @override
  String get lastPage => 'Ostatni';

  @override
  String get jumpToPage => 'Przejdź do strony';

  @override
  String get heroTagline =>
      'Pobierz ostrzeżenia, kiedy wyjść na zewnątrz i spojrzeć w górę';

  @override
  String get heroDescription =>
      'Nigdy nie przegap kolejnego UFO widząc w twoim obszarze';

  @override
  String get downloadApp => 'Pobierz aplikację';

  @override
  String get viewAllBeeps => 'Name';

  @override
  String get sightingsMap => 'Mapa przeglądów';

  @override
  String get globalSightingNetwork => 'Globalna sieć widokowa';

  @override
  String get howItWorks => 'Jak to działa';

  @override
  String get backToBeeps => 'Powrót do pików';

  @override
  String get loadingDetails => 'Wczytywanie szczegółów...';

  @override
  String get details => 'Szczegóły';

  @override
  String get location => 'Lokalizacja';

  @override
  String get timeAgo => 'przed';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'mile';

  @override
  String get distanceNearby => 'w pobliżu';

  @override
  String get ufobeepWitnesses => 'Świadkowie';

  @override
  String get ufobeepConfirmations => 'Potwierdzenia';

  @override
  String get ufobeepAlertLevel => 'Poziom alarmowy';

  @override
  String get ufobeepReportType => 'Raport UFOBeep';

  @override
  String get mufonAttribution => 'MUFON Sprawozdanie z bazy danych';

  @override
  String get mufonCaseNumber => 'Case #';

  @override
  String get mufonGenericTitle => 'Sprawozdanie z obserwacji MUFON';

  @override
  String get mufonSphere => 'Kula';

  @override
  String get mufonLight => 'Światło';

  @override
  String get mufonDisk => 'Dysk';

  @override
  String get mufonTriangle => 'Trójkąt';

  @override
  String get mufonCigar => 'Cygaro';

  @override
  String get mufonOval => 'Oval';

  @override
  String get mufonCylinder => 'Cylinder';

  @override
  String get mufonRectangle => 'Prostokąt';

  @override
  String get mufonDiamond => 'Diament';

  @override
  String get mufonFireball => 'Fireball';

  @override
  String get mufonFlash => 'Flash';

  @override
  String get mufonFormation => 'Formacja';

  @override
  String get mufonChanging => 'Zmiana';

  @override
  String get mufonChevron => 'Chevron';

  @override
  String get mufonCone => 'Łożysko';

  @override
  String get mufonCross => 'Krzyż';

  @override
  String get mufonEgg => 'Jaja';

  @override
  String get mufonOther => 'Obiekt';

  @override
  String get mufonUnknown => 'Nieznany obiekt';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON _ _ PLACESENT _ 0 _ _ Raport';
  }

  @override
  String get nuforcAttribution => 'NUFORC Sprawozdanie z bazy danych';

  @override
  String get nuforcCaseNumber => 'Case #';

  @override
  String get nuforcGenericTitle => 'NUFORC Sprawozdanie z obserwacji';

  @override
  String get mediaImageNotFound => 'Nie znaleziono obrazka';

  @override
  String get mediaPlayVideo => 'Zagraj w wideo';

  @override
  String get mediaViewImage => 'Wyświetl obrazek';

  @override
  String mediaCount(Object count) {
    return '_ _ PLACESENT _ 0 _ _ Obrazy';
  }

  @override
  String get mediaCountSingle => '1 obraz';

  @override
  String mediaMoreImages(Object count) {
    return '+ _ _ PLACESENT _ 0 _ _ more';
  }

  @override
  String get errorNotFound => 'Beep nie znaleziono';

  @override
  String get errorLoadError => 'Nie udało się wczytać szczegółów sygnału';

  @override
  String get shareYourThoughts =>
      'Podziel się swoimi myślami na temat tego widzenia...';

  @override
  String get postComment => 'Poczta Komentarz';

  @override
  String get loggedInAs => 'Zalogowane jako';

  @override
  String get logout => 'Wyloguj';

  @override
  String get notFollowing => 'Nie następuje';

  @override
  String get follow => 'Śledź';

  @override
  String get navRecentBeeps => 'Ostatnie sygnały';

  @override
  String get navMap => 'Mapa';

  @override
  String get navDownloadApp => 'Pobierz aplikację';

  @override
  String get alertLevel => 'Poziom alarmowy';

  @override
  String get witnesses => 'Świadkowie';

  @override
  String get confirmations => 'Potwierdzenia';

  @override
  String get reporterLabel => 'Zgłoszone przez użytkownika';

  @override
  String get coordinatesLabel => 'Współrzędne';

  @override
  String get eventTime => 'Czas zdarzenia';

  @override
  String get reportedTime => 'Zgłoszony czas';

  @override
  String get addedToUfobeep => 'Dodano do UFOBeep';

  @override
  String get mufonDatabaseReport => 'MUFON Numer sprawy:';

  @override
  String get copyShortLinkTitle => 'Kopiuj link do schowka';

  @override
  String get imageNotFound => 'Nie znaleziono obrazka';

  @override
  String get ufoSightingAlt => 'UFO Beep UFO alert';

  @override
  String get celestialDataTitle => 'Niebiańskie obiekty';

  @override
  String get visiblePlanets => 'Widoczne planety';

  @override
  String get locationDataTitle => 'Informacje o lokalizacji';

  @override
  String get timezone => 'Strefa czasowa';

  @override
  String get coordinates => 'Współrzędne';

  @override
  String get processingSummaryTitle => 'Podsumowanie przetwarzania';

  @override
  String get processingTime => 'Czas przetwarzania';

  @override
  String get successful => 'Udane';

  @override
  String get failed => 'Nieudany';

  @override
  String get locationEnrichmentTitle => 'Szczegóły lokalizacji';

  @override
  String get aircraftDataSource => 'Źródło danych';

  @override
  String get noAircraftDetected => 'Nie wykryto żadnego statku powietrznego';

  @override
  String get sightingReport => 'Sprawozdanie z obserwacji';

  @override
  String get ufoAlert => 'UFO Alarm';

  @override
  String get alert => 'Alarm';

  @override
  String get notificationTickerUfoAlert => 'Alert UFO - Nowy widok w pobliżu';

  @override
  String get notificationTickerComment => 'Nowy komentarz na temat UFO Alert';

  @override
  String get weatherConditions => 'Warunki pogodowe';

  @override
  String get visibility => 'Widoczność';

  @override
  String get humidity => 'Wilgotność';

  @override
  String get pressure => 'Ciśnienie';

  @override
  String get locationDetails => 'Szczegóły lokalizacji';

  @override
  String get city => 'Miasto';

  @override
  String get state => 'Państwo';

  @override
  String get country => 'Kraj';

  @override
  String get satelliteActivity => 'Działalność satelitarna';

  @override
  String get satellitesVisibleOverhead =>
      'Satelity widoczne nad głową w czasie i miejscu obserwacji';

  @override
  String get dataSource => 'Źródło danych';

  @override
  String get blackskyImagery => 'BlackSky Imagery';

  @override
  String get resolution => 'Rozdzielczość';

  @override
  String get groundResolution => 'rozdzielczość podłoża 35cm';

  @override
  String get delivery => 'Dostawa';

  @override
  String get averageDelivery => 'średnia 90- minutowa';

  @override
  String get cost => 'Koszt';

  @override
  String get skyfiSatelliteImagery => 'SkyFi Satellite Wyobraźnia';

  @override
  String get region => 'Region';

  @override
  String get remoteArea => 'Obszar zdalny';

  @override
  String get startingPrice => 'Cena początkowa';

  @override
  String get coverage => 'Zakres';

  @override
  String get confidenceCoverage => '95% przedział';

  @override
  String get status => 'Stan';

  @override
  String get shareThoughts =>
      'Podziel się swoimi myślami na temat tego widzenia...';

  @override
  String get postCommand => 'Polecenie pocztowe';

  @override
  String get clouds => 'Chmury';

  @override
  String get windLabel => 'Wiatr';

  @override
  String get filterAlerts => 'Wpisy filtrujące';

  @override
  String get alertSource => 'Źródło alarmu';

  @override
  String get ufobeepOnly => 'Tylko UFOBeep';

  @override
  String get ufobeepOnlyDescription =>
      'Pokaż tylko oryginalne raporty UFOBeep (z wyłączeniem bazy danych MUFON)';

  @override
  String get alertDistanceRange => 'Alert Zakres odległości';

  @override
  String get showAllAlerts => 'Pokaż wszystkie alarmy';

  @override
  String get showAll => 'Pokaż wszystkie';

  @override
  String get distanceSliderDescription =>
      'Przeciągnij, aby dostosować, jak daleko chcesz zobaczyć alarmy. Rozpocznij od odległości widoczności pogody aż do wyświetlenia wszystkich wpisów niezależnie od odległości.';

  @override
  String get applyFilters => 'Zastosuj filtry';

  @override
  String get notificationRange => 'Zakres zgłoszeń';

  @override
  String get notificationRangeDescription =>
      'Pobierz alarmy push dla obserwacji w tej odległości';

  @override
  String get viewingRange => 'Zakres przeglądania';

  @override
  String get viewingRangeDescription =>
      'Pokaż widoczność w tej odległości podczas przeglądania';

  @override
  String get weatherVisibility => 'Widoczność pogody (~ 10 km)';

  @override
  String get localArea => 'Obszar lokalny (25km)';

  @override
  String get regional => 'Regionalne';

  @override
  String get pushNotifications => 'Powiadomienia o uruchomieniu';

  @override
  String get alertBrowsing => 'Ostrzeżenie Przeglądanie';

  @override
  String get pushAlertsWithinDistance => 'Pobierz powiadomienia w tym zakresie';

  @override
  String get showAlertsWhenBrowsing => 'Filtruj to, co widzisz na liście';

  @override
  String get heroMainTagline => 'Odezwij się, gdy UFO będzie w pobliżu';

  @override
  String get heroSecondaryTagline =>
      'Dowiedz się, kiedy i gdzie patrzeć na niebo';

  @override
  String get sourceFilters => 'Źródło';

  @override
  String get sourceFiltersDescription =>
      'Wybierz, które raporty pojawiają się w paszy';

  @override
  String get ufobeepAndMufon => 'UFOBeep + MUFON';

  @override
  String get ufobeepOnlySource => 'Tylko UFOBeep';

  @override
  String get mufonOnlySource => 'Tylko MUFON';

  @override
  String get browseFilters => 'Przeglądaj';

  @override
  String get browseFiltersDescription => 'Jak przeglądać i sortować alarmy';

  @override
  String get sortByNewest => 'Newest';

  @override
  String get sortByNearest => 'Najbliższy';

  @override
  String get sortBy => 'Sortuj według';

  @override
  String get pushAlertsTitle => 'Wpisy';

  @override
  String get pushAlertsDescription => 'Co to za telefon';

  @override
  String get alertRadius => 'Alarm Radius';

  @override
  String get mufonNoPushInfo =>
      'Raporty MUFON są importowane nocą i nie uruchamiają alarmów';

  @override
  String get privacyData => 'Prywatność i dane';

  @override
  String get privacyPolicyDesc => 'Jak chronić i używać danych';

  @override
  String get termsOfService => 'Warunki świadczenia usług';

  @override
  String get termsOfServiceDesc => 'Warunki prawne';

  @override
  String get locationTracking => 'Lokalizacja śledzenia';

  @override
  String get locationTrackingDesc =>
      'Lokalizacja tła wpisów dotyczących bliskości';

  @override
  String get locationTrackingTitle => 'Tło Lokalizacja śledzenia';

  @override
  String get locationTrackingExplanation =>
      'UFOBeep monitoruje Twoją lokalizację w tle, aby wysłać Ci ostrzeżenia o bliskości, gdy obserwacje UFO pojawią się w pobliżu Twojej obecnej lokalizacji, nawet jeśli jesteś poza domem.';

  @override
  String get locationTrackingBattery =>
      'Wykorzystuje inteligentne geofendery dla < 3% uderzenia akumulatora';

  @override
  String get backgroundLocationTracking => 'Włącz tło Śledzenie';

  @override
  String get locationTrackingActive =>
      'Monitorowanie lokalizacji wpisów dotyczących bliskości';

  @override
  String get locationTrackingInactive => 'Śledzenie lokalizacji jest wyłączone';

  @override
  String get locationTrackingDisabledWarning =>
      'Nie otrzymasz alarmów zbliżeniowych, gdy przeniesiesz się do nowych miejsc';

  @override
  String get trackingStatus => 'Status śledzenia';

  @override
  String get monitoringStatus => 'Monitorowanie';

  @override
  String get active => 'Aktywne';

  @override
  String get inactive => 'Nieaktywne';

  @override
  String get lastKnownLocation => 'Ostatnia znana lokalizacja';

  @override
  String get lastLocationUpdate => 'Ostatnia aktualizacja';

  @override
  String get movementThreshold => 'Próg ruchu';

  @override
  String get updateFrequency => 'Aktualizuj częstotliwość';

  @override
  String get batteryImpact => 'Uderzenie akumulatora';

  @override
  String get dataPrivacy => 'Prywatność danych';

  @override
  String get locationPermissionExplanation =>
      'UFOBeep potrzebuje zezwolenia na lokalizację, aby monitorować ruch i wysyłać ostrzeżenia o bliskości, gdy jesteś w nowych miejscach.';

  @override
  String get benefitsTitle => 'Korzyści';

  @override
  String get locationTrackingBenefits =>
      '• Pobierz ostrzeżenia UFO gdziekolwiek podróżujesz\n• Automatyczne aktualizacje lokalizacji\n• Nie wymaga się ręcznego ustawiania';

  @override
  String get allowLocationAccess => 'Pozwól na dostęp lokalizacji';

  @override
  String get locationPermissionRequired =>
      'Do śledzenia tła wymagane jest zezwolenie na lokalizację';

  @override
  String get locationTrackingEnabled => 'Włączenie śledzenia lokalizacji tła';

  @override
  String get locationTrackingDisabled => 'Śledzenie lokalizacji tła wyłączone';

  @override
  String get justNow => 'Przed chwilą';

  @override
  String minutesAgo(int minutes) {
    return '_ _ PLACESENT _ 0 _ _ minutes temu';
  }

  @override
  String hoursAgo(int hours) {
    return '_ _ PLACESENT _ 0 _ _ godzin temu';
  }

  @override
  String daysAgo(int days) {
    return '_ _ PLACESENT _ 0 _ _ dni temu';
  }

  @override
  String get dataManagement => 'Zarządzanie danymi';

  @override
  String get dataManagementDesc => 'Eksportuj lub usuwaj dane konta';

  @override
  String get splashTagline => 'Wpisy dotyczące rzeczywistego czasu obserwacji';

  @override
  String get splashStartingUp => 'Zaczynając...';

  @override
  String get splashInitializationFailed => 'Inicjalizacja nie powiodła się';

  @override
  String get splashInitializationFailedTitle =>
      'Inicjalizacja nie powiodła się';

  @override
  String get splashInitializationError =>
      'Aplikacja nie zainicjowała prawidłowo:';

  @override
  String get splashRetry => 'Retry';

  @override
  String get splashContinue => 'Kontynuuj';

  @override
  String get splashInitializing => 'Inicjowanie...';

  @override
  String signInWelcome(String username) {
    return 'Powitanie _ _ PLACESENER _ 0 _ _!';
  }

  @override
  String signInFailed(String error) {
    return 'Sygnał nie powiódł się: _ _ PLACESENT _ 0 _ _';
  }

  @override
  String get signInPleaseEnterEmail => 'Proszę podać swój adres e-mail';

  @override
  String get signInPleaseEnterValidEmail =>
      'Proszę podać poprawny adres e-mail';

  @override
  String get signInMagicLinkSent =>
      'Magiczne połączenie wysłane! Sprawdź swój e-mail i kliknij link do zalogowania się.';

  @override
  String get signInMagicLinkFailed =>
      'Nie udało się wysłać magicznego łącza. Proszę spróbować jeszcze raz.';

  @override
  String get signInAllDataCleared => 'Wszystkie dane oczyszczone';

  @override
  String get signInSubtitle =>
      'Real- time alerty obserwacji UFO i raporty MUFON';

  @override
  String get signInGoogleLoading => 'Wpisuję się...';

  @override
  String get signInContinueWithGoogle => 'Kontynuuj z Google';

  @override
  String get signInOr => 'lub';

  @override
  String get signInWithEmail => 'Zaloguj się e- mailem';

  @override
  String get signInEmailDescription =>
      'Wyślemy ci bezpieczne połączenie, aby się zalogować';

  @override
  String get signInEmailAddress => 'Adres e-mail';

  @override
  String get signInEmailPlaceholder => 'twój @ email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'Spróbuj ponownie w _ _ PLACEScorter _ 0 _ _ s';
  }

  @override
  String get signInSending => 'Wysyłam...';

  @override
  String get signInSendMagicLink => 'Wyślij magiczny link';

  @override
  String get signInCheckEmail =>
      'Sprawdź swój e-mail! Połączenie wygasa za 15 minut.';

  @override
  String get signInSecureAuth => 'Bezpieczne uwierzytelnienie';

  @override
  String get signInSecureAuthDescription =>
      'Użyj Google Sign- In dla natychmiastowego dostępu, lub e-mail magiczne linki, które wygasają w 15 minut.';

  @override
  String get signInClearAllDataDebug => 'Wyczyść wszystkie dane (debugowanie)';

  @override
  String get emailAuthFailedToSend => 'Nie udało się wysłać e-maila';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'Nie udało się wysłać e-maila. Proszę spróbować jeszcze raz.';

  @override
  String get emailAuthInvalidEmail =>
      'Nieprawidłowy adres e-mail. Proszę sprawdzić format.';

  @override
  String get emailAuthUserNotFound =>
      'Nie znaleziono konta z tym adresem e-mail.';

  @override
  String get emailAuthTooManyRequests =>
      'Zbyt wiele prób. Proszę spróbować później.';

  @override
  String get emailAuthOperationNotAllowed =>
      'Email link signing- in nie jest włączony.';

  @override
  String get emailAuthQuotaExceeded =>
      'Przekroczono kwotę pocztową. Proszę spróbować jutro.';

  @override
  String get emailAuthVerificationFailed =>
      'Weryfikacja poczty elektronicznej nie powiodła się. Proszę spróbować jeszcze raz.';

  @override
  String get emailAuthTitle => 'Weryfikacja poczty elektronicznej';

  @override
  String get emailAuthVerifyYourEmail => 'Sprawdź swój e-mail';

  @override
  String get emailAuthDescription =>
      'Dodaj swój adres e-mail do odzyskiwania konta i bezpieczeństwa. Wyślemy ci bezpieczny sygnał.';

  @override
  String get emailAuthEmailAddress => 'Adres e-mail';

  @override
  String get emailAuthEmailPlaceholder => 'your.email @ example.com';

  @override
  String get emailAuthPleaseEnterEmail => 'Proszę podać swój adres e-mail';

  @override
  String get emailAuthPleaseEnterValidEmail =>
      'Proszę podać poprawny adres e-mail';

  @override
  String get emailAuthCheckEmailToContinue =>
      'Sprawdź swój e-mail i dotknij łącza weryfikacji, aby kontynuować.';

  @override
  String get emailAuthResendEmail => 'Przywróć email';

  @override
  String get emailAuthSendVerificationEmail => 'Wyślij weryfikację E-mail';

  @override
  String get emailAuthHowItWorks =>
      'Jak działa weryfikacja poczty elektronicznej';

  @override
  String get emailAuthHowItWorksSteps =>
      '1. Wysyłamy Ci bezpieczny sygnał w link\n2. Sprawdź swój e-mail i stuknij link\n3. Twój e-mail zostaje zweryfikowany automatycznie\n4. Żadnych haseł!';

  @override
  String get emailAuthSecurityNotice =>
      'Weryfikacja poczty elektronicznej pomaga zabezpieczyć konto i umożliwia odzyskanie konta, jeśli stracisz dostęp do urządzenia.';

  @override
  String get phoneAuthFailedToSendCode =>
      'Nie udało się wysłać kodu weryfikacji. Proszę spróbować jeszcze raz.';

  @override
  String get phoneAuthInvalidCodeTryAgain =>
      'Nieprawidłowy kod weryfikacyjny. Proszę spróbować jeszcze raz.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'Numer telefonu zweryfikowany: _ _ PLACESENT _ 0 _ _';
  }

  @override
  String get phoneAuthVerificationFailed =>
      'Weryfikacja telefonu nie powiodła się. Proszę spróbować jeszcze raz.';

  @override
  String get phoneAuthCodeResent => 'Kod weryfikacji urażony';

  @override
  String get phoneAuthFailedToResendCode =>
      'Nie udało się przywrócić kodu. Proszę spróbować jeszcze raz.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'Nieprawidłowy numer telefonu. Proszę sprawdzić format.';

  @override
  String get phoneAuthTooManyRequests =>
      'Zbyt wiele prób. Proszę spróbować później.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'Nieprawidłowy kod weryfikacyjny. Proszę sprawdzić i spróbować ponownie.';

  @override
  String get phoneAuthSessionExpired =>
      'Sesja weryfikacyjna wygasła. Proszę o nowy kod.';

  @override
  String get phoneAuthSmsQuotaExceeded =>
      'Przekroczono kwotę SMS. Proszę spróbować jutro.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'Ten numer telefonu jest już powiązany z innym kontem.';

  @override
  String get phoneAuthVerificationFailedGeneric =>
      'Weryfikacja nie powiodła się. Proszę spróbować jeszcze raz.';

  @override
  String get phoneAuthTitle => 'Weryfikacja telefonu';

  @override
  String get phoneAuthVerifyYourPhone => 'Weryfikacja telefonu';

  @override
  String get phoneAuthEnterVerificationCode => 'Wprowadź weryfikację Kod';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'Dodaj swój numer telefonu do odzyskiwania i ochrony konta';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return 'Wprowadź 6-cyfrowy kod wysłany do _ _ PLACEScorped _ 0 _ _';
  }

  @override
  String get phoneAuthPhoneNumber => 'Numer telefonu';

  @override
  String get phoneAuthPhonePlaceholder => '+ 1 (555) 123- 4567';

  @override
  String get phoneAuthPleaseEnterPhone => 'Proszę podać swój numer telefonu';

  @override
  String get phoneAuthPleaseEnterValidPhone =>
      'Proszę podać poprawny numer telefonu';

  @override
  String get phoneAuthVerificationCode => 'Kod weryfikacji';

  @override
  String get phoneAuthPleaseEnterSixDigitCode =>
      'Proszę wprowadzić kod 6-cyfrowy';

  @override
  String get phoneAuthResendCode => 'Przywróć kod';

  @override
  String get phoneAuthSendVerificationCode => 'Wyślij weryfikację Kod';

  @override
  String get phoneAuthVerifyCode => 'Weryfikacja kodu';

  @override
  String get phoneAuthChangePhoneNumber => 'Zmień numer telefonu';

  @override
  String get phoneAuthSmsNotice =>
      'Wyślemy ci kod weryfikacyjny przez SMS. Można stosować standardowe stawki komunikatów.';

  @override
  String get phoneAuthCodeExpires =>
      'Kod wygasa za 60 sekund. Sprawdź wiadomości.';

  @override
  String get yourDataRights => 'Twoje prawa do danych';

  @override
  String get dataRightsExplanation =>
      'Masz pełną kontrolę nad swoimi danymi osobowymi. Możesz eksportować wszystkie dane lub trwale usuwać swoje konto w dowolnym momencie.';

  @override
  String get exportYourData => 'Eksportuj swoje dane';

  @override
  String get exportDataDescription => 'Pobierz wszystkie dane konta';

  @override
  String get exportData => 'Eksport danych';

  @override
  String get exportingData => 'Eksportowanie...';

  @override
  String get exportDataDetails =>
      'Zawiera: profil, piki, komentarze, informacje o urządzeniu i preferencje. Dane są dostarczane w formacie JSON.';

  @override
  String get dataExportedSuccessfully => 'Dane eksportowane pomyślnie';

  @override
  String get dataExportFailed => 'Nie udało się wyeksportować danych';

  @override
  String get deleteAccount => 'Usuń konto';

  @override
  String get deleteAccountDescription =>
      'Stałe usuwanie konta i wszystkich danych';

  @override
  String get deleteAccountWarning =>
      'Tego działania nie można cofnąć. Wszystkie Twoje sygnały, komentarze i dane konta zostaną trwale usunięte.';

  @override
  String get deleteMyAccount => 'Usuń moje konto';

  @override
  String get deletingAccount => 'Usuwanie...';

  @override
  String get deleteAccountConfirmTitle => 'Usuń konto';

  @override
  String get deleteAccountConfirmMessage =>
      'Czy na pewno chcesz usunąć swoje konto? Działanie to jest trwałe i nie może zostać cofnięte.';

  @override
  String get dataWillBeDeleted => 'Następujące dane zostaną trwale usunięte:';

  @override
  String get deletedDataList =>
      '• Twój profil i nazwa użytkownika\n• Wszystkie twoje sygnały i raporty\n• Wszystkie komentarze\n• Dane rejestracyjne urządzenia\n• Dane dotyczące lokalizacji i preferencji';

  @override
  String get deleteAccountPermanent => 'Usuń na stałe';

  @override
  String get accountDeletedSuccessfully => 'Konto usunięte pomyślnie';

  @override
  String get accountDeletionFailed => 'Nie udało się usunąć konta';

  @override
  String get onboardingWelcomeTitle => 'Witamy w UFOBeep';

  @override
  String get onboardingWelcomeBody =>
      'Uzyskaj natychmiastowy alarm, gdy UFO zostaną zauważone w pobliżu twojej lokalizacji. Nigdy więcej nie przegap widoku!';

  @override
  String get onboardingReportTitle => 'Widzisz coś? Pip!';

  @override
  String get onboardingReportBody =>
      'Uchwycić zdjęcia i filmy z obserwacji UFO. Natychmiast podziel się z globalną społecznością.';

  @override
  String get onboardingCompassTitle => 'Zobacz, gdzie patrzyli';

  @override
  String get onboardingCompassBody =>
      'Kompas pokazuje dokładny kierunek, w którym patrzył świadek, gdy zobaczył UFO. Wyceluj w telefon i patrz!';

  @override
  String get onboardingCommunityTitle => 'Połącz się z obserwatorami';

  @override
  String get onboardingCommunityBody =>
      'Przeczytaj najnowsze obserwacje UFO nad poranną kawą. Dostęp do profesjonalnych danych MUFON i połączyć się z innymi obserwatorami.';

  @override
  String get skip => 'Pomiń';

  @override
  String get getStarted => 'Zacznij';

  @override
  String get viewOnboardingAgain => 'Zobacz ponownie na pokładzie';

  @override
  String get customAlertRange => 'Własny zakres alarmów';

  @override
  String get enterRangeKm => 'Wprowadź zakres w km (1- 99999)';

  @override
  String get largeRangeWarning =>
      'Duże zakresy (> 100 km) mogą generować wiele wpisów';

  @override
  String get globalRangeWarning =>
      'Bardzo duże zakresy (> 1000km) wyśle alarmy z całego świata';

  @override
  String get invalidRange => 'Proszę podać liczbę od 1 do 99999';

  @override
  String get celestialSunDaylight =>
      'Słońce wschodzi - warunki dnia mogą wpływać na widoczność';

  @override
  String get celestialSunTwilight =>
      'Twilight warunki - niektóre widoczność, ale ciemniejsze niż światło dzienne';

  @override
  String get celestialSunDark =>
      'Ciemne warunki - optymalne do obserwacji obiektów na niebie';

  @override
  String celestialMoonBright(Object phase) {
    return 'Jasny _ _ PLACESORM _ 0 _ _ księżyc widoczny - może oświetlić lub zasłonić inne obiekty';
  }

  @override
  String celestialMoonModerate(Object phase) {
    return '_ _ PLACESENER _ 0 _ _ widzialny księżyc - umiarkowane warunki oświetlenia';
  }

  @override
  String celestialMoonThin(Object phase) {
    return 'Widoczne cienkie _ _ PLACEStore _ 0 _ _ moon - minimalne oświetlenie';
  }

  @override
  String celestialMoonHidden(Object phase) {
    return '_ _ PLACESENER _ 0 _ _ księżyc poniżej horyzontu - brak oświetlenia Księżyca';
  }

  @override
  String get celestialNoPlanets =>
      'Żadnych jasnych planet, które mogłyby być mylone z UFO';

  @override
  String celestialPlanetHigh(Object altitude, Object planet) {
    return '_ _ PLACESORM _ 0 _ _ wysokie koszty ogólne (_ _ PLACESORM _ 1 _ _ °) - bardzo znaczące';
  }

  @override
  String celestialPlanetMedium(Object altitude, Object planet) {
    return '_ _ PLACESORM _ 0 _ _ widoczny na _ _ PLACESORM _ 1 _ _ ° - może być mylony z samolotem';
  }

  @override
  String celestialPlanetLow(Object altitude, Object planet) {
    return '_ _ PLACESECRET _ 0 _ _ low on horizon (_ _ PLACESECRET _ 1 _ _ °)';
  }

  @override
  String get celestialNoStars => 'Nie widać żadnych gwiazd';

  @override
  String celestialStarSingle(Object altitude, Object star) {
    return '_ _ PLACEScorpiter _ 0 _ _ widoczna na _ _ PLACEScorpiter _ 1 _ _ °';
  }

  @override
  String celestialStarsMultiple(Object count, Object names) {
    return '_ _ PLACESECRET _ 0 _ _ jasne gwiazdy widoczne - _ _ PLACESECRET _ 1 _ _';
  }

  @override
  String get celestialSummaryDaylight => 'Warunki światła dziennego';

  @override
  String get celestialSummaryDark => 'Warunki ciemnego nieba';

  @override
  String get celestialSummaryMoonUp => 'światło księżyca obecny';

  @override
  String get celestialSummaryMoonDown => 'brak oświetlenia księżyca';

  @override
  String celestialSummaryManyObjects(Object count) {
    return '_ _ PLACESORM _ 0 _ _ jasne obiekty, które mogą być mylone z UFO';
  }

  @override
  String celestialSummarySomeObjects(Object count) {
    return '_ _ PLACEScorter _ 0 _ _ jasny (-e) obiekt (-y) widoczny (-e)';
  }

  @override
  String get celestialSummaryFewObjects => 'minimalne jasne obiekty na niebie';

  @override
  String celestialSkySummary(Object conditions) {
    return 'Warunki dotyczące nieba: _ _ PLACESENT _ 0 _ _';
  }
}
