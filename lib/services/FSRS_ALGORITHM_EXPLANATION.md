# Explication Complète de l'Algorithme FSRS

## Vue d'Ensemble

FSRS (Free Spaced Repetition Scheduler) est un algorithme moderne de répétition espacée basé sur des modèles d'apprentissage automatique. Contrairement à SM-2 (l'algorithme classique d'Anki), FSRS utilise 17 paramètres optimisés par machine learning pour adapter l'intervalle de révision à chaque carte individuelle.

## Concepts Fondamentaux

### 1. **Stabilité (Stability)**
- **Définition** : La stabilité représente le temps (en jours) après lequel la probabilité de rétention chute à 90% (ou au taux de rétention cible).
- **Évolution** : La stabilité augmente ou diminue après chaque révision selon la qualité de la réponse.
- **Exemple** : Si une carte a une stabilité de 10 jours, cela signifie qu'après 10 jours, l'utilisateur a encore 90% de chance de se souvenir de la réponse.

### 2. **Difficulté (Difficulty)**
- **Définition** : Un nombre de 0 à 10 qui représente la difficulté intrinsèque de la carte.
- **Calcul** : S'ajuste dynamiquement selon les performances (réponses difficiles augmentent la difficulté, réponses faciles la diminuent).
- **Impact** : Les cartes difficiles nécessitent des révisions plus fréquentes et ont des intervalles plus courts.

### 3. **État (State)**
L'état d'une carte peut être l'un des quatre suivants :
- **0 = NEW** : Carte jamais révisée
- **1 = LEARNING** : Carte en phase d'apprentissage (intervalles courts)
- **2 = REVIEW** : Carte maîtrisée en révision normale
- **3 = RELEARNING** : Carte oubliée, en phase de réapprentissage

### 4. **Échecs (Lapses)**
- **Définition** : Nombre d'oublis historiques d'une carte (lapses).
- **Note (dans cette app)** : L'utilisateur ne peut pas passer au prochain exercice tant qu'il n'a pas réussi, donc on ne produit pas de réponse "AGAIN" (`quality=0`). Le champ `lapses` peut exister pour compatibilité, mais n'est pas incrémenté par les reviews actuelles.

