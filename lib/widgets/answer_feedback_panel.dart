import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:dualingocoran/utils/arabic_text_style.dart';

/// Panneau de correction affiché en bas de l'écran après une réponse
/// (style Duolingo) : message, bonne réponse en cas d'erreur, bouton Continuer.
class AnswerFeedbackPanel extends StatelessWidget {
  final bool isCorrect;
  final String? correctAnswer;
  final bool willRetryLater;
  final VoidCallback onContinue;

  /// Choix du message d'encouragement (fixé par l'appelant pour rester stable)
  final int praiseIndex;

  const AnswerFeedbackPanel({
    super.key,
    required this.isCorrect,
    required this.onContinue,
    this.correctAnswer,
    this.willRetryLater = false,
    this.praiseIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = isCorrect
        ? const Color(0xFF4ADE80)
        : const Color(0xFFF87171);
    final background = isCorrect
        ? const Color(0xFF12301F)
        : const Color(0xFF3A161B);
    final title = isCorrect ? _praise(l10n) : l10n.feedbackIncorrect;
    final showAnswer =
        !isCorrect && correctAnswer != null && correctAnswer!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: accent.withValues(alpha: 0.6), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCorrect ? Icons.check_rounded : Icons.close_rounded,
                    color: accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
            if (showAnswer) ...[
              const SizedBox(height: 12),
              Text(
                l10n.correctAnswerLabel,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accent.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 2),
              ArabicText(
                correctAnswer!,
                style: ArabicTextStyle.smartStyle(
                  correctAnswer!,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
            if (willRetryLater) ...[
              const SizedBox(height: 6),
              Text(
                l10n.feedbackRetryLater,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: const Color(0xFF0F0C29),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.continueButton.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(
      begin: 1,
      end: 0,
      duration: 260.ms,
      curve: Curves.easeOutCubic,
    );
  }

  String _praise(AppLocalizations l10n) {
    final options = [
      l10n.feedbackCorrect1,
      l10n.feedbackCorrect2,
      l10n.feedbackCorrect3,
    ];
    return options[praiseIndex % options.length];
  }
}
