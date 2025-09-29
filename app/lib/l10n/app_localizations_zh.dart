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
    return '离开这里';
  }

  @override
  String alertDirection(int bearing) {
    return '夹着... PLACEHOLDER_0..';
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
  String get locationPermissionTitle => '需要的位置权限';

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
    return '由_PLACEHOLDER_0___报导';
  }

  @override
  String reportedAt(String timeAgo) {
    return '报告_PLACEHOLDER_0__';
  }

  @override
  String distanceAway(String distance) {
    return '– 地点/地点/地点/地点/地点/地点';
  }

  @override
  String bearingToObject(int bearing) {
    return '持械反对:_PLACEHOLDER_0_____________________';
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
    return '指向  _PLACEHOLDER_0__ (英语)';
  }

  @override
  String get calibratingCompass => '校准指南针..';

  @override
  String get openAROverlay => '打开 AR 覆盖';

  @override
  String get pushTitleAlertNearby => '你身边的UFO警报';

  @override
  String pushBodyAlertNearby(String distance) {
    return '[永久失效連結] [永久失效連結] [永久失效連結] 互联网档案馆的存檔,存档日期2013-07-01.';
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
    return '云盖曰: - 地点 - 地点';
  }

  @override
  String wind(num speed, String unit) {
    return '风：$speed $unit';
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
  String get quietHoursEnabled => '启用安静时间';

  @override
  String get quietHoursFrom => '从';

  @override
  String get quietHoursUntil => '直至';

  @override
  String get quietHoursDefaultTime => '默认安静时间';

  @override
  String get emergencyOverride => '紧急控制';

  @override
  String get emergencyOverrideDesc => '允许静时紧急报警';

  @override
  String get dndMode => '不要烦恼';

  @override
  String get dndUntil => '不要打扰到这里';

  @override
  String dndEnabled(Object time) {
    return 'DND 启用至 __ PLACEHOLDER_ 0___';
  }

  @override
  String get dndDisabled => 'DND 已禁用';

  @override
  String get quietHoursActive => '静默时间活动';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return '安静时间: (原始内容存档于2017-09-01) (中文(中国大陆) )';
  }

  @override
  String get pushNotificationUfoAlert => '不明飞行物 警报';

  @override
  String get pushNotificationAnomalyAlert => '异常警报';

  @override
  String get pushNotificationNearby => '临近';

  @override
  String get pushNotificationInYourArea => '在你的区域。 点击查看细节.';

  @override
  String pushNotificationCommented(Object username) {
    return '– PLACEHOLDER_0_ 评论';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '–PLACEHOLDER_0__评论_PLACEHOLDER_1_';
  }

  @override
  String get pushNotificationGeneric => '打开';

  @override
  String get pushNotificationNewSighting => '附近新出现';

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
  String get beepOnly => '只鸣';

  @override
  String get reportOnly => '仅限文本';

  @override
  String get videoOnly => '仅限视频';

  @override
  String get imageOnly => '只有图像';

  @override
  String get mediaOnly => '仅限媒体';

  @override
  String get timeJustNow => '刚才';

  @override
  String timeDaysAgo(int count) {
    return '# 几天前,我来到了这里#';
  }

  @override
  String timeHoursAgo(int count) {
    return '0小时前';
  }

  @override
  String timeMinutesAgo(int count) {
    return '0分钟前';
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
  String get mufonSighting => 'MUFON 观察报告';

  @override
  String get mufonLightSighting => 'MUFON 灯光观察报告';

  @override
  String get mufonSphereSighting => 'MUFON 球面观察报告';

  @override
  String get mufonDiscSighting => '毛里求斯 磁盘透视报告';

  @override
  String get mufonTriangleSighting => '毛里求斯 三角观测报告';

  @override
  String get mufonCigarSighting => 'MUFON 雪茄观察报告';

  @override
  String get mufonOvalSighting => 'MUFON OVAL 观察报告';

  @override
  String get mufonRectangleSighting => '毛里求斯 矩形瞄准报告';

  @override
  String get mufonCylinderSighting => 'MUFON 圆柱形探测报告';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang观察报告';

  @override
  String get mufonStarlikeSighting => '毛里求斯 星光照视报告';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON案 详细情况';
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
    return '分析:_PLACEHOLDER_0_媒体文件已处理';
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
  String get timeFormat => '时间格式';

  @override
  String get timeFormat24Hour => '24小时(14:30)';

  @override
  String get timeFormat12Hour => '12小时(下午2: 30)';

  @override
  String get timeFormatDesc => '以24小时或12小时格式显示时间';

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
  String get ufoSighting => '不明飞行物 警报';

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
  String get showLess => '显示较少';

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
  String get ufoTypeBoomerang => 'Boom';

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
  String get shapeBoomerang => 'boom';

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
  String get attachMedia => '附加媒体';

  @override
  String get addCommentOptional => '添加注释( 可选)';

  @override
  String get describeNewMedia => '描述新媒体...';

  @override
  String get filesSelected => '选中文件';

  @override
  String get selectMediaToAttach => '请选择要附加的照片或视频';

  @override
  String get newMediaUploaded => '新媒体上传';

  @override
  String get mediaFilesUploaded => '上传的新媒体文件';

  @override
  String get filesAttachedSuccessfully => '成功附加文件';

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
    return '毛里求斯 案件QQPLACEHOLDER_0___';
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
  String get notificationSightingTitle => '不明飞行物 警报';

  @override
  String get notificationSightingUrgent => '紧急UFO 警报';

  @override
  String get notificationSightingEmergency => '紧急UFO 警报';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '靠近... PLACEHOLDER_0_ 靠近... PLACEHOLDER_ 1_';
  }

  @override
  String notificationCommentTitle(String username) {
    return '~PLACEHOLDER_0_评论';
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
    return '离开这里';
  }

  @override
  String get unknown => '未知';

  @override
  String get report => '报告';

  @override
  String get mufon => '木冯';

  @override
  String get recentUfoBeepsTitle => '近期的UFO 黄蜂';

  @override
  String get recentUfoBeepsSubtitle => '我们全球社会的目击UFO实况报道';

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
  String get ufoSightingAlert => '不明飞行物 观察警报';

  @override
  String get previousPage => '上一个';

  @override
  String get nextPage => '下一个';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return '页面存档备份,存于互联网档案馆 页面存档备份,存于互联网档案馆 页面存档备份,存于互联网档案馆 页面存档备份,存于互联网档案馆 页面存档备份,存于互联网档案馆 页面存档备份,存于互联网档案馆 页面存档备份,存于互联网档案馆 页面存档备份,存于互联网档案馆 页面存档备份,存于互联网档案馆';
  }

  @override
  String get firstPage => '第一届';

  @override
  String get lastPage => '最后一个';

  @override
  String get jumpToPage => '跳转到页面';

  @override
  String get heroTagline => '什么时候到外面看看';

  @override
  String get heroDescription => '永远不要错过 在你的区域看到另一个UFO';

  @override
  String get downloadApp => 'QQ 下载 App';

  @override
  String get viewAllBeeps => 'QQ 查看全部蜂窝';

  @override
  String get sightingsMap => '图像';

  @override
  String get globalSightingNetwork => '全球观察网';

  @override
  String get howItWorks => '如何运作';

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
    return '毛里求斯 报告';
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
    return '_PLACEHOLDER_0_图像';
  }

  @override
  String get mediaCountSingle => '1 张图像';

  @override
  String mediaMoreImages(Object count) {
    return '再来一点';
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
  String get addedToUfobeep => '添加到UFOBEP';

  @override
  String get mufonDatabaseReport => '毛里求斯 案件编号 :';

  @override
  String get copyShortLinkTitle => '复制链接到剪贴板';

  @override
  String get imageNotFound => '未找到图像';

  @override
  String get ufoSightingAlt => '不明飞行物 哔声UFO警报';

  @override
  String get celestialDataTitle => '天体';

  @override
  String get visiblePlanets => '可见行星';

  @override
  String get locationDataTitle => '地点信息';

  @override
  String get timezone => '时区';

  @override
  String get coordinates => '坐标';

  @override
  String get processingSummaryTitle => '处理摘要';

  @override
  String get processingTime => '处理时间';

  @override
  String get successful => '成功';

  @override
  String get failed => '失败';

  @override
  String get locationEnrichmentTitle => '地点细节';

  @override
  String get aircraftDataSource => '数据来源';

  @override
  String get noAircraftDetected => '未发现飞机';

  @override
  String get sightingReport => '观察报告';

  @override
  String get ufoAlert => '不明飞行物 警报';

  @override
  String get alert => '警报';

  @override
  String get notificationTickerUfoAlert => 'UFO 警告 - 附近新视觉';

  @override
  String get notificationTickerComment => '关于 UFO 提醒的新注释';

  @override
  String get weatherConditions => '天气条件';

  @override
  String get visibility => '可见度';

  @override
  String get humidity => '湿度';

  @override
  String get pressure => '压力';

  @override
  String get locationDetails => '地点细节';

  @override
  String get city => '城市';

  @override
  String get state => '状态';

  @override
  String get country => '国家';

  @override
  String get satelliteActivity => '卫星活动';

  @override
  String get satellitesVisibleOverhead => '视时间和地点可见的卫星';

  @override
  String get dataSource => '数据来源';

  @override
  String get blackskyImagery => '黑色天空图像';

  @override
  String get resolution => '决议';

  @override
  String get groundResolution => '35厘米地面分辨率';

  @override
  String get delivery => '交付';

  @override
  String get averageDelivery => '平均90分钟';

  @override
  String get cost => '费用';

  @override
  String get skyfiSatelliteImagery => '天线卫星 图像';

  @override
  String get region => '地区';

  @override
  String get remoteArea => '远程区域';

  @override
  String get startingPrice => '开始价格';

  @override
  String get coverage => '覆盖范围';

  @override
  String get confidenceCoverage => '95%的信心';

  @override
  String get status => '状态';

  @override
  String get shareThoughts => '分享你对这次目击的看法...';

  @override
  String get postCommand => '邮局命令';

  @override
  String get clouds => '云层';

  @override
  String get windLabel => '风';

  @override
  String get filterAlerts => '过滤提醒';

  @override
  String get alertSource => '警告来源';

  @override
  String get ufobeepOnly => '仅限UUOBEP';

  @override
  String get ufobeepOnlyDescription => '只显示原始UFOBEP报告(不包括MUFON数据库)';

  @override
  String get alertDistanceRange => '警报距离';

  @override
  String get showAllAlerts => '显示全部提醒';

  @override
  String get showAll => '全部显示';

  @override
  String get distanceSliderDescription =>
      '拖曳以调整要看到提示的距离 。 从天气可见度距离开始,到显示所有警报,无论距离.';

  @override
  String get applyFilters => '应用过滤器';

  @override
  String get notificationRange => '通知范围';

  @override
  String get notificationRangeDescription => '得到推进警报,在这个距离内看到';

  @override
  String get viewingRange => '查看范围';

  @override
  String get viewingRangeDescription => '浏览时显示此距离内的目视';

  @override
  String get weatherVisibility => '天气可见度( ~10km)';

  @override
  String get localArea => '地区(25公里)';

  @override
  String get regional => '区域';

  @override
  String get pushNotifications => '推动通知';

  @override
  String get alertBrowsing => '提醒浏览';

  @override
  String get pushAlertsWithinDistance => '在此范围内获取通知';

  @override
  String get showAlertsWhenBrowsing => '过滤列表中看到的内容';

  @override
  String get heroMainTagline => '当不明飞行物在附近发现时,在手机上鸣声';

  @override
  String get heroSecondaryTagline => '找出何时何地看天空';

  @override
  String get sourceFilters => '来源';

  @override
  String get sourceFiltersDescription => '选择种子中出现的报告';

  @override
  String get ufobeepAndMufon => 'UFOBEP + 毛里求斯';

  @override
  String get ufobeepOnlySource => '仅限UUOBEP';

  @override
  String get mufonOnlySource => '仅指毛里求斯';

  @override
  String get browseFilters => '浏览';

  @override
  String get browseFiltersDescription => '如何查看和排序提醒';

  @override
  String get sortByNewest => '最新数据';

  @override
  String get sortByNearest => '最接近';

  @override
  String get sortBy => '排序为';

  @override
  String get pushAlertsTitle => '推进提醒';

  @override
  String get pushAlertsDescription => '手机响什么';

  @override
  String get alertRadius => '提醒半径';

  @override
  String get mufonNoPushInfo => 'MUFON报告是夜间输入的,不会触发推力警报';

  @override
  String get privacyData => '隐私数据( D)';

  @override
  String get privacyPolicyDesc => '我们如何保护和使用你的数据';

  @override
  String get termsOfService => '服务条件';

  @override
  String get termsOfServiceDesc => '法律条款和条件';

  @override
  String get locationTracking => '地点跟踪';

  @override
  String get locationTrackingDesc => '近距离警报的背景位置';

  @override
  String get locationTrackingTitle => '背景位置跟踪';

  @override
  String get locationTrackingExplanation =>
      'UFOBEP在背景中监视你的位置,当UFO的目击发生在你现在的位置附近时,即使你远离家,也会发出近距离警报.';

  @override
  String get locationTrackingBattery => '使用智能地球圈进行 < 3% 电池撞击';

  @override
  String get backgroundLocationTracking => '启用背景 跟踪';

  @override
  String get locationTrackingActive => '监测近距离警报的地点';

  @override
  String get locationTrackingInactive => '位置跟踪已禁用';

  @override
  String get locationTrackingDisabledWarning => '搬去新地方时,不会收到近距离警报';

  @override
  String get trackingStatus => '跟踪状态';

  @override
  String get monitoringStatus => '监测';

  @override
  String get active => '活动';

  @override
  String get inactive => '非活动';

  @override
  String get lastKnownLocation => '最后已知位置';

  @override
  String get lastLocationUpdate => '上次更新';

  @override
  String get movementThreshold => '移动阈值';

  @override
  String get updateFrequency => '更新频率';

  @override
  String get batteryImpact => '电池撞击';

  @override
  String get dataPrivacy => '数据隐私';

  @override
  String get locationPermissionExplanation =>
      'UFOBEP需要“ 永远允许” 位置权限来监视您的移动, 并在您在新位置时发出近距离警报 .';

  @override
  String get benefitsTitle => '福利';

  @override
  String get locationTrackingBenefits =>
      '• 支助 无论你在哪里旅行,都要收到UFO警报\n• 自动更新位置\n• 支助 不需要手动设置';

  @override
  String get allowLocationAccess => '允许访问位置';

  @override
  String get locationPermissionRequired => '背景跟踪需要位置许可';

  @override
  String get locationTrackingEnabled => '背景位置跟踪启用';

  @override
  String get locationTrackingDisabled => '背景位置跟踪已禁用';

  @override
  String get justNow => '刚才';

  @override
  String minutesAgo(int minutes) {
    return '0分钟前';
  }

  @override
  String hoursAgo(int hours) {
    return '0小时前';
  }

  @override
  String daysAgo(int days) {
    return '# 几天前,我来到了这里#';
  }

  @override
  String get dataManagement => '数据管理';

  @override
  String get dataManagementDesc => '导出或删除您的账户数据';

  @override
  String get splashTagline => '实时目视警报';

  @override
  String get splashStartingUp => '开始...';

  @override
  String get splashInitializationFailed => '初始化失败';

  @override
  String get splashInitializationFailedTitle => '初始化失败';

  @override
  String get splashInitializationError => '应用程序未正确初始化 :';

  @override
  String get splashRetry => '重试';

  @override
  String get splashContinue => '继续';

  @override
  String get splashInitializing => '正在初始化...';

  @override
  String signInWelcome(String username) {
    return '欢迎光临!';
  }

  @override
  String signInFailed(String error) {
    return '签名失败 : – 地点/地点/地点/地点/地点/地点';
  }

  @override
  String get signInPleaseEnterEmail => '请输入您的电子邮件地址';

  @override
  String get signInPleaseEnterValidEmail => '请输入有效的电子邮件地址';

  @override
  String get signInMagicLinkSent => '传送魔法链接! 检查您的电子邮件并点击链接签名 .';

  @override
  String get signInMagicLinkFailed => '发送魔法链接失败 。 请再试一次.';

  @override
  String get signInAllDataCleared => '所有数据已清理';

  @override
  String get signInSubtitle => '实时UFO目击警报和MUFON报告';

  @override
  String get signInGoogleLoading => '签名于...';

  @override
  String get signInContinueWithGoogle => '继续谷歌';

  @override
  String get signInOr => '或';

  @override
  String get signInWithEmail => '用电子邮件签名';

  @override
  String get signInEmailDescription => '我们会给你一个安全的链接 来注册';

  @override
  String get signInEmailAddress => '电子邮件地址';

  @override
  String get signInEmailPlaceholder => '请检查date=中的日期值 (帮助) your@email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return '在 _PLACEHOLDER_0_s中再次尝试';
  }

  @override
  String get signInSending => '正在发送...';

  @override
  String get signInSendMagicLink => '发送魔法链接';

  @override
  String get signInCheckEmail => '检查你的电子邮件! 链接在15分钟后到期.';

  @override
  String get signInSecureAuth => '安全认证';

  @override
  String get signInSecureAuthDescription =>
      '使用Google Sign-In进行即时访问,或者在15分钟内过期的电子邮件魔法链接.';

  @override
  String get signInClearAllDataDebug => '清除全部数据( 调试)';

  @override
  String get emailAuthFailedToSend => '发送邮件失败';

  @override
  String get emailAuthFailedToSendTryAgain => '发送邮件失败 。 请再试一次.';

  @override
  String get emailAuthInvalidEmail => '无效的电子邮件地址 。 请检查格式 .';

  @override
  String get emailAuthUserNotFound => '此电子邮件地址找不到账户 .';

  @override
  String get emailAuthTooManyRequests => '尝试太多。 请稍候再试.';

  @override
  String get emailAuthOperationNotAllowed => '未启用电子邮件链接签名 .';

  @override
  String get emailAuthQuotaExceeded => '电子邮件配额超过。 明天再试一次.';

  @override
  String get emailAuthVerificationFailed => '电子邮件验证失败 。 请再试一次.';

  @override
  String get emailAuthTitle => '电子邮件验证';

  @override
  String get emailAuthVerifyYourEmail => '校验您的电子邮件';

  @override
  String get emailAuthDescription => '添加您的电子邮件地址, 用于账户恢复和安全 。 我们会给你发送一个安全登录链接.';

  @override
  String get emailAuthEmailAddress => '电子邮件地址';

  @override
  String get emailAuthEmailPlaceholder => '电子邮件@example.com';

  @override
  String get emailAuthPleaseEnterEmail => '请输入您的电子邮件地址';

  @override
  String get emailAuthPleaseEnterValidEmail => '请输入有效的电子邮件地址';

  @override
  String get emailAuthCheckEmailToContinue => '检查您的电子邮件, 并点击验证链接继续 .';

  @override
  String get emailAuthResendEmail => '重新发送电子邮件';

  @override
  String get emailAuthSendVerificationEmail => '发送验证 电子邮件';

  @override
  String get emailAuthHowItWorks => '电子邮件核查工作如何进行';

  @override
  String get emailAuthHowItWorksSteps =>
      '一、导 言 我们给你发送一个安全的登录链接\n2. 国家 检查您的电子邮件并点击链接\n3个 您的电子邮件会自动校验\n4个 不需要密码!';

  @override
  String get emailAuthSecurityNotice => '电子邮件验证有助于保护您的账户, 并允许在无法访问您的设备时恢复账户 .';

  @override
  String get phoneAuthFailedToSendCode => '发送验证码失败 。 请再试一次.';

  @override
  String get phoneAuthInvalidCodeTryAgain => '无效的校验代码 。 请再试一次.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return '经核实的电话号码: – 地点/地点/地点/地点/地点/地点';
  }

  @override
  String get phoneAuthVerificationFailed => '电话验证失败 。 请再试一次.';

  @override
  String get phoneAuthCodeResent => '核查码很讨厌';

  @override
  String get phoneAuthFailedToResendCode => '重新发送代码失败 。 请再试一次.';

  @override
  String get phoneAuthInvalidPhoneNumber => '无效的电话号码 。 请检查格式 .';

  @override
  String get phoneAuthTooManyRequests => '尝试太多。 请稍候再试.';

  @override
  String get phoneAuthInvalidVerificationCode => '无效的校验代码 。 请再检查一次.';

  @override
  String get phoneAuthSessionExpired => '核查会话到期 。 请申请新的代码 .';

  @override
  String get phoneAuthSmsQuotaExceeded => '短信配额超过。 明天再试一次.';

  @override
  String get phoneAuthCredentialAlreadyInUse => '这个电话号码已经链接到另一个账户 .';

  @override
  String get phoneAuthVerificationFailedGeneric => '验证失败 。 请再试一次.';

  @override
  String get phoneAuthTitle => '电话验证';

  @override
  String get phoneAuthVerifyYourPhone => '校验您的手机';

  @override
  String get phoneAuthEnterVerificationCode => '输入校验 代码';

  @override
  String get phoneAuthAddPhoneForSecurity => '添加您的电话号码用于账户恢复和安全';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return '输入发送到 _PLACEHOLDER_0__的6位数代码';
  }

  @override
  String get phoneAuthPhoneNumber => '电话号码';

  @override
  String get phoneAuthPhonePlaceholder => '+1(555) 123-4567';

  @override
  String get phoneAuthPleaseEnterPhone => '请输入您的电话号码';

  @override
  String get phoneAuthPleaseEnterValidPhone => '请输入有效的电话号码';

  @override
  String get phoneAuthVerificationCode => '核查码';

  @override
  String get phoneAuthPleaseEnterSixDigitCode => '请输入六位数代码';

  @override
  String get phoneAuthResendCode => '重新发送代码';

  @override
  String get phoneAuthSendVerificationCode => '发送验证 代码';

  @override
  String get phoneAuthVerifyCode => '校验代码';

  @override
  String get phoneAuthChangePhoneNumber => '更改电话号码';

  @override
  String get phoneAuthSmsNotice => '我们会通过短信给你一个验证码 可适用标准的信息费率.';

  @override
  String get phoneAuthCodeExpires => '代码在60秒后失效 检查您的留言.';

  @override
  String get yourDataRights => '您的数据权限';

  @override
  String get dataRightsExplanation => '你完全控制你的个人资料 您可以随时导出您的全部数据或永久删除您的账户 .';

  @override
  String get exportYourData => '导出您的数据';

  @override
  String get exportDataDescription => '下载您的账户数据';

  @override
  String get exportData => '导出数据';

  @override
  String get exportingData => '导出中...';

  @override
  String get exportDataDetails => '包括:剖面图,哔声,评论,设备信息,以及首选项. 数据以JSON格式提供.';

  @override
  String get dataExportedSuccessfully => '数据成功导出';

  @override
  String get dataExportFailed => '导出数据失败';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get deleteAccountDescription => '永久删除您的账户和所有数据';

  @override
  String get deleteAccountWarning => '这一行动不能取消。 您的所有哔声、 评论和账户数据将被永久删除 .';

  @override
  String get deleteMyAccount => '删除我的账户';

  @override
  String get deletingAccount => '正在删除...';

  @override
  String get deleteAccountConfirmTitle => '删除账户';

  @override
  String get deleteAccountConfirmMessage => '您确定要删除您的账户吗 ? 这一行动是永久性的,不能取消.';

  @override
  String get dataWillBeDeleted => '以下数据将永久删除:';

  @override
  String get deletedDataList =>
      '• 支助 您的配置和用户名\n• 支助 所有你的哔声和报告\n• 支助 所有你的评论\n• 设备登记数据\n• 地点和偏好数据';

  @override
  String get deleteAccountPermanent => '永久删除';

  @override
  String get accountDeletedSuccessfully => '账户已成功删除';

  @override
  String get accountDeletionFailed => '删除账户失败';

  @override
  String get onboardingWelcomeTitle => '欢迎来到UFOBEP';

  @override
  String get onboardingWelcomeBody => '当不明飞行物在附近被发现时,获得实时警报. 永远不要错过一次目击.';

  @override
  String get onboardingAlertsTitle => '保持知情';

  @override
  String get onboardingAlertsBody => '设定视线应该有多远才能触发警报.';

  @override
  String get onboardingReportTitle => '看到什么了吗? 鸣吧!';

  @override
  String get onboardingReportBody => '立即与附近的观察者分享照片或录像.';

  @override
  String get onboardingPermissionsTitle => '您的相机位置( L)';

  @override
  String get onboardingPermissionsBody =>
      '启用相机、 位置和通知, 您可以:\n- 快速报告目击情况\n- 说吧 通知你身边的不明飞行物';

  @override
  String get onboardingCameraTitle => '抓取证据';

  @override
  String get onboardingCameraBody => '分享你刚从画廊里拍到的照片和视频 或长压UFOBEP图标 以即时相机模式开始.';

  @override
  String get onboardingCompassTitle => '看他们看哪里';

  @override
  String get onboardingCompassBody => 'Compass告诉你目击证人看到UFO时正在寻找的确切方向. 指着手机看!';

  @override
  String get onboardingCommunityTitle => '加入监视天空的人';

  @override
  String get onboardingCommunityBody => '浏览目击,访问MUFON报告,并与同行的天空观察者连接.';

  @override
  String get skip => '跳过';

  @override
  String get getStarted => '开始';

  @override
  String get viewOnboardingAgain => '再次查看登机';

  @override
  String get customAlertRange => '自定义提醒范围';

  @override
  String get enterRangeKm => '输入范围,公里(1-99999)';

  @override
  String get largeRangeWarning => '大范围( > 100km)可能产生许多警报';

  @override
  String get globalRangeWarning => '非常大的范围( > 1 000km)将发出来自世界各地的警报';

  @override
  String get invalidRange => '请输入1到99999之间的数字';

  @override
  String get celestialSunDaylight => '太阳升起 -- -- 日光条件可能影响可见度';

  @override
  String get celestialSunTwilight => '暮色的条件 - 一些能见度但比日光更暗';

  @override
  String get celestialSunDark => '黑暗条件 - 在天空中观测天体的最佳条件';

  @override
  String celestialMoonBright(Object phase) {
    return '明亮的  _PLACEHOLDER_ 0_ 月亮可见 - 可能照亮或模糊其他物体';
  }

  @override
  String celestialMoonModerate(Object phase) {
    return '月亮可见度 - 中等照明条件';
  }

  @override
  String celestialMoonThin(Object phase) {
    return '细小的月亮可见度最小';
  }

  @override
  String celestialMoonHidden(Object phase) {
    return '- PLACEHOLDER_0__ 地平线以下的月亮 - 没有月光';
  }

  @override
  String get celestialNoPlanets => '没有可以被误认为UFO的明亮行星';

  @override
  String celestialPlanetHigh(Object altitude, Object planet) {
    return '- PLACEHOLDER_0__ 高管理(__PLACEHOLDER_1+) - 非常突出';
  }

  @override
  String celestialPlanetMedium(Object altitude, Object planet) {
    return '—— PLACEHOLDER_0_ 可见于_PLACEHOLDER_1_ ——可能误认为飞机';
  }

  @override
  String celestialPlanetLow(Object altitude, Object planet) {
    return '- PLACEHOLDER_0_ 低地平线(_PLACEHOLDER_1_+)';
  }

  @override
  String get celestialNoStars => '没有异常亮的星星可见';

  @override
  String celestialStarSingle(Object altitude, Object star) {
    return '位置: 高度: 高度: 高度: 高度: 高度:';
  }

  @override
  String celestialStarsMultiple(Object count, Object names) {
    return '- PLACEHOLDER_0_ 明亮的恒星可见 - _PLACEHOLDER_1_';
  }

  @override
  String get celestialSummaryDaylight => '日光条件';

  @override
  String get celestialSummaryDark => '黑暗的天空条件';

  @override
  String get celestialSummaryMoonUp => '月亮照现';

  @override
  String get celestialSummaryMoonDown => '没有月光';

  @override
  String celestialSummaryManyObjects(Object count) {
    return '_PLACEHOLDER_0_ 与UFO相混淆的亮天体';
  }

  @override
  String celestialSummarySomeObjects(Object count) {
    return '_PLACEHOLDER_ 0_ 亮物体可见';
  }

  @override
  String get celestialSummaryFewObjects => '天空中最小亮度对象';

  @override
  String celestialSkySummary(Object conditions) {
    return '天空条件 : – 地点/地点/地点/地点/地点/地点';
  }

  @override
  String get planetVenus => '金星';

  @override
  String get planetJupiter => '木星( 木星)';

  @override
  String get planetSaturn => '土星号';

  @override
  String get planetMars => '火星';

  @override
  String get planetMercury => '汞';

  @override
  String get planetUranus => '天王星';

  @override
  String get planetNeptune => '海王星号';

  @override
  String get starSirius => '天狼星号';

  @override
  String get starCanopus => '卡诺普斯';

  @override
  String get starArcturus => '阿克图鲁斯';

  @override
  String get starVega => '维嘉';

  @override
  String get starCapella => '卡贝拉';

  @override
  String get starRigel => '刚性';

  @override
  String get starProcyon => '亲子';

  @override
  String get starBetelgeuse => '贝特尔吉斯';

  @override
  String get moonPhaseNew => '新月亮';

  @override
  String get moonPhaseWaxingCrescent => '蜡新月';

  @override
  String get moonPhaseFirstQuarter => '第一季度';

  @override
  String get moonPhaseWaxingGibbous => '蜡光吉布斯';

  @override
  String get moonPhaseFull => '满月';

  @override
  String get moonPhaseWaningGibbous => '瓦宁・吉布斯';

  @override
  String get moonPhaseThirdQuarter => '第三季度';

  @override
  String get moonPhaseWaningCrescent => '万灵新月';

  @override
  String planetBelowHorizon(Object planet) {
    return '地平线以下的 PLACEHOLDER_ 0__';
  }

  @override
  String planetHighOverheadProminent(Object altitude, Object planet) {
    return '- PLACEHOLDER_0__ 高管理(__PLACEHOLDER_1+) - 非常突出';
  }

  @override
  String planetMidSkyProminent(Object altitude, Object planet) {
    return '- PLACEHOLDER_0_ at ^ PLACEHOLDER_ 1_ - 显著位置';
  }

  @override
  String planetMidSky(Object altitude, Object planet) {
    return '地点:';
  }

  @override
  String starVeryBright(Object altitude, Object star) {
    return '时非常亮';
  }

  @override
  String starProminent(Object altitude, Object star) {
    return '位置: 高度: 高度: 高度: 高度: 高度:';
  }

  @override
  String starVisible(Object altitude, Object star) {
    return '地点:';
  }

  @override
  String get altitudeShort => '备选案文';

  @override
  String get magnitudeShort => '马格';

  @override
  String satellitesVisibleMightExplain(Object count) {
    return '——PLACEHOLDER_0_ 可见的卫星 - 可以解释目击';
  }

  @override
  String satellitesVisibleUnlikelyExplain(Object count) {
    return '* PLACEHOLDER_0_ 卫星可见- 不太可能解释目击';
  }

  @override
  String get noSatellitesVisible => '没有可见的卫星';

  @override
  String aircraftDetectedInRadius(Object count, Object radius) {
    return '在_PLACEHOLDER_0_公里范围内探测到的飞机';
  }

  @override
  String get processingAlert => '正在处理 UFO 提醒...';

  @override
  String get analyzingEnvironment => '分析环境状况';

  @override
  String get weatherAnalysis => '天气分析';

  @override
  String get locationAnalysis => '地点分析';

  @override
  String get aircraftTracking => '飞机跟踪';

  @override
  String get satelliteAnalysis => '卫星分析';

  @override
  String get celestialAnalysis => '天体分析';

  @override
  String analyzing(Object processor) {
    return '分析_PLACEHOLDER_0_......';
  }

  @override
  String get processorWeather => '天气状况';

  @override
  String get processorLocation => '地点细节';

  @override
  String get processorAircraft => '附近飞机';

  @override
  String get processorSatellites => '卫星位置';

  @override
  String get processorCelestial => '天体';

  @override
  String get calculatingCelestialData => '计算天体数据...';

  @override
  String get sunLabel => '太阳';

  @override
  String get moonLabel => '月亮';

  @override
  String planetsVisible(int count) {
    return '行星:_PLACEHOLDER_0_可见';
  }

  @override
  String get starsLabel => '恒星数';

  @override
  String get planetsLabel => '行星';

  @override
  String moonWithPhase(String phase) {
    return '月球( __ PLACEHOLDER_ 0__)';
  }

  @override
  String get noSatellitesVisibleAtTime => '在你的目击时间没有看到卫星';

  @override
  String get satellitesVisibleOverheadAtTime => '视时间和地点可见的卫星';

  @override
  String get belowHorizon => '地平线以下';

  @override
  String get analysisFailedGeneric => '分析失败';

  @override
  String get unknownWeather => '未知';

  @override
  String get noWeatherDescription => '无说明';

  @override
  String get altitudeAbbrev => '备选案文';

  @override
  String get azimuthAbbrev => '阿兹';

  @override
  String satellitesVisibleNow(int count) {
    return '卫星($count现在可见)';
  }

  @override
  String sunWithDescription(String description) {
    return '太阳:_PLACEHOLDER_0_';
  }

  @override
  String moonWithDescription(String description) {
    return '月球: ~ PLACEHOLDER_0_ 月球主题 月球主题';
  }

  @override
  String get unknownPlanet => '未知行星';

  @override
  String get unknownStar => '未知恒星';

  @override
  String get unknownSatellite => '未知的卫星';

  @override
  String get unknownDirection => '未知的方向';

  @override
  String get brightStars => '闪亮的恒星';

  @override
  String get satellites => '卫星';

  @override
  String seeAllSatellites(int count) {
    return '见所有_PLACEHOLDER_0_ 卫星';
  }

  @override
  String maxElevation(String degrees) {
    return '最大海拔 : - 地点 - 地点';
  }

  @override
  String magnitude(String value) {
    return '宽度 : – 地点/地点/地点/地点/地点/地点';
  }

  @override
  String get unknownGeneric => '未知';

  @override
  String altitudeValue(String degrees) {
    return '高度为0';
  }

  @override
  String azimuthValue(String degrees) {
    return '方位角数';
  }

  @override
  String get noCelestialDataAvailable => '无天体数据可用.';

  @override
  String get gettingLocation => '找到你们的位置...';

  @override
  String get media => '媒体';

  @override
  String get locationRequired => '所需地点';

  @override
  String get confirmingWitness => '确认证人...';

  @override
  String get chooseYourUsername => '选择您的用户名';

  @override
  String get moreNames => 'More Names';

  @override
  String get weatherClear => '清除';

  @override
  String get weatherClearSky => '天空清净';

  @override
  String get rain => '风雨';

  @override
  String get snow => '雪';

  @override
  String get thunderstorm => '暴风雨';

  @override
  String get drizzle => '滴滴声';

  @override
  String get fog => '雾';

  @override
  String get fewClouds => '少数云';

  @override
  String get scatteredClouds => '散开的云';

  @override
  String get brokenClouds => '断云';

  @override
  String get overcastClouds => '覆盖云';

  @override
  String get lightRain => '轻雨';

  @override
  String get moderateRain => '中等雨量';

  @override
  String get heavyRain => '暴风雨';

  @override
  String aircraftDetectedCurrentPositions(
    int count,
    String radius,
    Object raggio,
  ) {
    return '在_PLACEHOLDER_0_km(现有位置)内探测到的飞机';
  }

  @override
  String dimSatellitesUnlikely(int count) {
    return '* PLACEHOLDER_0_ 显微卫星 - 不太可能解释目击';
  }

  @override
  String get mufonReportingDate => '毛里求斯 报告日期';

  @override
  String satelliteNameDirection(String name, String direction) {
    return '(原始内容存档于2017-09-01) (中文(中国大陆) )';
  }
}
