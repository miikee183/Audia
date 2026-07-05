import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import '../l10n/app_strings.dart';

class AuthResult {
  final String accessToken;
  final String? email;
  final String? telefono;
  final String userId;
  final bool tienePerfil;
  final String? profileId;

  AuthResult({
    required this.accessToken,
    this.email,
    this.telefono,
    required this.userId,
    required this.tienePerfil,
    this.profileId,
  });
}

class AuthService {
  late final GoogleSignIn _googleSignIn;
  final ApiService _api = ApiService();

  AuthService({String? iosClientId, String? serverClientId})
      : _googleSignIn = GoogleSignIn(
          clientId: iosClientId,
          serverClientId: serverClientId ?? _defaultWebClientId,
        );

  static const _defaultWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '615052367691-hi0gjbtauj2lb4ctd27ol69297j68274.apps.googleusercontent.com',
  );

  Future<AuthResult> signInWithGoogle({String? telefono, bool silent = false}) async {
    final account = silent ? await _googleSignIn.signInSilently() : await _googleSignIn.signIn();
    if (account == null) throw Exception(AppStrings.loginCancelled);

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception(AppStrings.googleTokenError);

    final body = <String, dynamic>{'id_token': idToken};
    if (telefono != null) body['telefono'] = telefono;
    final data = await _api.post('/auth/google', body);

    return AuthResult(
      accessToken: data['access_token'] as String,
      email: data['account']['correoGoogle'] as String?,
      telefono: data['account']['telefono'] as String?,
      userId: data['account']['id'] as String,
      tienePerfil: data['account']['tiene_perfil'] as bool? ?? false,
      profileId: data['account']['id_perfil'] as String?,
    );
  }

  Future<bool> verifySession() async {
    try {
      await _api.get('/auth/me');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
