import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/blur_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/callout_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_snapshot.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';

/// Turns markup with the photo.
///
/// Coordinates are stored normalised against the photo, so rotating the photo
/// means rewriting every coordinate once rather than carrying a rotation
/// through every hit test and every draw call for the rest of the session.
class MarkupRotationUtils {
  const MarkupRotationUtils._();

  /// (x, y) -> (1 - y, x) turning right; (y, 1 - x) turning left.
  static Offset rotatePoint(Offset point, {required bool clockwise}) {
    return clockwise
        ? Offset(1.0 - point.dy, point.dx)
        : Offset(point.dy, 1.0 - point.dx);
  }

  static int rotateQuarterTurns(int current, {required bool clockwise}) {
    return ((current + (clockwise ? 1 : -1)) % 4 + 4) % 4;
  }

  static Size rotateSize(Size size) => Size(size.height, size.width);

  static MarkupSnapshot rotateSnapshot(
    MarkupSnapshot snapshot, {
    required bool clockwise,
  }) {
    Offset turn(Offset point) => rotatePoint(point, clockwise: clockwise);

    return MarkupSnapshot(
      // A dragged label offset is normalised against width and height
      // separately, and those swap under rotation. Rather than guess, the
      // label goes back to its default position beside the line.
      dimensionLines: snapshot.dimensionLines
          .map(
            (DimensionLine line) => line.copyWith(
              startNormalized: turn(line.startNormalized),
              endNormalized: turn(line.endNormalized),
              clearLabelOffset: true,
            ),
          )
          .toList(growable: false),
      arrows: snapshot.arrows
          .map(
            (ArrowMarkup arrow) => arrow.copyWith(
              startNormalized: turn(arrow.startNormalized),
              endNormalized: turn(arrow.endNormalized),
            ),
          )
          .toList(growable: false),
      rectangles: snapshot.rectangles
          .map(
            (RectangleMarkup rectangle) => rectangle.copyWith(
              startNormalized: turn(rectangle.startNormalized),
              endNormalized: turn(rectangle.endNormalized),
            ),
          )
          .toList(growable: false),
      ovals: snapshot.ovals
          .map(
            (OvalMarkup oval) => oval.copyWith(
              startNormalized: turn(oval.startNormalized),
              endNormalized: turn(oval.endNormalized),
            ),
          )
          .toList(growable: false),
      freehands: snapshot.freehands
          .map(
            (FreehandMarkup freehand) => freehand.copyWith(
              normalizedPoints: freehand.normalizedPoints
                  .map(turn)
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
      textNotes: snapshot.textNotes
          .map(
            (TextNoteMarkup note) =>
                note.copyWith(anchorNormalized: turn(note.anchorNormalized)),
          )
          .toList(growable: false),
      callouts: snapshot.callouts
          .map(
            (CalloutMarkup callout) => callout.copyWith(
              anchorNormalized: turn(callout.anchorNormalized),
            ),
          )
          .toList(growable: false),
      blurs: snapshot.blurs
          .map(
            (BlurMarkup blur) => blur.copyWith(
              startNormalized: turn(blur.startNormalized),
              endNormalized: turn(blur.endNormalized),
            ),
          )
          .toList(growable: false),
      nextMarkupId: snapshot.nextMarkupId,
      quarterTurns: rotateQuarterTurns(
        snapshot.quarterTurns,
        clockwise: clockwise,
      ),
      imagePixelSize: snapshot.imagePixelSize == null
          ? null
          : rotateSize(snapshot.imagePixelSize!),
    );
  }
}
