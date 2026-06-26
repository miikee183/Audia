import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../app_router.dart';
import '../widgets/app_header.dart';

class CodeVerificationScreen extends StatefulWidget {
  final String telefono;

  const CodeVerificationScreen({super.key, required this.telefono});

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = await _api.post('/auth/verify-code', {
        'telefono': widget.telefono,
        'codigo': _codeController.text.trim(),
      });
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      authProvider.setAuthData(
        accessToken: data['access_token'] as String,
        userId: data['account']['id'] as String,
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
                  const AppHeader(logoSize: 80, fontSize: 28, spacing: 12),
                  const SizedBox(height: 40),
                  const Text(
                    'Introduce código',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Se envió un código a tu número',
                    style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(180)),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, letterSpacing: 12, color: Colors.white),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '0000',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(60), fontSize: 32, letterSpacing: 12),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppTheme.primaryColor.withAlpha(80)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppTheme.primaryColor.withAlpha(80)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length != 4) return 'Ingresa el código de 4 dígitos';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Text('Verificar código', style: TextStyle(fontSize: 16)),
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
