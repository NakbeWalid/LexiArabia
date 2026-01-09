import 'package:flutter/material.dart';
import 'package:dualingocoran/services/user_service.dart';
import 'package:dualingocoran/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String _error = '';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isLoggedIn => _currentUser != null;

  // Charger un utilisateur par ID
  Future<void> loadUser(String userId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final userData = await UserService.getUserData(userId);
      if (userData != null) {
        print('📥 Données brutes chargées depuis Firestore:');
        print('   - progress: ${userData['progress']}');
        print('   - progress.lessons: ${userData['progress']?['lessons']}');

        _currentUser = UserModel.fromMap(userId, userData);
        print('✅ Utilisateur chargé: ${_currentUser!.profile.username}');
        print(
          '📊 Progress.lessons dans le modèle: ${_currentUser!.progress.lessons.keys.toList()}',
        );
        print(
          '📊 Nombre de leçons dans progress: ${_currentUser!.progress.lessons.length}',
        );
      } else {
        _error = 'Utilisateur non trouvé';
        print('❌ Utilisateur non trouvé: $userId');
      }
    } catch (e, stackTrace) {
      _error = 'Erreur lors du chargement: $e';
      print('❌ Erreur lors du chargement de l\'utilisateur: $e');
      print('❌ Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger l'utilisateur de démonstration
  Future<void> loadDemoUser() async {
    await loadUser('demo_user_001');
  }

  // Charger un utilisateur de démonstration spécifique
  Future<void> loadDemoUserById(String userId) async {
    await loadUser(userId);
  }

  // Obtenir la liste des IDs d'utilisateurs de démonstration disponibles
  List<String> getAvailableDemoUserIds() {
    return [
      'demo_user_001', // QuranLearner - Niveau 5
      'demo_user_002', // ArabicMaster - Niveau 8
      'demo_user_003', // BeginnerStudent - Niveau 2
      'demo_user_004', // IntermediateLearner - Niveau 6
      'demo_user_005', // AdvancedStudent - Niveau 10
      'demo_user_006', // CasualLearner - Niveau 3
      'demo_user_007', // DedicatedStudent - Niveau 7
      'demo_user_008', // WeekendWarrior - Niveau 3
      'demo_user_009', // SpeedLearner - Niveau 9
      'demo_user_010', // ConsistentLearner - Niveau 6
    ];
  }

  // Mettre à jour les statistiques
  Future<void> updateStats(Map<String, dynamic> newStats) async {
    if (_currentUser == null) return;

    try {
      await UserService.updateUserStats(_currentUser!.userId, newStats);

      // Mettre à jour le modèle local
      final updatedStats = UserStats.fromMap(newStats);
      _currentUser = UserModel(
        userId: _currentUser!.userId,
        profile: _currentUser!.profile,
        stats: updatedStats,
        progress: _currentUser!.progress,
        achievements: _currentUser!.achievements,
        studySessions: _currentUser!.studySessions,
        dailyProgress: _currentUser!.dailyProgress,
      );

      notifyListeners();
      print('✅ Statistiques mises à jour');
    } catch (e) {
      print('❌ Erreur lors de la mise à jour des stats: $e');
    }
  }

  // Ajouter de l'XP
  Future<void> addXP(int xpToAdd) async {
    if (_currentUser == null) return;

    try {
      await UserService.addXP(_currentUser!.userId, xpToAdd);

      // Mettre à jour le modèle local
      final newXP = _currentUser!.stats.totalXP + xpToAdd;
      final newLevel = (newXP / 1000).floor() + 1;

      final updatedStats = UserStats(
        totalXP: newXP,
        currentLevel: newLevel,
        currentStreak: _currentUser!.stats.currentStreak,
        bestStreak: _currentUser!.stats.bestStreak,
        lessonsCompleted: _currentUser!.stats.lessonsCompleted,
        totalLessons: _currentUser!.stats.totalLessons,
        exercisesCompleted: _currentUser!.stats.exercisesCompleted,
        wordsLearned: _currentUser!.stats.wordsLearned,
        accuracy: _currentUser!.stats.accuracy,
        totalStudyTime: _currentUser!.stats.totalStudyTime,
      );

      _currentUser = UserModel(
        userId: _currentUser!.userId,
        profile: _currentUser!.profile,
        stats: updatedStats,
        progress: _currentUser!.progress,
        achievements: _currentUser!.achievements,
        studySessions: _currentUser!.studySessions,
        dailyProgress: _currentUser!.dailyProgress,
      );

      notifyListeners();
      print('✅ XP ajouté: +$xpToAdd (Total: $newXP, Niveau: $newLevel)');
    } catch (e) {
      print('❌ Erreur lors de l\'ajout d\'XP: $e');
    }
  }

  // Mettre à jour le streak
  Future<void> updateStreak(bool maintained) async {
    if (_currentUser == null) return;

    try {
      await UserService.updateStreak(_currentUser!.userId, maintained);

      // Mettre à jour le modèle local
      int newStreak = maintained ? _currentUser!.stats.currentStreak + 1 : 0;
      int newBestStreak = newStreak > _currentUser!.stats.bestStreak
          ? newStreak
          : _currentUser!.stats.bestStreak;

      final updatedStats = UserStats(
        totalXP: _currentUser!.stats.totalXP,
        currentLevel: _currentUser!.stats.currentLevel,
        currentStreak: newStreak,
        bestStreak: newBestStreak,
        lessonsCompleted: _currentUser!.stats.lessonsCompleted,
        totalLessons: _currentUser!.stats.totalLessons,
        exercisesCompleted: _currentUser!.stats.exercisesCompleted,
        wordsLearned: _currentUser!.stats.wordsLearned,
        accuracy: _currentUser!.stats.accuracy,
        totalStudyTime: _currentUser!.stats.totalStudyTime,
      );

      _currentUser = UserModel(
        userId: _currentUser!.userId,
        profile: _currentUser!.profile,
        stats: updatedStats,
        progress: _currentUser!.progress,
        achievements: _currentUser!.achievements,
        studySessions: _currentUser!.studySessions,
        dailyProgress: _currentUser!.dailyProgress,
      );

      notifyListeners();
      print('✅ Streak mis à jour: $newStreak (Meilleur: $newBestStreak)');
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du streak: $e');
    }
  }

  // Marquer une leçon comme terminée
  Future<void> completeLesson(
    String lessonId,
    int score, {
    int? xpReward,
  }) async {
    if (_currentUser == null) return;

    try {
      await UserService.completeLesson(
        _currentUser!.userId,
        lessonId,
        score,
        xpReward: xpReward,
      );

      // Calculer l'XP basé sur le score (même logique que dans UserService)
      final xpToAdd =
          xpReward ?? (50 + (score * 100 / 100).round()).clamp(50, 150);
      final newXP = _currentUser!.stats.totalXP + xpToAdd;
      final newLevel = (newXP / 1000).floor() + 1;

      // Recharger les données utilisateur pour obtenir le streak mis à jour
      await loadUser(_currentUser!.userId);

      // Vérifier et débloquer automatiquement les achievements
      await UserService.checkAndUnlockAchievements(_currentUser!.userId);

      // Recharger à nouveau pour avoir les achievements mis à jour
      await loadUser(_currentUser!.userId);

      // Mettre à jour le modèle local avec les nouvelles données
      final updatedLessons = Map<String, LessonProgress>.from(
        _currentUser!.progress.lessons,
      );
      updatedLessons[lessonId] = LessonProgress(
        completed: true,
        completedAt: DateTime.now(),
        score: score,
        attempts: 1,
        bestScore: score,
      );

      final updatedProgress = UserProgress(
        lessons: updatedLessons,
        sections: _currentUser!.progress.sections,
      );

      // Utiliser les stats mises à jour depuis Firestore (incluant le streak)
      final updatedStats = UserStats(
        totalXP: newXP,
        currentLevel: newLevel,
        currentStreak:
            _currentUser!.stats.currentStreak, // Mis à jour par loadUser
        bestStreak: _currentUser!.stats.bestStreak, // Mis à jour par loadUser
        lessonsCompleted: _currentUser!.stats.lessonsCompleted + 1,
        totalLessons: _currentUser!.stats.totalLessons,
        exercisesCompleted: _currentUser!.stats.exercisesCompleted,
        wordsLearned: _currentUser!.stats.wordsLearned,
        accuracy: _currentUser!.stats.accuracy,
        totalStudyTime: _currentUser!.stats.totalStudyTime,
      );

      _currentUser = UserModel(
        userId: _currentUser!.userId,
        profile: _currentUser!.profile,
        stats: updatedStats,
        progress: updatedProgress,
        achievements: _currentUser!.achievements,
        studySessions: _currentUser!.studySessions,
        dailyProgress: _currentUser!.dailyProgress,
      );

      notifyListeners();
      print(
        '✅ Leçon terminée: $lessonId (Score: $score, +$xpToAdd XP, Total: $newXP, Niveau: $newLevel)',
      );
    } catch (e) {
      print('❌ Erreur lors de la complétion de la leçon: $e');
    }
  }

  // Déconnecter l'utilisateur
  void logout() {
    _currentUser = null;
    _error = '';
    notifyListeners();
    print('👋 Utilisateur déconnecté');
  }

  // Effacer l'erreur
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
