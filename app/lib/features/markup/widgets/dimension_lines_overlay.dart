import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';

class DimensionLinesOverlay extends StatelessWidget {
  const DimensionLinesOverlay({
    super.key,
    required this.lines,
    required this.imageRect,
    this.activeStart,
    this.activeEnd,
    required this.isEnabled,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
  });

  final List<DimensionLine> lines;
  final Rect imageRect;
  final Offset? activeStart;
  final Offset? activeEnd;
  final bool isEnabled;
  final ValueChanged<Offset> onStart;
  final ValueChanged<Offset> onUpdate;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: isEnabled
          ? (PointerDownEvent event) {
              if (imageRect.contains(event.localPosition)) {
                onStart(
                  DimensionLine.clampToRect(event.localPosition, imageRect),
                );
              }
            }
          : null,
      onPointerMove: isEnabled
          ? (PointerMoveEvent event) {
              onUpdate(
                DimensionLine.clampToRect(event.localPosition, imageRect),
              );
            }
          : null,
      onPointerUp: isEnabled ? (_) => onEnd() : null,
      onPointerCancel: isEnabled ? (_) => onEnd() : null,
      child: CustomPaint(
        painter: _DimensionLinesPainter(
          lines: lines,
          imageRect: imageRect,
          activeStart: activeStart,
          activeEnd: activeEnd,
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
    required this.activeStart,
    required this.activeEnd,
  });

  final List<DimensionLine> lines;
  final Rect imageRect;
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

    final Paint endpointFillPaint = Paint()
      ..color = DimensionLineConstants.endpointFillColor
      ..style = PaintingStyle.fill;

    final Paint endpointStrokePaint = Paint()
      ..color = DimensionLineConstants.lineColor
      ..strokeWidth = DimensionLineConstants.endpointStrokeWidth
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipRect(imageRect);

    for (final DimensionLine line in lines) {
      _drawLine(
        canvas,
        line.startInRect(imageRect),
        line.endInRect(imageRect),
        linePaint,
        endpointFillPaint,
        endpointStrokePaint,
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

  @override
  bool shouldRepaint(covariant _DimensionLinesPainter oldDelegate) {
    return oldDelegate.lines != lines ||
        oldDelegate.imageRect != imageRect ||
        oldDelegate.activeStart != activeStart ||
        oldDelegate.activeEnd != activeEnd;
  }
}
