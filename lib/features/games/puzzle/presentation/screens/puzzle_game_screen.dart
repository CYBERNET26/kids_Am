import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/games/domain/models/game_level.dart';

class PuzzleGameScreen extends ConsumerStatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  ConsumerState<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends ConsumerState<PuzzleGameScreen> {
  late ConfettiController _confettiController;
  int _gridDimension = 2; // 2x2 = 4 piezas por defecto para 6 años
  late List<int?> _boardSlots;
  late List<int> _availablePieces;
  bool _isSolved = false;

  final List<String> _animalIcons = ['🦁', '🐘', '🦒', '🐼', '🦊', '🐸', '🐯', '🐵', '🦉', '🦓', '🐨', '🐧', '🐙', '🦄', '🐬', '🐝'];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initPuzzle();
  }

  void _initPuzzle() {
    final profile = ref.read(childProfileProvider);
    // Nivel 1: 4 piezas (2x2), Nivel 2: 9 piezas (3x3), Nivel 3: 16 piezas (4x4)
    if (profile.puzzleLevel == 1) {
      _gridDimension = 2;
    } else if (profile.puzzleLevel == 2) {
      _gridDimension = 3;
    } else {
      _gridDimension = 4;
    }

    final totalPieces = _gridDimension * _gridDimension;
    _boardSlots = List<int?>.filled(totalPieces, null);
    _availablePieces = List.generate(totalPieces, (index) => index)..shuffle();
    _isSolved = false;
  }

  void _checkSolution() {
    for (int i = 0; i < _boardSlots.length; i++) {
      if (_boardSlots[i] != i) {
        return;
      }
    }
    setState(() {
      _isSolved = true;
      _confettiController.play();
      ref.read(childProfileProvider.notifier).recordWin(gameType: GameType.puzzle);
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
    final totalPieces = _gridDimension * _gridDimension;

    return Scaffold(
      appBar: AppBar(
        title: Text('Rompecabezas ($totalPieces Piezas - Nivel ${profile.puzzleLevel})'),
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'Arrastra cada animalito a su casilla correspondiente en orden (1, 2, 3...):',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Tablero de colocación (Drag Targets)
              Expanded(
                flex: 3,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                              final pieceIndex = details.data;
                              setState(() {
                                _boardSlots[slotIndex] = pieceIndex;
                                _availablePieces.remove(pieceIndex);
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
                                          ? AppColors.sunnyYellow.withValues(alpha: 0.3)
                                          : Colors.grey.shade100),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isTargetHovered
                                        ? AppColors.playfulGreen
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: currentPiece != null
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _animalIcons[currentPiece % _animalIcons.length],
                                              style: TextStyle(
                                                fontSize: _gridDimension == 2 ? 40 : 26,
                                              ),
                                            ),
                                            Text(
                                              '#${currentPiece + 1}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          'Casilla ${slotIndex + 1}',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
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
              ),

              // Bandeja de piezas arrastrables
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Piezas disponibles:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _availablePieces.isEmpty
                            ? Center(
                                child: _isSolved
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            '🎉 ¡Puzle completado con éxito! ⭐',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.playfulGreen,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _initPuzzle();
                                              });
                                            },
                                            child: const Text('Jugar de Nuevo'),
                                          ),
                                        ],
                                      )
                                    : const Text('¡Comprueba tus casillas!'),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _availablePieces.map((pieceIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Draggable<int>(
                                        data: pieceIndex,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: AppColors.sunnyYellow,
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 8,
                                                )
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                _animalIcons[pieceIndex % _animalIcons.length],
                                                style: const TextStyle(fontSize: 36),
                                              ),
                                            ),
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.3,
                                          child: _PieceBox(
                                            pieceIndex: pieceIndex,
                                            icon: _animalIcons[pieceIndex % _animalIcons.length],
                                          ),
                                        ),
                                        child: _PieceBox(
                                          pieceIndex: pieceIndex,
                                          icon: _animalIcons[pieceIndex % _animalIcons.length],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.sunnyYellow.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          Text('#${pieceIndex + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}

