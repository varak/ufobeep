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
    return '$distance μακριά';
  }

  @override
  String alertDirection(int bearing) {
    return 'Ρουλεμάν $bearing°';
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
  String beepSentWithUrl(String shortUrl) {
    return 'Το μπιπ στάλθηκε επιτυχώς';
  }

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
  String get locationPermissionTitle => 'Απαιτούμενη άδεια θέσης';

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
    return 'Αναφέρθηκε από $username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Αναφέρθηκε $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '$distance';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Με σκοπό την ένσταση: $bearing°';
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
  String get noCommentsYet =>
      'Κανένα σχόλιο ακόμα. Να είσαι ο πρώτος που θα σχολιάσει!';

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
    return 'Μια νέα παρατήρηση αναφέρθηκε $distance μακριά.';
  }

  @override
  String get pushTitleComment => 'Νέο σχόλιο';

  @override
  String get pushBodyComment => 'Κάποιος σχολίασε ότι σε είδε να ακολουθείς.';

  @override
  String get pushTitleWitness => 'Επιβεβαίωση μάρτυρα';

  @override
  String get temperature => 'Θερμοκρασία';

  @override
  String get pushBodyWitness =>
      'Ένας χρήστης επιβεβαίωσε ότι βλέπουν το ίδιο αντικείμενο.';

  @override
  String get weather => 'Καιρός';

  @override
  String cloudCover(int percent) {
    return 'Νεφοκάλυψη: $percent%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Άνεμος: $speed $unit';
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
  String get quietHours => 'Ήσυχες ώρες';

  @override
  String get quietHoursDesc => 'Συναγερμός σιωπής μεταξύ επιλεγμένων ωρών.';

  @override
  String get quietHoursEnabled => 'Ενεργοποίηση ωρών ησυχίας';

  @override
  String get quietHoursFrom => 'Από';

  @override
  String get quietHoursUntil => 'Μέχρι';

  @override
  String get quietHoursDefaultTime => 'Προκαθορισμένες ώρες ησυχίας';

  @override
  String get emergencyOverride => 'Αντικατάσταση έκτακτης ανάγκης';

  @override
  String get emergencyOverrideDesc =>
      'Επίτρεψε επείγουσες ειδοποιήσεις κατά τη διάρκεια ωρών ηρεμίας';

  @override
  String get dndMode => 'Μην ενοχλείστε';

  @override
  String get dndUntil => 'Μην ενοχλείστε μέχρι';

  @override
  String dndEnabled(Object time) {
    return 'DND ενεργοποιημένο μέχρι $time';
  }

  @override
  String get dndDisabled => 'Απενεργοποίηση DND';

  @override
  String quietHoursActive(String startTime, String endTime) {
    return 'Ενεργός $startTime - $endTime';
  }

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Ώρες ησυχίας: $start - $end';
  }

  @override
  String get pushNotificationUfoAlert => 'ΑΤΙΑ Συναγερμός';

  @override
  String get pushNotificationAnomalyAlert => 'Ανωμαλία';

  @override
  String get pushNotificationNearby => 'Κοντά';

  @override
  String get pushNotificationInYourArea =>
      'στην περιοχή σου. Πατήστε για να δείτε λεπτομέρειες.';

  @override
  String pushNotificationCommented(Object username) {
    return '$username σχολίασε';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '$username σχολίασε στο $beepTitle';
  }

  @override
  String get pushNotificationGeneric => 'ΑΤΙΑ μπιπ';

  @override
  String get pushNotificationNewSighting => 'Νέα θέαση κοντά';

  @override
  String get language => 'Γλώσσα';

  @override
  String get chooseLanguage => 'Επιλογή γλώσσας';

  @override
  String get units => 'Μονάδες';

  @override
  String get unitsImperial => 'Αυτοκρατορικό';

  @override
  String get unitsMetric => 'Μετρικό';

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
  String get beepOnly => 'Μόνο μπιπ';

  @override
  String get reportOnly => 'Μόνο κείμενο';

  @override
  String get videoOnly => 'Μόνο βίντεο';

  @override
  String get imageOnly => 'Μόνο εικόνα';

  @override
  String get mediaOnly => 'Μόνο μέσα ενημέρωσης';

  @override
  String get timeJustNow => 'μόλις τώρα';

  @override
  String timeDaysAgo(int count) {
    return '$count ημέρες πριν';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count ώρες πριν';
  }

  @override
  String timeMinutesAgo(int count) {
    return '$count λεπτά πριν';
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
  String get mufonSighting => 'Έκθεση παρατήρησης MUFON';

  @override
  String get mufonLightSighting => 'Έκθεση παρατήρησης φωτός MUFON';

  @override
  String get mufonSphereSighting => 'Έκθεση παρατήρησης σφαίρας MUFON';

  @override
  String get mufonDiscSighting => 'ΜΟΥΦΟΝ Έκθεση παρατήρησης δίσκων';

  @override
  String get mufonTriangleSighting => 'ΜΟΥΦΟΝ Έκθεση παρατήρησης τριγώνου';

  @override
  String get mufonCigarSighting => 'Έκθεση παρατήρησης πούρων MUFON';

  @override
  String get mufonOvalSighting => 'Έκθεση Οβάλ παρατήρησης MUFON';

  @override
  String get mufonRectangleSighting => 'ΜΟΥΦΟΝ Έκθεση παρατήρησης ορθογωνίου';

  @override
  String get mufonCylinderSighting => 'Έκθεση παρατήρησης κυλίνδρων MUFON';

  @override
  String get mufonBoomerangSighting => 'Έκθεση παρατήρησης MUFON Boomerang';

  @override
  String get mufonStarlikeSighting => 'ΜΟΥΦΟΝ Starlike Sighting Αναφορά';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'Υπόθεση MUFON #$caseNumber Λεπτομέρειες';
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
  String get locationLabel => 'Τοποθεσία:';

  @override
  String get distanceLabel => 'Απόσταση';

  @override
  String get timeLabel => 'Ώρα:';

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
    return '$count άτομα επιβεβαίωσαν αυτή την παρατήρηση';
  }

  @override
  String get photoAnalysisTitle => 'Ανάλυση φωτογραφιών';

  @override
  String mediaItemsProcessed(int count) {
    return 'Ανάλυση: $count επεξεργασμένα αρχεία πολυμέσων';
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
  String get timeFormat => 'Μορφή χρόνου';

  @override
  String get timeFormat24Hour => '24 ώρες';

  @override
  String get timeFormat12Hour => '12 ώρες';

  @override
  String get timeFormatDesc => 'Εμφάνιση ώρας σε 24ωρη ή 12ωρη μορφή';

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
  String get ufo => 'ΑΤΙΑ';

  @override
  String get sighting => 'Ορατότητα';

  @override
  String get ufoSighting => 'UFOBeep UFO Συναγερμός';

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
  String get showLess => 'Εμφάνιση λιγότερου';

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
  String get shapeTriangle => 'τρίγωνο';

  @override
  String get shapeDisc => 'δίσκος';

  @override
  String get shapeDisk => 'δίσκος';

  @override
  String get shapeSphere => 'σφαίρα';

  @override
  String get shapeCigar => 'πούρα';

  @override
  String get shapeLight => 'φως';

  @override
  String get shapeBoomerang => 'βουμεράνγκ';

  @override
  String get shapeDiamond => 'διαμάντι';

  @override
  String get shapeRectangle => 'ορθογώνιο';

  @override
  String get shapeOval => 'οβάλ';

  @override
  String get shapeCone => 'κώνος';

  @override
  String get shapeCross => 'σταυρός';

  @override
  String get shapeCylinder => 'κύλινδρος';

  @override
  String get shapeDumbbell => 'αλουμινόχαρτο';

  @override
  String get shapeTeardrop => 'δάκρυο';

  @override
  String get shapeTicTac => 'τικ-τακ';

  @override
  String get shapeBullet => 'σφαίρα';

  @override
  String get shapeSaturn => 'saturn';

  @override
  String get shapeStarlike => 'αστεροειδής';

  @override
  String get shapeBlimp => 'blimp';

  @override
  String get shapeFireball => 'πυρόμπαλα';

  @override
  String get shapeFormation => 'σχηματισμός';

  @override
  String get shapeUnknown => 'άγνωστο';

  @override
  String get actionsTitle => 'Δράσεις';

  @override
  String get addPhotosAndVideos => 'Προσθήκη φωτογραφιών & βίντεο';

  @override
  String get attachMedia => 'Προσάρτηση μέσου';

  @override
  String get addCommentOptional => 'Προσθέστε ένα σχόλιο (προαιρετικό)';

  @override
  String get describeNewMedia => 'Περιγράψτε τα νέα μέσα ενημέρωσης...';

  @override
  String get filesSelected => 'επιλεγμένα αρχεία';

  @override
  String get selectMediaToAttach =>
      'Παρακαλώ επιλέξτε φωτογραφίες ή βίντεο για επισύναψη';

  @override
  String get newMediaUploaded => 'Μεταφόρτωση νέων μέσων';

  @override
  String get mediaFilesUploaded => 'νέα αρχεία πολυμέσων που φορτώθηκαν';

  @override
  String get filesAttachedSuccessfully => 'τα αρχεία επισυνάπτονται επιτυχώς';

  @override
  String get howToReportToMufon => 'Πώς να αναφέρετε στο MUFON';

  @override
  String get reportToMufon => 'Αναφορά στο MUFON';

  @override
  String get whyReportToMufon => 'Γιατί αναφέρεσαι στο MUFON?';

  @override
  String get openMufonReport => 'Άνοιγμα MUFON Έκθεση';

  @override
  String get howToFormallyReport => 'Πώς να αναφέρετε επίσημα';

  @override
  String get formalReportingTitle => 'Επίσημη UFO Υποβολή εκθέσεων';

  @override
  String get ufobeepVsFormalReporting =>
      'UFOBeep εναντίον της επίσημης αναφοράς';

  @override
  String get versus => 'vs';

  @override
  String get formalReporting => 'Επίσημη έκθεση';

  @override
  String get reportingOrganizations => 'Οργανισμοί αναφοράς';

  @override
  String get ufobeepRealtimeExplanation =>
      'Το UFOBeep έχει σχεδιαστεί για ειδοποιήσεις σε πραγματικό χρόνο - βοηθώντας τους κοντινούς μάρτυρες να συνδεθούν άμεσα για να επιβεβαιώσουν τι βλέπουν αυτή τη στιγμή.';

  @override
  String get formalReportingExplanation =>
      'Για επίσημη έρευνα και επιστημονική τεκμηρίωση, μπορείτε να καταθέσετε επίσημες αναφορές σε καθιερωμένους ερευνητικούς οργανισμούς.';

  @override
  String get mufonFullName => 'MUFON (Αμοιβαίο δίκτυο UFO)';

  @override
  String get mufonDescription =>
      'Ο μεγαλύτερος οργανισμός έρευνας UFO στον κόσμο με επαγγελματίες ερευνητές πεδίου και επιστημονική τεκμηρίωση.';

  @override
  String get nuforcFullName => 'NUFORC (Εθνικό Κέντρο Αναφοράς ΑΤΙΑ)';

  @override
  String get nuforcDescription =>
      'Λειτουργεί από το 1974, NUFORC διατηρεί μια ολοκληρωμένη δημόσια βάση δεδομένων των UFO θεάσεις.';

  @override
  String get whatToExpect => 'Τι να Αναμένετε';

  @override
  String get formalReportRequirements =>
      'Οι επίσημες εκθέσεις συνήθως απαιτούν:\n• Λεπτομερής χρόνος, ημερομηνία και διάρκεια\n• Καιρικές συνθήκες και ορατότητα\n• Πλήρης μαρτυρία μαρτύρων\n• Φωτογραφίες ή βίντεο εάν είναι διαθέσιμα\n\nΟι οργανισμοί μπορούν να παρακολουθούν για πρόσθετες λεπτομέρειες. Η αναφορά σας συμβάλλει στη συνεχή έρευνα UFO.';

  @override
  String get confirmedWitness => 'Επιβεβαίωσες αυτή την παρατήρηση';

  @override
  String witnessesHaveConfirmed(int count) {
    return '$count άνθρωποι έχουν επιβεβαιώσει αυτή την παρατήρηση';
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
  String get directionDistanceTitle => '& Απόσταση κατεύθυνσης';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'ΜΟΥΦΟΝ Υπόθεση #$caseNumber';
  }

  @override
  String get satellitePassesTitle => 'Δορυφορικά περάσματα';

  @override
  String get satellitePassExplanation =>
      'Ορατός δορυφόρος περνάει κατά τη διάρκεια του χρονικού πλαισίου παρατήρησης. Πολλές αναφορές για UFO είναι στην πραγματικότητα δορυφόροι ή διαστημικά συντρίμμια.';

  @override
  String get followingAlert =>
      'Μετά την ειδοποίηση - θα λάβετε ειδοποιήσεις σχολίων';

  @override
  String get unfollowedAlert =>
      'Μη ακολουθούμενη ειδοποίηση - όχι άλλες ειδοποιήσεις σχολίων';

  @override
  String get alertFollowError => 'Σφάλμα ενημέρωσης της κατάστασης';

  @override
  String get notificationChannelAlerts => 'Συναγερμοί UFOBeep';

  @override
  String get notificationChannelAlertsDesc =>
      'Ειδοποιήσεις για UFO μπιπ και ειδοποιήσεις εγγύτητας';

  @override
  String get notificationSightingTitle => 'UFOBeep UFO Συναγερμός';

  @override
  String get notificationSightingUrgent => '⚠️ URGENT UFOBeep UFO Συναγερμός';

  @override
  String get notificationSightingEmergency =>
      '🚨 Έκτακτη UFOBeep UFO Συναγερμός';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '$witnessText near $locationName';
  }

  @override
  String notificationCommentTitle(String username) {
    return '💬 $username σχολίασε';
  }

  @override
  String get notificationWitnessText => 'Νέα παρατήρηση';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '$count μάρτυρες';
  }

  @override
  String get notificationActionSnooze => 'Σνούζ 1 ώρα';

  @override
  String get notificationActionDismiss => 'Ελεύθεροι';

  @override
  String notificationDistance(String distance) {
    return '$distance μακριά';
  }

  @override
  String get unknown => 'Άγνωστο';

  @override
  String get report => 'έκθεση';

  @override
  String get mufon => 'μουφόν';

  @override
  String get recentUfoBeepsTitle => 'Πρόσφατο UFO Μπιζέλια';

  @override
  String get recentUfoBeepsSubtitle =>
      'Ζωντανές αναφορές παρατήρησης UFO από την παγκόσμια κοινότητα μας';

  @override
  String get recentUfoBeepsDescription =>
      'Αυτή η τροφοδοσία συνδυάζει σε πραγματικό χρόνο UFOBeep-beeps\" από τους χρήστες εφαρμογών κινητής τηλεφωνίας μας με ιστορικές αναφορές από τη βάση δεδομένων MUFON.';

  @override
  String get loadingBeeps => 'Φόρτωση πρόσφατων μπιπ...';

  @override
  String get noBeepsAvailable => 'Δεν υπάρχουν διαθέσιμα μπιπ προς το παρόν.';

  @override
  String get anomalyReported => 'Ανωμαλία αναφερθεί';

  @override
  String get copyShortLink => 'Αντιγραφή σύντομου δεσμού';

  @override
  String get shareAlert => 'Κοινοποίηση ειδοποίησης';

  @override
  String get ufoSightingAlert => 'ΑΤΙΑ Εντοπισμός συναγερμού';

  @override
  String get previousPage => 'Προηγούμενο';

  @override
  String get nextPage => 'Επόμενο';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Σελίδα $currentPage από $totalPages ($totalCount συνολικά ηχητικά σήματα)';
  }

  @override
  String get firstPage => 'Πρώτο';

  @override
  String get lastPage => 'Τελευταία';

  @override
  String get jumpToPage => 'Μετάβαση στη σελίδα';

  @override
  String get heroTagline => 'Πάρε ειδοποιήσεις όταν βγεις έξω και κοίτα ψηλά';

  @override
  String get heroDescription =>
      'Ποτέ μην χάσετε άλλη παρατήρηση UFO στην περιοχή σας';

  @override
  String get downloadApp => '📱 Λήψη εφαρμογής';

  @override
  String get viewAllBeeps => '📋 Δείτε Όλους τους Μπιπς';

  @override
  String get sightingsMap => '🗺️ Χάρτης παρατήρησης';

  @override
  String get globalSightingNetwork => 'Παγκόσμιο δίκτυο παρατήρησης';

  @override
  String get howItWorks => 'Πώς Λειτουργεί';

  @override
  String get backToBeeps => 'Επιστροφή στους Μπιπς';

  @override
  String get loadingDetails => 'Φόρτωση λεπτομερειών ήχου...';

  @override
  String get details => 'Λεπτομέρειες';

  @override
  String get location => 'Τοποθεσία';

  @override
  String get timeAgo => 'πριν';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'μίλια';

  @override
  String get distanceNearby => 'κοντά';

  @override
  String get ufobeepWitnesses => 'Μάρτυρες';

  @override
  String get ufobeepConfirmations => 'Επιβεβαίωση';

  @override
  String get ufobeepAlertLevel => 'Επίπεδο συναγερμού';

  @override
  String get ufobeepReportType => 'Αναφορά UFOBeep';

  @override
  String get mufonAttribution => 'ΜΟΥΦΟΝ Έκθεση βάσης δεδομένων';

  @override
  String get mufonCaseNumber => 'Υπόθεση #';

  @override
  String get mufonGenericTitle => 'Έκθεση παρατήρησης MUFON';

  @override
  String get mufonSphere => 'Σφαίρα';

  @override
  String get mufonLight => 'Φως';

  @override
  String get mufonDisk => 'Δίσκος';

  @override
  String get mufonTriangle => 'Τρίγωνο';

  @override
  String get mufonCigar => 'Πούρα';

  @override
  String get mufonOval => 'Οβάλ';

  @override
  String get mufonCylinder => 'Κύλινδρος';

  @override
  String get mufonRectangle => 'Ορθογώνιο';

  @override
  String get mufonDiamond => 'Διαμάντι';

  @override
  String get mufonFireball => 'Πυρόμπαλα';

  @override
  String get mufonFlash => 'Φλας';

  @override
  String get mufonFormation => 'Σχηματισμός';

  @override
  String get mufonChanging => 'Αλλαγή';

  @override
  String get mufonChevron => 'Ακίδα';

  @override
  String get mufonCone => 'Κώνος';

  @override
  String get mufonCross => 'Σταυρός';

  @override
  String get mufonEgg => 'Αυγά';

  @override
  String get mufonOther => 'Αντικείμενο';

  @override
  String get mufonUnknown => 'Άγνωστο αντικείμενο';

  @override
  String mufonTitleFormat(Object classification) {
    return 'Έκθεση MUFON $classification';
  }

  @override
  String get nuforcAttribution => 'ΝΟΥΦΟΡΚ Έκθεση βάσης δεδομένων';

  @override
  String get nuforcCaseNumber => 'Υπόθεση #';

  @override
  String get nuforcGenericTitle => 'ΝΟΥΦΟΡΚ Έκθεση παρατήρησης';

  @override
  String get mediaImageNotFound => 'Η εικόνα δε βρέθηκε';

  @override
  String get mediaPlayVideo => 'Αναπαραγωγή βίντεο';

  @override
  String get mediaViewImage => 'Προβολή εικόνας';

  @override
  String mediaCount(Object count) {
    return '$count εικόνες';
  }

  @override
  String get mediaCountSingle => '1 εικόνα';

  @override
  String mediaMoreImages(Object count) {
    return '+$count more';
  }

  @override
  String get errorNotFound => 'Το σήμα δεν βρέθηκε';

  @override
  String get errorLoadError =>
      'Αποτυχία φόρτωσης λεπτομερειών ηχητικού σήματος';

  @override
  String get shareYourThoughts =>
      'Μοιραστείτε τις σκέψεις σας για αυτή την εμφάνιση...';

  @override
  String get postComment => 'Σχόλιο Post';

  @override
  String get loggedInAs => 'Σύνδεση ως';

  @override
  String get logout => 'Αποσύνδεση';

  @override
  String get notFollowing => 'Δεν ακολουθεί';

  @override
  String get follow => 'Συνέχεια';

  @override
  String get navRecentBeeps => 'Πρόσφατες Beeps';

  @override
  String get navMap => 'Χάρτης';

  @override
  String get navDownloadApp => 'Λήψη εφαρμογής';

  @override
  String get alertLevel => 'Επίπεδο συναγερμού';

  @override
  String get witnesses => 'Μάρτυρες';

  @override
  String get confirmations => 'Επιβεβαίωση';

  @override
  String get reporterLabel => 'Αναφέρθηκε από το χρήστη';

  @override
  String get coordinatesLabel => 'Συντεταγμένες';

  @override
  String get eventTime => 'Ώρα συμβάντος';

  @override
  String get reportedTime => 'Χρόνος αναφοράς';

  @override
  String get addedToUfobeep => 'Προστέθηκε στο UFOBeep';

  @override
  String get mufonDatabaseReport => 'ΜΟΥΦΟΝ Αριθμός υπόθεσης:';

  @override
  String get copyShortLinkTitle => 'Αντιγραφή δεσμού στο πρόχειρο';

  @override
  String get imageNotFound => 'Η εικόνα δε βρέθηκε';

  @override
  String get ufoSightingAlt => 'ΑΤΙΑ Συναγερμός ΑΤΙΑ μπιπ';

  @override
  String get celestialDataTitle => 'Ουράνια αντικείμενα';

  @override
  String get visiblePlanets => 'Ορατοί Πλανήτες';

  @override
  String get locationDataTitle => 'Πληροφορίες τοποθεσίας';

  @override
  String get timezone => 'Ζώνη ώρας';

  @override
  String get coordinates => 'Συντεταγμένες';

  @override
  String get processingSummaryTitle => 'Περίληψη επεξεργασίας';

  @override
  String get processingTime => 'Χρόνος επεξεργασίας';

  @override
  String get successful => 'Επιτυχής';

  @override
  String get failed => 'Αποτυχία';

  @override
  String get locationEnrichmentTitle => 'Λεπτομέρειες τοποθεσίας';

  @override
  String get aircraftDataSource => 'Πηγή δεδομένων';

  @override
  String get noAircraftDetected => 'Δεν εντοπίστηκαν αεροσκάφη';

  @override
  String get sightingReport => 'Έκθεση παρατήρησης';

  @override
  String get ufoAlert => 'ΑΤΙΑ Συναγερμός';

  @override
  String get alert => 'Συναγερμός';

  @override
  String get notificationTickerUfoAlert =>
      'Συναγερμός UFO - Νέα Αξιοθέατα σε κοντινή απόσταση';

  @override
  String get notificationTickerComment => 'Νέο σχόλιο για το UFO Alert';

  @override
  String get weatherConditions => 'Καιρικές συνθήκες';

  @override
  String get visibility => 'Ορατότητα';

  @override
  String get humidity => 'Υγρασία';

  @override
  String get pressure => 'Πίεση';

  @override
  String get locationDetails => 'Λεπτομέρειες τοποθεσίας';

  @override
  String get city => 'Πόλη';

  @override
  String get state => 'Κατάσταση';

  @override
  String get country => 'Χώρες';

  @override
  String get satelliteActivity => 'Δορυφορική δραστηριότητα';

  @override
  String get satellitesVisibleOverhead =>
      'Δορυφορικοί δορυφόροι ορατοί από πάνω κατά το χρόνο και την τοποθεσία παρατήρησης';

  @override
  String get dataSource => 'Πηγή δεδομένων';

  @override
  String get blackskyImagery => 'Εικόνα BlackSky';

  @override
  String get resolution => 'Ανάλυση';

  @override
  String get groundResolution => '35cm ανάλυση εδάφους';

  @override
  String get delivery => 'Παράδοση';

  @override
  String get averageDelivery => 'μέσος όρος 90 λεπτών';

  @override
  String get cost => 'Κόστος';

  @override
  String get skyfiSatelliteImagery => 'Δορυφόρος SkyFi Εικόνα';

  @override
  String get region => 'Περιφέρεια';

  @override
  String get remoteArea => 'Απομακρυσμένη περιοχή';

  @override
  String get startingPrice => 'Τιμή εκκίνησης';

  @override
  String get coverage => 'Κάλυψη';

  @override
  String get confidenceCoverage => '95% εμπιστοσύνη';

  @override
  String get status => 'Κατάσταση';

  @override
  String get shareThoughts =>
      'Μοιραστείτε τις σκέψεις σας για αυτή την εμφάνιση...';

  @override
  String get postCommand => 'Αποστολή';

  @override
  String get clouds => 'Σύννεφα';

  @override
  String get windLabel => 'Άνεμος';

  @override
  String get filterAlerts => 'Συναγερμοί φίλτρου';

  @override
  String get alertSource => 'Ειδοποίηση πηγής';

  @override
  String get ufobeepOnly => 'Μόνο UFOBeep';

  @override
  String get ufobeepOnlyDescription =>
      'Εμφάνιση μόνο πρωτότυπων αναφορών UFOBeep (αποκλείστε τη βάση δεδομένων MUFON)';

  @override
  String get alertDistanceRange => 'Ειδοποίηση εύρους απόστασης';

  @override
  String get showAllAlerts => 'Εμφάνιση όλων των ειδοποιήσεων';

  @override
  String get showAll => 'Εμφάνιση όλων';

  @override
  String get distanceSliderDescription =>
      'Σύρετε για να ρυθμίσετε πόσο μακριά θέλετε να δείτε ειδοποιήσεις. Ξεκινήστε από την απόσταση ορατότητας του καιρού μέχρι την εμφάνιση όλων των ειδοποιήσεων ανεξάρτητα από την απόσταση.';

  @override
  String get applyFilters => 'Εφαρμογή φίλτρων';

  @override
  String get notificationRange => 'Εύρος κοινοποίησης';

  @override
  String get notificationRangeDescription =>
      'Πάρτε ειδοποιήσεις ώθησης για θεάσεις σε αυτή την απόσταση';

  @override
  String get viewingRange => 'Προβολή εύρους';

  @override
  String get viewingRangeDescription =>
      'Εμφάνιση προβολών σε αυτή την απόσταση κατά την περιήγηση';

  @override
  String get weatherVisibility => 'Ορατότητα καιρού (~10 χιλιόμετρα)';

  @override
  String get localArea => 'Τοπική περιοχή (25 χιλιόμετρα)';

  @override
  String get regional => 'Περιφερειακή';

  @override
  String get pushNotifications => 'Πιέστε τις ειδοποιήσεις';

  @override
  String get alertBrowsing => 'Προειδοποίηση περιήγησης';

  @override
  String get pushAlertsWithinDistance =>
      'Λήψη ειδοποιήσεων εντός αυτού του εύρους';

  @override
  String get showAlertsWhenBrowsing => 'Φιλτράρισμα όσων βλέπετε στη λίστα';

  @override
  String get heroMainTagline =>
      'Πάρτε ένα μπιπ στο τηλέφωνό σας όταν UFOs εντοπίζονται κοντά';

  @override
  String get heroSecondaryTagline =>
      'Μάθε πότε και πού να κοιτάξεις τον ουρανό';

  @override
  String get sourceFilters => 'Πηγή';

  @override
  String get sourceFiltersDescription =>
      'Επιλέξτε ποιες αναφορές εμφανίζονται στη ροή σας';

  @override
  String get ufobeepAndMufon => 'UFOBeep + MUFON';

  @override
  String get ufobeepOnlySource => 'Μόνο UFOBeep';

  @override
  String get mufonOnlySource => 'Μόνο MUFON';

  @override
  String get browseFilters => 'Περιήγηση';

  @override
  String get browseFiltersDescription =>
      'Πώς να δείτε και να ταξινομήσετε τις ειδοποιήσεις';

  @override
  String get sortByNewest => 'Νεότερο';

  @override
  String get sortByNearest => 'Πλησιέστερο';

  @override
  String get sortBy => 'Ταξινόμηση κατά';

  @override
  String get pushAlertsTitle => 'Συναγερμοί ώθησης';

  @override
  String get pushAlertsDescription => 'Τι pings το τηλέφωνό σας';

  @override
  String get alertRadius => 'Ακτίνα ειδοποίησης';

  @override
  String get mufonNoPushInfo =>
      'Οι αναφορές MUFON εισάγονται τη νύχτα και δεν ενεργοποιούν ειδοποιήσεις ώθησης';

  @override
  String get privacyData => 'Ιδιωτικότητα & Δεδομένα';

  @override
  String get privacyPolicyDesc =>
      'Πώς προστατεύουμε και χρησιμοποιούμε τα δεδομένα σας';

  @override
  String get termsOfService => 'Όροι υπηρεσίας';

  @override
  String get termsOfServiceDesc => 'Νομικοί όροι και προϋποθέσεις';

  @override
  String get locationTracking => 'Παρακολούθηση τοποθεσίας';

  @override
  String get locationTrackingDesc =>
      'Θέση φόντου για τις καταχωρίσεις εγγύτητας';

  @override
  String get locationTrackingTitle => 'Παρακολούθηση τοποθεσίας φόντου';

  @override
  String get locationTrackingExplanation =>
      'UFOBeep παρακολουθεί τη θέση σας στο παρασκήνιο για να σας στείλει ειδοποιήσεις εγγύτητας όταν UFO εμφανίσεις συμβαίνουν κοντά στην τρέχουσα τοποθεσία σας, ακόμη και όταν είστε μακριά από το σπίτι.';

  @override
  String get locationTrackingBattery =>
      'Χρησιμοποιεί ευφυή γεωφαινόμενη για την πρόσκρουση μπαταρίας <3%';

  @override
  String get backgroundLocationTracking => 'Ενεργοποίηση φόντου Παρακολούθηση';

  @override
  String get locationTrackingActive =>
      'Θέση παρακολούθησης για καταχωρίσεις εγγύτητας';

  @override
  String get locationTrackingInactive =>
      'Η παρακολούθηση τοποθεσίας είναι απενεργοποιημένη';

  @override
  String get locationTrackingDisabledWarning =>
      'Δεν θα λάβετε ειδοποιήσεις εγγύτητας όταν μετακομίσετε σε νέες τοποθεσίες';

  @override
  String get trackingStatus => 'Κατάσταση παρακολούθησης';

  @override
  String get monitoringStatus => 'Παρακολούθηση';

  @override
  String get active => 'Ενεργό';

  @override
  String get inactive => 'Ανενεργός';

  @override
  String get lastKnownLocation => 'Τελευταία γνωστή τοποθεσία';

  @override
  String get lastLocationUpdate => 'Τελευταία ενημέρωση';

  @override
  String get movementThreshold => 'Κατώφλι κίνησης';

  @override
  String get updateFrequency => 'Συχνότητα ενημέρωσης';

  @override
  String get batteryImpact => 'Επιπτώσεις μπαταριών';

  @override
  String get dataPrivacy => 'Προστασία δεδομένων';

  @override
  String get locationPermissionExplanation =>
      'Το UFOBeep χρειάζεται άδεια τοποθεσίας \'Πάντα επιτρέπεται\' για να παρακολουθεί την κίνησή σας και να στέλνει ειδοποιήσεις εγγύτητας όταν βρίσκεστε σε νέες τοποθεσίες.';

  @override
  String get benefitsTitle => 'Οφέλη';

  @override
  String get locationTrackingBenefits =>
      '• Πάρτε UFO ειδοποιήσεις όπου κι αν ταξιδεύετε\n• Αυτόματη ενημέρωση τοποθεσίας\n• Δεν απαιτείται χειροκίνητη ρύθμιση';

  @override
  String get allowLocationAccess => 'Επίτρεψε πρόσβαση τοποθεσίας';

  @override
  String get locationPermissionRequired =>
      'Απαιτείται άδεια τοποθεσίας για παρακολούθηση ιστορικού';

  @override
  String get locationTrackingEnabled =>
      'Ενεργοποίηση εντοπισμού τοποθεσίας φόντου';

  @override
  String get locationTrackingDisabled =>
      'Απενεργοποίηση εντοπισμού τοποθεσίας φόντου';

  @override
  String get justNow => 'Μόλις τώρα';

  @override
  String minutesAgo(int minutes) {
    return '$minutes πριν από λεπτά';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours ώρες πριν';
  }

  @override
  String daysAgo(int days) {
    return '$days ημέρες πριν';
  }

  @override
  String get dataManagement => 'Διαχείριση δεδομένων';

  @override
  String get dataManagementDesc =>
      'Εξαγωγή ή διαγραφή των δεδομένων του λογαριασμού σας';

  @override
  String get splashTagline => 'Συναγερμοί εντοπισμού σε πραγματικό χρόνο';

  @override
  String get splashStartingUp => 'Ξεκινώντας...';

  @override
  String get splashInitializationFailed => 'Αποτυχία αρχικοποίησης';

  @override
  String get splashInitializationFailedTitle => 'Αποτυχία αρχικοποίησης';

  @override
  String get splashInitializationError =>
      'Η εφαρμογή απέτυχε να αρχικοποιήσει σωστά:';

  @override
  String get splashRetry => 'Επανάληψη';

  @override
  String get splashContinue => 'Συνέχεια';

  @override
  String get splashInitializing => 'Αρχικοποίηση...';

  @override
  String signInWelcome(String username) {
    return 'Καλωσόρισες!';
  }

  @override
  String signInFailed(String error) {
    return 'Αποτυχία σύνδεσης: $error';
  }

  @override
  String get signInPleaseEnterEmail =>
      'Παρακαλώ εισάγετε τη διεύθυνση email σας';

  @override
  String get signInPleaseEnterValidEmail =>
      'Παρακαλώ εισάγετε μια έγκυρη διεύθυνση email';

  @override
  String get signInMagicLinkSent =>
      'Ο μαγικός κρίκος στάλθηκε! Ελέγξτε το email σας και κάντε κλικ στο σύνδεσμο για να συνδεθείτε.';

  @override
  String get signInMagicLinkFailed =>
      'Αποτυχία αποστολής μαγικού συνδέσμου. Παρακαλώ προσπαθήστε ξανά.';

  @override
  String get signInAllDataCleared => 'Εκκαθάριση όλων των δεδομένων';

  @override
  String get signInSubtitle =>
      'Συναγερμοί εντοπισμού UFO σε πραγματικό χρόνο και αναφορές MUFON';

  @override
  String get signInGoogleLoading => 'Υπογραφή...';

  @override
  String get signInContinueWithGoogle => 'Συνεχίστε με το Google';

  @override
  String get signInOr => 'ή';

  @override
  String get signInWithEmail => 'Σύνδεση με Email';

  @override
  String get signInEmailDescription =>
      'Θα σου στείλουμε έναν ασφαλή σύνδεσμο για να υπογράψεις';

  @override
  String get signInEmailAddress => 'Διεύθυνση ηλεκτρονικού ταχυδρομείου';

  @override
  String get signInEmailPlaceholder => 'your@email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'Δοκιμάστε ξανά σε ${seconds}s';
  }

  @override
  String get signInSending => 'Αποστολή...';

  @override
  String get signInSendMagicLink => 'Αποστολή μαγικού δεσμού';

  @override
  String get signInCheckEmail =>
      'Έλεγξε το email σου! Ο σύνδεσμος λήγει σε 15 λεπτά.';

  @override
  String get signInSecureAuth => 'Ασφαλής ταυτοποίηση';

  @override
  String get signInSecureAuthDescription =>
      'Χρησιμοποιήστε το Google Sign-In για άμεση πρόσβαση, ή email μαγικό συνδέσμους που λήγουν σε 15 λεπτά.';

  @override
  String get signInClearAllDataDebug =>
      'Καθαρισμός όλων των δεδομένων (αποσφαλμάτωση)';

  @override
  String get emailAuthFailedToSend => 'Αποτυχία αποστολής email';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'Αποτυχία αποστολής email. Παρακαλώ προσπαθήστε ξανά.';

  @override
  String get emailAuthInvalidEmail =>
      'Μη έγκυρη διεύθυνση email. Παρακαλώ ελέγξτε τη μορφή.';

  @override
  String get emailAuthUserNotFound =>
      'Δε βρέθηκε λογαριασμός με αυτή τη διεύθυνση email.';

  @override
  String get emailAuthTooManyRequests =>
      'Πολλές προσπάθειες. Παρακαλώ προσπαθήστε ξανά αργότερα.';

  @override
  String get emailAuthOperationNotAllowed =>
      'Η σύνδεση email δεν είναι ενεργοποιημένη.';

  @override
  String get emailAuthQuotaExceeded =>
      'Υπερέβη την ποσόστωση ηλεκτρονικού ταχυδρομείου. Παρακαλώ προσπαθήστε ξανά αύριο.';

  @override
  String get emailAuthVerificationFailed =>
      'Η επαλήθευση ηλεκτρονικού ταχυδρομείου απέτυχε. Παρακαλώ προσπαθήστε ξανά.';

  @override
  String get emailAuthTitle => 'Επαλήθευση ηλεκτρονικού ταχυδρομείου';

  @override
  String get emailAuthVerifyYourEmail => 'Επαλήθευση του email σας';

  @override
  String get emailAuthDescription =>
      'Προσθέστε τη διεύθυνση ηλεκτρονικού ταχυδρομείου σας για την ανάκτηση λογαριασμού και την ασφάλεια. Θα σας στείλουμε έναν ασφαλή σύνδεσμο εισόδου.';

  @override
  String get emailAuthEmailAddress => 'Διεύθυνση ηλεκτρονικού ταχυδρομείου';

  @override
  String get emailAuthEmailPlaceholder => 'your.email@example.com';

  @override
  String get emailAuthPleaseEnterEmail =>
      'Παρακαλώ εισάγετε τη διεύθυνση email σας';

  @override
  String get emailAuthPleaseEnterValidEmail =>
      'Παρακαλώ εισάγετε μια έγκυρη διεύθυνση email';

  @override
  String get emailAuthCheckEmailToContinue =>
      'Ελέγξτε το email σας και πατήστε το σύνδεσμο επαλήθευσης για να συνεχίσετε.';

  @override
  String get emailAuthResendEmail => 'Επαναφορά email';

  @override
  String get emailAuthSendVerificationEmail =>
      'Αποστολή επαλήθευσης Ηλεκτρονικό ταχυδρομείο';

  @override
  String get emailAuthHowItWorks =>
      'Πώς λειτουργεί η επαλήθευση ηλεκτρονικού ταχυδρομείου';

  @override
  String get emailAuthHowItWorksSteps =>
      '1. Σας στέλνουμε ασφαλή σύνδεση εισόδου\n2. Ελέγξτε το email σας και πατήστε το σύνδεσμο\n3. Το email σας επαληθεύεται αυτόματα\n4. Δεν χρειάζονται κωδικοί πρόσβασης!';

  @override
  String get emailAuthSecurityNotice =>
      'Η επαλήθευση ηλεκτρονικού ταχυδρομείου βοηθά στην εξασφάλιση του λογαριασμού σας και επιτρέπει την ανάκτηση λογαριασμού αν χάσετε την πρόσβαση στη συσκευή σας.';

  @override
  String get phoneAuthFailedToSendCode =>
      'Αποτυχία αποστολής κωδικού επαλήθευσης. Παρακαλώ προσπαθήστε ξανά.';

  @override
  String get phoneAuthInvalidCodeTryAgain =>
      'Μη έγκυρος κωδικός επαλήθευσης. Παρακαλώ προσπαθήστε ξανά.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'Επαλήθευση αριθμού τηλεφώνου: $phoneNumber';
  }

  @override
  String get phoneAuthVerificationFailed =>
      'Η επαλήθευση τηλεφώνου απέτυχε. Παρακαλώ προσπαθήστε ξανά.';

  @override
  String get phoneAuthCodeResent => 'Κωδικός επαλήθευσης';

  @override
  String get phoneAuthFailedToResendCode =>
      'Αποτυχία αποστολής κώδικα. Παρακαλώ προσπαθήστε ξανά.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'Μη έγκυρο αριθμό τηλεφώνου. Παρακαλώ ελέγξτε τη μορφή.';

  @override
  String get phoneAuthTooManyRequests =>
      'Πολλές προσπάθειες. Παρακαλώ προσπαθήστε ξανά αργότερα.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'Μη έγκυρος κωδικός επαλήθευσης. Παρακαλώ ελέγξτε και προσπαθήστε ξανά.';

  @override
  String get phoneAuthSessionExpired =>
      'Η συνεδρία επαλήθευσης έληξε. Παρακαλώ ζητήστε νέο κωδικό.';

  @override
  String get phoneAuthSmsQuotaExceeded =>
      'Υπερέβη την ποσόστωση SMS. Παρακαλώ προσπαθήστε ξανά αύριο.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'Αυτός ο αριθμός τηλεφώνου είναι ήδη συνδεδεμένος με άλλο λογαριασμό.';

  @override
  String get phoneAuthVerificationFailedGeneric =>
      'Η επαλήθευση απέτυχε. Παρακαλώ προσπαθήστε ξανά.';

  @override
  String get phoneAuthTitle => 'Επαλήθευση τηλεφώνου';

  @override
  String get phoneAuthVerifyYourPhone => 'Επαλήθευση του τηλεφώνου σας';

  @override
  String get phoneAuthEnterVerificationCode => 'Εισαγωγή επαλήθευσης Κωδικός';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'Προσθέστε τον αριθμό τηλεφώνου σας για ανάκτηση λογαριασμού και ασφάλεια';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return 'Εισάγετε τον εξαψήφιο κωδικό που αποστέλλεται στο $phoneNumber';
  }

  @override
  String get phoneAuthPhoneNumber => 'Αριθμός τηλεφώνου';

  @override
  String get phoneAuthPhonePlaceholder => '+1 (555) 123-4567';

  @override
  String get phoneAuthPleaseEnterPhone =>
      'Παρακαλώ εισάγετε τον αριθμό τηλεφώνου σας';

  @override
  String get phoneAuthPleaseEnterValidPhone =>
      'Παρακαλώ εισάγετε έναν έγκυρο αριθμό τηλεφώνου';

  @override
  String get phoneAuthVerificationCode => 'Κωδικός επαλήθευσης';

  @override
  String get phoneAuthPleaseEnterSixDigitCode =>
      'Παρακαλώ εισάγετε τον εξαψήφιο κωδικό';

  @override
  String get phoneAuthResendCode => 'Επαναφορά κώδικα';

  @override
  String get phoneAuthSendVerificationCode => 'Αποστολή επαλήθευσης Κωδικός';

  @override
  String get phoneAuthVerifyCode => 'Επαλήθευση κώδικα';

  @override
  String get phoneAuthChangePhoneNumber => 'Τροποποίηση αριθμού τηλεφώνου';

  @override
  String get phoneAuthSmsNotice =>
      'Θα σας στείλουμε έναν κωδικό επαλήθευσης μέσω SMS. Ενδέχεται να ισχύουν τυποποιημένες τιμές μηνυμάτων.';

  @override
  String get phoneAuthCodeExpires =>
      'Ο κωδικός λήγει σε 60 δευτερόλεπτα. Ελέγξτε τα μηνύματά σας.';

  @override
  String get yourDataRights => 'Τα Δικαιώματα των Δεδομένων Σας';

  @override
  String get dataRightsExplanation =>
      'Έχετε τον πλήρη έλεγχο των προσωπικών σας δεδομένων. Μπορείτε να εξαγάγετε όλα τα δεδομένα σας ή να διαγράψετε μόνιμα το λογαριασμό σας ανά πάσα στιγμή.';

  @override
  String get exportYourData => 'Εξαγωγή των δεδομένων σας';

  @override
  String get exportDataDescription =>
      'Κατεβάστε όλα τα δεδομένα του λογαριασμού σας';

  @override
  String get exportData => 'Εξαγωγή δεδομένων';

  @override
  String get exportingData => 'Εξαγωγή...';

  @override
  String get exportDataDetails =>
      'Περιλαμβάνει: προφίλ, μπιπ, σχόλια, πληροφορίες συσκευών και προτιμήσεις. Τα δεδομένα παρέχονται σε μορφή JSON.';

  @override
  String get dataExportedSuccessfully => 'Τα δεδομένα εξάγονται επιτυχώς';

  @override
  String get dataExportFailed => 'Αποτυχία εξαγωγής δεδομένων';

  @override
  String get deleteAccount => 'Διαγραφή λογαριασμού';

  @override
  String get deleteAccountDescription =>
      'Διαρκώς αφαιρέστε το λογαριασμό σας και όλα τα δεδομένα';

  @override
  String get deleteAccountWarning =>
      'Αυτή η ενέργεια δεν μπορεί να αναιρεθεί. Όλα τα μπιπ, τα σχόλια και τα δεδομένα λογαριασμού σας θα διαγραφούν οριστικά.';

  @override
  String get deleteMyAccount => 'Διαγραφή του λογαριασμού μου';

  @override
  String get deletingAccount => 'Διαγραφή...';

  @override
  String get deleteAccountConfirmTitle => 'Διαγραφή λογαριασμού';

  @override
  String get deleteAccountConfirmMessage =>
      'Είστε απολύτως σίγουροι ότι θέλετε να διαγράψετε το λογαριασμό σας; Αυτή η ενέργεια είναι μόνιμη και δεν μπορεί να αναιρεθεί.';

  @override
  String get dataWillBeDeleted =>
      'Τα ακόλουθα δεδομένα θα διαγραφούν οριστικά:';

  @override
  String get deletedDataList =>
      '• Το προφίλ και το όνομα χρήστη σας\n• Όλα τα μπιπ και οι αναφορές σας\n• Όλα τα σχόλιά σας\n• Δεδομένα εγγραφής συσκευών\n• Δεδομένα τοποθεσίας και προτίμησης';

  @override
  String get deleteAccountPermanent => 'Διαγραφή μόνιμα';

  @override
  String get accountDeletedSuccessfully =>
      'Ο λογαριασμός διαγράφηκε με επιτυχία';

  @override
  String get accountDeletionFailed => 'Αποτυχία διαγραφής λογαριασμού';

  @override
  String get onboardingWelcomeTitle => 'Καλώς ήρθατε στο UFOBeep';

  @override
  String get onboardingWelcomeBody =>
      'Πάρτε σε πραγματικό χρόνο ειδοποιήσεις όταν UFOs εντοπίζονται κοντά. Ποτέ μην χάσεις μια ματιά ξανά.';

  @override
  String get onboardingAlertsTitle => 'Μείνετε ενημερωμένοι';

  @override
  String get onboardingAlertsBody =>
      'Καθορίστε πόσο μακριά θα πρέπει να είναι οι εμφανίσεις για να ενεργοποιήσετε τις ειδοποιήσεις.';

  @override
  String get onboardingReportTitle => 'Βλέπεις κάτι; Μπιπ!';

  @override
  String get onboardingReportBody =>
      'Τραβήξτε μια φωτογραφία ή βίντεο και μοιραστείτε αμέσως με κοντινούς παρατηρητές.';

  @override
  String get onboardingPermissionsTitle =>
      'Η φωτογραφική σας μηχανή & τοποθεσία';

  @override
  String get onboardingPermissionsBody =>
      'Ενεργοποίηση κάμερας, τοποθεσίας και ειδοποιήσεων ώστε να μπορείτε:\n– Αναφέρετε τις εμφανίσεις γρήγορα\n– Πάρτε ειδοποιήσεις για UFOs κοντά σας';

  @override
  String get onboardingCameraTitle => 'Αποδείξεις σύλληψης';

  @override
  String get onboardingCameraBody =>
      'Μοιραστείτε φωτογραφίες και βίντεο που μόλις τραβήξατε από τη γκαλερί σας ή πατήστε το εικονίδιο UFOBeep για να ξεκινήσετε σε λειτουργία στιγμιαίας κάμερας.';

  @override
  String get onboardingCompassTitle => 'Βλέπε Πού Κοίταξαν';

  @override
  String get onboardingCompassBody =>
      'Η πυξίδα σας δείχνει την ακριβή κατεύθυνση που έψαχνε ο μάρτυρας όταν είδαν το UFO. Σημάδεψε το τηλέφωνό σου και κοίτα!';

  @override
  String get onboardingCommunityTitle => 'Μπείτε στους Παρατηρητές του Ουρανού';

  @override
  String get onboardingCommunityBody =>
      'Περιήγηση θεάσεις, πρόσβαση MUFON εκθέσεις, και σύνδεση με συναδέλφους παρατηρητές του ουρανού.';

  @override
  String get skip => 'Παράλειψη';

  @override
  String get getStarted => 'Ξεκινήστε';

  @override
  String get viewOnboardingAgain => 'Προβολή και πάλι επί του σκάφους';

  @override
  String get customAlertRange => 'Προσαρμοσμένο εύρος ειδοποίησης';

  @override
  String get enterRangeKm => 'Εισάγετε εύρος σε km (1-99999)';

  @override
  String get largeRangeWarning =>
      'Μεγάλο εύρος (> 100 km) μπορεί να δημιουργήσει πολλές καταχωρίσεις';

  @override
  String get globalRangeWarning =>
      'Πολύ μεγάλες σειρές (> 1000 χιλιόμετρα) θα σας στείλει ειδοποιήσεις από όλο τον κόσμο';

  @override
  String get invalidRange => 'Παρακαλώ εισάγετε έναν αριθμό μεταξύ 1 και 99999';

  @override
  String get celestialSunDaylight =>
      'Ο ήλιος είναι επάνω - συνθήκες ημέρας μπορεί να επηρεάσει την ορατότητα παρατήρησης';

  @override
  String get celestialSunTwilight =>
      'Συνθήκες λυκόφως - κάποια ορατότητα αλλά πιο σκοτεινή από το φως της ημέρας';

  @override
  String get celestialSunDark =>
      'Σκοτεινές συνθήκες - βέλτιστες για την παρατήρηση αντικειμένων στον ουρανό';

  @override
  String celestialMoonBright(Object phase) {
    return 'Φωτεινό φεγγάρι $phase ορατό - μπορεί να φωτίσει ή να κρύψει άλλα αντικείμενα';
  }

  @override
  String celestialMoonModerate(Object phase) {
    return '$phase ορατό φεγγάρι - μέτριες συνθήκες φωτισμού';
  }

  @override
  String celestialMoonThin(Object phase) {
    return 'Λεπτό $phase φεγγάρι ορατό - ελάχιστος φωτισμός';
  }

  @override
  String celestialMoonHidden(Object phase) {
    return '$phase φεγγάρι κάτω από τον ορίζοντα - χωρίς σεληνιακό φωτισμό';
  }

  @override
  String get celestialNoPlanets =>
      'Κανένας φωτεινός πλανήτης ορατός που θα μπορούσε να είναι λάθος για UFO';

  @override
  String celestialPlanetHigh(Object altitude, Object planet) {
    return '$planet ψηλά πάνω από το κεφάλι ($altitude°) - πολύ εμφανές';
  }

  @override
  String celestialPlanetMedium(Object altitude, Object planet) {
    return '$planet ορατό σε $altitude° - θα μπορούσε να εκληφθεί λανθασμένα ως αεροσκάφος';
  }

  @override
  String celestialPlanetLow(Object altitude, Object planet) {
    return '$planet χαμηλά στον ορίζοντα ($altitude°)';
  }

  @override
  String get celestialNoStars =>
      'Δεν υπάρχουν ασυνήθιστα φωτεινά αστέρια ορατά';

  @override
  String celestialStarSingle(Object altitude, Object star) {
    return '$star εμφανές σε $altitude° υψόμετρο';
  }

  @override
  String celestialStarsMultiple(Object count, Object names) {
    return '$count φωτεινά αστέρια ορατά - $names';
  }

  @override
  String get celestialSummaryDaylight => 'Συνθήκες ημέρας';

  @override
  String get celestialSummaryDark => 'Σκοτεινές συνθήκες ουρανού';

  @override
  String get celestialSummaryMoonUp => 'φωτισμός φεγγαριού παρούσα';

  @override
  String get celestialSummaryMoonDown => 'χωρίς φωτισμό φεγγαριού';

  @override
  String celestialSummaryManyObjects(Object count) {
    return '$count φωτεινά αντικείμενα που θα μπορούσαν να συγχέονται με UFO';
  }

  @override
  String celestialSummarySomeObjects(Object count) {
    return '$count φωτεινά αντικείμενα ορατά';
  }

  @override
  String get celestialSummaryFewObjects =>
      'ελάχιστα φωτεινά αντικείμενα στον ουρανό';

  @override
  String celestialSkySummary(Object conditions) {
    return 'Συνθήκες ουρανού: $conditions';
  }

  @override
  String get planetVenus => 'Αφροδίτη';

  @override
  String get planetJupiter => 'Δίας';

  @override
  String get planetSaturn => 'Κρόνος';

  @override
  String get planetMars => 'Άρης';

  @override
  String get planetMercury => 'Υδράργυρος';

  @override
  String get planetUranus => 'Ουρανός';

  @override
  String get planetNeptune => 'Ποσειδώνας';

  @override
  String get starSirius => 'Σείριος';

  @override
  String get starCanopus => 'Κανόπους';

  @override
  String get starArcturus => 'Αρκτούρος';

  @override
  String get starVega => 'Βέγκα';

  @override
  String get starCapella => 'Καπέλα';

  @override
  String get starRigel => 'Ρίγκελ';

  @override
  String get starProcyon => 'Προκυόνιο';

  @override
  String get starBetelgeuse => 'Μπετελγκέζε';

  @override
  String get moonPhaseNew => 'Νέα Σελήνη';

  @override
  String get moonPhaseWaxingCrescent => 'Ημισέληνος';

  @override
  String get moonPhaseFirstQuarter => 'Πρώτο τρίμηνο';

  @override
  String get moonPhaseWaxingGibbous => 'Γυαλιά με κερί';

  @override
  String get moonPhaseFull => 'Πανσέληνος';

  @override
  String get moonPhaseWaningGibbous => 'Κεραυνοί Γκίμπους';

  @override
  String get moonPhaseThirdQuarter => 'Τρίτο τρίμηνο';

  @override
  String get moonPhaseWaningCrescent => 'Κερδίζοντας ημισέληνος';

  @override
  String planetBelowHorizon(Object planet) {
    return '$planet κάτω από τον ορίζοντα';
  }

  @override
  String planetHighOverheadProminent(Object altitude, Object planet) {
    return '$planet ψηλά πάνω από το κεφάλι ($altitude°) - πολύ εμφανές';
  }

  @override
  String planetMidSkyProminent(Object altitude, Object planet) {
    return '$planet σε $altitude° - εμφανές';
  }

  @override
  String planetMidSky(Object altitude, Object planet) {
    return '$planet at $altitude°';
  }

  @override
  String starVeryBright(Object altitude, Object star) {
    return '$star πολύ φωτεινό σε $altitude°';
  }

  @override
  String starProminent(Object altitude, Object star) {
    return '$star εμφανές σε $altitude° υψόμετρο';
  }

  @override
  String starVisible(Object altitude, Object star) {
    return '$star at $altitude°';
  }

  @override
  String get altitudeShort => 'Άλτ';

  @override
  String get magnitudeShort => 'Μαγ';

  @override
  String get airlineLabel => 'Αεροπορική εταιρεία';

  @override
  String get speedLabel => 'Ταχύτητα';

  @override
  String get headingLabel => 'Πορεία';

  @override
  String get ownerLabel => 'Ιδιοκτήτης';

  @override
  String get launchedLabel => 'Εκτοξεύθηκε';

  @override
  String get noradIdLabel => 'NORAD ID';

  @override
  String get typeLabel => 'Τύπος';

  @override
  String get azimuthLabel => 'Αζιμούθιο';

  @override
  String get visibilityLabel => 'Ορατότητα';

  @override
  String get satelliteType => 'Δορυφόρος';

  @override
  String get rocketBodyType => 'Σώμα πυραύλου';

  @override
  String get debrisType => 'Συντρίμμια';

  @override
  String get nakedEyeVisible => 'Ορατό με γυμνό μάτι';

  @override
  String satellitesVisibleMightExplain(Object count) {
    return '$count δορυφόροι ορατοί - μπορεί να εξηγήσει την παρατήρηση';
  }

  @override
  String satellitesVisibleUnlikelyExplain(Object count) {
    return '$count δορυφόροι ορατοί - απίθανο να εξηγήσει την παρατήρηση';
  }

  @override
  String get noSatellitesVisible => 'Δεν φαίνονται δορυφόροι';

  @override
  String aircraftDetectedInRadius(Object count, Object radius) {
    return '$count αεροσκάφος που εντοπίστηκε εντός ${radius}km';
  }

  @override
  String get processingAlert => 'Επεξεργασία συναγερμού UFO...';

  @override
  String get analyzingEnvironment => 'Ανάλυση των περιβαλλοντικών συνθηκών';

  @override
  String get weatherAnalysis => 'Ανάλυση καιρού';

  @override
  String get locationAnalysis => 'Ανάλυση τοποθεσίας';

  @override
  String get aircraftTracking => 'Παρακολούθηση αεροσκαφών';

  @override
  String get satelliteAnalysis => 'Δορυφορική Ανάλυση';

  @override
  String get celestialAnalysis => 'Ουράνια Ανάλυση';

  @override
  String analyzing(Object processor) {
    return 'Ανάλυση $processor...';
  }

  @override
  String get processorWeather => 'καιρικές συνθήκες';

  @override
  String get processorLocation => 'λεπτομέρειες τοποθεσίας';

  @override
  String get processorAircraft => 'γειτονικά αεροσκάφη';

  @override
  String get processorSatellites => 'δορυφορικές θέσεις';

  @override
  String get processorCelestial => 'ουράνια αντικείμενα';

  @override
  String get calculatingCelestialData => 'Υπολογίζοντας ουράνια δεδομένα...';

  @override
  String get sunLabel => 'Ήλιος';

  @override
  String get moonLabel => 'Σελήνη';

  @override
  String planetsVisible(int count) {
    return 'Πλανήτες: $count ορατοί';
  }

  @override
  String get starsLabel => 'Άστρα';

  @override
  String get planetsLabel => 'Πλανήτες';

  @override
  String moonWithPhase(String phase) {
    return 'Σελήνη ($phase)';
  }

  @override
  String get noSatellitesVisibleAtTime =>
      'Κανένας δορυφόρος δεν ήταν ορατός την ακριβή στιγμή της θέασής σας';

  @override
  String get satellitesVisibleOverheadAtTime =>
      'Δορυφορικοί δορυφόροι ορατοί από πάνω κατά το χρόνο και την τοποθεσία παρατήρησης';

  @override
  String get belowHorizon => 'κάτω από τον ορίζοντα';

  @override
  String get analysisFailedGeneric => 'Αποτυχία ανάλυσης';

  @override
  String get unknownWeather => 'Άγνωστο';

  @override
  String get noWeatherDescription => 'Χωρίς περιγραφή';

  @override
  String get altitudeAbbrev => 'Άλτ';

  @override
  String get azimuthAbbrev => 'Αζ';

  @override
  String satellitesVisibleNow(int count) {
    return 'Δορυφόροι ($count ορατοί τώρα)';
  }

  @override
  String sunWithDescription(String description) {
    return 'Ήλιος: $description';
  }

  @override
  String moonWithDescription(String description) {
    return 'Φεγγάρι: $description';
  }

  @override
  String get unknownPlanet => 'Άγνωστος πλανήτης';

  @override
  String get unknownStar => 'Άγνωστο άστρο';

  @override
  String get unknownSatellite => 'Άγνωστος δορυφόρος';

  @override
  String get unknownDirection => 'άγνωστη κατεύθυνση';

  @override
  String get brightStars => 'Φωτεινά αστέρια';

  @override
  String get satellites => 'Δορυφόροι';

  @override
  String seeAllSatellites(int count) {
    return 'Δείτε όλους τους δορυφόρους $count';
  }

  @override
  String maxElevation(String degrees) {
    return 'Μέγιστο υψόμετρο: $degrees°';
  }

  @override
  String magnitude(String value) {
    return 'Μέγεθος: $value';
  }

  @override
  String get unknownGeneric => 'Άγνωστο';

  @override
  String altitudeValue(String degrees) {
    return '$degrees° υψόμετρο';
  }

  @override
  String azimuthValue(String degrees) {
    return '$degrees° αζιμούθιο';
  }

  @override
  String get noCelestialDataAvailable =>
      'Δεν υπάρχουν διαθέσιμα ουράνια δεδομένα.';

  @override
  String get gettingLocation => 'Να πάρει τη θέση σας...';

  @override
  String get media => 'Μέσα ενημέρωσης';

  @override
  String get locationRequired => 'Απαιτούμενη τοποθεσία';

  @override
  String get confirmingWitness => 'Επιβεβαιώνω μάρτυρα...';

  @override
  String get chooseYourUsername => 'Επιλέξτε το όνομα χρήστη σας';

  @override
  String get moreNames => 'Περισσότερα ονόματα';

  @override
  String get notificationSettings => 'Settings ειδοποίησης';

  @override
  String get quickActions => 'Γρήγορη ενέργεια';

  @override
  String get doNotDisturb => 'Μην ενοχλείστε';

  @override
  String get temporarilySilenceNotifications =>
      'Προσωρινά σιωπή όλες οι ειδοποιήσεις';

  @override
  String get oneHour => '1η';

  @override
  String get eightHours => '8η';

  @override
  String get oneDay => '1 ημέρα';

  @override
  String get startTime => 'Ώρα έναρξης';

  @override
  String get endTime => 'Ώρα τέλους';

  @override
  String get allowCriticalAlertsDuringQuietHours =>
      'Επίτρεψε κρίσιμες ειδοποιήσεις κατά τη διάρκεια ωρών ηρεμίας';

  @override
  String get silenceNotificationsDuringSleepHours =>
      'Ειδοποιήσεις σιωπής κατά τις ώρες ύπνου';

  @override
  String quietHoursActiveTimeRange(String startTime, String endTime) {
    return 'Ενεργός $startTime - $endTime';
  }

  @override
  String get followingAlerts => 'Μετά τις καταχωρίσεις';

  @override
  String activeCount(int count) {
    return '$count ενεργό';
  }

  @override
  String get unfollow => 'Ακολούθηση';

  @override
  String get unfollowAlert => 'Ακολούθα την ειδοποίηση';

  @override
  String commentsCount(int count) {
    return '$count comments';
  }

  @override
  String get photo => 'Φωτογραφία';

  @override
  String get video => 'Βίντεο';

  @override
  String get initializationComplete => 'Η αρχικοποίηση ολοκληρώθηκε!';

  @override
  String get validatingEnvironment => 'Επικύρωση περιβάλλοντος...';

  @override
  String get requestingPermissions => 'Ζητώ άδειες...';

  @override
  String get loadingAuthSession => 'Φόρτωση συνεδρίας γλώσσας...';

  @override
  String get checkingUserRegistration => 'Έλεγχος εγγραφής χρήστη...';

  @override
  String get loadingPreferences => 'Φόρτωση προτιμήσεων...';

  @override
  String get settingUpLocalization => 'Setting εντοπισμού...';

  @override
  String get checkingConnectivity => 'Έλεγχος συνδεσιμότητας...';

  @override
  String get gatheringDeviceInfo => 'Συγκέντρωση πληροφοριών συσκευής...';

  @override
  String get translating => 'Μεταφράζω...';

  @override
  String get showOriginal => 'Εμφάνιση αρχικού';

  @override
  String translateTo(String language) {
    return 'Μετάφραση σε $language';
  }

  @override
  String translatedFrom(String language) {
    return 'Μεταφράστηκε από $language';
  }

  @override
  String translateContent(String language) {
    return 'Μεταφράστε το περιεχόμενο στο $language';
  }

  @override
  String get weatherClear => 'Καθαρισμός';

  @override
  String get weatherClearSky => 'καθαρός ουρανός';

  @override
  String get rain => 'Βροχή';

  @override
  String get snow => 'Χιόνι';

  @override
  String get thunderstorm => 'Καταιγίδα';

  @override
  String get drizzle => 'Ψιλή';

  @override
  String get fog => 'Ομίχλη';

  @override
  String get fewClouds => 'λίγα σύννεφα';

  @override
  String get scatteredClouds => 'διάσπαρτα σύννεφα';

  @override
  String get brokenClouds => 'σπασμένα σύννεφα';

  @override
  String get overcastClouds => 'σύννεφα από συννεφιά';

  @override
  String get lightRain => 'ελαφρά βροχή';

  @override
  String get moderateRain => 'μέτρια βροχή';

  @override
  String get heavyRain => 'βαριά βροχή';

  @override
  String aircraftDetectedCurrentPositions(int count, String radius) {
    return '$count αεροσκάφος που εντοπίστηκε εντός ${radius}km (τρέχουσες θέσεις)';
  }

  @override
  String dimSatellitesUnlikely(int count) {
    return '$count Ορατοί αμυδροί δορυφόροι - απίθανο να εξηγήσουν την παρατήρηση';
  }

  @override
  String get mufonReportingDate => 'ΜΟΥΦΟΝ Ημερομηνία αναφοράς';

  @override
  String satelliteNameDirection(String name, String direction) {
    return '$name - $direction';
  }
}
