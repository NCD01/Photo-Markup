class LoadErrorVisibilityPolicy {
  const LoadErrorVisibilityPolicy._();

  static bool shouldShowSnackBar({required String? imagePath}) {
    return imagePath != null && imagePath.trim().isNotEmpty;
  }
}
