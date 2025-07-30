import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';

class DragDropExercise extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onNext;

  const DragDropExercise({
    super.key,
    required this.exercise,
    required this.onNext,
  });

  @override
  State<DragDropExercise> createState() => _DragDropExerciseState();
}

class _DragDropExerciseState extends State<DragDropExercise> {
  List<String> targetList = [];
  List<String> remainingList = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Variables pour drag_drop avec pairs
  Map<String, String> correctPairs = {};
  Map<String, String> userPairs = {};
  List<String> draggableItems = [];
  List<String> targetItems = [];

  @override
  void initState() {
    super.initState();
    _initializeExercise();
  }

  void _initializeExercise() {
    // Si c'est un drag_drop avec pairs
    if (widget.exercise.dragDropPairs != null &&
        widget.exercise.dragDropPairs!.isNotEmpty) {
      correctPairs.clear();
      userPairs.clear();
      draggableItems.clear();
      targetItems.clear();

      for (var pair in widget.exercise.dragDropPairs!) {
        final from = pair['from']?.toString() ?? '';
        final to = pair['to']?.toString() ?? '';
        if (from.isNotEmpty && to.isNotEmpty) {
          correctPairs[from] = to;
          draggableItems.add(from);
          targetItems.add(to);
        }
      }
      draggableItems.shuffle();
      targetItems.shuffle();
    } else {
      // Mode classique avec answer
      final correctWord = widget.exercise.answer ?? '';
      if (correctWord.isNotEmpty) {
        targetList = List.filled(correctWord.length, "");
        remainingList = correctWord.split('')..shuffle();
      }
    }
  }

  @override
  void didUpdateWidget(covariant DragDropExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      _initializeExercise();
      setState(() {});
    }
  }

  void handleDrop(int index, String? letter) async {
    if (letter == null) return;

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

      Future.delayed(const Duration(milliseconds: 800), widget.onNext);
    }
  }

  void handlePairDrop(String target, String? draggable) async {
    if (draggable == null) return;

    setState(() {
      // Enlève l'ancien mapping si il existe
      userPairs.removeWhere((key, value) => value == target);
      userPairs.removeWhere((key, value) => key == draggable);

      // Ajoute le nouveau mapping
      userPairs[draggable] = target;
    });

    // Vérifie si tous les pairs sont complétés
    if (userPairs.length == correctPairs.length) {
      bool allCorrect = true;
      for (var entry in userPairs.entries) {
        if (correctPairs[entry.key] != entry.value) {
          allCorrect = false;
          break;
        }
      }

      await _audioPlayer.play(
        AssetSource(allCorrect ? 'sounds/correct.mp3' : 'sounds/wrong.mp3'),
      );
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(allCorrect ? "Correct ✅" : "Incorrect ❌"),
          backgroundColor: allCorrect ? Colors.green : Colors.red,
        ),
      );

      Future.delayed(const Duration(milliseconds: 800), widget.onNext);
    }
  }

  void reset() {
    setState(() {
      _initializeExercise();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have valid exercise data
    if (widget.exercise.dragDropPairs == null &&
        (widget.exercise.answer == null || widget.exercise.answer!.isEmpty)) {
      return Scaffold(
        appBar: AppBar(title: Text("Drag & Drop")),
        body: Center(
          child: Text(
            "No valid exercise data available",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

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

            // Si c'est un exercice avec pairs
            if (widget.exercise.dragDropPairs != null &&
                widget.exercise.dragDropPairs!.isNotEmpty)
              ..._buildPairsExercise()
            else
              ..._buildLetterExercise(),

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

  List<Widget> _buildPairsExercise() {
    return [
      // Zones de dépôt pour les targets
      Text(
        "Drop here:",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: targetItems.map((target) {
          final assignedDraggable = userPairs.entries
              .where((entry) => entry.value == target)
              .map((entry) => entry.key)
              .firstOrNull;

          return DragTarget<String>(
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 120,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: assignedDraggable != null
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  assignedDraggable ?? target,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
            onAcceptWithDetails: (details) =>
                handlePairDrop(target, details.data),
            onWillAcceptWithDetails: (_) => true,
          );
        }).toList(),
      ),
      SizedBox(height: 30),

      // Items à glisser
      Text(
        "Drag from here:",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: draggableItems.map((draggable) {
          final isUsed = userPairs.containsKey(draggable);

          return Draggable<String>(
            data: draggable,
            feedback: Material(
              color: Colors.transparent,
              child: _letterBox(draggable, isFeedback: true),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _letterBox(draggable),
            ),
            child: Opacity(
              opacity: isUsed ? 0.5 : 1.0,
              child: _letterBox(draggable),
            ),
          );
        }).toList(),
      ),
    ];
  }

  List<Widget> _buildLetterExercise() {
    return [
      // Zones de dépôt
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(targetList.length, (index) {
          final current = targetList[index];
          return DragTarget<String>(
            builder: (context, candidateData, rejectedData) {
              return _letterBox(current);
            },
            onAcceptWithDetails: (details) => handleDrop(index, details.data),
            onWillAcceptWithDetails: (_) => targetList[index] == "",
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
            childWhenDragging: Opacity(opacity: 0.3, child: _letterBox(letter)),
            child: _letterBox(letter),
          );
        }).toList(),
      ),
    ];
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
