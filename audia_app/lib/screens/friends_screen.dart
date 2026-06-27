import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amigos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(
          8,
          (i) => Card(
            color: AppTheme.cardColor,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withAlpha(60),
                child: const Icon(Icons.person, color: Colors.white70),
              ),
              title: Text('Amigo ${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              subtitle: const Text('Ãšltimo mensaje...', style: TextStyle(color: Colors.white38, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () {},
            ),
          ),
        ),
      ),
    );
  }
}

