// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appName => 'ΑΤΙΑ μπιπ';

  @override
  String get ok => 'ΕΝΤΆΞΕΙ';

  @override
  String get cancel => 'Ακύρωση';

  @override
  String get close => 'Κλείσιμο';

  @override
  String get save => 'Αποθήκευση';

  @override
  String get delete => 'Διαγραφή';

  @override
  String get edit => 'Επεξεργασία';

  @override
  String get retry => 'Επανάληψη';

  @override
  String get yes => 'Ναι';

  @override
  String get no => 'Όχι';

  @override
  String get back => 'Πίσω';

  @override
  String get next => 'Επόμενο';

  @override
  String get done => 'Έγινε';

  @override
  String get loading => 'Φόρτωση..';

  @override
  String get processing => 'Επεξεργασία..';

  @override
  String get errorGeneric => 'Κάτι πήγε στραβά.';

  @override
  String get networkError => 'Σφάλμα δικτύου. Έλεγξε τη σύνδεσή σου.';

  @override
  String get permissionsRequired => 'Απαιτούμενες άδειες';

  @override
  String get learnMore => 'Μάθετε περισσότερα';

  @override
  String get welcomeTitle => 'Καλώς ήρθατε στο UFOBeep';

  @override
  String get welcomeSubtitle =>
      'Σε πραγματικό χρόνο UFO ειδοποιήσεις κοντά σας';

  @override
  String get signIn => 'Υπογραφή';

  @override
  String get signOut => 'Υπογραφή';

  @override
  String get continueAsGuest => 'Συνέχεια ως επισκέπτης';

  @override
  String get enterUsername => 'Εισάγετε ένα όνομα χρήστη';

  @override
  String get username => 'Όνομα χρήστη';

  @override
  String get usernameUpdated => 'Ενημέρωση ονόματος χρήστη';

  @override
  String get profile => 'Προφίλ';

  @override
  String get settings => 'Settings';

  @override
  String get tabAlerts => 'Καταχωρίσεις';

  @override
  String get tabBeep => 'Μπιπ';

  @override
  String get tabChat => 'Συζήτηση';

  @override
  String get tabMap => 'Χάρτης';

  @override
  String get tabSettings => 'Settings';

  @override
  String get alertsTitle => 'Κοντινές ειδοποιήσεις';

  @override
  String get noAlerts => 'Δεν υπάρχουν ειδοποιήσεις ακόμα κοντά.';

  @override
  String get pullToRefresh => 'Τραβήξτε για ανανέωση';

  @override
  String alertDistance(String distance) {
    return '__PH_0_ μακριά';
  }

  @override
  String alertDirection(int bearing) {
    return 'Διόπτευση __PH_0_°';
  }

  @override
  String get viewAlert => 'Προβολή συναγερμού';

  @override
  String get viewOnMap => 'Προβολή στο χάρτη';

  @override
  String get iSeeItToo => 'Το βλέπω κι εγώ';

  @override
  String get confirmWitnessed => 'Επιβεβαιώστε ότι είδατε αυτό το θέαμα?';

  @override
  String get witnessConfirmed => 'Ευχαριστώ — η επιβεβαίωσή σας δημοσιεύτηκε.';

  @override
  String get createBeepTitle => 'Στείλτε ένα μπιπ';

  @override
  String get beepExplain =>
      'Συλλάβετε ό, τι βλέπετε και ειδοποιήστε τους κοντινούς παρατηρητές.';

  @override
  String get capturePhoto => 'Φωτογραφία σύλληψης';

  @override
  String get captureVideo => 'Λήψη βίντεο';

  @override
  String get pickFromGallery => 'Επιλέξτε από τη συλλογή';

  @override
  String get descriptionHint => 'Περιγράψτε τι βλέπετε στον ουρανό..';

  @override
  String get submitBeep => 'Αποστολή μπιπ';

  @override
  String get beepSent => 'Αποστολή μπιπ';

  @override
  String get uploadingMedia => 'Αποστολή μέσων ενημέρωσης..';

  @override
  String get includeLocation => 'Συμπερίληψη τοποθεσίας';

  @override
  String get includeTimestamp => 'Συμπερίληψη χρονοσφραγίδας';

  @override
  String get beepFailed => 'Αποτυχία αποστολής του Μπιπ.';

  @override
  String get mediaProcessing => 'Επεξεργασία μέσων..';

  @override
  String get cameraPermissionTitle => 'Απαιτείται πρόσβαση κάμερας';

  @override
  String get cameraPermissionBody =>
      'Επιχορήγηση πρόσβασης κάμερας για να συλλάβει UFO φωτογραφίες και βίντεο.';

  @override
  String get locationPermissionTitle => 'Απαιτείται πρόσβαση τοποθεσίας';

  @override
  String get locationPermissionBody =>
      'Χρησιμοποιούμε την τοποθεσία σας για να στείλουμε και να λάβουμε κοντινές ειδοποιήσεις.';

  @override
  String get microphonePermissionTitle => 'Απαιτούμενη πρόσβαση μικροφώνου';

  @override
  String get microphonePermissionBody =>
      'Επιχορήγηση πρόσβασης μικροφώνου για λήψη βίντεο με ήχο.';

  @override
  String get openSettings => 'Άνοιγμα ρυθμίσεων';

  @override
  String get alertDetailTitle => 'Ορατότητα λεπτομερειών';

  @override
  String reportedBy(String username) {
    return 'Αναφέρθηκε από __PH_0_';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Αναφέρθηκε __PH_0_';
  }

  @override
  String distanceAway(String distance) {
    return '__PH_0_ μακριά';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Διόπτευση προς ένσταση: __PH_0_°';
  }

  @override
  String get openCompass => 'Ανοικτή πυξίδα';

  @override
  String get openAR => 'Άνοιγμα επικάλυψης AR';

  @override
  String get openChat => 'Άνοιγμα συνομιλίας';

  @override
  String get commentsTitle => 'Σχόλια';

  @override
  String get addComment => 'Προσθέστε ένα σχόλιο..';

  @override
  String get send => 'Αποστολή';

  @override
  String get commentPosted => 'Σχόλιο δημοσιεύτηκε';

  @override
  String get autoFollowEnabled => 'Τώρα ακολουθείτε αυτή την προειδοποίηση.';

  @override
  String get noCommentsYet => 'Κανένα σχόλιο ακόμα. Γίνε ο πρώτος!';

  @override
  String get newCommentNotification =>
      'Νέο σχόλιο για μια παρατήρηση που ακολουθείτε.';

  @override
  String get mapTitle => 'Ζωντανός χάρτης';

  @override
  String get compassTitle => 'Πυξίδα';

  @override
  String get compassSettings => 'Settings πυξίδας';

  @override
  String get compassMode => 'Λειτουργία πυξίδας';

  @override
  String get compassStandardMode => 'Τυπική λειτουργία';

  @override
  String get compassPilotMode => 'Πιλοτική λειτουργία';

  @override
  String get compassStandardDescription => 'Βασική κλάση και πλοήγηση';

  @override
  String get compassPilotDescription =>
      'Προηγμένη πλοήγηση με ETA και διανυσματική';

  @override
  String pointingTo(String direction) {
    return 'Επισημαίνοντας στο $direction';
  }

  @override
  String get calibratingCompass => 'Βαθμονόμηση πυξίδας..';

  @override
  String get openAROverlay => 'Άνοιγμα επικάλυψης AR';

  @override
  String get pushTitleAlertNearby => 'Συναγερμός UFO κοντά σας';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Μια νέα παρατήρηση αναφέρθηκε __PH_0_ μακριά.';
  }

  @override
  String get pushTitleComment => 'Νέο σχόλιο';

  @override
  String get pushBodyComment => 'Κάποιος σχολίασε ότι σε είδε να ακολουθείς.';

  @override
  String get pushTitleWitness => 'Επιβεβαίωση μάρτυρα';

  @override
  String get pushBodyWitness =>
      'Ένας χρήστης επιβεβαίωσε ότι βλέπουν το ίδιο αντικείμενο.';

  @override
  String get weather => 'Καιρός';

  @override
  String cloudCover(int percent) {
    return 'Σύννεφο: __PH_0_%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Άνεμος: ${speed}_PH_1_';
  }

  @override
  String get nearbyAircraft => 'Κοντινά αεροσκάφη';

  @override
  String get noAircraft => 'Κανένα αεροσκάφος κοντά';

  @override
  String get loadingContext => 'Φόρτωση περιβαλλοντικού πλαισίου..';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get notifications => 'Κοινοποιήσεις';

  @override
  String get enablePushNotifications =>
      'Λήψη κοινοποιήσεων για μελλοντικά σχόλια';

  @override
  String get quietHours => 'Ώρες ησυχίας';

  @override
  String get quietHoursDesc => 'Συναγερμός σιωπής μεταξύ επιλεγμένων ωρών.';

  @override
  String get dndMode => 'Μην ενοχλείστε';

  @override
  String get dndUntil => 'Μην ενοχλείστε μέχρι';

  @override
  String get language => 'Γλώσσα';

  @override
  String get chooseLanguage => 'Επιλογή γλώσσας';

  @override
  String get units => 'Μονάδες';

  @override
  String get unitsImperial => 'Αυτοκρατορικό (mi, mph)';

  @override
  String get unitsMetric => 'Μετρικό (km, km/h)';

  @override
  String get privacyPolicy => 'Πολιτική απορρήτου';

  @override
  String get termsOfUse => 'Όροι χρήσης';

  @override
  String get errorNoLocation =>
      'Τοποθεσία μη διαθέσιμη. Δοκιμάστε ξανά έξω με καθαρή θέα στον ουρανό.';

  @override
  String get errorNoCamera =>
      'Η κάμερα δεν είναι διαθέσιμη σε αυτή τη συσκευή.';

  @override
  String get errorUploadFailed =>
      'Η αποστολή απέτυχε. Παρακαλώ προσπαθήστε ξανά.';

  @override
  String get errorPermissionDenied => 'Η άδεια απορρίπτεται.';

  @override
  String get errorInvalidUsername =>
      'Αυτό το όνομα χρήστη δεν είναι διαθέσιμο.';

  @override
  String get nothingToShow => 'Δεν έχω κάτι να δείξω ακόμα.';

  @override
  String get storeShortDesc =>
      'Άμεση συναγερμούς UFO κοντά σας. Συλλάβετε, επιβεβαιώστε και συνομιλήστε σε πραγματικό χρόνο.';

  @override
  String get storeLongDesc =>
      'Το UFOBeep στέλνει ειδοποιήσεις σε πραγματικό χρόνο όταν κάποιος εντοπίζει ένα UFO κοντά. Συλλάβετε φωτογραφίες και βίντεο, επιβεβαιώστε τις εμφανίσεις με μια βρύση, την κατεύθυνση προβολής και την απόσταση, και συνομιλήστε με άλλους παρατηρητές του ουρανού.';

  @override
  String get keywords =>
      'UFO, UAP, OVNI, aliens, παρατηρήσεις, Skywatch, alerts, Radar, compass';

  @override
  String get noAlertsFound => 'Καμία αντίστοιχη καταχώριση';

  @override
  String get alertsFilterHelp =>
      'Δοκιμάστε να ρυθμίσετε τα φίλτρα σας για να δείτε περισσότερα αποτελέσματα';

  @override
  String get verified => 'Επαληθευμένο';

  @override
  String get beepOnly => 'μόνο μπιπ';

  @override
  String get videoOnly => 'μόνο βίντεο';

  @override
  String get imageOnly => 'μόνο εικόνα';

  @override
  String get timeJustNow => 'Μόλις τώρα';

  @override
  String timeDaysAgo(int count) {
    return '_PH_0_D πριν';
  }

  @override
  String timeHoursAgo(int count) {
    return '__PH_0_h πριν';
  }

  @override
  String timeMinutesAgo(int count) {
    return '_PH_0_m πριν';
  }

  @override
  String get loadMoreAlerts => 'Φόρτωση περισσότερων ειδοποιήσεων';

  @override
  String get toggleMufonTooltip => 'Εναλλαγή προβολών MUFON';

  @override
  String get showMufonData => 'Εμφάνιση δεδομένων MUFON';

  @override
  String get hideMufonData => 'Απόκρυψη δεδομένων MUFON';

  @override
  String get showingUfoBeepOnly => 'Εμφάνιση μόνο αναφορών UFOBeep';

  @override
  String get showingAllReports =>
      'Εμφάνιση όλων των αναφορών συμπεριλαμβανομένης της βάσης δεδομένων MUFON';

  @override
  String get filteredSuffix => 'φιλτράρεται';

  @override
  String get detailsTitle => 'Λεπτομέρειες';

  @override
  String get mufonCase => 'ΜΟΥΦΟΝ Υπόθεση';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'ΜΟΥΦΟΝ Υπόθεση #__PH_0_ Λεπτομέρειες';
  }

  @override
  String get sightingDate => 'Ημερομηνία παρατήρησης';

  @override
  String get mufonDatabaseEntryDate =>
      'Ημερομηνία εισόδου στο MUFON Βάση δεδομένων';

  @override
  String get databaseEntry => 'Είσοδος βάσης δεδομένων';

  @override
  String get shareLink => 'Κοινοποίηση δεσμού';

  @override
  String get linkCopied => 'Δεσμός αντιγραφόμενο στο πρόχειρο';

  @override
  String get locationLabel => 'Τοποθεσία';

  @override
  String get distanceLabel => 'Απόσταση';

  @override
  String get timeLabel => 'Χρόνος';

  @override
  String get reportedByLabel => 'Αναφέρθηκε από';

  @override
  String get unknownLocation => 'Άγνωστη τοποθεσία';

  @override
  String get locationUnknown => 'Άγνωστη τοποθεσία';

  @override
  String get witnessesLabel => 'Μάρτυρες';

  @override
  String witnessesCountMessage(int count) {
    return '__PH_0_ οι άνθρωποι επιβεβαίωσαν αυτή την παρατήρηση';
  }

  @override
  String get photoAnalysisTitle => 'Ανάλυση φωτογραφιών';

  @override
  String mediaItemsProcessed(int count) {
    return 'Ανάλυση: __PH_0_ Επεξεργασία αρχείου(ων) πολυμέσων';
  }

  @override
  String get addMoreMedia => 'Προσθήκη περισσότερων';

  @override
  String get addMedia => 'Προσθήκη μέσου';

  @override
  String get retakePhoto => 'Επανάληψη φωτογραφίας';

  @override
  String get retakeVideo => 'Επανάληψη βίντεο';

  @override
  String get camera => 'Κάμερα';

  @override
  String get gallery => 'Γκαλερί';

  @override
  String get basicSettings => 'Βασικές ρυθμίσεις';

  @override
  String get appSettings => 'Settings εφαρμογών';

  @override
  String get alertRange => 'Εύρος ειδοποίησης';

  @override
  String get manageNotificationsDesc => 'Διαχείριση συνδρομών & ρυθμίσεων';

  @override
  String get permissionsTitle => 'Άδειες';

  @override
  String get permissionLocation => 'Τοποθεσία';

  @override
  String get permissionCamera => 'Κάμερα';

  @override
  String get permissionNotifications => 'Κοινοποιήσεις';

  @override
  String get permissionPhotos => 'Φωτογραφίες';

  @override
  String get permissionGranted => 'Χορηγείται';

  @override
  String get permissionNotGranted => 'Δεν έχει χορηγηθεί';

  @override
  String get permissionGrant => 'Επιχορήγηση';

  @override
  String get generateUsername => 'Δημιουργία νέου ονόματος χρήστη';

  @override
  String get adminTools => 'Εργαλεία διαχείρισης';

  @override
  String get openAdminPanel => 'Άνοιγμα πίνακα διαχειριστή';

  @override
  String get webAdminInterface => 'Διεπαφή διαχειριστή ιστού';

  @override
  String get adminBetaNotice =>
      'Η Βήτα χτίζει μόνο. Εργαλεία διαχείρισης για τη δοκιμή ειδοποιήσεων εγγύτητας, ειδοποιήσεις ώθησης και διαγνωστικά συστημάτων.';

  @override
  String get whatDoYouSee => 'Τι βλέπεις?';

  @override
  String get ufoSighting => 'ΑΤΙΑ Ορατότητα';

  @override
  String get envAnalysisTitle => 'Περιβαλλοντική ανάλυση';

  @override
  String get envAnalysisPending => 'Εν αναμονή ανάλυσης';

  @override
  String get envAnalysisPendingDesc =>
      'Τα περιβαλλοντικά δεδομένα θα είναι διαθέσιμα μόλις αρχίσει η επεξεργασία.';

  @override
  String get unknownAircraft => 'Άγνωστο αεροσκάφος';

  @override
  String get moreAircraft => 'περισσότερα αεροσκάφη';

  @override
  String get premiumImageryTitle => 'Premium δορυφόρος Εικόνα';

  @override
  String get premiumImagerySubtitle => 'Εμπορικές εικόνες υψηλής ανάλυσης';

  @override
  String get sightingTypeLabel => 'Τύπος';

  @override
  String get ufoTypeSphere => 'Σφαίρα';

  @override
  String get ufoTypeTriangle => 'Τρίγωνο';

  @override
  String get ufoTypeDisk => 'Δίσκος';

  @override
  String get ufoTypeLight => 'Φως';

  @override
  String get ufoTypeFireball => 'Πυρόμπαλα';

  @override
  String get ufoTypeCylinder => 'Κύλινδρος';

  @override
  String get ufoTypeCigar => 'Πούρα';

  @override
  String get ufoTypeRectangle => 'Ορθογώνιο';

  @override
  String get ufoTypeFormation => 'Σχηματισμός';

  @override
  String get ufoTypeUnknown => 'Άγνωστο';

  @override
  String get ufoTypeBoomerang => 'Μπούμερανγκ';

  @override
  String get ufoTypeDiamond => 'Διαμάντι';

  @override
  String get ufoTypeOval => 'Οβάλ';

  @override
  String get ufoTypeCone => 'Κώνος';

  @override
  String get ufoTypeCross => 'Σταυρός';

  @override
  String get ufoTypeDumbbell => 'Βλακείες';

  @override
  String get ufoTypeTeardrop => 'Δάκρυο';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Σφαίρα';

  @override
  String get ufoTypeSaturn => 'Κρόνος';

  @override
  String get ufoTypeStarLike => 'Αστρική';

  @override
  String get ufoTypeBlimp => 'Μπλίμπ';

  @override
  String get actionsTitle => 'Δράσεις';

  @override
  String get addPhotosAndVideos => 'Προσθήκη φωτογραφιών & βίντεο';

  @override
  String get howToReportToMufon => 'Πώς να αναφέρετε στο MUFON';

  @override
  String get reportToMufon => 'Αναφορά στο MUFON';

  @override
  String get whyReportToMufon => 'Γιατί αναφέρεσαι στο MUFON?';

  @override
  String get openMufonReport => 'Άνοιγμα MUFON Έκθεση';

  @override
  String get confirmedWitness => 'Επιβεβαίωσες αυτή την παρατήρηση';

  @override
  String witnessesHaveConfirmed(int count) {
    return '__PH_0_ οι άνθρωποι έχουν επιβεβαιώσει αυτή την παρατήρηση';
  }

  @override
  String get aircraftTrackingTitle => 'Παρακολούθηση αεροσκαφών';

  @override
  String get weatherConditionsTitle => 'Καιρικές συνθήκες';

  @override
  String get noSatellitePasses => 'Δε βρέθηκαν ορατά δορυφορικά περάσματα';

  @override
  String get contentAnalysisTitle => 'Ανάλυση περιεχομένου';

  @override
  String get contentSafe => 'Το περιεχόμενο είναι ασφαλές';

  @override
  String get contentFlagged =>
      'Περιεχόμενο που φέρει τη σήμανση για επανεξέταση';

  @override
  String get confidenceLabel => 'Εμπιστοσύνη';

  @override
  String get methodLabel => 'Μέθοδος';

  @override
  String get premiumImageryAccessOnly =>
      'Premium δορυφορική εικόνα είναι διαθέσιμη μόνο για:';

  @override
  String get premiumAccessCreators => 'Προειδοποίηση δημιουργών';

  @override
  String get premiumAccessWitnesses =>
      'Επιβεβαιωμένοι μάρτυρες εντός εμβέλειας ορατότητας';

  @override
  String get comingSoon => 'Έρχομαι Σύντομα';

  @override
  String get directionDistanceTitle => 'Direction & Distance';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Case #$caseNumber';
  }

  @override
  String get satellitePassesTitle => 'Satellite Passes';

  @override
  String get satellitePassExplanation =>
      'Visible satellite passes during the sighting timeframe. Many UFO reports are actually satellites or space debris.';

  @override
  String get followingAlert =>
      'Following alert - you\'ll get comment notifications';

  @override
  String get unfollowedAlert =>
      'Unfollowed alert - no more comment notifications';

  @override
  String get alertFollowError => 'Error updating follow status';

  @override
  String get notificationChannelAlerts => 'UFOBeep Alerts';

  @override
  String get notificationChannelAlertsDesc =>
      'Notifications for UFO beeps and proximity alerts';

  @override
  String get notificationSightingTitle => 'UFO Sighting';

  @override
  String get notificationSightingUrgent => '⚠️ URGENT UFO Sighting';

  @override
  String get notificationSightingEmergency => '🚨 EMERGENCY UFO Sighting';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '$witnessText near $locationName';
  }

  @override
  String notificationCommentTitle(String username) {
    return '💬 $username commented';
  }

  @override
  String get notificationWitnessText => 'New sighting';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '$count witnesses';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Dismiss';

  @override
  String notificationDistance(String distance) {
    return '$distance away';
  }
}
