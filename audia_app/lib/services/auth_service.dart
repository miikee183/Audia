import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

class AuthResult {
  final String accessToken;
  final String? email;
  final String userId;
  final bool personalizado;

  AuthResult({
    required this.accessToken,
    this.email,
    required this.userId,
    required this.personalizado,
  });
}

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _api = ApiService();

  Future<AuthResult> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Inicio de sesión cancelado');

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception('No se pudo obtener el token de Google');

    final data = await _api.post('/auth/google', {'id_token': idToken});

    return AuthResult(
      accessToken: data['access_token'] as String,
      email: data['account']['correoGoogle'] as String?,
      userId: data['account']['id'] as String,
      personalizado: data['account']['personalizado'] as bool? ?? false,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
