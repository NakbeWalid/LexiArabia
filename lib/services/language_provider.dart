import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  static final Map<String, Locale> supportedLocales = {
    'en': const Locale('en'),
    'fr': const Locale('fr'),
    'ar': const Locale('ar'),
  };

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'en';
      _currentLocale = supportedLocales[languageCode] ?? const Locale('en');
      print('🌍 Langue chargée: ${_currentLocale.languageCode}');
      notifyListeners();
    } catch (e) {
      print('❌ Erreur lors du chargement de la langue: $e');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    print('🔄 Tentative de changement de langue vers: $languageCode');

    if (supportedLocales.containsKey(languageCode)) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);

        _currentLocale = supportedLocales[languageCode]!;
        print(
          '✅ Langue changée avec succès vers: ${_currentLocale.languageCode}',
        );

        notifyListeners();
      } catch (e) {
        print('❌ Erreur lors de la sauvegarde de la langue: $e');
      }
    } else {
      print('❌ Code de langue non supporté: $languageCode');
    }
  }

  String getCurrentLanguageCode() {
    return _currentLocale.languageCode;
  }

  // Vérifier si c'est l'arabe (pour le RTL)
  bool get isRTL => _currentLocale.languageCode == 'ar';

  // Obtenir le nom de la langue actuelle
  String getCurrentLanguageName() {
    final names = {'en': 'English', 'fr': 'Français', 'ar': 'العربية'};
    return names[_currentLocale.languageCode] ?? 'Unknown';
  }
}
