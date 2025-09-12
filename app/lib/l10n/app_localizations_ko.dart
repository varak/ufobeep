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
    return '$distance';
  }

  @override
  String alertDirection(int bearing) {
    return '방위 $bearing°';
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
  String beepSentWithUrl(String shortUrl) {
    return 'Beep는 성공적으로 보냈습니다';
  }

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
    return '작성자: $username';
  }

  @override
  String reportedAt(String timeAgo, Object time) {
    return '로그인 ';
  }

  @override
  String distanceAway(String distance) {
    return '뚱 베어';
  }

  @override
  String bearingToObject(int bearing) {
    return '물체에 베어링 : $bearing °';
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
  String get noCommentsYet => '아직 댓글이 없습니다. 댓글을 첫번째로!';

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
    return '에 대한 지적';
  }

  @override
  String get calibratingCompass => '캘리브레이션';

  @override
  String get openAROverlay => 'AR 오버레이를 엽니다';

  @override
  String get pushTitleAlertNearby => '당신 가까이에 UFO 경고';

  @override
  String pushBodyAlertNearby(String distance) {
    return '새로운 광경은 를보고했다.';
  }

  @override
  String get pushTitleComment => '새로운 의견';

  @override
  String get pushBodyComment => '누군가가 당신을 따르는 광경에 언급했다.';

  @override
  String get pushTitleWitness => 'Witness 확인';

  @override
  String get temperature => '제품 정보';

  @override
  String get pushBodyWitness => '사용자가 동일한 객체를 확인합니다.';

  @override
  String get weather => '날씨 예보';

  @override
  String cloudCover(int percent) {
    return '클라우드 커버: %';
  }

  @override
  String wind(num speed, String unit) {
    return '바람:';
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
  String get beepOnly => '계정 관리';

  @override
  String get reportOnly => '계정 관리';

  @override
  String get videoOnly => '비디오 만';

  @override
  String get imageOnly => '이미지 만';

  @override
  String get timeJustNow => '지금 시작';

  @override
  String timeDaysAgo(int count) {
    return 'd 전';
  }

  @override
  String timeHoursAgo(int count) {
    return 'h 전';
  }

  @override
  String timeMinutesAgo(int count) {
    return 'm 전';
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
    return '사이트맵 사례 # 세부 정보';
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
  String get locationLabel => '위치:';

  @override
  String get distanceLabel => '주요 특징';

  @override
  String get timeLabel => '시간:';

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
    return '사람들은이 광경을 확인';
  }

  @override
  String get photoAnalysisTitle => '사진 분석';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analysis:  미디어 파일 처리';
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
  String get ufo => '사이트맵';

  @override
  String get sighting => '뚱 베어';

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
  String get shapeTriangle => '팟캐스트';

  @override
  String get shapeDisc => '·';

  @override
  String get shapeDisk => '기본 정보';

  @override
  String get shapeSphere => '강좌';

  @override
  String get shapeCigar => '시가';

  @override
  String get shapeLight => '제품 정보';

  @override
  String get shapeBoomerang => '채용정보';

  @override
  String get shapeDiamond => '다이아몬드';

  @override
  String get shapeRectangle => '연락처';

  @override
  String get shapeOval => '이름 *';

  @override
  String get shapeCone => '제품 정보';

  @override
  String get shapeCross => '기타';

  @override
  String get shapeCylinder => '자료실';

  @override
  String get shapeDumbbell => '뚱 베어';

  @override
  String get shapeTeardrop => '눈물방울';

  @override
  String get shapeTicTac => '사이트맵';

  @override
  String get shapeBullet => '주요특징';

  @override
  String get shapeSaturn => '인기있는';

  @override
  String get shapeStarlike => '이름 *';

  @override
  String get shapeBlimp => '뚱 베어';

  @override
  String get shapeFireball => '풋볼';

  @override
  String get shapeFormation => '주요연혁';

  @override
  String get shapeUnknown => '이름 *';

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
    return '사람들은이 광경을 확인했습니다';
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
  String get directionDistanceTitle => '방향 & 거리';

  @override
  String mufonCaseTitle(String caseNumber) {
    return '사이트맵 케이스 #';
  }

  @override
  String get satellitePassesTitle => '위성 패스';

  @override
  String get satellitePassExplanation =>
      '눈에 띄는 위성은 광경 시간대에 통과합니다. 많은 UFO 보고서는 실제로 위성 또는 공간 파편입니다.';

  @override
  String get followingAlert => '경고 후 - 당신은 코멘트 알림을 얻을 것이다';

  @override
  String get unfollowedAlert => '경고 없음 - 더 많은 의견 알림';

  @override
  String get alertFollowError => '에러 updating 따라 상태';

  @override
  String get notificationChannelAlerts => 'UFOBeep 경고';

  @override
  String get notificationChannelAlertsDesc => 'UFO beeps 및 근접 경고에 대한 알림';

  @override
  String get notificationSightingTitle => '사이트맵 뚱 베어';

  @override
  String get notificationSightingUrgent => '⚠️ 유벤트 UFO 뚱 베어';

  @override
  String get notificationSightingEmergency => '∙ 에너지 UFO 뚱 베어';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '닫기 이름 *';
  }

  @override
  String notificationCommentTitle(String username) {
    return '$username 댓글';
  }

  @override
  String get notificationWitnessText => '새로운 광경';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '이름 *';
  }

  @override
  String get notificationActionSnooze => '스누즈 1시간';

  @override
  String get notificationActionDismiss => '뚱 베어';

  @override
  String notificationDistance(String distance) {
    return '';
  }

  @override
  String get unknown => '이름 *';

  @override
  String get report => '이름 *';

  @override
  String get mufon => '사이트맵';

  @override
  String get recentUfoBeepsTitle => '최근 UFO 뚱 베어';

  @override
  String get recentUfoBeepsSubtitle => '라이브 UFOBeep 커뮤니티 보고서 & MUFON 데이터베이스 광경';

  @override
  String get recentUfoBeepsDescription =>
      '이 피드는 실시간 UFOBeep \"beeps\"를 결합하여 모바일 앱 사용자는 MUFON 데이터베이스의 과거 보고서를 보여줍니다.';

  @override
  String get loadingBeeps => '최근 beeps을로드 ...';

  @override
  String get noBeepsAvailable => '순간에 사용할 수 없습니다.';

  @override
  String get anomalyReported => 'Anomaly 보고';

  @override
  String get copyShortLink => '짧은 링크 복사';

  @override
  String get shareAlert => '비밀번호';

  @override
  String get previousPage => '이름 *';

  @override
  String get nextPage => '이름 *';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return '페이지  의  ( 총 금액)';
  }

  @override
  String get heroTagline => '외부로 이동할 때 경고를 얻고 봐';

  @override
  String get heroDescription =>
      '다른 UFO 보행을 놓치지 마십시오. 누군가가 하늘에서 이상한 것을 볼 때 실시간 경고를 가져옵니다. 휴대폰을 끄고 정확히 어디에서 볼 수 있습니다.';

  @override
  String get downloadApp => '앱 다운로드';

  @override
  String get viewAllBeeps => ' All 모두 Beeps';

  @override
  String get sightingsMap => 'Sightings 지도';

  @override
  String get globalSightingNetwork => '글로벌 Sighting Network';

  @override
  String get howItWorks => 'UFOBeep 작동 방법';

  @override
  String get backToBeeps => 'Beeps로 돌아가기';

  @override
  String get loadingDetails => '로딩...';

  @override
  String get details => '제품 정보';

  @override
  String get location => '- 연혁';

  @override
  String get timeAgo => '...에서';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => '24시간';

  @override
  String get distanceMiles => '여행 정보';

  @override
  String get distanceNearby => '이름 *';

  @override
  String get ufobeepWitnesses => '뚱 베어';

  @override
  String get ufobeepConfirmations => '이름 *';

  @override
  String get ufobeepAlertLevel => '출력 레벨';

  @override
  String get ufobeepReportType => 'UFOBeep 보고서';

  @override
  String get mufonAttribution => '사이트맵 Database 보고';

  @override
  String get mufonCaseNumber => '사례 #';

  @override
  String get mufonGenericTitle => 'MUFON Sighting 보고서';

  @override
  String get mufonSphere => '사이트 맵';

  @override
  String get mufonLight => '제품 정보';

  @override
  String get mufonDisk => '제품정보';

  @override
  String get mufonTriangle => '연락처';

  @override
  String get mufonCigar => '시가';

  @override
  String get mufonOval => '오벌';

  @override
  String get mufonCylinder => '자료실';

  @override
  String get mufonRectangle => '관련 상품';

  @override
  String get mufonDiamond => '담당자: Ms';

  @override
  String get mufonFireball => '불꽃놀이';

  @override
  String get mufonFlash => '이름 *';

  @override
  String get mufonFormation => '이름 *';

  @override
  String get mufonChanging => '관련 기사';

  @override
  String get mufonChevron => '체브론';

  @override
  String get mufonCone => '한국어';

  @override
  String get mufonCross => '기타';

  @override
  String get mufonEgg => '계란';

  @override
  String get mufonOther => '기타';

  @override
  String get mufonUnknown => 'Unknown 개체';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON 예제 제품정보';
  }

  @override
  String get nuforcAttribution => '사이트맵 Database 보고';

  @override
  String get nuforcCaseNumber => '사례 #';

  @override
  String get nuforcGenericTitle => '사이트맵 연락처';

  @override
  String get mediaImageNotFound => '찾을 수 없음';

  @override
  String get mediaPlayVideo => '재생 동영상';

  @override
  String get mediaViewImage => '이미지 보기';

  @override
  String mediaCount(Object count) {
    return '이미지';
  }

  @override
  String get mediaCountSingle => '1 이미지';

  @override
  String mediaMoreImages(Object count) {
    return '+ 더보기';
  }

  @override
  String get errorNotFound => '찾을 수 없음';

  @override
  String get errorLoadError => 'Beep 세부사항을 적재하는 실패';

  @override
  String get shareYourThoughts => '이 광경에 대한 생각을 공유 ...';

  @override
  String get postComment => '게시물 댓글';

  @override
  String get loggedInAs => '로그인';

  @override
  String get logout => '로그아웃';

  @override
  String get notFollowing => '이름 *';

  @override
  String get follow => '이름 *';

  @override
  String get navRecentBeeps => '최근 Beeps';

  @override
  String get navMap => '지도보기';

  @override
  String get navDownloadApp => '앱 다운로드';

  @override
  String get alertLevel => '출력 레벨';

  @override
  String get witnesses => '뚱 베어';

  @override
  String get confirmations => '이름 *';

  @override
  String get reporterLabel => '로그인';

  @override
  String get coordinatesLabel => '관련 기사';

  @override
  String get eventTime => '이벤트 시간';

  @override
  String get reportedTime => '접수시간';

  @override
  String get mufonDatabaseReport => '사이트맵 Database 보고';

  @override
  String get copyShortLinkTitle => '클립보드에 링크 복사';

  @override
  String get imageNotFound => '찾을 수 없음';

  @override
  String get ufoSightingAlt => 'UFO 광경';
}
