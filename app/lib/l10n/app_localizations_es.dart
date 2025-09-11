// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'UFOBeep';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerca';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Suprimir';

  @override
  String get edit => 'Editar';

  @override
  String get retry => 'Retry';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get done => 'Hecho';

  @override
  String get loading => 'Cargando..';

  @override
  String get processing => 'Procesando..';

  @override
  String get errorGeneric => 'Algo salió mal.';

  @override
  String get networkError => 'Error de red. Comprueba tu conexión.';

  @override
  String get permissionsRequired => 'Permisos necesarios';

  @override
  String get learnMore => 'Aprender más';

  @override
  String get welcomeTitle => 'Bienvenido a UFOBeep';

  @override
  String get welcomeSubtitle => 'Alertas de OVNI en tiempo real cerca de usted';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signOut => 'Suscríbase';

  @override
  String get continueAsGuest => 'Continuar como invitado';

  @override
  String get enterUsername => 'Introduzca un nombre de usuario';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get usernameUpdated => 'Nombre de usuario actualizado';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Ajustes';

  @override
  String get tabAlerts => 'Alertas';

  @override
  String get tabBeep => 'Beep';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabMap => 'Mapa';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get alertsTitle => 'Alertas cercanas';

  @override
  String get noAlerts => 'Todavía no hay alertas cerca.';

  @override
  String get pullToRefresh => 'Tire para refrescar';

  @override
  String alertDistance(String distance) {
    return '$distance';
  }

  @override
  String alertDirection(int bearing) {
    return 'Rodamiento ${bearing}_°';
  }

  @override
  String get viewAlert => 'Alerta';

  @override
  String get viewOnMap => 'Ver mapa';

  @override
  String get iSeeItToo => 'Yo también lo veo';

  @override
  String get confirmWitnessed =>
      'Confirma que has presenciado este avistamiento?';

  @override
  String get witnessConfirmed => 'Gracias — su confirmación fue publicada.';

  @override
  String get createBeepTitle => 'Enviar un pitido';

  @override
  String get beepExplain =>
      'Captura lo que ves y alerta a los observadores cercanos.';

  @override
  String get capturePhoto => 'Imagen de captura';

  @override
  String get captureVideo => 'Capturar vídeo';

  @override
  String get pickFromGallery => 'Elija de la galería';

  @override
  String get descriptionHint => 'Describe lo que estás viendo en el cielo..';

  @override
  String get submitBeep => 'Enviar Beep';

  @override
  String get beepSent => 'Beep sent';

  @override
  String beepSentWithUrl(String shortUrl) {
    return 'Beep sent successfully';
  }

  @override
  String get uploadingMedia => 'Subiendo medios..';

  @override
  String get includeLocation => 'Incluido el lugar';

  @override
  String get includeTimestamp => 'Incluir el temporizador';

  @override
  String get beepFailed => 'Failed to send Beep.';

  @override
  String get mediaProcessing => 'Procesando medios..';

  @override
  String get cameraPermissionTitle => 'Acceso a la cámara necesitada';

  @override
  String get cameraPermissionBody =>
      'Permite acceso a la cámara para capturar fotos y videos OVNI.';

  @override
  String get locationPermissionTitle => 'Acceso a la ubicación necesaria';

  @override
  String get locationPermissionBody =>
      'Usamos su ubicación para enviar y recibir alertas cercanas.';

  @override
  String get microphonePermissionTitle => 'Acceso al micrófono necesario';

  @override
  String get microphonePermissionBody =>
      'Acceso al micrófono de Grant para captura de vídeo con audio.';

  @override
  String get openSettings => 'Configuración abierta';

  @override
  String get alertDetailTitle => 'Detalles de visión';

  @override
  String reportedBy(String username) {
    return 'Reportado por $username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Reportado $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '$distance';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Rodamiento para oponerse: __PH_0_';
  }

  @override
  String get openCompass => 'Brújula abierta';

  @override
  String get openAR => 'Open AR overlay';

  @override
  String get openChat => 'Charla abierta';

  @override
  String get commentsTitle => 'Comentarios';

  @override
  String get addComment => 'Añadir un comentario..';

  @override
  String get send => 'Enviar';

  @override
  String get commentPosted => 'Comentario publicado';

  @override
  String get autoFollowEnabled => 'Ahora estás siguiendo esta alerta.';

  @override
  String get noCommentsYet => 'Todavía no hay comentarios. ¡Sé el primero!';

  @override
  String get newCommentNotification =>
      'Nuevo comentario sobre un avistamiento que sigue.';

  @override
  String get mapTitle => 'Mapa en vivo';

  @override
  String get compassTitle => 'Compass';

  @override
  String get compassSettings => 'Ajustes de compatibilidad';

  @override
  String get compassMode => 'Modo Compasivo';

  @override
  String get compassStandardMode => 'Modo estándar';

  @override
  String get compassPilotMode => 'Modo piloto';

  @override
  String get compassStandardDescription => 'Encabezamiento básico y navegación';

  @override
  String get compassPilotDescription =>
      'Navegación avanzada con ETA y vectorización';

  @override
  String pointingTo(String direction) {
    return 'Apuntando a $direction';
  }

  @override
  String get calibratingCompass => 'Calibrando la brújula..';

  @override
  String get openAROverlay => 'Open AR overlay';

  @override
  String get pushTitleAlertNearby => 'OVNI alerta cerca de usted';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Se reportó un nuevo avistamiento ${distance}_.';
  }

  @override
  String get pushTitleComment => 'Nuevo comentario';

  @override
  String get pushBodyComment =>
      'Alguien comentó sobre un avistamiento que sigues.';

  @override
  String get pushTitleWitness => 'Confirmación de testigos';

  @override
  String get pushBodyWitness => 'Un usuario confirmó que ven el mismo objeto.';

  @override
  String get weather => 'El tiempo';

  @override
  String cloudCover(int percent) {
    return 'Cubierta en la nube: ¿Por qué';
  }

  @override
  String wind(num speed, String unit) {
    return 'Viento:';
  }

  @override
  String get nearbyAircraft => 'Aviones cercanos';

  @override
  String get noAircraft => 'No hay aviones cerca';

  @override
  String get loadingContext => 'Cargando contexto ambiental..';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get enablePushNotifications =>
      'Obtenga notificaciones para comentarios futuros';

  @override
  String get quietHours => 'Horas tranquilas';

  @override
  String get quietHoursDesc => 'Alertas de silencio entre horas seleccionadas.';

  @override
  String get dndMode => 'No te molestes';

  @override
  String get dndUntil => 'No molestar hasta';

  @override
  String get language => 'Idioma';

  @override
  String get chooseLanguage => 'Elija idioma';

  @override
  String get units => 'Unidades';

  @override
  String get unitsImperial => 'Imperial (mi, mph)';

  @override
  String get unitsMetric => 'Metro (km/h)';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfUse => 'Términos de uso';

  @override
  String get errorNoLocation =>
      'Ubicación no disponible. Pruebe de nuevo afuera con vista clara al cielo.';

  @override
  String get errorNoCamera => 'Cámara no disponible en este dispositivo.';

  @override
  String get errorUploadFailed =>
      'La carga falló. Por favor, inténtalo de nuevo.';

  @override
  String get errorPermissionDenied => 'Permiso negado.';

  @override
  String get errorInvalidUsername =>
      'Ese nombre de usuario no está disponible.';

  @override
  String get nothingToShow => 'Aún no hay nada que mostrar.';

  @override
  String get storeShortDesc =>
      'Instant UFO alertas cerca de usted. Captura, confirma y chatea en tiempo real.';

  @override
  String get storeLongDesc =>
      'UFOBeep envía alertas en tiempo real cuando alguien ve a un OVNI cerca. Captura fotos y videos, confirma los avistamientos con un grifo, la dirección de la vista & distancia, y chatea con otros observadores de cielo.';

  @override
  String get keywords =>
      'UFO,UAP,OVNI,aliens,sightings,skywatch,alerts,radar,compass';

  @override
  String get noAlertsFound => 'No hay alertas coincidentes';

  @override
  String get alertsFilterHelp =>
      'Intente ajustar sus filtros para ver más resultados';

  @override
  String get verified => 'Verificado';

  @override
  String get beepOnly => '# beep only #';

  @override
  String get videoOnly => 'video sólo';

  @override
  String get imageOnly => 'imagen sólo';

  @override
  String get timeJustNow => 'Ahora';

  @override
  String timeDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '__PH_0_h ago';
  }

  @override
  String timeMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String get loadMoreAlerts => 'Cargar más alertas';

  @override
  String get toggleMufonTooltip => 'Toggle MUFON sightings';

  @override
  String get showMufonData => 'Mostrar datos MUFON';

  @override
  String get hideMufonData => 'Ocultar datos de MUFON';

  @override
  String get showingUfoBeepOnly => 'Mostrando sólo informes de OVNIS';

  @override
  String get showingAllReports =>
      'Mostrando todos los informes incluyendo la base de datos MUFON';

  @override
  String get filteredSuffix => 'filtrado';

  @override
  String get detailsTitle => 'Detalles';

  @override
  String get mufonCase => 'MUFON Caso';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Caso #$caseNumber';
  }

  @override
  String get sightingDate => 'Fecha de visión';

  @override
  String get mufonDatabaseEntryDate => 'Fecha ingresada en MUFON Base de datos';

  @override
  String get databaseEntry => 'Entrada de bases de datos';

  @override
  String get shareLink => 'Compartir Enlace';

  @override
  String get linkCopied => 'Enlace copiado a portapapeles';

  @override
  String get locationLabel => 'Ubicación';

  @override
  String get distanceLabel => 'Distancia';

  @override
  String get timeLabel => 'Hora';

  @override
  String get reportedByLabel => 'Reported by';

  @override
  String get unknownLocation => 'Ubicación desconocida';

  @override
  String get locationUnknown => 'Ubicación Desconocida';

  @override
  String get witnessesLabel => 'Testigos';

  @override
  String witnessesCountMessage(int count) {
    return 'La gente confirmó este avistamiento';
  }

  @override
  String get photoAnalysisTitle => 'Análisis de fotos';

  @override
  String mediaItemsProcessed(int count) {
    return 'Análisis: ${count}________________________';
  }

  @override
  String get addMoreMedia => 'Añadir más';

  @override
  String get addMedia => 'Añadir medios';

  @override
  String get retakePhoto => 'Retoma foto';

  @override
  String get retakeVideo => 'Retomar vídeo';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get basicSettings => 'Ajustes básicos';

  @override
  String get appSettings => 'Ajustes de la aplicación';

  @override
  String get alertRange => 'Distancia de alerta';

  @override
  String get manageNotificationsDesc => 'Gestionar suscripciones y ajustes';

  @override
  String get permissionsTitle => 'Permisos';

  @override
  String get permissionLocation => 'Ubicación';

  @override
  String get permissionCamera => 'Cámara';

  @override
  String get permissionNotifications => 'Notificaciones';

  @override
  String get permissionPhotos => 'Fotos';

  @override
  String get permissionGranted => 'Subvenciones';

  @override
  String get permissionNotGranted => 'No concedido';

  @override
  String get permissionGrant => 'Grant';

  @override
  String get generateUsername => 'Generar nuevo nombre de usuario';

  @override
  String get adminTools => 'Herramientas de Admin';

  @override
  String get openAdminPanel => 'Open Admin Panel';

  @override
  String get webAdminInterface => 'Interfaz de Admin Web';

  @override
  String get adminBetaNotice =>
      'Beta solo construye. Herramientas para probar alertas de proximidad, notificaciones de empuje y diagnóstico del sistema.';

  @override
  String get whatDoYouSee => '¿Qué ves?';

  @override
  String get ufoSighting => 'OVNI Avistamiento';

  @override
  String get envAnalysisTitle => 'Environmental Analysis';

  @override
  String get envAnalysisPending => 'Análisis';

  @override
  String get envAnalysisPendingDesc =>
      'Los datos ambientales estarán disponibles una vez que comience el procesamiento.';

  @override
  String get unknownAircraft => 'Aviones desconocidos';

  @override
  String get moreAircraft => 'más aeronaves';

  @override
  String get premiumImageryTitle => 'Satélite Premium Imagen';

  @override
  String get premiumImagerySubtitle =>
      'Imágenes comerciales de alta resolución';

  @override
  String get sightingTypeLabel => 'Tipo';

  @override
  String get ufoTypeSphere => 'Sphere';

  @override
  String get ufoTypeTriangle => 'Triángulo';

  @override
  String get ufoTypeDisk => 'Disk';

  @override
  String get ufoTypeLight => 'Luz';

  @override
  String get ufoTypeFireball => 'Bola de fuego';

  @override
  String get ufoTypeCylinder => 'Cilindro';

  @override
  String get ufoTypeCigar => 'Cigarro';

  @override
  String get ufoTypeRectangle => 'Rectángulo';

  @override
  String get ufoTypeFormation => 'Formación';

  @override
  String get ufoTypeUnknown => 'Desconocida';

  @override
  String get ufoTypeBoomerang => 'Boomerang';

  @override
  String get ufoTypeDiamond => 'Diamante';

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
  String get ufoTypeBullet => 'Bala';

  @override
  String get ufoTypeSaturn => 'Saturno';

  @override
  String get ufoTypeStarLike => 'Star-like';

  @override
  String get ufoTypeBlimp => 'Blimp';

  @override
  String get actionsTitle => 'Acciones';

  @override
  String get addPhotosAndVideos => 'Añadir fotos > Videos';

  @override
  String get howToReportToMufon => 'Cómo reportar a MUFON';

  @override
  String get reportToMufon => 'Informe a MUFON';

  @override
  String get whyReportToMufon => '¿Por qué reportarle a MUFON?';

  @override
  String get openMufonReport => 'Open MUFON Informe';

  @override
  String get confirmedWitness => 'Usted confirmó este avistamiento';

  @override
  String witnessesHaveConfirmed(int count) {
    return 'La gente ha confirmado este avistamiento';
  }

  @override
  String get aircraftTrackingTitle => 'Aircraft Tracking';

  @override
  String get weatherConditionsTitle => 'Condiciones meteorológicas';

  @override
  String get noSatellitePasses =>
      'No se encontraron pases de satélite visibles';

  @override
  String get contentAnalysisTitle => 'Análisis de contenidos';

  @override
  String get contentSafe => 'El contenido es seguro';

  @override
  String get contentFlagged => 'Contenido marcado para su examen';

  @override
  String get confidenceLabel => 'Confianza';

  @override
  String get methodLabel => 'Método';

  @override
  String get premiumImageryAccessOnly =>
      'Las imágenes de satélite Premium solo están disponibles para:';

  @override
  String get premiumAccessCreators => 'Creadores de alerta';

  @override
  String get premiumAccessWitnesses =>
      'Testigos confirmados dentro del rango de visibilidad';

  @override
  String get comingSoon => 'Pronto';

  @override
  String get directionDistanceTitle => 'Dirección \" Distancia';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Caso..';
  }

  @override
  String get satellitePassesTitle => 'Pases por satélite';

  @override
  String get satellitePassExplanation =>
      'El satélite visible pasa durante el período de visualización. Muchos informes de OVNI son en realidad satélites o desechos espaciales.';

  @override
  String get followingAlert =>
      'Después de la alerta - obtendrá notificaciones de comentarios';

  @override
  String get unfollowedAlert =>
      'Alerta sin seguimiento - no más notificaciones de comentarios';

  @override
  String get alertFollowError => 'Actualización de errores';

  @override
  String get notificationChannelAlerts => 'UFOBeep Alerts';

  @override
  String get notificationChannelAlertsDesc =>
      'Notifications for UFO beeps and proximity alerts';

  @override
  String get notificationSightingTitle => 'UFO Sighting';

  @override
  String get notificationSightingUrgent => '⚠️ URGENT UFO Sighting';

  @override
  String get notificationSightingEmergency => '🚨 EMERGENCY UFO Sighting';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '$witnessText near $locationName';
  }

  @override
  String notificationCommentTitle(String username) {
    return '💬 $username commented';
  }

  @override
  String get notificationWitnessText => 'New sighting';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '$count witnesses';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Dismiss';

  @override
  String notificationDistance(String distance) {
    return '$distance away';
  }
}
