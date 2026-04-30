// Conditional export for platform-specific implementation
export 'platform_helper_native.dart' if (dart.library.html) 'platform_helper_web.dart';
