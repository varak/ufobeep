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
  String get close => 'Cerrar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get retry => 'Reintentar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get done => 'Listo';

  @override
  String get loading => 'Cargando…';

  @override
  String get processing => 'Procesando…';

  @override
  String get errorGeneric => 'Algo salió mal.';

  @override
  String get networkError => 'Error de red. Verifica tu conexión.';

  @override
  String get permissionsRequired => 'Permisos requeridos';

  @override
  String get learnMore => 'Más información';

  @override
  String get welcomeTitle => 'Bienvenido a UFOBeep';

  @override
  String get welcomeSubtitle => 'Alertas de OVNIs en tiempo real cerca de ti';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get continueAsGuest => 'Continuar como invitado';

  @override
  String get enterUsername => 'Ingresa un nombre de usuario';

  @override
  String get username => 'Usuario';

  @override
  String get usernameUpdated => 'Usuario actualizado';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Configuración';

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
  String get noAlerts => 'Aún no hay alertas cercanas.';

  @override
  String get pullToRefresh => 'Desliza para actualizar';

  @override
  String alertDistance(String distance) {
    return '$distance away';
  }

  @override
  String alertDirection(int bearing) {
    return 'Rumbo $bearing°';
  }

  @override
  String get viewAlert => 'Ver alerta';

  @override
  String get viewOnMap => 'Ver en el mapa';

  @override
  String get iSeeItToo => '¡Yo también lo veo!';

  @override
  String get confirmWitnessed =>
      '¿Confirmas que presenciaste este avistamiento?';

  @override
  String get witnessConfirmed => 'Gracias — tu confirmación fue publicada.';

  @override
  String get createBeepTitle => 'Enviar un Beep';

  @override
  String get beepExplain =>
      'Captura lo que ves y avisa a los observadores cercanos.';

  @override
  String get capturePhoto => 'Tomar foto';

  @override
  String get captureVideo => 'Grabar video';

  @override
  String get pickFromGallery => 'Elegir de la galería';

  @override
  String get descriptionHint => 'Describe lo que ves en el cielo…';

  @override
  String get submitBeep => 'Enviar Beep';

  @override
  String get beepSent => 'Beep enviado';

  @override
  String get uploadingMedia => 'Subiendo contenido…';

  @override
  String get includeLocation => 'Incluir ubicación';

  @override
  String get includeTimestamp => 'Incluir fecha y hora';

  @override
  String get beepFailed => 'No se pudo enviar el Beep.';

  @override
  String get mediaProcessing => 'Procesando contenido…';

  @override
  String get cameraPermissionTitle => 'Se necesita acceso a la cámara';

  @override
  String get cameraPermissionBody =>
      'Concede acceso para capturar fotos y videos de OVNIs.';

  @override
  String get locationPermissionTitle => 'Se necesita acceso a la ubicación';

  @override
  String get locationPermissionBody =>
      'Usamos tu ubicación para enviar y recibir alertas cercanas.';

  @override
  String get microphonePermissionTitle => 'Se necesita acceso al micrófono';

  @override
  String get microphonePermissionBody =>
      'Concede acceso para grabar video con audio.';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get alertDetailTitle => 'Detalles del avistamiento';

  @override
  String reportedBy(String username) {
    return 'Reportado por $username';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Reportado hace $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return 'a $distance';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Rumbo al objeto: $bearing°';
  }

  @override
  String get openCompass => 'Abrir brújula';

  @override
  String get openAR => 'Abrir capa AR';

  @override
  String get openChat => 'Abrir chat';

  @override
  String get commentsTitle => 'Comentarios';

  @override
  String get addComment => 'Añadir un comentario…';

  @override
  String get send => 'Enviar';

  @override
  String get commentPosted => 'Comentario publicado';

  @override
  String get autoFollowEnabled => 'Ahora sigues esta alerta.';

  @override
  String get noCommentsYet => 'Aún no hay comentarios. ¡Sé el primero!';

  @override
  String get newCommentNotification =>
      'Nuevo comentario en un avistamiento que sigues.';

  @override
  String get mapTitle => 'Mapa en vivo';

  @override
  String get compassTitle => 'Brújula';

  @override
  String get compassSettings => 'Compass Settings';

  @override
  String get compassMode => 'Compass Mode';

  @override
  String get compassStandardMode => 'Standard Mode';

  @override
  String get compassPilotMode => 'Pilot Mode';

  @override
  String get compassStandardDescription => 'Basic heading and navigation';

  @override
  String get compassPilotDescription =>
      'Advanced navigation with ETA and vectoring';

  @override
  String pointingTo(String direction) {
    return 'Pointing to $direction';
  }

  @override
  String get calibratingCompass => 'Calibrando brújula…';

  @override
  String get openAROverlay => 'Abrir capa AR';

  @override
  String get pushTitleAlertNearby => 'Alerta de OVNI cerca de ti';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Se reportó un nuevo avistamiento a $distance.';
  }

  @override
  String get pushTitleComment => 'Nuevo comentario';

  @override
  String get pushBodyComment =>
      'Alguien comentó en un avistamiento que sigues.';

  @override
  String get pushTitleWitness => 'Confirmación de testigo';

  @override
  String get pushBodyWitness => 'Un usuario confirmó que ve el mismo objeto.';

  @override
  String get weather => 'Clima';

  @override
  String cloudCover(int percent) {
    return 'Cloud cover: $percent%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Wind: $speed $unit';
  }

  @override
  String get nearbyAircraft => 'Aeronaves cercanas';

  @override
  String get noAircraft => 'No hay aeronaves cercanas';

  @override
  String get loadingContext => 'Cargando contexto ambiental…';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get enablePushNotifications => 'Activar notificaciones push';

  @override
  String get quietHours => 'Horas de silencio';

  @override
  String get quietHoursDesc => 'Silencia alertas entre horas seleccionadas.';

  @override
  String get dndMode => 'No molestar';

  @override
  String get dndUntil => 'No molestar hasta';

  @override
  String get language => 'Idioma';

  @override
  String get chooseLanguage => 'Elegir idioma';

  @override
  String get units => 'Unidades';

  @override
  String get unitsImperial => 'Imperiales (mi, mph)';

  @override
  String get unitsMetric => 'Métricas (km, km/h)';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfUse => 'Términos de uso';

  @override
  String get errorNoLocation =>
      'Ubicación no disponible. Intenta afuera con cielo despejado.';

  @override
  String get errorNoCamera => 'Cámara no disponible en este dispositivo.';

  @override
  String get errorUploadFailed => 'Falló la carga. Inténtalo de nuevo.';

  @override
  String get errorPermissionDenied => 'Permiso denegado.';

  @override
  String get errorInvalidUsername => 'Ese usuario no está disponible.';

  @override
  String get nothingToShow => 'Nada para mostrar aún.';

  @override
  String get storeShortDesc =>
      'Alertas instantáneas de OVNIs cerca de ti. Captura, confirma y chatea en tiempo real.';

  @override
  String get storeLongDesc =>
      'UFOBeep envía alertas en tiempo real cuando alguien observa un OVNI cerca. Captura fotos y videos, confirma avistamientos con un toque, ve dirección y distancia, y chatea con otros observadores.';

  @override
  String get keywords =>
      'OVNI,UAP,aliens,avistamientos,observación,alertas,radar,brújula';
}
