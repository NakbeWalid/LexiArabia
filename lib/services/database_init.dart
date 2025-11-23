import 'package:cloud_firestore/cloud_firestore.dart';
import 'srs_database_init.dart';

class DatabaseInit {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialiser la collection des achievements
  static Future<void> initializeAchievements() async {
    try {
      print('🚀 Initialisation de la collection achievements...');

      final achievements = [
        {
          'id': 'first_lesson',
          'name': 'Premier Pas',
          'description': 'Complétez votre première leçon',
          'icon': 'directions_walk',
          'category': 'learning',
          'requirements': {'type': 'lessons', 'value': 1, 'condition': '>='},
          'rewards': {'xp': 50, 'badge': 'first_lesson'},
          'tier': 'bronze',
        },
        {
          'id': 'streak_7_days',
          'name': 'Streak 7 jours',
          'description': 'Maintenez un streak de 7 jours consécutifs',
          'icon': 'local_fire_department',
          'category': 'streak',
          'requirements': {'type': 'streak', 'value': 7, 'condition': '>='},
          'rewards': {'xp': 100, 'badge': 'streak_7'},
          'tier': 'silver',
        },
        {
          'id': 'streak_30_days',
          'name': 'Streak 30 jours',
          'description': 'Maintenez un streak de 30 jours consécutifs',
          'icon': 'emoji_events',
          'category': 'streak',
          'requirements': {'type': 'streak', 'value': 30, 'condition': '>='},
          'rewards': {'xp': 500, 'badge': 'streak_30'},
          'tier': 'gold',
        },
        {
          'id': 'accuracy_80_plus',
          'name': 'Précision 80%+',
          'description': 'Atteignez une précision de 80% ou plus',
          'icon': 'track_changes',
          'category': 'accuracy',
          'requirements': {'type': 'accuracy', 'value': 80, 'condition': '>='},
          'rewards': {'xp': 200, 'badge': 'accuracy_80'},
          'tier': 'silver',
        },
        {
          'id': 'accuracy_100',
          'name': '100% Précision',
          'description': 'Atteignez une précision parfaite de 100%',
          'icon': 'star',
          'category': 'accuracy',
          'requirements': {'type': 'accuracy', 'value': 100, 'condition': '=='},
          'rewards': {'xp': 1000, 'badge': 'accuracy_100'},
          'tier': 'platinum',
        },
        {
          'id': 'five_lessons',
          'name': '5 leçons',
          'description': 'Complétez 5 leçons',
          'icon': 'school',
          'category': 'learning',
          'requirements': {'type': 'lessons', 'value': 5, 'condition': '>='},
          'rewards': {'xp': 150, 'badge': 'five_lessons'},
          'tier': 'bronze',
        },
        {
          'id': 'ten_lessons',
          'name': '10 leçons',
          'description': 'Complétez 10 leçons',
          'icon': 'school',
          'category': 'learning',
          'requirements': {'type': 'lessons', 'value': 10, 'condition': '>='},
          'rewards': {'xp': 300, 'badge': 'ten_lessons'},
          'tier': 'silver',
        },
        {
          'id': 'level_5',
          'name': 'Niveau 5',
          'description': 'Atteignez le niveau 5',
          'icon': 'emoji_events',
          'category': 'level',
          'requirements': {'type': 'level', 'value': 5, 'condition': '>='},
          'rewards': {'xp': 200, 'badge': 'level_5'},
          'tier': 'bronze',
        },
        {
          'id': 'level_10',
          'name': 'Niveau 10',
          'description': 'Atteignez le niveau 10',
          'icon': 'emoji_events',
          'category': 'level',
          'requirements': {'type': 'level', 'value': 10, 'condition': '>='},
          'rewards': {'xp': 500, 'badge': 'level_10'},
          'tier': 'silver',
        },
        {
          'id': 'study_time_1_hour',
          'name': '1 heure d\'étude',
          'description': 'Accumulez 1 heure de temps d\'étude',
          'icon': 'schedule',
          'category': 'study_time',
          'requirements': {
            'type': 'study_time',
            'value': 60,
            'condition': '>=',
          },
          'rewards': {'xp': 100, 'badge': 'study_1h'},
          'tier': 'bronze',
        },
        {
          'id': 'words_50',
          'name': '50 mots appris',
          'description': 'Apprenez 50 mots',
          'icon': 'translate',
          'category': 'words',
          'requirements': {'type': 'words', 'value': 50, 'condition': '>='},
          'rewards': {'xp': 150, 'badge': 'words_50'},
          'tier': 'bronze',
        },
        {
          'id': 'words_100',
          'name': '100 mots appris',
          'description': 'Apprenez 100 mots',
          'icon': 'translate',
          'category': 'words',
          'requirements': {'type': 'words', 'value': 100, 'condition': '>='},
          'rewards': {'xp': 300, 'badge': 'words_100'},
          'tier': 'silver',
        },
      ];

      for (final achievement in achievements) {
        final id = achievement['id'] as String;
        await _firestore.collection('achievements').doc(id).set(achievement);
        print('✅ Achievement ajouté: $id');
      }

      print('🎉 Collection achievements initialisée avec succès !');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation des achievements: $e');
    }
  }

