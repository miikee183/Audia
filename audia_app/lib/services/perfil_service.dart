import 'package:audia/models/perfil_model.dart';
import 'api_service.dart';

class PerfilService {
  final ApiService _api = ApiService();

  Future<List<PerfilBasico>> obtenerPerfilesPorIds(List<String> perfilIds) async {
    if (perfilIds.isEmpty) return [];
    final response = await _api.post('/perfil/por-ids', {
      'perfil_ids': perfilIds,
    });
    final list = response as List<dynamic>;
    return list.map((j) => PerfilBasico.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<bool> toggleFollow(String targetId) async {
    final response = await _api.post('/perfil/toggle-follow/$targetId', {});
    return response['siguiendo'] as bool;
  }

  Future<bool> toggleBlock(String targetId) async {
    final response = await _api.post('/perfil/block/$targetId', {});
    return response['bloqueado'] as bool;
  }

  Future<List<PerfilBasico>> obtenerBloqueados() async {
    final response = await _api.get('/perfil/bloqueados');
    final list = response as List<dynamic>;
    return list.map((j) => PerfilBasico.fromJson(j as Map<String, dynamic>)).toList();
  }
}
