import 'dart:async';
import 'package:kids_am/core/services/teacher_voice_service.dart';
import 'package:kids_am/features/tutor/data/services/gemini_ai_tutor_service.dart';
import 'package:kids_am/features/tutor/data/services/static_local_tutor_service.dart';
import 'package:kids_am/features/tutor/domain/models/tutor_context.dart';

class HybridTutorCoordinator {
  final StaticLocalTutorService _staticService = StaticLocalTutorService();
  final bool isAiEnabled;
  final String apiKey;

  HybridTutorCoordinator({
    required this.isAiEnabled,
    required this.apiKey,
  });

  /// Genera la respuesta del tutor e inmediatamente la reproduce en voz alta
  /// mediante la capa de audio híbrida (TTS al vuelo con fallback local).
  Future<TutorFeedback> speakFeedback(TutorContext context) async {
    final feedback = await getFeedback(context);

    // Capa de Audio Híbrida: síntesis al vuelo con TeacherVoiceService
    try {
      TeacherVoiceService.instance.speak(feedback.speechText);
    } catch (_) {
      // Si por alguna razón falla el TTS del dispositivo, el flujo nunca se bloquea
    }

    return feedback;
  }

  /// Resuelve el feedback pedagógico aplicando la estrategia híbrida:
  /// 1. Si la IA está activa y configurada -> llama a Gemini con timeout estricto de 2.5s.
  /// 2. Si la IA está inactiva, falla, tarda más de 2.5s o no hay red -> fallback inmediato al Modo Clásico.
  Future<TutorFeedback> getFeedback(TutorContext context) async {
    // 1. MODO CLÁSICO DIRECTO (Si el padre desactivó la IA o no hay clave)
    if (!isAiEnabled || apiKey.trim().isEmpty) {
      return await _staticService.generateFeedback(context);
    }

    // 2. MODO TUTOR INTELIGENTE CON CIRCUIT BREAKER Y TIMEOUT ESTRICTO
    try {
      final aiService = GeminiAITutorService(apiKey: apiKey);

      // Timeout estricto de 2.5 segundos para no hacer esperar al niño
      final aiFeedback = await aiService.generateFeedback(context).timeout(
            const Duration(milliseconds: 2500),
          );

      return aiFeedback;
    } on TimeoutException {
      // Si Gemini demora más de 2.5s, fallback silencioso e instantáneo al banco local
      final fallback = await _staticService.generateFeedback(context);
      return TutorFeedback(
        speechText: fallback.speechText,
        source: TutorSource.classicStatic,
        debugReason: 'Fallback por Timeout de IA (> 2.5s)',
      );
    } catch (e) {
      // Si falla la red, la clave o cualquier error HTTP, fallback transparente
      final fallback = await _staticService.generateFeedback(context);
      return TutorFeedback(
        speechText: fallback.speechText,
        source: TutorSource.classicStatic,
        debugReason: 'Fallback por error de red en IA: $e',
      );
    }
  }
}
