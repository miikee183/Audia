import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_router.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('onboarded') == true) {
      await context.read<AuthProvider>().restoreSession();
      if (!mounted) return;
      context.go(AppRouter.home);
      return;
    }
    if (!mounted) return;
    context.go(AppRouter.phone);
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = MediaQuery.of(context).size.width * 0.35;
    final dpr = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, opacity, _) {
              return Opacity(
                opacity: opacity,
                child: Image.asset(
                  'assets/images/Logo.png',
                  width: logoSize,
                  height: logoSize,
                  cacheWidth: logoSize > 0 ? (logoSize * dpr).round() : null,
                  cacheHeight: logoSize > 0 ? (logoSize * dpr).round() : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}