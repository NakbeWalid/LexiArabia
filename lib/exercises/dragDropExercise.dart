import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/arabic_text_style.dart';

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

class _DragDropExerciseState extends State<DragDropExercise>
    with TickerProviderStateMixin {
  List<String?> sentenceSlots = [];
  List<String> availableWords = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _controller;
  late AnimationController _pulseController;

  String targetSentence = "";
  List<String> correctWords = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _initializeExercise();
    _controller.forward();
  }

  void _initializeExercise() {
    if (widget.exercise.answer != null && widget.exercise.answer!.isNotEmpty) {
      targetSentence = widget.exercise.answer!;
      correctWords = targetSentence.split(' ');
      sentenceSlots = List.filled(correctWords.length, null);
      availableWords = List.from(correctWords);
      availableWords.shuffle();
    }
  }

  @override
  void didUpdateWidget(covariant DragDropExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      _initializeExercise();
      setState(() {});
      _controller.reset();
      _pulseController.reset();
      _controller.forward();
    }
  }

  void handleWordDrop(int index, String word) async {
    setState(() {
      // Remove word from other slots if it exists
      for (int i = 0; i < sentenceSlots.length; i++) {
        if (sentenceSlots[i] == word) {
          sentenceSlots[i] = null;
        }
      }
      sentenceSlots[index] = word;
    });

    // Check if sentence is complete
    if (!sentenceSlots.contains(null)) {
      bool isCorrect = true;
      for (int i = 0; i < sentenceSlots.length; i++) {
        if (sentenceSlots[i] != correctWords[i]) {
          isCorrect = false;
          break;
        }
      }

      if (isCorrect) {
        HapticFeedback.lightImpact();
        try {
          await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
        } catch (e) {
          print('Audio error: $e');
        }
        _pulseController.forward();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.celebration, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Perfect sentence! ✨",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        Future.delayed(const Duration(milliseconds: 2000), widget.onNext);
      } else {
        HapticFeedback.mediumImpact();
        try {
          await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
        } catch (e) {
          print('Audio error: $e');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.refresh, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Word order is wrong. Try again!",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Reset',
              textColor: Colors.white,
              onPressed: reset,
            ),
          ),
        );
      }
    }
  }

  void reset() {
    setState(() {
      _initializeExercise();
    });
    _controller.reset();
    _pulseController.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exercise.answer == null || widget.exercise.answer!.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.white70),
                SizedBox(height: 16),
                Text(
                  "No valid exercise data available",
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        "Complete the Sentence",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: reset,
                      icon: Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

              // Question
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: ArabicText(
                  widget.exercise.question,
                  style: ArabicTextStyle.smartStyle(
                    widget.exercise.question,
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 300.ms).scale(),

              SizedBox(height: 40),

              // Progress indicator
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      "Progress: ${sentenceSlots.where((slot) => slot != null).length}/${sentenceSlots.length}",
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value:
                          sentenceSlots.where((slot) => slot != null).length /
                          sentenceSlots.length,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade400,
                      ),
                      minHeight: 6,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).scaleX(),

              SizedBox(height: 40),

              // Sentence slots
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "Complete the sentence:",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Sentence building area
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: AnimationLimiter(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: List.generate(sentenceSlots.length, (
                            index,
                          ) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 400),
                              child: SlideAnimation(
                                verticalOffset: 30.0,
                                child: FadeInAnimation(
                                  child: DragTarget<String>(
                                    builder:
                                        (context, candidateData, rejectedData) {
                                          return _wordSlot(
                                            sentenceSlots[index],
                                            index,
                                          );
                                        },
                                    onAcceptWithDetails: (details) =>
                                        handleWordDrop(index, details.data),
                                    onWillAcceptWithDetails: (_) => true,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms),

                    SizedBox(height: 40),

                    Text(
                      "Drag the words:",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Available words
                    Expanded(
                      child: AnimationLimiter(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: availableWords.asMap().entries.map((entry) {
                            final index = entry.key;
                            final word = entry.value;
                            final isUsed = sentenceSlots.contains(word);

                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 600),
                              child: ScaleAnimation(
                                child: FadeInAnimation(
                                  child: Draggable<String>(
                                    data: word,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: _wordBox(word, isFeedback: true),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: _wordBox(word),
                                    ),
                                    child: Opacity(
                                      opacity: isUsed ? 0.5 : 1.0,
                                      child: _wordBox(word),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wordSlot(String? word, int index) {
    return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 100,
          height: 50,
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: word != null
                  ? [Colors.blue.shade400, Colors.blue.shade600]
                  : [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: word != null
                  ? Colors.blue.shade300
                  : Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              word ?? "___",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: word != null
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
        .animate(target: word != null ? 1 : 0)
        .scale(begin: Offset(1, 1), end: Offset(1.05, 1.05));
  }

  Widget _wordBox(String word, {bool isFeedback = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFeedback
              ? [Colors.purple.shade400, Colors.purple.shade600]
              : [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        word,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isFeedback ? Colors.white : Colors.grey.shade800,
        ),
      ),
    );
  }
}
