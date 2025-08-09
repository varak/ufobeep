// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'UFOBeep';

  @override
  String get homeTitle => 'Alertas';

  @override
  String get beepTitle => 'Reportar Avistamiento';

  @override
  String get chatTitle => 'Chat';

  @override
  String get compassTitle => 'Brújula';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get compassStandardMode => 'Modo Estándar';

  @override
  String get compassPilotMode => 'Modo Piloto';

  @override
  String get compassStandardDescription => 'Navegación y rumbo básicos';

  @override
  String get compassPilotDescription =>
      'Navegación avanzada con ETA y vectorización';

  @override
  String get compassArView => 'Vista AR';

  @override
  String get compassCompassView => 'Vista Brújula';

  @override
  String get compassSettings => 'Configuración de Brújula';

  @override
  String get compassMode => 'Modo de Brújula';

  @override
  String get calibrateCompass => 'Calibrar Brújula';

  @override
  String get windInformation => 'Información del Viento';

  @override
  String get noDataAvailable => 'No hay datos disponibles';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get close => 'Cerrar';

  @override
  String get gotIt => 'Entendido';

  @override
  String get compassUnavailable => 'Brújula No Disponible';

  @override
  String get initializingCompass => 'Inicializando Brújula...';

  @override
  String get accessingSensors => 'Accediendo a sensores de magnetómetro y GPS';

  @override
  String unableToAccessSensors(String error) {
    return 'No se puede acceder a los sensores de brújula: $error';
  }

  @override
  String navigationTo(String target) {
    return 'Navegación a $target';
  }

  @override
  String get degrees => '°';

  @override
  String get degreesTrue => '°V';

  @override
  String get degreesMagnetic => '°M';

  @override
  String get heading => 'Rumbo';

  @override
  String get groundSpeed => 'Velocidad Terrestre';

  @override
  String get altitude => 'Altitud';

  @override
  String get bearing => 'Marcación';

  @override
  String get distance => 'Distancia';

  @override
  String get wind => 'Viento';

  @override
  String get component => 'Componente';

  @override
  String get noWindData => 'No hay datos de viento disponibles';

  @override
  String get currentWind => 'Viento Actual:';

  @override
  String get windComponentHelp =>
      'H=Viento de frente T=Viento de cola X=Viento cruzado';

  @override
  String get performance => 'Rendimiento';

  @override
  String get flightInstruments => 'Instrumentos de Vuelo';

  @override
  String get calibrationInstructions =>
      'Para mejorar la precisión de la brújula:\\n\\n1. Mantén el dispositivo alejado de objetos metálicos\\n2. Mueve el dispositivo en patrón de figura-8\\n3. Rota en todas las direcciones\\n4. Completa 3-4 rotaciones completas';

  @override
  String get alertsFilter => 'Filtrar Alertas';

  @override
  String get noAlertsFound => 'No se encontraron alertas';

  @override
  String get reportSighting => 'Reportar Avistamiento';

  @override
  String get takePhoto => 'Tomar Foto';

  @override
  String get selectFromGallery => 'Seleccionar de la Galería';

  @override
  String get submit => 'Enviar';

  @override
  String get sendMessage => 'Enviar mensaje';

  @override
  String get typeMessage => 'Escribe un mensaje...';
}
