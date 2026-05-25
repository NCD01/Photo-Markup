import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';

class MarkupHandleUtils {
  const MarkupHandleUtils._();

  static int? hitCornerIndex(
    Offset point, {
    required List<Offset> corners,
    required double hitDistance,
  }) {
    for (int i = 0; i < corners.length; i++) {
      if ((point - corners[i]).distance <= hitDistance) {
        return i;
      }
    }
    return null;
  }

  static List<Offset> rectangleCorners(Rect rect) {
    return <Offset>[
      rect.topLeft,
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft,
    ];
  }

  static Rect resizeRectFromCorner({
    required Rect currentRect,
    required int cornerIndex,
    required Offset dragPoint,
    required Rect bounds,
    required double minWidth,
    required double minHeight,
  }) {
    final Offset clampedDrag = DimensionLine.clampToRect(dragPoint, bounds);
    final List<Offset> corners = rectangleCorners(currentRect);
    final int oppositeIndex = (cornerIndex + 2) % 4;
    final Offset opposite = corners[oppositeIndex];

    double x = clampedDrag.dx;
    double y = clampedDrag.dy;
    switch (cornerIndex) {
      case 0:
        x = x.clamp(bounds.left, opposite.dx - minWidth);
        y = y.clamp(bounds.top, opposite.dy - minHeight);
        break;
      case 1:
        x = x.clamp(opposite.dx + minWidth, bounds.right);
        y = y.clamp(bounds.top, opposite.dy - minHeight);
        break;
      case 2:
        x = x.clamp(opposite.dx + minWidth, bounds.right);
        y = y.clamp(opposite.dy + minHeight, bounds.bottom);
        break;
      case 3:
        x = x.clamp(bounds.left, opposite.dx - minWidth);
        y = y.clamp(opposite.dy + minHeight, bounds.bottom);
        break;
    }

    final Offset resizedCorner = Offset(x, y);
    return Rect.fromPoints(resizedCorner, opposite);
  }
}
