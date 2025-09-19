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
  String get locationPermissionTitle => 'Konum access needed needed needed';

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
    return 'uzaktan uzakta';
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
      'Asla başka bir UFO görüşünü kaçırmayın. Yakınınızdaki biri gökyüzünde garip bir şey gördüğünde gerçek zamanlı uyarılar alın. Telefonunuzu işaret edin ve tam olarak nereye bakacağınızı bulun.';

  @override
  String get downloadApp => 'Download App';

  @override
  String get viewAllBeeps => 'View All Beeps';

  @override
  String get sightingsMap => 'Sightings Map';

  @override
  String get globalSightingNetwork => 'Global Sighting Network';

  @override
  String get howItWorks => 'UFOBeep Nasıl Çalışıyor';

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
  String get mufonDatabaseReport => 'MUFON Veritabanı Raporu';

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
}
