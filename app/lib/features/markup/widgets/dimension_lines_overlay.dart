import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';

class DimensionLinesOverlay extends StatefulWidget {
  const DimensionLinesOverlay({
    super.key,
    required this.lines,
    required this.arrows,
    required this.rectangles,
    required this.ovals,
    required this.freehands,
    required this.textNotes,
    required this.imageRect,
    required this.selectedDimensionId,
    required this.selectedArrowId,
    required this.selectedRectangleId,
    required this.selectedOvalId,
    required this.selectedFreehandId,
    required this.selectedTextNoteId,
    required this.activeStylePresetId,
    required this.activeTool,
    this.activeStart,
    this.activeEnd,
    required this.activeFreehandPoints,
    required this.isEnabled,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    this.onTap,
  });

  final List<DimensionLine> lines;
  final List<ArrowMarkup> arrows;
  final List<RectangleMarkup> rectangles;
  final List<OvalMarkup> ovals;
  final List<FreehandMarkup> freehands;
  final List<TextNoteMarkup> textNotes;
  final Rect imageRect;
  final int? selectedDimensionId;
  final int? selectedArrowId;
  final int? selectedRectangleId;
  final int? selectedOvalId;
  final int? selectedFreehandId;
  final int? selectedTextNoteId;
  final MarkupStylePresetId activeStylePresetId;
  final MarkupTool activeTool;
  final Offset? activeStart;
  final Offset? activeEnd;
  final List<Offset> activeFreehandPoints;
  final bool isEnabled;
  final ValueChanged<Offset> onStart;
  final ValueChanged<Offset> onUpdate;
  final VoidCallback onEnd;
  final ValueChanged<Offset>? onTap;

  @override
  State<DimensionLinesOverlay> createState() => _DimensionLinesOverlayState();
}

class _DimensionLinesOverlayState extends State<DimensionLinesOverlay> {
  Offset? _pointerDownPoint;
  bool _didDrag = false;

