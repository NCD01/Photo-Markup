import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/blur_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/callout_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';

/// An immutable copy of every markup on the current photo.
///
/// This is the unit that undo and redo push around. Snapshotting the whole
/// markup set instead of recording per-type edit commands means a new markup
/// type costs one field here and nothing at all in the undo path.
@immutable
class MarkupSnapshot {
  MarkupSnapshot({
    required List<DimensionLine> dimensionLines,
    required List<ArrowMarkup> arrows,
    required List<RectangleMarkup> rectangles,
    required List<OvalMarkup> ovals,
    required List<FreehandMarkup> freehands,
    required List<TextNoteMarkup> textNotes,
    List<CalloutMarkup> callouts = const <CalloutMarkup>[],
    List<BlurMarkup> blurs = const <BlurMarkup>[],
    required this.nextMarkupId,
    this.quarterTurns = 0,
    this.imagePixelSize,
  }) : dimensionLines = List<DimensionLine>.unmodifiable(dimensionLines),
       arrows = List<ArrowMarkup>.unmodifiable(arrows),
       rectangles = List<RectangleMarkup>.unmodifiable(rectangles),
       ovals = List<OvalMarkup>.unmodifiable(ovals),
       freehands = List<FreehandMarkup>.unmodifiable(freehands),
       textNotes = List<TextNoteMarkup>.unmodifiable(textNotes),
       callouts = List<CalloutMarkup>.unmodifiable(callouts),
       blurs = List<BlurMarkup>.unmodifiable(blurs);

  final List<DimensionLine> dimensionLines;
  final List<ArrowMarkup> arrows;
  final List<RectangleMarkup> rectangles;
  final List<OvalMarkup> ovals;
  final List<FreehandMarkup> freehands;
  final List<TextNoteMarkup> textNotes;
  final List<CalloutMarkup> callouts;
  final List<BlurMarkup> blurs;
  final int nextMarkupId;

  /// How far the photo has been turned, in quarter turns clockwise. Carried
  /// here so undo puts the photo and the marks back together.
  final int quarterTurns;

  /// The photo's pixel size in the current rotation. Width and height swap on
  /// an odd number of quarter turns.
  final Size? imagePixelSize;

  static MarkupSnapshot empty() {
    return MarkupSnapshot(
      dimensionLines: const <DimensionLine>[],
      arrows: const <ArrowMarkup>[],
      rectangles: const <RectangleMarkup>[],
      ovals: const <OvalMarkup>[],
      freehands: const <FreehandMarkup>[],
      textNotes: const <TextNoteMarkup>[],
      callouts: const <CalloutMarkup>[],
      blurs: const <BlurMarkup>[],
      nextMarkupId: 1,
    );
  }

  bool get isEmpty =>
      dimensionLines.isEmpty &&
      arrows.isEmpty &&
      rectangles.isEmpty &&
      ovals.isEmpty &&
      freehands.isEmpty &&
      textNotes.isEmpty &&
      callouts.isEmpty &&
      blurs.isEmpty;

  int get markupCount =>
      dimensionLines.length +
      arrows.length +
      rectangles.length +
      ovals.length +
      freehands.length +
      textNotes.length +
      callouts.length +
      blurs.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is MarkupSnapshot &&
        other.nextMarkupId == nextMarkupId &&
        listEquals(other.dimensionLines, dimensionLines) &&
        listEquals(other.arrows, arrows) &&
        listEquals(other.rectangles, rectangles) &&
        listEquals(other.ovals, ovals) &&
        listEquals(other.freehands, freehands) &&
        listEquals(other.textNotes, textNotes) &&
        listEquals(other.callouts, callouts) &&
        listEquals(other.blurs, blurs) &&
        other.quarterTurns == quarterTurns &&
        other.imagePixelSize == imagePixelSize;
  }

  @override
  int get hashCode => Object.hash(
    nextMarkupId,
    Object.hashAll(dimensionLines),
    Object.hashAll(arrows),
    Object.hashAll(rectangles),
    Object.hashAll(ovals),
    Object.hashAll(freehands),
    Object.hashAll(textNotes),
    Object.hashAll(callouts),
    Object.hashAll(blurs),
    quarterTurns,
    imagePixelSize,
  );
}
