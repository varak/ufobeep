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
    return '$distance away';
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
  String beepSentWithUrl(String shortUrl) {
    return 'Пип успешно отправлен';
  }

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
    return '$distance';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Возражение: $bearing°';
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
  String get noCommentsYet =>
      'Никаких комментариев. Будьте первым, кто комментирует!';

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
    return 'Указать на $direction';
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
  String get temperature => 'Температура';

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
  String get enablePushNotifications =>
      'Получить уведомления для будущих комментариев';

  @override
  String get quietHours => 'Тихие часы';

  @override
  String get quietHoursDesc =>
      'Предупреждение о молчании между выбранными часами.';

  @override
  String get quietHoursEnabled => 'Включите тихие часы';

  @override
  String get quietHoursFrom => 'Из';

  @override
  String get quietHoursUntil => 'Пока';

  @override
  String get quietHoursDefaultTime => 'По умолчанию тихие часы';

  @override
  String get emergencyOverride => 'Аварийная отмена';

  @override
  String get emergencyOverrideDesc => 'Срочные оповещения в тихие часы';

  @override
  String get dndMode => 'Не беспокоить';

  @override
  String get dndUntil => 'Не беспокоить, пока';

  @override
  String dndEnabled(Object time) {
    return 'DND включен до $time';
  }

  @override
  String get dndDisabled => 'DND отключен';

  @override
  String get quietHoursActive => 'Тихие часы активны';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Тихие часы: $start - $start';
  }

  @override
  String get pushNotificationUfoAlert => 'НЛО Предупреждение';

  @override
  String get pushNotificationAnomalyAlert => 'Предупреждение об аномалиях';

  @override
  String get pushNotificationNearby => 'Рядом';

  @override
  String get pushNotificationInYourArea =>
      'в вашем районе. Нажмите, чтобы просмотреть детали.';

  @override
  String pushNotificationCommented(Object username) {
    return '$username прокомментировал';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '$username прокомментировал $username';
  }

  @override
  String get pushNotificationGeneric => 'НЛО Бип';

  @override
  String get pushNotificationNewSighting => 'Новый взгляд рядом';

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
  String get beepOnly => 'Только гудок';

  @override
  String get reportOnly => 'Только текст';

  @override
  String get videoOnly => 'Только видео';

  @override
  String get imageOnly => 'Только изображение';

  @override
  String get mediaOnly => 'Только СМИ';

  @override
  String get timeJustNow => 'только сейчас';

  @override
  String timeDaysAgo(int count) {
    return '___________________';
  }

  @override
  String timeHoursAgo(int count) {
    return '____________________________';
  }

  @override
  String timeMinutesAgo(int count) {
    return '____________________________';
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
  String get mufonSighting => 'Обзорный отчет MUFON';

  @override
  String get mufonLightSighting =>
      'Об этом сообщает MUFON Light Sighting Report';

  @override
  String get mufonSphereSighting => 'Обзорный отчет MUFON Sphere';

  @override
  String get mufonDiscSighting => 'МУФОН Disc Sighting Report';

  @override
  String get mufonTriangleSighting => 'МУФОН Треугольный обзорный отчет';

  @override
  String get mufonCigarSighting =>
      'Об этом сообщает MUFON Cigar Sighting Report';

  @override
  String get mufonOvalSighting => 'Об этом сообщает MUFON Oval Sighting Report';

  @override
  String get mufonRectangleSighting =>
      'МУФОН Обсуждение Rectangle Sighting Report';

  @override
  String get mufonCylinderSighting => 'Обзор цилиндров MUFON';

  @override
  String get mufonBoomerangSighting =>
      'Об этом сообщает MUFON Boomerang Sighting Report';

  @override
  String get mufonStarlikeSighting =>
      'МУФОН Оригинальное название: Starlike Sighting Report';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Case #$caseNumber Подробности';
  }

  @override
  String get sightingDate => 'Дата наблюдения';

  @override
  String get mufonDatabaseEntryDate => 'Дата вхождения в MUFON База данных';

  @override
  String get databaseEntry => 'Вход в базу данных';

  @override
  String get shareLink => 'Share Link';

  @override
  String get linkCopied => 'Link скопирован в буфер обмена';

  @override
  String get locationLabel => 'Местонахождение:';

  @override
  String get distanceLabel => 'Расстояние';

  @override
  String get timeLabel => 'Время:';

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
    return '_______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get photoAnalysisTitle => 'Анализ фотографий';

  @override
  String mediaItemsProcessed(int count) {
    return 'Анализ: $count медиафайл(ы)';
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
  String get timeFormat => 'Формат времени';

  @override
  String get timeFormat24Hour => '24 часа (14:30)';

  @override
  String get timeFormat12Hour => '12 часов (2:30 вечера)';

  @override
  String get timeFormatDesc =>
      'Время показа в 24-часовом или 12-часовом формате';

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
  String get ufo => 'НЛО';

  @override
  String get sighting => 'Прицел';

  @override
  String get ufoSighting => 'НЛО Бип НЛО Предупреждение';

  @override
  String get envAnalysisTitle => 'Экологический анализ';

  @override
  String get envAnalysisPending => 'Анализ в ожидании';

  @override
  String get envAnalysisPendingDesc =>
      'Экологические данные будут доступны после начала обработки.';

  @override
  String get unknownAircraft => 'Неизвестный самолет';

  @override
  String get moreAircraft => 'больше самолетов';

  @override
  String get premiumImageryTitle => 'Премиальный спутник Изображения';

  @override
  String get premiumImagerySubtitle =>
      'Коммерческие изображения высокого разрешения';

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
  String get ufoTypeBoomerang => 'Бумеранг';

  @override
  String get ufoTypeDiamond => 'Алмаз';

  @override
  String get ufoTypeOval => 'Оваль';

  @override
  String get ufoTypeCone => 'Конус';

  @override
  String get ufoTypeCross => 'Крест';

  @override
  String get ufoTypeDumbbell => 'Дурацкий колокол';

  @override
  String get ufoTypeTeardrop => 'Жардроп';

  @override
  String get ufoTypeTicTac => 'Тик-так';

  @override
  String get ufoTypeBullet => 'Пуля';

  @override
  String get ufoTypeSaturn => 'Сатурн';

  @override
  String get ufoTypeStarLike => 'Звездообразный';

  @override
  String get ufoTypeBlimp => 'Блеск';

  @override
  String get shapeTriangle => 'треугольник';

  @override
  String get shapeDisc => 'диск';

  @override
  String get shapeDisk => 'диск';

  @override
  String get shapeSphere => 'область';

  @override
  String get shapeCigar => 'сигара';

  @override
  String get shapeLight => 'свет';

  @override
  String get shapeBoomerang => 'бумеранг';

  @override
  String get shapeDiamond => 'алмаз';

  @override
  String get shapeRectangle => 'прямоугольник';

  @override
  String get shapeOval => 'овальный';

  @override
  String get shapeCone => 'конус';

  @override
  String get shapeCross => 'крест';

  @override
  String get shapeCylinder => 'цилиндр';

  @override
  String get shapeDumbbell => 'гантель';

  @override
  String get shapeTeardrop => 'капля слез';

  @override
  String get shapeTicTac => 'тик-так';

  @override
  String get shapeBullet => 'пуля';

  @override
  String get shapeSaturn => 'поворот';

  @override
  String get shapeStarlike => 'звездообразный';

  @override
  String get shapeBlimp => 'ремень';

  @override
  String get shapeFireball => 'огненный шар';

  @override
  String get shapeFormation => 'формирование';

  @override
  String get shapeUnknown => 'неизвестный';

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
    return '_______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get aircraftTrackingTitle => 'Отслеживание самолетов';

  @override
  String get weatherConditionsTitle => 'Погодные условия';

  @override
  String get noSatellitePasses =>
      'Никаких видимых спутниковых проходов обнаружено не было';

  @override
  String get contentAnalysisTitle => 'Анализ содержания';

  @override
  String get contentSafe => 'Содержание безопасно';

  @override
  String get contentFlagged => 'Контент, отмеченный для обзора';

  @override
  String get confidenceLabel => 'Уверенность';

  @override
  String get methodLabel => 'Метод';

  @override
  String get premiumImageryAccessOnly =>
      'Премиальные спутниковые снимки доступны только для:';

  @override
  String get premiumAccessCreators => 'Создатели предупреждений';

  @override
  String get premiumAccessWitnesses =>
      'Подтвержденные свидетели в пределах видимости';

  @override
  String get comingSoon => 'Скоро придет';

  @override
  String get directionDistanceTitle => 'Направление и расстояние';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'МУФОН Случай #$caseNumber';
  }

  @override
  String get satellitePassesTitle => 'Спутниковые проходы';

  @override
  String get satellitePassExplanation =>
      'Видимый спутник проходит во время наблюдения. Многие сообщения об НЛО на самом деле являются спутниками или космическим мусором.';

  @override
  String get followingAlert =>
      'После предупреждения - вы получите уведомления о комментариях';

  @override
  String get unfollowedAlert =>
      'Unfollowed alert - больше никаких комментариев';

  @override
  String get alertFollowError => 'Обновление ошибок Следуйте за статусом';

  @override
  String get notificationChannelAlerts => 'Предупреждения UFOBeep';

  @override
  String get notificationChannelAlertsDesc =>
      'Уведомления о сигналах НЛО и предупреждениях о близости';

  @override
  String get notificationSightingTitle => 'НЛО Бип НЛО Предупреждение';

  @override
  String get notificationSightingUrgent =>
      'Оригинальное название: UFOBeep UFO Предупреждение';

  @override
  String get notificationSightingEmergency =>
      'ЭМЕРГЕНЦИЯ НЛОБИП НЛО Предупреждение';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '$witnessText около $locationName';
  }

  @override
  String notificationCommentTitle(String username) {
    return '・$username прокомментировал';
  }

  @override
  String get notificationWitnessText => 'Новый взгляд';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '___ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ ___ ___ ___ ___ __ ___ ___ ___ ___ ___ ___ ___ ___ ___';
  }

  @override
  String get notificationActionSnooze => 'Снюз 1ч';

  @override
  String get notificationActionDismiss => 'Увольнение';

  @override
  String notificationDistance(String distance) {
    return '$distance away';
  }

  @override
  String get unknown => 'неизвестный';

  @override
  String get report => 'доклад';

  @override
  String get mufon => 'мафия';

  @override
  String get recentUfoBeepsTitle => 'Недавний НЛО Бипс';

  @override
  String get recentUfoBeepsSubtitle =>
      'Отчеты о наблюдениях НЛО в прямом эфире от нашего мирового сообщества';

  @override
  String get recentUfoBeepsDescription =>
      'Эта лента сочетает в себе UFOBeep в реальном времени от пользователей нашего мобильного приложения с историческими отчетами из базы данных MUFON.';

  @override
  String get loadingBeeps => 'Загрузка недавних звуков...';

  @override
  String get noBeepsAvailable =>
      'На данный момент никаких звуковых сигналов нет.';

  @override
  String get anomalyReported => 'Об аномалии сообщили';

  @override
  String get copyShortLink => 'Скопировать короткую ссылку';

  @override
  String get shareAlert => 'Поделиться предупреждением';

  @override
  String get ufoSightingAlert => 'НЛО Сигнал тревоги';

  @override
  String get previousPage => 'Предыдущий';

  @override
  String get nextPage => 'Следующий';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Страница ${currentPage}_$totalPages ($totalCount полные звуковые сигналы)';
  }

  @override
  String get firstPage => 'Первый';

  @override
  String get lastPage => 'Последний';

  @override
  String get jumpToPage => 'Перейти на страницу';

  @override
  String get heroTagline =>
      'Получить оповещения, когда выходить на улицу и смотреть вверх';

  @override
  String get heroDescription =>
      'Никогда не пропустите очередное наблюдение НЛО. Получайте оповещения в реальном времени, когда кто-то рядом с вами видит что-то странное в небе. Направьте телефон и найдите, где именно искать.';

  @override
  String get downloadApp => 'Скачать приложение';

  @override
  String get viewAllBeeps => 'Смотреть все клипы';

  @override
  String get sightingsMap => '️ Карта достопримечательностей';

  @override
  String get globalSightingNetwork => 'Глобальная сеть наблюдения';

  @override
  String get howItWorks => 'Как работает UFOBeep';

  @override
  String get backToBeeps => 'Вернуться в Beeps';

  @override
  String get loadingDetails => 'Загрузка звуковых деталей...';

  @override
  String get details => 'Подробности';

  @override
  String get location => 'Расположение';

  @override
  String get timeAgo => 'давно';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'км';

  @override
  String get distanceMiles => 'миль';

  @override
  String get distanceNearby => 'поблизости';

  @override
  String get ufobeepWitnesses => 'Свидетели';

  @override
  String get ufobeepConfirmations => 'Подтверждения';

  @override
  String get ufobeepAlertLevel => 'Уровень оповещения';

  @override
  String get ufobeepReportType => 'Об этом сообщает UFOBeep';

  @override
  String get mufonAttribution => 'МУФОН Отчет о базе данных';

  @override
  String get mufonCaseNumber => 'Дело #';

  @override
  String get mufonGenericTitle => 'Обзорный отчет MUFON';

  @override
  String get mufonSphere => 'Сфера';

  @override
  String get mufonLight => 'Свет';

  @override
  String get mufonDisk => 'Диск';

  @override
  String get mufonTriangle => 'Треугольник';

  @override
  String get mufonCigar => 'Сигара';

  @override
  String get mufonOval => 'Оваль';

  @override
  String get mufonCylinder => 'Цилиндр';

  @override
  String get mufonRectangle => 'Прямоугольник';

  @override
  String get mufonDiamond => 'Алмаз';

  @override
  String get mufonFireball => 'Огненный шар';

  @override
  String get mufonFlash => 'Флэш';

  @override
  String get mufonFormation => 'Формирование';

  @override
  String get mufonChanging => 'Изменение';

  @override
  String get mufonChevron => 'Шеврон';

  @override
  String get mufonCone => 'Конус';

  @override
  String get mufonCross => 'Крест';

  @override
  String get mufonEgg => 'Яйцо';

  @override
  String get mufonOther => 'Объект';

  @override
  String get mufonUnknown => 'Неизвестный объект';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON$classification Report';
  }

  @override
  String get nuforcAttribution => 'НУФОРК Отчет о базе данных';

  @override
  String get nuforcCaseNumber => 'Дело #';

  @override
  String get nuforcGenericTitle => 'НУФОРК Обзорный доклад';

  @override
  String get mediaImageNotFound => 'Изображение не найдено';

  @override
  String get mediaPlayVideo => 'Играть видео';

  @override
  String get mediaViewImage => 'Просмотр изображения';

  @override
  String mediaCount(Object count) {
    return '$count Изображения';
  }

  @override
  String get mediaCountSingle => '1 изображение';

  @override
  String mediaMoreImages(Object count) {
    return '+$count';
  }

  @override
  String get errorNotFound => 'Бип не найден';

  @override
  String get errorLoadError => 'Не удалось загрузить детали звукового сигнала';

  @override
  String get shareYourThoughts =>
      'Поделитесь своими мыслями об этом зрелище...';

  @override
  String get postComment => 'Комментарий';

  @override
  String get loggedInAs => 'Зарегистрировано как';

  @override
  String get logout => 'Выход';

  @override
  String get notFollowing => 'Не следовать';

  @override
  String get follow => 'Следить';

  @override
  String get navRecentBeeps => 'Последние бипы';

  @override
  String get navMap => 'Карта';

  @override
  String get navDownloadApp => 'Скачать приложение';

  @override
  String get alertLevel => 'Уровень оповещения';

  @override
  String get witnesses => 'Свидетели';

  @override
  String get confirmations => 'Подтверждения';

  @override
  String get reporterLabel => 'Сообщение пользователя';

  @override
  String get coordinatesLabel => 'Координация';

  @override
  String get eventTime => 'Время события';

  @override
  String get reportedTime => 'Сообщенное время';

  @override
  String get addedToUfobeep => 'Добавлено в UFOBeep';

  @override
  String get mufonDatabaseReport => 'МУФОН Номер дела:';

  @override
  String get copyShortLinkTitle => 'Скопировать ссылку на clipboard';

  @override
  String get imageNotFound => 'Изображение не найдено';

  @override
  String get ufoSightingAlt => 'НЛО Бип предупреждения НЛО';

  @override
  String get celestialDataTitle => 'Небесные объекты';

  @override
  String get visiblePlanets => 'Видимые планеты';

  @override
  String get locationDataTitle => 'Информация о местонахождении';

  @override
  String get timezone => 'Таймзона';

  @override
  String get coordinates => 'Координация';

  @override
  String get processingSummaryTitle => 'Обработка резюме';

  @override
  String get processingTime => 'Время обработки';

  @override
  String get successful => 'Успешный';

  @override
  String get failed => 'Неудачник';

  @override
  String get locationEnrichmentTitle => 'Подробности о местоположении';

  @override
  String get aircraftDataSource => 'Источник данных';

  @override
  String get noAircraftDetected => 'Самолеты не обнаружены';

  @override
  String get sightingReport => 'Обзорный доклад';

  @override
  String get ufoAlert => 'НЛО Предупреждение';

  @override
  String get alert => 'Предупреждение';

  @override
  String get notificationTickerUfoAlert =>
      'Предупреждение об НЛО - новое наблюдение поблизости';

  @override
  String get notificationTickerComment => 'Новые комментарии к UFO Alert';

  @override
  String get weatherConditions => 'Погодные условия';

  @override
  String get visibility => 'Видимость';

  @override
  String get humidity => 'Влажность';

  @override
  String get pressure => 'Давление';

  @override
  String get locationDetails => 'Подробности о местоположении';

  @override
  String get city => 'Город';

  @override
  String get state => 'Государство';

  @override
  String get country => 'Страна';

  @override
  String get satelliteActivity => 'Спутниковая активность';

  @override
  String get satellitesVisibleOverhead =>
      'Спутники, видимые над головой при наблюдении времени и местоположения';

  @override
  String get dataSource => 'Источник данных';

  @override
  String get blackskyImagery => 'Изображения BlackSky';

  @override
  String get resolution => 'Резолюция';

  @override
  String get groundResolution => '35-сантиметровая резолюция';

  @override
  String get delivery => 'Доставка';

  @override
  String get averageDelivery => 'среднее значение 90 минут';

  @override
  String get cost => 'Стоимость';

  @override
  String get skyfiSatelliteImagery => 'Спутник SkyFi Изображения';

  @override
  String get region => 'Регион';

  @override
  String get remoteArea => 'Удаленная зона';

  @override
  String get startingPrice => 'Стартовая цена';

  @override
  String get coverage => 'Покрытие';

  @override
  String get confidenceCoverage => '95% уверенность';

  @override
  String get status => 'Статус';

  @override
  String get shareThoughts => 'Поделитесь своими мыслями об этом зрелище...';

  @override
  String get postCommand => 'Командование';

  @override
  String get clouds => 'Облака';

  @override
  String get windLabel => 'Ветер';

  @override
  String get filterAlerts => 'Предупреждения фильтра';

  @override
  String get alertSource => 'Источник оповещения';

  @override
  String get ufobeepOnly => 'НЛО только гудит';

  @override
  String get ufobeepOnlyDescription =>
      'Показать только оригинальные отчеты UFOBeep (за исключением базы данных MUFON)';

  @override
  String get alertDistanceRange => 'Дистанционный диапазон Alert';

  @override
  String get showAllAlerts => 'Показать все оповещения';

  @override
  String get showAll => 'Показать все';

  @override
  String get distanceSliderDescription =>
      'Перетащите, чтобы отрегулировать, как далеко вы хотите видеть оповещения. Начните с расстояния видимости погоды, показывая все оповещения независимо от расстояния.';

  @override
  String get applyFilters => 'Применять фильтры';
}
