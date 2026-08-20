import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/utils/measurement_display_formatter.dart';

String _ft(double v) =>
    MeasurementDisplayFormatter.format(value: v, unitLabel: 'ft');

void main() {
  group('MeasurementDisplayFormatter imperial', () {
    test('below a foot reads in whole inches', () {
      // The case that started this: 0.42 ft is unreadable on a job site.
      expect(_ft(0.42), '5 in');
    });

    test('inches that round up to a full foot promote to feet', () {
      // 0.98 ft is 11.76 in, which rounds to 12. It must not read "12 in".
      expect(_ft(0.98), '1 ft');
    });

    test('exactly one foot reads as feet only', () {
      expect(_ft(1.0), '1 ft');
    });

    test('exactly twelve inches reads as one foot, not twelve inches', () {
      expect(
        MeasurementDisplayFormatter.format(value: 12, unitLabel: 'in'),
        '1 ft',
      );
    });

    test('whole feet drop the inches part', () {
      expect(_ft(8.0), '8 ft');
    });

    test('feet and inches read like a tape', () {
      expect(_ft(8.5), '8 ft 6 in');
    });

    test('zero reads as zero inches', () {
      expect(_ft(0.0), '0 in');
    });

    test('just under a foot stays in inches', () {
      // 0.9 ft is 10.8 in, rounds to 11, still short of a foot.
      expect(_ft(0.9), '11 in');
    });

    test('an inches unit converts up once it passes a foot', () {
      expect(
        MeasurementDisplayFormatter.format(value: 30, unitLabel: 'in'),
        '2 ft 6 in',
      );
    });

    test('unit aliases are recognised', () {
      expect(
        MeasurementDisplayFormatter.format(value: 8.5, unitLabel: 'feet'),
        '8 ft 6 in',
      );
      expect(
        MeasurementDisplayFormatter.format(value: 8.5, unitLabel: "'"),
        '8 ft 6 in',
      );
      expect(
        MeasurementDisplayFormatter.format(value: 8.5, unitLabel: 'FT'),
        '8 ft 6 in',
      );
    });
  });

  group('MeasurementDisplayFormatter metric', () {
    test('exactly one metre reads in metres', () {
      expect(
        MeasurementDisplayFormatter.format(value: 1.0, unitLabel: 'm'),
        '1 m',
      );
    });

    test('over a metre reads in metres with decimals', () {
      expect(
        MeasurementDisplayFormatter.format(value: 2.5, unitLabel: 'm'),
        '2.5 m',
      );
    });

    test('just under a metre drops to centimetres', () {
      expect(
        MeasurementDisplayFormatter.format(value: 0.99, unitLabel: 'm'),
        '99 cm',
      );
    });

    test('under a centimetre drops to millimetres', () {
      expect(
        MeasurementDisplayFormatter.format(value: 0.004, unitLabel: 'm'),
        '4 mm',
      );
    });

    test('centimetres promote to metres at one hundred', () {
      expect(
        MeasurementDisplayFormatter.format(value: 100, unitLabel: 'cm'),
        '1 m',
      );
    });

    test('millimetres promote to centimetres at ten', () {
      expect(
        MeasurementDisplayFormatter.format(value: 10, unitLabel: 'mm'),
        '1 cm',
      );
    });
  });

  group('MeasurementDisplayFormatter bad input', () {
    test('a negative value does not throw and is not dressed up as a real '
        'measurement', () {
      final String result = _ft(-3);
      expect(result, isNotEmpty);
      expect(result, contains('ft'));
      // Must not silently present a negative length as a tidy tape reading.
      expect(result, isNot('3 ft'));
    });

    test('NaN and infinity do not throw', () {
      expect(() => _ft(double.nan), returnsNormally);
      expect(() => _ft(double.infinity), returnsNormally);
      expect(_ft(double.nan), contains('--'));
    });

    test('an unrecognised unit is passed through rather than guessed at', () {
      expect(
        MeasurementDisplayFormatter.format(value: 4.5, unitLabel: 'furlongs'),
        '4.5 furlongs',
      );
    });

    test('an empty unit falls back rather than throwing', () {
      expect(
        () => MeasurementDisplayFormatter.format(value: 4.5, unitLabel: ''),
        returnsNormally,
      );
    });
  });
}
