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
import 'package:kids_am/features/tutor/domain/models/tutor_context.dart';
import 'package:kids_am/features/tutor/presentation/providers/tutor_provider.dart';

enum ShapeType {
  circle,
  star,
  triangle,
  heart,
  diamond,
  hexagon,
  cross,
  clover,
  shield,
  moon,
  drop,
  flower,
}

class PuzzleShapeInfo {
  final ShapeType type;
  final String name;
  final String symbol;
  final IconData icon;
  final Color color;

  const PuzzleShapeInfo({
    required this.type,
    required this.name,
    required this.symbol,
    required this.icon,
    required this.color,
  });
}

// ---------------------------------------------------------------------------
// CLIPPERS PARA FIGURAS DE ENCASTRE REALES (COMO JUEGOS DE MESA DE MADERA)
// ---------------------------------------------------------------------------

class StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double outerR = size.width / 2;
    final double innerR = outerR * 0.42;
    const int points = 5;
    final double step = pi / points;
    double rot = -pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final double r = i.isEven ? outerR : innerR;
      final double x = cx + cos(rot) * r;
      final double y = cy + sin(rot) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      rot += step;
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 2);
    path.lineTo(size.width - 2, size.height - 2);
    path.lineTo(2, size.height - 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    path.moveTo(w / 2, h * 0.88);
    path.cubicTo(w * 0.08, h * 0.62, 0, h * 0.38, 0, h * 0.26);
    path.cubicTo(0, h * 0.06, w * 0.36, 0, w / 2, h * 0.28);
    path.cubicTo(w * 0.64, 0, w, h * 0.06, w, h * 0.26);
    path.cubicTo(w, h * 0.38, w * 0.92, h * 0.62, w / 2, h * 0.88);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 2);
    path.lineTo(size.width - 2, size.height / 2);
    path.lineTo(size.width / 2, size.height - 2);
    path.lineTo(2, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    path.moveTo(w * 0.25, 2);
    path.lineTo(w * 0.75, 2);
    path.lineTo(w - 2, h * 0.5);
    path.lineTo(w * 0.75, h - 2);
    path.lineTo(w * 0.25, h - 2);
    path.lineTo(2, h * 0.5);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CrossClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double a = w * 0.30;
    final double b = w * 0.70;
    path.moveTo(a, 0);
    path.lineTo(b, 0);
    path.lineTo(b, a);
    path.lineTo(w, a);
    path.lineTo(w, b);
    path.lineTo(b, b);
    path.lineTo(b, h);
    path.lineTo(a, h);
    path.lineTo(a, b);
    path.lineTo(0, b);
    path.lineTo(0, a);
    path.lineTo(a, a);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CloverClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double r = w * 0.26;
    path.addOval(Rect.fromCircle(center: Offset(w / 2, r), radius: r));
    path.addOval(Rect.fromCircle(center: Offset(w / 2, h - r), radius: r));
    path.addOval(Rect.fromCircle(center: Offset(r, h / 2), radius: r));
    path.addOval(Rect.fromCircle(center: Offset(w - r, h / 2), radius: r));
    path.addRect(Rect.fromCenter(center: Offset(w / 2, h / 2), width: r * 1.4, height: r * 1.4));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ShieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    path.moveTo(2, 2);
    path.lineTo(w - 2, 2);
    path.lineTo(w - 2, h * 0.55);
    path.cubicTo(w - 2, h * 0.88, w / 2, h - 2, w / 2, h - 2);
    path.cubicTo(w / 2, h - 2, 2, h * 0.88, 2, h * 0.55);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class MoonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    final base = Path()..addOval(Rect.fromLTWH(0, 0, w, h));
    final cut = Path()..addOval(Rect.fromLTWH(w * 0.25, 0, w * 0.85, h));
    return Path.combine(PathOperation.difference, base, cut);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DropClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    path.moveTo(w / 2, 0);
    path.cubicTo(w, h * 0.5, w, h * 0.75, w / 2, h);
    path.cubicTo(0, h * 0.75, 0, h * 0.5, w / 2, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class FlowerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width * 0.22;
    const int petals = 6;
    for (int i = 0; i < petals; i++) {
      final angle = (2 * pi / petals) * i;
      final px = cx + cos(angle) * (r * 1.15);
      final py = cy + sin(angle) * (r * 1.15);
      path.addOval(Rect.fromCircle(center: Offset(px, py), radius: r));
    }
    path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.9));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

CustomClipper<Path>? getClipperForShape(ShapeType type) {
  switch (type) {
    case ShapeType.circle:
      return null; // ClipOval
    case ShapeType.star:
      return StarClipper();
    case ShapeType.triangle:
      return TriangleClipper();
    case ShapeType.heart:
      return HeartClipper();
    case ShapeType.diamond:
      return DiamondClipper();
    case ShapeType.hexagon:
      return HexagonClipper();
    case ShapeType.cross:
      return CrossClipper();
    case ShapeType.clover:
      return CloverClipper();
    case ShapeType.shield:
      return ShieldClipper();
    case ShapeType.moon:
      return MoonClipper();
    case ShapeType.drop:
      return DropClipper();
    case ShapeType.flower:
      return FlowerClipper();
  }
}

