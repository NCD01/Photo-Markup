import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/import/services/dwg_preview_conversion_service.dart';
import 'package:ncd_photo_markup/features/import/services/image_import_service.dart';

void main() {
  group('ImageImportService', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'ncd_photo_markup_import_test_',
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('passes through non-HEIC images unchanged', () async {
      final File jpgFile = File('${tempDir.path}/sample.jpg');
      await jpgFile.writeAsBytes(<int>[1, 2, 3]);

      final ImageImportService service = ImageImportService(
        tempDirectoryPath: tempDir.path,
      );
      final ImageImportResult result = await service.prepareDisplayableImage(
        sourcePath: jpgFile.path,
      );

      expect(result.sourcePath, jpgFile.path);
      expect(result.displayPath, jpgFile.path);
      expect(result.usedTemporaryConvertedCopy, isFalse);
    });

    test('extracts cached preview for DWG source files', () async {
      final File dwgFile = File('${tempDir.path}/drawing1.dwg');
      await dwgFile.writeAsBytes(
        _buildFakeDwgWithPngPreview(_buildUsablePngPreviewBytes()),
      );

      final ImageImportService service = ImageImportService(
        tempDirectoryPath: tempDir.path,
      );

      final ImageImportResult result = await service.prepareDisplayableImage(
        sourcePath: dwgFile.path,
      );

      expect(result.sourcePath, dwgFile.path);
      expect(result.usedTemporaryConvertedCopy, isTrue);
      expect(result.displayPath, isNot(dwgFile.path));
      expect(result.displayPath.endsWith('.png'), isTrue);
      expect(await File(result.displayPath).exists(), isTrue);
    });

    test('rejects low-quality DWG embedded previews with friendly error', () async {
      final File dwgFile = File('${tempDir.path}/drawing1.dwg');
      await dwgFile.writeAsBytes(
        _buildFakeDwgWithPngPreview(_buildLowQualityPngPreviewBytes()),
      );

      final ImageImportService service = ImageImportService(
        tempDirectoryPath: tempDir.path,
      );

      expect(
        () => service.prepareDisplayableImage(sourcePath: dwgFile.path),
        throwsA(
          isA<ImageImportFailure>().having(
            (ImageImportFailure error) => error.message,
            'message',
            ImageImportConstants.dwgPreviewUnavailableMessage,
          ),
        ),
      );
    });

    test('reports friendly error for DWG source files with no preview', () async {
      final File dwgFile = File('${tempDir.path}/drawing1.dwg');
      await dwgFile.writeAsBytes(<int>[1, 2, 3, 4]);

      final ImageImportService service = ImageImportService(
        tempDirectoryPath: tempDir.path,
      );

      expect(
        () => service.prepareDisplayableImage(sourcePath: dwgFile.path),
        throwsA(
          isA<ImageImportFailure>().having(
            (ImageImportFailure error) => error.message,
            'message',
            ImageImportConstants.dwgPreviewUnavailableMessage,
          ),
        ),
      );
    });

    test('converts HEIC to temporary working copy', () async {
      final File heicFile = File('${tempDir.path}/sample.heic');
      await heicFile.writeAsBytes(<int>[10, 20, 30, 40]);

      final Uint8List fakePreviewBytes = Uint8List.fromList(<int>[
        255,
        216,
        255,
        224,
        0,
        16,
        74,
        70,
        73,
        70,
      ]);

      final ImageImportService service = ImageImportService(
        tempDirectoryPath: tempDir.path,
        heicFileConverter:
            ({
              required String sourcePath,
              required String outputPath,
              required int maxPreviewDimension,
            }) async {
              expect(sourcePath, heicFile.path);
              expect(maxPreviewDimension, greaterThan(0));
              final File outputFile = File(outputPath);
              await outputFile.parent.create(recursive: true);
              await outputFile.writeAsBytes(fakePreviewBytes, flush: true);
              return true;
        },
      );

      final ImageImportResult result = await service.prepareDisplayableImage(
        sourcePath: heicFile.path,
      );

      expect(result.sourcePath, heicFile.path);
      expect(result.usedTemporaryConvertedCopy, isTrue);
      expect(result.displayPath, isNot(heicFile.path));
      expect(
        result.displayPath.endsWith(
          '.${ImageImportConstants.heicConvertedOutputExtension}',
        ),
        isTrue,
      );

      final File convertedFile = File(result.displayPath);
      expect(await convertedFile.exists(), isTrue);
      expect(await convertedFile.readAsBytes(), fakePreviewBytes);
      expect(await heicFile.readAsBytes(), <int>[10, 20, 30, 40]);
    });

    test(
      'falls back to external converter when package converter fails',
      () async {
        final File heicFile = File('${tempDir.path}/sample.heic');
        await heicFile.writeAsBytes(<int>[10, 20, 30, 40]);

        final Uint8List externalPreviewBytes = Uint8List.fromList(<int>[
          255,
          216,
          255,
          224,
          0,
          16,
          74,
          70,
          73,
          70,
        ]);

        final ImageImportService service = ImageImportService(
          tempDirectoryPath: tempDir.path,
          heicFileConverter:
              ({
                required String sourcePath,
                required String outputPath,
                required int maxPreviewDimension,
              }) async {
                expect(sourcePath, heicFile.path);
                return false;
          },
          externalHeicConverter:
              ({required String sourcePath, required String outputPath}) async {
                expect(sourcePath, heicFile.path);
                final File outputFile = File(outputPath);
                await outputFile.parent.create(recursive: true);
                await outputFile.writeAsBytes(externalPreviewBytes, flush: true);
                return true;
              },
        );

        final ImageImportResult result = await service.prepareDisplayableImage(
          sourcePath: heicFile.path,
        );

        expect(result.usedTemporaryConvertedCopy, isTrue);
        final File convertedFile = File(result.displayPath);
        expect(await convertedFile.exists(), isTrue);
        expect(await convertedFile.readAsBytes(), externalPreviewBytes);
      },
    );

    test('reuses cached HEIC preview for repeated open', () async {
      final File heicFile = File('${tempDir.path}/sample.heic');
      await heicFile.writeAsBytes(<int>[10, 20, 30, 40]);

      int conversionCallCount = 0;
      final ImageImportService service = ImageImportService(
        tempDirectoryPath: tempDir.path,
        heicFileConverter:
            ( {
              required String sourcePath,
              required String outputPath,
              required int maxPreviewDimension,
            }) async {
              conversionCallCount += 1;
              final File outputFile = File(outputPath);
              await outputFile.parent.create(recursive: true);
              await outputFile.writeAsBytes(
                Uint8List.fromList(<int>[conversionCallCount]),
                flush: true,
              );
              return true;
            },
      );

      final ImageImportResult firstResult = await service.prepareDisplayableImage(
        sourcePath: heicFile.path,
      );
      final ImageImportResult secondResult = await service.prepareDisplayableImage(
        sourcePath: heicFile.path,
      );

      expect(firstResult.displayPath, secondResult.displayPath);
      expect(conversionCallCount, 1);
      expect(
        firstResult.displayPath.contains(
          ImageImportConstants.heicPreviewCacheFolderName,
        ),
        isTrue,
      );
    });

    test('invalidates cached preview when source file changes', () async {
      final File heicFile = File('${tempDir.path}/sample.heic');
      await heicFile.writeAsBytes(<int>[10, 20, 30, 40]);

      int conversionCallCount = 0;
      final ImageImportService service = ImageImportService(
        tempDirectoryPath: tempDir.path,
        heicFileConverter:
            ( {
              required String sourcePath,
              required String outputPath,
              required int maxPreviewDimension,
            }) async {
              conversionCallCount += 1;
              final File outputFile = File(outputPath);
              await outputFile.parent.create(recursive: true);
              await outputFile.writeAsBytes(
                Uint8List.fromList(<int>[conversionCallCount]),
                flush: true,
              );
              return true;
            },
      );

      final ImageImportResult firstResult = await service.prepareDisplayableImage(
        sourcePath: heicFile.path,
      );
      await heicFile.writeAsBytes(<int>[10, 20, 30, 40, 50], flush: true);
      final ImageImportResult secondResult = await service.prepareDisplayableImage(
        sourcePath: heicFile.path,
      );

      expect(firstResult.displayPath, isNot(secondResult.displayPath));
      expect(conversionCallCount, 2);
    });

    test('deletes temporary converted file when asked', () async {
      final File convertedFile = File('${tempDir.path}/temp_file.png');
      await convertedFile.writeAsBytes(<int>[1, 2, 3]);

      final ImageImportService service = ImageImportService(
        tempDirectoryPath: tempDir.path,
      );
      await service.deleteTemporaryDisplayPath(convertedFile.path);

      expect(await convertedFile.exists(), isFalse);
    });
  });
}

