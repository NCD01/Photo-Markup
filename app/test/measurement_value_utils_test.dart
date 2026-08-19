import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/area_measurement.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/multi_segment_measurement.dart';
import 'package:ncd_photo_markup/features/markup/models/scale_calibration.dart';
import 'package:ncd_photo_markup/features/markup/utils/measurement_value_utils.dart';

void main() {
  group('MeasurementValueUtils', () {
    test('computes calibration units per pixel from normalized geometry', () {
      const ScaleCalibration calibration = ScaleCalibration(
        id: 1,
        startNormalized: Offset(0.0, 0.0),
        endNormalized: Offset(0.5, 0.0),
        realDistance: 20,
        unitLabel: 'ft',
      );

      final double? unitsPerPixel =
          MeasurementValueUtils.calibrationUnitsPerPixel(
            calibration,
            const Size(200, 100),
          );

      expect(unitsPerPixel, closeTo(0.2, 0.0001));
    });

    test('returns set-scale label when no calibration is available', () {
      final MultiSegmentMeasurement measurement = MultiSegmentMeasurement(
        id: 2,
        normalizedPoints: const <Offset>[Offset(0.1, 0.1), Offset(0.4, 0.1)],
      );

      final String label = MeasurementValueUtils.multiSegmentDisplayLabel(
        measurement: measurement,
        calibration: null,
        imagePixelSize: const Size(1000, 800),
      );

      expect(label, UiCopyConstants.measurementNeedsScaleLabel);
    });

    test('formats multi-segment and area labels with calibrated values', () {
      const ScaleCalibration calibration = ScaleCalibration(
        id: 3,
        startNormalized: Offset(0.0, 0.0),
        endNormalized: Offset(0.5, 0.0),
        realDistance: 100,
        unitLabel: 'ft',
        stylePresetId: MarkupStylePresetId.ncdBlue,
      );
      final MultiSegmentMeasurement multi = MultiSegmentMeasurement(
        id: 4,
        normalizedPoints: const <Offset>[
          Offset(0.0, 0.0),
          Offset(0.5, 0.0),
          Offset(0.5, 0.5),
        ],
      );
      final AreaMeasurement area = AreaMeasurement(
        id: 5,
        normalizedPoints: const <Offset>[
          Offset(0.0, 0.0),
          Offset(0.5, 0.0),
          Offset(0.5, 0.5),
          Offset(0.0, 0.5),
        ],
      );

      final String multiLabel = MeasurementValueUtils.multiSegmentDisplayLabel(
        measurement: multi,
        calibration: calibration,
        imagePixelSize: const Size(200, 200),
      );
      final String areaLabel = MeasurementValueUtils.areaDisplayLabel(
        measurement: area,
        calibration: calibration,
        imagePixelSize: const Size(200, 200),
      );

      expect(multiLabel, 'Length: 200 ft');
      expect(areaLabel, contains('Area: 10000 sq ft'));
      expect(areaLabel, contains('Perimeter: 400 ft'));
    });
  });
}
