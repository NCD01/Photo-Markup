import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/utils/dimension_label_formatter.dart';
import 'package:ncd_photo_markup/features/markup/widgets/dimension_lines_overlay.dart';

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
    this.showStartupSplash = true,
  });

  final String? initialImagePath;
  final OpenFileCallback? openFileOverride;
  final bool showStartupSplash;

  @override
  Widget build(BuildContext context) {
    final Widget shell = PhotoMarkupShellScreen(
      initialImagePath: initialImagePath,
      openFileOverride: openFileOverride,
    );

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppThemeConstants.ncdBlue,
      ),
      home: showStartupSplash ? StartupSplashGate(child: shell) : shell,
    );
  }
}

class StartupSplashGate extends StatefulWidget {
  const StartupSplashGate({super.key, required this.child});

  final Widget child;

  @override
  State<StartupSplashGate> createState() => _StartupSplashGateState();
}

class _StartupSplashGateState extends State<StartupSplashGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(
      const Duration(
        milliseconds: BrandingAssetConstants.startupSplashDurationMs,
      ),
      () {
        if (!mounted) {
          return;
        }
        setState(() {
          _showSplash = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSplash) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiLayoutConstants.splashImageHorizontalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width:
                        constraints.maxWidth *
                        UiLayoutConstants.splashImageWidthFactor,
                    height:
                        constraints.maxHeight *
                        UiLayoutConstants.splashImageHeightFactor,
                    child: Image.asset(
                      BrandingAssetConstants.splashV15AssetPath,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) {
                            return const Icon(
                              Icons.photo_camera_outlined,
                              size: UiLayoutConstants.emptyStateIconSize,
                              color: AppThemeConstants.ncdBlue,
                            );
                          },
                    ),
                  ),
                  const SizedBox(height: UiLayoutConstants.splashTitleTopGap),
                  const Text(
                    UiCopyConstants.splashFallbackLabel,
                    style: TextStyle(
                      fontSize: UiLayoutConstants.emptyStateBodyFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppThemeConstants.ncdBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
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
  Size? _loadedImagePixelSize;

  MarkupTool _selectedTool = MarkupTool.none;
  final List<DimensionLine> _dimensionLines = <DimensionLine>[];
  Offset? _activeDimensionStart;
  Offset? _activeDimensionCurrent;

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

    final Size? imageSize = await _readImagePixelSize(path);
    if (imageSize == null) {
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
      _loadedImagePixelSize = imageSize;
      _errorMessage = null;
      _activeDimensionStart = null;
      _activeDimensionCurrent = null;
      _dimensionLines.clear();
    });
  }

  Future<Size?> _readImagePixelSize(String imagePath) async {
    try {
      final Uint8List bytes = await File(imagePath).readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final Size size = Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
      frame.image.dispose();
      codec.dispose();
      return size;
    } catch (_) {
      return null;
    }
  }

  void _setLoadError() {
    setState(() {
      _errorMessage = ImageImportConstants.openErrorMessage;
      _isPickingFile = false;
    });
  }

  void _onToolbarPressed(String label) {
    if (label == ToolbarConstants.openPhoto) {
      _openPhoto();
      return;
    }

    if (label == ToolbarConstants.dimension) {
      setState(() {
        _selectedTool = MarkupTool.dimension;
      });
      return;
    }

    if (label == ToolbarConstants.undo) {
      _undoMostRecentDimensionLine();
      return;
    }
  }

  void _undoMostRecentDimensionLine() {
    if (_dimensionLines.isEmpty) {
      return;
    }
    setState(() {
      _dimensionLines.removeLast();
    });
  }

  void _onDimensionStart(Offset startPoint, Rect imageRect) {
    if (!_canDrawDimensionLine(imageRect) || !imageRect.contains(startPoint)) {
      return;
    }
    final Offset clamped = DimensionLine.clampToRect(startPoint, imageRect);
    setState(() {
      _activeDimensionStart = clamped;
      _activeDimensionCurrent = clamped;
    });
  }

  void _onDimensionUpdate(Offset currentPoint, Rect imageRect) {
    if (_activeDimensionStart == null || !_canDrawDimensionLine(imageRect)) {
      return;
    }
    setState(() {
      _activeDimensionCurrent = DimensionLine.clampToRect(
        currentPoint,
        imageRect,
      );
    });
  }

  Future<void> _onDimensionEnd(Rect imageRect) async {
    final Offset? start = _activeDimensionStart;
    final Offset? end = _activeDimensionCurrent;
    if (start == null || end == null) {
      return;
    }

    final DimensionLine line = DimensionLine.fromCanvasPoints(
      startPoint: start,
      endPoint: end,
      imageRect: imageRect,
    );

    int? newLineIndex;
    setState(() {
      _activeDimensionStart = null;
      _activeDimensionCurrent = null;
      if (line.lengthInRect(imageRect) >=
          UiLayoutConstants.dimensionTapDragMinDistance) {
        _dimensionLines.add(line);
        newLineIndex = _dimensionLines.length - 1;
      }
    });

    if (!mounted || newLineIndex == null) {
      return;
    }
    await _promptForDimensionLabelForLine(newLineIndex!);
  }

  Future<void> _promptForDimensionLabelForLine(int lineIndex) async {
    if (lineIndex < 0 || lineIndex >= _dimensionLines.length) {
      return;
    }

    final String existingLabel = _dimensionLines[lineIndex].label ?? '';
    final String? updatedLabel = await _showDimensionLabelDialog(
      initialValue: existingLabel,
    );

    if (!mounted || updatedLabel == null) {
      return;
    }

    final String normalized = DimensionLabelFormatter.format(updatedLabel);
    setState(() {
      _dimensionLines[lineIndex] = normalized.isEmpty
          ? _dimensionLines[lineIndex].copyWith(clearLabel: true)
          : _dimensionLines[lineIndex].copyWith(label: normalized);
    });
  }

  Future<String?> _showDimensionLabelDialog({
    required String initialValue,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _DimensionLabelDialog(initialValue: initialValue);
      },
    );
  }

  Future<void> _onDimensionTap(Offset point, Rect imageRect) async {
    if (!_canDrawDimensionLine(imageRect) || _dimensionLines.isEmpty) {
      return;
    }

    final int lineIndex = _findNearestLineIndex(point, imageRect);
    if (lineIndex == -1) {
      return;
    }

    await _promptForDimensionLabelForLine(lineIndex);
  }

  int _findNearestLineIndex(Offset point, Rect imageRect) {
    int bestIndex = -1;
    double bestDistance = double.infinity;

    for (int i = 0; i < _dimensionLines.length; i++) {
      final double distance = _dimensionLines[i].distanceToPointInRect(
        point,
        imageRect,
      );
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }

    if (bestDistance > DimensionLineConstants.labelTapSelectDistance) {
      return -1;
    }

    return bestIndex;
  }

  bool _canDrawDimensionLine(Rect imageRect) {
    return _selectedTool == MarkupTool.dimension &&
        _imagePath != null &&
        imageRect.width > 0 &&
        imageRect.height > 0;
  }

  bool _isUndoEnabled() {
    return _dimensionLines.isNotEmpty;
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

  Rect _computeDisplayedImageRect(Size canvasSize) {
    final Size? sourceSize = _loadedImagePixelSize;
    if (sourceSize == null || sourceSize.width <= 0 || sourceSize.height <= 0) {
      return Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height);
    }

    final FittedSizes fitted = applyBoxFit(
      BoxFit.contain,
      sourceSize,
      canvasSize,
    );
    final Size destination = fitted.destination;
    final double left = (canvasSize.width - destination.width) / 2;
    final double top = (canvasSize.height - destination.height) / 2;
    return Rect.fromLTWH(left, top, destination.width, destination.height);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppThemeConstants.ncdBlue,
        foregroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(
            UiLayoutConstants.appBarBrandingIconPadding,
          ),
          child: Image.asset(
            BrandingAssetConstants.iconV15AssetPath,
            fit: BoxFit.contain,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
                  return const Icon(Icons.photo_camera_outlined);
                },
          ),
        ),
        title: const Text(AppConstants.appName),
        actions: [
          if (_loadedFileName != null)
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: UiLayoutConstants.loadedNameMaxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
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
                      child: _ToolbarActionButton(
                        label: label,
                        isSelected:
                            label == ToolbarConstants.dimension &&
                            _selectedTool == MarkupTool.dimension,
                        isDisabled:
                            label == ToolbarConstants.undo && !_isUndoEnabled(),
                        onPressed: () => _onToolbarPressed(label),
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
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final Size canvasSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                final Rect imageRect = _computeDisplayedImageRect(canvasSize);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Image.file(
                        File(_imagePath!),
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, Object error, StackTrace? stackTrace) {
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
                    DimensionLinesOverlay(
                      lines: _dimensionLines,
                      imageRect: imageRect,
                      activeStart: _activeDimensionStart,
                      activeEnd: _activeDimensionCurrent,
                      isEnabled: _canDrawDimensionLine(imageRect),
                      onStart: (Offset point) =>
                          _onDimensionStart(point, imageRect),
                      onUpdate: (Offset point) =>
                          _onDimensionUpdate(point, imageRect),
                      onEnd: () => _onDimensionEnd(imageRect),
                      onTap: (Offset point) =>
                          _onDimensionTap(point, imageRect),
                    ),
                  ],
                );
              },
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

