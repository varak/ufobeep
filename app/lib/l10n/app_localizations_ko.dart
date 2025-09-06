// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'UFO버프';

  @override
  String get ok => '이름 *';

  @override
  String get cancel => '이름 *';

  @override
  String get close => '이름 *';

  @override
  String get save => '제품 정보';

  @override
  String get delete => '이름 *';

  @override
  String get edit => '제품정보';

  @override
  String get retry => '이름 *';

  @override
  String get yes => '이름 *';

  @override
  String get no => '이름 *';

  @override
  String get back => '이름 *';

  @override
  String get next => '이름 *';

  @override
  String get done => '이름 *';

  @override
  String get loading => '로드 중 ..';

  @override
  String get processing => '기타..';

  @override
  String get errorGeneric => '뭔가 잘못되었습니다.';

  @override
  String get networkError => '네트워크 오류. 연결 확인.';

  @override
  String get permissionsRequired => '제출';

  @override
  String get learnMore => '더 알아보기';

  @override
  String get welcomeTitle => 'UFOBeep에 오신 것을 환영합니다';

  @override
  String get welcomeSubtitle => '실시간 UFO 알림';

  @override
  String get signIn => '이름 *';

  @override
  String get signOut => '이름 *';

  @override
  String get continueAsGuest => '이용 안내';

  @override
  String get enterUsername => '사용자 이름';

  @override
  String get username => '사용자 이름';

  @override
  String get usernameUpdated => '사용자 이름 업데이트';

  @override
  String get profile => '제품정보';

  @override
  String get settings => '지원하다';

  @override
  String get tabAlerts => '지원하다';

  @override
  String get tabBeep => '뚱 베어';

  @override
  String get tabChat => '이름 *';

  @override
  String get tabMap => '지도보기';

  @override
  String get tabSettings => '지원하다';

  @override
  String get alertsTitle => '근처 Alerts';

  @override
  String get noAlerts => '아직 경고가 없습니다.';

  @override
  String get pullToRefresh => '새로 고침';

  @override
  String alertDistance(String distance) {
    return '$distance 멀리';
  }

  @override
  String alertDirection(int bearing) {
    return '베어링 $bearing°';
  }

  @override
  String get viewAlert => '공지사항';

  @override
  String get viewOnMap => '지도 보기';

  @override
  String get iSeeItToo => '나는 그것을 본다';

  @override
  String get confirmWitnessed => '당신은이 광경을 목격?';

  @override
  String get witnessConfirmed => '감사합니다 - 확인이 게시되었습니다.';

  @override
  String get createBeepTitle => 'Beep을 보내기';

  @override
  String get beepExplain => '당신이 볼 수있는 캡처 및 가까운 watchers에 경고.';

  @override
  String get capturePhoto => '캡처 사진';

  @override
  String get captureVideo => '캡처 동영상';

  @override
  String get pickFromGallery => '갤러리에서 선택';

  @override
  String get descriptionHint => '당신이 하늘에서 본 것을 설명 ..';

  @override
  String get submitBeep => '공지사항';

  @override
  String get beepSent => 'Beep 전송';

  @override
  String get uploadingMedia => '미디어 업로드 ..';

  @override
  String get includeLocation => '위치 포함';

  @override
  String get includeTimestamp => '타임스탬프 포함';

  @override
  String get beepFailed => 'Beep을 보낼 실패.';

  @override
  String get mediaProcessing => '처리 미디어 ..';

  @override
  String get cameraPermissionTitle => '관련 동영상';

  @override
  String get cameraPermissionBody => 'UFO 사진 및 비디오를 캡처 할 수있는 Grant 카메라 액세스.';

  @override
  String get locationPermissionTitle => '오시는 길';

  @override
  String get locationPermissionBody => '자주 묻는 질문.';

  @override
  String get microphonePermissionTitle => '마이크 액세스 필요';

  @override
  String get microphonePermissionBody => '비디오 캡처에 대한 Grant 마이크 액세스.';

  @override
  String get openSettings => '설정 열기';

  @override
  String get alertDetailTitle => '연락처';

  @override
  String reportedBy(String username) {
    return '$username에 의해 신고';
  }

  @override
  String reportedAt(String timeAgo) {
    return '$timeAgo를 보고';
  }

  @override
  String distanceAway(String distance) {
    return '$distance 멀리';
  }

  @override
  String bearingToObject(int bearing) {
    return '목표에 방위: ₢ 킹';
  }

  @override
  String get openCompass => '열린 compass';

  @override
  String get openAR => 'AR 오버레이를 엽니다';

  @override
  String get openChat => '채팅 열기';

  @override
  String get commentsTitle => '이름 *';

  @override
  String get addComment => '자주 묻는 질문';

  @override
  String get send => '지원하다';

  @override
  String get commentPosted => '댓글 게시';

  @override
  String get autoFollowEnabled => '이 경고를 따르십시오.';

  @override
  String get noCommentsYet => '아직 댓글이 없습니다. 처음!';

  @override
  String get newCommentNotification => '당신을 따르는 광경에 새로운 의견.';

  @override
  String get mapTitle => '본문 바로가기';

  @override
  String get compassTitle => '한국어';

  @override
  String get compassSettings => 'Compass 설정';

  @override
  String get compassMode => 'Compass 형태';

  @override
  String get compassStandardMode => '표준 형태';

  @override
  String get compassPilotMode => '파일 형식';

  @override
  String get compassStandardDescription => '기본 제목 및 탐색';

  @override
  String get compassPilotDescription => 'ETA 및 벡터로 고급 항법';

  @override
  String pointingTo(String direction) {
    return '$direction에 포팅';
  }

  @override
  String get calibratingCompass => '캘리브레이션';

  @override
  String get openAROverlay => 'AR 오버레이를 엽니다';

  @override
  String get pushTitleAlertNearby => '당신 가까이에 UFO 경고';

  @override
  String pushBodyAlertNearby(String distance) {
    return '새로운 광경은 $distance를 나타냈습니다.';
  }

  @override
  String get pushTitleComment => '새로운 의견';

  @override
  String get pushBodyComment => '누군가가 당신을 따르는 광경에 언급했다.';

  @override
  String get pushTitleWitness => 'Witness 확인';

  @override
  String get pushBodyWitness => '사용자가 동일한 객체를 확인합니다.';

  @override
  String get weather => '날씨 예보';

  @override
  String cloudCover(int percent) {
    return '구름 덮개: ₢ 킹';
  }

  @override
  String wind(num speed, String unit) {
    return '바람: $speed $unit';
  }

  @override
  String get nearbyAircraft => '인근 항공기';

  @override
  String get noAircraft => '인근 항공기 없음';

  @override
  String get loadingContext => '환경 컨텍스트를로드 ..';

  @override
  String get settingsTitle => '지원하다';

  @override
  String get notifications => '공지사항';

  @override
  String get enablePushNotifications => '푸시 알림 활성화';

  @override
  String get quietHours => '영업시간';

  @override
  String get quietHoursDesc => '선택된 시간 사이에 침묵 경고.';

  @override
  String get dndMode => '뚱 베어';

  @override
  String get dndUntil => '할 수 없습니다';

  @override
  String get language => '* 이름';

  @override
  String get chooseLanguage => '한국어';

  @override
  String get units => '제품정보';

  @override
  String get unitsImperial => '제국 (미, mph)';

  @override
  String get unitsMetric => '미터 (km, km/h)';

  @override
  String get privacyPolicy => '회사 소개';

  @override
  String get termsOfUse => '이용 약관';

  @override
  String get errorNoLocation => '자주 묻는 질문 맑은 하늘 전망과 함께 다시 시도하십시오.';

  @override
  String get errorNoCamera => '이 장치에서 사용할 수없는 카메라.';

  @override
  String get errorUploadFailed => '업로드 실패. 다시 시도하십시오.';

  @override
  String get errorPermissionDenied => '권한이 없습니다.';

  @override
  String get errorInvalidUsername => '그 사용자 이름은 사용할 수 없습니다.';

  @override
  String get nothingToShow => '아직 표시되지 않았습니다.';

  @override
  String get storeShortDesc => '즉시 UFO 알림. 캡처, 확인 및 실시간 채팅.';

  @override
  String get storeLongDesc =>
      'UFOBeep은 누군가가 UFO를 가까이 두고 있을 때 실시간 알림을 보냅니다. 캡처 사진 및 동영상, 탭으로 시력 확인, 방향 및 거리보기, 동료 skywatchers와 채팅.';

  @override
  String get keywords =>
      'UFO, UAP, OVNI의 aliens의 sightings,skywatch, 경보, 레이더, 우회';
}
