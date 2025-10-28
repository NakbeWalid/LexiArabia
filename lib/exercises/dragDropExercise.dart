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
    // Debug
    print('Exercise type: ${widget.exercise.type}');
    print('Exercise question: ${widget.exercise.question}');
    print('Exercise answer: ${widget.exercise.answer}');
    print('Exercise options: ${widget.exercise.options}');
    print('Exercise dragDropPairs: ${widget.exercise.dragDropPairs}');

    // Pour les exercices drag_drop avec une phrase à compléter
    if (widget.exercise.options != null &&
        widget.exercise.options!.isNotEmpty) {
      availableWords = List.from(widget.exercise.options!);
      availableWords.shuffle();

      // Si on a une phrase avec des trous (champ sentence)
      if (widget.exercise.question.contains('____') ||
          (widget.exercise.question.contains('Fill in the blank') &&
              widget.exercise.question.contains('هذا'))) {
        // Extraire la phrase arabe de la question
        String arabicSentence = widget.exercise.question.split('(')[0].trim();
        if (arabicSentence.contains('هذا')) {
          arabicSentence = arabicSentence
              .substring(arabicSentence.indexOf('هذا'))
              .trim();
        }

        // Remplacer ____ par le mot correct
        targetSentence = arabicSentence.replaceAll(
          '____',
          widget.exercise.answer ?? '',
        );

        // Pour les exercices drag & drop, on crée seulement UN slot pour le mot manquant
        sentenceSlots = [null]; // Un seul slot vide
        correctWords = [widget.exercise.answer ?? '']; // Le mot correct

        print("🔍 Drag & Drop initialized:");
        print("🔍 sentenceSlots: $sentenceSlots");
        print("🔍 correctWords: $correctWords");
      }
    }
  }

  @override
  void didUpdateWidget(covariant DragDropExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      _initializeExercise();
      setState(() {});
      _controller.reset();
      if (mounted) _pulseController.reset();
      _controller.forward();
    }
  }

  void handleWordDrop(int index, String word) async {
    print("JE RENTRE ICI BOGOSSSS");
    setState(() {
      // Pour les exercices avec un seul mot à placer
      if (sentenceSlots.length == 1) {
        sentenceSlots[0] = word;
      } else {
        // Remove word from other slots if it exists
        for (int i = 0; i < sentenceSlots.length; i++) {
          if (sentenceSlots[i] == word) {
            sentenceSlots[i] = null;
          }
        }
        sentenceSlots[index] = word;
      }
    });

    // Check if sentence is complete
    print("🔍 Checking completion:");
    print("🔍 sentenceSlots: $sentenceSlots");
    print("🔍 Contains null: ${sentenceSlots.contains(null)}");
    print("🔍 All filled: ${!sentenceSlots.contains(null)}");

    if (!sentenceSlots.contains(null)) {
      bool isCorrect = true;

      // Pour les exercices avec un seul mot
      if (sentenceSlots.length == 1) {
        isCorrect = sentenceSlots[0] == widget.exercise.answer;
        print(
          '🔍 Single word check: "${sentenceSlots[0]}" == "${widget.exercise.answer}" = $isCorrect',
        );
      } else {
        // Pour les exercices avec plusieurs mots
        for (int i = 0; i < sentenceSlots.length; i++) {
          if (sentenceSlots[i] != correctWords[i]) {
            isCorrect = false;
            break;
          }
        }
        print('🔍 Multi-word check: $isCorrect');
        print('🔍 Sentence slots: $sentenceSlots');
        print('🔍 Correct words: $correctWords');
      }

      if (isCorrect) {
        // ✅ RÉPONSE CORRECTE
        Future.delayed(const Duration(milliseconds: 1000), widget.onNext);

        print(
          '🎉 Exercise completed successfully! Calling onNext in 2 seconds...',
        );
        HapticFeedback.lightImpact();
        try {
          await _audioPlayer.play(AssetSource('sounds/success.mp3'));
        } catch (e) {
          print('Audio error: $e');
        }
        if (mounted) _pulseController.forward();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.celebration, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Perfect! Sentence completed! ✨",
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

        Future.delayed(const Duration(milliseconds: 1000), () {
          print('🚀 Calling widget.onNext now!');
          widget.onNext();
        });
      } else {
        // ❌ RÉPONSE INCORRECTE MAIS ON PASSE QUAND MÊME
        print(
          '⚠️ Exercise completed with wrong answer! Calling onNext in 2 seconds...',
        );
        HapticFeedback.mediumImpact();
        try {
          await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
        } catch (e) {
          print('Audio error: $e');
        }
        if (mounted) _pulseController.forward();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Exercise completed! The answer was incorrect, but let's continue! 📚",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Passer à l'exercice suivant même avec une réponse incorrecte
        Future.delayed(const Duration(milliseconds: 2000), () {
          print('🚀 Calling widget.onNext now (with wrong answer)!');
          widget.onNext();
        });
      }
    }
  }

  void reset() {
    setState(() {
      _initializeExercise();
    });
    _controller.reset();
    if (mounted) _pulseController.reset();
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

              // Sentence with blank
              Expanded(
                child: SingleChildScrollView(
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

                      // Sentence with drag target
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
                        child: _buildSentenceWithBlank(),
                      ).animate().fadeIn(delay: 800.ms),

                      SizedBox(height: 30),

                      Text(
                        "Drag the correct word:",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Available words
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        child: AnimationLimiter(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: availableWords.asMap().entries.map((
                              entry,
                            ) {
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

                      SizedBox(height: 20),
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

  Widget _buildSentenceWithBlank() {
    // Extraire seulement la phrase arabe de la question
    String arabicSentence = widget.exercise.question;

    // Supprimer la partie anglaise entre parenthèses
    if (arabicSentence.contains('(')) {
      arabicSentence = arabicSentence.split('(')[0].trim();
    }

    // Supprimer les instructions en anglais au début
    if (arabicSentence.contains(':')) {
      arabicSentence = arabicSentence.split(':')[1].trim();
    }

    // Supprimer "Complete the sentence" ou "Fill in the blank"
    arabicSentence = arabicSentence
        .replaceAll('Complete the sentence', '')
        .trim();
    arabicSentence = arabicSentence.replaceAll('Fill in the blank', '').trim();

    // Nettoyer les espaces multiples
    arabicSentence = arabicSentence.replaceAll(RegExp(r'\s+'), ' ').trim();

    print('🔍 Cleaned Arabic sentence: "$arabicSentence"');

    // Diviser la phrase en mots et filtrer les mots anglais
    List<String> words = arabicSentence.split(' ');

    // Filtrer les mots anglais (garder seulement les mots arabes et ____)
    List<String> arabicWords = words.where((word) {
      // Garder les mots qui contiennent des caractères arabes ou ____
      return word.contains(RegExp(r'[\u0600-\u06FF]')) || word == '____';
    }).toList();

    // Inverser l'ordre pour l'affichage de droite à gauche (RTL)
    arabicWords = arabicWords.reversed.toList();

    print('🔍 Filtered Arabic words: $arabicWords');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: arabicWords.map((word) {
        // Si c'est le mot manquant (____)
        if (word == '____') {
          return DragTarget<String>(
            builder: (context, candidateData, rejectedData) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: candidateData.isNotEmpty
                        ? [Colors.yellow.shade400, Colors.orange.shade500]
                        : sentenceSlots.isNotEmpty && sentenceSlots[0] != null
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: candidateData.isNotEmpty
                        ? Colors.yellow.shade300
                        : sentenceSlots.isNotEmpty && sentenceSlots[0] != null
                        ? Colors.green.shade300
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
                child: Text(
                  sentenceSlots.isNotEmpty && sentenceSlots[0] != null
                      ? sentenceSlots[0]!
                      : "____",
                  style: ArabicTextStyle.smartStyle(
                    sentenceSlots.isNotEmpty && sentenceSlots[0] != null
                        ? sentenceSlots[0]!
                        : "____",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: sentenceSlots.isNotEmpty && sentenceSlots[0] != null
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              );
            },
            onAcceptWithDetails: (details) => handleWordDrop(0, details.data),
            onWillAcceptWithDetails: (_) => true,
          );
        } else {
          // Mot normal de la phrase arabe
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: ArabicText(
              word,
              style: ArabicTextStyle.smartStyle(
                word,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          );
        }
      }).toList(),
    );
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
