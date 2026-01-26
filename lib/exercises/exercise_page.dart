import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/multiple_choice_exercise.dart';
import 'package:dualingocoran/exercises/audio_exercise.dart';
import 'package:dualingocoran/exercises/dragDropExercise.dart';
import 'package:dualingocoran/exercises/pairs_exercise.dart';
import 'package:dualingocoran/exercises/true_false_exercise.dart';
import 'package:dualingocoran/services/daily_limit_service.dart';
import 'package:dualingocoran/services/user_provider.dart';
import 'package:dualingocoran/services/srs_service.dart';
import 'package:dualingocoran/services/srs_database_init.dart';
import 'package:dualingocoran/services/sound_service.dart';
import 'package:dualingocoran/services/learning_progress_service.dart';
import 'package:dualingocoran/screens/learning_progress_celebration_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ExercisePage extends StatefulWidget {
  final List<Exercise> exercises;
  final String? lessonId;

  const ExercisePage({super.key, required this.exercises, this.lessonId});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  late AnimationController _progressController;
  late AnimationController _celebrationController;
  int correctAnswers = 0;
  int totalAnswers = 0;

  // SRS: Stocker les IDs des exercices SRS créés
  Map<int, String> srsExerciseIds = {}; // index -> exerciseId SRS

  // Tracking pour notation automatique
  Map<int, DateTime> exerciseStartTimes = {}; // index -> temps de début
  Map<int, int> exerciseAttempts = {}; // index -> nombre d'essais

  // État du son
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    if (mounted) _progressController.forward();

    // Initialiser le tracking pour le premier exercice
    exerciseStartTimes[0] = DateTime.now();
    exerciseAttempts[0] = 0;

    // Charger l'état du son
    _loadSoundState();
  }

  Future<void> _loadSoundState() async {
    final enabled = await SoundService.isSoundEnabled();
    if (mounted) {
      setState(() {
        _soundEnabled = enabled;
      });
    }
  }

  Future<void> _toggleSound() async {
    final newState = await SoundService.toggleSound();
    if (mounted) {
      setState(() {
        _soundEnabled = newState;
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  /// Calculer automatiquement la qualité (1-3) basée sur le nombre d'essais et le temps
  /// IMPORTANT: Dans notre UX, l'utilisateur ne peut pas passer à l'exercice suivant tant qu'il n'a pas réussi,
  /// donc "AGAIN" (0) n'est pas pertinent ici.
  /// 1 = HARD (difficile)
  /// 2 = GOOD (bon)
  /// 3 = EASY (facile)
  int _calculateQuality(int attempts, int timeInSeconds) {
    // Seuil de temps (en secondes) pour considérer un exercice comme rapide
    const int fastTimeThreshold = 10; // 10 secondes = rapide
    const int slowTimeThreshold = 30; // 30 secondes = lent

    // Seuil d'essais
    const int perfectAttempts = 1; // 1 essai = parfait
    const int goodAttempts = 2; // 2 essais = bon
    const int hardAttempts = 3; // 3 essais = difficile

    // Logique de calcul
    if (attempts == perfectAttempts && timeInSeconds <= fastTimeThreshold) {
      // 1 essai et rapide = EASY (3)
      return 3;
    } else if (attempts == perfectAttempts &&
        timeInSeconds <= slowTimeThreshold) {
      // 1 essai mais plus lent = GOOD (2)
      return 2;
    } else if (attempts <= goodAttempts && timeInSeconds <= slowTimeThreshold) {
      // 2 essais max et pas trop lent = GOOD (2)
      return 2;
    } else if (attempts <= hardAttempts) {
      // 3 essais max = HARD (1)
      return 1;
    } else {
      // Plus de 3 essais = HARD (1)
      return 1;
    }
  }

  void nextExercise({
    bool? wasCorrect,
    int? attempts,
    int? timeInSeconds,
  }) async {
    // Enregistrer la réponse si fournie
    if (wasCorrect != null) {
      setState(() {
        totalAnswers++;
        if (wasCorrect) {
          correctAnswers++;
        }
      });

      // Créer un exercice SRS si la réponse est correcte et qu'on a un lessonId
      if (wasCorrect && widget.lessonId != null) {
        try {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final userId = userProvider.currentUser?.userId;

          if (userId != null) {
            // S'assurer que SRS est initialisé
            if (!await SRSDatabaseInit.isSRSInitialized(userId)) {
              await SRSDatabaseInit.initializeSRSCollections(userId);
            }

            // Créer l'exercice SRS
            final currentExercise = widget.exercises[currentIndex];
            final srsExerciseId = await SRSService.createSRSExercise(
              userId: userId,
              lessonId: widget.lessonId!,
              exerciseIndex: currentIndex,
              exercise: currentExercise,
            );

            // Stocker l'ID
            setState(() {
              srsExerciseIds[currentIndex] = srsExerciseId;
            });

            // Calculer la qualité automatiquement
            final attemptsCount =
                attempts ?? exerciseAttempts[currentIndex] ?? 1;
            final timeSeconds =
                timeInSeconds ??
                (exerciseStartTimes[currentIndex] != null
                    ? DateTime.now()
                          .difference(exerciseStartTimes[currentIndex]!)
                          .inSeconds
                    : 10);

            final quality = _calculateQuality(attemptsCount, timeSeconds);

            // Enregistrer automatiquement la révision avec la qualité calculée
            await SRSService.recordReview(
              userId: userId,
              exerciseId: srsExerciseId,
              quality: quality,
              responseTime: timeSeconds,
            );

            print(
              '✅ Exercice SRS créé et révisé automatiquement: exercice $currentIndex, qualité $quality (essais: $attemptsCount, temps: ${timeSeconds}s)',
            );
          }
        } catch (e) {
          print(
            '⚠️ Erreur lors de la création/révision de l\'exercice SRS: $e',
          );
          // Ne pas bloquer le flux si la création SRS échoue
        }
      }
    }

    if (currentIndex < widget.exercises.length - 1) {
      // Animate progress update
      if (mounted) await _progressController.forward();

      setState(() {
        currentIndex++;
        // Initialiser le tracking pour le prochain exercice
        exerciseStartTimes[currentIndex] = DateTime.now();
        exerciseAttempts[currentIndex] = 0;
      });

      // Reset and animate for next exercise
      if (mounted) _progressController.reset();
      if (mounted) _progressController.forward();

      HapticFeedback.selectionClick();
    } else {
      // All exercises completed - show celebration
      if (mounted) _celebrationController.forward();
      HapticFeedback.heavyImpact();

      await Future.delayed(const Duration(milliseconds: 200));

      // Vérifier si la leçon est déjà complétée
      bool isAlreadyCompleted = false;
      if (widget.lessonId != null) {
        isAlreadyCompleted = await LearningProgressService.isLessonCompleted(
          widget.lessonId!,
        );
      }

      // Incrémenter le compteur de leçons complétées aujourd'hui seulement si nouvelle complétion
      if (!isAlreadyCompleted) {
        await DailyLimitService.incrementLessonCount();
      }

      // Récupérer le pourcentage d'apprentissage gagné
      double percentageGained = 0.0;

      if (widget.lessonId != null) {
        // Marquer la leçon comme complétée dans UserProvider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final accuracy = widget.exercises.length > 0
            ? ((correctAnswers / widget.exercises.length) * 100).round()
            : 0;
        await userProvider.completeLesson(widget.lessonId!, accuracy);

        // Récupérer le learningPercentage de la leçon depuis Firestore
        // Seulement si la leçon n'était pas déjà complétée
        if (!isAlreadyCompleted) {
          try {
            final lessonDoc = await FirebaseFirestore.instance
                .collection('lessons')
                .doc(widget.lessonId!)
                .get();

            if (lessonDoc.exists) {
              final lessonData = lessonDoc.data();
              percentageGained =
                  (lessonData?['learningPercentage'] as num?)?.toDouble() ??
                  0.0;
            }
          } catch (e) {
            print('❌ Erreur lors de la récupération du learningPercentage: $e');
          }
        }
      }

      // Naviguer vers la page de célébration seulement si nouvelle complétion
      if (widget.lessonId != null &&
          percentageGained > 0 &&
          !isAlreadyCompleted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LearningProgressCelebrationScreen(
              lessonId: widget.lessonId!,
              percentageGained: percentageGained,
            ),
          ),
        );
      } else {
        // Si pas de lessonId, pas de pourcentage, ou déjà complétée, utiliser l'ancien dialogue
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ModernCompletionDialog(
            totalExercises: widget.exercises.length,
            correctAnswers: correctAnswers,
            onClose: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Return to roadmap with result
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have valid exercises
    if (widget.exercises.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 80,
                  color: Colors.white.withOpacity(0.5),
                ),
                SizedBox(height: 20),
                Text(
                  "No exercises available",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final exercise = widget.exercises[currentIndex];
    final progress = (currentIndex + 1) / widget.exercises.length;

    // Get exercise widget
    Widget exerciseWidget;
    switch (exercise.type) {
      case 'multiple_choice':
        exerciseWidget = MultipleChoiceExercise(
          exercise: exercise,
          onNext: (isCorrect) {
            // Incrémenter le nombre d'essais
            setState(() {
              exerciseAttempts[currentIndex] =
                  (exerciseAttempts[currentIndex] ?? 0) + 1;
            });
            // Calculer le temps écoulé
            final startTime =
                exerciseStartTimes[currentIndex] ?? DateTime.now();
            final timeInSeconds = DateTime.now()
                .difference(startTime)
                .inSeconds;
            final attempts = exerciseAttempts[currentIndex] ?? 1;
            nextExercise(
              wasCorrect: isCorrect,
              attempts: attempts,
              timeInSeconds: timeInSeconds,
            );
          },
        );
        break;
      case 'true_false':
        exerciseWidget = TrueFalseExercise(
          exercise: exercise,
          onNext: (isCorrect) {
            setState(() {
              exerciseAttempts[currentIndex] =
                  (exerciseAttempts[currentIndex] ?? 0) + 1;
            });
            final startTime =
                exerciseStartTimes[currentIndex] ?? DateTime.now();
            final timeInSeconds = DateTime.now()
                .difference(startTime)
                .inSeconds;
            final attempts = exerciseAttempts[currentIndex] ?? 1;
            nextExercise(
              wasCorrect: isCorrect,
              attempts: attempts,
              timeInSeconds: timeInSeconds,
            );
          },
        );
        break;
      case 'audio_choice':
        exerciseWidget = AudioExercise(
          exercise: exercise,
          onNext: (isCorrect) {
            setState(() {
              exerciseAttempts[currentIndex] =
                  (exerciseAttempts[currentIndex] ?? 0) + 1;
            });
            final startTime =
                exerciseStartTimes[currentIndex] ?? DateTime.now();
            final timeInSeconds = DateTime.now()
                .difference(startTime)
                .inSeconds;
            final attempts = exerciseAttempts[currentIndex] ?? 1;
            nextExercise(
              wasCorrect: isCorrect,
              attempts: attempts,
              timeInSeconds: timeInSeconds,
            );
          },
        );
        break;
      case 'drag_drop':
        exerciseWidget = DragDropExercise(
          exercise: exercise,
          onNext: (isCorrect) {
            setState(() {
              exerciseAttempts[currentIndex] =
                  (exerciseAttempts[currentIndex] ?? 0) + 1;
            });
            final startTime =
                exerciseStartTimes[currentIndex] ?? DateTime.now();
            final timeInSeconds = DateTime.now()
                .difference(startTime)
                .inSeconds;
            final attempts = exerciseAttempts[currentIndex] ?? 1;
            nextExercise(
              wasCorrect: isCorrect,
              attempts: attempts,
              timeInSeconds: timeInSeconds,
            );
          },
        );
        break;
      case 'pairs':
        exerciseWidget = PairsExercise(
          exercise: exercise,
          onNext: (isCorrect) {
            setState(() {
              exerciseAttempts[currentIndex] =
                  (exerciseAttempts[currentIndex] ?? 0) + 1;
            });
            final startTime =
                exerciseStartTimes[currentIndex] ?? DateTime.now();
            final timeInSeconds = DateTime.now()
                .difference(startTime)
                .inSeconds;
            final attempts = exerciseAttempts[currentIndex] ?? 1;
            nextExercise(
              wasCorrect: isCorrect,
              attempts: attempts,
              timeInSeconds: timeInSeconds,
            );
          },
        );
        break;
      default:
        exerciseWidget = Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.help_outline,
                  size: 80,
                  color: Colors.white.withOpacity(0.5),
                ),
                SizedBox(height: 20),
                Text(
                  "Unknown exercise type: ${exercise.type}",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main exercise content
          exerciseWidget,

          // Modern progress overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Header with back button, sound control, and progress
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                // Progress text
                                Text(
                                  "${currentIndex + 1} of ${widget.exercises.length}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),

                                // Progress bar
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 800),
                                      curve: Curves.easeInOut,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.6 *
                                          progress,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.greenAccent,
                                            Colors.blue.shade400,
                                            Colors.purple.shade400,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Sound control button
                          IconButton(
                            onPressed: _toggleSound,
                            icon: Icon(
                              _soundEnabled
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              color: Colors.white,
                              size: 28,
                            ),
                            tooltip: _soundEnabled
                                ? 'Désactiver le son'
                                : 'Activer le son',
                          ),
                          // XP indicator
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade400,
                                  Colors.orange.shade400,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  "${(currentIndex + 1) * 10} XP",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.5),

          // Celebration overlay
          if (_celebrationController.isAnimating)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.celebration,
                        size: 100,
                        color: Colors.amber,
                      ).animate().scale(delay: 200.ms).then().shake(),
                      SizedBox(height: 20),
                      Text(
                        "Lesson Complete!",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ModernCompletionDialog extends StatelessWidget {
  final VoidCallback onClose;
  final int totalExercises;
  final int correctAnswers;

  const ModernCompletionDialog({
    super.key,
    required this.onClose,
    required this.totalExercises,
    required this.correctAnswers,
  });

  @override
  Widget build(BuildContext context) {
    // Calculer les statistiques réelles
    final xpEarned = totalExercises * 10; // 10 XP par exercice
    final accuracy = totalExercises > 0
        ? ((correctAnswers / totalExercises) * 100).round()
        : 0;

    // Récupérer la streak depuis UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final streak = userProvider.currentUser?.stats.currentStreak ?? 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade300, Colors.orange.shade400],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Icons.emoji_events, size: 40, color: Colors.white),
            ).animate().scale(delay: 200.ms).then().shake(),

            SizedBox(height: 20),

            // Title
            Text(
              "Excellent Work!",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 400.ms),

            SizedBox(height: 10),

            // Subtitle
            Text(
              "You've completed all exercises\nin this lesson! 🎉",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 600.ms),

            SizedBox(height: 30),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat("XP Earned", "$xpEarned", Icons.star),
                _buildStat(
                  "Streak",
                  streak > 0 ? "🔥 $streak" : "🔥 0",
                  Icons.local_fire_department,
                ),
                _buildStat("Accuracy", "$accuracy%", Icons.trending_up),
              ],
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),

            SizedBox(height: 30),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF667eea),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  "Continue Learning",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 1000.ms).scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
