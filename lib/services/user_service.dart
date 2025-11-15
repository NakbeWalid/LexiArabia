import 'package:cloud_firestore/cloud_firestore.dart';

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
    int score,
  ) async {
    try {
      final userRef = _firestore.collection(_usersCollection).doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (userDoc.exists) {
          final lessonsCompleted =
              userDoc.data()?['stats']?['lessonsCompleted'] ?? 0;
          final totalLessons = userDoc.data()?['stats']?['totalLessons'] ?? 0;

          transaction.update(userRef, {
            'stats.lessonsCompleted': lessonsCompleted + 1,
            'progress.lessons.$lessonId.completed': true,
            'progress.lessons.$lessonId.completedAt':
                FieldValue.serverTimestamp(),
            'progress.lessons.$lessonId.score': score,
            'progress.lessons.$lessonId.attempts': FieldValue.increment(1),
            'lastActive': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('❌ Erreur lors de la complétion de la leçon: $e');
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
    } catch (e) {
      print('❌ Erreur lors de la création de l\'utilisateur: $e');
    }
  }
}
