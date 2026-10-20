import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/exercise_session.dart';
import 'package:dualingocoran/exercises/exercise_view.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:dualingocoran/models/srs_exercise_model.dart';
import 'package:dualingocoran/services/srs_database_init.dart';
import 'package:dualingocoran/services/srs_service.dart';
import 'package:dualingocoran/services/user_provider.dart';

/// Écran pour réviser les exercices SRS
class SRSReviewScreen extends StatefulWidget {
  const SRSReviewScreen({super.key});

  @override
  State<SRSReviewScreen> createState() => _SRSReviewScreenState();
}

class _SRSReviewScreenState extends State<SRSReviewScreen> {
  List<SRSExercise> _srsExercises = [];
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final userId = Provider.of<UserProvider>(
        context,
        listen: false,
      ).currentUser?.userId;

      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      if (!await SRSDatabaseInit.isSRSInitialized(userId)) {
        await SRSDatabaseInit.initializeSRSCollections(userId);
      }

      // Limite quotidienne stricte, priorisation des éléments les plus
      // fragiles et répartition du retard après une absence
      final settings = await SRSService.getSettings(userId);
      final dueExercises = await SRSService.getDueExercises(
        userId,
        smoothBacklog: true,
      );
      // Moins de nouveaux éléments quand il y a beaucoup de révisions dues
      final newLimit = SRSService.computeDailyNewLimit(
        settings: settings,
        dueSelectedCount: dueExercises.length,
      );
      final newExercises = await SRSService.getNewExercises(
        userId,
        limitOverride: newLimit,
      );

      // Déduplication stricte (par ID et par contenu)
      final seenIds = <String>{};
      final seenContent = <String>{};
      final unique = <SRSExercise>[];
      for (final srsEx in [...newExercises, ...dueExercises]) {
        final q = srsEx.exerciseData['question']?.toString() ?? '';
        final a = srsEx.exerciseData['answer']?.toString() ?? '';
        final contentKey = '$q|$a|${srsEx.exerciseType}';
        if (seenIds.add(srsEx.exerciseId) && seenContent.add(contentKey)) {
          unique.add(srsEx);
        }
      }

      if (!mounted) return;
      setState(() {
        _srsExercises = unique;
        _exercises = unique.map(_convertSRSToExercise).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur lors du chargement des exercices SRS: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Convertir un SRSExercise en Exercise pour l'affichage.
  /// Réutilise Exercise.fromJson pour accepter exactement les mêmes formats
  /// que les leçons (traductions, pairs en List ou Map, "choices"...).
  Exercise _convertSRSToExercise(SRSExercise srsExercise) {
    final data = Map<String, dynamic>.from(srsExercise.exerciseData);
    data['type'] = srsExercise.exerciseType;

    // Anciennes cartes sans "pairs" : utiliser dragDropPairs sauvegardé
    if (data['pairs'] == null && data['dragDropPairs'] is List) {
      data['pairs'] = data['dragDropPairs'];
    }

    return Exercise.fromJson(data);
  }

  /// Notation automatique d'un exercice réussi (non bloquant)
  Future<void> _recordReview(int index, int mistakes, int timeInSeconds) async {
    try {
      final userId = Provider.of<UserProvider>(
        context,
        listen: false,
      ).currentUser?.userId;
      if (userId == null) return;

      await SRSService.recordReview(
        userId: userId,
        exerciseId: _srsExercises[index].exerciseId,
        quality: SRSService.qualityFromPerformance(
          mistakes: mistakes,
          timeInSeconds: timeInSeconds,
        ),
        responseTime: timeInSeconds,
      );
    } catch (e) {
      print("❌ Erreur lors de l'enregistrement de la révision: $e");
    }
  }

  Future<void> _showCompletionDialog(int _) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, size: 64, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                l10n.srsDoneTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.srsDoneMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF667eea),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n.continueButton,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_started && _exercises.isNotEmpty) {
      return ExerciseSession(
        exercises: _exercises,
        onExerciseCompleted: _recordReview,
        onFinished: _showCompletionDialog,
      );
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kExerciseBackground),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  tooltip: l10n.back,
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _exercises.isEmpty
                    ? _buildMessage(
                        icon: Icons.check_circle_outline,
                        title: l10n.srsEmptyTitle,
                        subtitle: l10n.srsEmptyMessage,
                      )
                    : _buildMessage(
                        icon: Icons.replay_circle_filled_rounded,
                        title: l10n.srsIntroTitle,
                        subtitle: l10n.srsIntroSubtitle(_exercises.length),
                        action: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => setState(() => _started = true),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(l10n.startReview.toUpperCase()),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 88,
            color: const Color(0xFFD4AF37),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          if (action != null) ...[const SizedBox(height: 36), action],
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
