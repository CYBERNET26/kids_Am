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

enum ChessPieceType { knight, rook, bishop, queen }

class ChessGameScreen extends ConsumerStatefulWidget {
  const ChessGameScreen({super.key});

  @override
  ConsumerState<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends ConsumerState<ChessGameScreen> {
  static const int boardSize = 4;
  static const int totalChessMissions = 100;
  late ConfettiController _confettiController;

  int _missionNumber = 1;
  bool _hasGreetedThisVisit = false;

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

  final List<String> _variedPrompts = [
    '¡Siguiente misión táctica! Busca el mejor camino hacia la gema dorada.',
    '¡Nuevo reto en el tablero! ¿Qué casilla te acerca a la gema?',
    '¡A mover las piezas con estrategia! Llega a la gema.',
    '¡Excelente ritmo! Encuentra la jugada correcta para ganar.',
    '¡Concentración! Mira las casillas verdes y planea tu avance.',
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadProgressAndStart();
  }

  Future<void> _loadProgressAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('chess_mission_index') ?? 1;
    if (mounted) {
      setState(() {
        _missionNumber = savedIndex.clamp(1, totalChessMissions);
      });
      _initMission();
    }
  }

  void _initMission() {
    final profile = ref.read(childProfileProvider);
    _obstacles.clear();
    _missionComplete = false;
    _isAutoAdvancing = false;
    _isTip = false;

    // MEZCLADO CONSTANTE: Cada misión alterna entre Caballo, Torre, Alfil y Reina
    _currentPieceType = ChessPieceType.values[(_missionNumber - 1) % ChessPieceType.values.length];

    final level = profile.chessLevel;
    final seed = _missionNumber + (level * 10);
    final random = Random(seed);

    // Posición inicial y objetivo según la pieza seleccionada
    switch (_currentPieceType) {
      case ChessPieceType.rook:
        _pieceRow = random.nextInt(4);
        _pieceCol = 0;
        _targetRow = (_pieceRow + (random.nextBool() ? 0 : 2)) % 4;
        _targetCol = 3;
        if (level >= 2) _obstacles.add('$_pieceRow,2');
        if (level >= 3) _obstacles.add('${(_pieceRow + 1) % 4},1');
        break;

      case ChessPieceType.bishop:
        _pieceRow = random.nextBool() ? 0 : 1;
        _pieceCol = random.nextBool() ? 0 : 1;
        _targetRow = (_pieceRow == 0) ? 3 : 2;
        _targetCol = (_pieceCol == 0) ? 3 : 2;
        if (level >= 2) _obstacles.add('1,2');
        if (level >= 3) _obstacles.add('2,1');
        break;

      case ChessPieceType.knight:
        _pieceRow = random.nextInt(3);
        _pieceCol = 0;
        _targetRow = (_pieceRow + 1).clamp(0, 3);
        _targetCol = (random.nextBool() ? 2 : 3);
        if (level >= 2) _obstacles.add('1,1');
        if (level >= 3) _obstacles.add('2,2');
        break;

      case ChessPieceType.queen:
        _pieceRow = random.nextInt(2);
        _pieceCol = random.nextInt(2);
        _targetRow = 3;
        _targetCol = random.nextInt(4);
        if (level >= 2) _obstacles.add('1,2');
        if (level >= 3) _obstacles.add('2,1');
        break;
    }

    // Asegurar que inicio y meta no sean obstáculos
    _obstacles.remove('$_pieceRow,$_pieceCol');
    _obstacles.remove('$_targetRow,$_targetCol');

    // Solo saluda al niño por única vez en la visita
    if (!_hasGreetedThisVisit) {
      _hasGreetedThisVisit = true;
      _teacherSpeech = '¡Hola ${profile.name}! Bienvenido a Mini-Ajedrez Nivel $level. Mueve ${_getPieceName()} hasta la gema dorada en la misión $_missionNumber.';
    } else {
      _teacherSpeech = _variedPrompts[random.nextInt(_variedPrompts.length)];
    }

    TeacherVoiceService.instance.speak(_teacherSpeech);
    setState(() {});
  }

