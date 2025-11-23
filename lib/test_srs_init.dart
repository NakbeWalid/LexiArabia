/// Fichier de test pour l'initialisation SRS
/// 
/// Pour tester, ajoutez ce code temporairement dans votre main.dart
/// ou créez un bouton de test dans votre interface

import 'package:dualingocoran/services/srs_database_init.dart';

/// Fonction de test à appeler depuis votre code
Future<void> testSRSInitialization() async {
  print('🧪 Test de l\'initialisation SRS...\n');
  
  // Utiliser l'ID de l'utilisateur de démonstration
  const userId = 'demo_user_001';
  
  try {
    // 1. Vérifier si SRS est déjà initialisé
    print('1️⃣ Vérification de l\'état actuel...');
    final isInitialized = await SRSDatabaseInit.isSRSInitialized(userId);
    print('   SRS initialisé: $isInitialized\n');
    
    // 2. Initialiser SRS
    print('2️⃣ Initialisation des collections SRS...');
    await SRSDatabaseInit.initializeSRSCollections(userId);
    print('   ✅ Collections initialisées\n');
    
    // 3. Vérifier les paramètres
    print('3️⃣ Vérification des paramètres SRS...');
    final settings = await SRSDatabaseInit.getSRSSettings(userId);
    if (settings != null) {
      print('   ✅ Paramètres récupérés:');
      print('      - Algorithme: ${settings['algorithm']}');
      print('      - Nouveaux exercices/jour: ${settings['newExercisesPerDay']}');
      print('      - Révisions max/jour: ${settings['maxReviewsPerDay']}');
      print('      - Intervalle initial: ${settings['initialInterval']} jours');
      print('      - Facteur de facilité: ${settings['defaultEaseFactor']}\n');
    } else {
      print('   ❌ Paramètres non trouvés\n');
    }
    
    // 4. Vérifier à nouveau l'état
    print('4️⃣ Vérification finale...');
    final isNowInitialized = await SRSDatabaseInit.isSRSInitialized(userId);
    print('   SRS initialisé: $isNowInitialized\n');
    
    if (isNowInitialized) {
      print('🎉 Test réussi ! Les collections SRS sont prêtes.\n');
      print('📋 Prochaines étapes:');
      print('   1. Vérifiez dans Firebase Console que les collections existent');
      print('   2. Vérifiez: users/$userId/srsSettings/settings');
      print('   3. Vérifiez: users/$userId/srsExercises (collection)');
      print('   4. Vérifiez: users/$userId/srsReviews (collection)');
    } else {
      print('❌ Test échoué. Les collections ne sont pas initialisées.');
    }
    
  } catch (e, stackTrace) {
    print('❌ Erreur lors du test: $e');
    print('Stack trace: $stackTrace');
  }
}

/// Alternative: Test depuis un widget (bouton de test)
/// 
/// Ajoutez ceci dans un de vos écrans pour tester:
/// 
/// ElevatedButton(
///   onPressed: () async {
///     await testSRSInitialization();
///   },
///   child: Text('Tester SRS Init'),
/// )

