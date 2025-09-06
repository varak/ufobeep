// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appName => 'UFO- piippi';

  @override
  String get ok => 'SELVÄ';

  @override
  String get cancel => 'Peruuta';

  @override
  String get close => 'Sulje';

  @override
  String get save => 'Tallenna';

  @override
  String get delete => 'Poista';

  @override
  String get edit => 'Muokkaa';

  @override
  String get retry => 'Uudelleen';

  @override
  String get yes => 'Kyllä';

  @override
  String get no => 'Ei';

  @override
  String get back => 'Takaisin';

  @override
  String get next => 'Seuraava';

  @override
  String get done => 'Valmis';

  @override
  String get loading => 'Ladataan..';

  @override
  String get processing => 'Käsittely..';

  @override
  String get errorGeneric => 'Jokin meni pieleen.';

  @override
  String get networkError => 'Verkkovirhe. Tarkista yhteytesi.';

  @override
  String get permissionsRequired => 'Tarvittavat luvat';

  @override
  String get learnMore => 'Lue lisää';

  @override
  String get welcomeTitle => 'Tervetuloa UFO- piippiin';

  @override
  String get welcomeSubtitle => 'Reaaliaikaiset UFO-hälytykset lähelläsi';

  @override
  String get signIn => 'Kirjaudu sisään';

  @override
  String get signOut => 'Kirjaudu ulos';

  @override
  String get continueAsGuest => 'Jatka vieraana';

  @override
  String get enterUsername => 'Anna käyttäjätunnus';

  @override
  String get username => 'Käyttäjätunnus';

  @override
  String get usernameUpdated => 'Käyttäjänimi päivitetty';

  @override
  String get profile => 'Profiili';

  @override
  String get settings => 'Asetukset';

  @override
  String get tabAlerts => 'Kuulutukset';

  @override
  String get tabBeep => 'Piip';

  @override
  String get tabChat => 'Keskustelu';

  @override
  String get tabMap => 'Kartta';

  @override
  String get tabSettings => 'Asetukset';

  @override
  String get alertsTitle => 'Lähellä olevat hälytykset';

  @override
  String get noAlerts => 'Lähellä ei ole vielä hälytystä.';

  @override
  String get pullToRefresh => 'Vedä virkistääksesi';

  @override
  String alertDistance(String distance) {
    return '_PH_0_ pois';
  }

  @override
  String alertDirection(int bearing) {
    return 'Suunta _PH_0_°';
  }

  @override
  String get viewAlert => 'Näytä hälytys';

  @override
  String get viewOnMap => 'Näytä kartalta';

  @override
  String get iSeeItToo => 'Minäkin näen sen';

  @override
  String get confirmWitnessed => 'Oletteko todistanut tämän?';

  @override
  String get witnessConfirmed => 'Kiitos teidän vahvistus oli lähetetty.';

  @override
  String get createBeepTitle => 'Lähetä äänimerkki';

  @override
  String get beepExplain => 'Vangitkaa näkemänne ja hälyttäkää lähivalvojat.';

  @override
  String get capturePhoto => 'Ota kuva';

  @override
  String get captureVideo => 'Ota video';

  @override
  String get pickFromGallery => 'Valitse galleriasta';

  @override
  String get descriptionHint => 'Kuvaile, mitä näet taivaalla';

  @override
  String get submitBeep => 'Lähetä viesti';

  @override
  String get beepSent => 'Lähetetty';

  @override
  String get uploadingMedia => 'Lähetetään mediaa..';

  @override
  String get includeLocation => 'Sisällytä sijainti';

  @override
  String get includeTimestamp => 'Sisällytä aikaleima';

  @override
  String get beepFailed => 'Lähetys epäonnistui.';

  @override
  String get mediaProcessing => 'Käsittelyvälineet..';

  @override
  String get cameraPermissionTitle => 'Tarvitaan kameran käyttö';

  @override
  String get cameraPermissionBody =>
      'Anna kameran käyttää kaapata UFO kuvia ja videoita.';

  @override
  String get locationPermissionTitle => 'Tarvittava sijainti';

  @override
  String get locationPermissionBody =>
      'Käytämme sijaintisi lähettää ja vastaanottaa lähellä hälytyksiä.';

  @override
  String get microphonePermissionTitle => 'Mikrofoni tarvitaan';

  @override
  String get microphonePermissionBody =>
      'Antakaa mikrofonin pääsy videon kaappaamiseen audiolla.';

  @override
  String get openSettings => 'Avaa asetukset';

  @override
  String get alertDetailTitle => 'Näytön yksityiskohdat';

  @override
  String reportedBy(String username) {
    return 'Raportoinut $username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Raportoitu $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '_PH_0_ pois';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Kohteen suunta: _PH_0_°';
  }

  @override
  String get openCompass => 'Avoin kompassi';

  @override
  String get openAR => 'Avaa AR-overlay';

  @override
  String get openChat => 'Avaa keskustelu';

  @override
  String get commentsTitle => 'Huomautukset';

  @override
  String get addComment => 'Lisää kommentti..';

  @override
  String get send => 'Lähetä';

  @override
  String get commentPosted => 'Kommentti lähetetty';

  @override
  String get autoFollowEnabled => 'Seuraat nyt tätä hälytystä.';

  @override
  String get noCommentsYet => 'Ei vielä kommentteja. Ole ensimmäinen!';

  @override
  String get newCommentNotification =>
      'Uusi kommentti havaintoon jota seuraat.';

  @override
  String get mapTitle => 'Live Map';

  @override
  String get compassTitle => 'Kompassi';

  @override
  String get compassSettings => 'Kompassiasetukset';

  @override
  String get compassMode => 'Kompassitila';

  @override
  String get compassStandardMode => 'Vakiotila';

  @override
  String get compassPilotMode => 'Pilottitila';

  @override
  String get compassStandardDescription => 'Perusotsikko ja navigointi';

  @override
  String get compassPilotDescription =>
      'Edistynyt navigointi ETA:n ja vektoroinnin avulla';

  @override
  String pointingTo(String direction) {
    return 'Osoitetaan _PH_0__';
  }

  @override
  String get calibratingCompass => 'Kalibroidaan kompassia..';

  @override
  String get openAROverlay => 'Avaa AR-overlay';

  @override
  String get pushTitleAlertNearby => 'UFO hälytys lähelläsi';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Uusi havainto raportoitiin __PH_0_ pois.';
  }

  @override
  String get pushTitleComment => 'Uusi kommentti';

  @override
  String get pushBodyComment => 'Joku kommentoi havaintoasi.';

  @override
  String get pushTitleWitness => 'Todistajan vahvistus';

  @override
  String get pushBodyWitness => 'Käyttäjä vahvisti nähneensä saman esineen.';

  @override
  String get weather => 'Sää';

  @override
  String cloudCover(int percent) {
    return 'Pilvipeite: _PH_0_%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Tuuli: $speed$unit';
  }

  @override
  String get nearbyAircraft => 'Lähellä lentokonetta';

  @override
  String get noAircraft => 'Ei lentokoneita lähistöllä';

  @override
  String get loadingContext => 'Ladataan ympäristöolosuhteita..';

  @override
  String get settingsTitle => 'Asetukset';

  @override
  String get notifications => 'Ilmoitukset';

  @override
  String get enablePushNotifications => 'Käytä työntöilmoituksia';

  @override
  String get quietHours => 'Hiljaiset tunnit';

  @override
  String get quietHoursDesc =>
      'Hiljaiset hälytykset valittujen tuntien välillä.';

  @override
  String get dndMode => 'Älä häiritse';

  @override
  String get dndUntil => 'Älä häiritse ennen kuin';

  @override
  String get language => 'Kieli';

  @override
  String get chooseLanguage => 'Valitse kieli';

  @override
  String get units => 'Yksikkö';

  @override
  String get unitsImperial => 'Keisarillinen (mi,mph)';

  @override
  String get unitsMetric => 'Metri (km, km/h)';

  @override
  String get privacyPolicy => 'Yksityisyyden suoja';

  @override
  String get termsOfUse => 'Käyttöehdot';

  @override
  String get errorNoLocation =>
      'Sijaintia ei ole saatavilla. Yritä uudelleen ulkona selkeä taivas.';

  @override
  String get errorNoCamera => 'Tällä laitteella ei ole kameraa.';

  @override
  String get errorUploadFailed => 'Lähetys epäonnistui. Yritä uudestaan.';

  @override
  String get errorPermissionDenied => 'Lupa evätty.';

  @override
  String get errorInvalidUsername => 'Tämä käyttäjätunnus ei ole saatavilla.';

  @override
  String get nothingToShow => 'Ei vielä mitään näytettävää.';

  @override
  String get storeShortDesc =>
      'UFO-hälytys. Vangitkaa, vahvistakaa ja jutelkaa reaaliajassa.';

  @override
  String get storeLongDesc =>
      'Ufopieppi lähettää reaaliaikaisia hälytyksiä, kun joku näkee ufon lähellä. Ota valokuvia ja videoita, vahvista havaintoja hanalla, katso suunta & etäisyys, ja keskustella muiden skywaters.';

  @override
  String get keywords =>
      'UFO, UAP,OVNI, muukalaiset, nähtävyydet,skykello, hälytys, radar, kompassi';

  @override
  String get noAlertsFound => 'Ei osumia';

  @override
  String get alertsFilterHelp =>
      'Yritä säätää suodattimia nähdäksesi lisää tuloksia';

  @override
  String get verified => 'Varmennettu';

  @override
  String get beepOnly => 'vain piip';

  @override
  String get videoOnly => 'ainoastaan video';

  @override
  String get imageOnly => 'vain kuva';

  @override
  String get timeJustNow => 'Juuri nyt';

  @override
  String timeDaysAgo(int count) {
    return '_PH_0_d sitten';
  }

  @override
  String timeHoursAgo(int count) {
    return '_PH_0_h sitten';
  }

  @override
  String timeMinutesAgo(int count) {
    return '_PH_0_m sitten';
  }

  @override
  String get loadMoreAlerts => 'Lataa lisää hälytyksiä';

  @override
  String get toggleMufonTooltip => 'Vaihda MUFON- havaintoja';

  @override
  String get showMufonData => 'Näytä MUFON- tiedot';

  @override
  String get hideMufonData => 'Piilota MUFON- tiedot';

  @override
  String get showingUfoBeepOnly => 'Näytetään vain UFOBeepin raportit';

  @override
  String get showingAllReports =>
      'Näytetään kaikki raportit mukaan lukien MUFON- tietokanta';

  @override
  String get filteredSuffix => 'suodatettu';

  @override
  String get detailsTitle => 'Yksityiskohdat';

  @override
  String get mufonCase => 'MUFON Asia';

  @override
  String get sightingDate => 'Näkymispäivä';

  @override
  String get databaseEntry => 'Tietokannan tietue';

  @override
  String get locationLabel => 'Sijainti';

  @override
  String get distanceLabel => 'Etäisyys';

  @override
  String get timeLabel => 'Aika';

  @override
  String get reportedByLabel => 'Raportoinut';

  @override
  String get unknownLocation => 'Tuntematon sijainti';

  @override
  String get locationUnknown => 'Sijainti tuntematon';

  @override
  String get witnessesLabel => 'Todistajat';

  @override
  String witnessesCountMessage(int count) {
    return '_PH_0_ ihmiset vahvistivat tämän havainnon';
  }

  @override
  String get photoAnalysisTitle => 'Valokuva-analyysi';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analyysi: $count mediatiedosto [s] käsitelty';
  }

  @override
  String get addMoreMedia => 'Lisää lisää';

  @override
  String get addMedia => 'Lisää media';

  @override
  String get retakePhoto => 'Uusi kuva';

  @override
  String get retakeVideo => 'Palauta video';
}
