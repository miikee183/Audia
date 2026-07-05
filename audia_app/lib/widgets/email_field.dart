import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;

  const EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) return AppStrings.enterEmail;
        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!emailRegex.hasMatch(value)) return AppStrings.invalidEmail;
        return null;
      },
      decoration: InputDecoration(
        labelText: AppStrings.emailLabel,
        prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryColor),
      ),
    );
  }
}
