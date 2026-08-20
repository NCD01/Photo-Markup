import 'dart:io';

/// Removes a throwaway directory a test created, without letting the cleanup
/// itself fail the test.
///
/// On Windows a file that was written moments ago can still be held by the
/// process for a short while, and `deleteSync` throws errno 32 rather than
/// waiting. The assertions have all run by the time teardown happens, so a
/// scratch folder that outlives the run is untidy, not wrong. Retry a few
/// times, then leave it to the operating system's temp cleanup.
void deleteTempDirBestEffort(Directory dir) {
  for (int attempt = 0; attempt < 5; attempt++) {
    try {
      if (!dir.existsSync()) {
        return;
      }
      dir.deleteSync(recursive: true);
      return;
    } on FileSystemException {
      sleep(const Duration(milliseconds: 50));
    }
  }
}
