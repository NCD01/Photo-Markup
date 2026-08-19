import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/blur_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/callout_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_text_layout_utils.dart';

/// Everything the renderer needs to draw one frame of markup.
@immutable
class MarkupScene {
  const MarkupScene({
    required this.lines,
    required this.arrows,
    required this.rectangles,
    required this.ovals,
    required this.freehands,
    required this.textNotes,
    this.callouts = const <CalloutMarkup>[],
    this.blurs = const <BlurMarkup>[],
    this.selectedDimensionId,
    this.selectedArrowId,
    this.selectedRectangleId,
    this.selectedOvalId,
    this.selectedFreehandId,
    this.selectedTextNoteId,
    this.selectedCalloutId,
    this.selectedBlurId,
    this.activeStylePresetId = MarkupStylePresets.defaultPresetId,
    this.activeTool = MarkupTool.none,
    this.activeStart,
    this.activeEnd,
    this.activeFreehandPoints = const <Offset>[],
    this.activeStrokeWidthScale = MarkupStrokeConstants.defaultScale,
    this.activeFilled = false,
  });

  final List<DimensionLine> lines;
  final List<ArrowMarkup> arrows;
  final List<RectangleMarkup> rectangles;
  final List<OvalMarkup> ovals;
  final List<FreehandMarkup> freehands;
  final List<TextNoteMarkup> textNotes;
  final List<CalloutMarkup> callouts;
  final List<BlurMarkup> blurs;
  final int? selectedDimensionId;
  final int? selectedArrowId;
  final int? selectedRectangleId;
  final int? selectedOvalId;
  final int? selectedFreehandId;
  final int? selectedTextNoteId;
  final int? selectedCalloutId;
  final int? selectedBlurId;
  final MarkupStylePresetId activeStylePresetId;
  final MarkupTool activeTool;
  final Offset? activeStart;
  final Offset? activeEnd;
  final List<Offset> activeFreehandPoints;
  final double activeStrokeWidthScale;
  final bool activeFilled;

  /// Cheap repaint check for the overlay painter.
  static bool sameContent(MarkupScene a, MarkupScene b) {
    return listEquals(a.lines, b.lines) &&
        listEquals(a.arrows, b.arrows) &&
        listEquals(a.rectangles, b.rectangles) &&
        listEquals(a.ovals, b.ovals) &&
        listEquals(a.freehands, b.freehands) &&
        listEquals(a.textNotes, b.textNotes) &&
        listEquals(a.callouts, b.callouts) &&
        listEquals(a.blurs, b.blurs) &&
        a.selectedCalloutId == b.selectedCalloutId &&
        a.selectedBlurId == b.selectedBlurId &&
        a.selectedDimensionId == b.selectedDimensionId &&
        a.selectedArrowId == b.selectedArrowId &&
        a.selectedRectangleId == b.selectedRectangleId &&
        a.selectedOvalId == b.selectedOvalId &&
        a.selectedFreehandId == b.selectedFreehandId &&
        a.selectedTextNoteId == b.selectedTextNoteId &&
        a.activeStylePresetId == b.activeStylePresetId &&
        a.activeTool == b.activeTool &&
        a.activeStart == b.activeStart &&
        a.activeEnd == b.activeEnd &&
        a.activeStrokeWidthScale == b.activeStrokeWidthScale &&
        a.activeFilled == b.activeFilled &&
        listEquals(a.activeFreehandPoints, b.activeFreehandPoints);
  }
}

/// Draws a [MarkupScene] onto any canvas.
///
/// The same code paints the on-screen overlay and the exported PNG. On screen
/// [scale] is 1 and [imageRect] is the fitted photo rectangle. On export
/// [imageRect] is the full pixel rectangle of the source photo and [scale] is
/// how much larger that is than what was on screen, so the export is what the
/// user saw, just at the photo's real resolution.
class MarkupSceneRenderer {
  const MarkupSceneRenderer._();

