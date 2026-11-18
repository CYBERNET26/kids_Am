import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/core/services/teacher_voice_service.dart';
import 'package:kids_am/core/widgets/teacher_bubble_widget.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/games/domain/models/game_level.dart';

class PuzzleGameScreen extends ConsumerStatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  ConsumerState<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends ConsumerState<PuzzleGameScreen> {
  late ConfettiController _confettiController;
  int _gridDimension = 2;
  late List<int?> _boardSlots;
  late List<int> _availablePieces;
  bool _isSolved = false;
  bool _isAutoAdvancing = false;
  String _themeTitle = '';
  List<String> _currentThemeIcons = [];
  String _teacherSpeech = '';
  bool _isTip = false;

  final Map<int, Map<String, dynamic>> _levelConfigs = {
    1: {
      'dim': 2,
      'title': 'Animales de la Granja 🐮',
      'icons': ['🐮', '🐷', '🐑', '🐔'],
      'speech': '¡Hola explorador! Arrastra cada animalito a su casilla en orden del 1 al 4.',
    },
    2: {
      'dim': 2,
      'title': 'Frutas Dulces 🍎',
      'icons': ['🍎', '🍌', '🍓', '🍇'],
      'speech': '¡Qué ricas frutas! Coloca cada fruta en su número correspondiente.',
    },
    3: {
      'dim': 3,
      'title': 'Animales de la Selva 🦁',
      'icons': ['🦁', '🐘', '🦒', '🐼', '🦊', '🐸', '🐯', '🐵', '🦉'],
      'speech': '¡Desafío de 9 piezas! Arrastra a los animales de la selva a cada casilla.',
    },
    4: {
      'dim': 3,
      'title': 'Exploración Espacial 🚀',
      'icons': ['🚀', '👨‍🚀', '🛸', '🪐', '⭐️', '🌕', '☄️', '🛰️', '👾'],
      'speech': '¡Viaje a las estrellas! Coloca cohetes y planetas en su orden numérico.',
    },
    5: {
      'dim': 4,
      'title': 'Maravillas del Océano 🐬',
      'icons': ['🐬', '🐳', '🐙', '🦀', '🐠', '🦈', '🐢', '🦭', '🦞', '🐚', '🌊', '🦑', '🐡', '🪸', '⚓️', '💎'],
      'speech': '¡Gran reto de 16 piezas submarinas! Tómate tu tiempo y busca cada casilla.',
    },
  };

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPuzzle();
    });
  }

  void _initPuzzle() {
    final profile = ref.read(childProfileProvider);
    final level = profile.puzzleLevel.clamp(1, 5);
    final config = _levelConfigs[level] ?? _levelConfigs[1]!;

    _gridDimension = config['dim'] as int;
    _themeTitle = config['title'] as String;
    _currentThemeIcons = List<String>.from(config['icons'] as List);
    _teacherSpeech = config['speech'] as String;

    final totalPieces = _gridDimension * _gridDimension;
    _boardSlots = List<int?>.filled(totalPieces, null);
    _availablePieces = List.generate(totalPieces, (index) => index)..shuffle();
    _isSolved = false;
    _isAutoAdvancing = false;
    _isTip = false;

    TeacherVoiceService.instance.speak(_teacherSpeech);
    setState(() {});
  }

  void _checkSolution() async {
    for (int i = 0; i < _boardSlots.length; i++) {
      if (_boardSlots[i] != i) {
        return;
      }
    }

    setState(() {
      _isSolved = true;
      _isAutoAdvancing = true;
      _isTip = false;
      _confettiController.play();
      _teacherSpeech = '¡Bravo! Completaste el rompecabezas de $_themeTitle. ¡Eres increíble! Pasemos al siguiente nivel.';
    });

    ref.read(childProfileProvider.notifier).recordWin(gameType: GameType.puzzle);

    // ESPERAR a que la maestra termine completamente de hablar
    await TeacherVoiceService.instance.speakAndWait(_teacherSpeech);

    // Pausa adicional para disfrutar el éxito
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
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
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: Text('Rompecabezas (Nivel ${profile.puzzleLevel}/5)'),
        backgroundColor: const Color(0xFF5CD85A),
        foregroundColor: Colors.white,
      ),
      body: Stack(
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
                // Globo de la Maestra Sofía
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
                        ),
                        child: Text(
                          _themeTitle,
                          style: TextStyle(
                            fontSize: 14,
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

                // Tablero de colocación (Drag Targets) - completamente contenido y centrado
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

                // Bandeja de piezas arrastrables
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
                                        ? '🎉 ¡Completado! Pasando de nivel...'
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
