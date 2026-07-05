import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../l10n/app_strings.dart';

class ApiService {
  static const String _prodBaseUrl = 'https://audia-5cjt.onrender.com';

  static String get baseUrl {
    const bool isDev = bool.fromEnvironment('DEV', defaultValue: false);
    if (isDev) {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
      return 'http://localhost:8000';
    }
    return _prodBaseUrl;
  }

  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static String? get token => _token;

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await _client
        .post(
          Uri.parse('$baseUrl$path'),
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
    throw Exception(error['detail'] ?? AppStrings.serverError);
  }

  Future<dynamic> get(String path) async {
    final response = await _client
        .get(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? AppStrings.serverError);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final response = await _client
        .put(
          Uri.parse('$baseUrl$path'),
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
    throw Exception(error['detail'] ?? AppStrings.serverError);
  }

  void dispose() => _client.close();
}


