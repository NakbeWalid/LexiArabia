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
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ExercisePage extends StatefulWidget {
  final List<Exercise> exercises;
  final String? lessonId;

  const ExercisePage({
    super.key,
    required this.exercises,
    this.lessonId,
  });

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
  }

  @override
  void dispose() {
    _progressController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void nextExercise({bool? wasCorrect}) async {
    // Enregistrer la réponse si fournie
    if (wasCorrect != null) {
      setState(() {
        totalAnswers++;
        if (wasCorrect) {
          correctAnswers++;
        }
      });
    }

    if (currentIndex < widget.exercises.length - 1) {
      // Animate progress update
      if (mounted) await _progressController.forward();

      setState(() {
        currentIndex++;
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

      // Incrémenter le compteur de leçons complétées aujourd'hui
      await DailyLimitService.incrementLessonCount();

      // Marquer la leçon comme complétée dans UserProvider si lessonId est fourni
      // Le champ 'completed' sera créé dans users/{userId}/progress/lessons/{lessonId}/completed
      if (widget.lessonId != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final accuracy = widget.exercises.length > 0
            ? ((correctAnswers / widget.exercises.length) * 100).round()
            : 0;
        await userProvider.completeLesson(widget.lessonId!, accuracy);
      }

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
          onNext: (isCorrect) => nextExercise(wasCorrect: isCorrect),
        );
        break;
      case 'true_false':
        exerciseWidget = TrueFalseExercise(
          exercise: exercise,
          onNext: (isCorrect) => nextExercise(wasCorrect: isCorrect),
        );
        break;
      case 'audio_choice':
        exerciseWidget = AudioExercise(
          exercise: exercise,
          onNext: (isCorrect) => nextExercise(wasCorrect: isCorrect),
        );
        break;
      case 'drag_drop':
        exerciseWidget = DragDropExercise(
          exercise: exercise,
          onNext: (isCorrect) => nextExercise(wasCorrect: isCorrect),
        );
        break;
      case 'pairs':
        exerciseWidget = PairsExercise(
          exercise: exercise,
          onNext: (isCorrect) => nextExercise(wasCorrect: isCorrect),
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
                      // Header with back button and progress
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
                _buildStat("Streak", streak > 0 ? "🔥 $streak" : "🔥 0", Icons.local_fire_department),
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
