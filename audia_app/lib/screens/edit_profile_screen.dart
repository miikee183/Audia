import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audia/theme/app_theme.dart';
import 'package:audia/l10n/app_strings.dart';
import 'package:audia/services/api_service.dart';
import 'package:audia/widgets/profile_image.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentUsername;
  final String? currentBio;
  final String? currentPhoto;

  const EditProfileScreen({
    super.key,
    required this.currentUsername,
    this.currentBio,
    this.currentPhoto,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  File? _newPhotoFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
    _bioController = TextEditingController(text: widget.currentBio ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _api.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final cropped = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (cropped != null) {
      setState(() => _newPhotoFile = File(cropped.path));
    }
  }

  String? _encodePhoto() {
    if (_newPhotoFile == null) return null;
    final bytes = _newPhotoFile!.readAsBytesSync();
    return base64Encode(bytes);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'nombre_usuario': _usernameController.text.trim(),
        'biografia': _bioController.text.trim(),
      };
      final photoBase64 = _encodePhoto();
      if (photoBase64 != null) body['foto_perfil'] = photoBase64;

      await _api.put('/perfil/me', body);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.error}: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(AppStrings.editProfile, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  ProfileImage(
                    imageData: _newPhotoFile != null
                        ? base64Encode(_newPhotoFile!.readAsBytesSync())
                        : widget.currentPhoto,
                    radius: 56,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: AppStrings.username,
            ),
            style: const TextStyle(color: Colors.white),
            maxLength: 30,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController,
            decoration: InputDecoration(
              labelText: AppStrings.bio,
              alignLabelWithHint: true,
            ),
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            maxLength: 150,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(AppStrings.saveChanges),
            ),
          ),
        ],
      ),
    );
  }
}
