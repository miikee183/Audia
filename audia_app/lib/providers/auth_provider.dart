import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthUser {
  final String userId;
  final String? email;
  final String? telefono;
  final bool tienePerfil;
  final String accessToken;

  AuthUser({
    required this.userId,
    this.email,
    this.telefono,
    required this.tienePerfil,
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
      accessToken: result.accessToken,
    );

    _user = user;
    _api.setToken(user.accessToken);
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
      accessToken: data['access_token'] as String,
    );

    _user = user;
    _api.setToken(user.accessToken);
    notifyListeners();
  }

  void setAuthUser(AuthUser user) {
    _user = user;
    _api.setToken(user.accessToken);
    notifyListeners();
  }

  void markPerfilCreado() {
    if (_user != null) {
      _user = AuthUser(
        userId: _user!.userId,
        email: _user!.email,
        telefono: _user!.telefono,
        tienePerfil: true,
        accessToken: _user!.accessToken,
      );
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    _api.clearToken();
    notifyListeners();
  }
}
