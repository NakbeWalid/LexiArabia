import 'package:flutter/material.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/multiple_choice_exercise.dart';
import 'package:dualingocoran/exercises/audio_exercise.dart';
import 'package:dualingocoran/exercises/drag_drop_exercise.dart';
import 'package:dualingocoran/exercises/true_false_exercise.dart'; // à décommenter si tu as ce fichier

class ExercisePage extends StatefulWidget {
  final List<Exercise> exercises;

  const ExercisePage({super.key, required this.exercises});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  int currentIndex = 0;

  void nextExercise() {
    if (currentIndex < widget.exercises.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      // Tous les exercices sont faits
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Well done!"),
          content: const Text("You’ve completed all the exercises."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have valid exercises
    if (widget.exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Exercises")),
        body: Center(
          child: Text("No exercises available", style: TextStyle(fontSize: 18)),
        ),
      );
    }

    final exercise = widget.exercises[currentIndex];

    // Déclaration + assignation
    Widget exerciseWidget;

    switch (exercise.type) {
      case 'multiple_choice':
        exerciseWidget = MultipleChoiceExercise(
          exercise: exercise,
          onNext: nextExercise,
        );
        break;
      case 'true_false':
        exerciseWidget = TrueFalseExercise(
          exercise: exercise,
          onNext: nextExercise,
        );
        break;
      case 'audio_choice':
        exerciseWidget = AudioExercise(
          exercise: exercise,
          onNext: nextExercise,
        );
        break;
      case 'drag_drop':
        exerciseWidget = DragDropExercise(
          exercise: exercise,
          onNext: nextExercise,
        );
        break;
      default:
        exerciseWidget = const Center(child: Text("Unknown exercise type"));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Exercise ${currentIndex + 1}/${widget.exercises.length}"),
      ),
      body: exerciseWidget,
    );
  }
}
