import 'dart:math' as math;
import '../models/srs_exercise_model.dart';

/// Implémentation de l'algorithme FSRS-4.5 (Free Spaced Repetition Scheduler)
///
/// Référence : https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-Algorithm
///
/// Concepts clés :
/// - Stability (S) : nombre de jours pour que la probabilité de rappel tombe à 90%
/// - Difficulty (D) : difficulté intrinsèque de la carte (1-10)
/// - Retrievability (R) : probabilité de rappel au moment de la révision
/// - State : NEW(0), LEARNING(1), REVIEW(2), RELEARNING(3)
///
/// Notes (quality) utilisées dans l'app → rating FSRS :
/// 0=AGAIN(1), 1=HARD(2), 2=GOOD(3), 3=EASY(4)
class FSRSAlgorithm {
  /// Version des paramètres. Les paramètres stockés dans Firestore ne sont
  /// utilisés que s'ils portent cette version (les anciens étaient invalides).
  static const String version = '4.5';

  static const int again = 0;
  static const int hard = 1;
  static const int good = 2;
  static const int easy = 3;

  /// Paramètres par défaut officiels de FSRS-4.5 (w0..w16)
  static const List<double> defaultParams = [
    0.4872,
    1.4003,
    3.7145,
    13.8206,
    5.1618,
    1.2298,
    0.8975,
    0.031,
    1.6474,
    0.1367,
    1.0461,
    2.1072,
    0.0793,
    0.3246,
    1.587,
    0.2272,
    2.8755,
  ];

  static const double _decay = -0.5;
  static const double _factor = 19 / 81; // garantit R(S, S) = 0.9
  static const double _maximumIntervalDays = 36500;

  // Étapes d'apprentissage (courtes, avant de passer en REVIEW)
  static const Duration _againStep = Duration(minutes: 1);
  static const Duration _hardStep = Duration(minutes: 5);
  static const Duration _goodStep = Duration(minutes: 10);
  static const Duration _relearningStep = Duration(minutes: 5);

  /// Calculer le prochain état d'une carte après une révision
  static SRSExercise calculateNext({
    required SRSExercise current,
    required int quality, // 0=AGAIN, 1=HARD, 2=GOOD, 3=EASY
    List<double>? params,
    double requestRetention = 0.9,
    DateTime? now,
  }) {
    final w = (params != null && params.length == defaultParams.length)
        ? params
        : defaultParams;
    final reviewTime = now ?? DateTime.now();
    final rating = quality.clamp(again, easy) + 1; // 1..4
    final retention = requestRetention.clamp(0.7, 0.99);

    // Jours (fractionnaires) écoulés depuis la dernière révision
    final elapsedDays = current.lastReviewed == null
        ? 0.0
        : math.max(
            0.0,
            reviewTime.difference(current.lastReviewed!).inMinutes / 1440.0,
          );

    double difficulty;
    double stability;
    int state;
    int lapses = current.lapses;
    Duration interval;

    switch (current.state) {
      case 0: // NEW
        difficulty = _initDifficulty(w, rating);
        stability = _initStability(w, rating);
        if (rating == 4) {
          state = 2;
          interval = _days(_nextIntervalDays(stability, retention));
        } else {
          state = 1;
          interval = rating == 1
              ? _againStep
              : (rating == 2 ? _hardStep : _goodStep);
        }
        break;

      case 1: // LEARNING
      case 3: // RELEARNING
        difficulty = _nextDifficulty(w, current.difficulty, rating);
        stability = math.max(0.1, current.stability);
        // FSRS-4.5 ignore les révisions du même jour pour la stabilité
        if (elapsedDays >= 1) {
          final r = _retrievability(elapsedDays, stability);
          stability = rating == 1
              ? _forgetStability(w, current.difficulty, stability, r)
              : _recallStability(w, current.difficulty, stability, r, rating);
        }
        if (rating == 1) {
          state = current.state;
          interval = current.state == 3 ? _relearningStep : _againStep;
        } else if (rating == 2) {
          state = current.state;
          interval = current.state == 3 ? _goodStep : _hardStep;
        } else {
          state = 2;
          final goodDays = _nextIntervalDays(stability, retention);
          interval = _days(rating == 4 ? goodDays + 1 : goodDays);
        }
        break;

      default: // REVIEW
        final lastStability = math.max(0.1, current.stability);
        final r = _retrievability(elapsedDays, lastStability);
        difficulty = _nextDifficulty(w, current.difficulty, rating);
        if (rating == 1) {
          stability = _forgetStability(
            w,
            current.difficulty,
            lastStability,
            r,
          );
          lapses++;
          state = 3;
          interval = _relearningStep;
        } else {
          stability = _recallStability(
            w,
            current.difficulty,
            lastStability,
            r,
            rating,
          );
          state = 2;
          interval = _days(_nextIntervalDays(stability, retention));
        }
    }

    return current.copyWith(
      interval: interval.inMinutes / 1440.0,
      stability: stability,
      difficulty: difficulty,
      state: state,
      lapses: lapses,
      dueDate: reviewTime.add(interval),
      elapsedDays: elapsedDays.floor(),
      status: _stateToStatus(state),
    );
  }

  static double _initStability(List<double> w, int rating) =>
      math.max(0.1, w[rating - 1]);

  static double _initDifficulty(List<double> w, int rating) =>
      (w[4] - (rating - 3) * w[5]).clamp(1.0, 10.0);

  static double _nextDifficulty(List<double> w, double d, int rating) {
    final next = d - w[6] * (rating - 3);
    // Mean reversion vers la difficulté initiale d'une réponse GOOD (w4)
    final reverted = w[7] * w[4] + (1 - w[7]) * next;
    return reverted.clamp(1.0, 10.0);
  }

  /// Probabilité de rappel après [elapsedDays] jours
  static double _retrievability(double elapsedDays, double stability) =>
      math.pow(1 + _factor * elapsedDays / stability, _decay).toDouble();

  static double _recallStability(
    List<double> w,
    double d,
    double s,
    double r,
    int rating,
  ) {
    final hardPenalty = rating == 2 ? w[15] : 1.0;
    final easyBonus = rating == 4 ? w[16] : 1.0;
    return s *
        (1 +
            math.exp(w[8]) *
                (11 - d) *
                math.pow(s, -w[9]) *
                (math.exp((1 - r) * w[10]) - 1) *
                hardPenalty *
                easyBonus);
  }

  static double _forgetStability(
    List<double> w,
    double d,
    double s,
    double r,
  ) {
    final next =
        w[11] *
        math.pow(d, -w[12]) *
        (math.pow(s + 1, w[13]) - 1) *
        math.exp((1 - r) * w[14]);
    return math.max(0.1, math.min(next, s));
  }

  /// Intervalle (jours entiers) pour atteindre la rétention cible
  static int _nextIntervalDays(double stability, double retention) {
    final days =
        stability / _factor * (math.pow(retention, 1 / _decay) - 1);
    return days.round().clamp(1, _maximumIntervalDays.toInt());
  }

  static Duration _days(int days) => Duration(days: days);

  static String _stateToStatus(int state) {
    switch (state) {
      case 0:
        return 'new';
      case 2:
        return 'review';
      default:
        return 'learning'; // LEARNING et RELEARNING
    }
  }

  /// Obtenir les paramètres FSRS par défaut
  static List<double> getDefaultParams() => List<double>.from(defaultParams);
}
