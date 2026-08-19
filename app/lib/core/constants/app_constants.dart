import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class AppConstants {
  const AppConstants._();

  static const String appName = 'NCD Photo Markup';
  static const String appVersion = 'v0.32';
  static const String startupImageEnvKey = 'NCD_STARTUP_IMAGE_PATH';
}

class LaunchContextConstants {
  const LaunchContextConstants._();

  static const String argPrefix = '--';
  static const String argKeyValueSeparator = '=';
  static const String boolTrueString = 'true';

  static const String argLaunchContextPath = 'launchContextPath';
  static const String argLaunchedFromControlCenter =
      'launchedFromControlCenter';
  static const String argClientId = 'clientId';
  static const String argClientName = 'clientName';
  static const String argProjectId = 'projectId';
  static const String argProjectCode = 'projectCode';
  static const String argSourceImagePath = 'sourceImagePath';
  static const String argSuggestedExportFolder = 'suggestedExportFolder';
  static const String argSuggestedEditableMarkupFolder =
      'suggestedEditableMarkupFolder';
  static const String argReturnMode = 'returnMode';
  static const String argSourceLabel = 'sourceLabel';

  static const Set<String> supportedArgKeys = <String>{
    argLaunchContextPath,
    argLaunchedFromControlCenter,
    argClientId,
    argClientName,
    argProjectId,
    argProjectCode,
    argSourceImagePath,
    argSuggestedExportFolder,
    argSuggestedEditableMarkupFolder,
    argReturnMode,
    argSourceLabel,
  };

  static const List<String> contractFieldKeys = <String>[
    argLaunchedFromControlCenter,
    argClientId,
    argClientName,
    argProjectId,
    argProjectCode,
    argSourceImagePath,
    argSuggestedExportFolder,
    argSuggestedEditableMarkupFolder,
    argReturnMode,
    argSourceLabel,
  ];

  static const String defaultReturnMode = 'manual';
  static const Set<String> allowedReturnModes = <String>{
    'manual',
    'return_to_control_center',
    'none',
  };
  static const Set<String> trueValues = <String>{'1', 'true', 'yes', 'y', 'on'};
}

class BrandingAssetConstants {
  const BrandingAssetConstants._();

  static const String iconV15AssetPath = 'assets/branding/icon_v1_5.png';
  static const String splashV15AssetPath = 'assets/branding/splash_v1_5.png';
  static const int startupSplashDurationMs = 2200;
}

class AppThemeConstants {
  const AppThemeConstants._();

  static const Color ncdBlue = Color(0xFF009ADA);
  static const Color toolbarBackground = Color(0xFFF2FAFE);
  static const Color canvasFooterBorder = Color(0xFFD8E5EB);
  static const Color sidebarBackground = Color(0xFFF6FAFD);
  static const Color sidebarIconNeutral = Color(0xFF27313A);
  static const Color sidebarIconMuted = Color(0xFF5B6570);
  static const Color sidebarFileAccent = Color(0xFF007FB7);
  static const Color sidebarDestructiveAccent = Color(0xFFC64A4A);
  static const Color sidebarSelectedTint = Color(0x1A009ADA);
  static const Color sidebarSelectedIndicator = Color(0xFF009ADA);
  static const Color sidebarSectionLabel = Color(0xFF4D5A68);
  static const Color sidebarDivider = Color(0xFFE0E8EE);
  static const Color sidebarHeaderText = Color(0xFF1D2A33);
  static const Color errorAccent = Colors.redAccent;
  static const Color viewControlSurface = Color(0xEAF6FAFD);
  static const Color viewControlBorder = Color(0xFFD0DEE8);
  static const Color viewControlIcon = Color(0xFF1F2C36);
  static const Color viewControlAccent = Color(0xFF007FB7);
}

class ImageImportConstants {
  const ImageImportConstants._();

