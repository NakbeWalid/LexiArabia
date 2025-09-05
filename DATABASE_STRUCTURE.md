# Structure de la Base de Données - DualingOcoran

## Vue d'ensemble

Cette application utilise Firebase Firestore comme base de données NoSQL. La structure est organisée en collections principales pour gérer les utilisateurs, les leçons, et les achievements.

## Collections Principales

### 1. Collection `users`

Contient les données des utilisateurs et leurs statistiques d'apprentissage.

#### Structure d'un document utilisateur :

```json
{
  "userId": "string (auto-généré)",
  "profile": {
    "username": "string",
    "email": "string",
    "avatarUrl": "string (optionnel)",
    "displayName": "string",
    "bio": "string (optionnel)",
    "nativeLanguage": "string (en, fr, ar)",
    "learningLanguage": "string (ar)",
    "createdAt": "timestamp",
    "lastActive": "timestamp"
  },
  "stats": {
    "totalXP": "number",
    "currentLevel": "number",
    "currentStreak": "number",
    "bestStreak": "number",
    "lessonsCompleted": "number",
    "totalLessons": "number",
    "exercisesCompleted": "number",
    "wordsLearned": "number",
    "accuracy": "number (0-100)",
    "totalStudyTime": "number (en minutes)"
  },
  "progress": {
    "lessons": {
      "lessonId": {
        "completed": "boolean",
        "completedAt": "timestamp",
        "score": "number",
        "attempts": "number",
        "bestScore": "number"
      }
    },
    "sections": {
      "sectionId": {
        "completed": "boolean",
        "completedAt": "timestamp",
        "lessonsCompleted": "number",
        "totalLessons": "number"
      }
    }
  },
  "achievements": {
    "achievementId": {
      "unlocked": "boolean",
      "unlockedAt": "timestamp",
      "progress": "number (pour les achievements progressifs)"
    }
  },
  "studySessions": {
    "sessionId": {
      "startedAt": "timestamp",
      "endedAt": "timestamp",
      "duration": "number (en minutes)",
      "lessonsStudied": "array",
      "exercisesCompleted": "number",
      "xpEarned": "number"
    }
  },
  "dailyProgress": {
    "date": {
      "lessonsCompleted": "number",
      "exercisesCompleted": "number",
      "xpEarned": "number",
      "studyTime": "number",
      "streakMaintained": "boolean"
    }
  }
}
```

### 2. Collection `achievements`

Contient la définition de tous les achievements disponibles dans l'application.

#### Structure d'un document achievement :

```json
{
  "achievementId": "string",
  "name": "string",
  "description": "string",
  "icon": "string (nom de l'icône)",
  "category": "string (learning, streak, accuracy, etc.)",
  "requirements": {
    "type": "string (lessons, xp, streak, accuracy, etc.)",
    "value": "number",
    "condition": "string (>=, ==, etc.)"
  },
  "rewards": {
    "xp": "number",
    "badge": "string (optionnel)"
  },
  "tier": "string (bronze, silver, gold, platinum)"
}
```

### 3. Collection `lessons`

Contient les leçons et leurs exercices (déjà existante dans votre application).

## Utilisateur de Démonstration

L'application inclut un utilisateur de démonstration avec l'ID `demo_user_001` qui contient :

- **Profil** : Username "QuranLearner", email "demo@dualingocoran.com"
- **Statistiques** : 1250 XP, niveau 5, streak de 7 jours
- **Progression** : 8 leçons complétées sur 15
- **Achievements** : Plusieurs achievements débloqués
- **Sessions d'étude** : Données d'exemple

## Services et Modèles

### Services

1. **`UserService`** : Gère les opérations CRUD pour les utilisateurs
2. **`DatabaseInit`** : Initialise la base de données avec des données de base
3. **`UserProvider`** : Provider Flutter pour gérer l'état de l'utilisateur

### Modèles

1. **`UserModel`** : Modèle principal de l'utilisateur
2. **`UserProfile`** : Informations de profil
3. **`UserStats`** : Statistiques d'apprentissage
4. **`UserProgress`** : Progression dans les leçons
5. **`UserAchievement`** : Achievements de l'utilisateur
6. **`StudySession`** : Sessions d'étude
7. **`DailyProgress`** : Progression quotidienne

## Initialisation de la Base de Données

La base de données est automatiquement initialisée au démarrage de l'application avec :

- 12 achievements prédéfinis
- 1 utilisateur de démonstration
- Structure complète des collections

## Utilisation dans l'Application

### Charger un utilisateur

```dart
final userProvider = Provider.of<UserProvider>(context, listen: false);
await userProvider.loadDemoUser(); // Pour l'utilisateur de démonstration
// ou
await userProvider.loadUser('user_id'); // Pour un utilisateur spécifique
```

### Accéder aux données

```dart
final user = userProvider.currentUser;
if (user != null) {
  print('XP: ${user.stats.totalXP}');
  print('Niveau: ${user.stats.currentLevel}');
  print('Streak: ${user.stats.currentStreak}');
}
```

### Mettre à jour les statistiques

```dart
await userProvider.addXP(100); // Ajouter 100 XP
await userProvider.updateStreak(true); // Maintenir le streak
await userProvider.completeLesson('lesson_id', 95); // Terminer une leçon
```

## Sécurité et Règles Firestore

⚠️ **Important** : Configurez les règles de sécurité Firestore appropriés pour votre application en production.

Exemple de règles basiques :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Les utilisateurs peuvent lire/écrire leurs propres données
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Les achievements sont en lecture seule
    match /achievements/{achievementId} {
      allow read: if true;
      allow write: if false;
    }
    
    // Les leçons sont en lecture seule
    match /lessons/{lessonId} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

## Maintenance et Évolutions

- **Ajout d'achievements** : Modifiez le fichier `database_init.dart`
- **Nouvelles statistiques** : Étendez le modèle `UserStats`
- **Nouveaux types de progression** : Ajoutez des champs au modèle `UserProgress`

## Support

Pour toute question sur la structure de la base de données, consultez :
- Les modèles dans `lib/models/`
- Les services dans `lib/services/`
- La documentation Firebase Firestore
