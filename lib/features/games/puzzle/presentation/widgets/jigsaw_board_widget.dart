import 'package:flutter/material.dart';
import 'package:kids_am/features/games/puzzle/domain/models/jigsaw_piece.dart';
import 'package:kids_am/features/games/puzzle/presentation/widgets/fun_puzzle_scenes.dart';
import 'package:kids_am/features/games/puzzle/presentation/widgets/jigsaw_path_helper.dart';

class JigsawBoardWidget extends StatelessWidget {
  final int rows;
  final int cols;
  final List<JigsawPieceData> pieces;
  final List<int?> boardSlots;
  final FunSceneInfo sceneInfo;
  final bool isSolved;
  final Function(int slotIndex, int pieceIndex) onPieceDropped;
  final Function(int slotIndex, int pieceIndex) onWrongPieceDropped;

  const JigsawBoardWidget({
    super.key,
    required this.rows,
    required this.cols,
    required this.pieces,
    required this.boardSlots,
    required this.sceneInfo,
    required this.isSolved,
    required this.onPieceDropped,
    required this.onWrongPieceDropped,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tamaño óptimo para la cuadrícula del rompecabezas
        final maxSide = constraints.maxWidth.clamp(280.0, 380.0);
        final boardWidth = maxSide;
        final boardHeight = maxSide;
        final cellW = boardWidth / cols;
        final cellH = boardHeight / rows;

        return Center(
          child: Container(
            width: boardWidth,
            height: boardHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EAE1), // Madera de tilo claro
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSolved ? const Color(0xFFFFD54F) : const Color(0xFFBCAAA4),
                width: isSolved ? 5 : 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSolved
                      ? Colors.amber.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.14),
                  blurRadius: isSolved ? 18 : 12,
                  spreadRadius: isSolved ? 2 : 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // 1. Imagen de guía tenue al fondo (facilita la orientación del niño)
                  Opacity(
                    opacity: 0.22,
                    child: CustomPaint(
                      size: Size(boardWidth, boardHeight),
                      painter: FunScenePainter(sceneType: sceneInfo.type),
                    ),
                  ),

                  // 2. Líneas troqueladas sutiles de la cuadrícula de encastre
                  CustomPaint(
                    size: Size(boardWidth, boardHeight),
                    painter: _JigsawDieCutLinesPainter(
                      rows: rows,
                      cols: cols,
                      pieces: pieces,
                    ),
                  ),

                  // 3. Ranuras DragTarget interactivas para cada pieza
                  ...List.generate(rows * cols, (slotIndex) {
                    final r = slotIndex ~/ cols;
                    final c = slotIndex % cols;
                    final currentPlacedPieceIndex = boardSlots[slotIndex];

                    return Positioned(
                      left: c * cellW,
                      top: r * cellH,
                      width: cellW,
                      height: cellH,
                      child: DragTarget<int>(
                        onWillAcceptWithDetails: (_) => !isSolved,
                        onAcceptWithDetails: (details) {
                          final draggedPieceIndex = details.data;
                          if (draggedPieceIndex == slotIndex) {
                            onPieceDropped(slotIndex, draggedPieceIndex);
                          } else {
                            onWrongPieceDropped(slotIndex, draggedPieceIndex);
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isHovered = candidateData.isNotEmpty;

                          if (isHovered && currentPlacedPieceIndex == null) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.28),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          }
                          return const SizedBox.expand();
                        },
                      ),
                    );
                  }),

                  // 4. Piezas colocadas actualmente con su forma de encastre exacta
                  ...List.generate(rows * cols, (slotIndex) {
                    final placedIndex = boardSlots[slotIndex];
                    if (placedIndex == null) return const SizedBox.shrink();

                    final r = slotIndex ~/ cols;
                    final c = slotIndex % cols;
                    final pieceData = pieces[slotIndex];

                    return Positioned(
                      left: 0,
                      top: 0,
                      width: boardWidth,
                      height: boardHeight,
                      child: IgnorePointer(
                        child: CustomPaint(
                          size: Size(boardWidth, boardHeight),
                          painter: _PlacedPiecePainter(
                            cellRect: Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH),
                            piece: pieceData,
                            sceneType: sceneInfo.type,
                          ),
                        ),
                      ),
                    );
                  }),

                  // 5. Marco resaltador cuando está completado
                  if (isSolved)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.amberAccent, width: 3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Dibuja las líneas de troquelado o siluetas de encastre guía sobre el tablero
class _JigsawDieCutLinesPainter extends CustomPainter {
  final int rows;
  final int cols;
  final List<JigsawPieceData> pieces;

  _JigsawDieCutLinesPainter({
    required this.rows,
    required this.cols,
    required this.pieces,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    final linePaint = Paint()
      ..color = Colors.brown.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final index = r * cols + c;
        if (index >= pieces.length) continue;
        final p = pieces[index];
        final rect = Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH);

        final path = JigsawPathHelper.buildPiecePath(
          cellRect: rect,
          top: p.top,
          right: p.right,
          bottom: p.bottom,
          left: p.left,
        );
        canvas.drawPath(path, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _JigsawDieCutLinesPainter oldDelegate) {
    return oldDelegate.rows != rows || oldDelegate.cols != cols;
  }
}

/// Pinta una pieza individual ya encajada en el tablero en su posición exacta
class _PlacedPiecePainter extends CustomPainter {
  final Rect cellRect;
  final JigsawPieceData piece;
  final FunSceneType sceneType;

  _PlacedPiecePainter({
    required this.cellRect,
    required this.piece,
    required this.sceneType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = JigsawPathHelper.buildPiecePath(
      cellRect: cellRect,
      top: piece.top,
      right: piece.right,
      bottom: piece.bottom,
      left: piece.left,
    );

    // Sombra suave bajo la pieza colocada
    canvas.drawShadow(path, Colors.black, 3.0, false);

    // Dibujar porción recortada de la imagen completa
    canvas.save();
    canvas.clipPath(path);
    FunScenePainter(sceneType: sceneType).paint(canvas, size);
    canvas.restore();

    // Borde de encastre físico de la pieza
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(path, borderPaint);

    // Brillo sutil en el borde
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _PlacedPiecePainter oldDelegate) {
    return oldDelegate.cellRect != cellRect ||
        oldDelegate.piece != piece ||
        oldDelegate.sceneType != sceneType;
  }
}
