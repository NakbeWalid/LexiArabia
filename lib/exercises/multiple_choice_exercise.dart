import 'package:flutter/material.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/exercise_view.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/arabic_text_style.dart';
import '../widgets/smart_question_card.dart';

class MultipleChoiceExercise extends StatefulWidget {
  final Exercise exercise;
  final AnswerCallback onAnswered;

  const MultipleChoiceExercise({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  @override
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  String? selectedOption;
  bool get _answered => selectedOption != null;

  void _checkAnswer(String option) {
    if (_answered) return;
    final isCorrect = option == widget.exercise.getTranslatedAnswer(context);
    setState(() => selectedOption = option);
    widget.onAnswered(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = widget.exercise.getTranslatedOptions(context);
    final question = widget.exercise.getTranslatedQuestion(context);
    final answer = widget.exercise.getTranslatedAnswer(context);

    if (options.isEmpty) {
      return ExerciseMessage(
        icon: Icons.error_outline,
        messageBuilder: (l10n) => l10n.invalidExerciseData,
      );
    }

    return Container(
      decoration: const BoxDecoration(gradient: kExerciseBackground),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: kExerciseTopSpace),
            SmartQuestionCard(question: question)
                .animate()
                .fadeIn(delay: 200.ms)
                .scale(begin: const Offset(0.96, 0.96)),
            const SizedBox(height: 12),
            Text(
              l10n.chooseCorrectAnswer,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    kExerciseBottomSpace,
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 40,
                        child: FadeInAnimation(
                          child: _buildOption(option, index, option == answer),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String option, int index, bool isCorrect) {
    final isSelected = selectedOption == option;
    // Après la réponse : choix de l'utilisateur en vert/rouge,
    // et la bonne réponse toujours surlignée en vert.
    final showCorrect = _answered && isCorrect;
    final showWrong = _answered && isSelected && !isCorrect;
    final highlighted = showCorrect || showWrong;

    final List<Color> colors = showCorrect
        ? [Colors.green.shade400, Colors.green.shade600]
        : showWrong
        ? [Colors.red.shade400, Colors.red.shade600]
        : [
            Colors.white.withValues(alpha: _answered ? 0.6 : 0.92),
            Colors.white.withValues(alpha: _answered ? 0.45 : 0.75),
          ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Semantics(
        button: true,
        selected: isSelected,
        child: GestureDetector(
          onTap: _answered ? null : () => _checkAnswer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: highlighted
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.grey.shade300,
                  ),
                  child: Center(
                    child: highlighted
                        ? Icon(
                            showCorrect ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 22,
                          )
                        : Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ArabicText(
                    option,
                    style: ArabicTextStyle.smartStyle(
                      option,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: highlighted ? Colors.white : Colors.grey.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
