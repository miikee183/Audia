import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../l10n/app_strings.dart';
import '../app_router.dart';
import '../theme/app_theme.dart';

const _maxBioLength = 300;

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  int _currentStep = 0;
  final _pageController = PageController();
  bool _isLoading = false;
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();

  DateTime _fechaNacimiento = DateTime(2000, 1, 1);
  String? _sexo;
  String _nombreUsuario = '';
  String _biografia = '';
  File? _fotoPerfil;
  String? _idioma;

  final List<String> _sexoOptions = ['Hombre', 'Mujer', 'Otro'];

  static const Map<String, String> _idiomas = {
    'English': 'English',
    'Español': 'Español',
    'Français': 'Français',
    'Português': 'Português',
    'Deutsch': 'Deutsch',
    'Italiano': 'Italiano',
    'Русский': 'Русский',
    'العربية': 'العربية',
    '中文': '中文',
    '한국어': '한국어',
    '日本語': '日本語',
  };

  List<String> _stepTitles() => [
    AppStrings.birthDate,
    AppStrings.genderSelect,
    AppStrings.chooseUsername,
    AppStrings.bio,
    AppStrings.profilePhoto,
    AppStrings.language,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isCurrentStepValid() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _sexo != null;
      case 2:
        return _nombreUsuario.trim().isNotEmpty;
      case 3:
        return _biografia.length <= _maxBioLength;
      case 4:
        return true;
      case 5:
        return _idioma != null;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (!_isCurrentStepValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.completeStepPrompt)),
      );
      return;
    }
    FocusScope.of(context).unfocus();
      if (_currentStep < _stepTitles().length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitForm() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String? fotoBase64;
      if (_fotoPerfil != null) {
        final bytes = await _fotoPerfil!.readAsBytes();
        fotoBase64 = base64Encode(bytes);
      }

      final result = await _api.post('/perfil/', {
        'cuenta_id': user.userId,
        'fecha_nacimiento': _fechaNacimiento.toIso8601String().split('T')[0],
        'sexo': _sexo,
        'nombre_usuario': _nombreUsuario,
        'biografia': _biografia,
        'foto_perfil': fotoBase64,
        'idioma': _idioma,
      });

      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarded', true);
      if (!mounted) return;
      context.read<AuthProvider>().markPerfilCreado(result['id'] as String?);
      context.go(AppRouter.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _stepQuestion(int step) {
    return _stepTitles()[step];
  }

  void _showDatePicker() {
    final now = DateTime.now();
    final minDate = DateTime(now.year - 100, 1, 1);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      builder: (_) => SizedBox(
        height: 280,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppStrings.cancel, style: const TextStyle(color: Colors.white60)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: Text(AppStrings.done, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  brightness: Brightness.dark,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  initialDateTime: _fechaNacimiento,
                  minimumDate: minDate,
                  maximumDate: now,
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (v) => _fechaNacimiento = v,
                  backgroundColor: AppTheme.surfaceColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.stepOf.replaceFirst('{current}', '${_currentStep + 1}').replaceFirst('{total}', '${_stepTitles().length}'),
                          style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_currentStep + 1) / _stepTitles().length,
                            backgroundColor: Colors.white.withAlpha(30),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      _stepQuestion(_currentStep),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) => setState(() => _currentStep = i),
                      children: [
                        _DateStep(
                          date: _fechaNacimiento,
                          formatted: _formatDate(_fechaNacimiento),
                          onTap: _showDatePicker,
                        ),
                        _SexStep(value: _sexo, options: _sexoOptions, onChanged: (v) => setState(() => _sexo = v)),
                        _UsernameStep(value: _nombreUsuario, onChanged: (v) => setState(() => _nombreUsuario = v)),
                        _BioStep(value: _biografia, maxLength: _maxBioLength, onChanged: (v) => setState(() => _biografia = v)),
                        _PhotoStep(
                          file: _fotoPerfil,
                          onPickGallery: () async {
                            final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                            if (picked != null) {
                              final cropped = await ImageCropper().cropImage(
                                sourcePath: picked.path,
                                uiSettings: [
                                  AndroidUiSettings(
                                    toolbarTitle: AppStrings.adjustPhoto,
                                    toolbarColor: const Color(0xFF1A1A1A),
                                    toolbarWidgetColor: Colors.white,
                                    backgroundColor: Colors.black,
                                    statusBarColor: Colors.black,
                                    activeControlsWidgetColor: const Color(0xFF6C63FF),
                                    cropStyle: CropStyle.circle,
                                    lockAspectRatio: true,
                                    aspectRatioPresets: [CropAspectRatioPreset.square],
                                    hideBottomControls: true,
                                  ),
                                ],
                              );
                              if (cropped != null) setState(() => _fotoPerfil = File(cropped.path));
                            }
                          },
                          onPickCamera: () async {
                            final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                            if (picked != null) {
                              final cropped = await ImageCropper().cropImage(
                                sourcePath: picked.path,
                                uiSettings: [
                                  AndroidUiSettings(
                                    toolbarTitle: AppStrings.adjustPhoto,
                                    toolbarColor: const Color(0xFF1A1A1A),
                                    toolbarWidgetColor: Colors.white,
                                    backgroundColor: Colors.black,
                                    statusBarColor: Colors.black,
                                    activeControlsWidgetColor: const Color(0xFF6C63FF),
                                    cropStyle: CropStyle.circle,
                                    lockAspectRatio: true,
                                    aspectRatioPresets: [CropAspectRatioPreset.square],
                                    hideBottomControls: true,
                                  ),
                                ],
                              );
                              if (cropped != null) setState(() => _fotoPerfil = File(cropped.path));
                            }
                          },
                          onRemove: () => setState(() => _fotoPerfil = null),
                        ),
                        _LanguageStep(value: _idioma, idiomas: _idiomas, onChanged: (v) => setState(() => _idioma = v)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white.withAlpha(60)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(AppStrings.back, style: const TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isCurrentStepValid() ? _nextStep : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              disabledBackgroundColor: Colors.white.withAlpha(20),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              _currentStep == _stepTitles().length - 1 ? AppStrings.done : AppStrings.next,
                              style: TextStyle(
                                fontSize: 16,
                                color: _isCurrentStepValid() ? Colors.black : Colors.white38,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DateStep extends StatelessWidget {
  final DateTime date;
  final String formatted;
  final VoidCallback onTap;

  const _DateStep({required this.date, required this.formatted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryColor.withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 28),
                  const SizedBox(width: 16),
                  Text(
                    formatted,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Toca para cambiar fecha',
            style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 14),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _SexStep extends StatelessWidget {
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _SexStep({required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: options.map((option) {
          final isSelected = value == option;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => onChanged(option),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.white.withAlpha(60),
                    width: isSelected ? 2 : 1,
                  ),
                  backgroundColor: isSelected ? const Color(0xFF6C63FF).withAlpha(30) : null,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 18,
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _UsernameStep extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _UsernameStep({required this.value, required this.onChanged});

  @override
  State<_UsernameStep> createState() => _UsernameStepState();
}

class _UsernameStepState extends State<_UsernameStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(() => widget.onChanged(_controller.text));
  }

  @override
  void didUpdateWidget(_UsernameStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Expanded(child: SizedBox()),
          TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, color: Colors.white),
            decoration: InputDecoration(
              hintText: AppStrings.username.toLowerCase(),
              hintStyle: TextStyle(color: Colors.white.withAlpha(80), fontSize: 28),
              border: InputBorder.none,
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class _BioStep extends StatefulWidget {
  final String value;
  final int maxLength;
  final ValueChanged<String> onChanged;

  const _BioStep({required this.value, required this.maxLength, required this.onChanged});

  @override
  State<_BioStep> createState() => _BioStepState();
}

class _BioStepState extends State<_BioStep> {
  late final TextEditingController _controller;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _charCount = widget.value.length;
    _controller.addListener(() {
      widget.onChanged(_controller.text);
      setState(() => _charCount = _controller.text.length);
    });
  }

  @override
  void didUpdateWidget(_BioStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
      _charCount = widget.value.length;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overLimit = _charCount > widget.maxLength;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          TextField(
            controller: _controller,
            maxLines: 4,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, color: Colors.white),
            decoration: InputDecoration(
              hintText: AppStrings.bio,
              hintStyle: TextStyle(color: Colors.white.withAlpha(80), fontSize: 20),
              border: InputBorder.none,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$_charCount/${widget.maxLength}',
                style: TextStyle(
                  fontSize: 13,
                  color: overLimit ? Colors.redAccent : Colors.white38,
                ),
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _PhotoStep extends StatelessWidget {
  final File? file;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onRemove;

  const _PhotoStep({
    required this.file,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            GestureDetector(
              onTap: onPickGallery,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(40),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryColor.withAlpha(120), width: 2),
                  image: file != null
                      ? DecorationImage(image: FileImage(file!), fit: BoxFit.cover)
                      : null,
                ),
                child: file == null
                    ? const Center(
                        child: Icon(Icons.add, size: 64, color: Colors.black54),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            if (file != null)
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                label: Text(AppStrings.deletePhoto, style: const TextStyle(color: Colors.redAccent)),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onPickCamera,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(AppStrings.takePhoto),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withAlpha(60)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _LanguageStep extends StatelessWidget {
  final String? value;
  final Map<String, String> idiomas;
  final ValueChanged<String?> onChanged;

  const _LanguageStep({required this.value, required this.idiomas, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppTheme.surfaceColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          AppStrings.chooseLanguage,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const Divider(height: 1, color: Colors.white12),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: idiomas.length,
                          itemBuilder: (_, i) {
                            final entry = idiomas.entries.elementAt(i);
                            final isSelected = value == entry.value;
                            return ListTile(
                              title: Text(
                                entry.key,
                                style: TextStyle(
                                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: AppTheme.primaryColor)
                                  : null,
                              onTap: () {
                                onChanged(entry.value);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: value != null ? AppTheme.primaryColor : Colors.white.withAlpha(60),
                  width: value != null ? 2 : 1,
                ),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                value ?? AppStrings.chooseLanguage,
                style: TextStyle(
                  fontSize: 18,
                  color: value != null ? AppTheme.primaryColor : Colors.white60,
                  fontWeight: value != null ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
