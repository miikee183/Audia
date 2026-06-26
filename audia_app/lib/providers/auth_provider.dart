import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated }

class AuthProvider extends ChangeNotifier {
  late final AuthService _authService;

  AuthStatus _status = AuthStatus.unauthenticated;
  AuthResult? _user;

  AuthStatus get status => _status;
  AuthResult? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider({
    String? iosClientId,
    String? serverClientId,
  }) {
    _authService = AuthService(
      iosClientId: iosClientId,
      serverClientId: serverClientId,
    );
  }

  void setAuthData({
    required String accessToken,
    required String userId,
    String? email,
    String? telefono,
    required bool personalizado,
  }) {
    _user = AuthResult(
      accessToken: accessToken,
      email: email,
      telefono: telefono,
      userId: userId,
      personalizado: personalizado,
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> signInWithGoogle({String? telefono}) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      _user = await _authService.signInWithGoogle(telefono: telefono);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