### 5. **Jours Écoulés (Elapsed Days)**
- **Définition** : Nombre de jours réels depuis la dernière révision.
- **Importance** : Utilisé pour calculer la probabilité de rétention réelle (courbe d'oubli).

### 6. **Intervalle (Interval)**
- **Définition** : Temps jusqu'à la prochaine révision (en jours).
- **Calcul** : Basé sur la stabilité, ajusté selon la rétention cible.

## Qualités de Réponse

Dans cette app, on utilise 3 niveaux (pas de AGAIN) :

- **1 = HARD** : Réponse correcte mais difficile
- **2 = GOOD** : Réponse correcte (par défaut)
- **3 = EASY** : Réponse très facile

## Flux de Calcul FSRS

### Étape 1 : Calculer les Jours Écoulés

```dart
if (elapsedDays == 0 && lastReviewed != null) {
  actualElapsedDays = DateTime.now().difference(lastReviewed).inDays;
}
```

### Étape 2 : Calculer la Nouvelle Difficulté

La difficulté s'ajuste selon la qualité de la réponse :

```dart
change = p[5] + (quality - 2) * p[6]
newDifficulty = difficulty - change * (difficulty - 8)
```

- **GOOD (quality=2)** : Peu de changement
- **HARD (quality=1)** : Augmente légèrement la difficulté
- **EASY (quality=3)** : Diminue la difficulté

### Étape 3 : Calculer la Nouvelle Stabilité

#### Pour une Nouvelle Carte (state == 0)

**Initialisation de la difficulté** :
```dart
difficulty = 5.0 - (quality - 2) * p[4]
```

**Initialisation de la stabilité** :
```dart
stability = p[0] + (p[1] - p[0]) * (quality - 1) / 2.0
stability *= (1.0 + (difficulty - 5.0) * p[2] / 20.0)
```

- `p[0]` : Stabilité minimale initiale (environ 0.4 jours)
- `p[1]` : Stabilité maximale initiale (environ 1.6 jours)
- `p[2]` : Facteur d'ajustement selon la difficulté (environ 10.0)

#### Pour une Carte Existante

**Calcul de la rétention** (probabilité de se souvenir) :
```dart
retention = exp(-elapsedDays / stability)
```

**Mise à jour de la stabilité selon la qualité** :

- **HARD (quality=1)** :
  ```dart
  newStability = stability * (1.0 + exp(p[8]) * (11.0 - difficulty) * 
                pow(stability, -p[9]) * (exp((1.0 - retention) * p[10]) - 1.0))
  ```

- **GOOD (quality=2)** :
  ```dart
  newStability = stability * (1.0 + exp(p[8]) * (11.0 - difficulty) * 
                pow(stability, -p[9]) * (exp((1.0 - retention) * p[10]) - 1.0))
  ```

- **EASY (quality=3)** :
  ```dart
  newStability = stability * (1.0 + exp(p[8]) * (11.0 - difficulty) * 
                pow(stability, -p[9]) * (exp((1.0 - retention) * p[11]) - 1.0))
  ```

Les paramètres `p[8]`, `p[9]`, `p[10]`, `p[11]` contrôlent l'augmentation de stabilité.

### Étape 4 : Calculer le Nouvel Intervalle

#### Pour les Cartes en Apprentissage (LEARNING/RELEARNING)

```dart
if (state == 1) {
  interval = p[12]  // Intervalle pour LEARNING (≈ 0.05 jours = 1.2 heures)
} else if (state == 3) {
  interval = p[13]  // Intervalle pour RELEARNING (≈ 0.34 jours = 8 heures)
}
```

#### Pour les Cartes en Révision (REVIEW)

```dart
interval = stability  // L'intervalle de base = la stabilité
```

**Ajustement selon la rétention cible** :
```dart
actualRetention = exp(-interval / stability)
if (actualRetention < requestRetention) {
  // Réduire l'intervalle pour maintenir 90% de rétention
  interval = stability * ln(requestRetention) / ln(actualRetention)
}
```

### Étape 5 : Mettre à Jour l'État

#### Transition d'État

**Nouvelle carte (state == 0)** :
- HARD/GOOD → LEARNING (1)
- EASY → REVIEW (2)

**Carte en apprentissage (state == 1)** :
- HARD/GOOD → Continue LEARNING (1)
- EASY → REVIEW (2)

**Carte en révision (state == 2)** :
- HARD/GOOD/EASY → Continue REVIEW (2)

**Carte en réapprentissage (state == 3)** :
- (Legacy/compatibilité) Dans cette app, on ne bascule plus vers RELEARNING via `quality=0`.

### Étape 6 : Mettre à Jour les Échecs

Dans cette app, `quality=0` n'est pas utilisé, donc ce bloc n'est plus pertinent.

## Les 17 Paramètres FSRS

Les paramètres FSRS sont optimisés par machine learning sur de grandes bases de données de révisions. Voici leur signification approximative :

1. **p[0]** (0.4) : Stabilité minimale initiale
2. **p[1]** (1.6) : Stabilité maximale initiale
3. **p[2]** (10.0) : Facteur d'ajustement difficulté/stabilité initiale
4. **p[3]** (5.8) : Facteur d'ajustement difficulté initiale
5. **p[4]** (4.93) : Ajustement difficulté initiale selon qualité
6. **p[5]** (0.94) : Base de changement de difficulté
7. **p[6]** (0.86) : Amplitude du changement de difficulté
8. **p[7]** (0.01) : Facteur de réduction stabilité après échec
9. **p[8]** (1.49) : Base de croissance stabilité
10. **p[9]** (0.14) : Exposant de croissance stabilité
11. **p[10]** (0.94) : Facteur croissance stabilité HARD/GOOD
12. **p[11]** (2.18) : Facteur croissance stabilité EASY
13. **p[12]** (0.05) : Intervalle LEARNING
14. **p[13]** (0.34) : Intervalle RELEARNING
15. **p[14]** (1.26) : Facteur supplémentaire
16. **p[15]** (0.29) : Facteur supplémentaire
17. **p[16]** (2.61) : Facteur supplémentaire

## Courbe d'Oubli

La courbe d'oubli (forgetting curve) modélise la probabilité de rétention après un certain nombre de jours :

```
retention(t) = exp(-t / stability)
```

Où :
- `t` = jours écoulés depuis la dernière révision
- `stability` = stabilité actuelle de la carte

**Exemple** :
- Stabilité = 10 jours
- Après 5 jours : retention = exp(-5/10) = 60.6%
- Après 10 jours : retention = exp(-10/10) = 36.8%
- Après 20 jours : retention = exp(-20/10) = 13.5%

## Avantages de FSRS par rapport à SM-2

1. **Adaptation Individuelle** : FSRS s'adapte mieux à chaque carte individuelle grâce à la notion de difficulté.
2. **Meilleure Prédiction** : Utilise la courbe d'oubli pour prédire la probabilité de rétention.
3. **Optimisation Automatique** : Les 17 paramètres sont optimisés par machine learning sur de grandes bases de données.
4. **Gestion des Échecs** : Gère mieux les cartes oubliées avec le concept de "lapses" et l'état RELEARNING.
5. **Rétention Cible** : Permet d'ajuster l'intervalle pour maintenir un taux de rétention cible (par défaut 90%).

## Exemple de Calcul Complet

### Scénario : Première Révision d'une Nouvelle Carte

**Données initiales** :
- State = NEW (0)
- Difficulty = 5.0 (par défaut)
- Stability = 0.0
- Lapses = 0

**Utilisateur répond "GOOD" (quality = 2)** :

1. **Nouvelle difficulté** :
   ```
   difficulty = 5.0 - (2 - 2) * 4.93 = 5.0
   ```

2. **Nouvelle stabilité** :
   ```
   stability = 0.4 + (1.6 - 0.4) * (2 - 1) / 2.0 = 1.0
   stability *= (1.0 + (5.0 - 5.0) * 10.0 / 20.0) = 1.0 jour
   ```

3. **Nouvel état** : LEARNING (1)

4. **Nouvel intervalle** :
   ```
   interval = p[12] = 0.05 jours = 1.2 heures
   ```

5. **Prochaine révision** : Dans 1.2 heures

### Scénario : Révision d'une Carte Maîtrisée

**Données avant révision** :
- State = REVIEW (2)
- Difficulty = 6.5
- Stability = 15.0 jours
- ElapsedDays = 15 jours (révision exactement à temps)

**Utilisateur répond "GOOD" (quality = 2)** :

1. **Rétention calculée** :
   ```
   retention = exp(-15 / 15) = 0.368 (36.8%)
   ```

2. **Nouvelle difficulté** :
   ```
   change = 0.94 + (2 - 2) * 0.86 = 0.94
   newDifficulty = 6.5 - 0.94 * (6.5 - 8) = 6.5 - (-1.41) = 7.91
   ```

3. **Nouvelle stabilité** :
   ```
   newStability = 15.0 * (1.0 + exp(1.49) * (11.0 - 7.91) * 
                  pow(15.0, -0.14) * (exp((1.0 - 0.368) * 0.94) - 1.0))
   newStability ≈ 15.0 * 1.8 ≈ 27 jours
   ```

4. **Nouvel intervalle** :
   ```
   interval = 27 jours
   actualRetention = exp(-27 / 27) = 0.368
   // Ajustement pour 90% de rétention
   interval = 27 * ln(0.9) / ln(0.368) ≈ 27 * 0.28 ≈ 7.6 jours
   ```

5. **Prochaine révision** : Dans 7.6 jours (au lieu de 27 jours pour maintenir 90% de rétention)

## Conclusion

FSRS est un algorithme beaucoup plus sophistiqué que SM-2, utilisant des modèles mathématiques avancés pour optimiser l'apprentissage. Il s'adapte mieux aux différences individuelles entre les cartes et les utilisateurs, tout en maintenant un taux de rétention cible optimal.

