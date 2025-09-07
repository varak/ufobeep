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
  String get enablePushNotifications => '미래에 대한 알림 받기';

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

  @override
  String get noAlertsFound => '일치하는 경고 없음';

  @override
  String get alertsFilterHelp => '필터를 조정하여 더 많은 결과를 볼 수 있습니다';

  @override
  String get verified => '인증 및 인증';

  @override
  String get beepOnly => '뚱 베어';

  @override
  String get videoOnly => '비디오 만';

  @override
  String get imageOnly => '이미지 만';

  @override
  String get timeJustNow => '지금 시작';

  @override
  String timeDaysAgo(int count) {
    return '${count}d 전';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h 전';
  }

  @override
  String timeMinutesAgo(int count) {
    return '${count}m 전';
  }

  @override
  String get loadMoreAlerts => '더 많은 경고';

  @override
  String get toggleMufonTooltip => '사이트 맵';

  @override
  String get showMufonData => 'MUFON 자료 보기';

  @override
  String get hideMufonData => 'MUFON 데이터 숨기기';

  @override
  String get showingUfoBeepOnly => 'UFOBeep 보고';

  @override
  String get showingAllReports => 'MUFON 데이터베이스를 포함한 모든 보고서보기';

  @override
  String get filteredSuffix => '필터링';

  @override
  String get detailsTitle => '제품 정보';

  @override
  String get mufonCase => '사이트맵 제품정보';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return '사이트맵 케이스 #$caseNumber 세부 사항';
  }

  @override
  String get sightingDate => '관련 기사';

  @override
  String get mufonDatabaseEntryDate => '날짜 입력 MUFON 관련 기사';

  @override
  String get databaseEntry => '데이터베이스';

  @override
  String get shareLink => '공유 링크';

  @override
  String get linkCopied => '클립보드에 복사 링크';

  @override
  String get locationLabel => '- 연혁';

  @override
  String get distanceLabel => '주요 특징';

  @override
  String get timeLabel => '(주)';

  @override
  String get reportedByLabel => '관련 기사';

  @override
  String get unknownLocation => '자주 묻는 질문';

  @override
  String get locationUnknown => '위치 Unknown';

  @override
  String get witnessesLabel => '뚱 베어';

  @override
  String witnessesCountMessage(int count) {
    return '$count 사람들이 이 광경을 확인';
  }

  @override
  String get photoAnalysisTitle => '사진 분석';

  @override
  String mediaItemsProcessed(int count) {
    return '분석: $count 미디어 파일 처리';
  }

  @override
  String get addMoreMedia => '더 보기';

  @override
  String get addMedia => '미디어 추가';

  @override
  String get retakePhoto => 'Retake 사진';

  @override
  String get retakeVideo => 'Retake 비디오';

  @override
  String get camera => '관련 기사';

  @override
  String get gallery => '회사연혁';

  @override
  String get basicSettings => '기본 설정';

  @override
  String get appSettings => '앱 설정';

  @override
  String get alertRange => 'Alert 범위';

  @override
  String get manageNotificationsDesc => '구독 및 설정 관리';

  @override
  String get permissionsTitle => '제출';

  @override
  String get permissionLocation => '- 연혁';

  @override
  String get permissionCamera => '관련 기사';

  @override
  String get permissionNotifications => '공지사항';

  @override
  String get permissionPhotos => '사진 갤러리';

  @override
  String get permissionGranted => '지원하다';

  @override
  String get permissionNotGranted => '이름 *';

  @override
  String get permissionGrant => '지원하다';

  @override
  String get generateUsername => '새로운 사용자 정의';

  @override
  String get adminTools => '관리자 도구';

  @override
  String get openAdminPanel => 'Open Admin 패널';

  @override
  String get webAdminInterface => '웹 관리자 인터페이스';

  @override
  String get adminBetaNotice => '베타 빌드 만. 테스트 근접 경고, 푸시 알림 및 시스템 진단을위한 관리자 도구.';

  @override
  String get whatDoYouSee => '무엇을 볼까요?';

  @override
  String get ufoSighting => '사이트맵 뚱 베어';

  @override
  String get envAnalysisTitle => '환경분석';

  @override
  String get envAnalysisPending => '분석 Pending';

  @override
  String get envAnalysisPendingDesc => '환경 데이터는 한 번 처리가 시작됩니다.';

  @override
  String get unknownAircraft => '알 수없는 항공기';

  @override
  String get moreAircraft => '더 많은 항공기';

  @override
  String get premiumImageryTitle => '프리미엄 위성 이미지';

  @override
  String get premiumImagerySubtitle => '고해상도 상업 이미지';

  @override
  String get sightingTypeLabel => '제품정보';

  @override
  String get ufoTypeSphere => '사이트 맵';

  @override
  String get ufoTypeTriangle => '연락처';

  @override
  String get ufoTypeDisk => '제품정보';

  @override
  String get ufoTypeLight => '제품 정보';

  @override
  String get ufoTypeFireball => '불꽃놀이';

  @override
  String get ufoTypeCylinder => '자료실';

  @override
  String get ufoTypeCigar => '시가';

  @override
  String get ufoTypeRectangle => '관련 상품';

  @override
  String get ufoTypeFormation => '이름 *';

  @override
  String get ufoTypeUnknown => '이름 *';

  @override
  String get ufoTypeBoomerang => '프로모션';

  @override
  String get ufoTypeDiamond => '담당자: Ms';

  @override
  String get ufoTypeOval => '오벌';

  @override
  String get ufoTypeCone => '한국어';

  @override
  String get ufoTypeCross => '기타';

  @override
  String get ufoTypeDumbbell => '카테고리';

  @override
  String get ufoTypeTeardrop => '옵션 정보';

  @override
  String get ufoTypeTicTac => '카테고리';

  @override
  String get ufoTypeBullet => '주요연혁';

  @override
  String get ufoTypeSaturn => '인기 카테고리';

  @override
  String get ufoTypeStarLike => '이름 *';

  @override
  String get ufoTypeBlimp => '뚱 베어';

  @override
  String get actionsTitle => '팟캐스트';

  @override
  String get addPhotosAndVideos => '사진 및 동영상 추가';

  @override
  String get howToReportToMufon => 'MUFON에 보고하는 방법';

  @override
  String get reportToMufon => 'MUFON 소개';

  @override
  String get whyReportToMufon => '왜 MUFON에 보고?';

  @override
  String get openMufonReport => 'MUFON 오픈 제품정보';

  @override
  String get confirmedWitness => '이 광경을 확인';

  @override
  String witnessesHaveConfirmed(int count) {
    return '$count 사람들은 이 광경을 확인했습니다';
  }

  @override
  String get aircraftTrackingTitle => '항공기 추적';

  @override
  String get weatherConditionsTitle => '기상 조건';

  @override
  String get noSatellitePasses => '눈에 보이는 위성 패스 발견';

  @override
  String get contentAnalysisTitle => '콘텐츠 분석';

  @override
  String get contentSafe => '내용은 안전합니다';

  @override
  String get contentFlagged => 'Content flagged 에 대한 리뷰';

  @override
  String get confidenceLabel => '지원하다';

  @override
  String get methodLabel => '제품 설명';

  @override
  String get premiumImageryAccessOnly => '프리미엄 위성 이미지는 오직 사용할 수 있습니다:';

  @override
  String get premiumAccessCreators => 'Alert 제작자';

  @override
  String get premiumAccessWitnesses => '가시 범위 내에서 확인된 증언';

  @override
  String get comingSoon => '현재 위치';

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
}
