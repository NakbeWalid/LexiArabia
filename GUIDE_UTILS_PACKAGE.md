# 📦 Guide du Package `utils` - DualingOcoran

## 🎯 Vue d'ensemble

Le package `utils` contient **6 classes/fichiers** qui organisent les fonctionnalités utilitaires de votre application. Ces classes permettent de centraliser les constantes, helpers, et règles d'affichage pour éviter la duplication de code.

---

## 📋 Structure du Package

```
lib/utils/
├── app_constants.dart      ✅ CONSTANTS - Valeurs fixes
├── app_helpers.dart        ✅ HELpers - Fonctions utilitaires
├── translation_helper.dart ✅ TRADUCTIONS - Gestion des traductions Firestore
├── arabic_text_style.dart  ✅ STYLES - Affichage des textes arabes
├── app_localizations.dart  ⚠️ DEPRECATED - Ancien système de localisation
└── translations.dart       ⚠️ UNUSED - Non utilisé actuellement
```

---

## 1️⃣ `app_constants.dart` - Valeurs fixes centralisées

### **Rôle** : Collection de constantes de l’application

### **Pourquoi ça existe** : 
- Éviter les valeurs magiques
- Uniformiser les chemins Firestore
- Centraliser la configuration

### **Contenu** :

```dart
class AppConstants {
  // Routes de navigation
  static const String homeRoute = '/';
  static const String progressionRoute = '/progression';
  
  // Collections Firestore
  static const String usersCollection = 'users';
  static const String lessonsCollection = 'lessons';
  
  // Utilisateurs de démonstration
  static const List<String> demoUserIds = ['demo_user_001', ...];
  static const Map<String, Map<String, dynamic>> demoUserInfo = {...};
  
  // Valeurs par défaut
  static const int defaultXP = 0;
  static const int defaultLevel = 1;
  
  // Limites métier
  static const int maxLevel = 100;
  static const int xpPerLevel = 1000;
  
  // Langues supportées
  static const List<String> supportedLanguages = ['en', 'fr', 'ar'];
}
```

### **Usage actuel** :
- Importé par `app_helpers.dart` uniquement (calculs de niveau/XP)

### **📊 État** : ✅ Actif mais sous-utilisé

---

## 2️⃣ `app_helpers.dart` - Fonctions utilitaires

### **Rôle** : Fonctions réutilisables pour le formatage et la logique métier

### **Pourquoi ça existe** :
- Éviter la duplication
- Centraliser la logique métier (niveau, XP, streak)
- Unifier le formatage d’affichage

### **Catégories de fonctions** :

#### **A. Formatage**
```dart
formatStudyTime(125)     // → "2 h 5 min"
formatXP(1500)          // → "1.5k"
formatPercentage(0.85)  // → "85%"
formatDate(DateTime)    // → "Il y a 3 jours"
formatDuration(Duration) // → "2h 15m 30s"
```

#### **B. Couleurs**
```dart
getLevelColor(12)       // → Couleur selon le niveau
getStreakColor(7)       // → Couleur selon le streak
getAccuracyColor(0.85)  // → Couleur selon la précision
getAchievementTierColor('gold') // → Couleur du badge
```

#### **C. Logique métier**
```dart
calculateLevel(xp)           // → Calcul du niveau basé sur XP
calculateXPForNextLevel(5)   // → XP nécessaire pour niveau 6
calculateProgressToNextLevel(xp) // → % vers prochain niveau
isStreakMaintained(lastDate) // → Si streak maintenu
```

#### **D. Utilitaires**
```dart
getScoreGrade(0.85)     // → "B"
isValidEmail(email)     // → bool
truncate(text, 50)      // → "Texte tronqué..."
getInitials("John Doe") // → "JD"
```

### **Usage actuel** :
- ❌ Aucun usage détecté dans le code actuel

### **📊 État** : ⚠️ Inutilisé mais utile

---

## 3️⃣ `translation_helper.dart` - Gestion des traductions Firestore

### **Rôle** : Récupérer des traductions depuis Firestore

### **Pourquoi ça existe** :
- Traduire le contenu multilingue de Firestore
- Centraliser la logique de fallback
- Simplifier l’API côté UI

### **Fonctions** :

```dart
// Récupère une traduction (String)
TranslationHelper.getTranslation(
  context,
  {'en': 'Hello', 'fr': 'Bonjour', 'ar': 'مرحبا'},
  'greeting',
); // Retourne selon langue actuelle

// Récupère un tableau de traductions (List)
TranslationHelper.getTranslationList(
  context,
  {'en': ['A', 'B'], 'fr': ['A', 'B']},
); // Retourne liste selon langue actuelle
```

