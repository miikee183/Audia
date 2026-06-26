import 'package:flutter/material.dart';
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
  final _formKey = GlobalKey<FormState>();
  
  int? _anoNacimiento;
  String _sexo = 'Otro';
  String _nombreUsuario = '';
  String _gustos = '';
  String _idioma = 'Español';

  bool _isLoading = false;
  final ApiService _api = ApiService();

  final List<String> _sexoOptions = ['Hombre', 'Mujer', 'Otro'];
  final List<String> _idiomaOptions = ['Español', 'Inglés', 'Francés', 'Portugués'];

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await _api.post('/personalizacion/', {
        'cuenta_id': user.userId,
        'ano_nacimiento': _anoNacimiento,
        'sexo': _sexo,
        'nombre_usuario': _nombreUsuario,
        'gustos': _gustos,
        'foto_perfil': null, // Por ahora nulo hasta implementar subida
        'idioma': _idioma,
      });

      if (!mounted) return;
      // Navegar a la pantalla principal
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configura tu Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Nombre de Usuario'),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      onSaved: (v) => _nombreUsuario = v!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Año de Nacimiento (ej. 1995)'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (int.tryParse(v) == null) return 'Debe ser un número';
                        return null;
                      },
                      onSaved: (v) => _anoNacimiento = int.parse(v!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _sexo,
                      decoration: const InputDecoration(labelText: 'Sexo'),
                      items: _sexoOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() => _sexo = newValue!);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Gustos e intereses', 
                          hintText: 'Ej. Música rock, tecnología, viajes'
                      ),
                      maxLines: 3,
                      onSaved: (v) => _gustos = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _idioma,
                      decoration: const InputDecoration(labelText: 'Idioma Principal'),
                      items: _idiomaOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() => _idioma = newValue!);
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Comenzar', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
