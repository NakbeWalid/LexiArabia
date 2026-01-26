import 'dart:math' as math;
import '../models/srs_exercise_model.dart';

/// Implémentation de l'algorithme FSRS (Free Spaced Repetition Scheduler)
///
/// FSRS est un algorithme moderne de répétition espacée basé sur l'apprentissage automatique.
/// Il utilise 17 paramètres optimisés pour adapter l'intervalle de révision à chaque carte individuelle.
///
/// Concepts clés :
/// - Stability (stabilité) : Temps jusqu'à 90% de probabilité de rétention
/// - Difficulty (difficulté) : Difficulté intrinsèque de la carte (0-10)
/// - State (état) : NEW(0), LEARNING(1), REVIEW(2), RELEARNING(3)
/// - Lapses (échecs) : Nombre de fois que la carte a été oubliée
/// - ElapsedDays (jours écoulés) : Jours réels depuis la dernière révision
///
/// Voir FSRS_ALGORITHM_EXPLANATION.md pour une explication détaillée.
class FSRSAlgorithm {
  // Paramètres FSRS optimisés (17 paramètres)
  // Ces valeurs sont les paramètres par défaut optimisés par machine learning
  // sur de grandes bases de données de révisions.
  static const List<double> _defaultParams = [
    0.4,
    1.6,
    10.0,
    5.8,
    4.93,
    0.94,
    0.86,
    0.01,
    1.49,
    0.14,
    0.94,
    2.18,
    0.05,
    0.34,
    1.26,
    0.29,
    2.61,
  ];

  // Paramètres optimisés pour différents cas
  static const double _requestRetention = 0.9; // Taux de rétention cible (90%)
  static const double _minimumDifficulty = 0.0;
  static const double _maximumDifficulty = 10.0;
  static const double _initialDifficulty = 5.0;

  /// Calculer le prochain état avec l'algorithme FSRS
  static SRSExercise calculateNext({
    required SRSExercise current,
    required int
    quality, // 1=HARD, 2=GOOD, 3=EASY (0=AGAIN non utilisé dans ce projet)
    required List<double> params, // 17 paramètres FSRS
    required int elapsedDays, // Jours depuis la dernière révision
  }) {
    final p = params.isNotEmpty ? params : _defaultParams;
    final q = quality.clamp(1, 3);

    // Calculer elapsedDays si non fourni
    int actualElapsedDays = elapsedDays;
    if (actualElapsedDays == 0 && current.lastReviewed != null) {
      actualElapsedDays = DateTime.now()
          .difference(current.lastReviewed!)
          .inDays;
    } else if (actualElapsedDays == 0 && current.lastReviewed == null) {
      // Pour une nouvelle carte sans révision, calculer depuis la création
      actualElapsedDays = DateTime.now().difference(current.createdAt).inDays;
    }
    actualElapsedDays = math.max(0, actualElapsedDays);

    // Variables FSRS - initialiser depuis l'état actuel
    double newDifficulty = current.difficulty;
    double newStability = current.stability;
    int newState = current.state;
    // Lapses = nombre total d'oublis historiques (hérité/analytique).
    // Dans ce projet, on ne génère pas de réponse "AGAIN" (quality=0), donc lapses ne s'incrémente pas ici.
    int newLapses = current.lapses;
    double newInterval = 0.0;

    if (current.state == 0) {
      // NEW card (première révision)
      newState = _handleNewCard(q);
      newDifficulty = _initDifficulty(q, p);
      newStability = _initStability(q, newDifficulty, p);
    } else if (current.state == 1 || current.state == 3) {
      // LEARNING (state 1) or RELEARNING (state 3)
      newState = _handleLearningCard(q);
      newDifficulty = _updateDifficulty(current.difficulty, q, p);
      newStability = _nextRecallStability(
        q,
        newDifficulty,
        current.stability,
        actualElapsedDays,
        p,
      );
    } else {
      // REVIEW (state == 2)
      newState = _handleReviewCard(q);
      newDifficulty = _updateDifficulty(current.difficulty, q, p);
      newStability = _nextRecallStability(
        q,
        newDifficulty,
        current.stability,
        actualElapsedDays,
        p,
      );
    }

    // Calculer le nouvel intervalle
    if (newState == 1 || newState == 3) {
      // LEARNING/RELEARNING : intervalles courts
      newInterval = _nextInterval(newStability, newState, p);
    } else {
      // REVIEW : intervalle basé sur la stabilité
      newInterval = _nextInterval(newStability, newState, p);
      // Ajuster selon la rétention cible
      newInterval = _adjustInterval(
        newInterval,
        newStability,
        _requestRetention,
      );
    }

    // Clamper les valeurs
    newDifficulty = newDifficulty.clamp(_minimumDifficulty, _maximumDifficulty);
    newStability = math.max(0.1, newStability); // Minimum 0.1 jour

    // Convertir state en status string
    String newStatus = _stateToStatus(newState);

    // Calculer la nouvelle date
    final newDueDate = DateTime.now().add(
      Duration(
        days: newInterval.round(),
        hours: ((newInterval - newInterval.floor()) * 24).round(),
      ),
    );

    return current.copyWith(
      interval: newInterval,
      stability: newStability,
      difficulty: newDifficulty,
      state: newState,
      lapses: newLapses,
      dueDate: newDueDate,
      elapsedDays: actualElapsedDays,
      status: newStatus,
    );
  }

