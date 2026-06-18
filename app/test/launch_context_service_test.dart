import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/integration/services/launch_context_service.dart';

void main() {
  test(
    'resolveBootstrap keeps standalone behavior when no context args',
    () async {
      final LaunchContextService service = LaunchContextService();

      final bootstrap = await service.resolveBootstrap(
        args: const <String>[],
        startupImagePathFromEnv: r'C:\tmp\startup.jpg',
      );

      expect(bootstrap.launchContext, isNull);
      expect(bootstrap.initialImagePath, r'C:\tmp\startup.jpg');
      expect(bootstrap.launchErrorMessage, isNull);
    },
  );

  test(
    'resolveBootstrap parses valid direct launch context and image path',
    () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'launch_context_test_',
      );
      addTearDown(() => tempDir.delete(recursive: true));
      final File sourceFile = File('${tempDir.path}\\source image.jpg');
      await sourceFile.writeAsString('placeholder');

      final LaunchContextService service = LaunchContextService();
      final bootstrap = await service.resolveBootstrap(
        args: <String>[
          '--${LaunchContextConstants.argLaunchedFromControlCenter}',
          'true',
          '--${LaunchContextConstants.argClientName}',
          'Acme Client',
          '--${LaunchContextConstants.argProjectCode}',
          'P-100',
          '--${LaunchContextConstants.argSourceImagePath}',
          sourceFile.path,
        ],
        startupImagePathFromEnv: null,
      );

      expect(bootstrap.launchContext, isNotNull);
      expect(bootstrap.launchContext!.launchedFromControlCenter, isTrue);
      expect(bootstrap.launchContext!.clientName, 'Acme Client');
      expect(bootstrap.launchContext!.projectCode, 'P-100');
      expect(bootstrap.initialImagePath, sourceFile.path);
      expect(bootstrap.launchErrorMessage, isNull);
    },
  );

  test('resolveBootstrap accepts valid DWG launch source path', () async {
    final Directory tempDir = await Directory.systemTemp.createTemp(
      'launch_context_dwg_test_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final File sourceFile = File('${tempDir.path}\\drawing1.dwg');
    await sourceFile.writeAsString('placeholder');

    final LaunchContextService service = LaunchContextService();
    final bootstrap = await service.resolveBootstrap(
      args: <String>[
        '--${LaunchContextConstants.argLaunchedFromControlCenter}',
        'true',
        '--${LaunchContextConstants.argSourceImagePath}',
        sourceFile.path,
      ],
      startupImagePathFromEnv: null,
    );

    expect(bootstrap.launchContext, isNotNull);
    expect(bootstrap.launchContext!.sourceImagePath, sourceFile.path);
    expect(bootstrap.initialImagePath, sourceFile.path);
    expect(bootstrap.launchErrorMessage, isNull);
  });

  test('resolveBootstrap ignores unknown args safely', () async {
    final LaunchContextService service = LaunchContextService();
    final bootstrap = await service.resolveBootstrap(
      args: const <String>['--unknownArg', 'value'],
      startupImagePathFromEnv: null,
    );

    expect(bootstrap.launchContext, isNull);
    expect(bootstrap.initialImagePath, isNull);
    expect(bootstrap.launchErrorMessage, isNull);
  });

  test(
    'resolveBootstrap reports friendly error when source path is invalid',
    () async {
      final LaunchContextService service = LaunchContextService();
      final bootstrap = await service.resolveBootstrap(
        args: const <String>[
          '--launchedFromControlCenter',
          'true',
          '--sourceImagePath',
          r'C:\missing\photo.jpg',
        ],
        startupImagePathFromEnv: null,
      );

      expect(bootstrap.launchContext, isNotNull);
      expect(bootstrap.launchContext!.sourceImagePath, isNull);
      expect(
        bootstrap.launchErrorMessage,
        UiCopyConstants.launchSourceImageInvalidMessage,
      );
      expect(bootstrap.initialImagePath, isNull);
    },
  );

  test('resolveBootstrap supports launchContextPath json input', () async {
    final Directory tempDir = await Directory.systemTemp.createTemp(
      'launch_context_json_test_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final File sourceFile = File('${tempDir.path}\\jobsite.heic');
    await sourceFile.writeAsString('placeholder');
    final File launchFile = File('${tempDir.path}\\launch_context.json');
    await launchFile.writeAsString('''
{
  "launchedFromControlCenter": true,
  "clientName": "Client A",
  "projectCode": "PJ-77",
  "sourceImagePath": "${sourceFile.path.replaceAll('\\', '\\\\')}"
}
''');

    final LaunchContextService service = LaunchContextService();
    final bootstrap = await service.resolveBootstrap(
      args: <String>[
        '--${LaunchContextConstants.argLaunchContextPath}',
        launchFile.path,
      ],
      startupImagePathFromEnv: null,
    );

    expect(bootstrap.launchContext, isNotNull);
    expect(bootstrap.launchContext!.clientName, 'Client A');
    expect(bootstrap.launchContext!.projectCode, 'PJ-77');
    expect(bootstrap.initialImagePath, sourceFile.path);
    expect(bootstrap.launchErrorMessage, isNull);
  });

  test('resolveBootstrap handles invalid launch context json safely', () async {
    final LaunchContextService service = LaunchContextService(
      fileExists: (_) => true,
      fileReader: (_) async => '{invalid-json',
    );

    final bootstrap = await service.resolveBootstrap(
      args: const <String>['--launchContextPath', r'C:\tmp\bad.json'],
      startupImagePathFromEnv: null,
    );

    expect(bootstrap.launchContext, isNull);
    expect(
      bootstrap.launchErrorMessage,
      UiCopyConstants.launchContextInvalidJsonMessage,
    );
  });
}
