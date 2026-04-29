import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'app_state.dart';
import 'router.dart';
import 'config/app_languages.dart';
import 'l10n/app_localizations.dart';

// 判断是否为桌面平台（Windows/Linux/macOS，不包括 Android/Web）
final bool _isDesktop = (defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.linux ||
    defaultTargetPlatform == TargetPlatform.macOS);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Windows 桌面：设置窗口为手机比例 390 × 844（仅桌面平台调用）──
  if (_isDesktop) {
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
  // ─────────────────────────────────────────────────

  final appState = AppState();
  await appState.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => appState,
      child: const HanyuTongApp(),
    ),
  );
}

class HanyuTongApp extends StatefulWidget {
  const HanyuTongApp({super.key});

  @override
  State<HanyuTongApp> createState() => _HanyuTongAppState();
}

class _HanyuTongAppState extends State<HanyuTongApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(context);
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return MaterialApp.router(
          title: '汉语通',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4285F4)),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          routerConfig: router,
          // 多语言支持配置
          locale: Locale(appState.language),
          supportedLocales: supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            // 如果用户选择的语言在支持列表中，使用用户选择的语言
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            // 否则使用英语作为默认语言
            return const Locale('en');
          },
        );
      },
    );
  }
}
