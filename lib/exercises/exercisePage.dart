import 'package:flutter/material.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/multipleChoiceExercise.dart';
import 'package:dualingocoran/exercises/audio_exercise.dart';
import 'package:dualingocoran/exercises/dragDropExercise.dart';

//import 'package:dualingocoran/exercises/trueFalseExercise.dart'; // Assuming you
class ExercisePage extends StatelessWidget {
  final Exercise exercise;

  const ExercisePage({required this.exercise, super.key});

  @override
  Widget build(BuildContext context) {
    switch (exercise.type) {
      case 'multiple_choice':
        return MultipleChoiceExercise(exercise: exercise);
      case 'true_false':
      //return TrueFalseExercise(exercise: exercise);
      case 'audio_choice':
        return AudioExercise(exercise: exercise);
      case 'drag_drop':
        return DragDropExercise(exercise: exercise);
      default:
        return Center(child: Text("Unknown exercise type"));
    }
  }
}