  static void paint({
    required Canvas canvas,
    required MarkupScene scene,
    required Rect imageRect,
    double scale = 1.0,
    bool showSelection = true,
  }) {
    if (imageRect.width <= 0 || imageRect.height <= 0) {
      return;
    }

    canvas.save();
    canvas.clipRect(imageRect);

    // The blurred pixels themselves are applied by the photo layer (on screen)
    // and by the exporter (on save). All that is drawn here is the edge of the
    // region, so the user can see and grab it.
    for (final BlurMarkup blur in scene.blurs) {
      _paintBlurRegionOutline(
        canvas: canvas,
        rect: blur.rectInRect(imageRect),
        scale: scale,
        isSelected: showSelection && scene.selectedBlurId == blur.id,
        showOutline: showSelection,
      );
    }

    // Highlighter passes go underneath everything else so a highlight never
    // washes out the line it is meant to emphasise.
    for (final FreehandMarkup freehand in scene.freehands) {
      if (!freehand.isHighlighter) {
        continue;
      }
      _paintFreehand(
        canvas: canvas,
        freehand: freehand,
        imageRect: imageRect,
        scale: scale,
        isSelected: showSelection && scene.selectedFreehandId == freehand.id,
      );
    }

    for (final RectangleMarkup rectangle in scene.rectangles) {
      _paintRectangle(
        canvas: canvas,
        rect: rectangle.rectInRect(imageRect),
        preset: MarkupStylePresets.byId(rectangle.stylePresetId),
        strokeWidthScale: rectangle.strokeWidthScale,
        filled: rectangle.filled,
        scale: scale,
        isSelected: showSelection && scene.selectedRectangleId == rectangle.id,
      );
    }

    for (final OvalMarkup oval in scene.ovals) {
      _paintOval(
        canvas: canvas,
        rect: oval.rectInRect(imageRect),
        preset: MarkupStylePresets.byId(oval.stylePresetId),
        strokeWidthScale: oval.strokeWidthScale,
        filled: oval.filled,
        scale: scale,
        isSelected: showSelection && scene.selectedOvalId == oval.id,
      );
    }

    for (final FreehandMarkup freehand in scene.freehands) {
      if (freehand.isHighlighter) {
        continue;
      }
      _paintFreehand(
        canvas: canvas,
        freehand: freehand,
        imageRect: imageRect,
        scale: scale,
        isSelected: showSelection && scene.selectedFreehandId == freehand.id,
      );
    }

    for (final ArrowMarkup arrow in scene.arrows) {
      _paintArrow(
        canvas: canvas,
        start: arrow.startInRect(imageRect),
        end: arrow.endInRect(imageRect),
        preset: MarkupStylePresets.byId(arrow.stylePresetId),
        strokeWidthScale: arrow.strokeWidthScale,
        hasHead: arrow.hasHead,
        scale: scale,
        isSelected: showSelection && scene.selectedArrowId == arrow.id,
      );
    }

    for (final DimensionLine line in scene.lines) {
      final MarkupStylePreset preset = MarkupStylePresets.byId(
        line.stylePresetId,
      );
      final bool isSelected =
          showSelection && scene.selectedDimensionId == line.id;
      final Offset start = line.startInRect(imageRect);
      final Offset end = line.endInRect(imageRect);
      _paintDimensionLine(
        canvas: canvas,
        start: start,
        end: end,
        preset: preset,
        strokeWidthScale: line.strokeWidthScale,
        scale: scale,
        isSelected: isSelected,
      );
      _paintDimensionLabel(
        canvas: canvas,
        line: line,
        imageRect: imageRect,
        start: start,
        end: end,
        preset: preset,
        scale: scale,
        isSelected: isSelected,
      );
    }

    for (final TextNoteMarkup note in scene.textNotes) {
      _paintTextNote(
        canvas: canvas,
        note: note,
        imageRect: imageRect,
        preset: MarkupStylePresets.byId(note.stylePresetId),
        scale: scale,
        isSelected: showSelection && scene.selectedTextNoteId == note.id,
      );
    }

    for (final CalloutMarkup callout in scene.callouts) {
      _paintCallout(
        canvas: canvas,
        callout: callout,
        imageRect: imageRect,
        scale: scale,
        isSelected: showSelection && scene.selectedCalloutId == callout.id,
      );
    }

    if (showSelection) {
      _paintSelectionHandles(
        canvas: canvas,
        scene: scene,
        imageRect: imageRect,
        scale: scale,
      );
      _paintActivePreview(
        canvas: canvas,
        scene: scene,
        imageRect: imageRect,
        scale: scale,
      );
    }

    canvas.restore();
  }

