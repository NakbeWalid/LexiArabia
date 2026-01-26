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
      // Générer un ID unique pour l'exercice SRS
      final exerciseId =
          '${lessonId}_${exerciseIndex}_${DateTime.now().millisecondsSinceEpoch}';

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
        stability: 0.4, // Stabilité initiale FSRS
        difficulty: 5.0, // Difficulté initiale FSRS (milieu de l'échelle 0-10)
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
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .doc(exerciseId)
          .set(srsExercise.toMap());

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

  /// Enregistrer une révision et mettre à jour l'exercice avec l'algorithme FSRS
  static Future<void> recordReview({
    required String userId,
    required String exerciseId,
    required int quality, // 1=HARD, 2=GOOD, 3=EASY (0=AGAIN n'est plus utilisé)
    int? responseTime,
  }) async {
    try {
      final settings = await getSettings(userId);

      // Sécurité: dans ce projet, on ne veut plus de quality=0 (AGAIN).
      // On clamp systématiquement à 1..3 pour éviter des données incohérentes.
      final clampedQuality = quality.clamp(1, 3);

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

      // Sauvegarder les valeurs avant pour les logs
      final intervalBefore = currentExercise.interval;
      final stabilityBefore = currentExercise.stability;
      final difficultyBefore = currentExercise.difficulty;
      final stateBefore = currentExercise.state;

      // Calculer le nouvel état avec l'algorithme FSRS
      final updatedExercise = _calculateFSRS(
        currentExercise: currentExercise,
        quality: clampedQuality,
        settings: settings,
        responseTime: responseTime,
      );

      // Mettre à jour les statistiques (agrégées dans l'exercice)
      final updatedStats = updatedExercise.copyWith(
        totalReviews: currentExercise.totalReviews + 1,
        correctReviews: clampedQuality >= 2
            ? currentExercise.correctReviews + 1
            : currentExercise.correctReviews,
        // "incorrectReviews" était basé sur AGAIN(0). Comme on ne génère plus 0,
        // ce compteur n'augmente plus via recordReview.
        incorrectReviews: clampedQuality == 0
            ? currentExercise.incorrectReviews + 1
            : currentExercise.incorrectReviews,
        hardReviews: clampedQuality == 1
            ? currentExercise.hardReviews + 1
            : currentExercise.hardReviews,
        lastQuality: clampedQuality,
        lastReviewed: DateTime.now(),
        elapsedDays: 0, // Réinitialiser après révision
      );

      // Sauvegarder dans Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .doc(exerciseId)
          .update(updatedStats.toMap());

      // Obtenir le label de qualité pour le log
      final qualityLabel = _getQualityLabel(clampedQuality);
      print('✅ Révision FSRS enregistrée: $qualityLabel pour $exerciseId');
      print(
        '   Intervalle: ${intervalBefore.toStringAsFixed(1)} → ${updatedExercise.interval.toStringAsFixed(1)} jours',
      );
      print(
        '   Stabilité: ${stabilityBefore.toStringAsFixed(2)} → ${updatedExercise.stability.toStringAsFixed(2)} jours',
      );
      print(
        '   Difficulté: ${difficultyBefore.toStringAsFixed(2)} → ${updatedExercise.difficulty.toStringAsFixed(2)}',
      );
      print(
        '   État: $stateBefore → ${updatedExercise.state} (${updatedExercise.status})',
      );
    } catch (e) {
      print('❌ Erreur lors de l\'enregistrement de la révision: $e');
      rethrow;
    }
  }

  /// Calculer le nouvel état avec l'algorithme FSRS
  static SRSExercise _calculateFSRS({
    required SRSExercise currentExercise,
    required int quality,
    required SRSSettings settings,
    int? responseTime,
  }) {
    // Calculer elapsedDays depuis la dernière révision
    int elapsedDays = currentExercise.elapsedDays;
    if (elapsedDays == 0 && currentExercise.lastReviewed != null) {
      elapsedDays = DateTime.now()
          .difference(currentExercise.lastReviewed!)
          .inDays;
    } else if (elapsedDays == 0 && currentExercise.lastReviewed == null) {
      // Pour une nouvelle carte, calculer depuis la création
      elapsedDays = DateTime.now().difference(currentExercise.createdAt).inDays;
    }
    elapsedDays = elapsedDays.clamp(0, 365); // Limiter à 1 an max

    // Utiliser FSRS Algorithm
    return FSRSAlgorithm.calculateNext(
      current: currentExercise,
      quality: quality,
      params: settings.fsrsParams,
      elapsedDays: elapsedDays,
    );
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
