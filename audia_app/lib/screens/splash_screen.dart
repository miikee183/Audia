import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      context.go(AppRouter.phone);
    });
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
                  // Guard against cacheWidth=0 when screen is not yet measured
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