  // ---------------------------------------------------------------- contrast

  /// The outline drawn behind a stroke so it reads on any photo.
  ///
  /// A light stroke gets a dark halo and a dark stroke gets a light one, so
  /// yellow on a concrete slab and black on asphalt are both legible without
  /// the user picking a colour that suits the background.
  static Paint haloPaintFor({
    required Color strokeColor,
    required double strokeWidth,
    required double scale,
    PaintingStyle style = PaintingStyle.stroke,
  }) {
    final bool wantsDarkHalo = strokeColor.computeLuminance() > 0.42;
    final double haloWidth = math.max(
      MarkupStrokeConstants.haloMinimumWidth * scale,
      strokeWidth * MarkupStrokeConstants.haloWidthFactor,
    );
    return Paint()
      ..color = wantsDarkHalo
          ? MarkupStrokeConstants.darkHalo
          : MarkupStrokeConstants.lightHalo
      ..strokeWidth = strokeWidth + (haloWidth * 2)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = style;
  }

  static double resolveStrokeWidth({
    required double baseWidth,
    required double strokeWidthScale,
    required double scale,
    required bool isSelected,
    required double selectedMultiplier,
  }) {
    return baseWidth *
        MarkupStrokeConstants.normalizeScale(strokeWidthScale) *
        scale *
        (isSelected ? selectedMultiplier : 1.0);
  }

  // ------------------------------------------------------------------ shapes

