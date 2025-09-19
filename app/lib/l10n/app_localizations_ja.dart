// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'UFOビープ';

  @override
  String get ok => 'お問い合わせ';

  @override
  String get cancel => 'キャンセル';

  @override
  String get close => 'ふりがな';

  @override
  String get save => '保存する';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get retry => 'リトリート';

  @override
  String get yes => 'お問い合わせ';

  @override
  String get no => 'なし';

  @override
  String get back => 'バックナンバー';

  @override
  String get next => '次へ';

  @override
  String get done => 'ログイン';

  @override
  String get loading => 'ローディング..';

  @override
  String get processing => '加工..';

  @override
  String get errorGeneric => '何かが間違っていた.';

  @override
  String get networkError => 'ネットワークエラー。 接続を確認してください.';

  @override
  String get permissionsRequired => '必要な許可';

  @override
  String get learnMore => 'もっと詳しく';

  @override
  String get welcomeTitle => 'UFOBeepへようこそ';

  @override
  String get welcomeSubtitle => '近くのリアルタイム UFO アラート';

  @override
  String get signIn => 'サインイン';

  @override
  String get signOut => 'サインアップ';

  @override
  String get continueAsGuest => 'ゲストとして';

  @override
  String get enterUsername => 'ユーザー名を入力してください';

  @override
  String get username => 'ユーザ名';

  @override
  String get usernameUpdated => '更新されたユーザー名';

  @override
  String get profile => 'プロフィール';

  @override
  String get settings => 'コンテンツ';

  @override
  String get tabAlerts => 'アラート';

  @override
  String get tabBeep => 'ビープ';

  @override
  String get tabChat => 'チャット';

  @override
  String get tabMap => 'サイトマップ';

  @override
  String get tabSettings => 'コンテンツ';

  @override
  String get alertsTitle => '近くのアラート';

  @override
  String get noAlerts => '近隣のアラートはありません.';

  @override
  String get pullToRefresh => 'リフレッシュするプル';

  @override
  String alertDistance(String distance) {
    return '__PLACEHOLDER_0_ 離れて';
  }

  @override
  String alertDirection(int bearing) {
    return '軸受け_PLACEHOLDER_0__°';
  }

  @override
  String get viewAlert => 'アラートを見る';

  @override
  String get viewOnMap => 'サイトマップ';

  @override
  String get iSeeItToo => '見てみる';

  @override
  String get confirmWitnessed => '目撃したことを確認しますか?';

  @override
  String get witnessConfirmed => 'ありがとうございます.';

  @override
  String get createBeepTitle => 'ビープを送る';

  @override
  String get beepExplain => '近く見ているものをキャプチャし、近くの監視者に警告します.';

  @override
  String get capturePhoto => '写真のキャプチャ';

  @override
  String get captureVideo => 'ビデオのキャプチャ';

  @override
  String get pickFromGallery => 'ギャラリーから選ぶ';

  @override
  String get descriptionHint => '空を眺めているものを記述する..';

  @override
  String get submitBeep => 'ビープを送る';

  @override
  String get beepSent => 'フィードバック';

  @override
  String beepSentWithUrl(String shortUrl) {
    return '首尾よく送られるビープ';
  }

  @override
  String get uploadingMedia => 'メディアのアップロード..';

  @override
  String get includeLocation => '場所を含んで下さい';

  @override
  String get includeTimestamp => 'タイムスタンプを含める';

  @override
  String get beepFailed => 'ビープを送ることができません.';

  @override
  String get mediaProcessing => '加工媒体..';

  @override
  String get cameraPermissionTitle => '必要なカメラアクセス';

  @override
  String get cameraPermissionBody => 'UFO の写真やビデオをキャプチャするためのカメラアクセスを許可します.';

  @override
  String get locationPermissionTitle => '必要な場所へのアクセス';

  @override
  String get locationPermissionBody => '近隣のアラートを送受信する場所を使用します.';

  @override
  String get microphonePermissionTitle => '必要なマイクアクセス';

  @override
  String get microphonePermissionBody => 'ビデオキャプチャ用のマイクアクセスを音声で付与します.';

  @override
  String get openSettings => 'オープン設定';

  @override
  String get alertDetailTitle => '観光スポット詳細';

  @override
  String reportedBy(String username) {
    return '$username による報告';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'レポート ${timeAgo}_';
  }

  @override
  String distanceAway(String distance) {
    return 'ふりがな';
  }

  @override
  String bearingToObject(int bearing) {
    return 'オブジェクトへのベアリング:_PLACEHOLDER_0__°';
  }

  @override
  String get openCompass => 'コンパスを開く';

  @override
  String get openAR => 'AR オーバーレイを開く';

  @override
  String get openChat => 'チャットを開く';

  @override
  String get commentsTitle => 'コメント';

  @override
  String get addComment => 'コメントを追加..';

  @override
  String get send => 'お問い合わせ';

  @override
  String get commentPosted => 'コメント投稿';

  @override
  String get autoFollowEnabled => 'このアラートに続いています.';

  @override
  String get noCommentsYet => 'コメントはまだありません。 コメントを投稿する!';

  @override
  String get newCommentNotification => 'あなたがフォローする目撃に関する新しいコメント.';

  @override
  String get mapTitle => 'ライブマップ';

  @override
  String get compassTitle => 'コンパス';

  @override
  String get compassSettings => 'コンパス設定';

  @override
  String get compassMode => 'コンパスモード';

  @override
  String get compassStandardMode => '標準モード';

  @override
  String get compassPilotMode => 'パイロットモード';

  @override
  String get compassStandardDescription => '基本的な見出しとナビゲーション';

  @override
  String get compassPilotDescription => 'ETAとベクターの高度なナビゲーション';

  @override
  String pointingTo(String direction) {
    return '$direction へのポイント';
  }

  @override
  String get calibratingCompass => 'キャリブレーションコンパス..';

  @override
  String get openAROverlay => 'AR オーバーレイを開く';

  @override
  String get pushTitleAlertNearby => 'あなたの近くにUFOアラート';

  @override
  String pushBodyAlertNearby(String distance) {
    return '新たな視力が報告されました_PLACEHOLDER_0__ 離れて.';
  }

  @override
  String get pushTitleComment => '新規コメント';

  @override
  String get pushBodyComment => '誰かがフォローする目撃にコメントしました.';

  @override
  String get pushTitleWitness => 'ウィットネスの確認';

  @override
  String get temperature => '温度';

  @override
  String get pushBodyWitness => '同じオブジェクトが確認されたユーザ.';

  @override
  String get weather => 'ふりがな';

  @override
  String cloudCover(int percent) {
    return '雲カバー: $percent%の特長';
  }

  @override
  String wind(num speed, String unit) {
    return '風:_PLACEHOLDER_0______${unit}_';
  }

  @override
  String get nearbyAircraft => '近隣の航空機';

  @override
  String get noAircraft => '近くの航空機無し';

  @override
  String get loadingContext => '環境のコンテキストをロードする..';

  @override
  String get settingsTitle => 'コンテンツ';

  @override
  String get notifications => 'お知らせ';

  @override
  String get enablePushNotifications => '今後のコメントの通知を得る';

  @override
  String get quietHours => '静かな時間';

  @override
  String get quietHoursDesc => '選択した時間間のサイレンスアラート.';

  @override
  String get quietHoursEnabled => '静かな時間を有効にする';

  @override
  String get quietHoursFrom => '詳しくはこちら';

  @override
  String get quietHoursUntil => 'まで';

  @override
  String get quietHoursDefaultTime => 'デフォルトの静かな時間';

  @override
  String get emergencyOverride => '緊急オーバーライド';

  @override
  String get emergencyOverrideDesc => '静かな時間の間に緊急のアラートを許可する';

  @override
  String get dndMode => '蒸留しない';

  @override
  String get dndUntil => '邪魔しないでください';

  @override
  String dndEnabled(Object time) {
    return 'DND が $time まで有効';
  }

  @override
  String get dndDisabled => 'DND 無効';

  @override
  String get quietHoursActive => '活動的な静かな時間';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return '静かな時間: ${start}_________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get language => '用語集';

  @override
  String get chooseLanguage => '言語を選択';

  @override
  String get units => 'ユニット';

  @override
  String get unitsImperial => 'インペリアル(ミ, mph)';

  @override
  String get unitsMetric => 'メートル(km/h)';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfUse => '利用規約';

  @override
  String get errorNoLocation => '利用できない場所 空を眺めながらもう一度お試しください.';

  @override
  String get errorNoCamera => 'このデバイスでカメラが利用できなくなった.';

  @override
  String get errorUploadFailed => 'アップロードが失敗しました。 お問い合わせ.';

  @override
  String get errorPermissionDenied => '許可が拒否されました.';

  @override
  String get errorInvalidUsername => 'ユーザー名は利用できません.';

  @override
  String get nothingToShow => '何も見せません.';

  @override
  String get storeShortDesc => '近くのインスタントUFOアラート。 リアルタイムでキャプチャ、確認、チャット.';

  @override
  String get storeLongDesc =>
      'UFOBeep は、近くの UFO を指すときにリアルタイムのアラートを送信します。 写真やビデオをキャプチャし、タップ、ビューの方向と距離を確認し、仲間のSkywatchersとチャットします.';

  @override
  String get keywords => 'UFO、UAP、OVNI、aliens、視線、skywatch、alerts、レーダー、compass';

  @override
  String get noAlertsFound => 'マッチングアラートなし';

  @override
  String get alertsFilterHelp => 'フィルターを調整して、より多くの結果を見る';

  @override
  String get verified => 'プロフィール';

  @override
  String get beepOnly => 'ビープのみ';

  @override
  String get reportOnly => 'テキストのみ';

  @override
  String get videoOnly => 'ビデオのみ';

  @override
  String get imageOnly => '画像のみ';

  @override
  String get mediaOnly => 'メディアのみ';

  @override
  String get timeJustNow => 'ただ今';

  @override
  String timeDaysAgo(int count) {
    return '$count 日前';
  }

  @override
  String timeHoursAgo(int count) {
    return '__PLACEHOLDER_0_時間前';
  }

  @override
  String timeMinutesAgo(int count) {
    return '$count 分前';
  }

  @override
  String get loadMoreAlerts => 'より多くのアラートをロードする';

  @override
  String get toggleMufonTooltip => 'MUFONの視線をトグル';

  @override
  String get showMufonData => 'MUFONデータを表示する';

  @override
  String get hideMufonData => 'MUFONデータを隠す';

  @override
  String get showingUfoBeepOnly => 'UFOBeepレポートのみを表示する';

  @override
  String get showingAllReports => 'MUFONデータベースを含むすべてのレポートを表示';

  @override
  String get filteredSuffix => 'フィルター';

  @override
  String get detailsTitle => 'ニュース';

  @override
  String get mufonCase => 'MUFONについて 導入事例';

  @override
  String get mufonSighting => 'MUFONサイティングレポート';

  @override
  String get mufonLightSighting => 'MUFONライトサイティングレポート';

  @override
  String get mufonSphereSighting => 'MUFON 球面視レポート';

  @override
  String get mufonDiscSighting => 'MUFONについて ディスクサイトレポート';

  @override
  String get mufonTriangleSighting => 'MUFONについて トライアングルシーティングレポート';

  @override
  String get mufonCigarSighting => 'MUFONシガーサイトングレポート';

  @override
  String get mufonOvalSighting => 'MUFONオーバルサイトングレポート';

  @override
  String get mufonRectangleSighting => 'MUFONについて 長方形のサイトングレポート';

  @override
  String get mufonCylinderSighting => 'MUFONシリンダーサイティングレポート';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerangのサイトレポート';

  @override
  String get mufonStarlikeSighting => 'MUFONについて 星型観光レポート';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON ケース #${caseNumber}_';
  }

  @override
  String get sightingDate => '予定日';

  @override
  String get mufonDatabaseEntryDate => 'MUFON に入力された日付 データベース';

  @override
  String get databaseEntry => 'データベースのエントリ';

  @override
  String get shareLink => 'シェアリンク';

  @override
  String get linkCopied => 'クリップボードにコピーされたリンク';

  @override
  String get locationLabel => '所在地:';

  @override
  String get distanceLabel => 'アクセス';

  @override
  String get timeLabel => '時間:';

  @override
  String get reportedByLabel => 'レポート';

  @override
  String get unknownLocation => '未知の場所';

  @override
  String get locationUnknown => '所在地 不明';

  @override
  String get witnessesLabel => 'ウィッチネス';

  @override
  String witnessesCountMessage(int count) {
    return '$count 人々はこの視線を確認しました';
  }

  @override
  String get photoAnalysisTitle => 'フォト分析';

  @override
  String mediaItemsProcessed(int count) {
    return '解析: $count メディアファイル(s) 処理';
  }

  @override
  String get addMoreMedia => '詳しくはこちら';

  @override
  String get addMedia => 'メディアの追加';

  @override
  String get retakePhoto => '写真を撮る';

  @override
  String get retakeVideo => 'Retake ビデオ';

  @override
  String get camera => 'カメラ';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get basicSettings => '基本設定';

  @override
  String get appSettings => 'アプリの設定';

  @override
  String get timeFormat => '時間フォーマット';

  @override
  String get timeFormat24Hour => '24時間(14:30)';

  @override
  String get timeFormat12Hour => '12時間(2:30 PM)';

  @override
  String get timeFormatDesc => '24時間または12時間のフォーマットの表示時間';

  @override
  String get alertRange => 'アラート範囲';

  @override
  String get manageNotificationsDesc => 'サブスクリプションと設定の管理';

  @override
  String get permissionsTitle => 'パーミッション';

  @override
  String get permissionLocation => 'アクセス';

  @override
  String get permissionCamera => 'カメラ';

  @override
  String get permissionNotifications => 'お知らせ';

  @override
  String get permissionPhotos => 'ニュース';

  @override
  String get permissionGranted => '助成対象者';

  @override
  String get permissionNotGranted => '免責事項';

  @override
  String get permissionGrant => '助成金';

  @override
  String get generateUsername => '新しいユーザー名を生成する';

  @override
  String get adminTools => '管理者ツール';

  @override
  String get openAdminPanel => '開いた管理者のパネル';

  @override
  String get webAdminInterface => 'ウェブ管理者インターフェイス';

  @override
  String get adminBetaNotice => 'ベータビルドのみ。 近接アラートのテスト、プッシュ通知、システム診断のための管理ツール.';

  @override
  String get whatDoYouSee => 'お問い合わせ?';

  @override
  String get ufo => 'ユーチューブ';

  @override
  String get sighting => 'スタイリング';

  @override
  String get ufoSighting => 'UFOベープUFO アラート';

  @override
  String get envAnalysisTitle => '環境分析';

  @override
  String get envAnalysisPending => '解析の終わること';

  @override
  String get envAnalysisPendingDesc => '処理が始まると環境データが使用可能になります.';

  @override
  String get unknownAircraft => '未知の航空機';

  @override
  String get moreAircraft => 'より多くの航空機';

  @override
  String get premiumImageryTitle => 'プレミアム衛星 イメージ';

  @override
  String get premiumImagerySubtitle => '高解像度商用イメージ';

  @override
  String get sightingTypeLabel => 'タイプ:';

  @override
  String get ufoTypeSphere => 'スフィア';

  @override
  String get ufoTypeTriangle => 'トライアングル';

  @override
  String get ufoTypeDisk => 'ディスク';

  @override
  String get ufoTypeLight => 'ライトライト';

  @override
  String get ufoTypeFireball => 'ファイアーボール';

  @override
  String get ufoTypeCylinder => 'シリンダー';

  @override
  String get ufoTypeCigar => 'シガー';

  @override
  String get ufoTypeRectangle => '長方形';

  @override
  String get ufoTypeFormation => 'フォーム';

  @override
  String get ufoTypeUnknown => '未知の';

  @override
  String get ufoTypeBoomerang => 'ブーメラン';

  @override
  String get ufoTypeDiamond => 'ダイヤモンド';

  @override
  String get ufoTypeOval => 'オーバル';

  @override
  String get ufoTypeCone => 'コーン';

  @override
  String get ufoTypeCross => 'ログイン';

  @override
  String get ufoTypeDumbbell => 'ダンベル';

  @override
  String get ufoTypeTeardrop => 'ティアドロップ';

  @override
  String get ufoTypeTicTac => 'シックタック';

  @override
  String get ufoTypeBullet => 'ニュース';

  @override
  String get ufoTypeSaturn => 'サターン';

  @override
  String get ufoTypeStarLike => '星のような';

  @override
  String get ufoTypeBlimp => 'ログイン';

  @override
  String get shapeTriangle => 'トライアングル';

  @override
  String get shapeDisc => 'ディスク';

  @override
  String get shapeDisk => 'ディスク';

  @override
  String get shapeSphere => 'スフィア';

  @override
  String get shapeCigar => 'シガー';

  @override
  String get shapeLight => 'ライトライト';

  @override
  String get shapeBoomerang => 'ログイン';

  @override
  String get shapeDiamond => 'ダイヤモンド';

  @override
  String get shapeRectangle => 'リフォーム';

  @override
  String get shapeOval => 'オーバル';

  @override
  String get shapeCone => 'ログイン';

  @override
  String get shapeCross => 'クロス';

  @override
  String get shapeCylinder => 'シリンダー';

  @override
  String get shapeDumbbell => 'ダンベル';

  @override
  String get shapeTeardrop => '涙ドロップ';

  @override
  String get shapeTicTac => 'ティックタック';

  @override
  String get shapeBullet => 'ニュースレター';

  @override
  String get shapeSaturn => 'サターン';

  @override
  String get shapeStarlike => 'スターライク';

  @override
  String get shapeBlimp => 'ログイン';

  @override
  String get shapeFireball => 'サッカー';

  @override
  String get shapeFormation => 'フォーム';

  @override
  String get shapeUnknown => 'インフォメーション';

  @override
  String get actionsTitle => 'アクション';

  @override
  String get addPhotosAndVideos => '写真とビデオを追加';

  @override
  String get howToReportToMufon => 'MUFONへの報告方法';

  @override
  String get reportToMufon => 'MUFONへの報告';

  @override
  String get whyReportToMufon => 'なぜMUFONへの報告?';

  @override
  String get openMufonReport => 'MUFONを開く レポート';

  @override
  String get confirmedWitness => 'この視線を確認しました';

  @override
  String witnessesHaveConfirmed(int count) {
    return '$count 人々はこの視線を確認しました';
  }

  @override
  String get aircraftTrackingTitle => '航空機の追跡';

  @override
  String get weatherConditionsTitle => '気象条件';

  @override
  String get noSatellitePasses => '目に見えない衛星パスが見つかりません';

  @override
  String get contentAnalysisTitle => 'コンテンツ分析';

  @override
  String get contentSafe => 'コンテンツは安全です';

  @override
  String get contentFlagged => '審査対象のコンテンツ';

  @override
  String get confidenceLabel => 'コンプライアンス';

  @override
  String get methodLabel => 'メソッド';

  @override
  String get premiumImageryAccessOnly => 'プレミアム衛星画像のみ利用可能です:';

  @override
  String get premiumAccessCreators => 'アラート作成者';

  @override
  String get premiumAccessWitnesses => '可視範囲内で確認された証人';

  @override
  String get comingSoon => '近日公開';

  @override
  String get directionDistanceTitle => '方向及び間隔';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFONについて ケース #${caseNumber}_';
  }

  @override
  String get satellitePassesTitle => '衛星パス';

  @override
  String get satellitePassExplanation =>
      '視力時間枠の間に可視衛星パス. 多くのUFOレポートは、実際には衛星や宇宙の破片です.';

  @override
  String get followingAlert => '次のアラート - コメント通知を取得します';

  @override
  String get unfollowedAlert => 'フォローされていないアラート - コメント通知はありません';

  @override
  String get alertFollowError => 'エラー更新 ステータスをフォローする';

  @override
  String get notificationChannelAlerts => 'UFOBeepアラート';

  @override
  String get notificationChannelAlertsDesc => 'UFOビープと近接アラートの通知';

  @override
  String get notificationSightingTitle => 'UFOベープUFO アラート';

  @override
  String get notificationSightingUrgent => '⚠️ ウルゲン UFOBeep UFO アラート';

  @override
  String get notificationSightingEmergency => '緊急UFOBeep UFO アラート';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '${witnessText}______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String notificationCommentTitle(String username) {
    return '💬_PLACEHOLDER_0__コメント';
  }

  @override
  String get notificationWitnessText => '新しい視線';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '$count 証人';
  }

  @override
  String get notificationActionSnooze => 'スヌーズ 1h';

  @override
  String get notificationActionDismiss => '免責事項';

  @override
  String notificationDistance(String distance) {
    return '__PLACEHOLDER_0_ 離れて';
  }

  @override
  String get unknown => 'インフォメーション';

  @override
  String get report => 'レポート';

  @override
  String get mufon => 'ミュフォン';

  @override
  String get recentUfoBeepsTitle => '最近のUFO ベップス';

  @override
  String get recentUfoBeepsSubtitle => '世界中のコミュニティからライブ UFO を目撃するレポート';

  @override
  String get recentUfoBeepsDescription =>
      'このフィードは、MUFONデータベースからの履歴レポートを使用して、モバイルアプリユーザーからリアルタイムのUFOBeep \"beeps\"を組み合わせています.';

  @override
  String get loadingBeeps => '最近のビープ...';

  @override
  String get noBeepsAvailable => '現時点ではビープはありません.';

  @override
  String get anomalyReported => '異常報告';

  @override
  String get copyShortLink => 'ショートリンクのコピー';

  @override
  String get shareAlert => 'アラートを共有する';

  @override
  String get ufoSightingAlert => 'ユーチューブ アラートの閲覧';

  @override
  String get previousPage => '新着情報';

  @override
  String get nextPage => '次へ';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'ページの ${currentPage}_ の ${totalPages}_ (${totalCount}_の総ビープ)';
  }

  @override
  String get firstPage => 'ファースト';

  @override
  String get lastPage => '最近の投稿';

  @override
  String get jumpToPage => 'ページをジャンプ';

  @override
  String get heroTagline => '外部に行くときにアラートを取得し、調べる';

  @override
  String get heroDescription =>
      'UFOを見逃さない。 近くの人が空に奇妙な何かを見たときにリアルタイムのアラートを取得します。 携帯電話をポイントし、どこを見ても正確に見つけてください.';

  @override
  String get downloadApp => '◀ アプリのダウンロード';

  @override
  String get viewAllBeeps => 'すべてのビープを見る';

  @override
  String get sightingsMap => 'サイトマップ';

  @override
  String get globalSightingNetwork => 'グローバルサイトネットワーク';

  @override
  String get howItWorks => 'UFOBeepの仕組み';

  @override
  String get backToBeeps => 'ビープスに戻る';

  @override
  String get loadingDetails => 'ビープの詳細を読み込む...';

  @override
  String get details => 'ニュース';

  @override
  String get location => 'アクセス';

  @override
  String get timeAgo => '最近の投稿';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'マイル';

  @override
  String get distanceMiles => 'マイル';

  @override
  String get distanceNearby => '周辺エリア';

  @override
  String get ufobeepWitnesses => 'ウィッチネス';

  @override
  String get ufobeepConfirmations => '確認事項';

  @override
  String get ufobeepAlertLevel => 'アラートレベル';

  @override
  String get ufobeepReportType => 'UFOBeepレポート';

  @override
  String get mufonAttribution => 'MUFONについて データベースレポート';

  @override
  String get mufonCaseNumber => 'ケース #';

  @override
  String get mufonGenericTitle => 'MUFONサイティングレポート';

  @override
  String get mufonSphere => 'スフィア';

  @override
  String get mufonLight => 'ライトライト';

  @override
  String get mufonDisk => 'ディスク';

  @override
  String get mufonTriangle => 'トライアングル';

  @override
  String get mufonCigar => 'シガー';

  @override
  String get mufonOval => 'オーバル';

  @override
  String get mufonCylinder => 'シリンダー';

  @override
  String get mufonRectangle => '長方形';

  @override
  String get mufonDiamond => 'ダイヤモンド';

  @override
  String get mufonFireball => 'ファイアーボール';

  @override
  String get mufonFlash => 'フラッシュ';

  @override
  String get mufonFormation => 'フォーム';

  @override
  String get mufonChanging => '変更について';

  @override
  String get mufonChevron => 'シブロン';

  @override
  String get mufonCone => 'コーン';

  @override
  String get mufonCross => 'ログイン';

  @override
  String get mufonEgg => 'ツイート';

  @override
  String get mufonOther => 'オブジェクト';

  @override
  String get mufonUnknown => '未知のオブジェクト';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON $classification レポート';
  }

  @override
  String get nuforcAttribution => 'ログイン データベースレポート';

  @override
  String get nuforcCaseNumber => 'ケース #';

  @override
  String get nuforcGenericTitle => 'ログイン 観光レポート';

  @override
  String get mediaImageNotFound => '画像が見つかりません';

  @override
  String get mediaPlayVideo => '再生ビデオ';

  @override
  String get mediaViewImage => '画像を見る';

  @override
  String mediaCount(Object count) {
    return '__PLACEHOLDER_0_さんの画像';
  }

  @override
  String get mediaCountSingle => '1 画像';

  @override
  String mediaMoreImages(Object count) {
    return 'お問い合わせ';
  }

  @override
  String get errorNotFound => 'ビープが見つかりません';

  @override
  String get errorLoadError => 'ビープの詳細を読み込む失敗';

  @override
  String get shareYourThoughts => 'この視線についてのあなたの考えを共有する...';

  @override
  String get postComment => '投稿コメント';

  @override
  String get loggedInAs => 'ログイン';

  @override
  String get logout => 'ログイン';

  @override
  String get notFollowing => 'お問い合わせ';

  @override
  String get follow => 'フォロー';

  @override
  String get navRecentBeeps => '最近のビープ';

  @override
  String get navMap => 'サイトマップ';

  @override
  String get navDownloadApp => 'アプリのダウンロード';

  @override
  String get alertLevel => 'アラートレベル';

  @override
  String get witnesses => 'ウィッチネス';

  @override
  String get confirmations => '確認事項';

  @override
  String get reporterLabel => 'ユーザーによる報告';

  @override
  String get coordinatesLabel => 'コーディネート';

  @override
  String get eventTime => 'イベント情報';

  @override
  String get reportedTime => '報告時間';

  @override
  String get addedToUfobeep => 'UFOBeep に追加';

  @override
  String get mufonDatabaseReport => 'MUFONについて データベースレポート';

  @override
  String get copyShortLinkTitle => 'クリップボードへのリンクをコピーする';

  @override
  String get imageNotFound => '画像が見つかりません';

  @override
  String get ufoSightingAlt => 'ユーチューブ Beep UFOアラート';

  @override
  String get celestialDataTitle => 'Celestialオブジェクト';

  @override
  String get visiblePlanets => '可視惑星';

  @override
  String get locationDataTitle => '所在地案内';

  @override
  String get timezone => 'タイムゾーン';

  @override
  String get coordinates => 'コーディネート';

  @override
  String get processingSummaryTitle => '加工概要';

  @override
  String get processingTime => '処理時間';

  @override
  String get successful => '成功する';

  @override
  String get failed => '失敗した';

  @override
  String get locationEnrichmentTitle => 'ロケーション詳細';

  @override
  String get aircraftDataSource => 'データソース';

  @override
  String get noAircraftDetected => '航空機が検出されない';

  @override
  String get sightingReport => '観光レポート';

  @override
  String get ufoAlert => 'ユーチューブ アラート';

  @override
  String get alert => 'アラート';

  @override
  String get notificationTickerUfoAlert => 'UFOアラート - 近くの新しいサイト';

  @override
  String get notificationTickerComment => 'UFOアラートの新しいコメント';

  @override
  String get weatherConditions => '気象条件';

  @override
  String get visibility => '可視性';

  @override
  String get humidity => '湿度: 8';

  @override
  String get pressure => 'プレッシャー';

  @override
  String get locationDetails => 'ロケーション詳細';

  @override
  String get city => 'シティ';

  @override
  String get state => 'ステータス';

  @override
  String get country => 'カントリー';

  @override
  String get satelliteActivity => '衛星活動';

  @override
  String get satellitesVisibleOverhead => '視力時間と位置で見える衛星';

  @override
  String get dataSource => 'データソース';

  @override
  String get blackskyImagery => 'ブラックスカイのイメージ';

  @override
  String get resolution => 'ソリューション';

  @override
  String get groundResolution => '35cmの地上の決断';

  @override
  String get delivery => 'デリバリー';

  @override
  String get averageDelivery => '90分平均';

  @override
  String get cost => 'コスト';

  @override
  String get skyfiSatelliteImagery => 'SkyFi衛星 イメージ';

  @override
  String get region => 'エリア';

  @override
  String get remoteArea => '遠隔区域';

  @override
  String get startingPrice => '開始価格';

  @override
  String get coverage => 'カバレッジ';

  @override
  String get confidenceCoverage => '95%の自信';

  @override
  String get status => 'ステータス';

  @override
  String get shareThoughts => 'この視線についてのあなたの考えを共有する...';

  @override
  String get postCommand => 'コマンドの投稿';

  @override
  String get clouds => 'クラウド';

  @override
  String get windLabel => 'ウインド';
}
