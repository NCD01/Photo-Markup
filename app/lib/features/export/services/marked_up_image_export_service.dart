import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw StateError('Could not encode export image as PNG.');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(pngBytes, flush: true);

      return MarkedUpImageExportResult(
        path: outputPath,
        pixelWidth: image.width,
        pixelHeight: image.height,
        bytesWritten: pngBytes.length,
      );
    } finally {
      image.dispose();
    }
  }
}
