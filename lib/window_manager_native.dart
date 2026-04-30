import 'dart:ui';

import 'package:window_manager/window_manager.dart';

Future<void> initWindowManager() async {
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(390, 844),
    minimumSize: Size(360, 640),
    center: true,
    title: '汉语通',
    titleBarStyle: TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
