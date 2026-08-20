/// Whether there is markup on the photo that has not been written anywhere.
///
/// [onChanged] fires on every transition, which is how the autosave knows the
/// work moved without every call site having to remember to say so. One place
/// to hook means a new markup type cannot forget to be recoverable.
class UnsavedChangesTracker {
  UnsavedChangesTracker({this.onChanged});

  final void Function(bool hasUnsavedChanges)? onChanged;

  bool _hasUnsavedChanges = false;

  bool get hasUnsavedChanges => _hasUnsavedChanges;

  void markDirty() => _set(true);

  void markSaved() => _set(false);

  void _set(bool value) {
    final bool changed = _hasUnsavedChanges != value;
    _hasUnsavedChanges = value;
    if (changed) {
      onChanged?.call(value);
    }
  }
}
