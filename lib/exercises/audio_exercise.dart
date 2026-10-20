import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/exercise_view.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:dualingocoran/services/pronunciation_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/arabic_text_style.dart';
import '../widgets/smart_question_card.dart';

class AudioExercise extends StatefulWidget {
  final Exercise exercise;
  final AnswerCallback onAnswered;

  const AudioExercise({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  @override
  State<AudioExercise> createState() => _AudioExerciseState();
}

class _AudioExerciseState extends State<AudioExercise> {
  String? selectedOption;
  bool _audioUnavailable = false;
  bool get _answered => selectedOption != null;

  @override
  void initState() {
    super.initState();
    // Comme Duolingo : l'audio se lance automatiquement à l'affichage
    WidgetsBinding.instance.addPostFrameCallback((_) => _playAudio());
  }

  Future<void> _playAudio() async {
    HapticFeedback.selectionClick();
    final played = await PronunciationService.speak(
      audioUrl: widget.exercise.audioUrl,
      text: widget.exercise.answer,
    );
    if (mounted && played == _audioUnavailable) {
      setState(() => _audioUnavailable = !played);
    }
  }

  void _checkAnswer(String option) {
    if (_answered) return;
    setState(() => selectedOption = option);
    widget.onAnswered(option == widget.exercise.answer);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = widget.exercise.options ?? [];

    if (options.isEmpty) {
      return ExerciseMessage(
        icon: Icons.error_outline,
        messageBuilder: (l10n) => l10n.invalidExerciseData,
      );
    }

    return Container(
      decoration: const BoxDecoration(gradient: kExerciseBackground),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            top: kExerciseTopSpace,
            bottom: kExerciseBottomSpace,
          ),
          child: Column(
            children: [
              SmartQuestionCard(
                    question: widget.exercise.getTranslatedQuestion(context),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .scale(begin: const Offset(0.96, 0.96)),
              const SizedBox(height: 25),
              Text(
                l10n.listenToAudio,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildPlayButton(l10n).animate().fadeIn(delay: 300.ms).scale(),
              if (_audioUnavailable) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    l10n.audioUnavailable,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.orange.shade200,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 26),
              Text(
                l10n.chooseWhatYouHeard,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimationLimiter(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.25,
                        ),
                    itemCount: options.length,
                    itemBuilder: (context, index) =>
                        AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          columnCount: 2,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: _buildOption(options[index]),
                            ),
                          ),
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

  Widget _buildPlayButton(AppLocalizations l10n) {
    return ValueListenableBuilder<bool>(
      valueListenable: PronunciationService.isPlaying,
      builder: (context, isPlaying, _) => Semantics(
        button: true,
        label: l10n.playAudio,
        child: GestureDetector(
          onTap: _playAudio,
          child: AnimatedScale(
            scale: isPlaying ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isPlaying
                      ? [Colors.purple.shade400, Colors.pink.shade400]
                      : [Colors.blue.shade400, Colors.purple.shade400],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String option) {
    final isSelected = selectedOption == option;
    final isCorrect = option == widget.exercise.answer;
    final showCorrect = _answered && isCorrect;
    final showWrong = _answered && isSelected && !isCorrect;

    final List<Color> colors = showCorrect
        ? [Colors.green.shade400, Colors.green.shade600]
        : showWrong
        ? [Colors.red.shade400, Colors.red.shade600]
        : [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ];

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: _answered ? null : () => _checkAnswer(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                showCorrect
                    ? Icons.check_circle_rounded
                    : showWrong
                    ? Icons.cancel_rounded
                    : Icons.hearing_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 26,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ArabicText(
                  option,
                  style: ArabicTextStyle.smartStyle(
                    option,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
