import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

final Map<String, CachedNetworkImageProvider> _providerCache = {};

class ProfileImage extends StatelessWidget {
  final String? imageData;
  final double radius;

  const ProfileImage({super.key, required this.imageData, this.radius = 48});

  Widget _fallback() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white12,
      child: Icon(Icons.person, size: radius, color: Colors.white70),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = imageData;
    if (data == null || data.isEmpty) return _fallback();

    if (data.startsWith('http://') || data.startsWith('https://')) {
      final provider =
          _providerCache.putIfAbsent(data, () => CachedNetworkImageProvider(data));
      return CircleAvatar(
        radius: radius,
        backgroundImage: provider,
      );
    }

    try {
      final bytes = base64Decode(data);
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(Uint8List.fromList(bytes)),
      );
    } catch (_) {
      return _fallback();
    }
  }
}

ImageProvider? profileImageProvider(String? imageData) {
  if (imageData == null || imageData.isEmpty) return null;
  if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
    return _providerCache.putIfAbsent(
        imageData, () => CachedNetworkImageProvider(imageData));
  }
  try {
    final bytes = base64Decode(imageData);
    return MemoryImage(Uint8List.fromList(bytes));
  } catch (_) {
    return null;
  }
}