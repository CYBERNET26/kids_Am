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
  late List<int> _options;
  int? _selectedAnswer;
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
    _selectedAnswer = null;
    _isCorrect = null;
    _isTip = false;
    _isAutoAdvancing = false;
    _activeCustomExercise = customExercise;

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
            // PROGRESIÓN GRADUAL NIVEL 1 (Parámetro máximo hasta 100):
            if (_exerciseNumber <= 15) {
              // Fase 1: 1 a 10 (conteo visual directo)
              _firstGroup = random.nextInt(5) + 1;
              _secondGroup = random.nextInt(5) + 1;
            } else if (_exerciseNumber <= 35) {
              // Fase 2: hasta 20
              _firstGroup = random.nextInt(10) + 2;
              _secondGroup = random.nextInt(8) + 1;
            } else if (_exerciseNumber <= 55) {
              // Fase 3: decenas y números hasta 40
              _firstGroup = (random.nextInt(3) + 1) * 10 + random.nextInt(5);
              _secondGroup = random.nextInt(10) + 1;
            } else if (_exerciseNumber <= 75) {
              // Fase 4: números hasta 70
              _firstGroup = random.nextInt(35) + 15;
              _secondGroup = random.nextInt(20) + 5;
            } else {
              // Fase 5: desafío final hasta 100
              _firstGroup = random.nextInt(45) + 25;
              final maxSecond = 100 - _firstGroup;
              _secondGroup = random.nextInt(maxSecond.clamp(5, 35)) + 5;
            }
          } else if (level == 2) {
            // Nivel 2: sumas con llevadas de 100 a 200
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
            // PROGRESIÓN GRADUAL NIVEL 1 (Parámetro máximo hasta 100):
            if (_exerciseNumber <= 15) {
              // Fase 1: restas de 1 a 10
              _firstGroup = random.nextInt(6) + 4; // 4..9
              _secondGroup = random.nextInt(_firstGroup - 1) + 1;
            } else if (_exerciseNumber <= 35) {
              // Fase 2: restas hasta 20
              _firstGroup = random.nextInt(10) + 10; // 10..19
              _secondGroup = random.nextInt(8) + 1;
            } else if (_exerciseNumber <= 55) {
              // Fase 3: restas hasta 40
              _firstGroup = random.nextInt(20) + 20; // 20..39
              _secondGroup = random.nextInt(15) + 2;
            } else if (_exerciseNumber <= 75) {
              // Fase 4: restas hasta 70
              _firstGroup = random.nextInt(30) + 40; // 40..69
              _secondGroup = random.nextInt(25) + 5;
            } else {
              // Fase 5: restas partiendo de hasta 100
              _firstGroup = random.nextInt(31) + 70; // 70..100
              _secondGroup = random.nextInt(40) + 10;
            }
          } else if (level == 2) {
            _firstGroup = random.nextInt(80) + 100; // 100..180
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
            // Tablas del 1, 2 y 3 sencillas
            _firstGroup = random.nextInt(3) + 2; // 2, 3, 4
            _secondGroup = random.nextInt(3) + 1; // 1, 2, 3
          } else if (level <= 5) {
            // Tablas del 2 al 6
            _firstGroup = random.nextInt(5) + 2; // 2..6
            _secondGroup = random.nextInt(5) + 2; // 2..6
          } else {
            // Tablas completas del 2 al 9
            _firstGroup = random.nextInt(8) + 2;
            _secondGroup = random.nextInt(8) + 2;
          }
          _correctResult = _firstGroup * _secondGroup;
          break;

        case MathOperation.division:
          // Divisiones exactas sin resto
          if (level == 6) {
            _secondGroup = random.nextInt(3) + 2; // divisor: 2, 3 o 4
            _correctResult = random.nextInt(4) + 2; // cociente: 2, 3, 4, 5
          } else {
            _secondGroup = random.nextInt(4) + 2; // 2..5
            _correctResult = random.nextInt(6) + 2; // 2..7
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

    // Opciones de respuesta pedagógicas
    final Set<int> optionSet = {_correctResult};
    final List<int> possibleDeltas = _correctResult > 30
        ? [1, 2, 5, 10, -1, -2, -5, -10]
        : [1, 2, 3, -1, -2, -3];
    possibleDeltas.shuffle(random);
    for (final d in possibleDeltas) {
      if (optionSet.length >= 3) break;
      final val = _correctResult + d;
      if (val >= 0 && val != _correctResult) {
        optionSet.add(val);
      }
    }
    while (optionSet.length < 3) {
      final offset = random.nextBool() ? 1 : -1;
      final distractor = (_correctResult + offset * (random.nextInt(6) + 1)).clamp(0, 200);
      if (distractor != _correctResult) {
        optionSet.add(distractor);
      }
    }
    _options = optionSet.toList()..shuffle();

    TeacherVoiceService.instance.speak(_teacherSpeech);
    setState(() {});
  }

  void _checkAnswer(int answer) async {
    if (_isCorrect == true || _isAutoAdvancing) return;

    if (answer == _correctResult) {
      final profile = ref.read(childProfileProvider);
      final isFinalOfLevel = _exerciseNumber >= totalMathExercises;
      final wasCustom = _activeCustomExercise != null;

      setState(() {
        _selectedAnswer = answer;
        _isCorrect = true;
        _isTip = false;
        _isAutoAdvancing = true;
        _confettiController.play();

        if (wasCustom) {
          _teacherSpeech = '¡Bravo ${profile.name}! ¡Resolviste con éxito el desafío especial de mamá y papá! ¡Te ganaste 2 estrellas de premio!';
        } else if (isFinalOfLevel) {
          _teacherSpeech =
              '¡Increíble logro ${profile.name}! ¡Completaste los 100 ejercicios del Nivel ${profile.mathLevel}! ¡Subes al Nivel ${profile.mathLevel + 1} con nuevos aprendizajes!';
        } else {
          _teacherSpeech =
              '¡Maravilloso! $_firstGroup ${_currentOperation.symbol} $_secondGroup es igual a $_correctResult. ¡Excelente!';
        }
      });

      if (wasCustom) {
        ref.read(customExercisesProvider.notifier).markCompleted(_activeCustomExercise!.id);
        ref.read(childProfileProvider.notifier).addStars(2);
      } else {
        ref.read(childProfileProvider.notifier).recordWin(gameType: GameType.visualMath);
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

        // Si subió a nivel 3 o 6, mostramos el preámbulo explicativo de la nueva operación
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
    } else {
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

      setState(() {
        _selectedAnswer = answer;
        _isCorrect = false;
        _isTip = true;
      });

      final profile = ref.read(childProfileProvider);
      final tutorState = ref.read(tutorProvider);
      final feedback = await tutorState.coordinator.speakFeedback(
        TutorContext(
          childName: profile.name,
          childAge: 6,
          eventType: TutorEventType.mathIncorrect,
          gameName: 'Mundo Matemático',
          topicOrOperation: '$_firstGroup ${_currentOperation.symbol} $_secondGroup',
          childMistake: 'Eligió $answer en vez de $_correctResult',
          pedagogicalHint: hint,
        ),
      );

      if (mounted) {
        setState(() {
          _teacherSpeech = feedback.speechText;
        });
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
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

                  const SizedBox(height: 16),

                  // Expresión matemática en texto grande
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$_firstGroup ${_currentOperation.symbol} $_secondGroup = ?',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Botones de opciones
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _options.map((option) {
                        final isSelected = _selectedAnswer == option;
                        final isAnswerCorrect = option == _correctResult;

                        Color btnColor = Colors.white;
                        Color txtColor = AppColors.textDark;

                        if (isSelected) {
                          if (_isCorrect == true) {
                            btnColor = AppColors.playfulGreen;
                            txtColor = Colors.white;
                          } else {
                            btnColor = Colors.orange.shade300;
                            txtColor = Colors.white;
                          }
                        } else if (_isCorrect == true && isAnswerCorrect) {
                          btnColor = AppColors.playfulGreen.withValues(alpha: 0.3);
                        }

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: InkWell(
                              onTap: () => _checkAnswer(option),
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: 68,
                                decoration: BoxDecoration(
                                  color: btnColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '$option',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: txtColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  if (_isAutoAdvancing) ...[
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.playfulGreen, size: 24),
                        SizedBox(width: 8),
                        Text(
                          '¡Excelente! Avanzando...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.playfulGreen,
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

  Widget _buildGraphicContent() {
    switch (_currentOperation) {
      case MathOperation.addition:
        return Column(
          children: [
            _buildNumberRepresentation(_firstGroup, _currentEmoji),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '+',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            _buildNumberRepresentation(_secondGroup, _currentEmoji),
          ],
        );

      case MathOperation.subtraction:
        return Column(
          children: [
            _buildNumberRepresentation(_firstGroup, _currentEmoji),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '−',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            _buildNumberRepresentation(_secondGroup, _currentEmoji),
          ],
        );

      case MathOperation.multiplication:
        // Representación multiplicativa: N grupos iguales de M elementos
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
                  child: Wrap(
                    spacing: 4,
                    children: List.generate(
                      _secondGroup.clamp(1, 6),
                      (itemIndex) => Text(_currentEmoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }),
            ),
          ],
        );

      case MathOperation.division:
        // Representación de división: Repartir el total en partes iguales
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
          ],
        );
    }
  }

  Widget _buildNumberRepresentation(int count, String emoji) {
    if (count <= 12) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: List.generate(
          count,
          (i) => FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(emoji, style: const TextStyle(fontSize: 30)),
          ),
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
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade700, width: 2),
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
                return Text(emoji, style: const TextStyle(fontSize: 22));
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
