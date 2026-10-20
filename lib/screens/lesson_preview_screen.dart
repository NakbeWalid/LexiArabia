import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dualingocoran/exercises/exercise_page.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:dualingocoran/services/daily_limit_service.dart';
import 'package:dualingocoran/services/pronunciation_service.dart';
import 'package:dualingocoran/utils/arabic_text_style.dart';

class LessonPreviewScreen extends StatefulWidget {
  final String lessonTitle;
  final String lessonDescription;
  final List<dynamic>
  newWords; // Changed to dynamic to support both old and new structure
  final List<dynamic> exercises;
  final String sectionTitle;
  final String? lessonId;

  const LessonPreviewScreen({
    super.key,
    required this.lessonTitle,
    required this.lessonDescription,
    required this.newWords,
    required this.exercises,
    required this.sectionTitle,
    this.lessonId,
  });

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

    // Prononcer le premier mot à l'ouverture
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrentWord());
  }

  Map<String, dynamic>? get _currentWordData {
    if (widget.newWords.isEmpty) return null;
    final word = widget.newWords[currentWordIndex];
    return word is Map<String, dynamic> ? word : null;
  }

  Future<void> _speakCurrentWord() async {
    if (widget.newWords.isEmpty) return;
    final word = _currentWordData;
    final played = await PronunciationService.speak(
      audioUrl: word?['audioUrl']?.toString(),
      text:
          word?['word']?.toString() ??
          widget.newWords[currentWordIndex].toString(),
    );
    if (!played && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.audioUnavailable),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  @override
  void dispose() {
    PronunciationService.stop();
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
      _speakCurrentWord();
    }
  }

  void _previousWord() {
    if (currentWordIndex > 0) {
      setState(() {
        currentWordIndex--;
      });
      _slideController.reset();
      _slideController.forward();
      _speakCurrentWord();
    }
  }

  Future<void> _startLesson() async {
    // Vérifier la limite quotidienne
    final canStart = await DailyLimitService.canStartLesson();

    if (!canStart) {
      // Afficher un message indiquant que la limite est atteinte
      final limit = DailyLimitService.getDailyLimit();
      final completed = await DailyLimitService.getLessonsCompletedToday();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.orange.shade600),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.dailyLimitTitle,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  )!.dailyLimitMessage(completed, limit),
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.dailyLimitComeBack,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)!.understood,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return;
    }

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

    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExercisePage(exercises: exercises, lessonId: widget.lessonId),
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

    // Retourner true si la leçon a été complétée
    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                            localizations.newWordsToLearn,
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
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: ArabicText(
                                            _getCurrentWord(localizations),
                                            textAlign: TextAlign.center,
                                            style: ArabicTextStyle.smartStyle(
                                              _getCurrentWord(localizations),
                                              fontSize: 38,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        _buildSpeakButton(localizations),
                                      ],
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
                                      _getCurrentWordTranslation(localizations),
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
                                          localizations.descriptionLabel,
                                          style: GoogleFonts.poppins(
                                            color: Colors.orange.shade200,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _getCurrentWordDescription(
                                            localizations,
                                          ),
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
                                          localizations.exampleLabel,
                                          style: GoogleFonts.poppins(
                                            color: Colors.green.shade200,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _getCurrentWordExample(localizations),
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
                      localizations.startLesson,
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

  Widget _buildSpeakButton(AppLocalizations localizations) {
    return ValueListenableBuilder<bool>(
      valueListenable: PronunciationService.isPlaying,
      builder: (context, isPlaying, _) => Semantics(
        button: true,
        label: localizations.playAudio,
        child: Material(
          color: isPlaying
              ? const Color(0xFFD4AF37)
              : Colors.white.withValues(alpha: 0.2),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _speakCurrentWord,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                isPlaying ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Méthodes pour gérer la structure des mots (String ou Map de traductions)
  String _getCurrentWord(AppLocalizations localizations) {
    if (widget.newWords.isEmpty) return localizations.unknownWord;
    final currentWord = widget.newWords[currentWordIndex];
    if (currentWord is Map<String, dynamic>) {
      return currentWord['word']?.toString() ?? localizations.unknownWord;
    } else if (currentWord is String) {
      return currentWord;
    }
    return localizations.unknownWord;
  }

  /// Valeur traduite d'un champ du mot courant (String simple ou Map fr/en/ar)
  String _localizedField(
    String key,
    AppLocalizations localizations,
    String fallback,
  ) {
    final value = _currentWordData?[key];
    if (value is String && value.isNotEmpty) return value;
    if (value is Map) {
      final langCode = localizations.localeName.split('_').first.toLowerCase();
      return value[langCode]?.toString() ??
          value['en']?.toString() ??
          value['fr']?.toString() ??
          value['ar']?.toString() ??
          fallback;
    }
    return fallback;
  }

  String _getCurrentWordTranslation(AppLocalizations localizations) =>
      _localizedField(
        'translation',
        localizations,
        localizations.translationNotAvailable,
      );

  String _getCurrentWordDescription(AppLocalizations localizations) =>
      _localizedField(
        'description',
        localizations,
        localizations.descriptionNotAvailable,
      );

  String _getCurrentWordExample(AppLocalizations localizations) =>
      _localizedField(
        'example',
        localizations,
        localizations.exampleNotAvailable,
      );
}
