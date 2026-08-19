import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/utils/freehand_smoothing.dart';

/// How far a point strays from the straight line between two others.
double _sagitta(List<Offset> points) {
  if (points.length < 3) {
    return 0;
  }
  final Offset a = points.first;
  final Offset b = points.last;
  double worst = 0;
  for (final Offset point in points) {
    final Offset segment = b - a;
    final double lengthSquared =
        (segment.dx * segment.dx) + (segment.dy * segment.dy);
    if (lengthSquared == 0) {
      continue;
    }
    final double projection =
        ((((point.dx - a.dx) * segment.dx) + ((point.dy - a.dy) * segment.dy)) /
                lengthSquared)
            .clamp(0.0, 1.0);
    final Offset nearest = Offset(
      a.dx + (segment.dx * projection),
      a.dy + (segment.dy * projection),
    );
    worst = worst > (point - nearest).distance
        ? worst
        : (point - nearest).distance;
  }
  return worst;
}

void main() {
  test('a short stroke passes through untouched', () {
    const List<Offset> points = <Offset>[Offset(0, 0), Offset(10, 10)];
    expect(FreehandSmoothing.smooth(points), equals(points));
  });

  test('simplify drops points that only record tremor', () {
    final List<Offset> jittery = <Offset>[
      const Offset(0, 0),
      const Offset(10, 0.4),
      const Offset(20, -0.3),
      const Offset(30, 0.2),
      const Offset(40, -0.4),
      const Offset(50, 0),
    ];
    final List<Offset> simplified = FreehandSmoothing.simplify(
      jittery,
      tolerance: 1.6,
    );
    expect(simplified.length, 2);
    expect(simplified.first, jittery.first);
    expect(simplified.last, jittery.last);
  });

  test('simplify keeps a real corner', () {
    final List<Offset> corner = <Offset>[
      const Offset(0, 0),
      const Offset(25, 0.2),
      const Offset(50, 0),
      const Offset(50, 25),
      const Offset(50, 50),
    ];
    final List<Offset> simplified = FreehandSmoothing.simplify(
      corner,
      tolerance: 1.6,
    );
    expect(simplified, contains(const Offset(50, 0)));
  });

  test('chaikin rounds corners and pins the endpoints', () {
    final List<Offset> corner = <Offset>[
      const Offset(0, 0),
      const Offset(50, 0),
      const Offset(50, 50),
    ];
    final List<Offset> rounded = FreehandSmoothing.chaikin(corner, passes: 2);

    expect(rounded.first, corner.first);
    expect(rounded.last, corner.last);
    expect(rounded.length, greaterThan(corner.length));
    // The sharp vertex is gone: nothing sits exactly on it any more.
    expect(rounded.contains(const Offset(50, 0)), isFalse);
  });

  test('smoothing pulls a shaky line closer to straight', () {
    final List<Offset> shaky = <Offset>[
      for (int i = 0; i <= 40; i++)
        Offset(i * 5, (i.isEven ? 2.2 : -2.2) + (i % 3) * 0.6),
    ];
    final double before = _sagitta(shaky);
    final double after = _sagitta(FreehandSmoothing.smooth(shaky));
    expect(after, lessThan(before));
  });

  test('smoothing keeps where the stroke started and ended', () {
    final List<Offset> shaky = <Offset>[
      for (int i = 0; i <= 30; i++)
        Offset(i * 4, (i.isEven ? 3 : -3).toDouble()),
    ];
    final List<Offset> smoothed = FreehandSmoothing.smooth(shaky);
    expect(smoothed.first, shaky.first);
    expect(smoothed.last, shaky.last);
  });

  test('a long stroke stays bounded', () {
    final List<Offset> long = <Offset>[
      for (int i = 0; i < 3000; i++) Offset(i.toDouble(), (i % 7).toDouble()),
    ];
    final List<Offset> smoothed = FreehandSmoothing.smooth(long);
    expect(smoothed.length, lessThan(20000));
  });
}
