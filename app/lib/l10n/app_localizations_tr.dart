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
  String get enablePushNotifications => 'Enable push bildirimleri';

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
  String get noAlertsFound => 'No matching alerts';

  @override
  String get alertsFilterHelp =>
      'Try adjusting your filters to see more results';

  @override
  String get verified => 'Verified';

  @override
  String get beepOnly => 'beep only';

  @override
  String get videoOnly => 'video only';

  @override
  String get imageOnly => 'image only';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String timeMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String get loadMoreAlerts => 'Load More Alerts';

  @override
  String get toggleMufonTooltip => 'Toggle MUFON sightings';

  @override
  String get showMufonData => 'Show MUFON data';

  @override
  String get hideMufonData => 'Hide MUFON data';

  @override
  String get showingUfoBeepOnly => 'Showing only UFOBeep reports';

  @override
  String get showingAllReports =>
      'Showing all reports including MUFON database';

  @override
  String get filteredSuffix => 'filtered';
}
