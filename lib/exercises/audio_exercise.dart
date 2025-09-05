import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/arabic_text_style.dart';

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

class _AudioExerciseState extends State<AudioExercise>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? selectedOption;
  bool showFeedback = false;
  bool isPlaying = false;
  late AnimationController _controller;
  late AnimationController _audioController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _audioController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.forward();

    // Listen to audio player state
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
      if (state == PlayerState.playing) {
        _audioController.repeat();
      } else {
        _audioController.stop();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AudioExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      setState(() {
        selectedOption = null;
        showFeedback = false;
      });
      _controller.reset();
      _pulseController.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioController.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void checkAnswer(String option) async {
    setState(() {
      selectedOption = option;
      showFeedback = true;
    });

    final isCorrect = option == widget.exercise.answer;

    // Audio et haptic feedback
    if (isCorrect) {
      HapticFeedback.lightImpact();
      _pulseController.forward();
    } else {
      HapticFeedback.mediumImpact();
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
              isCorrect ? "Perfect! ✨" : "Try listening again! 🎧",
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

    Future.delayed(const Duration(milliseconds: 1500), widget.onNext);
  }

  void playAudio() async {
    try {
      if (widget.exercise.audioUrl != null) {
        await _audioPlayer.play(AssetSource("audio/jannah.mp3"));
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text("Audio not available", style: GoogleFonts.poppins()),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have valid exercise data
    // Un exercice est valide s'il a des options OU des pairs
    bool hasValidData =
        (widget.exercise.options != null &&
            widget.exercise.options!.isNotEmpty) ||
        (widget.exercise.dragDropPairs != null &&
            widget.exercise.dragDropPairs!.isNotEmpty);

    // Debug: afficher les données disponibles
    print('🔍 Exercise Type: ${widget.exercise.type}');
    print('🔍 Options: ${widget.exercise.options?.length ?? 0}');
    print('🔍 DragDropPairs: ${widget.exercise.dragDropPairs?.length ?? 0}');
    print('🔍 Has Valid Data: $hasValidData');

    // Pour les exercices drag_drop, on peut aussi accepter s'il n'y a pas d'options
    // car ils utilisent dragDropPairs
    if (widget.exercise.type == 'drag_drop' &&
        widget.exercise.options == null &&
        widget.exercise.dragDropPairs != null &&
        widget.exercise.dragDropPairs!.isNotEmpty) {
      hasValidData = true;
      print('✅ Drag & Drop exercise validated with pairs');
    }

    if (!hasValidData) {
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
                SizedBox(height: 16),
                Text(
                  "Type: ${widget.exercise.type}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  "Options: ${widget.exercise.options?.length ?? 0}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  "Pairs: ${widget.exercise.dragDropPairs?.length ?? 0}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
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
          child: SingleChildScrollView(
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
                          "Audio Exercise",
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

                // Audio Player
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        "Listen to the audio",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: playAudio,
                        child:
                            AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: isPlaying
                                          ? [
                                              Colors.purple.shade400,
                                              Colors.pink.shade400,
                                            ]
                                          : [
                                              Colors.blue.shade400,
                                              Colors.purple.shade400,
                                            ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                                .animate(target: isPlaying ? 1 : 0)
                                .scale(
                                  begin: Offset(1, 1),
                                  end: Offset(1.1, 1.1),
                                )
                                .animate()
                                .shimmer(
                                  duration: isPlaying ? 2000.ms : 0.ms,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(),

                SizedBox(height: 40),

                // Hint
                if (!showFeedback)
                  Text(
                    "Choose what you heard",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ).animate().fadeIn(delay: 900.ms),

                SizedBox(height: 20),

                // Options Grid
                Container(
                  height: 300, // Hauteur fixe pour permettre le scroll
                  child: AnimationLimiter(
                    child: GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: widget.exercise.options!.length,
                      itemBuilder: (context, index) {
                        final option = widget.exercise.options![index];
                        final isSelected = selectedOption == option;
                        final isCorrect = option == widget.exercise.answer;
                        final showResult = showFeedback && isSelected;

                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 600),
                          columnCount: 2,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child:
                                  GestureDetector(
                                        onTap: selectedOption == null
                                            ? () => checkAnswer(option)
                                            : null,
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 400),
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
                                                        0.1,
                                                      ),
                                                      Colors.white.withOpacity(
                                                        0.05,
                                                      ),
                                                    ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
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
                                                : Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    width: 1,
                                                  ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (showResult)
                                                Icon(
                                                  isCorrect
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
                                                  color: Colors.white,
                                                  size: 32,
                                                )
                                              else
                                                Icon(
                                                  Icons.hearing,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.white
                                                            .withOpacity(0.7),
                                                  size: 32,
                                                ),
                                              SizedBox(height: 12),
                                              ArabicText(
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
                                                          : Colors.white
                                                                .withOpacity(
                                                                  0.9,
                                                                ),
                                                    ),
                                                textAlign: TextAlign.center,
                                              ),
                                              if (showResult && isCorrect)
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    top: 8,
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
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
                                      )
                                      .animate(target: isSelected ? 1 : 0)
                                      .scale(
                                        begin: Offset(1, 1),
                                        end: Offset(1.05, 1.05),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
