// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '打开';

  @override
  String get ok => '还好';

  @override
  String get cancel => '取消';

  @override
  String get close => '关闭';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get retry => '重试';

  @override
  String get yes => '对';

  @override
  String get no => '没有';

  @override
  String get back => '回来';

  @override
  String get next => '下一个';

  @override
  String get done => '写好了';

  @override
  String get loading => '正在装入..';

  @override
  String get processing => '正在处理..';

  @override
  String get errorGeneric => '出了点问题.';

  @override
  String get networkError => '网络错误 。 检查你的连接.';

  @override
  String get permissionsRequired => '需要权限';

  @override
  String get learnMore => '学更多';

  @override
  String get welcomeTitle => '欢迎来到UFOBEP';

  @override
  String get welcomeSubtitle => '在你附近实时UFO警报';

  @override
  String get signIn => '签名';

  @override
  String get signOut => '签字';

  @override
  String get continueAsGuest => '继续做客';

  @override
  String get enterUsername => '输入用户名';

  @override
  String get username => '用户名';

  @override
  String get usernameUpdated => '用户名已更新';

  @override
  String get profile => '简介';

  @override
  String get settings => '设置';

  @override
  String get tabAlerts => '警报';

  @override
  String get tabBeep => '哔';

  @override
  String get tabChat => '聊天';

  @override
  String get tabMap => '地图';

  @override
  String get tabSettings => '设置';

  @override
  String get alertsTitle => '近距离警告';

  @override
  String get noAlerts => '附近还没有警报.';

  @override
  String get pullToRefresh => '拉来拉去';

  @override
  String alertDistance(String distance) {
    return '远离';
  }

  @override
  String alertDirection(int bearing) {
    return '轴承$bearing';
  }

  @override
  String get viewAlert => '查看提醒';

  @override
  String get viewOnMap => '在地图上查看';

  @override
  String get iSeeItToo => '我也看见了';

  @override
  String get confirmWitnessed => '确认你目睹了这次目击?';

  @override
  String get witnessConfirmed => '谢谢,你的确认已经公布.';

  @override
  String get createBeepTitle => '发出哔声';

  @override
  String get beepExplain => '抓住你看到的 并提醒附近的监视者.';

  @override
  String get capturePhoto => '抓取照片';

  @override
  String get captureVideo => '抓取视频';

  @override
  String get pickFromGallery => '从画廊中选择';

  @override
  String get descriptionHint => '描述你在天空中看到的..';

  @override
  String get submitBeep => '发出哔声';

  @override
  String get beepSent => '发出哔声';

  @override
  String beepSentWithUrl(String shortUrl) {
    return '哔声成功发送';
  }

  @override
  String get uploadingMedia => '正在上传媒体..';

  @override
  String get includeLocation => '包含位置';

  @override
  String get includeTimestamp => '包含时间戳';

  @override
  String get beepFailed => '发送哔声失败 .';

  @override
  String get mediaProcessing => '正在处理媒体..';

  @override
  String get cameraPermissionTitle => '需要摄像';

  @override
  String get cameraPermissionBody => '授权摄像头拍摄UFO照片和视频.';

  @override
  String get locationPermissionTitle => '需要访问的地点';

  @override
  String get locationPermissionBody => '我们用你的位置发送和接收附近的警报.';

  @override
  String get microphonePermissionTitle => '需要使用微型电话';

  @override
  String get microphonePermissionBody => '允许麦克风进入 视频捕捉带音频.';

  @override
  String get openSettings => '打开设置';

  @override
  String get alertDetailTitle => '查看细节';

  @override
  String reportedBy(String username) {
    return '由 $username 报告';
  }

  @override
  String reportedAt(String timeAgo, Object time) {
    return '已报告  阿广';
  }

  @override
  String distanceAway(String distance) {
    return '离开';
  }

  @override
  String bearingToObject(int bearing) {
    return '向反对方显示 :';
  }

  @override
  String get openCompass => '打开指南针';

  @override
  String get openAR => '打开 AR 覆盖';

  @override
  String get openChat => '打开聊天';

  @override
  String get commentsTitle => '评论';

  @override
  String get addComment => '添加注释..';

  @override
  String get send => '发送';

  @override
  String get commentPosted => '张贴的评论';

  @override
  String get autoFollowEnabled => '你们现在正在遵守这一警告.';

  @override
  String get noCommentsYet => '还没有评论。 成为第一个评论者!';

  @override
  String get newCommentNotification => '新的评论你跟踪.';

  @override
  String get mapTitle => '现场地图';

  @override
  String get compassTitle => '指南针';

  @override
  String get compassSettings => '指南针设置';

  @override
  String get compassMode => '编译模式';

  @override
  String get compassStandardMode => '标准模式';

  @override
  String get compassPilotMode => '试点模式';

  @override
  String get compassStandardDescription => '基本航向和导航';

  @override
  String get compassPilotDescription => '带有ETA和矢量的高级导航';

  @override
  String pointingTo(String direction) {
    return '指向';
  }

  @override
  String get calibratingCompass => '校准指南针..';

  @override
  String get openAROverlay => '打开 AR 覆盖';

  @override
  String get pushTitleAlertNearby => '你身边的UFO警报';

  @override
  String pushBodyAlertNearby(String distance) {
    return '传出新的目击画面.';
  }

  @override
  String get pushTitleComment => '新评论';

  @override
  String get pushBodyComment => '有人评论你跟踪的一幕.';

  @override
  String get pushTitleWitness => '证人确认';

  @override
  String get temperature => '温度';

  @override
  String get pushBodyWitness => '一个用户确认他们看到了同一个对象.';

  @override
  String get weather => '天气';

  @override
  String cloudCover(int percent) {
    return '云盖:';
  }

  @override
  String wind(num speed, String unit) {
    return '风:';
  }

  @override
  String get nearbyAircraft => '近地点飞机';

  @override
  String get noAircraft => '附近没有飞机';

  @override
  String get loadingContext => '正在装入环境背景..';

  @override
  String get settingsTitle => '设置';

  @override
  String get notifications => '通知';

  @override
  String get enablePushNotifications => '获取通知供今后评论';

  @override
  String get quietHours => '安静时间';

  @override
  String get quietHoursDesc => '选定时数之间的静态提示 .';

  @override
  String get dndMode => '不要烦恼';

  @override
  String get dndUntil => '不要打扰到这里';

  @override
  String get language => '语言';

  @override
  String get chooseLanguage => '选择语言';

  @override
  String get units => '单位';

  @override
  String get unitsImperial => '帝国语( mi, mph)';

  @override
  String get unitsMetric => '计量(公里,公里/小时)';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfUse => '使用条件';

  @override
  String get errorNoLocation => '没有位置 。 再用清空的天眼试试看.';

  @override
  String get errorNoCamera => '此设备没有摄像头 .';

  @override
  String get errorUploadFailed => '上传失败 。 请再试一次.';

  @override
  String get errorPermissionDenied => '拒绝许可.';

  @override
  String get errorInvalidUsername => '这个用户名不可用 .';

  @override
  String get nothingToShow => '还没显示什么.';

  @override
  String get storeShortDesc => '即时UFO警报接近你 抓住,确认,实时聊天.';

  @override
  String get storeLongDesc =>
      'UFOBEP在附近发现UFO时发出实时警报. 捕捉照片和录像,用水龙头证实目击情况,查看方向和距离,并与天空观察者同行聊天.';

  @override
  String get keywords => 'UFO、UAP、OVNI、aliens、视觉、天空表、警报、雷达、辅助设备';

  @override
  String get noAlertsFound => '没有匹配的提示';

  @override
  String get alertsFilterHelp => '尝试调整过滤器以查看更多结果';

  @override
  String get verified => '已验证';

  @override
  String get beepOnly => '仅报告';

  @override
  String get reportOnly => '仅报告';

  @override
  String get videoOnly => '只有视频';

  @override
  String get imageOnly => '仅图像';

  @override
  String get timeJustNow => '刚才';

  @override
  String timeDaysAgo(int count) {
    return '之前';
  }

  @override
  String timeHoursAgo(int count) {
    return '你刚才说';
  }

  @override
  String timeMinutesAgo(int count) {
    return '时间轴:';
  }

  @override
  String get loadMoreAlerts => '装入更多提醒';

  @override
  String get toggleMufonTooltip => '切换MUFON的目击';

  @override
  String get showMufonData => '显示 MUFON 数据';

  @override
  String get hideMufonData => '隐藏 MUFON 数据';

  @override
  String get showingUfoBeepOnly => '只显示 UFOBEP 报告';

  @override
  String get showingAllReports => '显示包括MUFON数据库在内的所有报告';

  @override
  String get filteredSuffix => '过滤';

  @override
  String get detailsTitle => '细节';

  @override
  String get mufonCase => '毛里求斯 大小写';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return '细节';
  }

  @override
  String get sightingDate => '观察日期';

  @override
  String get mufonDatabaseEntryDate => '输入 MUFON 的日期 数据库';

  @override
  String get databaseEntry => '数据库条目';

  @override
  String get shareLink => '共享链接';

  @override
  String get linkCopied => '链接复制到剪贴板';

  @override
  String get locationLabel => '地点 :';

  @override
  String get distanceLabel => '距离';

  @override
  String get timeLabel => '时间 :';

  @override
  String get reportedByLabel => '报告';

  @override
  String get unknownLocation => '未知位置';

  @override
  String get locationUnknown => '位置未知';

  @override
  String get witnessesLabel => '证人';

  @override
  String witnessesCountMessage(int count) {
    return '人们确认这次目击';
  }

  @override
  String get photoAnalysisTitle => '照片分析';

  @override
  String mediaItemsProcessed(int count) {
    return '分析:  已处理的媒体文件';
  }

  @override
  String get addMoreMedia => '添加更多内容';

  @override
  String get addMedia => '添加媒体';

  @override
  String get retakePhoto => '重取照片';

  @override
  String get retakeVideo => '重取视频';

  @override
  String get camera => '摄影机';

  @override
  String get gallery => '图片库';

  @override
  String get basicSettings => '基本设置';

  @override
  String get appSettings => '应用程序设置';

  @override
  String get alertRange => '警报范围';

  @override
  String get manageNotificationsDesc => '管理订阅设置( S)';

  @override
  String get permissionsTitle => '权限';

  @override
  String get permissionLocation => '地点';

  @override
  String get permissionCamera => '摄影机';

  @override
  String get permissionNotifications => '通知';

  @override
  String get permissionPhotos => '照片';

  @override
  String get permissionGranted => '获准';

  @override
  String get permissionNotGranted => '不予批准';

  @override
  String get permissionGrant => '赠款';

  @override
  String get generateUsername => '生成新用户名';

  @override
  String get adminTools => '管理工具';

  @override
  String get openAdminPanel => '打开管理面板';

  @override
  String get webAdminInterface => 'Web 管理员界面';

  @override
  String get adminBetaNotice => '贝塔只构建。 用于测试近距离警报、推进通知和系统诊断的行政管理工具.';

  @override
  String get whatDoYouSee => '你看见什么了?';

  @override
  String get ufo => '不明飞行物';

  @override
  String get sighting => '观察';

  @override
  String get ufoSighting => '不明飞行物 观察';

  @override
  String get envAnalysisTitle => '环境分析';

  @override
  String get envAnalysisPending => '待分析';

  @override
  String get envAnalysisPendingDesc => '一旦开始处理,将可获得环境数据.';

  @override
  String get unknownAircraft => '未知飞机';

  @override
  String get moreAircraft => '更多飞机';

  @override
  String get premiumImageryTitle => '钚卫星 图像';

  @override
  String get premiumImagerySubtitle => '高分辨率商业图像';

  @override
  String get sightingTypeLabel => '类型';

  @override
  String get ufoTypeSphere => '球体';

  @override
  String get ufoTypeTriangle => '三角形';

  @override
  String get ufoTypeDisk => '磁盘';

  @override
  String get ufoTypeLight => '光线';

  @override
  String get ufoTypeFireball => '火球';

  @override
  String get ufoTypeCylinder => '圆柱';

  @override
  String get ufoTypeCigar => '雪茄';

  @override
  String get ufoTypeRectangle => '矩形';

  @override
  String get ufoTypeFormation => '组建';

  @override
  String get ufoTypeUnknown => '未知';

  @override
  String get ufoTypeBoomerang => ' Boom';

  @override
  String get ufoTypeDiamond => '钻石';

  @override
  String get ufoTypeOval => '奥巴马';

  @override
  String get ufoTypeCone => '锥形';

  @override
  String get ufoTypeCross => '交叉';

  @override
  String get ufoTypeDumbbell => '哑铃';

  @override
  String get ufoTypeTeardrop => '泪滴';

  @override
  String get ufoTypeTicTac => '塔克语Name';

  @override
  String get ufoTypeBullet => '子弹';

  @override
  String get ufoTypeSaturn => '土星号';

  @override
  String get ufoTypeStarLike => '像星星一样';

  @override
  String get ufoTypeBlimp => '闪烁';

  @override
  String get shapeTriangle => '三角形';

  @override
  String get shapeDisc => '盘片';

  @override
  String get shapeDisk => '磁盘';

  @override
  String get shapeSphere => '区域';

  @override
  String get shapeCigar => '雪茄';

  @override
  String get shapeLight => '光线';

  @override
  String get shapeBoomerang => ' boom';

  @override
  String get shapeDiamond => '钻石';

  @override
  String get shapeRectangle => '矩形';

  @override
  String get shapeOval => '椭圆';

  @override
  String get shapeCone => '圆锥';

  @override
  String get shapeCross => '横';

  @override
  String get shapeCylinder => '圆柱形';

  @override
  String get shapeDumbbell => '哑铃';

  @override
  String get shapeTeardrop => '泪滴';

  @override
  String get shapeTicTac => '盘点';

  @override
  String get shapeBullet => '子弹';

  @override
  String get shapeSaturn => '静坐';

  @override
  String get shapeStarlike => '像星星一样';

  @override
  String get shapeBlimp => '蓝宝石';

  @override
  String get shapeFireball => '火球';

  @override
  String get shapeFormation => '编队';

  @override
  String get shapeUnknown => '不详';

  @override
  String get actionsTitle => '行动';

  @override
  String get addPhotosAndVideos => '添加照片和视频( V)';

  @override
  String get howToReportToMufon => '如何向毛里求斯财政部报告';

  @override
  String get reportToMufon => '向毛里求斯财政部报告';

  @override
  String get whyReportToMufon => '为什么向MUFON报告?';

  @override
  String get openMufonReport => '打开MUFON 报告';

  @override
  String get confirmedWitness => '你确认了这次目击';

  @override
  String witnessesHaveConfirmed(int count) {
    return '人们已经确认这次目击';
  }

  @override
  String get aircraftTrackingTitle => '飞机跟踪';

  @override
  String get weatherConditionsTitle => '天气条件';

  @override
  String get noSatellitePasses => '未发现可见的卫星通过';

  @override
  String get contentAnalysisTitle => '内容分析';

  @override
  String get contentSafe => '内容是安全的';

  @override
  String get contentFlagged => '标注供审查的内容';

  @override
  String get confidenceLabel => '信心';

  @override
  String get methodLabel => '方法';

  @override
  String get premiumImageryAccessOnly => '精度卫星图像仅提供给:';

  @override
  String get premiumAccessCreators => '提醒创建者';

  @override
  String get premiumAccessWitnesses => '在可见范围内确认的证人';

  @override
  String get comingSoon => '快来了';

  @override
  String get directionDistanceTitle => '方向距离( D)';

  @override
  String mufonCaseTitle(String caseNumber) {
    return '毛里求斯 案件数量';
  }

  @override
  String get satellitePassesTitle => '卫星通行证';

  @override
  String get satellitePassExplanation => '可见卫星在目视时间内通过. 许多UFO报告实际上是卫星或空间碎片.';

  @override
  String get followingAlert => '注意后 - 你会收到评论通知';

  @override
  String get unfollowedAlert => '未遵循提醒 - 没有更多评论通知';

  @override
  String get alertFollowError => '更新跟随状态出错';

  @override
  String get notificationChannelAlerts => 'UFOBEP 警报';

  @override
  String get notificationChannelAlertsDesc => '关于UFO哔声和近距离警报的通知';

  @override
  String get notificationSightingTitle => '不明飞行物 观察';

  @override
  String get notificationSightingUrgent => '紧急UFO 观察';

  @override
  String get notificationSightingEmergency => '紧急UFO 观察';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '靠近   名称]';
  }

  @override
  String notificationCommentTitle(String username) {
    return '注释';
  }

  @override
  String get notificationWitnessText => '新视觉';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '证人';
  }

  @override
  String get notificationActionSnooze => '斯努兹 1小时';

  @override
  String get notificationActionDismiss => '开除';

  @override
  String notificationDistance(String distance) {
    return '远离';
  }

  @override
  String get unknown => '不详';

  @override
  String get report => '报告';

  @override
  String get mufon => '木冯';

  @override
  String get recentUfoBeepsTitle => '近期的UFO 黄蜂';

  @override
  String get recentUfoBeepsSubtitle => '现场UFOBEP社区报告和MUFON数据库目击';

  @override
  String get recentUfoBeepsDescription =>
      '此饲料结合了我们移动应用用户的实时UFOBEP\"哔哩哔哩\"与MUFON数据库的历史报告.';

  @override
  String get loadingBeeps => '正在装入最近的蜂鸣...';

  @override
  String get noBeepsAvailable => '目前没有哔声.';

  @override
  String get anomalyReported => '异常报告';

  @override
  String get copyShortLink => '复制短链接';

  @override
  String get shareAlert => '共享提醒';

  @override
  String get previousPage => '上一个';

  @override
  String get nextPage => '下一个';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return '页面   ( 总哔声)';
  }

  @override
  String get heroTagline => '什么时候到外面看看';

  @override
  String get heroDescription =>
      '永远不要错过另一个UFO的目击。 当有人在天上看到奇怪的东西时,即刻发出警报. 把电话对准,找到可以找的地方.';

  @override
  String get downloadApp => 'QQ 下载 App';

  @override
  String get viewAllBeeps => 'QQ 查看全部蜂窝';

  @override
  String get sightingsMap => '图像';

  @override
  String get globalSightingNetwork => '全球观察网';

  @override
  String get howItWorks => '如何UFOBEP工作';

  @override
  String get backToBeeps => '回到蜂窝';

  @override
  String get loadingDetails => '正在装入哔声细节...';

  @override
  String get details => '细节';

  @override
  String get location => '地点';

  @override
  String get timeAgo => '刚才';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => '公里';

  @override
  String get distanceMiles => '英里数';

  @override
  String get distanceNearby => '附近';

  @override
  String get ufobeepWitnesses => '证人';

  @override
  String get ufobeepConfirmations => '确认';

  @override
  String get ufobeepAlertLevel => '警报级别';

  @override
  String get ufobeepReportType => 'UFOUBUP 报告';

  @override
  String get mufonAttribution => '毛里求斯 数据库报告';

  @override
  String get mufonCaseNumber => '案例#';

  @override
  String get mufonGenericTitle => 'MUFON 观察报告';

  @override
  String get mufonSphere => '球体';

  @override
  String get mufonLight => '光线';

  @override
  String get mufonDisk => '磁盘';

  @override
  String get mufonTriangle => '三角形';

  @override
  String get mufonCigar => '雪茄';

  @override
  String get mufonOval => '奥巴马';

  @override
  String get mufonCylinder => '圆柱';

  @override
  String get mufonRectangle => '矩形';

  @override
  String get mufonDiamond => '钻石';

  @override
  String get mufonFireball => '火球';

  @override
  String get mufonFlash => '闪光';

  @override
  String get mufonFormation => '组建';

  @override
  String get mufonChanging => '变化';

  @override
  String get mufonChevron => '雪佛龙';

  @override
  String get mufonCone => '锥形';

  @override
  String get mufonCross => '交叉';

  @override
  String get mufonEgg => '鸡蛋';

  @override
  String get mufonOther => '对象';

  @override
  String get mufonUnknown => '未知对象';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON  报告';
  }

  @override
  String get nuforcAttribution => '努福尔茨 数据库报告';

  @override
  String get nuforcCaseNumber => '案例#';

  @override
  String get nuforcGenericTitle => '努福尔茨 观察报告';

  @override
  String get mediaImageNotFound => '未找到图像';

  @override
  String get mediaPlayVideo => '播放视频';

  @override
  String get mediaViewImage => '查看图像';

  @override
  String mediaCount(Object count) {
    return '图像';
  }

  @override
  String get mediaCountSingle => '1 张图像';

  @override
  String mediaMoreImages(Object count) {
    return '再来点';
  }

  @override
  String get errorNotFound => '未找到哔声';

  @override
  String get errorLoadError => '装入哔声细节失败';

  @override
  String get shareYourThoughts => '分享你对这次目击的看法...';

  @override
  String get postComment => '邮政注释';

  @override
  String get loggedInAs => '登录为';

  @override
  String get logout => '注销';

  @override
  String get notFollowing => '没有';

  @override
  String get follow => '跟着';

  @override
  String get navRecentBeeps => '最近的蜂类';

  @override
  String get navMap => '地图';

  @override
  String get navDownloadApp => '下载 App';

  @override
  String get alertLevel => '警报级别';

  @override
  String get witnesses => '证人';

  @override
  String get confirmations => '确认';

  @override
  String get reporterLabel => '用户报告';

  @override
  String get coordinatesLabel => '坐标';

  @override
  String get eventTime => '活动时间';

  @override
  String get reportedTime => '报告时间';

  @override
  String get mufonDatabaseReport => '毛里求斯 数据库报告';

  @override
  String get copyShortLinkTitle => '复制链接到剪贴板';

  @override
  String get imageNotFound => '未找到图像';

  @override
  String get ufoSightingAlt => '不明飞行物目击';
}
