import 'dart:convert';
import 'dart:io';

import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/integration/models/photo_markup_launch_context.dart';

typedef LaunchContextFileReader = Future<String> Function(String path);
typedef LaunchContextFileExists = bool Function(String path);

class LaunchContextService {
  LaunchContextService({
    LaunchContextFileReader? fileReader,
    LaunchContextFileExists? fileExists,
  }) : _fileReader = fileReader ?? _defaultFileReader,
       _fileExists = fileExists ?? _defaultFileExists;

  final LaunchContextFileReader _fileReader;
  final LaunchContextFileExists _fileExists;

  Future<LaunchContextBootstrap> resolveBootstrap({
    required List<String> args,
    required String? startupImagePathFromEnv,
  }) async {
    final Map<String, String> parsedArgs = _parseKnownArgs(args);
    final String? launchContextPath = _cleanValue(
      parsedArgs[LaunchContextConstants.argLaunchContextPath],
    );

    Map<String, dynamic> jsonContext = <String, dynamic>{};
    String? launchError;
    if (launchContextPath != null) {
      final _ContextLoadResult fileResult = await _loadContextFile(
        launchContextPath,
      );
      jsonContext = fileResult.json;
      launchError = fileResult.errorMessage;
    }

    final Map<String, String?> mergedValues = _mergeKnownValues(
      parsedArgs: parsedArgs,
      jsonContext: jsonContext,
    );
    final PhotoMarkupLaunchContext context = _buildContext(mergedValues);
    final bool hasContextInput = _hasContextInput(mergedValues);

    final String? contextSourcePath = _cleanValue(context.sourceImagePath);
    final _PathValidationResult sourceValidation = _validateSourceImagePath(
      contextSourcePath,
    );
    final String? envStartupPath = _cleanValue(startupImagePathFromEnv);
    final String? initialImagePath =
        sourceValidation.validPath ?? envStartupPath;

    final PhotoMarkupLaunchContext? launchContext = hasContextInput
        ? _contextWithValidatedSource(context, sourceValidation.validPath)
        : null;

    final String? errorMessage = sourceValidation.errorMessage ?? launchError;
    return LaunchContextBootstrap(
      launchContext: launchContext,
      initialImagePath: initialImagePath,
      launchErrorMessage: errorMessage,
    );
  }

  Map<String, String> _parseKnownArgs(List<String> args) {
    final Map<String, String> values = <String, String>{};
    int index = 0;
    while (index < args.length) {
      final String token = args[index];
      if (!token.startsWith(LaunchContextConstants.argPrefix)) {
        index += 1;
        continue;
      }

      String key = token.substring(LaunchContextConstants.argPrefix.length);
      String value = LaunchContextConstants.boolTrueString;
      if (key.contains(LaunchContextConstants.argKeyValueSeparator)) {
        final List<String> split = key.split(
          LaunchContextConstants.argKeyValueSeparator,
        );
        key = split.first;
        value = split
            .sublist(1)
            .join(LaunchContextConstants.argKeyValueSeparator);
      } else if (index + 1 < args.length &&
          !args[index + 1].startsWith(LaunchContextConstants.argPrefix)) {
        value = args[index + 1];
        index += 1;
      }

      if (LaunchContextConstants.supportedArgKeys.contains(key)) {
        values[key] = value;
      }
      index += 1;
    }
    return values;
  }

