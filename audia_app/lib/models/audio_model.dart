class AudioModel {
  final String id;
  final String userId;
  final String nombreUsuario;
  final String? fotoPerfil;
  final String cloudinaryUrl;
  final double duration;
  int likeCount;
  int commentCount;
  bool isLiked;
  double listenProgress;
  bool isCompleted;
  final DateTime createdAt;

  AudioModel({
    required this.id,
    required this.userId,
    required this.nombreUsuario,
    this.fotoPerfil,
    required this.cloudinaryUrl,
    required this.duration,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.listenProgress,
    required this.isCompleted,
    required this.createdAt,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nombreUsuario: json['nombre_usuario'] as String,
      fotoPerfil: json['foto_perfil'] as String?,
      cloudinaryUrl: json['cloudinary_url'] as String,
      duration: (json['duration'] as num).toDouble(),
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      listenProgress: (json['listen_progress'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'nombre_usuario': nombreUsuario,
    'foto_perfil': fotoPerfil,
    'cloudinary_url': cloudinaryUrl,
    'duration': duration,
    'like_count': likeCount,
    'comment_count': commentCount,
    'is_liked': isLiked,
    'listen_progress': listenProgress,
    'is_completed': isCompleted,
    'created_at': createdAt.toIso8601String(),
  };
}

class AudioCommentModel {
  final String id;
  final String userId;
  final String nombreUsuario;
  final String? fotoPerfil;
  final String text;
  final int likeCount;
  final bool isLiked;
  final DateTime createdAt;

  AudioCommentModel({
    required this.id,
    required this.userId,
    required this.nombreUsuario,
    this.fotoPerfil,
    required this.text,
    required this.likeCount,
    required this.isLiked,
    required this.createdAt,
  });

  factory AudioCommentModel.fromJson(Map<String, dynamic> json) {
    return AudioCommentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nombreUsuario: json['nombre_usuario'] as String,
      fotoPerfil: json['foto_perfil'] as String?,
      text: json['text'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}


