import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/export/services/marked_up_image_export_service.dart';

void main() {
  group('MarkedUpImageExportService crop math', () {
    test('scales logical crop rect to pixel rect with ceil/floor bounds', () {
      final PixelCropRect crop =
          MarkedUpImageExportService.computePixelCropRectForTest(
            boundaryLogicalSize: const Size(1000, 800),
            cropRectLogical: const Rect.fromLTWH(100, 50, 800, 600),
            pixelRatio: 1.5,
            imagePixelWidth: 1500,
            imagePixelHeight: 1200,
          );

      expect(crop.left, 150);
      expect(crop.top, 75);
      expect(crop.width, 1200);
      expect(crop.height, 900);
    });

    test('clamps crop rect to boundary and image pixel limits', () {
      final PixelCropRect crop =
          MarkedUpImageExportService.computePixelCropRectForTest(
            boundaryLogicalSize: const Size(1000, 800),
            cropRectLogical: const Rect.fromLTWH(-25, -25, 1100, 900),
            pixelRatio: 2.0,
            imagePixelWidth: 2000,
            imagePixelHeight: 1600,
          );

      expect(crop.left, 0);
      expect(crop.top, 0);
      expect(crop.width, 2000);
      expect(crop.height, 1600);
    });

    test('throws when crop area is empty after intersection', () {
      expect(
        () => MarkedUpImageExportService.computePixelCropRectForTest(
          boundaryLogicalSize: const Size(1000, 800),
          cropRectLogical: const Rect.fromLTWH(1200, 900, 50, 50),
          pixelRatio: 1.0,
          imagePixelWidth: 1000,
          imagePixelHeight: 800,
        ),
        throwsStateError,
      );
    });
  });
}
