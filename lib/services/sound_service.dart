import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer l'état du son dans l'application
class SoundService {
  static const String _soundEnabledKey = 'sound_enabled';
  static bool? _cachedValue;
  static final AudioPlayer _effectsPlayer = AudioPlayer();

  /// Jouer le son de bonne / mauvaise réponse (si le son est activé)
  static Future<void> playFeedback(bool correct) async {
    if (!await isSoundEnabled()) return;
    try {
      await _effectsPlayer.stop();
      await _effectsPlayer.play(
        AssetSource(correct ? 'sounds/success.mp3' : 'sounds/wrong.mp3'),
      );
    } catch (e) {
      print('Audio error: $e');
    }
  }

  /// Vérifier si le son est activé
  static Future<bool> isSoundEnabled() async {
    if (_cachedValue != null) {
      return _cachedValue!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedValue =
          prefs.getBool(_soundEnabledKey) ?? true; // Par défaut activé
      return _cachedValue!;
    } catch (e) {
      print('❌ Erreur lors de la lecture de l\'état du son: $e');
      return true; // Par défaut activé en cas d'erreur
    }
  }

  /// Activer ou désactiver le son
  static Future<void> setSoundEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundEnabledKey, enabled);
      _cachedValue = enabled;
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde de l\'état du son: $e');
    }
  }

  /// Basculer l'état du son
  static Future<bool> toggleSound() async {
    final currentState = await isSoundEnabled();
    await setSoundEnabled(!currentState);
    return !currentState;
  }

  /// Réinitialiser le cache (utile après changement)
  static void clearCache() {
    _cachedValue = null;
  }
}
