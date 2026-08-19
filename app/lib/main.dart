import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/export/services/markup_export_path_service.dart';
import 'package:ncd_photo_markup/features/export/services/full_resolution_export_service.dart';
import 'package:ncd_photo_markup/features/integration/models/photo_markup_launch_context.dart';
import 'package:ncd_photo_markup/features/integration/services/launch_context_service.dart';
import 'package:ncd_photo_markup/features/import/services/dwg_preview_conversion_service.dart';
import 'package:ncd_photo_markup/features/import/services/image_import_service.dart';
import 'package:ncd_photo_markup/features/import/utils/load_error_visibility_policy.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/blur_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/callout_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/editable_markup_document.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_snapshot.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/markup/services/editable_markup_document_service.dart';
import 'package:ncd_photo_markup/features/markup/services/markup_history.dart';
import 'package:ncd_photo_markup/features/markup/utils/dimension_label_formatter.dart';
import 'package:ncd_photo_markup/features/markup/utils/freehand_smoothing.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_handle_utils.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_interaction_policy.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_move_utils.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_text_layout_utils.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_typography_utils.dart';
import 'package:ncd_photo_markup/features/markup/rendering/markup_scene_renderer.dart';
import 'package:ncd_photo_markup/features/markup/utils/unsaved_changes_tracker.dart';
import 'package:ncd_photo_markup/features/markup/widgets/blur_regions_layer.dart';
import 'package:ncd_photo_markup/features/markup/widgets/dimension_lines_overlay.dart';
import 'package:ncd_photo_markup/features/sidebar/models/sidebar_icon_pack.dart';
import 'package:ncd_photo_markup/features/view/utils/canvas_view_transform_utils.dart';

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
  bool _isShowingLoadErrorDialog = false;
  final UnsavedChangesTracker _unsavedChangesTracker = UnsavedChangesTracker();
  final MarkupHistory _history = MarkupHistory();
  MarkupSnapshot? _gestureSnapshot;
  Size? _loadedImagePixelSize;
  final GlobalKey _canvasExportKey = GlobalKey();
  final TransformationController _canvasTransformController =
      TransformationController();

  MarkupTool _selectedTool = MarkupTool.none;
  bool _isSidebarExpanded = false;
  bool _isPanModeEnabled = false;
  double _viewScale = ViewControlConstants.defaultScale;
  MarkupStylePresetId _selectedStylePresetId =
      MarkupStylePresets.defaultPresetId;
  String _selectedFontFamily = MarkupTypographyConstants.defaultFontFamily;
  double _selectedFontSize = MarkupTypographyConstants.defaultFontSize;
  double _selectedStrokeWidthScale = MarkupStrokeConstants.defaultScale;
  bool _selectedShapeFilled = false;
  final List<DimensionLine> _dimensionLines = <DimensionLine>[];
  final List<ArrowMarkup> _arrows = <ArrowMarkup>[];
  final List<RectangleMarkup> _rectangles = <RectangleMarkup>[];
  final List<OvalMarkup> _ovals = <OvalMarkup>[];
  final List<FreehandMarkup> _freehands = <FreehandMarkup>[];
  final List<TextNoteMarkup> _textNotes = <TextNoteMarkup>[];
  final List<CalloutMarkup> _callouts = <CalloutMarkup>[];
  final List<BlurMarkup> _blurs = <BlurMarkup>[];
  int? _selectedDimensionId;
  int? _selectedArrowId;
  int? _selectedRectangleId;
  int? _selectedOvalId;
  int? _selectedFreehandId;
  int? _selectedTextNoteId;
  int? _selectedCalloutId;
  int? _selectedBlurId;
  CalloutLabelStyle _calloutLabelStyle = CalloutLabelStyle.numbers;
  int _nextMarkupId = 1;
  Offset? _activeDimensionStart;
  Offset? _activeDimensionCurrent;
  final List<Offset> _activeFreehandPoints = <Offset>[];
  _MoveSession? _activeMoveSession;
  _HandleDragSession? _activeHandleDragSession;
  bool _didMoveSelectedMarkup = false;
  bool _suppressTapActionAfterPointerDownSelection = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _launchContext = widget.launchContext;
    _errorMessage = widget.launchErrorMessage;
    if (widget.launchErrorMessage != null &&
        widget.launchErrorMessage!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        unawaited(_showLoadErrorDialog(widget.launchErrorMessage!));
      });
    }
    final String? initialPath = widget.initialImagePath;
    if (initialPath != null && initialPath.isNotEmpty) {
      _loadImageFromPath(initialPath, showErrorForFailure: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _canvasTransformController.dispose();
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
    final Stopwatch importStopwatch = Stopwatch()..start();
    if (requireUnsavedGuard) {
      final bool canContinue = await _confirmUnsavedChangesBeforeContinuing();
      if (!canContinue || !mounted) {
        _logImportDebug('load canceled by unsaved-change guard');
        return false;
      }
    }

    final String extension = _fileExtension(path);
    if (!ImageImportConstants.supportedExtensionsSet.contains(extension)) {
      if (showErrorForFailure) {
        _setLoadError();
      }
      _logImportDebug('load rejected unsupported extension=$extension');
      return false;
    }

    final File imageFile = File(path);
    if (!await imageFile.exists()) {
      if (showErrorForFailure) {
        _setLoadError();
      }
      _logImportDebug('load rejected missing file path=$path');
      return false;
    }

    late final ImageImportResult importResult;
    try {
      importResult = await _imageImportService.prepareDisplayableImage(
        sourcePath: path,
      );
    } catch (error) {
      if (showErrorForFailure) {
        _setLoadError(message: _importFailureMessage(extension, error));
      }
      _logImportDebug('prepareDisplayableImage failed for path=$path');
      return false;
    }

    final Stopwatch decodeStopwatch = Stopwatch()..start();
    final Size? imageSize = await _readImagePixelSize(importResult.displayPath);
    decodeStopwatch.stop();
    if (imageSize == null) {
      if (importResult.usedTemporaryConvertedCopy) {
        await _imageImportService.deleteTemporaryDisplayPath(
          importResult.displayPath,
        );
      }
      if (showErrorForFailure) {
        _setLoadError(message: _fallbackImportFailureMessage(extension));
      }
      _logImportDebug(
        'image decode failed for displayPath=${importResult.displayPath}',
      );
      return false;
    }

    final String? previousImagePath = _imagePath;
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
    await _evictImageFromCache(previousImagePath);
    await _evictImageFromCache(previousTemporaryPath);

    setState(() {
      _imagePath = importResult.displayPath;
      _loadedSourceImagePath = path;
      _temporaryConvertedImagePath = importResult.usedTemporaryConvertedCopy
          ? importResult.displayPath
          : null;
      _loadedFileName = _fileNameFromPath(path);
      _loadedImagePixelSize = imageSize;
      _errorMessage = null;
      _isPanModeEnabled = false;
      _canvasTransformController.value = Matrix4.identity();
      _viewScale = ViewControlConstants.defaultScale;
      _clearMarkupSelection();
      _activeDimensionStart = null;
      _activeDimensionCurrent = null;
      _dimensionLines.clear();
      _arrows.clear();
      _rectangles.clear();
      _ovals.clear();
      _freehands.clear();
      _textNotes.clear();
      _callouts.clear();
      _blurs.clear();
      _activeFreehandPoints.clear();
      _activeMoveSession = null;
      _activeHandleDragSession = null;
      _didMoveSelectedMarkup = false;
      _nextMarkupId = 1;
      _resetMarkupHistory();
      _unsavedChangesTracker.markSaved();
    });
    importStopwatch.stop();
    _logImportDebug(
      'load complete extension=$extension '
      'decodeMs=${decodeStopwatch.elapsedMilliseconds} '
      'totalMs=${importStopwatch.elapsedMilliseconds} '
      'displayPath=${importResult.displayPath}',
    );
    return true;
  }

  Future<Size?> _readImagePixelSize(String imagePath) async {
    try {
      final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromFilePath(
        imagePath,
      );
      final ui.ImageDescriptor descriptor = await ui.ImageDescriptor.encoded(
        buffer,
      );
      final Size size = Size(
        descriptor.width.toDouble(),
        descriptor.height.toDouble(),
      );
      descriptor.dispose();
      buffer.dispose();
      return size;
    } catch (_) {
      return null;
    }
  }

  Future<void> _evictImageFromCache(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    try {
      final ImageProvider provider = FileImage(File(path));
      await provider.evict();
    } catch (_) {
      // Best-effort cache cleanup only.
    }
  }

  void _logImportDebug(String message) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('${ImageImportConstants.importDiagnosticsPrefix} $message');
  }

  void _setLoadError({String? message}) {
    final String resolvedMessage =
        message ?? ImageImportConstants.openErrorMessage;
    final bool hasLoadedImage =
        _loadedSourceImagePath != null && _imagePath != null;
    setState(() {
      if (!hasLoadedImage) {
        _imagePath = null;
        _loadedSourceImagePath = null;
        _temporaryConvertedImagePath = null;
        _loadedFileName = null;
        _loadedImagePixelSize = null;
      }
      _errorMessage = resolvedMessage;
      _isPickingFile = false;
    });
    if (!hasLoadedImage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        unawaited(_showLoadErrorDialog(resolvedMessage));
      });
      return;
    }
    if (LoadErrorVisibilityPolicy.shouldShowSnackBar(imagePath: _imagePath)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _showSnack(resolvedMessage);
      });
    }
  }

  String _importFailureMessage(String extension, Object error) {
    if (error is ImageImportFailure) {
      return error.message;
    }
    return _fallbackImportFailureMessage(extension);
  }

  String _fallbackImportFailureMessage(String extension) {
    if (ImageImportConstants.heicExtensionsSet.contains(extension)) {
      return ImageImportConstants.heicConversionFailedMessage;
    }
    if (ImageImportConstants.dwgExtensionsSet.contains(extension)) {
      return ImageImportConstants.dwgPreviewUnavailableMessage;
    }
    return ImageImportConstants.openErrorMessage;
  }

  double get _normalizedViewScale =>
      CanvasViewTransformUtils.clampScale(_viewScale);

  bool get _isZoomedCanvas =>
      (_normalizedViewScale - ViewControlConstants.defaultScale).abs() >
      ViewControlConstants.scaleEpsilon;

  int get _zoomPercent =>
      CanvasViewTransformUtils.zoomPercent(_normalizedViewScale);

  void _syncViewScaleFromController({bool force = false}) {
    final double nextScale = CanvasViewTransformUtils.clampScale(
      _canvasTransformController.value.getMaxScaleOnAxis(),
    );
    if (!force &&
        (nextScale - _viewScale).abs() <= ViewControlConstants.scaleEpsilon) {
      return;
    }
    setState(() {
      _viewScale = nextScale;
    });
  }

  Offset _currentCanvasCenter() {
    final BuildContext? context = _canvasExportKey.currentContext;
    if (context == null) {
      return Offset.zero;
    }
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) {
      return Offset.zero;
    }
    return renderObject.size.center(Offset.zero);
  }

  void _setCanvasScale(double targetScale, {Offset? focalPoint}) {
    if (_imagePath == null) {
      return;
    }
    final double clampedTarget = CanvasViewTransformUtils.clampScale(
      targetScale,
    );
    final double currentScale = CanvasViewTransformUtils.clampScale(
      _canvasTransformController.value.getMaxScaleOnAxis(),
    );
    if ((clampedTarget - currentScale).abs() <=
        ViewControlConstants.scaleEpsilon) {
      return;
    }
    final Offset localFocal = focalPoint ?? _currentCanvasCenter();
    final Offset sceneFocal = _canvasTransformController.toScene(localFocal);
    final double zoomDelta = clampedTarget / currentScale;
    // ignore: deprecated_member_use
    final Matrix4 nextTransform = _canvasTransformController.value.clone()
      // ignore: deprecated_member_use
      ..translate(sceneFocal.dx, sceneFocal.dy)
      // ignore: deprecated_member_use
      ..scale(zoomDelta)
      // ignore: deprecated_member_use
      ..translate(-sceneFocal.dx, -sceneFocal.dy);
    _canvasTransformController.value = nextTransform;
    _syncViewScaleFromController(force: true);
  }

  void _zoomInView() {
    _setCanvasScale(CanvasViewTransformUtils.zoomInStep(_normalizedViewScale));
  }

  void _zoomOutView() {
    _setCanvasScale(CanvasViewTransformUtils.zoomOutStep(_normalizedViewScale));
  }

  void _setCanvasViewActualSize() {
    _setCanvasScale(ViewControlConstants.defaultScale);
  }

  void _fitCanvasToScreen() {
    _canvasTransformController.value = Matrix4.identity();
    _syncViewScaleFromController(force: true);
  }

  void _togglePanMode() {
    setState(() {
      _isPanModeEnabled = !_isPanModeEnabled;
    });
  }

  @visibleForTesting
  void debugSetPanModeEnabled(bool enabled) {
    setState(() {
      _isPanModeEnabled = enabled;
    });
  }

  @visibleForTesting
  bool get debugIsPanModeEnabled => _isPanModeEnabled;

  @visibleForTesting
  MarkupTool get debugSelectedTool => _selectedTool;

  @visibleForTesting
  int? get debugSelectedDimensionId => _selectedDimensionId;

  @visibleForTesting
  List<DimensionLine> get debugDimensionLinesSnapshot =>
      List<DimensionLine>.unmodifiable(_dimensionLines);

  @visibleForTesting
  List<ArrowMarkup> get debugArrowsSnapshot =>
      List<ArrowMarkup>.unmodifiable(_arrows);

  @visibleForTesting
  void debugSeedLoadedImageState({
    String path = 'debug.png',
    Size pixelSize = const Size(1200, 900),
  }) {
    setState(() {
      _imagePath = path;
      _loadedSourceImagePath = path;
      _loadedFileName = _fileNameFromPath(path);
      _loadedImagePixelSize = pixelSize;
      _errorMessage = null;
    });
  }

  @visibleForTesting
  void debugSetDimensionLines(List<DimensionLine> lines, {int? selectedId}) {
    setState(() {
      _dimensionLines
        ..clear()
        ..addAll(lines);
      if (selectedId != null) {
        _selectDimensionById(selectedId);
      } else if (_selectedDimensionId != null &&
          !_dimensionLines.any(
            (DimensionLine line) => line.id == _selectedDimensionId,
          )) {
        _clearMarkupSelection();
      }
    });
  }

  @visibleForTesting
  void debugSetArrows(List<ArrowMarkup> arrows, {int? selectedId}) {
    setState(() {
      _arrows
        ..clear()
        ..addAll(arrows);
      if (selectedId != null) {
        _selectArrowById(selectedId);
      } else if (_selectedArrowId != null &&
          !_arrows.any((ArrowMarkup arrow) => arrow.id == _selectedArrowId)) {
        _clearMarkupSelection();
      }
    });
  }

  @visibleForTesting
  Rect? debugCurrentImageRect() => _computeExportCropRect();

  @visibleForTesting
  int get debugMarkupCount => _snapshotMarkup().markupCount;

  @visibleForTesting
  Object get debugMarkupFingerprint => _snapshotMarkup();

  @visibleForTesting
  bool get debugCanUndo => _history.canUndo;

  @visibleForTesting
  bool get debugCanRedo => _history.canRedo;

  @visibleForTesting
  void debugInvokeToolbarAction(String label) => _onToolbarPressed(label);

  @visibleForTesting
  Future<bool> debugExportMarkedUpImage() => _exportMarkedUpImage();

  @visibleForTesting
  Future<void> debugCanvasTap(Offset point) async {
    final Rect? imageRect = _computeExportCropRect();
    if (imageRect == null) {
      return;
    }
    _onDimensionStart(point, imageRect);
    await _onDimensionEnd(imageRect);
    await _onDimensionTap(point, imageRect);
  }

  @visibleForTesting
  Future<void> debugCanvasDrag({
    required Offset start,
    required Offset end,
  }) async {
    final Rect? imageRect = _computeExportCropRect();
    if (imageRect == null) {
      return;
    }
    _onDimensionStart(start, imageRect);
    _onDimensionUpdate(end, imageRect);
    await _onDimensionEnd(imageRect);
  }

  void _onCanvasInteractionUpdate(ScaleUpdateDetails details) {
    _syncViewScaleFromController();
  }

  void _onCanvasPointerSignal(PointerSignalEvent event) {
    if (_imagePath == null || event is! PointerScrollEvent) {
      return;
    }
    final double scrollDy = event.scrollDelta.dy;
    final bool zoomModifierPressed =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (zoomModifierPressed) {
      final double deltaScale = CanvasViewTransformUtils.wheelScaleDelta(
        scrollDy,
      );
      final double targetScale = _normalizedViewScale * deltaScale;
      _setCanvasScale(targetScale, focalPoint: event.localPosition);
      return;
    }
    if (!_isZoomedCanvas) {
      return;
    }
    // ignore: deprecated_member_use
    final Matrix4 nextTransform = _canvasTransformController.value.clone()
      // ignore: deprecated_member_use
      ..translate(
        -event.scrollDelta.dx * ViewControlConstants.panStepMultiplier,
        -event.scrollDelta.dy * ViewControlConstants.panStepMultiplier,
      );
    _canvasTransformController.value = nextTransform;
    _syncViewScaleFromController();
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
      _selectMarkupTool(MarkupTool.dimension);
      return;
    }

    if (label == ToolbarConstants.arrow) {
      _selectMarkupTool(MarkupTool.arrow);
      return;
    }

    if (label == ToolbarConstants.line) {
      _selectMarkupTool(MarkupTool.line);
      return;
    }

    if (label == ToolbarConstants.highlighter) {
      _selectMarkupTool(MarkupTool.highlighter);
      return;
    }

    if (label == ToolbarConstants.callout) {
      _selectMarkupTool(MarkupTool.callout);
      return;
    }

    if (label == ToolbarConstants.blur) {
      _selectMarkupTool(MarkupTool.blur);
      return;
    }

    if (label == ToolbarConstants.rectangle) {
      _selectMarkupTool(MarkupTool.rectangle);
      return;
    }

    if (label == ToolbarConstants.circle) {
      _selectMarkupTool(MarkupTool.oval);
      return;
    }

    if (label == ToolbarConstants.freehand) {
      _selectMarkupTool(MarkupTool.freehand);
      return;
    }

    if (label == ToolbarConstants.textNote) {
      _selectMarkupTool(MarkupTool.textNote);
      return;
    }

    if (label == ToolbarConstants.style) {
      _showStylePresetDialog();
      return;
    }

    if (label == ToolbarConstants.undo) {
      _undoMarkup();
      return;
    }

    if (label == ToolbarConstants.redo) {
      _redoMarkup();
      return;
    }

    if (label == ToolbarConstants.clearAll) {
      unawaited(_clearAllMarkup());
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

  void _selectMarkupTool(MarkupTool tool) {
    setState(() {
      _selectedTool = _isPanModeEnabled && _selectedTool == tool
          ? tool
          : MarkupInteractionPolicy.resolveRequestedTool(
              currentTool: _selectedTool,
              requestedTool: tool,
            );
      if (_isPanModeEnabled) {
        _isPanModeEnabled = false;
      }
    });
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

      final String outputPath = _markupExportPathService
          .buildSafeMarkupExportPath(_normalizeExportPath(saveLocation.path));
      final Rect? displayImageRect = _computeExportCropRect();
      final String? displayPath = _imagePath;
      if (displayImageRect == null ||
          displayImageRect.isEmpty ||
          displayPath == null) {
        _showSnack(UiCopyConstants.exportFailureMessage);
        return false;
      }

      final FullResolutionExportResult result =
          await FullResolutionExportService.exportToPng(
            sourceImagePath: displayPath,
            scene: _buildExportScene(),
            displayImageRect: displayImageRect,
            outputPath: outputPath,
          );

      if (!mounted) {
        return true;
      }
      setState(() {
        _unsavedChangesTracker.markSaved();
      });
      _showSnack(
        '${UiCopyConstants.exportSuccessMessage} '
        '${result.pixelWidth}x${result.pixelHeight}',
      );
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
      activeFontFamily: _selectedFontFamily,
      activeFontSize: _selectedFontSize,
      nextMarkupId: _nextMarkupId,
      dimensionLines: List<DimensionLine>.unmodifiable(_dimensionLines),
      arrows: List<ArrowMarkup>.unmodifiable(_arrows),
      rectangles: List<RectangleMarkup>.unmodifiable(_rectangles),
      ovals: List<OvalMarkup>.unmodifiable(_ovals),
      freehands: List<FreehandMarkup>.unmodifiable(_freehands),
      textNotes: List<TextNoteMarkup>.unmodifiable(_textNotes),
      callouts: List<CalloutMarkup>.unmodifiable(_callouts),
      blurs: List<BlurMarkup>.unmodifiable(_blurs),
    );
  }

  void _applyEditableMarkupDocument(EditableMarkupDocument document) {
    _selectedStylePresetId = document.activeStylePresetId;
    _selectedFontFamily = document.activeFontFamily;
    _selectedFontSize = document.activeFontSize;
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
    _callouts
      ..clear()
      ..addAll(document.callouts);
    _blurs
      ..clear()
      ..addAll(document.blurs);

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
    for (final CalloutMarkup callout in _callouts) {
      if (callout.id > maxId) {
        maxId = callout.id;
      }
    }
    for (final BlurMarkup blur in _blurs) {
      if (blur.id > maxId) {
        maxId = blur.id;
      }
    }
    _nextMarkupId = math.max(document.nextMarkupId, maxId + 1);
    _resetMarkupHistory();
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

  Future<void> _showLoadErrorDialog(String message) async {
    if (_isShowingLoadErrorDialog || !mounted) {
      return;
    }
    _isShowingLoadErrorDialog = true;
    try {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text(UiCopyConstants.importErrorDialogTitle),
            content: Text(message),
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  UiCopyConstants.importErrorDialogDismissButton,
                ),
              ),
            ],
          );
        },
      );
    } finally {
      _isShowingLoadErrorDialog = false;
    }
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

  DimensionLine? get _selectedDimensionLine {
    final int? selectedDimensionId = _selectedDimensionId;
    if (selectedDimensionId == null) {
      return null;
    }
    for (final DimensionLine line in _dimensionLines) {
      if (line.id == selectedDimensionId) {
        return line;
      }
    }
    return null;
  }

  TextNoteMarkup? get _selectedTextNote {
    final int? selectedTextNoteId = _selectedTextNoteId;
    if (selectedTextNoteId == null) {
      return null;
    }
    for (final TextNoteMarkup note in _textNotes) {
      if (note.id == selectedTextNoteId) {
        return note;
      }
    }
    return null;
  }

  String _buildToolbarStyleLabel() =>
      '${ToolbarConstants.style}: ${_selectedStylePreset.shortLabel}';

  String _sidebarStyleSummary() =>
      '${UiCopyConstants.sidebarStylePrefix}: ${_selectedStylePreset.shortLabel}';

  /// NCD artwork only exists for the original five presets. Anything newer
  /// falls back to a tinted glyph rather than a broken-image box.
  String? _currentNcdStyleIconAssetPath() {
    switch (_selectedStylePresetId) {
      case MarkupStylePresetId.red:
        return SidebarAssetConstants.ncdSidebarStyleRedAssetPath;
      case MarkupStylePresetId.yellow:
        return SidebarAssetConstants.ncdSidebarStyleYellowAssetPath;
      case MarkupStylePresetId.white:
        return SidebarAssetConstants.ncdSidebarStyleWhiteAssetPath;
      case MarkupStylePresetId.black:
        return SidebarAssetConstants.ncdSidebarStyleBlackAssetPath;
      case MarkupStylePresetId.ncdBlue:
        return SidebarAssetConstants.ncdSidebarStyleNcdBlueAssetPath;
      case MarkupStylePresetId.orange:
      case MarkupStylePresetId.green:
        return null;
    }
  }

  SidebarIconDescriptor _toolbarActionIconDescriptor(String label) {
    if (label == ToolbarConstants.style) {
      final String? assetPath = _currentNcdStyleIconAssetPath();
      if (assetPath == null) {
        return const SidebarIconDescriptor.icon(Icons.palette);
      }
      return SidebarIconDescriptor.asset(assetPath);
    }
    return SidebarIconRegistry.actionIcons[label] ??
        const SidebarIconDescriptor.icon(Icons.help_outline);
  }

  String _sidebarToggleTooltip() => _isSidebarExpanded
      ? UiCopyConstants.sidebarCollapseTooltip
      : UiCopyConstants.sidebarExpandTooltip;

  bool _isFileAction(String label) =>
      ToolbarConstants.fileActionOrder.contains(label);

  Color _toolbarActionIconColor(String label, {required bool isSelected}) {
    if (isSelected) {
      return AppThemeConstants.ncdBlue;
    }
    if (label == ToolbarConstants.style) {
      return _selectedStylePreset.dimensionLineColor;
    }
    if (label == ToolbarConstants.erase || label == ToolbarConstants.clearAll) {
      return AppThemeConstants.sidebarDestructiveAccent;
    }
    if (label == ToolbarConstants.undo || label == ToolbarConstants.redo) {
      return AppThemeConstants.sidebarIconMuted;
    }
    if (_isFileAction(label)) {
      return AppThemeConstants.sidebarFileAccent;
    }
    return AppThemeConstants.sidebarIconNeutral;
  }

  String _activeToolLabel() {
    switch (_selectedTool) {
      case MarkupTool.dimension:
        return ToolbarConstants.dimension;
      case MarkupTool.textNote:
        return ToolbarConstants.textNote;
      case MarkupTool.arrow:
        return ToolbarConstants.arrow;
      case MarkupTool.line:
        return ToolbarConstants.line;
      case MarkupTool.rectangle:
        return ToolbarConstants.rectangle;
      case MarkupTool.oval:
        return ToolbarConstants.circle;
      case MarkupTool.freehand:
        return ToolbarConstants.freehand;
      case MarkupTool.highlighter:
        return ToolbarConstants.highlighter;
      case MarkupTool.callout:
        return ToolbarConstants.callout;
      case MarkupTool.blur:
        return ToolbarConstants.blur;
      case MarkupTool.none:
        return UiCopyConstants.toolbarActiveToolNone;
    }
  }

  bool _isToolbarActionSelected(String label) =>
      (label == ToolbarConstants.dimension &&
          _selectedTool == MarkupTool.dimension) ||
      (label == ToolbarConstants.arrow && _selectedTool == MarkupTool.arrow) ||
      (label == ToolbarConstants.line && _selectedTool == MarkupTool.line) ||
      (label == ToolbarConstants.highlighter &&
          _selectedTool == MarkupTool.highlighter) ||
      (label == ToolbarConstants.callout &&
          _selectedTool == MarkupTool.callout) ||
      (label == ToolbarConstants.blur && _selectedTool == MarkupTool.blur) ||
      (label == ToolbarConstants.circle && _selectedTool == MarkupTool.oval) ||
      (label == ToolbarConstants.rectangle &&
          _selectedTool == MarkupTool.rectangle) ||
      (label == ToolbarConstants.freehand &&
          _selectedTool == MarkupTool.freehand) ||
      (label == ToolbarConstants.textNote &&
          _selectedTool == MarkupTool.textNote);

  bool _isToolbarActionDisabled(String label) =>
      (label == ToolbarConstants.saveMarkup && _isSavingMarkupDocument) ||
      (label == ToolbarConstants.undo && !_isUndoEnabled()) ||
      (label == ToolbarConstants.redo && !_isRedoEnabled()) ||
      (label == ToolbarConstants.clearAll && !_hasAnyMarkup()) ||
      (label == ToolbarConstants.export && _isExporting);

  double _sidebarDrawerWidthForViewport(double viewportWidth) {
    final double maxExpandedWidth = math.max(
      UiLayoutConstants.sidebarCollapsedWidth,
      viewportWidth - UiLayoutConstants.sidebarMinimumCanvasWidth,
    );
    return math.min(UiLayoutConstants.sidebarExpandedWidth, maxExpandedWidth);
  }

  Widget _buildSidebarRail() {
    final BorderSide seamBorder = _isSidebarExpanded
        ? BorderSide.none
        : const BorderSide(color: AppThemeConstants.sidebarDivider, width: 1);
    return Container(
      width: UiLayoutConstants.sidebarCollapsedWidth,
      decoration: BoxDecoration(
        color: AppThemeConstants.sidebarBackground,
        border: Border(right: seamBorder),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: UiLayoutConstants.sidebarHeaderHorizontalPadding,
                right: UiLayoutConstants.sidebarHeaderHorizontalPadding,
                top: UiLayoutConstants.sidebarHeaderTopPadding,
                bottom: UiLayoutConstants.sidebarHeaderBottomPadding,
              ),
              child: IconButton(
                key: const ValueKey<String>('sidebar-rail-toggle'),
                tooltip: _sidebarToggleTooltip(),
                onPressed: () {
                  setState(() {
                    _isSidebarExpanded = !_isSidebarExpanded;
                  });
                },
                iconSize: UiLayoutConstants.sidebarHeaderIconSize,
                visualDensity: VisualDensity.compact,
                splashRadius: UiLayoutConstants.sidebarHeaderIconSize,
                color: AppThemeConstants.sidebarIconNeutral,
                icon: const Icon(Icons.menu),
              ),
            ),
            if (!_isSidebarExpanded)
              Padding(
                padding: const EdgeInsets.only(
                  left: UiLayoutConstants.sidebarSectionHorizontalPadding,
                  right: UiLayoutConstants.sidebarSectionHorizontalPadding,
                  bottom: UiLayoutConstants.sidebarSectionBottomPadding,
                ),
                child: Tooltip(
                  message: _buildToolbarStyleLabel(),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _selectedStylePreset.dimensionLineColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppThemeConstants.canvasFooterBorder,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (!_isSidebarExpanded)
              Expanded(
                child: ListView.builder(
                  key: const ValueKey<String>('sidebar-rail-scroll'),
                  padding: const EdgeInsets.only(
                    top: UiLayoutConstants.sidebarSectionBottomPadding,
                    bottom: UiLayoutConstants.sidebarSectionBottomPadding,
                  ),
                  itemCount: ToolbarConstants.sections.length,
                  itemBuilder: (BuildContext context, int sectionIndex) {
                    final ToolbarSectionDefinition section =
                        ToolbarConstants.sections[sectionIndex];
                    return _SidebarActionSection(
                      title: section.title,
                      isExpanded: false,
                      child: Column(
                        children: [
                          for (final String label in section.actions)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: UiLayoutConstants.sidebarActionGap,
                              ),
                              child: _SidebarActionButton(
                                actionKey: label,
                                label: label == ToolbarConstants.style
                                    ? _buildToolbarStyleLabel()
                                    : label,
                                tooltipLabel: label == ToolbarConstants.style
                                    ? _buildToolbarStyleLabel()
                                    : label,
                                iconDescriptor: _toolbarActionIconDescriptor(
                                  label,
                                ),
                                iconColor: _toolbarActionIconColor(
                                  label,
                                  isSelected: _isToolbarActionSelected(label),
                                ),
                                isExpanded: false,
                                isSelected: _isToolbarActionSelected(label),
                                isDisabled: _isToolbarActionDisabled(label),
                                onPressed: () => _onToolbarPressed(label),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarHeaderChip({
    required String text,
    required Color foregroundColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UiLayoutConstants.sidebarHeaderChipHorizontalPadding,
        vertical: UiLayoutConstants.sidebarHeaderChipVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: UiLayoutConstants.sidebarStyleSummaryFontSize,
          fontWeight: FontWeight.w600,
          color: foregroundColor,
        ),
      ),
    );
  }

  Widget _buildSidebarDrawerOverlay() {
    final double drawerWidth = _sidebarDrawerWidthForViewport(
      MediaQuery.sizeOf(context).width,
    );
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      left: _isSidebarExpanded ? 0 : -(drawerWidth + 8),
      top: 0,
      bottom: 0,
      width: drawerWidth,
      child: IgnorePointer(
        ignoring: !_isSidebarExpanded,
        child: TooltipVisibility(
          visible: _isSidebarExpanded,
          child: Material(
            elevation: 10,
            color: AppThemeConstants.sidebarBackground,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: UiLayoutConstants.sidebarHeaderHorizontalPadding,
                      right: UiLayoutConstants.sidebarHeaderHorizontalPadding,
                      top: UiLayoutConstants.sidebarHeaderTopPadding,
                      bottom: UiLayoutConstants.sidebarHeaderBottomPadding,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          key: const ValueKey<String>('sidebar-drawer-toggle'),
                          tooltip: _sidebarToggleTooltip(),
                          onPressed: () {
                            setState(() {
                              _isSidebarExpanded = false;
                            });
                          },
                          iconSize: UiLayoutConstants.sidebarHeaderIconSize,
                          visualDensity: VisualDensity.compact,
                          splashRadius: UiLayoutConstants.sidebarHeaderIconSize,
                          color: AppThemeConstants.sidebarIconNeutral,
                          icon: const Icon(Icons.menu),
                        ),
                        const SizedBox(
                          width: UiLayoutConstants.sidebarHeaderChipGap,
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: UiLayoutConstants.sidebarHeaderChipGap,
                            runSpacing: UiLayoutConstants.sidebarHeaderChipGap,
                            children: [
                              _buildSidebarHeaderChip(
                                text:
                                    '${UiCopyConstants.toolbarActiveToolPrefix}: ${_activeToolLabel()}',
                                foregroundColor: AppThemeConstants.ncdBlue,
                                backgroundColor:
                                    AppThemeConstants.sidebarSelectedTint,
                              ),
                              _buildSidebarHeaderChip(
                                text: _sidebarStyleSummary(),
                                foregroundColor: AppThemeConstants.ncdBlue,
                                backgroundColor:
                                    AppThemeConstants.sidebarSelectedTint,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppThemeConstants.sidebarDivider,
                  ),
                  Expanded(
                    child: ListView.builder(
                      key: const ValueKey<String>('sidebar-drawer-scroll'),
                      padding: const EdgeInsets.only(
                        top: UiLayoutConstants.sidebarSectionBottomPadding,
                        bottom: UiLayoutConstants.sidebarSectionBottomPadding,
                      ),
                      itemCount: ToolbarConstants.sections.length,
                      itemBuilder: (BuildContext context, int sectionIndex) {
                        final ToolbarSectionDefinition section =
                            ToolbarConstants.sections[sectionIndex];
                        return _SidebarActionSection(
                          title: section.title,
                          isExpanded: true,
                          child: Column(
                            children: [
                              for (final String label in section.actions)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: UiLayoutConstants.sidebarActionGap,
                                  ),
                                  child: _SidebarActionButton(
                                    actionKey: label,
                                    label: label == ToolbarConstants.style
                                        ? _buildToolbarStyleLabel()
                                        : label,
                                    tooltipLabel:
                                        label == ToolbarConstants.style
                                        ? _buildToolbarStyleLabel()
                                        : label,
                                    iconDescriptor:
                                        _toolbarActionIconDescriptor(label),
                                    iconColor: _toolbarActionIconColor(
                                      label,
                                      isSelected: _isToolbarActionSelected(
                                        label,
                                      ),
                                    ),
                                    isExpanded: true,
                                    isSelected: _isToolbarActionSelected(label),
                                    isDisabled: _isToolbarActionDisabled(label),
                                    onPressed: () => _onToolbarPressed(label),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewControlButton({
    required String keySuffix,
    required String tooltip,
    required IconData icon,
    required VoidCallback? onPressed,
    Color? iconColor,
    bool isActive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        key: ValueKey<String>('view-control-$keySuffix'),
        width: UiLayoutConstants.viewControlButtonSize,
        height: UiLayoutConstants.viewControlButtonSize,
        child: Material(
          color: isActive
              ? AppThemeConstants.sidebarSelectedTint
              : Colors.transparent,
          borderRadius: BorderRadius.circular(
            UiLayoutConstants.sidebarActionRadius,
          ),
          child: IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            icon: Icon(
              icon,
              size: UiLayoutConstants.viewControlIconSize,
              color: iconColor ?? AppThemeConstants.viewControlIcon,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasViewControls() {
    final bool canZoomIn =
        _normalizedViewScale <
        ViewControlConstants.maxScale - ViewControlConstants.scaleEpsilon;
    final bool canZoomOut =
        _normalizedViewScale >
        ViewControlConstants.minScale + ViewControlConstants.scaleEpsilon;
    final bool canReset = _isZoomedCanvas;

    return Material(
      elevation: 3,
      color: AppThemeConstants.viewControlSurface,
      borderRadius: BorderRadius.circular(
        UiLayoutConstants.viewControlPanelRadius,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            UiLayoutConstants.viewControlPanelRadius,
          ),
          border: Border.all(
            color: AppThemeConstants.viewControlBorder,
            width: UiLayoutConstants.viewControlPanelBorderWidth,
          ),
        ),
        padding: const EdgeInsets.all(
          UiLayoutConstants.viewControlPanelPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildViewControlButton(
                  keySuffix: 'zoom-out',
                  tooltip: UiCopyConstants.viewZoomOutTooltip,
                  icon: Icons.remove,
                  onPressed: canZoomOut ? _zoomOutView : null,
                ),
                const SizedBox(width: UiLayoutConstants.viewControlGap),
                SizedBox(
                  width: UiLayoutConstants.viewControlZoomLabelWidth,
                  child: Text(
                    '${UiCopyConstants.viewZoomPrefix}: $_zoomPercent%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: UiLayoutConstants.viewControlZoomLabelFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppThemeConstants.sidebarHeaderText,
                    ),
                  ),
                ),
                const SizedBox(width: UiLayoutConstants.viewControlGap),
                _buildViewControlButton(
                  keySuffix: 'zoom-in',
                  tooltip: UiCopyConstants.viewZoomInTooltip,
                  icon: Icons.add,
                  onPressed: canZoomIn ? _zoomInView : null,
                ),
              ],
            ),
            const SizedBox(height: UiLayoutConstants.viewControlGap),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildViewControlButton(
                  keySuffix: 'fit',
                  tooltip: UiCopyConstants.viewFitTooltip,
                  icon: Icons.fit_screen,
                  onPressed: canReset ? _fitCanvasToScreen : null,
                  iconColor: AppThemeConstants.viewControlAccent,
                ),
                const SizedBox(width: UiLayoutConstants.viewControlGap),
                _buildViewControlButton(
                  keySuffix: 'actual',
                  tooltip: UiCopyConstants.viewActualSizeTooltip,
                  icon: Icons.center_focus_strong,
                  onPressed: canReset ? _setCanvasViewActualSize : null,
                ),
                const SizedBox(width: UiLayoutConstants.viewControlGap),
                _buildViewControlButton(
                  keySuffix: 'pan',
                  tooltip: _isPanModeEnabled
                      ? UiCopyConstants.viewPanDisableTooltip
                      : UiCopyConstants.viewPanEnableTooltip,
                  icon: Icons.pan_tool_alt_outlined,
                  onPressed: _togglePanMode,
                  iconColor: _isPanModeEnabled
                      ? AppThemeConstants.viewControlAccent
                      : AppThemeConstants.viewControlIcon,
                  isActive: _isPanModeEnabled,
                ),
              ],
            ),
            const SizedBox(height: UiLayoutConstants.viewControlPanLabelTopGap),
            Text(
              '${UiCopyConstants.viewPanLabel}: '
              '${_isPanModeEnabled ? UiCopyConstants.viewStateOn : UiCopyConstants.viewStateOff}',
              style: const TextStyle(
                fontSize: UiLayoutConstants.viewControlPanLabelFontSize,
                fontWeight: FontWeight.w600,
                color: AppThemeConstants.sidebarSectionLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStylePresetDialog() async {
    final DimensionLine? selectedDimension = _selectedDimensionLine;
    final TextNoteMarkup? selectedTextNote = _selectedTextNote;
    final _StyleDialogResult? selected = await showDialog<_StyleDialogResult>(
      context: context,
      builder: (BuildContext context) {
        MarkupStylePresetId pendingPresetId = _selectedStylePresetId;
        double pendingStrokeWidthScale = _selectedStrokeWidthScale;
        bool pendingFilled = _selectedShapeFilled;
        CalloutLabelStyle pendingCalloutStyle = _calloutLabelStyle;
        String pendingFontFamily =
            selectedDimension?.fontFamily ??
            selectedTextNote?.fontFamily ??
            _selectedFontFamily;
        double pendingFontSize =
            selectedDimension?.fontSize ??
            selectedTextNote?.fontSize ??
            _selectedFontSize;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text(UiCopyConstants.styleDialogTitle),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        UiCopyConstants.styleDialogPresetsSectionTitle,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      for (final MarkupStylePreset preset
                          in MarkupStylePresets.all)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 12,
                            backgroundColor: preset.dimensionLineColor,
                          ),
                          title: Text(preset.label),
                          trailing: preset.id == pendingPresetId
                              ? const Icon(Icons.check, size: 18)
                              : null,
                          onTap: () {
                            setDialogState(() {
                              pendingPresetId = preset.id;
                            });
                          },
                        ),
                      const Divider(height: 20),
                      const Text(
                        UiCopyConstants.styleDialogWidthSectionTitle,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: <Widget>[
                          for (int i = 0;
                              i < MarkupStrokeConstants.allScales.length;
                              i++)
                            ChoiceChip(
                              key: ValueKey<String>(
                                'style-width-'
                                '${MarkupStrokeConstants.allScaleLabels[i]}',
                              ),
                              label: Text(
                                MarkupStrokeConstants.allScaleLabels[i],
                              ),
                              selected:
                                  (pendingStrokeWidthScale -
                                          MarkupStrokeConstants.allScales[i])
                                      .abs() <
                                  0.01,
                              onSelected: (_) {
                                setDialogState(() {
                                  pendingStrokeWidthScale =
                                      MarkupStrokeConstants.allScales[i];
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        key: const ValueKey<String>('style-fill-toggle'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(UiCopyConstants.styleDialogFillLabel),
                        subtitle: const Text(
                          UiCopyConstants.styleDialogFillHelp,
                        ),
                        value: pendingFilled,
                        onChanged: (bool value) {
                          setDialogState(() {
                            pendingFilled = value;
                          });
                        },
                      ),
                      const Divider(height: 20),
                      const Text(
                        UiCopyConstants.styleDialogCalloutSectionTitle,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: <Widget>[
                          ChoiceChip(
                            key: const ValueKey<String>('callout-style-numbers'),
                            label: const Text(
                              UiCopyConstants.calloutLabelStyleNumbers,
                            ),
                            selected:
                                pendingCalloutStyle ==
                                CalloutLabelStyle.numbers,
                            onSelected: (_) {
                              setDialogState(() {
                                pendingCalloutStyle = CalloutLabelStyle.numbers;
                              });
                            },
                          ),
                          ChoiceChip(
                            key: const ValueKey<String>('callout-style-letters'),
                            label: const Text(
                              UiCopyConstants.calloutLabelStyleLetters,
                            ),
                            selected:
                                pendingCalloutStyle ==
                                CalloutLabelStyle.letters,
                            onSelected: (_) {
                              setDialogState(() {
                                pendingCalloutStyle = CalloutLabelStyle.letters;
                              });
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      const Text(
                        UiCopyConstants.styleDialogTypographySectionTitle,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: pendingFontFamily,
                        decoration: const InputDecoration(
                          labelText: UiCopyConstants.styleDialogFontFamilyLabel,
                        ),
                        items: MarkupTypographyConstants.allowedFontFamilies
                            .map(
                              (String family) => DropdownMenuItem<String>(
                                value: family,
                                child: Text(family),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (String? value) {
                          if (value == null) {
                            return;
                          }
                          setDialogState(() {
                            pendingFontFamily = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${UiCopyConstants.styleDialogFontSizeLabel}: '
                        '${pendingFontSize.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Slider(
                        min: MarkupTypographyConstants.minFontSize,
                        max: MarkupTypographyConstants.maxFontSize,
                        divisions:
                            (MarkupTypographyConstants.maxFontSize -
                                    MarkupTypographyConstants.minFontSize)
                                .round(),
                        value: pendingFontSize.clamp(
                          MarkupTypographyConstants.minFontSize,
                          MarkupTypographyConstants.maxFontSize,
                        ),
                        onChanged: (double value) {
                          setDialogState(() {
                            pendingFontSize = value.roundToDouble();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(UiCopyConstants.styleDialogCancelButton),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    _StyleDialogResult(
                      presetId: pendingPresetId,
                      fontFamily: pendingFontFamily,
                      fontSize: pendingFontSize,
                      strokeWidthScale: pendingStrokeWidthScale,
                      filled: pendingFilled,
                      calloutLabelStyle: pendingCalloutStyle,
                    ),
                  ),
                  child: const Text(UiCopyConstants.styleDialogApplyButton),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    final MarkupSnapshot historyBefore = _snapshotMarkup();
    final bool appliedToSelection = _applyTypographyAndStyleToSelection(
      presetId: selected.presetId,
      fontFamily: selected.fontFamily,
      fontSize: selected.fontSize,
      strokeWidthScale: selected.strokeWidthScale,
      filled: selected.filled,
    );
    if (appliedToSelection) {
      _history.record(historyBefore, _snapshotMarkup());
    }
    setState(() {
      _selectedStylePresetId = selected.presetId;
      _selectedFontFamily = MarkupTypographyUtils.normalizeFontFamily(
        selected.fontFamily,
      );
      _selectedFontSize = MarkupTypographyUtils.normalizeFontSize(
        selected.fontSize,
      );
      _selectedStrokeWidthScale = MarkupStrokeConstants.normalizeScale(
        selected.strokeWidthScale,
      );
      _selectedShapeFilled = selected.filled;
      _calloutLabelStyle = selected.calloutLabelStyle;
      if (appliedToSelection) {
        _unsavedChangesTracker.markDirty();
      }
    });
    if (appliedToSelection) {
      _showSnack(UiCopyConstants.styleApplyToSelectedMessage);
    }
  }

  bool _applyTypographyAndStyleToSelection({
    required MarkupStylePresetId presetId,
    required String fontFamily,
    required double fontSize,
    required double strokeWidthScale,
    required bool filled,
  }) {
    bool applied = false;
    final int? selectedDimensionId = _selectedDimensionId;
    if (selectedDimensionId != null) {
      final int index = _dimensionLines.indexWhere(
        (DimensionLine line) => line.id == selectedDimensionId,
      );
      if (index != -1) {
        _dimensionLines[index] = _dimensionLines[index].copyWith(
          stylePresetId: presetId,
          fontFamily: fontFamily,
          fontSize: fontSize,
          strokeWidthScale: strokeWidthScale,
        );
        applied = true;
      }
      return applied;
    }

    final int? selectedArrowId = _selectedArrowId;
    if (selectedArrowId != null) {
      final int index = _arrows.indexWhere(
        (ArrowMarkup arrow) => arrow.id == selectedArrowId,
      );
      if (index != -1) {
        _arrows[index] = _arrows[index].copyWith(
          stylePresetId: presetId,
          strokeWidthScale: strokeWidthScale,
        );
        applied = true;
      }
      return applied;
    }

    final int? selectedRectangleId = _selectedRectangleId;
    if (selectedRectangleId != null) {
      final int index = _rectangles.indexWhere(
        (RectangleMarkup rectangle) => rectangle.id == selectedRectangleId,
      );
      if (index != -1) {
        _rectangles[index] = _rectangles[index].copyWith(
          stylePresetId: presetId,
          strokeWidthScale: strokeWidthScale,
          filled: filled,
        );
        applied = true;
      }
      return applied;
    }

    final int? selectedOvalId = _selectedOvalId;
    if (selectedOvalId != null) {
      final int index = _ovals.indexWhere(
        (OvalMarkup oval) => oval.id == selectedOvalId,
      );
      if (index != -1) {
        _ovals[index] = _ovals[index].copyWith(
          stylePresetId: presetId,
          strokeWidthScale: strokeWidthScale,
          filled: filled,
        );
        applied = true;
      }
      return applied;
    }

    final int? selectedFreehandId = _selectedFreehandId;
    if (selectedFreehandId != null) {
      final int index = _freehands.indexWhere(
        (FreehandMarkup freehand) => freehand.id == selectedFreehandId,
      );
      if (index != -1) {
        _freehands[index] = _freehands[index].copyWith(
          stylePresetId: presetId,
          strokeWidthScale: strokeWidthScale,
        );
        applied = true;
      }
      return applied;
    }

    final int? selectedTextNoteId = _selectedTextNoteId;
    if (selectedTextNoteId != null) {
      final int index = _textNotes.indexWhere(
        (TextNoteMarkup note) => note.id == selectedTextNoteId,
      );
      if (index != -1) {
        _textNotes[index] = _textNotes[index].copyWith(
          stylePresetId: presetId,
          fontFamily: fontFamily,
          fontSize: fontSize,
        );
        applied = true;
      }
      return applied;
    }

    final int? selectedCalloutId = _selectedCalloutId;
    if (selectedCalloutId != null) {
      final int index = _callouts.indexWhere(
        (CalloutMarkup callout) => callout.id == selectedCalloutId,
      );
      if (index != -1) {
        _callouts[index] = _callouts[index].copyWith(
          stylePresetId: presetId,
          sizeScale: strokeWidthScale,
        );
        applied = true;
      }
      return applied;
    }

    final int? selectedBlurId = _selectedBlurId;
    if (selectedBlurId != null) {
      final int index = _blurs.indexWhere(
        (BlurMarkup blur) => blur.id == selectedBlurId,
      );
      if (index != -1) {
        _blurs[index] = _blurs[index].copyWith(
          strengthScale: strokeWidthScale,
        );
        applied = true;
      }
    }
    return applied;
  }

  MarkupScene _buildExportScene() {
    return MarkupScene(
      lines: List<DimensionLine>.of(_dimensionLines),
      arrows: List<ArrowMarkup>.of(_arrows),
      rectangles: List<RectangleMarkup>.of(_rectangles),
      ovals: List<OvalMarkup>.of(_ovals),
      freehands: List<FreehandMarkup>.of(_freehands),
      textNotes: List<TextNoteMarkup>.of(_textNotes),
      callouts: List<CalloutMarkup>.of(_callouts),
      blurs: List<BlurMarkup>.of(_blurs),
    );
  }

  MarkupSnapshot _snapshotMarkup() {
    return MarkupSnapshot(
      dimensionLines: _dimensionLines,
      arrows: _arrows,
      rectangles: _rectangles,
      ovals: _ovals,
      freehands: _freehands,
      textNotes: _textNotes,
      callouts: _callouts,
      blurs: _blurs,
      nextMarkupId: _nextMarkupId,
    );
  }

  void _restoreMarkupSnapshot(MarkupSnapshot snapshot) {
    _dimensionLines
      ..clear()
      ..addAll(snapshot.dimensionLines);
    _arrows
      ..clear()
      ..addAll(snapshot.arrows);
    _rectangles
      ..clear()
      ..addAll(snapshot.rectangles);
    _ovals
      ..clear()
      ..addAll(snapshot.ovals);
    _freehands
      ..clear()
      ..addAll(snapshot.freehands);
    _textNotes
      ..clear()
      ..addAll(snapshot.textNotes);
    _callouts
      ..clear()
      ..addAll(snapshot.callouts);
    _blurs
      ..clear()
      ..addAll(snapshot.blurs);
    _nextMarkupId = snapshot.nextMarkupId;
    _dropSelectionForMissingMarkup();
  }

  void _dropSelectionForMissingMarkup() {
    final bool stillPresent =
        (_selectedDimensionId != null &&
            _dimensionLines.any(
              (DimensionLine line) => line.id == _selectedDimensionId,
            )) ||
        (_selectedArrowId != null &&
            _arrows.any((ArrowMarkup arrow) => arrow.id == _selectedArrowId)) ||
        (_selectedRectangleId != null &&
            _rectangles.any(
              (RectangleMarkup rectangle) =>
                  rectangle.id == _selectedRectangleId,
            )) ||
        (_selectedOvalId != null &&
            _ovals.any((OvalMarkup oval) => oval.id == _selectedOvalId)) ||
        (_selectedFreehandId != null &&
            _freehands.any(
              (FreehandMarkup freehand) => freehand.id == _selectedFreehandId,
            )) ||
        (_selectedTextNoteId != null &&
            _textNotes.any(
              (TextNoteMarkup note) => note.id == _selectedTextNoteId,
            )) ||
        (_selectedCalloutId != null &&
            _callouts.any(
              (CalloutMarkup callout) => callout.id == _selectedCalloutId,
            )) ||
        (_selectedBlurId != null &&
            _blurs.any((BlurMarkup blur) => blur.id == _selectedBlurId));
    if (!stillPresent) {
      _clearMarkupSelection();
    }
  }

  /// Remembers the markup state at the start of a pointer gesture so a whole
  /// drag lands as one undo step rather than one step per pointer move.
  void _beginMarkupGesture() {
    _gestureSnapshot ??= _snapshotMarkup();
  }

  void _endMarkupGesture() {
    final MarkupSnapshot? before = _gestureSnapshot;
    _gestureSnapshot = null;
    if (before == null) {
      return;
    }
    _history.record(before, _snapshotMarkup());
  }

  /// Runs a discrete markup edit as a single undo step.
  void _runMarkupCommand(VoidCallback body) {
    final MarkupSnapshot before = _snapshotMarkup();
    body();
    _history.record(before, _snapshotMarkup());
  }

  void _resetMarkupHistory() {
    _history.clear();
    _gestureSnapshot = null;
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
    _selectedCalloutId = null;
    _selectedBlurId = null;
    _activeHandleDragSession = null;
    _suppressTapActionAfterPointerDownSelection = false;
  }

  void _selectCalloutById(int id) {
    _clearMarkupSelection();
    _selectedCalloutId = id;
  }

  void _selectBlurById(int id) {
    _clearMarkupSelection();
    _selectedBlurId = id;
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

  void _undoMarkup() {
    final MarkupSnapshot? previous = _history.undo(_snapshotMarkup());
    if (previous == null) {
      _showSnack(UiCopyConstants.undoNothingMessage);
      return;
    }
    setState(() {
      _restoreMarkupSnapshot(previous);
      _unsavedChangesTracker.markDirty();
    });
  }

  void _redoMarkup() {
    final MarkupSnapshot? next = _history.redo(_snapshotMarkup());
    if (next == null) {
      _showSnack(UiCopyConstants.redoNothingMessage);
      return;
    }
    setState(() {
      _restoreMarkupSnapshot(next);
      _unsavedChangesTracker.markDirty();
    });
  }

  Future<void> _clearAllMarkup() async {
    if (_snapshotMarkup().isEmpty) {
      _showSnack(UiCopyConstants.clearAllNothingMessage);
      return;
    }
    final bool confirmed = await _showClearAllConfirmation();
    if (!confirmed || !mounted) {
      return;
    }
    setState(() {
      _runMarkupCommand(() {
        _dimensionLines.clear();
        _arrows.clear();
        _rectangles.clear();
        _ovals.clear();
        _freehands.clear();
        _textNotes.clear();
        _callouts.clear();
        _blurs.clear();
        _clearMarkupSelection();
        _unsavedChangesTracker.markDirty();
      });
    });
    _showSnack(UiCopyConstants.clearAllDoneMessage);
  }

  Future<bool> _showClearAllConfirmation() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(UiCopyConstants.clearAllDialogTitle),
          content: const Text(UiCopyConstants.clearAllDialogBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(UiCopyConstants.clearAllCancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(UiCopyConstants.clearAllConfirmButton),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  void _eraseSelectedMarkup() {
    final MarkupSnapshot historyBefore = _snapshotMarkup();
    _eraseSelectedMarkupInternal();
    _history.record(historyBefore, _snapshotMarkup());
  }

  void _eraseSelectedMarkupInternal() {
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

    final int? selectedCalloutId = _selectedCalloutId;
    if (selectedCalloutId != null) {
      setState(() {
        _callouts.removeWhere(
          (CalloutMarkup callout) => callout.id == selectedCalloutId,
        );
        _clearMarkupSelection();
        _unsavedChangesTracker.markDirty();
      });
      return;
    }

    final int? selectedBlurId = _selectedBlurId;
    if (selectedBlurId != null) {
      setState(() {
        _blurs.removeWhere((BlurMarkup blur) => blur.id == selectedBlurId);
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
    _beginMarkupGesture();
    _didMoveSelectedMarkup = false;
    if (MarkupInteractionPolicy.allowsTapSelection(_selectedTool)) {
      if (_tryStartHandleDrag(startPoint, imageRect)) {
        return;
      }
      if (_tryStartMoveSelectedMarkup(startPoint, imageRect)) {
        return;
      }
      if (_selectMarkupAtPointForEditing(startPoint, imageRect)) {
        if (_tryStartHandleDrag(startPoint, imageRect)) {
          _suppressTapActionAfterPointerDownSelection = false;
          return;
        }
        if (_tryStartMoveSelectedMarkup(startPoint, imageRect)) {
          _suppressTapActionAfterPointerDownSelection = false;
          return;
        }
        return;
      }
    }
    if (!_canDrawMarkup(imageRect)) {
      return;
    }
    final Offset clamped = DimensionLine.clampToRect(startPoint, imageRect);
    setState(() {
      _activeDimensionStart = clamped;
      _activeDimensionCurrent = clamped;
      _activeFreehandPoints.clear();
      if (_isStrokeTool(_selectedTool)) {
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
      if (_isStrokeTool(_selectedTool)) {
        final Offset? lastPoint = _activeFreehandPoints.isEmpty
            ? null
            : _activeFreehandPoints.last;
        final double minDistance = _selectedTool == MarkupTool.highlighter
            ? HighlighterMarkupConstants.pointMinDistance
            : FreehandMarkupConstants.pointMinDistance;
        if (lastPoint == null || (clamped - lastPoint).distance >= minDistance) {
          _activeFreehandPoints.add(clamped);
        }
      }
    });
  }

  Future<void> _onDimensionEnd(Rect imageRect) async {
    try {
      await _onDimensionEndInternal(imageRect);
    } finally {
      _endMarkupGesture();
    }
  }

  Future<void> _onDimensionEndInternal(Rect imageRect) async {
    if (_activeHandleDragSession != null) {
      _activeHandleDragSession = null;
      _suppressTapActionAfterPointerDownSelection = false;
      _endMarkupGesture();
      return;
    }
    if (_activeMoveSession != null) {
      _activeMoveSession = null;
      _suppressTapActionAfterPointerDownSelection = false;
      _endMarkupGesture();
      return;
    }

    final Offset? start = _activeDimensionStart;
    final Offset? end = _activeDimensionCurrent;
    final List<Offset> freehandPoints = List<Offset>.of(_activeFreehandPoints);
    _activeDimensionStart = null;
    _activeDimensionCurrent = null;
    _activeFreehandPoints.clear();

    if (start == null || end == null || !_canDrawMarkup(imageRect)) {
      _endMarkupGesture();
      if (mounted) {
        setState(() {});
      }
      return;
    }

    if (_selectedTool == MarkupTool.arrow || _selectedTool == MarkupTool.line) {
      final ArrowMarkup arrow = ArrowMarkup.fromCanvasPoints(
        id: _allocateMarkupId(),
        startPoint: start,
        endPoint: end,
        imageRect: imageRect,
        stylePresetId: _selectedStylePresetId,
        strokeWidthScale: _selectedStrokeWidthScale,
        hasHead: _selectedTool == MarkupTool.arrow,
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

    if (_isStrokeTool(_selectedTool)) {
      if (freehandPoints.length < FreehandMarkupConstants.minimumPointCount) {
        if (mounted) {
          setState(() {});
        }
        return;
      }
      final bool isHighlighter = _selectedTool == MarkupTool.highlighter;
      final FreehandMarkup freehand = FreehandMarkup.fromCanvasPoints(
        id: _allocateMarkupId(),
        points: isHighlighter
            ? freehandPoints
            : FreehandSmoothing.smooth(freehandPoints),
        imageRect: imageRect,
        stylePresetId: _selectedStylePresetId,
        strokeWidthScale: _selectedStrokeWidthScale,
        isHighlighter: isHighlighter,
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

    if (_selectedTool == MarkupTool.blur) {
      final BlurMarkup blur = BlurMarkup.fromCanvasPoints(
        id: _allocateMarkupId(),
        startPoint: start,
        endPoint: end,
        imageRect: imageRect,
        strengthScale: _selectedStrokeWidthScale,
      );
      if (blur.widthInRect(imageRect) < BlurMarkupConstants.minSideLength ||
          blur.heightInRect(imageRect) < BlurMarkupConstants.minSideLength) {
        if (mounted) {
          setState(() {});
        }
        return;
      }
      if (mounted) {
        setState(() {
          _blurs.add(blur);
          _selectBlurById(blur.id);
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
        strokeWidthScale: _selectedStrokeWidthScale,
        filled: _selectedShapeFilled,
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
        strokeWidthScale: _selectedStrokeWidthScale,
        filled: _selectedShapeFilled,
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
        strokeWidthScale: _selectedStrokeWidthScale,
      ).copyWith(fontFamily: _selectedFontFamily, fontSize: _selectedFontSize);

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
      await _promptForDimensionLabelById(newLineId!, recordHistory: false);
    }
  }

  Future<void> _promptForDimensionLabelById(
    int dimensionId, {
    bool recordHistory = true,
  }) async {
    final MarkupSnapshot historyBefore = _snapshotMarkup();
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
          ? _dimensionLines[refreshIndex].copyWith(
              clearLabel: true,
              clearLabelOffset: true,
            )
          : _dimensionLines[refreshIndex].copyWith(label: normalized);
      _selectDimensionById(dimensionId);
      _unsavedChangesTracker.markDirty();
    });
    if (recordHistory) {
      _history.record(historyBefore, _snapshotMarkup());
    }
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

  void _createCalloutAt(Offset point, Rect imageRect) {
    final MarkupSnapshot historyBefore = _snapshotMarkup();
    final CalloutMarkup callout = CalloutMarkup.fromCanvasPoint(
      id: _allocateMarkupId(),
      anchorPoint: point,
      sequence: CalloutMarkup.nextSequence(_callouts),
      imageRect: imageRect,
      labelStyle: _calloutLabelStyle,
      stylePresetId: _selectedStylePresetId,
      sizeScale: _selectedStrokeWidthScale,
    );
    setState(() {
      _callouts.add(callout);
      _selectCalloutById(callout.id);
      _unsavedChangesTracker.markDirty();
    });
    _history.record(historyBefore, _snapshotMarkup());
  }

  Future<void> _createTextNoteAt(Offset point, Rect imageRect) async {
    final MarkupSnapshot historyBefore = _snapshotMarkup();
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
    ).copyWith(fontFamily: _selectedFontFamily, fontSize: _selectedFontSize);
    setState(() {
      _textNotes.add(note);
      _selectTextNoteById(note.id);
      _unsavedChangesTracker.markDirty();
    });
    _history.record(historyBefore, _snapshotMarkup());
  }

  Future<void> _editTextNoteById(int noteId) async {
    final MarkupSnapshot historyBefore = _snapshotMarkup();
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
      _history.record(historyBefore, _snapshotMarkup());
      return;
    }

    setState(() {
      _textNotes[refreshIndex] = _textNotes[refreshIndex].copyWith(
        text: trimmed,
      );
      _selectTextNoteById(noteId);
      _unsavedChangesTracker.markDirty();
    });
    _history.record(historyBefore, _snapshotMarkup());
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
        final DimensionLabelLayout? labelLayout =
            MarkupTextLayoutUtils.layoutDimensionLabel(
              line: line,
              imageRect: imageRect,
              start: start,
              end: end,
            );
        if (labelLayout != null &&
            MarkupTextLayoutUtils.distanceToRect(
                  labelLayout.labelRect,
                  point,
                ) <=
                DimensionLineConstants.labelHitDistance) {
          _activeHandleDragSession = _HandleDragSession(
            markupId: selectedDimensionId,
            handleKind: _HandleKind.dimensionLabel,
            startPoint: point,
            referenceOffset: labelLayout.labelCenter - point,
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

    final int? selectedBlurId = _selectedBlurId;
    if (selectedBlurId != null) {
      final int index = _blurs.indexWhere(
        (BlurMarkup blur) => blur.id == selectedBlurId,
      );
      if (index != -1) {
        final Rect rect = _blurs[index].rectInRect(imageRect);
        final int? cornerIndex = MarkupHandleUtils.hitCornerIndex(
          point,
          corners: MarkupHandleUtils.rectangleCorners(rect),
          hitDistance: MarkupHandleConstants.hitDistance,
        );
        if (cornerIndex != null) {
          _activeHandleDragSession = _HandleDragSession(
            markupId: selectedBlurId,
            handleKind: _HandleKind.blurCorner,
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
      case _HandleKind.dimensionLabel:
        changed = _moveDimensionLabel(
          markupId: handleSession.markupId,
          imageRect: imageRect,
          point: clampedPoint,
          referenceOffset: handleSession.referenceOffset ?? Offset.zero,
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
      case _HandleKind.blurCorner:
        changed = _resizeBlurFromCorner(
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
    final DimensionLine updated =
        DimensionLine.fromCanvasPoints(
          id: line.id,
          startPoint: start,
          endPoint: end,
          imageRect: imageRect,
          stylePresetId: line.stylePresetId,
          strokeWidthScale: line.strokeWidthScale,
        ).copyWith(
          label: line.label,
          labelOffsetNormalized: line.labelOffsetNormalized,
          fontFamily: line.fontFamily,
          fontSize: line.fontSize,
        );
    if (updated == line) {
      return false;
    }
    setState(() {
      _dimensionLines[index] = updated;
      _unsavedChangesTracker.markDirty();
    });
    return true;
  }

  bool _moveDimensionLabel({
    required int markupId,
    required Rect imageRect,
    required Offset point,
    required Offset referenceOffset,
  }) {
    final int index = _dimensionLines.indexWhere(
      (DimensionLine line) => line.id == markupId,
    );
    if (index == -1) {
      return false;
    }
    final DimensionLine line = _dimensionLines[index];
    final Offset start = line.startInRect(imageRect);
    final Offset end = line.endInRect(imageRect);
    final Offset midpoint = line.midpointInRect(imageRect);
    final Offset requestedCenter = point + referenceOffset;
    final Offset requestedNormalizedOffset =
        MarkupTextLayoutUtils.normalizedOffsetFromCenter(
          center: requestedCenter,
          midpoint: midpoint,
          imageRect: imageRect,
        );
    final DimensionLabelLayout? layout =
        MarkupTextLayoutUtils.layoutDimensionLabel(
          line: line,
          imageRect: imageRect,
          start: start,
          end: end,
          overrideLabelOffsetNormalized: requestedNormalizedOffset,
        );
    if (layout == null) {
      return false;
    }
    final Offset actualNormalizedOffset =
        MarkupTextLayoutUtils.normalizedOffsetFromCenter(
          center: layout.labelCenter,
          midpoint: midpoint,
          imageRect: imageRect,
        );
    final DimensionLine updated = line.copyWith(
      labelOffsetNormalized: actualNormalizedOffset,
    );
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
      strokeWidthScale: arrow.strokeWidthScale,
      hasHead: arrow.hasHead,
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
      strokeWidthScale: rectangle.strokeWidthScale,
      filled: rectangle.filled,
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
      strokeWidthScale: oval.strokeWidthScale,
      filled: oval.filled,
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

  bool _resizeBlurFromCorner({
    required int markupId,
    required int cornerIndex,
    required Rect imageRect,
    required Offset point,
  }) {
    final int index = _blurs.indexWhere(
      (BlurMarkup blur) => blur.id == markupId,
    );
    if (index == -1) {
      return false;
    }
    final BlurMarkup blur = _blurs[index];
    final Rect resized = MarkupHandleUtils.resizeRectFromCorner(
      currentRect: blur.rectInRect(imageRect),
      cornerIndex: cornerIndex,
      dragPoint: point,
      bounds: imageRect,
      minWidth: BlurMarkupConstants.minSideLength,
      minHeight: BlurMarkupConstants.minSideLength,
    );
    final BlurMarkup updated = BlurMarkup.fromCanvasPoints(
      id: blur.id,
      startPoint: resized.topLeft,
      endPoint: resized.bottomRight,
      imageRect: imageRect,
      strengthScale: blur.strengthScale,
    );
    if (updated == blur) {
      return false;
    }
    setState(() {
      _blurs[index] = updated;
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

  bool _selectMarkupAtPointForEditing(Offset point, Rect imageRect) {
    final _NearestMarkupHit nearestHit = _findNearestMarkupHit(
      point,
      imageRect,
    );
    if (!nearestHit.found) {
      return false;
    }

    final bool alreadySelected =
        (nearestHit.markupTool == MarkupTool.dimension &&
            _selectedDimensionId == nearestHit.markupId) ||
        (nearestHit.markupTool == MarkupTool.arrow &&
            _selectedArrowId == nearestHit.markupId) ||
        (nearestHit.markupTool == MarkupTool.rectangle &&
            _selectedRectangleId == nearestHit.markupId) ||
        (nearestHit.markupTool == MarkupTool.oval &&
            _selectedOvalId == nearestHit.markupId) ||
        (nearestHit.markupTool == MarkupTool.freehand &&
            _selectedFreehandId == nearestHit.markupId) ||
        (nearestHit.markupTool == MarkupTool.textNote &&
            _selectedTextNoteId == nearestHit.markupId);

    if (alreadySelected) {
      return true;
    }

    setState(() {
      switch (nearestHit.markupTool) {
        case MarkupTool.dimension:
          _selectDimensionById(nearestHit.markupId);
          break;
        case MarkupTool.arrow:
          _selectArrowById(nearestHit.markupId);
          break;
        case MarkupTool.rectangle:
          _selectRectangleById(nearestHit.markupId);
          break;
        case MarkupTool.oval:
          _selectOvalById(nearestHit.markupId);
          break;
        case MarkupTool.freehand:
          _selectFreehandById(nearestHit.markupId);
          break;
        case MarkupTool.textNote:
          _selectTextNoteById(nearestHit.markupId);
          break;
        case MarkupTool.callout:
          _selectCalloutById(nearestHit.markupId);
          break;
        case MarkupTool.blur:
          _selectBlurById(nearestHit.markupId);
          break;
        case MarkupTool.line:
        case MarkupTool.highlighter:
        case MarkupTool.none:
          break;
      }
      _suppressTapActionAfterPointerDownSelection = true;
    });
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
    if (_selectedCalloutId != null) {
      return _SelectedMarkup(
        markupId: _selectedCalloutId!,
        tool: MarkupTool.callout,
      );
    }
    if (_selectedBlurId != null) {
      return _SelectedMarkup(markupId: _selectedBlurId!, tool: MarkupTool.blur);
    }
    return null;
  }

  double _selectionDistanceForTool(MarkupTool tool) {
    final double minimumHitDistance =
        MarkupMoveConstants.selectionStartHitDistance;
    switch (tool) {
      case MarkupTool.dimension:
      case MarkupTool.arrow:
      case MarkupTool.line:
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
      case MarkupTool.highlighter:
        return math.max(
          HighlighterMarkupConstants.selectionHitDistance,
          minimumHitDistance,
        );
      case MarkupTool.callout:
        return math.max(
          CalloutMarkupConstants.selectionHitDistance,
          minimumHitDistance,
        );
      case MarkupTool.blur:
        return math.max(
          BlurMarkupConstants.selectionHitDistance,
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
        return math.min(
          _dimensionLines[index].distanceToPointInRect(point, imageRect),
          MarkupTextLayoutUtils.distanceToDimensionLabel(
            line: _dimensionLines[index],
            point: point,
            imageRect: imageRect,
          ),
        );
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
      case MarkupTool.callout:
        final int index = _callouts.indexWhere(
          (CalloutMarkup callout) => callout.id == selectedMarkup.markupId,
        );
        if (index == -1) {
          return double.infinity;
        }
        return _callouts[index].distanceToPointInRect(point, imageRect, 1.0);
      case MarkupTool.blur:
        final int index = _blurs.indexWhere(
          (BlurMarkup blur) => blur.id == selectedMarkup.markupId,
        );
        if (index == -1) {
          return double.infinity;
        }
        return _blurs[index].distanceToPointInRect(point, imageRect);
      case MarkupTool.line:
      case MarkupTool.highlighter:
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
      case MarkupTool.callout:
        return _moveCalloutByDelta(markupId, requestedDelta, imageRect);
      case MarkupTool.blur:
        return _moveBlurByDelta(markupId, requestedDelta, imageRect);
      case MarkupTool.line:
      case MarkupTool.highlighter:
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
    final DimensionLine movedLine =
        DimensionLine.fromCanvasPoints(
          id: line.id,
          startPoint: moved.first,
          endPoint: moved.last,
          imageRect: imageRect,
          stylePresetId: line.stylePresetId,
          strokeWidthScale: line.strokeWidthScale,
        ).copyWith(
          label: line.label,
          labelOffsetNormalized: line.labelOffsetNormalized,
          fontFamily: line.fontFamily,
          fontSize: line.fontSize,
        );
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
      strokeWidthScale: arrow.strokeWidthScale,
      hasHead: arrow.hasHead,
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
      strokeWidthScale: rectangle.strokeWidthScale,
      filled: rectangle.filled,
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
      strokeWidthScale: oval.strokeWidthScale,
      filled: oval.filled,
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
      strokeWidthScale: freehand.strokeWidthScale,
      isHighlighter: freehand.isHighlighter,
    );
    setState(() {
      _freehands[index] = movedFreehand;
      _unsavedChangesTracker.markDirty();
    });
    return appliedDelta;
  }

  Offset _moveCalloutByDelta(int markupId, Offset delta, Rect imageRect) {
    final int index = _callouts.indexWhere(
      (CalloutMarkup callout) => callout.id == markupId,
    );
    if (index == -1) {
      return Offset.zero;
    }
    final CalloutMarkup callout = _callouts[index];
    final Offset center = callout.centerInRect(imageRect);
    final Offset appliedDelta = MarkupMoveUtils.clampTranslationForPoints(
      points: <Offset>[center],
      requestedDelta: delta,
      bounds: imageRect,
      padding: MarkupMoveConstants.boundsPadding,
    );
    if (appliedDelta == Offset.zero) {
      return Offset.zero;
    }
    setState(() {
      _callouts[index] = CalloutMarkup.fromCanvasPoint(
        id: callout.id,
        anchorPoint: center + appliedDelta,
        sequence: callout.sequence,
        imageRect: imageRect,
        labelStyle: callout.labelStyle,
        stylePresetId: callout.stylePresetId,
        sizeScale: callout.sizeScale,
      );
      _unsavedChangesTracker.markDirty();
    });
    return appliedDelta;
  }

  Offset _moveBlurByDelta(int markupId, Offset delta, Rect imageRect) {
    final int index = _blurs.indexWhere(
      (BlurMarkup blur) => blur.id == markupId,
    );
    if (index == -1) {
      return Offset.zero;
    }
    final BlurMarkup blur = _blurs[index];
    final Rect rect = blur.rectInRect(imageRect);
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
    setState(() {
      _blurs[index] = BlurMarkup.fromCanvasPoints(
        id: blur.id,
        startPoint: moved.first,
        endPoint: moved.last,
        imageRect: imageRect,
        strengthScale: blur.strengthScale,
      );
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
    ).copyWith(fontFamily: note.fontFamily, fontSize: note.fontSize);
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
    if (MarkupInteractionPolicy.allowsTextNoteCreation(_selectedTool)) {
      await _createTextNoteAt(point, imageRect);
      return;
    }
    if (_selectedTool == MarkupTool.callout) {
      _createCalloutAt(point, imageRect);
      return;
    }
    if (!MarkupInteractionPolicy.allowsTapSelection(_selectedTool)) {
      return;
    }
    if (_suppressTapActionAfterPointerDownSelection) {
      _suppressTapActionAfterPointerDownSelection = false;
      return;
    }
    if (_dimensionLines.isEmpty &&
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
      final DimensionLine? selectedLine = _selectedDimensionLine;
      if (selectedLine != null &&
          (MarkupTextLayoutUtils.isDimensionLabelHit(
                line: selectedLine,
                point: point,
                imageRect: imageRect,
              ) ||
              (selectedLine.label?.trim().isEmpty ?? true))) {
        await _promptForDimensionLabelById(nearestHit.markupId);
      }
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
      final double distance = math.min(
        line.distanceToPointInRect(point, imageRect),
        MarkupTextLayoutUtils.distanceToDimensionLabel(
          line: line,
          point: point,
          imageRect: imageRect,
        ),
      );
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

    for (final CalloutMarkup callout in _callouts) {
      final double distance = callout.distanceToPointInRect(
        point,
        imageRect,
        1.0,
      );
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMarkupId = callout.id;
        bestTool = MarkupTool.callout;
      }
    }

    for (final BlurMarkup blur in _blurs) {
      final double distance = blur.distanceToPointInRect(point, imageRect);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMarkupId = blur.id;
        bestTool = MarkupTool.blur;
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
    if (CalloutMarkupConstants.selectionHitDistance > maxSelectionDistance) {
      maxSelectionDistance = CalloutMarkupConstants.selectionHitDistance;
    }
    if (BlurMarkupConstants.selectionHitDistance > maxSelectionDistance) {
      maxSelectionDistance = BlurMarkupConstants.selectionHitDistance;
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
    return MarkupTextLayoutUtils.distanceToTextNote(
      note: note,
      point: point,
      imageRect: imageRect,
      preset: MarkupStylePresets.byId(note.stylePresetId),
    );
  }

  KeyEventResult _onShellKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final bool ctrlOrMetaPressed =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (ctrlOrMetaPressed) {
      if (event.logicalKey == LogicalKeyboardKey.equal ||
          event.logicalKey == LogicalKeyboardKey.numpadAdd) {
        _zoomInView();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.minus ||
          event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
        _zoomOutView();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.digit0 ||
          event.logicalKey == LogicalKeyboardKey.numpad0) {
        _fitCanvasToScreen();
        return KeyEventResult.handled;
      }
    }
    if (ctrlOrMetaPressed) {
      final bool shiftPressed = HardwareKeyboard.instance.isShiftPressed;
      if (event.logicalKey == LogicalKeyboardKey.keyZ) {
        if (shiftPressed) {
          _redoMarkup();
        } else {
          _undoMarkup();
        }
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyY) {
        _redoMarkup();
        return KeyEventResult.handled;
      }
    }
    if (event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      _eraseSelectedMarkup();
      return KeyEventResult.handled;
    }
    if ((event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) &&
        _selectedTool == MarkupTool.none &&
        _selectedDimensionId != null) {
      unawaited(_promptForDimensionLabelById(_selectedDimensionId!));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  static bool _isStrokeTool(MarkupTool tool) =>
      tool == MarkupTool.freehand || tool == MarkupTool.highlighter;

  bool _canDrawMarkup(Rect imageRect) {
    return (_selectedTool == MarkupTool.dimension ||
            _selectedTool == MarkupTool.arrow ||
            _selectedTool == MarkupTool.line ||
            _selectedTool == MarkupTool.rectangle ||
            _selectedTool == MarkupTool.oval ||
            _selectedTool == MarkupTool.freehand ||
            _selectedTool == MarkupTool.highlighter ||
            _selectedTool == MarkupTool.blur) &&
        _imagePath != null &&
        imageRect.width > 0 &&
        imageRect.height > 0;
  }

  bool _isOverlayInteractionEnabled(Rect imageRect) {
    return !_isPanModeEnabled &&
        _imagePath != null &&
        imageRect.width > 0 &&
        imageRect.height > 0;
  }

  bool _isUndoEnabled() => _history.canUndo;

  bool _isRedoEnabled() => _history.canRedo;

  bool _hasAnyMarkup() => !_snapshotMarkup().isEmpty;

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
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isSidebarExpanded) _buildSidebarRail(),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        if (_showLaunchContextBanner)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: UiLayoutConstants
                                  .launchContextBannerHorizontalPadding,
                              vertical: UiLayoutConstants
                                  .launchContextBannerVerticalPadding,
                            ),
                            color: AppThemeConstants.toolbarBackground,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.link,
                                  size:
                                      UiLayoutConstants
                                          .launchContextBannerFontSize +
                                      2,
                                  color: AppThemeConstants.ncdBlue,
                                ),
                                const SizedBox(
                                  width:
                                      UiLayoutConstants.launchContextBannerGap,
                                ),
                                Expanded(
                                  child: Text(
                                    _buildLaunchContextSummary(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: UiLayoutConstants
                                          .launchContextBannerFontSize,
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
                      ],
                    ),
                    if (_isSidebarExpanded) ...[
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _isSidebarExpanded = false;
                            });
                          },
                          child: Container(color: Colors.black12),
                        ),
                      ),
                      _buildSidebarDrawerOverlay(),
                    ],
                  ],
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
                const SizedBox(height: UiLayoutConstants.messageTopGap),
                const Text(
                  UiCopyConstants.importInProgressMessage,
                  style: TextStyle(
                    fontSize: UiLayoutConstants.messageFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
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
                  children: <Widget>[
                    Listener(
                      onPointerSignal: _onCanvasPointerSignal,
                      child: InteractiveViewer(
                        transformationController: _canvasTransformController,
                        minScale: ViewControlConstants.minScale,
                        maxScale: ViewControlConstants.maxScale,
                        boundaryMargin: ViewControlConstants.boundaryMargin,
                        constrained: true,
                        panEnabled: _isPanModeEnabled,
                        scaleEnabled: true,
                        onInteractionUpdate: _onCanvasInteractionUpdate,
                        child: RepaintBoundary(
                          key: _canvasExportKey,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Center(
                                child: Image.file(
                                  File(_imagePath!),
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (
                                        _,
                                        Object error,
                                        StackTrace? stackTrace,
                                      ) {
                                        return const Text(
                                          ImageImportConstants.openErrorMessage,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                AppThemeConstants.errorAccent,
                                            fontSize: UiLayoutConstants
                                                .messageFontSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      },
                                ),
                              ),
                              BlurRegionsLayer(
                                blurs: _blurs,
                                imageRect: imageRect,
                              ),
                              DimensionLinesOverlay(
                                lines: _dimensionLines,
                                arrows: _arrows,
                                rectangles: _rectangles,
                                ovals: _ovals,
                                freehands: _freehands,
                                textNotes: _textNotes,
                                callouts: _callouts,
                                blurs: _blurs,
                                imageRect: imageRect,
                                selectedDimensionId: _selectedDimensionId,
                                selectedArrowId: _selectedArrowId,
                                selectedRectangleId: _selectedRectangleId,
                                selectedOvalId: _selectedOvalId,
                                selectedFreehandId: _selectedFreehandId,
                                selectedTextNoteId: _selectedTextNoteId,
                                selectedCalloutId: _selectedCalloutId,
                                selectedBlurId: _selectedBlurId,
                                activeStylePresetId: _selectedStylePresetId,
                                activeTool: _selectedTool,
                                activeStart: _activeDimensionStart,
                                activeEnd: _activeDimensionCurrent,
                                activeFreehandPoints: _activeFreehandPoints,
                                activeStrokeWidthScale:
                                    _selectedStrokeWidthScale,
                                activeFilled: _selectedShapeFilled,
                                isEnabled: _isOverlayInteractionEnabled(
                                  imageRect,
                                ),
                                onStart: (Offset point) =>
                                    _onDimensionStart(point, imageRect),
                                onUpdate: (Offset point) =>
                                    _onDimensionUpdate(point, imageRect),
                                onEnd: () => _onDimensionEnd(imageRect),
                                onTap: (Offset point) =>
                                    _onDimensionTap(point, imageRect),
                              ),
                              if (_isPickingFile)
                                Container(
                                  color: AppThemeConstants.toolbarBackground
                                      .withAlpha(200),
                                  alignment: Alignment.center,
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CircularProgressIndicator(),
                                      SizedBox(
                                        height: UiLayoutConstants.messageTopGap,
                                      ),
                                      Text(
                                        UiCopyConstants.importInProgressMessage,
                                        style: TextStyle(
                                          fontSize:
                                              UiLayoutConstants.messageFontSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: UiLayoutConstants.viewControlPanelTop,
                      right: UiLayoutConstants.viewControlPanelRight,
                      child: _buildCanvasViewControls(),
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
  dimensionLabel,
  arrowStart,
  arrowEnd,
  rectangleCorner,
  ovalCorner,
  blurCorner,
}

class _HandleDragSession {
  _HandleDragSession({
    required this.markupId,
    required this.handleKind,
    required this.startPoint,
    this.cornerIndex,
    this.referenceOffset,
  });

  final int markupId;
  final _HandleKind handleKind;
  final Offset startPoint;
  final int? cornerIndex;
  final Offset? referenceOffset;
  bool isDragActive = false;
}

class _StyleDialogResult {
  const _StyleDialogResult({
    required this.presetId,
    required this.fontFamily,
    required this.fontSize,
    required this.strokeWidthScale,
    required this.filled,
    required this.calloutLabelStyle,
  });

  final MarkupStylePresetId presetId;
  final String fontFamily;
  final double fontSize;
  final double strokeWidthScale;
  final bool filled;
  final CalloutLabelStyle calloutLabelStyle;
}

class _SidebarActionSection extends StatelessWidget {
  const _SidebarActionSection({
    required this.title,
    required this.isExpanded,
    required this.child,
  });

  final String title;
  final bool isExpanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TextStyle sectionStyle = const TextStyle(
      fontSize: UiLayoutConstants.sidebarSectionTitleFontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: AppThemeConstants.sidebarSectionLabel,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(
              left: UiLayoutConstants.sidebarSectionHorizontalPadding,
              right: UiLayoutConstants.sidebarSectionHorizontalPadding,
              bottom: UiLayoutConstants.sidebarSectionHeaderBottomGap,
            ),
            child: Text(title, style: sectionStyle),
          ),
        if (!isExpanded)
          const Divider(
            thickness: UiLayoutConstants.sidebarActionUnselectedBorderWidth,
            color: AppThemeConstants.sidebarDivider,
          ),
        child,
        const SizedBox(height: UiLayoutConstants.sidebarSectionBottomPadding),
      ],
    );
  }
}

class _SidebarActionButton extends StatelessWidget {
  const _SidebarActionButton({
    required this.actionKey,
    required this.label,
    required this.tooltipLabel,
    required this.iconDescriptor,
    required this.iconColor,
    required this.isExpanded,
    required this.onPressed,
    required this.isSelected,
    required this.isDisabled,
  });

  final String actionKey;
  final String label;
  final String tooltipLabel;
  final SidebarIconDescriptor iconDescriptor;
  final Color iconColor;
  final bool isExpanded;
  final VoidCallback onPressed;
  final bool isSelected;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = isExpanded
        ? UiLayoutConstants.sidebarExpandedActionHorizontalPadding
        : UiLayoutConstants.sidebarCollapsedActionHorizontalPadding;
    final Color resolvedIconColor = isDisabled
        ? AppThemeConstants.sidebarIconMuted.withValues(alpha: 0.55)
        : iconColor;
    final Color textColor = isDisabled
        ? AppThemeConstants.sidebarIconMuted.withValues(alpha: 0.65)
        : AppThemeConstants.sidebarIconNeutral;
    final Color backgroundColor = isSelected
        ? AppThemeConstants.sidebarSelectedTint
        : Colors.transparent;
    final BorderSide borderSide = BorderSide(
      color: isSelected
          ? AppThemeConstants.ncdBlue.withValues(alpha: 0.30)
          : Colors.transparent,
      width: UiLayoutConstants.sidebarActionSelectedBorderWidth,
    );
    final Widget iconWidget = _buildIconWidget(
      resolvedIconColor: resolvedIconColor,
      isDisabled: isDisabled,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Tooltip(
        message: tooltipLabel,
        child: SizedBox(
          key: ValueKey<String>(
            'sidebar-${isExpanded ? 'drawer' : 'rail'}-$actionKey',
          ),
          height: UiLayoutConstants.sidebarActionHeight,
          child: Material(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                UiLayoutConstants.sidebarActionRadius,
              ),
              side: borderSide,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(
                UiLayoutConstants.sidebarActionRadius,
              ),
              onTap: isDisabled ? null : onPressed,
              child: isExpanded
                  ? Row(
                      children: [
                        if (isSelected)
                          Container(
                            width:
                                UiLayoutConstants.sidebarSelectedIndicatorWidth,
                            height: UiLayoutConstants.sidebarActionHeight - 10,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: AppThemeConstants.sidebarSelectedIndicator,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        else
                          const SizedBox(width: 8),
                        iconWidget,
                        const SizedBox(
                          width: UiLayoutConstants.sidebarActionLabelGap,
                        ),
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: UiLayoutConstants.sidebarActionFontSize,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        if (isSelected)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: UiLayoutConstants
                                  .sidebarSelectedIndicatorWidth,
                              height:
                                  UiLayoutConstants.sidebarActionHeight - 12,
                              margin: const EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppThemeConstants.sidebarSelectedIndicator,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        Center(child: iconWidget),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWidget({
    required Color resolvedIconColor,
    required bool isDisabled,
  }) {
    final IconData? iconData = iconDescriptor.iconData;
    if (iconData != null) {
      return Icon(
        iconData,
        size: UiLayoutConstants.sidebarActionIconSize,
        color: resolvedIconColor,
      );
    }

    final String? assetPath = iconDescriptor.assetPath;
    if (assetPath != null) {
      final Color? tintedColor = iconDescriptor.allowTint
          ? resolvedIconColor
          : null;
      return Image.asset(
        assetPath,
        width: UiLayoutConstants.sidebarActionIconSize,
        height: UiLayoutConstants.sidebarActionIconSize,
        color: tintedColor,
        filterQuality: FilterQuality.high,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) =>
                Icon(
                  Icons.broken_image_outlined,
                  size: UiLayoutConstants.sidebarActionIconSize,
                  color: isDisabled
                      ? AppThemeConstants.sidebarIconMuted.withValues(
                          alpha: 0.55,
                        )
                      : AppThemeConstants.sidebarDestructiveAccent,
                ),
      );
    }

    return Icon(
      Icons.help_outline,
      size: UiLayoutConstants.sidebarActionIconSize,
      color: resolvedIconColor,
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
