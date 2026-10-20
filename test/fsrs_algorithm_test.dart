import 'package:dualingocoran/models/srs_exercise_model.dart';
import 'package:dualingocoran/services/fsrs_algorithm.dart';
import 'package:flutter_test/flutter_test.dart';

SRSExercise _newCard(DateTime now) => SRSExercise(
  exerciseId: 'test_0',
  lessonId: 'test',
  exerciseIndex: 0,
  exerciseType: 'multiple_choice',
  interval: 0,
  stability: 0.4,
  difficulty: 5.0,
  state: 0,
  lapses: 0,
  dueDate: now,
  elapsedDays: 0,
  status: 'new',
  createdAt: now,
  exerciseData: const {},
  totalReviews: 0,
  correctReviews: 0,
  incorrectReviews: 0,
  hardReviews: 0,
);

/// Simule une révision puis place la date de dernière révision à [now]
SRSExercise _review(SRSExercise card, int quality, DateTime now) =>
    FSRSAlgorithm.calculateNext(
      current: card,
      quality: quality,
      now: now,
    ).copyWith(lastReviewed: now);

void main() {
  final t0 = DateTime(2026, 1, 1, 9);

  test('nouvelle carte GOOD → apprentissage court', () {
    final card = _review(_newCard(t0), FSRSAlgorithm.good, t0);
    expect(card.state, 1);
    expect(card.dueDate.difference(t0), const Duration(minutes: 10));
  });

  test('GOOD en apprentissage fait passer en révision (pas de boucle)', () {
    var card = _review(_newCard(t0), FSRSAlgorithm.good, t0);
    card = _review(card, FSRSAlgorithm.good, t0.add(const Duration(hours: 1)));
    expect(card.state, 2);
    expect(card.status, 'review');
    expect(card.dueDate.difference(t0).inDays, greaterThanOrEqualTo(1));
  });

  test('les intervalles grandissent avec des révisions réussies', () {
    var now = t0;
    var card = _review(_newCard(now), FSRSAlgorithm.good, now);
    now = now.add(const Duration(minutes: 10));
    card = _review(card, FSRSAlgorithm.good, now);

    var previous = card.dueDate.difference(now);
    for (var i = 0; i < 4; i++) {
      now = card.dueDate;
      card = _review(card, FSRSAlgorithm.good, now);
      final next = card.dueDate.difference(now);
      expect(next, greaterThan(previous));
      previous = next;
    }
  });

  test('AGAIN en révision → réapprentissage et lapse', () {
    var card = _review(_newCard(t0), FSRSAlgorithm.easy, t0);
    expect(card.state, 2);
    final before = card.stability;

    card = _review(card, FSRSAlgorithm.again, card.dueDate);
    expect(card.state, 3);
    expect(card.lapses, 1);
    expect(card.stability, lessThan(before));
  });

  test('HARD < GOOD < EASY pour la stabilité', () {
    final base = _review(_newCard(t0), FSRSAlgorithm.easy, t0);
    final at = base.dueDate;
    final hard = _review(base, FSRSAlgorithm.hard, at).stability;
    final good = _review(base, FSRSAlgorithm.good, at).stability;
    final easy = _review(base, FSRSAlgorithm.easy, at).stability;
    expect(hard, lessThan(good));
    expect(good, lessThan(easy));
  });
}
