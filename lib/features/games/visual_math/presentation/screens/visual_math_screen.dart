import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/core/services/teacher_voice_service.dart';
import 'package:kids_am/core/widgets/playful_background.dart';
import 'package:kids_am/core/widgets/teacher_bubble_widget.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/games/domain/models/game_level.dart';
import 'package:kids_am/features/parent_zone/domain/models/custom_exercise.dart';
import 'package:kids_am/features/parent_zone/presentation/providers/custom_exercises_provider.dart';
import 'package:kids_am/features/games/visual_math/presentation/widgets/math_preamble_dialog.dart';
import 'package:kids_am/features/tutor/domain/models/tutor_context.dart';
import 'package:kids_am/features/tutor/presentation/providers/tutor_provider.dart';
import 'package:kids_am/features/games/visual_math/domain/number_words_helper.dart';

enum MathStep {
  number, // Ingreso numérico con el teclado numérico
  word,   // Escritura del nombre del número (activo si mathLevel > 7)
}

class VisualMathScreen extends ConsumerStatefulWidget {
  const VisualMathScreen({super.key});

  @override
  ConsumerState<VisualMathScreen> createState() => _VisualMathScreenState();
}

class _VisualMathScreenState extends ConsumerState<VisualMathScreen> {
  static const int totalMathExercises = 100;
  late ConfettiController _confettiController;
  int _exerciseNumber = 1;
  bool _hasGreetedThisVisit = false;

  late MathOperation _currentOperation;
  late int _firstGroup;
  late int _secondGroup;
  late int _correctResult;

  // Estado de ingreso y progresión de respuestas
  MathStep _currentStep = MathStep.number;
  String _enteredDigits = '';
  final TextEditingController _wordController = TextEditingController();
  int _exerciseMistakes = 0;
  bool _isFacilitated = false;
  bool _earnedStar = true;

  bool? _isCorrect;
  String _teacherSpeech = '';
  bool _isTip = false;
  bool _isAutoAdvancing = false;

  CustomExercise? _activeCustomExercise;

  final List<String> _emojis = ['🍎', '⭐️', '🚗', '🐱', '🚀', '🍓', '🎈', '🐶', '⚽️', '🍦', '🐼', '🍇'];
  late String _currentEmoji;

  final List<String> _variedPromptsAddition = [
    '¡Siguiente suma! Cuenta los objetos de arriba y de abajo para hallar el total.',
    '¡A sumar! ¿Cuántos objetos tenemos si los juntamos todos?',
    '¡Mira esta nueva cuenta! Sumemos con atención.',
    '¡Excelente ritmo! ¿Cuál es el resultado de esta suma?',
    '¡Vamos con otra divertida! Cuenta los objetos y toca la respuesta correcta.',
  ];

  final List<String> _variedPromptsSubtraction = [
    '¡Ahora toca una resta! Teníamos estos objetos y quitamos algunos. ¿Cuántos quedan?',
    '¡Aventura de restar! Haz la resta y encuentra el resultado correcto.',
    '¡Mira bien! Si quitamos los de abajo, ¿cuántos nos sobran?',
    '¡A calcular la resta! ¿Qué número queda?',
    '¡Vamos muy bien! Cuenta los que quedan y toca el botón.',
  ];

  final List<String> _variedPromptsMultiplication = [
    '¡Aventura de multiplicación! Recuerda: sumamos grupos iguales súper rápido.',
    '¡Mira los grupos iguales! ¿Cuántos objetos hay en total si multiplicamos?',
    '¡Multiplicar es genial! Calcula cuántos objetos hay en estos grupos.',
    '¡Excelente desafío! Multiplica y encuentra el resultado correcto.',
  ];

  final List<String> _variedPromptsDivision = [
    '¡Desafío de división! Repartimos en partes iguales entre amigos.',
    '¡A repartir! Si dividimos todos estos caramelos, ¿cuántos le tocan a cada uno?',
    '¡Mundo de la división! Reparte en partes iguales y elige el resultado.',
    '¡Calcula la división! ¿Cuánto le toca exactamente a cada amigo?',
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadProgressAndStart();
  }

