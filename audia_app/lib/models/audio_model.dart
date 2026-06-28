class AudioModel {
  final String id;
  final String idPerfilDueno;
  final String nombreUsuario;
  final String? fotoPerfil;
  final String audioUrl;
  final double duracion;
  int numLikes;
  int numComentarios;
  final String? fotoFondo;
  bool isLiked;

  AudioModel({
    required this.id,
    required this.idPerfilDueno,
    required this.nombreUsuario,
    this.fotoPerfil,
    required this.audioUrl,
    required this.duracion,
    required this.numLikes,
    required this.numComentarios,
    this.fotoFondo,
    required this.isLiked,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      id: json['id'] as String,
      idPerfilDueno: json['id_perfil_dueno'] as String,
      nombreUsuario: json['nombre_usuario'] as String,
      fotoPerfil: json['foto_perfil'] as String?,
      audioUrl: json['audio_url'] as String,
      duracion: (json['duracion'] as num).toDouble(),
      numLikes: json['num_likes'] as int? ?? 0,
      numComentarios: json['num_comentarios'] as int? ?? 0,
      fotoFondo: json['foto_fondo'] as String?,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_perfil_dueno': idPerfilDueno,
    'nombre_usuario': nombreUsuario,
    'foto_perfil': fotoPerfil,
    'audio_url': audioUrl,
    'duracion': duracion,
    'num_likes': numLikes,
    'num_comentarios': numComentarios,
    'foto_fondo': fotoFondo,
    'is_liked': isLiked,
  };
}

class ComentarioModel {
  final String id;
  final String idPerfilDuenoComentario;
  final String nombreUsuario;
  final String? fotoPerfil;
  final String texto;
  int numLikes;
  bool isLiked;

  ComentarioModel({
    required this.id,
    required this.idPerfilDuenoComentario,
    required this.nombreUsuario,
    this.fotoPerfil,
    required this.texto,
    required this.numLikes,
    required this.isLiked,
  });

  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    return ComentarioModel(
      id: json['id'] as String,
      idPerfilDuenoComentario: json['id_perfil_dueno_comentario'] as String,
      nombreUsuario: json['nombre_usuario'] as String,
      fotoPerfil: json['foto_perfil'] as String?,
      texto: json['texto'] as String,
      numLikes: json['num_likes'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }
}
