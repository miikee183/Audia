import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bandeja de entrada', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NotificationItem(
            icon: Icons.favorite,
            color: Colors.red,
            text: 'A usuario_123 le gustó tu audio',
            time: 'hace 2m',
          ),
          _NotificationItem(
            icon: Icons.chat,
            color: AppTheme.primaryColor,
            text: 'usuario_456 comentó: "Muy bueno!"',
            time: 'hace 15m',
          ),
          _NotificationItem(
            icon: Icons.person_add,
            color: Colors.green,
            text: 'usuario_789 empezó a seguirte',
            time: 'hace 1h',
          ),
          _NotificationItem(
            icon: Icons.favorite,
            color: Colors.red,
            text: 'A usuario_321 le gustó tu audio',
            time: 'hace 3h',
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String time;

  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(40),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing: Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        onTap: () {},
      ),
    );
  }
}

