import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/export/services/markup_export_path_service.dart';
import 'package:ncd_photo_markup/features/export/services/marked_up_image_export_service.dart';
import 'package:ncd_photo_markup/features/integration/models/photo_markup_launch_context.dart';
import 'package:ncd_photo_markup/features/integration/services/launch_context_service.dart';
import 'package:ncd_photo_markup/features/import/services/image_import_service.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/editable_markup_document.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/markup/services/editable_markup_document_service.dart';
import 'package:ncd_photo_markup/features/markup/utils/dimension_label_formatter.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_handle_utils.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_move_utils.dart';
import 'package:ncd_photo_markup/features/markup/utils/unsaved_changes_tracker.dart';
import 'package:ncd_photo_markup/features/markup/widgets/dimension_lines_overlay.dart';

typedef OpenFileCallback = Future<XFile?> Function();
typedef SaveLocationCallback =
    Future<FileSaveLocation?> Function({
      String? initialDirectory,
      String? suggestedName,
      String? confirmButtonText,
      List<XTypeGroup> acceptedTypeGroups,
    });

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final LaunchContextService launchContextService = LaunchContextService();
  const String startupImagePath = String.fromEnvironment(
    AppConstants.startupImageEnvKey,
  );
  final LaunchContextBootstrap launchBootstrap = await launchContextService
      .resolveBootstrap(args: args, startupImagePathFromEnv: startupImagePath);
  runApp(
    NcdPhotoMarkupApp(
      initialImagePath: launchBootstrap.initialImagePath,
      launchContext: launchBootstrap.launchContext,
      launchErrorMessage: launchBootstrap.launchErrorMessage,
    ),
  );
}

class NcdPhotoMarkupApp extends StatelessWidget {
  const NcdPhotoMarkupApp({
    super.key,
    this.initialImagePath,
    this.launchContext,
    this.launchErrorMessage,
    this.openFileOverride,
    this.saveLocationOverride,
    this.showStartupSplash = true,
  });

  final String? initialImagePath;
  final PhotoMarkupLaunchContext? launchContext;
  final String? launchErrorMessage;
  final OpenFileCallback? openFileOverride;
  final SaveLocationCallback? saveLocationOverride;
  final bool showStartupSplash;

  @override
  Widget build(BuildContext context) {
    final Widget shell = PhotoMarkupShellScreen(
      initialImagePath: initialImagePath,
      launchContext: launchContext,
      launchErrorMessage: launchErrorMessage,
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
    this.launchContext,
    this.launchErrorMessage,
    this.openFileOverride,
    this.saveLocationOverride,
  });

  final String? initialImagePath;
  final PhotoMarkupLaunchContext? launchContext;
  final String? launchErrorMessage;
  final OpenFileCallback? openFileOverride;
  final SaveLocationCallback? saveLocationOverride;

  @override
  State<PhotoMarkupShellScreen> createState() => _PhotoMarkupShellScreenState();
}

