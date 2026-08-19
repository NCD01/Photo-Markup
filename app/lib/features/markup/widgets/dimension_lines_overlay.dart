import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/markup/rendering/markup_scene_renderer.dart';

/// The interactive markup layer over the photo.
///
/// Pointer handling lives here; all drawing is delegated to
/// [MarkupSceneRenderer], which is the same code the exporter runs.
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
    this.activeStrokeWidthScale = MarkupStrokeConstants.defaultScale,
    this.activeFilled = false,
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
  final double activeStrokeWidthScale;
  final bool activeFilled;

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
        painter: _MarkupOverlayPainter(
          scene: MarkupScene(
            lines: List<DimensionLine>.of(widget.lines),
            arrows: List<ArrowMarkup>.of(widget.arrows),
            rectangles: List<RectangleMarkup>.of(widget.rectangles),
            ovals: List<OvalMarkup>.of(widget.ovals),
            freehands: List<FreehandMarkup>.of(widget.freehands),
            textNotes: List<TextNoteMarkup>.of(widget.textNotes),
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
            activeStrokeWidthScale: widget.activeStrokeWidthScale,
            activeFilled: widget.activeFilled,
          ),
          imageRect: widget.imageRect,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MarkupOverlayPainter extends CustomPainter {
  const _MarkupOverlayPainter({required this.scene, required this.imageRect});

  final MarkupScene scene;
  final Rect imageRect;

  @override
  void paint(Canvas canvas, Size size) {
    MarkupSceneRenderer.paint(
      canvas: canvas,
      scene: scene,
      imageRect: imageRect,
    );
  }

  @override
  bool shouldRepaint(covariant _MarkupOverlayPainter oldDelegate) {
    return oldDelegate.imageRect != imageRect ||
        !MarkupScene.sameContent(oldDelegate.scene, scene);
  }
}
