import 'package:cloud_firestore/cloud_firestore.dart';

/// Service pour initialiser les collections Firestore nécessaires au système SRS
class SRSDatabaseInit {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialise les paramètres FSRS par défaut pour un utilisateur
  /// Crée le document srsSettings avec les valeurs par défaut (algorithme FSRS)
  static Future<void> initializeSRSSettings(String userId) async {
    try {
      print(
        '🚀 Initialisation des paramètres SRS pour l\'utilisateur: $userId',
      );

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

      // Paramètres SRS par défaut (algorithme FSRS)
      final defaultSettings = {
        'algorithm': 'fsrs',

        // Paramètres FSRS
        'fsrsParams': [
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
        ],
        'requestRetention': 0.9, // 90% de rétention cible
        // Limites quotidiennes
        // Objectif UX: éviter la surcharge après une absence.
        // Les "new" sont limités et les révisions sont plafonnées.
        'newExercisesPerDay': 5, // Nouveaux exercices SRS/jour
        'maxReviewsPerDay': 15, // Révisions max/jour (10–15 recommandé)
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
  /// Crée la sous-collection srsExercises (les statistiques sont agrégées dans chaque exercice)
  static Future<void> initializeSRSCollections(String userId) async {
    try {
      print(
        '🚀 Initialisation des collections SRS pour l\'utilisateur: $userId',
      );

      // Initialiser les paramètres SRS
      await initializeSRSSettings(userId);

      // Créer un document de test dans srsExercises pour s'assurer que la collection existe
      // (Firestore crée les collections automatiquement, mais on peut créer un document vide)
      final srsExercisesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('srsExercises')
          .doc('_init');

      // Vérifier si la collection existe déjà
      final exercisesInit = await srsExercisesRef.get();

      if (!exercisesInit.exists) {
        await srsExercisesRef.set({
          'initialized': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('✅ Collection srsExercises initialisée');
      }

      print(
        '✅ Collections SRS initialisées avec succès pour l\'utilisateur: $userId',
      );
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation des collections SRS: $e');
      rethrow;
    }
  }

  /// Initialise les collections SRS pour tous les utilisateurs existants
  static Future<void> initializeSRSForAllUsers() async {
    try {
      print(
        '🚀 Initialisation des collections SRS pour tous les utilisateurs...',
      );

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

      print(
        '✅ Collections SRS initialisées pour $initializedCount utilisateur(s)',
      );
    } catch (e) {
      print(
        '❌ Erreur lors de l\'initialisation pour tous les utilisateurs: $e',
      );
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

        // Données FSRS
        'interval': 0.0,
        'stability': 0.4,
        'difficulty': 5.0,
        'state': 0,
        'lapses': 0,
        'elapsedDays': 0,
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
