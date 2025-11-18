import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/exercise_page.dart';
import 'package:dualingocoran/screens/profile_screen.dart';
import 'package:dualingocoran/screens/lesson_preview_screen.dart';
import 'package:dualingocoran/screens/settings_screen.dart';
import 'package:dualingocoran/screens/progression_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dualingocoran/services/language_provider.dart';
import 'package:dualingocoran/services/auth_service.dart';
import 'package:dualingocoran/services/theme_provider.dart';
import 'package:dualingocoran/services/user_provider.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:dualingocoran/utils/translation_helper.dart';
import 'package:dualingocoran/screens/login_screen.dart';
import 'package:dualingocoran/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dualingocoran/services/learning_progress_service.dart';

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
      await FirebaseFirestore.instance
          .collection('lessons')
          .doc('Independent Pronouns - Masculine')
          .set({
            "category": "Pronouns",
            "title": "Dual & Inanimate Pronouns",
            "section": "Leçon 4",
            "description": {
              "ar":
                  "تعلّم الضمائر للمثنى وللجماد: هُمَا (هما)، كُمَا (أنتما)، هَا (ها). تُستخدم هذه الضمائر في القرآن الكريم للإشارة إلى شخصين أو أشياء غير عاقلة.",
              "en":
                  "Learn the dual and inanimate pronouns in Arabic: هُمَا (they two), كُمَا (you two), and هَا (her/it). These pronouns appear in the Qur'an to refer to two persons or non-living things.",
              "fr":
                  "Apprends les pronoms du duel et de l’inanimé en arabe : هُمَا (eux deux), كُمَا (vous deux), et هَا (elle / cela). Ces pronoms apparaissent souvent dans le Coran pour désigner deux personnes ou des objets.",
            },
            "words": [
              {
                "word": "هُمَا",
                "translation": "They two",
                "description": "Refers to two people or things.",
                "example": {
                  "ar": "اللَّهُ خَلَقَهُمَا (الله خلقهما)",
                  "en": "Allah created both of them.",
                  "fr": "Allah les a tous deux créés.",
                },
                "audioUrl": "audio/humaa.mp3",
              },
              {
                "word": "كُمَا",
                "translation": "You two",
                "description": "Used when addressing two people.",
                "example": {
                  "ar": "أَنْتُمَا تُصَلِّيَانِ (أنتما تصليان)",
                  "en": "You two pray.",
                  "fr": "Vous deux priez.",
                },
                "audioUrl": "audio/kumaa.mp3",
              },
              {
                "word": "هَا",
                "translation": "Her / It",
                "description": "Refers to a feminine or inanimate object.",
                "example": {
                  "ar": "رَأَيْتُهَا (رأيتها)",
                  "en": "I saw her / it.",
                  "fr": "Je l’ai vue / je l’ai vu (objet).",
                },
                "audioUrl": "audio/haa.mp3",
              },
            ],
            "exercises": [
              {
                "type": "multiple_choice",
                "question": "Which pronoun means 'they two'?",
                "options": ["هُمَا", "كُمَا", "هَا", "هُمْ"],
                "answer": "هُمَا",
              },
              {
                "type": "multiple_choice",
                "question": "What does 'كُمَا' mean?",
                "options": ["You two", "They", "She", "We two"],
                "answer": "You two",
              },
              {
                "type": "true_false",
                "question": "هَا is used for masculine nouns.",
                "answer": false,
              },
              {
                "type": "audio_choice",
                "question": "Listen and choose the correct pronoun you hear.",
                "audioUrl": "audio/humaa.mp3",
                "options": ["هُمَا", "كُمَا", "هَا", "هُمْ"],
                "answer": "هُمَا",
              },
              {
                "type": "drag_drop",
                "question":
                    "Match each Arabic pronoun with its English meaning.",
                "pairs": {
                  "هُمَا": "They two",
                  "كُمَا": "You two",
                  "هَا": "Her / It",
                },
              },
              {
                "type": "true_false",
                "question": "كُمَا can refer to two men or two women.",
                "answer": true,
              },
              {
                "type": "multiple_choice",
                "question":
                    "Complete the sentence: اللَّهُ خَلَقَ ___ (Allah created both of them).",
                "options": ["هُمَا", "كُمَا", "هَا", "هُمْ"],
                "answer": "هُمَا",
              },
              {
                "type": "audio_choice",
                "question":
                    "Listen to the audio and select the correct translation.",
                "audioUrl": "audio/haa.mp3",
                "options": ["She / It", "You two", "They two", "He"],
                "answer": "She / It",
              },
              {
                "type": "drag_drop",
                "question":
                    "Complete the phrase: أَنْتُمَا ___ (You two pray).",
                "sentence": "أَنْتُمَا ___",
                "choices": [
                  "تُصَلِّيَانِ",
                  "يُصَلُّونَ",
                  "تَدْرُسَانِ",
                  "تَقْرَآنِ",
                ],
                "answer": "تُصَلِّيَانِ",
              },
              {
                "type": "pairs",
                "question": "Match each sentence with its translation.",
                "pairs": {
                  "هُمَا يَدْرُسَانِ الْقُرْآنَ": "They two study the Qur’an.",
                  "رَأَيْتُهَا فِي الْمَسْجِدِ": "I saw her in the mosque.",
                  "كُمَا تَقْرَآنِ الْكِتَابَ": "You two read the book.",
                },
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

const bool kAuthGuardEnabledForTesting = false;

class CoranLinguaApp extends StatelessWidget {
  const CoranLinguaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        Provider<AuthService>(create: (context) => AuthService()),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, child) {
          return StreamBuilder<User?>(
            stream: context.read<AuthService>().authStateChanges,
            builder: (context, snapshot) {
              return MaterialApp(
                title: 'CoranLingua',
                themeMode: themeProvider.themeMode,
                theme: buildLightTheme(),
                darkTheme: buildDarkTheme(),
                // Configuration de l'internationalisation
                localizationsDelegates: [
                  ...AppLocalizations.localizationsDelegates,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                locale: languageProvider.currentLocale,
                // Routes
                routes: {
                  '/home': (context) => MainScreen(),
                  '/login': (context) => LoginScreen(),
                },
                // Temporairement désactivé pour les tests via kAuthGuardEnabledForTesting
                home: kAuthGuardEnabledForTesting
                    ? (snapshot.hasData ? MainScreen() : LoginScreen())
                    : InitialScreen(),
                debugShowCheckedModeBanner: false,
                // showPerformanceOverlay: true,
              );
            },
          );
        },
      ),
    );
  }

  ThemeData buildLightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = base.colorScheme.copyWith(
      primary: const Color(0xFFD4AF37),
      secondary: const Color(0xFF6D5DF6),
      background: const Color(0xFFF4F7FF),
      surface: Colors.white,
      onBackground: const Color(0xFF1B1B33),
      onSurface: const Color(0xFF1B1B33),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      primaryColor: colorScheme.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: colorScheme.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: colorScheme.onBackground,
        displayColor: colorScheme.onBackground,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardColor: colorScheme.surface,
    );
  }

  ThemeData buildDarkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = base.colorScheme.copyWith(
      primary: const Color(0xFFD4AF37),
      secondary: const Color(0xFF6D5DF6),
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      onBackground: Colors.white,
      onSurface: Colors.white,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      primaryColor: colorScheme.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: colorScheme.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: colorScheme.onBackground,
        displayColor: colorScheme.onBackground,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF050505),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardColor: colorScheme.surface,
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    // Vérifier l'état d'authentification
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    setState(() {
      _showOnboarding = !onboardingCompleted;
      _isLoading = false;
    });

    // Si l'onboarding est complété mais l'utilisateur n'est pas connecté,
    // rediriger vers la page de connexion
    if (mounted && onboardingCompleted && user == null) {
      // Attendre un peu pour que l'écran de chargement soit visible
      await Future.delayed(Duration(milliseconds: 300));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F0C29), Color(0xFF24243e), Color(0xFF302B63)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
          ),
        ),
      );
    }

    // Si l'onboarding n'est pas complété, afficher l'onboarding
    if (_showOnboarding) {
      return OnboardingScreen();
    }

    // Vérifier à nouveau l'authentification avant d'afficher MainScreen
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    // Si l'utilisateur n'est pas connecté, afficher la page de connexion
    if (user == null) {
      return LoginScreen();
    }

    // Sinon, afficher MainScreen
    return MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _previousIndex = 0;

  static final List<Widget> _screens = [
    RoadmapBubbleScreen(),
    ProgressionScreen(),
    ProfilScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _previousIndex = _selectedIndex;
        _selectedIndex = index;
      });
    }
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

                  return Flexible(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        fontSize: isSelected ? 9 : 8,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Déterminer la direction de la transition
          final isMovingForward = _selectedIndex > _previousIndex;

          // Animation combinée : Slide + Fade + Scale pour un effet fluide et moderne
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: Offset(isMovingForward ? 0.3 : -0.3, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Interval(0.0, 0.7, curve: Curves.easeOut),
                ),
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          child: _screens[_selectedIndex],
        ),
      ),
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
                _buildNavItem(1, Icons.trending_up, 'progression'),
                _buildNavItem(2, Icons.person, 'profile'),
                _buildNavItem(3, Icons.settings, 'settings'),
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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _bubbleController;
  late AnimationController _sectionPanelController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  List<QueryDocumentSnapshot> _lessons = [];
  List<Map<String, dynamic>> _sections = [];
  String _currentSection = '';
  final ScrollController _scrollController = ScrollController();
  List<Animation<double>> _bubbleAnimations = [];
  double _learningPercentage = 0.0;
  late AnimationController _percentageController;

  @override
  void initState() {
    super.initState();
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

    _percentageController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadLessons();
    _loadLearningPercentage();
    _setupScrollListener();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bubbleController.dispose();
    _sectionPanelController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _percentageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recharger le pourcentage quand l'app revient au premier plan
      _loadLearningPercentage();
    }
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

  Future<void> _loadLearningPercentage() async {
    try {
      final percentage = await LearningProgressService.getLearningPercentage();
      if (mounted) {
        setState(() {
          _learningPercentage = percentage;
        });
        // Animer le pourcentage
        _percentageController.reset();
        _percentageController.forward();
      }
    } catch (e) {
      print('Erreur lors du chargement du pourcentage: $e');
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
      // Extraire le sectionTitle (Map de traductions uniquement)
      // Note: Cette méthode n'a pas accès au context, donc on utilise anglais comme fallback
      String sectionTitleText = sectionName;
      if (sectionData['sectionTitle'] != null &&
          sectionData['sectionTitle'] is Map) {
        final titleMap = sectionData['sectionTitle'] as Map<String, dynamic>;
        sectionTitleText =
            titleMap['en']?.toString() ??
            titleMap['fr']?.toString() ??
            titleMap['ar']?.toString() ??
            sectionName;
      }

      sections.add({
        'name': sectionName,
        'title': sectionTitleText,
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
        return 2;
      case 'pronouns':
        return 1;
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
                      children: [
                        // Icône avec effet de brillance dorée
                        Container(
                          padding: EdgeInsets.all(12),
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
                        SizedBox(width: 12),
                        // Informations de la section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentSectionData['title'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                currentSectionData['description'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bienvenue dans votre parcours !',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Text(
                  'Commencez votre apprentissage de l\'arabe',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '5 jours',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
          SizedBox(height: 12),
          // Widget de pourcentage d'apprentissage (discret)
          _buildLearningPercentageWidget(),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildLearningPercentageWidget() {
    return AnimatedBuilder(
      animation: _percentageController,
      builder: (context, child) {
        final animatedPercentage =
            _learningPercentage * _percentageController.value;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xFFD4AF37).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône discrète
              Icon(
                Icons.trending_up,
                color: Color(0xFFD4AF37).withOpacity(0.8),
                size: 16,
              ),
              SizedBox(width: 8),
              // Pourcentage
              Text(
                '${animatedPercentage.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(width: 8),
              // Barre de progression linéaire discrète
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      width: 60 * (animatedPercentage / 100),
                      decoration: BoxDecoration(
                        color: Color(0xFFD4AF37).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedRoadmap() {
    // Organiser les leçons par section avec leurs index globaux
    final List<Map<String, dynamic>> roadmapItems = [];
    int globalIndex = 0;

    // Si _sections est vide, utiliser directement _lessons (fallback)
    if (_sections.isEmpty && _lessons.isNotEmpty) {
      // Afficher toutes les leçons sans séparateurs
      for (int i = 0; i < _lessons.length; i++) {
        final lesson = _lessons[i];
        final data = lesson.data() as Map<String, dynamic>;
        roadmapItems.add({
          'type': 'lesson',
          'lesson': lesson,
          'data': data,
          'index': i,
          'originalIndex': i,
        });
      }
    } else if (_sections.isNotEmpty) {
      // Organiser par sections avec séparateurs
      for (
        int sectionIndex = 0;
        sectionIndex < _sections.length;
        sectionIndex++
      ) {
        final section = _sections[sectionIndex];
        final sectionLessons =
            section['lessons'] as List<QueryDocumentSnapshot>? ?? [];

        // Ajouter un séparateur de section pour toutes les sections (y compris la première)
        if (sectionLessons.isNotEmpty) {
          roadmapItems.add({
            'type': 'separator',
            'sectionName': section['name'] as String,
            'sectionTitle': section['title'] as String,
            'index': globalIndex,
          });
          globalIndex++;
        }

        // Ajouter les leçons de cette section
        for (final lesson in sectionLessons) {
          final data = lesson.data() as Map<String, dynamic>;
          // Trouver l'index original de la leçon dans _lessons
          final originalIndex = _lessons.indexWhere((l) => l.id == lesson.id);
          roadmapItems.add({
            'type': 'lesson',
            'lesson': lesson,
            'data': data,
            'index': globalIndex,
            'originalIndex': originalIndex >= 0 ? originalIndex : globalIndex,
          });
          globalIndex++;
        }
      }
    }

    // Debug: vérifier le nombre d'items
    print(
      '📊 Roadmap items: ${roadmapItems.length} (sections: ${_sections.length}, lessons: ${_lessons.length})',
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: _calculateRoadmapHeight(roadmapItems.length),
      child: Stack(
        children: [
          // Items de la roadmap (séparateurs + leçons)
          ...roadmapItems.map((item) {
            if (item['type'] == 'separator') {
              return _buildSectionSeparator(
                item['sectionTitle'] as String,
                item['index'] as int,
                roadmapItems.length,
              );
            } else {
              final data = item['data'] as Map<String, dynamic>;
              final index = item['index'] as int;
              final originalIndex = item['originalIndex'] as int? ?? index;

              // Extraire le titre (Map de traductions uniquement)
              String titleText = 'Unknown';
              if (data['title'] != null && data['title'] is Map) {
                final titleMap = data['title'] as Map<String, dynamic>;
                titleText = TranslationHelper.getTranslation(
                  context,
                  titleMap,
                  'title',
                );
              }

              // Extraire la description (Map de traductions uniquement)
              String descriptionText = '';
              if (data['description'] != null && data['description'] is Map) {
                final descMap = data['description'] as Map<String, dynamic>;
                descriptionText = TranslationHelper.getTranslation(
                  context,
                  descMap,
                  'description',
                );
              }

              return _buildEnhancedLessonBubble(
                context,
                titleText,
                descriptionText,
                data['words'] as List<dynamic>? ?? [],
                data['exercises'] as List<dynamic>? ?? [],
                originalIndex, // Index pour les animations (dans _lessons)
                index, // Index pour le positionnement (dans roadmapItems)
                roadmapItems.length, // Nombre total d'items dans la roadmap
                data['completed'] == true,
                data['started'] == true,
              );
            }
          }),
        ],
      ),
    );
  }

  double _calculateRoadmapHeight([int? itemCount]) {
    final count = itemCount ?? _lessons.length;
    if (count == 0) return 400;

    // Hauteur basée sur le nombre d'items (leçons + séparateurs) et l'espacement
    // Les séparateurs prennent ~80px de hauteur
    return 200 + (count * 160.0) + 200;
  }

  Widget _buildSectionSeparator(
    String sectionTitle,
    int index,
    int totalItems,
  ) {
    final position = _calculateEnhancedBubblePosition(index, totalItems);

    return Positioned(
      left: 0,
      right: 0,
      top: position.dy - 40,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ligne horizontale
            Container(
              height: 2,
              margin: EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            // Texte de la section au centre
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF302B63).withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                sectionTitle,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedLessonBubble(
    BuildContext context,
    String title,
    String description,
    List<dynamic> newWords,
    List<dynamic> exercises,
    int animationIndex, // Index pour les animations (dans _lessons)
    int positionIndex, // Index pour le positionnement (dans roadmapItems)
    int totalItems, // Nombre total d'items dans la roadmap
    bool isCompleted,
    bool isStarted,
  ) {
    if (animationIndex >= _bubbleAnimations.length) return SizedBox.shrink();

    final position = _calculateEnhancedBubblePosition(
      positionIndex,
      totalItems,
    );
    final bubbleInfo = _getEnhancedBubbleInfo(
      animationIndex,
      totalItems,
      isCompleted,
      isStarted,
    );

    return Positioned(
      left: position.dx - 60,
      top: position.dy - 60,
      child: AnimatedBuilder(
        animation: _bubbleAnimations[animationIndex],
        builder: (context, child) {
          final animationValue = _bubbleAnimations[animationIndex].value;

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
                        bottom: 20,
                        left: 6,
                        right: 6,
                        child: Text(
                          _getShortTitle(title),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
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

  String _getShortTitle(String title) {
    // Si le titre est court, le retourner tel quel
    if (title.length <= 20) return title;

    // Prendre les 2-3 premiers mots maximum
    final words = title.split(' ');
    if (words.length <= 2) {
      // Si 2 mots ou moins, prendre les 18 premiers caractères en coupant au dernier espace
      if (title.length > 18) {
        final lastSpace = title.lastIndexOf(' ', 18);
        if (lastSpace > 0) {
          return title.substring(0, lastSpace);
        }
        return title.substring(0, 18);
      }
      return title;
    }

    // Prendre les 2 premiers mots
    return '${words[0]} ${words[1]}';
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
