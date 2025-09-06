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
    return '离开';
  }

  @override
  String alertDirection(int bearing) {
    return '方位为_PH_0_%';
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
    return '报告作者:_PH_0__';
  }

  @override
  String reportedAt(String timeAgo) {
    return '报告 _PH_0__';
  }

  @override
  String distanceAway(String distance) {
    return '离开';
  }

  @override
  String bearingToObject(int bearing) {
    return '反对: - PH_0+++++++++++++++++++++++++++++++++++++';
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
  String get noCommentsYet => '还没有评论。 成为第一个!';

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
    return '指向 _PH_0__ (中文(简体) )';
  }

  @override
  String get calibratingCompass => '校准指南针..';

  @override
  String get openAROverlay => '打开 AR 覆盖';

  @override
  String get pushTitleAlertNearby => '你身边的UFO警报';

  @override
  String pushBodyAlertNearby(String distance) {
    return '据报道,有新的目击地点在_PH_0_离开.';
  }

  @override
  String get pushTitleComment => '新评论';

  @override
  String get pushBodyComment => '有人评论你跟踪的一幕.';

  @override
  String get pushTitleWitness => '证人确认';

  @override
  String get pushBodyWitness => '一个用户确认他们看到了同一个对象.';

  @override
  String get weather => '天气';

  @override
  String cloudCover(int percent) {
    return '云盖曰: - PH_0+++++++++++++++++++++++++++++++++++++';
  }

  @override
  String wind(num speed, String unit) {
    return '风:_PH_0___PH_1_';
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
  String get enablePushNotifications => '启用按键通知';

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
}
