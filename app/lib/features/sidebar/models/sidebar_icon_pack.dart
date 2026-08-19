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

  static const Map<String, SidebarIconDescriptor> actionIcons =
      <String, SidebarIconDescriptor>{
        ToolbarConstants.openPhoto: SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarOpenPhotoAssetPath,
        ),
        ToolbarConstants.openMarkup: SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarOpenMarkupAssetPath,
        ),
        ToolbarConstants.saveMarkup: SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarSaveMarkupAssetPath,
        ),
        ToolbarConstants.export: SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarExportAssetPath,
        ),
        ToolbarConstants.dimension: SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarDimensionAssetPath,
        ),
        ToolbarConstants.textNote: SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarTextNoteAssetPath,
        ),
        ToolbarConstants.arrow: SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarArrowAssetPath,
        ),
        ToolbarConstants.rectangle: SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarRectangleAssetPath,
        ),
        ToolbarConstants.circle: SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarCircleAssetPath,
        ),
        ToolbarConstants.freehand: SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarFreehandAssetPath,
        ),
        ToolbarConstants.style: SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarStyleNcdBlueAssetPath,
        ),
        ToolbarConstants.undo: SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarUndoAssetPath,
        ),
        ToolbarConstants.erase: SidebarIconDescriptor.asset(
          SidebarAssetConstants.ncdSidebarEraseAssetPath,
        ),
        // No NCD artwork exists for these yet, so they use Material glyphs that
        // pick up the sidebar tint like the rest of the rail.
        ToolbarConstants.redo: SidebarIconDescriptor.icon(Icons.redo),
        ToolbarConstants.clearAll: SidebarIconDescriptor.icon(
          Icons.layers_clear_outlined,
        ),
      };
}
