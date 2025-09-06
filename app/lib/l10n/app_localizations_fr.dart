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
  String get enablePushNotifications => 'Activer les notifications push';

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
}
