import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/date_of_birth_picker.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Set<String> _selectedLanguages = {};
  bool _isLoading = false;
  // ignore: unused_field
  DateTime _birthDate = DateTime(2000, 1, 1);
  String? _selectedGender;

  static const _languages = [
    'Español', 'Inglés', 'Portugués', 'Francés',
    'Alemán', 'Italiano', 'Catalán', 'Euskera',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _finish() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un idioma')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  const SizedBox(height: 32),
                  _UsernameField(controller: _usernameController),
                  const SizedBox(height: 24),
                  _GenderSection(
                    selected: _selectedGender,
                    onSelected: (gender) => setState(() => _selectedGender = gender),
                  ),
                  const SizedBox(height: 24),
                  _LanguagesSection(
                    languages: _languages,
                    selected: _selectedLanguages,
                    onToggle: (lang) {
                      setState(() {
                        if (_selectedLanguages.contains(lang)) {
                          _selectedLanguages.remove(lang);
                        } else {
                          _selectedLanguages.add(lang);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  DateOfBirthPicker(
                    onChanged: (date) => _birthDate = date,
                  ),
                  const SizedBox(height: 24),
                  _BioField(controller: _bioController),
                  const SizedBox(height: 32),
                  _FinishButton(
                    isLoading: _isLoading,
                    onPressed: _finish,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personaliza tu perfil',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Cuéntanos sobre ti para empezar',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}

class _UsernameField extends StatelessWidget {
  final TextEditingController controller;

  const _UsernameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Elige un nombre de usuario';
        if (value.length < 3) return 'Mínimo 3 caracteres';
        return null;
      },
      decoration: const InputDecoration(
        labelText: 'Nombre de usuario',
        prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
      ),
    );
  }
}

class _GenderSection extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _GenderSection({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sexo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withAlpha(200),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['Hombre', 'Mujer', 'Otro'].map((gender) {
            final sel = selected == gender;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: gender == 'Hombre' ? 0 : 8,
                  right: gender == 'Otro' ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () => onSelected(gender),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.primaryColor : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sel ? AppTheme.primaryColor : AppTheme.primaryColor.withAlpha(60),
                      ),
                    ),
                    child: Text(
                      gender,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: sel ? Colors.black : Colors.white70,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _LanguagesSection extends StatelessWidget {
  final List<String> languages;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _LanguagesSection({
    required this.languages,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Idiomas que hablas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withAlpha(200),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: languages.map((lang) {
            final sel = selected.contains(lang);
            return GestureDetector(
              onTap: () => onToggle(lang),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primaryColor : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel ? AppTheme.primaryColor : AppTheme.primaryColor.withAlpha(60),
                  ),
                ),
                child: Text(
                  lang,
                  style: TextStyle(
                    color: sel ? Colors.black : Colors.white70,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BioField extends StatelessWidget {
  final TextEditingController controller;

  const _BioField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      maxLength: 150,
      decoration: const InputDecoration(
        labelText: 'Biografía (opcional)',
        hintText: 'Cuéntanos algo sobre ti...',
        hintStyle: TextStyle(color: Colors.white38),
        alignLabelWithHint: true,
      ),
    );
  }
}

class _FinishButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _FinishButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
            )
          : const Text('Finalizar'),
    );
  }
}
