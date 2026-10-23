import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/games/domain/models/game_level.dart';

class ChessGameScreen extends ConsumerStatefulWidget {
  const ChessGameScreen({super.key});

  @override
  ConsumerState<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends ConsumerState<ChessGameScreen> {
  static const int boardSize = 4;
  late ConfettiController _confettiController;
  int _pieceRow = 0;
  int _pieceCol = 0;
  int _targetRow = 3;
  int _targetCol = 3;
  bool _isKnight = false; // Alterna entre Torre (rectas) y Caballo (L)
  bool _missionComplete = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initMission();
  }

  void _initMission() {
    final profile = ref.read(childProfileProvider);
    _isKnight = profile.chessLevel > 2; // Nivel 1 y 2: Torre; Nivel 3+: Caballo
    _pieceRow = 0;
    _pieceCol = 0;
    _targetRow = 3;
    _targetCol = _isKnight ? 2 : 3;
    _missionComplete = false;
  }

  bool _isValidMove(int toRow, int toCol) {
    if (_isKnight) {
      // Movimiento de caballo en L
      final dRow = (toRow - _pieceRow).abs();
      final dCol = (toCol - _pieceCol).abs();
      return (dRow == 1 && dCol == 2) || (dRow == 2 && dCol == 1);
    } else {
      // Movimiento de Torre (filas o columnas rectas)
      return (_pieceRow == toRow && _pieceCol != toCol) ||
          (_pieceCol == toCol && _pieceRow != toRow);
    }
  }

  void _onTileTapped(int row, int col) {
    if (_missionComplete) return;

    if (_isValidMove(row, col)) {
      setState(() {
        _pieceRow = row;
        _pieceCol = col;

        if (_pieceRow == _targetRow && _pieceCol == _targetCol) {
          _missionComplete = true;
          _confettiController.play();
          ref.read(childProfileProvider.notifier).recordWin(gameType: GameType.chess);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isKnight
                ? '🐴 El caballo se mueve en "L" (2 casillas y 1 al lado).'
                : '🏰 La Torre solo se mueve en línea recta (arriba, abajo, izquierda, derecha).',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
        title: Text('Mini-Ajedrez 4x4 (Nivel ${profile.chessLevel})'),
        backgroundColor: const Color(0xFF8E44AD),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isKnight ? Icons.pets : Icons.castle,
                        size: 36,
                        color: AppColors.magicPurple,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isKnight
                              ? 'Misión Caballo: Llega a la gema dorada 💎 moviéndote en forma de L.'
                              : 'Misión Torre: Llega a la gema dorada 💎 moviéndote en línea recta.',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tablero 4x4
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.brown.shade800, width: 4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: boardSize,
                          ),
                          itemCount: boardSize * boardSize,
                          itemBuilder: (context, index) {
                            final row = index ~/ boardSize;
                            final col = index % boardSize;
                            final isLight = (row + col) % 2 == 0;
                            final isPieceHere = row == _pieceRow && col == _pieceCol;
                            final isTargetHere = row == _targetRow && col == _targetCol;
                            final isValidTarget = _isValidMove(row, col);

                            return GestureDetector(
                              onTap: () => _onTileTapped(row, col),
                              child: Container(
                                color: isLight ? const Color(0xFFF0D9B5) : const Color(0xFFB58863),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (isValidTarget && !_missionComplete)
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.6),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    if (isTargetHere && !_missionComplete)
                                      const Text('💎', style: TextStyle(fontSize: 34)),
                                    if (isPieceHere)
                                      Text(
                                        _isKnight ? '🐴' : '🏰',
                                        style: const TextStyle(fontSize: 40),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                if (_missionComplete) ...[
                  const Text(
                    '🎉 ¡Misión Cumplida! ¡Eres un estratega genial! ⭐',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.playfulGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.magicPurple,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _initMission();
                      });
                    },
                    child: const Text('Jugar Otro Nivel'),
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

