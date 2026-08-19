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
    this.callouts = const <CalloutMarkup>[],
    this.blurs = const <BlurMarkup>[],
    required this.imageRect,
    required this.selectedDimensionId,
    required this.selectedArrowId,
    required this.selectedRectangleId,
    required this.selectedOvalId,
    required this.selectedFreehandId,
    required this.selectedTextNoteId,
    this.selectedCalloutId,
    this.selectedBlurId,
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
    this.markerMode = MarkerModeConstants.defaultEnabled,
  });

  final List<DimensionLine> lines;
  final List<ArrowMarkup> arrows;
  final List<RectangleMarkup> rectangles;
  final List<OvalMarkup> ovals;
  final List<FreehandMarkup> freehands;
  final List<TextNoteMarkup> textNotes;
  final List<CalloutMarkup> callouts;
  final List<BlurMarkup> blurs;
  final Rect imageRect;
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
  final bool isEnabled;
  final ValueChanged<Offset> onStart;
  final ValueChanged<Offset> onUpdate;
  final VoidCallback onEnd;
  final ValueChanged<Offset>? onTap;
  final double activeStrokeWidthScale;
  final bool activeFilled;
  final bool markerMode;

  @override
  State<DimensionLinesOverlay> createState() => _DimensionLinesOverlayState();
}

class _DimensionLinesOverlayState extends State<DimensionLinesOverlay> {
  Offset? _pointerDownPoint;
  bool _didDrag = false;
  int _activePointerCount = 0;
  bool _multiTouchCancelled = false;
  Offset? _lastTapPoint;
  Duration _lastTapAt = Duration.zero;
  final Stopwatch _tapClock = Stopwatch()..start();

  void _resetPointerState() {
    _pointerDownPoint = null;
    _didDrag = false;
  }

  /// True when the same spot was tapped a moment ago.
  ///
  /// A second tap in the same place within the double-tap window is almost
  /// always a slip, not a request for a second note or a second pin stacked on
  /// the first.
  bool _isAccidentalRepeatTap(Offset point) {
    final Offset? previous = _lastTapPoint;
    final Duration now = _tapClock.elapsed;
    final bool repeat =
        previous != null &&
        (point - previous).distance <=
            MarkupTapGuardConstants.repeatTapDistance &&
        (now - _lastTapAt) <= MarkupTapGuardConstants.repeatTapWindow;
    _lastTapPoint = point;
    _lastTapAt = now;
    return repeat;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: widget.isEnabled
          ? (PointerDownEvent event) {
              _activePointerCount += 1;
              if (_activePointerCount > 1) {
                // A second finger means pinch or pan, not a mark. Abandon the
                // stroke in progress and let the viewer have the gesture.
                _multiTouchCancelled = true;
                widget.onEnd();
                _resetPointerState();
                return;
              }
              if (!widget.imageRect.contains(event.localPosition)) {
                _resetPointerState();
                return;
              }
              _multiTouchCancelled = false;
              final Offset clamped = DimensionLine.clampToRect(
                event.localPosition,
                widget.imageRect,
              );
              _pointerDownPoint = clamped;
              _didDrag = false;
              widget.onStart(clamped);
            }
          : (PointerDownEvent event) {
              _activePointerCount += 1;
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
        if (_multiTouchCancelled || _activePointerCount > 1) {
          return;
        }
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
        _activePointerCount = (_activePointerCount - 1).clamp(0, 20);
        if (_multiTouchCancelled) {
          if (_activePointerCount == 0) {
            _multiTouchCancelled = false;
          }
          _resetPointerState();
          return;
        }
        if (widget.isEnabled) {
          widget.onEnd();
        }
        final Offset? tapPoint = _pointerDownPoint;
        if (tapPoint != null && !_didDrag && widget.onTap != null) {
          if (!_isAccidentalRepeatTap(tapPoint)) {
            widget.onTap!(tapPoint);
          }
        }
        _resetPointerState();
      },
      onPointerCancel: (_) {
        _activePointerCount = (_activePointerCount - 1).clamp(0, 20);
        if (_activePointerCount == 0) {
          _multiTouchCancelled = false;
        }
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
            callouts: List<CalloutMarkup>.of(widget.callouts),
            blurs: List<BlurMarkup>.of(widget.blurs),
            selectedDimensionId: widget.selectedDimensionId,
            selectedArrowId: widget.selectedArrowId,
            selectedRectangleId: widget.selectedRectangleId,
            selectedOvalId: widget.selectedOvalId,
            selectedFreehandId: widget.selectedFreehandId,
            selectedTextNoteId: widget.selectedTextNoteId,
            selectedCalloutId: widget.selectedCalloutId,
            selectedBlurId: widget.selectedBlurId,
            activeStylePresetId: widget.activeStylePresetId,
            activeTool: widget.activeTool,
            activeStart: widget.activeStart,
            activeEnd: widget.activeEnd,
            activeFreehandPoints: List<Offset>.of(widget.activeFreehandPoints),
            activeStrokeWidthScale: widget.activeStrokeWidthScale,
            activeFilled: widget.activeFilled,
            markerMode: widget.markerMode,
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
