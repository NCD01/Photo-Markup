import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/export/services/marked_up_image_export_service.dart';
import 'package:ncd_photo_markup/features/import/services/image_import_service.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/markup/utils/dimension_label_formatter.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_move_utils.dart';
import 'package:ncd_photo_markup/features/markup/widgets/dimension_lines_overlay.dart';

typedef OpenFileCallback = Future<XFile?> Function();
typedef SaveLocationCallback =
    Future<FileSaveLocation?> Function({
      String? suggestedName,
      String? confirmButtonText,
      List<XTypeGroup> acceptedTypeGroups,
    });

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
    this.saveLocationOverride,
    this.showStartupSplash = true,
  });

  final String? initialImagePath;
  final OpenFileCallback? openFileOverride;
  final SaveLocationCallback? saveLocationOverride;
  final bool showStartupSplash;

  @override
  Widget build(BuildContext context) {
    final Widget shell = PhotoMarkupShellScreen(
      initialImagePath: initialImagePath,
      openFileOverride: openFileOverride,
      saveLocationOverride: saveLocationOverride,
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
                  const SizedBox(height: UiLayoutConstants.splashVersionTopGap),
                  const Text(
                    AppConstants.appVersion,
                    style: TextStyle(
                      fontSize: UiLayoutConstants.splashVersionFontSize,
                      fontWeight: FontWeight.w600,
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
    this.saveLocationOverride,
  });

  final String? initialImagePath;
  final OpenFileCallback? openFileOverride;
  final SaveLocationCallback? saveLocationOverride;

  @override
  State<PhotoMarkupShellScreen> createState() => _PhotoMarkupShellScreenState();
}

class _PhotoMarkupShellScreenState extends State<PhotoMarkupShellScreen> {
  final ImageImportService _imageImportService = ImageImportService();
  String? _imagePath;
  String? _temporaryConvertedImagePath;
  String? _loadedFileName;
  String? _errorMessage;
  bool _isPickingFile = false;
  bool _isExporting = false;
  Size? _loadedImagePixelSize;
  final GlobalKey _canvasExportKey = GlobalKey();

  MarkupTool _selectedTool = MarkupTool.none;
  final List<DimensionLine> _dimensionLines = <DimensionLine>[];
  final List<ArrowMarkup> _arrows = <ArrowMarkup>[];
  final List<RectangleMarkup> _rectangles = <RectangleMarkup>[];
  final List<OvalMarkup> _ovals = <OvalMarkup>[];
  final List<FreehandMarkup> _freehands = <FreehandMarkup>[];
  final List<TextNoteMarkup> _textNotes = <TextNoteMarkup>[];
  int? _selectedDimensionId;
  int? _selectedArrowId;
  int? _selectedRectangleId;
  int? _selectedOvalId;
  int? _selectedFreehandId;
  int? _selectedTextNoteId;
  int _nextMarkupId = 1;
  Offset? _activeDimensionStart;
  Offset? _activeDimensionCurrent;
  final List<Offset> _activeFreehandPoints = <Offset>[];
  _MoveSession? _activeMoveSession;
  bool _didMoveSelectedMarkup = false;

  @override
  void initState() {
    super.initState();
    final String? initialPath = widget.initialImagePath;
    if (initialPath != null && initialPath.isNotEmpty) {
      _loadImageFromPath(initialPath, showErrorForFailure: false);
    }
  }

  @override
  void dispose() {
    unawaited(
      _imageImportService.deleteTemporaryDisplayPath(
        _temporaryConvertedImagePath,
      ),
    );
    super.dispose();
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
    final bool isHeicSource = ImageImportConstants.heicExtensionsSet.contains(
      extension,
    );
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

    late final ImageImportResult importResult;
    try {
      importResult = await _imageImportService.prepareDisplayableImage(
        sourcePath: path,
      );
    } catch (_) {
      if (showErrorForFailure) {
        _setLoadError(
          message: isHeicSource
              ? ImageImportConstants.heicConversionFailedMessage
              : ImageImportConstants.openErrorMessage,
        );
      }
      return;
    }

    final Size? imageSize = await _readImagePixelSize(importResult.displayPath);
    if (imageSize == null) {
      if (importResult.usedTemporaryConvertedCopy) {
        await _imageImportService.deleteTemporaryDisplayPath(
          importResult.displayPath,
        );
      }
      if (showErrorForFailure) {
        _setLoadError(
          message: isHeicSource
              ? ImageImportConstants.heicConversionFailedMessage
              : ImageImportConstants.openErrorMessage,
        );
      }
      return;
    }

    final String? previousTemporaryPath = _temporaryConvertedImagePath;
    if (!mounted) {
      if (importResult.usedTemporaryConvertedCopy) {
        await _imageImportService.deleteTemporaryDisplayPath(
          importResult.displayPath,
        );
      }
      return;
    }

    if (previousTemporaryPath != null &&
        previousTemporaryPath != importResult.displayPath) {
      await _imageImportService.deleteTemporaryDisplayPath(
        previousTemporaryPath,
      );
    }

    setState(() {
      _imagePath = importResult.displayPath;
      _temporaryConvertedImagePath = importResult.usedTemporaryConvertedCopy
          ? importResult.displayPath
          : null;
      _loadedFileName = _fileNameFromPath(path);
      _loadedImagePixelSize = imageSize;
      _errorMessage = null;
      _clearMarkupSelection();
      _activeDimensionStart = null;
      _activeDimensionCurrent = null;
      _dimensionLines.clear();
      _arrows.clear();
      _rectangles.clear();
      _ovals.clear();
      _freehands.clear();
      _textNotes.clear();
      _activeFreehandPoints.clear();
      _activeMoveSession = null;
      _didMoveSelectedMarkup = false;
      _nextMarkupId = 1;
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

  void _setLoadError({String? message}) {
    setState(() {
      _errorMessage = message ?? ImageImportConstants.openErrorMessage;
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

    if (label == ToolbarConstants.arrow) {
      setState(() {
        _selectedTool = MarkupTool.arrow;
      });
      return;
    }

    if (label == ToolbarConstants.rectangle) {
      setState(() {
        _selectedTool = MarkupTool.rectangle;
      });
      return;
    }

    if (label == ToolbarConstants.circle) {
      setState(() {
        _selectedTool = MarkupTool.oval;
      });
      return;
    }

    if (label == ToolbarConstants.freehand) {
      setState(() {
        _selectedTool = MarkupTool.freehand;
      });
      return;
    }

    if (label == ToolbarConstants.textNote) {
      setState(() {
        _selectedTool = MarkupTool.textNote;
      });
      return;
    }

    if (label == ToolbarConstants.undo) {
      _undoMostRecentMarkup();
      return;
    }

    if (label == ToolbarConstants.erase) {
      _eraseSelectedMarkup();
      return;
    }

    if (label == ToolbarConstants.export) {
      _exportMarkedUpImage();
      return;
    }
  }

  Future<void> _exportMarkedUpImage() async {
    if (_isExporting) {
      return;
    }

    if (_imagePath == null) {
      _showSnack(UiCopyConstants.exportNoPhotoMessage);
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final FileSaveLocation? saveLocation = widget.saveLocationOverride != null
          ? await widget.saveLocationOverride!(
              suggestedName: _suggestedExportName(),
              confirmButtonText: ExportConstants.saveDialogConfirmButtonText,
              acceptedTypeGroups: const <XTypeGroup>[
                ExportConstants.pngSaveTypeGroup,
              ],
            )
          : await getSaveLocation(
              suggestedName: _suggestedExportName(),
              confirmButtonText: ExportConstants.saveDialogConfirmButtonText,
              acceptedTypeGroups: const <XTypeGroup>[
                ExportConstants.pngSaveTypeGroup,
              ],
            );

      if (!mounted || saveLocation == null || saveLocation.path.isEmpty) {
        return;
      }

      final double pixelRatio = MediaQuery.of(
        context,
      ).devicePixelRatio.clamp(1.0, ExportConstants.maxPixelRatio);
      final String outputPath = _normalizeExportPath(saveLocation.path);

      await MarkedUpImageExportService.exportBoundaryToPng(
        boundaryKey: _canvasExportKey,
        outputPath: outputPath,
        pixelRatio: pixelRatio,
      );

      if (!mounted) {
        return;
      }
      _showSnack(UiCopyConstants.exportSuccessMessage);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(UiCopyConstants.exportFailureMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  String _suggestedExportName() {
    final String sourceName = _loadedFileName ?? 'photo';
    final int extensionIndex = sourceName.lastIndexOf('.');
    final String baseName = extensionIndex > 0
        ? sourceName.substring(0, extensionIndex)
        : sourceName;
    return '$baseName${ExportConstants.defaultFileSuffix}.${ExportConstants.outputExtension}';
  }

  String _normalizeExportPath(String path) {
    final String lowerPath = path.toLowerCase();
    final String extension = '.${ExportConstants.outputExtension}';
    if (lowerPath.endsWith(extension)) {
      return path;
    }
    return '$path$extension';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  int _allocateMarkupId() {
    final int id = _nextMarkupId;
    _nextMarkupId += 1;
    return id;
  }

  void _clearMarkupSelection() {
    _selectedDimensionId = null;
    _selectedArrowId = null;
    _selectedRectangleId = null;
    _selectedOvalId = null;
    _selectedFreehandId = null;
    _selectedTextNoteId = null;
  }

  void _selectDimensionById(int id) {
    _selectedDimensionId = id;
    _selectedArrowId = null;
    _selectedRectangleId = null;
    _selectedOvalId = null;
    _selectedFreehandId = null;
    _selectedTextNoteId = null;
  }

  void _selectArrowById(int id) {
    _selectedArrowId = id;
    _selectedDimensionId = null;
    _selectedRectangleId = null;
    _selectedOvalId = null;
    _selectedFreehandId = null;
    _selectedTextNoteId = null;
  }

  void _selectRectangleById(int id) {
    _selectedRectangleId = id;
    _selectedDimensionId = null;
    _selectedArrowId = null;
    _selectedOvalId = null;
    _selectedFreehandId = null;
    _selectedTextNoteId = null;
  }

  void _selectOvalById(int id) {
    _selectedOvalId = id;
    _selectedDimensionId = null;
    _selectedArrowId = null;
    _selectedRectangleId = null;
    _selectedFreehandId = null;
    _selectedTextNoteId = null;
  }

  void _selectFreehandById(int id) {
    _selectedFreehandId = id;
    _selectedDimensionId = null;
    _selectedArrowId = null;
    _selectedRectangleId = null;
    _selectedOvalId = null;
    _selectedTextNoteId = null;
  }

  void _selectTextNoteById(int id) {
    _selectedTextNoteId = id;
    _selectedDimensionId = null;
    _selectedArrowId = null;
    _selectedRectangleId = null;
    _selectedOvalId = null;
    _selectedFreehandId = null;
  }

  void _undoMostRecentMarkup() {
    int latestDimensionId = -1;
    for (final DimensionLine line in _dimensionLines) {
      if (line.id > latestDimensionId) {
        latestDimensionId = line.id;
      }
    }

    int latestArrowId = -1;
    for (final ArrowMarkup arrow in _arrows) {
      if (arrow.id > latestArrowId) {
        latestArrowId = arrow.id;
      }
    }

    int latestRectangleId = -1;
    for (final RectangleMarkup rectangle in _rectangles) {
      if (rectangle.id > latestRectangleId) {
        latestRectangleId = rectangle.id;
      }
    }

    int latestOvalId = -1;
    for (final OvalMarkup oval in _ovals) {
      if (oval.id > latestOvalId) {
        latestOvalId = oval.id;
      }
    }

    int latestFreehandId = -1;
    for (final FreehandMarkup freehand in _freehands) {
      if (freehand.id > latestFreehandId) {
        latestFreehandId = freehand.id;
      }
    }

    int latestTextNoteId = -1;
    for (final TextNoteMarkup textNote in _textNotes) {
      if (textNote.id > latestTextNoteId) {
        latestTextNoteId = textNote.id;
      }
    }

    if (latestDimensionId == -1 &&
        latestArrowId == -1 &&
        latestRectangleId == -1 &&
        latestOvalId == -1 &&
        latestFreehandId == -1 &&
        latestTextNoteId == -1) {
      return;
    }

    setState(() {
      if (latestDimensionId >= latestArrowId &&
          latestDimensionId >= latestRectangleId &&
          latestDimensionId >= latestOvalId &&
          latestDimensionId >= latestFreehandId &&
          latestDimensionId >= latestTextNoteId) {
        _dimensionLines.removeWhere(
          (DimensionLine line) => line.id == latestDimensionId,
        );
        if (_selectedDimensionId == latestDimensionId) {
          _clearMarkupSelection();
        }
      } else if (latestArrowId >= latestRectangleId &&
          latestArrowId >= latestOvalId &&
          latestArrowId >= latestFreehandId &&
          latestArrowId >= latestTextNoteId) {
        _arrows.removeWhere((ArrowMarkup arrow) => arrow.id == latestArrowId);
        if (_selectedArrowId == latestArrowId) {
          _clearMarkupSelection();
        }
      } else if (latestRectangleId >= latestOvalId &&
          latestRectangleId >= latestFreehandId &&
          latestRectangleId >= latestTextNoteId) {
        _rectangles.removeWhere(
          (RectangleMarkup rectangle) => rectangle.id == latestRectangleId,
        );
        if (_selectedRectangleId == latestRectangleId) {
          _clearMarkupSelection();
        }
      } else if (latestOvalId >= latestFreehandId &&
          latestOvalId >= latestTextNoteId) {
        _ovals.removeWhere((OvalMarkup oval) => oval.id == latestOvalId);
        if (_selectedOvalId == latestOvalId) {
          _clearMarkupSelection();
        }
      } else if (latestFreehandId >= latestTextNoteId) {
        _freehands.removeWhere(
          (FreehandMarkup freehand) => freehand.id == latestFreehandId,
        );
        if (_selectedFreehandId == latestFreehandId) {
          _clearMarkupSelection();
        }
      } else {
        _textNotes.removeWhere(
          (TextNoteMarkup textNote) => textNote.id == latestTextNoteId,
        );
        if (_selectedTextNoteId == latestTextNoteId) {
          _clearMarkupSelection();
        }
      }
    });
  }

  void _eraseSelectedMarkup() {
    final int? selectedDimensionId = _selectedDimensionId;
    if (selectedDimensionId != null) {
      setState(() {
        _dimensionLines.removeWhere(
          (DimensionLine line) => line.id == selectedDimensionId,
        );
        _clearMarkupSelection();
      });
      return;
    }

    final int? selectedArrowId = _selectedArrowId;
    if (selectedArrowId != null) {
      setState(() {
        _arrows.removeWhere((ArrowMarkup arrow) => arrow.id == selectedArrowId);
        _clearMarkupSelection();
      });
      return;
    }

    final int? selectedRectangleId = _selectedRectangleId;
    if (selectedRectangleId != null) {
      setState(() {
        _rectangles.removeWhere(
          (RectangleMarkup rectangle) => rectangle.id == selectedRectangleId,
        );
        _clearMarkupSelection();
      });
      return;
    }

    final int? selectedOvalId = _selectedOvalId;
    if (selectedOvalId != null) {
      setState(() {
        _ovals.removeWhere((OvalMarkup oval) => oval.id == selectedOvalId);
        _clearMarkupSelection();
      });
      return;
    }

    final int? selectedFreehandId = _selectedFreehandId;
    if (selectedFreehandId != null) {
      setState(() {
        _freehands.removeWhere(
          (FreehandMarkup freehand) => freehand.id == selectedFreehandId,
        );
        _clearMarkupSelection();
      });
      return;
    }

    final int? selectedTextNoteId = _selectedTextNoteId;
    if (selectedTextNoteId != null) {
      setState(() {
        _textNotes.removeWhere(
          (TextNoteMarkup textNote) => textNote.id == selectedTextNoteId,
        );
        _clearMarkupSelection();
      });
      return;
    }

    _showSnack(UiCopyConstants.eraseNoSelectionMessage);
  }

  void _onDimensionStart(Offset startPoint, Rect imageRect) {
    if (!imageRect.contains(startPoint)) {
      return;
    }
    _didMoveSelectedMarkup = false;
    if (_tryStartMoveSelectedMarkup(startPoint, imageRect)) {
      return;
    }
    if (!_canDrawMarkup(imageRect)) {
      return;
    }
    final Offset clamped = DimensionLine.clampToRect(startPoint, imageRect);
    setState(() {
      _activeDimensionStart = clamped;
      _activeDimensionCurrent = clamped;
      _activeFreehandPoints.clear();
      if (_selectedTool == MarkupTool.freehand) {
        _activeFreehandPoints.add(clamped);
      }
      _clearMarkupSelection();
    });
  }

  void _onDimensionUpdate(Offset currentPoint, Rect imageRect) {
    if (_activeMoveSession != null) {
      _updateMoveSelectedMarkup(currentPoint, imageRect);
      return;
    }
    if (_activeDimensionStart == null || !_canDrawMarkup(imageRect)) {
      return;
    }
    final Offset clamped = DimensionLine.clampToRect(currentPoint, imageRect);
    setState(() {
      _activeDimensionCurrent = clamped;
      if (_selectedTool == MarkupTool.freehand) {
        final Offset? lastPoint = _activeFreehandPoints.isEmpty
            ? null
            : _activeFreehandPoints.last;
        if (lastPoint == null ||
            (clamped - lastPoint).distance >=
                FreehandMarkupConstants.pointMinDistance) {
          _activeFreehandPoints.add(clamped);
        }
      }
    });
  }

  Future<void> _onDimensionEnd(Rect imageRect) async {
    if (_activeMoveSession != null) {
      _activeMoveSession = null;
      return;
    }

    final Offset? start = _activeDimensionStart;
    final Offset? end = _activeDimensionCurrent;
    final List<Offset> freehandPoints = List<Offset>.of(_activeFreehandPoints);
    _activeDimensionStart = null;
    _activeDimensionCurrent = null;
    _activeFreehandPoints.clear();

    if (start == null || end == null || !_canDrawMarkup(imageRect)) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    if (_selectedTool == MarkupTool.arrow) {
      final ArrowMarkup arrow = ArrowMarkup.fromCanvasPoints(
        id: _allocateMarkupId(),
        startPoint: start,
        endPoint: end,
        imageRect: imageRect,
      );
      if (arrow.lengthInRect(imageRect) < ArrowMarkupConstants.minLength) {
        if (mounted) {
          setState(() {});
        }
        return;
      }
      if (mounted) {
        setState(() {
          _arrows.add(arrow);
          _selectArrowById(arrow.id);
        });
      }
      return;
    }

    if (_selectedTool == MarkupTool.freehand) {
      if (freehandPoints.length < FreehandMarkupConstants.minimumPointCount) {
        if (mounted) {
          setState(() {});
        }
        return;
      }
      final FreehandMarkup freehand = FreehandMarkup.fromCanvasPoints(
        id: _allocateMarkupId(),
        points: freehandPoints,
        imageRect: imageRect,
      );
      if (mounted) {
        setState(() {
          _freehands.add(freehand);
          _selectFreehandById(freehand.id);
        });
      }
      return;
    }

    if (_selectedTool == MarkupTool.rectangle) {
      final RectangleMarkup rectangle = RectangleMarkup.fromCanvasPoints(
        id: _allocateMarkupId(),
        startPoint: start,
        endPoint: end,
        imageRect: imageRect,
      );
      if (rectangle.widthInRect(imageRect) <
              RectangleMarkupConstants.minSideLength ||
          rectangle.heightInRect(imageRect) <
              RectangleMarkupConstants.minSideLength) {
        if (mounted) {
          setState(() {});
        }
        return;
      }
      if (mounted) {
        setState(() {
          _rectangles.add(rectangle);
          _selectRectangleById(rectangle.id);
        });
      }
      return;
    }

    if (_selectedTool == MarkupTool.oval) {
      final OvalMarkup oval = OvalMarkup.fromCanvasPoints(
        id: _allocateMarkupId(),
        startPoint: start,
        endPoint: end,
        imageRect: imageRect,
      );
      if (oval.widthInRect(imageRect) < OvalMarkupConstants.minAxisLength ||
          oval.heightInRect(imageRect) < OvalMarkupConstants.minAxisLength) {
        if (mounted) {
          setState(() {});
        }
        return;
      }
      if (mounted) {
        setState(() {
          _ovals.add(oval);
          _selectOvalById(oval.id);
        });
      }
      return;
    }

    if (_selectedTool == MarkupTool.dimension) {
      final DimensionLine line = DimensionLine.fromCanvasPoints(
        id: _allocateMarkupId(),
        startPoint: start,
        endPoint: end,
        imageRect: imageRect,
      );

      int? newLineId;
      setState(() {
        if (line.lengthInRect(imageRect) >=
            UiLayoutConstants.dimensionTapDragMinDistance) {
          _dimensionLines.add(line);
          newLineId = line.id;
          _selectDimensionById(line.id);
        }
      });

      if (!mounted || newLineId == null) {
        return;
      }
      await _promptForDimensionLabelById(newLineId!);
    }
  }

  Future<void> _promptForDimensionLabelById(int dimensionId) async {
    final int lineIndex = _dimensionLines.indexWhere(
      (DimensionLine line) => line.id == dimensionId,
    );
    if (lineIndex == -1) {
      return;
    }

    final String existingLabel = _dimensionLines[lineIndex].label ?? '';
    final String? updatedLabel = await _showDimensionLabelDialog(
      initialValue: existingLabel,
    );

    if (!mounted || updatedLabel == null) {
      return;
    }

    final int refreshIndex = _dimensionLines.indexWhere(
      (DimensionLine line) => line.id == dimensionId,
    );
    if (refreshIndex == -1) {
      return;
    }

    final String normalized = DimensionLabelFormatter.format(updatedLabel);
    setState(() {
      _dimensionLines[refreshIndex] = normalized.isEmpty
          ? _dimensionLines[refreshIndex].copyWith(clearLabel: true)
          : _dimensionLines[refreshIndex].copyWith(label: normalized);
      _selectDimensionById(dimensionId);
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

  Future<void> _createTextNoteAt(Offset point, Rect imageRect) async {
    final String? noteText = await _showTextNoteDialog(initialValue: '');
    if (!mounted || noteText == null) {
      return;
    }

    final String trimmed = noteText.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final TextNoteMarkup note = TextNoteMarkup.fromCanvasPoint(
      id: _allocateMarkupId(),
      anchorPoint: point,
      text: trimmed,
      imageRect: imageRect,
    );
    setState(() {
      _textNotes.add(note);
      _selectTextNoteById(note.id);
    });
  }

  Future<void> _editTextNoteById(int noteId) async {
    final int index = _textNotes.indexWhere(
      (TextNoteMarkup note) => note.id == noteId,
    );
    if (index == -1) {
      return;
    }

    final String? updatedText = await _showTextNoteDialog(
      initialValue: _textNotes[index].text,
    );
    if (!mounted || updatedText == null) {
      return;
    }

    final int refreshIndex = _textNotes.indexWhere(
      (TextNoteMarkup note) => note.id == noteId,
    );
    if (refreshIndex == -1) {
      return;
    }

    final String trimmed = updatedText.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _textNotes.removeAt(refreshIndex);
        _clearMarkupSelection();
      });
      return;
    }

    setState(() {
      _textNotes[refreshIndex] = _textNotes[refreshIndex].copyWith(
        text: trimmed,
      );
      _selectTextNoteById(noteId);
    });
  }

  Future<String?> _showTextNoteDialog({required String initialValue}) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _TextNoteDialog(initialValue: initialValue);
      },
    );
  }

  bool _tryStartMoveSelectedMarkup(Offset point, Rect imageRect) {
    final _SelectedMarkup? selectedMarkup = _selectedMarkup();
    if (selectedMarkup == null) {
      return false;
    }
    final double distance = _distanceToSelectedMarkup(
      selectedMarkup,
      point,
      imageRect,
    );
    if (distance > _selectionDistanceForTool(selectedMarkup.tool)) {
      return false;
    }

    _activeMoveSession = _MoveSession(
      markupId: selectedMarkup.markupId,
      markupTool: selectedMarkup.tool,
      startPoint: point,
      lastPoint: point,
    );
    return true;
  }

  _SelectedMarkup? _selectedMarkup() {
    if (_selectedDimensionId != null) {
      return _SelectedMarkup(
        markupId: _selectedDimensionId!,
        tool: MarkupTool.dimension,
      );
    }
    if (_selectedArrowId != null) {
      return _SelectedMarkup(
        markupId: _selectedArrowId!,
        tool: MarkupTool.arrow,
      );
    }
    if (_selectedRectangleId != null) {
      return _SelectedMarkup(
        markupId: _selectedRectangleId!,
        tool: MarkupTool.rectangle,
      );
    }
    if (_selectedOvalId != null) {
      return _SelectedMarkup(markupId: _selectedOvalId!, tool: MarkupTool.oval);
    }
    if (_selectedFreehandId != null) {
      return _SelectedMarkup(
        markupId: _selectedFreehandId!,
        tool: MarkupTool.freehand,
      );
    }
    if (_selectedTextNoteId != null) {
      return _SelectedMarkup(
        markupId: _selectedTextNoteId!,
        tool: MarkupTool.textNote,
      );
    }
    return null;
  }

  double _selectionDistanceForTool(MarkupTool tool) {
    final double minimumHitDistance =
        MarkupMoveConstants.selectionStartHitDistance;
    switch (tool) {
      case MarkupTool.dimension:
      case MarkupTool.arrow:
        return math.max(
          DimensionLineConstants.selectionTapDistance,
          minimumHitDistance,
        );
      case MarkupTool.rectangle:
        return math.max(
          RectangleMarkupConstants.selectionHitDistance,
          minimumHitDistance,
        );
      case MarkupTool.oval:
        return math.max(
          OvalMarkupConstants.selectionHitDistance,
          minimumHitDistance,
        );
      case MarkupTool.freehand:
        return math.max(
          FreehandMarkupConstants.selectionHitDistance,
          minimumHitDistance,
        );
      case MarkupTool.textNote:
        return math.max(
          TextNoteMarkupConstants.selectionHitDistance,
          minimumHitDistance,
        );
      case MarkupTool.none:
        return math.max(
          DimensionLineConstants.selectionTapDistance,
          minimumHitDistance,
        );
    }
  }

  double _distanceToSelectedMarkup(
    _SelectedMarkup selectedMarkup,
    Offset point,
    Rect imageRect,
  ) {
    switch (selectedMarkup.tool) {
      case MarkupTool.dimension:
        final int index = _dimensionLines.indexWhere(
          (DimensionLine line) => line.id == selectedMarkup.markupId,
        );
        if (index == -1) {
          return double.infinity;
        }
        return _dimensionLines[index].distanceToPointInRect(point, imageRect);
      case MarkupTool.arrow:
        final int index = _arrows.indexWhere(
          (ArrowMarkup arrow) => arrow.id == selectedMarkup.markupId,
        );
        if (index == -1) {
          return double.infinity;
        }
        return _arrows[index].distanceToPointInRect(point, imageRect);
      case MarkupTool.rectangle:
        final int index = _rectangles.indexWhere(
          (RectangleMarkup rectangle) =>
              rectangle.id == selectedMarkup.markupId,
        );
        if (index == -1) {
          return double.infinity;
        }
        return _rectangles[index].distanceToPointInRect(point, imageRect);
      case MarkupTool.oval:
        final int index = _ovals.indexWhere(
          (OvalMarkup oval) => oval.id == selectedMarkup.markupId,
        );
        if (index == -1) {
          return double.infinity;
        }
        return _ovals[index].distanceToPointInRect(point, imageRect);
      case MarkupTool.freehand:
        final int index = _freehands.indexWhere(
          (FreehandMarkup freehand) => freehand.id == selectedMarkup.markupId,
        );
        if (index == -1) {
          return double.infinity;
        }
        return _freehands[index].distanceToPointInRect(point, imageRect);
      case MarkupTool.textNote:
        final int index = _textNotes.indexWhere(
          (TextNoteMarkup note) => note.id == selectedMarkup.markupId,
        );
        if (index == -1) {
          return double.infinity;
        }
        return _distanceToTextNote(_textNotes[index], point, imageRect);
      case MarkupTool.none:
        return double.infinity;
    }
  }

  void _updateMoveSelectedMarkup(Offset currentPoint, Rect imageRect) {
    final _MoveSession? moveSession = _activeMoveSession;
    if (moveSession == null) {
      return;
    }
    final Offset clampedPoint = DimensionLine.clampToRect(
      currentPoint,
      imageRect,
    );
    final double travelDistance =
        (clampedPoint - moveSession.startPoint).distance;
    if (!moveSession.isDragActive &&
        travelDistance < MarkupMoveConstants.dragActivationDistance) {
      return;
    }

    moveSession.isDragActive = true;
    final Offset requestedDelta = clampedPoint - moveSession.lastPoint;
    if (requestedDelta.distance < MarkupMoveConstants.minimumMoveDelta) {
      return;
    }
    final Offset appliedDelta = _moveMarkupByDelta(
      markupTool: moveSession.markupTool,
      markupId: moveSession.markupId,
      requestedDelta: requestedDelta,
      imageRect: imageRect,
    );
    moveSession.lastPoint = clampedPoint;
    if (appliedDelta.distance > 0) {
      _didMoveSelectedMarkup = true;
    }
  }

  Offset _moveMarkupByDelta({
    required MarkupTool markupTool,
    required int markupId,
    required Offset requestedDelta,
    required Rect imageRect,
  }) {
    switch (markupTool) {
      case MarkupTool.dimension:
        return _moveDimensionByDelta(markupId, requestedDelta, imageRect);
      case MarkupTool.arrow:
        return _moveArrowByDelta(markupId, requestedDelta, imageRect);
      case MarkupTool.rectangle:
        return _moveRectangleByDelta(markupId, requestedDelta, imageRect);
      case MarkupTool.oval:
        return _moveOvalByDelta(markupId, requestedDelta, imageRect);
      case MarkupTool.freehand:
        return _moveFreehandByDelta(markupId, requestedDelta, imageRect);
      case MarkupTool.textNote:
        return _moveTextNoteByDelta(markupId, requestedDelta, imageRect);
      case MarkupTool.none:
        return Offset.zero;
    }
  }

  Offset _moveDimensionByDelta(int markupId, Offset delta, Rect imageRect) {
    final int index = _dimensionLines.indexWhere(
      (DimensionLine line) => line.id == markupId,
    );
    if (index == -1) {
      return Offset.zero;
    }
    final DimensionLine line = _dimensionLines[index];
    final List<Offset> points = <Offset>[
      line.startInRect(imageRect),
      line.endInRect(imageRect),
    ];
    final Offset appliedDelta = MarkupMoveUtils.clampTranslationForPoints(
      points: points,
      requestedDelta: delta,
      bounds: imageRect,
      padding: MarkupMoveConstants.boundsPadding,
    );
    if (appliedDelta == Offset.zero) {
      return Offset.zero;
    }
    final List<Offset> moved = MarkupMoveUtils.translatePoints(
      points,
      appliedDelta,
    );
    final DimensionLine movedLine = DimensionLine.fromCanvasPoints(
      id: line.id,
      startPoint: moved.first,
      endPoint: moved.last,
      imageRect: imageRect,
    ).copyWith(label: line.label);
    setState(() {
      _dimensionLines[index] = movedLine;
    });
    return appliedDelta;
  }

  Offset _moveArrowByDelta(int markupId, Offset delta, Rect imageRect) {
    final int index = _arrows.indexWhere(
      (ArrowMarkup arrow) => arrow.id == markupId,
    );
    if (index == -1) {
      return Offset.zero;
    }
    final ArrowMarkup arrow = _arrows[index];
    final List<Offset> points = <Offset>[
      arrow.startInRect(imageRect),
      arrow.endInRect(imageRect),
    ];
    final Offset appliedDelta = MarkupMoveUtils.clampTranslationForPoints(
      points: points,
      requestedDelta: delta,
      bounds: imageRect,
      padding: MarkupMoveConstants.boundsPadding,
    );
    if (appliedDelta == Offset.zero) {
      return Offset.zero;
    }
    final List<Offset> moved = MarkupMoveUtils.translatePoints(
      points,
      appliedDelta,
    );
    final ArrowMarkup movedArrow = ArrowMarkup.fromCanvasPoints(
      id: arrow.id,
      startPoint: moved.first,
      endPoint: moved.last,
      imageRect: imageRect,
    );
    setState(() {
      _arrows[index] = movedArrow;
    });
    return appliedDelta;
  }

  Offset _moveRectangleByDelta(int markupId, Offset delta, Rect imageRect) {
    final int index = _rectangles.indexWhere(
      (RectangleMarkup rectangle) => rectangle.id == markupId,
    );
    if (index == -1) {
      return Offset.zero;
    }
    final RectangleMarkup rectangle = _rectangles[index];
    final Rect rect = rectangle.rectInRect(imageRect);
    final List<Offset> points = <Offset>[rect.topLeft, rect.bottomRight];
    final Offset appliedDelta = MarkupMoveUtils.clampTranslationForPoints(
      points: points,
      requestedDelta: delta,
      bounds: imageRect,
      padding: MarkupMoveConstants.boundsPadding,
    );
    if (appliedDelta == Offset.zero) {
      return Offset.zero;
    }
    final List<Offset> moved = MarkupMoveUtils.translatePoints(
      points,
      appliedDelta,
    );
    final RectangleMarkup movedRectangle = RectangleMarkup.fromCanvasPoints(
      id: rectangle.id,
      startPoint: moved.first,
      endPoint: moved.last,
      imageRect: imageRect,
    );
    setState(() {
      _rectangles[index] = movedRectangle;
    });
    return appliedDelta;
  }

  Offset _moveOvalByDelta(int markupId, Offset delta, Rect imageRect) {
    final int index = _ovals.indexWhere(
      (OvalMarkup oval) => oval.id == markupId,
    );
    if (index == -1) {
      return Offset.zero;
    }
    final OvalMarkup oval = _ovals[index];
    final Rect rect = oval.rectInRect(imageRect);
    final List<Offset> points = <Offset>[rect.topLeft, rect.bottomRight];
    final Offset appliedDelta = MarkupMoveUtils.clampTranslationForPoints(
      points: points,
      requestedDelta: delta,
      bounds: imageRect,
      padding: MarkupMoveConstants.boundsPadding,
    );
    if (appliedDelta == Offset.zero) {
      return Offset.zero;
    }
    final List<Offset> moved = MarkupMoveUtils.translatePoints(
      points,
      appliedDelta,
    );
    final OvalMarkup movedOval = OvalMarkup.fromCanvasPoints(
      id: oval.id,
      startPoint: moved.first,
      endPoint: moved.last,
      imageRect: imageRect,
    );
    setState(() {
      _ovals[index] = movedOval;
    });
    return appliedDelta;
  }

  Offset _moveFreehandByDelta(int markupId, Offset delta, Rect imageRect) {
    final int index = _freehands.indexWhere(
      (FreehandMarkup freehand) => freehand.id == markupId,
    );
    if (index == -1) {
      return Offset.zero;
    }
    final FreehandMarkup freehand = _freehands[index];
    final List<Offset> points = freehand.pointsInRect(imageRect);
    final Offset appliedDelta = MarkupMoveUtils.clampTranslationForPoints(
      points: points,
      requestedDelta: delta,
      bounds: imageRect,
      padding: MarkupMoveConstants.boundsPadding,
    );
    if (appliedDelta == Offset.zero) {
      return Offset.zero;
    }
    final List<Offset> moved = MarkupMoveUtils.translatePoints(
      points,
      appliedDelta,
    );
    final FreehandMarkup movedFreehand = FreehandMarkup.fromCanvasPoints(
      id: freehand.id,
      points: moved,
      imageRect: imageRect,
    );
    setState(() {
      _freehands[index] = movedFreehand;
    });
    return appliedDelta;
  }

  Offset _moveTextNoteByDelta(int markupId, Offset delta, Rect imageRect) {
    final int index = _textNotes.indexWhere(
      (TextNoteMarkup note) => note.id == markupId,
    );
    if (index == -1) {
      return Offset.zero;
    }
    final TextNoteMarkup note = _textNotes[index];
    final Offset anchor = note.anchorInRect(imageRect);
    final Offset appliedDelta = MarkupMoveUtils.clampTranslationForPoints(
      points: <Offset>[anchor],
      requestedDelta: delta,
      bounds: imageRect,
      padding: MarkupMoveConstants.boundsPadding,
    );
    if (appliedDelta == Offset.zero) {
      return Offset.zero;
    }
    final Offset moved = anchor + appliedDelta;
    final TextNoteMarkup movedNote = TextNoteMarkup.fromCanvasPoint(
      id: note.id,
      anchorPoint: moved,
      text: note.text,
      imageRect: imageRect,
    );
    setState(() {
      _textNotes[index] = movedNote;
    });
    return appliedDelta;
  }

  Future<void> _onDimensionTap(Offset point, Rect imageRect) async {
    if (_didMoveSelectedMarkup) {
      _didMoveSelectedMarkup = false;
      return;
    }
    if (_imagePath == null) {
      return;
    }
    if (_selectedTool != MarkupTool.textNote &&
        _dimensionLines.isEmpty &&
        _arrows.isEmpty &&
        _rectangles.isEmpty &&
        _ovals.isEmpty &&
        _freehands.isEmpty &&
        _textNotes.isEmpty) {
      return;
    }

    final _NearestMarkupHit nearestHit = _findNearestMarkupHit(
      point,
      imageRect,
    );
    if (!nearestHit.found) {
      if (_selectedTool == MarkupTool.textNote) {
        await _createTextNoteAt(point, imageRect);
        return;
      }
      if (_selectedDimensionId != null ||
          _selectedArrowId != null ||
          _selectedRectangleId != null ||
          _selectedOvalId != null ||
          _selectedFreehandId != null ||
          _selectedTextNoteId != null) {
        setState(() {
          _clearMarkupSelection();
        });
      }
      return;
    }

    if (nearestHit.markupTool == MarkupTool.dimension) {
      if (_selectedDimensionId != nearestHit.markupId ||
          _selectedArrowId != null ||
          _selectedRectangleId != null ||
          _selectedOvalId != null ||
          _selectedFreehandId != null ||
          _selectedTextNoteId != null) {
        setState(() {
          _selectDimensionById(nearestHit.markupId);
        });
        return;
      }
      await _promptForDimensionLabelById(nearestHit.markupId);
      return;
    }

    if (nearestHit.markupTool == MarkupTool.arrow &&
        (_selectedArrowId != nearestHit.markupId ||
            _selectedDimensionId != null ||
            _selectedRectangleId != null ||
            _selectedOvalId != null ||
            _selectedFreehandId != null ||
            _selectedTextNoteId != null)) {
      setState(() {
        _selectArrowById(nearestHit.markupId);
      });
      return;
    }

    if (nearestHit.markupTool == MarkupTool.rectangle &&
        (_selectedRectangleId != nearestHit.markupId ||
            _selectedDimensionId != null ||
            _selectedArrowId != null ||
            _selectedOvalId != null ||
            _selectedFreehandId != null ||
            _selectedTextNoteId != null)) {
      setState(() {
        _selectRectangleById(nearestHit.markupId);
      });
      return;
    }

    if (nearestHit.markupTool == MarkupTool.oval &&
        (_selectedOvalId != nearestHit.markupId ||
            _selectedDimensionId != null ||
            _selectedArrowId != null ||
            _selectedRectangleId != null ||
            _selectedFreehandId != null ||
            _selectedTextNoteId != null)) {
      setState(() {
        _selectOvalById(nearestHit.markupId);
      });
      return;
    }

    if (nearestHit.markupTool == MarkupTool.freehand &&
        (_selectedFreehandId != nearestHit.markupId ||
            _selectedDimensionId != null ||
            _selectedArrowId != null ||
            _selectedRectangleId != null ||
            _selectedOvalId != null ||
            _selectedTextNoteId != null)) {
      setState(() {
        _selectFreehandById(nearestHit.markupId);
      });
      return;
    }

    if (nearestHit.markupTool == MarkupTool.textNote) {
      if (_selectedTextNoteId != nearestHit.markupId ||
          _selectedDimensionId != null ||
          _selectedArrowId != null ||
          _selectedRectangleId != null ||
          _selectedOvalId != null ||
          _selectedFreehandId != null) {
        setState(() {
          _selectTextNoteById(nearestHit.markupId);
        });
        return;
      }
      await _editTextNoteById(nearestHit.markupId);
    }
  }

  _NearestMarkupHit _findNearestMarkupHit(Offset point, Rect imageRect) {
    int bestMarkupId = -1;
    MarkupTool bestTool = MarkupTool.none;
    double bestDistance = double.infinity;

    for (final DimensionLine line in _dimensionLines) {
      final double distance = line.distanceToPointInRect(point, imageRect);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMarkupId = line.id;
        bestTool = MarkupTool.dimension;
      }
    }

    for (final ArrowMarkup arrow in _arrows) {
      final double distance = arrow.distanceToPointInRect(point, imageRect);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMarkupId = arrow.id;
        bestTool = MarkupTool.arrow;
      }
    }

    for (final RectangleMarkup rectangle in _rectangles) {
      final double distance = rectangle.distanceToPointInRect(point, imageRect);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMarkupId = rectangle.id;
        bestTool = MarkupTool.rectangle;
      }
    }

    for (final OvalMarkup oval in _ovals) {
      final double distance = oval.distanceToPointInRect(point, imageRect);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMarkupId = oval.id;
        bestTool = MarkupTool.oval;
      }
    }

    for (final FreehandMarkup freehand in _freehands) {
      final double distance = freehand.distanceToPointInRect(point, imageRect);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMarkupId = freehand.id;
        bestTool = MarkupTool.freehand;
      }
    }

    for (final TextNoteMarkup note in _textNotes) {
      final double distance = _distanceToTextNote(note, point, imageRect);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMarkupId = note.id;
        bestTool = MarkupTool.textNote;
      }
    }

    double maxSelectionDistance = DimensionLineConstants.selectionTapDistance;
    if (RectangleMarkupConstants.selectionHitDistance > maxSelectionDistance) {
      maxSelectionDistance = RectangleMarkupConstants.selectionHitDistance;
    }
    if (OvalMarkupConstants.selectionHitDistance > maxSelectionDistance) {
      maxSelectionDistance = OvalMarkupConstants.selectionHitDistance;
    }
    if (FreehandMarkupConstants.selectionHitDistance > maxSelectionDistance) {
      maxSelectionDistance = FreehandMarkupConstants.selectionHitDistance;
    }
    if (TextNoteMarkupConstants.selectionHitDistance > maxSelectionDistance) {
      maxSelectionDistance = TextNoteMarkupConstants.selectionHitDistance;
    }

    if (bestDistance > maxSelectionDistance) {
      return const _NearestMarkupHit.notFound();
    }

    return _NearestMarkupHit(markupId: bestMarkupId, markupTool: bestTool);
  }

  double _distanceToTextNote(
    TextNoteMarkup note,
    Offset point,
    Rect imageRect,
  ) {
    final String text = note.text.trim();
    if (text.isEmpty) {
      return double.infinity;
    }

    final TextPainter textPainter =
        TextPainter(
          text: TextSpan(
            text: text,
            style: const TextStyle(
              color: TextNoteMarkupConstants.textColor,
              fontSize: TextNoteMarkupConstants.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 4,
          ellipsis: '...',
        )..layout(
          maxWidth: imageRect.width * TextNoteMarkupConstants.maxWidthFactor,
        );

    final Rect chipRect = _layoutTextNoteRect(
      note.anchorInRect(imageRect),
      textPainter,
      imageRect,
    );
    if (chipRect.contains(point)) {
      return 0;
    }
    final Offset nearest = Offset(
      point.dx.clamp(chipRect.left, chipRect.right),
      point.dy.clamp(chipRect.top, chipRect.bottom),
    );
    return (point - nearest).distance;
  }

  Rect _layoutTextNoteRect(
    Offset anchor,
    TextPainter textPainter,
    Rect imageRect,
  ) {
    final double width =
        textPainter.width + (TextNoteMarkupConstants.horizontalPadding * 2);
    final double height =
        textPainter.height + (TextNoteMarkupConstants.verticalPadding * 2);

    double left = anchor.dx;
    double top = anchor.dy;

    final double minLeft =
        imageRect.left + TextNoteMarkupConstants.clampPadding;
    final double maxLeft =
        imageRect.right - width - TextNoteMarkupConstants.clampPadding;
    final double minTop = imageRect.top + TextNoteMarkupConstants.clampPadding;
    final double maxTop =
        imageRect.bottom - height - TextNoteMarkupConstants.clampPadding;

    left = left.clamp(minLeft, maxLeft >= minLeft ? maxLeft : minLeft);
    top = top.clamp(minTop, maxTop >= minTop ? maxTop : minTop);

    return Rect.fromLTWH(left, top, width, height);
  }

  KeyEventResult _onShellKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      _eraseSelectedMarkup();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  bool _canDrawMarkup(Rect imageRect) {
    return (_selectedTool == MarkupTool.dimension ||
            _selectedTool == MarkupTool.arrow ||
            _selectedTool == MarkupTool.rectangle ||
            _selectedTool == MarkupTool.oval ||
            _selectedTool == MarkupTool.freehand) &&
        _imagePath != null &&
        imageRect.width > 0 &&
        imageRect.height > 0;
  }

  bool _isOverlayInteractionEnabled(Rect imageRect) {
    return _imagePath != null && imageRect.width > 0 && imageRect.height > 0;
  }

  bool _isUndoEnabled() {
    return _dimensionLines.isNotEmpty ||
        _arrows.isNotEmpty ||
        _rectangles.isNotEmpty ||
        _ovals.isNotEmpty ||
        _freehands.isNotEmpty ||
        _textNotes.isNotEmpty;
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
    return Focus(
      autofocus: true,
      onKeyEvent: _onShellKeyEvent,
      child: Scaffold(
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
                              (label == ToolbarConstants.dimension &&
                                  _selectedTool == MarkupTool.dimension) ||
                              (label == ToolbarConstants.arrow &&
                                  _selectedTool == MarkupTool.arrow) ||
                              (label == ToolbarConstants.circle &&
                                  _selectedTool == MarkupTool.oval) ||
                              (label == ToolbarConstants.rectangle &&
                                  _selectedTool == MarkupTool.rectangle) ||
                              (label == ToolbarConstants.freehand &&
                                  _selectedTool == MarkupTool.freehand) ||
                              (label == ToolbarConstants.textNote &&
                                  _selectedTool == MarkupTool.textNote),
                          isDisabled:
                              (label == ToolbarConstants.undo &&
                                  !_isUndoEnabled()) ||
                              (label == ToolbarConstants.export &&
                                  _isExporting),
                          onPressed: () => _onToolbarPressed(label),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                return RepaintBoundary(
                  key: _canvasExportKey,
                  child: Stack(
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
                        arrows: _arrows,
                        rectangles: _rectangles,
                        ovals: _ovals,
                        freehands: _freehands,
                        textNotes: _textNotes,
                        imageRect: imageRect,
                        selectedDimensionId: _selectedDimensionId,
                        selectedArrowId: _selectedArrowId,
                        selectedRectangleId: _selectedRectangleId,
                        selectedOvalId: _selectedOvalId,
                        selectedFreehandId: _selectedFreehandId,
                        selectedTextNoteId: _selectedTextNoteId,
                        activeTool: _selectedTool,
                        activeStart: _activeDimensionStart,
                        activeEnd: _activeDimensionCurrent,
                        activeFreehandPoints: _activeFreehandPoints,
                        isEnabled: _isOverlayInteractionEnabled(imageRect),
                        onStart: (Offset point) =>
                            _onDimensionStart(point, imageRect),
                        onUpdate: (Offset point) =>
                            _onDimensionUpdate(point, imageRect),
                        onEnd: () => _onDimensionEnd(imageRect),
                        onTap: (Offset point) =>
                            _onDimensionTap(point, imageRect),
                      ),
                    ],
                  ),
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

class _NearestMarkupHit {
  const _NearestMarkupHit({required this.markupId, required this.markupTool});

  const _NearestMarkupHit.notFound()
    : markupId = -1,
      markupTool = MarkupTool.none;

  final int markupId;
  final MarkupTool markupTool;

  bool get found => markupId != -1;
}

class _SelectedMarkup {
  const _SelectedMarkup({required this.markupId, required this.tool});

  final int markupId;
  final MarkupTool tool;
}

class _MoveSession {
  _MoveSession({
    required this.markupId,
    required this.markupTool,
    required this.startPoint,
    required this.lastPoint,
  });

  final int markupId;
  final MarkupTool markupTool;
  final Offset startPoint;
  Offset lastPoint;
  bool isDragActive = false;
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

class _TextNoteDialog extends StatefulWidget {
  const _TextNoteDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_TextNoteDialog> createState() => _TextNoteDialogState();
}

class _TextNoteDialogState extends State<_TextNoteDialog> {
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

  void _submitNote() {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(UiCopyConstants.textNoteDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitNote(),
              style: const TextStyle(
                fontSize: TextNoteMarkupConstants.fontSize,
              ),
              decoration: const InputDecoration(
                hintText: UiCopyConstants.textNoteHint,
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
          child: const Text(UiCopyConstants.textNoteSkipButton),
        ),
        FilledButton(
          onPressed: _submitNote,
          child: const Text(UiCopyConstants.textNoteSaveButton),
        ),
      ],
    );
  }
}