  Future<_ContextLoadResult> _loadContextFile(String launchContextPath) async {
    if (!_fileExists(launchContextPath)) {
      return const _ContextLoadResult(
        errorMessage: UiCopyConstants.launchContextFileNotFoundMessage,
      );
    }

    try {
      final String raw = await _fileReader(launchContextPath);
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const _ContextLoadResult(
          errorMessage: UiCopyConstants.launchContextInvalidJsonMessage,
        );
      }
      return _ContextLoadResult(json: decoded);
    } catch (_) {
      return const _ContextLoadResult(
        errorMessage: UiCopyConstants.launchContextInvalidJsonMessage,
      );
    }
  }

  Map<String, String?> _mergeKnownValues({
    required Map<String, String> parsedArgs,
    required Map<String, dynamic> jsonContext,
  }) {
    final Map<String, String?> merged = <String, String?>{};
    for (final String key in LaunchContextConstants.contractFieldKeys) {
      final String? argValue = _cleanValue(parsedArgs[key]);
      if (argValue != null) {
        merged[key] = argValue;
        continue;
      }
      final Object? jsonValue = jsonContext[key];
      if (jsonValue == null) {
        merged[key] = null;
      } else if (jsonValue is String) {
        merged[key] = _cleanValue(jsonValue);
      } else if (jsonValue is bool) {
        merged[key] = jsonValue.toString();
      } else if (jsonValue is num) {
        merged[key] = jsonValue.toString();
      } else {
        merged[key] = null;
      }
    }
    return merged;
  }

  PhotoMarkupLaunchContext _buildContext(Map<String, String?> values) {
    final String? providedReturnMode =
        values[LaunchContextConstants.argReturnMode];
    final String? resolvedReturnMode = providedReturnMode == null
        ? null
        : _resolveReturnMode(providedReturnMode);
    return PhotoMarkupLaunchContext(
      launchedFromControlCenter: _parseBool(
        values[LaunchContextConstants.argLaunchedFromControlCenter],
      ),
      clientId: values[LaunchContextConstants.argClientId],
      clientName: values[LaunchContextConstants.argClientName],
      projectId: values[LaunchContextConstants.argProjectId],
      projectCode: values[LaunchContextConstants.argProjectCode],
      sourceImagePath: values[LaunchContextConstants.argSourceImagePath],
      suggestedExportFolder:
          values[LaunchContextConstants.argSuggestedExportFolder],
      suggestedEditableMarkupFolder:
          values[LaunchContextConstants.argSuggestedEditableMarkupFolder],
      returnMode: resolvedReturnMode,
      sourceLabel: values[LaunchContextConstants.argSourceLabel],
    );
  }

  bool _hasContextInput(Map<String, String?> values) {
    for (final String key in LaunchContextConstants.contractFieldKeys) {
      if (values[key] != null) {
        return true;
      }
    }
    return false;
  }

  PhotoMarkupLaunchContext _contextWithValidatedSource(
    PhotoMarkupLaunchContext context,
    String? validSourcePath,
  ) {
    return PhotoMarkupLaunchContext(
      launchedFromControlCenter: context.launchedFromControlCenter,
      clientId: context.clientId,
      clientName: context.clientName,
      projectId: context.projectId,
      projectCode: context.projectCode,
      sourceImagePath: validSourcePath,
      suggestedExportFolder: context.suggestedExportFolder,
      suggestedEditableMarkupFolder: context.suggestedEditableMarkupFolder,
      returnMode: context.returnMode,
      sourceLabel: context.sourceLabel,
    );
  }

  _PathValidationResult _validateSourceImagePath(String? sourcePath) {
    if (sourcePath == null) {
      return const _PathValidationResult(validPath: null, errorMessage: null);
    }
    final String extension = _fileExtension(sourcePath);
    if (!ImageImportConstants.supportedExtensionsSet.contains(extension)) {
      return const _PathValidationResult(
        validPath: null,
        errorMessage: UiCopyConstants.launchSourceImageInvalidMessage,
      );
    }
    if (!_fileExists(sourcePath)) {
      return const _PathValidationResult(
        validPath: null,
        errorMessage: UiCopyConstants.launchSourceImageInvalidMessage,
      );
    }
    return _PathValidationResult(validPath: sourcePath, errorMessage: null);
  }

  String _resolveReturnMode(String? rawReturnMode) {
    final String fallback = LaunchContextConstants.defaultReturnMode;
    if (rawReturnMode == null) {
      return fallback;
    }
    final String candidate = rawReturnMode.trim().toLowerCase();
    if (!LaunchContextConstants.allowedReturnModes.contains(candidate)) {
      return fallback;
    }
    return candidate;
  }

  bool _parseBool(String? raw) {
    if (raw == null) {
      return false;
    }
    final String normalized = raw.trim().toLowerCase();
    return LaunchContextConstants.trueValues.contains(normalized);
  }

  String _fileExtension(String path) {
    final int dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex >= path.length - 1) {
      return '';
    }
    return path.substring(dotIndex + 1).toLowerCase();
  }

  String? _cleanValue(String? rawValue) {
    if (rawValue == null) {
      return null;
    }
    final String trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static Future<String> _defaultFileReader(String path) {
    return File(path).readAsString();
  }

  static bool _defaultFileExists(String path) {
    return File(path).existsSync();
  }
}

class _ContextLoadResult {
  const _ContextLoadResult({
    this.json = const <String, dynamic>{},
    this.errorMessage,
  });

  final Map<String, dynamic> json;
  final String? errorMessage;
}

class _PathValidationResult {
  const _PathValidationResult({
    required this.validPath,
    required this.errorMessage,
  });

  final String? validPath;
  final String? errorMessage;
}
