import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle pour une révision avec l'algorithme FSRS
///
/// Enregistre l'historique complet d'une révision, incluant tous les paramètres FSRS
/// avant et après la révision pour permettre l'analyse et le débogage.
class SRSReview {
  final String reviewId;
  final String exerciseId;
  final String lessonId;

  // Données de la révision
  final int quality; // 1=HARD, 2=GOOD, 3=EASY (0=AGAIN non utilisé)
  final String qualityLabel; // "HARD", "GOOD", "EASY"
  final int? responseTime; // Temps de réponse en secondes (optionnel)
  final DateTime reviewedAt;

  // État FSRS avant/après (pour debug et analyse)
  final double intervalBefore;
  final double intervalAfter;
  final double stabilityBefore; // Stabilité FSRS avant la révision
  final double stabilityAfter; // Stabilité FSRS après la révision
  final double difficultyBefore; // Difficulté FSRS avant la révision
  final double difficultyAfter; // Difficulté FSRS après la révision
  final int
  stateBefore; // État FSRS avant (0=New, 1=Learning, 2=Review, 3=Relearning)
  final int stateAfter; // État FSRS après
  final int lapsesBefore; // Nombre d'échecs avant
  final int lapsesAfter; // Nombre d'échecs après

  // Résultat
  // Dans cette app, on ne passe à l'exercice suivant qu'une fois réussi.
  // Donc une review enregistrée correspond à une réussite (HARD/GOOD/EASY).
  final bool wasCorrect;

  SRSReview({
    required this.reviewId,
    required this.exerciseId,
    required this.lessonId,
    required this.quality,
    required this.qualityLabel,
    this.responseTime,
    required this.reviewedAt,
    required this.intervalBefore,
    required this.intervalAfter,
    required this.stabilityBefore,
    required this.stabilityAfter,
    required this.difficultyBefore,
    required this.difficultyAfter,
    required this.stateBefore,
    required this.stateAfter,
    required this.lapsesBefore,
    required this.lapsesAfter,
    required this.wasCorrect,
  });

  /// Créer un SRSReview depuis les données Firestore
  factory SRSReview.fromMap(Map<String, dynamic> data) {
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

    return SRSReview(
      reviewId: data['reviewId'] as String? ?? '',
      exerciseId: data['exerciseId'] ?? '',
      lessonId: data['lessonId'] ?? '',
      quality: data['quality'] ?? 2,
      qualityLabel: data['qualityLabel'] ?? 'GOOD',
      responseTime: data['responseTime'],
      reviewedAt: parseTimestamp(data['reviewedAt']),
      intervalBefore: (data['intervalBefore'] ?? 0.0).toDouble(),
      intervalAfter: (data['intervalAfter'] ?? 0.0).toDouble(),
      // FSRS fields - compatibilité avec anciennes données (easeFactorBefore/After stockait stability)
      stabilityBefore:
          (data['stabilityBefore'] ?? data['easeFactorBefore'] ?? 0.4)
              .toDouble(),
      stabilityAfter: (data['stabilityAfter'] ?? data['easeFactorAfter'] ?? 0.4)
          .toDouble(),
      difficultyBefore: (data['difficultyBefore'] ?? 5.0).toDouble(),
      difficultyAfter: (data['difficultyAfter'] ?? 5.0).toDouble(),
      // stateBefore/After - compatibilité avec anciennes données (repetitionsBefore/After stockait state)
      stateBefore: data['stateBefore'] ?? data['repetitionsBefore'] ?? 0,
      stateAfter: data['stateAfter'] ?? data['repetitionsAfter'] ?? 0,
      lapsesBefore: data['lapsesBefore'] ?? 0,
      lapsesAfter: data['lapsesAfter'] ?? 0,
      wasCorrect: data['wasCorrect'] ?? true,
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'exerciseId': exerciseId,
      'lessonId': lessonId,
      'quality': quality,
      'qualityLabel': qualityLabel,
      'responseTime': responseTime,
      'reviewedAt': Timestamp.fromDate(reviewedAt),
      'intervalBefore': intervalBefore,
      'intervalAfter': intervalAfter,
      // FSRS fields
      'stabilityBefore': stabilityBefore,
      'stabilityAfter': stabilityAfter,
      'difficultyBefore': difficultyBefore,
      'difficultyAfter': difficultyAfter,
      'stateBefore': stateBefore,
      'stateAfter': stateAfter,
      'lapsesBefore': lapsesBefore,
      'lapsesAfter': lapsesAfter,
      'wasCorrect': wasCorrect,
    };
  }

  /// Obtenir le label de qualité depuis un entier
  static String getQualityLabel(int quality) {
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
