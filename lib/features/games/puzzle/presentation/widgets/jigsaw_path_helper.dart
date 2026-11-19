import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kids_am/features/games/puzzle/domain/models/jigsaw_piece.dart';

class JigsawPathHelper {
  /// Genera la cuadrícula de piezas de rompecabezas con encastres macho/hembra
  /// (tabs y blanks) perfectamente complementarios y bordes planos en el marco exterior.
  static List<JigsawPieceData> generateGrid({
    required int rows,
    required int cols,
    int? seed,
  }) {
    final random = Random(seed ?? 42);

    // Bordes horizontales internos: (rows - 1) x cols
    // true = pieza superior tiene tab (inferior tiene blank)
    // false = pieza superior tiene blank (inferior tiene tab)
    final horizontalEdges = List.generate(
      rows - 1,
      (_) => List.generate(cols, (_) => random.nextBool()),
    );

    // Bordes verticales internos: rows x (cols - 1)
    // true = pieza izquierda tiene tab (derecha tiene blank)
    // false = pieza izquierda tiene blank (derecha tiene tab)
    final verticalEdges = List.generate(
      rows,
      (_) => List.generate(cols - 1, (_) => random.nextBool()),
    );

    final pieces = <JigsawPieceData>[];

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final index = r * cols + c;

        // Borde superior
        final JigsawEdgeType top;
        if (r == 0) {
          top = JigsawEdgeType.flat;
        } else {
          top = horizontalEdges[r - 1][c]
              ? JigsawEdgeType.blank
              : JigsawEdgeType.tab;
        }

        // Borde derecho
        final JigsawEdgeType right;
        if (c == cols - 1) {
          right = JigsawEdgeType.flat;
        } else {
          right = verticalEdges[r][c]
              ? JigsawEdgeType.tab
              : JigsawEdgeType.blank;
        }

        // Borde inferior
        final JigsawEdgeType bottom;
        if (r == rows - 1) {
          bottom = JigsawEdgeType.flat;
        } else {
          bottom = horizontalEdges[r][c]
              ? JigsawEdgeType.tab
              : JigsawEdgeType.blank;
        }

        // Borde izquierdo
        final JigsawEdgeType left;
        if (c == 0) {
          left = JigsawEdgeType.flat;
        } else {
          left = verticalEdges[r][c - 1]
              ? JigsawEdgeType.blank
              : JigsawEdgeType.tab;
        }

        pieces.add(
          JigsawPieceData(
            index: index,
            row: r,
            col: c,
            top: top,
            right: right,
            bottom: bottom,
            left: left,
          ),
        );
      }
    }

    return pieces;
  }

  /// Construye el trazado vectorial (Path) del contorno de una pieza de rompecabezas
  /// con la silueta clásica auténtica (orejitas circulares y cuellos estrechos).
  static Path buildPiecePath({
    required Rect cellRect,
    required JigsawEdgeType top,
    required JigsawEdgeType right,
    required JigsawEdgeType bottom,
    required JigsawEdgeType left,
  }) {
    final path = Path();
    final p0 = cellRect.topLeft;
    final p1 = cellRect.topRight;
    final p2 = cellRect.bottomRight;
    final p3 = cellRect.bottomLeft;

    path.moveTo(p0.dx, p0.dy);

    // Borde Superior: de p0 a p1
    _drawJigsawEdge(path, p0, p1, top);

    // Borde Derecho: de p1 a p2
    _drawJigsawEdge(path, p1, p2, right);

    // Borde Inferior: de p2 a p3
    _drawJigsawEdge(path, p2, p3, bottom);

    // Borde Izquierdo: de p3 a p0
    _drawJigsawEdge(path, p3, p0, left);

    path.close();
    return path;
  }

  /// Traza un segmento con la silueta de lengüeta redondeada / hueco de rompecabezas.
  static void _drawJigsawEdge(
    Path path,
    Offset start,
    Offset end,
    JigsawEdgeType type,
  ) {
    if (type == JigsawEdgeType.flat) {
      path.lineTo(end.dx, end.dy);
      return;
    }

    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double len = sqrt(dx * dx + dy * dy);

    if (len < 1.0) {
      path.lineTo(end.dx, end.dy);
      return;
    }

    // Tangente unitaria a lo largo del segmento
    final double tx = dx / len;
    final double ty = dy / len;

    // Normal unitaria exterior (apunta a la derecha de la dirección de avance)
    final double nx = -ty;
    final double ny = tx;

    // Signo: +1 para lengüeta sobresaliente (tab), -1 para encastre hueco (blank)
    final double sign = (type == JigsawEdgeType.tab) ? 1.0 : -1.0;

    // Función auxiliar para obtener coordenadas con desplazamiento tangente y normal
    Offset p(double t, double n) {
      return Offset(
        start.dx + (tx * t * len) + (nx * n * len * sign),
        start.dy + (ty * t * len) + (ny * n * len * sign),
      );
    }

    // Proporciones fieles a las piezas clásicas mostradas en la imagen:
    // Línea base hasta el inicio del cuello
    path.lineTo(p(0.36, 0.0).dx, p(0.36, 0.0).dy);

    // Curva hacia el cuello de la pieza (estrechamiento suave)
    path.cubicTo(
      p(0.375, -0.015).dx, p(0.375, -0.015).dy,
      p(0.388, 0.035).dx, p(0.388, 0.035).dy,
      p(0.395, 0.080).dx, p(0.395, 0.080).dy,
    );

    // Arco exterior del bulbo/cabeza redondeada
    path.cubicTo(
      p(0.375, 0.185).dx, p(0.375, 0.185).dy,
      p(0.445, 0.220).dx, p(0.445, 0.220).dy,
      p(0.500, 0.220).dx, p(0.500, 0.220).dy,
    );
    path.cubicTo(
      p(0.555, 0.220).dx, p(0.555, 0.220).dy,
      p(0.625, 0.185).dx, p(0.625, 0.185).dy,
      p(0.605, 0.080).dx, p(0.605, 0.080).dy,
    );

    // Retorno suave desde el cuello a la línea base
    path.cubicTo(
      p(0.612, 0.035).dx, p(0.612, 0.035).dy,
      p(0.625, -0.015).dx, p(0.625, -0.015).dy,
      p(0.640, 0.0).dx, p(0.640, 0.0).dy,
    );

    // Tramo final recto hasta el vértice
    path.lineTo(end.dx, end.dy);
  }
}
