import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Fichier généré par `flutterfire configure`

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
    RoadmapScreen(),
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

class RoadmapScreen extends StatelessWidget {
  final List<Map<String, dynamic>> lessons = [
    {'title': 'Alphabet', 'icon': Icons.mosque, 'completed': true},
    {'title': 'Lecture', 'icon': Icons.menu_book, 'completed': false},
    {'title': 'Prononciation', 'icon': Icons.mic, 'completed': false},
    {'title': 'Tajwid', 'icon': Icons.auto_stories, 'completed': false},
    {'title': 'Vocabulaire', 'icon': Icons.translate, 'completed': false},
  ];

  RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D6A4F),
        title: const Text('Parcours Coranique'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: lessons.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          final bool isCompleted = lesson['completed'];

          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (isCompleted ||
                      index == 0 ||
                      lessons[index - 1]['completed']) {
                    // ouvrir la leçon
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isCompleted ? const Color(0xFFE9F5EF) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFFD4AF37)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(lesson['icon'], color: Color(0xFF2D6A4F), size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          lesson['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1C1C),
                          ),
                        ),
                      ),
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.lock_open,
                        color: isCompleted ? Color(0xFFD4AF37) : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              if (index != lessons.length - 1)
                Container(height: 40, width: 4, color: Color(0xFF2D6A4F)),
            ],
          );
        },
      ),
    );
  }
}

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  int currentIndex = 0;
  List<DocumentSnapshot> exercises = [];
  bool isLoading = true;
  String? selectedOption;
  bool showFeedback = false;

  @override
  void initState() {
    super.initState();
    loadExercises();
    print("salut123");
  }

  Future<void> loadExercises() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('exercises')
        .get();
    setState(() {
      exercises = snapshot.docs;

      isLoading = false;
    });
  }

  void checkAnswer(String selected) {
    setState(() {
      selectedOption = selected;
      showFeedback = true;
    });
  }

  void nextQuestion() {
    setState(() {
      if (currentIndex < exercises.length - 1) {
        currentIndex++;
        selectedOption = null;
        showFeedback = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Exercices')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentIndex >= exercises.length) {
      return Scaffold(
        appBar: AppBar(title: Text('Exercices terminés')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              SizedBox(height: 20),
              Text(
                'Bravo ! Tu as terminé tous les exercices.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentIndex = 0;
                    selectedOption = null;
                    showFeedback = false;
                  });
                },
                child: Text('Recommencer'),
              ),
            ],
          ),
        ),
      );
    }

    final exercise = exercises[currentIndex];
    final question = exercise['question'];
    final options = List<String>.from(exercise['options']);
    final answer = exercise['correct_answer'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Exercice ${currentIndex + 1}/${exercises.length}'),
        backgroundColor: Color(0xFF2D6A4F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            ...options.map(
              (option) => Card(
                color: selectedOption == option
                    ? (option == answer ? Colors.green : Colors.red.shade300)
                    : null,
                child: ListTile(
                  title: Text(option, style: TextStyle(fontSize: 18)),
                  onTap: selectedOption == null
                      ? () => checkAnswer(option)
                      : null,
                ),
              ),
            ),
            SizedBox(height: 30),
            if (showFeedback)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D6A4F),
                ),
                onPressed: nextQuestion,
                child: Text(
                  currentIndex < exercises.length - 1 ? 'Suivant' : 'Terminer',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfilScreen extends StatelessWidget {
  final String userId = 'user_123';

  const ProfilScreen({super.key});

  Future<void> saveUserData(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc('user_123').set({
        'name': 'Bhy',
        'level': 3,
        'xp': 1200,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur enregistré dans Firebase ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement ❌')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nom = 'Bhy';
    final int niveau = 3;
    final int xp = 1200;
    final String avatarUrl =
        'https://ui-avatars.com/api/?name=Bhy&background=2D6A4F&color=fff&rounded=true';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2D6A4F),
        elevation: 0,
        title: Text('Profil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(avatarUrl),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 20),
            Text(
              nom,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D6A4F),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Niveau $niveau',
              style: TextStyle(fontSize: 18, color: Color(0xFF1C1C1C)),
            ),
            SizedBox(height: 20),
            Text(
              'Expérience',
              style: TextStyle(fontSize: 18, color: Color(0xFF1C1C1C)),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: xp % 1000 / 1000,
              backgroundColor: Colors.grey.shade300,
              color: Color(0xFFD4AF37),
              minHeight: 10,
            ),
            SizedBox(height: 10),
            Text('$xp XP', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            SizedBox(height: 20),
            Divider(),
            ListTile(
              leading: Icon(Icons.emoji_events, color: Color(0xFF2D6A4F)),
              title: Text('Badges débloqués'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Color(0xFF2D6A4F)),
              title: Text('Paramètres du compte'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Se déconnecter'),
              onTap: () {},
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => saveUserData(context),
              icon: Icon(Icons.cloud_upload),
              label: Text("Tester ajout dans Firebase"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2D6A4F),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> ajouterExercices() async {
  final firestore = FirebaseFirestore.instance;

  final exercices = [
    {
      "question": "Quel est le sens du mot 'صلاة' ?",
      "word": "صلاة",
      "correct_answer": "Prière",
      "options": ["Prière", "Jeûne", "Zakat", "Pèlerinage"],
    },
    {
      "question": "Quel est le sens du mot 'صوم' ?",
      "word": "صوم",
      "correct_answer": "Jeûne",
      "options": ["Prière", "Jeûne", "Lecture", "Prosternation"],
    },
    {
      "question": "Quel est le sens du mot 'قرآن' ?",
      "word": "قرآن",
      "correct_answer": "Lecture",
      "options": ["Lecture", "Chanson", "Discours", "Hadith"],
    },
    {
      "question": "Quel est le sens du mot 'نار' ?",
      "word": "نار",
      "correct_answer": "Feu",
      "options": ["Feu", "Eau", "Ciel", "Lumière"],
    },
    {
      "question": "Quel est le sens du mot 'جنة' ?",
      "word": "جنة",
      "correct_answer": "Paradis",
      "options": ["Paradis", "Enfer", "Tombe", "Dunya"],
    },
    {
      "question": "Quel est le sens du mot 'زكاة' ?",
      "word": "زكاة",
      "correct_answer": "Aumône",
      "options": ["Aumône", "Prière", "Fête", "Foi"],
    },
    {
      "question": "Quel est le sens du mot 'إيمان' ?",
      "word": "إيمان",
      "correct_answer": "Foi",
      "options": ["Foi", "Richesse", "Crainte", "Islam"],
    },
    {
      "question": "Quel est le sens du mot 'نور' ?",
      "word": "نور",
      "correct_answer": "Lumière",
      "options": ["Lumière", "Ombre", "Vent", "Terre"],
    },
    {
      "question": "Quel est le sens du mot 'يوم' ?",
      "word": "يوم",
      "correct_answer": "Jour",
      "options": ["Jour", "Mois", "Année", "Matin"],
    },
    {
      "question": "Quel est le sens du mot 'حج' ?",
      "word": "حج",
      "correct_answer": "Pèlerinage",
      "options": ["Pèlerinage", "Mariage", "Aumône", "Jeûne"],
    },
  ];

  for (final exo in exercices) {
    await firestore.collection('exercises').add(exo);
  }

  print('✅ Les 10 exercices ont été ajoutés à Firestore');
}
