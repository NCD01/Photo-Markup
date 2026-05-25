import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';

void main() {
  group('FreehandMarkup', () {
    const Rect imageRect = Rect.fromLTWH(10, 20, 200, 100);

    test('clamps points to image bounds during creation', () {
      final FreehandMarkup markup = FreehandMarkup.fromCanvasPoints(
        id: 1,
        points: const <Offset>[
          Offset(-100, -100),
          Offset(30, 30),
          Offset(500, 500),
        ],
        imageRect: imageRect,
      );

      final List<Offset> denormalized = markup.pointsInRect(imageRect);
      expect(denormalized.first.dx, imageRect.left);
      expect(denormalized.first.dy, imageRect.top);
      expect(denormalized.last.dx, imageRect.right);
      expect(denormalized.last.dy, imageRect.bottom);
      expect(markup.stylePresetId, MarkupStylePresets.defaultPresetId);
    });

    test('distance is small for point near stroke and larger when far', () {
      final FreehandMarkup markup = FreehandMarkup.fromCanvasPoints(
        id: 2,
        points: const <Offset>[
          Offset(20, 30),
          Offset(150, 80),
          Offset(200, 90),
        ],
        imageRect: imageRect,
      );

      final double nearDistance = markup.distanceToPointInRect(
        const Offset(152, 82),
        imageRect,
      );
      final double farDistance = markup.distanceToPointInRect(
        const Offset(10, 120),
        imageRect,
      );

      expect(nearDistance, lessThan(10));
      expect(farDistance, greaterThan(nearDistance));
    });
  });
}
