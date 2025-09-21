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
    return '__PACHOLDER_0_ μακριά';
  }

  @override
  String alertDirection(int bearing) {
    return 'Διόπτευση __PLACEHOLDER_0_°';
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
    return 'Αναφέρθηκε από $username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Αναφέρθηκε $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '___PACHOLDER_0______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
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
    return 'Σύννεφο: __PLACEHOLDER_0_%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Άνεμος: ${speed}_PLACEHOLDER_1_';
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
  String get quietHoursEnabled => 'Ενεργοποίηση ωρών ησυχίας';

  @override
  String get quietHoursFrom => 'Από';

  @override
  String get quietHoursUntil => 'Μέχρι';

  @override
  String get quietHoursDefaultTime => 'Προκαθορισμένες ώρες ησυχίας';

  @override
  String get emergencyOverride => 'Παράκαμψη έκτακτης ανάγκης';

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
  String get quietHoursActive => 'Ώρες ηρεμίας ενεργές';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Ώρες ησυχίας: _________________________';
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
    return '_${username}_ σχολίασε στο __PLACEHOLDER_1_';
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
    return '__PACHOLDER_0_ ημέρες πριν';
  }

  @override
  String timeHoursAgo(int count) {
    return '__PLACEHOLDER_0_ ώρες πριν';
  }

  @override
  String timeMinutesAgo(int count) {
    return '__PLACEHOLDER_0_ πριν από λίγα λεπτά';
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
    return 'Υπόθεση MUFON #__PLACEHOLDER_0_ Λεπτομέρειες';
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
    return '__PLACEHOLDER_0_ Οι άνθρωποι επιβεβαίωσαν αυτή την παρατήρηση';
  }

  @override
  String get photoAnalysisTitle => 'Ανάλυση φωτογραφιών';

  @override
  String mediaItemsProcessed(int count) {
    return 'Ανάλυση: __PLACEHOLDER_0_ media file(s) processed';
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
  String get timeFormat24Hour => '24 ώρες (14:30)';

  @override
  String get timeFormat12Hour => '12 ώρες (2:30 μ.μ.)';

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
    return '__PLACEHOLDER_0_ Οι άνθρωποι έχουν επιβεβαιώσει αυτή την παρατήρηση';
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
    return '__PLACHOLDER_0___PLACHOLDER_1_';
  }

  @override
  String notificationCommentTitle(String username) {
    return '💬 $username σχολίασε';
  }

  @override
  String get notificationWitnessText => 'Νέα παρατήρηση';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '__PLACEHOLDER_0_ μάρτυρες';
  }

  @override
  String get notificationActionSnooze => 'Σνούζ 1 ώρα';

  @override
  String get notificationActionDismiss => 'Ελεύθεροι';

  @override
  String notificationDistance(String distance) {
    return '__PACHOLDER_0_ μακριά';
  }

  @override
  String get unknown => 'άγνωστο';

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
    return 'Σελίδα _${currentPage}__PLACEHOLDER_1_ (__PLACEHOLDER_2_ σύνολο μπιπ)';
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
  String get howItWorks => 'Πώς λειτουργεί το UFOBeep';

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
    return 'Έκθεση MUFON __PLACEHOLDER_0_';
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
    return '__PLACEHOLDER_0_ εικόνες';
  }

  @override
  String get mediaCountSingle => '1 εικόνα';

  @override
  String mediaMoreImages(Object count) {
    return '+___PLACHOLDER_0_ more';
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
}
