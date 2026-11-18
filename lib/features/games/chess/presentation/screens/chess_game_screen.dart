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

enum ChessPieceType { king, queen, rook, bishop, knight, pawn }

class BoardPiece {
  final ChessPieceType type;
  final bool isWhite;

  const BoardPiece({required this.type, required this.isWhite});

  String get symbol {
    if (isWhite) {
      switch (type) {
        case ChessPieceType.king:
          return '♔';
        case ChessPieceType.queen:
          return '♕';
        case ChessPieceType.rook:
          return '♖';
        case ChessPieceType.bishop:
          return '♗';
        case ChessPieceType.knight:
          return '♘';
        case ChessPieceType.pawn:
          return '♙';
      }
    } else {
      switch (type) {
        case ChessPieceType.king:
          return '♚';
        case ChessPieceType.queen:
          return '♛';
        case ChessPieceType.rook:
          return '♜';
        case ChessPieceType.bishop:
          return '♝';
        case ChessPieceType.knight:
          return '♞';
        case ChessPieceType.pawn:
          return '♟';
      }
    }
  }

  String get name {
    switch (type) {
      case ChessPieceType.king:
        return 'Rey';
      case ChessPieceType.queen:
        return 'Dama 👑';
      case ChessPieceType.rook:
        return 'Torre 🏰';
      case ChessPieceType.bishop:
        return 'Alfil 🧙‍♂️';
      case ChessPieceType.knight:
        return 'Caballo 🐴';
      case ChessPieceType.pawn:
        return 'Peón 🛡️';
    }
  }
}

class MateInOnePuzzle {
  final String title;
  final String hint;
  final Map<String, BoardPiece> pieces; // "row,col" -> BoardPiece
  final int moveFromRow;
  final int moveFromCol;
  final int targetRow;
  final int targetCol;

  const MateInOnePuzzle({
    required this.title,
    required this.hint,
    required this.pieces,
    required this.moveFromRow,
    required this.moveFromCol,
    required this.targetRow,
    required this.targetCol,
  });
}

class ChessGameScreen extends ConsumerStatefulWidget {
  const ChessGameScreen({super.key});

  @override
  ConsumerState<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends ConsumerState<ChessGameScreen> {
  static const int boardSize = 8;
  static const int totalChessMissions = 100;
  late ConfettiController _confettiController;

  int _missionNumber = 1;
  bool _hasGreetedThisVisit = false;

  // Estado del tablero
  final Map<String, BoardPiece> _boardPieces = {};
  int? _selectedRow;
  int? _selectedCol;
  final Set<String> _validMovesForSelected = {};
  final Set<String> _obstacles = {}; // Para niveles 1 a 3

  // Modo Mate en 1 (a partir de nivel 4)
  bool _isMateInOneMode = false;
  MateInOnePuzzle? _currentMatePuzzle;

  // Para niveles 1-3 (capturar o llegar a meta)
  int _targetRow = 7;
  int _targetCol = 7;
  ChessPieceType _activePieceType = ChessPieceType.rook;

  bool _missionComplete = false;
  bool _isAutoAdvancing = false;
  String _teacherSpeech = '';
  bool _isTip = false;

  // Columnas A-H y Filas 8-1
  final List<String> _colLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  final List<String> _rowLabels = ['8', '7', '6', '5', '4', '3', '2', '1'];

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
    final level = profile.chessLevel;
    _isMateInOneMode = level >= 4;

    _boardPieces.clear();
    _obstacles.clear();
    _selectedRow = null;
    _selectedCol = null;
    _validMovesForSelected.clear();
    _missionComplete = false;
    _isAutoAdvancing = false;
    _isTip = false;

    if (_isMateInOneMode) {
      _setupMateInOnePuzzle(level);
    } else {
      _setupTrainingMission(level);
    }

    TeacherVoiceService.instance.speak(_teacherSpeech);
    setState(() {});
  }

