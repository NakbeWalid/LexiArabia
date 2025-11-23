import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle pour une révision SRS
class SRSReview {
  final String reviewId;
  final String exerciseId;
  final String lessonId;
  
  // Données de la révision
  final int quality; // 0=AGAIN, 1=HARD, 2=GOOD, 3=EASY
  final String qualityLabel; // "AGAIN", "HARD", "GOOD", "EASY"
  final int? responseTime; // Temps de réponse en secondes (optionnel)
  final DateTime reviewedAt;
  
  // État avant/après (pour debug et analyse)
  final double intervalBefore;
  final double intervalAfter;
  final double easeFactorBefore;
  final double easeFactorAfter;
  final int repetitionsBefore;
  final int repetitionsAfter;
  
  // Résultat
  final bool wasCorrect; // true si GOOD ou EASY, false si AGAIN

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
    required this.easeFactorBefore,
    required this.easeFactorAfter,
    required this.repetitionsBefore,
    required this.repetitionsAfter,
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
      reviewId: data['reviewId'] ?? '',
      exerciseId: data['exerciseId'] ?? '',
      lessonId: data['lessonId'] ?? '',
      quality: data['quality'] ?? 2,
      qualityLabel: data['qualityLabel'] ?? 'GOOD',
      responseTime: data['responseTime'],
      reviewedAt: parseTimestamp(data['reviewedAt']),
      intervalBefore: (data['intervalBefore'] ?? 0.0).toDouble(),
      intervalAfter: (data['intervalAfter'] ?? 0.0).toDouble(),
      easeFactorBefore: (data['easeFactorBefore'] ?? 2.5).toDouble(),
      easeFactorAfter: (data['easeFactorAfter'] ?? 2.5).toDouble(),
      repetitionsBefore: data['repetitionsBefore'] ?? 0,
      repetitionsAfter: data['repetitionsAfter'] ?? 0,
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
      'easeFactorBefore': easeFactorBefore,
      'easeFactorAfter': easeFactorAfter,
      'repetitionsBefore': repetitionsBefore,
      'repetitionsAfter': repetitionsAfter,
      'wasCorrect': wasCorrect,
    };
  }

  /// Obtenir le label de qualité depuis un entier
  static String getQualityLabel(int quality) {
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
        return 'GOOD';
    }
  }
}

