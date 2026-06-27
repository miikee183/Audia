import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _prodBaseUrl = 'https://audia-5cjt.onrender.com';

  static String get baseUrl {
    const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
    if (isProduction) return _prodBaseUrl;
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static String? get token => _token;

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer ',
  };

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await _client
        .post(
          Uri.parse(''),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return {'data': decoded};
      return decoded as Map<String, dynamic>;
    }
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'Error del servidor');
  }

  Future<dynamic> get(String path) async {
    final response = await _client
        .get(
          Uri.parse(''),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'Error del servidor');
  }

  void dispose() => _client.close();
}


