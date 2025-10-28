# 🌍 Comment Traduire les Exercices Firestore

## 📋 Approche 1 : Stocker toutes les traductions dans Firestore

### Structure Recommandée dans Firestore

Au lieu de :
```json
{
  "question": "Which relative pronoun is used?",
  "answer": "الَّذِي"
}
```

Utilisez :
```json
{
  "question": {
    "en": "Which relative pronoun is used for: 'The man **who** prays'?",
    "fr": "Quel pronom relatif est utilisé pour : 'L'homme **qui** prie'?",
    "ar": "ما هو ضمير الموصول المستخدم لـ: 'الرجل **الذي** يصلي'؟"
  },
  "answer": "الَّذِي",
  "options": {
    "en": ["those (masc.)", "those (fem.)", "who (masc.)", "who (fem.)"],
    "fr": ["ceux (masc.)", "celles (fem.)", "qui (masc.)", "qui (fem.)"],
    "ar": ["الَّذِينَ", "اللَّائِي", "الَّذِي", "الَّتِي"]
  }
}
```

## 🔧 Modifications du Code

### 1. Créer une fonction helper pour récupérer les traductions

Créez un fichier `lib/utils/translation_helper.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';

class TranslationHelper {
  // Récupérer une traduction depuis un objet Firestore
  static String getTranslation(
    BuildContext context,
    dynamic field,
    String key,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final langCode = localizations.localeName;
    
    // Si c'est déjà une String, la retourner directement
    if (field is String) {
      return field;
    }
    
    // Si c'est une Map avec des clés de langue
    if (field is Map<String, dynamic>) {
      // Essayer la langue actuelle
      if (field.containsKey(langCode)) {
        return field[langCode].toString();
      }
      
      // Fallback vers l'anglais
      if (field.containsKey('en')) {
        return field['en'].toString();
      }
      
      // Prendre la première valeur disponible
      if (field.isNotEmpty) {
        return field.values.first.toString();
      }
    }
    
    // Aucune traduction disponible
    return 'Translation not available';
  }
  
  // Récupérer un tableau de traductions
  static List<String> getTranslationList(
    BuildContext context,
    dynamic field,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final langCode = localizations.localeName;
    
    if (field is List) {
      return field.map((e) => e.toString()).toList();
    }
    
    if (field is Map<String, dynamic>) {
      if (field.containsKey(langCode) && field[langCode] is List) {
        return (field[langCode] as List).map((e) => e.toString()).toList();
      }
      if (field.containsKey('en') && field['en'] is List) {
        return (field['en'] as List).map((e) => e.toString()).toList();
      }
    }
    
    return [];
  }
}
```

### 2. Modifier la classe Exercise pour supporter les traductions

Modifiez `lib/exercises/exercise.dart` :

```dart
class Exercise {
  final String type;
  final String question;
  final List<String>? options;
  final String? answer;
  final String? audioUrl;
  final List<Map<String, dynamic>>? dragDropPairs;
  
  // ⭐ Nouveau : Store raw data pour les traductions
  final Map<String, dynamic>? rawData;

  Exercise({
    required this.type,
    required this.question,
    this.options,
    this.answer,
    воthis.audioUrl,
    this.dragDropPairs,
    this.rawData, // ⭐ Nouveau
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    // ... code existant ...
    
    return Exercise(
      type: exerciseType,
      question: question,
      options: json['options'] != null
          ? (json['options'] as List).map((e) => e.toString()).toList()
          : null,
      answer: answer,
      audioUrl: json['audioUrl'],
      dragDropPairs: dragDropPairs,
      rawData: json, // ⭐ Stocker les données brutes
    );
  }
  
  // ⭐ Nouvelle méthode pour obtenir la question traduite
  String getTranslatedQuestion(BuildContext context) {
    if (rawData == null || rawData!['question'] == null) {
      return question;
    }
    return TranslationHelper.getTranslation(
      context,
      rawData!['question'],
      'question',
    );
  }
  
  // ⭐ Nouvelle méthode pour obtenir les options traduites
  List<String> getTranslatedOptions(BuildContext context) {
    if (options == null) return [];
    
    if (rawData == null || rawData!['options'] == null) {
      return options!;
    }
    
    final translated = TranslationHelper.getTranslationList(
      context,
      rawData!['options'],
    );
    
    return translated.isNotEmpty ? translated : options!;
  }
}
```

### 3. Utiliser dans les écrans d'exercices

Dans vos écrans d'exercices, utilisez les méthodes traduites :

```dart
// Au lieu de :
Text(exercise.question)

// Utilisez :
Text(exercise.getTranslatedQuestion(context))

// Au lieu de :
...exercise.options!.map((opt) => Text(opt))

// Utilisez :
...exercise.getTranslatedOptions(context).map((opt) => Text(opt))
```

## 📝 Approche 2 : Mapping côté Client (Simple mais moins flexible)

Si vous ne voulez pas modifier Firestore, créez un mapping dans le code :

### Créer `lib/utils/exercise_translations.dart` :

```dart
class ExerciseTranslations {
  static Map<String, Map<String, String>> translations = {
    'Which relative pronoun is used for: \'The man **who** prays\'?': {
      'fr': 'Quel pronom relatif est utilisé pour : \'先说 homme **qui** prie\'?',
      'ar': 'ما هو ضمير الموصول المستخدم لـ: \'الرجل **الذي** يصلي\'؟',
    },
    // Ajoutez plus de traductions ici
  };
  
  static String? getTranslation(String original, String langCode) {
    final trans = translations[original];
    return trans?[langCode] ?? original;
  }
}
```

## 🎯 Recommandation

**Je recommande l'Approche 1** car :
- ✅ Plus maintenable
- ✅ Facile d'ajouter de nouvelles langues
- ✅ Pas besoin de modifier le code à chaque nouvel exercice
- ✅ Les non-développeurs peuvent gérer les traductions dans Firestore

## 📊 Structure Complète Recommandée

```json
{
  "exercises": [
    {
      "type": "multiple_choice",
      "question": {
        "en": "Which relative pronoun is used for: 'The man **who** prays'?",
        "fr": "Quel pronom relatif est utilisé pour : 'L'homme **qui** prie'?",
        "ar": "ما هو ضمير الموصول المستخدم لـ: 'الرجل **الذي** يصلي'؟"
      },
      "answer": "الَّذِي",
      "options": {
        "en": ["those (masc.)", "those (fem.)", "who (masc.)", "who (fem.)"],
        "fr": ["ceux (masc.)", "celles (fem.)", "qui (masc.)", "qui (fem.)"],
        "ar": ["الَّذِينَ", "اللَّائِي", "الَّذِي", "الَّتِي"]
      },
      "instruction": {
        "en": "Select the correct answer",
        "fr": "Sélectionnez la bonne réponse",
        "ar": "اختر الإجابة الصحيحة"
      }
    }
  ]
}
```

## 🚀 Étapes pour Implémenter

1. ✅ Créer `translation_helper.dart`
2. ✅ Modifier `Exercise` class
3. ✅ Modifier les écrans d'exercices pour utiliser les méthodes traduites
4. 🔄 Mettre à jour vos données Firestore avec la nouvelle structure
5. ✅ Tester

---

**Voulez-vous que je crée ces fichiers pour vous ?** 🛠️