  void _setupTrainingMission(int level) {
    final profile = ref.read(childProfileProvider);
    final random = Random(_missionNumber * 37 + level * 11);

    // Alternar tipo de pieza a entrenar (Caballo, Torre, Alfil, Reina, Peón)
    final pieceTypes = [
      ChessPieceType.knight,
      ChessPieceType.rook,
      ChessPieceType.bishop,
      ChessPieceType.queen,
      ChessPieceType.pawn,
    ];
    _activePieceType = pieceTypes[(_missionNumber - 1) % pieceTypes.length];

    // Posición inicial y meta en tablero 8x8 con dificultad gradual
    int pRow = 7;
    int pCol = random.nextInt(8);
    int tRow = 0;
    int tCol = random.nextInt(8);

    // Ajuste de posiciones según la pieza para que sea alcanzable
    if (_activePieceType == ChessPieceType.pawn) {
      pRow = 6;
      pCol = random.nextInt(8);
      tRow = pRow - (level == 1 ? 1 : 2).clamp(1, 4);
      tCol = pCol;
    } else if (_activePieceType == ChessPieceType.knight) {
      pRow = 6;
      pCol = random.nextInt(6) + 1;
      final jumps = level == 1 ? 1 : (level == 2 ? 2 : 3);
      tRow = (pRow - (2 * jumps)).clamp(0, 7);
      tCol = (pCol + (random.nextBool() ? 1 : -1) * jumps).clamp(0, 7);
      if (tRow == pRow && tCol == pCol) {
        tRow = (pRow - 2).clamp(0, 7);
        tCol = (pCol + 1).clamp(0, 7);
      }
    } else if (_activePieceType == ChessPieceType.bishop) {
      pRow = 6;
      pCol = (random.nextInt(4) * 2); // casilla blanca o negra
      final isLight = (pRow + pCol) % 2 == 0;
      // Escoger meta del mismo color
      tRow = random.nextInt(3);
      tCol = random.nextInt(8);
      if (((tRow + tCol) % 2 == 0) != isLight) {
        tCol = (tCol + 1) % 8;
      }
    } else {
      // Torre o Reina
      pRow = random.nextInt(3) + 5;
      pCol = random.nextInt(8);
      tRow = random.nextInt(4);
      tCol = (_activePieceType == ChessPieceType.rook) ? pCol : random.nextInt(8);
    }

    _targetRow = tRow;
    _targetCol = tCol;

    _boardPieces['$pRow,$pCol'] = BoardPiece(type: _activePieceType, isWhite: true);

    // Generar obstáculos según nivel (1-2 en nivel 1; 3-4 en nivel 2; 5-6 en nivel 3)
    final numObstacles = level == 1 ? (1 + (_missionNumber ~/ 40)) : (level * 2);
    for (int i = 0; i < numObstacles; i++) {
      final obsR = random.nextInt(8);
      final obsC = random.nextInt(8);
      if ((obsR != pRow || obsC != pCol) && (obsR != tRow || obsC != tCol)) {
        _obstacles.add('$obsR,$obsC');
      }
    }

    if (!_hasGreetedThisVisit) {
      _hasGreetedThisVisit = true;
      _teacherSpeech =
          '¡Hola ${profile.name}! Bienvenido a Ajedrez 8x8 Nivel $level. Mueve tu ${_boardPieces['$pRow,$pCol']!.name} hasta la gema dorada en la casilla ${_colLabels[_targetCol]}${_rowLabels[_targetRow]}.';
    } else {
      _teacherSpeech =
          '¡Misión $_missionNumber! Mueve tu ${_boardPieces['$pRow,$pCol']!.name} hasta la gema dorada en ${_colLabels[_targetCol]}${_rowLabels[_targetRow]}.';
    }
  }

