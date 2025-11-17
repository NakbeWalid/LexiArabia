import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dualingocoran/services/user_service.dart';
import 'package:flutter/services.dart';

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

      // Créer le document utilisateur dans Firestore avec la structure complète
      await UserService.createUser(userCredential.user!.uid, {
        'username': name,
        'email': email,
        'displayName': name,
        'avatarUrl': '',
        'bio': '',
        'nativeLanguage': 'fr', // Par défaut, peut être changé plus tard
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
        print('ℹ️ L\'utilisateur a annulé la connexion Google');
        return null;
      }

      print('✅ Compte Google sélectionné: ${googleUser.email}');

      // Obtenir les détails d'authentification depuis la demande
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Les tokens d\'authentification Google sont manquants');
      }

      // Créer un nouvel identifiant
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('✅ Credential créé, connexion à Firebase...');

      // Connecter l'utilisateur avec Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      print('✅ Utilisateur connecté à Firebase: ${userCredential.user?.uid}');

      // Vérifier si c'est un nouvel utilisateur
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        print('ℹ️ Nouvel utilisateur, création du document...');
        // Créer le document utilisateur pour les nouveaux utilisateurs avec la structure complète
        await UserService.createUser(userCredential.user!.uid, {
          'username': userCredential.user!.displayName ?? 'User',
          'email': userCredential.user!.email ?? '',
          'displayName': userCredential.user!.displayName ?? 'User',
          'avatarUrl': userCredential.user!.photoURL ?? '',
          'bio': '',
          'nativeLanguage': 'fr', // Par défaut, peut être changé plus tard
        });
        print('✅ Document utilisateur créé');
      } else {
        print('ℹ️ Utilisateur existant trouvé');
      }

      return userCredential;
    } on PlatformException catch (e) {
      print(
        '❌ Erreur Platform lors de la connexion Google: ${e.code} - ${e.message}',
      );
      // Gérer les erreurs spécifiques à la plateforme
      if (e.code == 'sign_in_canceled') {
        throw FirebaseAuthException(
          code: 'sign_in_canceled',
          message: 'La connexion a été annulée',
        );
      } else if (e.code == 'sign_in_failed') {
        throw FirebaseAuthException(
          code: 'sign_in_failed',
          message:
              'Échec de la connexion Google. Vérifiez votre configuration.',
        );
      } else if (e.code == 'network_error') {
        throw FirebaseAuthException(
          code: 'network_error',
          message: 'Erreur de réseau. Vérifiez votre connexion internet.',
        );
      }
      throw FirebaseAuthException(
        code: 'google_sign_in_error',
        message:
            'Erreur lors de la connexion Google: ${e.message ?? "Erreur inconnue"}',
      );
    } on FirebaseAuthException catch (e) {
      print(
        '❌ Erreur Firebase Auth lors de la connexion Google: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e, stackTrace) {
      print('❌ Erreur inattendue lors de la connexion Google: $e');
      print('Stack trace: $stackTrace');
      throw FirebaseAuthException(
        code: 'unknown_error',
        message: 'Une erreur inattendue s\'est produite: ${e.toString()}',
      );
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
