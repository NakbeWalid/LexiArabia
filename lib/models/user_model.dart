import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final UserProfile profile;
  final UserStats stats;
  final UserProgress progress;
  final Map<String, UserAchievement> achievements;
  final List<StudySession> studySessions;
  final Map<String, DailyProgress> dailyProgress;

  UserModel({
    required this.userId,
    required this.profile,
    required this.stats,
    required this.progress,
    required this.achievements,
    required this.studySessions,
    required this.dailyProgress,
  });

  factory UserModel.fromMap(String userId, Map<String, dynamic> data) {
    return UserModel(
      userId: userId,
      profile: UserProfile.fromMap(data['profile'] ?? {}),
      stats: UserStats.fromMap(data['stats'] ?? {}),
      progress: UserProgress.fromMap(data['progress'] ?? {}),
      achievements: (data['achievements'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, UserAchievement.fromMap(value)),
      ),
      studySessions: (data['studySessions'] as List<dynamic>? ?? [])
          .map((session) => StudySession.fromMap(session))
          .toList(),
      dailyProgress: () {
        final dp = data['dailyProgress'] as Map<String, dynamic>? ?? {};
        // dailyProgress peut avoir deux structures :
        // 1. Ancienne structure : Map<date, DailyProgress> avec lessonsCompleted, etc.
        // 2. Nouvelle structure : {lastLessonDate: string, lessonsCompletedToday: int} (au niveau racine)
        if (dp.containsKey('lastLessonDate') ||
            dp.containsKey('lessonsCompletedToday')) {
          // C'est la nouvelle structure - ne pas la traiter comme une map de DailyProgress
          // Retourner une map vide car cette structure est gérée directement par DailyLimitService
          return <String, DailyProgress>{};
        }
        // Ancienne structure : map de dates vers DailyProgress
        return dp.map((key, value) {
          if (value is Map<String, dynamic>) {
            return MapEntry(key, DailyProgress.fromMap(value));
          }
          return MapEntry(key, DailyProgress.fromMap({}));
        });
      }(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile': profile.toMap(),
      'stats': stats.toMap(),
      'progress': progress.toMap(),
      'achievements': achievements.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'studySessions': studySessions.map((session) => session.toMap()).toList(),
      'dailyProgress': dailyProgress.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
    };
  }
}

class UserProfile {
  final String username;
  final String email;
  final String? avatarUrl;
  final String displayName;
  final String? bio;
  final String nativeLanguage;
  final String learningLanguage;
  final DateTime createdAt;
  final DateTime lastActive;

  UserProfile({
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.displayName,
    this.bio,
    required this.nativeLanguage,
    required this.learningLanguage,
    required this.createdAt,
    required this.lastActive,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    DateTime? parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return null;
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is DateTime) {
        return timestamp;
      }
      return null;
    }

    return UserProfile(
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
      displayName: data['displayName'] ?? data['username'] ?? '',
      bio: data['bio'],
      nativeLanguage: data['nativeLanguage'] ?? 'en',
      learningLanguage: data['learningLanguage'] ?? 'ar',
      createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
      lastActive: parseTimestamp(data['lastActive']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'displayName': displayName,
      'bio': bio,
      'nativeLanguage': nativeLanguage,
      'learningLanguage': learningLanguage,
      'createdAt': createdAt,
      'lastActive': lastActive,
    };
  }
}

class UserStats {
  final int totalXP;
  final int currentLevel;
  final int currentStreak;
  final int bestStreak;
  final int lessonsCompleted;
  final int totalLessons;
  final int exercisesCompleted;
  final int wordsLearned;
  final double accuracy;
  final int totalStudyTime; // en minutes

  UserStats({
    required this.totalXP,
    required this.currentLevel,
    required this.currentStreak,
    required this.bestStreak,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.exercisesCompleted,
    required this.wordsLearned,
    required this.accuracy,
    required this.totalStudyTime,
  });

  factory UserStats.fromMap(Map<String, dynamic> data) {
    return UserStats(
      totalXP: data['totalXP'] ?? 0,
      currentLevel: data['currentLevel'] ?? 1,
      currentStreak: data['currentStreak'] ?? 0,
      bestStreak: data['bestStreak'] ?? 0,
      lessonsCompleted: data['lessonsCompleted'] ?? 0,
      totalLessons: data['totalLessons'] ?? 0,
      exercisesCompleted: data['exercisesCompleted'] ?? 0,
      wordsLearned: data['wordsLearned'] ?? 0,
      accuracy: (data['accuracy'] ?? 0).toDouble(),
      totalStudyTime: data['totalStudyTime'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalXP': totalXP,
      'currentLevel': currentLevel,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lessonsCompleted': lessonsCompleted,
      'totalLessons': totalLessons,
      'exercisesCompleted': exercisesCompleted,
      'wordsLearned': wordsLearned,
      'accuracy': accuracy,
      'totalStudyTime': totalStudyTime,
    };
  }

  double get progressToNextLevel => (totalXP % 1000) / 1000;
  int get xpToNextLevel => 1000 - (totalXP % 1000);
}

class UserProgress {
  final Map<String, LessonProgress> lessons;
  final Map<String, SectionProgress> sections;