  void _setupMateInOnePuzzle(int level) {
    final profile = ref.read(childProfileProvider);

    // Banco de problemas de Mate en 1 reales en tablero 8x8
    final matePuzzlesBank = [
      // 1. Mate del Pasillo con Torre
      MateInOnePuzzle(
        title: 'Mate del Pasillo 🏰',
        hint: 'Lleva tu Torre blanca a la fila 8 para encerrar al Rey negro detrás de sus peones.',
        pieces: {
          '0,6': const BoardPiece(type: ChessPieceType.king, isWhite: false), // ♚ en g8
          '1,5': const BoardPiece(type: ChessPieceType.pawn, isWhite: false), // ♟ en f7
          '1,6': const BoardPiece(type: ChessPieceType.pawn, isWhite: false), // ♟ en g7
          '1,7': const BoardPiece(type: ChessPieceType.pawn, isWhite: false), // ♟ en h7
          '6,0': const BoardPiece(type: ChessPieceType.king, isWhite: true), // ♔ en a2
          '6,3': const BoardPiece(type: ChessPieceType.rook, isWhite: true), // ♖ en d2
        },
        moveFromRow: 6,
        moveFromCol: 3,
        targetRow: 0,
        targetCol: 3, // ♖d8#
      ),

      // 2. Mate del Pastor con Dama
      MateInOnePuzzle(
        title: 'Mate del Pastor 👑',
        hint: 'Tu Dama puede capturar el peón de f7 con la protección del Alfil y dar Jaque Mate.',
        pieces: {
          '0,4': const BoardPiece(type: ChessPieceType.king, isWhite: false), // ♚ en e8
          '1,4': const BoardPiece(type: ChessPieceType.pawn, isWhite: false), // ♟ en e7
          '1,5': const BoardPiece(type: ChessPieceType.pawn, isWhite: false), // ♟ en f7
          '4,2': const BoardPiece(type: ChessPieceType.bishop, isWhite: true), // ♗ en c4
          '5,7': const BoardPiece(type: ChessPieceType.queen, isWhite: true), // ♕ en h3
          '7,4': const BoardPiece(type: ChessPieceType.king, isWhite: true), // ♔ en e1
        },
        moveFromRow: 5,
        moveFromCol: 7,
        targetRow: 1,
        targetCol: 5, // ♕xf7#
      ),

      // 3. Beso de la Muerte con Dama y Rey
      MateInOnePuzzle(
        title: 'El Beso de la Muerte 💋',
        hint: 'Coloca tu Dama justo al lado del Rey negro con el respaldo de tu propio Rey.',
        pieces: {
          '0,7': const BoardPiece(type: ChessPieceType.king, isWhite: false), // ♚ en h8
          '1,6': const BoardPiece(type: ChessPieceType.pawn, isWhite: false), // ♟ en g7
          '2,7': const BoardPiece(type: ChessPieceType.king, isWhite: true), // ♔ en h6
          '4,0': const BoardPiece(type: ChessPieceType.queen, isWhite: true), // ♕ en a4
        },
        moveFromRow: 4,
        moveFromCol: 0,
        targetRow: 1,
        targetCol: 7, // ♕g7#
      ),

      // 4. Mate de Anastasia (Caballo y Torre)
      MateInOnePuzzle(
        title: 'Mate de Anastasia 🐴',
        hint: 'El caballo negro bloquea la salida y la Torre blanca ataca la columna abierta.',
        pieces: {
          '0,7': const BoardPiece(type: ChessPieceType.king, isWhite: false), // ♚ en h8
          '1,6': const BoardPiece(type: ChessPieceType.pawn, isWhite: false), // ♟ en g7
          '3,4': const BoardPiece(type: ChessPieceType.knight, isWhite: true), // ♘ en e5
          '6,0': const BoardPiece(type: ChessPieceType.rook, isWhite: true), // ♖ en a2
          '7,2': const BoardPiece(type: ChessPieceType.king, isWhite: true), // ♔ en c1
        },
        moveFromRow: 6,
        moveFromCol: 0,
        targetRow: 6,
        targetCol: 7, // ♖h2#
      ),

      // 5. Mate de la Escalera con Dos Torres
      MateInOnePuzzle(
        title: 'Mate de la Escalera 🪜',
        hint: 'Una torre controla la fila 7. ¡Envía tu otra torre a la fila 8 para ganar!',
        pieces: {
          '0,3': const BoardPiece(type: ChessPieceType.king, isWhite: false), // ♚ en d8
          '1,0': const BoardPiece(type: ChessPieceType.rook, isWhite: true), // ♖ en a7 (corta fila 7)
          '5,7': const BoardPiece(type: ChessPieceType.rook, isWhite: true), // ♖ en h3
          '7,4': const BoardPiece(type: ChessPieceType.king, isWhite: true), // ♔ en e1
        },
        moveFromRow: 5,
        moveFromCol: 7,
        targetRow: 0,
        targetCol: 7, // ♖h8#
      ),

      // 6. Mate con Caballo Ahogado (Mate de la Coz)
      MateInOnePuzzle(
        title: 'Salto Mágico de Caballo 🦄',
        hint: 'El Rey negro está atrapado por sus propias piezas. Da jaque con tu caballo.',
        pieces: {
          '0,7': const BoardPiece(type: ChessPieceType.king, isWhite: false), // ♚ en h8
          '0,6': const BoardPiece(type: ChessPieceType.rook, isWhite: false), // ♜ en g8
          '1,7': const BoardPiece(type: ChessPieceType.pawn, isWhite: false), // ♟ en h7
          '1,6': const BoardPiece(type: ChessPieceType.pawn, isWhite: false), // ♟ en g7
          '2,5': const BoardPiece(type: ChessPieceType.knight, isWhite: true), // ♘ en f6
          '7,0': const BoardPiece(type: ChessPieceType.king, isWhite: true), // ♔ en a1
        },
        moveFromRow: 2,
        moveFromCol: 5,
        targetRow: 1,
        targetCol: 7, // ♘f7#
      ),

      // 7. Mate con Alfil y Dama
      MateInOnePuzzle(
        title: 'Ataque en Diagonal 🧙‍♂️',
        hint: 'Usa tu Dama en la gran diagonal apoyada por tu Alfil para dar jaque mate en g7.',
        pieces: {
          '0,6': const BoardPiece(type: ChessPieceType.king, isWhite: false), // ♚ en g8
          '1,5': const BoardPiece(type: ChessPieceType.pawn, isWhite: false), // ♟ en f7
          '1,7': const BoardPiece(type: ChessPieceType.pawn, isWhite: false), // ♟ en h7
          '5,1': const BoardPiece(type: ChessPieceType.bishop, isWhite: true), // ♗ en b3
          '4,6': const BoardPiece(type: ChessPieceType.queen, isWhite: true), // ♕ en g4
          '7,4': const BoardPiece(type: ChessPieceType.king, isWhite: true), // ♔ en e1
        },
        moveFromRow: 4,
        moveFromCol: 6,
        targetRow: 1,
        targetCol: 6, // ♕g7#
      ),

      // 8. Mate de Bodén (Doble Alfil)
      MateInOnePuzzle(
        title: 'Cruce de Alfiles ⚔️',
        hint: 'Tus dos alfiles cruzan sus rayos. Lleva tu Alfil a la diagonal descubierta.',
        pieces: {
          '0,2': const BoardPiece(type: ChessPieceType.king, isWhite: false), // ♚ en c8
          '0,3': const BoardPiece(type: ChessPieceType.rook, isWhite: false), // ♜ en d8
          '1,1': const BoardPiece(type: ChessPieceType.pawn, isWhite: false), // ♟ en b7
          '1,2': const BoardPiece(type: ChessPieceType.pawn, isWhite: false), // ♟ en c7
          '4,7': const BoardPiece(type: ChessPieceType.bishop, isWhite: true), // ♗ en h4
          '5,0': const BoardPiece(type: ChessPieceType.bishop, isWhite: true), // ♗ en a3
          '7,4': const BoardPiece(type: ChessPieceType.king, isWhite: true), // ♔ en e1
        },
        moveFromRow: 5,
        moveFromCol: 0,
        targetRow: 2,
        targetCol: 5, // ♗a6#
      ),
    ];

    final puzzleIndex = (_missionNumber - 1) % matePuzzlesBank.length;
    _currentMatePuzzle = matePuzzlesBank[puzzleIndex];

    _boardPieces.addAll(_currentMatePuzzle!.pieces);

    if (!_hasGreetedThisVisit) {
      _hasGreetedThisVisit = true;
      _teacherSpeech =
          '¡Hola ${profile.name}! Bienvenido a Táctica de Ajedrez Nivel $level. ¡Encuentra el Jaque Mate en 1 jugada! ${_currentMatePuzzle!.title}.';
    } else {
      _teacherSpeech =
          '¡Desafío de Mate en 1! ${_currentMatePuzzle!.title}. ${_currentMatePuzzle!.hint}';
    }
  }

