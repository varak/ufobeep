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
    return '__PH_0_ 離れて';
  }

  @override
  String alertDirection(int bearing) {
    return '軸受け_PH_0__°';
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
    return 'レポート:_PH_0__';
  }

  @override
  String reportedAt(String timeAgo) {
    return '報告する ${timeAgo}_';
  }

  @override
  String distanceAway(String distance) {
    return '__PH_0_ 離れて';
  }

  @override
  String bearingToObject(int bearing) {
    return '目的への軸受け:  __ 0 0';
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
  String get noCommentsYet => 'コメントはまだありません。 まずは!';

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
    return 'へのポイント $direction';
  }

  @override
  String get calibratingCompass => 'キャリブレーションコンパス..';

  @override
  String get openAROverlay => 'AR オーバーレイを開く';

  @override
  String get pushTitleAlertNearby => 'あなたの近くにUFOアラート';

  @override
  String pushBodyAlertNearby(String distance) {
    return '新たな視力が報告されました。 ${distance}_ 離れて.';
  }

  @override
  String get pushTitleComment => '新規コメント';

  @override
  String get pushBodyComment => '誰かがフォローする目撃にコメントしました.';

  @override
  String get pushTitleWitness => 'ウィットネスの確認';

  @override
  String get pushBodyWitness => '同じオブジェクトが確認されたユーザ.';

  @override
  String get weather => 'ふりがな';

  @override
  String cloudCover(int percent) {
    return '雲カバー: 特許取得済';
  }

  @override
  String wind(num speed, String unit) {
    return '風:_PH_0____${unit}_';
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
  String get enablePushNotifications => 'プッシュ通知を有効にする';

  @override
  String get quietHours => '静かな時間';

  @override
  String get quietHoursDesc => '選択した時間間のサイレンスアラート.';

  @override
  String get dndMode => '蒸留しない';

  @override
  String get dndUntil => '邪魔しないでください';

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
  String get videoOnly => 'ビデオのみ';

  @override
  String get imageOnly => '画像のみ';

  @override
  String get timeJustNow => '今すぐ登録';

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
  String get sightingDate => '予定日';

  @override
  String get databaseEntry => 'データベースのエントリ';

  @override
  String get locationLabel => 'アクセス';

  @override
  String get distanceLabel => 'アクセス';

  @override
  String get timeLabel => 'タイムタイム';

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
    return '解析: $count 処理されたメディアファイル';
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
  String get ufoSighting => 'ユーチューブ スタイリング';

  @override
  String get envAnalysisTitle => 'Environmental Analysis';

  @override
  String get envAnalysisPending => 'Analysis Pending';

  @override
  String get envAnalysisPendingDesc =>
      'Environmental data will be available once processing begins.';

  @override
  String get unknownAircraft => 'Unknown Aircraft';

  @override
  String get moreAircraft => 'more aircraft';

  @override
  String get premiumImageryTitle => 'Premium Satellite Imagery';

  @override
  String get premiumImagerySubtitle => 'High-resolution commercial imagery';

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
  String get ufoTypeBoomerang => 'Boomerang';

  @override
  String get ufoTypeDiamond => 'Diamond';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Cone';

  @override
  String get ufoTypeCross => 'Cross';

  @override
  String get ufoTypeDumbbell => 'Dumbbell';

  @override
  String get ufoTypeTeardrop => 'Teardrop';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Bullet';

  @override
  String get ufoTypeSaturn => 'Saturn';

  @override
  String get ufoTypeStarLike => 'Star-like';

  @override
  String get ufoTypeBlimp => 'Blimp';

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
  String get aircraftTrackingTitle => 'Aircraft Tracking';

  @override
  String get weatherConditionsTitle => 'Weather Conditions';

  @override
  String get noSatellitePasses => 'No visible satellite passes found';

  @override
  String get contentAnalysisTitle => 'Content Analysis';

  @override
  String get contentSafe => 'Content is safe';

  @override
  String get contentFlagged => 'Content flagged for review';

  @override
  String get confidenceLabel => 'Confidence';

  @override
  String get methodLabel => 'Method';

  @override
  String get premiumImageryAccessOnly =>
      'Premium satellite imagery is only available to:';

  @override
  String get premiumAccessCreators => 'Alert creators';

  @override
  String get premiumAccessWitnesses =>
      'Confirmed witnesses within visibility range';

  @override
  String get comingSoon => 'Coming Soon';
}
