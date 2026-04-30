// Conditional export for window_manager
// Only available on desktop platforms
export 'window_manager_native.dart' if (dart.library.html) 'window_manager_stub.dart';