  void _onTileTapped(int row, int col) async {
    if (_missionComplete || _isAutoAdvancing) return;

    final clickedKey = '$row,$col';
    final clickedPiece = _boardPieces[clickedKey];

    // Si toca una de sus piezas blancas: seleccionarla y calcular casillas válidas
    if (clickedPiece != null && clickedPiece.isWhite) {
      setState(() {
        _selectedRow = row;
        _selectedCol = col;
        _validMovesForSelected.clear();
        _calculateValidMoves(row, col, clickedPiece.type);
      });
      return;
    }

    // Si ya tiene una pieza seleccionada y toca una casilla válida: mover
    if (_selectedRow != null && _selectedCol != null) {
      if (_validMovesForSelected.contains(clickedKey)) {
        final movingPiece = _boardPieces['$_selectedRow,$_selectedCol']!;

        if (_isMateInOneMode) {
          // Comprobar si es la jugada exacta de Mate en 1
          final isCorrectMove = _selectedRow == _currentMatePuzzle!.moveFromRow &&
              _selectedCol == _currentMatePuzzle!.moveFromCol &&
              row == _currentMatePuzzle!.targetRow &&
              col == _currentMatePuzzle!.targetCol;

          setState(() {
            _boardPieces.remove('$_selectedRow,$_selectedCol');
            _boardPieces[clickedKey] = movingPiece;
            _selectedRow = null;
            _selectedCol = null;
            _validMovesForSelected.clear();
          });

          if (isCorrectMove) {
            _handleWin(isMate: true);
          } else {
            setState(() {
              _isTip = true;
              _teacherSpeech =
                  'Esa jugada es legal, pero no da Jaque Mate. ¡Pista: ${_currentMatePuzzle!.hint}!';
            });
            TeacherVoiceService.instance.speak(_teacherSpeech);
          }
        } else {
          // Modo entrenamiento 8x8 (alcanzar la gema)
          setState(() {
            _boardPieces.remove('$_selectedRow,$_selectedCol');
            _boardPieces[clickedKey] = movingPiece;
            _selectedRow = null;
            _selectedCol = null;
            _validMovesForSelected.clear();
          });

          if (row == _targetRow && col == _targetCol) {
            _handleWin(isMate: false);
          } else {
            setState(() {
              _teacherSpeech = '¡Bien movido! Ahora acércate a la gema dorada.';
            });
            TeacherVoiceService.instance.speak(_teacherSpeech);
          }
        }
      } else {
        // Toco casilla no válida
        setState(() {
          _isTip = true;
          _teacherSpeech = 'Toca una de las casillas con círculo verde para mover tu pieza.';
        });
        TeacherVoiceService.instance.speak(_teacherSpeech);
      }
    }
  }

