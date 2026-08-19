import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_snapshot.dart';

/// Multi-step undo and redo over whole-markup snapshots.
///
/// Call [record] with the state as it was *before* an edit. Undo then hands
/// that state back and parks the state you were in on the redo stack.
class MarkupHistory {
  final List<MarkupSnapshot> _undoStack = <MarkupSnapshot>[];
  final List<MarkupSnapshot> _redoStack = <MarkupSnapshot>[];

  bool get canUndo => _undoStack.isNotEmpty;

  bool get canRedo => _redoStack.isNotEmpty;

  int get undoDepth => _undoStack.length;

  int get redoDepth => _redoStack.length;

  /// Pushes the pre-edit state. A new edit invalidates anything to redo.
  ///
  /// Returns false and records nothing when [previous] is identical to
  /// [current], so a gesture that ended up changing nothing does not cost the
  /// user an undo step.
  bool record(MarkupSnapshot previous, MarkupSnapshot current) {
    if (previous == current) {
      return false;
    }
    _undoStack.add(previous);
    if (_undoStack.length > MarkupHistoryConstants.maxSteps) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    return true;
  }

  /// Returns the state to restore, or null when there is nothing to undo.
  MarkupSnapshot? undo(MarkupSnapshot current) {
    if (_undoStack.isEmpty) {
      return null;
    }
    final MarkupSnapshot previous = _undoStack.removeLast();
    _redoStack.add(current);
    if (_redoStack.length > MarkupHistoryConstants.maxSteps) {
      _redoStack.removeAt(0);
    }
    return previous;
  }

  /// Returns the state to restore, or null when there is nothing to redo.
  MarkupSnapshot? redo(MarkupSnapshot current) {
    if (_redoStack.isEmpty) {
      return null;
    }
    final MarkupSnapshot next = _redoStack.removeLast();
    _undoStack.add(current);
    if (_undoStack.length > MarkupHistoryConstants.maxSteps) {
      _undoStack.removeAt(0);
    }
    return next;
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
