import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArabicTextStyle {
  // Police principale pour le texte arabe (Amiri - très belle pour l'arabe)
  static TextStyle arabicText({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white,
    double height = 1.9, // Hauteur de ligne pour une meilleure lisibilité des harakat
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // Style pour les titres arabes
  static TextStyle arabicTitle({
    double fontSize = 26,
    FontWeight fontWeight = FontWeight.bold,
    Color color = Colors.white,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.8,
    );
  }

  // Style pour les options de réponse
  static TextStyle arabicOption({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w600,
    Color color = Colors.white,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.7,
    );
  }

  // Style pour les questions avec texte arabe
  static TextStyle arabicQuestion({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
    Color color = Colors.white,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.9,
    );
  }

  // Style pour les petits textes arabes (comme dans les cartes)
  static TextStyle arabicSmall({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white70,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.6,
    );
  }

  // Style alternatif avec Scheherazade (aussi très belle pour l'arabe)
  static TextStyle arabicScheherazade({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white,
  }) {
    return GoogleFonts.scheherazadeNew(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.9,
    );
  }

  // Regex complet pour tous les blocs de caractères arabes et signes diacritiques
  static final RegExp _arabicRegex = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  );

  // Détecte si un texte contient de l'arabe
  static bool isArabicText(String text) {
    return _arabicRegex.hasMatch(text);
  }

  // Détecte si un texte contient des lettres latines
  static bool hasLatinText(String text) {
    return RegExp(r'[a-zA-Z]').hasMatch(text);
  }

  // Supprime les harakat / tashkeel (diacritiques) pour la comparaison souple
  static String stripHarakat(String text) {
    return text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
  }

  // Applique automatiquement le bon style selon le contenu
  static TextStyle smartStyle(
    String text, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white,
  }) {
    if (isArabicText(text)) {
      return arabicText(
        fontSize: fontSize > 16 ? fontSize : fontSize + 3,
        fontWeight: fontWeight,
        color: color,
      );
    } else {
      return GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }
  }
}

// Widget helper pour le texte arabe avec TextDirection automatique
class ArabicText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ArabicText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = ArabicTextStyle.isArabicText(text);

    return Text(
      text,
      style: style ?? (isArabic ? ArabicTextStyle.arabicText() : GoogleFonts.poppins()),
      textAlign: textAlign ?? (isArabic ? TextAlign.center : TextAlign.left),
      maxLines: maxLines,
      overflow: overflow,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    );
  }
}
