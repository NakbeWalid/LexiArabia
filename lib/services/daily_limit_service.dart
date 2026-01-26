import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyLimitService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _usersCollection = 'users';
  static const int _defaultDailyLimit = 2;

  /// Récupère l'ID de l'utilisateur actuel
  static String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Récupère la limite quotidienne (configurable, par défaut 5)
  static int getDailyLimit() {
    return _defaultDailyLimit;
  }

  /// Vérifie si l'utilisateur peut commencer une nouvelle leçon aujourd'hui
  static Future<bool> canStartLesson() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        print('⚠️ Aucun utilisateur connecté');
        return false;
      }

      final today = DateTime.now();
      final todayString = _getDateString(today);

      final userRef = _firestore.collection(_usersCollection).doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        // Si l'utilisateur n'existe pas encore, initialiser les données
        await _initializeDailyProgress(userId, todayString);
        return true;
      }

      final data = userDoc.data();
      final dailyProgress =
          data?['dailyProgress'] as Map<String, dynamic>? ?? {};
      final lastDateString = dailyProgress['lastLessonDate'] as String?;
      final lessonsToday = dailyProgress['lessonsCompletedToday'] as int? ?? 0;

      // Si c'est un nouveau jour, réinitialiser le compteur
      if (lastDateString != todayString) {
        await userRef.update({
          'dailyProgress.lastLessonDate': todayString,
          'dailyProgress.lessonsCompletedToday': 0,
        });
        return true;
      }

      // Vérifier si la limite est atteinte
      return lessonsToday < getDailyLimit();
    } catch (e) {
      print('❌ Erreur lors de la vérification de la limite quotidienne: $e');
      return true; // En cas d'erreur, permettre l'accès
    }
  }

  /// Récupère le nombre de leçons complétées aujourd'hui
  static Future<int> getLessonsCompletedToday() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return 0;

      final today = DateTime.now();
      final todayString = _getDateString(today);

      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) return 0;

      final data = userDoc.data();
      final dailyProgress =
          data?['dailyProgress'] as Map<String, dynamic>? ?? {};
      final lastDateString = dailyProgress['lastLessonDate'] as String?;
      final lessonsToday = dailyProgress['lessonsCompletedToday'] as int? ?? 0;

      // Si c'est un nouveau jour, retourner 0
      if (lastDateString != todayString) {
        return 0;
      }

      return lessonsToday;
    } catch (e) {
      print('❌ Erreur lors de la récupération des leçons complétées: $e');
      return 0;
    }
  }

  /// Incrémente le compteur de leçons complétées aujourd'hui et met à jour le streak
  static Future<void> incrementLessonCount() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        print(
          '⚠️ Aucun utilisateur connecté, impossible d\'incrémenter le compteur',
        );
        return;
      }

      final today = DateTime.now();
      final todayString = _getDateString(today);

      final userRef = _firestore.collection(_usersCollection).doc(userId);

      // Utiliser une transaction pour garantir la cohérence des données
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          // Initialiser si l'utilisateur n'existe pas
          await _initializeDailyProgress(userId, todayString);
          transaction.set(userRef, {
            'dailyProgress': {
              'lastLessonDate': todayString,
              'lessonsCompletedToday': 1,
            },
            'stats': {'currentStreak': 1, 'bestStreak': 1},
          }, SetOptions(merge: true));
          return;
        }

        final data = userDoc.data();
        final dailyProgress =
            data?['dailyProgress'] as Map<String, dynamic>? ?? {};
        final lastDateString = dailyProgress['lastLessonDate'] as String?;
        int lessonsToday = dailyProgress['lessonsCompletedToday'] as int? ?? 0;

        // Récupérer le streak actuel
        final stats = data?['stats'] as Map<String, dynamic>? ?? {};
        final currentStreak = stats['currentStreak'] as int? ?? 0;
        final bestStreak = stats['bestStreak'] as int? ?? 0;

        // Si c'est un nouveau jour, réinitialiser le compteur et mettre à jour le streak
        bool isNewDay = lastDateString != todayString;
        if (isNewDay) {
          lessonsToday = 0;
        }

        // Incrémenter le compteur
        lessonsToday++;

        // Calculer le nouveau streak
        int newStreak;
        if (isNewDay) {
          // Vérifier si la dernière leçon était hier (streak maintenu)
          if (lastDateString != null) {
            final lastDate = DateTime.parse(lastDateString);
            final yesterday = today.subtract(Duration(days: 1));
            final isYesterday =
                lastDate.year == yesterday.year &&
                lastDate.month == yesterday.month &&
                lastDate.day == yesterday.day;

            // Si la dernière leçon était hier, maintenir le streak (+1)
            // Sinon, réinitialiser à 1 (première leçon du jour)
            newStreak = isYesterday ? currentStreak + 1 : 1;
          } else {
            // Pas de date précédente, commencer à 1
            newStreak = 1;
          }
        } else {
          // Même jour, maintenir le streak actuel (ne pas l'incrémenter plusieurs fois par jour)
          newStreak = currentStreak > 0 ? currentStreak : 1;
        }

        // Mettre à jour le meilleur streak si nécessaire
        int newBestStreak = newStreak > bestStreak ? newStreak : bestStreak;

        transaction.update(userRef, {
          'dailyProgress.lastLessonDate': todayString,
          'dailyProgress.lessonsCompletedToday': lessonsToday,
          'stats.currentStreak': newStreak,
          'stats.bestStreak': newBestStreak,
        });
      });

      final lessonsToday = await getLessonsCompletedToday();
      print(
        '✅ Leçon comptabilisée. Total aujourd\'hui: $lessonsToday/${getDailyLimit()}',
      );
    } catch (e) {
      print('❌ Erreur lors de l\'incrémentation du compteur: $e');
    }
  }

  /// Initialise les données de progression quotidienne pour un nouvel utilisateur
  static Future<void> _initializeDailyProgress(
    String userId,
    String todayString,
  ) async {
    try {
      final userRef = _firestore.collection(_usersCollection).doc(userId);
      await userRef.set({
        'dailyProgress': {
          'lastLessonDate': todayString,
          'lessonsCompletedToday': 0,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      print(
        '❌ Erreur lors de l\'initialisation de la progression quotidienne: $e',
      );
    }
  }

  /// Réinitialise le compteur (utile pour les tests ou la réinitialisation manuelle)
  static Future<void> resetDailyCount() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return;

      final today = DateTime.now();
      final todayString = _getDateString(today);

      await _firestore.collection(_usersCollection).doc(userId).update({
        'dailyProgress.lastLessonDate': todayString,
        'dailyProgress.lessonsCompletedToday': 0,
      });
      print('✅ Compteur quotidien réinitialisé');
    } catch (e) {
      print('❌ Erreur lors de la réinitialisation: $e');
    }
  }

  /// Récupère le nombre de leçons restantes aujourd'hui
  static Future<int> getRemainingLessons() async {
    final completed = await getLessonsCompletedToday();
    final limit = getDailyLimit();
    final remaining = limit - completed;
    return remaining > 0 ? remaining : 0;
  }

  /// Convertit une date en string (format: YYYY-MM-DD)
  static String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
