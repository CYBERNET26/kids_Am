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

class VisualMathScreen extends ConsumerStatefulWidget {
  const VisualMathScreen({super.key});

  @override
  ConsumerState<VisualMathScreen> createState() => _VisualMathScreenState();
}

class _VisualMathScreenState extends ConsumerState<VisualMathScreen> {
  static const int totalMathExercises = 100;
  late ConfettiController _confettiController;
  int _exerciseNumber = 1; // 1 a 100
  bool _hasGreetedThisVisit = false;

  late int _firstGroup;
  late int _secondGroup;
  late bool _isAddition;
  late int _correctResult;
  late List<int> _options;
  int? _selectedAnswer;
  bool? _isCorrect;
  String _teacherSpeech = '';
  bool _isTip = false;
  bool _isAutoAdvancing = false;

  final List<String> _emojis = ['🍎', '⭐️', '🚗', '🐱', '🚀', '🍓', '🎈', '🐶', '⚽️', '🍦'];
  late String _currentEmoji;

  final List<String> _variedPromptsAddition = [
    '¡Siguiente desafío! ¿Cuántos objetos hay si los sumamos todos?',
    '¡Mira esta nueva cuenta! Suma los de arriba con los de abajo.',
    '¡A contar con atención! ¿Cuál es el resultado de esta suma?',
    '¡Excelente ritmo! ¿Cuántos objetos tenemos en total?',
    '¡Vamos con otra divertida! Cuenta los objetos y toca la respuesta.',
  ];