  void _calculateValidMoves(int r, int c, ChessPieceType type) {
    for (int tr = 0; tr < boardSize; tr++) {
      for (int tc = 0; tc < boardSize; tc++) {
        if (tr == r && tc == c) continue;
        if (_obstacles.contains('$tr,$tc')) continue;

        final targetPiece = _boardPieces['$tr,$tc'];
        if (targetPiece != null && targetPiece.isWhite) continue; // No puede comer pieza propia

        if (_isValidPieceMove(r, c, tr, tc, type)) {
          _validMovesForSelected.add('$tr,$tc');
        }
      }
    }
  }

  bool _isValidPieceMove(int fromR, int fromC, int toR, int toC, ChessPieceType type) {
    final dR = (toR - fromR).abs();
    final dC = (toC - fromC).abs();

    switch (type) {
      case ChessPieceType.rook:
        if (fromR != toR && fromC != toC) return false;
        return _isPathClearStraight(fromR, fromC, toR, toC);

      case ChessPieceType.bishop:
        if (dR != dC) return false;
        return _isPathClearDiagonal(fromR, fromC, toR, toC);

      case ChessPieceType.queen:
        if (fromR == toR || fromC == toC) {
          return _isPathClearStraight(fromR, fromC, toR, toC);
        } else if (dR == dC) {
          return _isPathClearDiagonal(fromR, fromC, toR, toC);
        }
        return false;

      case ChessPieceType.knight:
        return (dR == 1 && dC == 2) || (dR == 2 && dC == 1);

      case ChessPieceType.king:
        return dR <= 1 && dC <= 1;

      case ChessPieceType.pawn:
        // Peón blanco sube (fila decrece)
        if (fromC == toC && (fromR - toR == 1)) {
          return _boardPieces['$toR,$toC'] == null;
        }
        if (fromR == 6 && fromC == toC && (fromR - toR == 2)) {
          return _boardPieces['${fromR - 1},$fromC'] == null && _boardPieces['$toR,$toC'] == null;
        }
        // Captura en diagonal
        if (dC == 1 && (fromR - toR == 1)) {
          return _boardPieces['$toR,$toC'] != null || (toR == _targetRow && toC == _targetCol);
        }
        return false;
    }
  }

