import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import '../services/audio_service.dart';
import '../providers/audio_provider.dart';
import 'package:audia/widgets/profile_image.dart';

class PublishAudioScreen extends StatefulWidget {
  final String filePath;
  final double duration;

  const PublishAudioScreen({
    super.key,
    required this.filePath,
    required this.duration,
  });

  @override
  State<PublishAudioScreen> createState() => _PublishAudioScreenState();
}

class _PublishAudioScreenState extends State<PublishAudioScreen> {
  String? _selectedColor;
  String? _selectedImagePath;
  bool _isUploading = false;

  final List<String> _colors = [
    '#1B3D1B', '#2D4D2D', '#4A4A1A', '#4D2E1A',
    '#4D1A1A', '#1A1A4D', '#3D1B3D', '#1B3D3D',
    '#6C3483', '#2E86C1', '#1F618D', '#117864',
    '#B03A2E', '#A04000', '#7D6608', '#1B2631',
  ];

  Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  String? get _backgroundValue =>
      _selectedImagePath ?? _selectedColor;

  String _formatDuration(double seconds) {
    final m = seconds ~/ 60;
    final s = seconds.round() % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImagePath = picked.path;
        _selectedColor = null;
      });
    }
  }

  Future<void> _publish() async {
    if (!File(widget.filePath).existsSync()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.audioNotFound), backgroundColor: Colors.red),
        );
      }
      return;
    }
    setState(() => _isUploading = true);
    try {
      final s = AudioService();
      String? fondo;
      String? fondoPath;
      if (_selectedColor != null) {
        fondo = _selectedColor;
      } else if (_selectedImagePath != null) {
        fondoPath = _selectedImagePath;
      }
      await s.uploadAudio(
        widget.filePath,
        widget.duration,
        fotoFondo: fondo,
        fondoImagePath: fondoPath,
      );
      s.dispose();
      if (mounted) {
        context.read<AudioProvider>().loadAudios();
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.audioPublished)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red.shade800),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.publishAudio, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.thisIsHowItLooks,
              style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildPreview(),
            const SizedBox(height: 28),
            Text(
              AppStrings.audioBackground,
              style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildColorGrid(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  _selectedImagePath != null
                      ? AppStrings.changeImage
                      : AppStrings.chooseImage,
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withAlpha(60)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            if (_selectedImagePath != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_selectedImagePath!),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _publish,
                icon: _isUploading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Icon(Icons.cloud_upload, size: 20),
                label: Text(_isUploading ? AppStrings.publishing : AppStrings.publishAudio),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    Color? bgColor;
    if (_selectedColor != null) {
      final hex = _selectedColor!.replaceFirst('#', '');
      bgColor = Color(int.parse('FF$hex', radix: 16));
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: bgColor ?? Colors.black,
        image: _selectedImagePath != null
            ? DecorationImage(
                image: FileImage(File(_selectedImagePath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(180),
                    Colors.black.withAlpha(200),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(180),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.music_note, size: 14, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ProfileImage(imageData: null, radius: 27),
                  const SizedBox(height: 6),
                  Text(
                    _formatDuration(widget.duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.yourUser,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite_border, size: 20, color: Colors.white),
                            const SizedBox(width: 4),
                            const Text('0',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chat_bubble, size: 20, color: Colors.white),
                            const SizedBox(width: 4),
                            const Text('0',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _colors.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedColor = color;
            _selectedImagePath = null;
          }),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _parseColor(color),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : Border.all(color: Colors.white24),
              boxShadow: isSelected
                  ? [BoxShadow(color: _parseColor(color).withAlpha(120), blurRadius: 12, spreadRadius: 2)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : null,
          ),
        );
      }).toList(),
    );
  }
}


