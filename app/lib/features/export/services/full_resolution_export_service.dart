import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:ncd_photo_markup/features/markup/models/blur_markup.dart';
import 'package:ncd_photo_markup/features/markup/rendering/markup_scene_renderer.dart';

class FullResolutionExportResult {
  const FullResolutionExportResult({
    required this.path,
    required this.pixelWidth,
    required this.pixelHeight,
    required this.bytesWritten,
    required this.markupScale,
  });

  final String path;
  final int pixelWidth;
  final int pixelHeight;
  final int bytesWritten;

  /// How much the markup was scaled up from what was on screen.
  final double markupScale;
}

/// Writes the marked-up photo at the photo's own pixel size.
///
/// The old exporter screen-grabbed the canvas widget, so a 6000x4000 site
/// photo came out at whatever the canvas happened to be, often under 1000px
/// wide. This decodes the source file instead, paints it at full size, and runs
/// the same [MarkupSceneRenderer] over it with the annotations scaled up by the
/// same factor. What lands in the file is what was on screen, at the
/// resolution the camera captured.
class FullResolutionExportService {
  const FullResolutionExportService._();

  static Future<FullResolutionExportResult> exportToPng({
    required String sourceImagePath,
    required MarkupScene scene,
    required Rect displayImageRect,
    required String outputPath,
    int quarterTurns = 0,
  }) async {
    final ui.Image sourceImage = await decodeImageFile(sourceImagePath);
    try {
      return await renderToPng(
        sourceImage: sourceImage,
        scene: scene,
        displayImageRect: displayImageRect,
        outputPath: outputPath,
        quarterTurns: quarterTurns,
      );
    } finally {
      sourceImage.dispose();
    }
  }

  static Future<ui.Image> decodeImageFile(String path) async {
    final Uint8List bytes = await File(path).readAsBytes();
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
      bytes,
    );
    final ui.ImageDescriptor descriptor = await ui.ImageDescriptor.encoded(
      buffer,
    );
    final ui.Codec codec = await descriptor.instantiateCodec();
    try {
      final ui.FrameInfo frame = await codec.getNextFrame();
      return frame.image;
    } finally {
      codec.dispose();
      descriptor.dispose();
      buffer.dispose();
    }
  }

  /// The factor that turns on-screen annotation sizes into export sizes.
  ///
  /// Exposed so the geometry can be checked without decoding an image.
  static double markupScaleFor({
    required double exportWidth,
    required double displayWidth,
  }) {
    if (displayWidth <= 0 || exportWidth <= 0) {
      return 1.0;
    }
    return exportWidth / displayWidth;
  }

  /// Bakes each blur region into the exported pixels.
  ///
  /// This runs before the annotations are painted, so a blur hides part of the
  /// photo and never smears the markup on top of it.
  static void _applyRotation(Canvas canvas, int turns, Rect exportRect) {
    switch (turns) {
      case 1:
        canvas.translate(exportRect.width, 0);
        canvas.rotate(math.pi / 2);
        break;
      case 2:
        canvas.translate(exportRect.width, exportRect.height);
        canvas.rotate(math.pi);
        break;
      case 3:
        canvas.translate(0, exportRect.height);
        canvas.rotate(-math.pi / 2);
        break;
      default:
        break;
    }
  }

  static void _paintBlurRegions({
    required Canvas canvas,
    required ui.Image sourceImage,
    required List<BlurMarkup> blurs,
    required Rect exportRect,
    required Rect sourceRect,
    required int turns,
    required double scale,
  }) {
    for (final BlurMarkup blur in blurs) {
      final Rect rect = blur.rectInRect(exportRect).intersect(exportRect);
      if (rect.isEmpty) {
        continue;
      }
      final double sigma = blur.sigmaForRect(rect, scale);
      canvas.save();
      canvas.clipRect(rect);
      _applyRotation(canvas, turns, exportRect);
      canvas.drawImageRect(
        sourceImage,
        sourceRect,
        sourceRect,
        Paint()
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: sigma,
            sigmaY: sigma,
            tileMode: TileMode.decal,
          )
          ..filterQuality = FilterQuality.high,
      );
      canvas.restore();
    }
  }

  static Future<FullResolutionExportResult> renderToPng({
    required ui.Image sourceImage,
    required MarkupScene scene,
    required Rect displayImageRect,
    required String outputPath,
    int quarterTurns = 0,
  }) async {
    final int turns = ((quarterTurns % 4) + 4) % 4;
    final bool swapsAxes = turns.isOdd;
    final int width = swapsAxes ? sourceImage.height : sourceImage.width;
    final int height = swapsAxes ? sourceImage.width : sourceImage.height;
    if (width <= 0 || height <= 0) {
      throw StateError('Source image has no pixels to export.');
    }

    final double markupScale = markupScaleFor(
      exportWidth: width.toDouble(),
      displayWidth: displayImageRect.width,
    );
    final Rect exportRect = Rect.fromLTWH(
      0,
      0,
      width.toDouble(),
      height.toDouble(),
    );

    final Rect sourceRect = Rect.fromLTWH(
      0,
      0,
      sourceImage.width.toDouble(),
      sourceImage.height.toDouble(),
    );
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder, exportRect);

    // Draw the photo in its rotated orientation, then drop back to the
    // upright frame so the markup, whose coordinates were already rotated when
    // the user turned the photo, paints straight onto it.
    canvas.save();
    _applyRotation(canvas, turns, exportRect);
    canvas.drawImageRect(
      sourceImage,
      sourceRect,
      sourceRect,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();

    _paintBlurRegions(
      canvas: canvas,
      sourceImage: sourceImage,
      blurs: scene.blurs,
      exportRect: exportRect,
      sourceRect: sourceRect,
      turns: turns,
      scale: markupScale,
    );
    MarkupSceneRenderer.paint(
      canvas: canvas,
      scene: scene,
      imageRect: exportRect,
      scale: markupScale,
      // Selection handles are an editing aid, never part of the deliverable.
      showSelection: false,
    );

    final ui.Picture picture = recorder.endRecording();
    ui.Image? exported;
    try {
      exported = await picture.toImage(width, height);
      final ByteData? encoded = await exported.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (encoded == null) {
        throw StateError('Could not encode the export as PNG.');
      }
      final Uint8List pngBytes = encoded.buffer.asUint8List();
      final File outputFile = File(outputPath);
      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsBytes(pngBytes, flush: true);

      return FullResolutionExportResult(
        path: outputPath,
        pixelWidth: width,
        pixelHeight: height,
        bytesWritten: pngBytes.length,
        markupScale: markupScale,
      );
    } finally {
      exported?.dispose();
      picture.dispose();
    }
  }
}