Uint8List _buildFakeDwgWithPngPreview(Uint8List pngBytes) {
  final BytesBuilder builder = BytesBuilder(copy: false);
  builder.add(Uint8List.fromList(List<int>.filled(567, 0)));
  builder.add(pngBytes);
  builder.add(Uint8List.fromList(List<int>.filled(64, 0)));
  return builder.toBytes();
}

Uint8List _buildLowQualityPngPreviewBytes() {
  return base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAQAAAACOCAAAAAD71ImmAAAAIGNIUk0AAHomAACAhAAA+gAAAIDoAAB1MAAA6mAAADqYAAAXcJy6UTwAAAACYktHRAD/h4/MvwAAAAd0SU1FB+oGEgMbKJCeJckAAAAldEVYdGRhdGU6Y3JlYXRlADIwMjYtMDYtMThUMDM6Mjc6NDArMDA6MDCUNKPhAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDI2LTA2LTE4VDAzOjI3OjQwKzAwOjAw5WkbXQAAACh0RVh0ZGF0ZTp0aW1lc3RhbXAAMjAyNi0wNi0xOFQwMzoyNzo0MCswMDowMLJ8OoIAAAFASURBVHja7dwhDoBQDMBQPgHuf14UCo8geWKtmphomumtc5vNrgU0BdACmgJoAU0BtICmAFpAUwAtoCmAFtAUQAtoCqAFNAXQApoCaAFNAbSApgBaQFMALaApgBbQFEALaAqgBTQF0AKaAmgBTQG0gKYAWkBTAC2gKYAW0BRAC2gKoAU0BdACmkML/M/9Zel6h/EXUAAtoCmAFtAUQAtoCqAFNAXQApoCaAFNAbSApgBaQFMALaApgBbQFEALaAqgBTQF0AKaAmgBTQG0gKYAWkBTAC2gGR9g9Vh5OAXQApoCaAFNAbSApgBaQFMALaApgBbQFEALaAqgBTQF0AKaAmgBTQG0gKYAWkBTAC2gKYAW0BRAC2gKoAU0BdACmgJoAU0BtICmAFpAUwAtoCmAFtAUQAtoCqAFNAXQAprxAR6D2wInNgXPqgAAAABJRU5ErkJggg==',
  );
}

Uint8List _buildUsablePngPreviewBytes() {
  return base64Decode(
    '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',
  );
}
