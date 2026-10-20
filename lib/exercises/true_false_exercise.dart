import 'package:flutter/material.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/exercise_view.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/smart_question_card.dart';

class TrueFalseExercise extends StatefulWidget {
  final Exercise exercise;
  final AnswerCallback onAnswered;

  const TrueFalseExercise({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  @override
  State<TrueFalseExercise> createState() => _TrueFalseExerciseState();
}

class _TrueFalseExerciseState extends State<TrueFalseExercise> {
  bool? selectedAnswer;
  bool get _answered => selectedAnswer != null;

  void _checkAnswer(bool answer) {
    if (_answered) return;
    setState(() => selectedAnswer = answer);
    widget.onAnswered(answer == isTrueAnswer(widget.exercise));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(gradient: kExerciseBackground),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            kExerciseTopSpace,
            20,
            kExerciseBottomSpace,
          ),
          child: Column(
            children: [
              SmartQuestionCard(
                    question: widget.exercise.getTranslatedQuestion(context),
                    margin: EdgeInsets.zero,
                  )
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .scale(begin: const Offset(0.96, 0.96)),
              const SizedBox(height: 40),
              Text(
                l10n.trueOrFalseHint,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      true,
                      l10n.trueLabel,
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.3),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildButton(
                      false,
                      l10n.falseLabel,
                    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(bool value, String label) {
    final isSelected = selectedAnswer == value;
    final isCorrect = value == isTrueAnswer(widget.exercise);
    final showCorrect = _answered && isCorrect;
    final showWrong = _answered && isSelected && !isCorrect;

    final List<Color> colors = showCorrect
        ? [Colors.green.shade400, Colors.green.shade600]
        : showWrong
        ? [Colors.red.shade400, Colors.red.shade600]
        : [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ];

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: _answered ? null : () => _checkAnswer(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                showCorrect
                    ? Icons.check_circle
                    : showWrong
                    ? Icons.cancel
                    : (value ? Icons.check : Icons.close),
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
