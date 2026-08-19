import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/rendering/marker_mode.dart';

void main() {
  test('marker mode is off unless asked for, because it changes exports', () {
    expect(MarkerModeConstants.defaultEnabled, isFalse);
  });

  test('the wobble is repeatable, so a line does not crawl on screen', () {
    final List<Offset> points = <Offset>[
      for (int i = 0; i < 12; i++) Offset(i * 10.0, 40),
    ];
    final List<Offset> first = MarkerMode.wobble(
      points: points,
      seed: 7,
      amplitude: 3,
    );
    final List<Offset> second = MarkerMode.wobble(
      points: points,
      seed: 7,
      amplitude: 3,
    );
    expect(first, equals(second));
  });

  test('two annotations do not get the same wobble', () {
    final List<Offset> points = <Offset>[
      for (int i = 0; i < 12; i++) Offset(i * 10.0, 40),
    ];
    final List<Offset> a = MarkerMode.wobble(
      points: points,
      seed: 1,
      amplitude: 3,
    );
    final List<Offset> b = MarkerMode.wobble(
      points: points,
      seed: 2,
      amplitude: 3,
    );
    expect(a, isNot(equals(b)));
  });

  test('the wobble stays inside the amplitude it was given', () {
    final List<Offset> points = <Offset>[
      for (int i = 0; i < 40; i++) Offset(i * 5.0, 100),
    ];
    const double amplitude = 4;
    final List<Offset> wobbled = MarkerMode.wobble(
      points: points,
      seed: 99,
      amplitude: amplitude,
    );
    for (int i = 0; i < points.length; i++) {
      expect((wobbled[i] - points[i]).dx.abs(), lessThanOrEqualTo(amplitude));
      expect((wobbled[i] - points[i]).dy.abs(), lessThanOrEqualTo(amplitude));
    }
  });

  test('the ends move less than the middle', () {
    final List<Offset> points = <Offset>[
      for (int i = 0; i < 30; i++) Offset(i * 6.0, 50),
    ];
    final List<Offset> wobbled = MarkerMode.wobble(
      points: points,
      seed: 5,
      amplitude: 6,
    );
    final double startShift = (wobbled.first - points.first).distance;
    final double endShift = (wobbled.last - points.last).distance;
    double middleMax = 0;
    for (int i = 4; i < points.length - 4; i++) {
      final double shift = (wobbled[i] - points[i]).distance;
      middleMax = shift > middleMax ? shift : middleMax;
    }
    expect(startShift, lessThan(middleMax));
    expect(endShift, lessThan(middleMax));
  });

  test('a stroke too short to wobble is returned untouched', () {
    const List<Offset> single = <Offset>[Offset(1, 1)];
    expect(MarkerMode.wobble(points: single, seed: 1, amplitude: 3), single);
    expect(MarkerMode.wobble(points: single, seed: 1, amplitude: 0), single);
  });

  test('noise is bounded and deterministic', () {
    for (int seed = 0; seed < 50; seed++) {
      for (int index = 0; index < 10; index++) {
        final double value = MarkerMode.noise(seed, index);
        expect(value, greaterThanOrEqualTo(-1.0));
        expect(value, lessThanOrEqualTo(1.0));
        expect(value, MarkerMode.noise(seed, index));
      }
    }
  });

  test('a rectangle becomes a closed-ish outline with an overshoot', () {
    final List<Offset> outline = MarkerMode.rectangleOutline(
      const Rect.fromLTWH(10, 20, 100, 60),
      3,
    );
    expect(outline.length, greaterThanOrEqualTo(5));
    // It returns near where it started, the way a hand-drawn box does.
    expect((outline.last - outline.first).distance, lessThan(20));
  });

  test('an ellipse is sampled densely enough to look drawn', () {
    final List<Offset> outline = MarkerMode.ovalOutline(
      const Rect.fromLTWH(0, 0, 200, 100),
    );
    expect(outline.length, MarkerModeConstants.ovalSampleCount + 1);
    expect((outline.first - outline.last).distance, lessThan(0.001));
  });

  test('amplitude grows with the stroke', () {
    final double thin = MarkerMode.amplitudeFor(strokeWidth: 2, scale: 1);
    final double thick = MarkerMode.amplitudeFor(strokeWidth: 20, scale: 1);
    expect(thick, greaterThan(thin));
  });

  test('a hairline stroke still gets a visible wobble at export scale', () {
    // Callers pass a stroke width that already includes the export scale, so
    // amplitude follows it. The scale argument only lifts the floor, which is
    // what keeps a fine line from looking machine-straight in a big export.
    final double onScreen = MarkerMode.amplitudeFor(strokeWidth: 1, scale: 1);
    final double exported = MarkerMode.amplitudeFor(strokeWidth: 1, scale: 8);
    expect(exported, greaterThan(onScreen));
  });
}
