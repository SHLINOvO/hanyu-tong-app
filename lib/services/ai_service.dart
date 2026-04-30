// Conditional export for platform-specific implementation
// Native (Android/iOS/Desktop): uses dart:io for file operations
// Web: uses stub implementation
export 'ai_service_native.dart' if (dart.library.html) 'ai_service_web.dart';