  static const String pickerGroupLabel = 'Images';
  static const String pickerConfirmButtonText = 'Open Photo';
  static const List<String> supportedExtensions = <String>[
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'heif',
    'dwg',
  ];
  static const Set<String> supportedExtensionsSet = <String>{
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'heif',
    'dwg',
  };
  static const Set<String> heicExtensionsSet = <String>{'heic', 'heif'};
  static const Set<String> dwgExtensionsSet = <String>{'dwg'};
  static const String heicPreviewCacheFolderName =
      'ncd_photo_markup_heic_cache';
  static const String dwgPreviewCacheFolderName = 'ncd_photo_markup_dwg_cache';
  static const String heicPreviewCacheKeyVersion = 'v2';
  static const String dwgPreviewCacheKeyVersion = 'v3';
  static const int heicMaxPreviewDimension = 2560;
  static const int heicPreviewJpegQuality = 85;
  static const int dwgPreviewSearchByteLimit = 262144;
  static const int dwgPreviewMinimumWidth = 384;
  static const int dwgPreviewMinimumHeight = 216;
  static const int dwgPreviewDarkPixelThreshold = 16;
  static const int dwgPreviewOpaqueAlphaThreshold = 32;
  static const double dwgPreviewMaximumDarkPixelRatio = 0.88;
  static const double dwgPreviewMaximumDarkAreaRatio = 0.18;
  static const double dwgPreviewMaximumDominantMarginRatio = 0.35;
  static const bool heicPreferFallbackConverterFirst = false;
  static const Duration heicPackageConversionTimeout = Duration(seconds: 3);
  static const Duration heicFallbackConversionTimeout = Duration(seconds: 20);
  static const int tempConvertedFileMaxAgeHours = 24;
  static const int tempConvertedFileMaxCount = 25;
  static const String heicConversionFailedMessage =
      'Could not open this HEIC image. Please convert it to JPG/PNG or try another photo.';
  static const String dwgPreviewUnavailableMessage =
      'Could not create a usable DWG preview. This DWG needs an approved offline DWG converter.';
  static const String dwgPreviewRejectedTooSmallReason =
      'preview dimensions are below the minimum usable size';
  static const String dwgPreviewRejectedEmptyReason =
      'preview does not contain visible drawing content';
  static const String dwgPreviewRejectedMostlyDarkReason =
      'preview is mostly dark background with too little drawing area';
  static const String dwgPreviewRejectedMarginReason =
      'preview has extreme empty margins and appears partial';
  static const String dwgPreviewRejectedDecodeReason =
      'preview could not be decoded for quality validation';
  static const String dwgOfflineConverterCommandEnvVar =
      'NCD_PM_DWG_CONVERTER_COMMAND';
  static const String dwgOfflineConverterStrategyNameEnvVar =
      'NCD_PM_DWG_CONVERTER_STRATEGY_NAME';
  static const String dwgOfflineConverterOutputExtensionEnvVar =
      'NCD_PM_DWG_CONVERTER_OUTPUT_EXTENSION';
  static const String dwgOfflineConverterTimeoutSecondsEnvVar =
      'NCD_PM_DWG_CONVERTER_TIMEOUT_SECONDS';
  static const String dwgOfflineConverterDefaultStrategyName =
      'configured-offline-preview-pipeline';
  static const String dwgOfflineConverterDefaultOutputExtension = 'png';
  static const Duration dwgOfflineConverterTimeout = Duration(seconds: 20);
  static const List<String> dwgOfflineConverterAllowedOutputExtensions =
      <String>['png', 'jpg', 'jpeg', 'bmp'];
  static const String dwgOfflineConverterMissingReason =
      'offline converter command is not configured';
  static const String dwgOfflineConverterLaunchFailedReason =
      'offline converter command could not be started';
  static const String dwgOfflineConverterTimeoutReason =
      'offline converter command timed out';
  static const String dwgOfflineConverterExitCodeReason =
      'offline converter command returned a non-zero exit code';
  static const String dwgOfflineConverterOutputMissingReason =
      'offline converter command did not produce an output preview file';
  static const String dwgOfflineConverterOutputRejectedReason =
      'offline converter output failed the governed preview quality gate';
  static const List<String> dwgConverterCommandCandidates = <String>[
    'ODAFileConverter',
    'TeighaFileConverter',
    'dwgread',
    'LibreCAD',
  ];
  static const List<String> dwgPreviewCacheExtensions = <String>[
    'png',
    'bmp',
    'jpg',
    'jpeg',
  ];
  static const String heicTempSuffix = '_heic_converted';
  static const String heicConvertedOutputExtension = 'jpg';
  static const String heicFallbackConverterCommand = 'magick';
  static const String heicFallbackResizeOption =
      '$heicMaxPreviewDimension'
      'x$heicMaxPreviewDimension>';
  static const String heicFallbackQualityOption = '$heicPreviewJpegQuality';
  static const List<String> heicFallbackConverterOptions = <String>[
    '-auto-orient',
    '-resize',
    heicFallbackResizeOption,
    '-quality',
    heicFallbackQualityOption,
  ];
  static const String importDiagnosticsPrefix = '[ImageImport]';
  static const String openErrorMessage =
      'Could not open this image. Please choose a JPG, PNG, WEBP, HEIC/HEIF, or DWG file.';
  static const String loadedPhotoPrefix = 'Loaded photo: ';
  static const String unknownLoadedPhotoName = 'Unknown';

