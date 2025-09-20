// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'UFOBeep';

  @override
  String get ok => 'TRÈS BIEN';

  @override
  String get cancel => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get retry => 'Réessayer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Numéro';

  @override
  String get back => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get done => 'Fait';

  @override
  String get loading => 'Chargement..';

  @override
  String get processing => 'Traitement..';

  @override
  String get errorGeneric => 'Quelque chose s\'est mal passé.';

  @override
  String get networkError => 'Erreur réseau. Vérifiez votre connexion.';

  @override
  String get permissionsRequired => 'Autorisations requises';

  @override
  String get learnMore => 'En savoir plus';

  @override
  String get welcomeTitle => 'Bienvenue à UFOBeep';

  @override
  String get welcomeSubtitle => 'Alertes OVNI en temps réel près de chez vous';

  @override
  String get signIn => 'Connexion';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get continueAsGuest => 'Continuer comme invité';

  @override
  String get enterUsername => 'Saisissez un nom d\'utilisateur';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get usernameUpdated => 'Nom d\'utilisateur mis à jour';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get tabAlerts => 'Alertes';

  @override
  String get tabBeep => 'Bip';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabMap => 'Carte';

  @override
  String get tabSettings => 'Paramètres';

  @override
  String get alertsTitle => 'Alertes à proximité';

  @override
  String get noAlerts => 'Pas encore d\'alerte.';

  @override
  String get pullToRefresh => 'Tirer pour rafraîchir';

  @override
  String alertDistance(String distance) {
    return '__PLACÉHOLDER_0__ loin';
  }

  @override
  String alertDirection(int bearing) {
    return 'Roulement $bearing°';
  }

  @override
  String get viewAlert => 'Afficher l\'alerte';

  @override
  String get viewOnMap => 'Vue sur la carte';

  @override
  String get iSeeItToo => 'Je le vois aussi';

  @override
  String get confirmWitnessed =>
      'Vous confirmez avoir été témoin de cette observation ?';

  @override
  String get witnessConfirmed => 'Merci — votre confirmation a été postée.';

  @override
  String get createBeepTitle => 'Envoyer un bip';

  @override
  String get beepExplain =>
      'Capturez ce que vous voyez et alertez les observateurs à proximité.';

  @override
  String get capturePhoto => 'Photo de capture';

  @override
  String get captureVideo => 'Capture vidéo';

  @override
  String get pickFromGallery => 'Choisissez parmi la galerie';

  @override
  String get descriptionHint => 'Décrivez ce que vous voyez dans le ciel..';

  @override
  String get submitBeep => 'Envoyer un bip';

  @override
  String get beepSent => 'Bip envoyé';

  @override
  String beepSentWithUrl(String shortUrl) {
    return 'Bip envoyé avec succès';
  }

  @override
  String get uploadingMedia => 'Télécharger des médias..';

  @override
  String get includeLocation => 'Inclure l\'emplacement';

  @override
  String get includeTimestamp => 'Inclure l\'horodatage';

  @override
  String get beepFailed => 'Il n\'a pas envoyé de beep.';

  @override
  String get mediaProcessing => 'Traitement des supports..';

  @override
  String get cameraPermissionTitle => 'Accès à la caméra nécessaire';

  @override
  String get cameraPermissionBody =>
      'Accorder l\'accès à la caméra pour capturer des photos et des vidéos ovnis.';

  @override
  String get locationPermissionTitle => 'Accès à l\'emplacement nécessaire';

  @override
  String get locationPermissionBody =>
      'Nous utilisons votre emplacement pour envoyer et recevoir des alertes à proximité.';

  @override
  String get microphonePermissionTitle => 'Accès au microphone nécessaire';

  @override
  String get microphonePermissionBody =>
      'Accorder un accès microphone pour la capture vidéo avec audio.';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get alertDetailTitle => 'Détails de la vue';

  @override
  String reportedBy(String username) {
    return 'Signalé par __PLACEHODER_0__';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Rapporté __PLACEHODER_0__';
  }

  @override
  String distanceAway(String distance) {
    return '_PLACEHOLDER_0__';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Roulement à l\'objet : $bearing°';
  }

  @override
  String get openCompass => 'Boussole ouverte';

  @override
  String get openAR => 'Superposition AR ouverte';

  @override
  String get openChat => 'Ouvrir le chat';

  @override
  String get commentsTitle => 'Commentaires';

  @override
  String get addComment => 'Ajouter un commentaire..';

  @override
  String get send => 'Envoyer';

  @override
  String get commentPosted => 'Commentaire affiché';

  @override
  String get autoFollowEnabled => 'Vous suivez maintenant cette alerte.';

  @override
  String get noCommentsYet =>
      'Pas encore de commentaires. Soyez le premier à commenter!';

  @override
  String get newCommentNotification =>
      'Nouveau commentaire sur une observation que vous suivez.';

  @override
  String get mapTitle => 'Carte en direct';

  @override
  String get compassTitle => 'Boussole';

  @override
  String get compassSettings => 'Paramètres de la boussole';

  @override
  String get compassMode => 'Mode Boussole';

  @override
  String get compassStandardMode => 'Mode standard';

  @override
  String get compassPilotMode => 'Mode pilote';

  @override
  String get compassStandardDescription => 'Intitulé de base et navigation';

  @override
  String get compassPilotDescription =>
      'Navigation avancée avec ETA et vectoring';

  @override
  String pointingTo(String direction) {
    return 'Pointage vers _PLACEHODER_0__';
  }

  @override
  String get calibratingCompass => 'Boussole d\'étalonnage..';

  @override
  String get openAROverlay => 'Superposition AR ouverte';

  @override
  String get pushTitleAlertNearby => 'Alerte ovni près de chez vous';

  @override
  String pushBodyAlertNearby(String distance) {
    return 'Une nouvelle observation a été signalée $distance loin.';
  }

  @override
  String get pushTitleComment => 'Nouveau commentaire';

  @override
  String get pushBodyComment =>
      'Quelqu\'un a commenté une observation que vous suivez.';

  @override
  String get pushTitleWitness => 'Confirmation du témoin';

  @override
  String get temperature => 'Température';

  @override
  String get pushBodyWitness =>
      'Un utilisateur a confirmé qu\'il voit le même objet.';

  @override
  String get weather => 'Météo';

  @override
  String cloudCover(int percent) {
    return 'Couverture nuageuse & #160;: $percent%';
  }

  @override
  String wind(num speed, String unit) {
    return 'Vent: $speed$unit';
  }

  @override
  String get nearbyAircraft => 'Avion à proximité';

  @override
  String get noAircraft => 'Aucun aéronef à proximité';

  @override
  String get loadingContext => 'Chargement du contexte environnemental..';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get notifications => 'Notifications';

  @override
  String get enablePushNotifications =>
      'Obtenir des notifications pour les commentaires futurs';

  @override
  String get quietHours => 'Heures calmes';

  @override
  String get quietHoursDesc =>
      'Alertes de silence entre les heures sélectionnées.';

  @override
  String get quietHoursEnabled => 'Activer des heures calmes';

  @override
  String get quietHoursFrom => 'De';

  @override
  String get quietHoursUntil => 'Jusqu\'à';

  @override
  String get quietHoursDefaultTime => 'Heures de silence par défaut';

  @override
  String get emergencyOverride => 'Passage d\'urgence';

  @override
  String get emergencyOverrideDesc =>
      'Autoriser les alertes urgentes pendant les heures calmes';

  @override
  String get dndMode => 'Ne pas déranger';

  @override
  String get dndUntil => 'Ne pas déranger jusqu\'à';

  @override
  String dndEnabled(Object time) {
    return 'Le MDN a activé jusqu\'à __PLACEHODER_0__';
  }

  @override
  String get dndDisabled => 'Personnes handicapées du MDN';

  @override
  String get quietHoursActive => 'Heures calmes actives';

  @override
  String quietHoursScheduled(Object end, Object start) {
    return 'Heures calmes: ${start}_$start';
  }

  @override
  String get pushNotificationUfoAlert => 'OVNI Alerte';

  @override
  String get pushNotificationAnomalyAlert => 'Alerte d\'anomalie';

  @override
  String get pushNotificationNearby => 'À proximité';

  @override
  String get pushNotificationInYourArea =>
      'dans votre région. Appuyez sur pour voir les détails.';

  @override
  String pushNotificationCommented(Object username) {
    return '__PLACEHODER_0__ commenté';
  }

  @override
  String pushNotificationCommentedOn(Object beepTitle, Object username) {
    return '$username commente $username';
  }

  @override
  String get pushNotificationGeneric => 'UFOBeep';

  @override
  String get pushNotificationNewSighting => 'Nouvelle observation à proximité';

  @override
  String get language => 'Langue';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get units => 'Unités';

  @override
  String get unitsImperial => 'Impérial (mi, mi)';

  @override
  String get unitsMetric => 'Métrique (km, km/h)';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get errorNoLocation =>
      'Emplacement non disponible. Essayez de nouveau dehors avec une vue dégagée du ciel.';

  @override
  String get errorNoCamera => 'Caméra non disponible sur cet appareil.';

  @override
  String get errorUploadFailed => 'Le chargement a échoué. Veuillez réessayer.';

  @override
  String get errorPermissionDenied => 'Autorisation refusée.';

  @override
  String get errorInvalidUsername =>
      'Ce nom d\'utilisateur n\'est pas disponible.';

  @override
  String get nothingToShow => 'Rien à montrer.';

  @override
  String get storeShortDesc =>
      'Des ovnis instantanés vous alertent. Capturer, confirmer et discuter en temps réel.';

  @override
  String get storeLongDesc =>
      'UFOBeep envoie des alertes en temps réel quand quelqu\'un repère un OVNI à proximité. Capturez des photos et des vidéos, confirmez les observations avec un robinet, visualisez la direction et la distance et discutez avec d\'autres skywatchers.';

  @override
  String get keywords =>
      'UFO, UAP,OVNI, étrangers, visionnages,skywatch, alertes,radar,compass';

  @override
  String get noAlertsFound => 'Aucune alerte correspondante';

  @override
  String get alertsFilterHelp =>
      'Essayez d\'ajuster vos filtres pour voir plus de résultats';

  @override
  String get verified => 'Vérifié';

  @override
  String get beepOnly => 'Bip seulement';

  @override
  String get reportOnly => 'Texte seulement';

  @override
  String get videoOnly => 'Vidéo seulement';

  @override
  String get imageOnly => 'Image seulement';

  @override
  String get mediaOnly => 'Médias seulement';

  @override
  String get timeJustNow => 'juste maintenant';

  @override
  String timeDaysAgo(int count) {
    return '$count il y a des jours';
  }

  @override
  String timeHoursAgo(int count) {
    return '_PLACEHOLDER_0__il y a des heures';
  }

  @override
  String timeMinutesAgo(int count) {
    return '$count il y a quelques minutes';
  }

  @override
  String get loadMoreAlerts => 'Charger d\'autres alertes';

  @override
  String get toggleMufonTooltip => 'Éliminer les observations du MUFON';

  @override
  String get showMufonData => 'Afficher les données MUFON';

  @override
  String get hideMufonData => 'Masquer les données MUFON';

  @override
  String get showingUfoBeepOnly => 'Afficher seulement les rapports UFOBeep';

  @override
  String get showingAllReports =>
      'Affichage de tous les rapports, y compris la base de données MUFON';

  @override
  String get filteredSuffix => 'filtré';

  @override
  String get detailsTitle => 'Détails';

  @override
  String get mufonCase => 'MUFON Affaire';

  @override
  String get mufonSighting => 'Rapport de surveillance du MUFON';

  @override
  String get mufonLightSighting => 'Rapport de surveillance lumineuse du MUFON';

  @override
  String get mufonSphereSighting =>
      'Rapport de surveillance de la sphère MUFON';

  @override
  String get mufonDiscSighting => 'MUFON Rapport d\'observation des disques';

  @override
  String get mufonTriangleSighting =>
      'MUFON Rapport de surveillance du triangle';

  @override
  String get mufonCigarSighting =>
      'Rapport de surveillance des cigarettes MUFON';

  @override
  String get mufonOvalSighting => 'Rapport de surveillance ovale du MUFON';

  @override
  String get mufonRectangleSighting => 'MUFON Rapport d\'observation rectangle';

  @override
  String get mufonCylinderSighting =>
      'Rapport de surveillance des cylindres du MUFON';

  @override
  String get mufonBoomerangSighting =>
      'Rapport de surveillance du MUFON Boomerang';

  @override
  String get mufonStarlikeSighting =>
      'MUFON Rapport d\'observation des étoiles';

  @override
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'Cas MUFON #$caseNumber Détails';
  }

  @override
  String get sightingDate => 'Date de la visite';

  @override
  String get mufonDatabaseEntryDate =>
      'Date d\'entrée dans le MUFON Base de données';

  @override
  String get databaseEntry => 'Entrée de la base de données';

  @override
  String get shareLink => 'Partager le lien';

  @override
  String get linkCopied => 'Lien copié dans le presse-papiers';

  @override
  String get locationLabel => 'Lieu:';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get timeLabel => 'Heure:';

  @override
  String get reportedByLabel => 'Rapporté par';

  @override
  String get unknownLocation => 'Emplacement inconnu';

  @override
  String get locationUnknown => 'Lieu inconnu';

  @override
  String get witnessesLabel => 'Témoins';

  @override
  String witnessesCountMessage(int count) {
    return 'Les gens ont confirmé cette observation';
  }

  @override
  String get photoAnalysisTitle => 'Analyse photo';

  @override
  String mediaItemsProcessed(int count) {
    return 'Analyse : fichier multimédia $count traité';
  }

  @override
  String get addMoreMedia => 'Ajouter plus';

  @override
  String get addMedia => 'Ajouter un média';

  @override
  String get retakePhoto => 'Reprendre la photo';

  @override
  String get retakeVideo => 'Reprendre la vidéo';

  @override
  String get camera => 'Caméra';

  @override
  String get gallery => 'Galerie';

  @override
  String get basicSettings => 'Paramètres de base';

  @override
  String get appSettings => 'Paramètres de l\' application';

  @override
  String get timeFormat => 'Format de l\'heure';

  @override
  String get timeFormat24Hour => '24 heures sur 24 (14 h 30)';

  @override
  String get timeFormat12Hour => '12 heures (2 h 30)';

  @override
  String get timeFormatDesc =>
      'Temps d\'affichage en format 24 heures ou 12 heures';

  @override
  String get alertRange => 'Gamme d\'alerte';

  @override
  String get manageNotificationsDesc =>
      'Gérer les abonnements et les paramètres';

  @override
  String get permissionsTitle => 'Autorisations';

  @override
  String get permissionLocation => 'Lieu';

  @override
  String get permissionCamera => 'Caméra';

  @override
  String get permissionNotifications => 'Notifications';

  @override
  String get permissionPhotos => 'Photos';

  @override
  String get permissionGranted => 'Accordée';

  @override
  String get permissionNotGranted => 'Non accordée';

  @override
  String get permissionGrant => 'Subvention';

  @override
  String get generateUsername => 'Générer un nouveau nom d\'utilisateur';

  @override
  String get adminTools => 'Outils d\'administration';

  @override
  String get openAdminPanel => 'Ouvrir le panneau Admin';

  @override
  String get webAdminInterface => 'Interface Web Admin';

  @override
  String get adminBetaNotice =>
      'Beta construit seulement. Outils d\'administration pour tester les alertes de proximité, les notifications de poussée et les diagnostics système.';

  @override
  String get whatDoYouSee => 'Que voyez-vous ?';

  @override
  String get ufo => 'OVNI';

  @override
  String get sighting => 'Vue';

  @override
  String get ufoSighting => 'OVNI profond Alerte';

  @override
  String get envAnalysisTitle => 'Analyse environnementale';

  @override
  String get envAnalysisPending => 'Analyse en cours';

  @override
  String get envAnalysisPendingDesc =>
      'Les données environnementales seront disponibles une fois le traitement commencé.';

  @override
  String get unknownAircraft => 'Aéronef inconnu';

  @override
  String get moreAircraft => 'plus d\'avions';

  @override
  String get premiumImageryTitle => 'Satellite Premium Imagerie';

  @override
  String get premiumImagerySubtitle => 'Imagerie commerciale haute résolution';

  @override
  String get sightingTypeLabel => 'Type';

  @override
  String get ufoTypeSphere => 'Sphère';

  @override
  String get ufoTypeTriangle => 'Triangle';

  @override
  String get ufoTypeDisk => 'Disque';

  @override
  String get ufoTypeLight => 'Lumière';

  @override
  String get ufoTypeFireball => 'Boule de feu';

  @override
  String get ufoTypeCylinder => 'Cylindre';

  @override
  String get ufoTypeCigar => 'Cigares';

  @override
  String get ufoTypeRectangle => 'Rectangle';

  @override
  String get ufoTypeFormation => 'Formation';

  @override
  String get ufoTypeUnknown => 'Inconnu';

  @override
  String get ufoTypeBoomerang => 'Boomerang';

  @override
  String get ufoTypeDiamond => 'Diamant';

  @override
  String get ufoTypeOval => 'Ovale';

  @override
  String get ufoTypeCone => 'Cône';

  @override
  String get ufoTypeCross => 'Croix';

  @override
  String get ufoTypeDumbbell => 'Bouteille';

  @override
  String get ufoTypeTeardrop => 'Teardrop';

  @override
  String get ufoTypeTicTac => 'Tic Tac';

  @override
  String get ufoTypeBullet => 'Bullet';

  @override
  String get ufoTypeSaturn => 'Saturne';

  @override
  String get ufoTypeStarLike => 'Comme une étoile';

  @override
  String get ufoTypeBlimp => 'Blimp';

  @override
  String get shapeTriangle => 'triangle';

  @override
  String get shapeDisc => 'disque';

  @override
  String get shapeDisk => 'disque';

  @override
  String get shapeSphere => 'sphère';

  @override
  String get shapeCigar => 'cigare';

  @override
  String get shapeLight => 'lumière';

  @override
  String get shapeBoomerang => 'boomerang';

  @override
  String get shapeDiamond => 'diamant';

  @override
  String get shapeRectangle => 'rectangle';

  @override
  String get shapeOval => 'ovale';

  @override
  String get shapeCone => 'cône';

  @override
  String get shapeCross => 'croix';

  @override
  String get shapeCylinder => 'cylindre';

  @override
  String get shapeDumbbell => 'haltères';

  @override
  String get shapeTeardrop => 'goutte à la déchirure';

  @override
  String get shapeTicTac => 'tic-tac';

  @override
  String get shapeBullet => 'balle';

  @override
  String get shapeSaturn => 'saturne';

  @override
  String get shapeStarlike => 'comme une étoile';

  @override
  String get shapeBlimp => 'bleux';

  @override
  String get shapeFireball => 'boule de feu';

  @override
  String get shapeFormation => 'formation';

  @override
  String get shapeUnknown => 'inconnu';

  @override
  String get actionsTitle => 'Actions';

  @override
  String get addPhotosAndVideos => 'Ajouter des photos et des vidéos';

  @override
  String get howToReportToMufon => 'Comment se présenter au MUFON';

  @override
  String get reportToMufon => 'Rapport au MUFON';

  @override
  String get whyReportToMufon => 'Pourquoi se présenter au MUFON?';

  @override
  String get openMufonReport => 'Ouvrir le MUFON Rapport annuel';

  @override
  String get confirmedWitness => 'Vous avez confirmé cette observation';

  @override
  String witnessesHaveConfirmed(int count) {
    return 'Les gens ont confirmé cette observation';
  }

  @override
  String get aircraftTrackingTitle => 'Suivi des aéronefs';

  @override
  String get weatherConditionsTitle => 'Conditions météorologiques';

  @override
  String get noSatellitePasses =>
      'Aucune carte satellite visible n\'a été trouvée';

  @override
  String get contentAnalysisTitle => 'Analyse du contenu';

  @override
  String get contentSafe => 'Le contenu est sûr';

  @override
  String get contentFlagged => 'Contenu signalé pour examen';

  @override
  String get confidenceLabel => 'Confiance';

  @override
  String get methodLabel => 'Méthode';

  @override
  String get premiumImageryAccessOnly =>
      'L\'imagerie satellitaire haut de gamme est disponible uniquement pour :';

  @override
  String get premiumAccessCreators => 'Les créateurs d\'alerte';

  @override
  String get premiumAccessWitnesses =>
      'Témoins confirmés à portée de visibilité';

  @override
  String get comingSoon => 'Bientôt';

  @override
  String get directionDistanceTitle => 'Direction & Distance';

  @override
  String mufonCaseTitle(String caseNumber) {
    return 'MUFON Cas #__PLACEHODER_0__';
  }

  @override
  String get satellitePassesTitle => 'Cartes satellites';

  @override
  String get satellitePassExplanation =>
      'Satellite visible passe pendant la période d\'observation. De nombreux rapports ovnis sont en fait des satellites ou des débris spatiaux.';

  @override
  String get followingAlert =>
      'Après l\'alerte - vous obtiendrez des notifications de commentaires';

  @override
  String get unfollowedAlert =>
      'Alerte non suivie - plus de notifications de commentaires';

  @override
  String get alertFollowError => 'Erreur de mise à jour suivre l\'état';

  @override
  String get notificationChannelAlerts => 'Alertes ovni-breep';

  @override
  String get notificationChannelAlertsDesc =>
      'Notifications pour les bips ovnis et alertes de proximité';

  @override
  String get notificationSightingTitle => 'OVNI profond Alerte';

  @override
  String get notificationSightingUrgent => 'URGENT UFOBeep UFO Alerte';

  @override
  String get notificationSightingEmergency => 'UFO EMERGENCE Alerte';

  @override
  String notificationSightingBody(String witnessText, String locationName) {
    return '$witnessText près de _PLACEHOLDER_1__';
  }

  @override
  String notificationCommentTitle(String username) {
    return '$username commenté';
  }

  @override
  String get notificationWitnessText => 'Nouvelles observations';

  @override
  String notificationWitnessTextMultiple(int count) {
    return '_PLACEHOLDER_0__ témoins';
  }

  @override
  String get notificationActionSnooze => 'Snooze 1h';

  @override
  String get notificationActionDismiss => 'Rejet';

  @override
  String notificationDistance(String distance) {
    return '__PLACÉHOLDER_0__ loin';
  }

  @override
  String get unknown => 'inconnu';

  @override
  String get report => 'rapport';

  @override
  String get mufon => 'mufon';

  @override
  String get recentUfoBeepsTitle => 'OVNI récents Abeilles';

  @override
  String get recentUfoBeepsSubtitle =>
      'Rapports d\'observation d\'ovnis vivants de notre communauté mondiale';

  @override
  String get recentUfoBeepsDescription =>
      'Ce flux combine en temps réel UFOBeep \"beeps\" de nos utilisateurs d\'applications mobiles avec des rapports historiques de la base de données MUFON.';

  @override
  String get loadingBeeps => 'Chargement de bips récents...';

  @override
  String get noBeepsAvailable => 'Pas de bip pour le moment.';

  @override
  String get anomalyReported => 'Anomalie rapportée';

  @override
  String get copyShortLink => 'Copier le lien court';

  @override
  String get shareAlert => 'Partager l\'alerte';

  @override
  String get ufoSightingAlert => 'OVNI Alerte de surveillance';

  @override
  String get previousPage => 'Précédent';

  @override
  String get nextPage => 'Suivant';

  @override
  String pageOf(Object currentPage, Object totalCount, Object totalPages) {
    return 'Page $currentPage de $totalPages ($totalCount bips totaux)';
  }

  @override
  String get firstPage => 'Première';

  @override
  String get lastPage => 'Dernier';

  @override
  String get jumpToPage => 'Aller à la page';

  @override
  String get heroTagline =>
      'Obtenir des alertes quand aller dehors et regarder vers le haut';

  @override
  String get heroDescription =>
      'Ne manquez jamais une autre OVNI. Obtenez des alertes en temps réel quand quelqu\'un près de vous voit quelque chose de bizarre dans le ciel. Pointez votre téléphone et trouvez exactement où chercher.';

  @override
  String get downloadApp => 'Télécharger l\'application';

  @override
  String get viewAllBeeps => 'Voir toutes les abeilles';

  @override
  String get sightingsMap => 'Carte des visites';

  @override
  String get globalSightingNetwork => 'Réseau mondial de surveillance';

  @override
  String get howItWorks => 'Comment UFOBeep fonctionne';

  @override
  String get backToBeeps => 'Retour aux Beeps';

  @override
  String get loadingDetails => 'Chargement des détails du bip...';

  @override
  String get details => 'Détails';

  @override
  String get location => 'Lieu';

  @override
  String get timeAgo => 'il y a';

  @override
  String get timeMinutes => 'm';

  @override
  String get timeHours => 'h';

  @override
  String get timeDays => 'd';

  @override
  String get distanceKm => 'km';

  @override
  String get distanceMiles => 'miles';

  @override
  String get distanceNearby => 'à proximité';

  @override
  String get ufobeepWitnesses => 'Témoins';

  @override
  String get ufobeepConfirmations => 'Confirmations';

  @override
  String get ufobeepAlertLevel => 'Niveau d\'alerte';

  @override
  String get ufobeepReportType => 'Rapport UFOBeep';

  @override
  String get mufonAttribution => 'MUFON Rapport de base de données';

  @override
  String get mufonCaseNumber => 'Dossier #';

  @override
  String get mufonGenericTitle => 'Rapport de surveillance du MUFON';

  @override
  String get mufonSphere => 'Sphère';

  @override
  String get mufonLight => 'Lumière';

  @override
  String get mufonDisk => 'Disque';

  @override
  String get mufonTriangle => 'Triangle';

  @override
  String get mufonCigar => 'Cigares';

  @override
  String get mufonOval => 'Ovale';

  @override
  String get mufonCylinder => 'Cylindre';

  @override
  String get mufonRectangle => 'Rectangle';

  @override
  String get mufonDiamond => 'Diamant';

  @override
  String get mufonFireball => 'Boule de feu';

  @override
  String get mufonFlash => 'Flash';

  @override
  String get mufonFormation => 'Formation';

  @override
  String get mufonChanging => 'Changement';

  @override
  String get mufonChevron => 'Chevron';

  @override
  String get mufonCone => 'Cône';

  @override
  String get mufonCross => 'Croix';

  @override
  String get mufonEgg => 'Œuf';

  @override
  String get mufonOther => 'Objet';

  @override
  String get mufonUnknown => 'Objet inconnu';

  @override
  String mufonTitleFormat(Object classification) {
    return 'Rapport de MUFON __PLACEHODER_0__';
  }

  @override
  String get nuforcAttribution => 'NUFORC Rapport de base de données';

  @override
  String get nuforcCaseNumber => 'Dossier #';

  @override
  String get nuforcGenericTitle => 'NUFORC Rapport d\'observation';

  @override
  String get mediaImageNotFound => 'Image introuvable';

  @override
  String get mediaPlayVideo => 'Lire la vidéo';

  @override
  String get mediaViewImage => 'Afficher l\'image';

  @override
  String mediaCount(Object count) {
    return '_PLACEHOLDER_0__ images';
  }

  @override
  String get mediaCountSingle => '1 image';

  @override
  String mediaMoreImages(Object count) {
    return 'Plus';
  }

  @override
  String get errorNotFound => 'Bip non trouvé';

  @override
  String get errorLoadError => 'Impossible de charger les détails du bip';

  @override
  String get shareYourThoughts => 'Partagez vos idées sur cette vue...';

  @override
  String get postComment => 'Commentaires';

  @override
  String get loggedInAs => 'Enclenchée comme';

  @override
  String get logout => 'Déconnexion';

  @override
  String get notFollowing => 'Ne pas suivre';

  @override
  String get follow => 'Suivre';

  @override
  String get navRecentBeeps => 'Abeilles récentes';

  @override
  String get navMap => 'Carte';

  @override
  String get navDownloadApp => 'Télécharger l\'application';

  @override
  String get alertLevel => 'Niveau d\'alerte';

  @override
  String get witnesses => 'Témoins';

  @override
  String get confirmations => 'Confirmations';

  @override
  String get reporterLabel => 'Signalé par l\'utilisateur';

  @override
  String get coordinatesLabel => 'Coordonnées';

  @override
  String get eventTime => 'Heure de l\'événement';

  @override
  String get reportedTime => 'Heure indiquée';

  @override
  String get addedToUfobeep => 'Ajouté à UFOBeep';

  @override
  String get mufonDatabaseReport => 'MUFON Numéro de cas:';

  @override
  String get copyShortLinkTitle => 'Copier le lien vers le presse-papiers';

  @override
  String get imageNotFound => 'Image introuvable';

  @override
  String get ufoSightingAlt => 'OVNI Alerte aux ovnis bip';

  @override
  String get celestialDataTitle => 'Objets célestes';

  @override
  String get visiblePlanets => 'Planètes visibles';

  @override
  String get locationDataTitle => 'Informations sur l\'emplacement';

  @override
  String get timezone => 'Fuseau horaire';

  @override
  String get coordinates => 'Coordonnées';

  @override
  String get processingSummaryTitle => 'Résumé du traitement';

  @override
  String get processingTime => 'Délai de traitement';

  @override
  String get successful => 'Réussi';

  @override
  String get failed => 'Échec';

  @override
  String get locationEnrichmentTitle => 'Détails de la localisation';

  @override
  String get aircraftDataSource => 'Source des données';

  @override
  String get noAircraftDetected => 'Aucun aéronef détecté';

  @override
  String get sightingReport => 'Rapport d\'observation';

  @override
  String get ufoAlert => 'OVNI Alerte';

  @override
  String get alert => 'Alerte';

  @override
  String get notificationTickerUfoAlert =>
      'Alerte ovni - Nouvelle vue à proximité';

  @override
  String get notificationTickerComment => 'Nouveau commentaire sur OVNI Alert';

  @override
  String get weatherConditions => 'Conditions météorologiques';

  @override
  String get visibility => 'Visibilité';

  @override
  String get humidity => 'Humidité';

  @override
  String get pressure => 'Pression';

  @override
  String get locationDetails => 'Détails de la localisation';

  @override
  String get city => 'Ville';

  @override
  String get state => 'État';

  @override
  String get country => 'Pays';

  @override
  String get satelliteActivity => 'Activité satellitaire';

  @override
  String get satellitesVisibleOverhead =>
      'Satellites visibles au-dessus à l\'heure d\'observation et l\'emplacement';

  @override
  String get dataSource => 'Source des données';

  @override
  String get blackskyImagery => 'Imagerie noire';

  @override
  String get resolution => 'Résolution';

  @override
  String get groundResolution => 'résolution au sol de 35cm';

  @override
  String get delivery => 'Livraison';

  @override
  String get averageDelivery => 'moyenne de 90 minutes';

  @override
  String get cost => 'Coût';

  @override
  String get skyfiSatelliteImagery => 'Satellite SkyFi Imagerie';

  @override
  String get region => 'Région';

  @override
  String get remoteArea => 'Zone éloignée';

  @override
  String get startingPrice => 'Prix de départ';

  @override
  String get coverage => 'Couverture';

  @override
  String get confidenceCoverage => '95% confiance';

  @override
  String get status => 'État';

  @override
  String get shareThoughts => 'Partagez vos idées sur cette vue...';

  @override
  String get postCommand => 'Poste de commandement';

  @override
  String get clouds => 'Nuages';

  @override
  String get windLabel => 'Vent';
}