  String _getPieceName() {
    switch (_currentPieceType) {
      case ChessPieceType.rook:
        return 'tu Torre 🏰';
      case ChessPieceType.bishop:
        return 'tu Alfil 🧙‍♂️';
      case ChessPieceType.knight:
        return 'tu Caballo 🐴';
      case ChessPieceType.queen:
        return 'tu Reina 👑';
    }
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
        if (_pieceRow == toRow) {
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
        return (dRow == 1 && dCol == 2) || (dRow == 2 && dCol == 1);

      case ChessPieceType.queen:
        final isStraight = (_pieceRow == toRow || _pieceCol == toCol);
        final isDiag = (dRow == dCol);
        if (!isStraight && !isDiag) return false;

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

  void _onTileTapped(int row, int col) async {
    if (_missionComplete || _isAutoAdvancing) return;

    if (_isValidMove(row, col)) {
      setState(() {
        _pieceRow = row;
        _pieceCol = col;
        _isTip = false;
      });

      if (_pieceRow == _targetRow && _pieceCol == _targetCol) {
        final profile = ref.read(childProfileProvider);
        final isFinalOfLevel = _missionNumber >= totalChessMissions;

        setState(() {
          _missionComplete = true;
          _isAutoAdvancing = true;
          _confettiController.play();

          if (isFinalOfLevel) {
            _teacherSpeech = '¡Increíble maestría ${profile.name}! ¡Completaste las 100 misiones del Nivel ${profile.chessLevel}! ¡Avanzas al Nivel ${profile.chessLevel + 1} de ajedrez!';
          } else {
            _teacherSpeech = '¡Excelente jugada! Llegaste a la gema mágica y ganaste una estrella. ¡Felicitaciones!';
          }
        });

        ref.read(childProfileProvider.notifier).recordWin(gameType: GameType.chess);

        int nextMission;
        if (isFinalOfLevel) {
          ref.read(childProfileProvider.notifier).advanceLevel(GameType.chess);
          nextMission = 1;
        } else {
          nextMission = _missionNumber + 1;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('chess_mission_index', nextMission);

        await TeacherVoiceService.instance.speakAndWait(_teacherSpeech);
        await Future.delayed(const Duration(milliseconds: 1000));

        if (mounted) {
          setState(() {
            _missionNumber = nextMission;
          });
          _initMission();
        }
      } else {
        setState(() {
          _teacherSpeech = '¡Buen paso! Ahora busca el siguiente movimiento para llegar a la gema.';
        });
        TeacherVoiceService.instance.speak(_teacherSpeech);
      }
    } else {
      setState(() {
        _isTip = true;
        switch (_currentPieceType) {
          case ChessPieceType.rook:
            _teacherSpeech = 'La Torre solo camina derecho hacia adelante, atrás o a los lados. ¡Toca un punto verde!';
            break;
          case ChessPieceType.bishop:
            _teacherSpeech = 'El Alfil solo camina en diagonal por casillas del mismo color. ¡Mira las casillas sugeridas!';
            break;
          case ChessPieceType.knight:
            _teacherSpeech = 'El caballo salta en forma de L: dos pasos y dobla uno. ¡Toca una de las casillas con punto verde!';
            break;
          case ChessPieceType.queen:
            _teacherSpeech = 'La reina puede ir recto o en diagonal, pero sin atravesar rocas. ¡Busca un camino libre!';
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
      appBar: AppBar(
        title: Text('Mini-Ajedrez (Nivel ${profile.chessLevel})'),
        backgroundColor: const Color(0xFF8E44AD),
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(
                            'Nivel ${profile.chessLevel} • Misión $_missionNumber/100 🏆',
                            style: TextStyle(
                              fontSize: 13,
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withValues(alpha: 0.15),
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

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.brown.shade800, width: 4),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
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
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(alpha: 0.75),
                                              shape: BoxShape.circle,
                                              boxShadow: const [
                                                BoxShadow(color: Colors.white, blurRadius: 4)
                                              ],
                                            ),
                                          ),
                                        if (isObstacle)
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: const Text('🪨', style: TextStyle(fontSize: 32)),
                                            ),
                                          ),
                                        if (isTargetHere && !_missionComplete)
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: const Text('💎', style: TextStyle(fontSize: 32)),
                                            ),
                                          ),
                                        if (isPieceHere)
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                _getPieceEmoji(),
                                                style: const TextStyle(fontSize: 38),
                                              ),
                                            ),
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
                          '¡Misión Cumplida! Avanzando...',
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
