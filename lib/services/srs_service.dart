import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dualingocoran/models/srs_exercise_model.dart';
import 'package:dualingocoran/models/srs_settings_model.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/services/fsrs_algorithm.dart';
import 'srs_database_init.dart';
import 'dart:math' as math;

/// Service pour gérer le système SRS (Spaced Repetition System)
/// Implémente l'algorithme FSRS (Free Spaced Repetition Scheduler)
class SRSService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Politique "Duolingo-like":
  /// - Toujours prioriser les révisions dues (fragiles / oubliées)
  /// - Réduire fortement les "new" quand il y a beaucoup de due
  ///
  /// Règles (avec cap journalier typique 15):
  /// - Si due >= cap-3  (ex: 12/15) → 0 new
  /// - Si due >= cap-7  (ex: 8/15)  → 1 new max
  /// - Sinon → jusqu'à newExercisesPerDay
  static int computeDailyNewLimit({
    required SRSSettings settings,
    required int dueSelectedCount,
  }) {
    final cap = settings.maxReviewsPerDay.clamp(1, 50);
    final baseNew = settings.newExercisesPerDay.clamp(0, 50);

    final remainingSlots = math.max(0, cap - dueSelectedCount);
    if (remainingSlots == 0 || baseNew == 0) return 0;

    // Beaucoup de retard → on coupe les new pour rattraper
    if (dueSelectedCount >= cap - 3) return 0;

    // Retard significatif → on garde 1 new max pour continuer à avancer
    if (dueSelectedCount >= cap - 7) {
      return math.min(1, math.min(baseNew, remainingSlots));
    }

    // Sinon, on autorise le quota normal de new (dans la limite des slots restants)
    return math.min(baseNew, remainingSlots);
  }

  // Priorité "le plus ancien / oublié" (heuristique légère côté client)
  // - Plus un exercice est en retard (overdue), plus il est prioritaire
  // - Plus il a de lapses, plus il est prioritaire
  // - Plus sa stabilité est faible, plus il est fragile → prioritaire
  // - Plus sa difficulté est haute, plus il est prioritaire
  static double _priorityScore(SRSExercise ex, DateTime now) {
    final overdueHours = math.max(0, now.difference(ex.dueDate).inHours);
    final overdueDays = overdueHours / 24.0;
    final stability = ex.stability <= 0 ? 0.1 : ex.stability;

    final overdueComponent = overdueDays * 100.0;
    final lapsesComponent = ex.lapses * 40.0;
    final fragilityComponent = (1.0 / (stability + 0.5)) * 20.0;
    final difficultyComponent = ex.difficulty * 2.0;

    return overdueComponent +
        lapsesComponent +
        fragilityComponent +
        difficultyComponent;
  }

  /// Obtenir les paramètres SRS d'un utilisateur
  static Future<SRSSettings> getSettings(String userId) async {
    final settingsData = await SRSDatabaseInit.getSRSSettings(userId);
    if (settingsData != null) {
      return SRSSettings.fromMap(settingsData);
    }
    // Retourner les paramètres par défaut si non trouvés
    return SRSSettings.defaultSettings();
  }

  /// Créer un exercice SRS depuis un exercice complété
  static Future<String> createSRSExercise({
    required String userId,
    required String lessonId,
    required int exerciseIndex,
    required Exercise exercise,
  }) async {
    try {
      // Générer un ID déterministe pour éviter les doublons lors de la répétition d'une leçon
      final cleanLessonId = lessonId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final exerciseId = '${cleanLessonId}_$exerciseIndex';

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .doc(exerciseId);

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        print('ℹ️ Exercice SRS déjà existant réutilisé: $exerciseId');
        return exerciseId;
      }

      final now = DateTime.now();
      // Note: getSettings() initialise les paramètres par défaut si nécessaire
      await getSettings(userId);

      // Créer l'exercice SRS avec statut "new"
      // IMPORTANT: Utiliser rawData si disponible pour préserver les traductions
      // Sinon, créer un objet avec les données disponibles
      Map<String, dynamic> exerciseDataToSave;
      if (exercise.rawData != null) {
        // Utiliser les données brutes pour préserver les Maps de traductions
        exerciseDataToSave = Map<String, dynamic>.from(exercise.rawData!);
        // S'assurer que le type est présent
        exerciseDataToSave['type'] = exercise.type;

        // IMPORTANT: Pour les exercices pairs/drag_drop, s'assurer que dragDropPairs est présent
        // même si rawData contient seulement 'pairs'
        if ((exercise.type == 'pairs' || exercise.type == 'drag_drop') &&
            exercise.dragDropPairs != null &&
            exerciseDataToSave['dragDropPairs'] == null) {
          exerciseDataToSave['dragDropPairs'] = exercise.dragDropPairs;
          print(
            '✅ Added dragDropPairs to exerciseData for ${exercise.type} exercise',
          );
        }
      } else {
        // Fallback: créer un objet avec les données disponibles
        exerciseDataToSave = {
          'question': exercise.question,
          'type': exercise.type,
          'options': exercise.options,
          'answer': exercise.answer,
          'audioUrl': exercise.audioUrl,
          'dragDropPairs': exercise.dragDropPairs,
        };
      }

      // Initialiser avec FSRS (nouvelle carte)
      final srsExercise = SRSExercise(
        exerciseId: exerciseId,
        lessonId: lessonId,
        exerciseIndex: exerciseIndex,
        exerciseType: exercise.type,
        interval: 0.0, // Sera calculé par FSRS
        stability: 0.4, // Remplacée par FSRS à la première révision
        difficulty: 5.0, // Remplacée par FSRS à la première révision
        state: 0, // NEW
        lapses: 0,
        dueDate: now, // À réviser immédiatement
        elapsedDays: 0,
        status: 'new',
        lastReviewed: null,
        createdAt: now,
        exerciseData: exerciseDataToSave,
        totalReviews: 0,
        correctReviews: 0,
        incorrectReviews: 0,
        hardReviews: 0,
        lastQuality: null,
      );

      // Sauvegarder dans Firestore
      await docRef.set(srsExercise.toMap());

      print('✅ Exercice SRS créé: $exerciseId');
      return exerciseId;
    } catch (e) {
      print('❌ Erreur lors de la création de l\'exercice SRS: $e');
      rethrow;
    }
  }

  /// Obtenir les exercices à réviser aujourd'hui
  static Future<List<SRSExercise>> getDueExercises(
    String userId, {
    bool smoothBacklog = false,
  }) async {
    try {
      final now = DateTime.now();
      final settings = await getSettings(userId);

      // Limite stricte côté app (sécurité)
      final dailyCap = settings.maxReviewsPerDay.clamp(1, 50);
      final overfetch = (dailyCap * 4).clamp(dailyCap, 200);

      // Récupérer les exercices dont la date de révision est passée
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          // Les "new" sont gérés séparément via getNewExercises
          .where('status', whereIn: ['learning', 'review'])
          .orderBy('dueDate', descending: false)
          .limit(overfetch)
          .get();

      final fetched = snapshot.docs
          .map((doc) => SRSExercise.fromMap(doc.data()))
          .toList();

      if (fetched.isEmpty) return [];

      // Priorisation: sélectionner les plus "urgents / oubliés" parmi un sur-échantillon
      fetched.sort((a, b) {
        final sb = _priorityScore(b, now);
        final sa = _priorityScore(a, now);
        final byScore = sb.compareTo(sa);
        if (byScore != 0) return byScore;
        return a.dueDate.compareTo(b.dueDate);
      });

      final selected = fetched.take(dailyCap).toList();

      // Répartition après absence: décaler les items non sélectionnés sur les jours suivants
      // (on ne touche qu'au sur-échantillon pour limiter les writes)
      if (smoothBacklog && fetched.length > dailyCap) {
        final remaining = fetched.sublist(dailyCap);
        final spreadDays = math.min(
          7,
          (remaining.length / dailyCap).ceil().clamp(1, 7),
        );

        final batch = _firestore.batch();
        for (int i = 0; i < remaining.length; i++) {
          final ex = remaining[i];
          final deferByDays = 1 + (i % spreadDays);
          final newDue = DateTime(now.year, now.month, now.day).add(
            Duration(days: deferByDays, hours: 12),
          ); // demain midi, puis +n jours

          final ref = _firestore
              .collection('users')
              .doc(userId)
              .collection('srsExercises')
              .doc(ex.exerciseId);

          batch.update(ref, {
            'dueDate': Timestamp.fromDate(newDue),
            'deferredAt': FieldValue.serverTimestamp(),
            'deferredReason': 'backlog_smoothing',
          });
        }
        await batch.commit();
      }

      return selected;
    } catch (e) {
      print('❌ Erreur lors de la récupération des exercices à réviser: $e');
      return [];
    }
  }

  /// Obtenir les nouveaux exercices à réviser
  static Future<List<SRSExercise>> getNewExercises(
    String userId, {
    int? limitOverride,
    bool allowExceedDailyNewLimit = false,
  }) async {
    try {
      final settings = await getSettings(userId);

      // Par défaut, même si un appelant passe un limitOverride (ex: remainingSlots),
      // on ne dépasse pas la limite quotidienne "newExercisesPerDay".
      final rawRequested = (limitOverride ?? settings.newExercisesPerDay).clamp(
        0,
        50,
      );
      final limit = allowExceedDailyNewLimit
          ? rawRequested
          : math.min(rawRequested, settings.newExercisesPerDay.clamp(0, 50));

      if (limit == 0) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .where('status', isEqualTo: 'new')
          .orderBy('createdAt', descending: false)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => SRSExercise.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erreur lors de la récupération des nouveaux exercices: $e');
      return [];
    }
  }

  // Seuils (secondes) pour la notation automatique
  static const int _fastAnswerSeconds = 10;
  static const int _slowAnswerSeconds = 30;

  /// Notation automatique (0=AGAIN, 1=HARD, 2=GOOD, 3=EASY) à partir des
  /// erreurs commises avant la bonne réponse et du temps de réponse.
  /// Une seule erreur signifie que l'élément n'était pas su → AGAIN.
  static int qualityFromPerformance({
    required int mistakes,
    required int timeInSeconds,
  }) {
    if (mistakes > 0) return FSRSAlgorithm.again;
    if (timeInSeconds <= _fastAnswerSeconds) return FSRSAlgorithm.easy;
    if (timeInSeconds <= _slowAnswerSeconds) return FSRSAlgorithm.good;
    return FSRSAlgorithm.hard;
  }

  /// Enregistrer une révision et mettre à jour l'exercice avec l'algorithme FSRS
  static Future<void> recordReview({
    required String userId,
    required String exerciseId,
    required int quality, // 0=AGAIN, 1=HARD, 2=GOOD, 3=EASY
    int? responseTime,
  }) async {
    try {
      final settings = await getSettings(userId);
      final clampedQuality = quality.clamp(FSRSAlgorithm.again, FSRSAlgorithm.easy);

      // Récupérer l'exercice actuel
      final exerciseDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .doc(exerciseId)
          .get();

      if (!exerciseDoc.exists) {
        throw Exception('Exercice SRS non trouvé: $exerciseId');
      }

      final currentExercise = SRSExercise.fromMap(exerciseDoc.data()!);
      final now = DateTime.now();

      // Calculer le nouvel état avec l'algorithme FSRS
      final updatedExercise = FSRSAlgorithm.calculateNext(
        current: currentExercise,
        quality: clampedQuality,
        params: settings.fsrsParams,
        requestRetention: settings.requestRetention,
        now: now,
      );

      // Mettre à jour les statistiques (agrégées dans l'exercice)
      final updatedStats = updatedExercise.copyWith(
        totalReviews: currentExercise.totalReviews + 1,
        correctReviews: clampedQuality >= FSRSAlgorithm.hard
            ? currentExercise.correctReviews + 1
            : currentExercise.correctReviews,
        incorrectReviews: clampedQuality == FSRSAlgorithm.again
            ? currentExercise.incorrectReviews + 1
            : currentExercise.incorrectReviews,
        hardReviews: clampedQuality == FSRSAlgorithm.hard
            ? currentExercise.hardReviews + 1
            : currentExercise.hardReviews,
        lastQuality: clampedQuality,
        lastReviewed: now,
      );

      // Sauvegarder dans Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .doc(exerciseId)
          .update(updatedStats.toMap());

      print(
        '✅ Révision FSRS: ${_getQualityLabel(clampedQuality)} pour $exerciseId '
        '(S ${currentExercise.stability.toStringAsFixed(2)} → ${updatedExercise.stability.toStringAsFixed(2)}, '
        'état ${currentExercise.state} → ${updatedExercise.state}, prochaine: ${updatedExercise.dueDate})',
      );
    } catch (e) {
      print("❌ Erreur lors de l'enregistrement de la révision: $e");
      rethrow;
    }
  }

  /// Obtenir les statistiques SRS d'un utilisateur
  static Future<Map<String, dynamic>> getStats(String userId) async {
    try {
      final exercisesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .get();

      final exercises = exercisesSnapshot.docs
          .map((doc) => SRSExercise.fromMap(doc.data()))
          .toList();

      final dueExercises = exercises.where((e) => e.isDue).length;
      final newExercises = exercises.where((e) => e.status == 'new').length;
      final masteredExercises = exercises.where((e) => e.isMastered).length;

      // Calculer le total des révisions depuis les statistiques agrégées
      final totalReviews = exercises.fold<int>(
        0,
        (sum, exercise) => sum + exercise.totalReviews,
      );

      return {
        'totalExercises': exercises.length,
        'dueExercises': dueExercises,
        'newExercises': newExercises,
        'masteredExercises': masteredExercises,
        'totalReviews': totalReviews,
      };
    } catch (e) {
      print('❌ Erreur lors de la récupération des statistiques: $e');
      return {};
    }
  }

  /// Supprimer un exercice SRS (optionnel)
  static Future<void> deleteSRSExercise(
    String userId,
    String exerciseId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .doc(exerciseId)
          .delete();
      print('✅ Exercice SRS supprimé: $exerciseId');
    } catch (e) {
      print('❌ Erreur lors de la suppression: $e');
      rethrow;
    }
  }

  /// Obtenir le label de qualité depuis un entier
  static String _getQualityLabel(int quality) {
    switch (quality) {
      case 0:
        return 'AGAIN';
      case 1:
        return 'HARD';
      case 2:
        return 'GOOD';
      case 3:
        return 'EASY';
      default:
        return 'HARD';
    }
  }
}
