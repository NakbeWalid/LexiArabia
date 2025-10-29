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
    // Supporter uniquement les Maps de traduction pour de meilleures performances
    if (field is! Map<String, dynamic>) {
      return 'Translation not available';
    }

    final fieldMap = field;
    final localizations = AppLocalizations.of(context)!;
    // Extraire le code de langue depuis localeName (peut être 'en' ou 'en_US')
    final locale = localizations.localeName;
    final langCode = locale.split('_').first.toLowerCase();

    // Essayer la langue actuelle
    if (fieldMap.containsKey(langCode)) {
      return fieldMap[langCode].toString();
    }

    // Fallback vers l'anglais
    if (fieldMap.containsKey('en')) {
      return fieldMap['en'].toString();
    }

    // Fallback vers le français
    if (fieldMap.containsKey('fr')) {
      return fieldMap['fr'].toString();
    }

    // Fallback vers l'arabe
    if (fieldMap.containsKey('ar')) {
      return fieldMap['ar'].toString();
    }

    // Prendre la première valeur disponible
    if (fieldMap.isNotEmpty) {
      return fieldMap.values.first.toString();
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
    // Supporter uniquement les Maps de traduction pour de meilleures performances
    if (field is! Map<String, dynamic>) {
      return [];
    }

    final fieldMap = field;
    final localizations = AppLocalizations.of(context)!;

    // Extraire le code de langue depuis localeName
    final locale = localizations.localeName;
    final langCode = locale.split('_').first.toLowerCase();

    // Essayer la langue actuelle
    if (fieldMap.containsKey(langCode) && fieldMap[langCode] is List) {
      return (fieldMap[langCode] as List).map((e) => e.toString()).toList();
    }

    // Fallback vers l'anglais
    if (fieldMap.containsKey('en') && fieldMap['en'] is List) {
      return (fieldMap['en'] as List).map((e) => e.toString()).toList();
    }

    // Fallback vers le français
    if (fieldMap.containsKey('fr') && fieldMap['fr'] is List) {
      return (fieldMap['fr'] as List).map((e) => e.toString()).toList();
    }

    // Fallback vers l'arabe
    if (fieldMap.containsKey('ar') && fieldMap['ar'] is List) {
      return (fieldMap['ar'] as List).map((e) => e.toString()).toList();
    }

    return [];
  }

  /// Récupérer la langue actuelle de l'application
  static String getCurrentLanguageCode(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return localizations.localeName;
  }
}
