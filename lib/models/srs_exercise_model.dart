import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle pour un exercice en révision SRS
class SRSExercise {
  final String exerciseId;
  final String lessonId;
  final int exerciseIndex;
  final String exerciseType;
  
  // Données SRS (algorithme SM-2)
  final double interval; // Intervalle en jours jusqu'à la prochaine révision
  final double easeFactor; // Facteur de facilité
  final int repetitions; // Nombre de révisions réussies consécutives
  final DateTime dueDate; // Date/heure de la prochaine révision
  
  // État actuel
  final String status; // "new", "learning", "review", "mastered"
  final DateTime? lastReviewed;
  final DateTime createdAt;
  
  // Métadonnées de l'exercice (pour le retrouver)
  final Map<String, dynamic> exerciseData;
  
  // Statistiques
  final int totalReviews;
  final int correctReviews;
  final int incorrectReviews;
  final int hardReviews;
  final int? lastQuality; // 0=AGAIN, 1=HARD, 2=GOOD, 3=EASY

  SRSExercise({
    required this.exerciseId,
    required this.lessonId,
    required this.exerciseIndex,
    required this.exerciseType,
    required this.interval,
    required this.easeFactor,
    required this.repetitions,
    required this.dueDate,
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

    return SRSExercise(
      exerciseId: data['exerciseId'] ?? '',
      lessonId: data['lessonId'] ?? '',
      exerciseIndex: data['exerciseIndex'] ?? 0,
      exerciseType: data['exerciseType'] ?? '',
      interval: (data['interval'] ?? 0.0).toDouble(),
      easeFactor: (data['easeFactor'] ?? 2.5).toDouble(),
      repetitions: data['repetitions'] ?? 0,
      dueDate: parseTimestamp(data['dueDate']),
      status: data['status'] ?? 'new',
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
      'interval': interval,
      'easeFactor': easeFactor,
      'repetitions': repetitions,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'lastReviewed': lastReviewed != null ? Timestamp.fromDate(lastReviewed!) : null,
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
    double? easeFactor,
    int? repetitions,
    DateTime? dueDate,
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
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      dueDate: dueDate ?? this.dueDate,
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
  bool get isDue => dueDate.isBefore(DateTime.now()) || dueDate.isAtSameMomentAs(DateTime.now());

  /// Vérifier si l'exercice est maîtrisé (interval > 30 jours)
  bool get isMastered => interval > 30 && status == 'review';
}

