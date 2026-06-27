class PerfilBasico {
  final String cuentaId;
  final String nombreUsuario;
  final String? fotoPerfil;

  PerfilBasico({
    required this.cuentaId,
    required this.nombreUsuario,
    this.fotoPerfil,
  });

  factory PerfilBasico.fromJson(Map<String, dynamic> json) {
    return PerfilBasico(
      cuentaId: json['cuenta_id'] as String,
      nombreUsuario: json['nombre_usuario'] as String,
      fotoPerfil: json['foto_perfil'] as String?,
    );
  }
}
