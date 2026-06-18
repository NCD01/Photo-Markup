import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/export/services/markup_export_path_service.dart';

void main() {
  test('buildDefaultMarkupExportName uses markup suffix and png extension', () {
    const MarkupExportPathService service = MarkupExportPathService();
    final String name = service.buildDefaultMarkupExportName(
      sourcePathOrFileName: 'IMG_2434.jpeg',
    );

    expect(name, 'IMG_2434 - Markup.png');
  });

  test('buildDefaultMarkupExportName keeps basename for HEIC source path', () {
    const MarkupExportPathService service = MarkupExportPathService();
    final String name = service.buildDefaultMarkupExportName(
      sourcePathOrFileName: r'C:\Job Photos\My Area\IMG 3000.HEIC',
    );

    expect(name, 'IMG 3000 - Markup.png');
  });

  test('buildDefaultMarkupExportName keeps DWG basename', () {
    const MarkupExportPathService service = MarkupExportPathService();
    final String name = service.buildDefaultMarkupExportName(
      sourcePathOrFileName: r'C:\Plans\Drawing1.dwg',
    );

    expect(name, 'Drawing1 - Markup.png');
  });

  test('resolveDefaultExportDirectory prioritizes valid suggested folder', () {
    final Set<String> existingDirs = <String>{
      r'C:\Suggested Folder',
      r'C:\Source Folder',
    };
    final MarkupExportPathService service = MarkupExportPathService(
      directoryExists: existingDirs.contains,
    );

    final String? directory = service.resolveDefaultExportDirectory(
      suggestedExportFolder: r'C:\Suggested Folder',
      sourceImagePath: r'C:\Source Folder\IMG_2434.jpeg',
    );

    expect(directory, r'C:\Suggested Folder');
  });

  test(
    'resolveDefaultExportDirectory falls back to source folder for spaced path',
    () {
      final Set<String> existingDirs = <String>{r'C:\Source Folder'};
      final MarkupExportPathService service = MarkupExportPathService(
        directoryExists: existingDirs.contains,
      );

      final String? directory = service.resolveDefaultExportDirectory(
        suggestedExportFolder: r'C:\Missing Folder',
        sourceImagePath: r'C:\Source Folder\IMG 2434.jpeg',
      );

      expect(directory, r'C:\Source Folder');
    },
  );

  test('buildSafeMarkupExportPath appends increment for duplicate output', () {
    final Set<String> existingFiles = <String>{
      r'C:\Exports\IMG_2434 - Markup.png',
      r'C:\Exports\IMG_2434 - Markup 2.png',
    };
    final MarkupExportPathService service = MarkupExportPathService(
      fileExists: existingFiles.contains,
    );

    final String safePath = service.buildSafeMarkupExportPath(
      r'C:\Exports\IMG_2434 - Markup.png',
    );

    expect(safePath, r'C:\Exports\IMG_2434 - Markup 3.png');
  });
}
