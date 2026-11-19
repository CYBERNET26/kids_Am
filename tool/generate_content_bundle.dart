import 'dart:convert';
import 'dart:io';
import 'package:kids_am/core/constants/default_videos.dart';
import 'package:kids_am/features/stories/data/default_stories.dart';

void main() {
  final bundle = {
    'bundleVersion': 1,
    'updatedAt': '2026-11-19',
    'releaseNotes': 'Paquete inicial de contenido educativo: cuentos interactivos completos, biblioteca de videos seguros y configuración pedagógica adaptativa.',
    'stories': defaultStories.map((s) => s.toJson()).toList(),
    'videos': defaultEducationalVideos.map((v) => v.toJson()).toList(),
    'mathSettings': {
      'level1MaxNumber': 100,
      'levelCount': 10,
      'wordSpellingStartLevel': 7,
      'facilitatedModeMaxAttempts': 2,
    },
    'tutorConfig': {
      'sofiaTone': 'didactica, cariñosa, motivadora',
      'fallbackLanguage': 'es',
    }
  };

  final jsonStr = const JsonEncoder.withIndent('  ').convert(bundle);
  File('content_bundle.json').writeAsStringSync(jsonStr);
  // ignore: avoid_print
  print('content_bundle.json generated successfully. Size: ${jsonStr.length} bytes.');
}
