import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../app_router.dart';
import '../widgets/app_header.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = await _api.post('/auth/login', {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      authProvider.setAuthData(
        accessToken: data['access_token'] as String,
        userId: data['account']['id'] as String,
        email: _emailController.text.trim(),
        telefono: data['account']['telefono'] as String?,
        personalizado: data['account']['personalizado'] as bool? ?? false,
      );
      final personalizado = data['account']['personalizado'] as bool? ?? false;
      if (personalizado) {
        context.go(AppRouter.home);
      } else {
        context.go(AppRouter.personalization);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signInWithGoogle();
      if (!mounted) return;
      
      final user = authProvider.user;
      if (user != null) {
        if (user.personalizado) {
          context.go(AppRouter.home);
        } else {
          context.go(AppRouter.personalization);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthProvider>().status;
    final isLoading = authStatus == AuthStatus.authenticating;

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
                  const AppHeader(logoSize: 100, fontSize: 36, spacing: 20),
                  const SizedBox(height: 40),
                  _GoogleLoginButton(onPressed: _signInWithGoogle, isLoading: isLoading),
                  const SizedBox(height: 20),
                  const _DividerWithText(),
                  const SizedBox(height: 20),
                  _EmailField(controller: _emailController),
                  const SizedBox(height: 20),
                  _PasswordField(
                    controller: _passwordController,
                    obscure: _obscurePassword,
                    onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  _ForgotPasswordButton(),
                  const SizedBox(height: 20),
                  _LoginButton(onPressed: _login, isLoading: _isLoading),
                  const SizedBox(height: 24),
                  _RegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _GoogleLoginButton({required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : SizedBox(
                width: 24,
                height: 24,
                child: SvgPicture.asset(
                  'assets/images/google_logo.svg',
                  placeholderBuilder: (_) => const Icon(Icons.g_mobiledata, size: 24, color: Color(0xFF4285F4)),
                ),
              ),
        label: Text(
          isLoading ? 'Conectando...' : 'Continuar con Google',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withAlpha(60)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  const _DividerWithText();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withAlpha(30))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'o con correo',
            style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withAlpha(30))),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;

  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingresa tu correo';
        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!emailRegex.hasMatch(value)) return 'Correo inválido';
        return null;
      },
      decoration: const InputDecoration(
        labelText: 'Correo electrónico',
        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
        if (value.length < 6) return 'Mínimo 6 caracteres';
        return null;
      },
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

class _ForgotPasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: const Text('¿Has olvidado tu contraseña?'),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _LoginButton({required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
          : const Text('Iniciar sesión'),
    );
  }
}

class _RegisterLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta? ',
          style: TextStyle(color: Colors.white.withAlpha(180)),
        ),
        TextButton(
          onPressed: () => context.push(AppRouter.signUp),
          child: const Text('Regístrate'),
        ),
      ],
    );
  }
}
