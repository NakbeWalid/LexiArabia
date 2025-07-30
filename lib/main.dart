import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Fichier généré par `flutterfire configure`
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/Exercises/exercise_page.dart';
import 'package:dualingocoran/screens/profile_screen.dart';

Future<void> ajouterLeconFirestore() async {
  try {
    await FirebaseFirestore.instance
        .collection('lessons')
        .doc('Relative Pronouns') // 🔥 NOM FIXE DU DOCUMENT
        .set({
          "title": "Relative Pronouns – Who, Which, That",
          "description":
              "Learn how to use Arabic relative pronouns: الَّذِي, الَّتِي, الَّذِينَ, الَّلَائِي.",
          "words": ["الَّذِي", "الَّتِي", "الَّذِينَ", "اللَّائِي"],
          "exercises": [
            {
              "type": "multiple_choice",
              "question":
                  "Which relative pronoun is used for: 'The man **who** prays'?",
              "options": ["الَّذِينَ", "اللَّائِي", "الَّذِي", "الَّتِي"],
              "answer": "الَّذِي",
            },
            {
              "type": "multiple_choice",
              "question":
                  "You want to say: 'The woman **who** reads.' What do you use?",
              "options": ["الَّتِي", "الَّذِي", "الَّذِينَ", "اللَّائِي"],
              "answer": "الَّتِي",
            },
            {
              "type": "multiple_choice",
              "question":
                  "Pick the correct pronoun: 'Those (men) who believe are successful.'",
              "options": ["الَّذِي", "اللَّائِي", "الَّذِينَ", "الَّتِي"],
              "answer": "الَّذِينَ",
            },
            {
              "type": "multiple_choice",
              "question": "Which one is used for groups of women?",
              "options": ["الَّذِي", "الَّذِينَ", "الَّتِي", "اللَّائِي"],
              "answer": "اللَّائِي",
            },
            {
              "type": "drag_drop",
              "question":
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
              "answer": [
                {"from": "الَّذِي", "to": "who (masculine)"},
                {"from": "الَّتِي", "to": "who (feminine)"},
                {"from": "الَّذِينَ", "to": "those who (masc.)"},
                {"from": "اللَّائِي", "to": "those who (fem.)"},
              ],
            },
            {
              "type": "true_false",
              "question": "“اللَّائِي” can be used for a group of men.",
              "answer": "false",
            },
            {
              "type": "true_false",
              "question": "“الَّتِي” is used for singular feminine nouns.",
              "answer": "true",
            },
            {
              "type": "audio_choice",
              "question": "Which pronoun do you hear?",
              "audioUrl": "https://example.com/audio/allathi.mp3",
              "options": ["الَّتِي", "الَّذِي", "الَّذِينَ"],
              "answer": "الَّذِي",
            },
            {
              "type": "audio_choice",
              "question": "Listen and choose: what do you hear?",
              "audioUrl": "https://example.com/audio/allatheena.mp3",
              "options": ["اللَّائِي", "الَّذِينَ", "الَّتِي"],
              "answer": "الَّذِينَ",
            },
            {
              "type": "multiple_choice",
              "question":
                  "Choose the correct full phrase: 'The students **who** study succeed.'",
              "options": [
                "الطُّلاَّبُ الَّذِي يَدرُسُونَ",
                "الطُّلاَّبُ الَّذِينَ يَدرُسُونَ",
                "الطُّلاَّبُ الَّتِي يَدرُسُونَ",
                "الطُّلاَّبُ اللَّائِي يَدرُسُونَ",
              ],
              "answer": "الطُّلاَّبُ الَّذِينَ يَدرُسُونَ",
            },
          ],
        });
    print("Leçon ajoutée avec succès !");
  } catch (e) {
    print("Erreur lors de l'ajout de la leçon : $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ajouterLeconFirestore();

  runApp(const CoranLinguaApp());
}

class CoranLinguaApp extends StatelessWidget {
  const CoranLinguaApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
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
    // à _screens
    Center(child: Text('Progression', style: TextStyle(fontSize: 24))),
    ProfilScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF2D6A4F),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Cours'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Exercices',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Progression'),
        ],
      ),
    );
  }
}

class RoadmapBubbleScreen extends StatelessWidget {
  final int streak = 5; // 🔥 jours d'affilée
  final int lives = 3; // ❤️ vies restantes

  RoadmapBubbleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: Color(0xFF0F2027),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF0F2027),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    3,
                    (index) => Icon(
                      index < lives ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$streak",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B1B2F), Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildFirestoreZigzagRoadmap(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirestoreZigzagRoadmap(BuildContext context) {
    final double maxWidth = 280; // Réduit pour rapprocher les bulles
    final double bubbleSize = 60; // Plus petites bulles
    final double verticalSpacing = 20; // Espacement vertical réduit
    final double horizontalOffset = 40; // Offset horizontal réduit

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('lessons').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Aucune leçon trouvée."));
        }
        final lessons = snapshot.data!.docs;
        return SizedBox(
          width: maxWidth,
          child: Stack(
            children: [
              // CustomPaint for the luminous path
              Positioned.fill(
                child: CustomPaint(
                  painter: _ZigzagPathPainter(
                    itemCount: lessons.length,
                    bubbleSize: bubbleSize,
                    verticalSpacing: verticalSpacing,
                    horizontalOffset: horizontalOffset,
                    maxWidth: maxWidth,
                  ),
                ),
              ),
              // Bubbles
              Column(
                children: List.generate(lessons.length, (index) {
                  final lessonDoc = lessons[index];
                  final lesson = lessonDoc.data() as Map<String, dynamic>;
                  final title = lesson['title'] ?? 'Lesson';
                  final isCompleted =
                      index == 0; // TODO: à remplacer par ta logique
                  final isUnlocked =
                      index == 0 ||
                      (index > 0); // TODO: à remplacer par ta logique
                  final level = lesson['level'];
                  final isLeft = index % 2 == 0;
                  // Icône dynamique ou par défaut
                  final icon = index == 0
                      ? Icons.abc
                      : index == 1
                      ? Icons.menu_book
                      : Icons.school;

                  Color bubbleColor;
                  Gradient? bubbleGradient;
                  if (isCompleted) {
                    bubbleColor = const Color(0xFF2D6A4F);
                    bubbleGradient = const LinearGradient(
                      colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    );
                  } else if (isUnlocked) {
                    bubbleColor = const Color(0xFFD4AF37);
                    bubbleGradient = const LinearGradient(
                      colors: [Color(0xFFFFE259), Color(0xFFFFA751)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    );
                  } else {
                    bubbleColor = Colors.grey.shade700;
                    bubbleGradient = const LinearGradient(
                      colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    );
                  }

                  // Récupère les exercices de la leçon
                  final exercisesRaw =
                      lesson['exercises'] as List<dynamic>? ?? [];
                  final exercises = exercisesRaw
                      .map(
                        (ex) => Exercise.fromJson(ex as Map<String, dynamic>),
                      )
                      .where(
                        (exercise) =>
                            exercise.question.isNotEmpty &&
                            exercise.type.isNotEmpty,
                      )
                      .toList();

                  return Container(
                    margin: EdgeInsets.only(
                      top: index == 0 ? 0 : verticalSpacing,
                    ),
                    child: Row(
                      mainAxisAlignment: isLeft
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            left: isLeft ? horizontalOffset : 0,
                            right: isLeft ? 0 : horizontalOffset,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: isUnlocked && exercises.isNotEmpty
                                    ? () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ExercisePage(
                                              exercises: exercises,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  width: bubbleSize,
                                  height: bubbleSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: bubbleGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: bubbleColor.withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: isCompleted
                                          ? Colors.greenAccent
                                          : isUnlocked
                                          ? const Color(0xFFD4AF37)
                                          : Colors.grey.shade500,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: isUnlocked
                                        ? Icon(
                                            icon,
                                            size: 28,
                                            color: isCompleted
                                                ? Colors.white
                                                : Colors.black,
                                          )
                                        : const Icon(
                                            Icons.lock,
                                            size: 28,
                                            color: Colors.white70,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isUnlocked
                                        ? Colors.white
                                        : Colors.grey.shade400,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCompleted && level != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.shade700,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.greenAccent.withOpacity(
                                          0.2,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'Lv $level',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ZigzagPathPainter extends CustomPainter {
  final int itemCount;
  final double bubbleSize;
  final double verticalSpacing;
  final double horizontalOffset;
  final double maxWidth;

  _ZigzagPathPainter({
    required this.itemCount,
    required this.bubbleSize,
    required this.verticalSpacing,
    required this.horizontalOffset,
    required this.maxWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < itemCount - 1; i++) {
      final isLeftCurrent = i % 2 == 0;
      final isLeftNext = (i + 1) % 2 == 0;

      // Position du centre de la bulle actuelle
      final startX = isLeftCurrent
          ? horizontalOffset + bubbleSize / 2
          : maxWidth - horizontalOffset - bubbleSize / 2;
      final startY = i * (bubbleSize + verticalSpacing) + bubbleSize / 2;

      // Position du centre de la bulle suivante
      final endX = isLeftNext
          ? horizontalOffset + bubbleSize / 2
          : maxWidth - horizontalOffset - bubbleSize / 2;
      final endY = (i + 1) * (bubbleSize + verticalSpacing) + bubbleSize / 2;

      // Dessine une ligne droite entre les deux centres
      canvas.drawLine(
        Offset(startX, startY + bubbleSize / 2), // Commence au bas de la bulle
        Offset(
          endX,
          endY - bubbleSize / 2,
        ), // Finit au haut de la bulle suivante
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

          // Passe la liste d'exercices à la page
          return ExercisePage(exercises: exercises);
        },
      ),
    );
  }
}
