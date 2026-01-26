/// Modèle pour les paramètres FSRS d'un utilisateur
///
/// Utilise l'algorithme FSRS (Free Spaced Repetition Scheduler), un algorithme moderne
/// de répétition espacée basé sur l'apprentissage automatique.
///
/// Les paramètres incluent :
/// - fsrsParams : 17 paramètres optimisés par machine learning
/// - requestRetention : Taux de rétention cible (par défaut 0.9 = 90%)
/// - Limites quotidiennes pour nouveaux exercices et révisions
class SRSSettings {
  // Paramètres FSRS
  final List<double> fsrsParams; // 17 paramètres optimisés FSRS
  final double requestRetention; // Taux de rétention cible (0.9 = 90%)

  // Limites quotidiennes
  final int newExercisesPerDay;
  final int maxReviewsPerDay;

  SRSSettings({
    required this.fsrsParams,
    required this.requestRetention,
    required this.newExercisesPerDay,
    required this.maxReviewsPerDay,
  });

  /// Créer SRSSettings depuis les données Firestore
  factory SRSSettings.fromMap(Map<String, dynamic> data) {
    // Paramètres FSRS
    List<double> fsrsParams = [];
    if (data['fsrsParams'] != null && data['fsrsParams'] is List) {
      fsrsParams = (data['fsrsParams'] as List)
          .map((e) => (e as num).toDouble())
          .toList();
    } else {
      // Utiliser les paramètres par défaut FSRS
      fsrsParams = _getDefaultFSRSParams();
    }

    final requestRetention = (data['requestRetention'] ?? 0.9).toDouble();

    return SRSSettings(
      fsrsParams: fsrsParams,
      requestRetention: requestRetention,
      // Par défaut, on limite pour éviter une avalanche après une absence.
      // Les nouveaux items SRS (status 'new') sont volontairement bas.
      newExercisesPerDay: data['newExercisesPerDay'] ?? 5,
      // Limite stricte: 10–15 révisions/jour (on choisit 15 par défaut)
      maxReviewsPerDay: data['maxReviewsPerDay'] ?? 15,
    );
  }

  /// Obtenir les paramètres FSRS par défaut
  static List<double> _getDefaultFSRSParams() {
    // Paramètres FSRS optimisés par défaut
    return [
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
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'algorithm': 'fsrs', // Toujours FSRS maintenant
      'fsrsParams': fsrsParams,
      'requestRetention': requestRetention,
      'newExercisesPerDay': newExercisesPerDay,
      'maxReviewsPerDay': maxReviewsPerDay,
    };
  }

  /// Créer avec les valeurs par défaut (FSRS)
  factory SRSSettings.defaultSettings() {
    return SRSSettings(
      fsrsParams: _getDefaultFSRSParams(),
      requestRetention: 0.9, // 90% de rétention cible
      newExercisesPerDay: 5,
      maxReviewsPerDay: 15,
    );
  }

  /// Créer une copie avec des valeurs modifiées
  SRSSettings copyWith({
    List<double>? fsrsParams,
    double? requestRetention,
    int? newExercisesPerDay,
    int? maxReviewsPerDay,
  }) {
    return SRSSettings(
      fsrsParams: fsrsParams ?? this.fsrsParams,
      requestRetention: requestRetention ?? this.requestRetention,
      newExercisesPerDay: newExercisesPerDay ?? this.newExercisesPerDay,
      maxReviewsPerDay: maxReviewsPerDay ?? this.maxReviewsPerDay,
    );
  }
}
