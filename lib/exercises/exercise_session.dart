import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/exercise_view.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:dualingocoran/services/pronunciation_service.dart';
import 'package:dualingocoran/services/sound_service.dart';
import 'package:dualingocoran/widgets/answer_feedback_panel.dart';

/// Déroulé d'une série d'exercices, façon Duolingo :
/// - l'utilisateur répond, un panneau de correction apparaît en bas ;
/// - "Continuer" passe à l'exercice suivant ;
/// - un exercice raté est reposé à la fin de la série.
class ExerciseSession extends StatefulWidget {
  final List<Exercise> exercises;

  /// Appelé quand un exercice est enfin réussi (non bloquant).
  /// [mistakes] = erreurs commises avant la bonne réponse.
  final void Function(int exerciseIndex, int mistakes, int timeInSeconds)
  onExerciseCompleted;

  /// Appelé une fois tous les exercices réussis.
  /// [correctFirstTry] = exercices réussis sans erreur.
  final Future<void> Function(int correctFirstTry) onFinished;

  const ExerciseSession({
    super.key,
    required this.exercises,
    required this.onExerciseCompleted,
    required this.onFinished,
  });

  @override
  State<ExerciseSession> createState() => _ExerciseSessionState();
}

class _ExerciseSessionState extends State<ExerciseSession> {
  late final List<int> _queue = List.generate(
    widget.exercises.length,
    (i) => i,
  );
  int _position = 0;
  final Set<int> _completed = {};
  final Map<int, int> _mistakes = {};
  int _correctFirstTry = 0;
  DateTime _startTime = DateTime.now();
  bool _soundEnabled = true;
  bool _finishing = false;

  /// null = pas de correction affichée
  bool? _answerCorrect;
  int _praiseIndex = 0;

  int get _currentIndex => _queue[_position];

  @override
  void initState() {
    super.initState();
    SoundService.isSoundEnabled().then((enabled) {
      if (mounted) setState(() => _soundEnabled = enabled);
    });
  }

  @override
  void dispose() {
    PronunciationService.stop();
    super.dispose();
  }

  void _onAnswered(bool isCorrect) {
    if (_answerCorrect != null) return;
    if (!isCorrect) {
      _mistakes[_currentIndex] = (_mistakes[_currentIndex] ?? 0) + 1;
    }
    SoundService.playFeedback(isCorrect);
    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
    setState(() {
      _answerCorrect = isCorrect;
      _praiseIndex = math.Random().nextInt(3);
    });
  }

  /// Erreur intermédiaire (ex. mauvaise paire) qui ne termine pas l'exercice
  void _onMistake() {
    _mistakes[_currentIndex] = (_mistakes[_currentIndex] ?? 0) + 1;
    SoundService.playFeedback(false);
  }

  Future<void> _continue() async {
    final index = _currentIndex;
    final wasCorrect = _answerCorrect ?? false;

    if (wasCorrect) {
      _completed.add(index);
      final mistakes = _mistakes[index] ?? 0;
      if (mistakes == 0) _correctFirstTry++;
      widget.onExerciseCompleted(
        index,
        mistakes,
        DateTime.now().difference(_startTime).inSeconds,
      );
    } else {
      // Exercice raté : on le repose à la fin de la série
      _queue.add(index);
    }

    PronunciationService.stop();

    if (_position >= _queue.length - 1) {
      setState(() {
        _finishing = true;
        _answerCorrect = null;
      });
      HapticFeedback.heavyImpact();
      await widget.onFinished(_correctFirstTry);
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _position++;
      _answerCorrect = null;
      _startTime = DateTime.now();
    });
  }

  Future<void> _close() async {
    if (_completed.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          l10n.quitSessionTitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          l10n.quitSessionMessage,
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.quit,
              style: GoogleFonts.poppins(color: Colors.redAccent),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.keepLearning, style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
    if (shouldQuit == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _toggleSound() async {
    final enabled = await SoundService.toggleSound();
    if (mounted) setState(() => _soundEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exercise = widget.exercises[_currentIndex];
    final total = widget.exercises.length;
    final progress = total == 0 ? 0.0 : _completed.length / total;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_finishing) _close();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Exercice courant (clé unique par passage pour repartir d'un état neuf)
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_position),
                  child: buildExerciseWidget(
                    exercise: exercise,
                    onAnswered: _onAnswered,
                    onMistake: _onMistake,
                  ),
                ),
              ),
            ),

            // En-tête : fermer, progression, son
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _finishing ? null : _close,
                          tooltip: l10n.quit,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(end: progress),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) => ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 12,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.15,
                                ),
                                valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFF4ADE80),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleSound,
                          tooltip: _soundEnabled ? l10n.soundOff : l10n.soundOn,
                          icon: Icon(
                            _soundEnabled ? Icons.volume_up : Icons.volume_off,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Panneau de correction
            if (_answerCorrect != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnswerFeedbackPanel(
                  isCorrect: _answerCorrect!,
                  correctAnswer: correctAnswerText(context, exercise),
                  willRetryLater: !_answerCorrect!,
                  praiseIndex: _praiseIndex,
                  onContinue: _continue,
                ),
              ),

            if (_finishing)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black38,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
