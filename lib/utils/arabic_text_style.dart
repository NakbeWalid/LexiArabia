import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArabicTextStyle {
  // Police principale pour le texte arabe (Amiri - très belle pour l'arabe)
  static TextStyle arabicText({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    double height = 1.8, // Hauteur de ligne pour une meilleure lisibilité
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
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
    Color color = Colors.black,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.6,
    );
  }

  // Style pour les options de réponse
  static TextStyle arabicOption({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w500,
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
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w600,
    Color color = Colors.white,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.8,
    );
  }

  // Style pour les petits textes arabes (comme dans les cartes)
  static TextStyle arabicSmall({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black87,
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
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    return GoogleFonts.scheherazadeNew(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.8,
    );
  }

  // Détecte si un texte contient de l'arabe
  static bool isArabicText(String text) {
    return text.contains(RegExp(r'[\u0600-\u06FF]'));
  }

  // Applique automatiquement le bon style selon le contenu
  static TextStyle smartStyle(
    String text, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    if (isArabicText(text)) {
      return arabicText(
        fontSize: fontSize,
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

// Widget helper pour le texte arabe
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
    return Text(
      text,
      style: style ?? ArabicTextStyle.arabicText(),
      textAlign:
          textAlign ??
          (ArabicTextStyle.isArabicText(text)
              ? TextAlign.right
              : TextAlign.left),
      maxLines: maxLines,
      overflow: overflow,
      textDirection: ArabicTextStyle.isArabicText(text)
          ? TextDirection.rtl
          : TextDirection.ltr,
    );
  }
}
