import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/audio_model.dart';
import '../providers/audio_provider.dart';

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

Color _cardColorForDuration(double seconds) {
  if (seconds < 10) return const Color(0xFF1B3D1B);
  if (seconds < 15) return const Color(0xFF2D4D2D);
  if (seconds < 25) return const Color(0xFF4A4A1A);
  if (seconds < 45) return const Color(0xFF4D2E1A);
  return const Color(0xFF4D1A1A);
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
      context.read<AudioProvider>().loadAudios(widget.source);
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
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
      color: AppTheme.surfaceColor,
      items: [
        const PopupMenuItem(value: 'follow', child: ListTile(
          leading: Icon(Icons.person_add, color: Colors.white),
          title: Text('Seguir', style: TextStyle(color: Colors.white)),
          dense: true,
          contentPadding: EdgeInsets.zero,
        )),
        const PopupMenuItem(value: 'profile', child: ListTile(
          leading: Icon(Icons.person, color: Colors.white),
          title: Text('Ver perfil', style: TextStyle(color: Colors.white)),
          dense: true,
          contentPadding: EdgeInsets.zero,
        )),
      ],
    ).then((value) {
      if (value == 'follow') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Siguiendo a ${audio.nombreUsuario}'), backgroundColor: AppTheme.surfaceColor),
        );
      } else if (value == 'profile') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil de ${audio.nombreUsuario}'), backgroundColor: AppTheme.surfaceColor),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, _) {
        final audios = provider.audiosForSource(widget.source);
        if (provider.isLoading && audios.isEmpty) {
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
              onLike: () => provider.toggleLike(audio.id),
              onComment: () => _openComments(context, audio.id),
              onPlayPause: () {
                if (provider.currentAudio?.id == audio.id) {
                  provider.togglePlay();
                } else {
                  provider.play(audio);
                }
              },
              onLongPress: (pos) => _showCardMenu(context, audio, pos),
            );
          },
        );
      },
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
    final provider = context.watch<AudioProvider>();
    final progress = provider.listenProgress(audio.id);
    final isComplete = provider.isCompleted(audio.id);
    final circleValue = 1.0 - progress;
    final showRing = !isComplete && circleValue > 0.01;
    final isLiked = audio.isLiked;
    final isCurrentAudio = provider.currentAudio?.id == audio.id;
    final isCurrentlyPlaying = isCurrentAudio && provider.isPlaying;

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
              child: Image.network(
                'https://picsum.photos/seed//400/300',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: _cardColorForDuration(audio.duration)),
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
                child: isCurrentlyPlaying
                    ? const Icon(Icons.pause, size: 14, color: Colors.black)
                    : const Icon(Icons.music_note, size: 14, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (showRing)
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                              value: circleValue,
                              strokeWidth: 2.5,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                            ),
                          ),
                        CircleAvatar(
                          radius: 27,
                          backgroundImage: audio.fotoPerfil != null
                              ? NetworkImage(audio.fotoPerfil!)
                              : null,
                          onBackgroundImageError: (_, __) {},
                          child: audio.fotoPerfil == null
                              ? const Icon(Icons.person, size: 28, color: Colors.white70)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDuration(audio.duration),
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
                        _ScaleOnTap(
                          onTap: onLike,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: isLiked ? Colors.red : Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text('',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        _ScaleOnTap(
                          onTap: onComment,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chat_bubble, size: 20, color: Colors.white),
                              const SizedBox(width: 4),
                              Text('',
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

class _CommentsSheet extends StatefulWidget {
  final String audioId;
  const _CommentsSheet({required this.audioId});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();
  List<AudioCommentModel> _comments = [];
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
                                        Text(c.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
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


