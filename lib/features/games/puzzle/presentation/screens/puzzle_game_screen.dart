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

class PuzzleGameScreen extends ConsumerStatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  ConsumerState<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends ConsumerState<PuzzleGameScreen> {
  static const int totalPuzzles = 100;
  late ConfettiController _confettiController;

  int _puzzleNumber = 1;
  bool _hasGreetedThisVisit = false;

  int _gridDimension = 2;
  late List<int?> _boardSlots;
  late List<int> _availablePieces;
  bool _isSolved = false;
  bool _isAutoAdvancing = false;
  String _themeTitle = '';
  List<String> _currentThemeIcons = [];
  String _teacherSpeech = '';
  bool _isTip = false;

  final List<Map<String, dynamic>> _puzzleThemesBank = [
    {'title': 'Animales de la Granja 🐮', 'icons': ['🐮', '🐷', '🐑', '🐔', '🐴', '🦆', '🐰', '🐶', '🐱', '🐭', '🦃', '🐂', '🐐', '🦙', '🐕', '🐓']},
    {'title': 'Frutas Dulces 🍎', 'icons': ['🍎', '🍌', '🍓', '🍇', '🍊', '🍉', '🍍', '🍒', '🍑', '🥝', '🍋', '🍐', '🥭', '🫐', '🍈', '🍏']},
    {'title': 'Mascotas Divertidas 🐶', 'icons': ['🐶', '🐱', '🐰', '🐹', '🦜', '🐠', '🐢', '🐩', '🐾', '🦴', '🦮', '🐈', '🐁', '🦔', '🦎', '🐥']},
    {'title': 'Juguetes Alegres 🧸', 'icons': ['🧸', '🚗', '🪁', '🪀', '🚂', '🧩', '🎈', '🥁', '🛹', '🎳', '🎯', '🪅', '🎺', '🪄', '⛵️', '🤖']},
    {'title': 'Animales de la Selva 🦁', 'icons': ['🦁', '🐘', '🦒', '🐼', '🦊', '🐸', '🐯', '🐵', '🦉', '🦓', '🐨', '🐧', '🦛', '🦏', '🐆', '🦧']},
    {'title': 'Exploración Espacial 🚀', 'icons': ['🚀', '👨‍🚀', '🛸', '🪐', '⭐️', '🌕', '☄️', '🛰️', '👾', '🌍', '🌞', '🌌', '🌠', '🔭', '🌑', '✨']},
    {'title': 'Maravillas del Océano 🐬', 'icons': ['🐬', '🐳', '🐙', '🦀', '🐠', '🦈', '🐢', '🦭', '🦞', '🐚', '🌊', '🦑', '🐡', '🪸', '⚓️', '💎']},
    {'title': 'Dinosaurios del Pasado 🦖', 'icons': ['🦖', '🦕', '🐊', '🦎', '🦴', '🌋', '🌴', '🪨', '🥚', '🌿', '🪵', '🐾', '☄️', '⛰️', '🍂', '🍁']},
    {'title': 'Vehículos en Marcha 🚒', 'icons': ['🚒', '🚓', '🚑', '🚁', '✈️', '🚜', '🏎️', '🛵', '🚲', '⛴️', '🚂', '🚀', '🛻', '🏍️', '🛸', '⛵️']},
    {'title': 'Instrumentos Musicales 🎸', 'icons': ['🎸', '🥁', '🎺', '🎹', '🎻', '🎷', '🪗', '🪘', '🎤', '🎧', '🎼', '🎵', '🎶', '📻', '🔔', '🪕']},
    {'title': 'Deportes y Juegos ⚽️', 'icons': ['⚽️', '🏀', '🎾', '⚾️', '🏈', '🏐', '🎳', '🥊', '🏓', '🏸', '⛸️', '🛹', '🛼', '🚴', '🏆', '🎯']},
    {'title': 'Dulces y Golosinas 🍦', 'icons': ['🍦', '🧁', '🍩', '🍪', '🍫', '🍭', '🍬', '🥞', '🍰', '🧇', '🍮', '🥧', '🍧', '🎂', '🍯', '🍿']},
    {'title': 'El Bosque Mágico 🌲', 'icons': ['🌲', '🍄', '🐿️', '🦌', '🦔', '🦊', '🍁', '🪵', '🍂', '🦉', '🌿', '🌰', '🦋', '🐝', '⛺️', '🏕️']},
    {'title': 'Bichitos del Jardín 🐞', 'icons': ['🐞', '🐝', '🦋', '🐛', '🐜', '🐌', '🦗', '🕷️', '🌸', '🌼', '🌻', '🌺', '🌷', '🌱', '🌾', '🪴']},
    {'title': 'Mundo de Fantasía 🦄', 'icons': ['🦄', '🐉', '🏰', '👑', '🧙‍♂️', '🧚', '🧞', '💎', '🗡️', '🛡️', '🪄', '🔮', '✨', '🪙', '🌟', '🕊️']},
    {'title': 'Aventuras en la Nieve ⛄️', 'icons': ['⛄️', '❄️', '⛷️', '🏂', '🐧', '🐻‍❄️', '⛸️', '🧤', '🧣', '🛷', '🏔️', '🌲', '🪵', '🦭', '🌨️', '☕️']},
    {'title': 'El Circo Encantado 🎪', 'icons': ['🎪', '🎭', '🤹', '🦁', '🐘', '🎠', '🎟️', '🍿', '🎈', '🤡', '🎺', '🪄', '🥁', '🎪', '🌟', '🪅']},
    {'title': 'Flores y Naturaleza 🌻', 'icons': ['🌻', '🌹', '🌷', '💐', '🌸', '🌼', '🌺', '🌱', '🌿', '☘️', '🍀', '🪴', '🍃', '☀️', '🌈', '🌧️']},
    {'title': 'Castillos y Reyes 🏰', 'icons': ['🏰', '👑', '⚔️', '🛡️', '🐎', '🤴', '👸', '💎', '🗝️', '📜', '🏹', '🦅', '🦁', '📯', '🚩', '🪙']},
    {'title': 'Robots del Futuro 🤖', 'icons': ['🤖', '🦾', '🦿', '⚡️', '🔋', '💻', '🖥️', '📡', '🕹️', '⚙️', '🔧', '🔨', '💡', '🔬', '🚀', '🛸']},
  ];

