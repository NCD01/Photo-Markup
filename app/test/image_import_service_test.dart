import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
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
