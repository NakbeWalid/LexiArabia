import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilScreen extends StatelessWidget {
  final String userId = 'user_123'; // à rendre dynamique plus tard

  const ProfilScreen({super.key});

  Future<void> saveUserData(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': 'Bhy',
        'level': 3,
        'xp': 1200,
        'streak': 5,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Utilisateur enregistré ✅')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erreur ❌')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const String nom = 'Bhy';
    const int niveau = 3;
    const int xp = 1200;
    const int streak = 5;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(
                    'https://ui-avatars.com/api/?name=$nom&background=2D6A4F&color=fff',
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  nom,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Niveau $niveau',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // XP Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expérience',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (xp % 1000) / 1000,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade800,
                        color: const Color(0xFFD4AF37),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$xp XP',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Streak
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Streak : $streak jours',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 50, thickness: 1, color: Colors.white24),

                ElevatedButton.icon(
                  onPressed: () => saveUserData(context),
                  icon: const Icon(Icons.cloud_upload, color: Colors.white),
                  label: const Text(
                    'Enregistrer les données',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

int calculateLevel(int xp) {
  if (xp >= 3500) return 5;
  if (xp >= 2000) return 4;
  if (xp >= 1000) return 3;
  if (xp >= 500) return 2;
  return 1;
}