  Future<void> _loadProgressAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('math_exercise_index') ?? 1;
    if (mounted) {
      setState(() {
        _exerciseNumber = savedIndex.clamp(1, totalMathExercises);
      });
      _checkPreambleUnlockAndGenerate();
    }
  }

  Future<void> _checkPreambleUnlockAndGenerate() async {
    final profile = ref.read(childProfileProvider);
    final prefs = await SharedPreferences.getInstance();

    // Comprobar preámbulos automáticos según el nivel
    if (profile.mathLevel >= 6 && !(prefs.getBool('seen_preamble_div') ?? false)) {
      await prefs.setBool('seen_preamble_div', true);
      if (mounted) {
        await MathPreambleDialog.show(context, initialOperation: MathOperation.division);
      }
    } else if (profile.mathLevel >= 3 && !(prefs.getBool('seen_preamble_mult') ?? false)) {
      await prefs.setBool('seen_preamble_mult', true);
      if (mounted) {
        await MathPreambleDialog.show(context, initialOperation: MathOperation.multiplication);
      }
    }

    _generateExercise();
  }

  void _generateExercise({CustomExercise? customExercise}) {
    final profile = ref.read(childProfileProvider);
    final random = Random();
    _currentEmoji = _emojis[random.nextInt(_emojis.length)];
    _isCorrect = null;
    _isTip = false;
    _isAutoAdvancing = false;
    _activeCustomExercise = customExercise;

    // Reinicio pedagógico de intentos y pasos
    _currentStep = MathStep.number;
    _enteredDigits = '';
    _wordController.clear();
    _exerciseMistakes = 0;
    _isFacilitated = false;
    _earnedStar = true;

    if (customExercise != null) {
      _currentOperation = customExercise.operation;
      _firstGroup = customExercise.firstNum;
      _secondGroup = customExercise.secondNum;
      _correctResult = customExercise.correctResult;
      _teacherSpeech = customExercise.note.isNotEmpty
          ? '¡Desafío de Mamá y Papá! ${customExercise.note}. ¿Cuánto es $_firstGroup ${_currentOperation.symbol} $_secondGroup?'
          : '¡Desafío especial de tus papás! ¿Cuál es el resultado de $_firstGroup ${_currentOperation.symbol} $_secondGroup?';
    } else {
      final level = profile.mathLevel;

      // PROGRESIÓN PEDAGÓGICA Y MEZCLADO POR NIVEL:
      // Nivel 1-2: Sumas y Restas intercaladas
      // Nivel 3-5: Sumas, Restas y Multiplicación intercaladas
      // Nivel 6+: Sumas, Restas, Multiplicación y División intercaladas
      if (level < 3) {
        _currentOperation = (_exerciseNumber % 2 != 0)
            ? MathOperation.addition
            : MathOperation.subtraction;
      } else if (level < 6) {
        final mod = _exerciseNumber % 3;
        if (mod == 1) {
          _currentOperation = MathOperation.addition;
        } else if (mod == 2) {
          _currentOperation = MathOperation.subtraction;
        } else {
          _currentOperation = MathOperation.multiplication;
        }
      } else {
        final mod = _exerciseNumber % 4;
        if (mod == 1) {
          _currentOperation = MathOperation.addition;
        } else if (mod == 2) {
          _currentOperation = MathOperation.subtraction;
        } else if (mod == 3) {
          _currentOperation = MathOperation.multiplication;
        } else {
          _currentOperation = MathOperation.division;
        }
      }

      switch (_currentOperation) {
        case MathOperation.addition:
          if (level == 1) {
            if (_exerciseNumber <= 15) {
              _firstGroup = random.nextInt(5) + 1;
              _secondGroup = random.nextInt(5) + 1;
            } else if (_exerciseNumber <= 35) {
              _firstGroup = random.nextInt(10) + 2;
              _secondGroup = random.nextInt(8) + 1;
            } else if (_exerciseNumber <= 55) {
              _firstGroup = (random.nextInt(3) + 1) * 10 + random.nextInt(5);
              _secondGroup = random.nextInt(10) + 1;
            } else if (_exerciseNumber <= 75) {
              _firstGroup = random.nextInt(35) + 15;
              _secondGroup = random.nextInt(20) + 5;
            } else {
              _firstGroup = random.nextInt(45) + 25;
              final maxSecond = 100 - _firstGroup;
              _secondGroup = random.nextInt(maxSecond.clamp(5, 35)) + 5;
            }
          } else if (level == 2) {
            _firstGroup = random.nextInt(60) + 40;
            _secondGroup = random.nextInt(60) + 20;
          } else if (level <= 5) {
            _firstGroup = random.nextInt(80) + 20;
            _secondGroup = random.nextInt(80) + 20;
          } else {
            _firstGroup = random.nextInt(120) + 30;
            _secondGroup = random.nextInt(120) + 30;
          }
          _correctResult = _firstGroup + _secondGroup;
          break;

        case MathOperation.subtraction:
          if (level == 1) {
            if (_exerciseNumber <= 15) {
              _firstGroup = random.nextInt(6) + 4;
              _secondGroup = random.nextInt(_firstGroup - 1) + 1;
            } else if (_exerciseNumber <= 35) {
              _firstGroup = random.nextInt(10) + 10;
              _secondGroup = random.nextInt(8) + 1;
            } else if (_exerciseNumber <= 55) {
              _firstGroup = random.nextInt(20) + 20;
              _secondGroup = random.nextInt(15) + 2;
            } else if (_exerciseNumber <= 75) {
              _firstGroup = random.nextInt(30) + 40;
              _secondGroup = random.nextInt(25) + 5;
            } else {
              _firstGroup = random.nextInt(31) + 70;
              _secondGroup = random.nextInt(40) + 10;
            }
          } else if (level == 2) {
            _firstGroup = random.nextInt(80) + 100;
            _secondGroup = random.nextInt(60) + 20;
          } else if (level <= 5) {
            _firstGroup = random.nextInt(100) + 50;
            _secondGroup = random.nextInt(45) + 10;
          } else {
            _firstGroup = random.nextInt(150) + 50;
            _secondGroup = random.nextInt(80) + 15;
          }
          _correctResult = _firstGroup - _secondGroup;
          break;

        case MathOperation.multiplication:
          if (level == 3) {
            _firstGroup = random.nextInt(3) + 2;
            _secondGroup = random.nextInt(3) + 1;
          } else if (level <= 5) {
            _firstGroup = random.nextInt(5) + 2;
            _secondGroup = random.nextInt(5) + 2;
          } else {
            _firstGroup = random.nextInt(8) + 2;
            _secondGroup = random.nextInt(8) + 2;
          }
          _correctResult = _firstGroup * _secondGroup;
          break;

        case MathOperation.division:
          if (level == 6) {
            _secondGroup = random.nextInt(3) + 2;
            _correctResult = random.nextInt(4) + 2;
          } else {
            _secondGroup = random.nextInt(4) + 2;
            _correctResult = random.nextInt(6) + 2;
          }
          _firstGroup = _secondGroup * _correctResult;
          break;
      }

      // Speech didáctico
      if (!_hasGreetedThisVisit) {
        _hasGreetedThisVisit = true;
        _teacherSpeech =
            '¡Hola ${profile.name}! Bienvenido a Mundo Matemático Nivel $level. Ejercicio $_exerciseNumber de $totalMathExercises.';
      } else {
        switch (_currentOperation) {
          case MathOperation.addition:
            _teacherSpeech = _variedPromptsAddition[random.nextInt(_variedPromptsAddition.length)];
            break;
          case MathOperation.subtraction:
            _teacherSpeech = _variedPromptsSubtraction[random.nextInt(_variedPromptsSubtraction.length)];
            break;
          case MathOperation.multiplication:
            _teacherSpeech = _variedPromptsMultiplication[random.nextInt(_variedPromptsMultiplication.length)];
            break;
          case MathOperation.division:
            _teacherSpeech = _variedPromptsDivision[random.nextInt(_variedPromptsDivision.length)];
            break;
        }
      }
    }

    TeacherVoiceService.instance.speak(_teacherSpeech);
    setState(() {});
  }

  /// Manejo de pulsaciones del teclado numérico en pantalla
  void _onKeypadPress(String key) {
    if (_isCorrect == true || _isAutoAdvancing) return;

    if (key == 'DEL') {
      if (_enteredDigits.isNotEmpty) {
        setState(() {
          _enteredDigits = _enteredDigits.substring(0, _enteredDigits.length - 1);
        });
      }
      return;
    }

    if (key == 'OK') {
      _submitNumberAnswer();
      return;
    }

    // Dígito 0-9
    if (_enteredDigits.length < 3) {
      setState(() {
        if (_enteredDigits == '0') {
          _enteredDigits = key;
        } else {
          _enteredDigits += key;
        }
      });
    }
  }

  /// Validación de la respuesta numérica
  void _submitNumberAnswer() async {
    if (_isCorrect == true || _isAutoAdvancing) return;

    if (_enteredDigits.trim().isEmpty) {
      TeacherVoiceService.instance.speak('Escribe tu respuesta con los botones numéricos y luego toca Listo.');
      return;
    }

    final answer = int.tryParse(_enteredDigits);
    final profile = ref.read(childProfileProvider);

    if (answer == _correctResult) {
      // Si el nivel es mayor a 7, ahora debe escribir el nombre del número en letras
      if (profile.mathLevel > 7) {
        setState(() {
          _currentStep = MathStep.word;
          _isCorrect = null;
          _isTip = false;
          _teacherSpeech =
              '¡Correcto! El número es $_correctResult. Ahora escribe con letras cómo se dice este número:';
        });
        TeacherVoiceService.instance.speak(_teacherSpeech);
        return;
      }

      // Si es nivel <= 7, completa el ejercicio
      _completeExerciseSuccessfully();
    } else {
      // El niño se equivocó
      _exerciseMistakes++;
      _earnedStar = false; // REGLA: no le des la estrella ni por valido los errores

      setState(() {
        _isCorrect = false;
        _isTip = true;
      });

      String hint = '';
      switch (_currentOperation) {
        case MathOperation.addition:
          hint = 'Cuenta primero los de arriba y sigue sumando los de abajo.';
          break;
        case MathOperation.subtraction:
          hint = 'Quita mentalmente los $_secondGroup objetos y cuenta cuántos te quedan.';
          break;
        case MathOperation.multiplication:
          hint = 'Suma cada uno de los grupos iguales.';
          break;
        case MathOperation.division:
          hint = 'Reparte en partes iguales para saber cuánto le toca a cada uno.';
          break;
      }

      if (_exerciseMistakes == 1) {
        // REGLA: "si se equivoca explicalo"
        final tutorState = ref.read(tutorProvider);
        final feedback = await tutorState.coordinator.speakFeedback(
          TutorContext(
            childName: profile.name,
            childAge: 6,
            eventType: TutorEventType.mathIncorrect,
            gameName: 'Mundo Matemático',
            topicOrOperation: '$_firstGroup ${_currentOperation.symbol} $_secondGroup',
            childMistake: 'Escribió $answer en vez de $_correctResult',
            pedagogicalHint: hint,
          ),
        );

        if (mounted) {
          setState(() {
            _teacherSpeech = feedback.speechText;
            _enteredDigits = ''; // Limpiar para que reintente
          });
        }
      } else {
        // REGLA: "si se vuelve a equivocar facilitalo un poco pero no le des la estrella ni por valido los errores"
        setState(() {
          _isFacilitated = true; // Activa ayuda visual numerando los objetos
          _enteredDigits = '';
          _teacherSpeech =
              '¡No te preocupes! Te lo he facilitado mostrando los números arriba de cada uno para que los cuentes directo. ¡Inténtalo de nuevo!';
        });
        TeacherVoiceService.instance.speak(_teacherSpeech);
      }
    }
  }

  /// Validación del nombre del número en letras (Nivel > 7)
  void _submitWordAnswer() async {
    if (_isCorrect == true || _isAutoAdvancing) return;

    final word = _wordController.text.trim();
    if (word.isEmpty) {
      TeacherVoiceService.instance.speak('Escribe cómo se dice el número $_correctResult en letras.');
      return;
    }

    final isWordCorrect = NumberWordsHelper.matches(word, _correctResult);

    if (isWordCorrect) {
      _completeExerciseSuccessfully();
    } else {
      _exerciseMistakes++;
      _earnedStar = false; // REGLA: No estrella por errores

      final correctWord = NumberWordsHelper.toWords(_correctResult);

      setState(() {
        _isCorrect = false;
        _isTip = true;
      });

      if (_exerciseMistakes <= 2) {
        // Explicación
        setState(() {
          _teacherSpeech =
              '¡Casi! El número $_correctResult se escribe "$correctWord". Escucha cómo suena e inténtalo otra vez.';
        });
        TeacherVoiceService.instance.speak(_teacherSpeech);
      } else {
        // Facilitado en palabras
        final hint = correctWord.length > 3 ? correctWord.substring(0, 3) : correctWord.substring(0, 1);
        setState(() {
          _isFacilitated = true;
          _teacherSpeech = '¡Te ayudo! La palabra empieza con "$hint...". ¡Tú puedes completarla!';
        });
        TeacherVoiceService.instance.speak(_teacherSpeech);
      }
    }
  }

  /// Conclusión exitosa del ejercicio
  Future<void> _completeExerciseSuccessfully() async {
    final profile = ref.read(childProfileProvider);
    final isFinalOfLevel = _exerciseNumber >= totalMathExercises;
    final wasCustom = _activeCustomExercise != null;

    setState(() {
      _isCorrect = true;
      _isTip = false;
      _isAutoAdvancing = true;

      if (_earnedStar) {
        _confettiController.play();
        if (wasCustom) {
          _teacherSpeech =
              '¡Bravo ${profile.name}! ¡Resolviste con éxito el desafío especial de mamá y papá! ¡Te ganaste 2 estrellas de premio!';
        } else if (isFinalOfLevel) {
          _teacherSpeech =
              '¡Increíble logro ${profile.name}! ¡Completaste los 100 ejercicios del Nivel ${profile.mathLevel}! ¡Subes al Nivel ${profile.mathLevel + 1} con nuevos aprendizajes!';
        } else {
          _teacherSpeech =
              '¡Maravilloso! $_firstGroup ${_currentOperation.symbol} $_secondGroup es igual a $_correctResult. ¡Ganaste una estrella!';
        }
      } else {
        // Resuelto con ayuda tras errores: mensaje formativo sin estrellas
        _teacherSpeech =
            '¡Muy bien aprendido! Resolviste el ejercicio: $_firstGroup ${_currentOperation.symbol} $_secondGroup = $_correctResult. ¡Sigamos practicando!';
      }
    });

    if (wasCustom) {
      ref.read(customExercisesProvider.notifier).markCompleted(_activeCustomExercise!.id);
      if (_earnedStar) {
        ref.read(childProfileProvider.notifier).addStars(2);
      }
    } else {
      // REGLA CRÍTICA: no le des la estrella ni por valido los errores
      ref.read(childProfileProvider.notifier).recordWin(
            gameType: GameType.visualMath,
            awardStars: _earnedStar,
          );
    }

    int nextEx;
    if (!wasCustom && isFinalOfLevel) {
      ref.read(childProfileProvider.notifier).advanceLevel(GameType.visualMath);
      nextEx = 1;
    } else if (!wasCustom) {
      nextEx = _exerciseNumber + 1;
    } else {
      nextEx = _exerciseNumber;
    }

    if (!wasCustom) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('math_exercise_index', nextEx);
    }

    await TeacherVoiceService.instance.speakAndWait(_teacherSpeech);
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        _exerciseNumber = nextEx;
      });

      if (isFinalOfLevel) {
        final newLevel = ref.read(childProfileProvider).mathLevel;
        if (newLevel == 3) {
          await MathPreambleDialog.show(context, initialOperation: MathOperation.multiplication);
        } else if (newLevel == 6) {
          await MathPreambleDialog.show(context, initialOperation: MathOperation.division);
        }
      }

      _generateExercise();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _wordController.dispose();
    TeacherVoiceService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(childProfileProvider);
    final customExercises = ref.watch(customExercisesProvider);
    final pendingCustom = customExercises.where((e) => !e.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Mundo Matemático (Nivel ${profile.mathLevel})'),
        backgroundColor: const Color(0xFFFF9233),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'Explicación didáctica (Preámbulo)',
            onPressed: () => MathPreambleDialog.show(
              context,
              initialOperation: _currentOperation,
            ),
          ),
        ],
      ),
      body: PlayfulBackground(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  TeacherBubbleWidget(
                    speechText: _teacherSpeech,
                    isCelebration: _isCorrect == true,
                    isTip: _isTip,
                    onReplay: () => TeacherVoiceService.instance.speak(_teacherSpeech),
                  ),

                  // Barra de progreso y estrellas
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(
                            _activeCustomExercise != null
                                ? '💖 Desafío de Mamá/Papá'
                                : 'Nivel ${profile.mathLevel} • Ejercicio $_exerciseNumber/100 🚀',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _activeCustomExercise != null
                                  ? Colors.pink.shade700
                                  : Colors.orange.shade800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.orange, size: 22),
                              const SizedBox(width: 4),
                              Text(
                                '${profile.totalStars}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botón para acceder a ejercicios de los padres si hay pendientes
                  if (pendingCustom.isNotEmpty && _activeCustomExercise == null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: InkWell(
                        onTap: () {
                          _generateExercise(customExercise: pendingCustom.first);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.pink.shade300, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Text('💖', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '¡Mamá o Papá te prepararon ${pendingCustom.length} desafío${pendingCustom.length > 1 ? "s" : ""}! Toca aquí para jugar.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink.shade800,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.pink),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (_activeCustomExercise != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _generateExercise(),
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text('Volver a ejercicios normales'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 6),

                  // Alerta visual pedagógica de modo ayuda facilitado
                  if (_isFacilitated) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade400, width: 1.5),
                      ),
                      child: const Row(
                        children: [
                          Text('💡', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '¡Modo Ayuda Activo! Cuenta los números que aparecen arriba de cada objeto para descubrir el resultado.',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6D4C41),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 6),

                  // Tarjeta gráfica representativa
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildGraphicContent(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // PASO 1: Ingreso de la respuesta numérica con el teclado
                  if (_currentStep == MathStep.number) ...[
                    _buildEquationDisplay(),
                    const SizedBox(height: 14),
                    _buildNumericKeypad(),
                  ],

                  // PASO 2 (Nivel > 7): Escritura del nombre del número en letras
                  if (_currentStep == MathStep.word) ...[
                    _buildWordInputSection(),
                  ],

                  if (_isAutoAdvancing) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _earnedStar ? Icons.star_rounded : Icons.check_circle,
                          color: _earnedStar ? Colors.orange : AppColors.playfulGreen,
                          size: 26,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _earnedStar ? '¡Estrella Ganada! Avanzando...' : '¡Ejercicio Aprendido! Avanzando...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _earnedStar ? Colors.orange.shade800 : AppColors.playfulGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra la expresión matemática con el casillero numérico editable
  Widget _buildEquationDisplay() {
    final hasInput = _enteredDigits.isNotEmpty;
    Color boxColor = Colors.white;
    Color borderColor = AppColors.primaryBlue;

    if (_isCorrect == true) {
      boxColor = Colors.green.shade50;
      borderColor = AppColors.playfulGreen;
    } else if (_isCorrect == false) {
      boxColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade700;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$_firstGroup ${_currentOperation.symbol} $_secondGroup = ',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            constraints: const BoxConstraints(minWidth: 84, minHeight: 56),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              hasInput ? _enteredDigits : '?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: hasInput ? AppColors.textDark : AppColors.primaryBlue.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Teclado numérico táctil infantil (teclas grandes, cómodas y coloridas)
  Widget _buildNumericKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['DEL', '0', 'OK'],
    ];

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _buildKeypadButton(key),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeypadButton(String key) {
    final isDel = key == 'DEL';
    final isOk = key == 'OK';

    Color bgColor = Colors.white;
    Widget child;

    if (isDel) {
      bgColor = Colors.orange.shade50;
      child = const Icon(Icons.backspace_outlined, size: 24, color: Colors.deepOrange);
    } else if (isOk) {
      bgColor = AppColors.playfulGreen;
      child = const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_rounded, color: Colors.white, size: 22),
          SizedBox(width: 4),
          Text(
            'Listo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      );
    } else {
      child = Text(
        key,
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark),
      );
    }

    return Material(
      color: bgColor,
      elevation: 2,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: _isAutoAdvancing ? null : () => _onKeypadPress(key),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isOk
                  ? Colors.green.shade600
                  : isDel
                      ? Colors.orange.shade300
                      : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  /// Sección de escritura en letras para niveles > 7
  Widget _buildWordInputSection() {
    final correctWord = NumberWordsHelper.toWords(_correctResult);

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.purple.shade200, width: 2),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('✍️', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'Desafío Nivel 7+: Escribe en letras',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '¿Cómo se escribe el número $_correctResult?',
                  style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                ),
                if (_isFacilitated) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '💡 Pista: Empieza con "${correctWord.substring(0, min(3, correctWord.length))}..." (${correctWord.length} letras)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _wordController,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Ej: ${_correctResult <= 20 ? "doce, quince..." : "veinte..."}',
              fillColor: Colors.white,
              filled: true,
              prefixIcon: const Icon(Icons.edit_rounded, color: Colors.purple),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                onPressed: () => _wordController.clear(),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onSubmitted: (_) => _submitWordAnswer(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isAutoAdvancing ? null : _submitWordAnswer,
              icon: const Icon(Icons.check_circle_rounded, size: 22),
              label: const Text(
                'Comprobar Palabra ✓',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.playfulGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphicContent() {
    switch (_currentOperation) {
      case MathOperation.addition:
        return Column(
          children: [
            _buildNumberRepresentation(_firstGroup, _currentEmoji, startIndex: 1),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            _buildNumberRepresentation(_secondGroup, _currentEmoji, startIndex: _firstGroup + 1),
          ],
        );

      case MathOperation.subtraction:
        return Column(
          children: [
            _buildNumberRepresentation(_firstGroup, _currentEmoji, startIndex: 1),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '−',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            _buildNumberRepresentation(_secondGroup, _currentEmoji, startIndex: 1, isSubtracted: true),
          ],
        );

      case MathOperation.multiplication:
        return Column(
          children: [
            Text(
              '$_firstGroup grupos de $_secondGroup $_currentEmoji:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: List.generate(_firstGroup.clamp(1, 6), (groupIndex) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade200, width: 2),
                  ),
                  child: Column(
                    children: [
                      if (_isFacilitated)
                        Text('Grupo ${groupIndex + 1}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple)),
                      Wrap(
                        spacing: 4,
                        children: List.generate(
                          _secondGroup.clamp(1, 6),
                          (itemIndex) => Text(_currentEmoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            if (_isFacilitated) ...[
              const SizedBox(height: 8),
              Text(
                'Pista: ${List.generate(_firstGroup, (i) => "$_secondGroup").join(" + ")} = $_correctResult',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple),
              ),
            ],
          ],
        );

      case MathOperation.division:
        return Column(
          children: [
            Text(
              '$_firstGroup $_currentEmoji repartidos en $_secondGroup partes iguales:',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF00838F)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: List.generate(_secondGroup.clamp(1, 6), (friendIndex) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.cyan.shade200, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text('Amigo ${friendIndex + 1} 🧒', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: List.generate(
                          _correctResult.clamp(1, 6),
                          (itemIndex) => Text(_currentEmoji, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            if (_isFacilitated) ...[
              const SizedBox(height: 8),
              Text(
                'Pista: A cada uno le tocan $_correctResult porque $_secondGroup × $_correctResult = $_firstGroup',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF00838F)),
              ),
            ],
          ],
        );
    }
  }

  Widget _buildNumberRepresentation(int count, String emoji, {int startIndex = 1, bool isSubtracted = false}) {
    if (count <= 12) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(
          count,
          (i) {
            final orderNumber = startIndex + i;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isFacilitated)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSubtracted ? Colors.red.shade100 : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$orderNumber',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSubtracted ? Colors.red.shade900 : Colors.blue.shade900,
                      ),
                    ),
                  ),
                Opacity(
                  opacity: isSubtracted ? 0.6 : 1.0,
                  child: Text(emoji, style: const TextStyle(fontSize: 30)),
                ),
              ],
            );
          },
        ),
      );
    }

    // Para números > 12: Representación pedagógica Base 10 (Decenas y Unidades)
    final tens = count ~/ 10;
    final units = count % 10;

    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Bloques de decenas
            ...List.generate(tens, (i) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSubtracted ? Colors.red.shade50 : Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSubtracted ? Colors.red.shade400 : Colors.amber.shade700,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.shade200.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    const Text(
                      '10',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Color(0xFF795548),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Unidades sueltas
            if (units > 0)
              ...List.generate(units, (i) {
                return Opacity(
                  opacity: isSubtracted ? 0.6 : 1.0,
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                );
              }),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '$count = $tens decena${tens > 1 ? "s" : ""}${units > 0 ? " y $units unidad${units > 1 ? "es" : ""}" : ""}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
