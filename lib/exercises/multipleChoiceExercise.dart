import 'package:flutter/material.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MultipleChoiceExercise extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onNext;

  const MultipleChoiceExercise({
    super.key,
    required this.exercise,
    required this.onNext,
  });

  @override
  _MultipleChoiceExerciseState createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  String? selectedOption;
  bool showFeedback = false;

  void checkAnswer(String option) async {
    setState(() {
      selectedOption = option;
      showFeedback = true;
    });

    final isCorrect = option == widget.exercise.answer;
    if (isCorrect) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('user_123')
          .update({
            'xp': FieldValue.increment(10), // +10 XP par bonne réponse
            'streak': FieldValue.increment(
              1,
            ), // streak +1 par session (améliorable)
          });
    }
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
      appBar: AppBar(
        title: Text(
          "Multiple Choice",
          style: TextStyle(
            fontFamily: 'Poppins', // ✅ Police personnalisée (voir plus bas)
            fontSize: 20, // ✅ Taille de la police
            fontWeight: FontWeight.bold, // ✅ Gras
            color: Colors.white, // ✅ Couleur du texte
          ),
        ),
        centerTitle: true,
      ),

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
