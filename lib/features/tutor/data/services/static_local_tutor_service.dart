import 'dart:math';
import 'package:kids_am/features/tutor/domain/models/tutor_context.dart';
import 'package:kids_am/features/tutor/domain/services/tutor_service_interface.dart';

class StaticLocalTutorService implements ITutorService {
  final Random _random = Random();

  // Bancos locales pregrabados y fijos para niños de 6 años
  final List<String> _mathSuccess = [
    '¡Maravilloso {name}! ¡Hiciste la cuenta con gran maestría!',
    '¡Qué mente matemática tan brillante tienes, {name}!',
    '¡Excelente cálculo! Sigue sumando aprendizajes.',
    '¡Sensacional! Tus neuronas están súper despiertas hoy.',
  ];

  final List<String> _mathError = [
    '¡Casi casi {name}! Imagina que guardas las decenas en un bolsillo y cuentas las unidades sueltas.',
    '¡Buen intento! Junta primero los números más grandes y luego agrega los pequeños.',
    '¡No te preocupes {name}! Cuenta despacito paso a paso, tú puedes lograrlo.',
    '¡Ánimo! Quita mentalmente los objetos que sobran y verás cuántos quedan.',
  ];

  final List<String> _chessSuccess = [
    '¡Jugada de gran maestro {name}! Tu pieza se movió con inteligencia.',
    '¡Excelente estrategia! Dominas el tablero como un verdadero campeón.',
    '¡Bravo! Cada casilla te acerca a la victoria.',
  ];

  final List<String> _chessError = [
    '¡Cerca! Recuerda el camino especial de cada pieza. ¡Mira las casillas sugeridas!',
    '¡Ánimo {name}! Las piezas son como amigos que se cuidan entre sí en el tablero.',
    '¡Buen intento! Busca un camino libre donde no haya rocas que bloqueen tu paso.',
  ];

  final List<String> _puzzleSuccess = [
    '¡Encastre perfecto {name}! Todas las piezas coinciden como por arte de magia.',
    '¡Gran ojo de detective! Las figuras encajan perfectamente.',
    '¡Lo lograste {name}! El rompecabezas está completo y hermoso.',
  ];

  final List<String> _puzzleError = [
    '¡Casi! Esa figura tiene otra forma. Mira bien los bordes de la madera para encontrar su silueta.',
    '¡Atención a las puntitas {name}! Busca el hueco que tenga exactamente la misma forma.',
    '¡Intenta con otra ranura! Cada figura tiene su hogar exacto en el tablero.',
  ];

  final List<String> _storySuccess = [
    '¡Excelente comprensión {name}! Escuchaste el cuento con muchísima atención.',
    '¡Brillante respuesta! Se nota que te encantó la historia.',
    '¡Felicitaciones! Ganaste estrellas por prestar tanta atención.',
  ];

  final List<String> _storyError = [
    '¡Casi! Recuerda lo que pasó en el cuento cuando los personajes se ayudaron.',
    '¡Buen intento {name}! Vuelve a recordar la parte final de la historia.',
  ];

  @override
  Future<bool> isAvailable() async {
    // El modo clásico estático siempre está disponible (100% offline)
    return true;
  }

  @override
  Future<TutorFeedback> generateFeedback(TutorContext context) async {
    List<String> bank;

    switch (context.eventType) {
      case TutorEventType.mathCorrect:
        bank = _mathSuccess;
        break;
      case TutorEventType.mathIncorrect:
        bank = _mathError;
        break;
      case TutorEventType.chessCorrect:
        bank = _chessSuccess;
        break;
      case TutorEventType.chessIncorrect:
        bank = _chessError;
        break;
      case TutorEventType.puzzleCorrect:
        bank = _puzzleSuccess;
        break;
      case TutorEventType.puzzleIncorrect:
        bank = _puzzleError;
        break;
      case TutorEventType.storyCorrect:
        bank = _storySuccess;
        break;
      case TutorEventType.storyIncorrect:
        bank = _storyError;
        break;
    }

    final template = bank[_random.nextInt(bank.length)];
    String speech = template.replaceAll('{name}', context.childName);

    // Si hay una pista pedagógica específica provista por el juego, la anexamos
    if (!context.isSuccess && context.pedagogicalHint != null && context.pedagogicalHint!.isNotEmpty) {
      speech = '$speech ${context.pedagogicalHint}';
    }

    return TutorFeedback(
      speechText: speech,
      source: TutorSource.classicStatic,
    );
  }
}
