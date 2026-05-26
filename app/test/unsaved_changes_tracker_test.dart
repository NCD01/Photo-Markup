import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/utils/unsaved_changes_tracker.dart';

void main() {
  test('tracks unsaved toggle from dirty to saved', () {
    final UnsavedChangesTracker tracker = UnsavedChangesTracker();
    expect(tracker.hasUnsavedChanges, isFalse);

    tracker.markDirty();
    expect(tracker.hasUnsavedChanges, isTrue);

    tracker.markSaved();
    expect(tracker.hasUnsavedChanges, isFalse);
  });
}
