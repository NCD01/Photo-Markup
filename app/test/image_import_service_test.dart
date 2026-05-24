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

    test('converts HEIC to temporary PNG working copy', () async {
      final File heicFile = File('${tempDir.path}/sample.heic');
      await heicFile.writeAsBytes(<int>[10, 20, 30, 40]);

      final Uint8List fakePngBytes = Uint8List.fromList(<int>[
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
        1,
        2,
        3,
      ]);

      final ImageImportService service = ImageImportService(
        tempDirectoryPath: tempDir.path,
        heicPngConverter: (Uint8List input) async {
          expect(input, isNotEmpty);
          return fakePngBytes;
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
      expect(await convertedFile.readAsBytes(), fakePngBytes);
      expect(await heicFile.readAsBytes(), <int>[10, 20, 30, 40]);
    });

    test(
      'falls back to external converter when package converter fails',
      () async {
        final File heicFile = File('${tempDir.path}/sample.heic');
        await heicFile.writeAsBytes(<int>[10, 20, 30, 40]);

        final Uint8List externalPngBytes = Uint8List.fromList(<int>[
          137,
          80,
          78,
          71,
          13,
          10,
          26,
          10,
          5,
          4,
          3,
        ]);

        final ImageImportService service = ImageImportService(
          tempDirectoryPath: tempDir.path,
          heicPngConverter: (_) async {
            throw Exception('Package converter failed');
          },
          externalHeicConverter:
              ({required String sourcePath, required String outputPath}) async {
                expect(sourcePath, heicFile.path);
                final File outputFile = File(outputPath);
                await outputFile.parent.create(recursive: true);
                await outputFile.writeAsBytes(externalPngBytes, flush: true);
                return true;
              },
        );

        final ImageImportResult result = await service.prepareDisplayableImage(
          sourcePath: heicFile.path,
        );

        expect(result.usedTemporaryConvertedCopy, isTrue);
        final File convertedFile = File(result.displayPath);
        expect(await convertedFile.exists(), isTrue);
        expect(await convertedFile.readAsBytes(), externalPngBytes);
      },
    );

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