### **Logique de fallback** :
1. Langue actuelle (ex: `fr`)
2. Anglais (`en`)
3. Français (`fr`)
4. Arabe (`ar`)
5. Première valeur disponible
6. Message d’erreur

### **Usage actuel** :
- ✅ `lib/main.dart` - Titres et descriptions des leçons
- ✅ `lib/exercises/exercise.dart` - Méthodes de traduction
- ✅ `lib/screens/lesson_preview_screen.dart` - Mots arabes

### **📊 État** : ✅ Actif et utilisé

---

## 4️⃣ `arabic_text_style.dart` - Affichage du texte arabe

### **Rôle** : Styles et affichage du texte arabe

### **Pourquoi ça existe** :
- Surmonter les problèmes d’affichage RTL
- Appliquer des polices arabes adaptées
- Détecter automatiquement l’arabe

### **Styles disponibles** :

```dart
// Style de base
ArabicTextStyle.arabicText(fontSize: 18)

// Titre
ArabicTextStyle.arabicTitle(fontSize: 24)

// Option de réponse
ArabicTextStyle.arabicOption(fontSize: 18)

// Question
ArabicTextStyle.arabicQuestion(fontSize: 20)
```

### **Détection automatique** :

```dart
ArabicTextStyle.isArabicText("مرحبا")  // → true
ArabicTextStyle.smartStyle("مرحبا")    // → Style arabe (Amiri)
ArabicTextStyle.smartStyle("Hello")    // → Style Poppins
```

### **Widget helper** :

```dart
// Applique automatiquement le bon style ET direction
ArabicText(
  "مرحبا",
  style: ArabicTextStyle.arabicText(),
) // Aligné à droite, RTL automatique
```

### **Usage actuel** :
- ✅ `lib/exercises/multiple_choice_exercise.dart`
- ✅ `lib/exercises/audio_exercise.dart`
- ✅ `lib/exercises/dragDropExercise.dart`
- ✅ `lib/exercises/pairs_exercise.dart`
- ✅ `lib/exercises/true_false_exercise.dart`

### **📊 État** : ✅ Actif et utilisé

---

## 5️⃣ `app_localizations.dart` - ⚠️ ANCIEN SYSTÈME

### **Rôle** : Localisation via Maps statiques (déprécié)

### **Pourquoi ça existait** :
- Ancien système de traduction
- Remplacé par le système `.arb`

### **Méthode obsolète** :
```dart
AppLocalizations(locale).get('key')  // ❌ Ancien
```

### **Nouveau système** :
```dart
AppLocalizations.of(context).key    // ✅ Nouveau (dans l10n/)
```

### **Usage actuel** :
- ⚠️ Non importé, supprimable

### **📊 État** : ⚠️ Déprécié

---

## 6️⃣ `translations.dart` - ⚠️ INUTILISÉ

### **Rôle** : Autre système de traduction (non utilisé)

### **Usage actuel** :
- ❌ Aucun usage détecté

### **📊 État** : ⚠️ Inutilisé

---

## 🎯 Recommandations

### **À garder** :
1. ✅ `translation_helper.dart` - Essentiel
2. ✅ `arabic_text_style.dart` - Essentiel
3. ✅ `app_constants.dart` - Peut être utile

### **À utiliser** :
4. ⚠️ `app_helpers.dart` - Non utilisé mais utile

### **À supprimer** :
5. ❌ `app_localizations.dart` - Déprécié
6. ❌ `translations.dart` - Inutilisé

---

## 📝 Actions suggérées

### 1. Utiliser `app_helpers.dart`

Dans `progression_screen.dart` par exemple :

```dart
// ❌ AVANT
Text('${(xp / 1000).floor()}')

// ✅ APRÈS
Text(AppHelpers.calculateLevel(xp).toString())

// ❌ AVANT
Text('${(accuracy * 100).toInt()}%')

// ✅ APRÈS
Text(AppHelpers.formatPercentage(accuracy))
```

### 2. Supprimer les fichiers inutiles

```bash
# Supprimer les anciens systèmes de traduction
rm lib/utils/app_localizations.dart
rm lib/utils/translations.dart
```

### 3. Utiliser `app_constants.dart`

Dans les services Firestore :

```dart
// ❌ AVANT
FirebaseFirestore.instance.collection('users')

// ✅ APRÈS
FirebaseFirestore.instance.collection(AppConstants.usersCollection)
```

---

## 🎓 Conclusion

Le package `utils` est bien structuré et centralise les valeurs et la logique partagée. Deux fichiers sont dépréciés et peuvent être supprimés. `app_helpers.dart` n’est pas utilisé mais peut être bénéfique pour réduire la duplication. `translation_helper.dart` et `arabic_text_style.dart` sont essentiels au fonctionnement multilingue.

