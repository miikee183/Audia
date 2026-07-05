import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'app_router.dart';
import 'l10n/app_strings.dart';
import 'providers/auth_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const AudiaApp(),
    ),
  );
}

class AudiaApp extends StatefulWidget {
  const AudiaApp({super.key});

  @override
  State<AudiaApp> createState() => _AudiaAppState();
}

class _AudiaAppState extends State<AudiaApp> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final locale = context.read<LocaleProvider>();
    final theme = context.read<ThemeProvider>();
    await locale.loadLocale();
    await theme.loadTheme();
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );

    final themeMode = context.watch<ThemeProvider>().themeMode;

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}

