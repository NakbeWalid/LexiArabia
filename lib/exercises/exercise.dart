class Exercise {
  final String type;
  final String question;
  final List<String>? options;
  final String? answer;
  final String? audioUrl;
  final List<Map<String, dynamic>>? dragDropPairs; // Ajouté pour drag_drop

  Exercise({
    required this.type,
    required this.question,
    this.options,
    this.answer,
    this.audioUrl,
    this.dragDropPairs,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    // Gestion spéciale pour drag_and_drop et pairs
    List<Map<String, dynamic>>? dragDropPairs;
    String? answer;

    // Gestion des types d'exercices avec vos noms
    String exerciseType = json['type'] ?? '';
    if (exerciseType == 'true_or_false') {
      exerciseType = 'true_false';
    } else if (exerciseType == 'drag_and_drop') {
      exerciseType = 'drag_drop';
    } else if (exerciseType == 'audio') {
      exerciseType = 'audio_choice';
    }

    // Gestion des réponses
    if (json['answer'] is String) {
      answer = json['answer'];
    } else if (json['answer'] is bool) {
      answer = json['answer'].toString();
    } else if (json['correct_answer'] is String) {
      answer = json['correct_answer'];
    } else if (json['correct_answer'] is bool) {
      answer = json['correct_answer'].toString();
    }

    // Gestion de la question/instruction
    String question = json['question'] ?? json['instruction'] ?? '';

    // Gestion des pairs pour drag_and_drop et pairs
    if ((exerciseType == 'drag_drop' || exerciseType == 'pairs') &&
        json['pairs'] != null) {
      print('Processing pairs exercise: $exerciseType');
      print('Pairs data: ${json['pairs']}');
      if (json['pairs'] is List) {
        // Nouvelle structure: pairs est un tableau d'objets avec from et to
        List<dynamic> pairsList = json['pairs'] as List;
        print('Pairs is List with ${pairsList.length} items');
        dragDropPairs = pairsList
            .where(
              (pair) =>
                  pair is Map && pair['from'] != null && pair['to'] != null,
            )
            .map(
              (pair) => {
                'from': pair['from'].toString(),
                'to': pair['to'].toString(),
              },
            )
            .toList();
        print('Processed dragDropPairs: $dragDropPairs');
      } else if (json['pairs'] is Map) {
        // Ancienne structure: pairs est un Map
        Map<String, dynamic> pairs = json['pairs'] as Map<String, dynamic>;
        print('Pairs is Map');
        dragDropPairs = pairs.entries
            .map((e) => {'term': e.key, 'match': e.value.toString()})
            .toList();
        print('Processed dragDropPairs: $dragDropPairs');
      }
    }

    return Exercise(
      type: exerciseType,
      question: question,
      options: json['options'] != null
          ? (json['options'] as List).map((e) => e.toString()).toList()
          : null,
      answer: answer,
      audioUrl: json['audioUrl'],
      dragDropPairs: dragDropPairs,
    );
  }
}
