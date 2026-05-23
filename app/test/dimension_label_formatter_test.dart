import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/utils/dimension_label_formatter.dart';

void main() {
  group('DimensionLabelFormatter', () {
    test('formats inches-only values', () {
      expect(DimensionLabelFormatter.format('72'), '72"');
      expect(DimensionLabelFormatter.format('72 in'), '72"');
      expect(DimensionLabelFormatter.format('72 inches'), '72"');
      expect(DimensionLabelFormatter.format('72"'), '72"');
    });

    test('formats quick feet-and-inches values to inches', () {
      expect(DimensionLabelFormatter.format('6 0'), '72"');
      expect(DimensionLabelFormatter.format('6 6'), '78"');
      expect(DimensionLabelFormatter.format('5 10'), '70"');
    });

    test('normalizes common feet formats to inches', () {
      expect(DimensionLabelFormatter.format("6'"), '72"');
      expect(DimensionLabelFormatter.format('6 ft'), '72"');
      expect(DimensionLabelFormatter.format("6'-0\""), '72"');
      expect(DimensionLabelFormatter.format('6 ft 3 in'), '75"');
    });

    test('keeps non-measurement free text intact', () {
      expect(
        DimensionLabelFormatter.format("Approx. 5' opening"),
        "Approx. 5' opening",
      );
      expect(
        DimensionLabelFormatter.format('Verify on site'),
        'Verify on site',
      );
    });
  });
}
