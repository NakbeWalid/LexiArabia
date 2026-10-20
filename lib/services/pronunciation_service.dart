import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Prononciation des mots arabes.
///
/// Ordre de priorité :
/// 1. URL distante (http/https) — ex. audio mot à mot de Quran.com
/// 2. Fichier présent dans `assets/` (ex. `audio/hadha.mp3`)
/// 3. Synthèse vocale arabe de l'appareil (si la langue est disponible)
class PronunciationService {
  static final AudioPlayer _player = AudioPlayer();
  static final FlutterTts _tts = FlutterTts();
  static final Map<String, bool> _assetCache = {};
  static bool? _ttsAvailable;
  static bool _listenersReady = false;

  /// Vrai pendant la lecture (pour animer les boutons audio)
  static final ValueNotifier<bool> isPlaying = ValueNotifier(false);

  static final RegExp _arabicChars = RegExp(r'[؀-ۿݐ-ݿ]');

  /// Jouer la prononciation. Retourne false si aucune source n'est disponible.
  static Future<bool> speak({String? audioUrl, String? text}) async {
    _setupListeners();
    await stop();

    final url = audioUrl?.trim();
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        if (await _play(UrlSource(url))) return true;
      } else {
        final asset = url.startsWith('assets/') ? url.substring(7) : url;
        if (await _assetExists(asset) && await _play(AssetSource(asset))) {
          return true;
        }
      }
    }

    final arabic = _extractArabic(text);
    if (arabic == null) return false;
    return _speakWithTts(arabic);
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
      if (_ttsAvailable == true) await _tts.stop();
    } catch (_) {}
    isPlaying.value = false;
  }

  static void _setupListeners() {
    if (_listenersReady) return;
    _listenersReady = true;
    _player.onPlayerComplete.listen((_) => isPlaying.value = false);
    _tts.setCompletionHandler(() => isPlaying.value = false);
    _tts.setCancelHandler(() => isPlaying.value = false);
    _tts.setErrorHandler((_) => isPlaying.value = false);
  }

  static Future<bool> _play(Source source) async {
    try {
      isPlaying.value = true;
      await _player.play(source);
      return true;
    } catch (e) {
      print('⚠️ Lecture audio impossible: $e');
      isPlaying.value = false;
      return false;
    }
  }

  static Future<bool> _assetExists(String asset) async {
    final cached = _assetCache[asset];
    if (cached != null) return cached;
    bool exists;
    try {
      await rootBundle.load('assets/$asset');
      exists = true;
    } catch (_) {
      exists = false;
    }
    _assetCache[asset] = exists;
    return exists;
  }

  /// Garde uniquement la partie arabe ("اللَّهُ خَلَقَهُمَا (الله خلقهما)" → "اللَّهُ خَلَقَهُمَا")
  static String? _extractArabic(String? text) {
    if (text == null || !_arabicChars.hasMatch(text)) return null;
    final beforeParenthesis = text.split('(').first.trim();
    final candidate = _arabicChars.hasMatch(beforeParenthesis)
        ? beforeParenthesis
        : text;
    return candidate.trim().isEmpty ? null : candidate.trim();
  }

  static Future<bool> _speakWithTts(String text) async {
    try {
      if (_ttsAvailable == null) {
        final available = await _tts.isLanguageAvailable('ar');
        // Certaines plateformes ne répondent pas : on tente quand même
        _ttsAvailable = available != false;
        if (_ttsAvailable!) {
          await _tts.setLanguage('ar');
          await _tts.setSpeechRate(0.4);
        }
      }
      if (_ttsAvailable != true) return false;

      isPlaying.value = true;
      final result = await _tts.speak(text);
      if (result != 1) isPlaying.value = false;
      return result == 1;
    } catch (e) {
      print('⚠️ Synthèse vocale indisponible: $e');
      _ttsAvailable = false;
      isPlaying.value = false;
      return false;
    }
  }
}
