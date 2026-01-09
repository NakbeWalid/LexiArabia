import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Helper pour gérer les polices Google Fonts avec cache et gestion d'erreurs
class FontHelper {
  // Cache pour les TextStyle
  static final Map<String, TextStyle> _textStyleCache = {};

  /// Obtenir un TextStyle Poppins avec gestion d'erreurs
  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) {
    final cacheKey =
        'poppins_${fontSize}_${fontWeight}_${color}_${letterSpacing}';

    // Retourner depuis le cache si disponible
    if (_textStyleCache.containsKey(cacheKey)) {
      return _textStyleCache[cacheKey]!;
    }

    // Essayer de charger la police Google Fonts
    try {
      final style = GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        shadows: shadows,
      );
      _textStyleCache[cacheKey] = style;
      return style;
    } catch (e) {
      // Fallback sur la police système en cas d'erreur
      final style = TextStyle(
        fontFamily: 'Poppins',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        shadows: shadows,
      );
      _textStyleCache[cacheKey] = style;
      return style;
    }
  }

  /// Obtenir un TextStyle Roboto Mono avec gestion d'erreurs
  static TextStyle robotoMono({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    final cacheKey = 'robotoMono_${fontSize}_${fontWeight}_${color}';

    if (_textStyleCache.containsKey(cacheKey)) {
      return _textStyleCache[cacheKey]!;
    }

    try {
      final style = GoogleFonts.robotoMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
      _textStyleCache[cacheKey] = style;
      return style;
    } catch (e) {
      final style = TextStyle(
        fontFamily: 'Roboto Mono',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
      _textStyleCache[cacheKey] = style;
      return style;
    }
  }

  /// Obtenir un TextTheme Poppins avec gestion d'erreurs
  static TextTheme poppinsTextTheme(TextTheme base) {
    try {
      return GoogleFonts.poppinsTextTheme(base);
    } catch (e) {
      // Fallback sur le TextTheme de base
      return base;
    }
  }
}
