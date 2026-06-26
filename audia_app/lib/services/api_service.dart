import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'Error del servidor');
  }

  void dispose() => _client.close();
}
