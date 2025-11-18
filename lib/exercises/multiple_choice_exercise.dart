import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/arabic_text_style.dart';

class MultipleChoiceExercise extends StatefulWidget {
  final Exercise exercise;
  final Function(bool) onNext;

  const MultipleChoiceExercise({
    super.key,
    required this.exercise,
    required this.onNext,
  });

  @override
  _MultipleChoiceExerciseState createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise>
    with TickerProviderStateMixin {
  String? selectedOption;
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
  void didUpdateWidget(covariant MultipleChoiceExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      setState(() {
        selectedOption = null;
        showFeedback = false;
      });
      _controller.reset();
      if (mounted) _pulseController.reset();
      _controller.forward();
    }
  }

  void checkAnswer(String option, BuildContext context) async {
    setState(() {
      selectedOption = option;
      showFeedback = true;
    });

    // Comparer avec la version traduite de la réponse
    final translatedAnswer = widget.exercise.getTranslatedAnswer(context);
    final isCorrect = option == translatedAnswer;

    // Audio et haptic feedback
    if (isCorrect) {
      HapticFeedback.lightImpact();
      try {
        await _audioPlayer.play(AssetSource('sounds/success.mp3'));
      } catch (e) {
        print('Audio error: $e');
      }
      if (mounted) _pulseController.forward();
    } else {
      HapticFeedback.mediumImpact();
      try {
        await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
      } catch (e) {
        print('Audio error: $e');
      }
    }

    if (isCorrect) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('user_123')
            .update({
              'xp': FieldValue.increment(10),
              'streak': FieldValue.increment(1),
            });
      } catch (e) {
        print('Firestore error: $e');
      }
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
              isCorrect ? "Perfect! ✨" : "Oops, try again! 💪",
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

    // Seulement passer à l'exercice suivant si la réponse est correcte
    if (isCorrect) {
      print('About to call widget.onNext in 0.8 seconds...');
      Future.delayed(const Duration(milliseconds: 800), () {
        print('Calling widget.onNext now!');
        widget.onNext(isCorrect);
      });
    } else {
      // Réinitialiser après un délai pour permettre de réessayer
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            selectedOption = null;
            showFeedback = false;
          });
        }
      });
    }
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
    // Obtenir les options traduites
    final translatedOptions = widget.exercise.getTranslatedOptions(context);
    final translatedQuestion = widget.exercise.getTranslatedQuestion(context);
    final translatedAnswer = widget.exercise.getTranslatedAnswer(context);

    // Check if we have valid exercise data
    if (translatedOptions.isEmpty) {
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            "Multiple Choice",
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
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: ArabicText(
                        translatedQuestion,
                        style: ArabicTextStyle.smartStyle(
                          translatedQuestion,
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

              SizedBox(height: 20),

              // Options
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: translatedOptions.length,
                    itemBuilder: (context, index) {
                      final option = translatedOptions[index];
                      final isSelected = selectedOption == option;
                      final isCorrect = option == translatedAnswer;
                      final showResult = showFeedback && isSelected;
                      // Permettre de cliquer si pas de feedback, ou si feedback mais réponse incorrecte
                      final canTap =
                          !showFeedback ||
                          (showFeedback &&
                              selectedOption != null &&
                              selectedOption != translatedAnswer);

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 600),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child:
                                Container(
                                      margin: EdgeInsets.only(bottom: 16),
                                      child: GestureDetector(
                                        onTap: canTap
                                            ? () => checkAnswer(option, context)
                                            : null,
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 400),
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: showResult
                                                  ? isCorrect
                                                        ? [
                                                            Colors
                                                                .green
                                                                .shade400,
                                                            Colors
                                                                .green
                                                                .shade600,
                                                          ]
                                                        : [
                                                            Colors.red.shade400,
                                                            Colors.red.shade600,
                                                          ]
                                                  : isSelected
                                                  ? [
                                                      Colors.blue.shade400,
                                                      Colors.blue.shade600,
                                                    ]
                                                  : [
                                                      Colors.white.withOpacity(
                                                        0.9,
                                                      ),
                                                      Colors.white.withOpacity(
                                                        0.7,
                                                      ),
                                                    ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 12,
                                                offset: Offset(0, 6),
                                              ),
                                            ],
                                            border: isSelected
                                                ? Border.all(
                                                    color: showResult
                                                        ? (isCorrect
                                                              ? Colors
                                                                    .green
                                                                    .shade300
                                                              : Colors
                                                                    .red
                                                                    .shade300)
                                                        : Colors.blue.shade300,
                                                    width: 3,
                                                  )
                                                : null,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      (showResult || isSelected)
                                                      ? Colors.white
                                                            .withOpacity(0.2)
                                                      : Colors.grey.shade300,
                                                ),
                                                child: Center(
                                                  child: showResult
                                                      ? Icon(
                                                          isCorrect
                                                              ? Icons.check
                                                              : Icons.close,
                                                          color: Colors.white,
                                                          size: 24,
                                                        )
                                                      : Text(
                                                          String.fromCharCode(
                                                            65 + index,
                                                          ), // A, B, C, D
                                                          style: GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: isSelected
                                                                ? Colors.white
                                                                : Colors
                                                                      .grey
                                                                      .shade700,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: ArabicText(
                                                  option,
                                                  style:
                                                      ArabicTextStyle.smartStyle(
                                                        option,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            (showResult ||
                                                                isSelected)
                                                            ? Colors.white
                                                            : Colors
                                                                  .grey
                                                                  .shade800,
                                                      ),
                                                ),
                                              ),
                                              if (showResult && isCorrect)
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    "+10 XP",
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .animate(target: isSelected ? 1 : 0)
                                    .scale(
                                      begin: Offset(1, 1),
                                      end: Offset(1.02, 1.02),
                                    )
                                    .animate(
                                      target: showResult && isCorrect ? 1 : 0,
                                    )
                                    .shimmer(
                                      duration: 1500.ms,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom hint
              if (!showFeedback)
                Container(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Choose the correct answer",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
