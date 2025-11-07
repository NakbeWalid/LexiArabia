import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service pour gérer l'authentification Firebase
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  /// Stream des changements d'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// S'inscrire avec email et mot de passe
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Créer l'utilisateur
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Mettre à jour le nom d'affichage
      await userCredential.user?.updateDisplayName(name);

      // Créer le document utilisateur dans Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'xp': 0,
        'streak': 0,
        'level': 1,
        'completedLessons': [],
        'startedLessons': [],
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur lors de l\'inscription: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Erreur inattendue lors de l\'inscription: $e');
      rethrow;
    }
  }

  /// Se connecter avec email et mot de passe
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur lors de la connexion: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Erreur inattendue lors de la connexion: $e');
      rethrow;
    }
  }

  /// Se connecter avec Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Déclencher le flux de connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // L'utilisateur a annulé la connexion
        return null;
      }

      // Obtenir les détails d'authentification depuis la demande
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Créer un nouvel identifiant
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Connecter l'utilisateur avec Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Vérifier si c'est un nouvel utilisateur
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Créer le document utilisateur pour les nouveaux utilisateurs
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName ?? 'User',
          'photoURL': userCredential.user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'xp': 0,
          'streak': 0,
          'level': 1,
          'completedLessons': [],
          'startedLessons': [],
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur lors de la connexion Google: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Erreur inattendue lors de la connexion Google: $e');
      rethrow;
    }
  }

  /// Se déconnecter
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      print('✅ Déconnexion réussie');
    } catch (e) {
      print('❌ Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  /// Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print(
        '❌ Erreur lors de la réinitialisation du mot de passe: ${e.message}',
      );
      rethrow;
    }
  }

  /// Vérifier si l'email est vérifié
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Envoyer l'email de vérification
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      print(
        '❌ Erreur lors de l\'envoi de l\'email de vérification: ${e.message}',
      );
      rethrow;
    }
  }
}