// ---------------------------------------------------------------------------
// PANTALLA PRINCIPAL DE ROMPECABEZAS DE ENCASTRE REAL
// ---------------------------------------------------------------------------

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

  final List<PuzzleShapeInfo> _shapesBank = const [
    PuzzleShapeInfo(type: ShapeType.star, name: 'Estrella', symbol: '⭐', icon: Icons.star_rounded, color: Color(0xFFFFB300)),
    PuzzleShapeInfo(type: ShapeType.circle, name: 'Círculo', symbol: '🟢', icon: Icons.circle, color: Color(0xFF43A047)),
    PuzzleShapeInfo(type: ShapeType.triangle, name: 'Triángulo', symbol: '🔺', icon: Icons.change_history_rounded, color: Color(0xFFE91E63)),
    PuzzleShapeInfo(type: ShapeType.heart, name: 'Corazón', symbol: '💖', icon: Icons.favorite_rounded, color: Color(0xFFE53935)),
    PuzzleShapeInfo(type: ShapeType.diamond, name: 'Rombo', symbol: '🔷', icon: Icons.diamond_rounded, color: Color(0xFF1E88E5)),
    PuzzleShapeInfo(type: ShapeType.hexagon, name: 'Hexágono', symbol: '⬡', icon: Icons.hexagon_rounded, color: Color(0xFF8E24AA)),
    PuzzleShapeInfo(type: ShapeType.cross, name: 'Cruz', symbol: '➕', icon: Icons.add_rounded, color: Color(0xFF00ACC1)),
    PuzzleShapeInfo(type: ShapeType.clover, name: 'Trébol', symbol: '🍀', icon: Icons.energy_savings_leaf_rounded, color: Color(0xFF00897B)),
    PuzzleShapeInfo(type: ShapeType.shield, name: 'Escudo', symbol: '🛡️', icon: Icons.shield_rounded, color: Color(0xFF6D4C41)),
    PuzzleShapeInfo(type: ShapeType.moon, name: 'Luna', symbol: '🌙', icon: Icons.nightlight_round, color: Color(0xFF3949AB)),
    PuzzleShapeInfo(type: ShapeType.drop, name: 'Gota', symbol: '💧', icon: Icons.water_drop_rounded, color: Color(0xFF039BE5)),
    PuzzleShapeInfo(type: ShapeType.flower, name: 'Flor', symbol: '🌸', icon: Icons.local_florist_rounded, color: Color(0xFFD81B60)),
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
    } else if (level <= 7) {
      _gridRows = 3;
      _gridCols = 3; // 9 piezas
    } else if (level <= 9) {
      _gridRows = 3;
      _gridCols = 4; // 12 piezas
    } else {
      _gridRows = 4;
      _gridCols = 4; // 16 piezas
    }

    final totalPieces = _gridRows * _gridCols;

    // Asignar formas de encastre geométricas distintas a cada casilla
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

    // Saludo solo la primera vez que ingresa a la pantalla
    if (!_hasGreetedThisVisit) {
      _hasGreetedThisVisit = true;
      _teacherSpeech =
          '¡Hola ${profile.name}! Rompecabezas Nivel $level. Encaja cada figura en su hueco correspondiente de madera.';
      TeacherVoiceService.instance.speak(_teacherSpeech);
    } else {
      _teacherSpeech = 'Rompecabezas de $_themeTitle. Encaja cada figura en su lugar.';
    }

    setState(() {});
  }

  void _checkSolution() async {
    for (int i = 0; i < _boardSlots.length; i++) {
      if (_boardSlots[i] != i) {
        return;
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
            '¡EXTRAORDINARIO ${profile.name}! ¡Completaste los 25 rompecabezas del Nivel $_currentLevel! ¡Avanzas al Nivel ${_currentLevel + 1} con más figuras de encastre!';
      } else {
        _teacherSpeech =
            '¡Excelente trabajo! Encajaste todas las figuras de $_themeTitle. ¡Ganaste una estrella dorada!';
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

                  // TABLERO DE MADERA MONTESSORI CON HUECOS TROQUELADOS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEBE9), // Madera clara pulida
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFBCAAA4), width: 5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _gridCols,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
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
                                // ENCASTRE CORRECTO:
                                // REGLA: La Seño Sofía NO habla cuando coloca la pieza correcta
                                setState(() {
                                  if (_boardSlots[slotIndex] != null) {
                                    _availablePieces.add(_boardSlots[slotIndex]!);
                                  }
                                  _boardSlots[slotIndex] = pieceIndex;
                                  _availablePieces.remove(pieceIndex);
                                  _isTip = false;
                                  _teacherSpeech = '¡Encastre perfecto! Sigue encajando las demás figuras.';
                                });
                                // NO se llama a TeacherVoiceService.instance.speak() aquí
                                _checkSolution();
                              } else {
                                // ERROR: La Seño Sofía SOLAMENTE habla cuando el niño se equivoca
                                setState(() {
                                  _isTip = true;
                                  _teacherSpeech =
                                      '¡Esa pieza es una figura de ${draggedShape.name} ${draggedShape.symbol}! No encaja en el hueco de ${requiredShape.name} ${requiredShape.symbol}. ¡Busca la forma que coincida!';
                                });

                                final profile = ref.read(childProfileProvider);
                                final tutorState = ref.read(tutorProvider);
                                tutorState.coordinator.speakFeedback(
                                  TutorContext(
                                    childName: profile.name,
                                    childAge: 6,
                                    eventType: TutorEventType.puzzleIncorrect,
                                    gameName: 'Rompecabezas de Encastre',
                                    topicOrOperation: 'Figura ${requiredShape.name}',
                                    childMistake: 'Intentó colocar figura de ${draggedShape.name} en el hueco de ${requiredShape.name}',
                                    pedagogicalHint: 'Busca el hueco con la silueta de ${draggedShape.name}',
                                  ),
                                ).then((fb) {
                                  if (mounted) {
                                    setState(() {
                                      _teacherSpeech = fb.speechText;
                                    });
                                  }
                                });
                              }
                            },
                            builder: (context, candidateData, rejectedData) {
                              final isTargetHovered = candidateData.isNotEmpty;
                              final hasPiece = currentPiece != null;

                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  final size = constraints.maxWidth;

                                  return Center(
                                    child: SizedBox(
                                      width: size,
                                      height: size,
                                      child: hasPiece
                                          ? _buildFittedPiece(currentPiece, requiredShape, size)
                                          : _buildEmptySlotSilhouette(requiredShape, size, isTargetHovered),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // BANDEJA DE PIEZAS DE MADERA TROQUELADAS PARA ARRASTRAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
                                'Figuras para encajar en el tablero:',
                                style: TextStyle(
                                  fontSize: 15,
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
                                          ? '🎉 ¡Todas las figuras encajaron a la perfección!'
                                          : '¡Todas las figuras fueron encajadas!',
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
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Draggable<int>(
                                          data: pieceIndex,
                                          feedback: Material(
                                            color: Colors.transparent,
                                            child: _PieceShapeFigure(
                                              shape: shape,
                                              icon: icon,
                                              size: 78,
                                              isFloating: true,
                                            ),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.2,
                                            child: _PieceShapeFigure(shape: shape, icon: icon, size: 70),
                                          ),
                                          child: _PieceShapeFigure(shape: shape, icon: icon, size: 70),
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

  // Ranura vacía: hueco troquelado negativo en madera
  Widget _buildEmptySlotSilhouette(PuzzleShapeInfo shape, double size, bool isHovered) {
    final clipper = getClipperForShape(shape.type);

    Widget innerContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isHovered
            ? shape.color.withValues(alpha: 0.35)
            : const Color(0xFFD7CCC8), // Madera hundida oscura
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            spreadRadius: -2,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Center(
        child: Icon(
          shape.icon,
          size: size * 0.40,
          color: Colors.brown.shade400.withValues(alpha: 0.7),
        ),
      ),
    );

    if (clipper != null) {
      return ClipPath(
        clipper: clipper,
        child: innerContent,
      );
    } else {
      return ClipOval(child: innerContent);
    }
  }

  // Pieza encastrada en la ranura
  Widget _buildFittedPiece(int pieceIndex, PuzzleShapeInfo shape, double size) {
    final icon = _currentThemeIcons[pieceIndex % _currentThemeIcons.length];
    final clipper = getClipperForShape(shape.type);

    Widget fittedContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: shape.color,
        gradient: LinearGradient(
          colors: [shape.color.withValues(alpha: 0.85), shape.color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(fontSize: size * 0.46),
        ),
      ),
    );

    if (clipper != null) {
      return ClipPath(
        clipper: clipper,
        child: fittedContent,
      );
    } else {
      return ClipOval(child: fittedContent);
    }
  }
}

// ---------------------------------------------------------------------------
// FIGURA DE ENCASTRE FÍSICA TROQUELADA (NO CUADRADA)
// ---------------------------------------------------------------------------

class _PieceShapeFigure extends StatelessWidget {
  final PuzzleShapeInfo shape;
  final String icon;
  final double size;
  final bool isFloating;

  const _PieceShapeFigure({
    required this.shape,
    required this.icon,
    required this.size,
    this.isFloating = false,
  });

  @override
  Widget build(BuildContext context) {
    final clipper = getClipperForShape(shape.type);

    Widget shapeContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: shape.color,
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 0.9,
          colors: [
            shape.color.withValues(alpha: 0.95),
            shape.color,
          ],
        ),
        boxShadow: isFloating
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(
            fontSize: size * 0.46,
            shadows: const [
              Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
        ),
      ),
    );

    Widget clipped;
    if (clipper != null) {
      clipped = ClipPath(clipper: clipper, child: shapeContent);
    } else {
      clipped = ClipOval(child: shapeContent);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        clipped,
        const SizedBox(height: 4),
        Text(
          shape.name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade800,
          ),
        ),
      ],
    );
  }
}
