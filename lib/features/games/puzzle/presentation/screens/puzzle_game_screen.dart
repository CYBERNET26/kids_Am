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
import 'package:kids_am/features/games/puzzle/domain/models/jigsaw_piece.dart';
import 'package:kids_am/features/games/puzzle/presentation/widgets/fun_puzzle_scenes.dart';
import 'package:kids_am/features/games/puzzle/presentation/widgets/jigsaw_path_helper.dart';
import 'package:kids_am/features/games/puzzle/presentation/widgets/jigsaw_piece_widget.dart';
import 'package:kids_am/features/games/puzzle/presentation/widgets/jigsaw_board_widget.dart';
import 'package:kids_am/features/tutor/domain/models/tutor_context.dart';
import 'package:kids_am/features/tutor/presentation/providers/tutor_provider.dart';

class PuzzleGameScreen extends ConsumerStatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  ConsumerState<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends ConsumerState<PuzzleGameScreen> {
  static const int exercisesPerLevel = 25;
  static const int totalLevels = 10;
  static const int totalPuzzles = exercisesPerLevel * totalLevels; // 250 ejercicios

  late ConfettiController _confettiController;

  int _puzzleNumber = 1; // 1 a 250
  bool _hasGreetedThisVisit = false;

  int _gridRows = 2;
  int _gridCols = 2;
  late List<JigsawPieceData> _piecesData;
  late List<int?> _boardSlots;
  late List<int> _availablePieces;
  late FunSceneInfo _currentScene;
  bool _isSolved = false;
  bool _isAutoAdvancing = false;
  String _teacherSpeech = '';
  bool _isTip = false;

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

  int get _currentLevel => ((_puzzleNumber - 1) ~/ exercisesPerLevel) + 1;
  int get _exerciseInLevel => ((_puzzleNumber - 1) % exercisesPerLevel) + 1;

  void _initPuzzle() {
    final profile = ref.read(childProfileProvider);
    final level = _currentLevel;

    // Progresión de dificultad entre niveles (1 a 10):
    if (level <= 2) {
      _gridRows = 2;
      _gridCols = 2; // 4 piezas
    } else if (level <= 4) {
      _gridRows = 2;
      _gridCols = 3; // 6 piezas
    } else if (level <= 6) {
      _gridRows = 3;
      _gridCols = 3; // 9 piezas
    } else if (level <= 8) {
      _gridRows = 3;
      _gridCols = 4; // 12 piezas
    } else {
      _gridRows = 4;
      _gridCols = 4; // 16 piezas
    }

    final totalPieces = _gridRows * _gridCols;

    // Generar piezas de rompecabezas con siluetas de encastre auténticas
    final seed = _puzzleNumber * 37 + level * 13;
    _piecesData = JigsawPathHelper.generateGrid(
      rows: _gridRows,
      cols: _gridCols,
      seed: seed,
    );

    // Escena ilustrada divertida correspondiente
    _currentScene = FunPuzzleScenes.getSceneForPuzzle(_puzzleNumber);

    // Estado del tablero y bandeja de piezas
    _boardSlots = List<int?>.filled(totalPieces, null);
    final random = Random(seed + 99);
    _availablePieces = List.generate(totalPieces, (index) => index)..shuffle(random);
    _isSolved = false;
    _isAutoAdvancing = false;
    _isTip = false;

    // Saludo solo la primera vez que ingresa a la pantalla
    if (!_hasGreetedThisVisit) {
      _hasGreetedThisVisit = true;
      _teacherSpeech =
          '¡Hola ${profile.name}! Rompecabezas Nivel $level. Encaja las piezas con sus orejitas para armar: ${_currentScene.title}.';
      TeacherVoiceService.instance.speak(_teacherSpeech);
    } else {
      _teacherSpeech = 'Armemos: ${_currentScene.title}. Busca dónde encaja cada pieza.';
    }

    setState(() {});
  }

  void _onPiecePlaced(int slotIndex, int pieceIndex) {
    if (_isSolved || _isAutoAdvancing) return;

    // ENCASTRE CORRECTO:
    // REGLA ESTRICTA: La Seño Sofía NO habla cuando coloca la pieza correcta
    setState(() {
      if (_boardSlots[slotIndex] != null) {
        _availablePieces.add(_boardSlots[slotIndex]!);
      }
      _boardSlots[slotIndex] = pieceIndex;
      _availablePieces.remove(pieceIndex);
      _isTip = false;
      _teacherSpeech = '¡Encastre perfecto! Sigue armando el dibujo.';
    });

    _checkSolution();
  }

