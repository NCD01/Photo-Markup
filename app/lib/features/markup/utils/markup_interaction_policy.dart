import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';

class MarkupInteractionPolicy {
  const MarkupInteractionPolicy._();

  static bool allowsTapSelection(MarkupTool activeTool) {
    return activeTool == MarkupTool.none;
  }

  static bool allowsTextNoteCreation(MarkupTool activeTool) {
    return activeTool == MarkupTool.textNote;
  }

  static MarkupTool resolveRequestedTool({
    required MarkupTool currentTool,
    required MarkupTool requestedTool,
  }) {
    if (currentTool == requestedTool) {
      return MarkupTool.none;
    }
    return requestedTool;
  }
}
