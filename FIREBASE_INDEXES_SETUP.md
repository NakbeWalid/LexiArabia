# Configuration des Index Firestore pour le SRS

## Instructions pour créer les index Firestore

Les index Firestore sont nécessaires pour des requêtes performantes sur les collections SRS. Vous avez deux options :

### Option 1 : Création automatique (Recommandé)

1. **Déployer le fichier `firestore.indexes.json`** :
   - Dans la console Firebase, allez dans **Firestore Database** > **Indexes**
   - Cliquez sur **"Add Index"**
   - Ou utilisez Firebase CLI :
   ```bash
   firebase deploy --only firestore:indexes
   ```

2. **Le fichier `lib/services/firestore_indexes.json`** contient tous les index nécessaires.

### Option 2 : Création manuelle

Créez les index suivants dans la console Firebase :

#### Index 1 : Exercices à réviser aujourd'hui
- **Collection** : `users/{userId}/srsExercises`
- **Champs** :
  - `dueDate` (Ascending)
  - `status` (Ascending)

#### Index 2 : Nouveaux exercices
- **Collection** : `users/{userId}/srsExercises`
- **Champs** :
  - `status` (Ascending)
  - `createdAt` (Ascending)

#### Index 3 : Exercices par leçon
- **Collection** : `users/{userId}/srsExercises`
- **Champs** :
  - `lessonId` (Ascending)
  - `dueDate` (Ascending)

#### Index 4 : Historique des révisions
- **Collection** : `users/{userId}/srsReviews`
- **Champs** :
  - `exerciseId` (Ascending)
  - `reviewedAt` (Descending)

## Vérification

Après la création, vous pouvez vérifier que les index sont actifs dans la console Firebase sous **Firestore Database** > **Indexes**.

## Note importante

Les index peuvent prendre quelques minutes à être créés. Pendant ce temps, les requêtes peuvent échouer avec une erreur indiquant qu'un index est nécessaire. Firebase vous fournira un lien direct pour créer l'index manquant.

