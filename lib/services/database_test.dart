import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseTest {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tester la connexion à Firestore
  static Future<void> testConnection() async {
    try {
      print('🔍 Test de connexion à Firestore...');
      
      // Essayer de lire une collection
      final snapshot = await _firestore.collection('test').limit(1).get();
      print('✅ Connexion Firestore réussie');
    } catch (e) {
      print('❌ Erreur de connexion Firestore: $e');
    }
  }

  // Lister tous les utilisateurs
  static Future<void> listAllUsers() async {
    try {
      print('👥 Liste de tous les utilisateurs:');
      
      final snapshot = await _firestore.collection('users').get();
      print('📊 Nombre total d\'utilisateurs: ${snapshot.docs.length}');
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final profile = data['profile'] ?? {};
        print('   - ${doc.id}: ${profile['username'] ?? 'Unknown'} (${profile['displayName'] ?? 'No name'})');
      }
    } catch (e) {
      print('❌ Erreur lors de la liste des utilisateurs: $e');
    }
  }

  // Lister tous les achievements
  static Future<void> listAllAchievements() async {
    try {
      print('🏆 Liste de tous les achievements:');
      
      final snapshot = await _firestore.collection('achievements').get();
      print('📊 Nombre total d\'achievements: ${snapshot.docs.length}');
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        print('   - ${doc.id}: ${data['name'] ?? 'Unknown'} (${data['tier'] ?? 'No tier'})');
      }
    } catch (e) {
      print('❌ Erreur lors de la liste des achievements: $e');
    }
  }

  // Tester la création d'un utilisateur simple
  static Future<void> testCreateSimpleUser() async {
    try {
      print('🧪 Test de création d\'un utilisateur simple...');
      
      final testUser = {
        'profile': {
          'username': 'test_user',
          'email': 'test@test.com',
          'displayName': 'Test User',
          'bio': 'Utilisateur de test',
          'nativeLanguage': 'en',
          'learningLanguage': 'ar',
          'createdAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
        },
        'stats': {
          'totalXP': 100,
          'currentLevel': 1,
          'currentStreak': 0,
          'bestStreak': 0,
          'lessonsCompleted': 0,
          'totalLessons': 10,
          'exercisesCompleted': 0,
          'wordsLearned': 0,
          'accuracy': 0.0,
          'totalStudyTime': 0,
        },
        'progress': {
          'lessons': {},
          'sections': {},
        },
        'achievements': {},
        'studySessions': [],
        'dailyProgress': {},
      };

      await _firestore.collection('users').doc('test_user_001').set(testUser);
      print('✅ Utilisateur de test créé avec succès');
    } catch (e) {
      print('❌ Erreur lors de la création de l\'utilisateur de test: $e');
    }
  }

  // Nettoyer les utilisateurs de test
  static Future<void> cleanupTestUsers() async {
    try {
      print('🧹 Nettoyage des utilisateurs de test...');
      
      final testUsers = ['test_user_001'];
      for (final userId in testUsers) {
        await _firestore.collection('users').doc(userId).delete();
        print('✅ Utilisateur de test supprimé: $userId');
      }
    } catch (e) {
      print('❌ Erreur lors du nettoyage: $e');
    }
  }

  // Exécuter tous les tests
  static Future<void> runAllTests() async {
    print('🚀 Démarrage des tests de base de données...\n');
    
    await testConnection();
    print('');
    
    await listAllAchievements();
    print('');
    
    await listAllUsers();
    print('');
    
    await testCreateSimpleUser();
    print('');
    
    await listAllUsers();
    print('');
    
    await cleanupTestUsers();
    print('');
    
    print('🎉 Tests terminés !');
  }
}
