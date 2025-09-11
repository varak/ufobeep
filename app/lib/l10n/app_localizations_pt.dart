// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'OVNIBeep';

  @override
  String get ok => 'ESTÁ BEM';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Fechar';

  @override
  String get save => 'Gravar';

  @override
  String get delete => 'Apagar';

  @override
  String get edit => 'Editar';

  @override
  String get retry => 'Repetir';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get back => 'Voltar';

  @override
  String get next => 'Próxima';

  @override
  String get done => 'Feito';

  @override
  String get loading => 'Carregando..';

  @override
  String get processing => 'Processando..';

  @override
  String get errorGeneric => 'Algo correu mal.';

  @override
  String get networkError => 'Erro de rede. Verifica a tua ligação.';

  @override
  String get permissionsRequired => 'Permissões necessárias';

  @override
  String get learnMore => 'Saiba mais';

  @override
  String get welcomeTitle => 'Bem-vindo ao OVNIBeep';

  @override
  String get welcomeSubtitle => 'Alertas de OVNI em tempo real perto de você';

  @override
  String get signIn => 'Iniciar sessão';

  @override
  String get signOut => 'Sair';

  @override
  String get continueAsGuest => 'Continuar como convidado';

  @override
  String get enterUsername => 'Digite um nome de usuário';

  @override
  String get username => 'Utilizador';

  @override
  String get usernameUpdated => 'Nome de utilizador actualizado';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Configurações';

  @override
  String get tabAlerts => 'Alertas';

  @override
  String get tabBeep => 'Bip';

  @override
  String get tabChat => 'Conversar';

  @override
  String get tabMap => 'Mapa';

  @override
  String get tabSettings => 'Configurações';

  @override
  String get alertsTitle => 'Alertas próximos';

  @override
  String get noAlerts => 'Ainda não há alertas por perto.';

  @override
  String get pullToRefresh => 'Puxar para atualizar';

  @override
  String alertDistance(String distance) {
    return '${distance}_';
  }

  @override
  String alertDirection(int bearing) {
    return 'Rolamento $bearing';
  }

  @override
  String get viewAlert => 'Ver alerta';

  @override
  String get viewOnMap => 'Ver no mapa';

  @override
  String get iSeeItToo => 'Eu também vejo';

  @override
  String get confirmWitnessed => 'Confirma que viu isto?';

  @override
  String get witnessConfirmed => 'Obrigado — sua confirmação foi publicada.';

  @override
  String get createBeepTitle => 'Enviar uma Bip';

  @override
  String get beepExplain =>
      'Capture o que você vê e alerta os observadores próximos.';

  @override
  String get capturePhoto => 'Capturar foto';

  @override
  String get captureVideo => 'Capturar vídeo';

  @override
  String get pickFromGallery => 'Escolher na galeria';

  @override
  String get descriptionHint => 'Descreva o que está a ver no céu..';

  @override
  String get submitBeep => 'Enviar o Bip';

  @override
  String get beepSent => 'Bip enviado';

  @override
  String beepSentWithUrl(String shortUrl) {
    return 'Beep sent successfully';
  }

  @override
  String get uploadingMedia => 'Enviando mídia..';

  @override
  String get includeLocation => 'Incluir localização';

  @override
  String get includeTimestamp => 'Incluir a hora';

  @override
  String get beepFailed => 'Não foi possível enviar o Beep.';

  @override
  String get mediaProcessing => 'Processando mídia..';

  @override
  String get cameraPermissionTitle => 'Acesso necessário à câmara';

  @override
  String get cameraPermissionBody =>
      'Conceda acesso à câmera para capturar fotos e vídeos de OVNI.';

  @override
  String get locationPermissionTitle => 'Acesso de localização necessário';

  @override
  String get locationPermissionBody =>
      'Usamos a sua localização para enviar e receber alertas nas proximidades.';

  @override
  String get microphonePermissionTitle => 'Acesso ao microfone necessário';

  @override
  String get microphonePermissionBody =>
      'Conceda acesso ao microfone para captura de vídeo com áudio.';

  @override
  String get openSettings => 'Abrir configurações';

  @override
  String get alertDetailTitle => 'Detalhes da visão';

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
    return '${distance}_';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Rolamento para objeto: $bearing°';
  }

  @override
  String get openCompass => 'Abrir bússola';

  @override
  String get openAR => 'Abrir sobreposição do AR';

  @override
  String get openChat => 'Abrir a conversa';

  @override
  String get commentsTitle => 'Observações';

  @override
  String get addComment => 'Adicionar um comentário..';

  @override
  String get send => 'Enviar';

  @override
  String get commentPosted => 'Comentário publicado';

  @override
  String get autoFollowEnabled => 'Você está agora seguindo este alerta.';

  @override
  String get noCommentsYet => 'Sem comentários ainda. Sê o primeiro!';

  @override
  String get newCommentNotification =>
      'Novo comentário sobre um avistamento que você segue.';

  @override
  String get mapTitle => 'Mapa ao Vivo';

  @override
  String get compassTitle => 'Bússola';

  @override
  String get compassSettings => 'Configuração da Bússola';

  @override
  String get compassMode => 'Modo Bússola';

  @override
  String get compassStandardMode => 'Modo Padrão';

  @override
  String get compassPilotMode => 'Modo Pilot';

  @override
  String get compassStandardDescription => 'Cabeçalho básico e navegação';

  @override
  String get compassPilotDescription =>
      'Navegação avançada com ETA e vectorização';

  @override
  String pointingTo(String direction) {
    return 'Apontando para $direction';
  }

  @override
  String get calibratingCompass => 'Calibrando bússola..';

  @override
  String get openAROverlay => 'Abrir sobreposição do AR';

  @override
  String get pushTitleAlertNearby => 'Alerta OVNI perto de você';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Um novo avistamento foi relatado ${distance}_ longe.';
  }

  @override
  String get pushTitleComment => 'Novo comentário';

  @override
  String get pushBodyComment =>
      'Alguém comentou sobre um avistamento que você segue.';

  @override
  String get pushTitleWitness => 'Confirmação da testemunha';

  @override
  String get pushBodyWitness => 'Um usuário confirmou que vê o mesmo objeto.';

  @override
  String get weather => 'Tempo';

  @override
  String cloudCover(int percent) {
    return 'Capa da nuvem: $percent';
  }

  @override
  String wind(num speed, String unit) {
    return 'Vento: $speed $unit';
  }

  @override
  String get nearbyAircraft => 'Aviões próximos';

  @override
  String get noAircraft => 'Nenhuma aeronave próxima';

  @override
  String get loadingContext => 'Carregando contexto ambiental..';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get notifications => 'Notificação';

  @override
  String get enablePushNotifications =>
      'Obter notificações para comentários futuros';

  @override
  String get quietHours => 'Horas calmas';

  @override
  String get quietHoursDesc =>
      'Alertas de silêncio entre as horas selecionadas.';

  @override
  String get dndMode => 'Não Perturbe';

  @override
  String get dndUntil => 'Não perturbe até';

  @override
  String get language => 'Língua';

  @override
  String get chooseLanguage => 'Escolher idioma';

  @override
  String get units => 'Unidades';

  @override
  String get unitsImperial => 'Imperial (mi, mph)';

  @override
  String get unitsMetric => 'Metrico (km, km/h)';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get termsOfUse => 'Termos de Utilização';

  @override
  String get errorNoLocation =>
      'Localização não disponível. Tente novamente fora com visão clara do céu.';

  @override
  String get errorNoCamera => 'Câmera indisponível neste dispositivo.';

  @override
  String get errorUploadFailed => 'O envio falhou. Por favor, tente de novo.';

  @override
  String get errorPermissionDenied => 'Permissão negada.';

  @override
  String get errorInvalidUsername =>
      'Esse nome de usuário não está disponível.';

  @override
  String get nothingToShow => 'Nada para mostrar ainda.';

  @override
  String get storeShortDesc =>
      'Alertas de OVNI instantâneos perto de ti. Capturar, confirmar e conversar em tempo real.';

  @override
  String get storeLongDesc =>
      'OVNIBeep envia alertas em tempo real quando alguém vê um OVNI por perto. Capture fotos e vídeos, confirme avistamentos com toque, view direction & distance e converse com outros observadores do céu.';

  @override
  String get keywords =>
      'OVNI,UAP,OVNI,aliens,estrelas,sightings,skywatch,alerts,radar,compass';

  @override
  String get noAlertsFound => 'Sem alertas correspondentes';

  @override
  String get alertsFilterHelp =>
      'Tente ajustar seus filtros para ver mais resultados';

  @override
  String get verified => 'Verificado';

  @override
  String get beepOnly => 'apenas bip';

  @override
  String get videoOnly => 'somente vídeo';

  @override
  String get imageOnly => 'somente imagem';

  @override
  String get timeJustNow => 'Agora mesmo';

  @override
  String timeDaysAgo(int count) {
    return '__PH_0_d há';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h há';
  }

  @override
  String timeMinutesAgo(int count) {
    return '$count há';
  }

  @override
  String get loadMoreAlerts => 'Carregar mais alertas';

  @override
  String get toggleMufonTooltip => 'Alternar os avistamentos do MUFON';

  @override
  String get showMufonData => 'Mostrar dados MUFON';

  @override
  String get hideMufonData => 'Ocultar dados MUFON';

  @override
  String get showingUfoBeepOnly => 'Mostrando apenas relatórios UFOBeep';

  @override
  String get showingAllReports =>
      'A mostrar todos os relatórios, incluindo a base de dados MUFON';

  @override
  String get filteredSuffix => 'filtrado';

  @override
  String get detailsTitle => 'Detalhes';

  @override
  String get mufonCase => 'MUFON Processo';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Caso #_PH_0__ Detalhes';
  }

  @override
  String get sightingDate => 'Data de observação';

  @override
  String get mufonDatabaseEntryDate => 'Data de entrada em MUFON Base de dados';

  @override
  String get databaseEntry => 'Entrada da Base de Dados';

  @override
  String get shareLink => 'Partilhar a Ligação';

  @override
  String get linkCopied => 'Ligação copiada para a área de transferência';

  @override
  String get locationLabel => 'Localização';

  @override
  String get distanceLabel => 'Distância';

  @override
  String get timeLabel => 'Hora';

  @override
  String get reportedByLabel => 'Reportado por';

  @override
  String get unknownLocation => 'Localização desconhecida';

  @override
  String get locationUnknown => 'Localização Desconhecido';

  @override
  String get witnessesLabel => 'Testemunhas';

  @override
  String witnessesCountMessage(int count) {
    return '${count}_ pessoas confirmaram este avistamento';
  }

  @override
  String get photoAnalysisTitle => 'Análise Fotográfica';

  @override
  String mediaItemsProcessed(int count) {
    return 'Análise: $count arquivos de mídia processados';
  }

  @override
  String get addMoreMedia => 'Adicionar mais';

  @override
  String get addMedia => 'Adicionar mídia';

  @override
  String get retakePhoto => 'Retirar foto';

  @override
  String get retakeVideo => 'Retomar vídeo';

  @override
  String get camera => 'Câmera';

  @override
  String get gallery => 'Galeria';

  @override
  String get basicSettings => 'Configuração Básica';

  @override
  String get appSettings => 'Configuração da Aplicação';

  @override
  String get alertRange => 'Intervalo de Alerta';

  @override
  String get manageNotificationsDesc =>
      'Gerenciar as & configurações de assinaturas';

  @override
  String get permissionsTitle => 'Permissões';

  @override
  String get permissionLocation => 'Localização';

  @override
  String get permissionCamera => 'Câmera';

  @override
  String get permissionNotifications => 'Notificação';

  @override
  String get permissionPhotos => 'Fotos';

  @override
  String get permissionGranted => 'Concedido';

  @override
  String get permissionNotGranted => 'Não concedido';

  @override
  String get permissionGrant => 'Subvenção';

  @override
  String get generateUsername => 'Gerar um novo nome de utilizador';

  @override
  String get adminTools => 'Ferramentas de Administração';

  @override
  String get openAdminPanel => 'Abrir o Painel de Administração';

  @override
  String get webAdminInterface => 'Interface de Administração Web';

  @override
  String get adminBetaNotice =>
      'Só Beta constrói. Ferramentas de administração para testar alertas de proximidade, notificações de push e diagnósticos do sistema.';

  @override
  String get whatDoYouSee => 'O que vês?';

  @override
  String get ufoSighting => 'UFO Avistamento';

  @override
  String get envAnalysisTitle => 'Análise Ambiental';

  @override
  String get envAnalysisPending => 'Análise Pendente';

  @override
  String get envAnalysisPendingDesc =>
      'Os dados ambientais estarão disponíveis assim que o processamento começar.';

  @override
  String get unknownAircraft => 'Aeronaves desconhecidas';

  @override
  String get moreAircraft => 'mais aeronaves';

  @override
  String get premiumImageryTitle => 'Satélite Premium Imagem';

  @override
  String get premiumImagerySubtitle => 'Imagens comerciais de alta resolução';

  @override
  String get sightingTypeLabel => 'Tipo';

  @override
  String get ufoTypeSphere => 'Esfera';

  @override
  String get ufoTypeTriangle => 'Triângulo';

  @override
  String get ufoTypeDisk => 'Disco';

  @override
  String get ufoTypeLight => 'Luz';

  @override
  String get ufoTypeFireball => 'Bola de Fogo';

  @override
  String get ufoTypeCylinder => 'Cilindro';

  @override
  String get ufoTypeCigar => 'Charuto';

  @override
  String get ufoTypeRectangle => 'Rectângulo';

  @override
  String get ufoTypeFormation => 'Formação';

  @override
  String get ufoTypeUnknown => 'Desconhecido';

  @override
  String get ufoTypeBoomerang => 'Boomerang';

  @override
  String get ufoTypeDiamond => 'Diamante';

  @override
  String get ufoTypeOval => 'Oval';

  @override
  String get ufoTypeCone => 'Cone';

  @override
  String get ufoTypeCross => 'Cruz';

  @override
  String get ufoTypeDumbbell => 'Dumblebell';

  @override
  String get ufoTypeTeardrop => 'Lágrima';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Bala';

  @override
  String get ufoTypeSaturn => 'Saturno';

  @override
  String get ufoTypeStarLike => 'Estrelado';

  @override
  String get ufoTypeBlimp => 'Pimenta';

  @override
  String get actionsTitle => 'Acções';

  @override
  String get addPhotosAndVideos => 'Adicionar Fotos e Vídeos';

  @override
  String get howToReportToMufon => 'Como informar à MUFON';

  @override
  String get reportToMufon => 'Relatório à MUFON';

  @override
  String get whyReportToMufon => 'Por que se reportar a MUFON?';

  @override
  String get openMufonReport => 'Abrir MUFON Relatório';

  @override
  String get confirmedWitness => 'Confirmaste esta aparição';

  @override
  String witnessesHaveConfirmed(int count) {
    return '${count}_ pessoas confirmaram este avistamento';
  }

  @override
  String get aircraftTrackingTitle => 'Rastreamento de aeronaves';

  @override
  String get weatherConditionsTitle => 'Condições meteorológicas';

  @override
  String get noSatellitePasses => 'Nenhum passe de satélite visível encontrado';

  @override
  String get contentAnalysisTitle => 'Análise de Conteúdo';

  @override
  String get contentSafe => 'O conteúdo é seguro';

  @override
  String get contentFlagged => 'Conteúdo marcado para revisão';

  @override
  String get confidenceLabel => 'Confiança';

  @override
  String get methodLabel => 'Método';

  @override
  String get premiumImageryAccessOnly =>
      'Imagens de satélite Premium só estão disponíveis para:';

  @override
  String get premiumAccessCreators => 'Alertar criadores';

  @override
  String get premiumAccessWitnesses =>
      'Testemunhas confirmadas dentro do intervalo de visibilidade';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get directionDistanceTitle => 'Direcção & Distância';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Caso #__PH_0_';
  }

  @override
  String get satellitePassesTitle => 'Passagens por Satélite';

  @override
  String get satellitePassExplanation =>
      'O satélite visível passa durante o período de avistamento. Muitos relatórios de OVNIs são realmente satélites ou detritos espaciais.';

  @override
  String get followingAlert =>
      'A seguir alerta - você receberá notificações de comentários';

  @override
  String get unfollowedAlert =>
      'Alerta não seguido - sem notificações de comentários';

  @override
  String get alertFollowError => 'Erro ao atualizar o status da sequência';

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

  @override
  String get unknown => 'unknown';

  @override
  String get report => 'report';

  @override
  String get mufon => 'mufon';
}
