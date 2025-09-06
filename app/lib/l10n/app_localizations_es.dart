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
  String get enablePushNotifications => 'Permitir notificaciones de empuje';

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
  String get noAlertsFound => 'No matching alerts';

  @override
  String get alertsFilterHelp =>
      'Try adjusting your filters to see more results';

  @override
  String get verified => 'Verified';

  @override
  String get beepOnly => 'beep only';

  @override
  String get videoOnly => 'video only';

  @override
  String get imageOnly => 'image only';

  @override
  String get timeJustNow => 'Just now';

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
  String get loadMoreAlerts => 'Load More Alerts';

  @override
  String get toggleMufonTooltip => 'Toggle MUFON sightings';

  @override
  String get showMufonData => 'Show MUFON data';

  @override
  String get hideMufonData => 'Hide MUFON data';

  @override
  String get showingUfoBeepOnly => 'Showing only UFOBeep reports';

  @override
  String get showingAllReports =>
      'Showing all reports including MUFON database';

  @override
  String get filteredSuffix => 'filtered';
}
