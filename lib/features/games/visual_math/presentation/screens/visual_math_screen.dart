import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:kids_am/core/constants/app_colors.dart';
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

  final List<String> _emojis = ['🍎', '⭐️', '🚗', '🐱', '🚀', '🍓', '🎈'];
  late String _currentEmoji;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _generateProblem();
  }

  void _generateProblem() {
    final profile = ref.read(childProfileProvider);
    final random = Random();
    _currentEmoji = _emojis[random.nextInt(_emojis.length)];
    _selectedAnswer = null;
    _isCorrect = null;

    // Dificultad basada en el nivel de matemáticas
    final maxNum = (profile.mathLevel * 3).clamp(3, 10);
    _firstGroup = random.nextInt(maxNum) + 1;
    
    // Nivel 1: solo sumas pequeñas. Niveles superiores pueden tener restas amigables
    _isAddition = profile.mathLevel == 1 || random.nextBool();

    if (_isAddition) {
      _secondGroup = random.nextInt(maxNum) + 1;
      _correctResult = _firstGroup + _secondGroup;
    } else {
      _secondGroup = random.nextInt(_firstGroup) + 1;
      _correctResult = _firstGroup - _secondGroup;
    }

    // Generar 3 opciones (una correcta y dos distracciones cercanas)
    final Set<int> optionSet = {_correctResult};
    while (optionSet.length < 3) {
      final offset = random.nextBool() ? 1 : -1;
      final distractor = (_correctResult + offset * (random.nextInt(3) + 1)).clamp(0, 20);
      optionSet.add(distractor);
    }
    _options = optionSet.toList()..shuffle();
  }

  void _checkAnswer(int answer) {
    if (_isCorrect != null) return;

    setState(() {
      _selectedAnswer = answer;
      if (answer == _correctResult) {
        _isCorrect = true;
        _confettiController.play();
        ref.read(childProfileProvider.notifier).recordWin(gameType: GameType.visualMath);
      } else {
        _isCorrect = false; // Refuerzo positivo: sin penalizaciones frustrantes
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(childProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mundo Matemático (Nivel ${profile.mathLevel})'),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Barra de progreso y refuerzo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '¡Cuenta los objetos!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 24),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.totalStars}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Visualizador de figuras grupales
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: List.generate(
                            _firstGroup,
                            (i) => Text(_currentEmoji, style: const TextStyle(fontSize: 42)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            _isAddition ? '+' : '−',
                            style: const TextStyle(
                              fontSize: 40,
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
                            (i) => Text(_currentEmoji, style: const TextStyle(fontSize: 42)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Expresión numérica
                Text(
                  '$_firstGroup ${_isAddition ? "+" : "−"} $_secondGroup = ?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 28),

                // Opciones de respuesta amigables
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _options.map((option) {
                    final isThisSelected = _selectedAnswer == option;
                    Color btnColor = AppColors.sunnyYellow;
                    if (isThisSelected) {
                      btnColor = (_isCorrect ?? false) ? AppColors.playfulGreen : Colors.orange.shade300;
                    }

                    return SizedBox(
                      width: 90,
                      height: 90,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnColor,
                          foregroundColor: AppColors.textDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () => _checkAnswer(option),
                        child: Text(
                          '$option',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // Mensajes de retroalimentación constructiva
                if (_isCorrect == true) ...[
                  const Text(
                    '🎉 ¡Excelente trabajo! ¡Ganaste una estrella! ⭐',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.playfulGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.playfulGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                    onPressed: () {
                      setState(() {
                        _generateProblem();
                      });
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Siguiente Reto', style: TextStyle(fontSize: 18)),
                  ),
                ] else if (_isCorrect == false) ...[
                  const Text(
                    '💡 ¡Casi lo logras! Intenta contar los objetos uno a uno con tu dedito.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedAnswer = null;
                        _isCorrect = null;
                      });
                    },
                    child: const Text('Intentar de nuevo', style: TextStyle(fontSize: 16)),
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

