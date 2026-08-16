import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:netshare/ui/common_view/confirm_dialog.dart';
import 'package:provider/provider.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/data/preload_data.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/file_upload.dart';
import 'package:netshare/plugin_management/plugins.dart';
import 'package:netshare/provider/app_provider.dart';
import 'package:netshare/provider/chat_provider.dart';
import 'package:netshare/provider/connection_provider.dart';
import 'package:netshare/provider/file_provider.dart';
import 'package:netshare/ui/send/send_text_widget.dart';
import 'package:netshare/ui/client/scan_qr_widget.dart';
import 'package:netshare/ui/client/client_widget.dart';
import 'package:netshare/ui/send/send_file_widget.dart';
import 'package:netshare/ui/server/server_widget.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:netshare/config/constants.dart';
import 'package:netshare/ui/send/uploading_widget.dart';
import 'package:netshare/manager/system_tray_manager.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPlugins();
  setupDI();
  await PreloadData.inject();

  if (UtilityFunctions.isDesktop) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setPreventClose(true);
    });
    await SystemTrayManager().init();
  }

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  final GoRouter _router = GoRouter(
    navigatorKey: _navigatorKey,
    errorBuilder: (BuildContext context, GoRouterState state) =>
        ErrorWidget(state.error!),
    routes: <GoRoute>[
      GoRoute(
        path: mRootPath,
        redirect: (context, state) {
          if (UtilityFunctions.isMobile) {
            return '/$mClientPath';
          } else {
            return '/$mServerPath';
          }
        },
      ),
      GoRoute(
        name: mServerPath,
        path: '/$mServerPath',
        builder: (context, state) => const ServerWidget(),
      ),
      GoRoute(
        name: mClientPath,
        path: '/$mClientPath',
        builder: (context, state) => const ClientWidget(),
        routes: [
          GoRoute(
            name: mSendFilesPath,
            path: mSendFilesPath,
            builder: (BuildContext context, GoRouterState state) {
              final fileUpload = state.extra as FileUpload?;
              return SendFilesWidget(
                initialFiles: fileUpload != null ? [fileUpload] : null,
              );
            },
            routes: [
              GoRoute(
                name: mUploadingPath,
                path: mUploadingPath,
                builder: (context, state) => const UploadingWidget(),
              )
            ],
          ),
          GoRoute(
            name: mSendTextPath,
            path: mSendTextPath,
            builder: (BuildContext context, GoRouterState state) =>
                const SendTextWidget(),
          ),
          GoRoute(
            name: mScanningPath,
            path: mScanningPath,
            builder: (BuildContext context, GoRouterState state) =>
                const ScanQRWidget(),
          ),
        ],
      ),
    ],
  );
  bool _isKeyboardListenerEnabled = true;

  @override
  void initState() {
    super.initState();
    if (UtilityFunctions.isDesktop) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (UtilityFunctions.isDesktop) {
      windowManager.removeListener(this);
      SystemTrayManager().dispose();
    }
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // Hide window instead of closing it.
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FileProvider()),
        ChangeNotifierProvider(create: (context) => ConnectionProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => AppProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'NetShare',
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: const AppBarTheme(color: backgroundColor),
          colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor, background: backgroundColor),
          iconButtonTheme: const IconButtonThemeData(
            style: ButtonStyle(
              iconColor: WidgetStatePropertyAll<Color>(textIconButtonColor),
            ),
          ),
        ),
        routerConfig: _router,
        builder: (context, child) {
          // Handle keyboard listener here
          RawKeyboard.instance
              .addListener((RawKeyEvent value) => _handleKeyEvent(value));
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }

  void _handleKeyEvent(RawKeyEvent value) async {
    if (!_isKeyboardListenerEnabled) return;

    // If user pressed Command/Control + W keys, quit the app
    if (value.isMetaPressed && value.logicalKey == LogicalKeyboardKey.keyW ||
        value.isControlPressed && value.logicalKey == LogicalKeyboardKey.keyW) {
      if (_navigatorKey.currentContext == null) return;

      // show confirm dialog
      _showQuitAppConfirmationDialog(_navigatorKey.currentContext!,
          (confirmCallback) async {
        if (confirmCallback) {
          // SystemNavigator.pop(); // Quit the app
          await windowManager.hide();
        }
        // listen keyboard again
        _isKeyboardListenerEnabled = true;
      });
    }
  }

  void _showQuitAppConfirmationDialog(
      BuildContext context, Function(bool)? confirmCallback) {
    // Disable the keyboard listener.
    _isKeyboardListenerEnabled = false;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return ConfirmDialog(
          dialogWidth: MediaQuery.of(dialogContext).size.width / 2,
          header: Text(
            'Quit App',
            style: Theme.of(dialogContext).textTheme.headlineMedium?.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          body: const Text(
            'Are you sure you want to quit the app?',
            textAlign: TextAlign.center,
          ),
          cancelButtonTitle: 'No',
          okButtonTitle: 'Yes, I\'m sure',
          onCancel: () => confirmCallback?.call(false),
          onConfirm: () => confirmCallback?.call(true),
        );
      },
    );
  }
}
