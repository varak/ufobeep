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
    return '$distance away';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Nesneye bakın: $bearing°';
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
  String get noCommentsYet => 'Henüz yorum yok. İlk ol!';

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
  String get dndMode => 'Yapmayın';

  @override
  String get dndUntil => 'Ne kadar rahatsız etmeyin';

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
  String get beepOnly => 'beep sadece';

  @override
  String get videoOnly => 'video sadece video';

  @override
  String get imageOnly => 'sadece görüntü sadece görüntü';

  @override
  String get timeJustNow => 'Sadece şimdi';

  @override
  String timeDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h önce';
  }

  @override
  String timeMinutesAgo(int count) {
    return '${count}m ago';
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
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Case #$caseNumber Details';
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
  String get locationLabel => 'Konum Location';

  @override
  String get distanceLabel => 'Mesafe';

  @override
  String get timeLabel => 'Zaman Zamanı';

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
    return '$count insanlar bu manzarayı doğruladı';
  }

  @override
  String get photoAnalysisTitle => 'Photo Analysis';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analiz: $count medya dosyası (s) işlendi';
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
  String get ufoSighting => 'UFO UFO Sighting';

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
    return '$count insanlar bu manzarayı doğruladı';
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
}
