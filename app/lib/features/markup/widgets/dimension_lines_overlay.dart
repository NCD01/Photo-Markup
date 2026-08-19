import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/features/markup/models/area_measurement.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/multi_segment_measurement.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/scale_calibration.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_text_layout_utils.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_typography_utils.dart';
import 'package:ncd_photo_markup/features/markup/utils/measurement_value_utils.dart';

class DimensionLinesOverlay extends StatefulWidget {
  const DimensionLinesOverlay({
    super.key,
    required this.scaleCalibration,
    required this.multiSegmentMeasurements,
    required this.areaMeasurements,
    required this.lines,
    required this.arrows,
    required this.rectangles,
    required this.ovals,
    required this.freehands,
    required this.textNotes,
    required this.imageRect,
    required this.imagePixelSize,
    required this.selectedScaleCalibrationId,
    required this.selectedMultiSegmentMeasurementId,
    required this.selectedAreaMeasurementId,
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
    required this.activeMeasurementPoints,
    this.activeMeasurementPreviewPoint,
    required this.activeFreehandPoints,
    required this.isEnabled,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    this.onTap,
  });

  final ScaleCalibration? scaleCalibration;
  final List<MultiSegmentMeasurement> multiSegmentMeasurements;
  final List<AreaMeasurement> areaMeasurements;
  final List<DimensionLine> lines;
  final List<ArrowMarkup> arrows;
  final List<RectangleMarkup> rectangles;
  final List<OvalMarkup> ovals;
  final List<FreehandMarkup> freehands;
  final List<TextNoteMarkup> textNotes;
  final Rect imageRect;
  final Size? imagePixelSize;
  final int? selectedScaleCalibrationId;
  final int? selectedMultiSegmentMeasurementId;
  final int? selectedAreaMeasurementId;
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
  final List<Offset> activeMeasurementPoints;
  final Offset? activeMeasurementPreviewPoint;
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
    final bool usesTapSequenceTool =
        widget.activeTool == MarkupTool.multiSegmentMeasurement ||
        widget.activeTool == MarkupTool.areaMeasurement;
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
              if (!usesTapSequenceTool) {
                widget.onStart(clamped);
              }
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
          if (!usesTapSequenceTool ||
              widget.activeMeasurementPoints.isNotEmpty) {
            widget.onUpdate(clamped);
          }
        }
      },
      onPointerUp: (_) {
        if (widget.isEnabled && !usesTapSequenceTool) {
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
          scaleCalibration: widget.scaleCalibration,
          multiSegmentMeasurements: List<MultiSegmentMeasurement>.of(
            widget.multiSegmentMeasurements,
          ),
          areaMeasurements: List<AreaMeasurement>.of(widget.areaMeasurements),
          lines: List<DimensionLine>.of(widget.lines),
          arrows: List<ArrowMarkup>.of(widget.arrows),
          rectangles: List<RectangleMarkup>.of(widget.rectangles),
          ovals: List<OvalMarkup>.of(widget.ovals),
          freehands: List<FreehandMarkup>.of(widget.freehands),
          textNotes: List<TextNoteMarkup>.of(widget.textNotes),
          imageRect: widget.imageRect,
          imagePixelSize: widget.imagePixelSize,
          selectedScaleCalibrationId: widget.selectedScaleCalibrationId,
          selectedMultiSegmentMeasurementId:
              widget.selectedMultiSegmentMeasurementId,
          selectedAreaMeasurementId: widget.selectedAreaMeasurementId,
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
          activeMeasurementPoints: List<Offset>.of(
            widget.activeMeasurementPoints,
          ),
          activeMeasurementPreviewPoint: widget.activeMeasurementPreviewPoint,
          activeFreehandPoints: List<Offset>.of(widget.activeFreehandPoints),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DimensionLinesPainter extends CustomPainter {
  const _DimensionLinesPainter({
    required this.scaleCalibration,
    required this.multiSegmentMeasurements,
    required this.areaMeasurements,
    required this.lines,
    required this.arrows,
    required this.rectangles,
    required this.ovals,
    required this.freehands,
    required this.textNotes,
    required this.imageRect,
    required this.imagePixelSize,
    required this.selectedScaleCalibrationId,
    required this.selectedMultiSegmentMeasurementId,
    required this.selectedAreaMeasurementId,
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
    required this.activeMeasurementPoints,
    required this.activeMeasurementPreviewPoint,
    required this.activeFreehandPoints,
  });

  final ScaleCalibration? scaleCalibration;
  final List<MultiSegmentMeasurement> multiSegmentMeasurements;
  final List<AreaMeasurement> areaMeasurements;
  final List<DimensionLine> lines;
  final List<ArrowMarkup> arrows;
  final List<RectangleMarkup> rectangles;
  final List<OvalMarkup> ovals;
  final List<FreehandMarkup> freehands;
  final List<TextNoteMarkup> textNotes;
  final Rect imageRect;
  final Size? imagePixelSize;
  final int? selectedScaleCalibrationId;
  final int? selectedMultiSegmentMeasurementId;
  final int? selectedAreaMeasurementId;
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
  final List<Offset> activeMeasurementPoints;
  final Offset? activeMeasurementPreviewPoint;
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

    final ScaleCalibration? currentScaleCalibration = scaleCalibration;
    if (currentScaleCalibration != null) {
      final MarkupStylePreset preset = MarkupStylePresets.byId(
        currentScaleCalibration.stylePresetId,
      );
      final bool isSelected =
          selectedScaleCalibrationId == currentScaleCalibration.id;
      final Offset start = currentScaleCalibration.startInRect(imageRect);
      final Offset end = currentScaleCalibration.endInRect(imageRect);
      final DimensionLine calibrationLine = DimensionLine(
        id: currentScaleCalibration.id,
        startNormalized: currentScaleCalibration.startNormalized,
        endNormalized: currentScaleCalibration.endNormalized,
        label: MeasurementValueUtils.calibrationDisplayLabel(
          currentScaleCalibration,
        ),
        fontFamily: currentScaleCalibration.fontFamily,
        fontSize: currentScaleCalibration.fontSize,
        stylePresetId: currentScaleCalibration.stylePresetId,
      );
      _drawLine(
        canvas,
        start,
        end,
        _measurementLinePaint(preset, isSelected: isSelected),
        endpointFillPaint,
        _measurementEndpointStrokePaint(preset, isSelected: isSelected),
      );
      _drawLabelIfPresent(
        canvas: canvas,
        line: calibrationLine,
        start: start,
        end: end,
        labelBackgroundPaint: labelBackgroundPaint,
        labelBorderPaint: _measurementLabelBorderPaint(preset),
        leaderPaint: _measurementLeaderPaint(preset, isSelected: isSelected),
      );
    }

    for (final MultiSegmentMeasurement measurement
        in multiSegmentMeasurements) {
      final MarkupStylePreset preset = MarkupStylePresets.byId(
        measurement.stylePresetId,
      );
      final bool isSelected =
          selectedMultiSegmentMeasurementId == measurement.id;
      final List<Offset> points = measurement.pointsInRect(imageRect);
      _drawPolyline(
        canvas,
        points,
        _measurementLinePaint(preset, isSelected: isSelected),
      );
      _drawMeasurementLabel(
        canvas: canvas,
        label: MeasurementValueUtils.multiSegmentDisplayLabel(
          measurement: measurement,
          calibration: currentScaleCalibration,
          imagePixelSize: imagePixelSize,
        ),
        anchor: MeasurementValueUtils.polylineLabelAnchor(points),
        fontFamily: measurement.fontFamily,
        fontSize: measurement.fontSize,
        borderPaint: _measurementLabelBorderPaint(preset),
        backgroundPaint: labelBackgroundPaint,
      );
    }

    for (final AreaMeasurement measurement in areaMeasurements) {
      final MarkupStylePreset preset = MarkupStylePresets.byId(
        measurement.stylePresetId,
      );
      final bool isSelected = selectedAreaMeasurementId == measurement.id;
      final List<Offset> points = measurement.pointsInRect(imageRect);
      _drawPolygon(
        canvas,
        points,
        _measurementAreaFillPaint(preset),
        _measurementLinePaint(preset, isSelected: isSelected),
      );
      _drawMeasurementLabel(
        canvas: canvas,
        label: MeasurementValueUtils.areaDisplayLabel(
          measurement: measurement,
          calibration: currentScaleCalibration,
          imagePixelSize: imagePixelSize,
        ),
        anchor: MeasurementValueUtils.polygonLabelAnchor(points),
        fontFamily: measurement.fontFamily,
        fontSize: measurement.fontSize,
        borderPaint: _measurementLabelBorderPaint(preset),
        backgroundPaint: labelBackgroundPaint,
      );
    }

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
        leaderPaint: _dimensionLabelLeaderPaint(preset, isSelected: isSelected),
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

    final ScaleCalibration? currentCalibrationForHandles = scaleCalibration;
    if (selectedScaleCalibrationId != null &&
        currentCalibrationForHandles != null &&
        currentCalibrationForHandles.id == selectedScaleCalibrationId) {
      _drawHandle(
        canvas,
        currentCalibrationForHandles.startInRect(imageRect),
        handleFillPaint,
        handleBorderPaint,
      );
      _drawHandle(
        canvas,
        currentCalibrationForHandles.endInRect(imageRect),
        handleFillPaint,
        handleBorderPaint,
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
      } else if (activeTool == MarkupTool.scaleCalibration) {
        _drawLine(
          canvas,
          activeStart!,
          activeEnd!,
          _measurementLinePaint(activePreset, isSelected: false),
          endpointFillPaint,
          _measurementEndpointStrokePaint(activePreset, isSelected: false),
        );
      }
    }
    if (activeMeasurementPoints.isNotEmpty &&
        (activeTool == MarkupTool.multiSegmentMeasurement ||
            activeTool == MarkupTool.areaMeasurement)) {
      final List<Offset> previewPoints = <Offset>[
        ...activeMeasurementPoints,
        if (activeMeasurementPreviewPoint case final Offset previewPoint)
          previewPoint,
      ];
      final MarkupStylePreset previewPreset = MarkupStylePresets.byId(
        activeStylePresetId,
      );
      if (activeTool == MarkupTool.areaMeasurement) {
        _drawPolygon(
          canvas,
          previewPoints,
          _measurementAreaFillPaint(previewPreset, isPreview: true),
          _measurementLinePaint(previewPreset, isSelected: false),
        );
      } else {
        _drawPolyline(
          canvas,
          previewPoints,
          _measurementLinePaint(previewPreset, isSelected: false),
        );
      }
      for (final Offset point in activeMeasurementPoints) {
        _drawMeasurementVertex(canvas, point, previewPreset.dimensionLineColor);
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

  Paint _dimensionLabelLeaderPaint(
    MarkupStylePreset preset, {
    required bool isSelected,
  }) {
    return Paint()
      ..color = isSelected
          ? preset.dimensionSelectedLineColor
          : preset.dimensionLineColor
      ..strokeWidth = DimensionLineConstants.labelLeaderStrokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
  }

  Paint _measurementLinePaint(
    MarkupStylePreset preset, {
    required bool isSelected,
  }) {
    return Paint()
      ..color = isSelected
          ? preset.dimensionSelectedLineColor
          : preset.dimensionLineColor
      ..strokeWidth =
          MeasurementToolConstants.lineStrokeWidth *
          (isSelected ? MeasurementToolConstants.selectedStrokeMultiplier : 1.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
  }

  Paint _measurementEndpointStrokePaint(
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

  Paint _measurementLabelBorderPaint(MarkupStylePreset preset) {
    return Paint()
      ..color = preset.dimensionLineColor
      ..strokeWidth = DimensionLineConstants.labelBorderWidth
      ..style = PaintingStyle.stroke;
  }

  Paint _measurementLeaderPaint(
    MarkupStylePreset preset, {
    required bool isSelected,
  }) {
    return Paint()
      ..color = isSelected
          ? preset.dimensionSelectedLineColor
          : preset.dimensionLineColor
      ..strokeWidth = DimensionLineConstants.labelLeaderStrokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
  }

  Paint _measurementAreaFillPaint(
    MarkupStylePreset preset, {
    bool isPreview = false,
  }) {
    return Paint()
      ..color = preset.dimensionLineColor.withValues(
        alpha: isPreview
            ? MeasurementToolConstants.fillOpacity / 2
            : MeasurementToolConstants.fillOpacity,
      )
      ..style = PaintingStyle.fill;
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

  void _drawPolyline(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) {
      return;
    }
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawPolygon(
    Canvas canvas,
    List<Offset> points,
    Paint fillPaint,
    Paint outlinePaint,
  ) {
    if (points.length < 2) {
      return;
    }
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    if (points.length >= 3) {
      path.close();
      canvas.drawPath(path, fillPaint);
    }
    canvas.drawPath(path, outlinePaint);
  }

  void _drawMeasurementVertex(Canvas canvas, Offset point, Color color) {
    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      point,
      MeasurementToolConstants.pointPreviewRadius,
      fillPaint,
    );
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

    final TextNoteLayout layout = MarkupTextLayoutUtils.layoutTextNote(
      note: note,
      imageRect: imageRect,
      preset: stylePreset,
    );
    final Rect chipRect = layout.chipRect;
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
    layout.textPainter.paint(canvas, layout.textOffset);
  }

  void _drawMeasurementLabel({
    required Canvas canvas,
    required String label,
    required Offset anchor,
    required String fontFamily,
    required double fontSize,
    required Paint borderPaint,
    required Paint backgroundPaint,
  }) {
    final String trimmed = label.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final TextPainter textPainter =
        TextPainter(
          text: TextSpan(
            text: trimmed,
            style: MarkupTypographyUtils.baseTextStyle(
              color: DimensionLineConstants.labelTextColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              fontFamily: fontFamily,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 2,
          textAlign: TextAlign.center,
          ellipsis: '...',
        )..layout(
          maxWidth:
              imageRect.width * MeasurementToolConstants.labelMaxWidthFactor,
        );

    final double width =
        textPainter.width +
        (MeasurementToolConstants.labelPaddingHorizontal * 2);
    final double height =
        textPainter.height +
        (MeasurementToolConstants.labelPaddingVertical * 2);

    double left = anchor.dx - (width / 2);
    double top = anchor.dy - (height / 2);

    final double minLeft =
        imageRect.left + MeasurementToolConstants.labelClampPadding;
    final double maxLeft =
        imageRect.right - width - MeasurementToolConstants.labelClampPadding;
    final double minTop =
        imageRect.top + MeasurementToolConstants.labelClampPadding;
    final double maxTop =
        imageRect.bottom - height - MeasurementToolConstants.labelClampPadding;
    left = left.clamp(minLeft, maxLeft >= minLeft ? maxLeft : minLeft);
    top = top.clamp(minTop, maxTop >= minTop ? maxTop : minTop);

    final Rect rect = Rect.fromLTWH(left, top, width, height);
    final RRect chip = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(MeasurementToolConstants.labelRadius),
    );
    canvas.drawRRect(chip, backgroundPaint);
    canvas.drawRRect(chip, borderPaint);
    textPainter.paint(
      canvas,
      Offset(
        rect.left + MeasurementToolConstants.labelPaddingHorizontal,
        rect.top + MeasurementToolConstants.labelPaddingVertical,
      ),
    );
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
    required Paint leaderPaint,
  }) {
    final DimensionLabelLayout? layout =
        MarkupTextLayoutUtils.layoutDimensionLabel(
          line: line,
          imageRect: imageRect,
          start: start,
          end: end,
        );
    if (layout == null) {
      return;
    }
    final TextPainter textPainter =
        TextPainter(
          text: TextSpan(
            text: line.label?.trim(),
            style: MarkupTextLayoutUtils.dimensionLabelTextStyle(line),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 2,
          ellipsis: '...',
        )..layout(
          maxWidth:
              imageRect.width * DimensionLineConstants.labelTextMaxWidthFactor,
        );
    final Rect labelRect = layout.labelRect;
    final RRect rrect = RRect.fromRectAndRadius(
      labelRect,
      const Radius.circular(UiLayoutConstants.dimensionLabelBorderRadius),
    );

    if (layout.showLeader) {
      canvas.drawLine(layout.leaderStart, layout.leaderEnd, leaderPaint);
    }
    canvas.drawRRect(rrect, labelBackgroundPaint);
    canvas.drawRRect(rrect, labelBorderPaint);
    textPainter.paint(canvas, layout.textOffset);
  }

  @override
  bool shouldRepaint(covariant _DimensionLinesPainter oldDelegate) {
    return oldDelegate.scaleCalibration != scaleCalibration ||
        !listEquals(
          oldDelegate.multiSegmentMeasurements,
          multiSegmentMeasurements,
        ) ||
        !listEquals(oldDelegate.areaMeasurements, areaMeasurements) ||
        !listEquals(oldDelegate.lines, lines) ||
        !listEquals(oldDelegate.arrows, arrows) ||
        !listEquals(oldDelegate.rectangles, rectangles) ||
        !listEquals(oldDelegate.ovals, ovals) ||
        !listEquals(oldDelegate.freehands, freehands) ||
        !listEquals(oldDelegate.textNotes, textNotes) ||
        oldDelegate.imageRect != imageRect ||
        oldDelegate.imagePixelSize != imagePixelSize ||
        oldDelegate.selectedScaleCalibrationId != selectedScaleCalibrationId ||
        oldDelegate.selectedMultiSegmentMeasurementId !=
            selectedMultiSegmentMeasurementId ||
        oldDelegate.selectedAreaMeasurementId != selectedAreaMeasurementId ||
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
        !listEquals(
          oldDelegate.activeMeasurementPoints,
          activeMeasurementPoints,
        ) ||
        oldDelegate.activeMeasurementPreviewPoint !=
            activeMeasurementPreviewPoint ||
        !listEquals(oldDelegate.activeFreehandPoints, activeFreehandPoints);
  }
}
