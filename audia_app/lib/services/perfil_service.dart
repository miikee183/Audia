import 'package:audia/models/perfil_model.dart';
import 'api_service.dart';

class PerfilService {
  final ApiService _api = ApiService();

  Future<List<PerfilBasico>> obtenerPerfilesPorCuentas(List<String> cuentaIds) async {
    if (cuentaIds.isEmpty) return [];
    final response = await _api.post('/perfil/por-cuentas', {
      'cuenta_ids': cuentaIds,
    });
    final list = response as List<dynamic>;
    return list.map((j) => PerfilBasico.fromJson(j as Map<String, dynamic>)).toList();
  }
}
