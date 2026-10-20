import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/exercise_session.dart';
import 'package:dualingocoran/exercises/exercise_view.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:dualingocoran/screens/learning_progress_celebration_screen.dart';
import 'package:dualingocoran/services/daily_limit_service.dart';
import 'package:dualingocoran/services/fsrs_algorithm.dart';
import 'package:dualingocoran/services/learning_progress_service.dart';
import 'package:dualingocoran/services/srs_database_init.dart';
import 'package:dualingocoran/services/srs_service.dart';
import 'package:dualingocoran/services/user_provider.dart';

/// Déroulé d'une leçon : exercices + enregistrement SRS + complétion
class ExercisePage extends StatefulWidget {
  final List<Exercise> exercises;
  final String? lessonId;

  const ExercisePage({super.key, required this.exercises, this.lessonId});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  /// Créer (si besoin) la carte SRS de l'exercice et enregistrer la révision.
  /// Non bloquant : une erreur réseau ne doit pas freiner la leçon.
  Future<void> _recordSRSReview(
    int exerciseIndex,
    int mistakes,
    int timeInSeconds,
  ) async {
    if (widget.lessonId == null) return;
    try {
      final userId = Provider.of<UserProvider>(
        context,
        listen: false,
      ).currentUser?.userId;
      if (userId == null) return;

      if (!await SRSDatabaseInit.isSRSInitialized(userId)) {
        await SRSDatabaseInit.initializeSRSCollections(userId);
      }

      final srsExerciseId = await SRSService.createSRSExercise(
        userId: userId,
        lessonId: widget.lessonId!,
        exerciseIndex: exerciseIndex,
        exercise: widget.exercises[exerciseIndex],
      );

      // Première exposition au mot pendant la leçon : on plafonne à GOOD
      // pour ne pas l'envoyer directement à plusieurs jours.
      final quality = math.min(
        SRSService.qualityFromPerformance(
          mistakes: mistakes,
          timeInSeconds: timeInSeconds,
        ),
        FSRSAlgorithm.good,
      );

      await SRSService.recordReview(
        userId: userId,
        exerciseId: srsExerciseId,
        quality: quality,
        responseTime: timeInSeconds,
      );
    } catch (e) {
      print("⚠️ Erreur lors de la création/révision de l'exercice SRS: $e");
    }
  }

  Future<void> _onLessonFinished(int correctFirstTry) async {
    final total = widget.exercises.length;
    final accuracy = total > 0 ? ((correctFirstTry / total) * 100).round() : 0;

    bool isAlreadyCompleted = false;
    double percentageGained = 0.0;

    if (widget.lessonId != null) {
      isAlreadyCompleted = await LearningProgressService.isLessonCompleted(
        widget.lessonId!,
      );

      // Compteur quotidien uniquement pour une nouvelle complétion
      if (!isAlreadyCompleted) {
        await DailyLimitService.incrementLessonCount();
      }

      if (!mounted) return;
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).completeLesson(widget.lessonId!, accuracy);

      if (!isAlreadyCompleted) {
        try {
          final lessonDoc = await FirebaseFirestore.instance
              .collection('lessons')
              .doc(widget.lessonId!)
              .get();
          percentageGained =
              (lessonDoc.data()?['learningPercentage'] as num?)?.toDouble() ??
              0.0;
        } catch (e) {
          print('❌ Erreur lors de la récupération du learningPercentage: $e');
        }
      }
    }

    if (!mounted) return;

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
      return;
    }

    // Même règle que UserService.completeLesson : 50 à 150 XP, 0 si déjà faite
    final xpEarned = (widget.lessonId == null || isAlreadyCompleted)
        ? 0
        : (50 + accuracy).clamp(50, 150);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ModernCompletionDialog(
        xpEarned: xpEarned,
        accuracy: accuracy,
        onClose: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pop(true); // Retour à la roadmap
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        extendBodyBehindAppBar: true,
        body: ExerciseMessage(
          icon: Icons.assignment_outlined,
          messageBuilder: (l10n) => l10n.noExercisesAvailable,
        ),
      );
    }

    return ExerciseSession(
      exercises: widget.exercises,
      onExerciseCompleted: _recordSRSReview,
      onFinished: _onLessonFinished,
    );
  }
}

class ModernCompletionDialog extends StatelessWidget {
  final VoidCallback onClose;
  final int xpEarned;
  final int accuracy;

  const ModernCompletionDialog({
    super.key,
    required this.onClose,
    required this.xpEarned,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final streak =
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).currentUser?.stats.currentStreak ??
        0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade300, Colors.orange.shade400],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 40,
                color: Colors.white,
              ),
            ).animate().scale(delay: 200.ms).then().shake(),
            const SizedBox(height: 20),
            Text(
              l10n.lessonCompleteTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 10),
            Text(
              l10n.lessonCompleteMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(l10n.xpEarned, '+$xpEarned', Icons.star),
                _buildStat(
                  l10n.streakLabel,
                  '🔥 $streak',
                  Icons.local_fire_department,
                ),
                _buildStat(l10n.accuracy, '$accuracy%', Icons.trending_up),
              ],
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF667eea),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  l10n.continueButton,
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
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
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
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