  UserProgress({required this.lessons, required this.sections});

  factory UserProgress.fromMap(Map<String, dynamic> data) {
    return UserProgress(
      lessons: (data['lessons'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, LessonProgress.fromMap(value)),
      ),
      sections: (data['sections'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, SectionProgress.fromMap(value)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessons': lessons.map((key, value) => MapEntry(key, value.toMap())),
      'sections': sections.map((key, value) => MapEntry(key, value.toMap())),
    };
  }
}

class LessonProgress {
  final bool completed;
  final DateTime? completedAt;
  final int score;
  final int attempts;
  final int bestScore;

  LessonProgress({
    required this.completed,
    this.completedAt,
    required this.score,
    required this.attempts,
    required this.bestScore,
  });

  factory LessonProgress.fromMap(Map<String, dynamic> data) {
    DateTime? parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return null;
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is DateTime) {
        return timestamp;
      }
      return null;
    }

    return LessonProgress(
      completed: data['completed'] ?? false,
      completedAt: parseTimestamp(data['completedAt']),
      score: data['score'] ?? 0,
      attempts: data['attempts'] ?? 0,
      bestScore: data['bestScore'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'completed': completed,
      'completedAt': completedAt,
      'score': score,
      'attempts': attempts,
      'bestScore': bestScore,
    };
  }
}

class SectionProgress {
  final bool completed;
  final DateTime? completedAt;
  final int lessonsCompleted;
  final int totalLessons;

  SectionProgress({
    required this.completed,
    this.completedAt,
    required this.lessonsCompleted,
    required this.totalLessons,
  });

  factory SectionProgress.fromMap(Map<String, dynamic> data) {
    DateTime? parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return null;
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is DateTime) {
        return timestamp;
      }
      return null;
    }

    return SectionProgress(
      completed: data['completed'] ?? false,
      completedAt: parseTimestamp(data['completedAt']),
      lessonsCompleted: data['lessonsCompleted'] ?? 0,
      totalLessons: data['totalLessons'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'completed': completed,
      'completedAt': completedAt,
      'lessonsCompleted': lessonsCompleted,
      'totalLessons': totalLessons,
    };
  }
}

class UserAchievement {
  final bool unlocked;
  final DateTime? unlockedAt;
  final int progress;

  UserAchievement({
    required this.unlocked,
    this.unlockedAt,
    required this.progress,
  });

  factory UserAchievement.fromMap(Map<String, dynamic> data) {
    DateTime? parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return null;
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is DateTime) {
        return timestamp;
      }
      return null;
    }

    return UserAchievement(
      unlocked: data['unlocked'] ?? false,
      unlockedAt: parseTimestamp(data['unlockedAt']),
      progress: data['progress'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unlocked': unlocked,
      'unlockedAt': unlockedAt,
      'progress': progress,
    };
  }
}

class StudySession {
  final String sessionId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int duration; // en minutes
  final List<String> lessonsStudied;
  final int exercisesCompleted;
  final int xpEarned;

  StudySession({
    required this.sessionId,
    required this.startedAt,
    this.endedAt,
    required this.duration,
    required this.lessonsStudied,
    required this.exercisesCompleted,
    required this.xpEarned,
  });

  factory StudySession.fromMap(Map<String, dynamic> data) {
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

    DateTime? parseTimestampNullable(dynamic timestamp) {
      if (timestamp == null) return null;
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is DateTime) {
        return timestamp;
      }
      return null;
    }

    return StudySession(
      sessionId: data['sessionId'] ?? '',
      startedAt: parseTimestamp(data['startedAt']),
      endedAt: parseTimestampNullable(data['endedAt']),
      duration: data['duration'] ?? 0,
      lessonsStudied: List<String>.from(data['lessonsStudied'] ?? []),
      exercisesCompleted: data['exercisesCompleted'] ?? 0,
      xpEarned: data['xpEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'duration': duration,
      'lessonsStudied': lessonsStudied,
      'exercisesCompleted': exercisesCompleted,
      'xpEarned': xpEarned,
    };
  }
}

class DailyProgress {
  final int lessonsCompleted;
  final int exercisesCompleted;
  final int xpEarned;
  final int studyTime; // en minutes
  final bool streakMaintained;

  DailyProgress({
    required this.lessonsCompleted,
    required this.exercisesCompleted,
    required this.xpEarned,
    required this.studyTime,
    required this.streakMaintained,
  });

  factory DailyProgress.fromMap(Map<String, dynamic> data) {
    return DailyProgress(
      lessonsCompleted: data['lessonsCompleted'] ?? 0,
      exercisesCompleted: data['exercisesCompleted'] ?? 0,
      xpEarned: data['xpEarned'] ?? 0,
      studyTime: data['studyTime'] ?? 0,
      streakMaintained: data['streakMaintained'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonsCompleted': lessonsCompleted,
      'exercisesCompleted': exercisesCompleted,
      'xpEarned': xpEarned,
      'studyTime': studyTime,
      'streakMaintained': streakMaintained,
    };
  }
}
