import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dualingocoran/services/srs_service.dart';
import 'package:dualingocoran/services/user_provider.dart';
import 'package:dualingocoran/services/srs_database_init.dart';
import 'package:dualingocoran/models/srs_exercise_model.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/multiple_choice_exercise.dart';
import 'package:dualingocoran/exercises/true_false_exercise.dart';
import 'package:dualingocoran/exercises/audio_exercise.dart';
import 'package:dualingocoran/exercises/dragDropExercise.dart';
import 'package:dualingocoran/exercises/pairs_exercise.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Écran pour réviser les exercices SRS
class SRSReviewScreen extends StatefulWidget {
  const SRSReviewScreen({super.key});

  @override
  State<SRSReviewScreen> createState() => _SRSReviewScreenState();
}

class _SRSReviewScreenState extends State<SRSReviewScreen> {
  List<SRSExercise> _dueExercises = [];
  List<SRSExercise> _newExercises = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _showIntro = true;
  Map<String, Exercise> _exerciseCache = {}; // Cache pour les exercices
  Map<String, DateTime> _exerciseStartTimes =
      {}; // exerciseId -> temps de début
  Map<String, int> _exerciseAttempts = {}; // exerciseId -> nombre d'essais

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.userId;

      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // S'assurer que SRS est initialisé
      if (!await SRSDatabaseInit.isSRSInitialized(userId)) {
        await SRSDatabaseInit.initializeSRSCollections(userId);
      }

      // Charger les exercices à réviser avec:
      // - Limite quotidienne stricte (10–15 recommandé, 15 par défaut)
      // - Priorisation (le plus ancien / oublié)
      // - Répartition après absence (backlog smoothing)
      final settings = await SRSService.getSettings(userId);
      final dueExercises = await SRSService.getDueExercises(
        userId,
        smoothBacklog: true,
      );

      // Option B (Duolingo-like): réduire les "new" quand il y a beaucoup de due
      final newLimit = SRSService.computeDailyNewLimit(
        settings: settings,
        dueSelectedCount: dueExercises.length,
      );
      final newExercises = await SRSService.getNewExercises(
        userId,
        limitOverride: newLimit,
      );

      // Convertir les exercices SRS en objets Exercise pour l'affichage
      for (final srsExercise in [...dueExercises, ...newExercises]) {
        final exercise = _convertSRSToExercise(srsExercise);
        _exerciseCache[srsExercise.exerciseId] = exercise;
        // Initialiser le tracking pour chaque exercice
        _exerciseStartTimes[srsExercise.exerciseId] = DateTime.now();
        _exerciseAttempts[srsExercise.exerciseId] = 0;
      }

      setState(() {
        _dueExercises = dueExercises;
        _newExercises = newExercises;
        _isLoading = false;
      });

