import 'dart:math';
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
      // Habilitar espera de finalización para sincronizar perfectamente
      await _flutterTts.awaitSpeakCompletion(true);
      
      // Idioma en español natural
      await _flutterTts.setLanguage('es-ES');

      // Tono 1.0 es el tono humano natural estándar (cálido, agradable, sin efecto robótico ni agudo chillón)
      await _flutterTts.setPitch(1.0);

      // Velocidad 0.48 es un ritmo de conversación sereno, claro y paciente para niños
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);

      // Buscar si existe una voz natural en español disponible en el motor TTS del dispositivo
      final List<dynamic>? voices = await _flutterTts.getVoices;
      if (voices != null) {
        for (final v in voices) {
          if (v is Map) {
            final locale = (v['locale'] ?? '').toString().toLowerCase();
            final name = (v['name'] ?? '').toString().toLowerCase();
            // Priorizar voces en español naturales y suaves
            if (locale.startsWith('es') &&
                (name.contains('female') ||
                 name.contains('natural') ||
                 name.contains('network') ||
                 name.contains('neural'))) {
              await _flutterTts.setVoice({'name': v['name'], 'locale': v['locale']});
              break;
            }
          }
        }
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error inicializando Flutter TTS: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!isEnabled || text.trim().isEmpty) return;
    try {
      if (!_isInitialized) {
        await init();
      }
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error en speak: $e');
    }
  }

  /// Habla y espera hasta que la maestra TERMINE completamente de hablar
  /// Incluye un tiempo de seguridad basado en la cantidad de palabras
  Future<void> speakAndWait(String text) async {
    if (!isEnabled || text.trim().isEmpty) {
      // Si la voz está deshabilitada, igual dar un pequeño tiempo para leer el texto
      await Future.delayed(const Duration(milliseconds: 1500));
      return;
    }
    try {
      if (!_isInitialized) {
        await init();
      }
      await _flutterTts.stop();

      // Calcular duración mínima estimada para que NUNCA se corte la frase
      // A velocidad 0.48, cada palabra en español dura aprox ~380ms + 800ms de pausas y puntuación
      final wordCount = text.split(RegExp(r'\s+')).length;
      final estimatedMillis = max(2200, (wordCount * 380) + 900);

      // Ejecutar el TTS y esperar la promesa de finalización nativa en paralelo con el tiempo estimado
      await Future.wait([
        _flutterTts.speak(text),
        Future.delayed(Duration(milliseconds: estimatedMillis)),
      ]);
    } catch (e) {
      debugPrint('Error en speakAndWait: $e');
      await Future.delayed(const Duration(milliseconds: 2000));
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
