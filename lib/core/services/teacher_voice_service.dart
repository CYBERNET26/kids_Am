import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TeacherVoiceService {
  static final TeacherVoiceService instance = TeacherVoiceService._internal();
  factory TeacherVoiceService() => instance;
  TeacherVoiceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool isEnabled = true;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('es-ES');
      // Tono ligeramente agudo y cálido característico de maestra infantil
      await _flutterTts.setPitch(1.3);
      // Velocidad pausada y clara para que los niños comprendan
      await _flutterTts.setSpeechRate(0.46);
      await _flutterTts.setVolume(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error inicializando Flutter TTS: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!isEnabled) return;
    try {
      if (!_isInitialized) {
        await init();
      }
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error reproduciendo voz de maestra: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
