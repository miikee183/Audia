import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../app_router.dart';

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

  int? _anoNacimiento;
  String? _sexo;
  String _nombreUsuario = '';
  String _gustos = '';
  File? _fotoPerfil;
  String _idioma = 'Español';

  final List<String> _sexoOptions = ['Hombre', 'Mujer', 'Otro'];
  final List<String> _idiomaOptions = ['Español', 'Inglés', 'Francés', 'Portugués'];

  final List<String> _stepTitles = [
    'Año de nacimiento',
    'Sexo',
    'Nombre de Usuario',
    'Gustos',
    'Foto de perfil',
    'Idioma',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isCurrentStepValid() {
    switch (_currentStep) {
      case 0:
        return _anoNacimiento != null;
      case 1:
        return _sexo != null;
      case 2:
        return _nombreUsuario.trim().isNotEmpty;
      case 3:
        return _gustos.trim().isNotEmpty;
      case 4:
        return true;
      case 5:
        return _idioma.isNotEmpty;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (!_isCurrentStepValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa este paso')),
      );
      return;
    }
    if (_currentStep < _stepTitles.length - 1) {
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

      await _api.post('/personalizacion/', {
        'cuenta_id': user.userId,
        'ano_nacimiento': _anoNacimiento,
        'sexo': _sexo,
        'nombre_usuario': _nombreUsuario,
        'gustos': _gustos,
        'foto_perfil': fotoBase64,
        'idioma': _idioma,
      });

      if (!mounted) return;
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
    const questions = [
      '¿En qué año naciste?',
      '¿Cuál es tu sexo?',
      'Elige un nombre de usuario',
      '¿Qué te gusta?',
      'Añade una foto de perfil',
      '¿Qué idioma prefieres?',
    ];
    return questions[step];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
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
                          'Paso ${_currentStep + 1} de ${_stepTitles.length}',
                          style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_currentStep + 1) / _stepTitles.length,
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
                        _BirthYearStep(value: _anoNacimiento, onChanged: (v) => _anoNacimiento = v),
                        _SexStep(value: _sexo, options: _sexoOptions, onChanged: (v) => _sexo = v),
                        _UsernameStep(value: _nombreUsuario, onChanged: (v) => _nombreUsuario = v),
                        _InterestsStep(value: _gustos, onChanged: (v) => _gustos = v),
                        _PhotoStep(
                          file: _fotoPerfil,
                          onPickGallery: () async {
                            final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                            if (picked != null) setState(() => _fotoPerfil = File(picked.path));
                          },
                          onPickCamera: () async {
                            final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                            if (picked != null) setState(() => _fotoPerfil = File(picked.path));
                          },
                          onRemove: () => setState(() => _fotoPerfil = null),
                        ),
                        _LanguageStep(
                          value: _idioma,
                          options: _idiomaOptions,
                          onChanged: (v) => _idioma = v,
                        ),
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
                              child: const Text('Atrás', style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              _currentStep == _stepTitles.length - 1 ? 'Listo' : 'Siguiente',
                              style: const TextStyle(fontSize: 16, color: Colors.white),
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

class _BirthYearStep extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const _BirthYearStep({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ej. 1995',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(80), fontSize: 28),
                  border: InputBorder.none,
                ),
                onChanged: (v) => onChanged(int.tryParse(v)),
              ),
            ),
          ),
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

class _UsernameStep extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _UsernameStep({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: TextField(
                controller: TextEditingController(text: value),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, color: Colors.white),
                decoration: InputDecoration(
                  hintText: '@usuario',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(80), fontSize: 28),
                  border: InputBorder.none,
                ),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestsStep extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _InterestsStep({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: TextField(
                maxLines: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Música, tecnología, viajes...',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(80), fontSize: 20),
                  border: InputBorder.none,
                ),
                onChanged: onChanged,
              ),
            ),
          ),
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
      child: Column(
        children: [
          const Spacer(flex: 2),
          if (file != null)
            CircleAvatar(
              radius: 80,
              backgroundImage: FileImage(file!),
            )
          else
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withAlpha(20),
              child: Icon(Icons.person, size: 64, color: Colors.white.withAlpha(100)),
            ),
          const SizedBox(height: 24),
          if (file != null)
            TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              label: const Text('Eliminar foto', style: TextStyle(color: Colors.redAccent)),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPickGallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Elegir de galería'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPickCamera,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Tomar foto'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withAlpha(60)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _LanguageStep extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _LanguageStep({required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
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
