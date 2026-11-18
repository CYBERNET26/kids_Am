enum TutorEventType {
  mathCorrect,
  mathIncorrect,
  chessCorrect,
  chessIncorrect,
  puzzleCorrect,
  puzzleIncorrect,
  storyCorrect,
  storyIncorrect,
}

enum TutorSource {
  classicStatic, // Modo Clásico Offline
  intelligentAi, // Modo Tutor Inteligente IA
}

class TutorContext {
  final String childName;
  final int childAge;
  final TutorEventType eventType;
  final String gameName;
  final String topicOrOperation; // Ej: "35 + 12", "Torre en ajedrez", "Figura de Estrella"
  final String? childMistake;    // Ej: "Contó 46 en vez de 47"
  final String? pedagogicalHint; // Ej: "Suma primero las decenas y luego las unidades"

  const TutorContext({
    required this.childName,
    this.childAge = 6,
    required this.eventType,
    required this.gameName,
    required this.topicOrOperation,
    this.childMistake,
    this.pedagogicalHint,
  });

  bool get isSuccess =>
      eventType == TutorEventType.mathCorrect ||
      eventType == TutorEventType.chessCorrect ||
      eventType == TutorEventType.puzzleCorrect ||
      eventType == TutorEventType.storyCorrect;
}

class TutorFeedback {
  final String speechText;
  final TutorSource source;
  final String? debugReason;

  const TutorFeedback({
    required this.speechText,
    required this.source,
    this.debugReason,
  });
}
