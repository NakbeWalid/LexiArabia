import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LearningProgressService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Récupère le pourcentage d'apprentissage total basé sur les leçons complétées
  static Future<double> getLearningPercentage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0.0;

      // Récupérer toutes les leçons avec leur learningPercentage
      final lessonsSnapshot = await _firestore
          .collection('lessons')
          .orderBy('sectionOrder')
          .orderBy('lessonOrder')
          .get();

      if (lessonsSnapshot.docs.isEmpty) return 0.0;

      // Récupérer le progrès de l'utilisateur
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return 0.0;

      final userData = userDoc.data();
      final lessonsProgress =
          userData?['progress']?['lessons'] as Map<String, dynamic>? ?? {};

      double totalPercentage = 0.0;

      // Parcourir toutes les leçons et additionner les pourcentages des leçons complétées
      for (final lessonDoc in lessonsSnapshot.docs) {
        final lessonData = lessonDoc.data();
        final lessonId = lessonDoc.id;
        final learningPercentage =
            (lessonData['learningPercentage'] as num?)?.toDouble() ?? 0.0;

        // Vérifier si la leçon est complétée
        final lessonProgress =
            lessonsProgress[lessonId] as Map<String, dynamic>?;
        final isCompleted = lessonProgress?['completed'] == true;

        if (isCompleted && learningPercentage > 0) {
          totalPercentage += learningPercentage;
        }
      }

      return totalPercentage.clamp(0.0, 100.0);
    } catch (e) {
      print('❌ Erreur lors du calcul du pourcentage d\'apprentissage: $e');
      return 0.0;
    }
  }

  /// Récupère les informations détaillées sur le progrès d'apprentissage
  static Future<Map<String, dynamic>> getLearningProgressDetails() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'totalPercentage': 0.0,
          'completedLessons': 0,
          'totalLessons': 0,
          'lessons': [],
        };
      }

      // Récupérer toutes les leçons
      final lessonsSnapshot = await _firestore
          .collection('lessons')
          .orderBy('sectionOrder')
          .orderBy('lessonOrder')
          .get();

      if (lessonsSnapshot.docs.isEmpty) {
        return {
          'totalPercentage': 0.0,
          'completedLessons': 0,
          'totalLessons': 0,
          'lessons': [],
        };
      }

      // Récupérer le progrès de l'utilisateur
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final lessonsProgress =
          userDoc.data()?['progress']?['lessons'] as Map<String, dynamic>? ??
          {};

      double totalPercentage = 0.0;
      int completedLessons = 0;
      final lessons = <Map<String, dynamic>>[];

      for (final lessonDoc in lessonsSnapshot.docs) {
        final lessonData = lessonDoc.data();
        final lessonId = lessonDoc.id;
        final learningPercentage =
            (lessonData['learningPercentage'] as num?)?.toDouble() ?? 0.0;

        // Extraire le titre de la leçon
        String lessonTitle = lessonId;
        if (lessonData['title'] != null) {
          if (lessonData['title'] is Map) {
            final titleMap = lessonData['title'] as Map<String, dynamic>;
            lessonTitle =
                titleMap['fr']?.toString() ??
                titleMap['en']?.toString() ??
                titleMap['ar']?.toString() ??
                lessonId;
          } else {
            lessonTitle = lessonData['title'].toString();
          }
        }

        // Vérifier si la leçon est complétée
        final lessonProgress =
            lessonsProgress[lessonId] as Map<String, dynamic>?;
        final isCompleted = lessonProgress?['completed'] == true;

        if (isCompleted && learningPercentage > 0) {
          totalPercentage += learningPercentage;
          completedLessons++;
        }

        lessons.add({
          'id': lessonId,
          'title': lessonTitle,
          'learningPercentage': learningPercentage,
          'completed': isCompleted,
        });
      }

      return {
        'totalPercentage': totalPercentage.clamp(0.0, 100.0),
        'completedLessons': completedLessons,
        'totalLessons': lessonsSnapshot.docs.length,
        'lessons': lessons,
      };
    } catch (e) {
      print('❌ Erreur lors de la récupération des détails: $e');
      return {
        'totalPercentage': 0.0,
        'completedLessons': 0,
        'totalLessons': 0,
        'lessons': [],
      };
    }
  }

  /// Vérifie si une leçon spécifique est complétée
  static Future<bool> isLessonCompleted(String lessonId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final lessonsProgress =
          userDoc.data()?['progress']?['lessons'] as Map<String, dynamic>? ??
          {};
      final lessonProgress = lessonsProgress[lessonId] as Map<String, dynamic>?;

      return lessonProgress?['completed'] == true;
    } catch (e) {
      print('❌ Erreur lors de la vérification de la leçon: $e');
      return false;
    }
  }
}
