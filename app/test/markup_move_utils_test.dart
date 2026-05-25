import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_move_utils.dart';

void main() {
  test('clamps translation to keep points inside bounds', () {
    const Rect bounds = Rect.fromLTWH(10, 10, 100, 100);
    final List<Offset> points = <Offset>[
      const Offset(20, 20),
      const Offset(30, 30),
    ];

    final Offset clamped = MarkupMoveUtils.clampTranslationForPoints(
      points: points,
      requestedDelta: const Offset(-50, -50),
      bounds: bounds,
      padding: 0,
    );

    expect(clamped, const Offset(-10, -10));
  });

  test('translatePoints applies translation to all points', () {
    final List<Offset> moved = MarkupMoveUtils.translatePoints(<Offset>[
      const Offset(1, 2),
      const Offset(3, 4),
    ], const Offset(5, -1));

    expect(moved, <Offset>[const Offset(6, 1), const Offset(8, 3)]);
  });
}
