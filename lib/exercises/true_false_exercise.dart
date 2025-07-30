import 'package:flutter/material.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';

class TrueFalseExercise extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onNext;

  const TrueFalseExercise({
    super.key,
    required this.exercise,
    required this.onNext,
  });

  @override
  State<TrueFalseExercise> createState() => _TrueFalseExerciseState();
}

class _TrueFalseExerciseState extends State<TrueFalseExercise> {
  bool? selectedAnswer;
  bool showFeedback = false;

  @override
  void didUpdateWidget(covariant TrueFalseExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      setState(() {
        selectedAnswer = null;
        showFeedback = false;
      });
    }
  }

  void checkAnswer(bool answer) {
    setState(() {
      selectedAnswer = answer;
      showFeedback = true;
    });

    // The answer in your Exercise model is likely a String ("true"/"false") or a bool
    final correct = widget.exercise.answer == "true";
    final isCorrect = answer == correct;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "Correct ✅" : "Incorrect ❌"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
      ),
    );

    Future.delayed(const Duration(milliseconds: 800), widget.onNext);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("True or False"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.exercise.question,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(true, "True", Colors.green),
                _buildButton(false, "False", Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(bool value, String label, Color color) {
    final isSelected = selectedAnswer == value;
    return ElevatedButton(
      onPressed: selectedAnswer == null ? () => checkAnswer(value) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey.shade800,
        foregroundColor: Colors.white,
        minimumSize: const Size(120, 60),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isSelected ? 6 : 2,
      ),
      child: Text(label),
    );
  }
}
