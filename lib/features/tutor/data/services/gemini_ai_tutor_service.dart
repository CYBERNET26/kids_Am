import 'dart:convert';
import 'dart:io';
import 'package:kids_am/features/tutor/domain/models/tutor_context.dart';
import 'package:kids_am/features/tutor/domain/services/tutor_service_interface.dart';

class GeminiAITutorService implements ITutorService {
  final String apiKey;

  const GeminiAITutorService({required this.apiKey});

  @override
  Future<bool> isAvailable() async {
    return apiKey.trim().isNotEmpty;
  }

  /// Prueba la validez de la API Key conectándose con un prompt mínimo de prueba
  static Future<bool> testApiKey(String key) async {
    if (key.trim().isEmpty) return false;
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 4);

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${key.trim()}',
      );
      final request = await client.postUrl(url);
      request.headers.set('Content-Type', 'application/json');

      final requestBody = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "Di 'OK'"}
            ]
          }
        ],
        "generationConfig": {"maxOutputTokens": 5}
      });

      request.write(requestBody);
      final response = await request.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    } finally {
      client.close();
    }
  }

  @override
  Future<TutorFeedback> generateFeedback(TutorContext context) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('API Key no configurada');
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey.trim()}',
      );

      final systemPrompt = '''
Eres la "Seño Sofía", una maestra de educación infantil muy dulce, entusiasta y paciente para niños de 6 años.
REGLAS ESTRICTAS DE SEGURIDAD PEDAGÓGICA:
1. TIENES PROHIBIDO revelar la respuesta correcta o resolver el ejercicio por el niño.
2. Si el niño acertó: Da una felicitación alegre, fresca y breve (máximo 1 o 2 oraciones cortas). Menciona su nombre: "${context.childName}".
3. Si el niño se equivocó: Explica el concepto con una metáfora tierna y sencilla para un niño de 6 años (máximo 2 oraciones cortas). Anímalo a seguir intentando sin frustrarse.
4. Responde ÚNICAMENTE con el texto que la maestra va a hablar en voz alta. Cero comillas, cero asteriscos, cero explicaciones previas.
''';

      final userPrompt = context.isSuccess
          ? 'El niño ${context.childName} (6 años) acertó en ${context.gameName}: ${context.topicOrOperation}. Felicítalo cariñosamente.'
          : 'El niño ${context.childName} (6 años) se equivocó en ${context.gameName}: ${context.topicOrOperation}. ${context.childMistake != null ? "Intentó: ${context.childMistake}." : ""} ${context.pedagogicalHint != null ? "Pista conceptual: ${context.pedagogicalHint}." : ""} Explícale con una metáfora simple para 6 años sin darle la solución.';

      final payload = jsonEncode({
        "systemInstruction": {
          "parts": [
            {"text": systemPrompt}
          ]
        },
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": userPrompt}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "maxOutputTokens": 100,
        }
      });

      final request = await client.postUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.write(payload);

      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        final candidates = jsonResponse['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final rawText = (parts[0]['text'] as String?)?.trim() ?? '';
            // Limpieza de caracteres de markdown que no suenan bien en TTS
            final cleanText = rawText.replaceAll('*', '').replaceAll('"', '').trim();
            if (cleanText.isNotEmpty) {
              return TutorFeedback(
                speechText: cleanText,
                source: TutorSource.intelligentAi,
              );
            }
          }
        }
      }

      throw Exception('Respuesta no válida de Gemini (Código: ${response.statusCode})');
    } finally {
      client.close();
    }
  }
}
