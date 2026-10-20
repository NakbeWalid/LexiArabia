import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/exercises/exercise_page.dart';
import 'package:dualingocoran/screens/profile_screen.dart';
import 'package:dualingocoran/screens/roadmap_screen.dart';
import 'package:dualingocoran/screens/settings_screen.dart';
import 'package:dualingocoran/screens/progression_screen.dart';
import 'package:dualingocoran/screens/srs_review_screen.dart';
import 'package:dualingocoran/services/srs_service.dart';
import 'package:dualingocoran/services/srs_database_init.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dualingocoran/services/language_provider.dart';
import 'package:dualingocoran/services/auth_service.dart';
import 'package:dualingocoran/services/user_provider.dart';
import 'package:dualingocoran/services/notification_service.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:dualingocoran/utils/font_helper.dart';
import 'package:dualingocoran/screens/login_screen.dart';
import 'package:dualingocoran/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

/// Modifie une leçon existante avec un JSON partiel
///
/// [lessonId] : L'ID de la leçon à modifier
/// [updates] : Map contenant uniquement les champs à modifier
///
/// Exemple d'utilisation :
/// ```dart
/// await modifierLecon('Demonstrative Pronouns 1', {
///   'title': 'Nouveau titre',
///   'learningPercentage': 15.0,
/// });
/// ```
Future<void> modifierLecon(
  String lessonId,
  Map<String, dynamic> updates,
) async {
  try {
    print("🔄 Modification de la leçon: $lessonId");
    print("📝 Champs à modifier: ${updates.keys.toList()}");

    final lessonRef = FirebaseFirestore.instance
        .collection('lessons')
        .doc(lessonId);

    // Vérifier que la leçon existe
    final lessonDoc = await lessonRef.get();
    if (!lessonDoc.exists) {
      print("❌ La leçon '$lessonId' n'existe pas dans Firestore");
      return;
    }

    // Mettre à jour uniquement les champs spécifiés
    await lessonRef.update(updates);

    print("✅ Leçon '$lessonId' modifiée avec succès!");
    print("   Champs modifiés: ${updates.keys.join(", ")}");
  } catch (e) {
    print("❌ Erreur lors de la modification de la leçon '$lessonId': $e");
  }
}

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
  await NotificationService.init();
  // Modifier la leçon

  // Ajouter la nouvelle leçon
  //await verifierLecons();
  // ⬇️ AJOUTEZ CES LIGNES POUR TESTER
  //await testSRSInitialization(); // Tester l'initialisation SRS
  // ⬆️ FIN DU CODE DE TEST
  runApp(CoranLinguaApp());
}

class CoranLinguaApp extends StatelessWidget {
  const CoranLinguaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        Provider<AuthService>(create: (context) => AuthService()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'CoranLingua',
            // L'identité visuelle de l'app est uniquement sombre (noir / doré)
            themeMode: ThemeMode.dark,
            theme: buildDarkTheme(),
            darkTheme: buildDarkTheme(),
            // Configuration de l'internationalisation
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: languageProvider.currentLocale,
            // Routes
            routes: {
              '/home': (context) => MainScreen(),
              '/login': (context) => LoginScreen(),
            },
            home: InitialScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
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
        titleTextStyle: FontHelper.poppins(
          color: colorScheme.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: FontHelper.poppinsTextTheme(base.textTheme).apply(
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
          textStyle: FontHelper.poppins(
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

    // Vérifier l'état d'authentification.
    // Attendre le premier événement : Firebase restaure la session de façon
    // asynchrone, currentUser peut encore être null juste après le lancement.
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.authStateChanges.first;

    // Charger les données de l'utilisateur déjà connecté (progression, SRS...)
    // avant d'afficher MainScreen, sinon la roadmap et la vérification SRS
    // démarrent sans utilisateur.
    if (user != null && mounted) {
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).loadUser(user.uid);
    }

    if (!mounted) return;
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
  bool _hasCheckedSRS = false;

  static final List<Widget> _screens = [
    RoadmapBubbleScreen(),
    ProgressionScreen(),
    ProfilScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkSRSReviews();
  }

  /// Vérifier s'il y a des exercices SRS à réviser et afficher l'écran automatiquement
  Future<void> _checkSRSReviews() async {
    if (_hasCheckedSRS) return; // Éviter les vérifications multiples

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.userId;

      if (userId == null) {
        _hasCheckedSRS = true;
        return;
      }

      // S'assurer que SRS est initialisé
      if (!await SRSDatabaseInit.isSRSInitialized(userId)) {
        await SRSDatabaseInit.initializeSRSCollections(userId);
        _hasCheckedSRS = true;
        return;
      }

      // Vérifier s'il y a des exercices à réviser (limite quotidienne stricte)
      // IMPORTANT: ne pas "smoother" ici pour éviter des writes juste pour un check.
      final settings = await SRSService.getSettings(userId);
      final dueExercises = await SRSService.getDueExercises(userId);
      final newLimit = SRSService.computeDailyNewLimit(
        settings: settings,
        dueSelectedCount: dueExercises.length,
      );
      final newExercises = await SRSService.getNewExercises(
        userId,
        limitOverride: newLimit,
      );
      final totalExercises = dueExercises.length + newExercises.length;

      // Si il y a des exercices à réviser, afficher l'écran de révision
      if (totalExercises > 0 && mounted) {
        // Marquer comme vérifié avant la navigation pour éviter les vérifications multiples
        _hasCheckedSRS = true;

        await Future.delayed(
          const Duration(milliseconds: 800),
        ); // Petit délai pour l'animation
        if (mounted) {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => SRSReviewScreen()));
        }
      } else {
        // Pas d'exercices à réviser, marquer comme vérifié
        _hasCheckedSRS = true;
      }
    } catch (e) {
      print('❌ Erreur lors de la vérification des révisions SRS: $e');
      _hasCheckedSRS = true;
    }
  }

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
