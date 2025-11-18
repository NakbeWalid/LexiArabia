import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/arabic_text_style.dart';

class TrueFalseExercise extends StatefulWidget {
  final Exercise exercise;
  final Function(bool) onNext;

  const TrueFalseExercise({
    super.key,
    required this.exercise,
    required this.onNext,
  });

  @override
  State<TrueFalseExercise> createState() => _TrueFalseExerciseState();
}

class _TrueFalseExerciseState extends State<TrueFalseExercise>
    with TickerProviderStateMixin {
  bool? selectedAnswer;
  bool showFeedback = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _controller;
  late AnimationController _pulseController;

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
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant TrueFalseExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      setState(() {
        selectedAnswer = null;
        showFeedback = false;
      });
      _controller.reset();
      if (mounted) _pulseController.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void checkAnswer(bool answer) async {
    setState(() {
      selectedAnswer = answer;
      showFeedback = true;
    });

    final correct = widget.exercise.answer == "true";
    final isCorrect = answer == correct;

    // Audio et haptic feedback
    if (isCorrect) {
      HapticFeedback.lightImpact();
      // try {
      //   await _audioPlayer.play(AssetSource('assets/sounds/correct.mp3'));
      // } catch (e) {
      //   print('Audio error: $e');
      // }
      if (mounted) _pulseController.forward();
    } else {
      HapticFeedback.mediumImpact();
      // try {
      //   await _audioPlayer.play(AssetSource('assets/sounds/wrong.mp3'));
      // } catch (e) {
      //   print('Audio error: $e');
      // }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              isCorrect ? "Excellent! ✨" : "Not quite right! 🤔",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: isCorrect
            ? Colors.green.shade600
            : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    print('True/False: About to call widget.onNext in 1.5 seconds...');
    Future.delayed(const Duration(milliseconds: 1500), () {
      print('True/False: Calling widget.onNext now!');
      widget.onNext(isCorrect);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        "True or False",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Question Card
                      Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.quiz,
                              size: 48,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            SizedBox(height: 20),
                            ArabicText(
                              widget.exercise.question,
                              style: ArabicTextStyle.smartStyle(
                                widget.exercise.question,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms).scale(),

                      SizedBox(height: 60),

                      // Hint
                      if (!showFeedback)
                        Text(
                          "Is this statement true or false?",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ).animate().fadeIn(delay: 600.ms),

                      SizedBox(height: 40),

                      // True/False Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildButton(true, "TRUE", Colors.green)
                                .animate()
                                .fadeIn(delay: 800.ms)
                                .slideX(begin: -0.3),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: _buildButton(false, "FALSE", Colors.red)
                                .animate()
                                .fadeIn(delay: 900.ms)
                                .slideX(begin: 0.3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(bool value, String label, Color baseColor) {
    final isSelected = selectedAnswer == value;
    final correct = widget.exercise.answer == "true";
    final isCorrect = value == correct;
    final showResult = showFeedback && isSelected;

    return GestureDetector(
          onTap: selectedAnswer == null ? () => checkAnswer(value) : null,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 400),
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: showResult
                    ? isCorrect
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : [Colors.red.shade400, Colors.red.shade600]
                    : isSelected
                    ? [baseColor.withOpacity(0.8), baseColor.withOpacity(1.0)]
                    : [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
              border: isSelected
                  ? Border.all(
                      color: showResult
                          ? (isCorrect
                                ? Colors.green.shade300
                                : Colors.red.shade300)
                          : baseColor.withOpacity(0.6),
                      width: 3,
                    )
                  : Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showResult)
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                      size: 24,
                    )
                  else
                    Icon(
                      value ? Icons.thumb_up : Icons.thumb_down,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      size: 24,
                    ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: (showResult || isSelected)
                            ? Colors.white
                            : Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showResult && isCorrect)
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "+10 XP",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        )
        .animate(target: isSelected ? 1 : 0)
        .scale(begin: Offset(1, 1), end: Offset(1.05, 1.05))
        .animate(target: showResult && isCorrect ? 1 : 0)
        .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.5));
  }
}
