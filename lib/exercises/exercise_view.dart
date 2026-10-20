import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/audio_exercise.dart';
import 'package:dualingocoran/exercises/dragDropExercise.dart';
import 'package:dualingocoran/exercises/multiple_choice_exercise.dart';
import 'package:dualingocoran/exercises/pairs_exercise.dart';
import 'package:dualingocoran/exercises/true_false_exercise.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';

/// Signale la réponse de l'utilisateur. Appelé une seule fois par exercice :
/// le widget se verrouille ensuite et la session affiche la correction.
typedef AnswerCallback = void Function(bool isCorrect);

/// Fond commun à tous les exercices
const kExerciseBackground = LinearGradient(
  colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Espace réservé en haut pour l'en-tête de session (fermer + progression)
const double kExerciseTopSpace = 75;

/// Espace réservé en bas pour le panneau de correction
const double kExerciseBottomSpace = 200;

/// Construit le widget correspondant au type de l'exercice
Widget buildExerciseWidget({
  required Exercise exercise,
  required AnswerCallback onAnswered,
  VoidCallback? onMistake,
}) {
  switch (exercise.type) {
    case 'multiple_choice':
      return MultipleChoiceExercise(exercise: exercise, onAnswered: onAnswered);
    case 'true_false':
      return TrueFalseExercise(exercise: exercise, onAnswered: onAnswered);
    case 'audio_choice':
      return AudioExercise(exercise: exercise, onAnswered: onAnswered);
    case 'drag_drop':
      return DragDropExercise(exercise: exercise, onAnswered: onAnswered);
    case 'pairs':
      return PairsExercise(
        exercise: exercise,
        onAnswered: onAnswered,
        onMistake: onMistake,
      );
    default:
      return ExerciseMessage(
        icon: Icons.help_outline,
        messageBuilder: (l10n) => l10n.unknownExerciseType(exercise.type),
      );
  }
}

/// Texte de la bonne réponse, affiché dans le panneau en cas d'erreur
String? correctAnswerText(BuildContext context, Exercise exercise) {
  final l10n = AppLocalizations.of(context)!;
  switch (exercise.type) {
    case 'multiple_choice':
      return exercise.getTranslatedAnswer(context);
    case 'true_false':
      return isTrueAnswer(exercise) ? l10n.trueLabel : l10n.falseLabel;
    case 'audio_choice':
    case 'drag_drop':
      return exercise.answer;
    default:
      return null;
  }
}

/// Valeur attendue d'un exercice vrai/faux
bool isTrueAnswer(Exercise exercise) {
  final raw = exercise.answer?.toLowerCase().trim();
  return raw == 'true' || raw == '1' || raw == 'vrai';
}

/// Écran affiché quand un exercice ne peut pas être présenté
class ExerciseMessage extends StatelessWidget {
  final IconData icon;
  final String Function(AppLocalizations l10n) messageBuilder;

  const ExerciseMessage({
    super.key,
    required this.icon,
    required this.messageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(gradient: kExerciseBackground),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                messageBuilder(l10n),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 17, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
