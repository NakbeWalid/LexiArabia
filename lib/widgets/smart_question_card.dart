import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A smart widget that cleanly separates and formats questions containing
/// mixed languages (English/French instructions + Arabic sentences/verses + translations).
class SmartQuestionCard extends StatelessWidget {
  final String question;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const SmartQuestionCard({
    super.key,
    required this.question,
    this.margin = const EdgeInsets.symmetric(horizontal: 20),
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  });

  @override
  Widget build(BuildContext context) {
    final parsed = _parseQuestion(question);

    return Container(
      margin: margin,
      padding: padding,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _buildContent(context, parsed),
    );
  }

  Widget _buildContent(BuildContext context, _ParsedQuestion parsed) {
    if (parsed.isPureArabic) {
      // Pure Arabic text
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          parsed.arabicText ?? parsed.raw,
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.9,
          ),
        ),
      );
    }

    if (parsed.isPureLatin) {
      // Pure Latin text
      return Text(
        parsed.raw,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.5,
        ),
      );
    }

    if (parsed.isInlineMixed) {
      // Inline mixed sentence (e.g., "What does 'كُمَا' mean?" or "كُمَا can refer to...")
      return _buildInlineMixedText(parsed.raw);
    }

    // Structured mixed: Instruction + Arabic prompt [+ Translation]
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (parsed.instruction != null && parsed.instruction!.isNotEmpty) ...[
          Text(
            parsed.instruction!,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            width: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (parsed.arabicText != null && parsed.arabicText!.isNotEmpty)
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              parsed.arabicText!,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.9,
              ),
            ),
          ),
        if (parsed.translation != null && parsed.translation!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            "(${parsed.translation!})",
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInlineMixedText(String text) {
    final List<InlineSpan> spans = [];
    final pattern = RegExp(r'([\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]+)');
    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: GoogleFonts.amiri(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFD54F),
          ),
        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text.rich(
        TextSpan(children: spans),
        textAlign: TextAlign.center,
      ),
    );
  }

  static String _normalizeArabicWithBlank(String text, String? translation) {
    if (translation == null || !translation.contains(RegExp(r'_{2,}'))) {
      return text;
    }

    final trimmedTranslation = translation.trim();
    final trimmedText = text.trim();

    // If the translation starts with a blank (e.g. "____ is a distant mountain", "____ is my house")
    if (trimmedTranslation.startsWith(RegExp(r'_{2,}|\.{2,}|\-+|\((\s*_{2,}\s*)\)'))) {
      if (RegExp(r'_{2,}|\.{2,}|\-+$').hasMatch(trimmedText) && !trimmedText.startsWith(RegExp(r'_{2,}|\.{2,}|\-+'))) {
        final cleaned = trimmedText.replaceAll(RegExp(r'_{2,}|\.{2,}|\-+'), '').trim();
        return '____ $cleaned';
      }
    }

    // If the translation ends with a blank (e.g. "This is a ____")
    if (RegExp(r'_{2,}|\.{2,}|\-+$').hasMatch(trimmedTranslation)) {
      if (trimmedText.startsWith(RegExp(r'_{2,}|\.{2,}|\-+')) && !RegExp(r'_{2,}|\.{2,}|\-+$').hasMatch(trimmedText)) {
        final cleaned = trimmedText.replaceAll(RegExp(r'_{2,}|\.{2,}|\-+'), '').trim();
        return '$cleaned ____';
      }
    }

    return text;
  }

  static _ParsedQuestion _parseQuestion(String question) {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return _ParsedQuestion(raw: '');

    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(trimmed);
    final hasLatin = RegExp(r'[a-zA-Z]').hasMatch(trimmed);

    if (!hasArabic) {
      return _ParsedQuestion(raw: trimmed, isPureLatin: true);
    }

    if (!hasLatin) {
      return _ParsedQuestion(raw: trimmed, arabicText: trimmed, isPureArabic: true);
    }

    // 1. Colon pattern: "Instruction: Arabic (Translation)"
    if (trimmed.contains(':')) {
      final colonIndex = trimmed.indexOf(':');
      final instruction = trimmed.substring(0, colonIndex).trim();
      var remainder = trimmed.substring(colonIndex + 1).trim();

      String? translation;
      final parenMatch = RegExp(r'\(([^)]+)\)$').firstMatch(remainder);
      if (parenMatch != null) {
        final inside = parenMatch.group(1)?.trim() ?? '';
        if (RegExp(r'[a-zA-Z]').hasMatch(inside)) {
          translation = inside;
          remainder = remainder.substring(0, parenMatch.start).trim();
        }
      }

      return _ParsedQuestion(
        raw: trimmed,
        instruction: instruction,
        arabicText: _normalizeArabicWithBlank(remainder, translation),
        translation: translation,
      );
    }

    // 2. Trailing translation pattern: "Instruction Arabic (Translation)" or "Arabic (Translation)"
    final parenMatch = RegExp(r'\(([^)]+)\)$').firstMatch(trimmed);
    if (parenMatch != null) {
      final translation = parenMatch.group(1)?.trim();
      final before = trimmed.substring(0, parenMatch.start).trim();
      final firstArabic = before.indexOf(RegExp(r'[\u0600-\u06FF]'));
      if (firstArabic > 0) {
        // If there is Latin text preceding Arabic, that's the instruction
        final hasLatinBefore = RegExp(r'[a-zA-Z]').hasMatch(before.substring(0, firstArabic));
        if (hasLatinBefore) {
          return _ParsedQuestion(
            raw: trimmed,
            instruction: before.substring(0, firstArabic).trim(),
            arabicText: _normalizeArabicWithBlank(before.substring(firstArabic).trim(), translation),
            translation: translation,
          );
        } else {
          return _ParsedQuestion(
            raw: trimmed,
            arabicText: _normalizeArabicWithBlank(before, translation),
            translation: translation,
          );
        }
      } else if (firstArabic == 0) {
        return _ParsedQuestion(
          raw: trimmed,
          arabicText: _normalizeArabicWithBlank(before, translation),
          translation: translation,
        );
      }
    }

    // 3. Inline mixed (mostly English with short Arabic terms, e.g. "What does 'كُمَا' mean?")
    final arabicMatches = RegExp(r'[\u0600-\u06FF]+').allMatches(trimmed);
    final latinMatches = RegExp(r'[a-zA-Z]+').allMatches(trimmed);
    if (latinMatches.length > arabicMatches.length && latinMatches.length >= 3) {
      return _ParsedQuestion(raw: trimmed, isInlineMixed: true);
    }

    // 4. Default split at first Arabic char
    final firstArabic = trimmed.indexOf(RegExp(r'[\u0600-\u06FF]'));
    if (firstArabic > 0) {
      return _ParsedQuestion(
        raw: trimmed,
        instruction: trimmed.substring(0, firstArabic).trim(),
        arabicText: trimmed.substring(firstArabic).trim(),
      );
    }

    return _ParsedQuestion(raw: trimmed, arabicText: trimmed);
  }
}

class _ParsedQuestion {
  final String raw;
  final String? instruction;
  final String? arabicText;
  final String? translation;
  final bool isPureLatin;
  final bool isPureArabic;
  final bool isInlineMixed;

  _ParsedQuestion({
    required this.raw,
    this.instruction,
    this.arabicText,
    this.translation,
    this.isPureLatin = false,
    this.isPureArabic = false,
    this.isInlineMixed = false,
  });
}
