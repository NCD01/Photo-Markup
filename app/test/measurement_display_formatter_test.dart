import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/utils/measurement_display_formatter.dart';

String _ft(double v) =>
    MeasurementDisplayFormatter.format(value: v, unitLabel: 'ft');

void main() {
  group('MeasurementDisplayFormatter imperial, the worked examples', () {
    // Marcelo's table, verbatim. Every one of these was checked against the
    // arithmetic before it was asserted.
    final List<MapEntry<double, String>> cases = <MapEntry<double, String>>[
      const MapEntry<double, String>(0.42, '5 1/16 in'), // 5.04 in, 80.64/16
      const MapEntry<double, String>(8.5, '8 ft 6 in'),
      const MapEntry<double, String>(8.0, '8 ft'),
      const MapEntry<double, String>(0.98, '11 3/4 in'), // 11.76 in, 188.16/16
      const MapEntry<double, String>(0.9999, '1 ft'), // 11.9988 in, 191.98/16
      const MapEntry<double, String>(0.0001, '< 1/16 in'),
      const MapEntry<double, String>(0.0, '< 1/16 in'),
      const MapEntry<double, String>(1.03125, '1 ft 3/8 in'), // exactly 198/16
    ];

    for (final MapEntry<double, String> row in cases) {
      test('${row.key} ft reads ${row.value}', () {
        expect(_ft(row.key), row.value);
      });
    }
  });

  group('MeasurementDisplayFormatter sixteenths', () {
    String inches(double v) =>
        MeasurementDisplayFormatter.format(value: v, unitLabel: 'in');

    test('rounds to the nearest sixteenth at every magnitude', () {
      expect(inches(5.0625), '5 1/16 in');
      expect(inches(5.1875), '5 3/16 in');
      // Forty feet and one sixteenth. The tape rule does not stop being the
      // rule just because the number got big.
      expect(_ft(40 + 0.0625 / 12), '40 ft 1/16 in');
    });

    test('the fraction is reduced', () {
      expect(inches(5.5), '5 1/2 in'); // 8/16
      expect(inches(5.25), '5 1/4 in'); // 4/16
      expect(inches(5.125), '5 1/8 in'); // 2/16
      expect(inches(5.75), '5 3/4 in'); // 12/16
    });

    test('zero sixteenths shows no fraction at all', () {
      expect(inches(5), '5 in');
      expect(inches(5), isNot(contains('/')));
    });

    test('sixteen sixteenths promotes to the next whole inch', () {
      // 5.99 in is 95.84 sixteenths, which rounds to 96. Never "5 16/16".
      expect(inches(5.99), '6 in');
      expect(inches(5.99), isNot(contains('16/16')));
    });

    test('twelve inches promotes to the next foot', () {
      expect(inches(11.98), '1 ft'); // 191.68 sixteenths, rounds to 192
      expect(inches(12), '1 ft');
      expect(inches(11.98), isNot(contains('12 in')));
    });

    test('a fraction with no whole inches drops the leading zero', () {
      expect(inches(0.375), '3/8 in');
      expect(inches(0.375), isNot(contains('0 ')));
    });

    test('under a foot is inches alone', () {
      expect(_ft(0.9), '10 13/16 in'); // 10.8 in, 172.8 sixteenths, rounds to 173
      expect(_ft(0.9), isNot(contains('ft')));
    });

    test('a foot and over is feet then inches, inches dropped when zero', () {
      expect(_ft(2.5), '2 ft 6 in');
      expect(_ft(2.0), '2 ft');
      expect(_ft(2.0), isNot(contains('in')));
    });
  });

  group('MeasurementDisplayFormatter below the smallest fraction', () {
    // The defect this task exists to fix. A real length that is too small for
    // a tape must not read as nothing at all.
    test('a positive length under a sixteenth reads as less than a sixteenth', () {
      expect(_ft(0.0001), '< 1/16 in');
      expect(
        MeasurementDisplayFormatter.format(value: 0.01, unitLabel: 'in'),
        '< 1/16 in',
      );
    });

    test('it never reads as zero inches', () {
      expect(_ft(0.0001), isNot('0 in'));
      expect(_ft(0.0), isNot('0 in'));
      expect(_ft(0.0001), isNot(contains('0 in')));
    });

    test('a sixteenth itself reads as a sixteenth, not as less than one', () {
      expect(
        MeasurementDisplayFormatter.format(value: 0.0625, unitLabel: 'in'),
        '1/16 in',
      );
    });
  });

  group('MeasurementDisplayFormatter unit aliases', () {
    test('the foot aliases are recognised', () {
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

    test('an inches unit converts up once it passes a foot', () {
      expect(
        MeasurementDisplayFormatter.format(value: 30, unitLabel: 'in'),
        '2 ft 6 in',
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