  void _resetPointerState() {
    _pointerDownPoint = null;
    _didDrag = false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: widget.isEnabled
          ? (PointerDownEvent event) {
              if (!widget.imageRect.contains(event.localPosition)) {
                _resetPointerState();
                return;
              }
              final Offset clamped = DimensionLine.clampToRect(
                event.localPosition,
                widget.imageRect,
              );
              _pointerDownPoint = clamped;
              _didDrag = false;
              widget.onStart(clamped);
            }
          : (PointerDownEvent event) {
              if (!widget.imageRect.contains(event.localPosition)) {
                _resetPointerState();
                return;
              }
              _pointerDownPoint = DimensionLine.clampToRect(
                event.localPosition,
                widget.imageRect,
              );
              _didDrag = false;
            },
      onPointerMove: (PointerMoveEvent event) {
        final Offset clamped = DimensionLine.clampToRect(
          event.localPosition,
          widget.imageRect,
        );
        final Offset? pointerDown = _pointerDownPoint;
        if (pointerDown != null &&
            (clamped - pointerDown).distance >=
                DimensionLineConstants.tapMoveThreshold) {
          _didDrag = true;
        }
        if (widget.isEnabled) {
          widget.onUpdate(clamped);
        }
      },
      onPointerUp: (_) {
        if (widget.isEnabled) {
          widget.onEnd();
        }
        if (_pointerDownPoint != null && !_didDrag && widget.onTap != null) {
          widget.onTap!(_pointerDownPoint!);
        }
        _resetPointerState();
      },
      onPointerCancel: (_) {
        if (widget.isEnabled) {
          widget.onEnd();
        }
        _resetPointerState();
      },
      child: CustomPaint(
        painter: _DimensionLinesPainter(
          lines: List<DimensionLine>.of(widget.lines),
          arrows: List<ArrowMarkup>.of(widget.arrows),
          rectangles: List<RectangleMarkup>.of(widget.rectangles),
          ovals: List<OvalMarkup>.of(widget.ovals),
          freehands: List<FreehandMarkup>.of(widget.freehands),
          textNotes: List<TextNoteMarkup>.of(widget.textNotes),
          imageRect: widget.imageRect,
          selectedDimensionId: widget.selectedDimensionId,
          selectedArrowId: widget.selectedArrowId,
          selectedRectangleId: widget.selectedRectangleId,
          selectedOvalId: widget.selectedOvalId,
          selectedFreehandId: widget.selectedFreehandId,
          selectedTextNoteId: widget.selectedTextNoteId,
          activeStylePresetId: widget.activeStylePresetId,
          activeTool: widget.activeTool,
          activeStart: widget.activeStart,
          activeEnd: widget.activeEnd,
          activeFreehandPoints: List<Offset>.of(widget.activeFreehandPoints),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DimensionLinesPainter extends CustomPainter {
  const _DimensionLinesPainter({
    required this.lines,
    required this.arrows,
    required this.rectangles,
    required this.ovals,
    required this.freehands,
    required this.textNotes,
    required this.imageRect,
    required this.selectedDimensionId,
    required this.selectedArrowId,
    required this.selectedRectangleId,
    required this.selectedOvalId,
    required this.selectedFreehandId,
    required this.selectedTextNoteId,
    required this.activeStylePresetId,
    required this.activeTool,
    required this.activeStart,
    required this.activeEnd,
    required this.activeFreehandPoints,
  });

  final List<DimensionLine> lines;
  final List<ArrowMarkup> arrows;
  final List<RectangleMarkup> rectangles;
  final List<OvalMarkup> ovals;
  final List<FreehandMarkup> freehands;
  final List<TextNoteMarkup> textNotes;
  final Rect imageRect;
  final int? selectedDimensionId;
  final int? selectedArrowId;
  final int? selectedRectangleId;
  final int? selectedOvalId;
  final int? selectedFreehandId;
  final int? selectedTextNoteId;
  final MarkupStylePresetId activeStylePresetId;
  final MarkupTool activeTool;
  final Offset? activeStart;
  final Offset? activeEnd;
  final List<Offset> activeFreehandPoints;

  @override
  void paint(Canvas canvas, Size size) {
    if (imageRect.width <= 0 || imageRect.height <= 0) {
      return;
    }

    final Paint endpointFillPaint = Paint()
      ..color = DimensionLineConstants.endpointFillColor
      ..style = PaintingStyle.fill;

    final Paint labelBackgroundPaint = Paint()
      ..color = DimensionLineConstants.labelBackgroundColor
      ..style = PaintingStyle.fill;

    final Paint handleFillPaint = Paint()
      ..color = MarkupHandleConstants.fillColor
      ..style = PaintingStyle.fill;

    final Paint handleBorderPaint = Paint()
      ..color = MarkupHandleConstants.activeBorderColor
      ..strokeWidth = MarkupHandleConstants.activeBorderWidth
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipRect(imageRect);

    for (int i = 0; i < lines.length; i++) {
      final DimensionLine line = lines[i];
      final MarkupStylePreset preset = MarkupStylePresets.byId(
        line.stylePresetId,
      );
      final bool isSelected = selectedDimensionId == line.id;
      final Offset start = line.startInRect(imageRect);
      final Offset end = line.endInRect(imageRect);
      _drawLine(
        canvas,
        start,
        end,
        _dimensionLinePaint(preset, isSelected: isSelected),
        endpointFillPaint,
        _dimensionEndpointStrokePaint(preset, isSelected: isSelected),
      );
      _drawLabelIfPresent(
        canvas: canvas,
        line: line,
        start: start,
        end: end,
        labelBackgroundPaint: labelBackgroundPaint,
        labelBorderPaint: _dimensionLabelBorderPaint(preset),
      );
    }

    for (final ArrowMarkup arrow in arrows) {
      final MarkupStylePreset preset = MarkupStylePresets.byId(
        arrow.stylePresetId,
      );
      final bool isSelected = selectedArrowId == arrow.id;
      final Offset start = arrow.startInRect(imageRect);
      final Offset end = arrow.endInRect(imageRect);
      _drawArrow(
        canvas,
        start,
        end,
        _arrowPaint(preset, isSelected: isSelected),
      );
    }

    for (final RectangleMarkup rectangle in rectangles) {
      final MarkupStylePreset preset = MarkupStylePresets.byId(
        rectangle.stylePresetId,
      );
      final bool isSelected = selectedRectangleId == rectangle.id;
      final Rect rect = rectangle.rectInRect(imageRect);
      _drawRectangle(
        canvas,
        rect,
        _rectangleFillPaint(preset),
        _rectangleOutlinePaint(preset, isSelected: isSelected),
      );
    }

    for (final OvalMarkup oval in ovals) {
      final MarkupStylePreset preset = MarkupStylePresets.byId(
        oval.stylePresetId,
      );
      final bool isSelected = selectedOvalId == oval.id;
      final Rect rect = oval.rectInRect(imageRect);
      _drawOval(
        canvas,
        rect,
        _ovalFillPaint(preset),
        _ovalOutlinePaint(preset, isSelected: isSelected),
      );
    }

    for (final FreehandMarkup freehand in freehands) {
      final MarkupStylePreset preset = MarkupStylePresets.byId(
        freehand.stylePresetId,
      );
      final bool isSelected = selectedFreehandId == freehand.id;
      _drawFreehandPath(
        canvas,
        freehand.pointsInRect(imageRect),
        _freehandPaint(preset, isSelected: isSelected),
      );
    }

    for (final TextNoteMarkup note in textNotes) {
      final bool isSelected = selectedTextNoteId == note.id;
      _drawTextNote(
        canvas,
        note,
        isSelected: isSelected,
        stylePreset: MarkupStylePresets.byId(note.stylePresetId),
      );
    }

    if (selectedDimensionId != null) {
      for (final DimensionLine line in lines) {
        if (line.id == selectedDimensionId) {
          _drawHandle(
            canvas,
            line.startInRect(imageRect),
            handleFillPaint,
            handleBorderPaint,
          );
          _drawHandle(
            canvas,
            line.endInRect(imageRect),
            handleFillPaint,
            handleBorderPaint,
          );
          break;
        }
      }
    }

    if (selectedArrowId != null) {
      for (final ArrowMarkup arrow in arrows) {
        if (arrow.id == selectedArrowId) {
          _drawHandle(
            canvas,
            arrow.startInRect(imageRect),
            handleFillPaint,
            handleBorderPaint,
          );
          _drawHandle(
            canvas,
            arrow.endInRect(imageRect),
            handleFillPaint,
            handleBorderPaint,
          );
          break;
        }
      }
    }

    if (selectedRectangleId != null) {
      for (final RectangleMarkup rectangle in rectangles) {
        if (rectangle.id == selectedRectangleId) {
          final Rect rect = rectangle.rectInRect(imageRect);
          _drawHandle(canvas, rect.topLeft, handleFillPaint, handleBorderPaint);
          _drawHandle(
            canvas,
            rect.topRight,
            handleFillPaint,
            handleBorderPaint,
          );
          _drawHandle(
            canvas,
            rect.bottomRight,
            handleFillPaint,
            handleBorderPaint,
          );
          _drawHandle(
            canvas,
            rect.bottomLeft,
            handleFillPaint,
            handleBorderPaint,
          );
          break;
        }
      }
    }

    if (selectedOvalId != null) {
      for (final OvalMarkup oval in ovals) {
        if (oval.id == selectedOvalId) {
          final Rect rect = oval.rectInRect(imageRect);
          _drawHandle(canvas, rect.topLeft, handleFillPaint, handleBorderPaint);
          _drawHandle(
            canvas,
            rect.topRight,
            handleFillPaint,
            handleBorderPaint,
          );
          _drawHandle(
            canvas,
            rect.bottomRight,
            handleFillPaint,
            handleBorderPaint,
          );
          _drawHandle(
            canvas,
            rect.bottomLeft,
            handleFillPaint,
            handleBorderPaint,
          );
          break;
        }
      }
    }

    if (activeStart != null && activeEnd != null) {
      final MarkupStylePreset activePreset = MarkupStylePresets.byId(
        activeStylePresetId,
      );
      if (activeTool == MarkupTool.arrow) {
        _drawArrow(
          canvas,
          activeStart!,
          activeEnd!,
          _arrowPaint(activePreset, isSelected: false),
        );
      } else if (activeTool == MarkupTool.rectangle) {
        _drawRectangle(
          canvas,
          Rect.fromPoints(activeStart!, activeEnd!),
          _rectangleFillPaint(activePreset),
          _rectangleOutlinePaint(activePreset, isSelected: false),
        );
      } else if (activeTool == MarkupTool.oval) {
        _drawOval(
          canvas,
          Rect.fromPoints(activeStart!, activeEnd!),
          _ovalFillPaint(activePreset),
          _ovalOutlinePaint(activePreset, isSelected: false),
        );
      } else if (activeTool == MarkupTool.dimension) {
        _drawLine(
          canvas,
          activeStart!,
          activeEnd!,
          _dimensionLinePaint(activePreset, isSelected: false),
          endpointFillPaint,
          _dimensionEndpointStrokePaint(activePreset, isSelected: false),
        );
      }
    }
    if (activeTool == MarkupTool.freehand) {
      _drawFreehandPath(
        canvas,
        activeFreehandPoints,
        _freehandPaint(
          MarkupStylePresets.byId(activeStylePresetId),
          isSelected: false,
        ),
      );
    }

    canvas.restore();
  }

  Paint _dimensionLinePaint(
    MarkupStylePreset preset, {
    required bool isSelected,
  }) {
    return Paint()
      ..color = isSelected
          ? preset.dimensionSelectedLineColor
          : preset.dimensionLineColor
      ..strokeWidth =
          DimensionLineConstants.strokeWidth *
          (isSelected ? DimensionLineConstants.selectedStrokeMultiplier : 1.0)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
  }

  Paint _dimensionEndpointStrokePaint(
    MarkupStylePreset preset, {
    required bool isSelected,
  }) {
    return Paint()
      ..color = isSelected
          ? preset.dimensionSelectedLineColor
          : preset.dimensionLineColor
      ..strokeWidth = DimensionLineConstants.endpointStrokeWidth
      ..style = PaintingStyle.stroke;
  }

  Paint _dimensionLabelBorderPaint(MarkupStylePreset preset) {
    return Paint()
      ..color = preset.dimensionLineColor
      ..strokeWidth = DimensionLineConstants.labelBorderWidth
      ..style = PaintingStyle.stroke;
  }

  Paint _arrowPaint(MarkupStylePreset preset, {required bool isSelected}) {
    return Paint()
      ..color = isSelected
          ? preset.arrowSelectedLineColor
          : preset.arrowLineColor
      ..strokeWidth =
          ArrowMarkupConstants.strokeWidth *
          (isSelected ? ArrowMarkupConstants.selectedStrokeMultiplier : 1.0)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
  }

  Paint _rectangleOutlinePaint(
    MarkupStylePreset preset, {
    required bool isSelected,
  }) {
    return Paint()
      ..color = isSelected
          ? preset.rectangleSelectedOutlineColor
          : preset.rectangleOutlineColor
      ..strokeWidth =
          RectangleMarkupConstants.strokeWidth *
          (isSelected ? RectangleMarkupConstants.selectedStrokeMultiplier : 1.0)
      ..style = PaintingStyle.stroke;
  }

  Paint _rectangleFillPaint(MarkupStylePreset preset) {
    return Paint()
      ..color = preset.rectangleFillColor
      ..style = PaintingStyle.fill;
  }

  Paint _ovalOutlinePaint(
    MarkupStylePreset preset, {
    required bool isSelected,
  }) {
    return Paint()
      ..color = isSelected
          ? preset.ovalSelectedOutlineColor
          : preset.ovalOutlineColor
      ..strokeWidth =
          OvalMarkupConstants.strokeWidth *
          (isSelected ? OvalMarkupConstants.selectedStrokeMultiplier : 1.0)
      ..style = PaintingStyle.stroke;
  }

  Paint _ovalFillPaint(MarkupStylePreset preset) {
    return Paint()
      ..color = preset.ovalFillColor
      ..style = PaintingStyle.fill;
  }

  Paint _freehandPaint(MarkupStylePreset preset, {required bool isSelected}) {
    return Paint()
      ..color = isSelected
          ? preset.freehandSelectedStrokeColor
          : preset.freehandStrokeColor
      ..strokeWidth =
          FreehandMarkupConstants.strokeWidth *
          (isSelected ? FreehandMarkupConstants.selectedStrokeMultiplier : 1.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
  }

  void _drawFreehandPath(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.isEmpty) {
      return;
    }
    if (points.length == 1) {
      canvas.drawCircle(points.first, paint.strokeWidth / 2, paint);
      return;
    }

    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawHandle(
    Canvas canvas,
    Offset point,
    Paint fillPaint,
    Paint borderPaint,
  ) {
    canvas.drawCircle(point, MarkupHandleConstants.visibleRadius, fillPaint);
    canvas.drawCircle(point, MarkupHandleConstants.visibleRadius, borderPaint);
  }

  void _drawTextNote(
    Canvas canvas,
    TextNoteMarkup note, {
    required bool isSelected,
    required MarkupStylePreset stylePreset,
  }) {
    final String text = note.text.trim();
    if (text.isEmpty) {
      return;
    }

    final TextPainter textPainter =
        TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: stylePreset.textNoteTextColor,
              fontSize: TextNoteMarkupConstants.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 4,
          ellipsis: '...',
        )..layout(
          maxWidth: imageRect.width * TextNoteMarkupConstants.maxWidthFactor,
        );

    final Offset anchor = note.anchorInRect(imageRect);
    final Rect chipRect = _layoutNoteRect(anchor, textPainter);
    final RRect chip = RRect.fromRectAndRadius(
      chipRect,
      const Radius.circular(TextNoteMarkupConstants.borderRadius),
    );

    final Paint fillPaint = Paint()
      ..color = stylePreset.textNoteBackgroundColor
      ..style = PaintingStyle.fill;
    final Paint borderPaint = Paint()
      ..color = isSelected
          ? stylePreset.textNoteSelectedBorderColor
          : stylePreset.textNoteBorderColor
      ..strokeWidth = isSelected
          ? TextNoteMarkupConstants.selectedBorderWidth
          : TextNoteMarkupConstants.borderWidth
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(chip, fillPaint);
    canvas.drawRRect(chip, borderPaint);
    textPainter.paint(
      canvas,
      Offset(
        chipRect.left + TextNoteMarkupConstants.horizontalPadding,
        chipRect.top + TextNoteMarkupConstants.verticalPadding,
      ),
    );
  }

  Rect _layoutNoteRect(Offset anchor, TextPainter textPainter) {
    final double width =
        textPainter.width + (TextNoteMarkupConstants.horizontalPadding * 2);
    final double height =
        textPainter.height + (TextNoteMarkupConstants.verticalPadding * 2);

    double left = anchor.dx;
    double top = anchor.dy;

    final double minLeft =
        imageRect.left + TextNoteMarkupConstants.clampPadding;
    final double maxLeft =
        imageRect.right - width - TextNoteMarkupConstants.clampPadding;
    final double minTop = imageRect.top + TextNoteMarkupConstants.clampPadding;
    final double maxTop =
        imageRect.bottom - height - TextNoteMarkupConstants.clampPadding;

    left = left.clamp(minLeft, maxLeft >= minLeft ? maxLeft : minLeft);
    top = top.clamp(minTop, maxTop >= minTop ? maxTop : minTop);

    return Rect.fromLTWH(left, top, width, height);
  }

  void _drawOval(
    Canvas canvas,
    Rect rect,
    Paint fillPaint,
    Paint outlinePaint,
  ) {
    if (rect.width <= 0 || rect.height <= 0) {
      return;
    }
    canvas.drawOval(rect, fillPaint);
    canvas.drawOval(rect, outlinePaint);
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint arrowPaint) {
    canvas.drawLine(start, end, arrowPaint);

    final Offset direction = end - start;
    final double length = direction.distance;
    if (length < ArrowMarkupConstants.minLength) {
      return;
    }

    final double directionAngle = math.atan2(direction.dy, direction.dx);
    final double angleRad =
        ArrowMarkupConstants.arrowHeadAngleDegrees * (math.pi / 180.0);
    final double leftAngle = directionAngle + math.pi - angleRad;
    final double rightAngle = directionAngle + math.pi + angleRad;

    final Offset leftPoint =
        end +
        Offset(
          ArrowMarkupConstants.arrowHeadLength * math.cos(leftAngle),
          ArrowMarkupConstants.arrowHeadLength * math.sin(leftAngle),
        );
    final Offset rightPoint =
        end +
        Offset(
          ArrowMarkupConstants.arrowHeadLength * math.cos(rightAngle),
          ArrowMarkupConstants.arrowHeadLength * math.sin(rightAngle),
        );

    canvas.drawLine(end, leftPoint, arrowPaint);
    canvas.drawLine(end, rightPoint, arrowPaint);
  }

  void _drawRectangle(
    Canvas canvas,
    Rect rect,
    Paint fillPaint,
    Paint outlinePaint,
  ) {
    if (rect.width <= 0 || rect.height <= 0) {
      return;
    }
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, outlinePaint);
  }

  void _drawLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint linePaint,
    Paint endpointFillPaint,
    Paint endpointStrokePaint,
  ) {
    canvas.drawLine(start, end, linePaint);
    canvas.drawCircle(
      start,
      UiLayoutConstants.dimensionEndpointOuterRadius,
      endpointFillPaint,
    );
    canvas.drawCircle(
      end,
      UiLayoutConstants.dimensionEndpointOuterRadius,
      endpointFillPaint,
    );
    canvas.drawCircle(
      start,
      UiLayoutConstants.dimensionEndpointOuterRadius,
      endpointStrokePaint,
    );
    canvas.drawCircle(
      end,
      UiLayoutConstants.dimensionEndpointOuterRadius,
      endpointStrokePaint,
    );
    canvas.drawCircle(
      start,
      UiLayoutConstants.dimensionEndpointInnerRadius,
      endpointStrokePaint,
    );
    canvas.drawCircle(
      end,
      UiLayoutConstants.dimensionEndpointInnerRadius,
      endpointStrokePaint,
    );
  }

  void _drawLabelIfPresent({
    required Canvas canvas,
    required DimensionLine line,
    required Offset start,
    required Offset end,
    required Paint labelBackgroundPaint,
    required Paint labelBorderPaint,
  }) {
    final String label = line.label?.trim() ?? '';
    if (label.isEmpty) {
      return;
    }

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: DimensionLineConstants.labelTextColor,
          fontSize: UiLayoutConstants.dimensionLabelFontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    )..layout(maxWidth: imageRect.width * 0.8);

    final Offset midpoint = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );
    final Offset direction = end - start;
    Offset perpendicular = Offset(-direction.dy, direction.dx);
    if (perpendicular.distance == 0) {
      perpendicular = const Offset(0, -1);
    } else {
      perpendicular = perpendicular / perpendicular.distance;
    }

    Offset labelCenter =
        midpoint +
        (perpendicular * UiLayoutConstants.dimensionLabelOffsetFromLine);

    final double boxWidth =
        textPainter.width +
        (UiLayoutConstants.dimensionLabelHorizontalPadding * 2);
    final double boxHeight =
        textPainter.height +
        (UiLayoutConstants.dimensionLabelVerticalPadding * 2);

    double left = labelCenter.dx - (boxWidth / 2);
    double top = labelCenter.dy - (boxHeight / 2);

    final double minLeft =
        imageRect.left + UiLayoutConstants.dimensionLabelClampPadding;
    final double maxLeft =
        imageRect.right -
        boxWidth -
        UiLayoutConstants.dimensionLabelClampPadding;
    final double minTop =
        imageRect.top + UiLayoutConstants.dimensionLabelClampPadding;
    final double maxTop =
        imageRect.bottom -
        boxHeight -
        UiLayoutConstants.dimensionLabelClampPadding;
    left = left.clamp(minLeft, maxLeft >= minLeft ? maxLeft : minLeft);
    top = top.clamp(minTop, maxTop >= minTop ? maxTop : minTop);

    final Rect labelRect = Rect.fromLTWH(left, top, boxWidth, boxHeight);
    final RRect rrect = RRect.fromRectAndRadius(
      labelRect,
      const Radius.circular(UiLayoutConstants.dimensionLabelBorderRadius),
    );

    canvas.drawRRect(rrect, labelBackgroundPaint);
    canvas.drawRRect(rrect, labelBorderPaint);
    textPainter.paint(
      canvas,
      Offset(
        labelRect.left + UiLayoutConstants.dimensionLabelHorizontalPadding,
        labelRect.top + UiLayoutConstants.dimensionLabelVerticalPadding,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _DimensionLinesPainter oldDelegate) {
    return !listEquals(oldDelegate.lines, lines) ||
        !listEquals(oldDelegate.arrows, arrows) ||
        !listEquals(oldDelegate.rectangles, rectangles) ||
        !listEquals(oldDelegate.ovals, ovals) ||
        !listEquals(oldDelegate.freehands, freehands) ||
        !listEquals(oldDelegate.textNotes, textNotes) ||
        oldDelegate.imageRect != imageRect ||
        oldDelegate.selectedDimensionId != selectedDimensionId ||
        oldDelegate.selectedArrowId != selectedArrowId ||
        oldDelegate.selectedRectangleId != selectedRectangleId ||
        oldDelegate.selectedOvalId != selectedOvalId ||
        oldDelegate.selectedFreehandId != selectedFreehandId ||
        oldDelegate.selectedTextNoteId != selectedTextNoteId ||
        oldDelegate.activeTool != activeTool ||
        oldDelegate.activeStylePresetId != activeStylePresetId ||
        oldDelegate.activeStart != activeStart ||
        oldDelegate.activeEnd != activeEnd ||
        !listEquals(oldDelegate.activeFreehandPoints, activeFreehandPoints);
  }
}