  static const XTypeGroup imageTypeGroup = XTypeGroup(
    label: pickerGroupLabel,
    extensions: supportedExtensions,
  );
}

class UiCopyConstants {
  const UiCopyConstants._();

  static const String emptyStateTitle = 'Photo Canvas Placeholder';
  static const String emptyStateMessage =
      'Open or import a photo to start marking it up.';
  static const String splashFallbackLabel = 'NCD Photo Markup';
  static const String dimensionLabelDialogTitle = 'Dimension Label';
  static const String dimensionLabelHint = 'Example: 72" or 6\'-0"';
  static const String dimensionLabelSaveButton = 'Save';
  static const String dimensionLabelSkipButton = 'Skip';
  static const String textNoteDialogTitle = 'Text Note';
  static const String textNoteHint = 'Example: Replace drywall here';
  static const String textNoteSaveButton = 'Save';
  static const String textNoteSkipButton = 'Skip';
  static const String importInProgressMessage = 'Opening photo...';
  static const String importErrorDialogTitle = 'Open Photo Failed';
  static const String importErrorDialogDismissButton = 'OK';
  static const String styleDialogTitle = 'Markup Style & Text';
  static const String styleDialogPresetsSectionTitle = 'Color Preset';
  static const String styleDialogTypographySectionTitle = 'Text Typography';
  static const String styleDialogFontFamilyLabel = 'Font';
  static const String styleDialogFontSizeLabel = 'Size';
  static const String styleDialogApplyButton = 'Apply';
  static const String styleDialogCancelButton = 'Cancel';
  static const String styleApplyToSelectedMessage =
      'Style and text settings applied to selection.';
  static const String markupDocumentOpenFailureMessage =
      'Could not open this markup file. Please choose a valid .ncdmarkup.json file.';
  static const String markupDocumentMissingSourceTitle = 'Source Photo Needed';
  static const String markupDocumentSaveNoPhotoMessage =
      'Load a photo before saving markup.';
  static const String markupDocumentSaveSuccessMessage =
      'Markup save complete.';
  static const String markupDocumentSaveFailureMessage =
      'Could not save markup. Please try again.';
  static const String markupDocumentOpenSuccessMessage = 'Markup file loaded.';
  static const String markupDocumentMissingSourceMessage =
      'This markup file references a missing source image. Select the source photo to continue.';
  static const String markupDocumentNoSourceMessage =
      'This markup file does not include a source image path. Select the source photo to continue.';
  static const String markupDocumentLocateImageButton = 'Locate Image';
  static const String markupDocumentCancelButton = 'Cancel';
  static const String exportNoPhotoMessage = 'Load a photo before exporting.';
  static const String exportSuccessMessage = 'Export complete.';
  static const String exportFailureMessage =
      'Could not export this image. Please try again.';
  static const String unsavedChangesWarningTitle = 'Unsaved Markups';
  static const String unsavedChangesWarningBody =
      'You have unsaved markup changes. Export or discard before continuing.';
  static const String unsavedChangesExportButton = 'Export';
  static const String unsavedChangesDiscardButton = 'Discard';
  static const String unsavedChangesCancelButton = 'Cancel';
  static const String eraseNoSelectionMessage = 'Select a markup to erase.';
  static const String undoNothingMessage = 'Nothing left to undo.';
  static const String redoNothingMessage = 'Nothing to redo.';
  static const String clearAllDialogTitle = 'Clear All Markup?';
  static const String clearAllDialogBody =
      'This removes every markup on this photo. Undo can bring it back.';
  static const String clearAllConfirmButton = 'Clear All';
  static const String clearAllCancelButton = 'Keep Markup';
  static const String clearAllNothingMessage = 'There is no markup to clear.';
  static const String clearAllDoneMessage = 'All markup cleared.';
  static const String launchContextFileNotFoundMessage =
      'Launch context file was not found. You can still open a photo manually.';
  static const String launchContextInvalidJsonMessage =
      'Launch context could not be read. You can still open a photo manually.';
  static const String launchSourceImageInvalidMessage =
      'Launch photo path is invalid or unsupported. Use Open Photo to continue.';
  static const String launchContextLabelPrefix = 'Control Center Context';
  static const String launchContextSourceLabelPrefix = 'Source';
  static const String launchContextClientLabelPrefix = 'Client';
  static const String launchContextProjectLabelPrefix = 'Project';
  static const String toolbarActiveToolPrefix = 'Active Tool';
  static const String toolbarActiveToolNone = 'Select';
  static const String sidebarExpandTooltip = 'Expand Sidebar';
  static const String sidebarCollapseTooltip = 'Collapse Sidebar';
  static const String sidebarStylePrefix = 'Style';
  static const String sidebarTitle = 'Quick Actions';
  static const String viewZoomOutTooltip = 'Zoom Out';
  static const String viewZoomInTooltip = 'Zoom In';
  static const String viewFitTooltip = 'Fit to Screen';
  static const String viewActualSizeTooltip = 'Actual Size (100%)';
  static const String viewPanEnableTooltip = 'Enable Pan Drag';
  static const String viewPanDisableTooltip = 'Disable Pan Drag';
  static const String viewZoomPrefix = 'Zoom';
  static const String viewPanLabel = 'Pan';
  static const String viewStateOn = 'On';
  static const String viewStateOff = 'Off';
}

