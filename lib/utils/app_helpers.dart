import 'package:flutter/material.dart';
import 'app_constants.dart';

class AppHelpers {
  // Formater le temps d'étude
  static String formatStudyTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (remainingMinutes == 0) {
      return '$hours h';
    }
    
    return '$hours h $remainingMinutes min';
  }

  // Formater l'XP
  static String formatXP(int xp) {
    if (xp < 1000) {
      return xp.toString();
    }
    
    if (xp < 1000000) {
      final k = xp / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    
    final m = xp / 1000000;
    return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
  }

  // Formater le pourcentage
  static String formatPercentage(double value) {
    return '${(value * 100).toInt()}%';
  }

  // Formater la date
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }

  // Formater la durée
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Obtenir la couleur du niveau
  static Color getLevelColor(int level) {
    if (level >= 20) return Colors.purple;
    if (level >= 15) return Colors.red;
    if (level >= 10) return Colors.orange;
    if (level >= 5) return Colors.yellow;
    return Colors.green;
  }

  // Obtenir la couleur du streak
  static Color getStreakColor(int streak) {
    if (streak >= 30) return Colors.purple;
    if (streak >= 15) return Colors.red;
    if (streak >= 7) return Colors.orange;
    if (streak >= 3) return Colors.yellow;
    return Colors.green;
  }

  // Obtenir la couleur de la précision
  static Color getAccuracyColor(double accuracy) {
    if (accuracy >= 90) return Colors.green;
    if (accuracy >= 80) return Colors.yellow;
    if (accuracy >= 70) return Colors.orange;
    if (accuracy >= 60) return Colors.red;
    return Colors.grey;
  }

  // Obtenir la couleur du tier d'achievement
  static Color getAchievementTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return Colors.blue;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey;
      case 'bronze':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Obtenir l'icône du tier d'achievement
  static IconData getAchievementTierIcon(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return Icons.diamond;
      case 'gold':
        return Icons.emoji_events;
      case 'silver':
        return Icons.workspace_premium;
      case 'bronze':
        return Icons.military_tech;
      default:
        return Icons.star;
    }
  }

  // Calculer le niveau à partir de l'XP
  static int calculateLevel(int xp) {
    return (xp / AppConstants.xpPerLevel).floor() + 1;
  }

  // Calculer l'XP nécessaire pour le prochain niveau
  static int calculateXPForNextLevel(int currentLevel) {
    return currentLevel * AppConstants.xpPerLevel;
  }

  // Calculer le pourcentage de progression vers le prochain niveau
  static double calculateProgressToNextLevel(int xp) {
    final currentLevel = calculateLevel(xp);
    final xpForCurrentLevel = (currentLevel - 1) * AppConstants.xpPerLevel;
    final xpInCurrentLevel = xp - xpForCurrentLevel;
    return xpInCurrentLevel / AppConstants.xpPerLevel;
  }

  // Vérifier si un streak est maintenu
  static bool isStreakMaintained(DateTime lastStudyDate) {
    final now = DateTime.now();
    final difference = now.difference(lastStudyDate);
    return difference.inDays <= 1;
  }

  // Calculer le score en pourcentage
  static double calculateScorePercentage(int correct, int total) {
    if (total == 0) return 0.0;
    return correct / total;
  }

  // Obtenir le grade du score
  static String getScoreGrade(double percentage) {
    if (percentage >= 0.9) return 'A+';
    if (percentage >= 0.8) return 'A';
    if (percentage >= 0.7) return 'B';
    if (percentage >= 0.6) return 'C';
    if (percentage >= 0.5) return 'D';
    return 'F';
  }

  // Obtenir la couleur du grade
  static Color getScoreGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.yellow;
      case 'D':
        return Colors.orange;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Valider l'email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Valider le nom d'utilisateur
  static bool isValidUsername(String username) {
    return username.length >= 3 && username.length <= 20;
  }

  // Capitaliser la première lettre
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Tronquer le texte
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Obtenir les initiales
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return name[0].toUpperCase();
    }
    
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // Formater le nombre avec des séparateurs
  static String formatNumber(int number) {
    if (number < 1000) return number.toString();
    
    final parts = number.toString().split('');
    final result = <String>[];
    
    for (int i = parts.length - 1; i >= 0; i--) {
      if ((parts.length - 1 - i) % 3 == 0 && i != parts.length - 1) {
        result.insert(0, ' ');
      }
      result.insert(0, parts[i]);
    }
    
    return result.join();
  }

  // Obtenir la différence de temps en format lisible
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks sem';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }
}
