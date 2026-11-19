import 'package:flutter/material.dart';
import 'package:kids_am/features/games/puzzle/domain/models/jigsaw_piece.dart';
import 'package:kids_am/features/games/puzzle/presentation/widgets/fun_puzzle_scenes.dart';
import 'package:kids_am/features/games/puzzle/presentation/widgets/jigsaw_path_helper.dart';

class JigsawPieceThumbnail extends StatelessWidget {
  final JigsawPieceData piece;
  final FunSceneType sceneType;
  final int totalRows;
  final int totalCols;
  final double cellSize;
  final bool isFloating;

  const JigsawPieceThumbnail({
    super.key,
    required this.piece,
    required this.sceneType,
    required this.totalRows,
    required this.totalCols,
    this.cellSize = 72.0,
    this.isFloating = false,
  });

  @override
  Widget build(BuildContext context) {
    // Margen para dar espacio a las lengüetas que sobresalen (tabs)
    final margin = cellSize * 0.28;
    final totalWidth = cellSize + 2 * margin;
    final totalHeight = cellSize + 2 * margin;

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: CustomPaint(
        painter: _JigsawPieceThumbnailPainter(
          piece: piece,
          sceneType: sceneType,
          totalRows: totalRows,
          totalCols: totalCols,
          cellSize: cellSize,
          margin: margin,
          isFloating: isFloating,
        ),
      ),
    );
  }
}

class _JigsawPieceThumbnailPainter extends CustomPainter {
  final JigsawPieceData piece;
  final FunSceneType sceneType;
  final int totalRows;
  final int totalCols;
  final double cellSize;
  final double margin;
  final bool isFloating;

  _JigsawPieceThumbnailPainter({
    required this.piece,
    required this.sceneType,
    required this.totalRows,
    required this.totalCols,
    required this.cellSize,
    required this.margin,
    required this.isFloating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellRect = Rect.fromLTWH(margin, margin, cellSize, cellSize);

    final path = JigsawPathHelper.buildPiecePath(
      cellRect: cellRect,
      top: piece.top,
      right: piece.right,
      bottom: piece.bottom,
      left: piece.left,
    );

    // Sombra si está siendo arrastrada (isFloating) o en reposo
    if (isFloating) {
      canvas.drawShadow(path, Colors.black, 10.0, true);
    } else {
      canvas.drawShadow(path, Colors.black45, 4.0, false);
    }

    // Dibujar el contenido de la pieza recortado por su silueta de encastre
    canvas.save();
    canvas.clipPath(path);

    // Base de color cartón / madera prensada para el reverso
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFF5F5F5));

    // Dibujo correspondiente a este cuadrante de la escena divertida
    final fullWidth = cellSize * totalCols;
    final fullHeight = cellSize * totalRows;

    canvas.save();
    canvas.translate(margin - (piece.col * cellSize), margin - (piece.row * cellSize));
    FunScenePainter(sceneType: sceneType).paint(canvas, Size(fullWidth, fullHeight));
    canvas.restore();

    canvas.restore();

    // Borde biselado táctil de pieza física (resalta la forma de encastre)
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, borderPaint);

    final innerHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, innerHighlight);
  }

  @override
  bool shouldRepaint(covariant _JigsawPieceThumbnailPainter oldDelegate) {
    return oldDelegate.piece != piece ||
        oldDelegate.sceneType != sceneType ||
        oldDelegate.isFloating != isFloating;
  }
}
