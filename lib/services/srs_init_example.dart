/// Exemple d'utilisation du service d'initialisation SRS
/// 
/// Ce fichier montre comment utiliser SRSDatabaseInit pour initialiser
/// les collections SRS dans votre application.

import 'srs_database_init.dart';

class SRSInitExample {
  /// Exemple 1: Initialiser SRS pour un utilisateur spécifique
  static Future<void> example1_InitializeForUser() async {
    const userId = 'user_123';
    
    // Vérifier si déjà initialisé
    final isInitialized = await SRSDatabaseInit.isSRSInitialized(userId);
    
    if (!isInitialized) {
      // Initialiser les collections SRS
      await SRSDatabaseInit.initializeSRSCollections(userId);
      print('✅ SRS initialisé pour l\'utilisateur $userId');
    } else {
      print('ℹ️ SRS déjà initialisé pour l\'utilisateur $userId');
    }
  }

  /// Exemple 2: Initialiser SRS pour tous les utilisateurs
  static Future<void> example2_InitializeForAllUsers() async {
    await SRSDatabaseInit.initializeSRSForAllUsers();
    print('✅ SRS initialisé pour tous les utilisateurs');
  }

  /// Exemple 3: Obtenir et modifier les paramètres SRS
  static Future<void> example3_GetAndUpdateSettings() async {
    const userId = 'user_123';
    
    // Obtenir les paramètres actuels
    final settings = await SRSDatabaseInit.getSRSSettings(userId);
    if (settings != null) {
      print('Paramètres actuels:');
      print('  - Nouveaux exercices/jour: ${settings['newExercisesPerDay']}');
      print('  - Révisions max/jour: ${settings['maxReviewsPerDay']}');
      
      // Modifier les paramètres
      await SRSDatabaseInit.updateSRSSettings(userId, {
        'newExercisesPerDay': 30, // Augmenter à 30 nouveaux exercices par jour
        'maxReviewsPerDay': 300,  // Augmenter à 300 révisions max par jour
      });
      
      print('✅ Paramètres mis à jour');
    }
  }

  /// Exemple 4: Créer un exercice SRS d'exemple (pour test)
  static Future<void> example4_CreateExampleExercise() async {
    const userId = 'user_123';
    
    // S'assurer que SRS est initialisé
    if (!await SRSDatabaseInit.isSRSInitialized(userId)) {
      await SRSDatabaseInit.initializeSRSCollections(userId);
    }
    
    // Créer un exercice d'exemple
    await SRSDatabaseInit.createExampleSRSExercise(userId);
    print('✅ Exercice SRS d\'exemple créé');
  }

  /// Exemple 5: Utilisation dans le cycle de vie de l'application
  /// À appeler au démarrage de l'app ou lors de la connexion d'un utilisateur
  static Future<void> example5_OnUserLogin(String userId) async {
    // Initialiser SRS si nécessaire
    if (!await SRSDatabaseInit.isSRSInitialized(userId)) {
      await SRSDatabaseInit.initializeSRSCollections(userId);
      print('✅ Collections SRS initialisées pour $userId');
    }
    
    // Vous pouvez maintenant utiliser les collections SRS
    // pour charger les exercices à réviser, etc.
  }
}

/// Exemple d'intégration dans votre code existant
/// 
/// Dans votre UserProvider ou service d'authentification :
/// 
/// ```dart
/// Future<void> loadUser(String userId) async {
///   // ... charger l'utilisateur ...
///   
///   // Initialiser SRS si nécessaire
///   if (!await SRSDatabaseInit.isSRSInitialized(userId)) {
///     await SRSDatabaseInit.initializeSRSCollections(userId);
///   }
/// }
/// ```

