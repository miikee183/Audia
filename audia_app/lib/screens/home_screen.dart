import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.appName)),
      body: Center(
        child: Text(AppStrings.welcomeMessage, style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
      ),
    );
  }
}