  bool _isPathClearStraight(int fromR, int fromC, int toR, int toC) {
    final stepR = (toR - fromR) == 0 ? 0 : ((toR - fromR) > 0 ? 1 : -1);
    final stepC = (toC - fromC) == 0 ? 0 : ((toC - fromC) > 0 ? 1 : -1);

    int curR = fromR + stepR;
    int curC = fromC + stepC;
    while (curR != toR || curC != toC) {
      if (_boardPieces.containsKey('$curR,$curC') || _obstacles.contains('$curR,$curC')) {
        return false;
      }
      curR += stepR;
      curC += stepC;
    }
    return true;
  }

  bool _isPathClearDiagonal(int fromR, int fromC, int toR, int toC) {
    final stepR = toR > fromR ? 1 : -1;
    final stepC = toC > fromC ? 1 : -1;

    int curR = fromR + stepR;
    int curC = fromC + stepC;
    while (curR != toR && curC != toC) {
      if (_boardPieces.containsKey('$curR,$curC') || _obstacles.contains('$curR,$curC')) {
        return false;
      }
      curR += stepR;
      curC += stepC;
    }
    return true;
  }

  void _handleWin({required bool isMate}) async {
    final profile = ref.read(childProfileProvider);
    final isFinalOfLevel = _missionNumber >= totalChessMissions;

    setState(() {
      _missionComplete = true;
      _isAutoAdvancing = true;
      _isTip = false;
      _confettiController.play();

      if (isMate) {
        _teacherSpeech =
            '¡JAQUE MATE! 👑 ¡Sensacional jugada táctica ${profile.name}! ¡Ganaste una estrella dorada!';
      } else if (isFinalOfLevel) {
        _teacherSpeech =
            '¡Increíble maestría ${profile.name}! ¡Completaste las 100 misiones del Nivel ${profile.chessLevel}! ¡Avanzas al Nivel ${profile.chessLevel + 1} de ajedrez!';
      } else {
        _teacherSpeech = '¡Excelente movimiento! Llegaste a la gema mágica y ganaste una estrella. ¡Felicitaciones!';
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
        title: Text(_isMateInOneMode
            ? 'Ajedrez: Mate en 1 (Nivel ${profile.chessLevel})'
            : 'Ajedrez 8x8 (Nivel ${profile.chessLevel})'),
        backgroundColor: const Color(0xFF6A1B9A),
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
                            _isMateInOneMode
                                ? '👑 Mate en 1 • Ejercicio $_missionNumber/100'
                                : 'Nivel ${profile.chessLevel} • Misión $_missionNumber/100 🏆',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade900,
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

                  const SizedBox(height: 8),

                  // TABLERO 8x8 CON COORDENADAS
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4E342E),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Cuadrícula 8x8 con números de fila
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Números de fila (8 a 1)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: List.generate(boardSize, (r) {
                                    return SizedBox(
                                      width: 14,
                                      height: (MediaQuery.of(context).size.width - 60) / 8,
                                      child: Center(
                                        child: Text(
                                          _rowLabels[r],
                                          style: const TextStyle(
                                            color: Colors.amberAccent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(width: 4),

                                // Tablero 8x8
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 64,
                                  height: MediaQuery.of(context).size.width - 64,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
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
                                        final key = '$row,$col';
                                        final piece = _boardPieces[key];
                                        final isTarget = !_isMateInOneMode &&
                                            row == _targetRow &&
                                            col == _targetCol;
                                        final isObstacle = _obstacles.contains(key);
                                        final isValidMove = _validMovesForSelected.contains(key);
                                        final isSelected =
                                            row == _selectedRow && col == _selectedCol;

                                        return GestureDetector(
                                          onTap: () => _onTileTapped(row, col),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.amber.shade300
                                                  : (isLight
                                                      ? const Color(0xFFF0D9B5)
                                                      : const Color(0xFFB58863)),
                                              border: isSelected
                                                  ? Border.all(color: Colors.amber.shade900, width: 2)
                                                  : null,
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // Punto indicador de movimiento válido
                                                if (isValidMove && !_missionComplete)
                                                  Container(
                                                    width: 14,
                                                    height: 14,
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withValues(alpha: 0.8),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: Colors.white, width: 1.5),
                                                    ),
                                                  ),

                                                // Obstáculo
                                                if (isObstacle)
                                                  const FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text('🪨', style: TextStyle(fontSize: 22)),
                                                  ),

                                                // Gema de meta
                                                if (isTarget && !_missionComplete)
                                                  const FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text('💎', style: TextStyle(fontSize: 24)),
                                                  ),

                                                // Pieza de ajedrez
                                                if (piece != null)
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      piece.symbol,
                                                      style: TextStyle(
                                                        fontSize: 32,
                                                        fontWeight: FontWeight.bold,
                                                        color: piece.isWhite
                                                            ? Colors.white
                                                            : Colors.black,
                                                        shadows: [
                                                          Shadow(
                                                            color: piece.isWhite
                                                                ? Colors.black87
                                                                : Colors.white70,
                                                            blurRadius: 3,
                                                          )
                                                        ],
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
                              ],
                            ),

                            const SizedBox(height: 4),

                            // Letras de columna (A a H)
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: List.generate(boardSize, (c) {
                                  return SizedBox(
                                    width: (MediaQuery.of(context).size.width - 64) / 8,
                                    child: Center(
                                      child: Text(
                                        _colLabels[c],
                                        style: const TextStyle(
                                          color: Colors.amberAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (_isAutoAdvancing) ...[
                    const SizedBox(height: 14),
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
}
