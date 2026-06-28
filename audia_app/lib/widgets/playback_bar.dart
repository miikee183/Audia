import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audia/theme/app_theme.dart';
import 'package:audia/models/audio_model.dart';
import 'package:audia/providers/audio_provider.dart';
import 'package:audia/widgets/profile_image.dart';

String _formatDuration(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${m}:${s.toString().padLeft(2, '0')}';
}

String _speedLabel(PlaybackSpeed speed) {
  switch (speed) {
    case PlaybackSpeed.x1: return 'x1';
    case PlaybackSpeed.x1_5: return 'x1.5';
    case PlaybackSpeed.x2: return 'x2';
    case PlaybackSpeed.x4: return 'x4';
  }
}

class PlaybackBar extends StatelessWidget {
  const PlaybackBar({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.select<AudioProvider, AudioModel?>(
      (p) => p.currentAudio,
    );
    if (audio == null) return const SizedBox.shrink();

    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ProfileImage(imageData: audio.fotoPerfil, radius: 18),
              const SizedBox(width: 10),
              Expanded(
                child: _PositionText(),
              ),
              _PlaybackControls(),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 22),
                onPressed: () => context.read<AudioProvider>().stop(),
                splashRadius: 18,
              ),
            ],
          ),
          const SizedBox(height: 4),
          _ProgressSlider(),
        ],
      ),
    );
  }
}

class _PositionText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pos = context.select<AudioProvider, Duration>((p) => p.position);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.select<AudioProvider, String>(
            (p) => p.currentAudio?.nombreUsuario ?? '',
          ),
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          _formatDuration(pos.inSeconds),
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isPlaying = context.select<AudioProvider, bool>((p) => p.isPlaying);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10, color: Colors.white, size: 22),
          onPressed: () => context.read<AudioProvider>().seekRelative(-10),
          splashRadius: 18,
        ),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: AppTheme.primaryColor, size: 32),
          onPressed: () => context.read<AudioProvider>().togglePlay(),
          splashRadius: 22,
        ),
        IconButton(
          icon: const Icon(Icons.forward_10, color: Colors.white, size: 22),
          onPressed: () => context.read<AudioProvider>().seekRelative(10),
          splashRadius: 18,
        ),
        GestureDetector(
          onTap: () {
            final p = context.read<AudioProvider>();
            final speeds = [PlaybackSpeed.x1, PlaybackSpeed.x1_5, PlaybackSpeed.x2];
            final idx = speeds.indexOf(p.speed);
            final next = speeds[(idx + 1) % speeds.length];
            p.setSpeed(next);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(60),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _speedLabel(context.select<AudioProvider, PlaybackSpeed>((p) => p.speed)),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pos = context.select<AudioProvider, Duration>((p) => p.position);
    final dur = context.select<AudioProvider, Duration>((p) => p.duration ?? Duration.zero);
    final progress = dur.inMilliseconds > 0 ? pos.inMilliseconds / dur.inMilliseconds : 0.0;

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        activeTrackColor: AppTheme.primaryColor,
        inactiveTrackColor: Colors.white12,
        thumbColor: AppTheme.primaryColor,
        overlayColor: AppTheme.primaryColor.withAlpha(30),
      ),
      child: Slider(
        value: progress.clamp(0.0, 1.0),
        onChanged: (v) {
          final seekPos = Duration(milliseconds: (v * dur.inMilliseconds).round());
          context.read<AudioProvider>().seek(seekPos);
        },
      ),
    );
  }
}