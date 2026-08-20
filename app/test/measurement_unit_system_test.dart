import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/models/scale_calibration.dart';
import 'package:ncd_photo_markup/features/markup/utils/measurement_display_formatter.dart';
import 'package:ncd_photo_markup/features/markup/utils/measurement_value_utils.dart';
import 'package:ncd_photo_markup/features/settings/models/app_settings.dart';

String _format(
  double value,
  String unit,
  MeasurementUnitSystem system, {
  MeasurementDisplayMode mode = MeasurementDisplayMode.tape,
}) {
  return MeasurementDisplayFormatter.format(
    value: value,
    unitLabel: unit,
    mode: mode,
    system: system,
  );
}

void main() {
  group('Auto, the default', () {
    test('is what the app did before this setting existed', () {
      expect(_format(8.5, 'ft', MeasurementUnitSystem.auto), '8 ft 6 in');
      expect(_format(2.5, 'm', MeasurementUnitSystem.auto), '2.5 m');
      expect(_format(0.99, 'm', MeasurementUnitSystem.auto), '99 cm');
    });

    test('is the default on a fresh AppSettings', () {
      expect(
        AppSettings.defaults.measurementUnitSystem,
        MeasurementUnitSystem.auto,
      );
    });
  });

  group('Imperial converts whatever the calibration was', () {
    test('metres read as feet and inches', () {
      // 2.5 m is 8.20209 ft, so 8 ft 2.4252 in, 38.8 sixteenths, rounds to 39.
      expect(
        _format(2.5, 'm', MeasurementUnitSystem.imperial),
        '8 ft 2 7/16 in',
      );
    });

    test('centimetres and millimetres convert too', () {
      // 100 cm is one metre, 3.28084 ft, so 3 ft 3.37 in.
      expect(
        _format(100, 'cm', MeasurementUnitSystem.imperial),
        '3 ft 3 3/8 in',
      );
      // 25.4 mm is exactly one inch.
      expect(_format(25.4, 'mm', MeasurementUnitSystem.imperial), '1 in');
    });

    test('an imperial calibration is left exactly as it was', () {
      expect(_format(8.5, 'ft', MeasurementUnitSystem.imperial), '8 ft 6 in');
      expect(_format(30, 'in', MeasurementUnitSystem.imperial), '2 ft 6 in');
    });
  });

  group('Metric converts whatever the calibration was', () {
    test('feet read in metric', () {
      // 8.5 ft is 2.5908 m.
      expect(_format(8.5, 'ft', MeasurementUnitSystem.metric), '2.59 m');
    });

    test('a short imperial length drops through the metric magnitudes', () {
      // 1 in is 25.4 mm, so 2.54 cm.
      expect(_format(1, 'in', MeasurementUnitSystem.metric), '2.5 cm');
      // A sixteenth of an inch is 1.5875 mm.
      expect(_format(0.0625, 'in', MeasurementUnitSystem.metric), '2 mm');
    });

    test('a metric calibration is left exactly as it was', () {
      expect(_format(2.5, 'm', MeasurementUnitSystem.metric), '2.5 m');
      expect(_format(99, 'cm', MeasurementUnitSystem.metric), '99 cm');
    });
  });

  group('Conversion is display only', () {
    test(
      'switching a metric calibration to Imperial changes the label and not '
      'one stored number',
      () {
        // A photo 1000 pixels wide, calibrated by a line across the full
        // width, called 4 m.
        const Size imageSize = Size(1000, 500);
        const ScaleCalibration calibration = ScaleCalibration(
          id: 1,
          startNormalized: Offset(0, 0.5),
          endNormalized: Offset(1, 0.5),
          realDistance: 4,
          unitLabel: 'm',
        );

        // Snapshot every stored number before anything is displayed.
        final double storedDistance = calibration.realDistance;
        final String storedUnit = calibration.unitLabel;
        final Offset storedStart = calibration.startNormalized;
        final Offset storedEnd = calibration.endNormalized;

        String labelWith(MeasurementUnitSystem system) {
          return MeasurementValueUtils.calibratedSegmentDisplayValue(
                startNormalized: const Offset(0, 0.25),
                endNormalized: const Offset(0.5, 0.25),
                calibration: calibration,
                imagePixelSize: imageSize,
                system: system,
              ) ??
              '';
        }

        // Half the calibrated width is 2 m.
        final String auto = labelWith(MeasurementUnitSystem.auto);
        final String imperial = labelWith(MeasurementUnitSystem.imperial);
        final String metric = labelWith(MeasurementUnitSystem.metric);

        expect(auto, '2 m');
        // 2 m is 6.56168 ft, so 6 ft 6.74 in, 107.9 sixteenths, rounds to 108.
        expect(imperial, '6 ft 6 3/4 in');
        expect(metric, '2 m');
        expect(imperial, isNot(auto));

        // The point of the test: nothing stored moved.
        expect(calibration.realDistance, storedDistance);
        expect(calibration.unitLabel, storedUnit);
        expect(calibration.startNormalized, storedStart);
        expect(calibration.endNormalized, storedEnd);
        expect(calibration.realDistance, 4);
        expect(calibration.unitLabel, 'm');
      },
    );

    test('the stored unit label is never rewritten to the displayed one', () {
      const ScaleCalibration calibration = ScaleCalibration(
        id: 2,
        startNormalized: Offset(0, 0),
        endNormalized: Offset(1, 0),
        realDistance: 3,
        unitLabel: 'm',
      );
      MeasurementValueUtils.calibratedSegmentDisplayValue(
        startNormalized: const Offset(0, 0),
        endNormalized: const Offset(1, 0),
        calibration: calibration,
        imagePixelSize: const Size(800, 600),
        system: MeasurementUnitSystem.imperial,
      );
      expect(calibration.unitLabel, 'm');
      expect(
        MeasurementValueUtils.calibrationDisplayLabel(calibration),
        contains('m'),
      );
    });
  });

  group('Nothing is guessed at', () {
    test('an unrecognised unit is passed through in every system', () {
      for (final MeasurementUnitSystem system in MeasurementUnitSystem.values) {
        expect(_format(4.5, 'furlongs', system), '4.5 furlongs');
      }
    });

    test('a negative or non-finite value is not converted', () {
      for (final MeasurementUnitSystem system in MeasurementUnitSystem.values) {
        expect(() => _format(-3, 'm', system), returnsNormally);
        expect(() => _format(double.nan, 'm', system), returnsNormally);
        expect(_format(double.nan, 'm', system), contains('--'));
      }
    });
  });

  group('Decimal mode follows the chosen system', () {
    test('a metric calibration read as imperial gives decimal feet', () {
      expect(
        _format(
          2.5,
          'm',
          MeasurementUnitSystem.imperial,
          mode: MeasurementDisplayMode.decimal,
        ),
        '8.2 ft',
      );
    });

    test('auto leaves decimal mode exactly as it was', () {
      expect(
        _format(
          2.5,
          'm',
          MeasurementUnitSystem.auto,
          mode: MeasurementDisplayMode.decimal,
        ),
        '2.5 m',
      );
    });
  });

  group('The setting survives a round trip', () {
    test('it is written and read back', () {
      const AppSettings settings = AppSettings(
        measurementUnitSystem: MeasurementUnitSystem.metric,
      );
      final AppSettings restored = AppSettings.fromJson(settings.toJson());
      expect(restored.measurementUnitSystem, MeasurementUnitSystem.metric);
    });

    test('a settings file written before this setting existed reads as Auto',
        () {
      final AppSettings restored = AppSettings.fromJson(<String, dynamic>{
        'schemaVersion': '1.0',
        'measurementDisplayMode': 'tape',
      });
      expect(restored.measurementUnitSystem, MeasurementUnitSystem.auto);
    });

    test('resetting the measurement section puts it back to Auto', () {
      const AppSettings settings = AppSettings(
        measurementUnitSystem: MeasurementUnitSystem.imperial,
      );
      expect(
        settings.resetMeasurementGroup().measurementUnitSystem,
        MeasurementUnitSystem.auto,
      );
    });
  });
}
