import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audia/theme/app_theme.dart';
import 'package:audia/providers/audio_provider.dart';
import 'package:audia/models/audio_model.dart';
import 'package:audia/models/perfil_model.dart';
import 'package:audia/services/api_service.dart';
import 'package:audia/services/perfil_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  final PerfilService _perfilService = PerfilService();
  bool _loading = true;
  String _nombreUsuario = '';
  String? _fotoPerfil;
  String _biografia = '';
  int _numSeguidores = 0;
  int _numSiguiendo = 0;
  int _likesTotales = 0;
  List<String> _listaSeguidores = [];
  List<String> _listaSiguiendo = [];
  List<AudioModel> _misAudios = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final me = await _api.get('/auth/me');
      final account = me['account'] as Map<String, dynamic>;
      _nombreUsuario = account['nombre_usuario'] as String? ?? '';
      _fotoPerfil = account['foto_perfil'] as String?;
      _biografia = account['biografia'] as String? ?? '';
      _numSeguidores = account['num_seguidores'] as int? ?? 0;
      _numSiguiendo = account['num_siguiendo'] as int? ?? 0;
      _likesTotales = account['likes_totales'] as int? ?? 0;
    } catch (_) {}

    try {
      final detalle = await _api.get('/perfil/detalle');
      _listaSeguidores = List<String>.from(detalle['lista_seguidores'] ?? []);
      _listaSiguiendo = List<String>.from(detalle['lista_siguiendo'] ?? []);
    } catch (_) {}

    try {
      final audiosResp = await _api.get('/audio/mis-audios');
      final list = audiosResp['audios'] as List<dynamic>? ?? [];
      _misAudios = list.map((j) => AudioModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {}

    setState(() => _loading = false);
  }

  Future<void> _showLista(String titulo, List<String> cuentaIds) async {
    if (cuentaIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay $titulo')),
      );
      return;
    }

    List<PerfilBasico> perfiles;
    try {
      perfiles = await _perfilService.obtenerPerfilesPorCuentas(cuentaIds);
    } catch (_) {
      perfiles = [];
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (perfiles.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text('No hay usuarios', style: TextStyle(color: Colors.white38)),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: perfiles.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (_, i) {
                    final p = perfiles[i];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryColor.withAlpha(60),
                        backgroundImage: p.fotoPerfil != null ? NetworkImage(p.fotoPerfil!) : null,
                        child: p.fotoPerfil == null
                            ? const Icon(Icons.person, size: 20, color: Colors.white70)
                            : null,
                      ),
                      title: Text(p.nombreUsuario, style: const TextStyle(color: Colors.white)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.calendar_month, color: Colors.white70),
          onPressed: () {},
        ),
        title: const Text('Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.primaryColor.withAlpha(60),
                  backgroundImage: _fotoPerfil != null ? NetworkImage(_fotoPerfil!) : null,
                  child: _fotoPerfil == null
                      ? const Icon(Icons.person, size: 48, color: Colors.white70)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  _nombreUsuario.isNotEmpty ? _nombreUsuario : 'Usuario',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showLista('Siguiendo', _listaSiguiendo),
                  child: _Stat(count: '$_numSiguiendo', label: 'Siguiendo'),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showLista('Seguidores', _listaSeguidores),
                  child: _Stat(count: '$_numSeguidores', label: 'Seguidores'),
                ),
              ),
              Expanded(child: _Stat(count: '$_likesTotales', label: 'Likes')),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _biografia.isNotEmpty ? _biografia : 'Sin biografía',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Editar perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF81D4FA),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          const Text('Mis audios', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_misAudios.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('No has subido audios aún', style: TextStyle(color: Colors.white38))),
            )
          else
            Consumer<AudioProvider>(
              builder: (context, provider, _) {
                final sorted = _misAudios.reversed.toList();
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final audio = sorted[index];
                    return _ProfileAudioCard(
                      audio: audio,
                      onPlayPause: () {
                        if (provider.currentAudio?.id == audio.id) {
                          provider.togglePlay();
                        } else {
                          provider.play(audio);
                        }
                      },
                      onLike: () => provider.toggleLike(audio.id),
                      onComment: () => _openComments(context, audio.id),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return names[month - 1];
  }

  String _fmt(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

Color _cardColorForDuration(double seconds) {
  if (seconds < 10) return const Color(0xFF1B3D1B);
  if (seconds < 15) return const Color(0xFF2D4D2D);
  if (seconds < 25) return const Color(0xFF4A4A1A);
  if (seconds < 45) return const Color(0xFF4D2E1A);
  return const Color(0xFF4D1A1A);
}

class _ProfileAudioCard extends StatelessWidget {
  final AudioModel audio;
  final VoidCallback onPlayPause;
  final VoidCallback onLike;
  final VoidCallback onComment;
  const _ProfileAudioCard({
    required this.audio,
    required this.onPlayPause,
    required this.onLike,
    required this.onComment,
  });

  String _formatDuration(double seconds) {
    final m = seconds ~/ 60;
    final s = seconds.round() % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPlayPause,
      child: Card(
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://picsum.photos/seed/${audio.id}/400/300',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: _cardColorForDuration(audio.duracion)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(180),
                    Colors.black.withAlpha(200),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(180),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.music_note, size: 14, color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 27,
                  child: audio.fotoPerfil != null
                      ? CircleAvatar(
                          radius: 27,
                          backgroundImage: NetworkImage(audio.fotoPerfil!),
                        )
                      : const Icon(Icons.person, size: 28, color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDuration(audio.duracion),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  audio.nombreUsuario,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: onLike,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              audio.isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: audio.isLiked ? Colors.red : Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text('${audio.numLikes}',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onComment,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chat_bubble, size: 20, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('${audio.numComentarios}',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String count;
  final String label;

  const _Stat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }
}

void _openComments(BuildContext context, String audioId) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surfaceColor,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _CommentsSheet(audioId: audioId),
  );
}

class _CommentsSheet extends StatefulWidget {
  final String audioId;
  const _CommentsSheet({required this.audioId});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();
  List<ComentarioModel> _comments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final provider = context.read<AudioProvider>();
      final comments = await provider.getComments(widget.audioId);
      if (mounted) {
        setState(() {
          _comments = comments;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    try {
      final provider = context.read<AudioProvider>();
      final comment = await provider.addComment(widget.audioId, text);
      if (mounted) {
        setState(() {
          _comments.insert(0, comment);
          _controller.clear();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Comentarios',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  : _comments.isEmpty
                      ? const Center(child: Text('Sin comentarios', style: TextStyle(color: Colors.white38)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final c = _comments[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppTheme.primaryColor.withAlpha(60),
                                    backgroundImage: c.fotoPerfil != null ? NetworkImage(c.fotoPerfil!) : null,
                                    child: c.fotoPerfil == null
                                        ? const Icon(Icons.person, size: 16, color: Colors.white70)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.nombreUsuario,
                                          style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(c.texto, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Escribe un comentario...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendComment,
                    icon: const Icon(Icons.send_rounded, color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
