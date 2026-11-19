import 'dart:math';
import 'package:flutter/material.dart';

enum FunSceneType {
  dinoParty,
  spacePuppy,
  pirateCat,
  jungleLion,
  iceCreamCastle,
  yellowSubmarine,
  pizzaRobot,
  puddlePiggy,
  animalTrain,
  bubbleDragon,
}

class FunSceneInfo {
  final FunSceneType type;
  final String title;
  final String description;
  final String emoji;
  final Color themeColor;

  const FunSceneInfo({
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.themeColor,
  });
}

class FunPuzzleScenes {
  static const List<FunSceneInfo> allScenes = [
    FunSceneInfo(
      type: FunSceneType.dinoParty,
      title: '¡Dino Fiesta de Cumpleaños! 🦕🎂',
      description: 'El simpático T-Rex celebra con globos, gorro festivo y un gran pastel.',
      emoji: '🦕',
      themeColor: Color(0xFF43A047),
    ),
    FunSceneInfo(
      type: FunSceneType.spacePuppy,
      title: '¡Perrito Astronauta en las Estrellas! 🚀🐶',
      description: 'Un cachorrito espacial saluda desde su cohete entre planetas y estrellas.',
      emoji: '🚀',
      themeColor: Color(0xFF3949AB),
    ),
    FunSceneInfo(
      type: FunSceneType.pirateCat,
      title: '¡El Barco Pirata del Gatito! 🐱⛵️',
      description: 'Un valiente gatito con sombrero pirata y su cofre lleno de monedas de oro.',
      emoji: '🐱',
      themeColor: Color(0xFF00897B),
    ),
    FunSceneInfo(
      type: FunSceneType.jungleLion,
      title: '¡El León Músico de la Selva! 🦁🎸',
      description: 'El rey león tocando su guitarra acústica con notas musicales de colores.',
      emoji: '🦁',
      themeColor: Color(0xFFFF8F00),
    ),
    FunSceneInfo(
      type: FunSceneType.iceCreamCastle,
      title: '¡Castillo Mágico de Helado y Arcoíris! 🏰🍦',
      description: 'Torres de barquillos, cerezas brillantes y un cielo con arcoíris dulce.',
      emoji: '🏰',
      themeColor: Color(0xFFE91E63),
    ),
    FunSceneInfo(
      type: FunSceneType.yellowSubmarine,
      title: '¡Submarino Amarillo y Pulpo Sonriente! 🐙🫧',
      description: 'Aventuras submarinas con burbujas brillantes y un simpático pulpo morado.',
      emoji: '🐙',
      themeColor: Color(0xFF00ACC1),
    ),
    FunSceneInfo(
      type: FunSceneType.pizzaRobot,
      title: '¡El Robot Chef y su Súper Pizza! 🤖🍕',
      description: 'Un robot cocinero con gorro blanco lanzando una pizza con queso al aire.',
      emoji: '🤖',
      themeColor: Color(0xFF5E35B1),
    ),
    FunSceneInfo(
      type: FunSceneType.puddlePiggy,
      title: '¡Cerdito Feliz con Botas Amarillas! 🐷🥾',
      description: 'Un cerdito saltando en un charco de lluvia con mariposas y flores.',
      emoji: '🐷',
      themeColor: Color(0xFFD81B60),
    ),
    FunSceneInfo(
      type: FunSceneType.animalTrain,
      title: '¡El Tren Expreso de los Animalitos! 🚂🐼',
      description: 'Un tren a vapor con un maquinista oso panda y una alegre jirafa.',
      emoji: '🚂',
      themeColor: Color(0xFFE53935),
    ),
    FunSceneInfo(
      type: FunSceneType.bubbleDragon,
      title: '¡Gaspar el Dragón de las Burbujas! 🐉🫧',
      description: 'El dragoncito Gaspar soplando pompas de jabón gigantes de colores.',
      emoji: '🐉',
      themeColor: Color(0xFF00897B),
    ),
  ];

  static FunSceneInfo getSceneForPuzzle(int puzzleNumber) {
    final index = (puzzleNumber - 1) % allScenes.length;
    return allScenes[index];
  }
}

/// Pintor vectorial detallado de alta fidelidad que genera los dibujos infantiles divertidos
class FunScenePainter extends CustomPainter {
  final FunSceneType sceneType;

  const FunScenePainter({required this.sceneType});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fondo base redondeado suave
    final clipRect = Rect.fromLTWH(0, 0, w, h);
    canvas.save();
    canvas.clipRect(clipRect);

    switch (sceneType) {
      case FunSceneType.dinoParty:
        _drawDinoParty(canvas, w, h);
        break;
      case FunSceneType.spacePuppy:
        _drawSpacePuppy(canvas, w, h);
        break;
      case FunSceneType.pirateCat:
        _drawPirateCat(canvas, w, h);
        break;
      case FunSceneType.jungleLion:
        _drawJungleLion(canvas, w, h);
        break;
      case FunSceneType.iceCreamCastle:
        _drawIceCreamCastle(canvas, w, h);
        break;
      case FunSceneType.yellowSubmarine:
        _drawYellowSubmarine(canvas, w, h);
        break;
      case FunSceneType.pizzaRobot:
        _drawPizzaRobot(canvas, w, h);
        break;
      case FunSceneType.puddlePiggy:
        _drawPuddlePiggy(canvas, w, h);
        break;
      case FunSceneType.animalTrain:
        _drawAnimalTrain(canvas, w, h);
        break;
      case FunSceneType.bubbleDragon:
        _drawBubbleDragon(canvas, w, h);
        break;
    }

