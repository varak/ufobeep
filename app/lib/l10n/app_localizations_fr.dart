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
    return '$distance loin';
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
    return 'Rapporté par _PH_0__';
  }

  @override
  String reportedAt(String timeAgo) {
    return 'Rapporté $timeAgo';
  }

  @override
  String distanceAway(String distance) {
    return '$distance loin';
  }

  @override
  String bearingToObject(int bearing) {
    return 'Roulement à l\'objet: $bearing°';
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
  String get noCommentsYet => 'Pas encore de commentaires. Soyez le premier !';

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
    return 'Pointage vers _PH_0__';
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
    return 'Vent: ${speed}_PH_1__';
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
  String get dndMode => 'Ne pas déranger';

  @override
  String get dndUntil => 'Ne pas déranger jusqu\'à';

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
  String get beepOnly => 'bip seulement';

  @override
  String get videoOnly => 'vidéo seulement';

  @override
  String get imageOnly => 'image seulement';

  @override
  String get timeJustNow => 'Juste maintenant';

  @override
  String timeDaysAgo(int count) {
    return '${count}d il y a';
  }

  @override
  String timeHoursAgo(int count) {
    return 'Il y a ${count}h';
  }

  @override
  String timeMinutesAgo(int count) {
    return 'Il y a ${count}m';
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
  String mufonCaseDetailsTitle(String caseNumber) {
    return 'MUFON Cas #__PH_0_ Détails';
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
  String get locationLabel => 'Lieu';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get timeLabel => 'Heure';

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
  String get ufoSighting => 'OVNI Vue';

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
    return 'MUFON Cas #$caseNumber';
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
}