  static void _paintRectangle({
    required Canvas canvas,
    required Rect rect,
    required MarkupStylePreset preset,
    required double strokeWidthScale,
    required bool filled,
    required double scale,
    required bool isSelected,
  }) {
    if (rect.width <= 0 || rect.height <= 0) {
      return;
    }
    final double width = resolveStrokeWidth(
      baseWidth: RectangleMarkupConstants.strokeWidth,
      strokeWidthScale: strokeWidthScale,
      scale: scale,
      isSelected: isSelected,
      selectedMultiplier: RectangleMarkupConstants.selectedStrokeMultiplier,
    );
    final Color strokeColor = isSelected
        ? preset.selectedStrokeColor
        : preset.strokeColor;
    canvas.drawRect(
      rect,
      Paint()
        ..color = filled
            ? preset.strokeColor.withValues(
                alpha: MarkupFillConstants.solidFillOpacity,
              )
            : preset.fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      rect,
      haloPaintFor(strokeColor: strokeColor, strokeWidth: width, scale: scale),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = strokeColor
        ..strokeWidth = width
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
  }

  static void _paintOval({
    required Canvas canvas,
    required Rect rect,
    required MarkupStylePreset preset,
    required double strokeWidthScale,
    required bool filled,
    required double scale,
    required bool isSelected,
  }) {
    if (rect.width <= 0 || rect.height <= 0) {
      return;
    }
    final double width = resolveStrokeWidth(
      baseWidth: OvalMarkupConstants.strokeWidth,
      strokeWidthScale: strokeWidthScale,
      scale: scale,
      isSelected: isSelected,
      selectedMultiplier: OvalMarkupConstants.selectedStrokeMultiplier,
    );
    final Color strokeColor = isSelected
        ? preset.selectedStrokeColor
        : preset.strokeColor;
    canvas.drawOval(
      rect,
      Paint()
        ..color = filled
            ? preset.strokeColor.withValues(
                alpha: MarkupFillConstants.solidFillOpacity,
              )
            : preset.fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawOval(
      rect,
      haloPaintFor(strokeColor: strokeColor, strokeWidth: width, scale: scale),
    );
    canvas.drawOval(
      rect,
      Paint()
        ..color = strokeColor
        ..strokeWidth = width
        ..style = PaintingStyle.stroke,
    );
  }

  static void _paintArrow({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required MarkupStylePreset preset,
    required double strokeWidthScale,
    required bool hasHead,
    required double scale,
    required bool isSelected,
  }) {
    final double width = resolveStrokeWidth(
      baseWidth: ArrowMarkupConstants.strokeWidth,
      strokeWidthScale: strokeWidthScale,
      scale: scale,
      isSelected: isSelected,
      selectedMultiplier: ArrowMarkupConstants.selectedStrokeMultiplier,
    );
    final Color strokeColor = isSelected
        ? preset.selectedStrokeColor
        : preset.strokeColor;
    final Path path = _arrowPath(
      start: start,
      end: end,
      hasHead: hasHead,
      strokeWidthScale: strokeWidthScale,
      scale: scale,
    );
    canvas.drawPath(
      path,
      haloPaintFor(strokeColor: strokeColor, strokeWidth: width, scale: scale),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
  }

  static Path _arrowPath({
    required Offset start,
    required Offset end,
    required bool hasHead,
    required double strokeWidthScale,
    required double scale,
  }) {
    final Path path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    final Offset direction = end - start;
    final double length = direction.distance;
    if (!hasHead || length < ArrowMarkupConstants.minLength) {
      return path;
    }

    final double headLength =
        ArrowMarkupConstants.arrowHeadLength *
        scale *
        MarkupStrokeConstants.normalizeScale(strokeWidthScale);
    final double directionAngle = math.atan2(direction.dy, direction.dx);
    final double angleRad =
        ArrowMarkupConstants.arrowHeadAngleDegrees * (math.pi / 180.0);
    final double leftAngle = directionAngle + math.pi - angleRad;
    final double rightAngle = directionAngle + math.pi + angleRad;

    path
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx + (headLength * math.cos(leftAngle)),
        end.dy + (headLength * math.sin(leftAngle)),
      )
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx + (headLength * math.cos(rightAngle)),
        end.dy + (headLength * math.sin(rightAngle)),
      );
    return path;
  }

  static void _paintFreehand({
    required Canvas canvas,
    required FreehandMarkup freehand,
    required Rect imageRect,
    required double scale,
    required bool isSelected,
  }) {
    final List<Offset> points = freehand.pointsInRect(imageRect);
    if (points.isEmpty) {
      return;
    }
    final MarkupStylePreset preset = MarkupStylePresets.byId(
      freehand.stylePresetId,
    );
    final Color strokeColor = isSelected
        ? preset.selectedStrokeColor
        : preset.strokeColor;

    if (freehand.isHighlighter) {
      final double width = resolveStrokeWidth(
        baseWidth: HighlighterMarkupConstants.strokeWidth,
        strokeWidthScale: freehand.strokeWidthScale,
        scale: scale,
        isSelected: isSelected,
        selectedMultiplier: 1.0,
      );
      // A highlighter has no halo. The whole point is that it tints what is
      // under it rather than sitting on top of it.
      canvas.drawPath(
        smoothPath(points),
        Paint()
          ..color = strokeColor.withValues(
            alpha: HighlighterMarkupConstants.opacity,
          )
          ..strokeWidth = width
          ..strokeCap = StrokeCap.square
          ..strokeJoin = StrokeJoin.round
          ..blendMode = BlendMode.srcOver
          ..style = PaintingStyle.stroke,
      );
      if (isSelected) {
        canvas.drawPath(
          smoothPath(points),
          Paint()
            ..color = strokeColor
            ..strokeWidth = math.max(1.0, scale)
            ..style = PaintingStyle.stroke,
        );
      }
      return;
    }

    final double width = resolveStrokeWidth(
      baseWidth: FreehandMarkupConstants.strokeWidth,
      strokeWidthScale: freehand.strokeWidthScale,
      scale: scale,
      isSelected: isSelected,
      selectedMultiplier: FreehandMarkupConstants.selectedStrokeMultiplier,
    );
    if (points.length == 1) {
      canvas.drawCircle(points.first, width / 2, Paint()..color = strokeColor);
      return;
    }
    final Path path = smoothPath(points);
    canvas.drawPath(
      path,
      haloPaintFor(strokeColor: strokeColor, strokeWidth: width, scale: scale),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
  }

  /// Joins recorded points with quadratic segments through their midpoints so
  /// a hand-drawn line renders as a curve rather than a chain of facets.
  static Path smoothPath(List<Offset> points) {
    final Path path = Path();
    if (points.isEmpty) {
      return path;
    }
    path.moveTo(points.first.dx, points.first.dy);
    if (points.length == 1) {
      path.lineTo(points.first.dx, points.first.dy);
      return path;
    }
    if (points.length == 2) {
      path.lineTo(points[1].dx, points[1].dy);
      return path;
    }
    for (int i = 1; i < points.length - 1; i++) {
      final Offset midpoint = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        (points[i].dy + points[i + 1].dy) / 2,
      );
      path.quadraticBezierTo(
        points[i].dx,
        points[i].dy,
        midpoint.dx,
        midpoint.dy,
      );
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  static void _paintDimensionLine({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required MarkupStylePreset preset,
    required double strokeWidthScale,
    required double scale,
    required bool isSelected,
  }) {
    final double width = resolveStrokeWidth(
      baseWidth: DimensionLineConstants.strokeWidth,
      strokeWidthScale: strokeWidthScale,
      scale: scale,
      isSelected: isSelected,
      selectedMultiplier: DimensionLineConstants.selectedStrokeMultiplier,
    );
    final Color strokeColor = isSelected
        ? preset.selectedStrokeColor
        : preset.strokeColor;
    final double tickLength =
        DimensionLineConstants.endTickLength *
        scale *
        MarkupStrokeConstants.normalizeScale(strokeWidthScale);

    final Offset direction = end - start;
    Offset perpendicular = Offset(-direction.dy, direction.dx);
    perpendicular = perpendicular.distance == 0
        ? const Offset(0, -1)
        : perpendicular / perpendicular.distance;

    final Path path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy)
      ..moveTo(
        start.dx - (perpendicular.dx * tickLength),
        start.dy - (perpendicular.dy * tickLength),
      )
      ..lineTo(
        start.dx + (perpendicular.dx * tickLength),
        start.dy + (perpendicular.dy * tickLength),
      )
      ..moveTo(
        end.dx - (perpendicular.dx * tickLength),
        end.dy - (perpendicular.dy * tickLength),
      )
      ..lineTo(
        end.dx + (perpendicular.dx * tickLength),
        end.dy + (perpendicular.dy * tickLength),
      );

    canvas.drawPath(
      path,
      haloPaintFor(strokeColor: strokeColor, strokeWidth: width, scale: scale),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  // -------------------------------------------------------------------- text

  static void _paintDimensionLabel({
    required Canvas canvas,
    required DimensionLine line,
    required Rect imageRect,
    required Offset start,
    required Offset end,
    required MarkupStylePreset preset,
    required double scale,
    required bool isSelected,
  }) {
    final DimensionLabelLayout? layout =
        MarkupTextLayoutUtils.layoutDimensionLabel(
          line: line,
          imageRect: imageRect,
          start: start,
          end: end,
          scale: scale,
        );
    if (layout == null) {
      return;
    }
    final Color strokeColor = isSelected
        ? preset.selectedStrokeColor
        : preset.strokeColor;
    if (layout.showLeader) {
      canvas.drawLine(
        layout.leaderStart,
        layout.leaderEnd,
        Paint()
          ..color = strokeColor
          ..strokeWidth = DimensionLineConstants.labelLeaderStrokeWidth * scale
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
    _paintChip(
      canvas: canvas,
      rect: layout.labelRect,
      radius: UiLayoutConstants.dimensionLabelBorderRadius * scale,
      backgroundColor: preset.textBackgroundColor,
      borderColor: strokeColor,
      borderWidth: DimensionLineConstants.labelBorderWidth * scale,
      scale: scale,
    );
    layout.textPainter.paint(canvas, layout.textOffset);
  }

  static void _paintTextNote({
    required Canvas canvas,
    required TextNoteMarkup note,
    required Rect imageRect,
    required MarkupStylePreset preset,
    required double scale,
    required bool isSelected,
  }) {
    if (note.text.trim().isEmpty) {
      return;
    }
    final TextNoteLayout layout = MarkupTextLayoutUtils.layoutTextNote(
      note: note,
      imageRect: imageRect,
      preset: preset,
      scale: scale,
    );
    _paintChip(
      canvas: canvas,
      rect: layout.chipRect,
      radius: TextNoteMarkupConstants.borderRadius * scale,
      backgroundColor: preset.textBackgroundColor,
      borderColor: isSelected ? preset.selectedStrokeColor : preset.strokeColor,
      borderWidth:
          (isSelected
              ? TextNoteMarkupConstants.selectedBorderWidth
              : TextNoteMarkupConstants.borderWidth) *
          scale,
      scale: scale,
    );
    layout.textPainter.paint(canvas, layout.textOffset);
  }

  /// Chip background plus a contrast ring, so a pale note on a pale wall still
  /// has a visible edge.
  static void _paintChip({
    required Canvas canvas,
    required Rect rect,
    required double radius,
    required Color backgroundColor,
    required Color borderColor,
    required double borderWidth,
    required double scale,
  }) {
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rrect.inflate(borderWidth),
      haloPaintFor(
        strokeColor: backgroundColor,
        strokeWidth: borderWidth,
        scale: scale,
      ),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke,
    );
  }

  static void _paintBlurRegionOutline({
    required Canvas canvas,
    required Rect rect,
    required double scale,
    required bool isSelected,
    required bool showOutline,
  }) {
    if (!showOutline || rect.width <= 0 || rect.height <= 0) {
      return;
    }
    final double width =
        BlurMarkupConstants.outlineWidth * scale * (isSelected ? 2.0 : 1.0);
    canvas.drawRect(
      rect,
      Paint()
        ..color = BlurMarkupConstants.outlineShadowColor
        ..strokeWidth = width + (2 * scale)
        ..style = PaintingStyle.stroke,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = BlurMarkupConstants.outlineColor
        ..strokeWidth = width
        ..style = PaintingStyle.stroke,
    );
  }

  static void _paintCallout({
    required Canvas canvas,
    required CalloutMarkup callout,
    required Rect imageRect,
    required double scale,
    required bool isSelected,
  }) {
    final MarkupStylePreset preset = MarkupStylePresets.byId(
      callout.stylePresetId,
    );
    final Offset center = callout.centerInRect(imageRect);
    final double radius = callout.radiusForScale(scale);
    final Color fillColor = isSelected
        ? preset.selectedStrokeColor
        : preset.strokeColor;
    final double borderWidth = CalloutMarkupConstants.borderWidth * scale;

    canvas.drawCircle(
      center,
      radius,
      haloPaintFor(
        strokeColor: fillColor,
        strokeWidth: borderWidth,
        scale: scale,
      ),
    );
    canvas.drawCircle(center, radius, Paint()..color = fillColor);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = preset.textColor
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke,
    );

    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: callout.label,
        style: TextStyle(
          color: preset.textColor,
          fontSize: radius * CalloutMarkupConstants.fontSizeFactor,
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - (painter.width / 2), center.dy - (painter.height / 2)),
    );
  }

  // -------------------------------------------------------- handles, preview

  static void _paintSelectionHandles({
    required Canvas canvas,
    required MarkupScene scene,
    required Rect imageRect,
    required double scale,
  }) {
    final Paint fill = Paint()
      ..color = MarkupHandleConstants.fillColor
      ..style = PaintingStyle.fill;
    final Paint border = Paint()
      ..color = MarkupHandleConstants.activeBorderColor
      ..strokeWidth = MarkupHandleConstants.activeBorderWidth * scale
      ..style = PaintingStyle.stroke;

    void handle(Offset point) {
      canvas.drawCircle(
        point,
        MarkupHandleConstants.visibleRadius * scale,
        fill,
      );
      canvas.drawCircle(
        point,
        MarkupHandleConstants.visibleRadius * scale,
        border,
      );
    }

    for (final DimensionLine line in scene.lines) {
      if (line.id != scene.selectedDimensionId) {
        continue;
      }
      handle(line.startInRect(imageRect));
      handle(line.endInRect(imageRect));
      break;
    }
    for (final ArrowMarkup arrow in scene.arrows) {
      if (arrow.id != scene.selectedArrowId) {
        continue;
      }
      handle(arrow.startInRect(imageRect));
      handle(arrow.endInRect(imageRect));
      break;
    }
    for (final RectangleMarkup rectangle in scene.rectangles) {
      if (rectangle.id != scene.selectedRectangleId) {
        continue;
      }
      final Rect rect = rectangle.rectInRect(imageRect);
      handle(rect.topLeft);
      handle(rect.topRight);
      handle(rect.bottomRight);
      handle(rect.bottomLeft);
      break;
    }
    for (final OvalMarkup oval in scene.ovals) {
      if (oval.id != scene.selectedOvalId) {
        continue;
      }
      final Rect rect = oval.rectInRect(imageRect);
      handle(rect.topLeft);
      handle(rect.topRight);
      handle(rect.bottomRight);
      handle(rect.bottomLeft);
      break;
    }
    for (final BlurMarkup blur in scene.blurs) {
      if (blur.id != scene.selectedBlurId) {
        continue;
      }
      final Rect rect = blur.rectInRect(imageRect);
      handle(rect.topLeft);
      handle(rect.topRight);
      handle(rect.bottomRight);
      handle(rect.bottomLeft);
      break;
    }
  }

  static void _paintActivePreview({
    required Canvas canvas,
    required MarkupScene scene,
    required Rect imageRect,
    required double scale,
  }) {
    final MarkupStylePreset preset = MarkupStylePresets.byId(
      scene.activeStylePresetId,
    );
    final Offset? start = scene.activeStart;
    final Offset? end = scene.activeEnd;

    if (scene.activeTool == MarkupTool.freehand ||
        scene.activeTool == MarkupTool.highlighter) {
      if (scene.activeFreehandPoints.isEmpty) {
        return;
      }
      _paintFreehand(
        canvas: canvas,
        freehand: FreehandMarkup.fromCanvasPoints(
          id: -1,
          points: scene.activeFreehandPoints,
          imageRect: imageRect,
          stylePresetId: scene.activeStylePresetId,
          strokeWidthScale: scene.activeStrokeWidthScale,
          isHighlighter: scene.activeTool == MarkupTool.highlighter,
        ),
        imageRect: imageRect,
        scale: scale,
        isSelected: false,
      );
      return;
    }

    if (start == null || end == null) {
      return;
    }
    switch (scene.activeTool) {
      case MarkupTool.arrow:
      case MarkupTool.line:
        _paintArrow(
          canvas: canvas,
          start: start,
          end: end,
          preset: preset,
          strokeWidthScale: scene.activeStrokeWidthScale,
          hasHead: scene.activeTool == MarkupTool.arrow,
          scale: scale,
          isSelected: false,
        );
        break;
      case MarkupTool.rectangle:
        _paintRectangle(
          canvas: canvas,
          rect: Rect.fromPoints(start, end),
          preset: preset,
          strokeWidthScale: scene.activeStrokeWidthScale,
          filled: scene.activeFilled,
          scale: scale,
          isSelected: false,
        );
        break;
      case MarkupTool.oval:
        _paintOval(
          canvas: canvas,
          rect: Rect.fromPoints(start, end),
          preset: preset,
          strokeWidthScale: scene.activeStrokeWidthScale,
          filled: scene.activeFilled,
          scale: scale,
          isSelected: false,
        );
        break;
      case MarkupTool.dimension:
        _paintDimensionLine(
          canvas: canvas,
          start: start,
          end: end,
          preset: preset,
          strokeWidthScale: scene.activeStrokeWidthScale,
          scale: scale,
          isSelected: false,
        );
        break;
      case MarkupTool.blur:
        _paintBlurRegionOutline(
          canvas: canvas,
          rect: Rect.fromPoints(start, end),
          scale: scale,
          isSelected: true,
          showOutline: true,
        );
        break;
      case MarkupTool.none:
      case MarkupTool.textNote:
      case MarkupTool.callout:
      case MarkupTool.freehand:
      case MarkupTool.highlighter:
        break;
    }
  }
}
