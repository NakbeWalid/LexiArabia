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
    // Gestion spéciale pour drag_drop
    List<Map<String, dynamic>>? dragDropPairs;
    String? answer;

    if (json['type'] == 'drag_drop' && json['answer'] is List) {
      dragDropPairs = (json['answer'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else if (json['answer'] is String) {
      answer = json['answer'];
    } else if (json['answer'] is bool) {
      answer = json['answer'].toString();
    } else if (json['correct_answer'] is String) {
      answer = json['correct_answer'];
    } else if (json['correct_answer'] is bool) {
      answer = json['correct_answer'].toString();
    }

    return Exercise(
      type: json['type'] ?? '',
      question: json['question'] ?? '',
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
      answer: answer,
      audioUrl: json['audioUrl'],
      dragDropPairs: dragDropPairs,
    );
  }
}