  void _onWrongPiecePlaced(int slotIndex, int pieceIndex) {
    if (_isSolved || _isAutoAdvancing) return;

    // ERROR: La Seño Sofía SOLAMENTE habla cuando el niño se equivoca
    final targetPiece = _piecesData[slotIndex];
    final draggedPiece = _piecesData[pieceIndex];

    String hint = 'Fíjate en la forma de las orejitas y los colores del dibujo.';
    if (targetPiece.isCorner && !draggedPiece.isCorner) {
      hint = 'Esta esquina tiene dos bordes rectos. ¡Busca una pieza con esquinas rectas!';
    } else if (targetPiece.isEdge && !draggedPiece.isEdge) {
      hint = 'Este borde es plano. ¡Busca una pieza que tenga un lado recto!';
    }

    setState(() {
      _isTip = true;
      _teacherSpeech = '¡Esa pieza no encaja ahí! $hint';
    });

    final profile = ref.read(childProfileProvider);
    final tutorState = ref.read(tutorProvider);

    tutorState.coordinator.speakFeedback(
      TutorContext(
        childName: profile.name,
        childAge: 6,
        eventType: TutorEventType.puzzleIncorrect,
        gameName: 'Rompecabezas Clásico',
        topicOrOperation: _currentScene.title,
        childMistake: 'Intentó colocar una pieza en la casilla incorrecta',
        pedagogicalHint: hint,
      ),
    ).then((fb) {
      if (mounted) {
        setState(() {
          _teacherSpeech = fb.speechText;
        });
      }
    });
  }

  void _checkSolution() async {
    for (int i = 0; i < _boardSlots.length; i++) {
      if (_boardSlots[i] != i) {
        return; // Aún faltan piezas
      }
    }

    // Se completó todo el rompecabezas
    final profile = ref.read(childProfileProvider);
    final isLevelComplete = _exerciseInLevel == exercisesPerLevel;

    setState(() {
      _isSolved = true;
      _isAutoAdvancing = true;
      _isTip = false;
      _confettiController.play();

      if (isLevelComplete) {
        _teacherSpeech =
            '¡EXTRAORDINARIO ${profile.name}! ¡Completaste los 25 rompecabezas del Nivel $_currentLevel! ¡Avanzas al Nivel ${_currentLevel + 1}!';
      } else {
        _teacherSpeech =
            '¡Excelente trabajo! Armaste el dibujo de ${_currentScene.title}. ¡Ganaste una estrella dorada!';
      }
    });

    ref.read(childProfileProvider.notifier).recordWin(gameType: GameType.puzzle);

    int nextPuzzle;
    if (isLevelComplete && _currentLevel < totalLevels) {
      ref.read(childProfileProvider.notifier).advanceLevel(GameType.puzzle);
      nextPuzzle = _puzzleNumber + 1;
    } else if (isLevelComplete && _currentLevel >= totalLevels) {
      nextPuzzle = 1;
    } else {
      nextPuzzle = _puzzleNumber + 1;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('puzzle_number_index', nextPuzzle);

    // Habla al terminar el rompecabezas completo
    await TeacherVoiceService.instance.speakAndWait(_teacherSpeech);
    await Future.delayed(const Duration(milliseconds: 1200));

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

    return Scaffold(
      appBar: AppBar(
        title: Text('Rompecabezas Clásico (Nivel $_currentLevel/10)'),
        backgroundColor: const Color(0xFF2E7D32),
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

                  // Barra de progreso y estrellas
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
                            'Nivel $_currentLevel/10 • Puzle $_exerciseInLevel/$exercisesPerLevel ⭐',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
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

                  // Título temático del dibujo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _currentScene.themeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _currentScene.themeColor.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        _currentScene.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _currentScene.themeColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // TABLERO CON PIEZAS DE ENCASTRE REALES Y DIBUJO ILUSTRADO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: JigsawBoardWidget(
                      rows: _gridRows,
                      cols: _gridCols,
                      pieces: _piecesData,
                      boardSlots: _boardSlots,
                      sceneInfo: _currentScene,
                      isSolved: _isSolved,
                      onPieceDropped: _onPiecePlaced,
                      onWrongPieceDropped: _onWrongPiecePlaced,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // BANDEJA DE PIEZAS DE ROMPECABEZAS PARA ARRASTRAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('🧩', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text(
                                'Piezas para encajar en el tablero:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _availablePieces.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      _isSolved
                                          ? '🎉 ¡Completaste todo el dibujo!'
                                          : '¡Todas las piezas fueron encajadas!',
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
                                      final piece = _piecesData[pieceIndex];

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Draggable<int>(
                                          data: pieceIndex,
                                          feedback: Material(
                                            color: Colors.transparent,
                                            child: JigsawPieceThumbnail(
                                              piece: piece,
                                              sceneType: _currentScene.type,
                                              totalRows: _gridRows,
                                              totalCols: _gridCols,
                                              cellSize: 80,
                                              isFloating: true,
                                            ),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.25,
                                            child: JigsawPieceThumbnail(
                                              piece: piece,
                                              sceneType: _currentScene.type,
                                              totalRows: _gridRows,
                                              totalCols: _gridCols,
                                              cellSize: 72,
                                            ),
                                          ),
                                          child: JigsawPieceThumbnail(
                                            piece: piece,
                                            sceneType: _currentScene.type,
                                            totalRows: _gridRows,
                                            totalCols: _gridCols,
                                            cellSize: 72,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                        ],
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
                          '¡Excelente encastre! Pasando al siguiente...',
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
