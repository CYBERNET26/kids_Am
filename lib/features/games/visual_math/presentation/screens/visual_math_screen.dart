import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/core/services/teacher_voice_service.dart';
import 'package:kids_am/core/widgets/teacher_bubble_widget.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/games/domain/models/game_level.dart';

class VisualMathScreen extends ConsumerStatefulWidget {
  const VisualMathScreen({super.key});

  @override
  ConsumerState<VisualMathScreen> createState() => _VisualMathScreenState();
}

class _VisualMathScreenState extends ConsumerState<VisualMathScreen> {
  late ConfettiController _confettiController;
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

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateProblem();
    });
  }

  void _generateProblem() {
    final profile = ref.read(childProfileProvider);
    final random = Random();
    _currentEmoji = _emojis[random.nextInt(_emojis.length)];
    _selectedAnswer = null;
    _isCorrect = null;
    _isTip = false;
    _isAutoAdvancing = false;

    final level = profile.mathLevel;
    int maxGroup;
    if (level <= 2) {
      maxGroup = 4;
      _isAddition = true;
    } else if (level <= 4) {
      maxGroup = 6;
      _isAddition = random.nextBool();
    } else if (level <= 7) {
      maxGroup = 8;
      _isAddition = random.nextBool();
    } else {
      maxGroup = 10;
      _isAddition = random.nextBool();
    }

    _firstGroup = random.nextInt(maxGroup) + 1;

    if (_isAddition) {
      _secondGroup = random.nextInt(maxGroup) + 1;
      _correctResult = _firstGroup + _secondGroup;
    } else {
      _secondGroup = random.nextInt(_firstGroup) + 1;
      _correctResult = _firstGroup - _secondGroup;
    }

    final Set<int> optionSet = {_correctResult};
    while (optionSet.length < 3) {
      final offset = random.nextBool() ? 1 : -1;
      final distractor = (_correctResult + offset * (random.nextInt(3) + 1)).clamp(0, 30);
      optionSet.add(distractor);
    }
    _options = optionSet.toList()..shuffle();

    if (_isAddition) {
      _teacherSpeech = '¡Hola! Vamos a sumar: aquí tenemos $_firstGroup y agregamos $_secondGroup. ¿Cuántos hay en total?';
    } else {
      _teacherSpeech = '¡Aventura de restar! Teníamos $_firstGroup y quitamos $_secondGroup. ¿Cuántos nos quedan?';
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
        _teacherSpeech = '¡Maravilloso! $_firstGroup ${_isAddition ? "más" : "menos"} $_secondGroup es igual a $_correctResult. ¡Muy bien hecho!';
      });

      ref.read(childProfileProvider.notifier).recordWin(gameType: GameType.visualMath);

      // ESPERAR a que la maestra termine completamente de hablar
      await TeacherVoiceService.instance.speakAndWait(_teacherSpeech);

      // Pausa cómoda para que el niño disfrute el festejo antes de avanzar
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        _generateProblem();
      }
    } else {
      setState(() {
        _selectedAnswer = answer;
        _isCorrect = false;
        _isTip = true;
        if (_isAddition) {
          _teacherSpeech = '¡Casi lo logras! Mira con atención: contemos primero los de arriba y luego agregamos los de abajo. ¡Intenta de nuevo!';
        } else {
          _teacherSpeech = '¡Ánimo! Quita mentalmente los $_secondGroup objetos tachados y cuenta cuántos quedan.';
        }
      });

      // Explicación alternativa paciente
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

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: Text('Mundo Matemático (Nivel ${profile.mathLevel}/10)'),
        backgroundColor: const Color(0xFFFF9233),
        foregroundColor: Colors.white,
      ),
      body: Stack(
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
                // Globo de la Maestra Sofía
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
                        ),
                        child: Text(
                          'Nivel ${profile.mathLevel} de 10 🚀',
                          style: TextStyle(
                            fontSize: 14,
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
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 22),
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

                // Tarjeta central con objetos centrados
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

                // Expresión numérica centrada
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

                // Opciones táctiles para responder centradas y con FittedBox
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
    );
  }
}
