// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'НЛО Бип';

  @override
  String get ok => 'ХОРОШО';

  @override
  String get cancel => 'Отменить';

  @override
  String get close => 'Закрыть';

  @override
  String get save => 'Спасти';

  @override
  String get delete => 'Исключить';

  @override
  String get edit => 'Редактировать';

  @override
  String get retry => 'Повторять';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get back => 'Назад';

  @override
  String get next => 'Следующий';

  @override
  String get done => 'Сделано';

  @override
  String get loading => 'Загрузка..';

  @override
  String get processing => 'Обработка..';

  @override
  String get errorGeneric => 'Что-то пошло не так.';

  @override
  String get networkError => 'Ошибка сети. Проверьте свою связь.';

  @override
  String get permissionsRequired => 'Требуемые разрешения';

  @override
  String get learnMore => 'Узнать больше';

  @override
  String get welcomeTitle => 'Добро пожаловать в UFOBeep';

  @override
  String get welcomeSubtitle => 'НЛО в реальном времени рядом с вами';

  @override
  String get signIn => 'Войти';

  @override
  String get signOut => 'Подпишитесь';

  @override
  String get continueAsGuest => 'Продолжайте как гость';

  @override
  String get enterUsername => 'Введите имя пользователя';

  @override
  String get username => 'Имя пользователя';

  @override
  String get usernameUpdated => 'Имя пользователя обновлено';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get tabAlerts => 'Оповещения';

  @override
  String get tabBeep => 'Бип';

  @override
  String get tabChat => 'Чат';

  @override
  String get tabMap => 'Карта';

  @override
  String get tabSettings => 'Настройки';

  @override
  String get alertsTitle => 'Близкие оповещения';

  @override
  String get noAlerts => 'Никаких предупреждений поблизости пока нет.';

  @override
  String get pullToRefresh => 'Потянуть освежиться';

  @override
  String alertDistance(String distance) {
    return '$distance вдали';
  }

  @override
  String alertDirection(int bearing) {
    return 'Подшипник $bearing°';
  }

  @override
  String get viewAlert => 'Внимание';

  @override
  String get viewOnMap => 'Посмотреть на карте';

  @override
  String get iSeeItToo => 'Я тоже это вижу';

  @override
  String get confirmWitnessed => 'Подтвердите, что видели это?';

  @override
  String get witnessConfirmed => 'Спасибо, ваше подтверждение опубликовано.';

  @override
  String get createBeepTitle => 'Отправить Бип';

  @override
  String get beepExplain =>
      'Захватывайте то, что видите, и предупреждайте близких наблюдателей.';

  @override
  String get capturePhoto => 'Захват фото';

  @override
  String get captureVideo => 'Захват видео';

  @override
  String get pickFromGallery => 'Выбрать из галереи';

  @override
  String get descriptionHint => 'Опишите, что вы видите в небе..';

  @override
  String get submitBeep => 'Отправить Бип';

  @override
  String get beepSent => 'Пип отправлен';

  @override
  String get uploadingMedia => 'Загрузка медиа..';

  @override
  String get includeLocation => 'Включает местоположение';

  @override
  String get includeTimestamp => 'Включая временную метку';

  @override
  String get beepFailed => 'Не удалось отправить Бип.';

  @override
  String get mediaProcessing => 'Обработка медиа..';

  @override
  String get cameraPermissionTitle => 'Доступ к камере необходим';

  @override
  String get cameraPermissionBody =>
      'Предоставление доступа к камере для съемки фотографий и видео НЛО.';

  @override
  String get locationPermissionTitle => 'Доступ к местоположению необходим';

  @override
  String get locationPermissionBody =>
      'Мы используем ваше местоположение для отправки и получения близлежащих предупреждений.';

  @override
  String get microphonePermissionTitle => 'Доступ к микрофону необходим';

  @override
  String get microphonePermissionBody =>
      'Предоставление микрофонного доступа для захвата видео с помощью аудио.';

  @override
  String get openSettings => 'Открытые настройки';

  @override
  String get alertDetailTitle => 'Прицельные детали';

  @override
  String reportedBy(String username) {
    return 'Об этом сообщает $username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Об этом сообщает $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '$distance вдали';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Возражать против: $bearing';
  }

  @override
  String get openCompass => 'Открытый компас';

  @override
  String get openAR => 'Оверлей Open AR';

  @override
  String get openChat => 'Открытый чат';

  @override
  String get commentsTitle => 'Комментарий';

  @override
  String get addComment => 'Добавить комментарий..';

  @override
  String get send => 'Отправить';

  @override
  String get commentPosted => 'Комментарий опубликован';

  @override
  String get autoFollowEnabled => 'Теперь вы следуете этому предупреждению.';

  @override
  String get noCommentsYet => 'Никаких комментариев. Будь первым!';

  @override
  String get newCommentNotification =>
      'Новый комментарий о том, что вы видите.';

  @override
  String get mapTitle => 'Живая карта';

  @override
  String get compassTitle => 'Компас';

  @override
  String get compassSettings => 'Компасные настройки';

  @override
  String get compassMode => 'Компактный режим';

  @override
  String get compassStandardMode => 'Стандартный режим';

  @override
  String get compassPilotMode => 'Пилотный режим';

  @override
  String get compassStandardDescription => 'Основной заголовок и навигация';

  @override
  String get compassPilotDescription =>
      'Продвинутая навигация с ETA и вектором';

  @override
  String pointingTo(String direction) {
    return 'Указывает на $direction';
  }

  @override
  String get calibratingCompass => 'Калибровка компаса..';

  @override
  String get openAROverlay => 'Оверлей Open AR';

  @override
  String get pushTitleAlertNearby => 'НЛО рядом с вами';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Об этом сообщает $distance.';
  }

  @override
  String get pushTitleComment => 'Новый комментарий';

  @override
  String get pushBodyComment => 'Кто-то прокомментировал ваше наблюдение.';

  @override
  String get pushTitleWitness => 'Подтверждение свидетеля';

  @override
  String get pushBodyWitness =>
      'Пользователь подтвердил, что видит один и тот же объект.';

  @override
  String get weather => 'Погода';

  @override
  String cloudCover(int percent) {
    return 'Облачное покрытие: $percent%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Ветер: $speed$unit';
  }

  @override
  String get nearbyAircraft => 'Близлежащий самолет';

  @override
  String get noAircraft => 'Самолеты поблизости';

  @override
  String get loadingContext => 'Загрузка экологического контекста..';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get notifications => 'Уведомления';

  @override
  String get enablePushNotifications => 'Включить push-уведомления';

  @override
  String get quietHours => 'Тихие часы';

  @override
  String get quietHoursDesc =>
      'Предупреждение о молчании между выбранными часами.';

  @override
  String get dndMode => 'Не беспокоить';

  @override
  String get dndUntil => 'Не беспокоить, пока';

  @override
  String get language => 'Язык языка';

  @override
  String get chooseLanguage => 'Выберите язык';

  @override
  String get units => 'Подразделения';

  @override
  String get unitsImperial => 'Имперский (mi, mph)';

  @override
  String get unitsMetric => 'Метрика (км, км/ч)';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfUse => 'Условия использования';

  @override
  String get errorNoLocation =>
      'Место недоступно. Попробуйте снова выйти на улицу с ясным видом на небо.';

  @override
  String get errorNoCamera => 'Камера недоступна на этом устройстве.';

  @override
  String get errorUploadFailed =>
      'Загрузить не удалось. Пожалуйста, попробуйте еще раз.';

  @override
  String get errorPermissionDenied => 'Разрешение отказано.';

  @override
  String get errorInvalidUsername => 'Это имя пользователя недоступно.';

  @override
  String get nothingToShow => 'Пока нечего показывать.';

  @override
  String get storeShortDesc =>
      'Мгновенное предупреждение НЛО рядом с вами. Захват, подтверждение и чат в режиме реального времени.';

  @override
  String get storeLongDesc =>
      'UFOBeep отправляет оповещения в режиме реального времени, когда кто-то замечает НЛО поблизости. Захватите фотографии и видео, подтвердите наблюдения с помощью крана, просмотрите направление и расстояние и пообщайтесь с другими наблюдателями неба.';

  @override
  String get keywords =>
      'НЛО, UAP, OVNI, инопланетяне, наблюдения, небесные часы, оповещения, радар, компаст';

  @override
  String get noAlertsFound => 'Никаких совпадающих предупреждений';

  @override
  String get alertsFilterHelp =>
      'Попробуйте настроить фильтры, чтобы увидеть больше результатов';

  @override
  String get verified => 'Проверенный';

  @override
  String get beepOnly => 'только гудок';

  @override
  String get videoOnly => 'только видео';

  @override
  String get imageOnly => 'только изображение';

  @override
  String get timeJustNow => 'Только сейчас';

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
  String get loadMoreAlerts => 'Загрузите больше предупреждений';

  @override
  String get toggleMufonTooltip => 'Наблюдения MUFON';

  @override
  String get showMufonData => 'Показать данные MUFON';

  @override
  String get hideMufonData => 'Скрыть данные MUFON';

  @override
  String get showingUfoBeepOnly => 'Об этом сообщает UFOBeep';

  @override
  String get showingAllReports =>
      'Показать все отчеты, включая базу данных MUFON';

  @override
  String get filteredSuffix => 'фильтрованный';

  @override
  String get detailsTitle => 'Подробности';

  @override
  String get mufonCase => 'МУФОН Дело';

  @override
  String get sightingDate => 'Дата наблюдения';

  @override
  String get databaseEntry => 'Вход в базу данных';

  @override
  String get locationLabel => 'Расположение';

  @override
  String get distanceLabel => 'Расстояние';

  @override
  String get timeLabel => 'Время';

  @override
  String get reportedByLabel => 'Докладчик';

  @override
  String get unknownLocation => 'Неизвестное местоположение';

  @override
  String get locationUnknown => 'Местонахождение неизвестно';

  @override
  String get witnessesLabel => 'Свидетели';

  @override
  String witnessesCountMessage(int count) {
    return '$count люди подтвердили это наблюдение';
  }

  @override
  String get photoAnalysisTitle => 'Анализ фотографий';

  @override
  String mediaItemsProcessed(int count) {
    return 'Анализ: $count медиафайл(ы), обработанный';
  }

  @override
  String get addMoreMedia => 'Добавить больше';

  @override
  String get addMedia => 'Добавить медиа';

  @override
  String get retakePhoto => 'Восстановить фото';

  @override
  String get retakeVideo => 'Восстановить видео';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get basicSettings => 'Основные настройки';

  @override
  String get appSettings => 'Настройки приложений';

  @override
  String get alertRange => 'Диапазон тревоги';

  @override
  String get manageNotificationsDesc => 'Управление подписками и настройками';

  @override
  String get permissionsTitle => 'Разрешения';

  @override
  String get permissionLocation => 'Расположение';

  @override
  String get permissionCamera => 'Камера';

  @override
  String get permissionNotifications => 'Уведомления';

  @override
  String get permissionPhotos => 'Фото';

  @override
  String get permissionGranted => 'Предоставленный';

  @override
  String get permissionNotGranted => 'Не предоставлено';

  @override
  String get permissionGrant => 'Грант';

  @override
  String get generateUsername => 'Создайте новое имя пользователя';

  @override
  String get adminTools => 'Инструменты Admin';

  @override
  String get openAdminPanel => 'Открытая панель администратора';

  @override
  String get webAdminInterface => 'Веб-интерфейс администратора';

  @override
  String get adminBetaNotice =>
      'Бета строит только Инструменты администратора для тестирования предупреждений о близости, push-уведомлений и системной диагностики.';

  @override
  String get whatDoYouSee => 'Что ты видишь?';

  @override
  String get ufoSighting => 'НЛО прицел';

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
  String get sightingTypeLabel => 'Тип';

  @override
  String get ufoTypeSphere => 'Сфера';

  @override
  String get ufoTypeTriangle => 'Треугольник';

  @override
  String get ufoTypeDisk => 'Диск';

  @override
  String get ufoTypeLight => 'Свет';

  @override
  String get ufoTypeFireball => 'Огненный шар';

  @override
  String get ufoTypeCylinder => 'Цилиндр';

  @override
  String get ufoTypeCigar => 'Сигара';

  @override
  String get ufoTypeRectangle => 'Прямоугольник';

  @override
  String get ufoTypeFormation => 'Формирование';

  @override
  String get ufoTypeUnknown => 'Неизвестный';

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
  String get actionsTitle => 'Меры';

  @override
  String get addPhotosAndVideos => 'Добавить фото и видео';

  @override
  String get howToReportToMufon => 'Как сообщить в MUFON';

  @override
  String get reportToMufon => 'Сообщить MUFON';

  @override
  String get whyReportToMufon => 'Зачем отчитываться перед MUFON?';

  @override
  String get openMufonReport => 'Открыть MUFON Доклад';

  @override
  String get confirmedWitness => 'Вы подтвердили это наблюдение';

  @override
  String witnessesHaveConfirmed(int count) {
    return '$count люди подтвердили это наблюдение';
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