class _PhotoMarkupShellScreenState extends State<PhotoMarkupShellScreen>
    with WidgetsBindingObserver {
  final ImageImportService _imageImportService = ImageImportService();
  static const MarkupExportPathService _markupExportPathService =
      MarkupExportPathService();
  static const EditableMarkupDocumentService _editableMarkupDocumentService =
      EditableMarkupDocumentService();
  PhotoMarkupLaunchContext? _launchContext;
  String? _imagePath;
  String? _loadedSourceImagePath;
  String? _temporaryConvertedImagePath;
  String? _loadedFileName;
  String? _errorMessage;
  bool _isPickingFile = false;
  bool _isExporting = false;
  bool _isSavingMarkupDocument = false;
  final UnsavedChangesTracker _unsavedChangesTracker = UnsavedChangesTracker();
  Size? _loadedImagePixelSize;
  final GlobalKey _canvasExportKey = GlobalKey();

  MarkupTool _selectedTool = MarkupTool.none;
  MarkupStylePresetId _selectedStylePresetId =
      MarkupStylePresets.defaultPresetId;
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
  _HandleDragSession? _activeHandleDragSession;
  bool _didMoveSelectedMarkup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _launchContext = widget.launchContext;
    _errorMessage = widget.launchErrorMessage;
    final String? initialPath = widget.initialImagePath;
    if (initialPath != null && initialPath.isNotEmpty) {
      _loadImageFromPath(initialPath, showErrorForFailure: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

      await _loadImageFromPath(selectedFile.path, requireUnsavedGuard: true);
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

  Future<bool> _loadImageFromPath(
    String path, {
    bool showErrorForFailure = true,
    bool requireUnsavedGuard = false,
  }) async {
    if (requireUnsavedGuard) {
      final bool canContinue = await _confirmUnsavedChangesBeforeContinuing();
      if (!canContinue || !mounted) {
        return false;
      }
    }

    final String extension = _fileExtension(path);
    final bool isHeicSource = ImageImportConstants.heicExtensionsSet.contains(
      extension,
    );
    if (!ImageImportConstants.supportedExtensionsSet.contains(extension)) {
      if (showErrorForFailure) {
        _setLoadError();
      }
      return false;
    }

    final File imageFile = File(path);
    if (!await imageFile.exists()) {
      if (showErrorForFailure) {
        _setLoadError();
      }
      return false;
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
      return false;
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
      return false;
    }

    final String? previousTemporaryPath = _temporaryConvertedImagePath;
    if (!mounted) {
      if (importResult.usedTemporaryConvertedCopy) {
        await _imageImportService.deleteTemporaryDisplayPath(
          importResult.displayPath,
        );
      }
      return false;
    }

    if (previousTemporaryPath != null &&
        previousTemporaryPath != importResult.displayPath) {
      await _imageImportService.deleteTemporaryDisplayPath(
        previousTemporaryPath,
      );
    }

    setState(() {
      _imagePath = importResult.displayPath;
      _loadedSourceImagePath = path;
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
      _activeHandleDragSession = null;
      _didMoveSelectedMarkup = false;
      _nextMarkupId = 1;
      _unsavedChangesTracker.markSaved();
    });
    return true;
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

    if (label == ToolbarConstants.openMarkup) {
      _openMarkupDocument();
      return;
    }

    if (label == ToolbarConstants.saveMarkup) {
      _saveMarkupDocument();
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

    if (label == ToolbarConstants.style) {
      _showStylePresetDialog();
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

  Future<bool> _exportMarkedUpImage() async {
    if (_isExporting) {
      return false;
    }

    if (_imagePath == null) {
      _showSnack(UiCopyConstants.exportNoPhotoMessage);
      return false;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final String suggestedName = _suggestedExportName();
      final String? initialDirectory = _preferredExportDirectory();
      final FileSaveLocation? saveLocation = widget.saveLocationOverride != null
          ? await widget.saveLocationOverride!(
              initialDirectory: initialDirectory,
              suggestedName: suggestedName,
              confirmButtonText: ExportConstants.saveDialogConfirmButtonText,
              acceptedTypeGroups: const <XTypeGroup>[
                ExportConstants.pngSaveTypeGroup,
              ],
            )
          : await getSaveLocation(
              initialDirectory: initialDirectory,
              suggestedName: suggestedName,
              confirmButtonText: ExportConstants.saveDialogConfirmButtonText,
              acceptedTypeGroups: const <XTypeGroup>[
                ExportConstants.pngSaveTypeGroup,
              ],
            );

      if (!mounted || saveLocation == null || saveLocation.path.isEmpty) {
        return false;
      }

      final double pixelRatio = MediaQuery.of(
        context,
      ).devicePixelRatio.clamp(1.0, ExportConstants.maxPixelRatio);
      final String outputPath = _markupExportPathService
          .buildSafeMarkupExportPath(_normalizeExportPath(saveLocation.path));
      final Rect? exportCropRect = _computeExportCropRect();
      if (exportCropRect == null || exportCropRect.isEmpty) {
        _showSnack(UiCopyConstants.exportFailureMessage);
        return false;
      }

      await MarkedUpImageExportService.exportBoundaryToPng(
        boundaryKey: _canvasExportKey,
        outputPath: outputPath,
        pixelRatio: pixelRatio,
        cropRectLogical: exportCropRect,
      );

      if (!mounted) {
        return true;
      }
      setState(() {
        _unsavedChangesTracker.markSaved();
      });
      _showSnack(UiCopyConstants.exportSuccessMessage);
      return true;
    } catch (_) {
      if (!mounted) {
        return false;
      }
      _showSnack(UiCopyConstants.exportFailureMessage);
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _openMarkupDocument() async {
    if (_isPickingFile || _isExporting || _isSavingMarkupDocument) {
      return;
    }

    final bool canContinue = await _confirmUnsavedChangesBeforeContinuing();
    if (!canContinue || !mounted) {
      return;
    }

    setState(() {
      _isPickingFile = true;
    });

    try {
      final XFile? selectedFile = await openFile(
        acceptedTypeGroups: const <XTypeGroup>[
          EditableMarkupConstants.markupOpenTypeGroup,
        ],
        confirmButtonText: EditableMarkupConstants.openDialogConfirmButtonText,
      );

      if (!mounted) {
        return;
      }
      if (selectedFile == null || selectedFile.path.trim().isEmpty) {
        setState(() {
          _isPickingFile = false;
        });
        return;
      }

      final EditableMarkupDocument document =
          await _editableMarkupDocumentService.readDocument(selectedFile.path);
      final String? sourceImagePath = await _resolveSourceImagePathForDocument(
        document,
      );
      if (!mounted) {
        return;
      }
      if (sourceImagePath == null || sourceImagePath.isEmpty) {
        setState(() {
          _isPickingFile = false;
        });
        return;
      }

      final bool imageLoaded = await _loadImageFromPath(
        sourceImagePath,
        showErrorForFailure: true,
      );
      if (!mounted) {
        return;
      }
      if (!imageLoaded) {
        setState(() {
          _isPickingFile = false;
        });
        return;
      }

      setState(() {
        _applyEditableMarkupDocument(document);
        _unsavedChangesTracker.markSaved();
        _isPickingFile = false;
      });
      _showSnack(UiCopyConstants.markupDocumentOpenSuccessMessage);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isPickingFile = false;
      });
      _showSnack(UiCopyConstants.markupDocumentOpenFailureMessage);
    }
  }

  Future<void> _saveMarkupDocument() async {
    if (_isSavingMarkupDocument || _isExporting || _isPickingFile) {
      return;
    }
    if (_imagePath == null || _loadedSourceImagePath == null) {
      _showSnack(UiCopyConstants.markupDocumentSaveNoPhotoMessage);
      return;
    }

    setState(() {
      _isSavingMarkupDocument = true;
    });

    try {
      final String suggestedName = _suggestedMarkupDocumentName();
      final String? initialDirectory = _preferredMarkupDocumentDirectory();
      final FileSaveLocation? saveLocation = await getSaveLocation(
        initialDirectory: initialDirectory,
        suggestedName: suggestedName,
        confirmButtonText: EditableMarkupConstants.saveDialogConfirmButtonText,
        acceptedTypeGroups: const <XTypeGroup>[
          EditableMarkupConstants.markupSaveTypeGroup,
        ],
      );

      if (!mounted || saveLocation == null || saveLocation.path.isEmpty) {
        return;
      }

      final EditableMarkupDocument document = _buildEditableMarkupDocument();
      final String safePath = _editableMarkupDocumentService
          .buildSafeEditableMarkupPath(
            _normalizeMarkupDocumentPath(saveLocation.path),
          );
      await _editableMarkupDocumentService.saveDocument(
        document: document,
        outputPath: safePath,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _unsavedChangesTracker.markSaved();
      });
      _showSnack(UiCopyConstants.markupDocumentSaveSuccessMessage);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(UiCopyConstants.markupDocumentSaveFailureMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isSavingMarkupDocument = false;
        });
      }
    }
  }

  EditableMarkupDocument _buildEditableMarkupDocument() {
    return EditableMarkupDocument(
      schemaVersion: EditableMarkupConstants.schemaVersion,
      appVersion: AppConstants.appVersion,
      savedAtUtc: DateTime.now().toUtc().toIso8601String(),
      sourceImagePath: _loadedSourceImagePath ?? '',
      sourceImageFileName: _loadedFileName ?? '',
      imagePixelSize: _loadedImagePixelSize,
      activeStylePresetId: _selectedStylePresetId,
      nextMarkupId: _nextMarkupId,
      dimensionLines: List<DimensionLine>.unmodifiable(_dimensionLines),
      arrows: List<ArrowMarkup>.unmodifiable(_arrows),
      rectangles: List<RectangleMarkup>.unmodifiable(_rectangles),
      ovals: List<OvalMarkup>.unmodifiable(_ovals),
      freehands: List<FreehandMarkup>.unmodifiable(_freehands),
      textNotes: List<TextNoteMarkup>.unmodifiable(_textNotes),
    );
  }

  void _applyEditableMarkupDocument(EditableMarkupDocument document) {
    _selectedStylePresetId = document.activeStylePresetId;
    _clearMarkupSelection();
    _selectedTool = MarkupTool.none;
    _activeDimensionStart = null;
    _activeDimensionCurrent = null;
    _activeFreehandPoints.clear();
    _activeMoveSession = null;
    _activeHandleDragSession = null;
    _didMoveSelectedMarkup = false;
    _dimensionLines
      ..clear()
      ..addAll(document.dimensionLines);
    _arrows
      ..clear()
      ..addAll(document.arrows);
    _rectangles
      ..clear()
      ..addAll(document.rectangles);
    _ovals
      ..clear()
      ..addAll(document.ovals);
    _freehands
      ..clear()
      ..addAll(document.freehands);
    _textNotes
      ..clear()
      ..addAll(document.textNotes);

    int maxId = 0;
    for (final DimensionLine line in _dimensionLines) {
      if (line.id > maxId) {
        maxId = line.id;
      }
    }
    for (final ArrowMarkup arrow in _arrows) {
      if (arrow.id > maxId) {
        maxId = arrow.id;
      }
    }
    for (final RectangleMarkup rectangle in _rectangles) {
      if (rectangle.id > maxId) {
        maxId = rectangle.id;
      }
    }
    for (final OvalMarkup oval in _ovals) {
      if (oval.id > maxId) {
        maxId = oval.id;
      }
    }
    for (final FreehandMarkup freehand in _freehands) {
      if (freehand.id > maxId) {
        maxId = freehand.id;
      }
    }
    for (final TextNoteMarkup note in _textNotes) {
      if (note.id > maxId) {
        maxId = note.id;
      }
    }
    _nextMarkupId = math.max(document.nextMarkupId, maxId + 1);
  }

  Future<String?> _resolveSourceImagePathForDocument(
    EditableMarkupDocument document,
  ) async {
    final String sourcePath = document.sourceImagePath.trim();
    if (sourcePath.isNotEmpty && File(sourcePath).existsSync()) {
      return sourcePath;
    }

    final String message = sourcePath.isEmpty
        ? UiCopyConstants.markupDocumentNoSourceMessage
        : UiCopyConstants.markupDocumentMissingSourceMessage;
    final bool shouldLocate = await _showLocateSourceImageDialog(message);
    if (!mounted || !shouldLocate) {
      return null;
    }
    final XFile? selectedImage = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[
        ImageImportConstants.imageTypeGroup,
      ],
      confirmButtonText: ImageImportConstants.pickerConfirmButtonText,
    );
    if (selectedImage == null || selectedImage.path.trim().isEmpty) {
      return null;
    }
    return selectedImage.path.trim();
  }

  Future<bool> _showLocateSourceImageDialog(String body) async {
    final bool? shouldLocate = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(UiCopyConstants.markupDocumentMissingSourceTitle),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(UiCopyConstants.markupDocumentCancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                UiCopyConstants.markupDocumentLocateImageButton,
              ),
            ),
          ],
        );
      },
    );
    return shouldLocate ?? false;
  }

  String _suggestedMarkupDocumentName() {
    final String sourceName =
        _loadedSourceImagePath ?? _loadedFileName ?? 'photo';
    return _editableMarkupDocumentService.buildDefaultMarkupFileName(
      sourcePathOrFileName: sourceName,
    );
  }

  String? _preferredMarkupDocumentDirectory() {
    return _editableMarkupDocumentService.resolveDefaultMarkupDirectory(
      suggestedEditableMarkupFolder:
          _launchContext?.suggestedEditableMarkupFolder,
      suggestedExportFolder: _launchContext?.suggestedExportFolder,
      sourceImagePath: _loadedSourceImagePath,
    );
  }

  String _normalizeMarkupDocumentPath(String path) {
    return _editableMarkupDocumentService.ensureEditableMarkupExtension(path);
  }

  String _suggestedExportName() {
    final String sourceName =
        _loadedSourceImagePath ?? _loadedFileName ?? 'photo';
    return _markupExportPathService.buildDefaultMarkupExportName(
      sourcePathOrFileName: sourceName,
    );
  }

  String? _preferredExportDirectory() {
    return _markupExportPathService.resolveDefaultExportDirectory(
      suggestedExportFolder: _launchContext?.suggestedExportFolder,
      sourceImagePath: _loadedSourceImagePath,
    );
  }

  String _normalizeExportPath(String path) {
    return _markupExportPathService.ensurePngExtension(path);
  }

  Rect? _computeExportCropRect() {
    final RenderObject? renderObject = _canvasExportKey.currentContext
        ?.findRenderObject();
    if (renderObject is! RenderBox || renderObject.size.isEmpty) {
      return null;
    }
    return _computeDisplayedImageRect(renderObject.size);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool get _hasUnsavedMarkupChanges => _unsavedChangesTracker.hasUnsavedChanges;

  @visibleForTesting
  bool get debugHasUnsavedMarkupChanges => _hasUnsavedMarkupChanges;

  @visibleForTesting
  void debugSetUnsavedMarkupChanges(bool value) {
    if (value) {
      _unsavedChangesTracker.markDirty();
    } else {
      _unsavedChangesTracker.markSaved();
    }
  }

  Future<bool> _confirmUnsavedChangesBeforeContinuing() async {
    if (!_hasUnsavedMarkupChanges) {
      return true;
    }

    final _UnsavedChangesDecision? decision = await _showUnsavedChangesDialog();
    if (!mounted || decision == null) {
      return false;
    }

    if (decision == _UnsavedChangesDecision.cancel) {
      return false;
    }

    if (decision == _UnsavedChangesDecision.discard) {
      setState(() {
        _unsavedChangesTracker.markSaved();
      });
      return true;
    }

    final bool exported = await _exportMarkedUpImage();
    return exported && !_hasUnsavedMarkupChanges;
  }

  Future<_UnsavedChangesDecision?> _showUnsavedChangesDialog() {
    return showDialog<_UnsavedChangesDecision>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(UiCopyConstants.unsavedChangesWarningTitle),
          content: const Text(UiCopyConstants.unsavedChangesWarningBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_UnsavedChangesDecision.cancel),
              child: const Text(UiCopyConstants.unsavedChangesCancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_UnsavedChangesDecision.discard),
              child: const Text(UiCopyConstants.unsavedChangesDiscardButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_UnsavedChangesDecision.export),
              child: const Text(UiCopyConstants.unsavedChangesExportButton),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onShellWillPop() async {
    final ui.AppExitResponse response = await _resolveAppExitRequest();
    return response == ui.AppExitResponse.exit;
  }

  Future<ui.AppExitResponse> _resolveAppExitRequest() async {
    if (!mounted) {
      return ui.AppExitResponse.cancel;
    }
    final bool canClose = await _confirmUnsavedChangesBeforeContinuing();
    if (canClose) {
      return ui.AppExitResponse.exit;
    }
    return ui.AppExitResponse.cancel;
  }

  @override
  Future<ui.AppExitResponse> didRequestAppExit() async {
    return _resolveAppExitRequest();
  }

  bool get _showLaunchContextBanner =>
      _launchContext != null && _launchContext!.hasAnyContext;

  String _buildLaunchContextSummary() {
    final PhotoMarkupLaunchContext? context = _launchContext;
    if (context == null) {
      return '';
    }
    final List<String> parts = <String>[];
    if (context.sourceLabel != null && context.sourceLabel!.isNotEmpty) {
      parts.add(
        '${UiCopyConstants.launchContextSourceLabelPrefix}: ${context.sourceLabel}',
      );
    } else if (context.launchedFromControlCenter) {
      parts.add(UiCopyConstants.launchContextLabelPrefix);
    }
    if (context.clientName != null && context.clientName!.isNotEmpty) {
      parts.add(
        '${UiCopyConstants.launchContextClientLabelPrefix}: ${context.clientName}',
      );
    }
    if (context.projectCode != null && context.projectCode!.isNotEmpty) {
      parts.add(
        '${UiCopyConstants.launchContextProjectLabelPrefix}: ${context.projectCode}',
      );
    }
    if (parts.isEmpty) {
      return UiCopyConstants.launchContextLabelPrefix;
    }
    return parts.join(' • ');
  }

  MarkupStylePreset get _selectedStylePreset =>
      MarkupStylePresets.byId(_selectedStylePresetId);

  bool get _hasSelectedMarkup =>
      _selectedDimensionId != null ||
      _selectedArrowId != null ||
      _selectedRectangleId != null ||
      _selectedOvalId != null ||
      _selectedFreehandId != null ||
      _selectedTextNoteId != null;

  Future<void> _showStylePresetDialog() async {
    final MarkupStylePresetId? selected = await showDialog<MarkupStylePresetId>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(UiCopyConstants.styleDialogTitle),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final MarkupStylePreset preset in MarkupStylePresets.all)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: preset.dimensionLineColor,
                    ),
                    title: Text(preset.label),
                    trailing: preset.id == _selectedStylePresetId
                        ? const Icon(Icons.check, size: 18)
                        : null,
                    onTap: () => Navigator.of(context).pop(preset.id),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _selectedStylePresetId = selected;
      _applyStylePresetToSelectedMarkup(selected);
      if (_hasSelectedMarkup) {
        _unsavedChangesTracker.markDirty();
      }
    });
    if (_hasSelectedMarkup) {
      _showSnack(UiCopyConstants.styleApplyToSelectedMessage);
    }
  }

  void _applyStylePresetToSelectedMarkup(MarkupStylePresetId stylePresetId) {
    final int? selectedDimensionId = _selectedDimensionId;
    if (selectedDimensionId != null) {
      final int index = _dimensionLines.indexWhere(
        (DimensionLine line) => line.id == selectedDimensionId,
      );
      if (index != -1) {
        _dimensionLines[index] = _dimensionLines[index].copyWith(
          stylePresetId: stylePresetId,
        );
      }
      return;
    }

    final int? selectedArrowId = _selectedArrowId;
    if (selectedArrowId != null) {
      final int index = _arrows.indexWhere(
        (ArrowMarkup arrow) => arrow.id == selectedArrowId,
      );
      if (index != -1) {
        _arrows[index] = _arrows[index].copyWith(stylePresetId: stylePresetId);
      }
      return;
    }

    final int? selectedRectangleId = _selectedRectangleId;
    if (selectedRectangleId != null) {
      final int index = _rectangles.indexWhere(
        (RectangleMarkup rectangle) => rectangle.id == selectedRectangleId,
      );
      if (index != -1) {
        _rectangles[index] = _rectangles[index].copyWith(
          stylePresetId: stylePresetId,
        );
      }
      return;
    }

    final int? selectedOvalId = _selectedOvalId;
    if (selectedOvalId != null) {
      final int index = _ovals.indexWhere(
        (OvalMarkup oval) => oval.id == selectedOvalId,
      );
      if (index != -1) {
        _ovals[index] = _ovals[index].copyWith(stylePresetId: stylePresetId);
      }
      return;
    }

    final int? selectedFreehandId = _selectedFreehandId;
    if (selectedFreehandId != null) {
      final int index = _freehands.indexWhere(
        (FreehandMarkup freehand) => freehand.id == selectedFreehandId,
      );
      if (index != -1) {
        _freehands[index] = _freehands[index].copyWith(
          stylePresetId: stylePresetId,
        );
      }
      return;
    }

    final int? selectedTextNoteId = _selectedTextNoteId;
    if (selectedTextNoteId != null) {
      final int index = _textNotes.indexWhere(
        (TextNoteMarkup note) => note.id == selectedTextNoteId,
      );
      if (index != -1) {
        _textNotes[index] = _textNotes[index].copyWith(
          stylePresetId: stylePresetId,
        );
      }
    }
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
    _activeHandleDragSession = null;
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
      _unsavedChangesTracker.markDirty();
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
        _unsavedChangesTracker.markDirty();
      });
      return;
    }

    final int? selectedArrowId = _selectedArrowId;
    if (selectedArrowId != null) {
      setState(() {
        _arrows.removeWhere((ArrowMarkup arrow) => arrow.id == selectedArrowId);
        _clearMarkupSelection();
        _unsavedChangesTracker.markDirty();
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
        _unsavedChangesTracker.markDirty();
      });
      return;
    }

    final int? selectedOvalId = _selectedOvalId;
    if (selectedOvalId != null) {
      setState(() {
        _ovals.removeWhere((OvalMarkup oval) => oval.id == selectedOvalId);
        _clearMarkupSelection();
        _unsavedChangesTracker.markDirty();
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
        _unsavedChangesTracker.markDirty();
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
        _unsavedChangesTracker.markDirty();
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
    if (_tryStartHandleDrag(startPoint, imageRect)) {
      return;
    }
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
    if (_activeHandleDragSession != null) {
      _updateHandleDrag(currentPoint, imageRect);
      return;
    }
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
    if (_activeHandleDragSession != null) {
      _activeHandleDragSession = null;
      return;
    }
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
        stylePresetId: _selectedStylePresetId,
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
          _unsavedChangesTracker.markDirty();
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
        stylePresetId: _selectedStylePresetId,
      );
      if (mounted) {
        setState(() {
          _freehands.add(freehand);
          _selectFreehandById(freehand.id);
          _unsavedChangesTracker.markDirty();
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
        stylePresetId: _selectedStylePresetId,
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
          _unsavedChangesTracker.markDirty();
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
        stylePresetId: _selectedStylePresetId,
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
          _unsavedChangesTracker.markDirty();
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
        stylePresetId: _selectedStylePresetId,
      );

      int? newLineId;
      setState(() {
        if (line.lengthInRect(imageRect) >=
            UiLayoutConstants.dimensionTapDragMinDistance) {
          _dimensionLines.add(line);
          newLineId = line.id;
          _selectDimensionById(line.id);
          _unsavedChangesTracker.markDirty();
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
      _unsavedChangesTracker.markDirty();
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
      stylePresetId: _selectedStylePresetId,
    );
    setState(() {
      _textNotes.add(note);
      _selectTextNoteById(note.id);
      _unsavedChangesTracker.markDirty();
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
        _unsavedChangesTracker.markDirty();
      });
      return;
    }

    setState(() {
      _textNotes[refreshIndex] = _textNotes[refreshIndex].copyWith(
        text: trimmed,
      );
      _selectTextNoteById(noteId);
      _unsavedChangesTracker.markDirty();
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

  bool _tryStartHandleDrag(Offset point, Rect imageRect) {
    final int? selectedDimensionId = _selectedDimensionId;
    if (selectedDimensionId != null) {
      final int index = _dimensionLines.indexWhere(
        (DimensionLine line) => line.id == selectedDimensionId,
      );
      if (index != -1) {
        final DimensionLine line = _dimensionLines[index];
        final Offset start = line.startInRect(imageRect);
        final Offset end = line.endInRect(imageRect);
        if ((point - start).distance <= MarkupHandleConstants.hitDistance) {
          _activeHandleDragSession = _HandleDragSession(
            markupId: selectedDimensionId,
            handleKind: _HandleKind.dimensionStart,
            startPoint: point,
          );
          return true;
        }
        if ((point - end).distance <= MarkupHandleConstants.hitDistance) {
          _activeHandleDragSession = _HandleDragSession(
            markupId: selectedDimensionId,
            handleKind: _HandleKind.dimensionEnd,
            startPoint: point,
          );
          return true;
        }
      }
    }

    final int? selectedArrowId = _selectedArrowId;
    if (selectedArrowId != null) {
      final int index = _arrows.indexWhere(
        (ArrowMarkup arrow) => arrow.id == selectedArrowId,
      );
      if (index != -1) {
        final ArrowMarkup arrow = _arrows[index];
        final Offset start = arrow.startInRect(imageRect);
        final Offset end = arrow.endInRect(imageRect);
        if ((point - start).distance <= MarkupHandleConstants.hitDistance) {
          _activeHandleDragSession = _HandleDragSession(
            markupId: selectedArrowId,
            handleKind: _HandleKind.arrowStart,
            startPoint: point,
          );
          return true;
        }
        if ((point - end).distance <= MarkupHandleConstants.hitDistance) {
          _activeHandleDragSession = _HandleDragSession(
            markupId: selectedArrowId,
            handleKind: _HandleKind.arrowEnd,
            startPoint: point,
          );
          return true;
        }
      }
    }

    final int? selectedRectangleId = _selectedRectangleId;
    if (selectedRectangleId != null) {
      final int index = _rectangles.indexWhere(
        (RectangleMarkup rectangle) => rectangle.id == selectedRectangleId,
      );
      if (index != -1) {
        final Rect rect = _rectangles[index].rectInRect(imageRect);
        final int? cornerIndex = MarkupHandleUtils.hitCornerIndex(
          point,
          corners: MarkupHandleUtils.rectangleCorners(rect),
          hitDistance: MarkupHandleConstants.hitDistance,
        );
        if (cornerIndex != null) {
          _activeHandleDragSession = _HandleDragSession(
            markupId: selectedRectangleId,
            handleKind: _HandleKind.rectangleCorner,
            cornerIndex: cornerIndex,
            startPoint: point,
          );
          return true;
        }
      }
    }

    final int? selectedOvalId = _selectedOvalId;
    if (selectedOvalId != null) {
      final int index = _ovals.indexWhere(
        (OvalMarkup oval) => oval.id == selectedOvalId,
      );
      if (index != -1) {
        final Rect rect = _ovals[index].rectInRect(imageRect);
        final int? cornerIndex = MarkupHandleUtils.hitCornerIndex(
          point,
          corners: MarkupHandleUtils.rectangleCorners(rect),
          hitDistance: MarkupHandleConstants.hitDistance,
        );
        if (cornerIndex != null) {
          _activeHandleDragSession = _HandleDragSession(
            markupId: selectedOvalId,
            handleKind: _HandleKind.ovalCorner,
            cornerIndex: cornerIndex,
            startPoint: point,
          );
          return true;
        }
      }
    }

    return false;
  }

  void _updateHandleDrag(Offset currentPoint, Rect imageRect) {
    final _HandleDragSession? handleSession = _activeHandleDragSession;
    if (handleSession == null) {
      return;
    }
    final Offset clampedPoint = DimensionLine.clampToRect(
      currentPoint,
      imageRect,
    );
    final double travelDistance =
        (clampedPoint - handleSession.startPoint).distance;
    if (!handleSession.isDragActive &&
        travelDistance < MarkupHandleConstants.dragActivationDistance) {
      return;
    }
    handleSession.isDragActive = true;

    bool changed = false;
    switch (handleSession.handleKind) {
      case _HandleKind.dimensionStart:
        changed = _adjustDimensionEndpoint(
          markupId: handleSession.markupId,
          imageRect: imageRect,
          moveStart: true,
          point: clampedPoint,
        );
        break;
      case _HandleKind.dimensionEnd:
        changed = _adjustDimensionEndpoint(
          markupId: handleSession.markupId,
          imageRect: imageRect,
          moveStart: false,
          point: clampedPoint,
        );
        break;
      case _HandleKind.arrowStart:
        changed = _adjustArrowEndpoint(
          markupId: handleSession.markupId,
          imageRect: imageRect,
          moveStart: true,
          point: clampedPoint,
        );
        break;
      case _HandleKind.arrowEnd:
        changed = _adjustArrowEndpoint(
          markupId: handleSession.markupId,
          imageRect: imageRect,
          moveStart: false,
          point: clampedPoint,
        );
        break;
      case _HandleKind.rectangleCorner:
        changed = _resizeRectangleFromCorner(
          markupId: handleSession.markupId,
          cornerIndex: handleSession.cornerIndex!,
          imageRect: imageRect,
          point: clampedPoint,
        );
        break;
      case _HandleKind.ovalCorner:
        changed = _resizeOvalFromCorner(
          markupId: handleSession.markupId,
          cornerIndex: handleSession.cornerIndex!,
          imageRect: imageRect,
          point: clampedPoint,
        );
        break;
    }
    if (changed) {
      _didMoveSelectedMarkup = true;
    }
  }

  bool _adjustDimensionEndpoint({
    required int markupId,
    required Rect imageRect,
    required bool moveStart,
    required Offset point,
  }) {
    final int index = _dimensionLines.indexWhere(
      (DimensionLine line) => line.id == markupId,
    );
    if (index == -1) {
      return false;
    }
    final DimensionLine line = _dimensionLines[index];
    final Offset start = moveStart ? point : line.startInRect(imageRect);
    final Offset end = moveStart ? line.endInRect(imageRect) : point;
    final DimensionLine updated = DimensionLine.fromCanvasPoints(
      id: line.id,
      startPoint: start,
      endPoint: end,
      imageRect: imageRect,
      stylePresetId: line.stylePresetId,
    ).copyWith(label: line.label);
    if (updated == line) {
      return false;
    }
    setState(() {
      _dimensionLines[index] = updated;
      _unsavedChangesTracker.markDirty();
    });
    return true;
  }

  bool _adjustArrowEndpoint({
    required int markupId,
    required Rect imageRect,
    required bool moveStart,
    required Offset point,
  }) {
    final int index = _arrows.indexWhere(
      (ArrowMarkup arrow) => arrow.id == markupId,
    );
    if (index == -1) {
      return false;
    }
    final ArrowMarkup arrow = _arrows[index];
    final Offset start = moveStart ? point : arrow.startInRect(imageRect);
    final Offset end = moveStart ? arrow.endInRect(imageRect) : point;
    final ArrowMarkup updated = ArrowMarkup.fromCanvasPoints(
      id: arrow.id,
      startPoint: start,
      endPoint: end,
      imageRect: imageRect,
      stylePresetId: arrow.stylePresetId,
    );
    if (updated == arrow) {
      return false;
    }
    setState(() {
      _arrows[index] = updated;
      _unsavedChangesTracker.markDirty();
    });
    return true;
  }

  bool _resizeRectangleFromCorner({
    required int markupId,
    required int cornerIndex,
    required Rect imageRect,
    required Offset point,
  }) {
    final int index = _rectangles.indexWhere(
      (RectangleMarkup rectangle) => rectangle.id == markupId,
    );
    if (index == -1) {
      return false;
    }
    final RectangleMarkup rectangle = _rectangles[index];
    final Rect resized = MarkupHandleUtils.resizeRectFromCorner(
      currentRect: rectangle.rectInRect(imageRect),
      cornerIndex: cornerIndex,
      dragPoint: point,
      bounds: imageRect,
      minWidth: RectangleMarkupConstants.minSideLength,
      minHeight: RectangleMarkupConstants.minSideLength,
    );
    final RectangleMarkup updated = RectangleMarkup.fromCanvasPoints(
      id: rectangle.id,
      startPoint: resized.topLeft,
      endPoint: resized.bottomRight,
      imageRect: imageRect,
      stylePresetId: rectangle.stylePresetId,
    );
    if (updated == rectangle) {
      return false;
    }
    setState(() {
      _rectangles[index] = updated;
      _unsavedChangesTracker.markDirty();
    });
    return true;
  }

  bool _resizeOvalFromCorner({
    required int markupId,
    required int cornerIndex,
    required Rect imageRect,
    required Offset point,
  }) {
    final int index = _ovals.indexWhere(
      (OvalMarkup oval) => oval.id == markupId,
    );
    if (index == -1) {
      return false;
    }
    final OvalMarkup oval = _ovals[index];
    final Rect resized = MarkupHandleUtils.resizeRectFromCorner(
      currentRect: oval.rectInRect(imageRect),
      cornerIndex: cornerIndex,
      dragPoint: point,
      bounds: imageRect,
      minWidth: OvalMarkupConstants.minAxisLength,
      minHeight: OvalMarkupConstants.minAxisLength,
    );
    final OvalMarkup updated = OvalMarkup.fromCanvasPoints(
      id: oval.id,
      startPoint: resized.topLeft,
      endPoint: resized.bottomRight,
      imageRect: imageRect,
      stylePresetId: oval.stylePresetId,
    );
    if (updated == oval) {
      return false;
    }
    setState(() {
      _ovals[index] = updated;
      _unsavedChangesTracker.markDirty();
    });
    return true;
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
      stylePresetId: line.stylePresetId,
    ).copyWith(label: line.label);
    setState(() {
      _dimensionLines[index] = movedLine;
      _unsavedChangesTracker.markDirty();
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
      stylePresetId: arrow.stylePresetId,
    );
    setState(() {
      _arrows[index] = movedArrow;
      _unsavedChangesTracker.markDirty();
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
      stylePresetId: rectangle.stylePresetId,
    );
    setState(() {
      _rectangles[index] = movedRectangle;
      _unsavedChangesTracker.markDirty();
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
      stylePresetId: oval.stylePresetId,
    );
    setState(() {
      _ovals[index] = movedOval;
      _unsavedChangesTracker.markDirty();
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
      stylePresetId: freehand.stylePresetId,
    );
    setState(() {
      _freehands[index] = movedFreehand;
      _unsavedChangesTracker.markDirty();
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
      stylePresetId: note.stylePresetId,
    );
    setState(() {
      _textNotes[index] = movedNote;
      _unsavedChangesTracker.markDirty();
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
      child: PopScope<void>(
        canPop: !_hasUnsavedMarkupChanges,
        onPopInvokedWithResult: (bool didPop, void _) async {
          final NavigatorState navigator = Navigator.of(context);
          if (didPop) {
            return;
          }
          final bool canClose = await _onShellWillPop();
          if (canClose && mounted) {
            navigator.pop();
          }
        },
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
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
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
              if (_showLaunchContextBanner)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal:
                        UiLayoutConstants.launchContextBannerHorizontalPadding,
                    vertical:
                        UiLayoutConstants.launchContextBannerVerticalPadding,
                  ),
                  color: AppThemeConstants.toolbarBackground,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.link,
                        size: UiLayoutConstants.launchContextBannerFontSize + 2,
                        color: AppThemeConstants.ncdBlue,
                      ),
                      const SizedBox(
                        width: UiLayoutConstants.launchContextBannerGap,
                      ),
                      Expanded(
                        child: Text(
                          _buildLaunchContextSummary(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize:
                                UiLayoutConstants.launchContextBannerFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                          child: Builder(
                            builder: (BuildContext context) {
                              final String displayLabel =
                                  label == ToolbarConstants.style
                                  ? '${ToolbarConstants.style}: ${_selectedStylePreset.shortLabel}'
                                  : label;
                              return _ToolbarActionButton(
                                label: displayLabel,
                                isSelected:
                                    (label == ToolbarConstants.dimension &&
                                        _selectedTool ==
                                            MarkupTool.dimension) ||
                                    (label == ToolbarConstants.arrow &&
                                        _selectedTool == MarkupTool.arrow) ||
                                    (label == ToolbarConstants.circle &&
                                        _selectedTool == MarkupTool.oval) ||
                                    (label == ToolbarConstants.rectangle &&
                                        _selectedTool ==
                                            MarkupTool.rectangle) ||
                                    (label == ToolbarConstants.freehand &&
                                        _selectedTool == MarkupTool.freehand) ||
                                    (label == ToolbarConstants.textNote &&
                                        _selectedTool == MarkupTool.textNote),
                                isDisabled:
                                    (label == ToolbarConstants.saveMarkup &&
                                        _isSavingMarkupDocument) ||
                                    (label == ToolbarConstants.undo &&
                                        !_isUndoEnabled()) ||
                                    (label == ToolbarConstants.export &&
                                        _isExporting),
                                onPressed: () => _onToolbarPressed(label),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                        activeStylePresetId: _selectedStylePresetId,
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

enum _UnsavedChangesDecision { export, discard, cancel }

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

enum _HandleKind {
  dimensionStart,
  dimensionEnd,
  arrowStart,
  arrowEnd,
  rectangleCorner,
  ovalCorner,
}

class _HandleDragSession {
  _HandleDragSession({
    required this.markupId,
    required this.handleKind,
    required this.startPoint,
    this.cornerIndex,
  });

  final int markupId;
  final _HandleKind handleKind;
  final Offset startPoint;
  final int? cornerIndex;
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
