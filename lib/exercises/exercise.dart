class Exercise {
  final String type;
  final String question;
  final List<String>? options;
  final String? answer;
  final String? audioUrl;

  Exercise({
    required this.type,
    required this.question,
    this.options,
    this.answer,
    this.audioUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      type: json['type'],
      question: json['question'],
      options: List<String>.from(json['options'] ?? []),
      answer: json['correct_answer'],
      audioUrl: json['audio_url'],
    );
  }
}
