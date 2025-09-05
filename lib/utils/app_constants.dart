class AppConstants {
  // Noms des routes
  static const String homeRoute = '/';
  static const String lessonsRoute = '/lessons';
  static const String exercisesRoute = '/exercises';
  static const String progressionRoute = '/progression';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String userSelectionRoute = '/user-selection';

  // Noms des collections Firestore
  static const String usersCollection = 'users';
  static const String achievementsCollection = 'achievements';
  static const String lessonsCollection = 'lessons';
  static const String exercisesCollection = 'exercises';

  // IDs des utilisateurs de démonstration
  static const List<String> demoUserIds = [
    'demo_user_001',
    'demo_user_002',
    'demo_user_003',
    'demo_user_004',
    'demo_user_005',
    'demo_user_006',
    'demo_user_007',
    'demo_user_008',
    'demo_user_009',
    'demo_user_010',
  ];

  // Informations des utilisateurs de démonstration
  static const Map<String, Map<String, dynamic>> demoUserInfo = {
    'demo_user_001': {
      'displayName': 'QuranLearner',
      'bio': 'Passionné d\'apprentissage de l\'arabe',
      'level': 5,
      'xp': 1250,
      'streak': 7,
    },
    'demo_user_002': {
      'displayName': 'ArabicMaster',
      'bio': 'Expert en langue arabe',
      'level': 8,
      'xp': 3200,
      'streak': 15,
    },
    'demo_user_003': {
      'displayName': 'BeginnerStudent',
      'bio': 'Débutant enthousiaste',
      'level': 2,
      'xp': 450,
      'streak': 3,
    },
    'demo_user_004': {
      'displayName': 'IntermediateLearner',
      'bio': 'Apprenant intermédiaire',
      'level': 6,
      'xp': 1800,
      'streak': 10,
    },
    'demo_user_005': {
      'displayName': 'AdvancedStudent',
      'bio': 'Étudiant avancé en arabe',
      'level': 10,
      'xp': 4500,
      'streak': 22,
    },
    'demo_user_006': {
      'displayName': 'CasualLearner',
      'bio': 'Apprentissage occasionnel',
      'level': 3,
      'xp': 800,
      'streak': 2,
    },
    'demo_user_007': {
      'displayName': 'DedicatedStudent',
      'bio': 'Étudiant dévoué',
      'level': 7,
      'xp': 2800,
      'streak': 18,
    },
    'demo_user_008': {
      'displayName': 'WeekendWarrior',
      'bio': 'Étudie le weekend',
      'level': 3,
      'xp': 650,
      'streak': 1,
    },
    'demo_user_009': {
      'displayName': 'SpeedLearner',
      'bio': 'Apprend rapidement',
      'level': 9,
      'xp': 3800,
      'streak': 12,
    },
    'demo_user_010': {
      'displayName': 'ConsistentLearner',
      'bio': 'Apprentissage régulier',
      'level': 6,
      'xp': 2200,
      'streak': 14,
    },
  };

  // Noms des leçons
  static const List<String> lessonNames = [
    'Demonstrative Pronouns 1',
    'Basic Greetings',
    'Numbers 1-10',
    'Family Members',
    'Colors and Shapes',
    'Days of the Week',
    'Weather Expressions',
    'Food and Drinks',
    'Body Parts',
    'Clothing Items',
    'Transportation',
    'Professions',
    'Emotions',
    'Time Expressions',
    'Directions',
    'Shopping Phrases',
    'Restaurant Dialogues',
    'Travel Vocabulary',
    'Health and Wellness',
    'Technology Terms',
    'Sports and Hobbies',
    'Art and Culture',
    'Science Terms',
    'Business Vocabulary',
    'Academic Words',
    'Social Media Terms',
    'Environmental Terms',
    'Political Vocabulary',
    'Religious Terms',
    'Historical Words',
  ];

  // Noms des sections
  static const List<String> sectionNames = [
    'Basics',
    'Intermediate',
    'Advanced',
  ];

  // Limites des sections
  static const Map<String, int> sectionLimits = {
    'Basics': 5,
    'Intermediate': 15,
    'Advanced': 25,
  };

  // Types d'achievements
  static const List<String> achievementTypes = [
    'learning',
    'streak',
    'accuracy',
    'level',
    'study_time',
    'words',
  ];

  // Niveaux d'achievements
  static const List<String> achievementTiers = [
    'bronze',
    'silver',
    'gold',
    'platinum',
  ];

  // Langues supportées
  static const List<String> supportedLanguages = ['en', 'fr', 'ar'];
  
  static const Map<String, String> languageNames = {
    'en': 'English',
    'fr': 'Français',
    'ar': 'العربية',
  };

  // Messages d'erreur
  static const String errorUserNotFound = 'Utilisateur non trouvé';
  static const String errorLoadingUser = 'Erreur lors du chargement de l\'utilisateur';
  static const String errorDatabaseConnection = 'Erreur de connexion à la base de données';
  static const String errorUnknown = 'Une erreur inattendue s\'est produite';

  // Messages de succès
  static const String successUserLoaded = 'Utilisateur chargé avec succès';
  static const String successUserCreated = 'Utilisateur créé avec succès';
  static const String successDatabaseInitialized = 'Base de données initialisée avec succès';

  // Valeurs par défaut
  static const int defaultXP = 0;
  static const int defaultLevel = 1;
  static const int defaultStreak = 0;
  static const double defaultAccuracy = 0.0;
  static const int defaultStudyTime = 0;
  static const int defaultLessonsCompleted = 0;
  static const int defaultExercisesCompleted = 0;
  static const int defaultWordsLearned = 0;

  // Limites
  static const int maxLevel = 100;
  static const int maxStreak = 365;
  static const int maxAccuracy = 100;
  static const int xpPerLevel = 1000;
  static const int maxLessonsPerSection = 10;

  // Durées
  static const int sessionDurationMinutes = 30;
  static const int maxStudyTimePerDay = 480; // 8 heures
  static const int minStudyTimeForStreak = 15; // 15 minutes

  // Scores
  static const int perfectScore = 100;
  static const int goodScore = 80;
  static const int passingScore = 60;
  static const int minScore = 0;
}
