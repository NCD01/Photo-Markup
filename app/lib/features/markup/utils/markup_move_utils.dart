import 'package:flutter/material.dart';

class MarkupMoveUtils {
  const MarkupMoveUtils._();

  static Offset clampTranslationForPoints({
    required List<Offset> points,
    required Offset requestedDelta,
    required Rect bounds,
    required double padding,
  }) {
    if (points.isEmpty) {
      return Offset.zero;
    }

    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    for (final Offset point in points.skip(1)) {
      if (point.dx < minX) {
        minX = point.dx;
      }
      if (point.dx > maxX) {
        maxX = point.dx;
      }
      if (point.dy < minY) {
        minY = point.dy;
      }
      if (point.dy > maxY) {
        maxY = point.dy;
      }
    }

    final double leftLimit = (bounds.left + padding) - minX;
    final double rightLimit = (bounds.right - padding) - maxX;
    final double topLimit = (bounds.top + padding) - minY;
    final double bottomLimit = (bounds.bottom - padding) - maxY;

    final double dx = requestedDelta.dx.clamp(leftLimit, rightLimit);
    final double dy = requestedDelta.dy.clamp(topLimit, bottomLimit);
    return Offset(dx, dy);
  }

  static List<Offset> translatePoints(List<Offset> points, Offset translation) {
    return points
        .map((Offset point) => point + translation)
        .toList(growable: false);
  }
}
