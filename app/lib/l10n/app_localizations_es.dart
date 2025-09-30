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
  String get ok => 'De acuerdo';

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
    return '${distance}__ de distancia';
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
    return 'Beep enviado con éxito';
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
  String get locationPermissionTitle => 'Localización Permiso requerido';

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
    return 'Rodamiento de objeto: ${bearing}_°';
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
  String get noCommentsYet =>
      'Todavía no hay comentarios. ¡Sé el primero en comentar!';

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
    return 'Se informó de un nuevo avistamiento ${distance}_.';
  }

  @override
  String get pushTitleComment => 'Nuevo comentario';

  @override
  String get pushBodyComment =>
      'Alguien comentó sobre un avistamiento que sigues.';

  @override
  String get pushTitleWitness => 'Confirmación de testigos';

  @override
  String get temperature => 'Temperatura';

  @override
  String get pushBodyWitness => 'Un usuario confirmó que ven el mismo objeto.';

  @override
  String get weather => 'El tiempo';

  @override
  String cloudCover(int percent) {
    return 'Cubierta en la nube: ${percent}_%';
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
  String get quietHoursEnabled => 'Hábiles silenciosos';

  @override
  String get quietHoursFrom => 'Desde';

  @override
  String get quietHoursUntil => 'Hasta';

  @override
  String get quietHoursDefaultTime => 'Horas tranquilas predeterminadas';

  @override
  String get emergencyOverride => 'Anulación de emergencia';

  @override
  String get emergencyOverrideDesc =>
      'Permitir alertas urgentes durante horas tranquilas';

  @override
  String get dndMode => 'No molestar';

  @override
  String get dndUntil => 'No molestar hasta';

  @override
  String dndEnabled(Object time) {
    return 'DND habilitado hasta $time';
  }

  @override
  String get dndDisabled => 'DND discapacitados';

  @override
  String quietHoursActive(String startTime, String endTime) {
    return 'Active $endTime $startTime';
  }

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Horas de silencio: $start - $end';
  }

  @override
  String get pushNotificationUfoAlert => 'OVNI Alerta';

  @override
  String get pushNotificationAnomalyAlert => 'Alerta de anomalía';

  @override
  String get pushNotificationNearby => 'Cerca';

  @override
  String get pushNotificationInYourArea =>
      'en su área. Pulse para ver detalles.';

  @override
  String pushNotificationCommented(Object username) {
    return '${username}_ comentado';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '${beepTitle}_ comentado $username';
  }

  @override
  String get pushNotificationGeneric => 'UFOBeep';

  @override
  String get pushNotificationNewSighting => 'Nuevo avistamiento cerca';

  @override
  String get language => 'Idioma';

  @override
  String get chooseLanguage => 'Elija idioma';

  @override
  String get units => 'Unidades';

  @override
  String get unitsImperial => 'Imperial';

  @override
  String get unitsMetric => 'Métrica';

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
  String get beepOnly => 'Beep Only';

  @override
  String get reportOnly => 'Texto Sólo';

  @override
  String get videoOnly => 'Video sólo';

  @override
  String get imageOnly => 'Imagen';

  @override
  String get mediaOnly => 'Sólo medios';

  @override
  String get timeJustNow => 'ahora';

  @override
  String timeDaysAgo(int count) {
    return 'hace unos días';
  }

  @override
  String timeHoursAgo(int count) {
    return 'hace unas horas';
  }

  @override
  String timeMinutesAgo(int count) {
    return 'Hace unos minutos';
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
  String get mufonSighting => 'MUFON Sighting Report';

  @override
  String get mufonLightSighting => 'MUFON Light Sighting Report';

  @override
  String get mufonSphereSighting => 'MUFON Sphere Sighting Report';

  @override
  String get mufonDiscSighting => 'MUFON Informe de visión de disco';

  @override
  String get mufonTriangleSighting => 'MUFON Triangle Sighting Report';

  @override
  String get mufonCigarSighting => 'MUFON Cigar Sighting Report';

  @override
  String get mufonOvalSighting => 'MUFON Oval Sighting Report';

  @override
  String get mufonRectangleSighting => 'MUFON Rectangle Sighting Report';

  @override
  String get mufonCylinderSighting => 'MUFON Cylinder Sighting Report';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Sighting Report';

  @override
  String get mufonStarlikeSighting => 'MUFON Starlike Sighting Report';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'Caso MUFON #__PLACEHOLDER_0_';
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
  String get locationLabel => 'Ubicación:';

  @override
  String get distanceLabel => 'Distancia';

  @override
  String get timeLabel => 'Hora:';

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
    return 'Análisis: ${count}_______ archivo(s) media processed';
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
  String get timeFormat => 'Formato de tiempo';

  @override
  String get timeFormat24Hour => '24 horas';

  @override
  String get timeFormat12Hour => '12 horas';

  @override
  String get timeFormatDesc =>
      'Tiempo de visualización en formato 24 horas o 12 horas';

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
  String get ufo => 'OVNI';

  @override
  String get sighting => 'Avistamiento';

  @override
  String get ufoSighting => 'UFOBeep UFO Alerta';

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
  String get showLess => 'Mostrar menos';

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
  String get shapeTriangle => 'triángulo';

  @override
  String get shapeDisc => 'disco';

  @override
  String get shapeDisk => 'disco';

  @override
  String get shapeSphere => 'esfera';

  @override
  String get shapeCigar => 'cigarro';

  @override
  String get shapeLight => 'luz';

  @override
  String get shapeBoomerang => 'boomerang';

  @override
  String get shapeDiamond => 'diamante';

  @override
  String get shapeRectangle => 'rectángulo';

  @override
  String get shapeOval => 'oval';

  @override
  String get shapeCone => 'cone';

  @override
  String get shapeCross => 'cruz';

  @override
  String get shapeCylinder => 'cilindro';

  @override
  String get shapeDumbbell => 'tonto';

  @override
  String get shapeTeardrop => 'teardrop';

  @override
  String get shapeTicTac => 'tic-tac';

  @override
  String get shapeBullet => 'bala';

  @override
  String get shapeSaturn => 'saturn';

  @override
  String get shapeStarlike => 'estrella';

  @override
  String get shapeBlimp => 'blimp';

  @override
  String get shapeFireball => 'bola de fuego';

  @override
  String get shapeFormation => 'formación';

  @override
  String get shapeUnknown => 'desconocida';

  @override
  String get actionsTitle => 'Acciones';

  @override
  String get addPhotosAndVideos => 'Añadir fotos > Videos';

  @override
  String get attachMedia => 'Adjuntar medios';

  @override
  String get addCommentOptional => 'Agregar un comentario (opcional)';

  @override
  String get describeNewMedia => 'Describe los nuevos medios...';

  @override
  String get filesSelected => 'archivos seleccionados';

  @override
  String get selectMediaToAttach =>
      'Por favor seleccione fotos o vídeos para adjuntar';

  @override
  String get newMediaUploaded => 'Nuevos medios subidos';

  @override
  String get mediaFilesUploaded => 'nuevos archivos multimedia subidos';

  @override
  String get filesAttachedSuccessfully => 'archivos adjuntos';

  @override
  String get howToReportToMufon => 'Cómo reportar a MUFON';

  @override
  String get reportToMufon => 'Informe a MUFON';

  @override
  String get whyReportToMufon => '¿Por qué reportarle a MUFON?';

  @override
  String get openMufonReport => 'Open MUFON Informe';

  @override
  String get howToFormallyReport => 'How to Formally Report';

  @override
  String get formalReportingTitle => 'Formal UFO Reporting';

  @override
  String get ufobeepVsFormalReporting => 'UFOBeep vs Formal Reporting';

  @override
  String get reportingOrganizations => 'Reporting Organizations';

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
      'No se encontraron pases satelitales visibles';

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
    return 'MUFON Caso #$caseNumber';
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
  String get notificationChannelAlerts => 'Alertas de OVNIS';

  @override
  String get notificationChannelAlertsDesc =>
      'Notificaciones para ovnis y alertas de proximidad';

  @override
  String get notificationSightingTitle => 'UFOBeep UFO Alerta';

  @override
  String get notificationSightingUrgent => 'OVNI OVNIENTE OVNIENTE Alerta';

  @override
  String get notificationSightingEmergency => 'OVNI OVNIO DE OVNITO Alerta';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '${witnessText}_ Cerca de $locationName';
  }

  @override
  String notificationCommentTitle(String username) {
    return '💬 ${username}_ comentado';
  }

  @override
  String get notificationWitnessText => 'Nuevo avistamiento';

  @override
  String notificationWitnessTextMultiple(int count) {
    return 'testigos';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Desestimación';

  @override
  String notificationDistance(String distance) {
    return '${distance}__ de distancia';
  }

  @override
  String get unknown => 'Desconocida';

  @override
  String get report => 'informe';

  @override
  String get mufon => 'mufon';

  @override
  String get recentUfoBeepsTitle => 'OVNI reciente Beeps';

  @override
  String get recentUfoBeepsSubtitle =>
      'Informes de avistamiento de OVNI en vivo de nuestra comunidad global';

  @override
  String get recentUfoBeepsDescription =>
      'Este feed combina \"beeps\" en tiempo real de UFOBeep de nuestros usuarios de aplicaciones móviles con informes históricos de la base de datos MUFON.';

  @override
  String get loadingBeeps => 'Cargando recientes pitidos...';

  @override
  String get noBeepsAvailable => 'No hay pitidos disponibles en este momento.';

  @override
  String get anomalyReported => 'Anomaly reported';

  @override
  String get copyShortLink => 'Copiar el enlace corto';

  @override
  String get shareAlert => 'Alerta de participación';

  @override
  String get ufoSightingAlert => 'OVNI Alerta de visión';

  @override
  String get previousPage => 'Anterior';

  @override
  String get nextPage => 'Siguiente';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Página ${currentPage}_ de ${totalPages}_ (_________ total beeps)';
  }

  @override
  String get firstPage => 'Primera';

  @override
  String get lastPage => 'Último';

  @override
  String get jumpToPage => 'Saltar a página';

  @override
  String get heroTagline => 'Obtener alertas cuando salir y mirar hacia arriba';

  @override
  String get heroDescription =>
      'Nunca pierda otro OVNI avistamiento en su área';

  @override
  String get downloadApp => '📱 Descargar App';

  @override
  String get viewAllBeeps => '📋 View All Beeps';

  @override
  String get sightingsMap => 'Mapa de Avistamientos';

  @override
  String get globalSightingNetwork => 'Global Sighting Network';

  @override
  String get howItWorks => 'Cómo funciona';

  @override
  String get backToBeeps => 'Volver a Beeps';

  @override
  String get loadingDetails => 'Cargando detalles del pitido...';

  @override
  String get details => 'Detalles';

  @override
  String get location => 'Ubicación';

  @override
  String get timeAgo => 'hace mucho tiempo';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'millas';

  @override
  String get distanceNearby => 'cerca';

  @override
  String get ufobeepWitnesses => 'Testigos';

  @override
  String get ufobeepConfirmations => 'Confirmaciones';

  @override
  String get ufobeepAlertLevel => 'Nivel de alerta';

  @override
  String get ufobeepReportType => 'UFOBeep Report';

  @override
  String get mufonAttribution => 'MUFON Informe de base de datos';

  @override
  String get mufonCaseNumber => 'Caso';

  @override
  String get mufonGenericTitle => 'MUFON Sighting Report';

  @override
  String get mufonSphere => 'Sphere';

  @override
  String get mufonLight => 'Luz';

  @override
  String get mufonDisk => 'Disk';

  @override
  String get mufonTriangle => 'Triángulo';

  @override
  String get mufonCigar => 'Cigarro';

  @override
  String get mufonOval => 'Oval';

  @override
  String get mufonCylinder => 'Cilindro';

  @override
  String get mufonRectangle => 'Rectángulo';

  @override
  String get mufonDiamond => 'Diamante';

  @override
  String get mufonFireball => 'Bola de fuego';

  @override
  String get mufonFlash => 'Flash';

  @override
  String get mufonFormation => 'Formación';

  @override
  String get mufonChanging => 'Cambio';

  @override
  String get mufonChevron => 'Chevron';

  @override
  String get mufonCone => 'Cone';

  @override
  String get mufonCross => 'Cross';

  @override
  String get mufonEgg => 'Egg';

  @override
  String get mufonOther => 'Objeto';

  @override
  String get mufonUnknown => 'Objeto desconocido';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON $classification';
  }

  @override
  String get nuforcAttribution => 'NUFORC Informe de base de datos';

  @override
  String get nuforcCaseNumber => 'Caso';

  @override
  String get nuforcGenericTitle => 'NUFORC Informe de control';

  @override
  String get mediaImageNotFound => 'Imagen no encontrada';

  @override
  String get mediaPlayVideo => 'Jugar vídeo';

  @override
  String get mediaViewImage => 'Ver imagen';

  @override
  String mediaCount(Object count) {
    return '${count}_ imágenes';
  }

  @override
  String get mediaCountSingle => '1 imagen';

  @override
  String mediaMoreImages(Object count) {
    return '+${count}_ more';
  }

  @override
  String get errorNotFound => 'Beep no encontrada';

  @override
  String get errorLoadError => 'Failed to load beep details';

  @override
  String get shareYourThoughts =>
      'Comparte tus pensamientos sobre este avistamiento...';

  @override
  String get postComment => 'Public Comment';

  @override
  String get loggedInAs => 'Logged en';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get notFollowing => 'No seguir';

  @override
  String get follow => 'Seguir';

  @override
  String get navRecentBeeps => 'Beeps recientes';

  @override
  String get navMap => 'Mapa';

  @override
  String get navDownloadApp => 'Descargar App';

  @override
  String get alertLevel => 'Nivel de alerta';

  @override
  String get witnesses => 'Testigos';

  @override
  String get confirmations => 'Confirmaciones';

  @override
  String get reporterLabel => 'Informe del usuario';

  @override
  String get coordinatesLabel => 'Coordinaciones';

  @override
  String get eventTime => 'Hora del evento';

  @override
  String get reportedTime => 'Tiempo informado';

  @override
  String get addedToUfobeep => 'Añadido a UFOBeep';

  @override
  String get mufonDatabaseReport => 'MUFON Número de caso:';

  @override
  String get copyShortLinkTitle => 'Enlace de copia a portapapeles';

  @override
  String get imageNotFound => 'Imagen no encontrada';

  @override
  String get ufoSightingAlt => 'OVNI Alerta de ovnis';

  @override
  String get celestialDataTitle => 'Objetos Celestiales';

  @override
  String get visiblePlanets => 'Planetas visibles';

  @override
  String get locationDataTitle => 'Información de ubicación';

  @override
  String get timezone => 'Zona horaria';

  @override
  String get coordinates => 'Coordinaciones';

  @override
  String get processingSummaryTitle => 'Resumen del proceso';

  @override
  String get processingTime => 'Tiempo de procesamiento';

  @override
  String get successful => 'Éxito';

  @override
  String get failed => 'Failed';

  @override
  String get locationEnrichmentTitle => 'Detalles de la ubicación';

  @override
  String get aircraftDataSource => 'Fuente de datos';

  @override
  String get noAircraftDetected => 'No se detectó ningún avión';

  @override
  String get sightingReport => 'Informe de control';

  @override
  String get ufoAlert => 'OVNI Alerta';

  @override
  String get alert => 'Alerta';

  @override
  String get notificationTickerUfoAlert =>
      'Alerta OVNI - Nuevo Avistamiento cerca';

  @override
  String get notificationTickerComment => 'Nuevo comentario en la alerta OVNI';

  @override
  String get weatherConditions => 'Condiciones meteorológicas';

  @override
  String get visibility => 'Visibilidad';

  @override
  String get humidity => 'Humedad';

  @override
  String get pressure => 'Presión';

  @override
  String get locationDetails => 'Detalles de la ubicación';

  @override
  String get city => 'Ciudad';

  @override
  String get state => 'Estado';

  @override
  String get country => 'País';

  @override
  String get satelliteActivity => 'Actividad por satélite';

  @override
  String get satellitesVisibleOverhead =>
      'Satélites visibles en el tiempo de visualización & ubicación';

  @override
  String get dataSource => 'Fuente de datos';

  @override
  String get blackskyImagery => 'Imágenes BlackSky';

  @override
  String get resolution => 'Resolución';

  @override
  String get groundResolution => 'resolución de suelo de 35cm';

  @override
  String get delivery => 'Entrega';

  @override
  String get averageDelivery => 'promedio de 90 minutos';

  @override
  String get cost => 'Costo';

  @override
  String get skyfiSatelliteImagery => 'SkyFi Satellite Imagen';

  @override
  String get region => 'Región';

  @override
  String get remoteArea => 'Zona remota';

  @override
  String get startingPrice => 'Precio inicial';

  @override
  String get coverage => 'Cobertura';

  @override
  String get confidenceCoverage => 'confianza del 95%';

  @override
  String get status => 'Situación';

  @override
  String get shareThoughts =>
      'Comparte tus pensamientos sobre este avistamiento...';

  @override
  String get postCommand => 'Comando postal';

  @override
  String get clouds => 'Clouds';

  @override
  String get windLabel => 'Viento';

  @override
  String get filterAlerts => 'Alertas de filtro';

  @override
  String get alertSource => 'Fuente de alerta';

  @override
  String get ufobeepOnly => 'UFOBeep Only';

  @override
  String get ufobeepOnlyDescription =>
      'Mostrar sólo informes originales de UFOBeep (excluya la base de datos MUFON)';

  @override
  String get alertDistanceRange => 'Distancia de alerta';

  @override
  String get showAllAlerts => 'Mostrar todas las alertas';

  @override
  String get showAll => 'Mostrar todos';

  @override
  String get distanceSliderDescription =>
      'Arrastre para ajustar lo lejos que desea ver alertas. Comience desde la distancia de visibilidad del tiempo hasta mostrar todas las alertas independientemente de la distancia.';

  @override
  String get applyFilters => 'Aplicar filtros';

  @override
  String get notificationRange => 'Gama de notificación';

  @override
  String get notificationRangeDescription =>
      'Obtener alertas de presión para los avistamientos dentro de esta distancia';

  @override
  String get viewingRange => 'Alcance de visualización';

  @override
  String get viewingRangeDescription =>
      'Mostrar avistamientos dentro de esta distancia al navegar';

  @override
  String get weatherVisibility => 'Visibilidad meteorológica (~10km)';

  @override
  String get localArea => 'Zona local (25 km)';

  @override
  String get regional => 'Regional';

  @override
  String get pushNotifications => 'Notificaciones push';

  @override
  String get alertBrowsing => 'Alerta Browsing';

  @override
  String get pushAlertsWithinDistance =>
      'Obtenga notificaciones dentro de este rango';

  @override
  String get showAlertsWhenBrowsing => 'Filtrar lo que ves en la lista';

  @override
  String get heroMainTagline =>
      'Obtenga una señal en su teléfono cuando los OVNIs están cerca';

  @override
  String get heroSecondaryTagline => 'Descubre cuándo y dónde mirar el cielo';

  @override
  String get sourceFilters => 'Fuente';

  @override
  String get sourceFiltersDescription =>
      'Elija qué informes aparecen en su alimentación';

  @override
  String get ufobeepAndMufon => 'UFOBeep + MUFON';

  @override
  String get ufobeepOnlySource => 'OVNI solo';

  @override
  String get mufonOnlySource => 'MUFON';

  @override
  String get browseFilters => 'Navega';

  @override
  String get browseFiltersDescription => 'Cómo ver y ordenar alertas';

  @override
  String get sortByNewest => 'Más reciente';

  @override
  String get sortByNearest => 'Más cercano';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get pushAlertsTitle => 'Alertas de empuje';

  @override
  String get pushAlertsDescription => '¿Qué pings tu teléfono';

  @override
  String get alertRadius => 'Alerta Radius';

  @override
  String get mufonNoPushInfo =>
      'Los informes de MUFON son importados nocturnamente y no activan alertas de presión';

  @override
  String get privacyData => 'Privacidad \" Datos';

  @override
  String get privacyPolicyDesc => 'Cómo protegemos y utilizamos sus datos';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String get termsOfServiceDesc => 'Términos y condiciones legales';

  @override
  String get locationTracking => 'Localización de seguimiento';

  @override
  String get locationTrackingDesc =>
      'Ubicación de fondo para alertas de proximidad';

  @override
  String get locationTrackingTitle =>
      'Seguimiento de la localización de fondos';

  @override
  String get locationTrackingExplanation =>
      'UFOBeep monitorea su ubicación en el fondo para enviarle alertas de proximidad cuando los avistamientos OVNI suceden cerca de su ubicación actual, incluso cuando usted está lejos de casa.';

  @override
  String get locationTrackingBattery =>
      'Usa geofencing inteligente para el impacto de la batería';

  @override
  String get backgroundLocationTracking => 'Enable Background Seguimiento';

  @override
  String get locationTrackingActive =>
      'Localización de vigilancia para alertas de proximidad';

  @override
  String get locationTrackingInactive =>
      'El seguimiento de la ubicación es deshabilitado';

  @override
  String get locationTrackingDisabledWarning =>
      'No recibirás alertas de proximidad cuando te mudes a nuevas ubicaciones';

  @override
  String get trackingStatus => 'Situación de seguimiento';

  @override
  String get monitoringStatus => 'Supervisión';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  @override
  String get lastKnownLocation => 'Última ubicación conocida';

  @override
  String get lastLocationUpdate => 'Última actualización';

  @override
  String get movementThreshold => 'Movimiento Umbral';

  @override
  String get updateFrequency => 'Frecuencia de actualización';

  @override
  String get batteryImpact => 'Impacto de la batería';

  @override
  String get dataPrivacy => 'Privacidad de datos';

  @override
  String get locationPermissionExplanation =>
      'UFOBeep necesita \'Permite siempre\' permiso de ubicación para monitorear su movimiento y enviar alertas de proximidad cuando usted está en nuevas ubicaciones.';

  @override
  String get benefitsTitle => 'Beneficios';

  @override
  String get locationTrackingBenefits =>
      '• Recibe alertas de ovnis dondequiera que viajes\n• Actualizaciones automáticas de ubicación\n• No se requiere configuración manual';

  @override
  String get allowLocationAccess => 'Permitir acceso a la ubicación';

  @override
  String get locationPermissionRequired =>
      'El permiso de ubicación es necesario para el seguimiento de antecedentes';

  @override
  String get locationTrackingEnabled =>
      'Seguimiento de la ubicación de los fondos habilitado';

  @override
  String get locationTrackingDisabled =>
      'Seguimiento de la ubicación de los fondos discapacitados';

  @override
  String get justNow => 'Ahora';

  @override
  String minutesAgo(int minutes) {
    return 'Hace unos minutos';
  }

  @override
  String hoursAgo(int hours) {
    return 'hace unas horas';
  }

  @override
  String daysAgo(int days) {
    return 'hace unos días';
  }

  @override
  String get dataManagement => 'Gestión de datos';

  @override
  String get dataManagementDesc => 'Exportar o eliminar los datos de su cuenta';

  @override
  String get splashTagline => 'Alertas de avistamiento en tiempo real';

  @override
  String get splashStartingUp => 'Comenzando...';

  @override
  String get splashInitializationFailed => 'La inicialización falló';

  @override
  String get splashInitializationFailedTitle => 'Inicialización fallida';

  @override
  String get splashInitializationError =>
      'La aplicación no inicializó correctamente:';

  @override
  String get splashRetry => 'Retry';

  @override
  String get splashContinue => 'Continuar';

  @override
  String get splashInitializing => 'Iniciando...';

  @override
  String signInWelcome(String username) {
    return 'Bienvenido ${username}_!';
  }

  @override
  String signInFailed(String error) {
    return 'El registro falló: $error';
  }

  @override
  String get signInPleaseEnterEmail =>
      'Por favor, introduzca su dirección de correo electrónico';

  @override
  String get signInPleaseEnterValidEmail =>
      'Por favor, introduzca una dirección de correo electrónico válida';

  @override
  String get signInMagicLinkSent =>
      '¡El enlace mágico enviado! Revise su correo electrónico y haga clic en el enlace para iniciar sesión.';

  @override
  String get signInMagicLinkFailed =>
      'Failed to send magic link. Por favor, inténtalo de nuevo.';

  @override
  String get signInAllDataCleared => 'Todos los datos despejados';

  @override
  String get signInSubtitle =>
      'Alertas de avistamiento de OVNI en tiempo real e informes de MUFON';

  @override
  String get signInGoogleLoading => 'Firmando...';

  @override
  String get signInContinueWithGoogle => 'Continuar con Google';

  @override
  String get signInOr => 'o';

  @override
  String get signInWithEmail => 'Inicia sesión con Email';

  @override
  String get signInEmailDescription =>
      'Te enviaremos un enlace seguro para iniciar sesión';

  @override
  String get signInEmailAddress => 'Dirección de correo electrónico';

  @override
  String get signInEmailPlaceholder => 'su@email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'Prueba de nuevo en ${seconds}_s';
  }

  @override
  String get signInSending => 'Enviando...';

  @override
  String get signInSendMagicLink => 'Enviar enlace mágico';

  @override
  String get signInCheckEmail =>
      '¡Revise su correo electrónico! El enlace expira en 15 minutos.';

  @override
  String get signInSecureAuth => 'Autenticación segura';

  @override
  String get signInSecureAuthDescription =>
      'Utilice Google Sign-In para el acceso instantáneo, o correo electrónico enlaces mágicos que caducan en 15 minutos.';

  @override
  String get signInClearAllDataDebug => 'Borrar todos los datos (Debug)';

  @override
  String get emailAuthFailedToSend => 'Failed to send email';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'Failed to send email. Por favor, inténtalo de nuevo.';

  @override
  String get emailAuthInvalidEmail =>
      'Dirección de correo electrónico inválida. Por favor, compruebe el formato.';

  @override
  String get emailAuthUserNotFound =>
      'Ninguna cuenta encontrada con esta dirección de correo electrónico.';

  @override
  String get emailAuthTooManyRequests =>
      'Demasiados intentos. Por favor, intente de nuevo más tarde.';

  @override
  String get emailAuthOperationNotAllowed =>
      'El registro de enlace de correo electrónico no está habilitado.';

  @override
  String get emailAuthQuotaExceeded =>
      'La cuota de correo electrónico excedió. Por favor, inténtalo de nuevo mañana.';

  @override
  String get emailAuthVerificationFailed =>
      'La verificación por correo electrónico falló. Por favor, inténtalo de nuevo.';

  @override
  String get emailAuthTitle => 'Verificación de correo electrónico';

  @override
  String get emailAuthVerifyYourEmail => 'Verificar su correo electrónico';

  @override
  String get emailAuthDescription =>
      'Agregue su dirección de correo electrónico para la recuperación de la cuenta y la seguridad. Te enviaremos un enlace de registro seguro.';

  @override
  String get emailAuthEmailAddress => 'Dirección de correo electrónico';

  @override
  String get emailAuthEmailPlaceholder => 'su.email@example.com';

  @override
  String get emailAuthPleaseEnterEmail =>
      'Por favor, introduzca su dirección de correo electrónico';

  @override
  String get emailAuthPleaseEnterValidEmail =>
      'Por favor, introduzca una dirección de correo electrónico válida';

  @override
  String get emailAuthCheckEmailToContinue =>
      'Revise su correo electrónico y toque el enlace de verificación para continuar.';

  @override
  String get emailAuthResendEmail => 'Enviar correo electrónico';

  @override
  String get emailAuthSendVerificationEmail => 'Enviar verificación Email';

  @override
  String get emailAuthHowItWorks =>
      'Cómo funciona la verificación de correo electrónico';

  @override
  String get emailAuthHowItWorksSteps =>
      '1. Le enviamos un enlace de inicio de sesión seguro\n2. Revisa tu correo electrónico y toca el enlace\n3. Tu correo electrónico se verifica automáticamente\n4. ¡No se necesitan contraseñas!';

  @override
  String get emailAuthSecurityNotice =>
      'La verificación de correo electrónico ayuda a asegurar su cuenta y permite la recuperación de la cuenta si pierde acceso a su dispositivo.';

  @override
  String get phoneAuthFailedToSendCode =>
      'No se pudo enviar el código de verificación. Por favor, inténtalo de nuevo.';

  @override
  String get phoneAuthInvalidCodeTryAgain =>
      'Código de verificación inválido. Por favor, inténtalo de nuevo.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'Número de teléfono verificado: $phoneNumber';
  }

  @override
  String get phoneAuthVerificationFailed =>
      'La verificación del teléfono falló. Por favor, inténtalo de nuevo.';

  @override
  String get phoneAuthCodeResent => 'Resentimiento del código de verificación';

  @override
  String get phoneAuthFailedToResendCode =>
      'Failed to resend code. Por favor, inténtalo de nuevo.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'Número de teléfono inválido. Por favor, compruebe el formato.';

  @override
  String get phoneAuthTooManyRequests =>
      'Demasiados intentos. Por favor, intente de nuevo más tarde.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'Código de verificación inválido. Por favor, compruebe e inténtelo de nuevo.';

  @override
  String get phoneAuthSessionExpired =>
      'Sesión de verificación expirada. Por favor, solicite un nuevo código.';

  @override
  String get phoneAuthSmsQuotaExceeded =>
      'Cuota de SMS superada. Por favor, inténtalo de nuevo mañana.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'Este número de teléfono ya está relacionado con otra cuenta.';

  @override
  String get phoneAuthVerificationFailedGeneric =>
      'La verificación falló. Por favor, inténtalo de nuevo.';

  @override
  String get phoneAuthTitle => 'Verificación de teléfonos';

  @override
  String get phoneAuthVerifyYourPhone => 'Verifique su teléfono';

  @override
  String get phoneAuthEnterVerificationCode => 'Ingrese la verificación Código';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'Añada su número de teléfono para la recuperación de la cuenta y la seguridad';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return 'Introduzca el código de 6 dígitos enviado a $phoneNumber';
  }

  @override
  String get phoneAuthPhoneNumber => 'Número de teléfono';

  @override
  String get phoneAuthPhonePlaceholder => '+1 (555) 123-4567';

  @override
  String get phoneAuthPleaseEnterPhone => 'Introduzca su número de teléfono';

  @override
  String get phoneAuthPleaseEnterValidPhone =>
      'Introduzca un número de teléfono válido';

  @override
  String get phoneAuthVerificationCode => 'Código de verificación';

  @override
  String get phoneAuthPleaseEnterSixDigitCode =>
      'Por favor, introduzca el código de 6 dígitos';

  @override
  String get phoneAuthResendCode => 'Código de reenviamiento';

  @override
  String get phoneAuthSendVerificationCode => 'Enviar verificación Código';

  @override
  String get phoneAuthVerifyCode => 'Verificar Código';

  @override
  String get phoneAuthChangePhoneNumber => 'Cambiar número de teléfono';

  @override
  String get phoneAuthSmsNotice =>
      'Le enviaremos un código de verificación vía SMS. Se pueden aplicar tasas estándar de mensajes.';

  @override
  String get phoneAuthCodeExpires =>
      'El código expira en 60 segundos. Revisa tus mensajes.';

  @override
  String get yourDataRights => 'Sus Derechos de Datos';

  @override
  String get dataRightsExplanation =>
      'Usted tiene control completo sobre sus datos personales. Puede exportar todos sus datos o eliminar permanentemente su cuenta en cualquier momento.';

  @override
  String get exportYourData => 'Exportar sus datos';

  @override
  String get exportDataDescription => 'Descargar todos los datos de su cuenta';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get exportingData => 'Exportando...';

  @override
  String get exportDataDetails =>
      'Incluye: perfil, abejas, comentarios, información del dispositivo y preferencias. Los datos se proporcionan en formato JSON.';

  @override
  String get dataExportedSuccessfully => 'Datos exportados con éxito';

  @override
  String get dataExportFailed => 'Failed to export data';

  @override
  String get deleteAccount => 'Suprimir la Cuenta';

  @override
  String get deleteAccountDescription =>
      'Eliminar permanentemente su cuenta y todos los datos';

  @override
  String get deleteAccountWarning =>
      'Esta acción no se puede deshacer. Todos sus pitidos, comentarios y datos de cuenta serán eliminados permanentemente.';

  @override
  String get deleteMyAccount => 'Suprimir Mi Cuenta';

  @override
  String get deletingAccount => 'Eliminar...';

  @override
  String get deleteAccountConfirmTitle => 'Suprimir la Cuenta';

  @override
  String get deleteAccountConfirmMessage =>
      '¿Está absolutamente seguro de querer borrar su cuenta? Esta acción es permanente y no se puede deshacer.';

  @override
  String get dataWillBeDeleted =>
      'Se eliminarán permanentemente los siguientes datos:';

  @override
  String get deletedDataList =>
      '• Su perfil y nombre de usuario\n• Todos tus pitidos e informes\n• Todos sus comentarios\n• Datos de registro de dispositivos\n• Datos de ubicación y preferencia';

  @override
  String get deleteAccountPermanent => 'Suprímase permanentemente';

  @override
  String get accountDeletedSuccessfully => 'Cuenta eliminada con éxito';

  @override
  String get accountDeletionFailed => 'Failed to delete account';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a UFOBeep';

  @override
  String get onboardingWelcomeBody =>
      'Obtenga alertas en tiempo real cuando los OVNIs están cerca. Nunca vuelvas a extrañar un avistamiento.';

  @override
  String get onboardingAlertsTitle => 'Mantente informado';

  @override
  String get onboardingAlertsBody =>
      'Establece lo lejos que los avistamientos deben ser para desencadenar alertas.';

  @override
  String get onboardingReportTitle => '¿Ves algo? ¡Escúpelo!';

  @override
  String get onboardingReportBody =>
      'Pulse una foto o un video y comparta al instante con los observadores cercanos.';

  @override
  String get onboardingPermissionsTitle => 'Su cámara y ubicación';

  @override
  String get onboardingPermissionsBody =>
      'Habilitar cámara, ubicación y notificaciones para que pueda:\n– Reportar avistamientos rápido\n– Obtener alertas para los OVNIs cerca de usted';

  @override
  String get onboardingCameraTitle => 'Capture Evidence';

  @override
  String get onboardingCameraBody =>
      'Comparte fotos y videos que acabas de capturar desde tu galería o presiona el icono UFOBeep para comenzar en modo de cámara instantánea.';

  @override
  String get onboardingCompassTitle => 'A ver dónde miraban';

  @override
  String get onboardingCompassBody =>
      'Compass le muestra la dirección exacta que el testigo estaba mirando cuando vieron al OVNI. ¡Apunta tu teléfono y mira!';

  @override
  String get onboardingCommunityTitle => 'Únete a los Skywatchers';

  @override
  String get onboardingCommunityBody =>
      'Explore los avistamientos, acceda a informes de MUFON y conéctese con otros observadores de cielo.';

  @override
  String get skip => 'Saltarse';

  @override
  String get getStarted => 'Empieza';

  @override
  String get viewOnboardingAgain => 'Ver A bordo de nuevo';

  @override
  String get customAlertRange => 'Distancia de alerta personalizada';

  @override
  String get enterRangeKm => 'Entrada en km (1-99999)';

  @override
  String get largeRangeWarning =>
      'Grandes rangos (con100 km) pueden generar muchas alertas';

  @override
  String get globalRangeWarning =>
      'Los rangos muy grandes (con 1000km) te enviarán alertas de todo el mundo';

  @override
  String get invalidRange => 'Introduzca un número entre 1 y 99999';

  @override
  String get celestialSunDaylight =>
      'El sol está levantado - las condiciones de la luz del día pueden afectar la visibilidad del avistamiento';

  @override
  String get celestialSunTwilight =>
      'Twilight conditions - algo de visibilidad pero más oscuro que la luz del día';

  @override
  String get celestialSunDark =>
      'Condiciones oscuras - óptimas para observar objetos en el cielo';

  @override
  String celestialMoonBright(Object phase) {
    return 'Bright $phase luna visible - puede iluminar o ocultar otros objetos';
  }

  @override
  String celestialMoonModerate(Object phase) {
    return '$phase luna visible - condiciones de iluminación moderadas';
  }

  @override
  String celestialMoonThin(Object phase) {
    return 'Thin $phase luna visible - iluminación mínima';
  }

  @override
  String celestialMoonHidden(Object phase) {
    return '$phase luna debajo del horizonte - ninguna iluminación lunar';
  }

  @override
  String get celestialNoPlanets =>
      'No hay planetas brillantes visibles que puedan confundirse con ovnis';

  @override
  String celestialPlanetHigh(Object altitude, Object planet) {
    return '${altitude}_ alta overhead (${planet}_ °) - muy prominente';
  }

  @override
  String celestialPlanetMedium(Object altitude, Object planet) {
    return '${altitude}_ visible at ${planet}__° - podría confundirse con aviones';
  }

  @override
  String celestialPlanetLow(Object altitude, Object planet) {
    return '$altitude bajo en horizonte (${planet}_°)';
  }

  @override
  String get celestialNoStars =>
      'No hay estrellas inusualmente brillantes visibles';

  @override
  String celestialStarSingle(Object altitude, Object star) {
    return '${altitude}_ prominente en ${star}_nivel';
  }

  @override
  String celestialStarsMultiple(Object count, Object names) {
    return '$names estrellas brillantes visibles - $count';
  }

  @override
  String get celestialSummaryDaylight => 'Condiciones del día';

  @override
  String get celestialSummaryDark => 'Condiciones del cielo oscuro';

  @override
  String get celestialSummaryMoonUp => 'luna iluminada presente';

  @override
  String get celestialSummaryMoonDown => 'sin iluminación de luna';

  @override
  String celestialSummaryManyObjects(Object count) {
    return '$count objetos brillantes que podrían confundirse con OVNIS';
  }

  @override
  String celestialSummarySomeObjects(Object count) {
    return '${count}_ objeto(s) brillante visible';
  }

  @override
  String get celestialSummaryFewObjects =>
      'objetos brillantes mínimos en el cielo';

  @override
  String celestialSkySummary(Object conditions) {
    return 'Condiciones del cielo: $conditions';
  }

  @override
  String get planetVenus => 'Venus';

  @override
  String get planetJupiter => 'Júpiter';

  @override
  String get planetSaturn => 'Saturno';

  @override
  String get planetMars => 'Marte';

  @override
  String get planetMercury => 'Mercurio';

  @override
  String get planetUranus => 'Urano';

  @override
  String get planetNeptune => 'Neptuno';

  @override
  String get starSirius => 'Sirius';

  @override
  String get starCanopus => 'Canopus';

  @override
  String get starArcturus => 'Arcturus';

  @override
  String get starVega => 'Vega';

  @override
  String get starCapella => 'Capella';

  @override
  String get starRigel => 'Rigel';

  @override
  String get starProcyon => 'Procyon';

  @override
  String get starBetelgeuse => 'Betelgeuse';

  @override
  String get moonPhaseNew => 'Luna nueva';

  @override
  String get moonPhaseWaxingCrescent => 'Crescente encerado';

  @override
  String get moonPhaseFirstQuarter => 'Primer trimestre';

  @override
  String get moonPhaseWaxingGibbous => 'Depilando a Gibbous';

  @override
  String get moonPhaseFull => 'Luna Llena';

  @override
  String get moonPhaseWaningGibbous => 'Waning Gibbous';

  @override
  String get moonPhaseThirdQuarter => 'Tercer trimestre';

  @override
  String get moonPhaseWaningCrescent => 'Waning Crescent';

  @override
  String planetBelowHorizon(Object planet) {
    return '${planet}_ debajo del horizonte';
  }

  @override
  String planetHighOverheadProminent(Object altitude, Object planet) {
    return '${altitude}_ alta overhead (${planet}_ °) - muy prominente';
  }

  @override
  String planetMidSkyProminent(Object altitude, Object planet) {
    return '${altitude}_ ${planet}_° - prominente';
  }

  @override
  String planetMidSky(Object altitude, Object planet) {
    return '${altitude}_ ${planet}_°';
  }

  @override
  String starVeryBright(Object altitude, Object star) {
    return '$altitude muy brillante en ${star}_ °';
  }

  @override
  String starProminent(Object altitude, Object star) {
    return '${altitude}_ prominente en ${star}_nivel';
  }

  @override
  String starVisible(Object altitude, Object star) {
    return '${altitude}_ ${star}_°';
  }

  @override
  String get altitudeShort => 'Alt';

  @override
  String get magnitudeShort => 'Mag';

  @override
  String satellitesVisibleMightExplain(Object count) {
    return '${count}_ satélites visibles - podría explicar el avistamiento';
  }

  @override
  String satellitesVisibleUnlikelyExplain(Object count) {
    return '${count}_ satélites visibles - poco probable que explique el avistamiento';
  }

  @override
  String get noSatellitesVisible => 'No hay satélites visibles';

  @override
  String aircraftDetectedInRadius(Object count, Object radius) {
    return '$count aeronaves detectadas dentro de ${radius}km';
  }

  @override
  String get processingAlert => 'Procesando alerta OVNI...';

  @override
  String get analyzingEnvironment => 'Análisis de las condiciones ambientales';

  @override
  String get weatherAnalysis => 'Weather Analysis';

  @override
  String get locationAnalysis => 'Análisis de ubicación';

  @override
  String get aircraftTracking => 'Aircraft Tracking';

  @override
  String get satelliteAnalysis => 'Análisis por satélite';

  @override
  String get celestialAnalysis => 'Análisis Celestial';

  @override
  String analyzing(Object processor) {
    return 'Analyzing ${processor}_...';
  }

  @override
  String get processorWeather => 'condiciones meteorológicas';

  @override
  String get processorLocation => 'ubicación detalles';

  @override
  String get processorAircraft => 'aviones cercanos';

  @override
  String get processorSatellites => 'puestos de satélite';

  @override
  String get processorCelestial => 'objetos celestiales';

  @override
  String get calculatingCelestialData => 'Calculando datos celestiales...';

  @override
  String get sunLabel => 'Sol';

  @override
  String get moonLabel => 'Luna';

  @override
  String planetsVisible(int count) {
    return 'Planetas: $count visible';
  }

  @override
  String get starsLabel => 'Estrellas';

  @override
  String get planetsLabel => 'Planetas';

  @override
  String moonWithPhase(String phase) {
    return 'Luna ($phase)';
  }

  @override
  String get noSatellitesVisibleAtTime =>
      'No había satélites visibles en el momento exacto de su avistamiento';

  @override
  String get satellitesVisibleOverheadAtTime =>
      'Satélites visibles en el tiempo de visualización & ubicación';

  @override
  String get belowHorizon => 'debajo del horizonte';

  @override
  String get analysisFailedGeneric => 'Análisis fracasado';

  @override
  String get unknownWeather => 'Desconocida';

  @override
  String get noWeatherDescription => 'Sin descripción';

  @override
  String get altitudeAbbrev => 'Alt';

  @override
  String get azimuthAbbrev => 'Az';

  @override
  String satellitesVisibleNow(int count) {
    return 'Satélites (${count}_ visible ahora)';
  }

  @override
  String sunWithDescription(String description) {
    return 'Sol:';
  }

  @override
  String moonWithDescription(String description) {
    return 'Moon:';
  }

  @override
  String get unknownPlanet => 'Unknown Planet';

  @override
  String get unknownStar => 'Unknown Star';

  @override
  String get unknownSatellite => 'Satélite desconocido';

  @override
  String get unknownDirection => 'dirección desconocida';

  @override
  String get brightStars => 'Estrellas brillantes';

  @override
  String get satellites => 'Satélites';

  @override
  String seeAllSatellites(int count) {
    return 'Ver todos los satélites $count';
  }

  @override
  String maxElevation(String degrees) {
    return 'Altura máxima: ${degrees}_°';
  }

  @override
  String magnitude(String value) {
    return 'Magnitud: $value';
  }

  @override
  String get unknownGeneric => 'Desconocida';

  @override
  String altitudeValue(String degrees) {
    return '${degrees}_nivel';
  }

  @override
  String azimuthValue(String degrees) {
    return '${degrees}_ ° azimuth';
  }

  @override
  String get noCelestialDataAvailable => 'No hay datos celestes disponibles.';

  @override
  String get gettingLocation => 'Conseguir su ubicación...';

  @override
  String get media => 'Medio';

  @override
  String get locationRequired => 'Ubicación requerida';

  @override
  String get confirmingWitness => 'Confirmando el testigo...';

  @override
  String get chooseYourUsername => 'Elija su nombre de usuario';

  @override
  String get moreNames => 'Más nombres';

  @override
  String get notificationSettings => 'Ajustes de notificación';

  @override
  String get quickActions => 'Medidas rápidas';

  @override
  String get doNotDisturb => 'No molestar';

  @override
  String get temporarilySilenceNotifications =>
      'Silenciar temporalmente todas las notificaciones';

  @override
  String get oneHour => '1h';

  @override
  String get eightHours => '8h';

  @override
  String get oneDay => '1 día';

  @override
  String get startTime => 'Hora de inicio';

  @override
  String get endTime => 'Hora final';

  @override
  String get allowCriticalAlertsDuringQuietHours =>
      'Permitir alertas críticas durante horas tranquilas';

  @override
  String get silenceNotificationsDuringSleepHours =>
      'Notificaciones de silencio durante las horas de sueño';

  @override
  String quietHoursActiveTimeRange(String startTime, String endTime) {
    return 'Active $endTime $startTime';
  }

  @override
  String get followingAlerts => 'Following Alerts';

  @override
  String activeCount(int count) {
    return '$count active';
  }

  @override
  String get unfollow => 'Unfollow';

  @override
  String get unfollowAlert => 'Unfollow Alert';

  @override
  String commentsCount(int count) {
    return '${count}_ comentarios';
  }

  @override
  String get photo => 'Foto';

  @override
  String get video => 'Video';

  @override
  String get initializationComplete => '¡La inicialización completa!';

  @override
  String get validatingEnvironment => 'Medio ambiente validante...';

  @override
  String get requestingPermissions => 'Solicitando permisos...';

  @override
  String get loadingAuthSession => 'Cargando sesión de austeridad...';

  @override
  String get checkingUserRegistration =>
      'Comprobando el registro del usuario...';

  @override
  String get loadingPreferences => 'Cargando preferencias...';

  @override
  String get settingUpLocalization => 'Configurar la localización...';

  @override
  String get checkingConnectivity => 'Comprobando conectividad...';

  @override
  String get gatheringDeviceInfo => 'Reunión de información del dispositivo...';

  @override
  String get translating => 'Traduciendo...';

  @override
  String get showOriginal => 'Mostrar original';

  @override
  String translateTo(String language) {
    return 'Traducir a $language';
  }

  @override
  String translatedFrom(String language) {
    return 'Traducido del $language';
  }

  @override
  String translateContent(String language) {
    return 'Traducir contenido a $language';
  }

  @override
  String get weatherClear => 'Despejado';

  @override
  String get weatherClearSky => 'cielo claro';

  @override
  String get rain => 'Lluvia';

  @override
  String get snow => 'Nieve';

  @override
  String get thunderstorm => 'Thunderstorm';

  @override
  String get drizzle => 'Drizzle';

  @override
  String get fog => 'Fog';

  @override
  String get fewClouds => 'pocas nubes';

  @override
  String get scatteredClouds => 'nubes dispersas';

  @override
  String get brokenClouds => 'nubes rotas';

  @override
  String get overcastClouds => 'nubes nubladas';

  @override
  String get lightRain => 'lluvia ligera';

  @override
  String get moderateRain => 'lluvia moderada';

  @override
  String get heavyRain => 'lluvia pesada';

  @override
  String aircraftDetectedCurrentPositions(
    int count,
    String radius,
    Object raggio,
  ) {
    return '$count aeronaves detectadas dentro de ${radius}km (posiciones actuales)';
  }

  @override
  String dimSatellitesUnlikely(int count) {
    return '${count}_ satélites dim visibles - poco probable que explique el avistamiento';
  }

  @override
  String get mufonReportingDate => 'MUFON Fecha de presentación';

  @override
  String satelliteNameDirection(String name, String direction) {
    return '$name - $direction';
  }
}
