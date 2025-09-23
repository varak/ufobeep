// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'UFOBeep';

  @override
  String get ok => 'TAMAM TAMAM';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Retry';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır hayır hayır';

  @override
  String get back => 'Geri dön';

  @override
  String get next => 'Sonraki';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Yükleniyor..';

  @override
  String get processing => 'İşleme..';

  @override
  String get errorGeneric => 'Bir şey yanlış gitti.';

  @override
  String get networkError => 'Ağ hatası. bağlantınızı kontrol edin.';

  @override
  String get permissionsRequired => 'İzinler gerekli';

  @override
  String get learnMore => 'Daha fazlasını öğrenin';

  @override
  String get welcomeTitle => 'UFOBeep\'e hoş geldiniz';

  @override
  String get welcomeSubtitle => 'Gerçek zamanlı UFO, size yakın uyarılar';

  @override
  String get signIn => 'Sign in Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get continueAsGuest => 'Misafir olarak devam et';

  @override
  String get enterUsername => 'Bir kullanıcı adı girin';

  @override
  String get username => 'Username';

  @override
  String get usernameUpdated => 'Username güncellendi';

  @override
  String get profile => 'Profil Profili';

  @override
  String get settings => 'Ayarlar';

  @override
  String get tabAlerts => 'Uyarılar';

  @override
  String get tabBeep => 'Beep';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabMap => 'Map';

  @override
  String get tabSettings => 'Ayarlar';

  @override
  String get alertsTitle => 'Nearby Alerts';

  @override
  String get noAlerts => 'Henüz yakınlarda uyarı yok.';

  @override
  String get pullToRefresh => 'Yeniden yenilemek için';

  @override
  String alertDistance(String distance) {
    return '$distance away';
  }

  @override
  String alertDirection(int bearing) {
    return 'Page $bearing°';
  }

  @override
  String get viewAlert => 'View uyarı';

  @override
  String get viewOnMap => 'Haritada görüntüle';

  @override
  String get iSeeItToo => 'Onu da görüyorum';

  @override
  String get confirmWitnessed => 'Bu görüşe tanık oldunuz mu?';

  @override
  String get witnessConfirmed => 'Teşekkürler - onayınız yayınlandı.';

  @override
  String get createBeepTitle => 'Bir Beep gönder';

  @override
  String get beepExplain =>
      'Yakındaki bekçileri gördüğünüzü ve uyarmayı yakalayın.';

  @override
  String get capturePhoto => 'Yakalanan fotoğraf';

  @override
  String get captureVideo => 'Yakalanan video';

  @override
  String get pickFromGallery => 'Galeriden seçin';

  @override
  String get descriptionHint => 'Gökyüzünde ne gördüğünü açıklayın..';

  @override
  String get submitBeep => 'Gönder';

  @override
  String get beepSent => 'Beep sent';

  @override
  String beepSentWithUrl(String shortUrl) {
    return 'Beep başarıyla gönderildi';
  }

  @override
  String get uploadingMedia => 'Medyayı yüklemek..';

  @override
  String get includeLocation => 'Site Ekle';

  @override
  String get includeTimestamp => 'Zamanları ekleyin';

  @override
  String get beepFailed => 'Beep göndermeye başarısız oldu.';

  @override
  String get mediaProcessing => 'İşleme medyası..';

  @override
  String get cameraPermissionTitle =>
      'Camera access needed needed needed needed';

  @override
  String get cameraPermissionBody =>
      'UFO fotoğraf ve videoları yakalamak için kamera erişimi.';

  @override
  String get locationPermissionTitle => 'Konum Permission Required';

  @override
  String get locationPermissionBody =>
      'Konumunuzu yakındaki uyarıları göndermek ve almak için kullanıyoruz.';

  @override
  String get microphonePermissionTitle => 'Mikrophone erişim gerekli gerekli';

  @override
  String get microphonePermissionBody =>
      'Video için mikrofon erişimi ses ile yakalamak için.';

  @override
  String get openSettings => 'Açık ayarlar';

  @override
  String get alertDetailTitle => 'Sighting Details';

  @override
  String reportedBy(String username) {
    return '$username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Reported $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '$distance';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Nesneye göre: $bearing°';
  }

  @override
  String get openCompass => 'Open compass';

  @override
  String get openAR => 'Open AR overlay';

  @override
  String get openChat => 'Açık sohbet';

  @override
  String get commentsTitle => 'Yorumlar';

  @override
  String get addComment => 'Yorum ekleyin..';

  @override
  String get send => 'Send Send Send Gönder';

  @override
  String get commentPosted => 'Yorum yayınlandı';

  @override
  String get autoFollowEnabled => 'Şimdi bu uyarıyı takip ediyorsunuz.';

  @override
  String get noCommentsYet => 'Henüz yorum yok. Yorum yapmak için ilk olun!';

  @override
  String get newCommentNotification =>
      'Takip ettiğiniz bir görüşe yeni bir yorum.';

  @override
  String get mapTitle => 'Canlı Harita';

  @override
  String get compassTitle => 'Compass';

  @override
  String get compassSettings => 'Compass Ayarlar';

  @override
  String get compassMode => 'Compass Mode';

  @override
  String get compassStandardMode => 'Standart Mod';

  @override
  String get compassPilotMode => 'Pilot Mod';

  @override
  String get compassStandardDescription => 'Temel başlık ve navigasyon';

  @override
  String get compassPilotDescription =>
      'ETA ve vektöring ile Gelişmiş navigasyon';

  @override
  String pointingTo(String direction) {
    return '$direction';
  }

  @override
  String get calibratingCompass => 'Kalibrating compass..';

  @override
  String get openAROverlay => 'Open AR overlay';

  @override
  String get pushTitleAlertNearby => 'UFO Uyarısı yakınınızda';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Yeni bir görüşe göre $distance away.';
  }

  @override
  String get pushTitleComment => 'Yeni Yorum';

  @override
  String get pushBodyComment =>
      'Birisi takip ettiğiniz bir görüş üzerine yorum yaptı.';

  @override
  String get pushTitleWitness => 'Tanık Onay';

  @override
  String get temperature => 'Sıcaklık';

  @override
  String get pushBodyWitness =>
      'Bir kullanıcı aynı nesneyi gördüklerini doğruladı.';

  @override
  String get weather => 'Hava';

  @override
  String cloudCover(int percent) {
    return 'Cloud cover: $percent%%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Rüzgar: $speed $unit';
  }

  @override
  String get nearbyAircraft => 'Nearby uçakları';

  @override
  String get noAircraft => 'Yakınlarda hiç uçak yok';

  @override
  String get loadingContext => 'Çevre bağlamı yükleniyor..';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get enablePushNotifications =>
      'Gelecekteki yorumlar için bildirimleri alın';

  @override
  String get quietHours => 'Sessiz saatler';

  @override
  String get quietHoursDesc => 'Seçilen saatler arasında sessizlik uyarıları.';

  @override
  String get quietHoursEnabled => 'Enable sessiz saatler';

  @override
  String get quietHoursFrom => 'From';

  @override
  String get quietHoursUntil => 'Olana kadar';

  @override
  String get quietHoursDefaultTime => 'Varsayılan sessiz saatler';

  @override
  String get emergencyOverride => 'Acil durum';

  @override
  String get emergencyOverrideDesc =>
      'Sessiz saatler boyunca acil uyarılara izin verin';

  @override
  String get dndMode => 'Yapmayın';

  @override
  String get dndUntil => 'Ne kadar rahatsız etmeyin';

  @override
  String dndEnabled(Object time) {
    return 'DND, $time';
  }

  @override
  String get dndDisabled => 'DND engelli';

  @override
  String get quietHoursActive => 'Sessiz saatler aktif';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Sessiz saatler: $start - $start';
  }

  @override
  String get pushNotificationUfoAlert => 'UFO UFO Uyarı';

  @override
  String get pushNotificationAnomalyAlert => 'Anomaly Alert';

  @override
  String get pushNotificationNearby => 'Nearby';

  @override
  String get pushNotificationInYourArea =>
      'bölgenizde. Ayrıntıları görüntülemek için Tap.';

  @override
  String pushNotificationCommented(Object username) {
    return '$username yorum';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '$username, $username';
  }

  @override
  String get pushNotificationGeneric => 'UFOBeep';

  @override
  String get pushNotificationNewSighting => 'Yakınlarda Yeni Görmek';

  @override
  String get language => 'Dil Dili';

  @override
  String get chooseLanguage => 'Dil seçin';

  @override
  String get units => 'Birimler';

  @override
  String get unitsImperial => 'İmparatorluk (mi, mph)';

  @override
  String get unitsMetric => 'Top (km, km/h)';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsOfUse => 'Kullanım Şartları';

  @override
  String get errorNoLocation =>
      'Konum mevcut değil. Açık gökyüzü görünümü ile tekrar dışarı deneyin.';

  @override
  String get errorNoCamera => 'Kamera bu cihazda mevcut değil.';

  @override
  String get errorUploadFailed =>
      'Yükleme başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get errorPermissionDenied => 'İzin inkar etti.';

  @override
  String get errorInvalidUsername => 'Bu kullanıcı mevcut değildir.';

  @override
  String get nothingToShow => 'Henüz göstermek için hiçbir şey yok.';

  @override
  String get storeShortDesc =>
      'Anında UFO sizi yakınlaştırıyor. Yakalayın, onaylayın ve gerçek zamanlı sohbet edin.';

  @override
  String get storeLongDesc =>
      'UFOBeep, birinin yakınlardaki bir UFO bulduğunda gerçek zamanlı uyarılar gönderir. Fotoğraflar ve videolar yakalayın, bir dokunuş, bakış açısı ve mesafe ile görüş ve diğer gök gözlemcileriyle sohbet edin.';

  @override
  String get keywords =>
      'UFO,UAP,OVNI,aliens,görenler,skywatch,alerts,radar,compass';

  @override
  String get noAlertsFound => 'Eşleşen uyarılar yok';

  @override
  String get alertsFilterHelp =>
      'Daha fazla sonuç görmek için filtrelerinizi ayarlamaya çalışın';

  @override
  String get verified => 'Onaylandı';

  @override
  String get beepOnly => 'Beep Only';

  @override
  String get reportOnly => 'Text Only Text Only Text';

  @override
  String get videoOnly => 'Video Sadece Video';

  @override
  String get imageOnly => 'Resim Sadece Resim';

  @override
  String get mediaOnly => 'Medya Sadece Medya';

  @override
  String get timeJustNow => 'sadece şimdi';

  @override
  String timeDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count saatler önce';
  }

  @override
  String timeMinutesAgo(int count) {
    return '$count dakika önce';
  }

  @override
  String get loadMoreAlerts => 'Load More Alerts';

  @override
  String get toggleMufonTooltip => 'Toggle MUFON görüşüyor';

  @override
  String get showMufonData => 'Show MUFON data';

  @override
  String get hideMufonData => 'Hide MUFON verileri';

  @override
  String get showingUfoBeepOnly => 'Sadece UFOBeep raporlarını göstermek';

  @override
  String get showingAllReports =>
      'MUFON veritabanı dahil tüm raporları göstermek';

  @override
  String get filteredSuffix => 'filtrelenmiş filtre';

  @override
  String get detailsTitle => 'Detaylar';

  @override
  String get mufonCase => 'MUFON Vaka Örneği';

  @override
  String get mufonSighting => 'MUFON Raporu';

  @override
  String get mufonLightSighting => 'MUFON Işık Raporu';

  @override
  String get mufonSphereSighting => 'MUFON Sphere Raporu';

  @override
  String get mufonDiscSighting => 'MUFON Disc Sighting Report';

  @override
  String get mufonTriangleSighting => 'MUFON Üçgen Sighting Report';

  @override
  String get mufonCigarSighting => 'MUFON Cigar Sighting Report';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting Report';

  @override
  String get mufonRectangleSighting => 'MUFON Rectify Sighting Report';

  @override
  String get mufonCylinderSighting => 'MUFON Silindir Sighting Report';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Sighting Report';

  @override
  String get mufonStarlikeSighting => 'MUFON Starlike Sighting Report';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Vaka #$caseNumber Details';
  }

  @override
  String get sightingDate => 'Sighting Date';

  @override
  String get mufonDatabaseEntryDate =>
      'Tarih MUFON\'a girdi Veritabanı Veritabanı';

  @override
  String get databaseEntry => 'Veritabanı';

  @override
  String get shareLink => 'Share Link Link';

  @override
  String get linkCopied => 'Link kopyalandı';

  @override
  String get locationLabel => 'Konum:';

  @override
  String get distanceLabel => 'Mesafe';

  @override
  String get timeLabel => 'Zaman:';

  @override
  String get reportedByLabel => 'Rapora göre';

  @override
  String get unknownLocation => 'Bilinmeyen Konum';

  @override
  String get locationUnknown => 'Konum Bilinmeyen';

  @override
  String get witnessesLabel => 'Tanık Şahitler';

  @override
  String witnessesCountMessage(int count) {
    return '$count insanlar bu görüşü doğruladı';
  }

  @override
  String get photoAnalysisTitle => 'Photo Analysis';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analiz: $count media file(s) processed';
  }

  @override
  String get addMoreMedia =>
      'Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add More Add';

  @override
  String get addMedia => 'Media Add Media';

  @override
  String get retakePhoto => 'Retake Photo';

  @override
  String get retakeVideo => 'Retake Video';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Gallery';

  @override
  String get basicSettings => 'Temel Ayarlar';

  @override
  String get appSettings => 'App Ayarları';

  @override
  String get timeFormat => 'Zaman Biçimi';

  @override
  String get timeFormat24Hour => '24 saat (14:30)';

  @override
  String get timeFormat12Hour => '12 saat (2:30 PM)';

  @override
  String get timeFormatDesc => '24 saat veya 12 saat içinde görüntü zamanı';

  @override
  String get alertRange => 'Alert Range';

  @override
  String get manageNotificationsDesc => 'Aboneliği ve ayarları yönetin';

  @override
  String get permissionsTitle => 'İzinler';

  @override
  String get permissionLocation => 'Konum Location';

  @override
  String get permissionCamera => 'Kamera';

  @override
  String get permissionNotifications => 'Bildirimler';

  @override
  String get permissionPhotos => 'Fotoğraflar';

  @override
  String get permissionGranted => 'Granted';

  @override
  String get permissionNotGranted => 'Verilmedi';

  @override
  String get permissionGrant => 'Grant';

  @override
  String get generateUsername => 'Genrate new user';

  @override
  String get adminTools => 'Admin Tools';

  @override
  String get openAdminPanel => 'Open Admin Panel';

  @override
  String get webAdminInterface => 'Web Admin Interface';

  @override
  String get adminBetaNotice =>
      'Beta sadece inşa eder. Yakın uyarıları test etmek için yönetici araçları, bildirimleri zorlama ve sistem tanıları.';

  @override
  String get whatDoYouSee => 'Ne görüyorsunuz?';

  @override
  String get ufo => 'UFO';

  @override
  String get sighting => 'Sighting';

  @override
  String get ufoSighting => 'UFOBeep UFO Uyarı';

  @override
  String get envAnalysisTitle => 'Çevresel Analiz';

  @override
  String get envAnalysisPending => 'Analiz Pending';

  @override
  String get envAnalysisPendingDesc => 'Çevre verileri bir kez işleme başlar.';

  @override
  String get unknownAircraft => 'Bilinmeyen Uçaklar';

  @override
  String get moreAircraft => 'daha fazla uçak';

  @override
  String get premiumImageryTitle => 'Premium Uydu Imagery';

  @override
  String get premiumImagerySubtitle => 'Yüksek çözünürlüklü ticari imajry';

  @override
  String get sightingTypeLabel => 'Tipi';

  @override
  String get ufoTypeSphere => 'Sphere';

  @override
  String get ufoTypeTriangle => 'Üçgen';

  @override
  String get ufoTypeDisk => 'Disk';

  @override
  String get ufoTypeLight => 'Işık Işığı';

  @override
  String get ufoTypeFireball => 'Fireball';

  @override
  String get ufoTypeCylinder => 'Silindir';

  @override
  String get ufoTypeCigar => 'Cigar';

  @override
  String get ufoTypeRectangle => 'Rect';

  @override
  String get ufoTypeFormation => 'Formasyon';

  @override
  String get ufoTypeUnknown => 'Bilinmeyen';

  @override
  String get ufoTypeBoomerang => 'Boomerang';

  @override
  String get ufoTypeDiamond => 'Elmas';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Cone';

  @override
  String get ufoTypeCross => 'Cross';

  @override
  String get ufoTypeDumbbell => 'Aptal';

  @override
  String get ufoTypeTeardrop => 'Teardrop';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Bülten';

  @override
  String get ufoTypeSaturn => 'Satürn';

  @override
  String get ufoTypeStarLike => 'Star-like';

  @override
  String get ufoTypeBlimp => 'Blimp';

  @override
  String get shapeTriangle => 'üçgen';

  @override
  String get shapeDisc => 'disk';

  @override
  String get shapeDisk => 'disk';

  @override
  String get shapeSphere => 'alanı';

  @override
  String get shapeCigar => 'puro';

  @override
  String get shapeLight => 'ışık ışığı';

  @override
  String get shapeBoomerang => 'boomerang';

  @override
  String get shapeDiamond => 'elmas';

  @override
  String get shapeRectangle => 'yeniden dik';

  @override
  String get shapeOval => 'oval';

  @override
  String get shapeCone => 'cone';

  @override
  String get shapeCross => 'haç';

  @override
  String get shapeCylinder => 'silindir';

  @override
  String get shapeDumbbell => 'aptal';

  @override
  String get shapeTeardrop => 'çığ';

  @override
  String get shapeTicTac => 'tic-tac';

  @override
  String get shapeBullet => 'kurşun mermi';

  @override
  String get shapeSaturn => 'saturn';

  @override
  String get shapeStarlike => 'starlike';

  @override
  String get shapeBlimp => 'blimp';

  @override
  String get shapeFireball => 'fireball';

  @override
  String get shapeFormation => 'formasyon';

  @override
  String get shapeUnknown => 'bilinmeyen';

  @override
  String get actionsTitle => 'Eylemler';

  @override
  String get addPhotosAndVideos => 'Fotoğraflar ve Videolar ekleyin';

  @override
  String get howToReportToMufon => 'MUFON\'a Nasıl Rapor Verilir';

  @override
  String get reportToMufon => 'MUFON\'a Rapor';

  @override
  String get whyReportToMufon => 'Neden MUFON\'a Rapor?';

  @override
  String get openMufonReport => 'Açık MUFON Rapor';

  @override
  String get confirmedWitness => 'Bu manzarayı doğruladın';

  @override
  String witnessesHaveConfirmed(int count) {
    return '$count insanlar bu görüşü doğruladı';
  }

  @override
  String get aircraftTrackingTitle => 'Uçak Takipi';

  @override
  String get weatherConditionsTitle => 'Hava Koşulları';

  @override
  String get noSatellitePasses => 'Görünür bir uydu geçişi bulunamadı';

  @override
  String get contentAnalysisTitle => 'İçerik Analizi';

  @override
  String get contentSafe => 'İçerik güvenlidir';

  @override
  String get contentFlagged => 'Content flagged for review';

  @override
  String get confidenceLabel => 'Güven';

  @override
  String get methodLabel => 'Yöntem Yöntemi';

  @override
  String get premiumImageryAccessOnly =>
      'Premium uydu görüntüsü sadece kullanılabilir:';

  @override
  String get premiumAccessCreators => 'Uyarı yaratıcıları';

  @override
  String get premiumAccessWitnesses =>
      'Görünürlük aralığındaki tanıkları onaylayın';

  @override
  String get comingSoon => 'Yakında Geliyor';

  @override
  String get directionDistanceTitle => 'Yön & Uzaktan';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Vaka #$caseNumber';
  }

  @override
  String get satellitePassesTitle => 'Uydu Passes';

  @override
  String get satellitePassExplanation =>
      'Visible uydu, zaman çerçevesi sırasında geçer. Birçok UFO raporu aslında uydular veya uzay enkazıdır.';

  @override
  String get followingAlert => 'Uyarıyı takiben - bildirimleri alacaksınız';

  @override
  String get unfollowedAlert =>
      'Takip edilemez uyarı - daha fazla yorum bildirim';

  @override
  String get alertFollowError => 'Hata Güncellemesi';

  @override
  String get notificationChannelAlerts => 'UFOBeep Uyarıları';

  @override
  String get notificationChannelAlertsDesc =>
      'UFO arıları ve yakın uyarıları için bildirimler';

  @override
  String get notificationSightingTitle => 'UFOBeep UFO Uyarı';

  @override
  String get notificationSightingUrgent => 'UR URGENT UFOBeep UFO Uyarı';

  @override
  String get notificationSightingEmergency =>
      'EMER EMERGENCY UFOBeep UFO Uyarı';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '$witnessText yakın $locationName';
  }

  @override
  String notificationCommentTitle(String username) {
    return '__ $username yorumlandı';
  }

  @override
  String get notificationWitnessText => 'Yeni görüş';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '$count tanıkları';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1';

  @override
  String get notificationActionDismiss => 'Başarısızlık';

  @override
  String notificationDistance(String distance) {
    return '$distance away';
  }

  @override
  String get unknown => 'bilinmeyen';

  @override
  String get report => 'rapor';

  @override
  String get mufon => 'mufon';

  @override
  String get recentUfoBeepsTitle => 'Recent UFO Arılar';

  @override
  String get recentUfoBeepsSubtitle =>
      'Canlı UFO küresel topluluğumuzdan raporları gözden geçiriyor';

  @override
  String get recentUfoBeepsDescription =>
      'Bu besleme, MUFON veritabanından tarihi raporlarla mobil uygulama kullanıcılarımızdan gerçek zamanlı UFOBeep \"beeps\" birleştirir.';

  @override
  String get loadingBeeps => 'Yükleniyor son beeps...';

  @override
  String get noBeepsAvailable => 'Şu anda mevcut değil.';

  @override
  String get anomalyReported => 'Anomaly bildirildi';

  @override
  String get copyShortLink => 'Kısa bağlantı';

  @override
  String get shareAlert => 'Paylaş';

  @override
  String get ufoSightingAlert => 'UFO UFO Sighting Alert';

  @override
  String get previousPage => 'Önceki';

  @override
  String get nextPage => 'Sonraki';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Sayfa $currentPage of $totalPages ($totalCount total beeps)';
  }

  @override
  String get firstPage => 'First';

  @override
  String get lastPage => 'Son';

  @override
  String get jumpToPage => 'Sayfaya Git';

  @override
  String get heroTagline => 'Dışarı çıkmak ve yukarı bakmak için uyarılar alın';

  @override
  String get heroDescription =>
      'Bölgenizdeki başka bir UFO görüşünü asla kaçırmayın';

  @override
  String get downloadApp => 'Download App';

  @override
  String get viewAllBeeps => 'View All Beeps';

  @override
  String get sightingsMap => 'Sightings Map';

  @override
  String get globalSightingNetwork => 'Global Sighting Network';

  @override
  String get howItWorks => 'Nasıl çalışır';

  @override
  String get backToBeeps => 'Beeps';

  @override
  String get loadingDetails => 'Yükleniyor beep detayları...';

  @override
  String get details => 'Detaylar';

  @override
  String get location => 'Konum Location';

  @override
  String get timeAgo => 'daha önce daha önce daha önce daha önce';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'mil';

  @override
  String get distanceNearby => 'yakın';

  @override
  String get ufobeepWitnesses => 'Tanık Şahitler';

  @override
  String get ufobeepConfirmations => 'Onaylamalar';

  @override
  String get ufobeepAlertLevel => 'Uyarı Düzeyi';

  @override
  String get ufobeepReportType => 'UFOBeep Report';

  @override
  String get mufonAttribution => 'MUFON Veritabanı Raporu';

  @override
  String get mufonCaseNumber => 'Vaka # #';

  @override
  String get mufonGenericTitle => 'MUFON Raporu';

  @override
  String get mufonSphere => 'Sphere';

  @override
  String get mufonLight => 'Işık Işığı';

  @override
  String get mufonDisk => 'Disk';

  @override
  String get mufonTriangle => 'Üçgen';

  @override
  String get mufonCigar => 'Cigar';

  @override
  String get mufonOval => 'Oval';

  @override
  String get mufonCylinder => 'Silindir';

  @override
  String get mufonRectangle => 'Rect';

  @override
  String get mufonDiamond => 'Elmas';

  @override
  String get mufonFireball => 'Fireball';

  @override
  String get mufonFlash => 'Flash';

  @override
  String get mufonFormation => 'Formasyon';

  @override
  String get mufonChanging => 'Değişen';

  @override
  String get mufonChevron => 'Chevron';

  @override
  String get mufonCone => 'Cone';

  @override
  String get mufonCross => 'Cross';

  @override
  String get mufonEgg => 'Yumurta';

  @override
  String get mufonOther => 'Object';

  @override
  String get mufonUnknown => 'Bilinmeyen Object';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON $classification Report';
  }

  @override
  String get nuforcAttribution => 'NUFORC Veritabanı Raporu';

  @override
  String get nuforcCaseNumber => 'Vaka # #';

  @override
  String get nuforcGenericTitle => 'NUFORC Rapor';

  @override
  String get mediaImageNotFound => 'Resim bulunamadı';

  @override
  String get mediaPlayVideo => 'Play Video';

  @override
  String get mediaViewImage => 'View Image View Image';

  @override
  String mediaCount(Object count) {
    return '$count görüntüler';
  }

  @override
  String get mediaCountSingle => '1 resim';

  @override
  String mediaMoreImages(Object count) {
    return '+$count more';
  }

  @override
  String get errorNotFound => 'Arıp bulunamadı';

  @override
  String get errorLoadError => 'Beep detaylarını yüklemek için başarısız oldu';

  @override
  String get shareYourThoughts =>
      'Bu görüş hakkındaki düşüncelerini paylaşın...';

  @override
  String get postComment => 'Post Comment';

  @override
  String get loggedInAs => 'Logged in as as as';

  @override
  String get logout => 'Logout';

  @override
  String get notFollowing => 'Takip Et';

  @override
  String get follow => 'Takip';

  @override
  String get navRecentBeeps => 'Son Arılar';

  @override
  String get navMap => 'Map';

  @override
  String get navDownloadApp => 'Download App';

  @override
  String get alertLevel => 'Uyarı Düzeyi';

  @override
  String get witnesses => 'Tanık Şahitler';

  @override
  String get confirmations => 'Onaylamalar';

  @override
  String get reporterLabel => 'Kullanıcı tarafından rapor edildi';

  @override
  String get coordinatesLabel => 'Koordinatörleri';

  @override
  String get eventTime => 'Event time';

  @override
  String get reportedTime => 'Raporlanmış zaman';

  @override
  String get addedToUfobeep => 'UFOBeep';

  @override
  String get mufonDatabaseReport => 'MUFON Vaka Numarası:';

  @override
  String get copyShortLinkTitle => 'Klip için kopya link';

  @override
  String get imageNotFound => 'Resim bulunamadı';

  @override
  String get ufoSightingAlt => 'UFO UFO Beep UFO uyarısı';

  @override
  String get celestialDataTitle => 'Celestial Objects';

  @override
  String get visiblePlanets => 'Visible Planets';

  @override
  String get locationDataTitle => 'Konum Bilgileri';

  @override
  String get timezone => 'Timezone';

  @override
  String get coordinates => 'Koordinatörleri';

  @override
  String get processingSummaryTitle => 'İşleme Özeti';

  @override
  String get processingTime => 'Zaman İşleme Zamanı';

  @override
  String get successful => 'Başarılı';

  @override
  String get failed => 'Başarısızlık';

  @override
  String get locationEnrichmentTitle => 'Konum Details';

  @override
  String get aircraftDataSource => 'Data Source';

  @override
  String get noAircraftDetected => 'Hiçbir uçak tespit edilmedi';

  @override
  String get sightingReport => 'Rapor';

  @override
  String get ufoAlert => 'UFO UFO Uyarı';

  @override
  String get alert => 'Uyarı';

  @override
  String get notificationTickerUfoAlert => 'UFO Uyarısı - New Sighting Nearby';

  @override
  String get notificationTickerComment => 'UFO Uyarısı Üzerine Yeni Yorum';

  @override
  String get weatherConditions => 'Hava Koşulları';

  @override
  String get visibility => 'Viability';

  @override
  String get humidity => 'Nem';

  @override
  String get pressure => 'Basınç';

  @override
  String get locationDetails => 'Konum Details';

  @override
  String get city => 'Şehir Şehri';

  @override
  String get state => 'Devlet Devleti';

  @override
  String get country => 'Ülke';

  @override
  String get satelliteActivity => 'Uydu Aktivitesi';

  @override
  String get satellitesVisibleOverhead =>
      'Uydular, zamanı ve yeri göz önünde bulunduruyor';

  @override
  String get dataSource => 'Data Source';

  @override
  String get blackskyImagery => 'BlackSky Imagery';

  @override
  String get resolution => 'Karar';

  @override
  String get groundResolution => '35cm zemin çözünürlüğü';

  @override
  String get delivery => 'Teslimat';

  @override
  String get averageDelivery => '90 dakikalık ortalama';

  @override
  String get cost => 'Maliyet';

  @override
  String get skyfiSatelliteImagery => 'SkyFi Uydu Imagery';

  @override
  String get region => 'Bölge Bölgesi';

  @override
  String get remoteArea => 'Uzak Alan';

  @override
  String get startingPrice => 'Starting Price';

  @override
  String get coverage => 'Coverage';

  @override
  String get confidenceCoverage => '% 95 güven';

  @override
  String get status => 'Durum durumu';

  @override
  String get shareThoughts => 'Bu görüş hakkındaki düşüncelerini paylaşın...';

  @override
  String get postCommand => 'Post Komutanlığı';

  @override
  String get clouds => 'Bulutlar';

  @override
  String get windLabel => 'Rüzgar Rüzgar Rüzgarı';

  @override
  String get filterAlerts => 'Filtre Uyarıları';

  @override
  String get alertSource => 'Uyarı Kaynağı';

  @override
  String get ufobeepOnly => 'UFOBeep Only';

  @override
  String get ufobeepOnlyDescription =>
      'Sadece orijinal UFOBeep raporları ( MUFON veritabanı hariç)';

  @override
  String get alertDistanceRange => 'Alert Distance Range';

  @override
  String get showAllAlerts => 'Hepsini göster';

  @override
  String get showAll => 'Hepsini göster';

  @override
  String get distanceSliderDescription =>
      'Uyarıları görmek için ne kadar uzağa ayarlayın. Hava görünürlüğünden başlayarak, mesafeye bakılmaksızın tüm uyarıları göstermek için mesafeye başlayın.';

  @override
  String get applyFilters => 'Uygulamalı Filtreler';

  @override
  String get notificationRange => 'Bildirim Aralığı';

  @override
  String get notificationRangeDescription =>
      'Bu mesafe içinde göz atmak için uyarılar alın';

  @override
  String get viewingRange => 'Viewing Range';

  @override
  String get viewingRangeDescription =>
      'Bu mesafedeki manzaraları göz önüne alındığında';

  @override
  String get weatherVisibility => 'Hava Durumu Viability (~10km)';

  @override
  String get localArea => 'Yerel Alan (25km)';

  @override
  String get regional => 'Bölgesel';

  @override
  String get pushNotifications => 'Push Bildirims';

  @override
  String get alertBrowsing => 'Uyarı Browsing';

  @override
  String get pushAlertsWithinDistance => 'Bu aralıktaki bildirimleri alın';

  @override
  String get showAlertsWhenBrowsing => 'Listede gördüğünüz filtre';

  @override
  String get heroMainTagline =>
      'UFO\'ların yakınlaştığında telefonunuzda bir beep alın';

  @override
  String get heroSecondaryTagline =>
      'Ne zaman ve gökyüzüne bakmak için öğrenin';

  @override
  String get sourceFilters => 'Kaynak Kaynağı';

  @override
  String get sourceFiltersDescription =>
      'Hangi raporların feed\'inizde göründüğünü seçin';

  @override
  String get ufobeepAndMufon => 'UFOBeep + MUFON';

  @override
  String get ufobeepOnlySource => 'UFOBeep sadece';

  @override
  String get mufonOnlySource => 'MUFON sadece';

  @override
  String get browseFilters => 'Göze Göz';

  @override
  String get browseFiltersDescription => 'Nasıl görüntülemek ve tür uyarılar';

  @override
  String get sortByNewest => 'Newest';

  @override
  String get sortByNearest => 'En yakın';

  @override
  String get sortBy => 'Sort by Sort by Sort';

  @override
  String get pushAlertsTitle => 'Push Alerts';

  @override
  String get pushAlertsDescription => 'Telefonunuzu ne yapıyor';

  @override
  String get alertRadius => 'Uyarı Radius';

  @override
  String get mufonNoPushInfo =>
      'MUFON raporları gece ithal edilir ve uyarıları tetiklemezler';

  @override
  String get privacyData => 'Privacy & Data';

  @override
  String get privacyPolicyDesc => 'Verilerinizi nasıl koruyor ve kullanıyoruz';

  @override
  String get termsOfService => 'Hizmet Şartları';

  @override
  String get termsOfServiceDesc => 'Yasal şartlar ve koşullar';

  @override
  String get locationTracking => 'Konum Takip';

  @override
  String get locationTrackingDesc => 'Yakın uyarılar için arka plan yeri';

  @override
  String get locationTrackingTitle => 'Plan Yeri Takip';

  @override
  String get locationTrackingExplanation =>
      'UFOBeep, UFO görüşleriniz şu anki konumunuzun yakınındayken sizi yakın uyarılar göndermek için arka planda izler, hatta evden uzaktayken bile.';

  @override
  String get locationTrackingBattery =>
      'Güvenilir geofencing for Fleming% batarya etkisi için kullanın';

  @override
  String get backgroundLocationTracking => 'Enable arka plan Takip Takip Takip';

  @override
  String get locationTrackingActive => 'Yakın uyarılar için yeri izleyin';

  @override
  String get locationTrackingInactive => 'Konum izleme engellidir';

  @override
  String get locationTrackingDisabledWarning =>
      'Yeni yerlere taşınırken yakın uyarıları almazsınız';

  @override
  String get trackingStatus => 'Takip Durumu';

  @override
  String get monitoringStatus => 'İzleme';

  @override
  String get active => 'Aktif';

  @override
  String get inactive => 'Inaktif';

  @override
  String get lastKnownLocation => 'Son Bilinen Konum';

  @override
  String get lastLocationUpdate => 'Son Güncelleme';

  @override
  String get movementThreshold => 'Hareket Threshold';

  @override
  String get updateFrequency => 'Update Frekansı';

  @override
  String get batteryImpact => 'Battery Etkisi';

  @override
  String get dataPrivacy => 'Data Privacy';

  @override
  String get locationPermissionExplanation =>
      'UFOBeep, hareketinizi izlemek ve yeni konumlarda olduğunuzda yakın uyarıları göndermek için \'Always Allow\' location permission to monitor your move and send close alerts when you\'re in new locations.';

  @override
  String get benefitsTitle => 'Faydaları';

  @override
  String get locationTrackingBenefits =>
      '• • • Seyahat ettiğiniz her yerde UFO uyarıları alın\n• Otomatik konum güncelleştirmeleri\n• • • Hiçbir manuel kurulum gerekli';

  @override
  String get allowLocationAccess => 'Konum Access';

  @override
  String get locationPermissionRequired =>
      'Konum permission is required for background monitoring';

  @override
  String get locationTrackingEnabled => 'Plan yeri izleme etkinleştirdi';

  @override
  String get locationTrackingDisabled => 'Plan yeri takip engelli';

  @override
  String get justNow => 'Sadece şimdi';

  @override
  String minutesAgo(int minutes) {
    return '$minutes dakika önce';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours saatler önce';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get dataManagement => 'Data Management';

  @override
  String get dataManagementDesc => 'İhracat veya hesabınızı sil';

  @override
  String get splashTagline => 'Gerçek zamanlı görüş uyarıları';

  @override
  String get splashStartingUp => 'Başlayın...';

  @override
  String get splashInitializationFailed => 'İlkleşme başarısız oldu';

  @override
  String get splashInitializationFailedTitle => 'İlkleşme Başarısızlık';

  @override
  String get splashInitializationError =>
      'Uygulama düzgün bir şekilde başlamadı:';

  @override
  String get splashRetry => 'Retry';

  @override
  String get splashContinue => 'Devam etmeye devam et';

  @override
  String get splashInitializing => 'Başlangıç...';

  @override
  String signInWelcome(String username) {
    return 'Hoşgeldiniz $username!';
  }

  @override
  String signInFailed(String error) {
    return 'Sign-in başarısız oldu: $error';
  }

  @override
  String get signInPleaseEnterEmail => 'Lütfen e-posta adresinizi girin';

  @override
  String get signInPleaseEnterValidEmail =>
      'Lütfen geçerli bir e-posta adresi girin';

  @override
  String get signInMagicLinkSent =>
      'Sihirli bağlantı gönderildi! E-postanızı kontrol edin ve giriş için bağlantıyı tıklayın.';

  @override
  String get signInMagicLinkFailed =>
      'Büyüyü göndermek için başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get signInAllDataCleared => 'Tüm veriler temizlendi';

  @override
  String get signInSubtitle =>
      'Gerçek zamanlı UFO uyarıları ve MUFON raporları';

  @override
  String get signInGoogleLoading => 'Signing in...';

  @override
  String get signInContinueWithGoogle => 'Google ile devam et';

  @override
  String get signInOr => 'veya';

  @override
  String get signInWithEmail => 'E-posta ile oturum açın';

  @override
  String get signInEmailDescription =>
      'Size işaret etmek için güvenli bir bağlantı göndereceğiz';

  @override
  String get signInEmailAddress => 'E-posta adresi';

  @override
  String get signInEmailPlaceholder => 'your@email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'Tekrar ${seconds}s';
  }

  @override
  String get signInSending => 'Gönder...';

  @override
  String get signInSendMagicLink => 'Magic Link Gönder';

  @override
  String get signInCheckEmail =>
      'E-postanızı kontrol edin! Bağlantı 15 dakika içinde sona erer.';

  @override
  String get signInSecureAuth => 'Güvenli Kimlik';

  @override
  String get signInSecureAuthDescription =>
      'Google Sign-In\'i anlık erişim için veya 15 dakika içinde sonlanan e-posta sihirli bağlantıları kullanın.';

  @override
  String get signInClearAllDataDebug => 'Clear All Data (Debug)';

  @override
  String get emailAuthFailedToSend => 'E-posta göndermek için başarısız oldu';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'E-posta göndermeye başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get emailAuthInvalidEmail =>
      'Invalid e-posta adresi. Lütfen formatı kontrol edin.';

  @override
  String get emailAuthUserNotFound =>
      'Bu e-posta adresi ile hiçbir hesap bulunamadı.';

  @override
  String get emailAuthTooManyRequests =>
      'Çok fazla deneme. Lütfen daha sonra tekrar deneyin.';

  @override
  String get emailAuthOperationNotAllowed =>
      'E-posta link işareti-in etkinleştirilmemektedir.';

  @override
  String get emailAuthQuotaExceeded =>
      'E-posta kotası aştı. Lütfen yarın tekrar deneyin.';

  @override
  String get emailAuthVerificationFailed =>
      'E-posta doğrulama başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get emailAuthTitle => 'E-posta Doğrulama';

  @override
  String get emailAuthVerifyYourEmail => 'E-postanızı onaylayın';

  @override
  String get emailAuthDescription =>
      'Hesap kurtarma ve güvenlik için e-posta adresinizi ekleyin. Size güvenli bir işaret bağlantı göndereceğiz.';

  @override
  String get emailAuthEmailAddress => 'E-posta Adresi';

  @override
  String get emailAuthEmailPlaceholder => 'your.email@ör.com';

  @override
  String get emailAuthPleaseEnterEmail => 'Lütfen e-posta adresinizi girin';

  @override
  String get emailAuthPleaseEnterValidEmail =>
      'Lütfen geçerli bir e-posta adresi girin';

  @override
  String get emailAuthCheckEmailToContinue =>
      'E-postanızı kontrol edin ve devam etmek için doğrulama linkine tıklayın.';

  @override
  String get emailAuthResendEmail => 'E-posta';

  @override
  String get emailAuthSendVerificationEmail =>
      'Verification Gönder E-posta e-posta e-posta';

  @override
  String get emailAuthHowItWorks => 'E-posta Doğrulama Nasıl Çalışır';

  @override
  String get emailAuthHowItWorksSteps =>
      '1. Size güvenli bir işaret gönderiyoruz - bağlantı\n2. E-postanızı kontrol edin ve bağlantıya tıklayın\n3. E-postanız otomatik olarak doğrulanır\n4. Hiçbir şifre gerekli değil!';

  @override
  String get emailAuthSecurityNotice =>
      'E-posta doğrulama hesabınızı güvenceye yardımcı olur ve cihazınıza erişimi kaybederseniz hesabı kurtarma sağlar.';

  @override
  String get phoneAuthFailedToSendCode =>
      'Doğrulama kodunu göndermeye başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get phoneAuthInvalidCodeTryAgain =>
      'Invalid doğrulama kodu. Lütfen tekrar deneyin.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'Telefon numarası doğrulandı: $phoneNumber';
  }

  @override
  String get phoneAuthVerificationFailed =>
      'Telefon doğrulama başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get phoneAuthCodeResent => 'Doğrulama kodu';

  @override
  String get phoneAuthFailedToResendCode =>
      'Kodu geri almak için başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'Invalid telefon numarası. Lütfen formatı kontrol edin.';

  @override
  String get phoneAuthTooManyRequests =>
      'Çok fazla deneme. Lütfen daha sonra tekrar deneyin.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'Invalid doğrulama kodu. Lütfen kontrol edin ve tekrar deneyin.';

  @override
  String get phoneAuthSessionExpired =>
      'Doğrulama seansı sona erdi. Lütfen yeni bir kod talep edin.';

  @override
  String get phoneAuthSmsQuotaExceeded =>
      'SMS kotası aştı. Lütfen yarın tekrar deneyin.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'Bu telefon numarası zaten başka bir hesapla bağlantılıdır.';

  @override
  String get phoneAuthVerificationFailedGeneric =>
      'Doğrulama başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get phoneAuthTitle => 'Telefon Doğrulama';

  @override
  String get phoneAuthVerifyYourPhone => 'Telefonunuzu doğrulayın';

  @override
  String get phoneAuthEnterVerificationCode => 'Verification Kod Kodu';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'Hesap kurtarma ve güvenlik için telefon numaranızı ekleyin';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return '$phoneNumber\'a gönderilen 6 dijital kod girin';
  }

  @override
  String get phoneAuthPhoneNumber => 'Telefon Numarası';

  @override
  String get phoneAuthPhonePlaceholder => '+1 (555) 123-4567';

  @override
  String get phoneAuthPleaseEnterPhone => 'Lütfen telefon numaranıza girin';

  @override
  String get phoneAuthPleaseEnterValidPhone =>
      'Lütfen geçerli bir telefon numarası girin';

  @override
  String get phoneAuthVerificationCode => 'Doğrulama Kodu';

  @override
  String get phoneAuthPleaseEnterSixDigitCode => 'Lütfen 6 dijital kodu girin';

  @override
  String get phoneAuthResendCode => 'Sınırlı Kodu';

  @override
  String get phoneAuthSendVerificationCode => 'Verification Gönder Kod Kodu';

  @override
  String get phoneAuthVerifyCode => 'Verify Code';

  @override
  String get phoneAuthChangePhoneNumber => 'Change Phone Number';

  @override
  String get phoneAuthSmsNotice =>
      'Size SMS aracılığıyla doğrulama kodu göndereceğiz. Standart mesaj oranları uygulanabilir.';

  @override
  String get phoneAuthCodeExpires =>
      'Kod 60 saniye içinde sona erer. Mesajlarınızı kontrol edin.';

  @override
  String get yourDataRights => 'Veri Haklarınız';

  @override
  String get dataRightsExplanation =>
      'Kişisel verileriniz üzerinde tam kontrole sahipsiniz. Tüm verilerinizi ihraç edebilir veya hesabınızı herhangi bir zamanda kalıcı olarak silebilirsiniz.';

  @override
  String get exportYourData => 'Data Your Data';

  @override
  String get exportDataDescription => 'Tüm hesap verilerini indirin';

  @override
  String get exportData => 'İhracat Data';

  @override
  String get exportingData => 'İhracat ...';

  @override
  String get exportDataDetails =>
      'Adds: Profil, beeps, yorum, cihaz bilgisi ve tercihleri. Veriler JSON formatında sağlanır.';

  @override
  String get dataExportedSuccessfully => 'Veriler başarıyla ihraç edilir';

  @override
  String get dataExportFailed => 'Veri ihraç etmek için başarısız oldu';

  @override
  String get deleteAccount => 'Delete Hesabı';

  @override
  String get deleteAccountDescription =>
      'Sürekli olarak hesabınızı ve tüm verileri ortadan kaldırır';

  @override
  String get deleteAccountWarning =>
      'Bu eylem geri alınamaz. Tüm arılar, yorumlar ve hesap verileri kalıcı olarak silinecektir.';

  @override
  String get deleteMyAccount => 'Hesabımı';

  @override
  String get deletingAccount => 'Deleting...';

  @override
  String get deleteAccountConfirmTitle => 'Delete Hesabı';

  @override
  String get deleteAccountConfirmMessage =>
      'Hesabınızı silmek istediğinizden kesinlikle emin misiniz? Bu eylem kalıcıdır ve geri alınamaz.';

  @override
  String get dataWillBeDeleted =>
      'Aşağıdaki veriler kalıcı olarak silinecektir:';

  @override
  String get deletedDataList =>
      '• • • Profiliniz ve kullanıcı adı\n• • • Bütün arılarınız ve raporlarınız\n• • • Tüm yorumlarınız\n• Cihaz kayıt verileri\n• Konum ve tercih verileri';

  @override
  String get deleteAccountPermanent => 'Delete Sürekli';

  @override
  String get accountDeletedSuccessfully => 'Hesap silindi başarıyla';

  @override
  String get accountDeletionFailed => 'Hesabı silmek için başarısız oldu';

  @override
  String get onboardingWelcomeTitle => 'UFOBeep\'e hoş geldiniz';

  @override
  String get onboardingWelcomeBody =>
      'UFO\'ların konumunuzun yakınında görüldüğünde anlık uyarılar alın. Asla tekrar bir görüş kaçırmayın!';

  @override
  String get onboardingReportTitle => 'Bir şey görün? Beep it!';

  @override
  String get onboardingReportBody =>
      'UFO manzaralarının fotoğraflarını ve videolarını yakalayın. Küresel toplulukla anında paylaşın.';

  @override
  String get onboardingCompassTitle => 'Compass ile UFO\'ları bulun';

  @override
  String get onboardingCompassBody =>
      'UFO\'ların tam olarak nerede görüldüğünü görmek için AR compass navigasyonunu kullanın. Telefonunuzu açın ve gidin!';

  @override
  String get onboardingCommunityTitle => 'Topluluka katılın';

  @override
  String get onboardingCommunityBody =>
      'Binlerce gök gözlemcisi ile bağlantı kurun. Profesyonel MUFON verileri ve gerçek zamanlı tartışmalar.';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Başlayın';
}
