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
    return 'Ilmoittanut __PAIKKAHOLDER_0__';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Raportoitu __PAIKKAHOLDER_0___';
  }

  @override
  String distanceAway(String distance) {
    return 'pois';
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
  String get beepOnly => 'Vain piip';

  @override
  String get reportOnly => 'Raportoi vain';

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
    return '_Placeholder_0__d sitten';
  }

  @override
  String timeHoursAgo(int count) {
    return '_Placeholder_0_h sitten';
  }

  @override
  String timeMinutesAgo(int count) {
    return '_Placeholder_0_ m sitten';
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
  String get timeFormat => 'Time Format';

  @override
  String get timeFormat24Hour => '24-hour (14:30)';

  @override
  String get timeFormat12Hour => '12-hour (2:30 PM)';

  @override
  String get timeFormatDesc => 'Display time in 24-hour or 12-hour format';

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
  String get unknown => 'tuntematon';

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
  String get previousPage => 'Edellinen';

  @override
  String get nextPage => 'Seuraava';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Sivu __PASSIHOLDER_0__ of _PASSIHOLDER_1__ (__PASSIHOLDER_2_ total piips)';
  }

  @override
  String get heroTagline =>
      'Hanki hälytykset, milloin mennä ulos ja katsoa ylös';

  @override
  String get heroDescription =>
      'Älä koskaan jätä UFO-havaintoa väliin. Hanki reaaliaikainen hälytys, kun joku lähelläsi näkee jotain outoa taivaalla. Osoita puhelimeen ja etsi tarkalleen mistä etsiä.';

  @override
  String get downloadApp => 'Lataa sovellus';

  @override
  String get viewAllBeeps => 'Näytä kaikki äänimerkit';

  @override
  String get sightingsMap => 'Näyttökartta';

  @override
  String get globalSightingNetwork => 'Global Sighting Network';

  @override
  String get howItWorks => 'Miten UFO- piip toimii';

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
  String get addedToUfobeep => 'Added to UFOBeep';

  @override
  String get mufonDatabaseReport => 'MUFON Tietokantaraportti';

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
}
