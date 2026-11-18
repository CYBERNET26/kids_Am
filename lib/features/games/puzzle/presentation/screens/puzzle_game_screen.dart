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

class PuzzleShapeInfo {
  final String name;
  final String symbol;
  final IconData icon;
  final Color color;

  const PuzzleShapeInfo({
    required this.name,
    required this.symbol,
    required this.icon,
    required this.color,
  });
}

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
  late List<int?> _boardSlots;
  late List<int> _availablePieces;
  late List<PuzzleShapeInfo> _assignedShapes;
  bool _isSolved = false;
  bool _isAutoAdvancing = false;
  String _themeTitle = '';
  List<String> _currentThemeIcons = [];
  String _teacherSpeech = '';
  bool _isTip = false;

  // Catálogo rico de 16 formas de encastre geométricas distintivas
  final List<PuzzleShapeInfo> _shapesBank = const [
    PuzzleShapeInfo(name: 'Estrella', symbol: '⭐', icon: Icons.star_rounded, color: Color(0xFFFFB300)),
    PuzzleShapeInfo(name: 'Círculo', symbol: '🟢', icon: Icons.circle, color: Color(0xFF4CAF50)),
    PuzzleShapeInfo(name: 'Triángulo', symbol: '🔺', icon: Icons.change_history_rounded, color: Color(0xFFE91E63)),
    PuzzleShapeInfo(name: 'Corazón', symbol: '💖', icon: Icons.favorite_rounded, color: Color(0xFFF44336)),
    PuzzleShapeInfo(name: 'Rombo', symbol: '🔷', icon: Icons.diamond_rounded, color: Color(0xFF2196F3)),
    PuzzleShapeInfo(name: 'Hexágono', symbol: '⬡', icon: Icons.hexagon_rounded, color: Color(0xFF9C27B0)),
    PuzzleShapeInfo(name: 'Trébol', symbol: '🍀', icon: Icons.energy_savings_leaf_rounded, color: Color(0xFF009688)),
    PuzzleShapeInfo(name: 'Luna', symbol: '🌙', icon: Icons.nightlight_round, color: Color(0xFF3F51B5)),
    PuzzleShapeInfo(name: 'Nube', symbol: '☁️', icon: Icons.cloud_rounded, color: Color(0xFF00BCD4)),
    PuzzleShapeInfo(name: 'Flor', symbol: '🌸', icon: Icons.local_florist_rounded, color: Color(0xFFFF4081)),
    PuzzleShapeInfo(name: 'Escudo', symbol: '🛡️', icon: Icons.shield_rounded, color: Color(0xFF795548)),
    PuzzleShapeInfo(name: 'Gota', symbol: '💧', icon: Icons.water_drop_rounded, color: Color(0xFF0288D1)),
    PuzzleShapeInfo(name: 'Destello', symbol: '✨', icon: Icons.auto_awesome, color: Color(0xFFFFD54F)),
    PuzzleShapeInfo(name: 'Campana', symbol: '🔔', icon: Icons.notifications_rounded, color: Color(0xFFFF9800)),
    PuzzleShapeInfo(name: 'Hoja', symbol: '🍃', icon: Icons.eco_rounded, color: Color(0xFF8BC34A)),
    PuzzleShapeInfo(name: 'Corona', symbol: '👑', icon: Icons.workspace_premium_rounded, color: Color(0xFFFFC107)),
  ];

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
    '¡Nuevo rompecabezas de encastre! Observa las distintas formas y encaja cada pieza.',
    '¡Mira las siluetas del tablero! Cada pieza tiene su forma única para encajar.',
    '¡A encajar formas! Haz coincidir la silueta con su pieza correspondiente.',
    '¡Excelente concentración! Encuentra dónde encaja la estrella, el círculo y las demás formas.',
    '¡Diversión encajando! Arrastra cada pieza a su hueco de madera correspondiente.',
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

  int get _currentLevel => ((_puzzleNumber - 1) ~/ exercisesPerLevel) + 1;
  int get _exerciseInLevel => ((_puzzleNumber - 1) % exercisesPerLevel) + 1;

  void _initPuzzle() {
    final profile = ref.read(childProfileProvider);
    final level = _currentLevel;

    // Progresión de tamaño y dificultad por niveles (1 a 10):
    // Niveles 1 y 2: 2x2 = 4 piezas
    // Niveles 3 y 4: 2x3 = 6 piezas
    // Niveles 5, 6 y 7: 3x3 = 9 piezas
    // Niveles 8 y 9: 3x4 = 12 piezas
    // Nivel 10: 4x4 = 16 piezas
    if (level <= 2) {
      _gridRows = 2;
      _gridCols = 2;
    } else if (level <= 4) {
      _gridRows = 2;
      _gridCols = 3;
    } else if (level <= 7) {
      _gridRows = 3;
      _gridCols = 3;
    } else if (level <= 9) {
      _gridRows = 3;
      _gridCols = 4;
    } else {
      _gridRows = 4;
      _gridCols = 4;
    }

    final totalPieces = _gridRows * _gridCols;

    // Asignación de formas de encastre distintas y únicas para cada ranura
    final random = Random(_puzzleNumber * 19 + level * 7);
    final shuffledShapes = List<PuzzleShapeInfo>.from(_shapesBank)..shuffle(random);
    _assignedShapes = shuffledShapes.take(totalPieces).toList();

    // Temática
    final themeIndex = (_puzzleNumber - 1) % _puzzleThemesBank.length;
    final themeData = _puzzleThemesBank[themeIndex];
    _themeTitle = themeData['title'] as String;
    final allIcons = List<String>.from(themeData['icons'] as List);
    _currentThemeIcons = allIcons.take(totalPieces).toList();

    _boardSlots = List<int?>.filled(totalPieces, null);
    _availablePieces = List.generate(totalPieces, (index) => index)..shuffle(random);
    _isSolved = false;
    _isAutoAdvancing = false;
    _isTip = false;

    if (!_hasGreetedThisVisit) {
      _hasGreetedThisVisit = true;
      _teacherSpeech =
          '¡Hola ${profile.name}! Rompecabezas Nivel $level (Ejercicio $_exerciseInLevel de $exercisesPerLevel). Encaja cada pieza en su hueco de silueta correspondiente.';
    } else {
      _teacherSpeech = _variedPrompts[random.nextInt(_variedPrompts.length)];
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
    final isLevelComplete = _exerciseInLevel == exercisesPerLevel;

    setState(() {
      _isSolved = true;
      _isAutoAdvancing = true;
      _isTip = false;
      _confettiController.play();

      if (isLevelComplete) {
        _teacherSpeech =
            '¡EXTRAORDINARIO ${profile.name}! ¡Completaste los 25 puzles del Nivel $_currentLevel! ¡Avanzas al Nivel ${_currentLevel + 1} con nuevas formas y piezas de encastre!';
      } else {
        _teacherSpeech =
            '¡Magnífico encastre! Completaste el rompecabezas de $_themeTitle. ¡Ganaste una estrella dorada!';
      }
    });

    ref.read(childProfileProvider.notifier).recordWin(gameType: GameType.puzzle);

    int nextPuzzle;
    if (isLevelComplete && _currentLevel < totalLevels) {
      ref.read(childProfileProvider.notifier).advanceLevel(GameType.puzzle);
      nextPuzzle = _puzzleNumber + 1;
    } else if (isLevelComplete && _currentLevel >= totalLevels) {
      // Completó los 10 niveles (250 ejercicios)
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
    final totalPieces = _gridRows * _gridCols;

    return Scaffold(
      appBar: AppBar(
        title: Text('Rompecabezas de Encastre (Nivel $_currentLevel/10)'),
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

                  // Barra de progreso y nivel
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

                  const SizedBox(height: 10),

                  // TABLERO DE ENCASTRE CON FORMAS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1), // Aspecto de madera clara Montessori
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFD7CCC8), width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _gridCols,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: totalPieces,
                        itemBuilder: (context, slotIndex) {
                          final currentPiece = _boardSlots[slotIndex];
                          final requiredShape = _assignedShapes[slotIndex];

                          return DragTarget<int>(
                            onWillAcceptWithDetails: (details) {
                              return !_isSolved && !_isAutoAdvancing;
                            },
                            onAcceptWithDetails: (details) {
                              final pieceIndex = details.data;
                              final draggedShape = _assignedShapes[pieceIndex];

                              if (pieceIndex == slotIndex) {
                                // Encastre exacto
                                setState(() {
                                  if (_boardSlots[slotIndex] != null) {
                                    _availablePieces.add(_boardSlots[slotIndex]!);
                                  }
                                  _boardSlots[slotIndex] = pieceIndex;
                                  _availablePieces.remove(pieceIndex);
                                  _isTip = false;
                                  _teacherSpeech =
                                      '¡Clack! La forma ${requiredShape.name} ${requiredShape.symbol} encajó a la perfección.';
                                });
                                TeacherVoiceService.instance.speak(_teacherSpeech);
                                _checkSolution();
                              } else {
                                // No encaja
                                setState(() {
                                  _isTip = true;
                                  _teacherSpeech =
                                      '¡Esa pieza es un ${draggedShape.name} ${draggedShape.symbol}! No encaja en el hueco de ${requiredShape.name} ${requiredShape.symbol}. ¡Busca la forma que coincida!';
                                });
                                TeacherVoiceService.instance.speak(_teacherSpeech);
                              }
                            },
                            builder: (context, candidateData, rejectedData) {
                              final isTargetHovered = candidateData.isNotEmpty;
                              final hasPiece = currentPiece != null;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: hasPiece
                                      ? requiredShape.color.withValues(alpha: 0.15)
                                      : (isTargetHovered
                                          ? requiredShape.color.withValues(alpha: 0.25)
                                          : const Color(0xFFEFEBE9)),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: hasPiece
                                        ? requiredShape.color
                                        : (isTargetHovered
                                            ? requiredShape.color
                                            : Colors.brown.shade200),
                                    width: hasPiece ? 3 : 2,
                                    style: hasPiece ? BorderStyle.solid : BorderStyle.solid,
                                  ),
                                  boxShadow: hasPiece
                                      ? [
                                          BoxShadow(
                                            color: requiredShape.color.withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : [
                                          // Efecto de hueco vaciado en madera
                                          BoxShadow(
                                            color: Colors.brown.withValues(alpha: 0.15),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                ),
                                child: Center(
                                  child: hasPiece
                                      ? _buildFittedPiece(currentPiece, requiredShape)
                                      : _buildEmptySlotSilhouette(requiredShape),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // BANDEJA DE PIEZAS PARA ARRASTRAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
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
                              Text('🧩', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 6),
                              Text(
                                'Piezas para encajar (Arrastra a su forma):',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _availablePieces.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    child: Text(
                                      _isSolved
                                          ? '🎉 ¡Todas las piezas encajaron! Avanzando...'
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
                                      final shape = _assignedShapes[pieceIndex];
                                      final icon = _currentThemeIcons[pieceIndex % _currentThemeIcons.length];

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Draggable<int>(
                                          data: pieceIndex,
                                          feedback: Material(
                                            color: Colors.transparent,
                                            child: _PieceShapeWidget(
                                              shape: shape,
                                              icon: icon,
                                              isFloating: true,
                                            ),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.25,
                                            child: _PieceShapeWidget(shape: shape, icon: icon),
                                          ),
                                          child: _PieceShapeWidget(shape: shape, icon: icon),
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

  Widget _buildEmptySlotSilhouette(PuzzleShapeInfo shape) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(shape.icon, size: 36, color: shape.color.withValues(alpha: 0.45)),
        const SizedBox(height: 4),
        Text(
          shape.name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildFittedPiece(int pieceIndex, PuzzleShapeInfo shape) {
    final icon = _currentThemeIcons[pieceIndex % _currentThemeIcons.length];

    return Container(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(icon, style: const TextStyle(fontSize: 34)),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(shape.icon, size: 14, color: shape.color),
              const SizedBox(width: 2),
              Text(
                shape.symbol,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PieceShapeWidget extends StatelessWidget {
  final PuzzleShapeInfo shape;
  final String icon;
  final bool isFloating;

  const _PieceShapeWidget({
    required this.shape,
    required this.icon,
    this.isFloating = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isFloating ? 76.0 : 68.0;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: shape.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isFloating ? 0.35 : 0.15),
            blurRadius: isFloating ? 12 : 6,
            offset: Offset(0, isFloating ? 6 : 3),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Marca de agua de la forma de encastre
          Positioned(
            right: 2,
            top: 2,
            child: Icon(shape.icon, size: 16, color: Colors.white70),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: TextStyle(fontSize: isFloating ? 32 : 28)),
              Text(
                shape.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
