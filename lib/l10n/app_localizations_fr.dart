// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'LexiArabia';

  @override
  String get roadmap => 'Parcours';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get progression => 'Progression';

  @override
  String get exercises => 'Exercices';

  @override
  String get lessons => 'Leçons';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'Arabe';

  @override
  String get newWordsToLearn => 'Nouveaux mots à apprendre';

  @override
  String get startLesson => 'Commencer la leçon';

  @override
  String get description => 'Description';

  @override
  String get example => 'Exemple';

  @override
  String get noLessonsFound => 'Aucune leçon trouvée';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get retry => 'Réessayer';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get lesson => 'Leçon';

  @override
  String get section => 'Section';

  @override
  String get question => 'Question';

  @override
  String get answer => 'Réponse';

  @override
  String get options => 'Options';

  @override
  String get submit => 'Soumettre';

  @override
  String get correct => 'Correct !';

  @override
  String get incorrect => 'Incorrect !';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get continue_lesson => 'Continuer';

  @override
  String get finish => 'Terminer';

  @override
  String get score => 'Score';

  @override
  String get progress => 'Progression';

  @override
  String get completed => 'Terminé';

  @override
  String get inProgress => 'En cours';

  @override
  String get notStarted => 'Non commencé';

  @override
  String get totalXP => 'XP Total';

  @override
  String get currentStreak => 'Streak actuel';

  @override
  String get bestStreak => 'Meilleur streak';

  @override
  String get accuracy => 'Précision';

  @override
  String get lessonsCompleted => 'Leçons terminées';

  @override
  String get totalLessons => 'Total des leçons';

  @override
  String get lessonProgress => 'Progression des leçons';

  @override
  String get badgesAndAchievements => 'Badges & Accomplissements';

  @override
  String get detailedStats => 'Statistiques détaillées';

  @override
  String get totalStudyTime => 'Temps total d\'étude';

  @override
  String get exercisesCompleted => 'Exercices complétés';

  @override
  String get wordsLearned => 'Mots appris';

  @override
  String get studySessions => 'Sessions d\'étude';

  @override
  String get activeDays => 'Jours actifs';

  @override
  String get firstStep => 'Premier Pas';

  @override
  String get streak7Days => 'Streak 7 jours';

  @override
  String get accuracy80Plus => 'Précision 80%+';

  @override
  String get fiveLessons => '5 leçons';

  @override
  String get streak30Days => 'Streak 30 jours';

  @override
  String get hundredPercentAccuracy => '100% Précision';

  @override
  String get days => 'jours';

  @override
  String get percent => '%';

  @override
  String get descriptionLabel => 'Description :';

  @override
  String get exampleLabel => 'Exemple :';

  @override
  String get unknownWord => 'Mot inconnu';

  @override
  String get translationNotAvailable => 'Traduction non disponible';

  @override
  String get descriptionNotAvailable => 'Description non disponible';

  @override
  String get exampleNotAvailable => 'Exemple non disponible';

  @override
  String get unknown => 'Inconnu';

  @override
  String get continueButton => 'Continuer';

  @override
  String get streakDays => 'jours';

  @override
  String get completedLabel => 'complété';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get sound => 'Son';

  @override
  String get enableSound => 'Activer le son';

  @override
  String get userSelection => 'Sélection d\'Utilisateur';

  @override
  String get chooseDemoProfile => 'Choisissez un profil de démonstration';

  @override
  String get cancel => 'Annuler';

  @override
  String get understood => 'Compris';

  @override
  String get errorGeneric => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String errorWithDetails(String details) {
    return 'Une erreur est survenue : $details';
  }

  @override
  String get sectionDescBasics => 'Fondamentaux de la langue arabe';

  @override
  String get sectionDescPronouns => 'Pronoms et références';

  @override
  String get sectionDescGrammar => 'Règles grammaticales';

  @override
  String get sectionDescVocabulary => 'Vocabulaire essentiel';

  @override
  String get sectionDescConversation => 'Dialogues et expressions';

  @override
  String get sectionDescCulture => 'Culture et traditions';

  @override
  String get sectionDescReligion => 'Termes religieux';

  @override
  String get sectionDescAdvanced => 'Niveau avancé';

  @override
  String get sectionDescDefault => 'Apprentissage progressif';

  @override
  String get lessonLockedTitle => 'Leçon verrouillée';

  @override
  String get lessonLockedMessage =>
      'Termine la leçon précédente pour débloquer celle-ci.';

  @override
  String get loadLessonsError =>
      'Impossible de charger les leçons. Vérifie ta connexion.';

  @override
  String get roadmapWelcomeTitle => 'Bienvenue dans votre parcours !';

  @override
  String get roadmapWelcomeSubtitle =>
      'Commencez à apprendre les mots du Coran';

  @override
  String get lessonAlreadyCompletedTitle => 'Leçon déjà complétée';

  @override
  String get lessonAlreadyCompletedMessage =>
      'Vous avez déjà complété cette leçon.\nVoulez-vous la refaire ?';

  @override
  String get redo => 'Refaire';

  @override
  String unknownExerciseType(String type) {
    return 'Type d\'exercice inconnu : $type';
  }

  @override
  String get invalidExerciseData => 'Cet exercice ne peut pas être affiché.';

  @override
  String get noExercisesAvailable => 'Aucun exercice disponible';

  @override
  String get trueLabel => 'Vrai';

  @override
  String get falseLabel => 'Faux';

  @override
  String get chooseCorrectAnswer => 'Choisissez la bonne réponse';

  @override
  String get trueOrFalseHint => 'Cette affirmation est-elle vraie ou fausse ?';

  @override
  String get listenToAudio => 'Écoutez l\'audio';

  @override
  String get playAudio => 'Écouter la prononciation';

  @override
  String get audioUnavailable =>
      'Audio indisponible pour ce mot sur cet appareil.';

  @override
  String get chooseWhatYouHeard => 'Choisissez ce que vous avez entendu';

  @override
  String get completeTheSentence => 'Complétez la phrase :';

  @override
  String get dragTheCorrectWord => 'Glissez ou touchez le bon mot :';

  @override
  String get matchThePairs => 'Associez les paires';

  @override
  String get feedbackCorrect1 => 'Excellent !';

  @override
  String get feedbackCorrect2 => 'Bravo !';

  @override
  String get feedbackCorrect3 => 'Parfait !';

  @override
  String get feedbackIncorrect => 'Pas tout à fait…';

  @override
  String get correctAnswerLabel => 'Bonne réponse :';

  @override
  String get feedbackRetryLater => 'Tu reverras cette question à la fin.';

  @override
  String get quitSessionTitle => 'Quitter ?';

  @override
  String get quitSessionMessage =>
      'Ta progression dans cette session sera perdue.';

  @override
  String get quit => 'Quitter';

  @override
  String get keepLearning => 'Continuer';

  @override
  String get soundOn => 'Activer le son';

  @override
  String get soundOff => 'Désactiver le son';

  @override
  String get lessonCompleteTitle => 'Excellent travail !';

  @override
  String get lessonCompleteMessage =>
      'Vous avez terminé tous les exercices de cette leçon ! 🎉';

  @override
  String get xpEarned => 'XP gagnés';

  @override
  String get streakLabel => 'Série';

  @override
  String get srsIntroTitle => 'C\'est l\'heure de réviser vos mots ! 🚀';

  @override
  String srsIntroSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count mots à réviser — une courte session pour ancrer vos connaissances.',
      one:
          '1 mot à réviser — une courte session pour ancrer vos connaissances.',
    );
    return '$_temp0';
  }

  @override
  String get startReview => 'Commencer';

  @override
  String get srsDoneTitle => 'Super travail ! 🎉';

  @override
  String get srsDoneMessage =>
      'Vous avez terminé toutes vos révisions pour aujourd\'hui !';

  @override
  String get srsEmptyTitle => 'Aucune révision pour aujourd\'hui ! 🎉';

  @override
  String get srsEmptyMessage => 'Revenez demain pour consolider vos acquis';

  @override
  String get srsReviewTitle => 'Révisions';

  @override
  String exercisesToReview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercices à réviser',
      one: '1 exercice à réviser',
    );
    return '$_temp0';
  }

  @override
  String get noReviewsToday => 'Aucune révision aujourd\'hui';

  @override
  String get dailyLimitTitle => 'Limite quotidienne atteinte';

  @override
  String dailyLimitMessage(int completed, int limit) {
    return 'Vous avez complété $completed/$limit leçons aujourd\'hui.';
  }

  @override
  String get dailyLimitComeBack =>
      'Revenez demain pour continuer votre apprentissage !';

  @override
  String get account => 'Compte';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutSubtitle => 'Vous pourrez vous reconnecter à tout moment.';

  @override
  String get signOutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get dailyReminder => 'Rappel quotidien';

  @override
  String get dailyReminderSubtitle => 'Une notification pour garder ta série';

  @override
  String get notificationsUnsupported =>
      'Disponible uniquement sur l\'application mobile';

  @override
  String get reminderTime => 'Heure du rappel';

  @override
  String reminderScheduled(String time) {
    return 'Rappel programmé tous les jours à $time';
  }

  @override
  String get notificationPermissionDenied =>
      'Les notifications sont bloquées. Autorise-les dans les réglages du téléphone.';

  @override
  String get reminderNotificationTitle => 'C\'est l\'heure d\'apprendre ! 📖';

  @override
  String get reminderNotificationBody =>
      'Quelques minutes aujourd\'hui pour apprendre de nouveaux mots du Coran.';

  @override
  String get reminderChannelName => 'Rappels quotidiens';

  @override
  String get congratulations => 'Félicitations !';

  @override
  String get youProgressed => 'Vous avez progressé !';

  @override
  String get learningProgress => 'Progression d\'apprentissage';

  @override
  String get before => 'Avant';

  @override
  String get added => 'Ajouté';

  @override
  String get now => 'Maintenant';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginWelcome => 'Bienvenue sur LexiArabia';

  @override
  String get signupTitle => 'Créer un compte';

  @override
  String get signupWelcome => 'Rejoignez LexiArabia';

  @override
  String get nameLabel => 'Nom';

  @override
  String get nameHint => 'Votre nom';

  @override
  String get enterName => 'Veuillez entrer votre nom';

  @override
  String get nameTooShort => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'exemple@email.com';

  @override
  String get enterEmail => 'Veuillez entrer votre email';

  @override
  String get invalidEmail => 'Email invalide';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get enterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get enterNewPassword => 'Veuillez entrer un mot de passe';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get confirmPassword => 'Veuillez confirmer le mot de passe';

  @override
  String get passwordsDontMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get createMyAccount => 'Créer mon compte';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get noAccountYet => 'Pas encore de compte ? ';

  @override
  String get alreadyHaveAccount => 'Déjà un compte ? ';

  @override
  String get authUserNotFound => 'Aucun compte trouvé avec cet email.';

  @override
  String get authWrongPassword => 'Mot de passe incorrect.';

  @override
  String get authUserDisabled => 'Ce compte a été désactivé.';

  @override
  String get authTooManyRequests => 'Trop de tentatives. Réessayez plus tard.';

  @override
  String get authOperationNotAllowed => 'Opération non autorisée.';

  @override
  String get authSignInCanceled => 'La connexion a été annulée.';

  @override
  String get authGoogleFailed =>
      'Échec de la connexion Google. Vérifiez votre configuration.';

  @override
  String get authNetworkError =>
      'Erreur de réseau. Vérifiez votre connexion internet.';

  @override
  String get authGoogleError => 'Erreur lors de la connexion Google.';

  @override
  String get authAccountExistsDifferentCredential =>
      'Un compte existe déjà avec cet email mais avec un autre moyen de connexion.';

  @override
  String get authInvalidCredential =>
      'Les identifiants fournis sont invalides.';

  @override
  String get authUnknownError => 'Une erreur inattendue s\'est produite.';

  @override
  String get authEmailInUse => 'Cet email est déjà utilisé.';

  @override
  String get authWeakPassword => 'Le mot de passe est trop faible.';

  @override
  String get onboarding1Title => 'Bienvenue sur LexiArabia';

  @override
  String get onboarding1Subtitle => 'Votre mission';

  @override
  String get onboarding1Description =>
      'Apprenez l\'arabe en maîtrisant les mots les plus fréquents du Coran. Notre objectif : vous permettre de comprendre 80% du texte sacré.';

  @override
  String get onboarding1Feature1 => 'Maîtrisez les mots essentiels du Coran';

  @override
  String get onboarding1Feature2 =>
      'Apprenez à votre rythme avec des leçons progressives';

  @override
  String get onboarding1Feature3 => 'Suivez votre progression en temps réel';

  @override
  String get onboarding1Feature4 =>
      'Gagnez des récompenses en complétant les défis';

  @override
  String get onboarding2Title => 'Comment ça marche ?';

  @override
  String get onboarding2Subtitle => 'Apprendre 80% des mots du Coran';

  @override
  String get onboarding2Description =>
      'En apprenant seulement les 200 mots les plus fréquents du Coran, vous pourrez comprendre environ 80% du texte. C\'est notre méthode éprouvée.';

  @override
  String get onboarding2Feature1 => '200 mots = 80% de compréhension';

  @override
  String get onboarding2Feature2 => 'Leçons structurées par thème';

  @override
  String get onboarding2Feature3 => 'Exercices interactifs variés';

  @override
  String get onboarding2Feature4 =>
      'Répétition espacée pour une mémorisation durable';

  @override
  String get onboarding3Title => 'Progression et récompenses';

  @override
  String get onboarding3Subtitle => 'Restez motivé';

  @override
  String get onboarding3Description =>
      'Suivez votre avancement, débloquez des badges et célébrez chaque étape de votre apprentissage. Chaque leçon complétée vous rapproche de votre objectif.';

  @override
  String get onboarding3Feature1 => 'Suivi détaillé de votre progression';

  @override
  String get onboarding3Feature2 => 'Badges et récompenses à débloquer';

  @override
  String get onboarding3Feature3 => 'Statistiques de vos performances';

  @override
  String get onboarding3Feature4 =>
      'Rappels quotidiens pour garder votre rythme';

  @override
  String get skip => 'Passer';

  @override
  String get start => 'Commencer';

  @override
  String get defaultUserName => 'Apprenant';

  @override
  String get level => 'Niveau';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String percentCompleted(int percent) {
    return '$percent% terminé';
  }

  @override
  String get noLessonsAvailable => 'Aucune leçon disponible';

  @override
  String get achievements => 'Succès';

  @override
  String get achFirstLesson => 'Première leçon';

  @override
  String get ach100Xp => '100 XP';

  @override
  String get ach7DayStreak => 'Série de 7 jours';

  @override
  String get achQuickLearner => 'Apprenti rapide';

  @override
  String get achExpert => 'Expert';
}
