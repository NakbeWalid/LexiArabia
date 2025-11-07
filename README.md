# 📚 CoranLingua - Application d'Apprentissage de l'Arabe


![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-Private-red)

**Une application mobile moderne et interactive pour apprendre l'arabe, inspirée de Duolingo**

[Caractéristiques](#-caractéristiques) • [Installation](#-installation) • [Configuration](#-configuration) • [Utilisation](#-utilisation) • [Structure](#-structure-du-projet)




## À Propos

**CoranLingua** (anciennement DualingOcoran) est une application mobile Flutter dédiée à l'apprentissage de la langue arabe. L'application propose une expérience d'apprentissage gamifiée avec des leçons interactives, des exercices variés, et un système de progression qui motive les utilisateurs à continuer leur apprentissage.

### Points Forts

- 🎨 Interface utilisateur moderne et intuitive
- 🌍 Support multilingue (Français, Anglais, Arabe)
- 🎯 Système de progression avec roadmap interactive
- 🎮 Exercices variés et engageants
- 🔐 Authentification Firebase sécurisée
- 📊 Suivi détaillé de la progression
- 🌓 Mode sombre/clair
- 🎵 Audio intégré pour la prononciation

---

## Caractéristiques

### 📚 Roadmap Interactive
- Parcours d'apprentissage organisé en sections (Basics, Pronouns, Grammar, etc.)
- Visualisation en bulles animées avec chemin de progression
- Indicateurs visuels pour les leçons complétées, en cours ou verrouillées
- Navigation fluide entre les sections

### 🎯 Système d'Exercices
L'application propose plusieurs types d'exercices pour un apprentissage complet :

- **Choix multiples** - Questions à choix multiples avec feedback immédiat
- **Vrai/Faux** - Questions de compréhension rapide
- **Associations (Pairs)** - Associer des mots arabes à leurs traductions
- **Glisser-Déposer** - Exercices de construction de phrases
- **Audio** - Écouter et identifier la prononciation correcte

### 📊 Suivi de Progression
- Tableau de bord avec statistiques détaillées
- Système de points d'expérience (XP)
- Suivi des streaks (jours consécutifs)
- Pourcentage de complétion par section
- Historique des leçons complétées

### 👤 Profil Utilisateur
- Informations personnelles
- Statistiques d'apprentissage
- Réalisations et badges (à venir)
- Paramètres personnalisables

### ⚙️ Paramètres
- Changement de langue (FR/EN/AR)
- Activation/désactivation du mode sombre
- Paramètres de notifications
- Paramètres audio

### 🔐 Authentification
- Connexion par email/mot de passe
- Connexion avec Google
- Gestion sécurisée des sessions

---

## 🛠️ Technologies Utilisées

- **Flutter** 3.8.1 - Framework de développement cross-platform
- **Firebase** - Backend et services cloud
  - Firebase Authentication - Authentification utilisateur
  - Cloud Firestore - Base de données NoSQL
  - Firebase Storage - Stockage des fichiers multimédias
- **Provider** - Gestion d'état
- **Google Fonts** - Polices personnalisées
- **Audioplayers** - Lecture de fichiers audio
- **Flutter Animate** - Animations modernes
- **Shared Preferences** - Stockage local

---

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.8.1 ou supérieure)
- [Dart SDK](https://dart.dev/get-dart) (inclus avec Flutter)
- [Android Studio](https://developer.android.com/studio) ou [VS Code](https://code.visualstudio.com/)
- Un compte Firebase et un projet configuré
- [Git](https://git-scm.com/) (optionnel)

---



## 📱 Utilisation

### Première Utilisation

1. **Lancez l'application**
2. **Créez un compte** ou connectez-vous avec Google
3. **Sélectionnez votre langue préférée** (FR/EN/AR)
4. **Commencez votre première leçon** depuis la roadmap

### Navigation

L'application dispose de 5 écrans principaux accessibles via la barre de navigation en bas :

1. **📚 Lessons (Leçons)** - Roadmap avec toutes les leçons
2. **📝 Exercises (Exercices)** - Liste de tous les exercices disponibles
3. **📈 Progression** - Statistiques et progression détaillée
4. **👤 Profile** - Profil utilisateur et statistiques
5. **⚙️ Settings (Paramètres)** - Configuration de l'application

### Compléter une Leçon

1. Naviguez vers l'écran **Lessons**
2. Cliquez sur une leçon disponible (non verrouillée)
3. Consultez le vocabulaire et la description
4. Cliquez sur **"Commencer la leçon"**
5. Complétez tous les exercices de la leçon
6. La leçon sera marquée comme complétée

---

## 📁 Structure du Projet

```
dualingocoran/
├── lib/
│   ├── core/                    # Configuration de base
│   │   └── app_theme.dart       # Thèmes clair/sombre
│   ├── exercises/               # Types d'exercices
│   │   ├── exercise_page.dart
│   │   ├── multiple_choice_exercise.dart
│   │   ├── true_false_exercise.dart
│   │   ├── pairs_exercise.dart
│   │   ├── dragDropExercise.dart
│   │   └── audio_exercise.dart
│   ├── l10n/                    # Fichiers de localisation
│   │   ├── app_en.arb
│   │   ├── app_fr.arb
│   │   ├── app_ar.arb
│   │   └── app_localizations.dart
│   ├── models/                  # Modèles de données
│   │   └── user_model.dart
│   ├── screens/                 # Écrans de l'application
│   │   ├── login_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── progression_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── lesson_preview_screen.dart
│   │   └── user_selection_screen.dart
│   ├── services/                # Services et providers
│   │   ├── auth_service.dart
│   │   ├── language_provider.dart
│   │   └── theme_provider.dart
│   ├── utils/                   # Utilitaires
│   │   └── translation_helper.dart
│   ├── widgets/                 # Widgets réutilisables
│   └── main.dart                # Point d'entrée
├── assets/
│   ├── audio/                   # Fichiers audio pour les exercices
│   └── sounds/                  # Sons de l'application
├── android/                     # Configuration Android
├── ios/                         # Configuration iOS
├── web/                         # Configuration Web
├── windows/                     # Configuration Windows
├── pubspec.yaml                 # Dépendances Flutter
└── README.md                    # Ce fichier
```

---


### Captures d'Écran 

1. **Roadmap/Home Screen** - `screenshots/01-roadmap.png`
   - Capture de l'écran principal avec la roadmap des leçons
   - Montre les bulles animées et le chemin de progression
   - Affiche le header avec streak et vies

2. **Lesson Preview** - `screenshots/02-lesson-preview.png`
   - Aperçu d'une leçon avec le vocabulaire
   - Montre l'interface avant de commencer la leçon

3. **Exercise Types** - `screenshots/03-exercises.png`
   - Différents types d'exercices (choix multiple, pairs, audio, etc.)
   - Montre l'interface interactive des exercices

4. **Progression Screen** - `screenshots/04-progression.png`
   - Tableau de bord avec statistiques
   - Graphiques et métriques de progression

5. **Profile Screen** - `screenshots/05-profile.png`
   - Profil utilisateur avec statistiques personnelles

6. **Settings Screen** - `screenshots/06-settings.png`
   - Écran des paramètres avec sélection de langue et thème

7. **Authentication** - `screenshots/07-login.png`
   - Écran de connexion/inscription



## 🚧 Développement

### Ajouter une Nouvelle Leçon

1. Accédez à la console Firebase
2. Ajoutez un nouveau document dans la collection `lessons`
3. Suivez la structure définie dans [DATABASE_STRUCTURE.md](DATABASE_STRUCTURE.md)

### Ajouter une Nouvelle Traduction

1. Modifiez les fichiers `.arb` dans `lib/l10n/`
2. Ajoutez les clés dans les trois langues (FR, EN, AR)
3. Régénérez les fichiers : `flutter gen-l10n`

### Ajouter un Nouveau Type d'Exercice

1. Créez un nouveau widget dans `lib/exercises/`
2. Implémentez la logique dans `lib/exercises/exercise_page.dart`
3. Mettez à jour le modèle `Exercise` si nécessaire

---

## 📝 Documentation Supplémentaire

- [DATABASE_STRUCTURE.md](DATABASE_STRUCTURE.md) - Structure détaillée de la base de données
- [SYSTEME_LOCALISATION.md](SYSTEME_LOCALISATION.md) - Guide du système de localisation
- [COMMENT_UTILISER_TRADUCTIONS.md](COMMENT_UTILISER_TRADUCTIONS.md) - Comment utiliser les traductions
- [TRADUCTION_FIRESTORE.md](TRADUCTION_FIRESTORE.md) - Structure des traductions dans Firestore
- [GUIDE_SCREENSHOTS.md](GUIDE_SCREENSHOTS.md) - Guide pour ajouter des captures d'écran au README

---

## 📄 Licence

Ce projet est privé et propriétaire. Tous droits réservés.

---

## 👥 Auteurs

- Walid Benakmoum - *Développement initial* - [Votre GitHub](https://github.com/votre-username)

---

## 🙏 Remerciements

- Inspiration de l'interface utilisateur : [Duolingo](https://www.duolingo.com/)
- Polices : [Google Fonts](https://fonts.google.com/)
- Icônes : [Material Icons](https://fonts.google.com/icons)

---

## 📞 Support

Pour toute question ou problème :

- Ouvrez une [issue](https://github.com/votre-username/dualingocoran/issues)
- Contactez l'équipe de développement

---

<div align="center">

**Fait avec ❤️ en utilisant Flutter**

⭐ Si ce projet vous a aidé, n'hésitez pas à lui donner une étoile !

</div>