    canvas.restore();
  }

  // --------------------------------------------------------------------------
  // ESCENA 1: DINO FIESTA
  // --------------------------------------------------------------------------
  void _drawDinoParty(Canvas canvas, double w, double h) {
    // Cielo celeste vibrante
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF81D4FA), Color(0xFFB3E5FC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Sol con carita sonriente
    final sunPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(Offset(w * 0.15, h * 0.16), w * 0.09, sunPaint);
    _drawSmileyFace(canvas, Offset(w * 0.15, h * 0.16), w * 0.06);

    // Nubes esponjosas
    _drawCloud(canvas, Offset(w * 0.70, h * 0.14), w * 0.14);

    // Banderines de fiesta
    _drawBuntingFlags(canvas, w, h * 0.08);

    // Colinas verdes
    final hillPaint1 = Paint()..color = const Color(0xFF81C784);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.25, h * 0.90), width: w * 0.9, height: h * 0.45), hillPaint1);
    final hillPaint2 = Paint()..color = const Color(0xFF66BB6A);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.75, h * 0.92), width: w * 0.9, height: h * 0.45), hillPaint2);

    // Volcán simpático de fondo a la izquierda
    final volcanoPath = Path()
      ..moveTo(w * 0.05, h * 0.75)
      ..lineTo(w * 0.15, h * 0.45)
      ..lineTo(w * 0.25, h * 0.45)
      ..lineTo(w * 0.35, h * 0.75)
      ..close();
    canvas.drawPath(volcanoPath, Paint()..color = const Color(0xFF8D6E63));
    // Lava roja y humo de corazones
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.20, h * 0.45), width: w * 0.10, height: h * 0.03), Paint()..color = const Color(0xFFFF5252));
    canvas.drawCircle(Offset(w * 0.20, h * 0.38), w * 0.03, Paint()..color = Colors.white.withValues(alpha: 0.8));
    canvas.drawCircle(Offset(w * 0.22, h * 0.32), w * 0.04, Paint()..color = Colors.white.withValues(alpha: 0.7));

    // CUERPO DEL T-REX VERDE AMIGABLE
    final dinoPaint = Paint()..color = const Color(0xFF4CAF50);
    final bellyPaint = Paint()..color = const Color(0xFFA5D6A7);

    // Cola
    final tailPath = Path()
      ..moveTo(w * 0.30, h * 0.72)
      ..quadraticBezierTo(w * 0.10, h * 0.70, w * 0.08, h * 0.60)
      ..quadraticBezierTo(w * 0.15, h * 0.78, w * 0.35, h * 0.80)
      ..close();
    canvas.drawPath(tailPath, dinoPaint);

    // Cuerpo
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.45, h * 0.66), width: w * 0.38, height: h * 0.35), dinoPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.68), width: w * 0.24, height: h * 0.24), bellyPaint);

    // Patas gorditas
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.35, h * 0.75, w * 0.10, h * 0.16), const Radius.circular(16)), dinoPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.48, h * 0.75, w * 0.10, h * 0.16), const Radius.circular(16)), dinoPaint);

    // Cabeza de T-Rex
    final headRect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.42, h * 0.34, w * 0.34, h * 0.22), const Radius.circular(24));
    canvas.drawRRect(headRect, dinoPaint);

    // Ojo grande con brillo
    _drawCartoonEye(canvas, Offset(w * 0.55, h * 0.40), w * 0.045);

    // Sonrisa simpática y mejilla rosada
    final smilePath = Path()
      ..moveTo(w * 0.52, h * 0.49)
      ..quadraticBezierTo(w * 0.64, h * 0.56, w * 0.74, h * 0.48);
    canvas.drawPath(smilePath, Paint()..color = const Color(0xFF1B5E20)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round);
    canvas.drawCircle(Offset(w * 0.50, h * 0.47), w * 0.03, Paint()..color = const Color(0xFFFF80AB).withValues(alpha: 0.6));

    // Gorro de fiesta a rayas
    final hatPath = Path()
      ..moveTo(w * 0.50, h * 0.35)
      ..lineTo(w * 0.56, h * 0.18)
      ..lineTo(w * 0.62, h * 0.35)
      ..close();
    canvas.drawPath(hatPath, Paint()..color = const Color(0xFFFF4081));
    canvas.drawCircle(Offset(w * 0.56, h * 0.17), w * 0.025, Paint()..color = const Color(0xFFFFEB3B));

    // Pastel de cumpleaños delicioso en mesa
    final cakeTable = Rect.fromLTWH(w * 0.68, h * 0.66, w * 0.26, h * 0.24);
    canvas.drawRRect(RRect.fromRectAndRadius(cakeTable, const Radius.circular(10)), Paint()..color = const Color(0xFFFFCC80));

    // Base del pastel
    final cakeRect = Rect.fromLTWH(w * 0.72, h * 0.57, w * 0.18, h * 0.10);
    canvas.drawRRect(RRect.fromRectAndRadius(cakeRect, const Radius.circular(8)), Paint()..color = const Color(0xFFF48FB1));
    // Glaseado
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.71, h * 0.56, w * 0.20, h * 0.03), const Radius.circular(4)), Paint()..color = Colors.white);
    // Velitas encendidas
    canvas.drawRect(Rect.fromLTWH(w * 0.79, h * 0.51, w * 0.02, h * 0.05), Paint()..color = const Color(0xFF29B6F6));
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.80, h * 0.49), width: w * 0.025, height: h * 0.03), Paint()..color = const Color(0xFFFF9800));

    // Globos festivos flotando a la derecha
    _drawBalloon(canvas, Offset(w * 0.85, h * 0.28), const Color(0xFFFF1744), w * 0.06);
    _drawBalloon(canvas, Offset(w * 0.76, h * 0.34), const Color(0xFFFFEA00), w * 0.055);
  }

  // --------------------------------------------------------------------------
  // ESCENA 2: PERRITO ASTRONAUTA
  // --------------------------------------------------------------------------
  void _drawSpacePuppy(Canvas canvas, double w, double h) {
    // Espacio cósmico degradado
    final spacePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF311B92), Color(0xFF0D47A1), Color(0xFF050B14)],
        center: Alignment.center,
        radius: 1.1,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), spacePaint);

    // Estrellas titilantes
    final starPaint = Paint()..color = Colors.white;
    final yellowStar = Paint()..color = const Color(0xFFFFD54F);
    final random = Random(42);
    for (int i = 0; i < 24; i++) {
      final sx = random.nextDouble() * w;
      final sy = random.nextDouble() * h;
      final r = (i % 3 == 0) ? 3.0 : 1.5;
      canvas.drawCircle(Offset(sx, sy), r, (i % 2 == 0) ? yellowStar : starPaint);
    }

    // Planeta con anillos (Saturno simpático)
    final saturnPos = Offset(w * 0.82, h * 0.22);
    canvas.drawCircle(saturnPos, w * 0.11, Paint()..color = const Color(0xFFFFB74D));
    // Anillo
    final ringRect = Rect.fromCenter(center: saturnPos, width: w * 0.36, height: h * 0.08);
    canvas.save();
    canvas.translate(saturnPos.dx, saturnPos.dy);
    canvas.rotate(-0.35);
    canvas.translate(-saturnPos.dx, -saturnPos.dy);
    canvas.drawOval(ringRect, Paint()..color = const Color(0xFFFFE082)..style = PaintingStyle.stroke..strokeWidth = 6);
    canvas.restore();

    // Luna sonriente a la izquierda
    _drawCrescentMoon(canvas, Offset(w * 0.18, h * 0.22), w * 0.10);

    // COHETE ESPACIAL
    final rocketCenter = Offset(w * 0.48, h * 0.58);
    // Llamarada del motor
    final firePath = Path()
      ..moveTo(rocketCenter.dx - w * 0.09, rocketCenter.dy + h * 0.18)
      ..lineTo(rocketCenter.dx, rocketCenter.dy + h * 0.32)
      ..lineTo(rocketCenter.dx + w * 0.09, rocketCenter.dy + h * 0.18)
      ..close();
    canvas.drawPath(firePath, Paint()..color = const Color(0xFFFF5722));
    final innerFire = Path()
      ..moveTo(rocketCenter.dx - w * 0.05, rocketCenter.dy + h * 0.18)
      ..lineTo(rocketCenter.dx, rocketCenter.dy + h * 0.27)
      ..lineTo(rocketCenter.dx + w * 0.05, rocketCenter.dy + h * 0.18)
      ..close();
    canvas.drawPath(innerFire, Paint()..color = const Color(0xFFFFEB3B));

    // Aletas laterales del cohete
    canvas.drawPath(
      Path()
        ..moveTo(rocketCenter.dx - w * 0.15, rocketCenter.dy + h * 0.15)
        ..lineTo(rocketCenter.dx - w * 0.24, rocketCenter.dy + h * 0.22)
        ..lineTo(rocketCenter.dx - w * 0.13, rocketCenter.dy + h * 0.08)
        ..close(),
      Paint()..color = const Color(0xFFD32F2F),
    );
    canvas.drawPath(
      Path()
        ..moveTo(rocketCenter.dx + w * 0.15, rocketCenter.dy + h * 0.15)
        ..lineTo(rocketCenter.dx + w * 0.24, rocketCenter.dy + h * 0.22)
        ..lineTo(rocketCenter.dx + w * 0.13, rocketCenter.dy + h * 0.08)
        ..close(),
      Paint()..color = const Color(0xFFD32F2F),
    );

    // Fuselaje del cohete
    final rocketBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: rocketCenter, width: w * 0.30, height: h * 0.36),
      const Radius.circular(50),
    );
    canvas.drawRRect(rocketBody, Paint()..color = Colors.white);
    // Punta roja
    final nosePath = Path()
      ..moveTo(rocketCenter.dx - w * 0.12, rocketCenter.dy - h * 0.10)
      ..quadraticBezierTo(rocketCenter.dx, rocketCenter.dy - h * 0.26, rocketCenter.dx + w * 0.12, rocketCenter.dy - h * 0.10)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFFE53935));

    // Ojo de buey / Ventana redonda con PERRITO ASTRONAUTA
    final windowPos = Offset(rocketCenter.dx, rocketCenter.dy - h * 0.02);
    canvas.drawCircle(windowPos, w * 0.11, Paint()..color = const Color(0xFF1E88E5));
    canvas.drawCircle(windowPos, w * 0.11, Paint()..color = const Color(0xFF90CAF9)..style = PaintingStyle.stroke..strokeWidth = 4);

    // Cara del perrito dentro de la escotilla
    _drawPuppyFace(canvas, windowPos, w * 0.08);

    // Huesito espacial flotando
    _drawBone(canvas, Offset(w * 0.25, h * 0.70), w * 0.08);
  }

  // --------------------------------------------------------------------------
  // ESCENA 3: EL GATITO PIRATA
  // --------------------------------------------------------------------------
  void _drawPirateCat(Canvas canvas, double w, double h) {
    // Cielo tropical brillante
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..shader = const LinearGradient(colors: [Color(0xFF80D8FF), Color(0xFFE1F5FE)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Sol con anteojos
    final sunPos = Offset(w * 0.85, h * 0.18);
    canvas.drawCircle(sunPos, w * 0.10, Paint()..color = const Color(0xFFFFD54F));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(sunPos.dx - w * 0.07, sunPos.dy - h * 0.02, w * 0.14, h * 0.04), const Radius.circular(6)), Paint()..color = Colors.black87);

    // Olas marinas azules
    _drawOceanWaves(canvas, w, h);

    // Barco de madera
    final boatPath = Path()
      ..moveTo(w * 0.20, h * 0.58)
      ..lineTo(w * 0.15, h * 0.68)
      ..quadraticBezierTo(w * 0.50, h * 0.78, w * 0.80, h * 0.68)
      ..lineTo(w * 0.75, h * 0.58)
      ..close();
    canvas.drawPath(boatPath, Paint()..color = const Color(0xFF6D4C41));
    // Rayas de madera
    canvas.drawLine(Offset(w * 0.16, h * 0.63), Offset(w * 0.78, h * 0.63), Paint()..color = const Color(0xFF4E342E)..strokeWidth = 3);

    // Mástil y velas
    canvas.drawRect(Rect.fromLTWH(w * 0.48, h * 0.24, w * 0.04, h * 0.36), Paint()..color = const Color(0xFF4E342E));
    final sailPath = Path()
      ..moveTo(w * 0.52, h * 0.26)
      ..quadraticBezierTo(w * 0.75, h * 0.35, w * 0.52, h * 0.48)
      ..close();
    canvas.drawPath(sailPath, Paint()..color = Colors.white);

    // GATITO PIRATA
    final catPos = Offset(w * 0.36, h * 0.50);
    // Cara del gato naranja
    canvas.drawCircle(catPos, w * 0.10, Paint()..color = const Color(0xFFFFB74D));
    // Orejitas triangulares
    final ear1 = Path()..moveTo(catPos.dx - w * 0.08, catPos.dy - h * 0.06)..lineTo(catPos.dx - w * 0.05, catPos.dy - h * 0.14)..lineTo(catPos.dx - w * 0.01, catPos.dy - h * 0.08)..close();
    canvas.drawPath(ear1, Paint()..color = const Color(0xFFFF9800));
    final ear2 = Path()..moveTo(catPos.dx + w * 0.08, catPos.dy - h * 0.06)..lineTo(catPos.dx + w * 0.05, catPos.dy - h * 0.14)..lineTo(catPos.dx + w * 0.01, catPos.dy - h * 0.08)..close();
    canvas.drawPath(ear2, Paint()..color = const Color(0xFFFF9800));

    // Sombrero pirata con calavera feliz
    final hatPath = Path()
      ..moveTo(catPos.dx - w * 0.14, catPos.dy - h * 0.04)
      ..lineTo(catPos.dx, catPos.dy - h * 0.18)
      ..lineTo(catPos.dx + w * 0.14, catPos.dy - h * 0.04)
      ..close();
    canvas.drawPath(hatPath, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(Offset(catPos.dx, catPos.dy - h * 0.10), w * 0.02, Paint()..color = Colors.white);

    // Ojo con parche pirata y ojo verde
    canvas.drawCircle(Offset(catPos.dx - w * 0.04, catPos.dy - h * 0.01), w * 0.025, Paint()..color = Colors.black); // Parche
    _drawCartoonEye(canvas, Offset(catPos.dx + w * 0.04, catPos.dy - h * 0.01), w * 0.025);
    // Bigotes de gato
    canvas.drawLine(Offset(catPos.dx + w * 0.05, catPos.dy + h * 0.03), Offset(catPos.dx + w * 0.12, catPos.dy + h * 0.02), Paint()..color = Colors.black87..strokeWidth = 2);
    canvas.drawLine(Offset(catPos.dx + w * 0.05, catPos.dy + h * 0.05), Offset(catPos.dx + w * 0.12, catPos.dy + h * 0.06), Paint()..color = Colors.black87..strokeWidth = 2);

    // Cofre del tesoro rebosante de oro a la derecha
    final chestRect = Rect.fromLTWH(w * 0.60, h * 0.54, w * 0.18, h * 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(chestRect, const Radius.circular(6)), Paint()..color = const Color(0xFF5D4037));
    // Monedas de oro brillantes
    final goldPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(w * 0.65, h * 0.54), w * 0.02, goldPaint);
    canvas.drawCircle(Offset(w * 0.69, h * 0.53), w * 0.022, goldPaint);
    canvas.drawCircle(Offset(w * 0.73, h * 0.55), w * 0.018, goldPaint);

    // Delfín saltando en las olas
    _drawDolphin(canvas, Offset(w * 0.82, h * 0.80), w * 0.12);
  }

  // --------------------------------------------------------------------------
  // ESCENA 4: EL LEÓN MÚSICO
  // --------------------------------------------------------------------------
  void _drawJungleLion(Canvas canvas, double w, double h) {
    // Fondo selva tropical verde intenso
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = const LinearGradient(colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, 0, w, h)));

    // Hojas gigantes de monstera en las esquinas
    _drawJungleLeaves(canvas, w, h);

    // LEÓN CON MELENA RADIANTE
    final lionPos = Offset(w * 0.44, h * 0.50);

    // Gran melena esponjosa naranja
    for (int i = 0; i < 14; i++) {
      final angle = (2 * pi / 14) * i;
      final mx = lionPos.dx + cos(angle) * w * 0.18;
      final my = lionPos.dy + sin(angle) * h * 0.18;
      canvas.drawCircle(Offset(mx, my), w * 0.09, Paint()..color = const Color(0xFFFF8F00));
    }
    canvas.drawCircle(lionPos, w * 0.20, Paint()..color = const Color(0xFFFFA000));

    // Cara del león amarilla
    canvas.drawCircle(lionPos, w * 0.14, Paint()..color = const Color(0xFFFFD54F));
    // Nariz triangular y hocico blanco
    canvas.drawCircle(Offset(lionPos.dx, lionPos.dy + h * 0.04), w * 0.05, Paint()..color = Colors.white);
    final nosePath = Path()
      ..moveTo(lionPos.dx - w * 0.03, lionPos.dy + h * 0.01)
      ..lineTo(lionPos.dx + w * 0.03, lionPos.dy + h * 0.01)
      ..lineTo(lionPos.dx, lionPos.dy + h * 0.05)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFF6D4C41));

    // Ojos cariñosos
    _drawCartoonEye(canvas, Offset(lionPos.dx - w * 0.05, lionPos.dy - h * 0.02), w * 0.03);
    _drawCartoonEye(canvas, Offset(lionPos.dx + w * 0.05, lionPos.dy - h * 0.02), w * 0.03);

    // Sonrisa feliz
    final lionSmile = Path()..moveTo(lionPos.dx - w * 0.04, lionPos.dy + h * 0.06)..quadraticBezierTo(lionPos.dx, lionPos.dy + h * 0.09, lionPos.dx + w * 0.04, lionPos.dy + h * 0.06);
    canvas.drawPath(lionSmile, Paint()..color = Colors.brown.shade800..style = PaintingStyle.stroke..strokeWidth = 3);

    // GUITARRA ACÚSTICA
    final guitarBody = Offset(w * 0.65, h * 0.68);
    canvas.drawCircle(guitarBody, w * 0.11, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawCircle(guitarBody, w * 0.04, Paint()..color = Colors.black87);
    // Mástil de la guitarra
    canvas.drawLine(guitarBody, Offset(w * 0.82, h * 0.44), Paint()..color = const Color(0xFF5D4037)..strokeWidth = 8);

    // Notas musicales flotando en el aire (rosa, azul, verde)
    _drawMusicNote(canvas, Offset(w * 0.75, h * 0.28), const Color(0xFFE91E63));
    _drawMusicNote(canvas, Offset(w * 0.85, h * 0.38), const Color(0xFF29B6F6));
    _drawMusicNote(canvas, Offset(w * 0.20, h * 0.34), const Color(0xFF4CAF50));
  }

  // --------------------------------------------------------------------------
  // ESCENA 5: CASTILLO DE HELADOS Y ARCOÍRIS
  // --------------------------------------------------------------------------
  void _drawIceCreamCastle(Canvas canvas, double w, double h) {
    // Fondo cielo de fantasía
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = const LinearGradient(colors: [Color(0xFFFCE4EC), Color(0xFFE1BEE7)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, 0, w, h)));

    // GRAN ARCOÍRIS BRILLANTE
    _drawRainbow(canvas, Offset(w * 0.5, h * 0.95), w * 0.45);

    // Nubes de algodón de azúcar
    _drawCloud(canvas, Offset(w * 0.20, h * 0.70), w * 0.16, color: const Color(0xFFF8BBD0));
    _drawCloud(canvas, Offset(w * 0.80, h * 0.70), w * 0.16, color: const Color(0xFFB3E5FC));

    // CASTILLO MÁGICO DE HELADO
    final castleCenter = Offset(w * 0.50, h * 0.60);
    // Muro principal de galletita
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: castleCenter, width: w * 0.44, height: h * 0.32), const Radius.circular(16)), Paint()..color = const Color(0xFFFFE082));

    // Puerta de chocolate arqueada
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(castleCenter.dx, castleCenter.dy + h * 0.08), width: w * 0.12, height: h * 0.16), const Radius.circular(12)), Paint()..color = const Color(0xFF5D4037));

    // Torres laterales de barquillo (cucurucho invertido)
    _drawIceCreamTower(canvas, Offset(w * 0.28, h * 0.48), w * 0.12, h * 0.32, const Color(0xFFF48FB1)); // Fresa
    _drawIceCreamTower(canvas, Offset(w * 0.72, h * 0.48), w * 0.12, h * 0.32, const Color(0xFF80DEEA)); // Menta

    // Torre central con gran bola de helado y cereza
    canvas.drawCircle(Offset(castleCenter.dx, castleCenter.dy - h * 0.16), w * 0.10, Paint()..color = const Color(0xFFFF80AB));
    // Cereza brillante en la cima
    canvas.drawCircle(Offset(castleCenter.dx, castleCenter.dy - h * 0.26), w * 0.03, Paint()..color = const Color(0xFFD50000));
    canvas.drawLine(Offset(castleCenter.dx, castleCenter.dy - h * 0.28), Offset(castleCenter.dx + w * 0.02, castleCenter.dy - h * 0.32), Paint()..color = const Color(0xFF388E3C)..strokeWidth = 2);

    // Estrellitas y chispitas de colores
    _drawSparkle(canvas, Offset(w * 0.18, h * 0.24));
    _drawSparkle(canvas, Offset(w * 0.82, h * 0.22));
    _drawSparkle(canvas, Offset(w * 0.50, h * 0.18));
  }

  // --------------------------------------------------------------------------
  // ESCENA 6: SUBMARINO AMARILLO Y PULPO
  // --------------------------------------------------------------------------
  void _drawYellowSubmarine(Canvas canvas, double w, double h) {
    // Mar azul profundo
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = const LinearGradient(colors: [Color(0xFF00ACC1), Color(0xFF006064), Color(0xFF001F3F)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, 0, w, h)));

    // Burbujas subiendo
    _drawBubbles(canvas, w, h);

    // Corales multicolores en el fondo marino
    _drawCoralReef(canvas, w, h);

    // SUBMARINO AMARILLO
    final subCenter = Offset(w * 0.38, h * 0.45);
    // Fuselaje
    final subBody = RRect.fromRectAndRadius(Rect.fromCenter(center: subCenter, width: w * 0.44, height: h * 0.22), const Radius.circular(40));
    canvas.drawRRect(subBody, Paint()..color = const Color(0xFFFFEB3B));

    // Periscopio
    final periscopePath = Path()..moveTo(subCenter.dx, subCenter.dy - h * 0.11)..lineTo(subCenter.dx, subCenter.dy - h * 0.20)..lineTo(subCenter.dx + w * 0.06, subCenter.dy - h * 0.20);
    canvas.drawPath(periscopePath, Paint()..color = const Color(0xFFFBC02D)..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round);

    // Ventana redonda con pececito saludando
    canvas.drawCircle(subCenter, w * 0.07, Paint()..color = const Color(0xFF81D4FA));
    canvas.drawCircle(subCenter, w * 0.07, Paint()..color = const Color(0xFFF57F17)..style = PaintingStyle.stroke..strokeWidth = 4);

    // Hélice giratoria atrás
    canvas.drawOval(Rect.fromCenter(center: Offset(subCenter.dx - w * 0.23, subCenter.dy), width: w * 0.04, height: h * 0.12), Paint()..color = const Color(0xFFFF9800));

    // PULPO MORADO SIMPÁTICO A LA DERECHA
    final octopusPos = Offset(w * 0.74, h * 0.54);
    // Cabeza redonda
    canvas.drawCircle(octopusPos, w * 0.12, Paint()..color = const Color(0xFFBA68C8));
    // Ojos gigantes
    _drawCartoonEye(canvas, Offset(octopusPos.dx - w * 0.04, octopusPos.dy - h * 0.02), w * 0.035);
    _drawCartoonEye(canvas, Offset(octopusPos.dx + w * 0.04, octopusPos.dy - h * 0.02), w * 0.035);
    // Sonrisa pícara
    final octoSmile = Path()..moveTo(octopusPos.dx - w * 0.03, octopusPos.dy + h * 0.04)..quadraticBezierTo(octopusPos.dx, octopusPos.dy + h * 0.07, octopusPos.dx + w * 0.03, octopusPos.dy + h * 0.04);
    canvas.drawPath(octoSmile, Paint()..color = Colors.purple.shade900..style = PaintingStyle.stroke..strokeWidth = 3);

    // Tentáculos ondeando
    for (int i = 0; i < 5; i++) {
      final tx = octopusPos.dx - w * 0.10 + i * w * 0.05;
      final tentacle = Path()..moveTo(tx, octopusPos.dy + h * 0.10)..quadraticBezierTo(tx + (i.isEven ? 10 : -10), octopusPos.dy + h * 0.20, tx + (i.isEven ? -6 : 8), octopusPos.dy + h * 0.26);
      canvas.drawPath(tentacle, Paint()..color = const Color(0xFFAB47BC)..style = PaintingStyle.stroke..strokeWidth = 7..strokeCap = StrokeCap.round);
    }
  }

  // --------------------------------------------------------------------------
  // ESCENA 7: ROBOT CHEF DE PIZZA
  // --------------------------------------------------------------------------
  void _drawPizzaRobot(Canvas canvas, double w, double h) {
    // Fondo de cocina cálida a cuadros
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFFFF3E0));
    _drawKitchenTiles(canvas, w, h);

    // ROBOT AZUL SIMPÁTICO
    final robotCenter = Offset(w * 0.40, h * 0.58);
    // Cuerpo rectangular con pantalla de corazón
    final bodyRect = RRect.fromRectAndRadius(Rect.fromCenter(center: robotCenter, width: w * 0.32, height: h * 0.30), const Radius.circular(18));
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF42A5F5));
    // Pantallita con corazón
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: robotCenter, width: w * 0.18, height: h * 0.12), const Radius.circular(8)), Paint()..color = const Color(0xFF1E88E5));
    canvas.drawCircle(robotCenter, w * 0.03, Paint()..color = const Color(0xFFFF4081));

    // Cabeza cúbica del robot
    final headRect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(robotCenter.dx, robotCenter.dy - h * 0.22), width: w * 0.26, height: h * 0.16), const Radius.circular(14));
    canvas.drawRRect(headRect, Paint()..color = const Color(0xFF64B5F6));
    // Antena con bombillita amarilla
    canvas.drawLine(Offset(robotCenter.dx, robotCenter.dy - h * 0.30), Offset(robotCenter.dx, robotCenter.dy - h * 0.36), Paint()..color = Colors.grey.shade700..strokeWidth = 3);
    canvas.drawCircle(Offset(robotCenter.dx, robotCenter.dy - h * 0.36), w * 0.025, Paint()..color = const Color(0xFFFFEA00));

    // Ojos luminosos de robot
    canvas.drawCircle(Offset(robotCenter.dx - w * 0.06, robotCenter.dy - h * 0.22), w * 0.03, Paint()..color = const Color(0xFF00E676));
    canvas.drawCircle(Offset(robotCenter.dx + w * 0.06, robotCenter.dy - h * 0.22), w * 0.03, Paint()..color = const Color(0xFF00E676));

    // Gorro blanco de chef en la cabeza
    final hatPath = Path()
      ..moveTo(robotCenter.dx - w * 0.12, robotCenter.dy - h * 0.30)
      ..lineTo(robotCenter.dx - w * 0.14, robotCenter.dy - h * 0.40)
      ..quadraticBezierTo(robotCenter.dx, robotCenter.dy - h * 0.45, robotCenter.dx + w * 0.14, robotCenter.dy - h * 0.40)
      ..lineTo(robotCenter.dx + w * 0.12, robotCenter.dy - h * 0.30)
      ..close();
    canvas.drawPath(hatPath, Paint()..color = Colors.white);

    // PIZZA GIGANTE FLOTANDO EN EL AIRE A LA DERECHA
    final pizzaCenter = Offset(w * 0.74, h * 0.36);
    canvas.drawOval(Rect.fromCenter(center: pizzaCenter, width: w * 0.38, height: h * 0.20), Paint()..color = const Color(0xFFFFB74D)); // Masa
    canvas.drawOval(Rect.fromCenter(center: pizzaCenter, width: w * 0.32, height: h * 0.16), Paint()..color = const Color(0xFFFFD54F)); // Queso
    // Rodajas de pepperoni
    canvas.drawCircle(Offset(pizzaCenter.dx - w * 0.08, pizzaCenter.dy - h * 0.02), w * 0.03, Paint()..color = const Color(0xFFD32F2F));
    canvas.drawCircle(Offset(pizzaCenter.dx + w * 0.06, pizzaCenter.dy - h * 0.01), w * 0.032, Paint()..color = const Color(0xFFD32F2F));
    canvas.drawCircle(Offset(pizzaCenter.dx, pizzaCenter.dy + h * 0.03), w * 0.028, Paint()..color = const Color(0xFFD32F2F));
    // Aceitunas negras
    canvas.drawCircle(Offset(pizzaCenter.dx - w * 0.02, pizzaCenter.dy - h * 0.03), w * 0.015, Paint()..color = Colors.black87);
  }

  // --------------------------------------------------------------------------
  // ESCENA 8: CERDITO EN EL CHARCO
  // --------------------------------------------------------------------------
  void _drawPuddlePiggy(Canvas canvas, double w, double h) {
    // Campo soleado con cielo celeste
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = const LinearGradient(colors: [Color(0xFF81D4FA), Color(0xFFC8E6C9)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, 0, w, h)));

    // Sol con rayos alegres
    canvas.drawCircle(Offset(w * 0.16, h * 0.18), w * 0.09, Paint()..color = const Color(0xFFFFD54F));

    // Cerco de madera blanco y girasoles al fondo
    _drawFenceAndFlowers(canvas, w, h);

    // Charco de agua con reflejos de arcoíris
    final puddleCenter = Offset(w * 0.50, h * 0.78);
    canvas.drawOval(Rect.fromCenter(center: puddleCenter, width: w * 0.65, height: h * 0.18), Paint()..color = const Color(0xFF80DEEA));
    // Salpicaduras de agua
    _drawWaterSplashes(canvas, puddleCenter, w * 0.08);

    // CERDITO ROSADO GORDITO
    final pigCenter = Offset(w * 0.50, h * 0.52);
    // Cuerpo redondo
    canvas.drawCircle(pigCenter, w * 0.20, Paint()..color = const Color(0xFFF48FB1));

    // Orejitas caídas
    final ear1 = Path()..moveTo(pigCenter.dx - w * 0.14, pigCenter.dy - h * 0.12)..lineTo(pigCenter.dx - w * 0.20, pigCenter.dy - h * 0.04)..lineTo(pigCenter.dx - w * 0.08, pigCenter.dy - h * 0.08)..close();
    canvas.drawPath(ear1, Paint()..color = const Color(0xFFEC407A));
    final ear2 = Path()..moveTo(pigCenter.dx + w * 0.14, pigCenter.dy - h * 0.12)..lineTo(pigCenter.dx + w * 0.20, pigCenter.dy - h * 0.04)..lineTo(pigCenter.dx + w * 0.08, pigCenter.dy - h * 0.08)..close();
    canvas.drawPath(ear2, Paint()..color = const Color(0xFFEC407A));

    // Hocico redondo con dos orificios
    final snoutCenter = Offset(pigCenter.dx, pigCenter.dy + h * 0.03);
    canvas.drawOval(Rect.fromCenter(center: snoutCenter, width: w * 0.14, height: h * 0.09), Paint()..color = const Color(0xFFF06292));
    canvas.drawCircle(Offset(snoutCenter.dx - w * 0.03, snoutCenter.dy), w * 0.015, Paint()..color = const Color(0xFF880E4F));
    canvas.drawCircle(Offset(snoutCenter.dx + w * 0.03, snoutCenter.dy), w * 0.015, Paint()..color = const Color(0xFF880E4F));

    // Ojos alegres y mejillas rosadas
    _drawCartoonEye(canvas, Offset(pigCenter.dx - w * 0.08, pigCenter.dy - h * 0.04), w * 0.03);
    _drawCartoonEye(canvas, Offset(pigCenter.dx + w * 0.08, pigCenter.dy - h * 0.04), w * 0.03);
    canvas.drawCircle(Offset(pigCenter.dx - w * 0.12, pigCenter.dy + h * 0.04), w * 0.03, Paint()..color = const Color(0xFFFF4081).withValues(alpha: 0.5));
    canvas.drawCircle(Offset(pigCenter.dx + w * 0.12, pigCenter.dy + h * 0.04), w * 0.03, Paint()..color = const Color(0xFFFF4081).withValues(alpha: 0.5));

    // Botas de lluvia amarillas relucientes
    _drawRainBoot(canvas, Offset(pigCenter.dx - w * 0.08, pigCenter.dy + h * 0.18), w * 0.08);
    _drawRainBoot(canvas, Offset(pigCenter.dx + w * 0.08, pigCenter.dy + h * 0.18), w * 0.08);

    // Mariposa revoloteando a la derecha
    _drawButterfly(canvas, Offset(w * 0.82, h * 0.32), w * 0.08);
  }

  // --------------------------------------------------------------------------
  // ESCENA 9: EL TREN DE LOS ANIMALITOS
  // --------------------------------------------------------------------------
  void _drawAnimalTrain(Canvas canvas, double w, double h) {
    // Paisaje de colinas verdes
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = const LinearGradient(colors: [Color(0xFFE1F5FE), Color(0xFFA5D6A7)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, 0, w, h)));

    // Vías del tren
    final trackY = h * 0.76;
    canvas.drawLine(Offset(0, trackY), Offset(w, trackY), Paint()..color = const Color(0xFF795548)..strokeWidth = 6);
    canvas.drawLine(Offset(0, trackY + 8), Offset(w, trackY + 8), Paint()..color = const Color(0xFF795548)..strokeWidth = 6);

    // TREN A VAPOR ROJO Y DORADO
    final trainRect = Rect.fromLTWH(w * 0.15, h * 0.44, w * 0.45, h * 0.28);
    canvas.drawRRect(RRect.fromRectAndRadius(trainRect, const Radius.circular(12)), Paint()..color = const Color(0xFFD32F2F));

    // Chimenea echando humo de corazones
    canvas.drawRect(Rect.fromLTWH(w * 0.20, h * 0.34, w * 0.08, h * 0.10), Paint()..color = const Color(0xFFFBC02D));
    _drawHeartSmoke(canvas, Offset(w * 0.24, h * 0.24), w * 0.06);
    _drawHeartSmoke(canvas, Offset(w * 0.32, h * 0.14), w * 0.08);

    // Ventanilla con PANDA MAQUINISTA
    final cabWindow = Rect.fromLTWH(w * 0.42, h * 0.48, w * 0.15, h * 0.14);
    canvas.drawRRect(RRect.fromRectAndRadius(cabWindow, const Radius.circular(8)), Paint()..color = const Color(0xFF81D4FA));
    // Carita de oso panda
    final pandaPos = Offset(cabWindow.center.dx, cabWindow.center.dy + 4);
    canvas.drawCircle(pandaPos, w * 0.05, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(pandaPos.dx - w * 0.04, pandaPos.dy - h * 0.04), w * 0.02, Paint()..color = Colors.black87);
    canvas.drawCircle(Offset(pandaPos.dx + w * 0.04, pandaPos.dy - h * 0.04), w * 0.02, Paint()..color = Colors.black87);
    canvas.drawCircle(Offset(pandaPos.dx - w * 0.02, pandaPos.dy), w * 0.015, Paint()..color = Colors.black87); // Ojo panda
    canvas.drawCircle(Offset(pandaPos.dx + w * 0.02, pandaPos.dy), w * 0.015, Paint()..color = Colors.black87);

    // Vagón de pasajeros con JIRAFA CURIOSA asomando el cuello
    final wagonRect = Rect.fromLTWH(w * 0.65, h * 0.50, w * 0.30, h * 0.22);
    canvas.drawRRect(RRect.fromRectAndRadius(wagonRect, const Radius.circular(10)), Paint()..color = const Color(0xFF1976D2));
    // Cuello largo de jirafa
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.74, h * 0.24, w * 0.08, h * 0.28), const Radius.circular(10)), Paint()..color = const Color(0xFFFFB74D));
    // Cabeza de jirafa con cuernitos
    canvas.drawCircle(Offset(w * 0.78, h * 0.22), w * 0.045, Paint()..color = const Color(0xFFFFB74D));
    canvas.drawCircle(Offset(w * 0.76, h * 0.16), w * 0.012, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawCircle(Offset(w * 0.80, h * 0.16), w * 0.012, Paint()..color = const Color(0xFF8D6E63));

    // Ruedas del tren
    _drawWheel(canvas, Offset(w * 0.24, h * 0.74), w * 0.06);
    _drawWheel(canvas, Offset(w * 0.40, h * 0.74), w * 0.06);
    _drawWheel(canvas, Offset(w * 0.72, h * 0.74), w * 0.06);
    _drawWheel(canvas, Offset(w * 0.88, h * 0.74), w * 0.06);
  }

  // --------------------------------------------------------------------------
  // ESCENA 10: GASPAR EL DRAGÓN DE LAS BURBUJAS
  // --------------------------------------------------------------------------
  void _drawBubbleDragon(Canvas canvas, double w, double h) {
    // Montaña mágica al atardecer
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = const LinearGradient(colors: [Color(0xFFCE93D8), Color(0xFFFFCCBC), Color(0xFFC8E6C9)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, 0, w, h)));

    // Montaña Esmeralda al fondo
    final mountain = Path()..moveTo(w * 0.10, h * 0.80)..lineTo(w * 0.45, h * 0.25)..lineTo(w * 0.85, h * 0.80)..close();
    canvas.drawPath(mountain, Paint()..color = const Color(0xFFA5D6A7).withValues(alpha: 0.6));

    // DRAGÓN GASPAR VERDE ESMERALDA
    final dragonCenter = Offset(w * 0.35, h * 0.60);
    // Pancita lila
    canvas.drawOval(Rect.fromCenter(center: dragonCenter, width: w * 0.36, height: h * 0.32), Paint()..color = const Color(0xFF66BB6A));
    canvas.drawOval(Rect.fromCenter(center: Offset(dragonCenter.dx + w * 0.04, dragonCenter.dy + h * 0.02), width: w * 0.20, height: h * 0.20), Paint()..color = const Color(0xFFE1BEE7));

    // Alitas lilas de dragón
    final wing = Path()..moveTo(dragonCenter.dx - w * 0.10, dragonCenter.dy - h * 0.08)..quadraticBezierTo(dragonCenter.dx - w * 0.25, dragonCenter.dy - h * 0.22, dragonCenter.dx - w * 0.18, dragonCenter.dy - h * 0.02)..close();
    canvas.drawPath(wing, Paint()..color = const Color(0xFFAB47BC));

    // Cabeza con mejillas infladas soplando
    final dragonHead = Offset(dragonCenter.dx + w * 0.15, dragonCenter.dy - h * 0.16);
    canvas.drawCircle(dragonHead, w * 0.12, Paint()..color = const Color(0xFF81C784));

    // Ojo tierno y cuernitos amarillos
    _drawCartoonEye(canvas, Offset(dragonHead.dx - w * 0.02, dragonHead.dy - h * 0.03), w * 0.035);
    canvas.drawPath(Path()..moveTo(dragonHead.dx - w * 0.08, dragonHead.dy - h * 0.09)..lineTo(dragonHead.dx - w * 0.05, dragonHead.dy - h * 0.18)..lineTo(dragonHead.dx - w * 0.02, dragonHead.dy - h * 0.10)..close(), Paint()..color = const Color(0xFFFFD54F));

    // Mofletes inflados soplando pompas de jabón
    canvas.drawCircle(Offset(dragonHead.dx + w * 0.08, dragonHead.dy + h * 0.03), w * 0.04, Paint()..color = const Color(0xFFA5D6A7));

    // NUBE DE BURBUJAS DE JABÓN GIGANTES DE COLORES ARCOÍRIS
    _drawRainbowBubble(canvas, Offset(w * 0.65, h * 0.35), w * 0.10);
    _drawRainbowBubble(canvas, Offset(w * 0.82, h * 0.24), w * 0.08);
    _drawRainbowBubble(canvas, Offset(w * 0.78, h * 0.52), w * 0.12);
    _drawRainbowBubble(canvas, Offset(w * 0.58, h * 0.55), w * 0.06);
    _drawRainbowBubble(canvas, Offset(w * 0.90, h * 0.44), w * 0.05);

    // Conejito del bosque saltando feliz a la derecha
    _drawCuteBunny(canvas, Offset(w * 0.85, h * 0.78), w * 0.09);
  }

  // ==========================================================================
  // ELEMENTOS GRÁFICOS REUTILIZABLES DE ALTA CALIDAD
  // ==========================================================================

  void _drawCartoonEye(Canvas canvas, Offset center, double radius) {
    // Esclerótica blanca
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius, Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2);
    // Iris negro / pupila
    canvas.drawCircle(Offset(center.dx + radius * 0.15, center.dy), radius * 0.65, Paint()..color = const Color(0xFF212121));
    // Brillo blanco grande
    canvas.drawCircle(Offset(center.dx + radius * 0.35, center.dy - radius * 0.30), radius * 0.28, Paint()..color = Colors.white);
    // Brillo secundario pequeño
    canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.25), radius * 0.14, Paint()..color = Colors.white);
  }

  void _drawSmileyFace(Canvas canvas, Offset center, double radius) {
    _drawCartoonEye(canvas, Offset(center.dx - radius * 0.35, center.dy - radius * 0.15), radius * 0.20);
    _drawCartoonEye(canvas, Offset(center.dx + radius * 0.35, center.dy - radius * 0.15), radius * 0.20);
    final smile = Path()..moveTo(center.dx - radius * 0.45, center.dy + radius * 0.20)..quadraticBezierTo(center.dx, center.dy + radius * 0.60, center.dx + radius * 0.45, center.dy + radius * 0.20);
    canvas.drawPath(smile, Paint()..color = const Color(0xFFE65100)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round);
  }

  void _drawCloud(Canvas canvas, Offset center, double size, {Color color = Colors.white}) {
    final p = Paint()..color = color;
    canvas.drawCircle(center, size * 0.5, p);
    canvas.drawCircle(Offset(center.dx - size * 0.4, center.dy + size * 0.1), size * 0.35, p);
    canvas.drawCircle(Offset(center.dx + size * 0.4, center.dy + size * 0.1), size * 0.38, p);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - size * 0.6, center.dy, size * 1.2, size * 0.4), Radius.circular(size * 0.2)), p);
  }

  void _drawBuntingFlags(Canvas canvas, double w, double y) {
    final colors = [const Color(0xFFFF1744), const Color(0xFFFFEA00), const Color(0xFF00E676), const Color(0xFF2979FF), const Color(0xFFFF4081)];
    const int count = 7;
    final step = w / count;
    final linePath = Path()..moveTo(0, y);
    for (int i = 0; i < count; i++) {
      final x0 = i * step;
      final x1 = (i + 1) * step;
      final xm = (x0 + x1) / 2;
      linePath.quadraticBezierTo(xm, y + 10, x1, y);

      final flag = Path()..moveTo(x0, y + 4)..lineTo(xm, y + 26)..lineTo(x1, y + 4)..close();
      canvas.drawPath(flag, Paint()..color = colors[i % colors.length]);
    }
    canvas.drawPath(linePath, Paint()..color = Colors.brown.shade700..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  void _drawBalloon(Canvas canvas, Offset center, Color color, double radius) {
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * 1.8, height: radius * 2.3), Paint()..color = color);
    // Brillo blanco en globo
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - radius * 0.35, center.dy - radius * 0.40), width: radius * 0.4, height: radius * 0.8), Paint()..color = Colors.white.withValues(alpha: 0.6));
    // Hilo
    canvas.drawLine(Offset(center.dx, center.dy + radius * 1.15), Offset(center.dx + 4, center.dy + radius * 2.5), Paint()..color = Colors.grey.shade600..strokeWidth = 1.5);
  }

  void _drawPuppyFace(Canvas canvas, Offset center, double size) {
    // Cara dorada
    canvas.drawCircle(center, size, Paint()..color = const Color(0xFFFFB74D));
    // Orejas caídas marrones
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - size * 0.8, center.dy), width: size * 0.6, height: size * 1.2), Paint()..color = const Color(0xFF8D6E63));
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + size * 0.8, center.dy), width: size * 0.6, height: size * 1.2), Paint()..color = const Color(0xFF8D6E63));
    // Ojos
    _drawCartoonEye(canvas, Offset(center.dx - size * 0.35, center.dy - size * 0.15), size * 0.24);
    _drawCartoonEye(canvas, Offset(center.dx + size * 0.35, center.dy - size * 0.15), size * 0.24);
    // Hocico y naricita
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + size * 0.30), width: size * 0.6, height: size * 0.4), Paint()..color = const Color(0xFFFFE0B2));
    canvas.drawCircle(Offset(center.dx, center.dy + size * 0.20), size * 0.14, Paint()..color = Colors.black87);
  }

  void _drawBone(Canvas canvas, Offset center, double size) {
    final p = Paint()..color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: size * 1.4, height: size * 0.3), Radius.circular(size * 0.15)), p);
    canvas.drawCircle(Offset(center.dx - size * 0.7, center.dy - size * 0.2), size * 0.2, p);
    canvas.drawCircle(Offset(center.dx - size * 0.7, center.dy + size * 0.2), size * 0.2, p);
    canvas.drawCircle(Offset(center.dx + size * 0.7, center.dy - size * 0.2), size * 0.2, p);
    canvas.drawCircle(Offset(center.dx + size * 0.7, center.dy + size * 0.2), size * 0.2, p);
  }

  void _drawCrescentMoon(Canvas canvas, Offset center, double size) {
    final moonBase = Path()..addOval(Rect.fromCircle(center: center, radius: size));
    final moonCut = Path()..addOval(Rect.fromCircle(center: Offset(center.dx + size * 0.45, center.dy - size * 0.20), radius: size * 0.90));
    final moon = Path.combine(PathOperation.difference, moonBase, moonCut);
    canvas.drawPath(moon, Paint()..color = const Color(0xFFFFEE58));
  }

  void _drawOceanWaves(Canvas canvas, double w, double h) {
    final wavePath = Path()..moveTo(0, h * 0.62);
    for (double x = 0; x <= w; x += 40) {
      wavePath.quadraticBezierTo(x + 20, h * 0.62 - 12, x + 40, h * 0.62);
    }
    wavePath.lineTo(w, h);
    wavePath.lineTo(0, h);
    wavePath.close();
    canvas.drawPath(wavePath, Paint()..color = const Color(0xFF0288D1));

    final wavePath2 = Path()..moveTo(0, h * 0.70);
    for (double x = 0; x <= w; x += 35) {
      wavePath2.quadraticBezierTo(x + 17.5, h * 0.70 + 10, x + 35, h * 0.70);
    }
    wavePath2.lineTo(w, h);
    wavePath2.lineTo(0, h);
    wavePath2.close();
    canvas.drawPath(wavePath2, Paint()..color = const Color(0xFF01579B));
  }

  void _drawDolphin(Canvas canvas, Offset center, double size) {
    final path = Path()
      ..moveTo(center.dx - size * 0.6, center.dy)
      ..quadraticBezierTo(center.dx, center.dy - size * 0.5, center.dx + size * 0.6, center.dy + size * 0.3)
      ..quadraticBezierTo(center.dx, center.dy - size * 0.1, center.dx - size * 0.6, center.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF4FC3F7));
  }

  void _drawJungleLeaves(Canvas canvas, double w, double h) {
    final leafPaint = Paint()..color = const Color(0xFF388E3C);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.08, h * 0.08), width: w * 0.28, height: h * 0.18), leafPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.92, h * 0.08), width: w * 0.28, height: h * 0.18), leafPaint);
  }

  void _drawMusicNote(Canvas canvas, Offset center, Color color) {
    final p = Paint()..color = color;
    canvas.drawOval(Rect.fromCenter(center: center, width: 14, height: 10), p);
    canvas.drawLine(Offset(center.dx + 5, center.dy), Offset(center.dx + 5, center.dy - 22), Paint()..color = color..strokeWidth = 3);
    canvas.drawLine(Offset(center.dx + 5, center.dy - 22), Offset(center.dx + 12, center.dy - 16), Paint()..color = color..strokeWidth = 3);
  }

  void _drawRainbow(Canvas canvas, Offset center, double maxRadius) {
    final colors = [const Color(0xFFFF1744), const Color(0xFFFF9100), const Color(0xFFFFEA00), const Color(0xFF00E676), const Color(0xFF2979FF), const Color(0xFFD500F9)];
    for (int i = 0; i < colors.length; i++) {
      final r = maxRadius - i * 9.0;
      canvas.drawCircle(center, r, Paint()..color = colors[i]..style = PaintingStyle.stroke..strokeWidth = 8);
    }
  }

  void _drawIceCreamTower(Canvas canvas, Offset top, double width, double height, Color scoopColor) {
    // Barquillo triangular
    final cone = Path()..moveTo(top.dx - width / 2, top.dy + height * 0.2)..lineTo(top.dx + width / 2, top.dy + height * 0.2)..lineTo(top.dx, top.dy + height)..close();
    canvas.drawPath(cone, Paint()..color = const Color(0xFFFFB74D));
    // Bola de helado encima
    canvas.drawCircle(Offset(top.dx, top.dy + height * 0.1), width * 0.65, Paint()..color = scoopColor);
  }

  void _drawSparkle(Canvas canvas, Offset center) {
    final p = Paint()..color = const Color(0xFFFFD700);
    canvas.drawLine(Offset(center.dx - 8, center.dy), Offset(center.dx + 8, center.dy), p..strokeWidth = 2);
    canvas.drawLine(Offset(center.dx, center.dy - 8), Offset(center.dx, center.dy + 8), p..strokeWidth = 2);
  }

  void _drawBubbles(Canvas canvas, double w, double h) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.6);
    final offsets = [Offset(w * 0.2, h * 0.3), Offset(w * 0.24, h * 0.22), Offset(w * 0.60, h * 0.25), Offset(w * 0.88, h * 0.40), Offset(w * 0.82, h * 0.30)];
    for (final off in offsets) {
      canvas.drawCircle(off, 7, p);
      canvas.drawCircle(Offset(off.dx - 2, off.dy - 2), 2, Paint()..color = Colors.white);
    }
  }

  void _drawCoralReef(Canvas canvas, double w, double h) {
    final coralColors = [const Color(0xFFFF4081), const Color(0xFFFFAB40), const Color(0xFF69F0AE)];
    for (int i = 0; i < 6; i++) {
      canvas.drawCircle(Offset(w * 0.15 + i * w * 0.14, h * 0.92), w * 0.08, Paint()..color = coralColors[i % coralColors.length]);
    }
  }

  void _drawKitchenTiles(Canvas canvas, double w, double h) {
    final p = Paint()..color = Colors.orange.withValues(alpha: 0.08);
    for (double y = 0; y < h; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(w, y), p..strokeWidth = 2);
    }
  }

  void _drawFenceAndFlowers(Canvas canvas, double w, double h) {
    final fence = Paint()..color = Colors.white..strokeWidth = 4;
    canvas.drawLine(Offset(0, h * 0.40), Offset(w, h * 0.40), fence);
    canvas.drawLine(Offset(0, h * 0.48), Offset(w, h * 0.48), fence);
    for (double x = 10; x < w; x += 30) {
      canvas.drawLine(Offset(x, h * 0.35), Offset(x, h * 0.52), fence);
    }
  }

  void _drawWaterSplashes(Canvas canvas, Offset center, double size) {
    final p = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(Offset(center.dx - size * 1.5, center.dy - size * 0.8), 5, p);
    canvas.drawCircle(Offset(center.dx + size * 1.5, center.dy - size * 0.8), 5, p);
    canvas.drawCircle(Offset(center.dx, center.dy - size * 1.2), 6, p);
  }

  void _drawRainBoot(Canvas canvas, Offset pos, double size) {
    final boot = Path()
      ..moveTo(pos.dx - size * 0.3, pos.dy)
      ..lineTo(pos.dx + size * 0.2, pos.dy)
      ..lineTo(pos.dx + size * 0.2, pos.dy + size * 0.6)
      ..lineTo(pos.dx + size * 0.6, pos.dy + size * 0.6)
      ..lineTo(pos.dx + size * 0.6, pos.dy + size * 0.9)
      ..lineTo(pos.dx - size * 0.3, pos.dy + size * 0.9)
      ..close();
    canvas.drawPath(boot, Paint()..color = const Color(0xFFFFD600));
  }

  void _drawButterfly(Canvas canvas, Offset center, double size) {
    final p = Paint()..color = const Color(0xFFFF4081);
    canvas.drawCircle(Offset(center.dx - size * 0.4, center.dy - size * 0.3), size * 0.4, p);
    canvas.drawCircle(Offset(center.dx + size * 0.4, center.dy - size * 0.3), size * 0.4, p);
    canvas.drawCircle(Offset(center.dx - size * 0.3, center.dy + size * 0.3), size * 0.3, Paint()..color = const Color(0xFFFF80AB));
    canvas.drawCircle(Offset(center.dx + size * 0.3, center.dy + size * 0.3), size * 0.3, Paint()..color = const Color(0xFFFF80AB));
    canvas.drawOval(Rect.fromCenter(center: center, width: 4, height: size * 0.9), Paint()..color = Colors.black87);
  }

  void _drawHeartSmoke(Canvas canvas, Offset center, double size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final heart = Path()
      ..moveTo(center.dx, center.dy + size * 0.5)
      ..cubicTo(center.dx - size, center.dy - size * 0.5, center.dx - size * 0.5, center.dy - size, center.dx, center.dy - size * 0.3)
      ..cubicTo(center.dx + size * 0.5, center.dy - size, center.dx + size, center.dy - size * 0.5, center.dx, center.dy + size * 0.5)
      ..close();
    canvas.drawPath(heart, p);
  }

  void _drawWheel(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(center, radius * 0.7, Paint()..color = const Color(0xFF757575));
    canvas.drawCircle(center, radius * 0.25, Paint()..color = const Color(0xFFFFD700));
  }

  void _drawRainbowBubble(Canvas canvas, Offset center, double radius) {
    final shader = const SweepGradient(
      colors: [Color(0x88FF1744), Color(0x88FFEA00), Color(0x8800E676), Color(0x882979FF), Color(0x88D500F9), Color(0x88FF1744)],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, Paint()..shader = shader..style = PaintingStyle.stroke..strokeWidth = 4);
    canvas.drawCircle(center, radius * 0.92, Paint()..color = Colors.white.withValues(alpha: 0.22));
    canvas.drawCircle(Offset(center.dx - radius * 0.35, center.dy - radius * 0.35), radius * 0.22, Paint()..color = Colors.white.withValues(alpha: 0.75));
  }

  void _drawCuteBunny(Canvas canvas, Offset center, double size) {
    final p = Paint()..color = Colors.white;
    canvas.drawCircle(center, size * 0.5, p);
    // Orejas largas
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - size * 0.25, center.dy - size * 0.7), width: size * 0.22, height: size * 0.8), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + size * 0.25, center.dy - size * 0.7), width: size * 0.22, height: size * 0.8), p);
    // Interior rosita de orejas
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - size * 0.25, center.dy - size * 0.7), width: size * 0.12, height: size * 0.6), Paint()..color = const Color(0xFFFF80AB));
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + size * 0.25, center.dy - size * 0.7), width: size * 0.12, height: size * 0.6), Paint()..color = const Color(0xFFFF80AB));
    // Ojitos
    canvas.drawCircle(Offset(center.dx - size * 0.18, center.dy - size * 0.05), 3, Paint()..color = Colors.black87);
    canvas.drawCircle(Offset(center.dx + size * 0.18, center.dy - size * 0.05), 3, Paint()..color = Colors.black87);
    // Nariz rosita
    canvas.drawCircle(Offset(center.dx, center.dy + size * 0.1), 3, Paint()..color = const Color(0xFFFF4081));
  }

  @override
  bool shouldRepaint(covariant FunScenePainter oldDelegate) => oldDelegate.sceneType != sceneType;
}
