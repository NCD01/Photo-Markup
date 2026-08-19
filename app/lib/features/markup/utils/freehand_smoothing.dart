import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';

/// Cleans up a raw finger or stylus track before it is stored.
///
/// A line drawn one-handed on a tablet, on a ladder, in the cold, arrives as a
/// jittery chain of points. Two cheap passes fix that: drop the points that
/// carry no shape information, then round off what is left.
class FreehandSmoothing {
  const FreehandSmoothing._();

  static List<Offset> smooth(
    List<Offset> points, {
    double? simplifyTolerance,
    int? chaikinPasses,
  }) {
    if (points.length < 3) {
      return List<Offset>.of(points);
    }
    final List<Offset> simplified = simplify(
      points,
      tolerance:
          simplifyTolerance ?? FreehandSmoothingConstants.simplifyTolerance,
    );
    return chaikin(
      simplified,
      passes: chaikinPasses ?? FreehandSmoothingConstants.chaikinPasses,
    );
  }

  /// Ramer-Douglas-Peucker. Keeps the points that define the shape and drops
  /// the ones that only record hand tremor.
  static List<Offset> simplify(List<Offset> points, {required double tolerance}) {
    if (points.length < 3 || tolerance <= 0) {
      return List<Offset>.of(points);
    }
    final List<bool> keep = List<bool>.filled(points.length, false);
    keep[0] = true;
    keep[points.length - 1] = true;
    _simplifySegment(points, 0, points.length - 1, tolerance, keep);

    final List<Offset> result = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      if (keep[i]) {
        result.add(points[i]);
      }
    }
    return result;
  }

  static void _simplifySegment(
    List<Offset> points,
    int first,
    int last,
    double tolerance,
    List<bool> keep,
  ) {
    if (last <= first + 1) {
      return;
    }
    double maxDistance = -1;
    int maxIndex = first;
    for (int i = first + 1; i < last; i++) {
      final double distance = _perpendicularDistance(
        points[i],
        points[first],
        points[last],
      );
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }
    if (maxDistance <= tolerance) {
      return;
    }
    keep[maxIndex] = true;
    _simplifySegment(points, first, maxIndex, tolerance, keep);
    _simplifySegment(points, maxIndex, last, tolerance, keep);
  }

  static double _perpendicularDistance(Offset point, Offset a, Offset b) {
    final Offset segment = b - a;
    final double lengthSquared =
        (segment.dx * segment.dx) + (segment.dy * segment.dy);
    if (lengthSquared == 0) {
      return (point - a).distance;
    }
    final double projection =
        ((((point.dx - a.dx) * segment.dx) + ((point.dy - a.dy) * segment.dy)) /
                lengthSquared)
            .clamp(0.0, 1.0);
    final Offset nearest = Offset(
      a.dx + (segment.dx * projection),
      a.dy + (segment.dy * projection),
    );
    return (point - nearest).distance;
  }

  /// Chaikin corner cutting. Each pass replaces every corner with two points a
  /// quarter and three quarters along, which rounds the path without pulling
  /// it away from where the user drew.
  ///
  /// The endpoints are pinned so a stroke still starts and ends exactly where
  /// the finger touched down and lifted.
  static List<Offset> chaikin(List<Offset> points, {required int passes}) {
    if (points.length < 3 || passes <= 0) {
      return List<Offset>.of(points);
    }
    List<Offset> current = List<Offset>.of(points);
    final int safePasses = math.min(
      passes,
      FreehandSmoothingConstants.maxChaikinPasses,
    );
    for (int pass = 0; pass < safePasses; pass++) {
      if (current.length > FreehandSmoothingConstants.maxSmoothedPoints) {
        break;
      }
      final List<Offset> next = <Offset>[current.first];
      for (int i = 0; i < current.length - 1; i++) {
        final Offset a = current[i];
        final Offset b = current[i + 1];
        next.add(Offset(
          (a.dx * 0.75) + (b.dx * 0.25),
          (a.dy * 0.75) + (b.dy * 0.25),
        ));
        next.add(Offset(
          (a.dx * 0.25) + (b.dx * 0.75),
          (a.dy * 0.25) + (b.dy * 0.75),
        ));
      }
      next.add(current.last);
      current = next;
    }
    return current;
  }
}
