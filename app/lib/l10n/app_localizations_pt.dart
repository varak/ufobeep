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
    return '__PACEHOLDER_0____';
  }

  @override
  String alertDirection(int bearing) {
    return 'Rolamento __PLACELODER_0___';
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
    return 'Beep enviado com sucesso';
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
  String get locationPermissionTitle => 'Permissão de localização necessária';

  @override
  String get locationPermissionBody =>
      'Usamos a sua localização para enviar e receber alertas nas proximidades.';

  @override
  String get microphonePermissionTitle => 'Acesso ao microfone necessário';

  @override
  String get microphonePermissionBody =>
      'Conceda acesso ao microfone para captura de vídeo com áudio.';

  @override
  String get openSettings => 'Abrir Configurações';

  @override
  String get alertDetailTitle => 'Detalhes da visão';

  @override
  String reportedBy(String username) {
    return 'Reportado por __PLACEHOLDER_0_';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Reportado $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '__PACELODER_0_';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Rolamento para objeto: ${bearing}_°';
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
  String get noCommentsYet =>
      'Sem comentários ainda. Seja o primeiro a comentar!';

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
    return 'Apontando para __PLACEHOLDER_0_';
  }

  @override
  String get calibratingCompass => 'Calibrando bússola..';

  @override
  String get openAROverlay => 'Abrir sobreposição do AR';

  @override
  String get pushTitleAlertNearby => 'Alerta OVNI perto de você';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Foi relatado um novo avistamento ${distance}_______________________________________________________________________________________________________________________________________________________________________________________________.';
  }

  @override
  String get pushTitleComment => 'Novo comentário';

  @override
  String get pushBodyComment =>
      'Alguém comentou sobre um avistamento que você segue.';

  @override
  String get pushTitleWitness => 'Confirmação da testemunha';

  @override
  String get temperature => 'Temperatura';

  @override
  String get pushBodyWitness => 'Um usuário confirmou que vê o mesmo objeto.';

  @override
  String get weather => 'Tempo';

  @override
  String cloudCover(int percent) {
    return 'Capa da nuvem: __PACEHOLDER_0__';
  }

  @override
  String wind(num speed, String unit) {
    return 'Vento:';
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
  String get quietHours => 'Horas de silêncio';

  @override
  String get quietHoursDesc =>
      'Alertas de silêncio entre as horas selecionadas.';

  @override
  String get quietHoursEnabled => 'Habilitar horas silenciosas';

  @override
  String get quietHoursFrom => 'De';

  @override
  String get quietHoursUntil => 'Até';

  @override
  String get quietHoursDefaultTime => 'Horas de silêncio padrão';

  @override
  String get emergencyOverride => 'Substituição de Emergência';

  @override
  String get emergencyOverrideDesc =>
      'Permitir alertas urgentes durante horas silenciosas';

  @override
  String get dndMode => 'Não Perturbe';

  @override
  String get dndUntil => 'Não perturbe até';

  @override
  String dndEnabled(Object time) {
    return 'DND ativado até $time';
  }

  @override
  String get dndDisabled => 'DND desabilitado';

  @override
  String quietHoursActive(String startTime, String endTime) {
    return 'Ativo ${startTime}_ __PLACEHOLDER_1_';
  }

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Horas de silêncio: __PACEHOLDER_0__ __PACEHOLDER_1_';
  }

  @override
  String get pushNotificationUfoAlert => 'UFO Alerta';

  @override
  String get pushNotificationAnomalyAlert => 'Alerta de Anomalias';

  @override
  String get pushNotificationNearby => 'Perto';

  @override
  String get pushNotificationInYourArea =>
      'na sua área. Toque rapidamente para ver os detalhes.';

  @override
  String pushNotificationCommented(Object username) {
    return '__PACEHOLDER_0___ comentado';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '$username comentado em __PLACEHOLDER_1_';
  }

  @override
  String get pushNotificationGeneric => 'OVNIBeep';

  @override
  String get pushNotificationNewSighting => 'Novo avistamento nas proximidades';

  @override
  String get language => 'Língua';

  @override
  String get chooseLanguage => 'Escolher idioma';

  @override
  String get units => 'Unidades';

  @override
  String get unitsImperial => 'Imperial';

  @override
  String get unitsMetric => 'Métrico';

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
  String get beepOnly => 'Apenas Beep';

  @override
  String get reportOnly => 'Somente texto';

  @override
  String get videoOnly => 'Apenas Vídeo';

  @override
  String get imageOnly => 'Apenas a Imagem';

  @override
  String get mediaOnly => 'Somente mídia';

  @override
  String get timeJustNow => 'agora mesmo';

  @override
  String timeDaysAgo(int count) {
    return '$count há dias';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count há horas';
  }

  @override
  String timeMinutesAgo(int count) {
    return '$count há minutos';
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
  String get mufonSighting => 'Relatório de Avistamento de MUFON';

  @override
  String get mufonLightSighting => 'Relatório de observação da luz de MUFON';

  @override
  String get mufonSphereSighting =>
      'Relatório de observação da esfera de MUFON';

  @override
  String get mufonDiscSighting => 'MUFON Relatório de Avistamento do Disco';

  @override
  String get mufonTriangleSighting => 'MUFON Relatório de Visão do Triângulo';

  @override
  String get mufonCigarSighting => 'Relatório de observação do charuto MUFON';

  @override
  String get mufonOvalSighting => 'Relatório de observação ocular de MUFON';

  @override
  String get mufonRectangleSighting => 'MUFON Relatório de Vista Rectângulo';

  @override
  String get mufonCylinderSighting =>
      'Relatório de observação do cilindro MUFON';

  @override
  String get mufonBoomerangSighting => 'MUFON Boomerang Sighting Report';

  @override
  String get mufonStarlikeSighting => 'MUFON Relatório de Avistamento Estelar';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'CASO MUFON #$caseNumber Detalhes';
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
  String get locationLabel => 'Localização:';

  @override
  String get distanceLabel => 'Distância';

  @override
  String get timeLabel => 'Tempo:';

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
    return 'As pessoas confirmaram este avistamento';
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
  String get timeFormat => 'Formato de Hora';

  @override
  String get timeFormat24Hour => '24 horas';

  @override
  String get timeFormat12Hour => '12 horas';

  @override
  String get timeFormatDesc =>
      'Tempo de exibição em formato 24 horas ou 12 horas';

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
  String get ufo => 'UFO';

  @override
  String get sighting => 'Avistamento';

  @override
  String get ufoSighting => 'OVNIBeep Alerta';

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
  String get showLess => 'Mostrar menos';

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
  String get shapeTriangle => 'triângulo';

  @override
  String get shapeDisc => 'disco';

  @override
  String get shapeDisk => 'disco';

  @override
  String get shapeSphere => 'esfera';

  @override
  String get shapeCigar => 'charuto';

  @override
  String get shapeLight => 'luz';

  @override
  String get shapeBoomerang => 'bumerangue';

  @override
  String get shapeDiamond => 'diamante';

  @override
  String get shapeRectangle => 'retângulo';

  @override
  String get shapeOval => 'oval';

  @override
  String get shapeCone => 'cone';

  @override
  String get shapeCross => 'cruz';

  @override
  String get shapeCylinder => 'cilindro';

  @override
  String get shapeDumbbell => 'haltere';

  @override
  String get shapeTeardrop => 'lágrima';

  @override
  String get shapeTicTac => 'tic-tac';

  @override
  String get shapeBullet => 'bala';

  @override
  String get shapeSaturn => 'saturn';

  @override
  String get shapeStarlike => 'estrelado';

  @override
  String get shapeBlimp => 'dirigível';

  @override
  String get shapeFireball => 'bola de fogo';

  @override
  String get shapeFormation => 'formação';

  @override
  String get shapeUnknown => 'desconhecido';

  @override
  String get actionsTitle => 'Acções';

  @override
  String get addPhotosAndVideos => 'Adicionar Fotos e Vídeos';

  @override
  String get attachMedia => 'Anexar mídia';

  @override
  String get addCommentOptional => 'Adicionar um comentário (opcional)';

  @override
  String get describeNewMedia => 'Descreva a nova mídia...';

  @override
  String get filesSelected => 'ficheiros seleccionados';

  @override
  String get selectMediaToAttach => 'Selecione fotos ou vídeos para anexar';

  @override
  String get newMediaUploaded => 'Nova mídia enviada';

  @override
  String get mediaFilesUploaded => 'novos arquivos de mídia enviados';

  @override
  String get filesAttachedSuccessfully => 'arquivos anexados com sucesso';

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
    return 'As pessoas confirmaram esta aparição';
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
    return 'MUFON Caso #__PLACEHOLDER_0_';
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
  String get notificationChannelAlerts => 'Alertas OVNIBeep';

  @override
  String get notificationChannelAlertsDesc =>
      'Notificações para bips de OVNI e alertas de proximidade';

  @override
  String get notificationSightingTitle => 'OVNIBeep Alerta';

  @override
  String get notificationSightingUrgent => 'OVNI URGENTE Alerta';

  @override
  String get notificationSightingEmergency => 'OVNI OVNI EMERGÊNCIA Alerta';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return 'LOCALIZADOR';
  }

  @override
  String notificationCommentTitle(String username) {
    return '_${username}_ comentado';
  }

  @override
  String get notificationWitnessText => 'Novo avistamento';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '__PACEHOLDER_0__ testemunhas';
  }

  @override
  String get notificationActionSnooze => 'Soneca 1h';

  @override
  String get notificationActionDismiss => 'Demitir';

  @override
  String notificationDistance(String distance) {
    return '__PACEHOLDER_0____';
  }

  @override
  String get unknown => 'Desconhecido';

  @override
  String get report => 'relatório';

  @override
  String get mufon => 'mufon';

  @override
  String get recentUfoBeepsTitle => 'OVNI recente Abelhas';

  @override
  String get recentUfoBeepsSubtitle =>
      'Relatórios de avistamento de OVNIs vivos da nossa comunidade global';

  @override
  String get recentUfoBeepsDescription =>
      'Este feed combina \"beeps\" UFOBeep em tempo real de nossos usuários de aplicativos móveis com relatórios históricos do banco de dados MUFON.';

  @override
  String get loadingBeeps => 'Carregando beeps recentes...';

  @override
  String get noBeepsAvailable => 'Não há sinal de momento.';

  @override
  String get anomalyReported => 'Anomalia notificada';

  @override
  String get copyShortLink => 'Copiar link curto';

  @override
  String get shareAlert => 'Alerta de partilha';

  @override
  String get ufoSightingAlert => 'UFO Alerta de observação';

  @override
  String get previousPage => 'Anterior';

  @override
  String get nextPage => 'Próxima';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Página __PACEVOLDER_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________';
  }

  @override
  String get firstPage => 'Primeiro';

  @override
  String get lastPage => 'Último';

  @override
  String get jumpToPage => 'Ir para a página';

  @override
  String get heroTagline => 'Obter alertas quando sair e olhar para cima';

  @override
  String get heroDescription => 'Nunca perca outro OVNI na sua área';

  @override
  String get downloadApp => 'Aplicação de Download';

  @override
  String get viewAllBeeps => 'Ver todos os Beeps';

  @override
  String get sightingsMap => 'Mapa de Imagens';

  @override
  String get globalSightingNetwork => 'Rede de observação global';

  @override
  String get howItWorks => 'Como Funciona';

  @override
  String get backToBeeps => 'Voltar para Beeps';

  @override
  String get loadingDetails => 'Carregando detalhes do bip...';

  @override
  String get details => 'Detalhes';

  @override
  String get location => 'Localização';

  @override
  String get timeAgo => 'atrás';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'milhas';

  @override
  String get distanceNearby => 'próximo';

  @override
  String get ufobeepWitnesses => 'Testemunhas';

  @override
  String get ufobeepConfirmations => 'Confirmações';

  @override
  String get ufobeepAlertLevel => 'Nível de Alerta';

  @override
  String get ufobeepReportType => 'Relatório UFOBeep';

  @override
  String get mufonAttribution => 'MUFON Relatório da Base de Dados';

  @override
  String get mufonCaseNumber => 'Caso #';

  @override
  String get mufonGenericTitle => 'Relatório de Avistamento de MUFON';

  @override
  String get mufonSphere => 'Esfera';

  @override
  String get mufonLight => 'Luz';

  @override
  String get mufonDisk => 'Disco';

  @override
  String get mufonTriangle => 'Triângulo';

  @override
  String get mufonCigar => 'Charuto';

  @override
  String get mufonOval => 'Oval';

  @override
  String get mufonCylinder => 'Cilindro';

  @override
  String get mufonRectangle => 'Rectângulo';

  @override
  String get mufonDiamond => 'Diamante';

  @override
  String get mufonFireball => 'Bola de Fogo';

  @override
  String get mufonFlash => 'Flash';

  @override
  String get mufonFormation => 'Formação';

  @override
  String get mufonChanging => 'Mudando';

  @override
  String get mufonChevron => 'Chevron';

  @override
  String get mufonCone => 'Cone';

  @override
  String get mufonCross => 'Cruz';

  @override
  String get mufonEgg => 'Ovos';

  @override
  String get mufonOther => 'Objecto';

  @override
  String get mufonUnknown => 'Objecto Desconhecido';

  @override
  String mufonTitleFormat(Object classification) {
    return 'MUFON ${classification}_ Relatório';
  }

  @override
  String get nuforcAttribution => 'NUFORC Relatório da Base de Dados';

  @override
  String get nuforcCaseNumber => 'Caso #';

  @override
  String get nuforcGenericTitle => 'NUFORC Relatório de Avistamento';

  @override
  String get mediaImageNotFound => 'Imagem não encontrada';

  @override
  String get mediaPlayVideo => 'Reproduzir vídeo';

  @override
  String get mediaViewImage => 'Ver imagem';

  @override
  String mediaCount(Object count) {
    return '__PACEHOLDER_0____ imagens';
  }

  @override
  String get mediaCountSingle => '1 imagem';

  @override
  String mediaMoreImages(Object count) {
    return 'Mais';
  }

  @override
  String get errorNotFound => 'Beep não encontrado';

  @override
  String get errorLoadError => 'Falha ao carregar os detalhes do bip';

  @override
  String get shareYourThoughts =>
      'Compartilhe seus pensamentos sobre este avistamento...';

  @override
  String get postComment => 'Comentário da Mensagem';

  @override
  String get loggedInAs => 'Entrar como';

  @override
  String get logout => 'Sair';

  @override
  String get notFollowing => 'Não seguindo';

  @override
  String get follow => 'Seguir';

  @override
  String get navRecentBeeps => 'Beeps recentes';

  @override
  String get navMap => 'Mapa';

  @override
  String get navDownloadApp => 'Aplicativo de Download';

  @override
  String get alertLevel => 'Nível de Alerta';

  @override
  String get witnesses => 'Testemunhas';

  @override
  String get confirmations => 'Confirmações';

  @override
  String get reporterLabel => 'Relatado pelo usuário';

  @override
  String get coordinatesLabel => 'Coordenadas';

  @override
  String get eventTime => 'Hora do evento';

  @override
  String get reportedTime => 'Hora de notificação';

  @override
  String get addedToUfobeep => 'Adicionado ao OVNIBeep';

  @override
  String get mufonDatabaseReport => 'MUFON Número do caso:';

  @override
  String get copyShortLinkTitle => 'Copiar o link para a área de transferência';

  @override
  String get imageNotFound => 'Imagem não encontrada';

  @override
  String get ufoSightingAlt => 'UFO Alerta de OVNIs';

  @override
  String get celestialDataTitle => 'Objetos Celestiais';

  @override
  String get visiblePlanets => 'Planetas Visíveis';

  @override
  String get locationDataTitle => 'Informação da Localização';

  @override
  String get timezone => 'Fuso horário';

  @override
  String get coordinates => 'Coordenadas';

  @override
  String get processingSummaryTitle => 'Resumo de Processamento';

  @override
  String get processingTime => 'Tempo de processamento';

  @override
  String get successful => 'Sucesso';

  @override
  String get failed => 'Falha';

  @override
  String get locationEnrichmentTitle => 'Detalhes da localização';

  @override
  String get aircraftDataSource => 'Fonte dos Dados';

  @override
  String get noAircraftDetected => 'Nenhuma aeronave detectada';

  @override
  String get sightingReport => 'Relatório de Avistamento';

  @override
  String get ufoAlert => 'UFO Alerta';

  @override
  String get alert => 'Alerta';

  @override
  String get notificationTickerUfoAlert =>
      'Alerta de OVNIs - Novas Visões nas proximidades';

  @override
  String get notificationTickerComment => 'Novo comentário sobre o alerta UFO';

  @override
  String get weatherConditions => 'Condições meteorológicas';

  @override
  String get visibility => 'Visibilidade';

  @override
  String get humidity => 'Humidade';

  @override
  String get pressure => 'Pressão';

  @override
  String get locationDetails => 'Detalhes da localização';

  @override
  String get city => 'Cidade';

  @override
  String get state => 'Estado';

  @override
  String get country => 'País';

  @override
  String get satelliteActivity => 'Actividade por Satélite';

  @override
  String get satellitesVisibleOverhead =>
      'Satélites visíveis em cima ao avistar hora e local';

  @override
  String get dataSource => 'Fonte dos Dados';

  @override
  String get blackskyImagery => 'Imagem de BlackSky';

  @override
  String get resolution => 'Resolução';

  @override
  String get groundResolution => 'resolução do solo de 35cm';

  @override
  String get delivery => 'Entrega';

  @override
  String get averageDelivery => 'média de 90 minutos';

  @override
  String get cost => 'Custo';

  @override
  String get skyfiSatelliteImagery => 'Satélite SkyFi Imagem';

  @override
  String get region => 'Região';

  @override
  String get remoteArea => 'Área Remota';

  @override
  String get startingPrice => 'Preço Inicial';

  @override
  String get coverage => 'Cobertura';

  @override
  String get confidenceCoverage => '95% de confiança';

  @override
  String get status => 'Estado';

  @override
  String get shareThoughts =>
      'Compartilhe seus pensamentos sobre este avistamento...';

  @override
  String get postCommand => 'Comando Postal';

  @override
  String get clouds => 'Nuvens';

  @override
  String get windLabel => 'Vento';

  @override
  String get filterAlerts => 'Alertas de Filtro';

  @override
  String get alertSource => 'Fonte de Alerta';

  @override
  String get ufobeepOnly => 'Apenas OVNIBeep';

  @override
  String get ufobeepOnlyDescription =>
      'Mostrar apenas os relatórios originais do UFOBeep (exclua a base de dados MUFON)';

  @override
  String get alertDistanceRange => 'Intervalo de Distância do Alerta';

  @override
  String get showAllAlerts => 'Mostrar Todos os Alertas';

  @override
  String get showAll => 'Mostrar Tudo';

  @override
  String get distanceSliderDescription =>
      'Arraste para ajustar até onde quer ver alertas. Comece da distância de visibilidade do tempo até mostrar todos os alertas, independentemente da distância.';

  @override
  String get applyFilters => 'Aplicar os Filtros';

  @override
  String get notificationRange => 'Intervalo de Notificação';

  @override
  String get notificationRangeDescription =>
      'Obter alertas para avistamentos dentro desta distância';

  @override
  String get viewingRange => 'Visualizando o Intervalo';

  @override
  String get viewingRangeDescription =>
      'Mostrar avistamentos dentro desta distância ao navegar';

  @override
  String get weatherVisibility => 'Visibilidade do Tempo (~10km)';

  @override
  String get localArea => 'Área Local (25 km)';

  @override
  String get regional => 'Regional';

  @override
  String get pushNotifications => 'Push Notificações';

  @override
  String get alertBrowsing => 'Alerta de Navegação';

  @override
  String get pushAlertsWithinDistance =>
      'Obter notificações dentro deste intervalo';

  @override
  String get showAlertsWhenBrowsing => 'Filtrar o que vê na lista';

  @override
  String get heroMainTagline =>
      'Obter um sinal no seu telefone quando OVNIs são vistos nas proximidades';

  @override
  String get heroSecondaryTagline => 'Descubra quando e onde olhar para o céu';

  @override
  String get sourceFilters => 'Origem';

  @override
  String get sourceFiltersDescription =>
      'Escolha quais relatórios aparecem na sua fonte';

  @override
  String get ufobeepAndMufon => 'UFOBeep + MUFON';

  @override
  String get ufobeepOnlySource => 'Apenas OVNIBeep';

  @override
  String get mufonOnlySource => 'Apenas MUFON';

  @override
  String get browseFilters => 'Navegar';

  @override
  String get browseFiltersDescription =>
      'Como visualizar e classificar alertas';

  @override
  String get sortByNewest => 'Mais recente';

  @override
  String get sortByNearest => 'Mais perto';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get pushAlertsTitle => 'Ativar Alertas';

  @override
  String get pushAlertsDescription => 'O que pings seu telefone';

  @override
  String get alertRadius => 'Alertar o Raio';

  @override
  String get mufonNoPushInfo =>
      'Relatórios MUFON são importados todas as noites e não acionam alertas push';

  @override
  String get privacyData => 'Privacidade e Dados';

  @override
  String get privacyPolicyDesc => 'Como protegemos e usamos seus dados';

  @override
  String get termsOfService => 'Termos de Serviço';

  @override
  String get termsOfServiceDesc => 'Termos e condições legais';

  @override
  String get locationTracking => 'Rastreamento de Localização';

  @override
  String get locationTrackingDesc =>
      'Local de referência para as indicações de proximidade';

  @override
  String get locationTrackingTitle => 'Rastreamento de Localização de Fundo';

  @override
  String get locationTrackingExplanation =>
      'UFOBeep monitora sua localização no fundo para enviar alertas de proximidade quando avistamentos de UFO acontecem perto de sua localização atual, mesmo quando você está longe de casa.';

  @override
  String get locationTrackingBattery =>
      'Utiliza geofecção inteligente para impacto <3% da bateria';

  @override
  String get backgroundLocationTracking => 'Activar o Fundo Rastreamento';

  @override
  String get locationTrackingActive =>
      'Localização de monitorização das indicações de proximidade';

  @override
  String get locationTrackingInactive => 'A localização está desactivada';

  @override
  String get locationTrackingDisabledWarning =>
      'Você não receberá alertas de proximidade quando mudar para novos locais';

  @override
  String get trackingStatus => 'Estado de Rastreamento';

  @override
  String get monitoringStatus => 'Acompanhamento';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inativo';

  @override
  String get lastKnownLocation => 'Última Localização Conhecida';

  @override
  String get lastLocationUpdate => 'Última atualização';

  @override
  String get movementThreshold => 'Limiar de Movimento';

  @override
  String get updateFrequency => 'Actualizar a Frequência';

  @override
  String get batteryImpact => 'Impacto da Bateria';

  @override
  String get dataPrivacy => 'Privacidade de Dados';

  @override
  String get locationPermissionExplanation =>
      'OVNIBeep precisa de permissão de localização para monitorar seu movimento e enviar alertas de proximidade quando você estiver em novos locais.';

  @override
  String get benefitsTitle => 'Benefícios';

  @override
  String get locationTrackingBenefits =>
      '• Obter alertas OVNIs onde quer que você viaje\n• Atualizações automáticas de localização\n• Não é necessária nenhuma configuração manual';

  @override
  String get allowLocationAccess => 'Permitir o Acesso de Localização';

  @override
  String get locationPermissionRequired =>
      'A permissão de localização é necessária para o rastreamento de fundo';

  @override
  String get locationTrackingEnabled =>
      'Monitoramento de localização de fundo habilitado';

  @override
  String get locationTrackingDisabled =>
      'Rastreamento de localização de fundo desabilitado';

  @override
  String get justNow => 'Agora mesmo';

  @override
  String minutesAgo(int minutes) {
    return '$minutes há minutos';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours há horas';
  }

  @override
  String daysAgo(int days) {
    return '$days há dias';
  }

  @override
  String get dataManagement => 'Gestão de Dados';

  @override
  String get dataManagementDesc => 'Exportar ou apagar os dados da sua conta';

  @override
  String get splashTagline => 'Alertas de avistamento em tempo real';

  @override
  String get splashStartingUp => 'A começar...';

  @override
  String get splashInitializationFailed => 'A inicialização falhou';

  @override
  String get splashInitializationFailedTitle => 'Falha na inicialização';

  @override
  String get splashInitializationError =>
      'O aplicativo falhou ao inicializar corretamente:';

  @override
  String get splashRetry => 'Repetir';

  @override
  String get splashContinue => 'Continuar';

  @override
  String get splashInitializing => 'Inicializando...';

  @override
  String signInWelcome(String username) {
    return 'Bem-vindos!';
  }

  @override
  String signInFailed(String error) {
    return 'Falha ao iniciar sessão: __PACELODER_0_';
  }

  @override
  String get signInPleaseEnterEmail => 'Digite seu endereço de e- mail';

  @override
  String get signInPleaseEnterValidEmail =>
      'Digite um endereço de e- mail válido';

  @override
  String get signInMagicLinkSent =>
      'Ligação mágica enviada! Verifique seu e-mail e clique no link para iniciar sessão.';

  @override
  String get signInMagicLinkFailed =>
      'Não foi possível enviar o link mágico. Por favor, tente de novo.';

  @override
  String get signInAllDataCleared => 'Todos os dados apagados';

  @override
  String get signInSubtitle =>
      'Alertas de avistamento de OVNIs em tempo real e relatórios MUFON';

  @override
  String get signInGoogleLoading => 'A assinar...';

  @override
  String get signInContinueWithGoogle => 'Continuar com o Google';

  @override
  String get signInOr => 'ou';

  @override
  String get signInWithEmail => 'Iniciar sessão com o Email';

  @override
  String get signInEmailDescription =>
      'Vamos enviar-lhe uma ligação segura para entrar';

  @override
  String get signInEmailAddress => 'Endereço de e- mail';

  @override
  String get signInEmailPlaceholder => 'your@email.com';

  @override
  String signInTryAgainIn(int seconds) {
    return 'Tente novamente em __PACEHOLDER_0__';
  }

  @override
  String get signInSending => 'Enviando...';

  @override
  String get signInSendMagicLink => 'Enviar uma Ligação Mágica';

  @override
  String get signInCheckEmail =>
      'Vê o teu e-mail! O link expira em 15 minutos.';

  @override
  String get signInSecureAuth => 'Autenticação Segura';

  @override
  String get signInSecureAuthDescription =>
      'Use o Google Sign-In para acesso instantâneo ou links mágicos de e-mail que expiram em 15 minutos.';

  @override
  String get signInClearAllDataDebug => 'Limpar Todos os Dados (Depurar)';

  @override
  String get emailAuthFailedToSend => 'Falha ao enviar o e- mail';

  @override
  String get emailAuthFailedToSendTryAgain =>
      'Não foi possível enviar o e- mail. Por favor, tente de novo.';

  @override
  String get emailAuthInvalidEmail =>
      'Endereço de e- mail inválido. Por favor, verifique o formato.';

  @override
  String get emailAuthUserNotFound =>
      'Nenhuma conta encontrada com este endereço de e- mail.';

  @override
  String get emailAuthTooManyRequests =>
      'Demasiadas tentativas. Por favor, tente novamente mais tarde.';

  @override
  String get emailAuthOperationNotAllowed =>
      'O login do link de e- mail não está ativado.';

  @override
  String get emailAuthQuotaExceeded =>
      'Cota de e- mail excedida. Por favor, tente de novo amanhã.';

  @override
  String get emailAuthVerificationFailed =>
      'A verificação por e- mail falhou. Por favor, tente de novo.';

  @override
  String get emailAuthTitle => 'Verificação por E- mail';

  @override
  String get emailAuthVerifyYourEmail => 'Verificar o seu E- mail';

  @override
  String get emailAuthDescription =>
      'Adicione seu endereço de e-mail para recuperação de conta e segurança. Vamos enviar-lhe uma ligação segura.';

  @override
  String get emailAuthEmailAddress => 'Endereço de E- mail';

  @override
  String get emailAuthEmailPlaceholder => 'your.email@example.com';

  @override
  String get emailAuthPleaseEnterEmail => 'Digite seu endereço de e- mail';

  @override
  String get emailAuthPleaseEnterValidEmail =>
      'Digite um endereço de e- mail válido';

  @override
  String get emailAuthCheckEmailToContinue =>
      'Verifique seu e-mail e toque no link de verificação para continuar.';

  @override
  String get emailAuthResendEmail => 'Reenviar e- mail';

  @override
  String get emailAuthSendVerificationEmail => 'Enviar Verificação E- mail';

  @override
  String get emailAuthHowItWorks => 'Como funciona a verificação de email';

  @override
  String get emailAuthHowItWorksSteps =>
      '1. Enviamos-lhe uma ligação segura de entrada.\n2. Verifique seu e-mail e toque no link\n3. Seu e-mail é verificado automaticamente\n4. Não são necessárias senhas!';

  @override
  String get emailAuthSecurityNotice =>
      'A verificação por e-mail ajuda a proteger sua conta e permite a recuperação da conta se você perder o acesso ao seu dispositivo.';

  @override
  String get phoneAuthFailedToSendCode =>
      'Não foi possível enviar o código de verificação. Por favor, tente de novo.';

  @override
  String get phoneAuthInvalidCodeTryAgain =>
      'Código de verificação inválido. Por favor, tente de novo.';

  @override
  String phoneAuthPhoneVerified(String phoneNumber) {
    return 'Número de telefone verificado: __PACELODER_0_';
  }

  @override
  String get phoneAuthVerificationFailed =>
      'A verificação do telefone falhou. Por favor, tente de novo.';

  @override
  String get phoneAuthCodeResent => 'Código de verificação';

  @override
  String get phoneAuthFailedToResendCode =>
      'Não foi possível reenviar o código. Por favor, tente de novo.';

  @override
  String get phoneAuthInvalidPhoneNumber =>
      'Número de telefone inválido. Por favor, verifique o formato.';

  @override
  String get phoneAuthTooManyRequests =>
      'Demasiadas tentativas. Por favor, tente novamente mais tarde.';

  @override
  String get phoneAuthInvalidVerificationCode =>
      'Código de verificação inválido. Por favor, verifique e tente novamente.';

  @override
  String get phoneAuthSessionExpired =>
      'Sessão de verificação expirada. Por favor, solicite um novo código.';

  @override
  String get phoneAuthSmsQuotaExceeded =>
      'Quota SMS excedida. Por favor, tente de novo amanhã.';

  @override
  String get phoneAuthCredentialAlreadyInUse =>
      'Este número de telefone já está ligado a outra conta.';

  @override
  String get phoneAuthVerificationFailedGeneric =>
      'A verificação falhou. Por favor, tente de novo.';

  @override
  String get phoneAuthTitle => 'Verificação do Telefone';

  @override
  String get phoneAuthVerifyYourPhone => 'Verificar o Seu Telefone';

  @override
  String get phoneAuthEnterVerificationCode => 'Digite a verificação Código';

  @override
  String get phoneAuthAddPhoneForSecurity =>
      'Adicione seu número de telefone para recuperação de conta e segurança';

  @override
  String phoneAuthEnterSixDigitCode(String phoneNumber) {
    return 'Digite o código de 6 dígitos enviado para $phoneNumber';
  }

  @override
  String get phoneAuthPhoneNumber => 'Número de telefone';

  @override
  String get phoneAuthPhonePlaceholder => '+1 (555) 123- 4567';

  @override
  String get phoneAuthPleaseEnterPhone => 'Digite seu número de telefone';

  @override
  String get phoneAuthPleaseEnterValidPhone =>
      'Digite um número de telefone válido';

  @override
  String get phoneAuthVerificationCode => 'Código de verificação';

  @override
  String get phoneAuthPleaseEnterSixDigitCode => 'Digite o código de 6 dígitos';

  @override
  String get phoneAuthResendCode => 'Reenviar o Código';

  @override
  String get phoneAuthSendVerificationCode => 'Enviar Verificação Código';

  @override
  String get phoneAuthVerifyCode => 'Verificar o Código';

  @override
  String get phoneAuthChangePhoneNumber => 'Mudar o Número de Telefone';

  @override
  String get phoneAuthSmsNotice =>
      'Enviaremos um código de verificação via SMS. Podem aplicar-se as taxas normais de mensagens.';

  @override
  String get phoneAuthCodeExpires =>
      'O código expira em 60 segundos. Verifica as tuas mensagens.';

  @override
  String get yourDataRights => 'Seus Direitos de Dados';

  @override
  String get dataRightsExplanation =>
      'Você tem total controle sobre seus dados pessoais. Você pode exportar todos os seus dados ou excluir permanentemente sua conta a qualquer momento.';

  @override
  String get exportYourData => 'Exportar seus dados';

  @override
  String get exportDataDescription => 'Baixe todos os dados de sua conta';

  @override
  String get exportData => 'Exportar Dados';

  @override
  String get exportingData => 'Exportando...';

  @override
  String get exportDataDetails =>
      'Inclui: perfil, beeps, comentários, informações do dispositivo e preferências. Os dados são fornecidos no formato JSON.';

  @override
  String get dataExportedSuccessfully => 'Dados exportados com sucesso';

  @override
  String get dataExportFailed => 'Não foi possível exportar dados';

  @override
  String get deleteAccount => 'Apagar conta';

  @override
  String get deleteAccountDescription =>
      'Remova permanentemente sua conta e todos os dados';

  @override
  String get deleteAccountWarning =>
      'Esta acção não pode ser desfeita. Todos os seus beeps, comentários e dados de conta serão excluídos permanentemente.';

  @override
  String get deleteMyAccount => 'Apagar a Minha Conta';

  @override
  String get deletingAccount => 'A apagar...';

  @override
  String get deleteAccountConfirmTitle => 'Apagar conta';

  @override
  String get deleteAccountConfirmMessage =>
      'Tem a certeza absoluta de que deseja apagar a sua conta? Esta acção é permanente e não pode ser desfeita.';

  @override
  String get dataWillBeDeleted =>
      'Os seguintes dados serão permanentemente apagados:';

  @override
  String get deletedDataList =>
      '• Seu perfil e nome de usuário\n• Todos os seus beeps e relatórios\n• Todos os seus comentários\n• Dados de registro de dispositivos\n• Dados de localização e de preferência';

  @override
  String get deleteAccountPermanent => 'Apagar Permanentemente';

  @override
  String get accountDeletedSuccessfully => 'Conta apagada com sucesso';

  @override
  String get accountDeletionFailed => 'Falha ao apagar a conta';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao OVNIBeep';

  @override
  String get onboardingWelcomeBody =>
      'Receba alertas em tempo real quando os OVNIs forem vistos por perto. Nunca mais percas uma visão.';

  @override
  String get onboardingAlertsTitle => 'Mantenha-se informado';

  @override
  String get onboardingAlertsBody =>
      'Defina o quão longe devem estar os avistamentos para activar alertas.';

  @override
  String get onboardingReportTitle => 'Vês alguma coisa? Bip!';

  @override
  String get onboardingReportBody =>
      'Tire uma foto ou vídeo e compartilhe instantaneamente com os observadores próximos.';

  @override
  String get onboardingPermissionsTitle => 'Sua & localização da câmera';

  @override
  String get onboardingPermissionsBody =>
      'Habilitar câmera, localização e notificações para que você possa:\n– Relatar avistamentos rapidamente\n– Obter alertas para OVNIs perto de você';

  @override
  String get onboardingCameraTitle => 'Capturar Evidências';

  @override
  String get onboardingCameraBody =>
      'Compartilhe fotos e vídeos que você acabou de capturar de sua galeria ou pressione o ícone OVNIBeep para iniciar em modo de câmera instantânea.';

  @override
  String get onboardingCompassTitle => 'Veja para onde olharam';

  @override
  String get onboardingCompassBody =>
      'A bússola mostra-te a direcção exacta que a testemunha estava a ver quando viram o OVNI. Aponta o telefone e olha!';

  @override
  String get onboardingCommunityTitle => 'Junte-se aos Skywatchers';

  @override
  String get onboardingCommunityBody =>
      'Veja avistamentos, acesse relatórios MUFON e conecte-se com outros observadores do céu.';

  @override
  String get skip => 'Pular';

  @override
  String get getStarted => 'Iniciar';

  @override
  String get viewOnboardingAgain => 'Ver a Onboard novamente';

  @override
  String get customAlertRange => 'Intervalo de Alerta Personalizado';

  @override
  String get enterRangeKm => 'Digite intervalo em km (1-99999)';

  @override
  String get largeRangeWarning =>
      'Grandes intervalos (>100km) podem gerar muitos alertas';

  @override
  String get globalRangeWarning =>
      'Faixas muito grandes (>1000km) enviarão alertas de todo o mundo';

  @override
  String get invalidRange => 'Digite um número entre 1 e 99999';

  @override
  String get celestialSunDaylight =>
      'O sol está de pé - as condições da luz do dia podem afetar a visibilidade da visão';

  @override
  String get celestialSunTwilight =>
      'Crepúsculo condições - alguma visibilidade, mas mais escuro do que a luz do dia';

  @override
  String get celestialSunDark =>
      'Condições escuras - ideal para observar objetos no céu';

  @override
  String celestialMoonBright(Object phase) {
    return 'Luz $phase lua visível - pode iluminar ou obscurecer outros objetos';
  }

  @override
  String celestialMoonModerate(Object phase) {
    return '${phase}_ lua visível - condições de iluminação moderadas';
  }

  @override
  String celestialMoonThin(Object phase) {
    return 'Magro ${phase}_ lua visível - iluminação mínima';
  }

  @override
  String celestialMoonHidden(Object phase) {
    return 'Lua abaixo do horizonte - sem iluminação lunar';
  }

  @override
  String get celestialNoPlanets =>
      'Nenhum planeta brilhante visível que possa ser confundido com OVNIs';

  @override
  String celestialPlanetHigh(Object altitude, Object planet) {
    return '(_________________) - muito proeminente';
  }

  @override
  String celestialPlanetMedium(Object altitude, Object planet) {
    return '${planet}_ visível em $planet° - pode ser confundido com aeronaves';
  }

  @override
  String celestialPlanetLow(Object altitude, Object planet) {
    return '$planet baixo no horizonte ($planet°)';
  }

  @override
  String get celestialNoStars =>
      'Nenhuma estrela invulgarmente brilhante visível';

  @override
  String celestialStarSingle(Object altitude, Object star) {
    return '__PACEHOLDER_0____ proeminente a altitude __PACEHOLDER_1___°';
  }

  @override
  String celestialStarsMultiple(Object count, Object names) {
    return '__PACEHOLDER_0__ estrelas brilhantes visíveis __PACEHOLDER_1_';
  }

  @override
  String get celestialSummaryDaylight => 'Condições de luz do dia';

  @override
  String get celestialSummaryDark => 'Condições do céu escuro';

  @override
  String get celestialSummaryMoonUp => 'iluminação da lua presente';

  @override
  String get celestialSummaryMoonDown => 'sem iluminação da lua';

  @override
  String celestialSummaryManyObjects(Object count) {
    return '${count}__ objetos brilhantes que podem ser confundidos com OVNIs';
  }

  @override
  String celestialSummarySomeObjects(Object count) {
    return '__PACEHOLDER_0___ objeto(s) brilhante(s) visível(ais)';
  }

  @override
  String get celestialSummaryFewObjects => 'objetos brilhantes mínimos no céu';

  @override
  String celestialSkySummary(Object conditions) {
    return 'Condições do céu: __PACELODER_0_';
  }

  @override
  String get planetVenus => 'Vênus';

  @override
  String get planetJupiter => 'Júpiter';

  @override
  String get planetSaturn => 'Saturno';

  @override
  String get planetMars => 'Marte';

  @override
  String get planetMercury => 'Mercúrio';

  @override
  String get planetUranus => 'Urano';

  @override
  String get planetNeptune => 'Netuno';

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
  String get moonPhaseNew => 'Lua Nova';

  @override
  String get moonPhaseWaxingCrescent => 'Crescente de Cera';

  @override
  String get moonPhaseFirstQuarter => 'Primeiro trimestre';

  @override
  String get moonPhaseWaxingGibbous => 'Gibbous de cera';

  @override
  String get moonPhaseFull => 'Lua cheia';

  @override
  String get moonPhaseWaningGibbous => 'Gibbous';

  @override
  String get moonPhaseThirdQuarter => 'Terceiro trimestre';

  @override
  String get moonPhaseWaningCrescent => 'Crescente em declínio';

  @override
  String planetBelowHorizon(Object planet) {
    return '__PACEHOLDER_0__ abaixo do horizonte';
  }

  @override
  String planetHighOverheadProminent(Object altitude, Object planet) {
    return '(_________________) - muito proeminente';
  }

  @override
  String planetMidSkyProminent(Object altitude, Object planet) {
    return '${planet}________________________________________________________________________________';
  }

  @override
  String planetMidSky(Object altitude, Object planet) {
    return 'LONDRES DE LOCALIZAÇÃO';
  }

  @override
  String starVeryBright(Object altitude, Object star) {
    return '__PACEHOLDER_0___ muito brilhante em __PACEHOLDER_1___';
  }

  @override
  String starProminent(Object altitude, Object star) {
    return '__PACEHOLDER_0____ proeminente a altitude __PACEHOLDER_1___°';
  }

  @override
  String starVisible(Object altitude, Object star) {
    return 'LONDRES DE LOCALIZAÇÃO';
  }

  @override
  String get altitudeShort => 'Alt';

  @override
  String get magnitudeShort => 'Mag';

  @override
  String satellitesVisibleMightExplain(Object count) {
    return '${count}_ satélites visíveis - pode explicar o avistamento';
  }

  @override
  String satellitesVisibleUnlikelyExplain(Object count) {
    return '${count}_ satélites visíveis - improvável explicar o avistamento';
  }

  @override
  String get noSatellitesVisible => 'Nenhum satélite visível';

  @override
  String aircraftDetectedInRadius(Object count, Object radius) {
    return 'Aeronaves detetadas dentro de 1 km';
  }

  @override
  String get processingAlert => 'Processando alerta de OVNI...';

  @override
  String get analyzingEnvironment => 'Análise das condições ambientais';

  @override
  String get weatherAnalysis => 'Análise Meteorológica';

  @override
  String get locationAnalysis => 'Análise de Localização';

  @override
  String get aircraftTracking => 'Rastreamento de aeronaves';

  @override
  String get satelliteAnalysis => 'Análise por Satélite';

  @override
  String get celestialAnalysis => 'Análise Celestial';

  @override
  String analyzing(Object processor) {
    return 'Analisando __PACEHOLDER_0__...';
  }

  @override
  String get processorWeather => 'condições meteorológicas';

  @override
  String get processorLocation => 'detalhes da localização';

  @override
  String get processorAircraft => 'aeronaves vizinhas';

  @override
  String get processorSatellites => 'posições de satélite';

  @override
  String get processorCelestial => 'objetos celestes';

  @override
  String get calculatingCelestialData => 'Calculando dados celestes...';

  @override
  String get sunLabel => 'Sol';

  @override
  String get moonLabel => 'Lua';

  @override
  String planetsVisible(int count) {
    return 'Planetas: $count visível';
  }

  @override
  String get starsLabel => 'Estrelas';

  @override
  String get planetsLabel => 'Planetas';

  @override
  String moonWithPhase(String phase) {
    return 'Lua (__PLACEHOLDER_0_)';
  }

  @override
  String get noSatellitesVisibleAtTime =>
      'Nenhum satélite foi visível na hora exata de sua aparição';

  @override
  String get satellitesVisibleOverheadAtTime =>
      'Satélites visíveis em cima ao avistar hora e local';

  @override
  String get belowHorizon => 'abaixo do horizonte';

  @override
  String get analysisFailedGeneric => 'A análise falhou';

  @override
  String get unknownWeather => 'Desconhecido';

  @override
  String get noWeatherDescription => 'Sem descrição';

  @override
  String get altitudeAbbrev => 'Alt';

  @override
  String get azimuthAbbrev => 'Az';

  @override
  String satellitesVisibleNow(int count) {
    return 'Satélites ($count visível agora)';
  }

  @override
  String sunWithDescription(String description) {
    return 'Sol:';
  }

  @override
  String moonWithDescription(String description) {
    return 'Lua:';
  }

  @override
  String get unknownPlanet => 'Planeta Desconhecido';

  @override
  String get unknownStar => 'Estrela desconhecida';

  @override
  String get unknownSatellite => 'Satélite Desconhecido';

  @override
  String get unknownDirection => 'direção desconhecida';

  @override
  String get brightStars => 'Estrelas Brilhantes';

  @override
  String get satellites => 'Satélites';

  @override
  String seeAllSatellites(int count) {
    return 'Ver todos os satélites';
  }

  @override
  String maxElevation(String degrees) {
    return 'Elevação máxima: __PACELODER_0___';
  }

  @override
  String magnitude(String value) {
    return 'Amplitude: __PACELODER_0_';
  }

  @override
  String get unknownGeneric => 'Desconhecido';

  @override
  String altitudeValue(String degrees) {
    return 'Altitude de 0°';
  }

  @override
  String azimuthValue(String degrees) {
    return '__PACEHOLDER_0___° azimute';
  }

  @override
  String get noCelestialDataAvailable => 'Nenhum dado celestial disponível.';

  @override
  String get gettingLocation => 'A obter a sua localização...';

  @override
  String get media => 'Mídia';

  @override
  String get locationRequired => 'Localização necessária';

  @override
  String get confirmingWitness => 'Confirmando testemunha...';

  @override
  String get chooseYourUsername => 'Escolha seu nome de usuário';

  @override
  String get moreNames => 'Mais nomes';

  @override
  String get notificationSettings => 'Configuração da Notificação';

  @override
  String get quickActions => 'Acções Rápidas';

  @override
  String get doNotDisturb => 'Não Perturbe';

  @override
  String get temporarilySilenceNotifications =>
      'Silenciar temporariamente todas as notificações';

  @override
  String get oneHour => '1h';

  @override
  String get eightHours => '8h';

  @override
  String get oneDay => '1 dia';

  @override
  String get startTime => 'Hora de início';

  @override
  String get endTime => 'Hora do fim';

  @override
  String get allowCriticalAlertsDuringQuietHours =>
      'Permitir alertas críticos durante horas silenciosas';

  @override
  String get silenceNotificationsDuringSleepHours =>
      'Notificações de silêncio durante as horas de sono';

  @override
  String quietHoursActiveTimeRange(String startTime, String endTime) {
    return 'Ativo ${startTime}_ __PLACEHOLDER_1_';
  }

  @override
  String get followingAlerts => 'Seguir as Alertas';

  @override
  String activeCount(int count) {
    return '__PACEHOLDER_0__ ativo';
  }

  @override
  String get unfollow => 'Sem seguir';

  @override
  String get unfollowAlert => 'Alerta de Não Seguir';

  @override
  String commentsCount(int count) {
    return '__PACEHOLDER_0__ comentários';
  }

  @override
  String get photo => 'Foto';

  @override
  String get video => 'Vídeo';

  @override
  String get initializationComplete => 'Inicialização completa!';

  @override
  String get validatingEnvironment => 'A validar o ambiente...';

  @override
  String get requestingPermissions => 'Solicitando permissões...';

  @override
  String get loadingAuthSession => 'A carregar a sessão de autenticação...';

  @override
  String get checkingUserRegistration =>
      'A verificar o registo do utilizador...';

  @override
  String get loadingPreferences => 'Carregando preferências...';

  @override
  String get settingUpLocalization => 'A configurar a localização...';

  @override
  String get checkingConnectivity => 'A verificar a conectividade...';

  @override
  String get gatheringDeviceInfo =>
      'A recolher as informações do dispositivo...';

  @override
  String get translating => 'Translating...';

  @override
  String get showOriginal => 'Show Original';

  @override
  String translateTo(String language) {
    return 'Translate to $language';
  }

  @override
  String translatedFrom(String language) {
    return 'Translated from $language';
  }

  @override
  String translateContent(String language) {
    return 'Translate content to $language';
  }

  @override
  String get weatherClear => 'Limpar';

  @override
  String get weatherClearSky => 'céu limpo';

  @override
  String get rain => 'Chuva';

  @override
  String get snow => 'Neve';

  @override
  String get thunderstorm => 'Trovão';

  @override
  String get drizzle => 'Drizzle';

  @override
  String get fog => 'Nevoeiro';

  @override
  String get fewClouds => 'poucas nuvens';

  @override
  String get scatteredClouds => 'nuvens dispersas';

  @override
  String get brokenClouds => 'nuvens quebradas';

  @override
  String get overcastClouds => 'nuvens nubladas';

  @override
  String get lightRain => 'chuva leve';

  @override
  String get moderateRain => 'chuva moderada';

  @override
  String get heavyRain => 'chuva pesada';

  @override
  String aircraftDetectedCurrentPositions(int count, String radius) {
    return '${count}__aeronaves detectadas dentro de ${count}km (posição atual)';
  }

  @override
  String dimSatellitesUnlikely(int count) {
    return '$count os satélites menos visíveis - improvável explicar o avistamento';
  }

  @override
  String get mufonReportingDate => 'MUFON Data de comunicação';

  @override
  String satelliteNameDirection(String name, String direction) {
    return '__PACEHOLDER_0__ __PACEHOLDER_1_';
  }
}
