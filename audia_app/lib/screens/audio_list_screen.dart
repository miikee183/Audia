import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/audio_model.dart';
import '../providers/audio_provider.dart';
import '../providers/auth_provider.dart';
import '../services/perfil_service.dart';
import '../widgets/profile_image.dart';

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({super.key});

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audia', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          dividerColor: AppTheme.primaryColor.withAlpha(80),
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'Para ti'),
            Tab(text: 'Contactos'),
            Tab(text: 'Siguiendo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AudioGrid(source: 'para_ti'),
          _AudioGrid(source: 'contactos'),
          _AudioGrid(source: 'siguiendo'),
        ],
      ),
    );
  }
}

class _AudioGrid extends StatefulWidget {
  final String source;
  const _AudioGrid({required this.source});

  @override
  State<_AudioGrid> createState() => _AudioGridState();
}

class _AudioGridState extends State<_AudioGrid> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<AudioProvider>().loadAudios();
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

  void _showCardMenu(BuildContext context, AudioModel audio, Offset position) {
    final profileId = context.read<AuthProvider>().profileId;
    if (profileId != null && audio.idPerfilDueno == profileId) return;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
      color: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: [
        const PopupMenuItem(value: 'follow', child: SizedBox(
          width: 160,
          child: Row(
            children: [
              Icon(Icons.person_add, color: Color(0xFF64FFDA), size: 20),
              SizedBox(width: 12),
              Text('Seguir', style: TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
        )),
        const PopupMenuItem(value: 'profile', child: SizedBox(
          width: 160,
          child: Row(
            children: [
              Icon(Icons.person, color: Color(0xFF64FFDA), size: 20),
              SizedBox(width: 12),
              Text('Ver perfil', style: TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
        )),
      ],
    ).then((value) async {
      if (value == 'follow') {
        final perfilService = PerfilService();
        try {
          final siguiendo = await perfilService.toggleFollow(audio.idPerfilDueno);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(siguiendo ? 'Siguiendo a ${audio.nombreUsuario}' : 'Dejaste de seguir a ${audio.nombreUsuario}'),
              backgroundColor: AppTheme.surfaceColor,
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } else if (value == 'profile') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil de ${audio.nombreUsuario}'), backgroundColor: AppTheme.surfaceColor),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audios = context.select<AudioProvider, List<AudioModel>>(
      (p) => p.audiosForSource(widget.source),
    );
    final isLoading = context.select<AudioProvider, bool>((p) => p.isLoading);

    if (isLoading && audios.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }
    if (audios.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text('Sin audios aún', style: TextStyle(color: Colors.white38, fontSize: 16)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: audios.length,
      itemBuilder: (context, index) {
        final audio = audios[index];
        return _AudioCard(
          audio: audio,
          onLike: () => context.read<AudioProvider>().toggleLike(audio.id),
          onComment: () => _openComments(context, audio.id),
          onPlayPause: () {
            final p = context.read<AudioProvider>();
            if (p.currentAudio?.id == audio.id) {
              p.togglePlay();
            } else {
              p.play(audio);
            }
          },
          onLongPress: (pos) => _showCardMenu(context, audio, pos),
        );
      },
    );
  }
}

class _LikeButton extends StatefulWidget {
  final AudioModel audio;
  final VoidCallback onLike;
  const _LikeButton({required this.audio, required this.onLike});

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  late AudioProvider _provider;
  bool _isLiked = false;
  int _numLikes = 0;

  @override
  void initState() {
    super.initState();
    _provider = context.read<AudioProvider>();
    _sync();
    _provider.addListener(_onChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onChanged);
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

  @override
  Widget build(BuildContext context) {
    return _ScaleOnTap(
      onTap: widget.onLike,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: _isLiked ? Colors.red : Colors.white,
          ),
          const SizedBox(width: 3),
          Text('$_numLikes',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CommentButton extends StatefulWidget {
  final AudioModel audio;
  final VoidCallback onComment;
  const _CommentButton({required this.audio, required this.onComment});

  @override
  State<_CommentButton> createState() => _CommentButtonState();
}

class _CommentButtonState extends State<_CommentButton> {
  late AudioProvider _provider;
  int _numComentarios = 0;

  @override
  void initState() {
    super.initState();
    _provider = context.read<AudioProvider>();
    _numComentarios = _provider.audioById(widget.audio.id)?.numComentarios ?? widget.audio.numComentarios;
    _provider.addListener(_onChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    final newCount = _provider.audioById(widget.audio.id)?.numComentarios ?? widget.audio.numComentarios;
    if (newCount != _numComentarios) {
      setState(() => _numComentarios = newCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ScaleOnTap(
      onTap: widget.onComment,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble, size: 20, color: Colors.white),
          const SizedBox(width: 3),
          Text('$_numComentarios',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PlayStateIcon extends StatelessWidget {
  final String audioId;
  const _PlayStateIcon({required this.audioId});

  @override
  Widget build(BuildContext context) {
    final isPlaying = context.select<AudioProvider, bool>(
      (p) => p.currentAudio?.id == audioId && p.isPlaying,
    );
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha(180),
        borderRadius: BorderRadius.circular(6),
      ),
      child: isPlaying
          ? const Icon(Icons.pause, size: 14, color: Colors.black)
          : const Icon(Icons.music_note, size: 14, color: Colors.black),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 2.5) / 2;
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final startAngle = -1.5708 + progress * 6.2832;
    final sweepAngle = (1.0 - progress) * 6.2832;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _AudioProgressRing extends StatelessWidget {
  final String audioId;
  final Widget child;
  const _AudioProgressRing({required this.audioId, required this.child});

  @override
  Widget build(BuildContext context) {
    final progress = context.select<AudioProvider, double?>(
      (p) => p.progressForAudio(audioId),
    );
    final p = progress ?? 0.0;
    if (p >= 1.0) return child;
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(60, 60),
            painter: _RingPainter(p),
          ),
          child,
        ],
      ),
    );
  }
}

class _AudioCard extends StatelessWidget {
  final AudioModel audio;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onPlayPause;
  final void Function(Offset) onLongPress;

  const _AudioCard({
    required this.audio,
    required this.onLike,
    required this.onComment,
    required this.onPlayPause,
    required this.onLongPress,
  });

  String _formatDuration(double seconds) {
    final m = seconds ~/ 60;
    final s = seconds.round() % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: GestureDetector(
        onTap: onPlayPause,
        onLongPressStart: (details) => onLongPress(details.globalPosition),
        child: Stack(
          children: [
            Positioned.fill(
              child: _AudioBackground(fotoFondo: audio.fotoFondo, audioId: audio.id),
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
              child: _PlayStateIcon(audioId: audio.id),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AudioProgressRing(
                      audioId: audio.id,
                      child: ProfileImage(imageData: audio.fotoPerfil, radius: 27),
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
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _LikeButton(audio: audio, onLike: onLike),
                          _CommentButton(audio: audio, onComment: onComment),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

  Future<void> _toggleCommentLike(ComentarioModel c) async {
    final result = await context.read<AudioProvider>().toggleLikeComment(widget.audioId, c.id);
    if (mounted) {
      setState(() {
        c.isLiked = result['liked'] as bool;
        c.numLikes = (result['num_likes'] as num).toInt();
      });
    }
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
                                        const SizedBox(height: 4),
                                        GestureDetector(
                                          onTap: () => _toggleCommentLike(c),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                c.isLiked ? Icons.favorite : Icons.favorite_border,
                                                size: 16,
                                                color: c.isLiked ? Colors.red : Colors.white54,
                                              ),
                                              const SizedBox(width: 3),
                                              Text('${c.numLikes}',
                                                style: TextStyle(
                                                  color: c.isLiked ? Colors.red : Colors.white54,
                                                  fontSize: 12,
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

class _ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;
  const _ScaleOnTap({required this.child, required this.onTap, this.padding});

  @override
  State<_ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<_ScaleOnTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward().then((_) => _controller.reverse());
        widget.onTap();
      },
      child: Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => Transform.scale(
            scale: _animation.value,
            child: child,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _AudioBackground extends StatelessWidget {
  final String? fotoFondo;
  final String audioId;

  const _AudioBackground({required this.fotoFondo, required this.audioId});

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


