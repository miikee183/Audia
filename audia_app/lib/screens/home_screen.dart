import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audia Home')),
      body: const Center(
        child: Text('¡Bienvenido a Audia! Tu cuenta está configurada.', style: TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center,),
      ),
    );
  }
}

