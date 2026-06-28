class PerfilBasico {
  final String perfilId;
  final String nombreUsuario;
  final String? fotoPerfil;

  PerfilBasico({
    required this.perfilId,
    required this.nombreUsuario,
    this.fotoPerfil,
  });

  factory PerfilBasico.fromJson(Map<String, dynamic> json) {
    return PerfilBasico(
      perfilId: json['perfil_id'] as String,
      nombreUsuario: json['nombre_usuario'] as String,
      fotoPerfil: json['foto_perfil'] as String?,
    );
  }
}
