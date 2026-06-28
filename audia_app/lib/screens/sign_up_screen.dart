import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../l10n/app_strings.dart';

class SignUpScreen extends StatefulWidget {
  final String? telefono;

  const SignUpScreen({super.key, this.telefono});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final api = ApiService();
    try {
      final body = <String, dynamic>{
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      };
      if (widget.telefono != null) body['telefono'] = widget.telefono;
      final data = await api.post('/auth/signup', body);
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      authProvider.setUserFromResult(data);
      context.go(AppRouter.personalization);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      api.dispose();
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
                  const AppHeader(logoSize: 100, fontSize: 36, spacing: 20),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return AppStrings.enterEmail;
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return AppStrings.invalidEmail;
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: AppStrings.emailLabel,
                      prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (v) {
                      if (v == null || v.isEmpty) return AppStrings.enterPassword;
                      if (v.length < 6) return AppStrings.minChars;
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: AppStrings.passwordLabel,
                      prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.white54,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : Text(AppStrings.createAccount),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.haveAccount, style: TextStyle(color: Colors.white.withAlpha(180))),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(AppStrings.logInLink),
                      ),
                    ],
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
