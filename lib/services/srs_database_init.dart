import 'package:cloud_firestore/cloud_firestore.dart';

/// Service pour initialiser les collections Firestore nécessaires au système SRS
class SRSDatabaseInit {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialise les paramètres SRS par défaut pour un utilisateur
  /// Crée le document srsSettings avec les valeurs par défaut (algorithme SM-2)
  static Future<void> initializeSRSSettings(String userId) async {
    try {
      print('🚀 Initialisation des paramètres SRS pour l\'utilisateur: $userId');

      final srsSettingsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('srsSettings')
          .doc('settings');

      // Vérifier si les paramètres existent déjà
      final settingsDoc = await srsSettingsRef.get();
      if (settingsDoc.exists) {
        print('✅ Les paramètres SRS existent déjà pour cet utilisateur');
        return;
      }

      // Paramètres SRS par défaut (algorithme SM-2 comme Anki)
      final defaultSettings = {
        'algorithm': 'sm2',
        
        // Paramètres SM-2
        'initialInterval': 1.0, // 1 jour
        'minimumInterval': 1.0, // 1 jour minimum
        'maximumInterval': 36500.0, // 100 ans maximum
        'easyBonus': 1.3, // Bonus pour EASY
        'intervalModifier': 1.0, // Modificateur global
        
        // Intervalles initiaux pour chaque qualité (en jours)
        'initialIntervals': {
          'AGAIN': 0.0, // Recommencer immédiatement
          'HARD': 0.5, // 12 heures
          'GOOD': 1.0, // 1 jour
          'EASY': 4.0, // 4 jours
        },
        
        // Limites quotidiennes
        'newExercisesPerDay': 20, // Nouveaux exercices à réviser par jour
        'maxReviewsPerDay': 200, // Révisions max par jour
        
        // Modificateurs de facilité
        'easeFactorMin': 1.3, // Minimum
        'easeFactorMax': 2.5, // Maximum (défaut)
        'easeFactorChange': {
          'AGAIN': -0.2, // Réduire la facilité
          'HARD': -0.15, // Réduire légèrement
          'GOOD': 0.0, // Pas de changement
          'EASY': 0.15, // Augmenter légèrement
        },
        
        // Facteur de facilité initial
        'defaultEaseFactor': 2.5,
        
        // Créé à
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await srsSettingsRef.set(defaultSettings);
      print('✅ Paramètres SRS initialisés avec succès');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation des paramètres SRS: $e');
      rethrow;
    }
  }

  /// Initialise les collections SRS pour un utilisateur
  /// Crée les sous-collections srsExercises et srsReviews
  static Future<void> initializeSRSCollections(String userId) async {
    try {
      print('🚀 Initialisation des collections SRS pour l\'utilisateur: $userId');

      // Initialiser les paramètres SRS
      await initializeSRSSettings(userId);

      // Créer un document de test dans srsExercises pour s'assurer que la collection existe
      // (Firestore crée les collections automatiquement, mais on peut créer un document vide)
      final srsExercisesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .doc('_init');

      final srsReviewsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('srsReviews')
          .doc('_init');

      // Vérifier si les collections existent déjà
      final exercisesInit = await srsExercisesRef.get();
      final reviewsInit = await srsReviewsRef.get();

      if (!exercisesInit.exists) {
        await srsExercisesRef.set({
          'initialized': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('✅ Collection srsExercises initialisée');
      }

      if (!reviewsInit.exists) {
        await srsReviewsRef.set({
          'initialized': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('✅ Collection srsReviews initialisée');
      }

      print('✅ Collections SRS initialisées avec succès pour l\'utilisateur: $userId');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation des collections SRS: $e');
      rethrow;
    }
  }

  /// Initialise les collections SRS pour tous les utilisateurs existants
  static Future<void> initializeSRSForAllUsers() async {
    try {
      print('🚀 Initialisation des collections SRS pour tous les utilisateurs...');

      final usersSnapshot = await _firestore.collection('users').get();
      int initializedCount = 0;

      for (final userDoc in usersSnapshot.docs) {
        try {
          await initializeSRSCollections(userDoc.id);
          initializedCount++;
        } catch (e) {
          print('⚠️ Erreur pour l\'utilisateur ${userDoc.id}: $e');
        }
      }

      print('✅ Collections SRS initialisées pour $initializedCount utilisateur(s)');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation pour tous les utilisateurs: $e');
      rethrow;
    }
  }

  /// Supprime les documents d'initialisation (optionnel, pour nettoyer)
  static Future<void> cleanupInitDocuments(String userId) async {
    try {
      print('🧹 Nettoyage des documents d\'initialisation pour: $userId');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .doc('_init')
          .delete();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsReviews')
          .doc('_init')
          .delete();

      print('✅ Documents d\'initialisation supprimés');
    } catch (e) {
      print('❌ Erreur lors du nettoyage: $e');
    }
  }

  /// Vérifie si les collections SRS sont initialisées pour un utilisateur
  static Future<bool> isSRSInitialized(String userId) async {
    try {
      final settingsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('srsSettings')
          .doc('settings');

      final settingsDoc = await settingsRef.get();
      return settingsDoc.exists;
    } catch (e) {
      print('❌ Erreur lors de la vérification: $e');
      return false;
    }
  }

  /// Obtient les paramètres SRS d'un utilisateur
  static Future<Map<String, dynamic>?> getSRSSettings(String userId) async {
    try {
      final settingsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('srsSettings')
          .doc('settings');

      final settingsDoc = await settingsRef.get();
      if (settingsDoc.exists) {
        return settingsDoc.data();
      }
      return null;
    } catch (e) {
      print('❌ Erreur lors de la récupération des paramètres: $e');
      return null;
    }
  }

  /// Met à jour les paramètres SRS d'un utilisateur
  static Future<void> updateSRSSettings(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final settingsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('srsSettings')
          .doc('settings');

      updates['updatedAt'] = FieldValue.serverTimestamp();
      await settingsRef.update(updates);
      print('✅ Paramètres SRS mis à jour');
    } catch (e) {
      print('❌ Erreur lors de la mise à jour des paramètres: $e');
      rethrow;
    }
  }

  /// Crée un document d'exemple pour tester la structure
  static Future<void> createExampleSRSExercise(String userId) async {
    try {
      print('📝 Création d\'un exercice SRS d\'exemple...');

      final now = DateTime.now();
      final exerciseId = 'example_${now.millisecondsSinceEpoch}';

      final exampleExercise = {
        'exerciseId': exerciseId,
        'lessonId': 'example_lesson',
        'exerciseIndex': 0,
        'exerciseType': 'multiple_choice',
        
        // Données SRS
        'interval': 0.0,
        'easeFactor': 2.5,
        'repetitions': 0,
        'dueDate': Timestamp.fromDate(now),
        
        // État
        'status': 'new',
        'lastReviewed': null,
        'createdAt': Timestamp.fromDate(now),
        
        // Métadonnées
        'exerciseData': {
          'question': 'Exemple de question',
          'type': 'multiple_choice',
        },
        
        // Statistiques
        'totalReviews': 0,
        'correctReviews': 0,
        'incorrectReviews': 0,
        'hardReviews': 0,
        'lastQuality': null,
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .doc(exerciseId)
          .set(exampleExercise);

      print('✅ Exercice SRS d\'exemple créé: $exerciseId');
    } catch (e) {
      print('❌ Erreur lors de la création de l\'exemple: $e');
    }
  }
}

