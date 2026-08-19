import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/features/markup/models/blur_markup.dart';

/// Blurs the photo underneath, inside the given regions.
///
/// This sits between the photo and the annotation overlay, so a blur hides
/// part of the photo but never smears the markup drawn on top of it. The
/// exporter reproduces the same regions with the same maths at full
/// resolution.
class BlurRegionsLayer extends StatelessWidget {
  const BlurRegionsLayer({
    super.key,
    required this.blurs,
    required this.imageRect,
  });

  final List<BlurMarkup> blurs;
  final Rect imageRect;

  @override
  Widget build(BuildContext context) {
    if (blurs.isEmpty || imageRect.width <= 0 || imageRect.height <= 0) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          for (final BlurMarkup blur in blurs) _buildRegion(blur),
        ],
      ),
    );
  }

  Widget _buildRegion(BlurMarkup blur) {
    final Rect rect = blur.rectInRect(imageRect).intersect(imageRect);
    if (rect.isEmpty) {
      return const SizedBox.shrink();
    }
    final double sigma = blur.sigmaForRect(rect, 1.0);
    return Positioned.fromRect(
      rect: rect,
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
