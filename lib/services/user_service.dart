import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dualingocoran/services/srs_database_init.dart';

// Fonction helper pour formater la date (utilisée pour dailyProgress)
String _getDateString(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';
  static const String _achievementsCollection = 'achievements';

  // Récupérer les données d'un utilisateur
  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Erreur lors de la récupération des données utilisateur: $e');
      return null;
    }
  }

  // Récupérer les statistiques d'un utilisateur
  static Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      final userData = await getUserData(userId);
      if (userData != null && userData['stats'] != null) {
        return userData['stats'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Erreur lors de la récupération des stats utilisateur: $e');
      return null;
    }
  }

  // Récupérer la progression d'un utilisateur
  static Future<Map<String, dynamic>?> getUserProgress(String userId) async {
    try {
      final userData = await getUserData(userId);
      if (userData != null && userData['progress'] != null) {
        return userData['progress'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Erreur lors de la récupération de la progression: $e');
      return null;
    }
  }

  // Récupérer les achievements d'un utilisateur
  static Future<Map<String, dynamic>?> getUserAchievements(
    String userId,
  ) async {
    try {
      final userData = await getUserData(userId);
      if (userData != null && userData['achievements'] != null) {
        return userData['achievements'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Erreur lors de la récupération des achievements: $e');
      return null;
    }
  }

  // Récupérer tous les achievements disponibles
  static Future<List<Map<String, dynamic>>> getAllAchievements() async {
    try {
      final snapshot = await _firestore
          .collection(_achievementsCollection)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Erreur lors de la récupération des achievements: $e');
      return [];
    }
  }

  // Mettre à jour les statistiques d'un utilisateur
  static Future<void> updateUserStats(
    String userId,
    Map<String, dynamic> stats,
  ) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'stats': stats,
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erreur lors de la mise à jour des stats: $e');
    }
  }

  // Ajouter de l'XP à un utilisateur
  static Future<void> addXP(String userId, int xpToAdd) async {
    try {
      final userRef = _firestore.collection(_usersCollection).doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (userDoc.exists) {
          final currentXP = userDoc.data()?['stats']?['totalXP'] ?? 0;
          final newXP = currentXP + xpToAdd;
          final newLevel = (newXP / 1000).floor() + 1;

          transaction.update(userRef, {
            'stats.totalXP': newXP,
            'stats.currentLevel': newLevel,
            'lastActive': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('❌ Erreur lors de l\'ajout d\'XP: $e');
    }
  }

  // Mettre à jour le streak d'un utilisateur
  static Future<void> updateStreak(String userId, bool maintained) async {
    try {
      final userRef = _firestore.collection(_usersCollection).doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (userDoc.exists) {
          final currentStreak = userDoc.data()?['stats']?['currentStreak'] ?? 0;
          final bestStreak = userDoc.data()?['stats']?['bestStreak'] ?? 0;

          int newStreak = maintained ? currentStreak + 1 : 0;
          int newBestStreak = newStreak > bestStreak ? newStreak : bestStreak;

          transaction.update(userRef, {
            'stats.currentStreak': newStreak,
            'stats.bestStreak': newBestStreak,
            'lastActive': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du streak: $e');
    }
  }

  // Marquer une leçon comme terminée
  static Future<void> completeLesson(
    String userId,
    String lessonId,
    int score, {
    int? xpReward,
  }) async {
    try {
      print(
        '🔄 Début de complétion de la leçon: $lessonId pour l\'utilisateur: $userId',
      );
      final userRef = _firestore.collection(_usersCollection).doc(userId);

      // Calculer l'XP basé sur le score (par défaut 100 XP pour une leçon complétée)
      // Plus le score est élevé, plus l'XP est élevé (50-150 XP)
      final xpToAdd =
          xpReward ?? (50 + (score * 100 / 100).round()).clamp(50, 150);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final lessonsCompleted = userData['stats']?['lessonsCompleted'] ?? 0;
          final currentXP = userData['stats']?['totalXP'] ?? 0;
          final newXP = currentXP + xpToAdd;
          final newLevel = (newXP / 1000).floor() + 1;

          print('📊 Stats actuelles - lessonsCompleted: $lessonsCompleted');
          print(
            '📊 XP actuel: $currentXP, XP à ajouter: $xpToAdd, Nouveau XP: $newXP',
          );
          print(
            '📊 Progress.lessons avant: ${userData['progress']?['lessons']}',
          );

          // Préparer la mise à jour
          final updateData = <String, dynamic>{
            'stats.lessonsCompleted': lessonsCompleted + 1,
            'stats.totalXP': newXP,
            'stats.currentLevel': newLevel,
            'progress.lessons.$lessonId.completed': true,
            'progress.lessons.$lessonId.completedAt':
                FieldValue.serverTimestamp(),
            'progress.lessons.$lessonId.score': score,
            'progress.lessons.$lessonId.attempts': FieldValue.increment(1),
            'lastActive': FieldValue.serverTimestamp(),
          };

          // S'assurer que progress.lessons existe si nécessaire
          final progress = userData['progress'] as Map<String, dynamic>?;
          if (progress == null || !progress.containsKey('lessons')) {
            print('⚠️ progress.lessons n\'existe pas, initialisation...');
            updateData['progress.lessons'] = {};
          }

          transaction.update(userRef, updateData);

          print(
            '✅ Transaction préparée pour mettre à jour progress.lessons.$lessonId avec +$xpToAdd XP',
          );
        } else {
          print('❌ Document utilisateur non trouvé: $userId');
        }
      });

      // Vérifier que la mise à jour a bien été effectuée
      final updatedDoc = await userRef.get();
      if (updatedDoc.exists) {
        final updatedData = updatedDoc.data()!;
        final progressLessons =
            updatedData['progress']?['lessons'] as Map<String, dynamic>?;
        print(
          '✅ Vérification après mise à jour - progress.lessons: $progressLessons',
        );
        if (progressLessons != null && progressLessons.containsKey(lessonId)) {
          print('✅ La leçon $lessonId est bien dans progress.lessons');
        } else {
          print('❌ La leçon $lessonId n\'est PAS dans progress.lessons');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Erreur lors de la complétion de la leçon: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  // Créer un nouvel utilisateur
  static Future<void> createUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final now = FieldValue.serverTimestamp();

      await _firestore.collection(_usersCollection).doc(userId).set({
        'profile': {
          'username': userData['username'] ?? 'User',
          'email': userData['email'] ?? '',
          'avatarUrl': userData['avatarUrl'] ?? '',
          'displayName':
              userData['displayName'] ?? userData['username'] ?? 'User',
          'bio': userData['bio'] ?? '',
          'nativeLanguage': userData['nativeLanguage'] ?? 'en',
          'learningLanguage': 'ar',
          'createdAt': now,
          'lastActive': now,
        },
        'stats': {
          'totalXP': 0,
          'currentLevel': 1,
          'currentStreak': 0,
          'bestStreak': 0,
          'lessonsCompleted': 0,
          'totalLessons': 0,
          'exercisesCompleted': 0,
          'wordsLearned': 0,
          'accuracy': 0,
          'totalStudyTime': 0,
        },
        'progress': {'lessons': {}, 'sections': {}},
        'achievements': {},
        'studySessions': {},
        'dailyProgress': {
          'lastLessonDate': _getDateString(DateTime.now()),
          'lessonsCompletedToday': 0,
        },
      });

      // Initialiser le système SRS pour le nouvel utilisateur
      try {
        await SRSDatabaseInit.initializeSRSCollections(userId);
        print('✅ Système SRS initialisé pour le nouvel utilisateur: $userId');
      } catch (e) {
        // Ne pas faire échouer la création de l'utilisateur si l'initialisation SRS échoue
        print('⚠️ Erreur lors de l\'initialisation SRS (non bloquant): $e');
      }
    } catch (e) {
      print('❌ Erreur lors de la création de l\'utilisateur: $e');
    }
  }

  /// Débloquer un achievement pour un utilisateur
  static Future<void> unlockAchievement(
    String userId,
    String achievementId, {
    int? progress,
  }) async {
    try {
      final userRef = _firestore.collection(_usersCollection).doc(userId);
      final now = FieldValue.serverTimestamp();

      // Vérifier si l'achievement existe dans la collection achievements
      final achievementDoc = await _firestore
          .collection(_achievementsCollection)
          .doc(achievementId)
          .get();

      if (!achievementDoc.exists) {
        print(
          '⚠️ Achievement $achievementId n\'existe pas dans la collection achievements',
        );
        // On continue quand même pour permettre les tests
      }

      // Mettre à jour l'achievement de l'utilisateur
      await userRef.update({
        'achievements.$achievementId': {
          'unlocked': true,
          'unlockedAt': now,
          'progress': progress ?? 100,
        },
        'lastActive': now,
      });

      // Si l'achievement a une récompense XP, l'ajouter
      if (achievementDoc.exists) {
        final achievementData = achievementDoc.data();
        final rewards = achievementData?['rewards'] as Map<String, dynamic>?;
        final xpReward = rewards?['xp'] as int?;

        if (xpReward != null && xpReward > 0) {
          await addXP(userId, xpReward);
          print('✅ ${xpReward} XP ajoutés pour l\'achievement $achievementId');
        }
      }

      print(
        '✅ Achievement $achievementId débloqué pour l\'utilisateur $userId',
      );
    } catch (e) {
      print('❌ Erreur lors du déblocage de l\'achievement: $e');
      rethrow;
    }
  }

  /// Vérifier et débloquer automatiquement les achievements basés sur les stats
  static Future<void> checkAndUnlockAchievements(String userId) async {
    try {
      final userData = await getUserData(userId);
      if (userData == null) return;

      final stats = userData['stats'] as Map<String, dynamic>? ?? {};
      final achievements = await getAllAchievements();

      for (final achievement in achievements) {
        final achievementId = achievement['id'] as String;
        final requirements =
            achievement['requirements'] as Map<String, dynamic>?;

        if (requirements == null) continue;

        final type = requirements['type'] as String?;
        final value = requirements['value'] as num?;
        final condition = requirements['condition'] as String? ?? '>=';

        if (type == null || value == null) continue;

        // Vérifier si l'achievement est déjà débloqué
        final userAchievements =
            userData['achievements'] as Map<String, dynamic>? ?? {};
        if (userAchievements[achievementId]?['unlocked'] == true) {
          continue; // Déjà débloqué
        }

        // Gérer les valeurs décimales (pour accuracy, study_time, etc.)
        final numValue = value.toDouble();
        final numUserValue =
            (stats[_getStatKey(type)] as num?)?.toDouble() ?? 0.0;

        // Vérifier les critères
        bool shouldUnlock = false;

        switch (condition) {
          case '>=':
            shouldUnlock = numUserValue >= numValue;
            break;
          case '==':
            shouldUnlock = numUserValue == numValue;
            break;
          case '>':
            shouldUnlock = numUserValue > numValue;
            break;
          case '<=':
            shouldUnlock = numUserValue <= numValue;
            break;
          case '<':
            shouldUnlock = numUserValue < numValue;
            break;
          default:
            shouldUnlock = numUserValue >= numValue;
        }

        if (shouldUnlock) {
          await unlockAchievement(userId, achievementId);
        }
      }
    } catch (e) {
      print('❌ Erreur lors de la vérification des achievements: $e');
    }
  }

  /// Mapper le type d'achievement vers la clé de stat
  static String _getStatKey(String type) {
    switch (type) {
      case 'lessons':
        return 'lessonsCompleted';
      case 'xp':
        return 'totalXP';
      case 'streak':
        return 'currentStreak';
      case 'best_streak':
        return 'bestStreak';
      case 'level':
        return 'currentLevel';
      case 'accuracy':
        return 'accuracy';
      case 'study_time':
        return 'totalStudyTime';
      case 'words':
        return 'wordsLearned';
      case 'exercises':
        return 'exercisesCompleted';
      default:
        return type;
    }
  }
}
