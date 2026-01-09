import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dualingocoran/models/srs_exercise_model.dart';
import 'package:dualingocoran/models/srs_review_model.dart';
import 'package:dualingocoran/models/srs_settings_model.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'srs_database_init.dart';

/// Service pour gérer le système SRS (Spaced Repetition System)
/// Implémente l'algorithme SM-2 (comme Anki)
class SRSService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      final settings = await getSettings(userId);

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

      final srsExercise = SRSExercise(
        exerciseId: exerciseId,
        lessonId: lessonId,
        exerciseIndex: exerciseIndex,
        exerciseType: exercise.type,
        interval: 0.0, // Nouveau, pas encore révisé
        easeFactor: settings.defaultEaseFactor,
        repetitions: 0,
        dueDate: now, // À réviser immédiatement
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
  static Future<List<SRSExercise>> getDueExercises(String userId) async {
    try {
      final now = DateTime.now();
      final settings = await getSettings(userId);

      // Récupérer les exercices dont la date de révision est passée
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .where('status', whereIn: ['new', 'learning', 'review'])
          .orderBy('dueDate', descending: false)
          .limit(settings.maxReviewsPerDay)
          .get();

      return snapshot.docs
          .map((doc) => SRSExercise.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erreur lors de la récupération des exercices à réviser: $e');
      return [];
    }
  }

  /// Obtenir les nouveaux exercices à réviser
  static Future<List<SRSExercise>> getNewExercises(String userId) async {
    try {
      final settings = await getSettings(userId);

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .where('status', isEqualTo: 'new')
          .orderBy('createdAt', descending: false)
          .limit(settings.newExercisesPerDay)
          .get();

      return snapshot.docs
          .map((doc) => SRSExercise.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erreur lors de la récupération des nouveaux exercices: $e');
      return [];
    }
  }

  /// Enregistrer une révision et mettre à jour l'exercice avec l'algorithme SM-2
  static Future<void> recordReview({
    required String userId,
    required String exerciseId,
    required int quality, // 0=AGAIN, 1=HARD, 2=GOOD, 3=EASY
    int? responseTime,
  }) async {
    try {
      final settings = await getSettings(userId);
      final qualityLabel = SRSReview.getQualityLabel(quality);

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

      // Sauvegarder l'état avant
      final intervalBefore = currentExercise.interval;
      final easeFactorBefore = currentExercise.easeFactor;
      final repetitionsBefore = currentExercise.repetitions;

      // Calculer le nouvel état avec l'algorithme SM-2
      final updatedExercise = _calculateSM2(
        currentExercise: currentExercise,
        quality: quality,
        settings: settings,
      );

      // Créer l'enregistrement de révision
      final reviewId = '${exerciseId}_${DateTime.now().millisecondsSinceEpoch}';
      final review = SRSReview(
        reviewId: reviewId,
        exerciseId: exerciseId,
        lessonId: currentExercise.lessonId,
        quality: quality,
        qualityLabel: qualityLabel,
        responseTime: responseTime,
        reviewedAt: DateTime.now(),
        intervalBefore: intervalBefore,
        intervalAfter: updatedExercise.interval,
        easeFactorBefore: easeFactorBefore,
        easeFactorAfter: updatedExercise.easeFactor,
        repetitionsBefore: repetitionsBefore,
        repetitionsAfter: updatedExercise.repetitions,
        wasCorrect: quality >= 2, // GOOD ou EASY = correct
      );

      // Mettre à jour les statistiques
      final updatedStats = updatedExercise.copyWith(
        totalReviews: currentExercise.totalReviews + 1,
        correctReviews: quality >= 2
            ? currentExercise.correctReviews + 1
            : currentExercise.correctReviews,
        incorrectReviews: quality == 0
            ? currentExercise.incorrectReviews + 1
            : currentExercise.incorrectReviews,
        hardReviews: quality == 1
            ? currentExercise.hardReviews + 1
            : currentExercise.hardReviews,
        lastQuality: quality,
        lastReviewed: DateTime.now(),
      );

      // Sauvegarder dans Firestore (transaction pour garantir la cohérence)
      final batch = _firestore.batch();

      // Mettre à jour l'exercice
      batch.update(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('srsExercises')
            .doc(exerciseId),
        updatedStats.toMap(),
      );

      // Créer l'enregistrement de révision
      batch.set(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('srsReviews')
            .doc(reviewId),
        review.toMap(),
      );

      await batch.commit();

      print('✅ Révision enregistrée: $qualityLabel pour $exerciseId');
      print(
        '   Intervalle: ${intervalBefore.toStringAsFixed(1)} → ${updatedExercise.interval.toStringAsFixed(1)} jours',
      );
      print(
        '   Facilité: ${easeFactorBefore.toStringAsFixed(2)} → ${updatedExercise.easeFactor.toStringAsFixed(2)}',
      );
    } catch (e) {
      print('❌ Erreur lors de l\'enregistrement de la révision: $e');
      rethrow;
    }
  }

  /// Calculer le nouvel état avec l'algorithme SM-2
  static SRSExercise _calculateSM2({
    required SRSExercise currentExercise,
    required int quality,
    required SRSSettings settings,
  }) {
    double newInterval = currentExercise.interval;
    double newEaseFactor = currentExercise.easeFactor;
    int newRepetitions = currentExercise.repetitions;
    String newStatus = currentExercise.status;
    DateTime newDueDate = currentExercise.dueDate;

    // Obtenir l'intervalle initial pour cette qualité
    final qualityLabel = SRSReview.getQualityLabel(quality);
    final initialIntervalForQuality =
        settings.initialIntervals[qualityLabel] ?? 1.0;

    if (quality == 0) {
      // AGAIN - Recommencer
      newInterval = initialIntervalForQuality;
      newRepetitions = 0;
      newStatus = 'learning';
      // Réduire le facteur de facilité
      newEaseFactor = (newEaseFactor + settings.easeFactorChange['AGAIN']!)
          .clamp(settings.easeFactorMin, settings.easeFactorMax);
    } else if (quality == 1) {
      // HARD
      if (currentExercise.repetitions == 0) {
        newInterval = initialIntervalForQuality;
      } else {
        newInterval = (currentExercise.interval * 1.2).clamp(
          settings.minimumInterval,
          settings.maximumInterval,
        );
      }
      newRepetitions = currentExercise.repetitions;
      newStatus = currentExercise.repetitions == 0 ? 'learning' : 'review';
      // Réduire légèrement le facteur de facilité
      newEaseFactor = (newEaseFactor + settings.easeFactorChange['HARD']!)
          .clamp(settings.easeFactorMin, settings.easeFactorMax);
    } else if (quality == 2) {
      // GOOD
      if (currentExercise.repetitions == 0) {
        newInterval = initialIntervalForQuality;
        newRepetitions = 1;
        newStatus = 'learning';
      } else if (currentExercise.repetitions == 1) {
        newInterval = 6.0;
        newRepetitions = 2;
        newStatus = 'review';
      } else {
        newInterval = (currentExercise.interval * newEaseFactor).clamp(
          settings.minimumInterval,
          settings.maximumInterval,
        );
        newRepetitions = currentExercise.repetitions + 1;
        newStatus = 'review';
      }
      // Pas de changement du facteur de facilité pour GOOD
    } else if (quality == 3) {
      // EASY
      if (currentExercise.repetitions == 0) {
        newInterval = initialIntervalForQuality * settings.easyBonus;
        newRepetitions = 1;
        newStatus = 'review';
      } else {
        newInterval =
            (currentExercise.interval * newEaseFactor * settings.easyBonus)
                .clamp(settings.minimumInterval, settings.maximumInterval);
        newRepetitions = currentExercise.repetitions + 1;
        newStatus = 'review';
      }
      // Augmenter légèrement le facteur de facilité
      newEaseFactor = (newEaseFactor + settings.easeFactorChange['EASY']!)
          .clamp(settings.easeFactorMin, settings.easeFactorMax);
    }

    // Appliquer le modificateur d'intervalle global
    newInterval = newInterval * settings.intervalModifier;

    // Calculer la nouvelle date de révision
    newDueDate = DateTime.now().add(Duration(days: newInterval.round()));

    // Mettre à jour le statut si maîtrisé
    if (newInterval > 30 && newStatus == 'review') {
      newStatus = 'mastered';
    }

    return currentExercise.copyWith(
      interval: newInterval,
      easeFactor: newEaseFactor,
      repetitions: newRepetitions,
      dueDate: newDueDate,
      status: newStatus,
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

      final reviewsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsReviews')
          .get();

      final exercises = exercisesSnapshot.docs
          .map((doc) => SRSExercise.fromMap(doc.data()))
          .toList();

      final dueExercises = exercises.where((e) => e.isDue).length;
      final newExercises = exercises.where((e) => e.status == 'new').length;
      final masteredExercises = exercises.where((e) => e.isMastered).length;

      return {
        'totalExercises': exercises.length,
        'dueExercises': dueExercises,
        'newExercises': newExercises,
        'masteredExercises': masteredExercises,
        'totalReviews': reviewsSnapshot.docs.length,
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
}
