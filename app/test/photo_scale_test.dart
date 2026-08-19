import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/models/photo_scale.dart';

void main() {
  group('parsing what a tradesperson types', () {
    test('plain inches', () {
      expect(PhotoScale.parseInches('36'), 36);
      expect(PhotoScale.parseInches('36"'), 36);
      expect(PhotoScale.parseInches('36 in'), 36);
      expect(PhotoScale.parseInches('36 inches'), 36);
    });

    test('feet', () {
      expect(PhotoScale.parseInches("8'"), 96);
      expect(PhotoScale.parseInches('8 ft'), 96);
      expect(PhotoScale.parseInches('8 feet'), 96);
    });

    test('feet and inches in the forms people actually write', () {
      expect(PhotoScale.parseInches("6'2\""), 74);
      expect(PhotoScale.parseInches('6-2'), 74);
      expect(PhotoScale.parseInches('6 2'), 74);
      expect(PhotoScale.parseInches("6' 2\""), 74);
    });

    test('fractions of a foot survive', () {
      expect(PhotoScale.parseInches('1.5 ft'), 18);
    });

    test('nonsense returns nothing rather than a wrong number', () {
      expect(PhotoScale.parseInches(''), isNull);
      expect(PhotoScale.parseInches('about a metre'), isNull);
      expect(PhotoScale.parseInches('x'), isNull);
    });
  });

  group('formatting', () {
    test('under a foot stays in inches', () {
      expect(PhotoScale.formatInches(9), '9"');
      expect(PhotoScale.formatInches(11.4), '11"');
    });

    test('whole feet read as feet', () {
      expect(PhotoScale.formatInches(96), "8'-0\"");
    });

    test('feet and inches read the way a tape reads', () {
      expect(PhotoScale.formatInches(74), "6'-2\"");
      expect(PhotoScale.formatInches(13), "1'-1\"");
    });

    test('garbage in gives an empty label, not an exception', () {
      expect(PhotoScale.formatInches(double.nan), '');
      expect(PhotoScale.formatInches(-4), '');
    });
  });

  group('measuring', () {
    const Size photo = Size(4000, 3000);

    test('a calibrated photo measures a second line correctly', () {
      // The full width of a 4000x3000 photo is 8 feet.
      final double fullWidth = PhotoScale.normalizedLengthBetween(
        startNormalized: const Offset(0, 0.5),
        endNormalized: const Offset(1, 0.5),
        imagePixelSize: photo,
      );
      final PhotoScale scale = PhotoScale(
        referenceNormalizedLength: fullWidth,
        referenceInches: 96,
        calibratedStart: const Offset(0, 0.5),
        calibratedEnd: const Offset(1, 0.5),
      );
      expect(scale.isUsable, isTrue);

      // Half the width should therefore be four feet.
      final double halfWidth = PhotoScale.normalizedLengthBetween(
        startNormalized: const Offset(0.25, 0.2),
        endNormalized: const Offset(0.75, 0.2),
        imagePixelSize: photo,
      );
      expect(scale.inchesForNormalizedLength(halfWidth), closeTo(48, 0.0001));
      expect(
        PhotoScale.formatInches(scale.inchesForNormalizedLength(halfWidth)),
        "4'-0\"",
      );
    });

    test('a vertical measurement is right too, not just horizontal', () {
      // Calibrating across the width, then measuring the height, only comes
      // out right if the normalisation uses the diagonal.
      final double fullWidth = PhotoScale.normalizedLengthBetween(
        startNormalized: const Offset(0, 0),
        endNormalized: const Offset(1, 0),
        imagePixelSize: photo,
      );
      final PhotoScale scale = PhotoScale(
        referenceNormalizedLength: fullWidth,
        referenceInches: 4000,
        calibratedStart: const Offset(0, 0),
        calibratedEnd: const Offset(1, 0),
      );
      final double fullHeight = PhotoScale.normalizedLengthBetween(
        startNormalized: const Offset(0, 0),
        endNormalized: const Offset(0, 1),
        imagePixelSize: photo,
      );
      // 3000px tall against 4000px calibrated as 4000 inches.
      expect(scale.inchesForNormalizedLength(fullHeight), closeTo(3000, 0.001));
    });

    test('a diagonal measurement is right', () {
      final double fullWidth = PhotoScale.normalizedLengthBetween(
        startNormalized: const Offset(0, 0),
        endNormalized: const Offset(1, 0),
        imagePixelSize: photo,
      );
      final PhotoScale scale = PhotoScale(
        referenceNormalizedLength: fullWidth,
        referenceInches: 4000,
        calibratedStart: const Offset(0, 0),
        calibratedEnd: const Offset(1, 0),
      );
      final double diagonal = PhotoScale.normalizedLengthBetween(
        startNormalized: const Offset(0, 0),
        endNormalized: const Offset(1, 1),
        imagePixelSize: photo,
      );
      expect(scale.inchesForNormalizedLength(diagonal), closeTo(5000, 0.01));
    });

    test('a too-short calibration is refused', () {
      const PhotoScale tiny = PhotoScale(
        referenceNormalizedLength: 0.001,
        referenceInches: 96,
        calibratedStart: Offset.zero,
        calibratedEnd: Offset(0.001, 0),
      );
      expect(tiny.isUsable, isFalse);
    });

    test('an absurd reference length is refused', () {
      const PhotoScale absurd = PhotoScale(
        referenceNormalizedLength: 0.5,
        referenceInches: 900000,
        calibratedStart: Offset.zero,
        calibratedEnd: Offset(0.5, 0),
      );
      expect(absurd.isUsable, isFalse);
    });
  });

  group('persistence', () {
    test('a scale round-trips through json', () {
      const PhotoScale scale = PhotoScale(
        referenceNormalizedLength: 0.4,
        referenceInches: 96,
        calibratedStart: Offset(0.1, 0.2),
        calibratedEnd: Offset(0.5, 0.2),
      );
      final PhotoScale? restored = PhotoScale.fromJson(scale.toJson());
      expect(restored, equals(scale));
    });

    test('an unusable stored scale comes back as nothing', () {
      expect(
        PhotoScale.fromJson(<String, dynamic>{
          'referenceNormalizedLength': 0.0001,
          'referenceInches': 96,
          'calibratedStart': <String, dynamic>{'x': 0, 'y': 0},
          'calibratedEnd': <String, dynamic>{'x': 0.0001, 'y': 0},
        }),
        isNull,
      );
      expect(PhotoScale.fromJson(null), isNull);
      expect(PhotoScale.fromJson('nonsense'), isNull);
    });
  });
}
