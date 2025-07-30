import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';

class AudioExercise extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onNext;

  const AudioExercise({
    required this.exercise,
    super.key,
    required this.onNext,
  });

  @override
  State<AudioExercise> createState() => _AudioExerciseState();
}

class _AudioExerciseState extends State<AudioExercise> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? selectedOption;

  @override
  void didUpdateWidget(covariant AudioExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      setState(() {
        selectedOption = null;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void checkAnswer(String option) {
    setState(() {
      selectedOption = option;
    });

    final isCorrect = option == widget.exercise.answer;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "Correct!" : "Incorrect"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
      ),
    );
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have valid exercise data
    if (widget.exercise.options == null || widget.exercise.options!.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B1B2F), Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Text(
              "No valid exercise data available",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B1B2F), Color(0xFF121212)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                widget.exercise.question,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    size: 36,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    if (widget.exercise.audioUrl != null) {
                      await _audioPlayer.play(AssetSource("audio/jannah.mp3"));
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1,
                  children: widget.exercise.options!.map((option) {
                    final isSelected = selectedOption == option;
                    final isCorrect = option == widget.exercise.answer;
                    final color = isSelected
                        ? (isCorrect ? Colors.green : Colors.red)
                        : Colors.white10;

                    return GestureDetector(
                      onTap: selectedOption == null
                          ? () => checkAnswer(option)
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
