import 'package:flutter/material.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';

/// Helper class pour gérer les traductions depuis Firestore
class TranslationHelper {
  /// Récupérer une traduction depuis un objet Firestore
  ///
  /// Accepte :
  /// - Une String directe : retournée telle quelle
  /// - Une Map avec clés de langue : retourne la traduction selon la langue actuelle
  ///
  /// Exemple d'utilisation :
  /// ```dart
  /// final question = TranslationHelper.getTranslation(
  ///   context,
  ///   exerciseData['question'], // Peut être String ou Map
  ///   'question',
  /// );
  /// ```
  static String getTranslation(
    BuildContext context,
    dynamic field,
    String key,
  ) {
    // Si c'est déjà une String, la retourner directement (cas sans traduction)
    if (field is String) {
      return field;
    }

    // Si c'est une Map avec des clés de langue
    if (field is Map<String, dynamic>) {
      final localizations = AppLocalizations.of(context)!;
      final langCode = localizations.localeName;

      // Essayer la langue actuelle
      if (field.containsKey(langCode)) {
        return field[langCode].toString();
      }

      // Fallback vers l'anglais
      if (field.containsKey('en')) {
        return field['en'].toString();
      }

      // Fallback vers le français
      if (field.containsKey('fr')) {
        return field['fr'].toString();
      }

      // Fallback vers l'arabe
      if (field.containsKey('ar')) {
        return field['ar'].toString();
      }

      // Prendre la première valeur disponible
      if (field.isNotEmpty) {
        return field.values.first.toString();
      }
    }

    // Aucune traduction disponible
    return 'Translation not available';
  }

  /// Récupérer un tableau de traductions depuis Firestore
  ///
  /// Accepte :
  /// - Une List : retournée telle quelle
  /// - Une Map avec clés de langue : retourne la liste selon la langue actuelle
  ///
  /// Exemple :
  /// ```dart
  /// final options = TranslationHelper.getTranslationList(
  ///   context,
  ///   exerciseData['options'],
  /// );
  /// ```
  static List<String> getTranslationList(BuildContext context, dynamic field) {
    final localizations = AppLocalizations.of(context)!;
    final langCode = localizations.localeName;

    // Si c'est déjà une liste, la retourner
    if (field is List) {
      return field.map((e) => e.toString()).toList();
    }

    // Si c'est une Map avec clés de langue
    if (field is Map<String, dynamic>) {
      // Essayer la langue actuelle
      if (field.containsKey(langCode) && field[langCode] is List) {
        return (field[langCode] as List).map((e) => e.toString()).toList();
      }

      // Fallback vers l'anglais
      if (field.containsKey('en') && field['en'] is List) {
        return (field['en'] as List).map((e) => e.toString()).toList();
      }

      // Fallback vers le français
      if (field.containsKey('fr') && field['fr'] is List) {
        return (field['fr'] as List).map((e) => e.toString()).toList();
      }

      // Fallback vers l'arabe
      if (field.containsKey('ar') && field['ar'] is List) {
        return (field['ar'] as List).map((e) => e.toString()).toList();
      }
    }

    return [];
  }

  /// Récupérer la langue actuelle de l'application
  static String getCurrentLanguageCode(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return localizations.localeName;
  }
}
