import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';

/// Makes markup look drawn by hand rather than laid on by software.
///
/// A perfectly straight machine line on a client's photo reads as a decision
/// that has already been made. The same line drawn with a marker reads as a
/// suggestion. Which one you want depends on whether you are sending a punch
/// list to a sub or an idea to a homeowner, so it is a switch, not a style.
///
/// The wobble is derived from the annotation's own id and the index of the
/// point, never from a random number generator. That matters for two reasons:
/// the line does not crawl while it is on screen, and the export is identical
/// to what was on screen rather than a second, different set of wobbles.
class MarkerMode {
  const MarkerMode._();

  /// A repeatable value in -1..1 from two integers.
  static double noise(int seed, int index) {
    final int mixed = (seed * 73856093) ^ (index * 19349663);
    // sin of a large mixed integer is well distributed and completely
    // deterministic, which is the whole point.
    final double raw = math.sin(mixed.toDouble() * 0.0001) * 43758.5453;
    return ((raw - raw.floor()) * 2.0) - 1.0;
  }

  /// Nudges each point off the machine-drawn path.
  ///
  /// The first and last points move less than the middle, so a stroke still
  /// starts and ends where it was drawn.
  static List<Offset> wobble({
    required List<Offset> points,
    required int seed,
    required double amplitude,
  }) {
    if (points.length < 2 || amplitude <= 0) {
      return points;
    }
    final List<Offset> result = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final double endFalloff = _endFalloff(i, points.length);
      final double dx = noise(seed, i * 2) * amplitude * endFalloff;
      final double dy = noise(seed, (i * 2) + 1) * amplitude * endFalloff;
      result.add(points[i] + Offset(dx, dy));
    }
    return result;
  }

  static double _endFalloff(int index, int length) {
    if (length < 4) {
      return 0.35;
    }
    final int fromEnd = math.min(index, length - 1 - index);
    if (fromEnd == 0) {
      return 0.15;
    }
    if (fromEnd == 1) {
      return 0.6;
    }
    return 1.0;
  }

  /// Turns a rectangle into a point list a marker pass can be applied to.
  ///
  /// Each edge is sampled rather than reduced to two corners, so the smoothing
  /// pass rounds the corners a little and leaves the sides looking like sides
  /// rather than turning the whole box into a blob. The start overshoots the
  /// way a hand-drawn box does when the pen comes back round to where it began.
  static List<Offset> rectangleOutline(Rect rect, int seed) {
    final int perEdge = MarkerModeConstants.rectangleSamplesPerEdge;
    final List<Offset> corners = <Offset>[
      rect.topLeft,
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft,
      rect.topLeft,
    ];
    final List<Offset> points = <Offset>[];
    for (int edge = 0; edge < corners.length - 1; edge++) {
      final Offset from = corners[edge];
      final Offset to = corners[edge + 1];
      for (int step = 0; step < perEdge; step++) {
        points.add(Offset.lerp(from, to, step / perEdge)!);
      }
    }
    points.add(corners.last);

    final double overshoot =
        math.min(rect.width, rect.height) *
        MarkerModeConstants.cornerOvershootFactor;
    points.add(rect.topLeft + Offset(overshoot, -overshoot * 0.35));
    return points;
  }

  /// Samples an ellipse into points so the same marker pass applies.
  static List<Offset> ovalOutline(Rect rect) {
    final Offset center = rect.center;
    final double radiusX = rect.width / 2;
    final double radiusY = rect.height / 2;
    final int steps = MarkerModeConstants.ovalSampleCount;
    return <Offset>[
      for (int i = 0; i <= steps; i++)
        Offset(
          center.dx + (radiusX * math.cos((i / steps) * 2 * math.pi)),
          center.dy + (radiusY * math.sin((i / steps) * 2 * math.pi)),
        ),
    ];
  }

  /// How far to push points around, given how thick the stroke is.
  static double amplitudeFor({
    required double strokeWidth,
    required double scale,
  }) {
    return math.max(
      MarkerModeConstants.minimumAmplitude * scale,
      strokeWidth * MarkerModeConstants.amplitudeStrokeFactor,
    );
  }
}
