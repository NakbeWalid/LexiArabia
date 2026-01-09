import 'package:dualingocoran/services/user_service.dart';

/// Script de test pour ajouter un achievement à un utilisateur
/// 
/// Utilisation:
/// 1. Remplacez 'VOTRE_USER_ID' par l'ID de votre utilisateur
/// 2. Remplacez 'first_lesson' par l'ID de l'achievement que vous voulez débloquer
/// 3. Exécutez: dart run lib/services/test_achievement.dart
/// 
/// Ou dans votre code:
/// ```dart
/// await testUnlockAchievement();
/// ```

Future<void> testUnlockAchievement() async {
  // ⬇️ MODIFIEZ CES VALEURS
  const String userId = 'VOTRE_USER_ID'; // Remplacez par l'ID de votre utilisateur
  const String achievementId = 'first_lesson'; // ID de l'achievement à débloquer
  
  try {
    print('🧪 Test: Déblocage de l\'achievement $achievementId pour l\'utilisateur $userId');
    
    // Débloquer l'achievement
    await UserService.unlockAchievement(userId, achievementId);
    
    print('✅ Achievement débloqué avec succès !');
    
    // Vérifier que l'achievement a été ajouté
    final achievements = await UserService.getUserAchievements(userId);
    if (achievements != null && achievements.containsKey(achievementId)) {
      print('✅ Vérification: L\'achievement est bien dans les données utilisateur');
      print('   Détails: ${achievements[achievementId]}');
    } else {
      print('⚠️ L\'achievement n\'a pas été trouvé dans les données utilisateur');
    }
    
  } catch (e) {
    print('❌ Erreur lors du test: $e');
  }
}

/// Test pour débloquer plusieurs achievements
Future<void> testUnlockMultipleAchievements() async {
  const String userId = 'VOTRE_USER_ID'; // Remplacez par l'ID de votre utilisateur
  
  final achievementsToUnlock = [
    'first_lesson',
    'hundred_xp',
    'streak_7_days',
  ];
  
  try {
    print('🧪 Test: Déblocage de ${achievementsToUnlock.length} achievements');
    
    for (final achievementId in achievementsToUnlock) {
      await UserService.unlockAchievement(userId, achievementId);
      print('✅ $achievementId débloqué');
    }
    
    print('✅ Tous les achievements ont été débloqués !');
    
  } catch (e) {
    print('❌ Erreur lors du test: $e');
  }
}

/// Test pour vérifier et débloquer automatiquement les achievements
Future<void> testCheckAndUnlockAchievements() async {
  const String userId = 'VOTRE_USER_ID'; // Remplacez par l'ID de votre utilisateur
  
  try {
    print('🧪 Test: Vérification automatique des achievements');
    
    await UserService.checkAndUnlockAchievements(userId);
    
    print('✅ Vérification terminée !');
    
    // Afficher tous les achievements débloqués
    final achievements = await UserService.getUserAchievements(userId);
    if (achievements != null && achievements.isNotEmpty) {
      print('📊 Achievements débloqués:');
      achievements.forEach((id, data) {
        if (data['unlocked'] == true) {
          print('   - $id: débloqué le ${data['unlockedAt']}');
        }
      });
    } else {
      print('ℹ️ Aucun achievement débloqué');
    }
    
  } catch (e) {
    print('❌ Erreur lors du test: $e');
  }
}

