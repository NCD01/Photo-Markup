import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';

void main() {
  group('DimensionLine', () {
    test(
      'copyWith preserves default typography and can update label state',
      () {
        const DimensionLine original = DimensionLine(
          id: 1,
          startNormalized: Offset(0.1, 0.2),
          endNormalized: Offset(0.7, 0.2),
          label: '48"',
        );

        final DimensionLine updated = original.copyWith(
          labelOffsetNormalized: const Offset(0.1, -0.05),
          fontFamily: 'Segoe UI',
          fontSize: 20,
          stylePresetId: MarkupStylePresetId.red,
        );

        expect(
          original.fontFamily,
          MarkupTypographyConstants.defaultFontFamily,
        );
        expect(original.fontSize, MarkupTypographyConstants.defaultFontSize);
        expect(updated.labelOffsetNormalized, const Offset(0.1, -0.05));
        expect(updated.fontFamily, 'Segoe UI');
        expect(updated.fontSize, 20);
        expect(updated.stylePresetId, MarkupStylePresetId.red);
      },
    );

    test('copyWith can clear saved label offset', () {
      const DimensionLine original = DimensionLine(
        id: 2,
        startNormalized: Offset(0.2, 0.2),
        endNormalized: Offset(0.6, 0.4),
        label: '72"',
        labelOffsetNormalized: Offset(0.08, 0.03),
      );

      final DimensionLine updated = original.copyWith(clearLabelOffset: true);

      expect(updated.labelOffsetNormalized, isNull);
      expect(updated.label, '72"');
    });
  });
}
