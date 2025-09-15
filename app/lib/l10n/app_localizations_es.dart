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
    return 'lejos';
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
  String get beepOnly => 'Beep Only';

  @override
  String get reportOnly => 'Report Only';

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
  String get timeFormat => 'Time Format';

  @override
  String get timeFormat24Hour => '24-hour (14:30)';

  @override
  String get timeFormat12Hour => '12-hour (2:30 PM)';

  @override
  String get timeFormatDesc => 'Display time in 24-hour or 12-hour format';

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
  String get unknown => 'desconocida';

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
  String get previousPage => 'Anterior';

  @override
  String get nextPage => 'Siguiente';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Página ${currentPage}_ de ${totalPages}_ (_________ total beeps)';
  }

  @override
  String get heroTagline => 'Obtener alertas cuando salir y mirar hacia arriba';

  @override
  String get heroDescription =>
      'Nunca pierdas otro avistamiento de OVNI. Obtenga alertas en tiempo real cuando alguien cercano ve algo raro en el cielo. Apunte el teléfono y encuentre exactamente dónde buscar.';

  @override
  String get downloadApp => '📱 Descargar App';

  @override
  String get viewAllBeeps => '📋 View All Beeps';

  @override
  String get sightingsMap => 'Mapa de Avistamientos';

  @override
  String get globalSightingNetwork => 'Global Sighting Network';

  @override
  String get howItWorks => 'Cómo funciona UFOBeep';

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
  String get addedToUfobeep => 'Added to UFOBeep';

  @override
  String get mufonDatabaseReport => 'MUFON Informe de base de datos';

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
}
