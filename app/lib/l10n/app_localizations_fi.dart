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
    return '_Placeholder_0_ pois';
  }

  @override
  String alertDirection(int bearing) {
    return 'Suunta __PAIKKAHOLDER_0_°';
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
  String beepSentWithUrl(String shortUrl) {
    return 'Piip lähetetty onnistuneesti';
  }

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
  String get locationPermissionTitle => 'Sijainti Lupa vaaditaan';

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
    return 'Ilmoittanut __PAIKKAHOLDER_0__';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Raportoitu __PAIKKAHOLDER_0___';
  }

  @override
  String distanceAway(String distance) {
    return '__PAIKKAHOLDER_0___';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Kohde: __PAIKKAHOLDER_0_°';
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
  String get noCommentsYet =>
      'Ei vielä kommentteja. Ole ensimmäinen kommentoimaan!';

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
    return 'Osoitetaan __PAIKKAHOLDER_0__';
  }

  @override
  String get calibratingCompass => 'Kalibroidaan kompassia..';

  @override
  String get openAROverlay => 'Avaa AR-overlay';

  @override
  String get pushTitleAlertNearby => 'UFO hälytys lähelläsi';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Uusi havainto raportoitiin __PASSIHOLDER_0_ pois.';
  }

  @override
  String get pushTitleComment => 'Uusi kommentti';

  @override
  String get pushBodyComment => 'Joku kommentoi havaintoasi.';

  @override
  String get pushTitleWitness => 'Todistajan vahvistus';

  @override
  String get temperature => 'Lämpötila';

  @override
  String get pushBodyWitness => 'Käyttäjä vahvisti nähneensä saman esineen.';

  @override
  String get weather => 'Sää';

  @override
  String cloudCover(int percent) {
    return 'Pilvipeite: __Placeholder_0__%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Tuuli: __PAIKKAHOLDER_0____PAIKKAHOLDER_1__';
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
  String get enablePushNotifications =>
      'Hae ilmoituksia tulevia kommentteja varten';

  @override
  String get quietHours => 'Hiljaiset tunnit';

  @override
  String get quietHoursDesc =>
      'Hiljaiset hälytykset valittujen tuntien välillä.';

  @override
  String get quietHoursEnabled => 'Käytä hiljaisia tunteja';

  @override
  String get quietHoursFrom => 'Alkaen';

  @override
  String get quietHoursUntil => 'Asti';

  @override
  String get quietHoursDefaultTime => 'Oletus hiljaiset tunnit';

  @override
  String get emergencyOverride => 'Hätätila';

  @override
  String get emergencyOverrideDesc =>
      'Kiireellisten kuulutusten salliminen hiljaisina aikoina';

  @override
  String get dndMode => 'Älä häiritse';

  @override
  String get dndUntil => 'Älä häiritse ennen kuin';

  @override
  String dndEnabled(Object time) {
    return 'DND on käytössä kunnes __PAIKKAHOLDER_0__';
  }

  @override
  String get dndDisabled => 'DND ei käytössä';

  @override
  String quietHoursActive(String startTime, String endTime) {
    return 'Aktiivinen __PASSIHOLDER_0__ - __PASSIHOLDER_1__';
  }

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Hiljaiset tunnit: __Placeholder_0__ - __Placeholder_1_';
  }

  @override
  String get pushNotificationUfoAlert => 'UFO Varoitus';

  @override
  String get pushNotificationAnomalyAlert => 'Anomaliahälytys';

  @override
  String get pushNotificationNearby => 'Lähellä';

  @override
  String get pushNotificationInYourArea =>
      'sinun alueellasi. Napauta nähdäksesi yksityiskohdat.';

  @override
  String pushNotificationCommented(Object username) {
    return '__Placeholder_0__ kommentoi';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '__PASSIHOLDER_0__ kommentoi __PASSIHOLDER_1__';
  }

  @override
  String get pushNotificationGeneric => 'UFO- piippi';

  @override
  String get pushNotificationNewSighting => 'Uusi havainto lähellä';

  @override
  String get language => 'Kieli';

  @override
  String get chooseLanguage => 'Valitse kieli';

  @override
  String get units => 'Yksikkö';

  @override
  String get unitsImperial => 'Keisarillinen';

  @override
  String get unitsMetric => 'Metrinen';

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
  String get beepOnly => 'Vain piip';

  @override
  String get reportOnly => 'Vain teksti';

  @override
  String get videoOnly => 'Vain video';

  @override
  String get imageOnly => 'Vain kuva';

  @override
  String get mediaOnly => 'Vain media';

  @override
  String get timeJustNow => 'juuri nyt';

  @override
  String timeDaysAgo(int count) {
    return '_Placeholder_0__ päivää sitten';
  }

  @override
  String timeHoursAgo(int count) {
    return '__PASSIHOLDER_0__ tunteja sitten';
  }

  @override
  String timeMinutesAgo(int count) {
    return '_Placeholder_0__ minuuttia sitten';
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
  String get mufonSighting => 'MUFON Sighting Report';

  @override
  String get mufonLightSighting => 'MUFON Light Sighting Report';

  @override
  String get mufonSphereSighting => 'MUFON-pallon näkyvyysraportti';

  @override
  String get mufonDiscSighting => 'MUFON Levyn havainnointiraportti';

  @override
  String get mufonTriangleSighting => 'MUFON Kolmion havainnointiraportti';

  @override
  String get mufonCigarSighting => 'MUFON Cigar Sighting Report';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting Report';

  @override
  String get mufonRectangleSighting =>
      'MUFON Suorakulmion havainnointiraportti';

  @override
  String get mufonCylinderSighting => 'MUFON-sylinterin havainnointiraportti';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Sighting Report';

  @override
  String get mufonStarlikeSighting => 'MUFON Tähtien näkyvyysraportti';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON-tapaus #__Placeholder_0_ Yksityiskohdat';
  }

  @override
  String get sightingDate => 'Näkymispäivä';

  @override
  String get mufonDatabaseEntryDate => 'Päivämäärä Tietokanta';

  @override
  String get databaseEntry => 'Tietokannan tietue';

  @override
  String get shareLink => 'Jaa linkki';

  @override
  String get linkCopied => 'Linkki kopioitu leikepöydälle';

  @override
  String get locationLabel => 'Sijainti:';

  @override
  String get distanceLabel => 'Etäisyys';

  @override
  String get timeLabel => 'Aika:';

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
    return '_Placeholder_0_ ihmiset vahvistivat tämän havainnon';
  }

  @override
  String get photoAnalysisTitle => 'Valokuva-analyysi';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analyysi: __PAIKKAHOLDER_0__ mediatiedosto [s] käsitelty';
  }

  @override
  String get addMoreMedia => 'Lisää lisää';

  @override
  String get addMedia => 'Lisää media';

  @override
  String get retakePhoto => 'Uusi kuva';

  @override
  String get retakeVideo => 'Palauta video';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galleria';

  @override
  String get basicSettings => 'Perusasetukset';

  @override
  String get appSettings => 'Sovelluksen asetukset';

  @override
  String get timeFormat => 'Aikamuoto';

  @override
  String get timeFormat24Hour => '24 tuntia';

  @override
  String get timeFormat12Hour => '12 tuntia';

  @override
  String get timeFormatDesc => 'Näyttöaika 24 tunnin tai 12 tunnin muodossa';

  @override
  String get alertRange => 'Varoitusalue';

  @override
  String get manageNotificationsDesc => 'Hallitse tilauksia ja asetuksia';

  @override
  String get permissionsTitle => 'Lupa';

  @override
  String get permissionLocation => 'Sijainti';

  @override
  String get permissionCamera => 'Kamera';

  @override
  String get permissionNotifications => 'Ilmoitukset';

  @override
  String get permissionPhotos => 'Valokuvat';

  @override
  String get permissionGranted => 'Myönnetty';

  @override
  String get permissionNotGranted => 'Ei myönnetty';

  @override
  String get permissionGrant => 'Avustus';

  @override
  String get generateUsername => 'Luo uusi käyttäjätunnus';

  @override
  String get adminTools => 'Hallitse työkaluja';

  @override
  String get openAdminPanel => 'Avaa hallintapaneeli';

  @override
  String get webAdminInterface => 'Web Admin- käyttöliittymä';

  @override
  String get adminBetaNotice =>
      'Beta rakentaa vain. Hallitse työkaluja, joilla testataan lähikuulutuksia, työntöilmoituksia ja järjestelmän diagnostiikkaa.';

  @override
  String get whatDoYouSee => 'Mitä näet?';

  @override
  String get ufo => 'UFO';

  @override
  String get sighting => 'Näkyminen';

  @override
  String get ufoSighting => 'UFOBeep UFO Varoitus';

  @override
  String get envAnalysisTitle => 'Ympäristöanalyysi';

  @override
  String get envAnalysisPending => 'Analyysi kesken';

  @override
  String get envAnalysisPendingDesc =>
      'Ympäristötiedot ovat saatavilla käsittelyn aloittamisen jälkeen.';

  @override
  String get unknownAircraft => 'Tuntematon ilma-alus';

  @override
  String get moreAircraft => 'enemmän ilma-aluksia';

  @override
  String get showLess => 'Näytä vähemmän';

  @override
  String get premiumImageryTitle => 'Premium-satelliitti Kuvasto';

  @override
  String get premiumImagerySubtitle => 'Korkearesoluutioiset kaupalliset kuvat';

  @override
  String get sightingTypeLabel => 'Tyyppi';

  @override
  String get ufoTypeSphere => 'Pallo';

  @override
  String get ufoTypeTriangle => 'Kolmio';

  @override
  String get ufoTypeDisk => 'Levy';

  @override
  String get ufoTypeLight => 'Valo';

  @override
  String get ufoTypeFireball => 'Tulipallo';

  @override
  String get ufoTypeCylinder => 'Sylinteri';

  @override
  String get ufoTypeCigar => 'Sikari';

  @override
  String get ufoTypeRectangle => 'Suorakulmio';

  @override
  String get ufoTypeFormation => 'Muotoilu';

  @override
  String get ufoTypeUnknown => 'Tuntematon';

  @override
  String get ufoTypeBoomerang => 'Boomerang';

  @override
  String get ufoTypeDiamond => 'Timantti';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Cone';

  @override
  String get ufoTypeCross => 'Risti';

  @override
  String get ufoTypeDumbbell => 'Käsipaino';

  @override
  String get ufoTypeTeardrop => 'Teardrop';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Luoti';

  @override
  String get ufoTypeSaturn => 'Saturnus';

  @override
  String get ufoTypeStarLike => 'Tähtimäinen';

  @override
  String get ufoTypeBlimp => 'Blimp';

  @override
  String get shapeTriangle => 'kolmio';

  @override
  String get shapeDisc => 'levy';

  @override
  String get shapeDisk => 'levy';

  @override
  String get shapeSphere => 'pallo';

  @override
  String get shapeCigar => 'sikari';

  @override
  String get shapeLight => 'kevyt';

  @override
  String get shapeBoomerang => 'bumerang';

  @override
  String get shapeDiamond => 'timantti';

  @override
  String get shapeRectangle => 'suorakulmio';

  @override
  String get shapeOval => 'soikea';

  @override
  String get shapeCone => 'kartio';

  @override
  String get shapeCross => 'risti';

  @override
  String get shapeCylinder => 'sylinteri';

  @override
  String get shapeDumbbell => 'käsipaino';

  @override
  String get shapeTeardrop => 'kyynel';

  @override
  String get shapeTicTac => 'tic-tac';

  @override
  String get shapeBullet => 'luoti';

  @override
  String get shapeSaturn => 'saturnus';

  @override
  String get shapeStarlike => 'tähtimäinen';

  @override
  String get shapeBlimp => 'ilmalaiva';

  @override
  String get shapeFireball => 'tulipallo';

  @override
  String get shapeFormation => 'muodostuminen';

  @override
  String get shapeUnknown => 'tuntematon';

  @override
  String get actionsTitle => 'Toimet';

  @override
  String get addPhotosAndVideos => 'Lisää kuvia ja videoita';

  @override
  String get attachMedia => 'Liitä media';

  @override
  String get addCommentOptional => 'Lisää kommentti (valinnainen)';

  @override
  String get describeNewMedia => 'Kuvaile uutta mediaa.';

  @override
  String get filesSelected => 'valitut tiedostot';

  @override
  String get selectMediaToAttach => 'Valitse liitettävät kuvat tai videot';

  @override
  String get newMediaUploaded => 'Uusi media ladattu';

  @override
  String get mediaFilesUploaded => 'uudet mediatiedostot ladattu';

  @override
  String get filesAttachedSuccessfully => 'liitetyt tiedostot onnistuneesti';

  @override
  String get howToReportToMufon => 'Miten raportoida MUFON';

  @override
  String get reportToMufon => 'Raportoi MUFONille';

  @override
  String get whyReportToMufon => 'Miksi ilmoittautua Mufoniin?';

  @override
  String get openMufonReport => 'Avaa MUFON Kertomus';

  @override
  String get confirmedWitness => 'Varmistit tämän';

  @override
  String witnessesHaveConfirmed(int count) {
    return '_Placeholder_0_ ihmiset ovat vahvistaneet tämän havainnon';
  }

  @override
  String get aircraftTrackingTitle => 'Ilma-alusten seuranta';

  @override
  String get weatherConditionsTitle => 'Sääolosuhteet';

  @override
  String get noSatellitePasses => 'Ei näkyviä satelliitteja ei löytynyt';

  @override
  String get contentAnalysisTitle => 'Sisältöanalyysi';

  @override
  String get contentSafe => 'Sisältö on turvallista';

  @override
  String get contentFlagged => 'Tarkasteltavaksi merkitty sisältö';

  @override
  String get confidenceLabel => 'Luottamus';

  @override
  String get methodLabel => 'Menetelmä';

  @override
  String get premiumImageryAccessOnly =>
      'Premium satelliittikuvia on saatavilla vain:';

  @override
  String get premiumAccessCreators => 'Varoituksen luojat';

  @override
  String get premiumAccessWitnesses =>
      'Vahvistetut todistajat näkyvyysalueella';

  @override
  String get comingSoon => 'Tulossa pian';

  @override
  String get directionDistanceTitle => 'Suunta ja etäisyys';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Asia #__Placeholder_0___';
  }

  @override
  String get satellitePassesTitle => 'Satelliittipassit';

  @override
  String get satellitePassExplanation =>
      'Näkyvä satelliitti kulkee aikana havainnointi aikavälillä. Monet UFO-raportit ovat satelliitteja tai avaruusromua.';

  @override
  String get followingAlert =>
      'Varoituksen jälkeen - saat kommentti-ilmoitukset';

  @override
  String get unfollowedAlert =>
      'Seuraamaton hälytys - ei enää kommentti-ilmoituksia';

  @override
  String get alertFollowError => 'Virhe seurauksen tilan päivittämisessä';

  @override
  String get notificationChannelAlerts => 'UFOBeepin hälytykset';

  @override
  String get notificationChannelAlertsDesc =>
      'UFO-ääni- ja läheisyyshälytyksiä koskevat ilmoitukset';

  @override
  String get notificationSightingTitle => 'UFOBeep UFO Varoitus';

  @override
  String get notificationSightingUrgent => 'KIIREELLINEN UFO Varoitus';

  @override
  String get notificationSightingEmergency => 'Varoitus';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '__PASSIHOLDER_0___ lähellä __PASSIHOLDER_1_';
  }

  @override
  String notificationCommentTitle(String username) {
    return '💬 $username commented';
  }

  @override
  String get notificationWitnessText => 'Uusi havainto';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '_Placeholder_0__ silminnäkijät';
  }

  @override
  String get notificationActionSnooze => 'Torkut 1h';

  @override
  String get notificationActionDismiss => 'Poistu';

  @override
  String notificationDistance(String distance) {
    return '_Placeholder_0_ pois';
  }

  @override
  String get unknown => 'Tuntematon';

  @override
  String get report => 'raportti';

  @override
  String get mufon => 'mufoni';

  @override
  String get recentUfoBeepsTitle => 'Uusin UFO Piipit';

  @override
  String get recentUfoBeepsSubtitle =>
      'Live UFO-havaintoraportit maailmanlaajuiselta yhteisöltämme';

  @override
  String get recentUfoBeepsDescription =>
      'Tässä syötteessä yhdistyvät reaaliaikaiset UFOBeep \"piipit\" mobiilisovelluskäyttäjiltämme ja historiaraportit MUFON-tietokannasta.';

  @override
  String get loadingBeeps => 'Ladataan viimeaikaisia äänimerkkejä...';

  @override
  String get noBeepsAvailable => 'Ei piippejä tällä hetkellä.';

  @override
  String get anomalyReported => 'Anomalia';

  @override
  String get copyShortLink => 'Kopioi lyhyt linkki';

  @override
  String get shareAlert => 'Jaa hälytys';

  @override
  String get ufoSightingAlert => 'UFO Havaintovaroitus';

  @override
  String get previousPage => 'Edellinen';

  @override
  String get nextPage => 'Seuraava';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Sivu __PASSIHOLDER_0__ of _PASSIHOLDER_1__ (__PASSIHOLDER_2_ total piips)';
  }

  @override
  String get firstPage => 'Ensimmäinen';

  @override
  String get lastPage => 'Viimeinen';

  @override
  String get jumpToPage => 'Siirry sivulle';

  @override
  String get heroTagline =>
      'Hanki hälytykset, milloin mennä ulos ja katsoa ylös';

  @override
  String get heroDescription =>
      'Älä koskaan jätä väliin toista ufo-havaintoa alueellasi';

  @override
  String get downloadApp => 'Lataa sovellus';

  @override
  String get viewAllBeeps => 'Näytä kaikki äänimerkit';

  @override
  String get sightingsMap => 'Näyttökartta';

  @override
  String get globalSightingNetwork => 'Global Sighting Network';

  @override
  String get howItWorks => 'Miten se toimii';

  @override
  String get backToBeeps => 'Takaisin piipseihin';

  @override
  String get loadingDetails => 'Ladataan piippaustietoja...';

  @override
  String get details => 'Yksityiskohdat';

  @override
  String get location => 'Sijainti';

  @override
  String get timeAgo => 'sitten';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'mailia';

  @override
  String get distanceNearby => 'lähistöllä';

  @override
  String get ufobeepWitnesses => 'Todistajat';

  @override
  String get ufobeepConfirmations => 'Vahvistukset';

  @override
  String get ufobeepAlertLevel => 'Varoitustaso';

  @override
  String get ufobeepReportType => 'UFOBeepin raportti';

  @override
  String get mufonAttribution => 'MUFON Tietokantaraportti';

  @override
  String get mufonCaseNumber => 'Asia #';

  @override
  String get mufonGenericTitle => 'MUFON Sighting Report';

  @override
  String get mufonSphere => 'Pallo';

  @override
  String get mufonLight => 'Valo';

  @override
  String get mufonDisk => 'Levy';

  @override
  String get mufonTriangle => 'Kolmio';

  @override
  String get mufonCigar => 'Sikari';

  @override
  String get mufonOval => 'Oval';

  @override
  String get mufonCylinder => 'Sylinteri';

  @override
  String get mufonRectangle => 'Suorakulmio';

  @override
  String get mufonDiamond => 'Timantti';

  @override
  String get mufonFireball => 'Tulipallo';

  @override
  String get mufonFlash => 'Salama';

  @override
  String get mufonFormation => 'Muotoilu';

  @override
  String get mufonChanging => 'Muutos';

  @override
  String get mufonChevron => 'Merkki';

  @override
  String get mufonCone => 'Cone';

  @override
  String get mufonCross => 'Risti';

  @override
  String get mufonEgg => 'Munat';

  @override
  String get mufonOther => 'Kohde';

  @override
  String get mufonUnknown => 'Tuntematon objekti';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON__Placeholder_0_report';
  }

  @override
  String get nuforcAttribution => 'NUFORC Tietokantaraportti';

  @override
  String get nuforcCaseNumber => 'Asia #';

  @override
  String get nuforcGenericTitle => 'NUFORC Havaintoraportti';

  @override
  String get mediaImageNotFound => 'Kuvaa ei löytynyt';

  @override
  String get mediaPlayVideo => 'Toista video';

  @override
  String get mediaViewImage => 'Näytä kuva';

  @override
  String mediaCount(Object count) {
    return '_Placeholder_0_vedokset';
  }

  @override
  String get mediaCountSingle => '1 kuva';

  @override
  String mediaMoreImages(Object count) {
    return '+__PASSIHOLDER_0_ lisää';
  }

  @override
  String get errorNotFound => 'Piip ei löytynyt';

  @override
  String get errorLoadError => 'Piippauksen yksityiskohtia ei voitu ladata';

  @override
  String get shareYourThoughts => 'Jaa ajatuksesi tästä havainnosta...';

  @override
  String get postComment => 'Post Comment';

  @override
  String get loggedInAs => 'Kirjautunut sisään';

  @override
  String get logout => 'Kirjaudu ulos';

  @override
  String get notFollowing => 'Ei seuraa';

  @override
  String get follow => 'Seuraa';

  @override
  String get navRecentBeeps => 'Äskettäiset viestit';

  @override
  String get navMap => 'Kartta';

  @override
  String get navDownloadApp => 'Lataa sovellus';

  @override
  String get alertLevel => 'Varoitustaso';

  @override
  String get witnesses => 'Todistajat';

  @override
  String get confirmations => 'Vahvistukset';

  @override
  String get reporterLabel => 'Käyttäjän ilmoittama';

  @override
  String get coordinatesLabel => 'Koordinaatit';

  @override
  String get eventTime => 'Tapahtuma-aika';

  @override
  String get reportedTime => 'Raportoitu aika';

  @override
  String get addedToUfobeep => 'Lisätty UFO- piippiin';

  @override
  String get mufonDatabaseReport => 'MUFON Tapausnumero:';

  @override
  String get copyShortLinkTitle => 'Kopioi linkki leikepöydälle';

  @override
  String get imageNotFound => 'Kuvaa ei löytynyt';

  @override
  String get ufoSightingAlt => 'UFO Piip UFO-hälytys';

  @override
  String get celestialDataTitle => 'Taivaalliset objektit';

  @override
  String get visiblePlanets => 'Näkyvät planeetat';

  @override
  String get locationDataTitle => 'Sijaintitiedot';

  @override
  String get timezone => 'Aikavyöhyke';

  @override
  String get coordinates => 'Koordinaatit';

  @override
  String get processingSummaryTitle => 'Käsittelyn yhteenveto';

  @override
  String get processingTime => 'Käsittelyaika';

  @override
  String get successful => 'Onnistunut';

  @override
  String get failed => 'Ei onnistunut';

  @override
  String get locationEnrichmentTitle => 'Sijaintitiedot';

  @override
  String get aircraftDataSource => 'Tietolähde';

  @override
  String get noAircraftDetected => 'Ilma-alusta ei havaittu';

  @override
  String get sightingReport => 'Havaintoraportti';

  @override
  String get ufoAlert => 'UFO Varoitus';

  @override
  String get alert => 'Varoitus';

  @override
  String get notificationTickerUfoAlert => 'UFO-hälytys - Uusi nähtävyys';

  @override
  String get notificationTickerComment =>
      'UFO-hälytysjärjestelmän uusi huomautus';

  @override
  String get weatherConditions => 'Sääolosuhteet';

  @override
  String get visibility => 'Näkyvyys';

  @override
  String get humidity => 'Kosteus';

  @override
  String get pressure => 'Paine';

  @override
  String get locationDetails => 'Sijaintitiedot';

  @override
  String get city => 'Kaupunki';

  @override
  String get state => 'Tila';

  @override
  String get country => 'Maa';

  @override
  String get satelliteActivity => 'Satelliittitoiminta';

  @override
  String get satellitesVisibleOverhead =>
      'Satelliitit näkyvät yläpuolella havaintohetkellä ja paikan päällä';

  @override
  String get dataSource => 'Tietolähde';

  @override
  String get blackskyImagery => 'BlackSky-kuvasto';

  @override
  String get resolution => 'Päätöslauselma';

  @override
  String get groundResolution => '35cm pohjaresoluutio';

  @override
  String get delivery => 'Toimitus';

  @override
  String get averageDelivery => '90 minuutin keskiarvo';

  @override
  String get cost => 'Kustannukset';

  @override
  String get skyfiSatelliteImagery => 'SkyFi-satelliitti Kuvasto';

  @override
  String get region => 'Alue';

  @override
  String get remoteArea => 'Etäalue';

  @override
  String get startingPrice => 'Aloitushinta';

  @override
  String get coverage => 'Kattavuus';

  @override
  String get confidenceCoverage => '95% luottamusväli';

  @override
  String get status => 'Tila';

  @override
  String get shareThoughts => 'Jaa ajatuksesi tästä havainnosta...';

  @override
  String get postCommand => 'Postikomento';

  @override
  String get clouds => 'Pilvet';

  @override
  String get windLabel => 'Tuuli';

  @override
  String get filterAlerts => 'Suodatinhälytykset';

  @override
  String get alertSource => 'Varoituslähde';

  @override
  String get ufobeepOnly => 'Vain UFO- piippaus';

  @override
  String get ufobeepOnlyDescription =>
      'Näytä vain alkuperäiset UFOBeepin raportit (pois lukien MUFON-tietokanta)';

  @override
  String get alertDistanceRange => 'Varoitusetäisyysalue';

  @override
  String get showAllAlerts => 'Näytä kaikki hälytykset';

  @override
  String get showAll => 'Näytä kaikki';

  @override
  String get distanceSliderDescription =>
      'Vedä säätää, kuinka pitkälle haluat nähdä hälytykset. Aloita säänäkyvyysetäisyydestä kaikkien kuulutusten näyttämiseen etäisyydestä riippumatta.';

  @override
  String get applyFilters => 'Käytä suotimia';

  @override
  String get notificationRange => 'Ilmoitusalue';

  @override
  String get notificationRangeDescription =>
      'Hanki etsintäkuulutukset havaintoja varten tämän etäisyyden sisällä';

  @override
  String get viewingRange => 'Katselualue';

  @override
  String get viewingRangeDescription =>
      'Näytä havaintoja tämän etäisyyden sisällä selattaessa';

  @override
  String get weatherVisibility => 'Säänäkyvyys (~10 km)';

  @override
  String get localArea => 'Paikallinen alue (25 km)';

  @override
  String get regional => 'Alueellinen';

  @override
  String get pushNotifications => 'Työnnä ilmoitukset';

  @override
  String get alertBrowsing => 'Hälytysselaus';

  @override
  String get pushAlertsWithinDistance => 'Hanki ilmoituksia tälle alueelle';

  @override
  String get showAlertsWhenBrowsing => 'Suodata mitä näet luettelossa';

  @override
  String get heroMainTagline => 'Soita puhelimeen, kun ufot ovat lähellä';

  @override
  String get heroSecondaryTagline => 'Selvitä milloin ja missä katsoa taivasta';

  @override
  String get sourceFilters => 'Lähde';

  @override
  String get sourceFiltersDescription => 'Valitse mitkä raportit syötteestäsi';

  @override
  String get ufobeepAndMufon => 'UFO- piikki + MUFON';

  @override
  String get ufobeepOnlySource => 'Vain UFO- piippi';

  @override
  String get mufonOnlySource => 'Vain MUFON';

  @override
  String get browseFilters => 'Selaa';

  @override
  String get browseFiltersDescription =>
      'Kuulutusten katselu ja lajitteleminen';

  @override
  String get sortByNewest => 'Uusin';

  @override
  String get sortByNearest => 'Lähin';

  @override
  String get sortBy => 'Järjestä';

  @override
  String get pushAlertsTitle => 'Työnnä hälytykset';

  @override
  String get pushAlertsDescription => 'Mikä soi puhelimessasi';

  @override
  String get alertRadius => 'Hälytys Säde';

  @override
  String get mufonNoPushInfo =>
      'MUFON-raportit tuodaan yöllä, eivätkä ne laukaise työntökuulutuksia';

  @override
  String get privacyData => 'Tietosuoja & tiedot';

  @override
  String get privacyPolicyDesc => 'Miten suojaamme ja käytämme tietojasi';

  @override
  String get termsOfService => 'Käyttöehdot';

  @override
  String get termsOfServiceDesc => 'Oikeudelliset ehdot';

  @override
  String get locationTracking => 'Sijaintin seuranta';

  @override
  String get locationTrackingDesc => 'Läheisyyskuulutusten taustapaikka';

  @override
  String get locationTrackingTitle => 'Taustan sijainnin seuranta';

  @override
  String get locationTrackingExplanation =>
      'UFOBeep valvoo sijaintisi taustalla lähettää sinulle läheisyyttä hälytyksiä, kun UFO havaintoja tapahtuu lähellä nykyistä sijaintia, vaikka olet poissa kotoa.';

  @override
  String get locationTrackingBattery =>
      'Käyttää älykästä geoferointia alle 3% akun iskuun';

  @override
  String get backgroundLocationTracking => 'Käytä taustaa Seuranta';

  @override
  String get locationTrackingActive => 'Läheisyyskuulutusten seurantapaikka';

  @override
  String get locationTrackingInactive => 'Sijaintiseuranta ei ole käytössä';

  @override
  String get locationTrackingDisabledWarning =>
      'Et saa läheisyyshälytyksiä, kun siirryt uusiin paikkoihin';

  @override
  String get trackingStatus => 'Seurantatila';

  @override
  String get monitoringStatus => 'Seuranta';

  @override
  String get active => 'Aktiivinen';

  @override
  String get inactive => 'Ei aktiivinen';

  @override
  String get lastKnownLocation => 'Viimeisin tunnettu sijainti';

  @override
  String get lastLocationUpdate => 'Viimeisin päivitys';

  @override
  String get movementThreshold => 'Liikkumiskynnys';

  @override
  String get updateFrequency => 'Päivitystiheys';

  @override
  String get batteryImpact => 'Akun vaikutus';

  @override
  String get dataPrivacy => 'Tietosuoja';

  @override
  String get locationPermissionExplanation =>
      'UFOBeep tarvitsee \"Aina Salli\" paikantamisluvan seurata liikettäsi ja lähettää lähetyksiä, kun olet uusissa paikoissa.';

  @override
  String get benefitsTitle => 'Edut';

  @override
  String get locationTrackingBenefits =>
      '• Hanki UFO-hälytykset minne tahansa matkustat\n• Automaattiset sijaintipäivitykset\n• Käsikäyttöisiä asetuksia ei tarvita';

  @override
  String get allowLocationAccess => 'Salli sijainti';

  @override
  String get locationPermissionRequired =>
      'Sijaintilupa vaaditaan taustaseurantaan';

  @override
  String get locationTrackingEnabled => 'Taustan sijainnin seuranta käytössä';

  @override
  String get locationTrackingDisabled =>
      'Taustan sijainnin seuranta pois käytöstä';

  @override
  String get justNow => 'Juuri nyt';

  @override
  String minutesAgo(int minutes) {
    return '_Placeholder_0__ minuuttia sitten';
  }

  @override
  String hoursAgo(int hours) {
    return '__PASSIHOLDER_0__ tunteja sitten';
  }

  @override
  String daysAgo(int days) {
    return '_Placeholder_0__ päivää sitten';
  }

  @override
  String get dataManagement => 'Tietojen hallinta';

  @override
  String get dataManagementDesc => 'Vie tai poista tilisi tiedot';

  @override
  String get splashTagline => 'Reaaliaikaiset havaintohälytykset';

  @override
  String get splashStartingUp => 'Aloitetaan...';

  @override
  String get splashInitializationFailed => 'Alustaminen epäonnistui';

  @override
  String get splashInitializationFailedTitle => 'Alustaminen epäonnistui';

  @override
  String get splashInitializationError => 'Sovellus ei alustanut oikein:';

  @override
  String get splashRetry => 'Uudelleen';

  @override
  String get splashContinue => 'Jatka';

  @override
  String get splashInitializing => 'Alustetaan...';

  @override
  String signInWelcome(String username) {
    return 'Tervetuloa __PAIKKAHOLDER_0__!';
  }

  @override
  String signInFailed(String error) {
    return 'Kirjautuminen epäonnistui: __PAIKKAHOLDER_0___';
  }

  @override
  String get signInPleaseEnterEmail => 'Syötä sähköpostiosoite';

  @override
  String get signInPleaseEnterValidEmail => 'Anna kelvollinen sähköpostiosoite';

  @override
  String get signInMagicLinkSent =>
      'Taikalinkki lähetetty! Tarkista sähköpostisi ja klikkaa linkkiä kirjautua sisään.';

  @override
  String get signInMagicLinkFailed =>
      'Taikalinkin lähettäminen epäonnistui. Yritä uudestaan.';

  @override
  String get signInAllDataCleared => 'Kaikki tarkastetut tiedot';

  @override
  String get signInSubtitle =>
      'Reaaliaikaiset UFO-havaintohälytykset ja MUFON-raportit';

  @override
  String get signInGoogleLoading => 'Kirjaudun sisään...';

  @override
  String get signInContinueWithGoogle => 'Jatka Googlella';

  @override
  String get signInOr => 'tai';

  @override
  String get signInWithEmail => 'Kirjaudu sisään sähköpostilla';

  @override
  String get signInEmailDescription => 'Lähetämme sinulle turvallisen linkin';

  @override
  String get signInEmailAddress => 'Sähköpostiosoite';

  @override
  String get signInEmailPlaceholder => 'your@email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'Yritä uudelleen __PAIKKAHOLDER_0_s';
  }

  @override
  String get signInSending => 'Lähetetään...';

  @override
  String get signInSendMagicLink => 'Lähetä taikalinkki';

  @override
  String get signInCheckEmail =>
      'Tarkista sähköpostisi! Linkki päättyy 15 minuutin kuluttua.';

  @override
  String get signInSecureAuth => 'Turvallinen tunnistus';

  @override
  String get signInSecureAuthDescription =>
      'Käytä Google Sign-In instant pääsy, tai sähköposti magic linkkejä, jotka vanhenevat 15 minuuttia.';

  @override
  String get signInClearAllDataDebug => 'Tyhjennä kaikki tiedot (debug)';

  @override
  String get emailAuthFailedToSend => 'Sähköpostin lähettäminen epäonnistui';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'Sähköpostin lähettäminen epäonnistui. Yritä uudestaan.';

  @override
  String get emailAuthInvalidEmail =>
      'Virheellinen sähköpostiosoite. Tarkistakaa muoto.';

  @override
  String get emailAuthUserNotFound =>
      'Tällä sähköpostiosoitteella ei löytynyt tiliä.';

  @override
  String get emailAuthTooManyRequests =>
      'Liikaa yrityksiä. Yritä myöhemmin uudestaan.';

  @override
  String get emailAuthOperationNotAllowed =>
      'Sähköpostilinkki ei ole käytössä.';

  @override
  String get emailAuthQuotaExceeded =>
      'Sähköpostikiintiö ylitettiin. Yritä huomenna uudestaan.';

  @override
  String get emailAuthVerificationFailed =>
      'Sähköpostin tarkistus epäonnistui. Yritä uudestaan.';

  @override
  String get emailAuthTitle => 'Sähköpostin tarkistus';

  @override
  String get emailAuthVerifyYourEmail => 'Tarkista sähköpostisi';

  @override
  String get emailAuthDescription =>
      'Lisää sähköpostiosoite tilisi palautumista ja turvallisuutta varten. Lähetämme sinulle turvallisen yhteyden.';

  @override
  String get emailAuthEmailAddress => 'Sähköpostiosoite';

  @override
  String get emailAuthEmailPlaceholder => 'your.email@example.com';

  @override
  String get emailAuthPleaseEnterEmail => 'Syötä sähköpostiosoite';

  @override
  String get emailAuthPleaseEnterValidEmail =>
      'Anna kelvollinen sähköpostiosoite';

  @override
  String get emailAuthCheckEmailToContinue =>
      'Tarkista sähköpostisi ja napauta vahvistuslinkkiä jatkaaksesi.';

  @override
  String get emailAuthResendEmail => 'Palauta sähköposti';

  @override
  String get emailAuthSendVerificationEmail => 'Lähetä tarkistus Sähköposti';

  @override
  String get emailAuthHowItWorks => 'Miten sähköpostin tarkistus toimii';

  @override
  String get emailAuthHowItWorksSteps =>
      '1. Lähetämme sinulle turvallisen kirjautumislinkin.\n2. Tarkista sähköpostisi ja napauta linkkiä\n3. sähköpostisi varmennetaan automaattisesti\n4. Salasanoja ei tarvita!';

  @override
  String get emailAuthSecurityNotice =>
      'Sähköpostin varmistus auttaa turvaamaan tilisi ja mahdollistaa tilin palautuksen, jos menetät pääsyn laitteeseen.';

  @override
  String get phoneAuthFailedToSendCode =>
      'Tarkastuskoodia ei voitu lähettää. Yritä uudestaan.';

  @override
  String get phoneAuthInvalidCodeTryAgain =>
      'Virheellinen tarkastuskoodi. Yritä uudestaan.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'Puhelinnumero vahvistettu: __PAIKKAHOLDER_0___';
  }

  @override
  String get phoneAuthVerificationFailed =>
      'Puhelintarkastus epäonnistui. Yritä uudestaan.';

  @override
  String get phoneAuthCodeResent => 'Varmennuskoodi';

  @override
  String get phoneAuthFailedToResendCode =>
      'Koodia ei voitu lähettää uudelleen. Yritä uudestaan.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'Virheellinen puhelinnumero. Tarkistakaa muoto.';

  @override
  String get phoneAuthTooManyRequests =>
      'Liikaa yrityksiä. Yritä myöhemmin uudestaan.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'Virheellinen tarkastuskoodi. Tarkistakaa ja yrittäkää uudelleen.';

  @override
  String get phoneAuthSessionExpired =>
      'Tarkastusaika päättyi. Pyydä uusi koodi.';

  @override
  String get phoneAuthSmsQuotaExceeded =>
      'SMS-kiintiö ylitettiin. Yritä huomenna uudestaan.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'Tämä puhelinnumero on jo yhdistetty toiseen tiliin.';

  @override
  String get phoneAuthVerificationFailedGeneric =>
      'Varmennus epäonnistui. Yritä uudestaan.';

  @override
  String get phoneAuthTitle => 'Puhelintarkastus';

  @override
  String get phoneAuthVerifyYourPhone => 'Tarkista puhelin';

  @override
  String get phoneAuthEnterVerificationCode => 'Syötä tarkistus Koodi';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'Lisää puhelinnumerosi tilin palautukseen ja tietoturvaan';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return 'Anna 6-numeroinen koodi, joka on lähetetty osoitteeseen __Placeholder_0__';
  }

  @override
  String get phoneAuthPhoneNumber => 'Puhelinnumero';

  @override
  String get phoneAuthPhonePlaceholder => '+1 (555) 123- 4567';

  @override
  String get phoneAuthPleaseEnterPhone => 'Anna puhelinnumerosi';

  @override
  String get phoneAuthPleaseEnterValidPhone =>
      'Anna voimassa oleva puhelinnumero';

  @override
  String get phoneAuthVerificationCode => 'Tarkastuskoodi';

  @override
  String get phoneAuthPleaseEnterSixDigitCode => 'Anna 6-numeroinen koodi';

  @override
  String get phoneAuthResendCode => 'Hae koodi';

  @override
  String get phoneAuthSendVerificationCode => 'Lähetä tarkistus Koodi';

  @override
  String get phoneAuthVerifyCode => 'Tarkista koodi';

  @override
  String get phoneAuthChangePhoneNumber => 'Vaihda puhelinnumeroa';

  @override
  String get phoneAuthSmsNotice =>
      'Lähetämme varmistuskoodin tekstiviestillä. Viestin vakiohintoja voidaan soveltaa.';

  @override
  String get phoneAuthCodeExpires =>
      'Koodi päättyy 60 sekunnin kuluttua. Tarkista viestisi.';

  @override
  String get yourDataRights => 'Tietooikeudet';

  @override
  String get dataRightsExplanation =>
      'Sinulla on täysi kontrolli henkilötietoihisi. Voit viedä kaikki tietosi tai poistaa tilisi pysyvästi milloin tahansa.';

  @override
  String get exportYourData => 'Vie tietosi';

  @override
  String get exportDataDescription => 'Lataa kaikki tilitiedot';

  @override
  String get exportData => 'Vie tiedot';

  @override
  String get exportingData => 'Viedä...';

  @override
  String get exportDataDetails =>
      'Sisältää: profiili, äänimerkit, kommentit, laitteen tiedot ja asetukset. Tiedot toimitetaan JSON-muodossa.';

  @override
  String get dataExportedSuccessfully => 'Tiedot vietiin onnistuneesti';

  @override
  String get dataExportFailed => 'Tietoja ei voitu viedä';

  @override
  String get deleteAccount => 'Poista tili';

  @override
  String get deleteAccountDescription =>
      'Poista pysyvästi tilisi ja kaikki tiedot';

  @override
  String get deleteAccountWarning =>
      'Tätä toimintaa ei voida perua. Kaikki äänimerkit, kommentit ja tilitiedot poistetaan pysyvästi.';

  @override
  String get deleteMyAccount => 'Poista tili';

  @override
  String get deletingAccount => 'Poistan...';

  @override
  String get deleteAccountConfirmTitle => 'Poista tili';

  @override
  String get deleteAccountConfirmMessage =>
      'Haluatko varmasti poistaa tilisi? Tämä toiminta on pysyvää eikä sitä voida peruuttaa.';

  @override
  String get dataWillBeDeleted => 'Seuraavat tiedot poistetaan pysyvästi:';

  @override
  String get deletedDataList =>
      '• Profiilisi ja käyttäjätunnuksesi\n• Kaikki viestit ja raportit\n• Kaikki kommenttisi\n• Laiterekisteritiedot\n• Sijainti- ja etuuskohtelutiedot';

  @override
  String get deleteAccountPermanent => 'Poista pysyvästi';

  @override
  String get accountDeletedSuccessfully => 'Tili poistettu onnistuneesti';

  @override
  String get accountDeletionFailed => 'Tiliä ei voitu poistaa';

  @override
  String get onboardingWelcomeTitle => 'Tervetuloa UFO- piippiin';

  @override
  String get onboardingWelcomeBody =>
      'Hanki reaaliaikaisia hälytyksiä, kun ufot ovat lähellä. Älä koskaan jätä jälkiä väliin.';

  @override
  String get onboardingAlertsTitle => 'Pysy informoituna';

  @override
  String get onboardingAlertsBody =>
      'Aseta, miten kaukana havainnoiden pitäisi olla käynnistää hälytykset.';

  @override
  String get onboardingReportTitle => 'Näetkö jotain? Piip!';

  @override
  String get onboardingReportBody =>
      'Napsauta kuva tai video ja jakaa heti lähipiirin katsojille.';

  @override
  String get onboardingPermissionsTitle => 'Kamerasi & sijainti';

  @override
  String get onboardingPermissionsBody =>
      'Ota käyttöön kamera, sijainti ja ilmoitukset, jotta voit:\nIlmoita havainnoista nopeasti\n- Mitä? Kuulutetaan ufoista';

  @override
  String get onboardingCameraTitle => 'Todisteet';

  @override
  String get onboardingCameraBody =>
      'Jaa kuvia ja videoita juuri kaapattu galleria tai pitkä painaa UFOBeep kuvake aloittaa instant kamera tilassa.';

  @override
  String get onboardingCompassTitle => 'Katso, mistä he etsivät';

  @override
  String get onboardingCompassBody =>
      'Kompassi näyttää tarkan suunnan, jota todistaja katsoi nähdessään UFO:n. Osoita puhelimeen ja katso!';

  @override
  String get onboardingCommunityTitle => 'Liity Skywatchereihin';

  @override
  String get onboardingCommunityBody =>
      'Selaa havaintoja, käytä MUFON-raportteja ja ota yhteys toisiin pilvenpiirtäjiin.';

  @override
  String get skip => 'Ohita';

  @override
  String get getStarted => 'Aloita';

  @override
  String get viewOnboardingAgain => 'Näytä uudelleen aluksella';

  @override
  String get customAlertRange => 'Oma hälytysalue';

  @override
  String get enterRangeKm => 'Anna alue kilometrillä (1-99999)';

  @override
  String get largeRangeWarning =>
      'Suuret alueet (>100 km) voivat aiheuttaa useita hälytyksiä';

  @override
  String get globalRangeWarning =>
      'Erittäin suuret alueet (>1000km) lähettää sinulle hälytyksiä ympäri maailmaa';

  @override
  String get invalidRange => 'Anna numero välillä 1 ja 99999';

  @override
  String get celestialSunDaylight =>
      'Aurinko nousee - päivänvalo-olosuhteet voivat vaikuttaa näkemiseen';

  @override
  String get celestialSunTwilight =>
      'Hämärät olosuhteet - näkyvyyttä, mutta pimeämpi kuin päivänvalo';

  @override
  String get celestialSunDark =>
      'Tummat olosuhteet - optimaalinen objektien tarkkailuun taivaalla';

  @override
  String celestialMoonBright(Object phase) {
    return 'Kirkas __PAIKKAHOLDER_0__ kuu näkyvissä - voi valaisea tai hämärtää muita esineitä';
  }

  @override
  String celestialMoonModerate(Object phase) {
    return '__PAIKKAHOLDER_0__ kuu näkyvissä - kohtuulliset valaistusolosuhteet';
  }

  @override
  String celestialMoonThin(Object phase) {
    return 'Ohut __PAIKKAHOLDER_0__ kuu näkyvissä - minimaalinen valaistus';
  }

  @override
  String celestialMoonHidden(Object phase) {
    return '__Placeholder_0__ kuu horisontin alla - ei kuun valaistus';
  }

  @override
  String get celestialNoPlanets =>
      'Ei näkyviä kirkkaita planeettoja, joita voisi luulla UFOiksi';

  @override
  String celestialPlanetHigh(Object altitude, Object planet) {
    return '__PASSIHOLDER_0__ korkea yläpuolella (__PASSIHOLDER_1_°) - erittäin näkyvä';
  }

  @override
  String celestialPlanetMedium(Object altitude, Object planet) {
    return '__PASSIHOLDER_0__ näkyvissä __PASSIHOLDER_1_° - voidaan sekoittaa ilma-aluksiin';
  }

  @override
  String celestialPlanetLow(Object altitude, Object planet) {
    return '__PASSIHOLDER_0__ alhainen horisontissa (__PASSIHOLDER_1_°)';
  }

  @override
  String get celestialNoStars => 'Ei epätavallisen kirkkaita tähtiä näkyvissä';

  @override
  String celestialStarSingle(Object altitude, Object star) {
    return '__PASSIHOLDER_0__ näkyvä __PASSIHOLDER_1__° korkeus';
  }

  @override
  String celestialStarsMultiple(Object count, Object names) {
    return '__PAIKKAHOLDER_0__ kirkkaat tähdet näkyvissä - _PlaceHOLDER_1_';
  }

  @override
  String get celestialSummaryDaylight => 'Päivänvalo-olosuhteet';

  @override
  String get celestialSummaryDark => 'Pimeän taivaan olosuhteet';

  @override
  String get celestialSummaryMoonUp => 'kuun valaistus läsnä';

  @override
  String get celestialSummaryMoonDown => 'ei kuun valaistusta';

  @override
  String celestialSummaryManyObjects(Object count) {
    return '__Placeholder_0__ kirkkaat objektit, jotka voidaan sekoittaa UFOihin';
  }

  @override
  String celestialSummarySomeObjects(Object count) {
    return '__Placeholder_0__ kirkas objekti [s] näkyvissä';
  }

  @override
  String get celestialSummaryFewObjects =>
      'minimaalinen kirkas esineitä taivaalla';

  @override
  String celestialSkySummary(Object conditions) {
    return 'Lento-olosuhteet: __PAIKKAHOLDER_0___';
  }

  @override
  String get planetVenus => 'Venus';

  @override
  String get planetJupiter => 'Jupiter';

  @override
  String get planetSaturn => 'Saturnus';

  @override
  String get planetMars => 'Mars';

  @override
  String get planetMercury => 'Elohopea';

  @override
  String get planetUranus => 'Uranus';

  @override
  String get planetNeptune => 'Neptune';

  @override
  String get starSirius => 'Sirius';

  @override
  String get starCanopus =>
      'CanopusCity name (optional, probably does not need a translation)';

  @override
  String get starArcturus => 'Arcturus';

  @override
  String get starVega => 'Vega';

  @override
  String get starCapella => 'Kapella';

  @override
  String get starRigel => 'Rigel';

  @override
  String get starProcyon => 'Procyon';

  @override
  String get starBetelgeuse => 'Betelgeuse';

  @override
  String get moonPhaseNew => 'Uusikuu';

  @override
  String get moonPhaseWaxingCrescent => 'Vahaava puolikuu';

  @override
  String get moonPhaseFirstQuarter => 'Ensimmäinen vuosineljännes';

  @override
  String get moonPhaseWaxingGibbous => 'Waxing Gibbous';

  @override
  String get moonPhaseFull => 'Täysikuu';

  @override
  String get moonPhaseWaningGibbous => 'Waning Gibbous';

  @override
  String get moonPhaseThirdQuarter => 'Kolmas neljännes';

  @override
  String get moonPhaseWaningCrescent => 'Waning Crescent';

  @override
  String planetBelowHorizon(Object planet) {
    return '__PAIKKAHOLDER_0__ horisontin alapuolella';
  }

  @override
  String planetHighOverheadProminent(Object altitude, Object planet) {
    return '__PASSIHOLDER_0__ korkea yläpuolella (__PASSIHOLDER_1_°) - erittäin näkyvä';
  }

  @override
  String planetMidSkyProminent(Object altitude, Object planet) {
    return '__PASSIHOLDER_0__ at __PASSIHOLDER_1_° - näkyvä';
  }

  @override
  String planetMidSky(Object altitude, Object planet) {
    return '__PASSIHOLDER_0__ at _PlaceHOLDER_1_°';
  }

  @override
  String starVeryBright(Object altitude, Object star) {
    return '__PASSIHOLDER_0__ erittäin kirkas __PASSIHOLDER_1_°';
  }

  @override
  String starProminent(Object altitude, Object star) {
    return '__PASSIHOLDER_0__ näkyvä __PASSIHOLDER_1__° korkeus';
  }

  @override
  String starVisible(Object altitude, Object star) {
    return '__PASSIHOLDER_0__ at _PlaceHOLDER_1_°';
  }

  @override
  String get altitudeShort => 'Alt';

  @override
  String get magnitudeShort => 'Mag';

  @override
  String satellitesVisibleMightExplain(Object count) {
    return '_Placeholder_0_ satelliitit näkyvät - saattaa selittää havaintoja';
  }

  @override
  String satellitesVisibleUnlikelyExplain(Object count) {
    return '_Placeholder_0__ satelliitit näkyvissä - tuskin selittää havaintoja';
  }

  @override
  String get noSatellitesVisible => 'Ei satelliitteja näkyvissä';

  @override
  String aircraftDetectedInRadius(Object count, Object radius) {
    return '__PASSIHOLDER_0___-ilma-alus havaittu __PASSIHOLDER_1_km';
  }

  @override
  String get processingAlert => 'Käsittely UFO-hälytys...';

  @override
  String get analyzingEnvironment => 'Ympäristöolosuhteiden analysointi';

  @override
  String get weatherAnalysis => 'Sääanalyysi';

  @override
  String get locationAnalysis => 'Sijainti-analyysi';

  @override
  String get aircraftTracking => 'Ilma-alusten seuranta';

  @override
  String get satelliteAnalysis => 'Satelliittianalyysi';

  @override
  String get celestialAnalysis => 'Taivaallinen analyysi';

  @override
  String analyzing(Object processor) {
    return 'Analysoidaan __PASSIHOLDER_0__...';
  }

  @override
  String get processorWeather => 'sääolosuhteet';

  @override
  String get processorLocation => 'sijaintitiedot';

  @override
  String get processorAircraft => 'lähilentokoneet';

  @override
  String get processorSatellites => 'satelliittipaikat';

  @override
  String get processorCelestial => 'taivaankappaleet';

  @override
  String get calculatingCelestialData => 'Lasketaan taivaallisia tietoja...';

  @override
  String get sunLabel => 'Su';

  @override
  String get moonLabel => 'Kuu';

  @override
  String planetsVisible(int count) {
    return 'Planeetat: __PAIKKAHOLDER_0_ näkyvissä';
  }

  @override
  String get starsLabel => 'Tähdet';

  @override
  String get planetsLabel => 'Planeetat';

  @override
  String moonWithPhase(String phase) {
    return 'Kuu (___PASSIHOLDER_0__)';
  }

  @override
  String get noSatellitesVisibleAtTime =>
      'Satelliitteja ei näkynyt tarkkana havaintoajankohtana';

  @override
  String get satellitesVisibleOverheadAtTime =>
      'Satelliitit näkyvät yläpuolella havaintohetkellä ja paikan päällä';

  @override
  String get belowHorizon => 'horisontin alapuolella';

  @override
  String get analysisFailedGeneric => 'Analyysi epäonnistui';

  @override
  String get unknownWeather => 'Tuntematon';

  @override
  String get noWeatherDescription => 'Ei kuvausta';

  @override
  String get altitudeAbbrev => 'Alt';

  @override
  String get azimuthAbbrev => 'Az';

  @override
  String satellitesVisibleNow(int count) {
    return 'Satelliitit (__Placeholder_0_ näkyvät nyt)';
  }

  @override
  String sunWithDescription(String description) {
    return 'Aurinko: __PAIKKAHOLDER_0___';
  }

  @override
  String moonWithDescription(String description) {
    return 'Kuu: __PAIKKAHOLDER_0__';
  }

  @override
  String get unknownPlanet => 'Tuntematon planeetta';

  @override
  String get unknownStar => 'Tuntematon tähti';

  @override
  String get unknownSatellite => 'Tuntematon satelliitti';

  @override
  String get unknownDirection => 'tuntematon suunta';

  @override
  String get brightStars => 'Kirkkaat tähdet';

  @override
  String get satellites => 'Satelliitit';

  @override
  String seeAllSatellites(int count) {
    return 'Katso kaikki __PAIKKAHOLDER_0_ satelliitit';
  }

  @override
  String maxElevation(String degrees) {
    return 'Suurin korkeus merenpinnasta: _Placeholder_0__°';
  }

  @override
  String magnitude(String value) {
    return 'Merkitys: __PAIKKAHOLDER_0___';
  }

  @override
  String get unknownGeneric => 'Tuntematon';

  @override
  String altitudeValue(String degrees) {
    return '_Placeholder_0__° korkeus';
  }

  @override
  String azimuthValue(String degrees) {
    return '__Placeholder_0_° azimuth';
  }

  @override
  String get noCelestialDataAvailable => 'Ei taivaallista tietoa.';

  @override
  String get gettingLocation => 'Sain sijaintisi...';

  @override
  String get media => 'Media';

  @override
  String get locationRequired => 'Sijainti vaaditaan';

  @override
  String get confirmingWitness => 'Vahvistan todistajan...';

  @override
  String get chooseYourUsername => 'Valitse käyttäjätunnus';

  @override
  String get moreNames => 'Lisää nimiä';

  @override
  String get notificationSettings => 'Ilmoitusasetukset';

  @override
  String get quickActions => 'Nopeat toimet';

  @override
  String get doNotDisturb => 'Älä häiritse';

  @override
  String get temporarilySilenceNotifications =>
      'Väliaikaisesti vaienna kaikki ilmoitukset';

  @override
  String get oneHour => '1h';

  @override
  String get eightHours => '8h';

  @override
  String get oneDay => '1 vrk';

  @override
  String get startTime => 'Aloitusaika';

  @override
  String get endTime => 'Loppuaika';

  @override
  String get allowCriticalAlertsDuringQuietHours =>
      'Salli kriittiset kuulutukset hiljaisina tunteina';

  @override
  String get silenceNotificationsDuringSleepHours =>
      'Hiljaisuusilmoitukset nukkumistuntien aikana';

  @override
  String quietHoursActiveTimeRange(String startTime, String endTime) {
    return 'Aktiivinen __PASSIHOLDER_0__ - __PASSIHOLDER_1__';
  }

  @override
  String get followingAlerts => 'Kuulutusten jälkeen';

  @override
  String activeCount(int count) {
    return '_Placeholder_0__ aktiivinen';
  }

  @override
  String get unfollow => 'Ei seuraa';

  @override
  String get unfollowAlert => 'Noudata varoitusta';

  @override
  String commentsCount(int count) {
    return '__Placeholder_0__ comments';
  }

  @override
  String get photo => 'Valokuva';

  @override
  String get video => 'Video';

  @override
  String get initializationComplete => 'Alustus valmis!';

  @override
  String get validatingEnvironment => 'Validoidaan ympäristö...';

  @override
  String get requestingPermissions => 'Pyydän oikeuksia...';

  @override
  String get loadingAuthSession => 'Ladataan auth-istuntoa...';

  @override
  String get checkingUserRegistration => 'Tarkistan käyttäjärekisterin...';

  @override
  String get loadingPreferences => 'Ladataan asetuksia...';

  @override
  String get settingUpLocalization => 'Lokalisointi...';

  @override
  String get checkingConnectivity => 'Tarkistan yhteyksiä...';

  @override
  String get gatheringDeviceInfo => 'Keräyslaitteen tiedot...';

  @override
  String get translating => 'Translating...';

  @override
  String get showOriginal => 'Show Original';

  @override
  String translateTo(String language) {
    return 'Translate to $language';
  }

  @override
  String translatedFrom(String language) {
    return 'Translated from $language';
  }

  @override
  String translateContent(String language) {
    return 'Translate content to $language';
  }

  @override
  String get weatherClear => 'Tyhjennä';

  @override
  String get weatherClearSky => 'kirkas taivas';

  @override
  String get rain => 'Sade';

  @override
  String get snow => 'Lumi';

  @override
  String get thunderstorm => 'Ukkosmyrsky';

  @override
  String get drizzle => 'Tiima';

  @override
  String get fog => 'Sumu';

  @override
  String get fewClouds => 'muutama pilvi';

  @override
  String get scatteredClouds => 'hajallaan olevat pilvet';

  @override
  String get brokenClouds => 'rikkinäiset pilvet';

  @override
  String get overcastClouds => 'pilvet';

  @override
  String get lightRain => 'kevyt sade';

  @override
  String get moderateRain => 'kohtalainen sade';

  @override
  String get heavyRain => 'rankkasade';

  @override
  String aircraftDetectedCurrentPositions(int count, String radius) {
    return '__PASSIHOLDER_0__-ilma-alus havaittu __PASSIHOLDER_1_km (nykyiset paikat)';
  }

  @override
  String dimSatellitesUnlikely(int count) {
    return '__PlaceHolder_0__himmennyssatelliitit näkyvissä - ei todennäköisesti selitä havaintoja';
  }

  @override
  String get mufonReportingDate => 'MUFON Raportointipäivä';

  @override
  String satelliteNameDirection(String name, String direction) {
    return '$name - __PLACEHOLDER_1_';
  }
}
