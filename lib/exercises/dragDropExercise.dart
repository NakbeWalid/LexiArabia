import 'package:flutter/material.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/exercise_view.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/arabic_text_style.dart';
import '../widgets/smart_question_card.dart';

/// Phrase à trou : l'utilisateur glisse (ou touche) le mot manquant
class DragDropExercise extends StatefulWidget {
  final Exercise exercise;
  final AnswerCallback onAnswered;

  const DragDropExercise({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  @override
  State<DragDropExercise> createState() => _DragDropExerciseState();
}

class _DragDropExerciseState extends State<DragDropExercise> {
  late final List<String> availableWords = List<String>.from(
    widget.exercise.options ?? const [],
  )..shuffle();
  String? _placedWord;
  bool? _isCorrect;

  bool get _answered => _isCorrect != null;

  void _placeWord(String word) {
    if (_answered) return;
    final isCorrect = word.trim() == widget.exercise.answer?.trim();
    setState(() {
      _placedWord = word;
      _isCorrect = isCorrect;
    });
    widget.onAnswered(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.exercise.answer == null ||
        widget.exercise.answer!.isEmpty ||
        availableWords.isEmpty) {
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
          padding: const EdgeInsets.fromLTRB(
            16,
            kExerciseTopSpace,
            16,
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
              const SizedBox(height: 25),
              Text(
                l10n.completeTheSentence,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1.5,
                  ),
                ),
                child: _buildSentenceWithBlank(),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),
              Text(
                l10n.dragTheCorrectWord,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 18),
              AnimationLimiter(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: [
                    for (int i = 0; i < availableWords.length; i++)
                      AnimationConfiguration.staggeredList(
                        position: i,
                        duration: const Duration(milliseconds: 500),
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: _buildWordChoice(availableWords[i]),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordChoice(String word) {
    final isUsed = _placedWord == word;
    final box = Opacity(opacity: isUsed ? 0.35 : 1.0, child: _wordBox(word));

    if (_answered) return box;

    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: () => _placeWord(word),
        child: Draggable<String>(
          data: word,
          feedback: Material(
            color: Colors.transparent,
            child: _wordBox(word, isFeedback: true),
          ),
          childWhenDragging: Opacity(opacity: 0.25, child: _wordBox(word)),
          child: box,
        ),
      ),
    );
  }

  Widget _buildSentenceWithBlank() {
    final arabicWords = _extractOrderedArabicWords();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: arabicWords.map((word) {
          if (word.contains('____')) {
            return DragTarget<String>(
              onWillAcceptWithDetails: (_) => !_answered,
              onAcceptWithDetails: (details) => _placeWord(details.data),
              builder: (context, candidateData, rejectedData) =>
                  _buildBlank(candidateData.isNotEmpty),
            );
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Text(
              word,
              textDirection: TextDirection.rtl,
              style: ArabicTextStyle.arabicText(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.95),
                height: 1.4,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBlank(bool isHovered) {
    final hasValue = _placedWord != null;
    final List<Color> colors = isHovered
        ? [Colors.amber.shade400, Colors.orange.shade500]
        : _isCorrect == true
        ? [Colors.green.shade400, Colors.green.shade600]
        : _isCorrect == false
        ? [Colors.red.shade400, Colors.red.shade600]
        : [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      constraints: const BoxConstraints(minWidth: 80, minHeight: 46),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHovered
              ? Colors.amber.shade300
              : Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Text(
        hasValue ? _placedWord! : '····',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: ArabicTextStyle.arabicText(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: hasValue ? Colors.white : Colors.white.withValues(alpha: 0.5),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _wordBox(String word, {bool isFeedback = false}) {
    final isArabic = ArabicTextStyle.isArabicText(word);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFeedback
              ? [Colors.purple.shade400, Colors.purple.shade600]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.85),
                ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        word,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        style: isArabic
            ? ArabicTextStyle.arabicText(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isFeedback ? Colors.white : Colors.grey.shade900,
                height: 1.4,
              )
            : GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isFeedback ? Colors.white : Colors.grey.shade800,
              ),
      ),
    );
  }

  List<String> _extractOrderedArabicWords() {
    // Format explicite : "sentence": "أَنْتُمَا ___"
    final sentence = widget.exercise.rawData?['sentence'];
    if (sentence is String && sentence.trim().isNotEmpty) {
      final words = sentence
          .replaceAll(RegExp(r'_{2,}'), '____')
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();
      return words.contains('____') ? words : [...words, '____'];
    }

    String raw = widget.exercise.question;

    String? translation;
    final parenMatch = RegExp(r'\(([^)]+)\)$').firstMatch(raw.trim());
    if (parenMatch != null) {
      translation = parenMatch.group(1)?.trim();
      raw = raw.substring(0, parenMatch.start).trim();
    }

    if (raw.contains(':')) {
      raw = raw.split(':')[1].trim();
    }

    raw = raw
        .replaceAll('Complete the sentence', '')
        .replaceAll(
          'Complete the blank for the distant in the beginning of Surah Al-Baqarah',
          '',
        )
        .replaceAll('Complete the phrase', '')
        .replaceAll('Fill in the blank', '')
        .replaceAll('Complétez la phrase', '')
        .trim();

    raw = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    raw = raw.replaceAll(RegExp(r'_{2,}'), '____');

    List<String> rawWords = raw.split(' ');
    List<String> arabicOnlyWords = rawWords.where((word) {
      return word.contains(RegExp(r'[\u0600-\u06FF]'));
    }).toList();

    // Déterminer si le trou '____' doit être au début (premier token RTL) ou à la fin
    // Si la traduction commence par un trou (ex: "____ is a distant mountain", "____ is my house"),
    // le trou doit être le PREMIER token (placé à droite en RTL).
    bool blankAtBeginning = false;
    if (translation != null &&
        translation.trim().startsWith(
          RegExp(r'_{2,}|\.{2,}|\-+|\((\s*_{2,}\s*)\)'),
        )) {
      blankAtBeginning = true;
    } else if (raw.trim().startsWith(RegExp(r'_{2,}|\.{2,}|\-+'))) {
      blankAtBeginning = true;
    } else if (rawWords.isNotEmpty && rawWords.first.contains('____')) {
      blankAtBeginning = true;
    }

    List<String> orderedWords;
    if (blankAtBeginning) {
      orderedWords = ['____', ...arabicOnlyWords];
    } else {
      if (raw.contains('____')) {
        orderedWords = rawWords
            .where(
              (w) =>
                  w.contains(RegExp(r'[\u0600-\u06FF]')) || w.contains('____'),
            )
            .toList();
      } else {
        orderedWords = [...arabicOnlyWords, '____'];
      }
    }

    if (orderedWords.isEmpty) {
      orderedWords = ['____'];
    }

    return orderedWords;
  }
}
