import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle pour un exercice en révision avec l'algorithme FSRS
///
/// FSRS (Free Spaced Repetition Scheduler) utilise les concepts suivants :
/// - stability : Temps (en jours) jusqu'à 90% de probabilité de rétention
/// - difficulty : Difficulté intrinsèque de la carte (0-10)
/// - state : État de la carte (NEW=0, LEARNING=1, REVIEW=2, RELEARNING=3)
/// - lapses : Nombre de fois que la carte a été oubliée
/// - elapsedDays : Jours réels depuis la dernière révision
class SRSExercise {
  final String exerciseId;
  final String lessonId;
  final int exerciseIndex;
  final String exerciseType;

  // Paramètres FSRS
  final double
  interval; // Intervalle en jours jusqu'à la prochaine révision (calculé depuis stability)
  final double
  stability; // Stabilité : temps jusqu'à 90% de probabilité de rétention (FSRS)
  final double
  difficulty; // Difficulté : 0-10, ajustée dynamiquement selon les performances (FSRS)
  final int state; // État FSRS: 0=New, 1=Learning, 2=Review, 3=Relearning
  // Nombre total d'oublis historiques (lapses). Dans ce projet, on ne génère plus "AGAIN"(0),
  // donc ce compteur n'augmente pas automatiquement via les reviews actuelles.
  final int lapses;
  final DateTime dueDate; // Date/heure de la prochaine révision
  final int elapsedDays; // Jours écoulés depuis la dernière révision (FSRS)

  // État actuel
  final String
  status; // "new", "learning", "review", "mastered" (dérivé de state)
  final DateTime? lastReviewed;
  final DateTime createdAt;

  // Métadonnées de l'exercice (pour le retrouver)
  final Map<String, dynamic> exerciseData;

  // Statistiques
  final int totalReviews;
  final int correctReviews;
  final int incorrectReviews;
  final int hardReviews;
  final int? lastQuality; // 1=HARD, 2=GOOD, 3=EASY (0=AGAIN non utilisé)

  SRSExercise({
    required this.exerciseId,
    required this.lessonId,
    required this.exerciseIndex,
    required this.exerciseType,
    required this.interval,
    required this.stability,
    required this.difficulty,
    required this.state,
    required this.lapses,
    required this.dueDate,
    required this.elapsedDays,
    required this.status,
    this.lastReviewed,
    required this.createdAt,
    required this.exerciseData,
    required this.totalReviews,
    required this.correctReviews,
    required this.incorrectReviews,
    required this.hardReviews,
    this.lastQuality,
  });

  /// Créer un SRSExercise depuis les données Firestore
  factory SRSExercise.fromMap(Map<String, dynamic> data) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is DateTime) {
        return timestamp;
      }
      return DateTime.now();
    }

    DateTime? parseTimestampNullable(dynamic timestamp) {
      if (timestamp == null) return null;
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is DateTime) {
        return timestamp;
      }
      return null;
    }

    // FSRS fields
    final stability = (data['stability'] ?? 0.4).toDouble();
    final difficulty = (data['difficulty'] ?? 5.0).toDouble();
    final state = data['state'] ?? 0;
    final lapses = data['lapses'] ?? 0;
    final elapsedDays = data['elapsedDays'] ?? 0;

    // Calculer le statut depuis state si nécessaire
    String status = data['status'] ?? '';
    if (status.isEmpty) {
      switch (state) {
        case 0:
          status = 'new';
          break;
        case 1:
          status = 'learning';
          break;
        case 2:
          status = 'review';
          break;
        case 3:
          status = 'learning';
          break;
        default:
          status = 'new';
      }
    }

    // Calculer interval depuis stability si nécessaire
    double interval = (data['interval'] ?? stability).toDouble();
    if (interval == 0 && stability > 0) {
      interval = stability;
    }

    // Calculer elapsedDays depuis lastReviewed si nécessaire
    int calculatedElapsedDays = elapsedDays;
    if (calculatedElapsedDays == 0 && data['lastReviewed'] != null) {
      final lastReviewed = parseTimestampNullable(data['lastReviewed']);
      if (lastReviewed != null) {
        calculatedElapsedDays = DateTime.now().difference(lastReviewed).inDays;
      }
    }

    return SRSExercise(
      exerciseId: data['exerciseId'] ?? '',
      lessonId: data['lessonId'] ?? '',
      exerciseIndex: data['exerciseIndex'] ?? 0,
      exerciseType: data['exerciseType'] ?? '',
      interval: interval,
      stability: stability,
      difficulty: difficulty,
      state: state,
      lapses: lapses,
      dueDate: parseTimestamp(data['dueDate']),
      elapsedDays: calculatedElapsedDays,
      status: status,
      lastReviewed: parseTimestampNullable(data['lastReviewed']),
      createdAt: parseTimestamp(data['createdAt']),
      exerciseData: data['exerciseData'] as Map<String, dynamic>? ?? {},
      totalReviews: data['totalReviews'] ?? 0,
      correctReviews: data['correctReviews'] ?? 0,
      incorrectReviews: data['incorrectReviews'] ?? 0,
      hardReviews: data['hardReviews'] ?? 0,
      lastQuality: data['lastQuality'],
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'lessonId': lessonId,
      'exerciseIndex': exerciseIndex,
      'exerciseType': exerciseType,
      // FSRS fields
      'interval': interval,
      'stability': stability,
      'difficulty': difficulty,
      'state': state,
      'lapses': lapses,
      'elapsedDays': elapsedDays,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'lastReviewed': lastReviewed != null
          ? Timestamp.fromDate(lastReviewed!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'exerciseData': exerciseData,
      'totalReviews': totalReviews,
      'correctReviews': correctReviews,
      'incorrectReviews': incorrectReviews,
      'hardReviews': hardReviews,
      'lastQuality': lastQuality,
    };
  }

  /// Créer une copie avec des valeurs modifiées
  SRSExercise copyWith({
    String? exerciseId,
    String? lessonId,
    int? exerciseIndex,
    String? exerciseType,
    double? interval,
    double? stability,
    double? difficulty,
    int? state,
    int? lapses,
    DateTime? dueDate,
    int? elapsedDays,
    String? status,
    DateTime? lastReviewed,
    DateTime? createdAt,
    Map<String, dynamic>? exerciseData,
    int? totalReviews,
    int? correctReviews,
    int? incorrectReviews,
    int? hardReviews,
    int? lastQuality,
  }) {
    return SRSExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      lessonId: lessonId ?? this.lessonId,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      exerciseType: exerciseType ?? this.exerciseType,
      interval: interval ?? this.interval,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      state: state ?? this.state,
      lapses: lapses ?? this.lapses,
      dueDate: dueDate ?? this.dueDate,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      status: status ?? this.status,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      createdAt: createdAt ?? this.createdAt,
      exerciseData: exerciseData ?? this.exerciseData,
      totalReviews: totalReviews ?? this.totalReviews,
      correctReviews: correctReviews ?? this.correctReviews,
      incorrectReviews: incorrectReviews ?? this.incorrectReviews,
      hardReviews: hardReviews ?? this.hardReviews,
      lastQuality: lastQuality ?? this.lastQuality,
    );
  }

  /// Vérifier si l'exercice est à réviser maintenant
  bool get isDue =>
      dueDate.isBefore(DateTime.now()) ||
      dueDate.isAtSameMomentAs(DateTime.now());

  /// Vérifier si l'exercice est maîtrisé (FSRS: stabilité > 30 jours et en état review)
  bool get isMastered => stability > 30 && state == 2 && status == 'review';
}
