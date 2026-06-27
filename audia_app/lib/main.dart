import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'app_router.dart';
import 'config.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(
        iosClientId: AppConfig.googleIosClientId,
        serverClientId: AppConfig.googleWebClientId,
      ),
      child: const AudiaApp(),
    ),
  );
}

class AudiaApp extends StatelessWidget {
  const AudiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Audia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}

