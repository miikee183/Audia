import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.inboxFull, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NotificationItem(
            icon: Icons.favorite,
            color: Colors.red,
            text: AppStrings.notificationLikedAudio.replaceFirst('{user}', 'usuario_123'),
            time: AppStrings.timeAgoMinFormat.replaceFirst('{n}', '2'),
          ),
          _NotificationItem(
            icon: Icons.chat,
            color: AppTheme.primaryColor,
            text: AppStrings.notificationCommented.replaceFirst('{user}', 'usuario_456').replaceFirst('{comment}', '"Muy bueno!"'),
            time: AppStrings.timeAgoMinFormat.replaceFirst('{n}', '15'),
          ),
          _NotificationItem(
            icon: Icons.person_add,
            color: Colors.green,
            text: AppStrings.notificationStartedFollowing.replaceFirst('{user}', 'usuario_789'),
            time: AppStrings.timeAgoHourFormat.replaceFirst('{n}', '1'),
          ),
          _NotificationItem(
            icon: Icons.favorite,
            color: Colors.red,
            text: AppStrings.notificationLikedAudio.replaceFirst('{user}', 'usuario_321'),
            time: AppStrings.timeAgoHourFormat.replaceFirst('{n}', '3'),
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

