import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';

class SidebarIconDescriptor {
  const SidebarIconDescriptor.icon(
    this.iconData, {
    this.assetPath,
    this.allowTint = true,
  });

  const SidebarIconDescriptor.asset(
    this.assetPath, {
    this.iconData,
    this.allowTint = false,
  });

  final IconData? iconData;
  final String? assetPath;
  final bool allowTint;
}

class SidebarIconRegistry {
  const SidebarIconRegistry._();

  /// Which artwork the rail uses.
  ///
  /// The NCD pack is full-colour tiles drawn for the old light sidebar. On the
  /// dark rail the tiles cannot pick up the selected, disabled or destructive
  /// tint that now carries state, and there is no NCD artwork for the tools
  /// added tonight, so a mixed rail looked like two different apps. The line
  /// pack is one consistent system that inherits the theme. Flip this to true
  /// to go back to the NCD tiles; the artwork is still in the repo.
  static const bool useNcdArtworkPack = false;

  static Map<String, SidebarIconDescriptor> get actionIcons =>
      useNcdArtworkPack ? ncdArtworkIcons : lineIcons;

  /// One consistent stroke-drawn set, tintable so the rail can show which tool
  /// is active and which command is unavailable.
  static const Map<String, SidebarIconDescriptor>
  lineIcons = <String, SidebarIconDescriptor>{
    ToolbarConstants.openPhoto: SidebarIconDescriptor.icon(
      Icons.add_photo_alternate_outlined,
    ),
    ToolbarConstants.openMarkup: SidebarIconDescriptor.icon(
      Icons.folder_open_outlined,
    ),
    ToolbarConstants.saveMarkup: SidebarIconDescriptor.icon(
      Icons.save_outlined,
    ),
    ToolbarConstants.export: SidebarIconDescriptor.icon(Icons.bolt_outlined),
    ToolbarConstants.exportAs: SidebarIconDescriptor.icon(
      Icons.ios_share_outlined,
    ),
    ToolbarConstants.dimension: SidebarIconDescriptor.icon(
      Icons.straighten_outlined,
    ),
    ToolbarConstants.textNote: SidebarIconDescriptor.icon(Icons.text_fields),
    ToolbarConstants.arrow: SidebarIconDescriptor.icon(
      Icons.north_east_outlined,
    ),
    ToolbarConstants.line: SidebarIconDescriptor.icon(Icons.horizontal_rule),
    ToolbarConstants.rectangle: SidebarIconDescriptor.icon(
      Icons.crop_square_outlined,
    ),
    ToolbarConstants.circle: SidebarIconDescriptor.icon(Icons.circle_outlined),
    ToolbarConstants.freehand: SidebarIconDescriptor.icon(
      Icons.gesture_outlined,
    ),
    ToolbarConstants.highlighter: SidebarIconDescriptor.icon(
      Icons.brush_outlined,
    ),
    ToolbarConstants.callout: SidebarIconDescriptor.icon(
      Icons.filter_1_outlined,
    ),
    ToolbarConstants.blur: SidebarIconDescriptor.icon(Icons.blur_on),
    ToolbarConstants.scale: SidebarIconDescriptor.icon(
      Icons.square_foot_outlined,
    ),
    ToolbarConstants.style: SidebarIconDescriptor.icon(Icons.palette_outlined),
    ToolbarConstants.undo: SidebarIconDescriptor.icon(Icons.undo),
    ToolbarConstants.redo: SidebarIconDescriptor.icon(Icons.redo),
    ToolbarConstants.erase: SidebarIconDescriptor.icon(Icons.delete_outline),
    ToolbarConstants.clearAll: SidebarIconDescriptor.icon(
      Icons.layers_clear_outlined,
    ),
    ToolbarConstants.rotateLeft: SidebarIconDescriptor.icon(
      Icons.rotate_90_degrees_ccw_outlined,
    ),
    ToolbarConstants.rotateRight: SidebarIconDescriptor.icon(
      Icons.rotate_90_degrees_cw_outlined,
    ),
    ToolbarConstants.markerMode: SidebarIconDescriptor.icon(
      Icons.draw_outlined,
    ),
  };

  /// The NCD-drawn tiles, kept intact. Tools added after the pack was drawn
  /// fall back to the line set.
  static Map<String, SidebarIconDescriptor> get ncdArtworkIcons =>
      <String, SidebarIconDescriptor>{
        ...lineIcons,
        ToolbarConstants.openPhoto: const SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarOpenPhotoAssetPath,
        ),
        ToolbarConstants.openMarkup: const SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarOpenMarkupAssetPath,
        ),
        ToolbarConstants.saveMarkup: const SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarSaveMarkupAssetPath,
        ),
        ToolbarConstants.export: const SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarExportAssetPath,
        ),
        ToolbarConstants.dimension: const SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarDimensionAssetPath,
        ),
        ToolbarConstants.textNote: const SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarTextNoteAssetPath,
        ),
        ToolbarConstants.arrow: const SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarArrowAssetPath,
        ),
        ToolbarConstants.rectangle: const SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarRectangleAssetPath,
        ),
        ToolbarConstants.circle: const SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarCircleAssetPath,
        ),
        ToolbarConstants.freehand: const SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarFreehandAssetPath,
        ),
        ToolbarConstants.undo: const SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarUndoAssetPath,
        ),
        ToolbarConstants.erase: const SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarEraseAssetPath,
        ),
      };
}
