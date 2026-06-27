import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  final double spacing;

  const AppHeader({
    super.key,
    this.logoSize = 120,
    this.fontSize = 42,
    this.spacing = 24,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return Column(
      children: [
        Image.asset(
          'assets/images/Logo.png',
          width: logoSize,
          height: logoSize,
          cacheWidth: (logoSize * dpr).round(),
          cacheHeight: (logoSize * dpr).round(),
        ),
        SizedBox(height: spacing),
        Text(
          'Audia',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

