# Guide d'Initialisation du Système SRS

Ce guide explique comment initialiser les collections Firestore nécessaires pour le système SRS (Spaced Repetition System).

## 📋 Fichiers créés

1. **`srs_database_init.dart`** - Service d'initialisation des collections SRS
2. **`firestore_indexes.json`** - Configuration des index Firestore
3. **`FIREBASE_INDEXES_SETUP.md`** - Instructions pour créer les index

## 🚀 Utilisation

### Initialisation automatique

Les collections SRS sont automatiquement initialisées lors de l'initialisation complète de la base de données :

```dart
await DatabaseInit.initializeDatabase();
```

Cela initialisera les collections SRS pour tous les utilisateurs existants.

### Initialisation pour un utilisateur spécifique

```dart
import 'package:dualingocoran/services/srs_database_init.dart';

// Initialiser les collections SRS pour un utilisateur
await SRSDatabaseInit.initializeSRSCollections('user_id');
```

### Vérifier si SRS est initialisé

```dart
bool isInitialized = await SRSDatabaseInit.isSRSInitialized('user_id');
if (!isInitialized) {
  await SRSDatabaseInit.initializeSRSCollections('user_id');
}
```

### Obtenir les paramètres SRS

```dart
Map<String, dynamic>? settings = await SRSDatabaseInit.getSRSSettings('user_id');
if (settings != null) {
  print('Algorithme: ${settings['algorithm']}');
  print('Nouveaux exercices par jour: ${settings['newExercisesPerDay']}');
}
```

### Mettre à jour les paramètres SRS

```dart
await SRSDatabaseInit.updateSRSSettings('user_id', {
  'newExercisesPerDay': 30,
  'maxReviewsPerDay': 300,
});
```

## 📊 Collections créées

### 1. `users/{userId}/srsSettings/settings`

Document contenant les paramètres SRS de l'utilisateur (algorithme SM-2).

### 2. `users/{userId}/srsExercises`

Collection contenant tous les exercices en révision SRS.

### 3. `users/{userId}/srsReviews`

Collection contenant l'historique de toutes les révisions.

## 🔧 Configuration des Index Firestore

**IMPORTANT** : Vous devez créer les index Firestore pour que les requêtes fonctionnent correctement.

### Option 1 : Via Firebase CLI (Recommandé)

1. Placez le fichier `firestore_indexes.json` à la racine de votre projet
2. Exécutez :
```bash
firebase deploy --only firestore:indexes
```

### Option 2 : Via la Console Firebase

Suivez les instructions dans `FIREBASE_INDEXES_SETUP.md`

## 📝 Structure des données

### Paramètres SRS (srsSettings)

```json
{
  "algorithm": "sm2",
  "initialInterval": 1.0,
  "minimumInterval": 1.0,
  "maximumInterval": 36500.0,
  "easyBonus": 1.3,
  "newExercisesPerDay": 20,
  "maxReviewsPerDay": 200,
  "defaultEaseFactor": 2.5
}
```

### Exercice SRS (srsExercises)

```json
{
  "exerciseId": "unique_id",
  "lessonId": "lesson_id",
  "exerciseIndex": 0,
  "exerciseType": "multiple_choice",
  "interval": 0.0,
  "easeFactor": 2.5,
  "repetitions": 0,
  "dueDate": "timestamp",
  "status": "new",
  "totalReviews": 0
}
```

### Révision SRS (srsReviews)

```json
{
  "reviewId": "unique_id",
  "exerciseId": "exercise_id",
  "quality": 2,
  "qualityLabel": "GOOD",
  "reviewedAt": "timestamp",
  "intervalBefore": 1.0,
  "intervalAfter": 2.5
}
```

## 🧪 Test

Pour créer un exercice SRS d'exemple :

```dart
await SRSDatabaseInit.createExampleSRSExercise('user_id');
```

## 🧹 Nettoyage

Pour supprimer les documents d'initialisation (optionnel) :

```dart
await SRSDatabaseInit.cleanupInitDocuments('user_id');
```

## ⚠️ Notes importantes

1. Les collections sont créées automatiquement lors de la première écriture
2. Les index Firestore doivent être créés manuellement ou via CLI
3. Les paramètres SRS sont créés avec des valeurs par défaut (algorithme SM-2)
4. Les paramètres peuvent être personnalisés par utilisateur

## 🔄 Prochaines étapes

Une fois les collections initialisées, vous pouvez :
1. Créer un service SRS pour gérer les révisions
2. Implémenter l'algorithme SM-2
3. Créer l'interface utilisateur pour les révisions
4. Intégrer avec le système d'exercices existant

