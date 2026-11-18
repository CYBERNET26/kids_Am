import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/core/services/teacher_voice_service.dart';
import 'package:kids_am/core/widgets/teacher_bubble_widget.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/games/domain/models/game_level.dart';

enum ChessPieceType { rook, bishop, knight, queen }

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
  final Set<String> _obstacles = {};
  late ChessPieceType _currentPieceType;
  bool _missionComplete = false;
  bool _isAutoAdvancing = false;
  String _teacherSpeech = '';
  bool _isTip = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMission();
    });
  }

  void _initMission() {
    final profile = ref.read(childProfileProvider);
    _obstacles.clear();
    _missionComplete = false;
    _isAutoAdvancing = false;
    _isTip = false;

    final level = profile.chessLevel;
    // Configuración según los 6 niveles
    switch (level) {
      case 1:
        // Nivel 1: Torre directa
        _currentPieceType = ChessPieceType.rook;
        _pieceRow = 0;
        _pieceCol = 0;
        _targetRow = 0;
        _targetCol = 3;
        _teacherSpeech = '¡Hola pequeño gran maestro! Esta es la Torre 🏰. Se mueve en línea recta. ¡Muévela hacia la gema dorada!';
        break;
      case 2:
        // Nivel 2: Torre con obstáculo en el centro
        _currentPieceType = ChessPieceType.rook;
        _pieceRow = 0;
        _pieceCol = 0;
        _targetRow = 3;
        _targetCol = 3;
        _obstacles.add('0,2'); // Muro
        _teacherSpeech = '¡Cuidado! Hay una roca en el camino. Mueve tu Torre hacia abajo y luego hacia la gema.';
        break;
      case 3:
        // Nivel 3: Alfil en diagonal
        _currentPieceType = ChessPieceType.bishop;
        _pieceRow = 0;
        _pieceCol = 0;
        _targetRow = 3;
        _targetCol = 3;
        _teacherSpeech = '¡Ahora aprenderemos con el Alfil 🧙‍♂️! El Alfil se desliza únicamente en diagonal como una X. ¡Alcanza la gema!';
        break;
      case 4:
        // Nivel 4: Caballo en L directo
        _currentPieceType = ChessPieceType.knight;
        _pieceRow = 0;
        _pieceCol = 0;
        _targetRow = 1;
        _targetCol = 2;
        _teacherSpeech = '¡Llegó el Caballo 🐴! El caballo da saltos mágicos en forma de letra L: dos pasos y uno al costado.';
        break;
      case 5:
        // Nivel 5: Caballo en dos saltos esquivando roca
        _currentPieceType = ChessPieceType.knight;
        _pieceRow = 0;
        _pieceCol = 0;
        _targetRow = 2;
        _targetCol = 3;
        _obstacles.add('1,1');
        _teacherSpeech = '¡Misión avanzada de Caballo! Debes hacer dos saltos en L para rodear la montaña y capturar la gema.';
        break;
      default:
        // Nivel 6+: La Reina
        _currentPieceType = ChessPieceType.queen;
        _pieceRow = 0;
        _pieceCol = 1;
        _targetRow = 3;
        _targetCol = 2;
        _obstacles.add('1,2');
        _teacherSpeech = '¡La Reina 👑 es la pieza más poderosa! Puede moverse en línea recta como la Torre o en diagonal como el Alfil.';
        break;
    }

    TeacherVoiceService.instance.speak(_teacherSpeech);
    setState(() {});
  }

  bool _isBlocked(int toRow, int toCol) {
    return _obstacles.contains('$toRow,$toCol');
  }

  bool _isValidMove(int toRow, int toCol) {
    if (toRow == _pieceRow && toCol == _pieceCol) return false;
    if (_isBlocked(toRow, toCol)) return false;

    final dRow = (toRow - _pieceRow).abs();
    final dCol = (toCol - _pieceCol).abs();

    switch (_currentPieceType) {
      case ChessPieceType.rook:
        // Misma fila o misma columna
        if (_pieceRow == toRow) {
          // Chequear obstáculos en el trayecto
          final minC = _pieceCol < toCol ? _pieceCol : toCol;
          final maxC = _pieceCol > toCol ? _pieceCol : toCol;
          for (int c = minC + 1; c < maxC; c++) {
            if (_isBlocked(_pieceRow, c)) return false;
          }
          return true;
        } else if (_pieceCol == toCol) {
          final minR = _pieceRow < toRow ? _pieceRow : toRow;
          final maxR = _pieceRow > toRow ? _pieceRow : toRow;
          for (int r = minR + 1; r < maxR; r++) {
            if (_isBlocked(r, _pieceCol)) return false;
          }
          return true;
        }
        return false;

      case ChessPieceType.bishop:
        // Diagonal dRow == dCol
        if (dRow == dCol && dRow > 0) {
          final stepR = toRow > _pieceRow ? 1 : -1;
          final stepC = toCol > _pieceCol ? 1 : -1;
          int curR = _pieceRow + stepR;
          int curC = _pieceCol + stepC;
          while (curR != toRow && curC != toCol) {
            if (_isBlocked(curR, curC)) return false;
            curR += stepR;
            curC += stepC;
          }
          return true;
        }
        return false;

      case ChessPieceType.knight:
        // Salto en L (puede saltar por encima de obstáculos)
        return (dRow == 1 && dCol == 2) || (dRow == 2 && dCol == 1);

      case ChessPieceType.queen:
        // Torre o Alfil
        final isStraight = (_pieceRow == toRow || _pieceCol == toCol);
        final isDiag = (dRow == dCol);
        if (!isStraight && !isDiag) return false;

        // Comprobación de camino libre
        final stepR = (toRow - _pieceRow) == 0 ? 0 : ((toRow - _pieceRow) > 0 ? 1 : -1);
        final stepC = (toCol - _pieceCol) == 0 ? 0 : ((toCol - _pieceCol) > 0 ? 1 : -1);
        int curR = _pieceRow + stepR;
        int curC = _pieceCol + stepC;
        while (curR != toRow || curC != toCol) {
          if (_isBlocked(curR, curC)) return false;
          curR += stepR;
          curC += stepC;
        }
        return true;
    }
  }

  void _onTileTapped(int row, int col) {
    if (_missionComplete || _isAutoAdvancing) return;

    if (_isValidMove(row, col)) {
      setState(() {
        _pieceRow = row;
        _pieceCol = col;
        _isTip = false;

        if (_pieceRow == _targetRow && _pieceCol == _targetCol) {
          _missionComplete = true;
          _isAutoAdvancing = true;
          _confettiController.play();

          _teacherSpeech = '¡Excelente jugada! ¡Llegaste a la gema mágica y ganaste una estrella! Pasemos al siguiente reto de ajedrez.';
          TeacherVoiceService.instance.speak(_teacherSpeech);

          ref.read(childProfileProvider.notifier).recordWin(gameType: GameType.chess);

          Future.delayed(const Duration(milliseconds: 2400), () {
            if (mounted) {
              _initMission();
            }
          });
        } else {
          _teacherSpeech = '¡Buen paso! Ahora busca el siguiente movimiento para acercarte a la gema.';
          TeacherVoiceService.instance.speak(_teacherSpeech);
        }
      });
    } else {
      setState(() {
        _isTip = true;
        // Explicación pedagógica alternativa si erra
        switch (_currentPieceType) {
          case ChessPieceType.rook:
            _teacherSpeech = 'La Torre solo puede caminar hacia adelante, atrás, izquierda o derecha en línea recta. ¡Toca una casilla con punto verde!';
            break;
          case ChessPieceType.bishop:
            _teacherSpeech = 'El Alfil solo camina en diagonal por las casillas de su mismo color. ¡Mira los puntos verdes sugeridos!';
            break;
          case ChessPieceType.knight:
            _teacherSpeech = 'El caballo dibuja una letra L: camina dos casillas y dobla una. ¡Intenta tocar una de las casillas marcadas!';
            break;
          case ChessPieceType.queen:
            _teacherSpeech = 'La reina puede ir recto o en diagonal, pero no puede atravesar rocas. ¡Busca un camino libre!';
            break;
        }
      });
      TeacherVoiceService.instance.speak(_teacherSpeech);
    }
  }

  String _getPieceEmoji() {
    switch (_currentPieceType) {
      case ChessPieceType.rook:
        return '🏰';
      case ChessPieceType.bishop:
        return '🧙‍♂️';
      case ChessPieceType.knight:
        return '🐴';
      case ChessPieceType.queen:
        return '👑';
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
        title: Text('Mini-Ajedrez (Nivel ${profile.chessLevel}/6)'),
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
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                // Globo de la Maestra
                TeacherBubbleWidget(
                  speechText: _teacherSpeech,
                  isCelebration: _missionComplete,
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
                          'Misión ${profile.chessLevel} de 6 🏆',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade800,
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

                // Tablero 4x4
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.brown.shade800, width: 4),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
                              final isObstacle = _obstacles.contains('$row,$col');
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
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.7),
                                            shape: BoxShape.circle,
                                            boxShadow: const [
                                              BoxShadow(color: Colors.white, blurRadius: 4)
                                            ],
                                          ),
                                        ),
                                      if (isObstacle)
                                        const Text('🪨', style: TextStyle(fontSize: 32)),
                                      if (isTargetHere && !_missionComplete)
                                        const Text('💎', style: TextStyle(fontSize: 34)),
                                      if (isPieceHere)
                                        Text(
                                          _getPieceEmoji(),
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
                ),

                if (_isAutoAdvancing) ...[
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.playfulGreen, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '¡Misión Cumplida! Pasando al siguiente reto...',
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
