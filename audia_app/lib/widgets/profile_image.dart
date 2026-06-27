import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final String? imageData;
  final double radius;

  const ProfileImage({super.key, required this.imageData, this.radius = 48});

  @override
  Widget build(BuildContext context) {
    final data = imageData;
    if (data == null || data.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white12,
        child: Icon(Icons.person, size: radius, color: Colors.white70),
      );
    }

    if (data.startsWith('http://') || data.startsWith('https://')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(data),
      );
    }

    try {
      final bytes = base64Decode(data);
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(Uint8List.fromList(bytes)),
      );
    } catch (_) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white12,
        child: Icon(Icons.person, size: radius, color: Colors.white70),
      );
    }
  }
}

ImageProvider? profileImageProvider(String? imageData) {
  if (imageData == null || imageData.isEmpty) return null;
  if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
    return NetworkImage(imageData);
  }
  try {
    final bytes = base64Decode(imageData);
    return MemoryImage(Uint8List.fromList(bytes));
  } catch (_) {
    return null;
  }
}