  final List<String> _variedPromptsSubtraction = [
    '¡Aventura de restar! Teníamos estos objetos y quitamos algunos. ¿Cuántos quedan?',
    '¡Siguiente ejercicio! Haz la resta y encuentra el resultado correcto.',
    '¡Mira bien! Si quitamos los de abajo, ¿cuántos nos quedan?',
    '¡A calcular! ¿Qué número queda después de restar?',
    '¡Vamos muy bien! Cuenta los que sobran y toca el botón.',
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
      _generateExercise();
    }
  }

  void _generateExercise() {
    final profile = ref.read(childProfileProvider);
    final random = Random();
    _currentEmoji = _emojis[random.nextInt(_emojis.length)];
    _selectedAnswer = null;
    _isCorrect = null;
    _isTip = false;
    _isAutoAdvancing = false;

    // Progresión estructurada a lo largo de los 100 ejercicios
    // 1-10: Sumas 1 a 4 (Nivel 1)
    // 11-20: Sumas 1 a 6 (Nivel 2)
    // 21-30: Sumas 1 a 8 (Nivel 3)
    // 31-40: Restas 1 a 6 (Nivel 4)
    // 41-50: Restas 1 a 10 (Nivel 5)
    // 51-60: Combinadas hasta 10 (Nivel 6)
    // 61-70: Sumas hasta 14 (Nivel 7)
    // 71-80: Restas hasta 14 (Nivel 8)
    // 81-90: Desafíos hasta 18 (Nivel 9)
    // 91-100: Retos de campeón hasta 22 (Nivel 10)

    if (_exerciseNumber <= 30) {
      _isAddition = true;
      final maxG = _exerciseNumber <= 10 ? 3 : (_exerciseNumber <= 20 ? 5 : 6);
      _firstGroup = random.nextInt(maxG) + 1;
      _secondGroup = random.nextInt(maxG) + 1;
      _correctResult = _firstGroup + _secondGroup;
    } else if (_exerciseNumber <= 50) {
      _isAddition = false;
      final maxG = _exerciseNumber <= 40 ? 6 : 9;
      _firstGroup = random.nextInt(maxG) + 2;
      _secondGroup = random.nextInt(_firstGroup - 1) + 1;
      _correctResult = _firstGroup - _secondGroup;
    } else {
      _isAddition = random.nextBool();
      final maxG = _exerciseNumber <= 70 ? 7 : (_exerciseNumber <= 85 ? 9 : 11);
      if (_isAddition) {
        _firstGroup = random.nextInt(maxG) + 1;
        _secondGroup = random.nextInt(maxG) + 1;
        _correctResult = _firstGroup + _secondGroup;
      } else {
        _firstGroup = random.nextInt(maxG) + 3;
        _secondGroup = random.nextInt(_firstGroup - 1) + 1;
        _correctResult = _firstGroup - _secondGroup;
      }
    }

    final Set<int> optionSet = {_correctResult};
    while (optionSet.length < 3) {
      final offset = random.nextBool() ? 1 : -1;
      final distractor = (_correctResult + offset * (random.nextInt(3) + 1)).clamp(0, 30);
      optionSet.add(distractor);
    }
    _options = optionSet.toList()..shuffle();

    // Mensaje de la maestra: Solo saluda con "Hola [Nombre]" en el primer ejercicio de la visita
    if (!_hasGreetedThisVisit) {
      _hasGreetedThisVisit = true;
      _teacherSpeech = '¡Hola ${profile.name}! Bienvenido a Mundo Matemático. Empecemos con el ejercicio número $_exerciseNumber.';
    } else {
      // Mensajes variados sin repetir "Hola"
      if (_isAddition) {
        _teacherSpeech = _variedPromptsAddition[random.nextInt(_variedPromptsAddition.length)];
      } else {
        _teacherSpeech = _variedPromptsSubtraction[random.nextInt(_variedPromptsSubtraction.length)];
      }
    }

    TeacherVoiceService.instance.speak(_teacherSpeech);
    setState(() {});
  }

  void _checkAnswer(int answer) async {
    if (_isCorrect == true || _isAutoAdvancing) return;

    if (answer == _correctResult) {
      setState(() {
        _selectedAnswer = answer;
        _isCorrect = true;
        _isTip = false;
        _isAutoAdvancing = true;
        _confettiController.play();
        _teacherSpeech = '¡Maravilloso! $_firstGroup ${_isAddition ? "más" : "menos"} $_secondGroup es igual a $_correctResult. ¡Excelente respuesta!';
      });

      ref.read(childProfileProvider.notifier).recordWin(gameType: GameType.visualMath);

      // Guardar progreso al siguiente ejercicio
      final nextEx = (_exerciseNumber < totalMathExercises) ? _exerciseNumber + 1 : 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('math_exercise_index', nextEx);

      // Esperar a que la maestra termine de hablar
      await TeacherVoiceService.instance.speakAndWait(_teacherSpeech);
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        setState(() {
          _exerciseNumber = nextEx;
        });
        _generateExercise();
      }
    } else {
      setState(() {
        _selectedAnswer = answer;
        _isCorrect = false;
        _isTip = true;
        if (_isAddition) {
          _teacherSpeech = '¡Casi lo logras! Mira con cuidado: contemos primero los $_firstGroup de arriba y luego agregamos los $_secondGroup de abajo. ¡Intenta otra vez!';
        } else {
          _teacherSpeech = '¡Ánimo! Cuenta solo los objetos que quedaron sin tachar. ¡Tú puedes!';
        }
      });
      TeacherVoiceService.instance.speak(_teacherSpeech);
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
    final calculatedLevel = ((_exerciseNumber - 1) ~/ 10) + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mundo Matemático (Ej. $_exerciseNumber de $totalMathExercises)'),
        backgroundColor: const Color(0xFFFF9233),
        foregroundColor: Colors.white,
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
                            'Nivel $calculatedLevel • Ejercicio $_exerciseNumber/100 🚀',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
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

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: List.generate(
                                _firstGroup,
                                (i) => FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(_currentEmoji, style: const TextStyle(fontSize: 36)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                _isAddition ? '+' : '−',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: List.generate(
                                _secondGroup,
                                (i) => FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(_currentEmoji, style: const TextStyle(fontSize: 36)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$_firstGroup ${_isAddition ? "+" : "−"} $_secondGroup = ?',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

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
                          '¡Excelente! Avanzando al siguiente ejercicio...',
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
}