class ViewControlConstants {
  const ViewControlConstants._();

  static const double defaultScale = 1.0;
  static const double minScale = 1.0;
  static const double maxScale = 5.0;
  static const double buttonZoomStep = 0.25;
  static const double wheelZoomSensitivity = 0.0015;
  static const double panStepMultiplier = 1.0;
  static const double scaleEpsilon = 0.001;
  static const EdgeInsets boundaryMargin = EdgeInsets.all(1200);
}

class MarkupTypographyConstants {
  const MarkupTypographyConstants._();

  static const String defaultFontFamily = 'Default/System';
  static const List<String> allowedFontFamilies = <String>[
    defaultFontFamily,
    'Segoe UI',
    'Arial',
    'Calibri',
  ];
  static const double defaultFontSize = 15;
  static const double minFontSize = 10;
  static const double maxFontSize = 72;
  static const double fontSizeStep = 1;
}

class ToolbarSectionDefinition {
  const ToolbarSectionDefinition({required this.title, required this.actions});

  final String title;
  final List<String> actions;
}

class ToolbarConstants {
  const ToolbarConstants._();

  static const String openPhoto = 'Open Photo';
  static const String openMarkup = 'Open Markup';
  static const String saveMarkup = 'Save Markup';
  static const String dimension = 'Dimension';
  static const String arrow = 'Arrow';
  static const String circle = 'Circle';
  static const String rectangle = 'Rectangle';
  static const String freehand = 'Freehand';
  static const String textNote = 'Text Note';
  static const String style = 'Style';
  static const String erase = 'Erase';
  static const String undo = 'Undo';
  static const String redo = 'Redo';
  static const String clearAll = 'Clear All';
  static const String export = 'Export';
  static const String fileSectionTitle = 'File';
  static const String markupSectionTitle = 'Markup Tools';
  static const String editSectionTitle = 'Edit';

  static const List<String> fileActionOrder = <String>[
    openPhoto,
    openMarkup,
    saveMarkup,
    export,
  ];
  static const List<String> markupActionOrder = <String>[
    dimension,
    textNote,
    arrow,
    rectangle,
    circle,
    freehand,
  ];
  static const List<String> editActionOrder = <String>[
    style,
    undo,
    redo,
    erase,
    clearAll,
  ];

  static const List<ToolbarSectionDefinition>
  sections = <ToolbarSectionDefinition>[
    ToolbarSectionDefinition(title: fileSectionTitle, actions: fileActionOrder),
    ToolbarSectionDefinition(
      title: markupSectionTitle,
      actions: markupActionOrder,
    ),
    ToolbarSectionDefinition(title: editSectionTitle, actions: editActionOrder),
  ];

  static const List<String> labels = <String>[
    ...fileActionOrder,
    ...markupActionOrder,
    ...editActionOrder,
  ];
}

class SidebarConstants {
  const SidebarConstants._();
}

class SidebarAssetConstants {
  const SidebarAssetConstants._();

