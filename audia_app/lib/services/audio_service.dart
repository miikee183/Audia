import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audia/services/api_service.dart';
import 'package:audia/models/audio_model.dart';

class AudioService {
  final ApiService _api = ApiService();

  Future<List<AudioModel>> getAudios() async {
    final response = await _api.get('/audio/');
    final list = response['audios'] as List<dynamic>;
    return list.map((j) => AudioModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<AudioModel> uploadAudio(String filePath, double duracion, {String? fotoFondo, String? fondoImagePath}) async {
    final request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/audio/upload'));
    final token = ApiService.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields['duracion'] = duracion.toString();
    if (fotoFondo != null) request.fields['foto_fondo'] = fotoFondo;
    if (fondoImagePath != null) request.files.add(await http.MultipartFile.fromPath('fondo_file', fondoImagePath));
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return AudioModel.fromJson(body);
    }
    try {
      final error = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(error['detail'] ?? 'Error del servidor');
    } catch (_) {
      throw Exception('Error del servidor (${response.statusCode}): ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
    }
  }

  Future<Map<String, dynamic>> toggleLike(String audioId) async {
    return await _api.post('/audio/$audioId/like', {});
  }

  Future<ComentarioModel> addComment(String audioId, String texto) async {
    final response = await _api.post('/audio/$audioId/comentario', {'texto': texto});
    return ComentarioModel.fromJson(response);
  }

  Future<List<ComentarioModel>> getComments(String audioId) async {
    final response = await _api.get('/audio/$audioId/comentarios');
    final list = response as List<dynamic>;
    return list.map((j) => ComentarioModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> toggleLikeComment(String audioId, String comentarioId) async {
    return await _api.post('/audio/$audioId/comentario/$comentarioId/like', {});
  }

  void dispose() => _api.dispose();
}
