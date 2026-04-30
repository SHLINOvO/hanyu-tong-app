// File helper for Web platform
// dart:io File is not available on Web

/// Delete a file if it exists (Web stub - does nothing on Web)
Future<void> deleteFileIfExists(String path) async {
  // On Web, files don't exist as paths, so nothing to do
  // The path might be a blob URL which is handled by the browser
}
