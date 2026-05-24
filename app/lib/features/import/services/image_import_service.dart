import 'dart:io';
import 'dart:typed_data';

import 'package:heic_to_png_jpg/heic_to_png_jpg.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';

typedef HeicPngConverter = Future<Uint8List> Function(Uint8List heicData);
typedef ExternalHeicConverter =
    Future<bool> Function({
      required String sourcePath,
      required String outputPath,
    });

class ImageImportResult {
  const ImageImportResult({
    required this.sourcePath,
    required this.displayPath,
    required this.usedTemporaryConvertedCopy,
  });

  final String sourcePath;
  final String displayPath;
  final bool usedTemporaryConvertedCopy;
}

class ImageImportService {
  ImageImportService({
    HeicPngConverter? heicPngConverter,
    ExternalHeicConverter? externalHeicConverter,
    String? tempDirectoryPath,
  }) : _heicPngConverter = heicPngConverter ?? _defaultHeicPngConverter,
       _externalHeicConverter =
           externalHeicConverter ?? _defaultExternalHeicConverter,
       _tempDirectoryPath = tempDirectoryPath ?? Directory.systemTemp.path;

  final HeicPngConverter _heicPngConverter;
  final ExternalHeicConverter _externalHeicConverter;
  final String _tempDirectoryPath;

  Future<ImageImportResult> prepareDisplayableImage({
    required String sourcePath,
  }) async {
    final String extension = _fileExtension(sourcePath);
    if (!ImageImportConstants.heicExtensionsSet.contains(extension)) {
      return ImageImportResult(
        sourcePath: sourcePath,
        displayPath: sourcePath,
        usedTemporaryConvertedCopy: false,
      );
    }

    final String tempPath = _buildTempPath(sourcePath);
    await _convertHeicToDisplayableImage(
      sourcePath: sourcePath,
      outputPath: tempPath,
    );

    return ImageImportResult(
      sourcePath: sourcePath,
      displayPath: tempPath,
      usedTemporaryConvertedCopy: true,
    );
  }

  Future<void> deleteTemporaryDisplayPath(String? displayPath) async {
    if (displayPath == null || displayPath.isEmpty) {
      return;
    }
    try {
      final File file = File(displayPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort temp cleanup only.
    }
  }

  String _buildTempPath(String sourcePath) {
    final String normalized = sourcePath.replaceAll('\\', '/');
    final String rawName = normalized.split('/').last;
    final int dotIndex = rawName.lastIndexOf('.');
    final String baseName = dotIndex > 0
        ? rawName.substring(0, dotIndex)
        : rawName;
    final String safeBaseName = baseName.replaceAll(
      RegExp(r'[^A-Za-z0-9_-]'),
      '_',
    );
    final String timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    return '$_tempDirectoryPath${Platform.pathSeparator}$safeBaseName${ImageImportConstants.heicTempSuffix}_$timestamp.${ImageImportConstants.heicConvertedOutputExtension}';
  }

  String _fileExtension(String path) {
    final int dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex >= path.length - 1) {
      return '';
    }
    return path.substring(dotIndex + 1).toLowerCase();
  }

  static Future<Uint8List> _defaultHeicPngConverter(Uint8List heicData) {
    return HeicConverter.convertToPNG(heicData: heicData);
  }

  Future<void> _convertHeicToDisplayableImage({
    required String sourcePath,
    required String outputPath,
  }) async {
    final File outputFile = File(outputPath);
    await outputFile.parent.create(recursive: true);

    bool packageConversionSucceeded = false;
    try {
      final Uint8List sourceBytes = await File(sourcePath).readAsBytes();
      final Uint8List convertedPngBytes = await _heicPngConverter(sourceBytes);
      if (convertedPngBytes.isNotEmpty) {
        await outputFile.writeAsBytes(convertedPngBytes, flush: true);
        packageConversionSucceeded = true;
      }
    } catch (_) {
      packageConversionSucceeded = false;
    }

    if (!packageConversionSucceeded) {
      final bool externalSucceeded = await _externalHeicConverter(
        sourcePath: sourcePath,
        outputPath: outputPath,
      );
      if (!externalSucceeded) {
        throw const ConversionFailedException(
          ImageImportConstants.heicConversionFailedMessage,
        );
      }
    }

    if (!await outputFile.exists() || await outputFile.length() == 0) {
      throw const ConversionFailedException(
        ImageImportConstants.heicConversionFailedMessage,
      );
    }
  }

  static Future<bool> _defaultExternalHeicConverter({
    required String sourcePath,
    required String outputPath,
  }) async {
    try {
      final List<String> args = <String>[
        sourcePath,
        ...ImageImportConstants.heicFallbackConverterOptions,
        outputPath,
      ];
      final ProcessResult result = await Process.run(
        ImageImportConstants.heicFallbackConverterCommand,
        args,
      );
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