      // Petite intro UX (affichée une seule fois au début de la session)
      if (mounted && (dueExercises.isNotEmpty || newExercises.isNotEmpty)) {
        Future.delayed(const Duration(milliseconds: 2600), () {
          if (mounted) {
            setState(() {
              _showIntro = false;
            });
          }
        });
      } else if (mounted) {
        setState(() {
          _showIntro = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des exercices SRS: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Convertir un SRSExercise en Exercise pour l'affichage
  Exercise _convertSRSToExercise(SRSExercise srsExercise) {
    final exerciseData = srsExercise.exerciseData;

    // Extraire la question (peut être String ou Map avec traductions)
    String question = '';
    if (exerciseData['question'] != null) {
      if (exerciseData['question'] is Map) {
        // C'est une Map de traductions, prendre l'anglais comme fallback
        final questionMap = exerciseData['question'] as Map<String, dynamic>;
        question =
            questionMap['en']?.toString() ??
            questionMap['fr']?.toString() ??
            questionMap['ar']?.toString() ??
            questionMap.values.first?.toString() ??
            '';
      } else {
        question = exerciseData['question'].toString();
      }
    }

    // Extraire la réponse (peut être String ou Map avec traductions)
    String? answer;
    if (exerciseData['answer'] != null) {
      if (exerciseData['answer'] is Map) {
        final answerMap = exerciseData['answer'] as Map<String, dynamic>;
        answer =
            answerMap['en']?.toString() ??
            answerMap['fr']?.toString() ??
            answerMap['ar']?.toString() ??
            answerMap.values.first?.toString();
      } else {
        answer = exerciseData['answer'].toString();
      }
    }

    // Extraire les options (peut être List ou Map avec traductions)
    List<String>? options;
    if (exerciseData['options'] != null) {
      if (exerciseData['options'] is List) {
        options = List<String>.from(exerciseData['options']);
      } else if (exerciseData['options'] is Map) {
        // C'est une Map de traductions, prendre l'anglais comme fallback
        final optionsMap = exerciseData['options'] as Map<String, dynamic>;
        if (optionsMap['en'] is List) {
          options = (optionsMap['en'] as List)
              .map((e) => e.toString())
              .toList();
        } else if (optionsMap['fr'] is List) {
          options = (optionsMap['fr'] as List)
              .map((e) => e.toString())
              .toList();
        } else if (optionsMap['ar'] is List) {
          options = (optionsMap['ar'] as List)
              .map((e) => e.toString())
              .toList();
        }
      }
    }

    // Extraire les dragDropPairs (peut être directement dragDropPairs ou pairs à convertir)
    List<Map<String, dynamic>>? dragDropPairs;
    if (exerciseData['dragDropPairs'] != null) {
      // Si dragDropPairs existe déjà, l'utiliser directement
      dragDropPairs = List<Map<String, dynamic>>.from(
        exerciseData['dragDropPairs'],
      );
    } else if (exerciseData['pairs'] != null &&
        (srsExercise.exerciseType == 'pairs' ||
            srsExercise.exerciseType == 'drag_drop')) {
      // Si pairs existe, le convertir en dragDropPairs (comme dans Exercise.fromJson)
      print('🔄 Converting pairs to dragDropPairs for SRS exercise');
      if (exerciseData['pairs'] is List) {
        // Nouvelle structure: pairs est un tableau d'objets avec from et to
        List<dynamic> pairsList = exerciseData['pairs'] as List;
        dragDropPairs = pairsList
            .where(
              (pair) =>
                  pair is Map && pair['from'] != null && pair['to'] != null,
            )
            .map(
              (pair) => {
                'from': pair['from'].toString(),
                'to': pair['to'].toString(),
              },
            )
            .toList();
        print('✅ Converted ${dragDropPairs.length} pairs from List format');
      } else if (exerciseData['pairs'] is Map) {
        // Ancienne structure: pairs est un Map
        Map<String, dynamic> pairs =
            exerciseData['pairs'] as Map<String, dynamic>;
        dragDropPairs = pairs.entries
            .map((e) => {'from': e.key, 'to': e.value.toString()})
            .toList();
        print('✅ Converted ${dragDropPairs.length} pairs from Map format');
      }
    }

    return Exercise(
      type: srsExercise.exerciseType,
      question: question,
      options: options,
      answer: answer,
      audioUrl: exerciseData['audioUrl'],
      dragDropPairs: dragDropPairs,
      rawData:
          exerciseData, // IMPORTANT: Garder les données brutes pour les traductions
    );
  }

  /// Obtenir tous les exercices à réviser (nouveaux + à réviser)
  List<SRSExercise> get _allExercises => [..._newExercises, ..._dueExercises];

  /// Calculer automatiquement la qualité (1-3) basée sur le nombre d'essais et le temps
  /// IMPORTANT: Dans notre UX, l'utilisateur ne passe pas au prochain exercice tant qu'il n'a pas réussi.
  /// Donc "AGAIN" (0) n'est pas utilisé: on mappe le pire cas vers HARD (1).
  int _calculateQuality(int attempts, int timeInSeconds) {
    const int fastTimeThreshold = 10;
    const int slowTimeThreshold = 30;
    const int perfectAttempts = 1;
    const int goodAttempts = 2;
    const int hardAttempts = 3;

    if (attempts == perfectAttempts && timeInSeconds <= fastTimeThreshold) {
      return 3; // EASY
    } else if (attempts == perfectAttempts &&
        timeInSeconds <= slowTimeThreshold) {
      return 2; // GOOD
    } else if (attempts <= goodAttempts && timeInSeconds <= slowTimeThreshold) {
      return 2; // GOOD
    } else if (attempts <= hardAttempts) {
      return 1; // HARD
    } else {
      return 1; // HARD (pire cas)
    }
  }

  /// Gérer la notation automatique d'un exercice
  Future<void> _handleAutomaticRating(
    String exerciseId,
    bool wasCorrect,
  ) async {
    if (!wasCorrect) return; // Ne pas enregistrer si incorrect

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.userId;

      if (userId == null) return;

      // Calculer la qualité automatiquement
      final attempts = _exerciseAttempts[exerciseId] ?? 1;
      final startTime = _exerciseStartTimes[exerciseId] ?? DateTime.now();
      final timeInSeconds = DateTime.now().difference(startTime).inSeconds;
      final quality = _calculateQuality(attempts, timeInSeconds);

      // Enregistrer la révision
      await SRSService.recordReview(
        userId: userId,
        exerciseId: exerciseId,
        quality: quality,
        responseTime: timeInSeconds,
      );

      print(
        '✅ Révision SRS automatique: exercice $exerciseId, qualité $quality (essais: $attempts, temps: ${timeInSeconds}s)',
      );

      // Passer à l'exercice suivant après un court délai
      await Future.delayed(const Duration(milliseconds: 500));

      if (_currentIndex < _allExercises.length - 1) {
        setState(() {
          _currentIndex++;
          // Initialiser le tracking pour le prochain exercice
          final nextExerciseId = _allExercises[_currentIndex].exerciseId;
          _exerciseStartTimes[nextExerciseId] = DateTime.now();
          _exerciseAttempts[nextExerciseId] = 0;
        });
        HapticFeedback.selectionClick();
      } else {
        // Tous les exercices sont révisés
        HapticFeedback.heavyImpact();
        _showCompletionDialog();
      }
    } catch (e) {
      print('❌ Erreur lors de l\'enregistrement de la révision: $e');
    }
  }

  /// Afficher le dialogue de complétion
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.celebration, size: 64, color: Colors.white),
              SizedBox(height: 20),
              Text(
                "Great Job! 🎉",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "You've completed all reviews for today!",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Return to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF667eea),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text(
                  "Continue",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    if (_allExercises.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          "SRS Review",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "No reviews for today! 🎉",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Come back tomorrow for more reviews",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentSRSExercise = _allExercises[_currentIndex];
    final currentExercise = _exerciseCache[currentSRSExercise.exerciseId];

    if (currentExercise == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            ),
          ),
          child: Center(
            child: Text(
              "Error loading exercise",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ),
      );
    }

    // Obtenir le widget d'exercice approprié
    Widget exerciseWidget;
    switch (currentExercise.type) {
      case 'multiple_choice':
        exerciseWidget = MultipleChoiceExercise(
          exercise: currentExercise,
          onNext: (isCorrect) {
            setState(() {
              _exerciseAttempts[currentSRSExercise.exerciseId] =
                  (_exerciseAttempts[currentSRSExercise.exerciseId] ?? 0) + 1;
            });
            _handleAutomaticRating(currentSRSExercise.exerciseId, isCorrect);
          },
        );
        break;
      case 'true_false':
        exerciseWidget = TrueFalseExercise(
          exercise: currentExercise,
          onNext: (isCorrect) {
            setState(() {
              _exerciseAttempts[currentSRSExercise.exerciseId] =
                  (_exerciseAttempts[currentSRSExercise.exerciseId] ?? 0) + 1;
            });
            _handleAutomaticRating(currentSRSExercise.exerciseId, isCorrect);
          },
        );
        break;
      case 'audio_choice':
        exerciseWidget = AudioExercise(
          exercise: currentExercise,
          onNext: (isCorrect) {
            setState(() {
              _exerciseAttempts[currentSRSExercise.exerciseId] =
                  (_exerciseAttempts[currentSRSExercise.exerciseId] ?? 0) + 1;
            });
            _handleAutomaticRating(currentSRSExercise.exerciseId, isCorrect);
          },
        );
        break;
      case 'drag_drop':
        exerciseWidget = DragDropExercise(
          exercise: currentExercise,
          onNext: (isCorrect) {
            setState(() {
              _exerciseAttempts[currentSRSExercise.exerciseId] =
                  (_exerciseAttempts[currentSRSExercise.exerciseId] ?? 0) + 1;
            });
            _handleAutomaticRating(currentSRSExercise.exerciseId, isCorrect);
          },
        );
        break;
      case 'pairs':
        exerciseWidget = PairsExercise(
          exercise: currentExercise,
          onNext: (isCorrect) {
            setState(() {
              _exerciseAttempts[currentSRSExercise.exerciseId] =
                  (_exerciseAttempts[currentSRSExercise.exerciseId] ?? 0) + 1;
            });
            _handleAutomaticRating(currentSRSExercise.exerciseId, isCorrect);
          },
        );
        break;
      default:
        exerciseWidget = Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            ),
          ),
          child: Center(
            child: Text(
              "Unknown exercise type: ${currentExercise.type}",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main exercise content
          exerciseWidget,

          // Progress overlay
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
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.white, size: 28),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            if (_showIntro) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.18),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "C'est le temps de réviser tes mots !!",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Fais une petite session — ça prend 2 minutes.",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn().slideY(begin: -0.15),
                              const SizedBox(height: 10),
                            ],
                            Text(
                              "Review ${_currentIndex + 1} of ${_allExercises.length}",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: FractionallySizedBox(
                                  widthFactor:
                                      (_currentIndex + 1) /
                                      _allExercises.length,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.greenAccent,
                                          Colors.blue.shade400,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.5),
        ],
      ),
    );
  }
}
