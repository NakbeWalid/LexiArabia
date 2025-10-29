import 'package:flutter/material.dart';
import 'package:dualingocoran/utils/translation_helper.dart';

class Exercise {
  final String type;
  final String question;
  final List<String>? options;
  final String? answer;
  final String? audioUrl;
  final List<Map<String, dynamic>>? dragDropPairs; // Ajouté pour drag_drop
  final Map<String, dynamic>? rawData; // Données brutes pour les traductions

  Exercise({
    required this.type,
    required this.question,
    this.options,
    this.answer,
    this.audioUrl,
    this.dragDropPairs,
    this.rawData,
  });

  /// Parser les options (peut être une List ou une Map avec traductions)
  static List<String>? _parseOptions(dynamic optionsData) {
    // Supporter uniquement les Maps de traduction pour de meilleures performances
    if (optionsData is! Map) {
      return null;
    }

    // C'est une Map de traductions, utiliser l'anglais comme fallback initial
    final optionsMap = optionsData as Map<String, dynamic>;
    if (optionsMap['en'] is List) {
      return (optionsMap['en'] as List).map((e) => e.toString()).toList();
    } else if (optionsMap['fr'] is List) {
      return (optionsMap['fr'] as List).map((e) => e.toString()).toList();
    } else if (optionsMap['ar'] is List) {
      return (optionsMap['ar'] as List).map((e) => e.toString()).toList();
    }

    return null;
  }

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

    // Gestion des réponses (Map de traductions uniquement)
    if (json['answer'] != null && json['answer'] is Map) {
      final answerMap = json['answer'] as Map<String, dynamic>;
      answer =
          answerMap['en']?.toString() ??
          answerMap['fr']?.toString() ??
          answerMap['ar']?.toString() ??
          answerMap.values.first?.toString() ??
          '';
    } else if (json['answer'] is bool) {
      answer = json['answer'].toString();
    } else if (json['correct_answer'] != null &&
        json['correct_answer'] is Map) {
      final answerMap = json['correct_answer'] as Map<String, dynamic>;
      answer =
          answerMap['en']?.toString() ??
          answerMap['fr']?.toString() ??
          answerMap['ar']?.toString() ??
          answerMap.values.first?.toString() ??
          '';
    } else if (json['correct_answer'] is bool) {
      answer = json['correct_answer'].toString();
    }

    // Gestion de la question/instruction (Map de traductions uniquement)
    String question = '';
    if (json['question'] != null && json['question'] is Map) {
      final questionMap = json['question'] as Map<String, dynamic>;
      question =
          questionMap['en']?.toString() ??
          questionMap['fr']?.toString() ??
          questionMap['ar']?.toString() ??
          questionMap.values.first?.toString() ??
          '';
    } else if (json['instruction'] != null && json['instruction'] is Map) {
      final instructionMap = json['instruction'] as Map<String, dynamic>;
      question =
          instructionMap['en']?.toString() ??
          instructionMap['fr']?.toString() ??
          instructionMap['ar']?.toString() ??
          instructionMap.values.first?.toString() ??
          '';
    }

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
      options: json['options'] != null ? _parseOptions(json['options']) : null,
      answer: answer,
      audioUrl: json['audioUrl'],
      dragDropPairs: dragDropPairs,
      rawData: json, // Stocker les données brutes pour les traductions
    );
  }

  /// Obtenir la question traduite selon la langue de l'application
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

  /// Obtenir les options traduites selon la langue de l'application
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

  /// Obtenir la réponse traduite
  String getTranslatedAnswer(BuildContext context) {
    if (rawData == null || rawData!['answer'] == null) {
      return answer ?? '';
    }

    // Si l'answer est une Map avec traductions
    if (rawData!['answer'] is Map) {
      return TranslationHelper.getTranslation(
        context,
        rawData!['answer'],
        'answer',
      );
    }

    return answer ?? '';
  }

  /// Obtenir l'instruction traduite si elle existe
  String? getTranslatedInstruction(BuildContext context) {
    if (rawData == null || rawData!['instruction'] == null) {
      return null;
    }
    return TranslationHelper.getTranslation(
      context,
      rawData!['instruction'],
      'instruction',
    );
  }

  /// Obtenir les pairs traduits pour drag_drop et pairs
  List<Map<String, dynamic>>? getTranslatedPairs(BuildContext context) {
    if (dragDropPairs == null || rawData == null || rawData!['pairs'] == null) {
      return dragDropPairs;
    }

    // Si les pairs contiennent des traductions
    final pairs = rawData!['pairs'] as List;
    final translatedPairs = <Map<String, dynamic>>[];

    for (var pair in pairs) {
      if (pair is Map) {
        var from = pair['from']?.toString() ?? '';
        var to = pair['to']?.toString() ?? '';

        // Si 'from' est une Map de traductions
        if (pair['from'] is Map) {
          from = TranslationHelper.getTranslation(
            context,
            pair['from'],
            'from',
          );
        }

        // Si 'to' est une Map de traductions
        if (pair['to'] is Map) {
          to = TranslationHelper.getTranslation(context, pair['to'], 'to');
        }

        translatedPairs.add({'from': from, 'to': to});
      }
    }

    return translatedPairs.isNotEmpty ? translatedPairs : dragDropPairs;
  }
}
