import 'package:dualingocoran/widgets/lesson_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Fichier généré par `flutterfire configure`
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:dualingocoran/Exercises/ExercisePage.dart';
import 'package:dualingocoran/screens/profile_screen.dart';

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
  final List<Map<String, dynamic>> lessons = [
    {'title': 'Alphabet', 'icon': Icons.abc, 'completed': true, 'level': 2},
    {
      'title': 'Reading',
      'icon': Icons.menu_book,
      'completed': true,
      'level': 1,
    },
    {
      'title': 'Pronunciation',
      'icon': Icons.record_voice_over,
      'completed': false,
    },
    {'title': 'Tajwid', 'icon': Icons.auto_stories, 'completed': false},
    {'title': 'Vocabulary', 'icon': Icons.translate, 'completed': false},
  ];

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
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          itemCount: lessons.length,
          separatorBuilder: (_, __) => Center(
            child: Container(height: 40, width: 3, color: Colors.grey.shade700),
          ),

          itemBuilder: (context, index) {
            final lesson = lessons[index];
            final isCompleted = lesson['completed'] == true;
            final isUnlocked =
                index == 0 || lessons[index - 1]['completed'] == true;
            final level = lesson['level'];

            Color bubbleColor;
            if (isCompleted) {
              bubbleColor = const Color.fromARGB(255, 65, 42, 125);
            } else if (isUnlocked) {
              bubbleColor = const Color(0xFF2D6A4F);
            } else {
              bubbleColor = Colors.grey.shade800;
            }

            Widget bubble = Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isUnlocked ? Colors.black : Colors.grey.shade700,
                      width: 2,
                    ),
                    boxShadow: [
                      if (isUnlocked)
                        BoxShadow(
                          color: bubbleColor.withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(lesson['icon'], size: 32, color: Colors.white),
                      if (isCompleted && level != null)
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.yellow.shade700,
                            ),
                            child: Text(
                              '$level',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lesson['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );

            // ⚠️ Positionnement zigzag
            bool isLeft = index % 2 == 0;

            return Row(
              mainAxisAlignment: isLeft
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [bubble],
            );
          },
        ),
      ),
    );
  }
}

class _ExercisePageState extends State<ExercisePage> {
  int currentIndex = 0;

  void goToNextExercise() {
    if (currentIndex < widget.exercises.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      // Tous les exercices sont finis
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Well done!"),
          content: const Text("You’ve completed all the exercises."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = widget.exercises[currentIndex];

    // Sélectionne le bon widget selon le type
    switch (currentExercise.type) {
      case 'multiple_choice':
        return MultipleChoiceWidget(
          exercise: currentExercise,
          onNext: goToNextExercise,
        );
      case 'true_or_false':
        return TrueOrFalseWidget(
          exercise: currentExercise,
          onNext: goToNextExercise,
        );
      case 'drag_and_drop':
        return DragAndDropWidget(
          exercise: currentExercise,
          onNext: goToNextExercise,
        );
      case 'audio':
        return AudioExerciseWidget(
          exercise: currentExercise,
          onNext: goToNextExercise,
        );
      default:
        return const Center(child: Text("Unknown exercise type"));
    }
  }
}

Future<void> ajouterLeconFirestore() async {
  try {
    await FirebaseFirestore.instance
        .collection('lessons')
        .doc('Demonstrative Pronouns 1') // 🔥 NOM FIXE DU DOCUMENT
        .set({
          "title": "Demonstrative Pronouns 1",
          "category": "Pronouns",
          "newWords": [
            {"arabic": "هَذَا", "english": "this (masculine singular)"},
            {
              "arabic": "هَذِهِ",
              "english": "this (feminine singular or inanimate plural)",
            },
            {"arabic": "هَذَانِ", "english": "these two (masculine dual)"},
            {
              "arabic": "هَؤُلَاءِ",
              "english": "these (plural, masculine/feminine)",
            },
          ],
          "exercises": [
            {
              "type": "multiple_choice",
              "question": "What does هَذَا mean?",
              "options": ["that", "this (masculine singular)", "those", "he"],
              "answer": "this (masculine singular)",
            },
            {
              "type": "multiple_choice",
              "question":
                  "Which one is the correct Arabic for 'these (plural)'?",
              "options": ["هَذِهِ", "هَذَا", "هَؤُلَاءِ", "ذَلِكَ"],
              "answer": "هَؤُلَاءِ",
            },
            {
              "type": "true_or_false",
              "question":
                  "هَذِهِ refers to feminine singular or inanimate plural.",
              "answer": true,
            },
            {
              "type": "true_or_false",
              "question": "هَذَانِ is used for three or more items.",
              "answer": false,
            },
            {
              "type": "drag_and_drop",
              "instruction":
                  "Match each Arabic pronoun to its English meaning.",
              "pairs": {
                "هَذَا": "this (masculine singular)",
                "هَذَانِ": "these two (masculine dual)",
                "هَذِهِ": "this (feminine singular)",
                "هَؤُلَاءِ": "these (plural)",
              },
            },
            {
              "type": "multiple_choice",
              "question": "Which is the dual masculine form of 'this'?",
              "options": ["هَذَانِ", "هَذَا", "هَذِهِ", "هَؤُلَاءِ"],
              "answer": "هَذَانِ",
            },
            {
              "type": "drag_and_drop",
              "instruction": "Match each pronoun to the correct gender/number.",
              "pairs": {
                "هَذَا": "masculine singular",
                "هَذِهِ": "feminine singular",
                "هَذَانِ": "masculine dual",
                "هَؤُلَاءِ": "plural",
              },
            },
            {
              "type": "audio",
              "question": "Listen and choose the correct meaning.",
              "audioUrl": "audio/hadha.mp3",
              "options": ["this", "that", "he", "those"],
              "answer": "this",
            },
            {
              "type": "audio",
              "question": "Listen and identify the Arabic word.",
              "audioUrl": "audio/hadhihi.mp3",
              "options": ["هَذَا", "هَذِهِ", "هَذَانِ", "هَؤُلَاءِ"],
              "answer": "هَذِهِ",
            },
            {
              "type": "true_or_false",
              "question":
                  "هَؤُلَاءِ is used for both masculine and feminine plural.",
              "answer": true,
            },
          ],
        });
    print("Leçon ajoutée avec succès !");
  } catch (e) {
    print("Erreur lors de l'ajout de la leçon : $e");
  }
}
