import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

class AuthResult {
  final String accessToken;
  final String? email;
  final String? telefono;
  final String userId;
  final bool personalizado;

  AuthResult({
    required this.accessToken,
    this.email,
    this.telefono,
    required this.userId,
    required this.personalizado,
  });
}

class AuthService {
  final GoogleSignIn _googleSignIn;
  final ApiService _api = ApiService();

  AuthService({String? iosClientId, String? serverClientId})
      : _googleSignIn = GoogleSignIn(
          clientId: iosClientId,
          serverClientId: serverClientId,
        );

  Future<AuthResult> signInWithGoogle({String? telefono}) async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Inicio de sesión cancelado');

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception('No se pudo obtener el token de Google');

    final body = <String, dynamic>{'id_token': idToken};
    if (telefono != null) body['telefono'] = telefono;
    final data = await _api.post('/auth/google', body);

    return AuthResult(
      accessToken: data['access_token'] as String,
      email: data['account']['correoGoogle'] as String?,
      telefono: data['account']['telefono'] as String?,
      userId: data['account']['id'] as String,
      personalizado: data['account']['personalizado'] as bool? ?? false,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

