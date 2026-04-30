// File helper for native platforms (Windows, Linux, macOS, iOS, Android)
// dart:io File is only available on non-web platforms

import 'dart:io' show File;

/// Delete a file if it exists
Future<void> deleteFileIfExists(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (_) {
    // Ignore errors (file might not exist or permission denied)
  }
}
