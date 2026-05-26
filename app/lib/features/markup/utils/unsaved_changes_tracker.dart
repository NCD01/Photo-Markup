class UnsavedChangesTracker {
  bool _hasUnsavedChanges = false;

  bool get hasUnsavedChanges => _hasUnsavedChanges;

  void markDirty() {
    _hasUnsavedChanges = true;
  }

  void markSaved() {
    _hasUnsavedChanges = false;
  }
}
