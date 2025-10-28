# 🎯 Comment Utiliser les Traductions dans les Exercices

## ✅ Modifications Effectuées

1. ✅ Créé `lib/utils/translation_helper.dart` - Fonctions helper pour les traductions
2. ✅ Modifié `lib/exercises/exercise.dart` - Ajout du support multilingue
3. 📝 Instructions ci-dessous pour mettre à jour vos écrans

## 🚀 Comment Utiliser

### Dans vos écrans d'exercices, remplacez :

#### ❌ AVANT (texte hardcodé)
```dart
Text(exercise.question)
```

#### ✅ APRÈS (traduction automatique)
```dart
Text(exercise.getTranslatedQuestion(context))
```

### De même pour les options :

#### ❌ AVANT
```dart
exercise.options!.map((opt) => Text(opt))
```

#### ✅ APRÈS
```dart
exercise.getTranslatedOptions(context).map((opt) => Text(opt))
```

## 📝 Exemple Complet

### Avant :
```dart
Column(
  children: [
    Text(
      exercise.question,
      style: TextStyle(fontSize: 18),
    ),
    ...exercise.options!.map(
      (option) => ListTile(
        title: Text(option),
        onTap: () => _checkAnswer(option),
      ),
    ),
  ],
)
```

### Après :
```dart
Column(
  children: [
    Text(
      exercise.getTranslatedQuestion(context), // ✅ Traduit automatiquement
      style: TextStyle(fontSize: 18),
    ),
    ...exercise.getTranslatedOptions(context).map( // ✅ Traduit automatiquement
      (option) => ListTile(
        title: Text(option),
        onTap: () => _checkAnswer(option),
      ),
    ),
  ],
)
```

## 📊 Structure Firestore Recommandée

Mettez à jour vos documents Firestore pour utiliser cette structure :

```json
{
  "exercises": [
    {
      "type": "multiple_choice",
      "question": {
        "en": "What is the Arabic word for 'book'?",
        "fr": "Quel est le mot arabe pour 'livre'?",
        "ar": "ما هي الكلمة العربية لـ 'livre'؟"
      },
      "options": {
        "en": ["كتاب", "قلم", "منزل", "سيارة"],
        "fr": ["كتاب", "قلم", "منزل", "سيارة"],
        "ar": ["كتاب", "قلم", "منزل", "سيارة"]
      },
      "answer": "كتاب"
    }
  ]
}
```

## ⚡ Rétrocompatibilité

**Si vous n'avez pas encore mis à jour Firestore**, ne vous inquiétez pas ! Le code fonctionne toujours avec l'ancienne structure :

```json
{
  "question": "What is...",
  "options": ["option1", "option2"]
}
```

Dans ce cas, `getTranslatedQuestion()` retournera simplement le texte tel quel.

## 🎓 Trouver où Modifier dans Vos Fichiers

Cherchez dans ces fichiers :
- `lib/exercises/multiple_choice_exercise.dart`
- `lib/exercises/true_false_exercise.dart`
- `lib/exercises/pairs_exercise.dart`
- `lib/exercises/dragDropExercise.dart`
- `lib/exercises/audio_exercise.dart`

Utilisez `grep` pour trouver :
```bash
grep -r "exercise.question" lib/exercises/
grep -r "exercise.options" lib/exercises/
```

## 🧪 Test

1. Mettez à jour quelques exercices dans Firestore avec la nouvelle structure
2. Modifiez vos écrans pour utiliser les nouvelles méthodes
3. Changez la langue dans l'application
4. Les questions et options devraient maintenant se traduire automatiquement !

---

**Questions ?** Si vous avez besoin d'aide pour modifier un fichier spécifique, dites-moi lequel ! 🛠️

