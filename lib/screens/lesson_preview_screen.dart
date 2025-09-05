import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dualingocoran/exercises/exercise_page.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';

class LessonPreviewScreen extends StatefulWidget {
  final String lessonTitle;
  final String lessonDescription;
  final List<dynamic>
  newWords; // Changed to dynamic to support both old and new structure
  final List<dynamic> exercises;
  final String sectionTitle;

  const LessonPreviewScreen({
    Key? key,
    required this.lessonTitle,
    required this.lessonDescription,
    required this.newWords,
    required this.exercises,
    required this.sectionTitle,
  }) : super(key: key);

  @override
  State<LessonPreviewScreen> createState() => _LessonPreviewScreenState();
}

class _LessonPreviewScreenState extends State<LessonPreviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  int currentWordIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextWord() {
    if (currentWordIndex < widget.newWords.length - 1) {
      setState(() {
        currentWordIndex++;
      });
      _slideController.reset();
      _slideController.forward();
    }
  }

  void _previousWord() {
    if (currentWordIndex > 0) {
      setState(() {
        currentWordIndex--;
      });
      _slideController.reset();
      _slideController.forward();
    }
  }

  void _startLesson() {
    // Convertir les exercices bruts en objets Exercise
    List<Exercise> exercises = [];
    try {
      for (var ex in widget.exercises) {
        if (ex is Map<String, dynamic>) {
          exercises.add(Exercise.fromJson(ex));
        }
      }
    } catch (e) {
      print("❌ Erreur lors de la conversion des exercices: $e");
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExercisePage(exercises: exercises),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade800,
              Colors.blue.shade900,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header avec titre de la leçon
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Bouton retour
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.sectionTitle,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Titre de la leçon
                    Text(
                      widget.lessonTitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ).animate(controller: _fadeController).fadeIn(),

                    const SizedBox(height: 12),

                    // Description
                    Text(
                          widget.lessonDescription,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate(controller: _fadeController)
                        .fadeIn(delay: 200.ms),
                  ],
                ),
              ),

              // Section des nouveaux mots
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Titre de la section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade400.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.lightbulb_outline,
                              color: Colors.blue.shade200,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'New Words to Learn',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Affichage du mot actuel avec ScrollView
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Mot en arabe
                              Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      _getCurrentWord(),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                  .animate(controller: _slideController)
                                  .slideX(begin: 0.3, end: 0.0)
                                  .fadeIn(),

                              const SizedBox(height: 20),

                              // Traduction en anglais
                              Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade400.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _getCurrentWordTranslation(),
                                      style: GoogleFonts.poppins(
                                        color: Colors.blue.shade100,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                  .animate(controller: _slideController)
                                  .slideX(begin: -0.3, end: 0.0)
                                  .fadeIn(delay: 200.ms),

                              const SizedBox(height: 16),

                              // Description du mot
                              Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade400.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Description:',
                                          style: GoogleFonts.poppins(
                                            color: Colors.orange.shade200,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _getCurrentWordDescription(),
                                          style: GoogleFonts.poppins(
                                            color: Colors.orange.shade100,
                                            fontSize: 16,
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate(controller: _slideController)
                                  .slideY(begin: 0.3, end: 0.0)
                                  .fadeIn(delay: 300.ms),

                              const SizedBox(height: 16),

                              // Exemple d'utilisation
                              Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade400.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Example:',
                                          style: GoogleFonts.poppins(
                                            color: Colors.green.shade200,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _getCurrentWordExample(),
                                          style: GoogleFonts.poppins(
                                            color: Colors.green.shade100,
                                            fontSize: 16,
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate(controller: _slideController)
                                  .slideY(begin: 0.3, end: 0.0)
                                  .fadeIn(delay: 400.ms),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Navigation entre les mots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Bouton précédent
                          GestureDetector(
                            onTap: currentWordIndex > 0 ? _previousWord : null,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: currentWordIndex > 0
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: currentWordIndex > 0
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                size: 20,
                              ),
                            ),
                          ),

                          // Indicateur de progression
                          Row(
                            children: List.generate(
                              widget.newWords.length,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == currentWordIndex
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),

                          // Bouton suivant
                          GestureDetector(
                            onTap: currentWordIndex < widget.newWords.length - 1
                                ? _nextWord
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    currentWordIndex <
                                        widget.newWords.length - 1
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color:
                                    currentWordIndex <
                                        widget.newWords.length - 1
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton pour commencer la leçon
              Container(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: _startLesson,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade400.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      'Start Lesson',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthodes pour gérer la nouvelle structure des mots
  String _getCurrentWord() {
    final currentWord = widget.newWords[currentWordIndex];
    if (currentWord is Map<String, dynamic>) {
      return currentWord['word'] ?? 'Unknown word';
    } else if (currentWord is String) {
      return currentWord;
    }
    return 'Unknown word';
  }

  String _getCurrentWordTranslation() {
    final currentWord = widget.newWords[currentWordIndex];
    if (currentWord is Map<String, dynamic>) {
      return currentWord['translation'] ?? 'Translation not available';
    } else if (currentWord is String) {
      // Fallback vers l'ancienne méthode pour la compatibilité
      return _getWordTranslation(currentWord);
    }
    return 'Translation not available';
  }

  String _getCurrentWordDescription() {
    final currentWord = widget.newWords[currentWordIndex];
    if (currentWord is Map<String, dynamic>) {
      return currentWord['description'] ?? 'Description not available';
    }
    return 'Description not available';
  }

  String _getCurrentWordExample() {
    final currentWord = widget.newWords[currentWordIndex];
    if (currentWord is Map<String, dynamic>) {
      return currentWord['example'] ?? 'Example not available';
    }
    return 'Example not available';
  }

  String _getWordTranslation(String word) {
    // Dictionnaire des traductions pour les mots de négation
    final translations = {
      'لَنْ': 'will not (future negation)',
      'لَمْ': 'did not (past negation)',
      'مَا': 'not (past negation)',
      'لَيْسَ': 'is not (present negation)',
      'كَلَّا': 'no, never',
      'لَا': 'no, not',
      'مِنْ': 'from, of',
      'إِلَى': 'to, towards',
      'عَلَى': 'on, upon',
      'فِي': 'in, at',
      'مَعَ': 'with',
      'بَيْنَ': 'between',
      'قَبْلَ': 'before',
      'بَعْدَ': 'after',
      'أَمَامَ': 'in front of',
      'وَرَاءَ': 'behind',
      'تَحْتَ': 'under',
      'فَوْقَ': 'above',
      'دَاخِلَ': 'inside',
      'خَارِجَ': 'outside',
    };

    return translations[word] ?? 'New word to learn';
  }

  String _getWordExample(String word) {
    // Exemples d'utilisation pour chaque mot
    final examples = {
      'لَنْ':
          'لَنْ أَذْهَبَ إِلَى السُّوقِ غَدًا (I will not go to the market tomorrow)',
      'لَمْ': 'لَمْ أَقْرَأِ الكِتَابَ (I did not read the book)',
      'مَا': 'مَا كَتَبَ الرِّسَالَةَ (He did not write the message)',
      'لَيْسَ': 'لَيْسَ هَذَا بَيْتِي (This is not my house)',
      'كَلَّا': 'كَلَّا، لَنْ أَفْعَلَ ذَلِكَ (No, I will never do that)',
      'لَا': 'لَا أَعْرِفُ (I do not know)',
      'مِنْ': 'أَتَيْتُ مِنَ المَدِيْنَةِ (I came from the city)',
      'إِلَى': 'أَذْهَبُ إِلَى المَسْجِدِ (I go to the mosque)',
      'عَلَى': 'الكِتَابُ عَلَى المَكْتَبِ (The book is on the desk)',
      'فِي': 'أَنَا فِي البَيْتِ (I am in the house)',
      'مَعَ': 'أَنَا مَعَكَ (I am with you)',
      'بَيْنَ':
          'البَيْتُ بَيْنَ المَسْجِدِ وَالمَدْرَسَةِ (The house is between the mosque and the school)',
      'قَبْلَ': 'أَكَلْتُ قَبْلَ الذَّهَابِ (I ate before leaving)',
      'بَعْدَ': 'سَأَذْهَبُ بَعْدَ الفَجْرِ (I will go after dawn)',
      'أَمَامَ': 'أَنَا أَمَامَ البَابِ (I am in front of the door)',
      'وَرَاءَ': 'الكِتَابُ وَرَاءَ المَكْتَبِ (The book is behind the desk)',
      'تَحْتَ': 'القِطُّ تَحْتَ الطَّاوِلَةِ (The cat is under the table)',
      'فَوْقَ': 'الطَّائِرُ فَوْقَ الشَّجَرَةِ (The bird is above the tree)',
      'دَاخِلَ': 'أَنَا دَاخِلَ البَيْتِ (I am inside the house)',
      'خَارِجَ':
          'الأَطْفَالُ خَارِجَ البَيْتِ (The children are outside the house)',
    };

    return examples[word] ?? 'Practice using this word in sentences';
  }
}
