import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_typography_utils.dart';

class DimensionLabelLayout {
  const DimensionLabelLayout({
    required this.labelRect,
    required this.labelCenter,
    required this.textOffset,
    required this.leaderStart,
    required this.leaderEnd,
    required this.showLeader,
  });

  final Rect labelRect;
  final Offset labelCenter;
  final Offset textOffset;
  final Offset leaderStart;
  final Offset leaderEnd;
  final bool showLeader;
}

class TextNoteLayout {
  const TextNoteLayout({
    required this.chipRect,
    required this.textOffset,
    required this.textPainter,
  });

  final Rect chipRect;
  final Offset textOffset;
  final TextPainter textPainter;
}

class MarkupTextLayoutUtils {
  const MarkupTextLayoutUtils._();

  static TextStyle dimensionLabelTextStyle(DimensionLine line) {
    return MarkupTypographyUtils.baseTextStyle(
      color: DimensionLineConstants.labelTextColor,
      fontSize: line.fontSize,
      fontWeight: FontWeight.w700,
      fontFamily: line.fontFamily,
    );
  }

  static TextStyle textNoteTextStyle(
    TextNoteMarkup note,
    MarkupStylePreset preset,
  ) {
    return MarkupTypographyUtils.baseTextStyle(
      color: preset.textNoteTextColor,
      fontSize: note.fontSize,
      fontWeight: FontWeight.w600,
      fontFamily: note.fontFamily,
    );
  }

  static DimensionLabelLayout? layoutDimensionLabel({
    required DimensionLine line,
    required Rect imageRect,
    required Offset start,
    required Offset end,
    Offset? overrideLabelOffsetNormalized,
  }) {
    final String label = line.label?.trim() ?? '';
    if (label.isEmpty || imageRect.width <= 0 || imageRect.height <= 0) {
      return null;
    }

    final TextPainter textPainter =
        TextPainter(
          text: TextSpan(text: label, style: dimensionLabelTextStyle(line)),
          textDirection: TextDirection.ltr,
          maxLines: 2,
          ellipsis: '...',
        )..layout(
          maxWidth:
              imageRect.width * DimensionLineConstants.labelTextMaxWidthFactor,
        );

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

    final Offset defaultCenter =
        midpoint +
        (perpendicular * DimensionLineConstants.defaultLabelOffsetFromLine);
    final Offset? normalizedOffset =
        overrideLabelOffsetNormalized ?? line.labelOffsetNormalized;
    final Offset requestedCenter = normalizedOffset == null
        ? defaultCenter
        : midpoint +
              Offset(
                normalizedOffset.dx * imageRect.width,
                normalizedOffset.dy * imageRect.height,
              );

    final double boxWidth =
        textPainter.width +
        (UiLayoutConstants.dimensionLabelHorizontalPadding * 2);
    final double boxHeight =
        textPainter.height +
        (UiLayoutConstants.dimensionLabelVerticalPadding * 2);

    double left = requestedCenter.dx - (boxWidth / 2);
    double top = requestedCenter.dy - (boxHeight / 2);

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
    final Offset labelCenter = labelRect.center;
    final Offset leaderEnd = nearestPointOnRect(labelRect, midpoint);
    final bool showLeader =
        normalizedOffset != null &&
        (leaderEnd - midpoint).distance >=
            DimensionLineConstants.labelLeaderVisibilityThreshold;

    return DimensionLabelLayout(
      labelRect: labelRect,
      labelCenter: labelCenter,
      textOffset: Offset(
        labelRect.left + UiLayoutConstants.dimensionLabelHorizontalPadding,
        labelRect.top + UiLayoutConstants.dimensionLabelVerticalPadding,
      ),
      leaderStart: midpoint,
      leaderEnd: leaderEnd,
      showLeader: showLeader,
    );
  }

  static TextNoteLayout layoutTextNote({
    required TextNoteMarkup note,
    required Rect imageRect,
    required MarkupStylePreset preset,
  }) {
    final TextPainter textPainter =
        TextPainter(
          text: TextSpan(
            text: note.text.trim(),
            style: textNoteTextStyle(note, preset),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 4,
          ellipsis: '...',
        )..layout(
          maxWidth: imageRect.width * TextNoteMarkupConstants.maxWidthFactor,
        );

    final Offset anchor = note.anchorInRect(imageRect);
    final Rect chipRect = layoutTextNoteRect(
      anchor: anchor,
      textPainter: textPainter,
      imageRect: imageRect,
    );

    return TextNoteLayout(
      chipRect: chipRect,
      textOffset: Offset(
        chipRect.left + TextNoteMarkupConstants.horizontalPadding,
        chipRect.top + TextNoteMarkupConstants.verticalPadding,
      ),
      textPainter: textPainter,
    );
  }

  static Rect layoutTextNoteRect({
    required Offset anchor,
    required TextPainter textPainter,
    required Rect imageRect,
  }) {
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

  static double distanceToDimensionLabel({
    required DimensionLine line,
    required Offset point,
    required Rect imageRect,
  }) {
    final DimensionLabelLayout? layout = layoutDimensionLabel(
      line: line,
      imageRect: imageRect,
      start: line.startInRect(imageRect),
      end: line.endInRect(imageRect),
    );
    if (layout == null) {
      return double.infinity;
    }
    return distanceToRect(layout.labelRect, point);
  }

  static double distanceToTextNote({
    required TextNoteMarkup note,
    required Offset point,
    required Rect imageRect,
    required MarkupStylePreset preset,
  }) {
    final String text = note.text.trim();
    if (text.isEmpty) {
      return double.infinity;
    }
    final TextNoteLayout layout = layoutTextNote(
      note: note,
      imageRect: imageRect,
      preset: preset,
    );
    return distanceToRect(layout.chipRect, point);
  }

  static bool isDimensionLabelHit({
    required DimensionLine line,
    required Offset point,
    required Rect imageRect,
  }) {
    return distanceToDimensionLabel(
          line: line,
          point: point,
          imageRect: imageRect,
        ) <=
        DimensionLineConstants.labelHitDistance;
  }

  static Offset nearestPointOnRect(Rect rect, Offset point) {
    return Offset(
      point.dx.clamp(rect.left, rect.right),
      point.dy.clamp(rect.top, rect.bottom),
    );
  }

  static double distanceToRect(Rect rect, Offset point) {
    if (rect.contains(point)) {
      return 0;
    }
    final Offset nearest = nearestPointOnRect(rect, point);
    return (point - nearest).distance;
  }

  static Offset normalizedOffsetFromCenter({
    required Offset center,
    required Offset midpoint,
    required Rect imageRect,
  }) {
    if (imageRect.width <= 0 || imageRect.height <= 0) {
      return Offset.zero;
    }
    return Offset(
      (center.dx - midpoint.dx) / imageRect.width,
      (center.dy - midpoint.dy) / imageRect.height,
    );
  }
}