  /// Initialiser la difficulté pour une nouvelle carte
  static double _initDifficulty(int quality, List<double> p) {
    // p[4] est le paramètre pour l'initialisation de la difficulté
    double difficulty = _initialDifficulty;
    difficulty -= (quality - 2) * p[4];
    return difficulty.clamp(_minimumDifficulty, _maximumDifficulty);
  }

  /// Initialiser la stabilité pour une nouvelle carte
  static double _initStability(int quality, double difficulty, List<double> p) {
    // Formule FSRS pour la stabilité initiale
    double stability = p[0] + (p[1] - p[0]) * (quality - 1) / 2.0;
    // Ajuster selon la difficulté
    stability *= (1.0 + (difficulty - _initialDifficulty) * p[2] / 20.0);
    return math.max(0.1, stability);
  }

  /// Mettre à jour la difficulté
  static double _updateDifficulty(
    double difficulty,
    int quality,
    List<double> p,
  ) {
    // p[5], p[6] sont les paramètres pour la mise à jour de difficulté
    double change = p[5] + (quality - 2) * p[6];
    difficulty -= change * (difficulty - 8);
    return difficulty.clamp(_minimumDifficulty, _maximumDifficulty);
  }

  /// Calculer la prochaine stabilité de rappel
  static double _nextRecallStability(
    int quality,
    double difficulty,
    double stability,
    int elapsedDays,
    List<double> p,
  ) {
    // Calculer le facteur de rétention
    double retention = _forgettingCurve(stability, elapsedDays);

    // Calculer la nouvelle stabilité selon la qualité
    double newStability;
    if (quality == 1) {
      // HARD
      newStability =
          stability *
          (1.0 +
              math.exp(p[8]) *
                  (11.0 - difficulty) *
                  math.pow(stability, -p[9]) *
                  (math.exp((1.0 - retention) * p[10]) - 1.0));
    } else if (quality == 2) {
      // GOOD
      newStability =
          stability *
          (1.0 +
              math.exp(p[8]) *
                  (11.0 - difficulty) *
                  math.pow(stability, -p[9]) *
                  (math.exp((1.0 - retention) * p[10]) - 1.0));
    } else {
      // EASY (quality == 3)
      newStability =
          stability *
          (1.0 +
              math.exp(p[8]) *
                  (11.0 - difficulty) *
                  math.pow(stability, -p[9]) *
                  (math.exp((1.0 - retention) * p[11]) - 1.0));
    }

    return math.max(0.1, newStability);
  }

  /// Courbe d'oubli : probabilité de rétention après elapsedDays
  static double _forgettingCurve(double stability, int elapsedDays) {
    if (elapsedDays <= 0) return 1.0;
    return math.exp(-elapsedDays / stability);
  }

  /// Calculer le prochain intervalle
  static double _nextInterval(double stability, int state, List<double> p) {
    if (state == 1 || state == 3) {
      // LEARNING/RELEARNING : intervalles courts fixes
      // p[12], p[13] sont les intervalles pour learning/relearning
      return state == 1 ? p[12] : p[13];
    } else {
      // REVIEW : utiliser la stabilité directement
      return stability;
    }
  }

  /// Ajuster l'intervalle selon la rétention cible
  static double _adjustInterval(
    double interval,
    double stability,
    double requestRetention,
  ) {
    // Ajuster pour maintenir le taux de rétention cible
    double actualRetention = _forgettingCurve(stability, interval.round());
    if (actualRetention < requestRetention) {
      // Réduire l'intervalle si la rétention est trop faible
      interval =
          stability * math.log(requestRetention) / math.log(actualRetention);
    }
    return math.max(1.0, interval); // Minimum 1 jour
  }

  /// Gérer l'état pour une nouvelle carte
  static int _handleNewCard(int quality) {
    // Pas de AGAIN(0) dans ce projet.
    // HARD/GOOD => LEARNING, EASY => REVIEW
    if (quality <= 2) return 1; // LEARNING
    return 2; // REVIEW
  }

  /// Gérer l'état pour une carte en apprentissage
  static int _handleLearningCard(int quality) {
    // Pas de AGAIN(0) dans ce projet.
    // HARD/GOOD => reste LEARNING, EASY => REVIEW
    if (quality <= 2) return 1;
    return 2;
  }

  /// Gérer l'état pour une carte en révision
  static int _handleReviewCard(int quality) {
    // Pas de AGAIN(0) dans ce projet.
    // HARD/GOOD/EASY => reste REVIEW
    return 2;
  }

  /// Convertir l'état FSRS en string de statut
  static String _stateToStatus(int state) {
    switch (state) {
      case 0:
        return 'new';
      case 1:
        return 'learning';
      case 2:
        return 'review';
      case 3:
        return 'learning'; // relearning est aussi "learning"
      default:
        return 'new';
    }
  }

  /// Obtenir les paramètres FSRS par défaut
  static List<double> getDefaultParams() => List<double>.from(_defaultParams);
}
