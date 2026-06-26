import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppHeader(logoSize: 100, fontSize: 36, spacing: 20),
                const SizedBox(height: 40),
                const _EmailField(),
                const SizedBox(height: 16),
                _PasswordField(
                  obscure: _obscurePassword,
                  onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 24),
                const _SignUpButton(),
                const SizedBox(height: 24),
                const _LoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Correo electrónico',
        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({required this.obscure, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.white54,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: const Text('Crear cuenta'),
    );
  }
}

class _LoginLink extends StatelessWidget {
  const _LoginLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes cuenta? ',
          style: TextStyle(color: Colors.white.withAlpha(180)),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Inicia sesión'),
        ),
      ],
    );
  }
}