  static const String ncdSidebarAssetDirectory =
      'assets/sidebar_icons/ncd_custom';

  static const String ncdSidebarOpenPhotoAssetPath =
      '$ncdSidebarAssetDirectory/open_photo.png';
  static const String ncdSidebarOpenMarkupAssetPath =
      '$ncdSidebarAssetDirectory/open_markup.png';
  static const String ncdSidebarSaveMarkupAssetPath =
      '$ncdSidebarAssetDirectory/save_markup.png';
  static const String ncdSidebarExportAssetPath =
      '$ncdSidebarAssetDirectory/export.png';
  static const String ncdSidebarDimensionAssetPath =
      '$ncdSidebarAssetDirectory/dimension.png';
  static const String ncdSidebarTextNoteAssetPath =
      '$ncdSidebarAssetDirectory/text_note.png';
  static const String ncdSidebarArrowAssetPath =
      '$ncdSidebarAssetDirectory/arrow.png';
  static const String ncdSidebarRectangleAssetPath =
      '$ncdSidebarAssetDirectory/rectangle.png';
  static const String ncdSidebarCircleAssetPath =
      '$ncdSidebarAssetDirectory/circle.png';
  static const String ncdSidebarFreehandAssetPath =
      '$ncdSidebarAssetDirectory/freehand.png';
  static const String ncdSidebarUndoAssetPath =
      '$ncdSidebarAssetDirectory/undo.png';
  static const String ncdSidebarEraseAssetPath =
      '$ncdSidebarAssetDirectory/erase.png';

  static const String ncdSidebarStyleNcdBlueAssetPath =
      '$ncdSidebarAssetDirectory/style_ncd_blue.png';
  static const String ncdSidebarStyleRedAssetPath =
      '$ncdSidebarAssetDirectory/style_red.png';
  static const String ncdSidebarStyleYellowAssetPath =
      '$ncdSidebarAssetDirectory/style_yellow.png';
  static const String ncdSidebarStyleWhiteAssetPath =
      '$ncdSidebarAssetDirectory/style_white.png';
  static const String ncdSidebarStyleBlackAssetPath =
      '$ncdSidebarAssetDirectory/style_black.png';
}

class UiLayoutConstants {
  const UiLayoutConstants._();

