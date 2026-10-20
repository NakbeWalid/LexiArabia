import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/exercise_view.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/arabic_text_style.dart';
import '../widgets/smart_question_card.dart';

/// Associer chaque terme à sa traduction.
/// Une paire correcte se verrouille en vert ; une paire fausse clignote en
/// rouge et compte comme une erreur. L'exercice est réussi quand tout est associé.
class PairsExercise extends StatefulWidget {
  final Exercise exercise;
  final AnswerCallback onAnswered;

  /// Appelé à chaque mauvaise association
  final VoidCallback? onMistake;

  const PairsExercise({
    super.key,
    required this.exercise,
    required this.onAnswered,
    this.onMistake,
  });

  @override
  State<PairsExercise> createState() => _PairsExerciseState();
}

class _PairsExerciseState extends State<PairsExercise> {
  final Map<String, String> _correctPairs = {}; // gauche → droite
  final List<String> _leftItems = [];
  final List<String> _rightItems = [];
  final Set<String> _matchedLeft = {};
  final Set<String> _matchedRight = {};
  final Set<String> _wrongFlash = {};
  String? _selectedLeft;
  String? _selectedRight;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    // Les traductions dépendent de la langue de l'app (context requis)
    final pairs =
        widget.exercise.getTranslatedPairs(context) ??
        widget.exercise.dragDropPairs ??
        [];
    for (final pair in pairs) {
      final from = pair['from']?.toString() ?? '';
      final to = pair['to']?.toString() ?? '';
      if (from.isEmpty || to.isEmpty || _correctPairs.containsKey(from)) {
        continue;
      }
      _correctPairs[from] = to;
      _leftItems.add(from);
      _rightItems.add(to);
    }
    _leftItems.shuffle();
    _rightItems.shuffle();
  }

  void _onTap(String item, bool isLeft) {
    if (_wrongFlash.isNotEmpty) return;
    if (isLeft ? _matchedLeft.contains(item) : _matchedRight.contains(item)) {
      return;
    }
    HapticFeedback.selectionClick();

    setState(() {
      if (isLeft) {
        _selectedLeft = _selectedLeft == item ? null : item;
      } else {
        _selectedRight = _selectedRight == item ? null : item;
      }
    });

    if (_selectedLeft != null && _selectedRight != null) _checkPair();
  }

  void _checkPair() {
    final left = _selectedLeft!;
    final right = _selectedRight!;

    if (_correctPairs[left] == right) {
      setState(() {
        _matchedLeft.add(left);
        _matchedRight.add(right);
        _selectedLeft = null;
        _selectedRight = null;
      });
      if (_matchedLeft.length == _correctPairs.length) {
        widget.onAnswered(true);
      } else {
        HapticFeedback.lightImpact();
      }
      return;
    }

    HapticFeedback.mediumImpact();
    widget.onMistake?.call();
    setState(() {
      _wrongFlash
        ..add(left)
        ..add(right);
    });
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() {
        _wrongFlash.clear();
        _selectedLeft = null;
        _selectedRight = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_correctPairs.isEmpty) {
      return ExerciseMessage(
        icon: Icons.error_outline,
        messageBuilder: (l10n) => l10n.invalidExerciseData,
      );
    }

    final question = widget.exercise.getTranslatedQuestion(context);

    return Container(
      decoration: const BoxDecoration(gradient: kExerciseBackground),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: kExerciseTopSpace),
            SmartQuestionCard(
                  question: question.isNotEmpty ? question : l10n.matchThePairs,
                )
                .animate()
                .fadeIn(delay: 200.ms)
                .scale(begin: const Offset(0.96, 0.96)),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  0,
                  12,
                  kExerciseBottomSpace,
                ),
                child: AnimationLimiter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildColumn(_leftItems, true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildColumn(_rightItems, false)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(List<String> items, bool isLeft) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          AnimationConfiguration.staggeredList(
            position: i,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              horizontalOffset: isLeft ? -40 : 40,
              child: FadeInAnimation(child: _buildItem(items[i], isLeft)),
            ),
          ),
      ],
    );
  }

  Widget _buildItem(String item, bool isLeft) {
    final isMatched = isLeft
        ? _matchedLeft.contains(item)
        : _matchedRight.contains(item);
    final isSelected = isLeft ? _selectedLeft == item : _selectedRight == item;
    final isWrong = _wrongFlash.contains(item);

    final Color background;
    final Color border;
    final Color textColor;
    if (isWrong) {
      background = Colors.red.shade500;
      border = Colors.red.shade200;
      textColor = Colors.white;
    } else if (isMatched) {
      background = Colors.green.shade600.withValues(alpha: 0.35);
      border = Colors.green.shade300.withValues(alpha: 0.5);
      textColor = Colors.white.withValues(alpha: 0.6);
    } else if (isSelected) {
      background = Colors.amber.shade400;
      border = Colors.amber.shade200;
      textColor = Colors.grey.shade900;
    } else {
      background = Colors.white.withValues(alpha: 0.92);
      border = Colors.transparent;
      textColor = Colors.grey.shade900;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Semantics(
        button: true,
        selected: isSelected,
        child: GestureDetector(
          onTap: () => _onTap(item, isLeft),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 2),
              boxShadow: isMatched
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: ArabicText(
              item,
              textAlign: TextAlign.center,
              style: ArabicTextStyle.smartStyle(
                item,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    ).animate(target: isWrong ? 1 : 0).shakeX(hz: 5, amount: 4);
  }
}
