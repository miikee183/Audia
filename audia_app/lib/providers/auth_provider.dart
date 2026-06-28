import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthUser {
  final String userId;
  final String? email;
  final String? telefono;
  final bool tienePerfil;
  final String? profileId;
  final String accessToken;

  AuthUser({
    required this.userId,
    this.email,
    this.telefono,
    required this.tienePerfil,
    this.profileId,
    required this.accessToken,
  });
}

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  AuthUser? _user;

  AuthUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAuthenticated => _user != null;

  Future<AuthUser> signInWithGoogle({String? telefono}) async {
    final service = AuthService();
    final result = await service.signInWithGoogle(telefono: telefono);

    final user = AuthUser(
      userId: result.userId,
      email: result.email,
      telefono: result.telefono,
      tienePerfil: result.tienePerfil,
      profileId: result.profileId,
      accessToken: result.accessToken,
    );

    _user = user;
    ApiService.setToken(user.accessToken);
    await _saveSession();
    notifyListeners();
    return user;
  }

  void setUserFromResult(dynamic data) {
    final account = data['account'] as Map<String, dynamic>;
    final user = AuthUser(
      userId: account['id'] as String,
      email: (account['correoGoogle'] ?? account['correoAudia']) as String?,
      telefono: account['telefono'] as String?,
      tienePerfil: account['tiene_perfil'] as bool? ?? false,
      profileId: account['id_perfil'] as String?,
      accessToken: data['access_token'] as String,
    );

    _user = user;
    ApiService.setToken(user.accessToken);
    _saveSession();
    notifyListeners();
  }

  void setAuthUser(AuthUser user) {
    _user = user;
    ApiService.setToken(user.accessToken);
    _saveSession();
    notifyListeners();
  }

  String? get profileId => _user?.profileId;

  void markPerfilCreado(String? profileId) {
    if (_user != null) {
      _user = AuthUser(
        userId: _user!.userId,
        email: _user!.email,
        telefono: _user!.telefono,
        tienePerfil: true,
        profileId: profileId ?? _user!.profileId,
        accessToken: _user!.accessToken,
      );
      _saveSession();
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    ApiService.setToken(null);
    _clearSession();
    notifyListeners();
  }

  Future<void> _saveSession() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', _user!.accessToken);
    await prefs.setString('userId', _user!.userId);
    if (_user!.email != null) await prefs.setString('email', _user!.email!);
    if (_user!.telefono != null) await prefs.setString('telefono', _user!.telefono!);
    await prefs.setBool('tienePerfil', _user!.tienePerfil);
    if (_user!.profileId != null) await prefs.setString('profileId', _user!.profileId!);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('telefono');
    await prefs.remove('tienePerfil');
    await prefs.remove('profileId');
  }

  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final userId = prefs.getString('userId');
    if (token == null || userId == null) return false;
    _user = AuthUser(
      userId: userId,
      email: prefs.getString('email'),
      telefono: prefs.getString('telefono'),
      tienePerfil: prefs.getBool('tienePerfil') ?? false,
      profileId: prefs.getString('profileId'),
      accessToken: token,
    );
    ApiService.setToken(token);
    try {
      await _api.get('/auth/me');
      notifyListeners();
      return true;
    } catch (_) {
      _user = null;
      ApiService.setToken(null);
      await _clearSession();
      return false;
    }
  }
}