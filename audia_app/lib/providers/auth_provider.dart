import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unauthenticated;
  AuthResult? _user;

  AuthStatus get status => _status;
  AuthResult? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> signInWithGoogle() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      _user = await _authService.signInWithGoogle();
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
