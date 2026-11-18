import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:kids_am/features/tutor/domain/models/tutor_context.dart';
import 'package:kids_am/features/tutor/domain/services/tutor_service_interface.dart';

class ApiKeyValidationResult {
  final bool isValid;
  final String message;
  final int? statusCode;

  const ApiKeyValidationResult({
    required this.isValid,
    required this.message,
    this.statusCode,
  });
}

class GeminiAITutorService implements ITutorService {
  final String apiKey;

  const GeminiAITutorService({required this.apiKey});

  /// Sanitiza la clave eliminando comillas simples/dobles, espacios y caracteres invisibles
  static String cleanKey(String raw) {
    return raw
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('`', '')
        .replaceAll(RegExp(r'\s+'), '')
        .trim();
  }

  @override
  Future<bool> isAvailable() async {
    return cleanKey(apiKey).isNotEmpty;
  }

  /// Valida la API Key contra la API oficial de Google AI Studio con diagnóstico detallado
  static Future<ApiKeyValidationResult> validateApiKey(String rawKey) async {
    final key = cleanKey(rawKey);
    if (key.isEmpty) {
      return const ApiKeyValidationResult(
        isValid: false,
        message: 'Por favor escribe o pega tu clave de Gemini.',
      );
    }

    if (!key.startsWith('AIza')) {
      return const ApiKeyValidationResult(
        isValid: false,
        message: 'La clave de Gemini suele empezar con "AIzaSy...". Revisa que esté copiada completa.',
      );
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);

    try {
      // 1. Probar GET a la lista de modelos en v1beta (consulta ligera sin costo de tokens)
      final urlV1Beta = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$key',
      );
      final reqBeta = await client.getUrl(urlV1Beta);
      final respBeta = await reqBeta.close();

      if (respBeta.statusCode == 200) {
        return const ApiKeyValidationResult(
          isValid: true,
          message: '¡Conexión exitosa con Google Gemini! Clave verificada y activa.',
          statusCode: 200,
        );
      }

      // Si no fue 200, leer respuesta de error de Google
      final body = await respBeta.transform(utf8.decoder).join();
      String? googleMessage;
      try {
        final errMap = jsonDecode(body) as Map<String, dynamic>;
        googleMessage = errMap['error']?['message'] as String?;
      } catch (_) {}

      // 2. Si falló v1beta, probar con v1
      final urlV1 = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models?key=$key',
      );
      final reqV1 = await client.getUrl(urlV1);
      final respV1 = await reqV1.close();

      if (respV1.statusCode == 200) {
        return const ApiKeyValidationResult(
          isValid: true,
          message: '¡Conexión exitosa con Google Gemini (v1)! Clave verificada.',
          statusCode: 200,
        );
      }

      if (respBeta.statusCode == 400 || respV1.statusCode == 400) {
        return ApiKeyValidationResult(
          isValid: false,
          statusCode: 400,
          message: googleMessage ??
              'Clave no válida en Google AI Studio. Asegúrate de haberla copiado completa desde aistudio.google.com.',
        );
      } else if (respBeta.statusCode == 403 || respV1.statusCode == 403) {
        return ApiKeyValidationResult(
          isValid: false,
          statusCode: 403,
          message: 'Permiso denegado por Google: la API Generative Language está restringida en tu cuenta.',
        );
      } else if (respBeta.statusCode == 429 || respV1.statusCode == 429) {
        return const ApiKeyValidationResult(
          isValid: true, // La clave es válida, sólo alcanzó el límite de tasa
          statusCode: 429,
          message: 'Clave válida, pero se alcanzó la cuota de Google temporalmente. Se guardó con éxito.',
        );
      }

      return ApiKeyValidationResult(
        isValid: false,
        statusCode: respBeta.statusCode,
        message: googleMessage ?? 'Google devolvió error ${respBeta.statusCode}. Revisa tu clave.',
      );
    } on SocketException {
      return const ApiKeyValidationResult(
        isValid: false,
        message: 'No se pudo conectar a Google. Comprueba tu conexión a Internet o WiFi.',
      );
    } on TimeoutException {
      return const ApiKeyValidationResult(
        isValid: false,
        message: 'Tiempo de espera agotado al conectar con Google. Revisa tu conexión de red.',
      );
    } catch (e) {
      return ApiKeyValidationResult(
        isValid: false,
        message: 'Error al verificar clave: $e',
      );
    } finally {
      client.close();
    }
  }

  /// Método de compatibilidad booleano
  static Future<bool> testApiKey(String key) async {
    final result = await validateApiKey(key);
    return result.isValid;
  }

  @override
  Future<TutorFeedback> generateFeedback(TutorContext context) async {
    final clean = cleanKey(apiKey);
    if (clean.isEmpty) {
      throw Exception('API Key no configurada');
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 4);

    try {
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

      // Intentar primero con gemini-1.5-flash y luego gemini-2.0-flash si hiciera falta
      final models = ['gemini-1.5-flash', 'gemini-2.0-flash', 'gemini-1.5-flash-8b'];

      for (final model in models) {
        try {
          final url = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$clean',
          );
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
        } catch (_) {
          continue;
        }
      }

      throw Exception('No se pudo obtener respuesta de los modelos de Gemini');
    } finally {
      client.close();
    }
  }
}