  // Créer plusieurs utilisateurs de démonstration
  static Future<void> createDemoUsers() async {
    try {
      print('🚀 Création de plusieurs utilisateurs de démonstration...');

      final now = FieldValue.serverTimestamp();

      // Liste des utilisateurs de démonstration
      final demoUsers = [
        {
          'id': 'demo_user_001',
          'username': 'QuranLearner',
          'email': 'demo1@dualingocoran.com',
          'displayName': 'Quran Learner',
          'bio': 'Passionné d\'apprentissage de l\'arabe',
          'nativeLanguage': 'en',
          'stats': {
            'totalXP': 1250,
            'currentLevel': 5,
            'currentStreak': 7,
            'bestStreak': 12,
            'lessonsCompleted': 8,
            'totalLessons': 15,
            'exercisesCompleted': 156,
            'wordsLearned': 89,
            'accuracy': 87.5,
            'totalStudyTime': 165,
          },
          'achievements': [
            'first_lesson',
            'streak_7_days',
            'accuracy_80_plus',
            'five_lessons',
            'level_5',
            'study_time_1_hour',
            'words_50',
          ],
        },
        {
          'id': 'demo_user_002',
          'username': 'ArabicMaster',
          'email': 'demo2@dualingocoran.com',
          'displayName': 'Arabic Master',
          'bio': 'Expert en langue arabe',
          'nativeLanguage': 'fr',
          'stats': {
            'totalXP': 3200,
            'currentLevel': 8,
            'currentStreak': 15,
            'bestStreak': 25,
            'lessonsCompleted': 22,
            'totalLessons': 30,
            'exercisesCompleted': 450,
            'wordsLearned': 200,
            'accuracy': 94.2,
            'totalStudyTime': 480,
          },
          'achievements': [
            'first_lesson',
            'streak_7_days',
            'streak_30_days',
            'accuracy_80_plus',
            'accuracy_100',
            'five_lessons',
            'ten_lessons',
            'level_5',
            'level_10',
            'study_time_1_hour',
            'words_50',
            'words_100',
          ],
        },
        {
          'id': 'demo_user_003',
          'username': 'BeginnerStudent',
          'email': 'demo3@dualingocoran.com',
          'displayName': 'Beginner Student',
          'bio': 'Débutant enthousiaste',
          'nativeLanguage': 'ar',
          'stats': {
            'totalXP': 450,
            'currentLevel': 2,
            'currentStreak': 3,
            'bestStreak': 5,
            'lessonsCompleted': 3,
            'totalLessons': 15,
            'exercisesCompleted': 45,
            'wordsLearned': 25,
            'accuracy': 78.5,
            'totalStudyTime': 60,
          },
          'achievements': ['first_lesson', 'five_lessons'],
        },
        {
          'id': 'demo_user_004',
          'username': 'IntermediateLearner',
          'email': 'demo4@dualingocoran.com',
          'displayName': 'Intermediate Learner',
          'bio': 'Apprenant intermédiaire',
          'nativeLanguage': 'en',
          'stats': {
            'totalXP': 1800,
            'currentLevel': 6,
            'currentStreak': 10,
            'bestStreak': 18,
            'lessonsCompleted': 15,
            'totalLessons': 25,
            'exercisesCompleted': 280,
            'wordsLearned': 120,
            'accuracy': 89.1,
            'totalStudyTime': 320,
          },
          'achievements': [
            'first_lesson',
            'streak_7_days',
            'accuracy_80_plus',
            'five_lessons',
            'ten_lessons',
            'level_5',
            'study_time_1_hour',
            'words_50',
          ],
        },
        {
          'id': 'demo_user_005',
          'username': 'AdvancedStudent',
          'email': 'demo5@dualingocoran.com',
          'displayName': 'Advanced Student',
          'bio': 'Étudiant avancé en arabe',
          'nativeLanguage': 'fr',
          'stats': {
            'totalXP': 4500,
            'currentLevel': 10,
            'currentStreak': 22,
            'bestStreak': 35,
            'lessonsCompleted': 28,
            'totalLessons': 35,
            'exercisesCompleted': 600,
            'wordsLearned': 280,
            'accuracy': 96.8,
            'totalStudyTime': 720,
          },
          'achievements': [
            'first_lesson',
            'streak_7_days',
            'streak_30_days',
            'accuracy_80_plus',
            'accuracy_100',
            'five_lessons',
            'ten_lessons',
            'level_5',
            'level_10',
            'study_time_1_hour',
            'words_50',
            'words_100',
          ],
        },
        {
          'id': 'demo_user_006',
          'username': 'CasualLearner',
          'email': 'demo6@dualingocoran.com',
          'displayName': 'Casual Learner',
          'bio': 'Apprentissage occasionnel',
          'nativeLanguage': 'en',
          'stats': {
            'totalXP': 800,
            'currentLevel': 3,
            'currentStreak': 2,
            'bestStreak': 8,
            'lessonsCompleted': 6,
            'totalLessons': 20,
            'exercisesCompleted': 120,
            'wordsLearned': 60,
            'accuracy': 82.3,
            'totalStudyTime': 180,
          },
          'achievements': [
            'first_lesson',
            'five_lessons',
            'level_5',
            'words_50',
          ],
        },
        {
          'id': 'demo_user_007',
          'username': 'DedicatedStudent',
          'email': 'demo7@dualingocoran.com',
          'displayName': 'Dedicated Student',
          'bio': 'Étudiant dévoué',
          'nativeLanguage': 'ar',
          'stats': {
            'totalXP': 2800,
            'currentLevel': 7,
            'currentStreak': 18,
            'bestStreak': 28,
            'lessonsCompleted': 20,
            'totalLessons': 28,
            'exercisesCompleted': 380,
            'wordsLearned': 180,
            'accuracy': 91.5,
            'totalStudyTime': 420,
          },
          'achievements': [
            'first_lesson',
            'streak_7_days',
            'streak_30_days',
            'accuracy_80_plus',
            'five_lessons',
            'ten_lessons',
            'level_5',
            'level_10',
            'study_time_1_hour',
            'words_50',
            'words_100',
          ],
        },
        {
          'id': 'demo_user_008',
          'username': 'WeekendWarrior',
          'email': 'demo8@dualingocoran.com',
          'displayName': 'Weekend Warrior',
          'bio': 'Étudie le weekend',
          'nativeLanguage': 'fr',
          'stats': {
            'totalXP': 650,
            'currentLevel': 3,
            'currentStreak': 1,
            'bestStreak': 6,
            'lessonsCompleted': 5,
            'totalLessons': 18,
            'exercisesCompleted': 85,
            'wordsLearned': 40,
            'accuracy': 79.8,
            'totalStudyTime': 120,
          },
          'achievements': ['first_lesson', 'five_lessons'],
        },
        {
          'id': 'demo_user_009',
          'username': 'SpeedLearner',
          'email': 'demo9@dualingocoran.com',
          'displayName': 'Speed Learner',
          'bio': 'Apprend rapidement',
          'nativeLanguage': 'en',
          'stats': {
            'totalXP': 3800,
            'currentLevel': 9,
            'currentStreak': 12,
            'bestStreak': 20,
            'lessonsCompleted': 25,
            'totalLessons': 32,
            'exercisesCompleted': 520,
            'wordsLearned': 250,
            'accuracy': 93.7,
            'totalStudyTime': 600,
          },
          'achievements': [
            'first_lesson',
            'streak_7_days',
            'accuracy_80_plus',
            'five_lessons',
            'ten_lessons',
            'level_5',
            'level_10',
            'study_time_1_hour',
            'words_50',
            'words_100',
          ],
        },
        {
          'id': 'demo_user_010',
          'username': 'ConsistentLearner',
          'email': 'demo10@dualingocoran.com',
          'displayName': 'Consistent Learner',
          'bio': 'Apprentissage régulier',
          'nativeLanguage': 'fr',
          'stats': {
            'totalXP': 2200,
            'currentLevel': 6,
            'currentStreak': 14,
            'bestStreak': 22,
            'lessonsCompleted': 18,
            'totalLessons': 26,
            'exercisesCompleted': 320,
            'wordsLearned': 150,
            'accuracy': 88.9,
            'totalStudyTime': 380,
          },
          'achievements': [
            'first_lesson',
            'streak_7_days',
            'accuracy_80_plus',
            'five_lessons',
            'ten_lessons',
            'level_5',
            'study_time_1_hour',
            'words_50',
          ],
        },
      ];

      // Créer chaque utilisateur
      for (final userData in demoUsers) {
        final userId = userData['id'] as String;
        final username = userData['username'] as String;
        final email = userData['email'] as String;
        final displayName = userData['displayName'] as String;
        final bio = userData['bio'] as String;
        final nativeLanguage = userData['nativeLanguage'] as String;
        final stats = userData['stats'] as Map<String, dynamic>;
        final achievementIds = userData['achievements'] as List<String>;

        // Créer les achievements de l'utilisateur
        final achievements = <String, dynamic>{};
        for (final achievementId in achievementIds) {
          achievements[achievementId] = {
            'unlocked': true,
            'unlockedAt': now,
            'progress': 100,
          };
        }

        // Créer la progression des leçons
        final lessonsProgress = <String, dynamic>{};
        final lessonsCompleted = stats['lessonsCompleted'] as int;
        final lessonNames = [
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

        for (int i = 0; i < lessonsCompleted; i++) {
          if (i < lessonNames.length) {
            lessonsProgress[lessonNames[i]] = {
              'completed': true,
              'completedAt': now,
              'score': 80 + (i * 2), // Score progressif
              'attempts': 1,
              'bestScore': 80 + (i * 2),
            };
          }
        }

        // Créer les sections de progression
        final sectionsProgress = <String, dynamic>{
          'Basics': {
            'completed': lessonsCompleted >= 5,
            'completedAt': lessonsCompleted >= 5 ? now : null,
            'lessonsCompleted': lessonsCompleted >= 5 ? 5 : lessonsCompleted,
            'totalLessons': 5,
          },
          'Intermediate': {
            'completed': lessonsCompleted >= 15,
            'completedAt': lessonsCompleted >= 15 ? now : null,
            'lessonsCompleted': lessonsCompleted >= 15
                ? 10
                : (lessonsCompleted > 5 ? lessonsCompleted - 5 : 0),
            'totalLessons': 10,
          },
          'Advanced': {
            'completed': lessonsCompleted >= 25,
            'completedAt': lessonsCompleted >= 25 ? now : null,
            'lessonsCompleted': lessonsCompleted >= 25
                ? 10
                : (lessonsCompleted > 15 ? lessonsCompleted - 15 : 0),
            'totalLessons': 10,
          },
        };

        // Créer les sessions d'étude
        final studySessions = <Map<String, dynamic>>[];
        final totalStudyTime = stats['totalStudyTime'] as int;
        final sessionCount = (totalStudyTime / 30)
            .ceil(); // Une session toutes les 30 minutes

        for (int i = 0; i < sessionCount; i++) {
          studySessions.add({
            'sessionId': 'session_${userId}_$i',
            'startedAt': now,
            'endedAt': now,
            'duration': 30,
            'lessonsStudied': lessonNames.take(3).toList(),
            'exercisesCompleted': (stats['exercisesCompleted'] / sessionCount)
                .round(),
            'xpEarned': (stats['totalXP'] / sessionCount).round(),
          });
        }

        // Créer la progression quotidienne
        final dailyProgress = <String, dynamic>{
          '2024-01-15': {
            'lessonsCompleted': (lessonsCompleted / 7).ceil(),
            'exercisesCompleted': (stats['exercisesCompleted'] / 7).ceil(),
            'xpEarned': (stats['totalXP'] / 7).ceil(),
            'studyTime': (totalStudyTime / 7).ceil(),
            'streakMaintained': true,
          },
        };

        // Créer l'utilisateur complet
        final userDataComplete = {
          'profile': {
            'username': username,
            'email': email,
            'avatarUrl': '',
            'displayName': displayName,
            'bio': bio,
            'nativeLanguage': nativeLanguage,
            'learningLanguage': 'ar',
            'createdAt': now,
            'lastActive': now,
          },
          'stats': stats,
          'progress': {
            'lessons': lessonsProgress,
            'sections': sectionsProgress,
          },
          'achievements': achievements,
          'studySessions': studySessions,
          'dailyProgress': dailyProgress,
        };

        await _firestore.collection('users').doc(userId).set(userDataComplete);
        print('✅ Utilisateur créé: $username (ID: $userId)');
      }

      print(
        '🎉 ${demoUsers.length} utilisateurs de démonstration créés avec succès !',
      );
      print('📱 IDs utilisateurs disponibles:');
      for (final user in demoUsers) {
        print('   - ${user['id']}: ${user['username']}');
      }
    } catch (e) {
      print(
        '❌ Erreur lors de la création des utilisateurs de démonstration: $e',
      );
    }
  }

  // Initialiser complètement la base de données
  static Future<void> initializeDatabase() async {
    try {
      print('🚀 Initialisation complète de la base de données...');

      await initializeAchievements();
      await createDemoUsers();

      // Initialiser les collections SRS pour tous les utilisateurs
      try {
        await SRSDatabaseInit.initializeSRSForAllUsers();
      } catch (e) {
        print('⚠️ Erreur lors de l\'initialisation SRS (non bloquant): $e');
      }

      print('🎉 Base de données initialisée avec succès !');
      print('📊 Collections créées:');
      print(
        '   - achievements (${await _getCollectionCount('achievements')} documents)',
      );
      print('   - users (${await _getCollectionCount('users')} documents)');
      print('   - lessons (${await _getCollectionCount('lessons')} documents)');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation de la base de données: $e');
    }
  }

  // Compter les documents dans une collection
  static Future<int> _getCollectionCount(String collectionName) async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
