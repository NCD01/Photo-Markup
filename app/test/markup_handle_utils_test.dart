import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_handle_utils.dart';

void main() {
  test('hitCornerIndex detects corner within hit distance', () {
    final List<Offset> corners = <Offset>[
      const Offset(10, 10),
      const Offset(30, 10),
      const Offset(30, 30),
      const Offset(10, 30),
    ];
    final int? hit = MarkupHandleUtils.hitCornerIndex(
      const Offset(11, 9),
      corners: corners,
      hitDistance: 4,
    );
    expect(hit, 0);
  });

  test('resizeRectFromCorner enforces minimum size and bounds', () {
    const Rect bounds = Rect.fromLTWH(0, 0, 100, 100);
    const Rect initial = Rect.fromLTWH(20, 20, 40, 40);

    final Rect resized = MarkupHandleUtils.resizeRectFromCorner(
      currentRect: initial,
      cornerIndex: 0,
      dragPoint: const Offset(90, 90),
      bounds: bounds,
      minWidth: 8,
      minHeight: 8,
    );

    expect(resized.width, greaterThanOrEqualTo(8));
    expect(resized.height, greaterThanOrEqualTo(8));
    expect(resized.left, greaterThanOrEqualTo(bounds.left));
    expect(resized.top, greaterThanOrEqualTo(bounds.top));
    expect(resized.right, lessThanOrEqualTo(bounds.right));
    expect(resized.bottom, lessThanOrEqualTo(bounds.bottom));
  });
}
