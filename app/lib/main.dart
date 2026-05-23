import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';

typedef OpenFileCallback = Future<XFile?> Function();

void main() {
  const String startupImagePath = String.fromEnvironment(
    AppConstants.startupImageEnvKey,
  );
  runApp(NcdPhotoMarkupApp(initialImagePath: startupImagePath));
}

class NcdPhotoMarkupApp extends StatelessWidget {
  const NcdPhotoMarkupApp({
    super.key,
    this.initialImagePath,
    this.openFileOverride,
  });

  final String? initialImagePath;
  final OpenFileCallback? openFileOverride;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppThemeConstants.ncdBlue,
      ),
      home: PhotoMarkupShellScreen(
        initialImagePath: initialImagePath,
        openFileOverride: openFileOverride,
      ),
    );
  }
}

class PhotoMarkupShellScreen extends StatefulWidget {
  const PhotoMarkupShellScreen({
    super.key,
    this.initialImagePath,
    this.openFileOverride,
  });

  final String? initialImagePath;
  final OpenFileCallback? openFileOverride;

  @override
  State<PhotoMarkupShellScreen> createState() => _PhotoMarkupShellScreenState();
}

class _PhotoMarkupShellScreenState extends State<PhotoMarkupShellScreen> {
  String? _imagePath;
  String? _loadedFileName;
  String? _errorMessage;
  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();
    final String? initialPath = widget.initialImagePath;
    if (initialPath != null && initialPath.isNotEmpty) {
      _loadImageFromPath(initialPath, showErrorForFailure: false);
    }
  }

  Future<void> _openPhoto() async {
    if (_isPickingFile) {
      return;
    }

    setState(() {
      _isPickingFile = true;
      _errorMessage = null;
    });

    try {
      final XFile? selectedFile = widget.openFileOverride != null
          ? await widget.openFileOverride!.call()
          : await openFile(
              acceptedTypeGroups: const <XTypeGroup>[
                ImageImportConstants.imageTypeGroup,
              ],
              confirmButtonText: ImageImportConstants.pickerConfirmButtonText,
            );

      if (!mounted) {
        return;
      }

      if (selectedFile == null) {
        setState(() {
          _isPickingFile = false;
        });
        return;
      }

      await _loadImageFromPath(selectedFile.path);
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _setLoadError();
    }
  }

  void _setLoadError() {
    setState(() {
      _errorMessage = ImageImportConstants.openErrorMessage;
      _isPickingFile = false;
    });
  }

  String _fileExtension(String path) {
    final List<String> parts = path.split('.');
    if (parts.length < 2) {
      return '';
    }
    return parts.last.toLowerCase();
  }

  String _fileNameFromPath(String path) {
    final String normalized = path.replaceAll('\\', '/');
    final List<String> parts = normalized.split('/');
    return parts.isEmpty ? path : parts.last;
  }

  Future<void> _loadImageFromPath(
    String path, {
    bool showErrorForFailure = true,
  }) async {
    final String extension = _fileExtension(path);
    if (!ImageImportConstants.supportedExtensionsSet.contains(extension)) {
      if (showErrorForFailure) {
        _setLoadError();
      }
      return;
    }

    final File imageFile = File(path);
    if (!await imageFile.exists()) {
      if (showErrorForFailure) {
        _setLoadError();
      }
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _imagePath = path;
      _loadedFileName = _fileNameFromPath(path);
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppThemeConstants.ncdBlue,
        foregroundColor: Colors.white,
        title: const Text(AppConstants.appName),
        actions: [
          if (_loadedFileName != null)
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: UiLayoutConstants.loadedNameMaxWidth,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  right: UiLayoutConstants.appBarLoadedNameRightPadding,
                ),
                child: Center(
                  child: Text(
                    _loadedFileName!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: UiLayoutConstants.loadedNameFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.only(
              right: UiLayoutConstants.appBarVersionRightPadding,
            ),
            child: Center(
              child: Text(
                AppConstants.appVersion,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(
                UiLayoutConstants.canvasOuterPadding,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    UiLayoutConstants.canvasBorderRadius,
                  ),
                  border: Border.all(
                    color: AppThemeConstants.ncdBlue,
                    width: UiLayoutConstants.canvasBorderWidth,
                  ),
                ),
                child: _buildCanvasContent(),
              ),
            ),
          ),
          Container(
            color: AppThemeConstants.toolbarBackground,
            padding: const EdgeInsets.symmetric(
              horizontal: UiLayoutConstants.toolbarHorizontalPadding,
              vertical: UiLayoutConstants.toolbarVerticalPadding,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final String label in ToolbarConstants.labels)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: UiLayoutConstants.toolbarButtonGap,
                      ),
                      child: _ToolbarPlaceholderButton(
                        label: label,
                        onPressed: label == ToolbarConstants.openPhoto
                            ? _openPhoto
                            : () {},
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasContent() {
    if (_imagePath == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UiLayoutConstants.emptyStateHorizontalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.photo_size_select_actual_outlined,
                size: UiLayoutConstants.emptyStateIconSize,
                color: AppThemeConstants.ncdBlue,
              ),
              const SizedBox(height: UiLayoutConstants.emptyStateIconBottomGap),
              const Text(
                UiCopyConstants.emptyStateTitle,
                style: TextStyle(
                  fontSize: UiLayoutConstants.emptyStateTitleFontSize,
                  fontWeight: FontWeight.w700,
                  color: AppThemeConstants.ncdBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: UiLayoutConstants.emptyStateTitleBottomGap,
              ),
              const Text(
                UiCopyConstants.emptyStateMessage,
                style: TextStyle(
                  fontSize: UiLayoutConstants.emptyStateBodyFontSize,
                ),
                textAlign: TextAlign.center,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: UiLayoutConstants.messageTopGap),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: UiLayoutConstants.messageFontSize,
                    color: AppThemeConstants.errorAccent,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (_isPickingFile) ...[
                const SizedBox(height: UiLayoutConstants.messageTopGap),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(UiLayoutConstants.imageAreaPadding),
            child: Center(
              child: Image.file(
                File(_imagePath!),
                fit: BoxFit.contain,
                errorBuilder: (_, Object error, StackTrace? stackTrace) {
                  return const Text(
                    ImageImportConstants.openErrorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppThemeConstants.errorAccent,
                      fontSize: UiLayoutConstants.messageFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: UiLayoutConstants.footerHorizontalPadding,
            vertical: UiLayoutConstants.footerVerticalPadding,
          ),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppThemeConstants.canvasFooterBorder),
            ),
          ),
          child: Text(
            '${ImageImportConstants.loadedPhotoPrefix}${_loadedFileName ?? ImageImportConstants.unknownLoadedPhotoName}',
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ToolbarPlaceholderButton extends StatelessWidget {
  const _ToolbarPlaceholderButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: UiLayoutConstants.toolbarButtonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            UiLayoutConstants.toolbarButtonMinWidth,
            UiLayoutConstants.toolbarButtonHeight,
          ),
          side: const BorderSide(color: AppThemeConstants.ncdBlue),
          foregroundColor: Colors.black87,
          textStyle: const TextStyle(
            fontSize: UiLayoutConstants.toolbarButtonFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
