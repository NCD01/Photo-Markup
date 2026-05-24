import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';

class DimensionLinesOverlay extends StatefulWidget {
  const DimensionLinesOverlay({
    super.key,
    required this.lines,
    required this.imageRect,
    this.selectedLineIndex,
    this.activeStart,
    this.activeEnd,
    required this.isEnabled,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    this.onTap,
  });

  final List<DimensionLine> lines;
  final Rect imageRect;
  final int? selectedLineIndex;
  final Offset? activeStart;
  final Offset? activeEnd;
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
          imageRect: widget.imageRect,
          selectedLineIndex: widget.selectedLineIndex,
          activeStart: widget.activeStart,
          activeEnd: widget.activeEnd,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DimensionLinesPainter extends CustomPainter {
  const _DimensionLinesPainter({
    required this.lines,
    required this.imageRect,
    required this.selectedLineIndex,
    required this.activeStart,
    required this.activeEnd,
  });

  final List<DimensionLine> lines;
  final Rect imageRect;
  final int? selectedLineIndex;
  final Offset? activeStart;
  final Offset? activeEnd;

  @override
  void paint(Canvas canvas, Size size) {
    if (imageRect.width <= 0 || imageRect.height <= 0) {
      return;
    }

    final Paint linePaint = Paint()
      ..color = DimensionLineConstants.lineColor
      ..strokeWidth = DimensionLineConstants.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint selectedLinePaint = Paint()
      ..color = DimensionLineConstants.selectedLineColor
      ..strokeWidth =
          DimensionLineConstants.strokeWidth *
          DimensionLineConstants.selectedStrokeMultiplier
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint endpointFillPaint = Paint()
      ..color = DimensionLineConstants.endpointFillColor
      ..style = PaintingStyle.fill;

    final Paint endpointStrokePaint = Paint()
      ..color = DimensionLineConstants.lineColor
      ..strokeWidth = DimensionLineConstants.endpointStrokeWidth
      ..style = PaintingStyle.stroke;

    final Paint labelBackgroundPaint = Paint()
      ..color = DimensionLineConstants.labelBackgroundColor
      ..style = PaintingStyle.fill;

    final Paint labelBorderPaint = Paint()
      ..color = DimensionLineConstants.labelBorderColor
      ..strokeWidth = DimensionLineConstants.labelBorderWidth
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipRect(imageRect);

    for (int i = 0; i < lines.length; i++) {
      final DimensionLine line = lines[i];
      final bool isSelected = selectedLineIndex == i;
      final Offset start = line.startInRect(imageRect);
      final Offset end = line.endInRect(imageRect);
      _drawLine(
        canvas,
        start,
        end,
        isSelected ? selectedLinePaint : linePaint,
        endpointFillPaint,
        isSelected ? selectedLinePaint : endpointStrokePaint,
      );
      _drawLabelIfPresent(
        canvas: canvas,
        line: line,
        start: start,
        end: end,
        labelBackgroundPaint: labelBackgroundPaint,
        labelBorderPaint: labelBorderPaint,
      );
    }

    if (activeStart != null && activeEnd != null) {
      _drawLine(
        canvas,
        activeStart!,
        activeEnd!,
        linePaint,
        endpointFillPaint,
        endpointStrokePaint,
      );
    }

    canvas.restore();
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
        oldDelegate.imageRect != imageRect ||
        oldDelegate.selectedLineIndex != selectedLineIndex ||
        oldDelegate.activeStart != activeStart ||
        oldDelegate.activeEnd != activeEnd;
  }
}