class _ToolbarActionButton extends StatelessWidget {
  const _ToolbarActionButton({
    required this.label,
    required this.onPressed,
    required this.isSelected,
    required this.isDisabled,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isSelected;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor = isDisabled ? Colors.black38 : Colors.black87;
    final Color borderColor = isSelected
        ? AppThemeConstants.ncdBlue
        : AppThemeConstants.ncdBlue.withValues(alpha: 0.75);
    final double borderWidth = isSelected
        ? UiLayoutConstants.toolbarButtonSelectedBorderWidth
        : 1;

    return SizedBox(
      height: UiLayoutConstants.toolbarButtonHeight,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            UiLayoutConstants.toolbarButtonMinWidth,
            UiLayoutConstants.toolbarButtonHeight,
          ),
          side: BorderSide(color: borderColor, width: borderWidth),
          backgroundColor: isSelected
              ? AppThemeConstants.ncdBlue.withValues(alpha: 0.12)
              : Colors.white,
          foregroundColor: foregroundColor,
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

class _DimensionLabelDialog extends StatefulWidget {
  const _DimensionLabelDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_DimensionLabelDialog> createState() => _DimensionLabelDialogState();
}

class _DimensionLabelDialogState extends State<_DimensionLabelDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitLabel() {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(UiCopyConstants.dimensionLabelDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitLabel(),
              style: const TextStyle(
                fontSize: UiLayoutConstants.dimensionLabelFontSize,
              ),
              decoration: const InputDecoration(
                hintText: UiCopyConstants.dimensionLabelHint,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(
                  UiLayoutConstants.dimensionLabelDialogFieldPadding,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: UiLayoutConstants.dimensionLabelDialogButtonTopGap,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text(UiCopyConstants.dimensionLabelSkipButton),
        ),
        FilledButton(
          onPressed: _submitLabel,
          child: const Text(UiCopyConstants.dimensionLabelSaveButton),
        ),
      ],
    );
  }
}