  final List<String> _variedPrompts = [
    '¡Nuevo rompecabezas para ti! Ubica cada pieza en su número correspondiente.',
    '¡Vamos con otro desafío! Arrastra las piezas al tablero con cuidado.',
    '¡Excelente trabajo! Arma este nuevo rompecabezas y diviértete.',
    '¡Concéntrate! Fíjate en los números y coloca cada pieza en su lugar.',
    '¡A jugar! Llena cada casilla en orden para completar la imagen.',
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadProgressAndStart();
  }

  Future<void> _loadProgressAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('puzzle_number_index') ?? 1;
    if (mounted) {
      setState(() {
        _puzzleNumber = savedIndex.clamp(1, totalPuzzles);
      });
      _initPuzzle();
    }
  }

  void _initPuzzle() {
    final profile = ref.read(childProfileProvider);

    // Dimensiones según el nivel del niño:
    // Nivel 1: 2x2 = 4 piezas
    // Nivel 2: 3x3 = 9 piezas
    // Nivel 3+: 4x4 = 16 piezas
    final level = profile.puzzleLevel;
    if (level <= 1) {
      _gridDimension = 2;
    } else if (level == 2) {
      _gridDimension = 3;
    } else {
      _gridDimension = 4;
    }

    // MEZCLADO CONSTANTE: Rota a través de las 20 temáticas distintas en cada puzle
    final themeIndex = (_puzzleNumber - 1) % _puzzleThemesBank.length;
    final themeData = _puzzleThemesBank[themeIndex];
    _themeTitle = themeData['title'] as String;
    final allIcons = List<String>.from(themeData['icons'] as List);

    final totalPieces = _gridDimension * _gridDimension;
    _currentThemeIcons = allIcons.take(totalPieces).toList();
    _boardSlots = List<int?>.filled(totalPieces, null);
    _availablePieces = List.generate(totalPieces, (index) => index)..shuffle();
    _isSolved = false;
    _isAutoAdvancing = false;
    _isTip = false;

    // Solo saluda por única vez al entrar al juego en esta visita
    if (!_hasGreetedThisVisit) {
      _hasGreetedThisVisit = true;
      _teacherSpeech = '¡Hola ${profile.name}! Bienvenido a Rompecabezas Nivel $level. Empecemos con $_themeTitle.';
    } else {
      final rand = Random();
      _teacherSpeech = _variedPrompts[rand.nextInt(_variedPrompts.length)];
    }

    TeacherVoiceService.instance.speak(_teacherSpeech);
    setState(() {});
  }

  void _checkSolution() async {
    for (int i = 0; i < _boardSlots.length; i++) {
      if (_boardSlots[i] != i) {
        return;
      }
    }

    final profile = ref.read(childProfileProvider);
    final isFinalOfLevel = _puzzleNumber >= totalPuzzles;

    setState(() {
      _isSolved = true;
      _isAutoAdvancing = true;
      _isTip = false;
      _confettiController.play();

      if (isFinalOfLevel) {
        _teacherSpeech = '¡Sensacional logro ${profile.name}! ¡Armaste los 100 rompecabezas del Nivel ${profile.puzzleLevel}! ¡Subes al Nivel ${profile.puzzleLevel + 1} con puzles más desafiantes!';
      } else {
        _teacherSpeech = '¡Bravo! Completaste el rompecabezas de $_themeTitle. ¡Eres increíble!';
      }
    });

    ref.read(childProfileProvider.notifier).recordWin(gameType: GameType.puzzle);

    int nextPuzzle;
    if (isFinalOfLevel) {
      ref.read(childProfileProvider.notifier).advanceLevel(GameType.puzzle);
      nextPuzzle = 1;
    } else {
      nextPuzzle = _puzzleNumber + 1;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('puzzle_number_index', nextPuzzle);

    await TeacherVoiceService.instance.speakAndWait(_teacherSpeech);
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        _puzzleNumber = nextPuzzle;
      });
      _initPuzzle();
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
    final totalPieces = _gridDimension * _gridDimension;

    return Scaffold(
      appBar: AppBar(
        title: Text('Rompecabezas (Nivel ${profile.puzzleLevel})'),
        backgroundColor: const Color(0xFF5CD85A),
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
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  TeacherBubbleWidget(
                    speechText: _teacherSpeech,
                    isCelebration: _isSolved,
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
                                color: Colors.green.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(
                            'Nivel ${profile.puzzleLevel} • Puzle $_puzzleNumber/100 ⭐',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
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
                                color: Colors.green.withValues(alpha: 0.15),
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
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _gridDimension,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: totalPieces,
                          itemBuilder: (context, slotIndex) {
                            final currentPiece = _boardSlots[slotIndex];

                            return DragTarget<int>(
                              onAcceptWithDetails: (details) {
                                if (_isSolved || _isAutoAdvancing) return;
                                final pieceIndex = details.data;
                                setState(() {
                                  if (_boardSlots[slotIndex] != null) {
                                    _availablePieces.add(_boardSlots[slotIndex]!);
                                  }
                                  _boardSlots[slotIndex] = pieceIndex;
                                  _availablePieces.remove(pieceIndex);

                                  if (pieceIndex == slotIndex) {
                                    _teacherSpeech = '¡Muy bien! El número ${pieceIndex + 1} está en su lugar.';
                                  } else {
                                    _isTip = true;
                                    _teacherSpeech = 'Fíjate en el número: colocaste el #${pieceIndex + 1} en la casilla #${slotIndex + 1}.';
                                  }
                                  TeacherVoiceService.instance.speak(_teacherSpeech);

                                  _checkSolution();
                                });
                              },
                              builder: (context, candidateData, rejectedData) {
                                final isTargetHovered = candidateData.isNotEmpty;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: isTargetHovered
                                        ? Colors.green.shade100
                                        : (currentPiece != null
                                            ? AppColors.sunnyYellow.withValues(alpha: 0.35)
                                            : Colors.grey.shade100),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isTargetHovered
                                          ? AppColors.playfulGreen
                                          : (currentPiece != null
                                              ? AppColors.playfulGreen.withValues(alpha: 0.6)
                                              : Colors.grey.shade300),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: currentPiece != null
                                            ? Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _currentThemeIcons[currentPiece % _currentThemeIcons.length],
                                                    style: TextStyle(
                                                      fontSize: _gridDimension == 2
                                                          ? 42
                                                          : (_gridDimension == 3 ? 28 : 20),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '#${currentPiece + 1}',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                      color: AppColors.textDark,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Casilla',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade400,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    '#${slotIndex + 1}',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Piezas para arrastrar:',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 10),
                          _availablePieces.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      _isSolved
                                          ? '🎉 ¡Completado! Pasando al siguiente puzle...'
                                          : 'Todas las piezas fueron ubicadas',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.playfulGreen,
                                      ),
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: _availablePieces.map((pieceIndex) {
                                      final icon = _currentThemeIcons[pieceIndex % _currentThemeIcons.length];

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Draggable<int>(
                                          data: pieceIndex,
                                          feedback: Material(
                                            color: Colors.transparent,
                                            child: Container(
                                              width: 68,
                                              height: 68,
                                              decoration: BoxDecoration(
                                                color: AppColors.sunnyYellow,
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: const [
                                                  BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4))
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(icon, style: const TextStyle(fontSize: 34)),
                                              ),
                                            ),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.3,
                                            child: _PieceBox(pieceIndex: pieceIndex, icon: icon),
                                          ),
                                          child: _PieceBox(pieceIndex: pieceIndex, icon: icon),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieceBox extends StatelessWidget {
  final int pieceIndex;
  final String icon;

  const _PieceBox({required this.pieceIndex, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.sunnyYellow.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade400, width: 2),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 26)),
              Text(
                '#${pieceIndex + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
