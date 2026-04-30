// Conditional export for platform-specific implementation
export 'file_helper_native.dart' if (dart.library.html) 'file_helper_web.dart';
