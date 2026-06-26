import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../models/country_code.dart';
import '../app_router.dart';
import '../widgets/app_header.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  CountryCode _selectedCountry = detectCountry();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;

    final fullPhone = '${_selectedCountry.code}${_phoneController.text.trim()}';

    setState(() => _isLoading = true);
    try {
      await _api.post('/auth/send-code', {'telefono': fullPhone});
      if (!mounted) return;
      context.go('${AppRouter.codeVerification}?telefono=$fullPhone');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                children: [
                  const AppHeader(),
                  const SizedBox(height: 48),
                  _PhoneField(
                    selectedCountry: _selectedCountry,
                    controller: _phoneController,
                    onCountryChanged: (c) => setState(() => _selectedCountry = c),
                  ),
                  const SizedBox(height: 32),
                  _VerifyButton(onPressed: _verify, isLoading: _isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountryPicker extends StatelessWidget {
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onChanged;

  const _CountryPicker({
    required this.selectedCountry,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withAlpha(80)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CountryCode>(
          value: selectedCountry,
          dropdownColor: AppTheme.surfaceColor,
          items: countries.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(
                '${c.flag} ${c.code}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final CountryCode selectedCountry;
  final TextEditingController controller;
  final ValueChanged<CountryCode> onCountryChanged;

  const _PhoneField({
    required this.selectedCountry,
    required this.controller,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CountryPicker(
          selectedCountry: selectedCountry,
          onChanged: onCountryChanged,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Ingresa tu número';
              if (value.length < 7) return 'Número inválido';
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'Número de teléfono',
              hintStyle: TextStyle(color: Colors.white38),
              labelStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}

class _VerifyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _VerifyButton({required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
          : const Text('Verifícate'),
    );
  }
}
