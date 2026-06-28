import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audia/theme/app_theme.dart';
import 'package:audia/providers/audio_provider.dart';
import 'package:audia/models/audio_model.dart';
import 'package:audia/models/perfil_model.dart';
import 'package:audia/services/api_service.dart';
import 'package:audia/services/perfil_service.dart';
import 'package:audia/widgets/profile_image.dart';
import 'package:audia/helpers/formatters.dart';
import 'package:audia/l10n/app_strings.dart';
import 'package:audia/screens/edit_profile_screen.dart';
import 'package:audia/screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
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

  void loadProfile() => _loadProfile();

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

  Future<void> _showLista(String titulo, List<String> perfilIds) async {
    if (perfilIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.noData.replaceFirst('{label}', titulo))),
      );
      return;
    }

    List<PerfilBasico> perfiles;
    try {
      perfiles = await _perfilService.obtenerPerfilesPorIds(perfilIds);
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(AppStrings.noUsers, style: const TextStyle(color: Colors.white38)),
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
                      leading: ProfileImage(imageData: p.fotoPerfil, radius: 20),
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
        title: Text(AppStrings.profile, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        children: [
          Center(
            child: Column(
              children: [
                ProfileImage(imageData: _fotoPerfil, radius: 48),
                const SizedBox(height: 12),
                Text(
                  _nombreUsuario.isNotEmpty ? _nombreUsuario : AppStrings.userPlaceholder,
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
                  onTap: () => _showLista(AppStrings.following, _listaSiguiendo),
                  child: _Stat(count: formatCount(_numSiguiendo), label: AppStrings.following),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showLista(AppStrings.followers, _listaSeguidores),
                  child: _Stat(count: formatCount(_numSeguidores), label: AppStrings.followers),
                ),
              ),
              Expanded(child: _Stat(count: formatCount(_likesTotales), label: AppStrings.likes)),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _biografia.isNotEmpty ? _biografia : AppStrings.noBio,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                flex: 7,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          currentUsername: _nombreUsuario,
                          currentBio: _biografia,
                          currentPhoto: _fotoPerfil,
                        ),
                      ),
                    );
                    if (result == true) _loadProfile();
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(AppStrings.editProfile),
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
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A3A3A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Icon(Icons.settings, size: 22),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Text(AppStrings.myAudios, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_misAudios.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text(AppStrings.noAudiosYet, style: const TextStyle(color: Colors.white38))),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _misAudios.length,
              itemBuilder: (context, index) {
                final audio = _misAudios[index];
                return _ProfileAudioCard(
                  audio: audio,
                  onPlayPause: () {
                    final p = context.read<AudioProvider>();
                    if (p.currentAudio?.id == audio.id) {
                      p.togglePlay();
                    } else {
                      p.play(audio);
                    }
                  },
                  onLike: () => context.read<AudioProvider>().toggleLike(audio.id),
                  onComment: () => _openComments(context, audio.id),
                );
              },
            ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    final names = <String>[
      AppStrings.month1, AppStrings.month2, AppStrings.month3,
      AppStrings.month4, AppStrings.month5, AppStrings.month6,
      AppStrings.month7, AppStrings.month8, AppStrings.month9,
      AppStrings.month10, AppStrings.month11, AppStrings.month12,
    ];
    return names[month - 1];
  }

  String _fmt(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _ProfileLikeButton extends StatefulWidget {
  final AudioModel audio;
  final VoidCallback onLike;
  const _ProfileLikeButton({required this.audio, required this.onLike});

  @override
  State<_ProfileLikeButton> createState() => _ProfileLikeButtonState();
}

class _ProfileLikeButtonState extends State<_ProfileLikeButton>
    with SingleTickerProviderStateMixin {
  late AudioProvider _provider;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLiked = false;
  int _numLikes = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _provider = context.read<AudioProvider>();
    _sync();
    _provider.addListener(_onChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _sync() {
    final a = _provider.audioById(widget.audio.id);
    _isLiked = a?.isLiked ?? widget.audio.isLiked;
    _numLikes = a?.numLikes ?? widget.audio.numLikes;
  }

  void _onChanged() {
    if (!mounted) return;
    final a = _provider.audioById(widget.audio.id);
    final newLiked = a?.isLiked ?? widget.audio.isLiked;
    final newNumLikes = a?.numLikes ?? widget.audio.numLikes;
    if (newLiked != _isLiked || newNumLikes != _numLikes) {
      setState(() {
        _isLiked = newLiked;
        _numLikes = newNumLikes;
      });
    }
  }

  void _onTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onLike();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) => Transform.scale(
              scale: _animation.value,
              child: child,
            ),
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: _isLiked ? Colors.red : Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text('$_numLikes',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
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
            child: _ProfileAudioBackground(fotoFondo: audio.fotoFondo, audioId: audio.id),
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
                ProfileImage(imageData: audio.fotoPerfil, radius: 27),
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
                      _ProfileLikeButton(audio: audio, onLike: onLike),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(AppStrings.comments, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  : _comments.isEmpty
                      ? Center(child: Text(AppStrings.noComments, style: const TextStyle(color: Colors.white38)))
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
                                  ProfileImage(imageData: c.fotoPerfil, radius: 16),
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
                        hintText: AppStrings.writeComment,
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

class _ProfileAudioBackground extends StatelessWidget {
  final String? fotoFondo;
  final String audioId;

  const _ProfileAudioBackground({required this.fotoFondo, required this.audioId});

  @override
  Widget build(BuildContext context) {
    if (fotoFondo != null && fotoFondo!.startsWith('#')) {
      final hex = fotoFondo!.replaceFirst('#', '');
      final color = Color(int.parse('FF$hex', radix: 16));
      return Container(color: color);
    }
    if (fotoFondo != null && (fotoFondo!.startsWith('http://') || fotoFondo!.startsWith('https://'))) {
      return CachedNetworkImage(
        imageUrl: fotoFondo!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => Container(color: const Color(0xFF1A1A2E)),
      );
    }
    return CachedNetworkImage(
      imageUrl: 'https://picsum.photos/seed/$audioId/400/300',
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => Container(color: const Color(0xFF1A1A2E)),
    );
  }
}
