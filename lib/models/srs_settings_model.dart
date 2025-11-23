/// Modèle pour les paramètres SRS d'un utilisateur
class SRSSettings {
  final String algorithm;
  
  // Paramètres SM-2
  final double initialInterval;
  final double minimumInterval;
  final double maximumInterval;
  final double easyBonus;
  final double intervalModifier;
  
  // Intervalles initiaux pour chaque qualité (en jours)
  final Map<String, double> initialIntervals;
  
  // Limites quotidiennes
  final int newExercisesPerDay;
  final int maxReviewsPerDay;
  
  // Modificateurs de facilité
  final double easeFactorMin;
  final double easeFactorMax;
  final Map<String, double> easeFactorChange;
  
  // Facteur de facilité initial
  final double defaultEaseFactor;

  SRSSettings({
    required this.algorithm,
    required this.initialInterval,
    required this.minimumInterval,
    required this.maximumInterval,
    required this.easyBonus,
    required this.intervalModifier,
    required this.initialIntervals,
    required this.newExercisesPerDay,
    required this.maxReviewsPerDay,
    required this.easeFactorMin,
    required this.easeFactorMax,
    required this.easeFactorChange,
    required this.defaultEaseFactor,
  });

  /// Créer SRSSettings depuis les données Firestore
  factory SRSSettings.fromMap(Map<String, dynamic> data) {
    return SRSSettings(
      algorithm: data['algorithm'] ?? 'sm2',
      initialInterval: (data['initialInterval'] ?? 1.0).toDouble(),
      minimumInterval: (data['minimumInterval'] ?? 1.0).toDouble(),
      maximumInterval: (data['maximumInterval'] ?? 36500.0).toDouble(),
      easyBonus: (data['easyBonus'] ?? 1.3).toDouble(),
      intervalModifier: (data['intervalModifier'] ?? 1.0).toDouble(),
      initialIntervals: Map<String, double>.from(
        data['initialIntervals'] ?? {
          'AGAIN': 0.0,
          'HARD': 0.5,
          'GOOD': 1.0,
          'EASY': 4.0,
        },
      ),
      newExercisesPerDay: data['newExercisesPerDay'] ?? 20,
      maxReviewsPerDay: data['maxReviewsPerDay'] ?? 200,
      easeFactorMin: (data['easeFactorMin'] ?? 1.3).toDouble(),
      easeFactorMax: (data['easeFactorMax'] ?? 2.5).toDouble(),
      easeFactorChange: Map<String, double>.from(
        data['easeFactorChange'] ?? {
          'AGAIN': -0.2,
          'HARD': -0.15,
          'GOOD': 0.0,
          'EASY': 0.15,
        },
      ),
      defaultEaseFactor: (data['defaultEaseFactor'] ?? 2.5).toDouble(),
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'algorithm': algorithm,
      'initialInterval': initialInterval,
      'minimumInterval': minimumInterval,
      'maximumInterval': maximumInterval,
      'easyBonus': easyBonus,
      'intervalModifier': intervalModifier,
      'initialIntervals': initialIntervals,
      'newExercisesPerDay': newExercisesPerDay,
      'maxReviewsPerDay': maxReviewsPerDay,
      'easeFactorMin': easeFactorMin,
      'easeFactorMax': easeFactorMax,
      'easeFactorChange': easeFactorChange,
      'defaultEaseFactor': defaultEaseFactor,
    };
  }

  /// Créer avec les valeurs par défaut (SM-2)
  factory SRSSettings.defaultSettings() {
    return SRSSettings(
      algorithm: 'sm2',
      initialInterval: 1.0,
      minimumInterval: 1.0,
      maximumInterval: 36500.0,
      easyBonus: 1.3,
      intervalModifier: 1.0,
      initialIntervals: {
        'AGAIN': 0.0,
        'HARD': 0.5,
        'GOOD': 1.0,
        'EASY': 4.0,
      },
      newExercisesPerDay: 20,
      maxReviewsPerDay: 200,
      easeFactorMin: 1.3,
      easeFactorMax: 2.5,
      easeFactorChange: {
        'AGAIN': -0.2,
        'HARD': -0.15,
        'GOOD': 0.0,
        'EASY': 0.15,
      },
      defaultEaseFactor: 2.5,
    );
  }

  /// Créer une copie avec des valeurs modifiées
  SRSSettings copyWith({
    String? algorithm,
    double? initialInterval,
    double? minimumInterval,
    double? maximumInterval,
    double? easyBonus,
    double? intervalModifier,
    Map<String, double>? initialIntervals,
    int? newExercisesPerDay,
    int? maxReviewsPerDay,
    double? easeFactorMin,
    double? easeFactorMax,
    Map<String, double>? easeFactorChange,
    double? defaultEaseFactor,
  }) {
    return SRSSettings(
      algorithm: algorithm ?? this.algorithm,
      initialInterval: initialInterval ?? this.initialInterval,
      minimumInterval: minimumInterval ?? this.minimumInterval,
      maximumInterval: maximumInterval ?? this.maximumInterval,
      easyBonus: easyBonus ?? this.easyBonus,
      intervalModifier: intervalModifier ?? this.intervalModifier,
      initialIntervals: initialIntervals ?? this.initialIntervals,
      newExercisesPerDay: newExercisesPerDay ?? this.newExercisesPerDay,
      maxReviewsPerDay: maxReviewsPerDay ?? this.maxReviewsPerDay,
      easeFactorMin: easeFactorMin ?? this.easeFactorMin,
      easeFactorMax: easeFactorMax ?? this.easeFactorMax,
      easeFactorChange: easeFactorChange ?? this.easeFactorChange,
      defaultEaseFactor: defaultEaseFactor ?? this.defaultEaseFactor,
    );
  }
}