  static const double appBarBrandingIconSize = 32;
  static const double appBarBrandingIconPadding = 8;
  static const double splashImageWidthFactor = 0.97;
  static const double splashImageHeightFactor = 0.88;
  static const double splashImageHorizontalPadding = 12;
  static const double splashTitleTopGap = 16;
  static const double splashVersionTopGap = 6;
  static const double splashVersionFontSize = 14;
  static const double loadedNameMaxWidth = 260;
  static const double appBarLoadedNameRightPadding = 10;
  static const double appBarVersionRightPadding = 16;
  static const double launchContextBannerHorizontalPadding = 12;
  static const double launchContextBannerVerticalPadding = 8;
  static const double launchContextBannerFontSize = 12;
  static const double launchContextBannerGap = 6;
  static const double canvasOuterPadding = 20;
  static const double canvasBorderRadius = 12;
  static const double canvasBorderWidth = 2;
  static const double toolbarHorizontalPadding = 12;
  static const double toolbarVerticalPadding = 12;
  static const double toolbarTopStatusBottomGap = 10;
  static const double toolbarSectionGap = 14;
  static const double toolbarSectionHeaderBottomGap = 8;
  static const double toolbarSectionDividerIndent = 6;
  static const double toolbarSectionDividerEndIndent = 6;
  static const double toolbarSectionDividerWidth = 1.6;
  static const double toolbarSectionTitleFontSize = 13;
  static const double toolbarStatusFontSize = 13;
  static const double toolbarButtonGap = 4;
  static const double sidebarCollapsedWidth = 54;
  static const double sidebarExpandedWidth = 252;
  static const double sidebarMinimumCanvasWidth = 340;
  static const double sidebarHeaderHorizontalPadding = 6;
  static const double sidebarHeaderTopPadding = 6;
  static const double sidebarHeaderBottomPadding = 4;
  static const double sidebarSectionHorizontalPadding = 6;
  static const double sidebarSectionBottomPadding = 4;
  static const double sidebarActionGap = 2;
  static const double sidebarActionHeight = 42;
  static const double sidebarActionIconSize = 21;
  static const double sidebarActionFontSize = 14;
  static const double sidebarActionLabelGap = 8;
  static const double sidebarActionRadius = 8;
  static const double sidebarSelectedIndicatorWidth = 3;
  static const double sidebarHeaderIconSize = 21;
  static const double sidebarHeaderTitleFontSize = 12;
  static const double sidebarStyleSummaryFontSize = 11;
  static const double sidebarSectionTitleFontSize = 11;
  static const double sidebarActionSelectedBorderWidth = 1;
  static const double sidebarActionUnselectedBorderWidth = 1;
  static const double sidebarSectionHeaderBottomGap = 4;
  static const double sidebarCollapsedActionHorizontalPadding = 4;
  static const double sidebarExpandedActionHorizontalPadding = 8;
  static const double sidebarHeaderChipGap = 4;
  static const double sidebarHeaderChipVerticalPadding = 3;
  static const double sidebarHeaderChipHorizontalPadding = 8;
  static const double emptyStateHorizontalPadding = 24;
  static const double emptyStateIconSize = 64;
  static const double emptyStateTitleFontSize = 24;
  static const double emptyStateBodyFontSize = 18;
  static const double messageFontSize = 15;
  static const double emptyStateIconBottomGap = 16;
  static const double emptyStateTitleBottomGap = 12;
  static const double messageTopGap = 14;
  static const double imageAreaPadding = 12;
  static const double footerHorizontalPadding = 12;
  static const double footerVerticalPadding = 10;
  static const double toolbarButtonHeight = 56;
  static const double toolbarButtonMinWidth = 116;
  static const double toolbarButtonFontSize = 16;
  static const double loadedNameFontSize = 13;
  static const double toolbarButtonSelectedBorderWidth = 2.4;
  static const double viewControlPanelTop = 12;
  static const double viewControlPanelRight = 12;
  static const double viewControlPanelPadding = 6;
  static const double viewControlPanelRadius = 10;
  static const double viewControlPanelBorderWidth = 1;
  static const double viewControlButtonSize = 38;
  static const double viewControlIconSize = 20;
  static const double viewControlGap = 4;
  static const double viewControlZoomLabelWidth = 66;
  static const double viewControlZoomLabelFontSize = 12;
  static const double viewControlPanLabelFontSize = 11;
  static const double viewControlPanLabelTopGap = 2;
  static const double dimensionEndpointOuterRadius = 5;
  static const double dimensionEndpointInnerRadius = 2.5;
  static const double dimensionTapDragMinDistance = 6;
  static const double dimensionLabelFontSize = 15;
  static const double dimensionLabelVerticalPadding = 6;
  static const double dimensionLabelHorizontalPadding = 10;
  static const double dimensionLabelBorderRadius = 8;
  static const double dimensionLabelOffsetFromLine = 14;
  static const double dimensionLabelClampPadding = 4;
  static const double dimensionLabelDialogFieldMinHeight = 64;
  static const double dimensionLabelDialogFieldPadding = 12;
  static const double dimensionLabelDialogButtonTopGap = 8;
}

class DimensionLineConstants {
  const DimensionLineConstants._();

  static const Color lineColor = Color(0xFF005C85);
  static const Color selectedLineColor = AppThemeConstants.ncdBlue;
  static const double strokeWidth = 3;
  static const double selectedStrokeMultiplier = 1.4;
  static const double endpointStrokeWidth = 1.2;
  static const Color endpointFillColor = Colors.white;
  static const Color labelTextColor = Colors.black87;
  static const Color labelBackgroundColor = Color(0xD9FFFFFF);
  static const Color labelBorderColor = Color(0xFF005C85);
  static const double labelBorderWidth = 1;
  static const double labelLeaderStrokeWidth = 1.6;
  static const double labelLeaderVisibilityThreshold = 12;
  static const double labelHitDistance = 18;
  static const double labelTextMaxWidthFactor = 0.8;
  static const double selectionTapDistance = 26;
  static const double tapMoveThreshold = 8;
  static const double defaultLabelOffsetFromLine = 14;
}

class ArrowMarkupConstants {
  const ArrowMarkupConstants._();

  static const Color lineColor = Color(0xFF006B3F);
  static const Color selectedLineColor = Color(0xFF009A5F);
  static const double strokeWidth = 3.2;
  static const double selectedStrokeMultiplier = 1.35;
  static const double arrowHeadLength = 16;
  static const double arrowHeadAngleDegrees = 28;
  static const double minLength = 8;
}

