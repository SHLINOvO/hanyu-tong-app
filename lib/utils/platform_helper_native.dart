// Platform-specific helper for native platforms (Windows, Linux, macOS, iOS, Android)
// dart:io Platform is only available on non-web platforms

import 'dart:io' show Platform;

/// Returns true if running on a desktop platform (Windows, Linux, macOS)
bool get isDesktop {
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}
