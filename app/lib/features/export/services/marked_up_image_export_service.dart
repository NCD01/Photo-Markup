import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:ncd_photo_markup/features/export/services/png_metadata_writer.dart';

class MarkedUpImageExportResult {
  const MarkedUpImageExportResult({
    required this.path,
    required this.pixelWidth,
    required this.pixelHeight,
    required this.bytesWritten,
  });

  final String path;
  final int pixelWidth;
  final int pixelHeight;
  final int bytesWritten;
}

class MarkedUpImageExportService {
  const MarkedUpImageExportService._();

  static Future<MarkedUpImageExportResult> exportBoundaryToPng({
    required GlobalKey boundaryKey,
    required String outputPath,
    required double pixelRatio,
    Rect? cropRectLogical,
    Map<String, String> metadata = const <String, String>{},
  }) async {
    await WidgetsBinding.instance.endOfFrame;

    final RenderObject? renderObject = boundaryKey.currentContext
        ?.findRenderObject();
    if (renderObject == null) {
      throw StateError('Export boundary context is not available.');
    }
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError(
        'Export boundary render object is not a repaint boundary.',
      );
    }

    if (renderObject.size.isEmpty) {
      throw StateError('Export boundary size is empty.');
    }

    final ui.Image image = await renderObject.toImage(pixelRatio: pixelRatio);
    try {
      final PixelCropRect pixelCropRect = _computePixelCropRect(
        boundaryLogicalSize: renderObject.size,
        cropRectLogical: cropRectLogical ?? (Offset.zero & renderObject.size),
        pixelRatio: pixelRatio,
        imagePixelWidth: image.width,
        imagePixelHeight: image.height,
      );

      final ui.Image exportImage = await _cropImage(
        image: image,
        pixelCropRect: pixelCropRect,
      );
      try {
        final ByteData? byteData = await exportImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (byteData == null) {
          throw StateError('Could not encode export image as PNG.');
        }

        // Stamped after encoding, by inserting text chunks into the byte
        // stream. The pixels are never decoded or re-encoded, so the exported
        // image is identical whether or not there was metadata to add.
        final Uint8List pngBytes = PngMetadataWriter.withTextFields(
          byteData.buffer.asUint8List(),
          metadata,
        );
        final File outputFile = File(outputPath);
        await outputFile.writeAsBytes(pngBytes, flush: true);

        return MarkedUpImageExportResult(
          path: outputPath,
          pixelWidth: exportImage.width,
          pixelHeight: exportImage.height,
          bytesWritten: pngBytes.length,
        );
      } finally {
        exportImage.dispose();
      }
    } finally {
      image.dispose();
    }
  }

  static PixelCropRect computePixelCropRectForTest({
    required Size boundaryLogicalSize,
    required Rect cropRectLogical,
    required double pixelRatio,
    required int imagePixelWidth,
    required int imagePixelHeight,
  }) {
    return _computePixelCropRect(
      boundaryLogicalSize: boundaryLogicalSize,
      cropRectLogical: cropRectLogical,
      pixelRatio: pixelRatio,
      imagePixelWidth: imagePixelWidth,
      imagePixelHeight: imagePixelHeight,
    );
  }

  static Future<ui.Image> _cropImage({
    required ui.Image image,
    required PixelCropRect pixelCropRect,
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Paint paint = ui.Paint();
    final Rect srcRect = Rect.fromLTWH(
      pixelCropRect.left.toDouble(),
      pixelCropRect.top.toDouble(),
      pixelCropRect.width.toDouble(),
      pixelCropRect.height.toDouble(),
    );
    final Rect dstRect = Rect.fromLTWH(
      0,
      0,
      pixelCropRect.width.toDouble(),
      pixelCropRect.height.toDouble(),
    );
    canvas.drawImageRect(image, srcRect, dstRect, paint);
    final ui.Picture picture = recorder.endRecording();
    try {
      return picture.toImage(pixelCropRect.width, pixelCropRect.height);
    } finally {
      picture.dispose();
    }
  }

  static PixelCropRect _computePixelCropRect({
    required Size boundaryLogicalSize,
    required Rect cropRectLogical,
    required double pixelRatio,
    required int imagePixelWidth,
    required int imagePixelHeight,
  }) {
    final Rect boundaryRect = Offset.zero & boundaryLogicalSize;
    final Rect boundedCropRect = cropRectLogical.intersect(boundaryRect);
    if (boundedCropRect.isEmpty) {
      throw StateError('Export crop area is empty.');
    }

    final int left = _clampInt(
      (boundedCropRect.left * pixelRatio).floor(),
      0,
      imagePixelWidth - 1,
    );
    final int top = _clampInt(
      (boundedCropRect.top * pixelRatio).floor(),
      0,
      imagePixelHeight - 1,
    );
    final int right = _clampInt(
      (boundedCropRect.right * pixelRatio).ceil(),
      left + 1,
      imagePixelWidth,
    );
    final int bottom = _clampInt(
      (boundedCropRect.bottom * pixelRatio).ceil(),
      top + 1,
      imagePixelHeight,
    );

    return PixelCropRect(
      left: left,
      top: top,
      width: right - left,
      height: bottom - top,
    );
  }

  static int _clampInt(int value, int min, int max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }
}

class PixelCropRect {
  const PixelCropRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final int left;
  final int top;
  final int width;
  final int height;
}
