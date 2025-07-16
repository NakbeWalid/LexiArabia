import 'package:flutter/material.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';

class MultipleChoiceExercise extends StatefulWidget {
  final Exercise exercise;

  const MultipleChoiceExercise({super.key, required this.exercise});

  @override
  _MultipleChoiceExerciseState createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  String? selectedOption;
  bool showFeedback = false;

  void checkAnswer(String option) {
    setState(() {
      selectedOption = option;
      showFeedback = true;
    });

    final isCorrect = option == widget.exercise.answer;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "Correct ✅" : "Incorrect ❌"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Multiple Choice")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.exercise.question,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...widget.exercise.options!.map(
              (option) => Card(
                color: selectedOption == option
                    ? (option == widget.exercise.answer
                          ? Colors.green
                          : Colors.red.shade300)
                    : null,
                child: ListTile(
                  title: Text(option),
                  onTap: selectedOption == null
                      ? () => checkAnswer(option)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
