import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/blur_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/callout_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_snapshot.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_rotation_utils.dart';

MarkupSnapshot sample() {
  return MarkupSnapshot(
    dimensionLines: const <DimensionLine>[
      DimensionLine(
        id: 1,
        startNormalized: Offset(0.1, 0.2),
        endNormalized: Offset(0.4, 0.8),
        label: '72"',
        labelOffsetNormalized: Offset(0.05, -0.05),
      ),
    ],
    arrows: const <ArrowMarkup>[
      ArrowMarkup(
        id: 2,
        startNormalized: Offset(0.0, 0.0),
        endNormalized: Offset(1.0, 1.0),
      ),
    ],
    rectangles: const <RectangleMarkup>[
      RectangleMarkup(
        id: 3,
        startNormalized: Offset(0.2, 0.3),
        endNormalized: Offset(0.6, 0.7),
      ),
    ],
    ovals: const <OvalMarkup>[
      OvalMarkup(
        id: 4,
        startNormalized: Offset(0.1, 0.1),
        endNormalized: Offset(0.3, 0.3),
      ),
    ],
    freehands: <FreehandMarkup>[
      FreehandMarkup(
        id: 5,
        normalizedPoints: const <Offset>[Offset(0.2, 0.2), Offset(0.5, 0.6)],
      ),
    ],
    textNotes: const <TextNoteMarkup>[
      TextNoteMarkup(
        id: 6,
        anchorNormalized: Offset(0.25, 0.75),
        text: 'Replace drywall',
      ),
    ],
    callouts: const <CalloutMarkup>[
      CalloutMarkup(id: 7, anchorNormalized: Offset(0.9, 0.1), sequence: 1),
    ],
    blurs: const <BlurMarkup>[
      BlurMarkup(
        id: 8,
        startNormalized: Offset(0.05, 0.05),
        endNormalized: Offset(0.15, 0.2),
      ),
    ],
    nextMarkupId: 9,
    quarterTurns: 0,
    imagePixelSize: const Size(1600, 1200),
  );
}

void main() {
  test('a point turned right lands where the eye expects', () {
    // Top-left corner goes to top-right when the photo turns right.
    expect(
      MarkupRotationUtils.rotatePoint(Offset.zero, clockwise: true),
      const Offset(1, 0),
    );
    expect(
      MarkupRotationUtils.rotatePoint(const Offset(1, 0), clockwise: true),
      const Offset(1, 1),
    );
    expect(
      MarkupRotationUtils.rotatePoint(const Offset(0.5, 0.5), clockwise: true),
      const Offset(0.5, 0.5),
    );
  });

  test('turning right then left puts a point back', () {
    const Offset point = Offset(0.23, 0.71);
    final Offset there = MarkupRotationUtils.rotatePoint(
      point,
      clockwise: true,
    );
    final Offset back = MarkupRotationUtils.rotatePoint(
      there,
      clockwise: false,
    );
    expect(back.dx, closeTo(point.dx, 1e-9));
    expect(back.dy, closeTo(point.dy, 1e-9));
  });

  test('quarter turns wrap in both directions', () {
    expect(MarkupRotationUtils.rotateQuarterTurns(3, clockwise: true), 0);
    expect(MarkupRotationUtils.rotateQuarterTurns(0, clockwise: false), 3);
  });

  test('the photo size swaps on a quarter turn', () {
    expect(
      MarkupRotationUtils.rotateSize(const Size(1600, 1200)),
      const Size(1200, 1600),
    );
  });

  test('four right turns return the whole scene to where it started', () {
    MarkupSnapshot snapshot = sample();
    final MarkupSnapshot original = snapshot;
    for (int i = 0; i < 4; i++) {
      snapshot = MarkupRotationUtils.rotateSnapshot(snapshot, clockwise: true);
    }

    expect(snapshot.quarterTurns, original.quarterTurns);
    expect(snapshot.imagePixelSize, original.imagePixelSize);
    expect(snapshot.markupCount, original.markupCount);

    for (int i = 0; i < original.arrows.length; i++) {
      expect(
        snapshot.arrows[i].startNormalized.dx,
        closeTo(original.arrows[i].startNormalized.dx, 1e-9),
      );
      expect(
        snapshot.arrows[i].endNormalized.dy,
        closeTo(original.arrows[i].endNormalized.dy, 1e-9),
      );
    }
    expect(
      snapshot.callouts.single.anchorNormalized.dx,
      closeTo(original.callouts.single.anchorNormalized.dx, 1e-9),
    );
    expect(
      snapshot.freehands.single.normalizedPoints.first.dy,
      closeTo(original.freehands.single.normalizedPoints.first.dy, 1e-9),
    );
  });

  test('every markup type moves, none is left behind', () {
    final MarkupSnapshot rotated = MarkupRotationUtils.rotateSnapshot(
      sample(),
      clockwise: true,
    );
    expect(rotated.dimensionLines.single.startNormalized, isNot(const Offset(0.1, 0.2)));
    expect(rotated.arrows.single.startNormalized, const Offset(1.0, 0.0));
    expect(rotated.rectangles.single.startNormalized, isNot(const Offset(0.2, 0.3)));
    expect(rotated.ovals.single.startNormalized, isNot(const Offset(0.1, 0.1)));
    expect(rotated.textNotes.single.anchorNormalized, const Offset(0.25, 0.25));
    expect(rotated.callouts.single.anchorNormalized, const Offset(0.9, 0.9));
    expect(rotated.blurs.single.startNormalized, isNot(const Offset(0.05, 0.05)));
    expect(rotated.imagePixelSize, const Size(1200, 1600));
    expect(rotated.quarterTurns, 1);
  });

  test('a dragged dimension label goes back to its default place', () {
    final MarkupSnapshot rotated = MarkupRotationUtils.rotateSnapshot(
      sample(),
      clockwise: true,
    );
    expect(rotated.dimensionLines.single.labelOffsetNormalized, isNull);
    // The label text itself survives.
    expect(rotated.dimensionLines.single.label, '72"');
  });

  test('rotation is part of snapshot equality, so undo restores it', () {
    final MarkupSnapshot before = sample();
    final MarkupSnapshot after = MarkupRotationUtils.rotateSnapshot(
      before,
      clockwise: true,
    );
    expect(after, isNot(equals(before)));
  });
}
