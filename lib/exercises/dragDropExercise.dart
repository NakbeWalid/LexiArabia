import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';

class DragDropExercise extends StatefulWidget {
  final Exercise exercise;

  const DragDropExercise({super.key, required this.exercise});

  @override
  State<DragDropExercise> createState() => _DragDropExerciseState();
}

class _DragDropExerciseState extends State<DragDropExercise> {
  List<String> targetList = [];
  List<String> remainingList = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    final correctWord = widget.exercise.answer!;
    targetList = List.filled(correctWord.length, "");
    remainingList = correctWord.split('')..shuffle();
  }

  void handleDrop(int index, String letter) async {
    setState(() {
      targetList[index] = letter;
      remainingList.remove(letter);
    });

    if (!targetList.contains("")) {
      final result = targetList.join() == widget.exercise.answer;

      await _audioPlayer.play(
        AssetSource(result ? 'sounds/correct.mp3' : 'sounds/wrong.mp3'),
      );
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ? "Correct ✅" : "Incorrect ❌"),
          backgroundColor: result ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void reset() {
    setState(() {
      final correctWord = widget.exercise.answer!;
      targetList = List.filled(correctWord.length, "");
      remainingList = correctWord.split('')..shuffle();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Drag & Drop")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              widget.exercise.question,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Zones de dépôt
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(targetList.length, (index) {
                final current = targetList[index];
                return DragTarget<String>(
                  builder: (context, candidateData, rejectedData) {
                    return _letterBox(current);
                  },
                  onAccept: (letter) => handleDrop(index, letter),
                  onWillAccept: (_) => targetList[index] == "",
                );
              }),
            ),
            SizedBox(height: 30),

            // Lettres disponibles
            Wrap(
              spacing: 10,
              children: remainingList.map((letter) {
                return Draggable<String>(
                  data: letter,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _letterBox(letter, isFeedback: true),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _letterBox(letter),
                  ),
                  child: _letterBox(letter),
                );
              }).toList(),
            ),
            SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: reset,
              icon: Icon(Icons.refresh),
              label: Text("Reset"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _letterBox(String letter, {bool isFeedback = false}) {
    return Container(
      width: 50,
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFeedback ? Colors.deepPurple.shade100 : Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isFeedback ? Colors.deepPurple : Colors.black,
        ),
      ),
    );
  }
}
