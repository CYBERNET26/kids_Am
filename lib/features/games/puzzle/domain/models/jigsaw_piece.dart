enum JigsawEdgeType {
  flat,
  tab,
  blank,
}

class JigsawPieceData {
  final int index;
  final int row;
  final int col;
  final JigsawEdgeType top;
  final JigsawEdgeType right;
  final JigsawEdgeType bottom;
  final JigsawEdgeType left;

  const JigsawPieceData({
    required this.index,
    required this.row,
    required this.col,
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });

  bool get isCorner =>
      (top == JigsawEdgeType.flat && left == JigsawEdgeType.flat) ||
      (top == JigsawEdgeType.flat && right == JigsawEdgeType.flat) ||
      (bottom == JigsawEdgeType.flat && left == JigsawEdgeType.flat) ||
      (bottom == JigsawEdgeType.flat && right == JigsawEdgeType.flat);

  bool get isEdge =>
      !isCorner &&
      (top == JigsawEdgeType.flat ||
          right == JigsawEdgeType.flat ||
          bottom == JigsawEdgeType.flat ||
          left == JigsawEdgeType.flat);

  bool get isInterior =>
      top != JigsawEdgeType.flat &&
      right != JigsawEdgeType.flat &&
      bottom != JigsawEdgeType.flat &&
      left != JigsawEdgeType.flat;
}
