import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/exercise_page.dart';
import 'package:dualingocoran/screens/profile_screen.dart';
import 'package:dualingocoran/screens/lesson_preview_screen.dart';
import 'package:dualingocoran/screens/settings_screen.dart';
import 'package:dualingocoran/screens/progression_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:dualingocoran/services/language_provider.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'dart:math' as math;

Future<void> verifierLecons() async {
  try {
    print("🔍 Vérification des leçons existantes...");

    final snapshot = await FirebaseFirestore.instance
        .collection('lessons')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      print(
        "✅ Des leçons existent déjà (${snapshot.docs.length} trouvées). Exemple: ${snapshot.docs.first.data()}",
      );

      // ➝ Nouvelle leçon : Relative Pronouns
      print("📝 Ajout de la leçon: Relative Pronouns");
      await FirebaseFirestore.instance.collection('lessons').doc('Relative Pronouns').set({
        "category": "Pronouns",
        "description":
            "Learn how to use Arabic relative pronouns: الَّذِي, الَّتِي, الَّذِينَ, اللَّائِي.",
        "exercises": [
          {
            "answer": "الَّذِي",
            "options": ["الَّذِينَ", "اللَّائِي", "الَّذِي", "الَّتِي"],
            "question":
                "Which relative pronoun is used for: 'The man **who** prays'?",
            "type": "multiple_choice",
          },
          {
            "answer": "الَّتِي",
            "options": ["الَّتِي", "الَّذِي", "الَّذِينَ", "اللَّائِي"],
            "question":
                "You want to say: 'The woman **who** reads.' What do you use?",
            "type": "multiple_choice",
          },
          {
            "answer": "الَّذِينَ",
            "options": ["الَّذِي", "اللَّائِي", "الَّذِينَ", "الَّتِي"],
            "question":
                "Pick the correct pronoun: 'Those (men) who believe are successful.'",
            "type": "multiple_choice",
          },
          {
            "answer": "اللَّائِي",
            "options": ["الَّذِي", "الَّذِينَ", "الَّتِي", "اللَّائِي"],
            "question": "Which one is used for groups of women?",
            "type": "multiple_choice",
          },
          {
            "instruction":
                "Match the Arabic relative pronoun to its correct use.",
            "options": [
              "الَّذِي",
              "الَّتِي",
              "الَّذِينَ",
              "اللَّائِي",
              "who (masculine)",
              "who (feminine)",
              "those who (masc.)",
              "those who (fem.)",
            ],
            "pairs": [
              {"from": "الَّذِي", "to": "who (masculine)"},
              {"from": "الَّتِي", "to": "who (feminine)"},
              {"from": "الَّذِينَ", "to": "those who (masc.)"},
              {"from": "اللَّائِي", "to": "those who (fem.)"},
            ],
            "question": "Match the Arabic relative pronoun to its correct use.",
            "type": "pairs",
          },
          {
            "answer": false,
            "question": "“اللَّائِي” can be used for a group of men.",
            "type": "true_false",
          },
          {
            "answer": true,
            "question": "“الَّتِي” is used for singular feminine nouns.",
            "type": "true_false",
          },
          {
            "answer": "الَّذِي",
            "audioUrl": "audio/allathi.mp3",
            "options": ["الَّتِي", "الَّذِي", "الَّذِينَ", "اللَّائِي"],
            "question": "Which pronoun do you hear?",
            "type": "audio_choice",
          },
          {
            "answer": "الَّذِينَ",
            "audioUrl": "audio/allatheena.mp3",
            "options": ["اللَّائِي", "الَّذِينَ", "الَّتِي", "الَّذِي"],
            "question": "Listen and choose: what do you hear?",
            "type": "audio_choice",
          },
          {
            "answer": "الطُّلاَّبُ الَّذِينَ يَدرُسُونَ",
            "options": [
              "الطُّلاَّبُ الَّذِي يَدرُسُونَ",
              "الطُّلاَّبُ الَّذِينَ يَدرُسُونَ",
              "الطُّلاَّبُ الَّتِي يَدرُسُونَ",
              "الطُّلاَّبُ اللَّائِي يَدرُسُونَ",
            ],
            "question":
                "Choose the correct full phrase: 'The students **who** study succeed.'",
            "type": "multiple_choice",
          },
        ],
        "lessonOrder": 1,
        "section": "Basics",
        "sectionOrder": 3,
        "sectionTitle": "Relative Pronouns",
        "title": "Relative Pronouns – Who, Which, That",
        "words": [
          {
            "word": "الَّذِي",
            "translation": "who (masculine)",
            "description": "Used for singular masculine nouns.",
            "example": "الرجلُ الَّذِي يُصَلِّي (The man who prays)",
          },
          {
            "word": "الَّتِي",
            "translation": "who (feminine)",
            "description": "Used for singular feminine nouns.",
            "example": "المرأةُ الَّتِي تَقرَأُ (The woman who reads)",
          },
          {
            "word": "الَّذِينَ",
            "translation": "those who (masc.)",
            "description": "Used for plural masculine nouns.",
            "example":
                "الطُّلَّابُ الَّذِينَ يَدرُسُونَ (The students who study)",
          },
          {
            "word": "اللَّائِي",
            "translation": "those who (fem.)",
            "description": "Used for plural feminine nouns.",
            "example": "النِّسَاءُ اللَّائِي يُصَلِّينَ (The women who pray)",
          },
        ],
      });

      print("✅ Leçon 'Negation and Exclusion' ajoutée avec succès!");
    } else {
      print("❌ Aucune leçon trouvée dans Firestore");
    }
  } catch (e) {
    print("❌ Erreur lors de la vérification/ajout des leçons: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ajouter la nouvelle leçon
  //await verifierLecons();

  runApp(CoranLinguaApp());
}

class CoranLinguaApp extends StatelessWidget {
  const CoranLinguaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'CoranLingua',
            theme: ThemeData.dark().copyWith(
              primaryColor: const Color(0xFFD4AF37),
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
              textTheme: const TextTheme(
                headlineMedium: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
                bodyMedium: TextStyle(fontSize: 16, color: Colors.white),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Color(0xFFD4AF37),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.black,
                selectedItemColor: Color(0xFFD4AF37),
                unselectedItemColor: Colors.grey,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            // Configuration de l'internationalisation
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: languageProvider.currentLocale,
            home: MainScreen(),
            debugShowCheckedModeBanner: false,
            // showPerformanceOverlay: true,
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    RoadmapBubbleScreen(),
    ExercisesScreen(),
    ProgressionScreen(),
    ProfilScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem(int index, IconData icon, String labelKey) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [Colors.purple.shade400, Colors.blue.shade400],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
                size: isSelected ? 22 : 20,
              ),
              SizedBox(height: 2),
              Builder(
                builder: (context) {
                  final localizations = AppLocalizations.of(context)!;

                  // Mapping des clés vers les getters
                  String label;
                  switch (labelKey) {
                    case 'lessons':
                      label = localizations.lessons;
                      break;
                    case 'exercises':
                      label = localizations.exercises;
                      break;
                    case 'progression':
                      label = localizations.progression;
                      break;
                    case 'profile':
                      label = localizations.profile;
                      break;
                    case 'settings':
                      label = localizations.settings;
                      break;
                    default:
                      label = labelKey;
                  }

                  return Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                      fontSize: isSelected ? 10 : 9,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF24243e), Color(0xFF302B63)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.school, 'lessons'),
                _buildNavItem(1, Icons.assignment, 'exercises'),
                _buildNavItem(2, Icons.trending_up, 'progression'),
                _buildNavItem(3, Icons.person, 'profile'),
                _buildNavItem(4, Icons.settings, 'settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoadmapBubbleScreen extends StatefulWidget {
  const RoadmapBubbleScreen({super.key});

  @override
  State<RoadmapBubbleScreen> createState() => _RoadmapBubbleScreenState();
}

class _RoadmapBubbleScreenState extends State<RoadmapBubbleScreen>
    with TickerProviderStateMixin {
  late AnimationController _pathController;
  late AnimationController _bubbleController;
  late AnimationController _sectionPanelController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  List<QueryDocumentSnapshot> _lessons = [];
  List<Map<String, dynamic>> _sections = [];
  String _currentSection = '';
  final ScrollController _scrollController = ScrollController();
  List<Animation<double>> _bubbleAnimations = [];

  @override
  void initState() {
    super.initState();
    _pathController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _bubbleController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _sectionPanelController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _loadLessons();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _pathController.dispose();
    _bubbleController.dispose();
    _sectionPanelController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      _updateCurrentSection();
    });
  }

  void _updateCurrentSection() {
    if (_sections.isEmpty) return;

    final scrollOffset = _scrollController.offset;
    final screenHeight = MediaQuery.of(context).size.height;

    // Logique simplifiée : basée sur la position de scroll
    for (int i = 0; i < _sections.length; i++) {
      final section = _sections[i];

      // Calculer la position approximative de la section
      final sectionStartY = 200 + (i * 300.0); // 300px par section
      final sectionEndY = sectionStartY + 300;

      // Vérifier si l'utilisateur est dans cette section
      if (scrollOffset >= sectionStartY - screenHeight * 0.3 &&
          scrollOffset <= sectionEndY - screenHeight * 0.3) {
        if (_currentSection != section['name']) {
          setState(() {
            _currentSection = section['name'];
          });
          _showSectionPanel();

          // Debug: afficher le changement de section
          print('🔄 Section changée: ${section['name']} (${section['title']})');
          print(
            '📍 Scroll: $scrollOffset, Section: $sectionStartY - $sectionEndY',
          );
        }
        break;
      }
    }
  }

  void _showSectionPanel() {
    // Réinitialiser et relancer l'animation pour la nouvelle section
    _sectionPanelController.reset();
    _sectionPanelController.forward();
  }

  Future<void> _loadLessons() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('lessons')
          .orderBy('sectionOrder')
          .orderBy('lessonOrder')
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _lessons = snapshot.docs;
          _sections = _organizeLessonsIntoSections(snapshot.docs);

          // Initialiser la section actuelle avec la première section
          if (_sections.isNotEmpty) {
            _currentSection = _sections.first['name'];
            // Afficher la bannière immédiatement
            _sectionPanelController.forward();
            print('🚀 Section initiale: $_currentSection');
          }
        });

        // Créer des animations individuelles pour chaque bulle
        _bubbleAnimations = List.generate(
          _lessons.length,
          (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _bubbleController,
              curve: Interval(
                index * 0.1,
                (index + 1) * 0.1,
                curve: Curves.elasticOut,
              ),
            ),
          ),
        );

        _bubbleController.forward();
      }
    } catch (e) {
      print('Erreur lors du chargement des leçons: $e');
    }
  }

  List<Map<String, dynamic>> _organizeLessonsIntoSections(
    List<QueryDocumentSnapshot> lessons,
  ) {
    final sections = <Map<String, dynamic>>[];
    final sectionMap = <String, List<QueryDocumentSnapshot>>{};

    // Organiser les leçons par section
    for (final lesson in lessons) {
      final data = lesson.data() as Map<String, dynamic>;
      final section = data['section'] as String? ?? 'Basics';
      sectionMap.putIfAbsent(section, () => []).add(lesson);
    }

    // Créer les sections avec leurs métadonnées
    sectionMap.forEach((sectionName, sectionLessons) {
      final sectionData = sectionLessons.first.data() as Map<String, dynamic>;
      sections.add({
        'name': sectionName,
        'title': sectionData['sectionTitle'] as String? ?? sectionName,
        'description': _getSectionDescription(sectionName),
        'icon': _getSectionIcon(sectionName),
        'color': _getSectionColor(sectionName),
        'lessons': sectionLessons,
        'completed': sectionLessons.where((l) {
          final data = l.data() as Map<String, dynamic>;
          return data['completed'] == true;
        }).length,
        'total': sectionLessons.length,
      });
    });

    // Trier les sections par ordre
    sections.sort((a, b) {
      final orderA = _getSectionOrder(a['name']);
      final orderB = _getSectionOrder(b['name']);
      return orderA.compareTo(orderB);
    });

    return sections;
  }

  String _getSectionDescription(String sectionName) {
    switch (sectionName.toLowerCase()) {
      case 'basics':
        return 'Fondamentaux de la langue arabe';
      case 'pronouns':
        return 'Pronoms et références';
      case 'grammar':
        return 'Règles grammaticales';
      case 'vocabulary':
        return 'Vocabulaire essentiel';
      case 'conversation':
        return 'Dialogues et expressions';
      case 'culture':
        return 'Culture et traditions';
      case 'religion':
        return 'Termes religieux';
      case 'advanced':
        return 'Niveau avancé';
      default:
        return 'Apprentissage progressif';
    }
  }

  IconData _getSectionIcon(String sectionName) {
    switch (sectionName.toLowerCase()) {
      case 'basics':
        return Icons.abc;
      case 'pronouns':
        return Icons.person;
      case 'grammar':
        return Icons.book;
      case 'vocabulary':
        return Icons.translate;
      case 'conversation':
        return Icons.chat;
      case 'culture':
        return Icons.celebration;
      case 'religion':
        return Icons.church;
      case 'advanced':
        return Icons.school;
      default:
        return Icons.star;
    }
  }

  Color _getSectionColor(String sectionName) {
    switch (sectionName.toLowerCase()) {
      case 'basics':
        return Color(0xFF4CAF50);
      case 'pronouns':
        return Color(0xFF2196F3);
      case 'grammar':
        return Color(0xFF9C27B0);
      case 'vocabulary':
        return Color(0xFFFF9800);
      case 'conversation':
        return Color(0xFFE91E63);
      case 'culture':
        return Color(0xFF795548);
      case 'religion':
        return Color(0xFF607D8B);
      case 'advanced':
        return Color(0xFFD4AF37);
      default:
        return Color(0xFF6C63FF);
    }
  }

  int _getSectionOrder(String sectionName) {
    switch (sectionName.toLowerCase()) {
      case 'basics':
        return 1;
      case 'pronouns':
        return 2;
      case 'grammar':
        return 3;
      case 'vocabulary':
        return 4;
      case 'conversation':
        return 5;
      case 'culture':
        return 6;
      case 'religion':
        return 7;
      case 'advanced':
        return 8;
      default:
        return 999;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF24243e),
              Color(0xFF302B63),
              Color(0xFF0F0C29),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header avec Streak et Lives
              _buildHeader(),

              // Panneau de section actuelle
              // Bannière de section permanente et belle
              _buildPermanentSectionPanel(),

              // Contenu de la roadmap avec chemin
              Expanded(
                child: _lessons.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD4AF37),
                        ),
                      )
                    : SingleChildScrollView(
                        controller: _scrollController,
                        child: _buildEnhancedRoadmap(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermanentSectionPanel() {
    if (_sections.isEmpty || _currentSection.isEmpty) {
      return _buildDefaultSectionPanel();
    }

    final currentSectionData = _sections.firstWhere(
      (section) => section['name'] == _currentSection,
      orElse: () => _sections.first,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: AnimatedBuilder(
        animation: _sectionPanelController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _sectionPanelController.value) * -20),
            child: Opacity(
              opacity: _sectionPanelController.value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF302B63).withOpacity(0.95),
                      Color(0xFF24243e).withOpacity(0.9),
                      Color(0xFF0F0C29).withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Color(0xFFD4AF37).withOpacity(0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD4AF37).withOpacity(0.3),
                      blurRadius: 30,
                      offset: Offset(0, 15),
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Effet de brillance dorée en arrière-plan
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFFD4AF37).withOpacity(0.3),
                              Color(0xFFD4AF37).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Effet de particules flottantes
                    Positioned(
                      top: 10,
                      left: 20,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Color(0xFFD4AF37).withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 25,
                      right: 40,
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Color(0xFFD4AF37).withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Contenu principal
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icône avec effet de brillance dorée
                        Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFD4AF37).withOpacity(0.4),
                                Color(0xFFD4AF37).withOpacity(0.2),
                                Color(0xFFD4AF37).withOpacity(0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFFD4AF37).withOpacity(0.6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFD4AF37).withOpacity(0.4),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            currentSectionData['icon'] as IconData,
                            color: Color(0xFFD4AF37),
                            size: 30,
                          ),
                        ),
                        SizedBox(width: 20),
                        // Informations de la section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSectionData['title'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFFD4AF37).withOpacity(0.5),
                                      offset: Offset(0, 2),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                currentSectionData['description'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Progression avec effet doré
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFD4AF37).withOpacity(0.3),
                                Color(0xFFD4AF37).withOpacity(0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Color(0xFFD4AF37).withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFD4AF37).withOpacity(0.2),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xFFD4AF37),
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                '${currentSectionData['completed']}/${currentSectionData['total']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFFD4AF37).withOpacity(0.3),
                                      offset: Offset(0, 1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultSectionPanel() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF302B63).withOpacity(0.95),
            Color(0xFF24243e).withOpacity(0.9),
            Color(0xFF0F0C29).withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Color(0xFFD4AF37).withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 30,
            offset: Offset(0, 15),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD4AF37).withOpacity(0.4),
                  Color(0xFFD4AF37).withOpacity(0.2),
                  Color(0xFFD4AF37).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFFD4AF37).withOpacity(0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFD4AF37).withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.school, color: Color(0xFFD4AF37), size: 30),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue dans votre parcours !',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        color: Color(0xFFD4AF37).withOpacity(0.5),
                        offset: Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Commencez votre apprentissage de l\'arabe',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Streak avec animation
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (0.1 * _pulseController.value),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withOpacity(0.8),
                            Colors.red.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.8),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '5 jours',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Lives avec animation
              Row(
                children: List.generate(
                  3,
                  (index) => AnimatedBuilder(
                    animation: _floatingController,
                    builder: (context, child) {
                      final offset =
                          math.sin(
                            (_floatingController.value * 2 * math.pi) +
                                (index * 0.5),
                          ) *
                          3;
                      return Transform.translate(
                        offset: Offset(0, offset),
                        child: Container(
                          margin: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Titre avec effet de brillance
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.white, Color(0xFFD4AF37), Colors.white],
              stops: [0.0, 0.5, 1.0],
              transform: GradientRotation(
                _floatingController.value * 2 * math.pi,
              ),
            ).createShader(bounds),
            child: Text(
              'Roadmap',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'Continue ton apprentissage',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEnhancedRoadmap() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: _calculateRoadmapHeight(),
      child: Stack(
        children: [
          // Chemin de base avec effet de particules
          CustomPaint(
            painter: EnhancedPathPainter(
              lessons: _lessons,
              pathValue: _pathController.value,
              floatingValue: _floatingController.value,
            ),
            child: Container(),
          ),

          // Bulles de leçons avec animations avancées
          ..._lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            final data = lesson.data() as Map<String, dynamic>;

            return _buildEnhancedLessonBubble(
              context,
              data['title'] as String? ?? 'Unknown',
              data['description'] as String? ?? '',
              data['words'] as List<dynamic>? ?? [],
              data['exercises'] as List<dynamic>? ?? [],
              index,
              _lessons.length,
              data['completed'] == true,
              data['started'] == true,
            );
          }),

          // Effets de particules flottantes
          _buildFloatingParticles(),
        ],
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            final progress = (index / 20.0 + _floatingController.value) % 1.0;
            final x = MediaQuery.of(context).size.width * progress;
            final y = 200 + (progress * _calculateRoadmapHeight() * 0.8);
            final offset = math.sin(progress * 4 * math.pi + index) * 20;

            return Positioned(
              left: x + offset,
              top: y,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  double _calculateRoadmapHeight() {
    if (_lessons.isEmpty) return 400;

    // Hauteur basée sur le nombre de leçons et l'espacement
    return 200 + (_lessons.length * 160.0) + 200;
  }

  Widget _buildEnhancedLessonBubble(
    BuildContext context,
    String title,
    String description,
    List<dynamic> newWords,
    List<dynamic> exercises,
    int index,
    int totalLessons,
    bool isCompleted,
    bool isStarted,
  ) {
    if (index >= _bubbleAnimations.length) return SizedBox.shrink();

    final position = _calculateEnhancedBubblePosition(index, totalLessons);
    final bubbleInfo = _getEnhancedBubbleInfo(
      index,
      totalLessons,
      isCompleted,
      isStarted,
    );

    return Positioned(
      left: position.dx - 60,
      top: position.dy - 60,
      child: AnimatedBuilder(
        animation: _bubbleAnimations[index],
        builder: (context, child) {
          final animationValue = _bubbleAnimations[index].value;

          return Transform.scale(
            scale: animationValue,
            child: Transform.translate(
              offset: Offset(0, (1 - animationValue) * 100),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonPreviewScreen(
                        lessonTitle: title,
                        lessonDescription: description,
                        newWords: newWords,
                        exercises: exercises,
                        sectionTitle: 'Leçon',
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        bubbleInfo['color'] as Color,
                        (bubbleInfo['color'] as Color).withOpacity(0.7),
                        (bubbleInfo['color'] as Color).withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? Colors.green : Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (bubbleInfo['color'] as Color).withOpacity(0.5),
                        blurRadius: 25,
                        offset: Offset(0, 10),
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Icône principale avec effet de brillance
                      Positioned(
                        top: 15,
                        left: 0,
                        right: 0,
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.8),
                              Colors.white,
                            ],
                          ).createShader(bounds),
                          child: Icon(
                            bubbleInfo['icon'] as IconData,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),

                      // Nom de la leçon
                      Positioned(
                        bottom: 25,
                        left: 8,
                        right: 8,
                        child: Text(
                          title.length > 15
                              ? '${title.substring(0, 15)}...'
                              : title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Texte ou numéro
                      if (bubbleInfo['text'] != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              bubbleInfo['text'] as String,
                              style: GoogleFonts.poppins(
                                color: bubbleInfo['color'] as Color,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      // Indicateur de statut avec animation
                      if (isCompleted)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (0.2 * _pulseController.value),
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.95),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.6),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // Effet de brillance rotative
                      AnimatedBuilder(
                        animation: _floatingController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _floatingController.value * 2 * math.pi,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Offset _calculateEnhancedBubblePosition(int index, int totalLessons) {
    final screenWidth = MediaQuery.of(context).size.width - 40;
    final screenHeight = _calculateRoadmapHeight();

    // Utiliser l'index de la liste pour éviter les superpositions
    // mais trier les leçons par ordre logique d'abord
    final lesson = _lessons[index];
    final data = lesson.data() as Map<String, dynamic>;
    final sectionOrder = data['sectionOrder'] as int? ?? 1;
    final lessonOrder = data['lessonOrder'] as int? ?? 1;

    // Chemin en zigzag avec espacement régulier
    final baseX = screenWidth * 0.5;

    // Alternance gauche/droite basée sur l'index de la liste
    final zigzagX = (index % 2 == 0) ? -1.0 : 1.0;
    final variationX = zigzagX * (screenWidth * 0.25);
    final x = baseX + variationX;

    // Espacement vertical basé sur l'index de la liste
    final baseY = 200.0 + (index * 160.0); // 160px entre chaque bulle
    final y = baseY;

    return Offset(x, y);
  }

  Map<String, dynamic> _getEnhancedBubbleInfo(
    int index,
    int totalLessons,
    bool isCompleted,
    bool isStarted,
  ) {
    if (index == 0) {
      if (isCompleted) {
        return {'color': Colors.green, 'icon': Icons.check_circle, 'text': '✓'};
      } else if (isStarted) {
        return {
          'color': Color(0xFFFF9800),
          'icon': Icons.pause_circle,
          'text': '⏸',
        };
      } else {
        return {
          'color': Color(0xFF4CAF50),
          'icon': Icons.play_arrow,
          'text': '1',
        };
      }
    } else if (index == totalLessons - 1) {
      if (isCompleted) {
        return {
          'color': Colors.green,
          'icon': Icons.emoji_events,
          'text': '🏆',
        };
      } else {
        return {'color': Color(0xFFD4AF37), 'icon': Icons.lock, 'text': '🔒'};
      }
    } else if (index % 5 == 0) {
      if (isCompleted) {
        return {
          'color': Colors.green,
          'icon': Icons.workspace_premium,
          'text': '💎',
        };
      } else {
        return {
          'color': Color(0xFFFF9800),
          'icon': Icons.workspace_premium,
          'text': '💎',
        };
      }
    } else if (index % 3 == 0) {
      if (isCompleted) {
        return {'color': Colors.green, 'icon': Icons.menu_book, 'text': '📚'};
      } else if (isStarted) {
        return {
          'color': Color(0xFF9C27B0),
          'icon': Icons.menu_book,
          'text': '📚',
        };
      } else {
        return {
          'color': Color(0xFF9C27B0).withOpacity(0.6),
          'icon': Icons.lock,
          'text': '🔒',
        };
      }
    } else {
      if (isCompleted) {
        return {'color': Colors.green, 'icon': Icons.check_circle, 'text': '✓'};
      } else if (isStarted) {
        final colors = [
          Color(0xFF2196F3),
          Color(0xFF4CAF50),
          Color(0xFFE91E63),
          Color(0xFF607D8B),
        ];
        return {
          'color': colors[index % colors.length],
          'icon': Icons.play_circle,
          'text': '▶',
        };
      } else {
        return {'color': Colors.grey, 'icon': Icons.lock, 'text': '🔒'};
      }
    }
  }
}

class DuolingoPathPainter extends CustomPainter {
  final List<QueryDocumentSnapshot> lessons;
  final double pathValue;

  DuolingoPathPainter({required this.lessons, required this.pathValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (lessons.isEmpty) return;

    final paint = Paint()
      ..color = Color(0xFFD4AF37)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = Color(0xFFD4AF37).withOpacity(0.3)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sparklePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dessiner le chemin sinueux
    final path = Path();
    final points = <Offset>[];

    // Calculer les points du chemin avec le même algorithme que _calculateBubblePosition
    for (int i = 0; i < lessons.length; i++) {
      final progress = i / (lessons.length - 1);

      // Position X avec variation sinusoïdale plus prononcée
      final baseX = size.width * 0.5;
      final variationX = math.sin(progress * math.pi * 4) * (size.width * 0.35);
      final x = baseX + variationX;

      // Position Y progressive avec légères ondulations
      final baseY = 200 + (progress * (size.height - 400));
      final waveY = math.sin(progress * math.pi * 6) * 20;
      final y = baseY + waveY;

      points.add(Offset(x, y));
    }

    // Créer le chemin courbe
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        final current = points[i];
        final previous = points[i - 1];

        // Créer des courbes de Bézier plus naturelles
        final control1 = Offset(
          previous.dx + (current.dx - previous.dx) * 0.3,
          previous.dy + (current.dy - previous.dy) * 0.3 + 40,
        );
        final control2 = Offset(
          previous.dx + (current.dx - previous.dx) * 0.7,
          previous.dy + (current.dy - previous.dy) * 0.7 - 40,
        );

        path.cubicTo(
          control1.dx,
          control1.dy,
          control2.dx,
          control2.dy,
          current.dx,
          current.dy,
        );
      }
    }

    // Dessiner le chemin avec lueur
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Ajouter des étincelles animées le long du chemin
    final sparkleCount = 15;
    for (int i = 0; i < sparkleCount; i++) {
      final t = (pathValue + i * 0.08) % 1.0;
      final sparkleMetrics = path.computeMetrics().first;
      final sparklePos = sparkleMetrics.getTangentForOffset(
        sparkleMetrics.length * t,
      );

      if (sparklePos != null) {
        final sparkleX = sparklePos.position.dx;
        final sparkleY = sparklePos.position.dy;

        // Dessiner l'étincelle
        canvas.drawCircle(
          Offset(sparkleX, sparkleY),
          3 + math.sin(pathValue * 2 * math.pi + i) * 1,
          sparklePaint,
        );

        // Dessiner les rayons de l'étincelle
        final rayPaint = Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round;

        for (int k = 0; k < 4; k++) {
          final angle = k * math.pi / 2 + pathValue * 2 * math.pi;
          final rayLength = 6 + math.sin(pathValue * 4 * math.pi + k) * 2;
          final rayEndX = sparkleX + math.cos(angle) * rayLength;
          final rayEndY = sparkleY + math.sin(angle) * rayLength;

          canvas.drawLine(
            Offset(sparkleX, sparkleY),
            Offset(rayEndX, rayEndY),
            rayPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EnhancedPathPainter extends CustomPainter {
  final List<QueryDocumentSnapshot> lessons;
  final double pathValue;
  final double floatingValue;

  EnhancedPathPainter({
    required this.lessons,
    required this.pathValue,
    required this.floatingValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (lessons.isEmpty) return;

    final paint = Paint()
      ..color = Color(0xFFD4AF37)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = Color(0xFFD4AF37).withOpacity(0.3)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sparklePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dessiner le chemin sinueux
    final path = Path();
    final points = <Offset>[];

    // Calculer les points du chemin avec le même algorithme que _calculateBubblePosition
    for (int i = 0; i < lessons.length; i++) {
      final progress = i / (lessons.length - 1);

      // Position X avec variation sinusoïdale plus prononcée
      final baseX = size.width * 0.5;
      final variationX =
          math.sin(progress * math.pi * 4) * (size.width * 0.35) +
          math.sin(progress * math.pi * 8) * (size.width * 0.1) +
          math.sin(progress * math.pi * 12) *
              (size.width * 0.05) *
              math.sin(floatingValue * 2 * math.pi);
      final x = baseX + variationX;

      // Position Y progressive avec légères ondulations
      final baseY = 200 + (progress * (size.height - 400));
      final waveY =
          math.sin(progress * math.pi * 6) * 20 +
          math.sin(progress * math.pi * 12) *
              10 *
              math.sin(floatingValue * 2 * math.pi);
      final y = baseY + waveY;

      points.add(Offset(x, y));
    }

    // Créer le chemin courbe
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        final current = points[i];
        final previous = points[i - 1];

        // Créer des courbes de Bézier plus naturelles
        final control1 = Offset(
          previous.dx + (current.dx - previous.dx) * 0.3,
          previous.dy +
              (current.dy - previous.dy) * 0.3 +
              40 +
              math.sin(floatingValue * 2 * math.pi) * 10,
        );
        final control2 = Offset(
          previous.dx + (current.dx - previous.dx) * 0.7,
          previous.dy +
              (current.dy - previous.dy) * 0.7 -
              40 -
              math.sin(floatingValue * 2 * math.pi) * 10,
        );

        path.cubicTo(
          control1.dx,
          control1.dy,
          control2.dx,
          control2.dy,
          current.dx,
          current.dy,
        );
      }
    }

    // Dessiner le chemin avec lueur
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Ajouter des étincelles animées le long du chemin
    final sparkleCount = 20;
    for (int i = 0; i < sparkleCount; i++) {
      final t = (pathValue + i * 0.08) % 1.0;
      final sparkleMetrics = path.computeMetrics().first;
      final sparklePos = sparkleMetrics.getTangentForOffset(
        sparkleMetrics.length * t,
      );

      if (sparklePos != null) {
        final sparkleX = sparklePos.position.dx;
        final sparkleY = sparklePos.position.dy;

        // Dessiner l'étincelle
        canvas.drawCircle(
          Offset(sparkleX, sparkleY),
          3 +
              math.sin(pathValue * 2 * math.pi + i) * 1 +
              math.sin(floatingValue * 2 * math.pi) * 1,
          sparklePaint,
        );

        // Dessiner les rayons de l'étincelle
        final rayPaint = Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round;

        for (int k = 0; k < 4; k++) {
          final angle =
              k * math.pi / 2 +
              pathValue * 2 * math.pi +
              floatingValue * 2 * math.pi;
          final rayLength =
              6 +
              math.sin(pathValue * 4 * math.pi + k) * 2 +
              math.sin(floatingValue * 4 * math.pi + k) * 2;
          final rayEndX = sparkleX + math.cos(angle) * rayLength;
          final rayEndY = sparkleY + math.sin(angle) * rayLength;

          canvas.drawLine(
            Offset(sparkleX, sparkleY),
            Offset(rayEndX, rayEndY),
            rayPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("lessons").get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No lessons found."));
          }

          // Extract and flatten all exercises from all lessons
          final exercises = snapshot.data!.docs
              .expand((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final lessonExercises =
                    data['exercises'] as List<dynamic>? ?? [];

                // Debug: afficher les exercices bruts
                for (var ex in lessonExercises) {
                  if (ex is Map<String, dynamic> && ex['type'] == 'pairs') {
                    print('🔍 Raw pairs exercise: $ex');
                    print('🔍 Pairs field: ${ex['pairs']}');
                    print('🔍 Pairs type: ${ex['pairs'].runtimeType}');
                  }
                }

                return lessonExercises.map(
                  (ex) => Exercise.fromJson(ex as Map<String, dynamic>),
                );
              })
              .where(
                (exercise) =>
                    exercise.question.isNotEmpty && exercise.type.isNotEmpty,
              )
              .toList();

          print('Loaded  [32m${exercises.length} [0m exercises from lessons');

          // Test: créer un exercice de pairs de test
          final testExercise = Exercise.fromJson({
            "type": "pairs",
            "question": "Match each Arabic pronoun to its English meaning.",
            "instruction": "Match each Arabic pronoun to its English meaning.",
            "pairs": [
              {"from": "هَؤُلَاءِ", "to": "these (plural)"},
              {"from": "هَذَا", "to": "this (masculine singular)"},
              {"from": "هَذَانِ", "to": "these two (masculine dual)"},
              {"from": "هَذِهِ", "to": "this (feminine singular)"},
            ],
            "options": [
              "هَؤُلَاءِ",
              "هَذَا",
              "هَذَانِ",
              "هَذِهِ",
              "these (plural)",
              "this (masculine singular)",
              "these two (masculine dual)",
              "this (feminine singular)",
            ],
          });

          print('🧪 Test exercise created:');
          print('Type: ${testExercise.type}');
          print('DragDropPairs: ${testExercise.dragDropPairs}');
          print('DragDropPairs length: ${testExercise.dragDropPairs?.length}');

          print(
            '🧪 Test exercise dragDropPairs: ${testExercise.dragDropPairs}',
          );

          // Test: créer un exercice drag_drop de test
          final testDragDropExercise = Exercise.fromJson({
            "type": "drag_drop",
            "question": "Complete the sentence: هذا ____ (This is a book)",
            "answer": "كتاب",
            "options": ["كتاب", "قلم", "مدرسة", "بيت"],
          });

          print('🧪 Test drag_drop exercise created:');
          print('Type: ${testDragDropExercise.type}');
          print('Question: ${testDragDropExercise.question}');
          print('Answer: ${testDragDropExercise.answer}');
          print('Options: ${testDragDropExercise.options}');

          // Ajouter les exercices de test au début de la liste pour les tester
          exercises.insert(0, testExercise);
          exercises.insert(0, testDragDropExercise);

          // Passe la liste d'exercices à la page
          return ExercisePage(exercises: exercises);
        },
      ),
    );
  }
}