class RectangleMarkupConstants {
  const RectangleMarkupConstants._();

  static const Color outlineColor = Color(0xFF7A4B00);
  static const Color selectedOutlineColor = Color(0xFFA46600);
  static const Color fillColor = Color(0x1FBD8A2A);
  static const double strokeWidth = 3;
  static const double selectedStrokeMultiplier = 1.35;
  static const double minSideLength = 8;
  static const double selectionHitDistance = 26;
}

class OvalMarkupConstants {
  const OvalMarkupConstants._();

  static const Color outlineColor = Color(0xFF8B1E00);
  static const Color selectedOutlineColor = Color(0xFFC02A00);
  static const Color fillColor = Color(0x1FD4572A);
  static const double strokeWidth = 3;
  static const double selectedStrokeMultiplier = 1.35;
  static const double minAxisLength = 8;
  static const double selectionHitDistance = 26;
}

class FreehandMarkupConstants {
  const FreehandMarkupConstants._();

  static const Color strokeColor = Color(0xFF5A2099);
  static const Color selectedStrokeColor = Color(0xFF7B2FD6);
  static const double strokeWidth = 3.2;
  static const double selectedStrokeMultiplier = 1.35;
  static const double pointMinDistance = 4;
  static const double selectionHitDistance = 24;
  static const int minimumPointCount = 2;
}

class TextNoteMarkupConstants {
  const TextNoteMarkupConstants._();

  static const Color textColor = Colors.black87;
  static const Color backgroundColor = Color(0xD9FFFDE7);
  static const Color borderColor = Color(0xFF5A4A00);
  static const Color selectedBorderColor = AppThemeConstants.ncdBlue;
  static const double borderWidth = 1.2;
  static const double selectedBorderWidth = 2.2;
  static const double fontSize = MarkupTypographyConstants.defaultFontSize;
  static const double horizontalPadding = 10;
  static const double verticalPadding = 6;
  static const double borderRadius = 8;
  static const double clampPadding = 4;
  static const double maxWidthFactor = 0.7;
  static const double selectionHitDistance = 26;
}

class MarkupMoveConstants {
  const MarkupMoveConstants._();

  static const double dragActivationDistance = 8;
  static const double selectionStartHitDistance = 24;
  static const double boundsPadding = 0;
  static const double minimumMoveDelta = 0.5;
}

class MarkupHandleConstants {
  const MarkupHandleConstants._();

  static const double visibleRadius = 7;
  static const double hitDistance = 20;
  static const double dragActivationDistance = 6;
  static const Color fillColor = Color(0xFFF4FBFF);
  static const Color borderColor = Color(0xFF005C85);
  static const Color activeBorderColor = AppThemeConstants.ncdBlue;
  static const double borderWidth = 1.8;
  static const double activeBorderWidth = 2.4;
}

class MarkupHistoryConstants {
  const MarkupHistoryConstants._();

  static const int maxSteps = 80;
}

class ExportConstants {
  const ExportConstants._();

  static const String saveDialogConfirmButtonText = 'Export PNG';
  static const String saveTypeGroupLabel = 'PNG Image';
  static const String outputExtension = 'png';
  static const String defaultFileSuffix = ' - Markup';
  static const String duplicateNameSeparator = ' ';
  static const int duplicateNameStartIndex = 2;
  static const double maxPixelRatio = 3.0;

  static const XTypeGroup pngSaveTypeGroup = XTypeGroup(
    label: saveTypeGroupLabel,
    extensions: <String>[outputExtension],
  );
}

class EditableMarkupConstants {
  const EditableMarkupConstants._();

  static const String schemaVersion = '1.0';
  static const String saveDialogConfirmButtonText = 'Save Markup';
  static const String openDialogConfirmButtonText = 'Open Markup';
  static const String saveTypeGroupLabel = 'NCD Markup File';
  static const String outputExtension = 'json';
  static const String outputFileSuffix = '.ncdmarkup.json';
  static const String duplicateNameSeparator = ' ';
  static const int duplicateNameStartIndex = 2;

  static const XTypeGroup markupSaveTypeGroup = XTypeGroup(
    label: saveTypeGroupLabel,
    extensions: <String>[outputExtension],
  );

  static const XTypeGroup markupOpenTypeGroup = XTypeGroup(
    label: saveTypeGroupLabel,
    extensions: <String>[outputExtension],
  );
}
