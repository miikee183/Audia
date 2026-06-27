import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audia/services/api_service.dart';
import 'package:audia/models/audio_model.dart';

class AudioService {
  final ApiService _api = ApiService();

  Future<List<AudioModel>> getAudios(String source) async {
    final response = await _api.get('/audio/?source=');
    final list = response['audios'] as List<dynamic>;
    return list.map((j) => AudioModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<AudioModel> uploadAudio(String filePath, double duration) async {
    final request = http.MultipartRequest('POST', Uri.parse('/audio/upload'));
    final token = ApiService.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer ';
    }
    request.fields['duration'] = duration.toString();
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return AudioModel.fromJson(body);
    }
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'Error al subir audio');
  }

  Future<Map<String, dynamic>> toggleLike(String audioId) async {
    return await _api.post('/audio//like', {});
  }

  Future<AudioCommentModel> addComment(String audioId, String text) async {
    final response = await _api.post('/audio//comment', {'text': text});
    return AudioCommentModel.fromJson(response);
  }

  Future<List<AudioCommentModel>> getComments(String audioId) async {
    final response = await _api.get('/audio//comments');
    final list = response as List<dynamic>;
    return list.map((j) => AudioCommentModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<void> updateProgress(String audioId, double progressSeconds, bool completed) async {
    await _api.post('/audio//progress', {
      'progress_seconds': progressSeconds,
      'completed': completed,
    });
  }

  void dispose() => _api.dispose();
}


