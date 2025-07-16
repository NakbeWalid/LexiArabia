import 'package:flutter/material.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';

class AudioExercise extends StatelessWidget {
  final Exercise exercise;

  const AudioExercise({required this.exercise, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(exercise.question),
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () {
            // joue l’audio depuis exercise.audioUrl
          },
        ),
        ...exercise.options!.map(
          (option) => ElevatedButton(
            onPressed: () {
              // vérifie
            },
            child: Text(option),
          ),
        ),
      ],
    );
  }
}
